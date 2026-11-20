# NPC Relationships

> **Status**: In Design
> **Author**: user + Claude
> **Last Updated**: 2026-11-20
> **Last Verified**: 2026-11-20
> **Implements Pillar**: Pillar 5 "A World That Remembers"; Pillar 4 "Every Season Counts"
> **Creative Director Review (CD-GDD-ALIGN)**: REVISED 2026-11-20 — concern 1 (Pillar 4: free help calls and errands)
> revised with `help_cost` and `errand_cost`; concern 2 (Pillar 3: flat master and đạo lữ cultivation rows) CONCERNS
> (accepted) 2026-11-20: the bond is the built asset. Player Fantasy not authored at the standard tier, so not checked.

## Summary

NPC Relationships stores the lasting bonds and grudges between people (kin, master and disciple, sworn siblings, Dao
companions, companions, friends, rivals, debts of gratitude, enmity and blood feuds) as a small capped set of records
on top of NPC Traits' computed opinion. Ties form from events, fights, rescues, betrayals and the player's bond verbs,
fade, harden and pass to heirs at death, and each pinned kind gives one build hook (cultivation speed from a master or
đạo lữ, a sworn sibling's help in a fight, a companion's blows, disciples' errands). It exists so the world remembers
who helped and who wronged whom (Pillar 5).

> **Quick reference** — Layer: `Feature` · Priority: `To decide (Alpha provisional)` · Key deps: `World DB, Save/Load, Living World Tick, NPC Traits, Event Engine, Time & Turn; soft: NPC Interaction & Dialogue, Power Rankings, Sects & Missions, World Generation, Realms`

## Overview

NPC Relationships gives the world's cultivators lasting bonds and grudges: master and disciple (sư đồ), sworn siblings
(kết nghĩa), Dao companions (đạo lữ), the player's companions (đồng hành), friends, rivals, enmity (thù hận) and blood
feuds (huyết thù), debts of gratitude (ân tình), and family. Ties form, strengthen, weaken and end through the season
tick, events, fights and sect life, and death can pass a feud or a debt on to disciples and kin. Ties change what NPCs
do (who helps, who takes revenge, who succeeds a sect head), what the player is offered (quests, conversation, bond
verbs) and what the player can build on (one hook per bond kind), and narration (authored, or the LLM Game Master when
enabled) can tell them.

Under the hood it is a **sparse stored layer on top of computed opinion**. Opinion between two people stays computed from
traits as NPC Traits rule 16 says; this system stores only the named ties that have formed, one small record per pair
(kinds, strength, last change), capped per person so the save stays cheap across 5,000 cultivators. Every person can
hold ties; **notable people** (the fixed cast, sect heads and elders, Nguyên Anh and above, anyone the player has met)
have a higher cap and may start kết nghĩa and đạo lữ. Pinned ties (kin, sư đồ, kết nghĩa, đạo lữ, companion, blood feud)
are never evicted; soft ties (friend, rival, ân tình, enmity) compete for the remaining slots and fade. The player's ties use the same record; the stored attitude to the player (Quests, Formulas E)
is unchanged. Rule 16 is amended: ties are the one stored exception, and reading an opinion never creates or changes a
tie.

Without it the world is a crowd of strangers whose only links are traits and sect membership. Pillar 5, "A World That
Remembers", needs a death to leave a feud, a rescue to leave a debt, and a disciple to carry a master's name.

## Detailed Design

### Core Rules

**The record**

1. **One record per pair.** A tie is stored as one record between two people `(a, b)`, indexed from both sides. A record
   holds a **set of pinned kinds** (flags: a father who is also his son's master holds kin and sư đồ; a kinslayer's
   kin hold kin and blood feud) and at most **one soft kind** (a master and disciple who fell out hold sư đồ and
   enmity together). Fields: the two ids, pinned flags, soft kind, direction, strength (soft kind only), and
   `last_season` (the season the soft strength was last set). A record counts once against each person's cap,
   whatever it holds.
2. **Tie kinds.**

   | Kind | Class | Direction | Notes |
   |---|---|---|---|
   | Kin (thân tộc) | pinned | both | Parent, child, sibling only. Wider clan is a `clan_id` on the person, not a tie |
   | Sư đồ (master and disciple) | pinned | master → disciple | A disciple has at most one living master |
   | Kết nghĩa (sworn siblings) | pinned | both | |
   | Đạo lữ (Dao companion) | pinned | both | At most one living đạo lữ per person |
   | Blood feud (huyết thù) | pinned | holder → target, or both | Hardened enmity (rule 11); passes to heirs (rule 13) |
   | Companion (đồng hành) | pinned | both | Player and NPC only, from the recruit verb (NPC Interaction & Dialogue rule 11); ends when dismissed or when the NPC leaves |
   | Friend (bằng hữu) | soft | both | |
   | Rival (đối thủ) | soft | both | Competitive respect, not hatred |
   | Debt of gratitude (ân tình) | soft | debtor → creditor | |
   | Enmity (thù hận) | soft | holder → target, or both | |

   Pinned ties have no strength; their weight is fixed per kind (Formulas). Soft ties carry a strength.
3. **Opinion stays computed (amends NPC Traits rule 16).** Opinion is still derived on demand from NPC Traits F3. The
   `tie(a, b)` term reads this system's record: the largest positive pinned value, plus a blood feud's negative value,
   plus the soft kind's value at its current strength (Formula A). Ties are the one stored exception to rule 16. **Reading an opinion or a tie never creates,
   changes or removes a record**, so AC-NT-21 (save byte-identical after 1,000,000 reads) keeps holding.
4. **Soft strength fades lazily.** A soft tie's current strength is computed when read from its stored strength and
   the seasons since `last_season` (Formulas). Nothing scans ties per season; a tie whose current strength has fallen
   to 0 is removed the next time either person is touched by rule 7.

**Caps**

5. **Cap per person.** An ordinary person holds at most `cap_ordinary` (6) ties; a **notable** person at most
   `cap_notable` (16). Pinned ties count inside the cap. The player uses `cap_notable`.
6. **Notable** is computed when a tie is added, never stored: a fixed-cast member, a sect head or elder, a Nguyên Anh
   or higher cultivator, or anyone the player has met. Notable people may also hold the two kinds an ordinary person
   cannot start: kết nghĩa and đạo lữ form only when at least one of the two is notable, or by an authored event.
   (The fuller "richer records" set for notable people is Open Question 1.)
7. **Eviction.** When a new tie would exceed a person's cap, the weakest soft tie (lowest current strength; ties broken
   by the oldest `last_season`, then the lower partner id) is removed, from both sides. Pinned ties are never evicted.
   A new **pinned** tie always forms, even when the person's ties are all pinned (overflow is allowed for pinned ties
   only). A new **soft** tie does not form if every slot is pinned or every existing soft tie is stronger than it.
   A person who stops being notable keeps their ties; the next tie added to them evicts soft ties down to
   `cap_ordinary` first.

**Forming and changing ties**

8. **No per-pair roll.** Ties change only through these sources, never through a scan of all pairs:
   - **Event Engine outcomes**: `tie_add`, `tie_strengthen`, `tie_weaken`, `tie_end` effects, inside the event budgets.
   - **Power Rankings world fights**: a close fight can form a rivalry; a crippling or killing blow forms enmity in the
     loser's side (and in the loser's kin and disciples on a kill, rule 13).
   - **Rescues and betrayals** reported by the tick or by events: a rescue forms ân tình (debtor = the rescued); a
     betrayal turns a pinned kết nghĩa, đạo lữ or sư đồ into enmity (rule 12).
   - **Sect life**: taking a disciple forms sư đồ; succession reads it (Sects).
   - **The player's bond verbs** through NPC Interaction & Dialogue: ask to become a disciple, take a disciple, propose
     kết nghĩa or đạo lữ, repay a debt, declare enmity.
   - **World Generation**: authored kin, sư đồ, kết nghĩa and đạo lữ at the start, plus generated kin for ordinary
     people.
9. **One tick step.** Changes from a season's sources are queued and applied in the Living World Tick's reserved step
   **S8b**, after S8 (events), in this order: deaths and inheritance (rule 13), ends, hardening (rule 11), new ties
   with eviction (rule 7), strength changes. Only people named in a queued change are touched. The player's bond
   verbs apply at once, outside the tick.
10. **Strengthening a soft tie** sets its stored strength to the new value and `last_season` to now. Adding a soft
    kind that differs from the pair's current soft kind replaces it when the new kind's strength is greater, and is
    dropped otherwise (one soft kind per record, rule 1).

**Hardening, breaking and inheritance**

11. **Enmity hardens into a blood feud** when its strength reaches `feud_threshold`, or at once when the target kills
    the holder's kin, master, disciple, kết nghĩa or đạo lữ. The soft enmity is removed and a pinned blood feud is
    set.
12. **Betrayal breaks a pinned bond.** An event that marks a betrayal removes the pinned kết nghĩa, đạo lữ or sư đồ
    and sets soft enmity in the betrayed person toward the betrayer. Kin is never removed by betrayal; it gains a soft
    enmity alongside.
13. **Death passes ties on.** When a person dies, before their records are removed:
    - **Heirs** are the dead person's children (eldest first), then disciples (longest-held first), at most
      `inherit_feud_max` of them. Other kin, other disciples and kết nghĩa are **mourners**.
    - Each **blood feud** the dead held passes to the heirs as a pinned blood feud toward the same target, marked
      *inherited*, and to mourners as soft enmity at `inherit_enmity` strength.
    - If the death was a **kill and the killer is known** (the event log names them as seen or reported; a killing no
      one knows of leaves no feud), the heirs gain an inherited blood feud toward the killer and the mourners soft
      enmity at `inherit_enmity`.
    - An **inherited** blood feud passes on at its holder's death only as soft enmity, never as a pinned feud, so a
      vendetta fades over generations unless a new kill renews it.
    - **Ân tình owed to** the dead passes to the heirs at `inherit_debt` strength (the debtor now owes the heirs).
      Ân tình the dead owed is cancelled.
    - **Loans are not ties** (NPC Interaction & Dialogue OQ 2): a dead lender's loan is written off as Dialogue rule
      already says, and a dead borrower's loan is cancelled; neither passes to heirs.
    - All other ties of the dead are removed. The event log keeps the history.
    - Inheritance obeys each heir's and mourner's cap (rule 7). A dead person passes ties on once; ties inherited this
      season do not pass on again in the same season.
14. **Ending.** A tie ends by death (rule 13), by fading to 0 (rule 4), by eviction (rule 7), by betrayal (rule 12), by
    repaying a debt (an event or a player verb; a repaid debt becomes a friend tie at `repay_friend` strength), or by
    an Event Engine `tie_end`. Kin ends only by death. A **blood feud or enmity ends when its target dies**; when the
    holder or one of their close ties made the kill, the news calls it avenged (báo thù).
14a. **Vendettas are damped, not banned.** Revenge is a Living World Tick choice weighted by ties, inside the tick's
    budget of violent deaths a season (Living World Tick Open Question 4), so blood feuds cannot drive the death rate
    past Realms' headcounts. Revenge never raises a feud's strength by itself; only new deeds do.

**What ties change**

15. Ties feed other systems; this system owns the records, not their behaviour:
    - **Opinion** through F3 `tie` (rule 3), and through it everything that reads opinion.
    - **Event conditions**: events may test "has tie of kind K with b", "has blood feud", and the strength.
    - **Living World Tick actions**: who helps whom and who seeks revenge are tick choices weighted by ties.
    - **Sect succession** prefers the head's disciples (Sects).
    - **Quests and conversation** read the player's ties for offers, refusals and bond verbs.
    - **Narration** (authored text, or the LLM Game Master when enabled) may read tie kinds and names.
15a. **Each pinned kind has one build hook** (user decision 2026-11-20). This GDD names the hook and its size
    (Formulas); the owning system applies it. Hooks that are stat rows are plain Modifier System rows with source
    `tie`, present while the tie lasts and recomputed only when a tie changes (as NPC Traits does for trait rows).

    | Kind | Hook | Applies to | Applied by |
    |---|---|---|---|
    | Sư đồ, as disciple | `cultivation_speed_pct` +`master_cult_pct` while the master lives and is of a higher realm; the master's teaching verb is always accepted for the master's own techniques (the score's `b_v` is waived) | player and NPCs (teaching: player) | Character Stats; NPC Interaction & Dialogue |
    | Sư đồ, as master | Disciples run errands (gather, deliver, scout): up to `errands_per_season` per disciple, each a Quests Errand-tier quest the disciple completes for the player, resolved by the Event Engine. Sending an errand costs `errand_cost` in linh thạch, paid when sent (a stone sink; CD-GDD-ALIGN, Pillar 4) | player | Quests, Event Engine |
    | Kết nghĩa | In a fight event, the player may call for help: each sworn sibling within one travel step answers with chance `p_help` (Formulas F), and at most `help_max` of those who answer join, each as one Combat companion source (Combat rule 19) at their power share. Each answer spends goodwill: a sibling who joined loses `help_cost` of their friend strength toward the caller (Δ −`help_cost`); with no friend tie, the caller instead owes them ân tình (Δ `help_cost`), a favour to repay. Either way the next call is less likely to be answered (CD-GDD-ALIGN, Pillar 4) | player | Event Engine, Combat |
    | Đạo lữ | Dual cultivation (song tu): `cultivation_speed_pct` +`daolu_cult_pct` for both while in the same place at season close; "has a Dao companion" is a group condition build Effects may test | player and NPCs | Character Stats, Effects |
    | Companion | Fights beside the player as one Combat companion source at their power share, and travels with them | player | Combat |
    | Kin, blood feud | No build hook; kin and feuds act through opinion, events and the tick | — | — |
16. **The player.** The player's ties use the same record and rules. The stored attitude to the player (Quests,
    Formulas E) is separate and unchanged; a tie adds to the NPC's opinion of the player through F3 but does not write
    to that attitude.

### States and Transitions

The state of a pair is its record's pinned kind and soft kind; "none" means no record.

| From | To | Trigger | Rule |
|---|---|---|---|
| none | friend, rival, ân tình, enmity | Event outcome, world fight, rescue | 8 |
| none | kin, sư đồ, kết nghĩa, đạo lữ | World Gen, birth, taking a disciple, bond verb or event (rule 6 gate) | 6, 8 |
| friend | kết nghĩa or đạo lữ | Bond verb or event; friend soft kind stays until it fades | 6, 8 |
| ân tình | friend | Debt repaid | 14 |
| friend, rival, ân tình | enmity | Event outcome (insult, theft, a crippling world fight); replaces the soft kind when stronger | 8, 10 |
| enmity | blood feud | Strength ≥ `feud_threshold`, or a kill of a close tie | 11 |
| blood feud, enmity | none | The target dies (avenged if the holder's side killed) | 14 |
| none | companion | Player's recruit verb accepted | 8 |
| companion | none | Dismissed, or the NPC leaves (attitude hostile, or an event) | 2 |
| kết nghĩa, đạo lữ, sư đồ | enmity | Betrayal | 12 |
| kin | kin + enmity | Betrayal | 12 |
| any soft | none (soft part) | Fades to 0, evicted, replaced by a stronger soft kind, `tie_end` | 4, 7, 10, 14 |
| any | removed | Death of either person (after inheritance) | 13 |
| blood feud held by the dead | blood feud held by heirs | Death | 13 |

### Interactions with Other Systems

| System | Direction | What passes | Owner of the interface |
|---|---|---|---|
| **NPC Traits** (#42) | out | Rule 3's tie value into F3 `tie(a, b)`; rule 16 amended. A Grudge gained trait and an enmity tie toward the same person do not stack: F3 takes the more negative of `target` and the enmity value (provisional, Open Question 2) | This GDD (record); NPC Traits (formula) |
| **Living World Tick** (#28) | in / out | In: the S8b slot, deaths, rescues and betrayals of the season. Out: tie lookups for help and revenge choice weights | Tick owns the step order; this GDD owns S8b's contents |
| **Event Engine** (#23) | in / out | In: `tie_add`, `tie_strengthen`, `tie_weaken`, `tie_end` effects and betrayal flags. Out: tie conditions | Event Engine owns effect syntax and budgets |
| **NPC Interaction & Dialogue** (#30) | in / out | In: the player's bond verbs. Out: the player's ties, the gate for each verb | Dialogue owns the verbs and their attitude gates |
| **Power Rankings** (#44) | in | World-fight results: closeness, injury, kill | Power Rankings |
| **Sects & Missions** (#26) | in / out | In: taking disciples, ranks for notability. Out: sư đồ for succession | Sects owns succession |
| **Quests** (#31) | out | The player's ties for offers; attitude to the player stays Quests' | Quests |
| **World Generation & History** (#27) | in | Authored ties of the fixed cast; generated kin | World Gen |
| **Realms & Bottlenecks** (#8) | in | Deaths by lifespan and failed breakthroughs (via the tick) | Realms |
| **World DB** (#3), **Save/Load** (#5) | in / out | The tie records, indexed by both ids | This GDD (shape); Save/Load (format) |
| **LLM Game Master** (#29, parked) | out | Tie kinds and names for narration; the game plays without it | — |

## Formulas

Scale notes for every number below: 4 seasons a year; lifespans 120 / 200 / 500 / 1,000 years by realm
(`cultivation_realms.json`); opinion runs −100 to 100 (NPC Traits F3); `cultivation_speed_pct` sources today run
+3 a generating pair (0–15 a root), +11 for a Chaos 55 variant, +0.5 to +3.6 a modifier roll (Modifier System).
Values marked *(guess)* are first numbers for the balance pass.

### A. Tie value in opinion

The tie_value formula is defined as:

`tie(a, b) = max(0, max_{k ∈ P} pin(k, a → b)) + feud(a → b) + soft(k_s, a → b) · str_now / 100`

The positive pinned kinds do not add up: a father who is also the master counts +30 once. A blood feud is the one
negative pinned kind and adds on top (a kinslayer's brother: 30 − 60 = −30).

It replaces the `tie` term of NPC Traits F3; the rest of F3 is unchanged (the sect head +15 stays in F3, computed
from the sect, not stored).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P, k_s | set; enum | the record's pinned flags (blood feud excluded); its soft kind or none | calculated (the record) | Rule 1 |
| pin | int | kin +30; sư đồ +30 both ways; kết nghĩa +40; đạo lữ +50; companion +20 | data file (kin, sư đồ, đạo lữ: NPC Traits F3 values, unchanged) | Fixed positive pinned weight |
| feud | int | −60 for a holder of a blood feud toward b; 0 otherwise (a target who does not hold it back feels nothing from it) | data file *(guess)* | The negative pinned weight |
| soft | int | friend +25; rival −10; ân tình +30 debtor → creditor, +10 creditor → debtor; enmity −50 holder → target, 0 the other way unless held both ways | data file *(guess)* | Soft weight at full strength |
| str_now | int | 0–100 | Formula B | Current soft strength |

**Output Range:** −70 (a blood feud −60 plus a full rivalry −10; a feud and an enmity never coexist, rule 11) to +80
(đạo lữ +50 plus a full ân tình +30 as debtor). A record with no pinned kind and a full enmity gives −50. F3's clamp to
−100…100 still applies to the whole opinion.
**Example:** sworn siblings who are friends at strength 60: 40 + 25 × 0.6 = **55**. A master who betrayed his
disciple, held at enmity 80 by the disciple: disciple → master 30 − 50 × 0.8 = **−10**; master → disciple **30**.

The enmity weight −50 equals the Grudge trait's `target` −50 (NPC Traits F3), and the two do not stack: F3 takes the
more negative of `target` and `soft(enmity) · str_now / 100` for the same person (provisional, Open Question 2).

### B. Lazy fade

The soft_strength formula is defined as:

`str_now = max(0, str − floor(fade(k_s) · (season_now − last_season)))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| str | int | 1–100 | the record | Strength when last set |
| fade | float | friend 1.0; rival 1.0; enmity 0.5; ân tình 0.25 per season | data file *(guess)* | Loss a season. Friend from 100 fades in 25 years, enmity in 50, a debt of gratitude in 100: within one Luyện Khí life (120 years) a debt is not forgotten |
| season_now, last_season | int | ≥ 0 | clock; the record | `season_now − last_season` is clamped at 0 |

**Output Range:** 0–100. At 0 the soft kind is removed the next time either person is touched (rule 4). `fade` must
be greater than 0 for every soft kind; at 0 a soft tie never vacates its slot and eviction (rule 7) becomes the only
way out.
**Example:** a friend tie set to 70 twelve years (48 seasons) ago: 70 − 48 = **22**.

### C. Strength changes

The strength_change formula is defined as:

`str = clamp(str_now + Δ, 0, 100)` ; `last_season = season_now`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| Δ | int | −100 – 100 | the source (event effect, or the defaults below) | Positive strengthens; negative weakens; reaching 0 removes the soft kind |
| Δ defaults | int | shared event friend +20; close world fight (rating gap ≤ `rival_gap`) rival +30; rescue ân tình +60; crippling world fight enmity +40; insult or theft enmity +30; betrayal enmity +70; repaid debt friend `repay_friend` 30 | data file *(guess)* | Used when a source gives no Δ of its own |
| rival_gap | int | 100 rating points | data file *(guess)* | "Close" in Power Rankings rating terms |

A new soft kind starts at `str_now = 0` (rule 10 compares the new value against the existing soft kind's `str_now`).
**Output Range:** 0–100.
**Example:** a rescue (Δ 60) of a person who already owed ân tình at 30: **90**.

### D. Hardening and inheritance

The feud_rules are defined as:

`enmity → blood feud` when `str_now(enmity) ≥ feud_threshold`, or at once on a known kill of a close tie (rule 11)
`heirs = first inherit_feud_max of [children by age, eldest first] ++ [disciples by sư đồ age, longest first]`
`str(mourner enmity) = inherit_enmity` ; `str(heir ân tình) = floor(str_now(debt owed to the dead) · inherit_debt)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| feud_threshold | int | 90 | data file *(guess)* | Two serious offences (crippling +40 then betrayal +70, or three insults) harden enmity |
| inherit_feud_max | int | 3 | data file *(guess)* | Heirs who take a pinned blood feud; bounds the cascade (rule 13) |
| inherit_enmity | int | 50 | data file *(guess)* | Mourners' soft enmity |
| inherit_debt | float | 0.5 | data file *(guess)* | Share of a debt of gratitude the heirs are owed |

**Output Range:** at most `inherit_feud_max` pinned feuds per death per target; mourners' enmity 50 fades to 0 in 25
years (Formula B). `inherit_feud_max = 0` turns all heirs into mourners.
**Example:** a sect head with 2 children and 30 disciples is killed in public. 2 children and the longest-held disciple
take a pinned blood feud on the killer (3 records); the other 29 disciples and kin take soft enmity 50, each subject
to their own caps.

### E. Caps and the save bound

The tie_bound formula is defined as:

`records ≤ (N_ord · cap_ordinary + N_not · cap_notable) / 2 + overflow_pinned`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cap_ordinary | int | 6 (safe 1–12) | data file | Ties per ordinary person (user decision 2026-11-20) |
| cap_notable | int | 16 (safe ≥ cap_ordinary) | data file | Ties per notable person and the player (user decision 2026-11-20) |
| N_ord, N_not | int | 5,000 in all; N_not about 750 | calculated | Notable estimate: 72 fixed cast, about 150 sect heads and elders (30 sects), about 30 Nguyên Anh and Hóa Thần, up to 500 people the player has met |
| overflow_pinned | int | small | calculated | Pinned ties past a cap (rule 7): large families and many disciples |

**Output Range:** (4,250 × 6 + 750 × 16) / 2 = **18,750** records, plus overflow; about 16 bytes a record before the
save format, so about 0.3 MB raw. The design target is **≤ 20,000 records** at 5,000 cultivators (AC-NR). Halving
`cap_ordinary` to 3 gives 12,375.

### F. Hooks

The tie_hooks are defined as:

`cultivation_speed_pct += master_cult_pct` (disciple, master alive and of a higher realm)
`cultivation_speed_pct += daolu_cult_pct` (each đạo lữ, while in the same place at season close)
`p_help = clamp((op(sibling → caller) − help_min) / (100 − help_min), 0, 1)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| master_cult_pct | int | +5 | data file *(guess)* | About two generating pairs; a good master matters but is not a root |
| daolu_cult_pct | int | +8 | data file *(guess)* | Dual cultivation (song tu), the best-known pairing bonus, below a five-element root's +15 |
| help_min | int | 30 (safe 0–99) | data file *(guess)* | Opinion below which a sworn sibling never answers. At 100 the formula divides by zero, so 99 is the safe ceiling |
| help_max | int | 1 | data file *(guess)* | Sworn siblings who may join one fight: kết nghĩa with up to 16 slots would otherwise add a companion source each (Combat rule 19 has no total cap) |
| errands_per_season | int | 1 | data file *(guess)* | Errand events per disciple a season |
| help_cost | int | 40 (safe 1–100) | data file *(guess)* | Friend strength a sibling spends by joining, or the ân tình the caller owes when there is no friend tie. At 0 the call is free again (the Pillar 4 concern returns) |
| errand_cost | int | `stip_r` of the disciple's realm × `errand_cost_mult` | calculated | Linh thạch per errand; `stip_r` is the Sects stipend per season by realm (3 / 20 / 50 / 325 / 2,500, Sects anchors) |
| errand_cost_mult | float | 1.0 | data file *(guess)* | One season's stipend per errand: the disciple is paid as their sect would pay them |
| op | int | −100 – 100 | NPC Traits F3 | The sibling's opinion of the caller |

**Output Range:** `cultivation_speed_pct` gains 0, +5, +8 or +13 from ties. `p_help` 0–1. `errand_cost` 3–2,500 linh
thạch by realm. A sworn sibling at friend 100 (opinion 65, `p_help` 0.5) who answers drops to friend 60
(opinion 55, `p_help` 0.36), and after a second answer to friend 20 (opinion 45, `p_help` 0.21); shared events and
time rebuild it. A sworn sibling with no friend tie (opinion 40, `p_help` 0.14) who answers leaves the caller owing ân
tình 40, and the sibling's own view rises only by the creditor's +4.
**Example:** a sworn sibling with opinion 65 (kết nghĩa 40 + friend 25 at full): (65 − 30) / 70 = **0.5**.

**Feedback loops.** (1) Đạo lữ and masters speed cultivation, a higher realm makes a person notable, and notables hold
more ties: a mild rich-get-richer loop, intended (famous cultivators gather bonds), damped by the one-đạo-lữ and
one-master limits. (2) Kills create feuds and feuds cause kills: damped by rule 14a (the tick's violent-death budget),
`inherit_feud_max`, and inherited feuds passing on only as soft enmity.

## Edge Cases

**Deaths and inheritance**
- **If two people kill each other in the same season** (or the killer dies before S8b): deaths are processed in event-log
  order; a feud toward someone already dead is never created (rule 14), so neither side's heirs gain a feud from that
  exchange. Mourners still take soft enmity only toward a living killer.
- **If an heir is the killer** (a disciple kills the master, a son the father): the killer is struck from the heirs
  and mourners; the next in line takes the slot. Their own record with the dead is removed with the others.
- **If one person is both kin and disciple of the dead**: they take one heir slot, once.
- **If the killer was unknown and is revealed later** by an event: that event may add the feuds then (`tie_add`),
  computed from the heirs alive at the reveal; nothing is back-dated.
- **If the player kills many people with heirs**: each known kill adds at most `inherit_feud_max` pinned blood feuds
  on the player, which may pass the player's cap (pinned overflow, rule 7). The player's record count grows with known
  kills: 100 such kills is at most 300 extra records.
- **If a person with ties dies mid-season**: until S8b removes the records, readers treat ties with a dead person as
  absent (no opinion, no hook, no help call).
- **If a companion dies in a fight**: the companion tie ends by death (rule 13) at S8b; the fight's result stands.

**Caps and records**
- **If an heir's or mourner's slots are all pinned**: an inherited pinned feud still forms (overflow); a mourner's soft
  enmity does not form unless it is stronger than one of their soft ties (rule 7).
- **If `cap_ordinary` or `cap_notable` is lowered by a data change in a running game**: existing records stay; each
  person evicts down to the new cap the next time a tie is added to them (as for loss of notability, rule 7).
- **If a second pinned kind is added to a pair** (a disciple becomes đạo lữ): the flag is added to the same record;
  no second record, no extra cap use (rule 1).
- **If a new soft kind is weaker than the pair's current one**: it is dropped (rule 10). A rescue (ân tình +60) of
  someone who holds enmity 80 toward the rescuer leaves the enmity; the event may weaken it with its own Δ.
- **If `season_now − last_season` is negative** (a corrupt or hand-edited save): it is clamped to 0 (Formula B).

**Bonds and verbs**
- **If a person already has a living đạo lữ or master and is offered another**: the verb or event is not available;
  the bond verb shows greyed with the requirement (NPC Interaction & Dialogue rule 5). Leaving a master first needs an
  event that ends sư đồ (expulsion, leaving the sect).
- **If the master falls to or below the disciple's realm** (the disciple breaks through past him): `master_cult_pct`
  stops; the tie stays.
- **If đạo lữ are in different places at season close**: no dual-cultivation bonus that season; the tie is unchanged.
- **If a sworn sibling is the opponent, or is already fighting on the other side**: they are not called. A sibling
  already in another fight is not called either.
- **If the player calls for help and no sibling answers**: the fight runs as it would have; no debt forms. Only a sibling who joins is owed.

**Degenerate strategies**
- **Farming help:** many sworn siblings would add a companion source each, since Combat rule 19 has no total cap.
  `help_max` 1 bounds it, and each answered call spends the sibling's goodwill, lowering the next answer (`help_cost`).
- **Farming disciples for errands:** up to 16 disciples would make 16 errands a season. Each costs a season's stipend
  of the disciple's realm (`errand_cost`), so errands pay only when their reward beats the stipend. Errand rewards are Quests
  Errand-tier rewards inside the Event Engine budgets and count toward found money (5 % of mines, world economy plan
  `production/plans/world-economy.md`) like any other find, so more disciples do not add more money than the share
  allows. Owner: Quests and Event Engine.
- **Cycling a đạo lữ for the bonus:** only one living đạo lữ; ending one needs a betrayal, which leaves enmity, so
  cycling costs a lasting enemy each time.
- **Rescue farming for ân tình:** ân tình has no build hook; it only raises opinion, which attitude already bounds
  (NPC Interaction & Dialogue).

**Narrative**
- **If a feud's target dies of old age or a failed breakthrough**: the feud ends; the news reports it as heaven's
  judgement, not as avenged (rule 14).
- **If a blood feud is held both ways and one side's heir kills the other**: the killed person's heirs take a new
  feud (a renewal, rule 13); the inherited one held by the killer ends with the target.

## Dependencies

**Upstream (this system needs them)**

| System | Hard / Soft | Interface | Has GDD |
|---|---|---|---|
| World Database (#3) | Hard | Tie records indexed by both ids; people, deaths, the event log (killer known or not) | No (built) |
| Save / Load (#5) | Hard | Saves the records (Formula E bound) | No (built) |
| Living World Tick (#28) | Hard | Calls step S8b; supplies the season's deaths, rescues, betrayals; owns the violent-death budget (rule 14a) | Yes |
| NPC Traits (#42) | Hard | F3 opinion, whose `tie` term this GDD now defines (Formula A); rule 16 amended | Yes |
| Event Engine (#23) | Hard | `tie_add`, `tie_strengthen`, `tie_weaken`, `tie_end` effects, betrayal flags, errand and help-call fight events, budgets | Yes |
| Time & Turn (#4) | Hard | `season_now`, 4 seasons a year | No (built) |
| NPC Interaction & Dialogue (#30) | Soft | The player's bond verbs and their acceptance gates (rule 11 there) | Yes |
| Power Rankings (#44) | Soft | World-fight results: rating gap, injury, kill | Yes |
| Sects & Missions (#26) | Soft | Taking disciples, ranks (notability), sect succession | Yes |
| World Generation & History (#27) | Soft | Authored ties of the cast (10 master ties, parents); generated kin and masters (`master_share`) | Yes |
| Realms & Bottlenecks (#8) | Soft | Realms for notability and the master hook; deaths by lifespan | Yes |

**Downstream (they read this system)**

| System | Hard / Soft | Interface |
|---|---|---|
| NPC Traits (#42) | Hard | `tie(a, b)` for F3 |
| NPC Interaction & Dialogue (#30) | Hard (bond verbs) | Creates bonds on accept; reads the player's ties for verbs, address and tone |
| Living World Tick (#28) | Soft | Ties as weights for help and revenge choices |
| Character Stats (#7) | Soft | `cultivation_speed_pct` rows with source `tie` (Formula F) |
| Effects (#41) | Soft | The "has a Dao companion" group condition |
| Combat (#21) | Soft | Companions and answering sworn siblings as companion sources (rule 19 there) |
| Quests (#31) | Soft | Disciples' errands as Errand-tier quests; offers that read ties; `tie_share` for quest reactions |
| Sects & Missions (#26) | Soft | Sư đồ for succession |
| LLM Game Master (#29, parked) | Soft, optional | Tie kinds for narration; never required |

**Back-links written 2026-11-20** (user-approved), so every dependency above points both ways:
- **NPC Traits:** rule 16 amended (ties are the one stored exception); F3 `tie` row points to Formula A; upstream,
  downstream and interaction rows; its Open Question 8 mirrors this GDD's Open Question 2 (Grudge against enmity).
  NPC Traits was Approved; the amendment reopens rule 16 and F3 for the end-of-design review pass.
- **Living World Tick:** rule 20 and the S8b row describe the step; Dependencies and Interactions rows; its Open
  Question 4 notes that rule 14a relies on the violent-death budget.
- **NPC Interaction & Dialogue:** rule 11 no longer "hooks until #46" (new verbs: repay a debt, declare enmity, call
  for help); loans not inherited (state line, edge case, Open Question 2 answered); Dependencies row.
- **Quests:** Dependencies row; its Open Question 15 asks whether kin, kết nghĩa and đạo lữ get a `tie_share`
  (proposal kin 0.5, kết nghĩa 0.5, đạo lữ 0.75). Still open there.
- **Combat:** Dependencies row; its Open Question 28 asks for a person's companion power share (this GDD's Open
  Question 4). Still open there.
- **Character Stats** (modifier source `tie`), **Effects** (đạo lữ group condition), **Sects**, **World Generation**:
  Dependencies rows.

## Visual/Audio Requirements

Art bible sections 1–4 are still `[To be designed]`, so this draws on the pillars and on art bible §7 (icon grammar,
dark tiles on ink-wash paper). The system is mostly text; its events are news and card states, not effects.

- **Tie icons.** One small glyph per tie kind on the person card and in the relationships list, in the §7.1 dark-tile
  style: kin (a family seal), sư đồ (a brush and scroll), kết nghĩa (crossed cups), đạo lữ (two linked rings),
  companion (a walking staff), friend, rival (two crossed swords, unlit), ân tình (an open palm), enmity (a cracked
  jade), blood feud (a red-stained seal). Kind is never told by colour alone: each has its own glyph, and warm or cold
  tint is a backup (accessibility floor).
- **Strength.** Soft ties show a band (faint, firm, deep for 1–33 / 34–66 / 67–100), drawn as one to three strokes
  under the glyph; no raw number on the card, the number in the tooltip (Pillar 2, "Every Number Is Bounded and
  Visible").
- **News.** Tie events appear as *tin đồn* lines with the tick's bracketed tag (Living World Tick Visual/Audio):
  bonds sworn, feuds declared, avenged (báo thù), heaven's judgement, a debt repaid.
- **Audio.** No new cues required; a single short ink-stroke sound for a bond formed and a low drum for a blood feud
  on the player are candidates for the audio pass (Audio #38, not designed).
- `art-director` lens applied (full mode); no art bible principles 1–4 exist to cite.

## Game Feel

Optional for a Narrative system; one target only. A bond formed or broken with the player is acknowledged in the same
screen, the moment the verb or event resolves (the news line and the card glyph update before the player can act
again), so a deed and its consequence read as one beat.

## UI Requirements

- **Person card** (NPC Interaction & Dialogue): the card lists the NPC's ties to the player first, then up to 3 of
  their other notable ties (master, đạo lữ, a blood feud), each with its glyph, name in Vietnamese and English, and
  band. Bond verbs greyed with their missing requirement stay Dialogue's.
- **Relationships page** on the player's character screen: every tie the player holds, grouped pinned then soft,
  sortable by kind and by strength, with the partner's location if known; the cap shown as `ties / 16`, so the player
  sees eviction coming ("the weakest soft tie will fade from memory" warning when full).
- **Help call** in a fight event: an option listing the sworn siblings in range and their answer chance (`p_help` as a
  percentage), shown before the call.
- **Text room:** Vietnamese tie names run longer than English; fields fit the longest (Dao companion / Đạo lữ, blood
  feud / Huyết thù) at the base font.

## Cross-References

| This GDD | Refers to | Where | Why |
|---|---|---|---|
| Rule 3, Formula A | NPC Traits F3 `tie`, `target`; rule 16; AC-NT-21 | `npc-traits.md` F3, rule 16 | This GDD defines the `tie` term; rule 16 amended |
| Formula A values | kin +30, sư đồ +30, đạo lữ +50, sect head +15 | `npc-traits.md` F3 | Unchanged, reused |
| Rule 9 | Step S8b | `living-world-tick.md` rule 20, step table | The reserved slot |
| Rule 14a | Violent-death budget | `living-world-tick.md` Open Question 4 | Damps vendettas |
| Rules 8, 15a, 16 | Bond verbs, attitude, bands, teaching, loans | `npc-interaction-dialogue.md` rules 5, 11–15, OQ 2 | Verbs create bonds; attitude stays Dialogue's |
| Rule 15a | Companion sources | `combat.md` rule 19, Formula J | Companions and answering siblings |
| Rule 15a, Formula F | `cultivation_speed_pct`, modifier sources | `character-stats.md`, `modifiers.md` | Hook rows |
| Rule 15a | Errand tier, `tie_share` | `quests.md` rule 14, Formulas E | Disciples' errands; quest reactions |
| Formula C | Rating gap | `power-rankings.md` Formulas F | Rivalry from close world fights |
| Rule 8 | Authored masters and parents, `master_share` | `world-generation.md` rules 5, 8 | Starting ties |
| Edge Cases | Found money 5 % of mines | `production/plans/world-economy.md` | Errand rewards |

## Acceptance Criteria

Tags: [Logic] automated unit test (`tests/unit/relationships/`); [Integration] automated integration test
(`tests/integration/relationships/`); [Performance] timed run on the reference machine; [UI] retained screenshot in
`production/qa/evidence/`. Numbers come from the data file; a test reads the value it checks, except where the
boundary itself is the point.

**Fixtures**
- **FX-PAIR:** two Luyện Khí NPCs A and B, same sect, no shared or opposed traits, no gained traits, ordinary
  (not notable), season 100.
- **FX-FAM:** a sect head H (notable) with 2 children (C1 elder, C2), 30 disciples (D1 longest-held … D30), a
  sibling S, and a known killer K; `inherit_feud_max` 3.
- **FX-W5K:** NPC Traits' generated world of 5,000 people from a fixed seed, plus World Generation's authored cast
  and its ties.
- **FX-EV-T:** an Event Engine stub emitting a fixed list of `tie_add` / `tie_strengthen` / `tie_end` effects,
  rescues, betrayals and kills a season, from a fixed seed.

**Record and kinds**
- **AC-NR-01** [Logic] Rule 1. **GIVEN** FX-PAIR, **WHEN** sư đồ, then kin, then enmity 40 are added to (A, B),
  **THEN** exactly one record exists, holding flags {sư đồ, kin} and soft kind enmity, and A's and B's tie counts are
  each 1.
- **AC-NR-02** [Logic] Rule 2. **GIVEN** a disciple with a living master, **WHEN** a second sư đồ to another master
  is added, **THEN** it is refused; the same holds for a second living đạo lữ.
- **AC-NR-03** [Logic] Rule 2. **GIVEN** an NPC, **WHEN** a companion tie to another NPC (not the player) is added,
  **THEN** it is refused.

**Opinion (Formula A, rule 3)**
- **AC-NR-04** [Logic] Formula A. **GIVEN** FX-PAIR with kết nghĩa and friend strength 60, **THEN** `tie(A, B)` is
  55; **WHEN** strength is 0, **THEN** 40; **WHEN** kin and sư đồ are both set and nothing else, **THEN** 30 (not 60).
- **AC-NR-05** [Logic] Formula A. **GIVEN** B holds a blood feud toward A and the pair are kin, **THEN**
  `tie(B, A)` is −30 and `tie(A, B)` is 30.
- **AC-NR-06** [Logic] Formula A, Open Question 2. **GIVEN** A holds a Grudge gained trait toward B and an enmity
  tie toward B at strength 80, **THEN** F3 uses −50 for the pair (the more negative of −50 and −40), not −90.
- **AC-NR-07** [Integration] Rule 3, NPC Traits AC-NT-21. **GIVEN** FX-W5K after 20 seasons with ties, **WHEN**
  1,000,000 opinions and 1,000,000 tie lookups are read, **THEN** the save is byte-identical before and after.

**Fade, strength and eviction (Formulas B, C, rules 4, 7, 10)**
- **AC-NR-08** [Logic] Formula B. **GIVEN** a friend tie set to 70 at season 100, **THEN** at season 148 its
  strength reads 22, at season 170 it reads 0, and the record still exists until either person is touched; **WHEN**
  A is touched by a rule-7 change, **THEN** the soft kind is removed (and the record too, if it holds no flags).
- **AC-NR-09** [Logic] Formula B boundary. **GIVEN** `last_season` greater than `season_now`, **THEN** the strength
  reads as stored (no increase, no error).
- **AC-NR-10** [Logic] Formula C. **GIVEN** ân tình at 30, **WHEN** a rescue (Δ 60) applies, **THEN** strength is
  90 and `last_season` is now; **WHEN** Δ −100 applies, **THEN** the soft kind is removed.
- **AC-NR-11** [Logic] Rule 10. **GIVEN** enmity 80 on (A, B), **WHEN** ân tình Δ 60 is added, **THEN** the soft
  kind stays enmity 80; **WHEN** instead enmity is 40, **THEN** the soft kind becomes ân tình 60.
- **AC-NR-12** [Logic] Rule 7. **GIVEN** an ordinary person with 6 ties (2 pinned, 4 soft at 10/20/20/50; the two
  20s set at seasons 80 and 90), **WHEN** a soft tie of 30 is added, **THEN** the 10 tie is evicted from both sides;
  **WHEN** a second 30 is added, **THEN** the season-80 tie of 20 is evicted.
- **AC-NR-13** [Logic] Rule 7. **GIVEN** an ordinary person with 6 pinned ties, **WHEN** a soft tie is added,
  **THEN** it does not form; **WHEN** a pinned tie is added, **THEN** it forms (7 ties).
- **AC-NR-14** [Logic] Rules 5–7. **GIVEN** a sect elder with 12 ties who loses the rank, **WHEN** no tie is added,
  **THEN** they keep 12; **WHEN** one soft tie is added, **THEN** soft ties are evicted until at most 6 remain (pinned
  ones kept).
- **AC-NR-15** [Logic] Rule 6. **GIVEN** two ordinary NPCs, **WHEN** a non-authored source adds kết nghĩa or đạo
  lữ, **THEN** it is refused; **GIVEN** one of them is notable, **THEN** it forms.

**Hardening, betrayal, death (Formula D, rules 11–14a)**
- **AC-NR-16** [Logic] Rule 11. **GIVEN** enmity 50, **WHEN** Δ +40 applies, **THEN** the pair holds a pinned blood
  feud and no soft enmity; **GIVEN** enmity 10, **WHEN** the target kills the holder's master (known), **THEN** the
  same.
- **AC-NR-17** [Logic] Rule 12. **GIVEN** kết nghĩa (A, B), **WHEN** an event marks B's betrayal of A, **THEN** the
  kết nghĩa flag is removed and A holds enmity 70 toward B; **GIVEN** kin instead, **THEN** kin stays and enmity is
  added.
- **AC-NR-18** [Logic] Formula D, rule 13. **GIVEN** FX-FAM, **WHEN** K kills H in public, **THEN** C1, C2 and D1
  each hold a pinned inherited blood feud toward K (3 records on K), D2–D30 and S hold soft enmity 50 toward K
  (subject to their caps), and H has no records left.
- **AC-NR-19** [Logic] Rule 13. **GIVEN** FX-FAM, **WHEN** the kill is not known, **THEN** no feud or enmity toward K
  forms; **WHEN** D1 is the killer, **THEN** D1 is struck and D2 takes the third heir slot.
- **AC-NR-20** [Logic] Rule 13. **GIVEN** C1 holds an inherited blood feud toward K, **WHEN** C1 dies naturally,
  **THEN** C1's heirs take soft enmity 50 toward K, not a pinned feud.
- **AC-NR-21** [Logic] Rule 13. **GIVEN** B owes ân tình 80 to H, **WHEN** H dies, **THEN** B owes ân tình 40 to each
  of H's heirs; **GIVEN** H owed ân tình to B, **THEN** it is cancelled. A loan H made or owed passes to no one.
- **AC-NR-22** [Logic] Rule 14. **GIVEN** A holds a blood feud toward B, **WHEN** B dies of old age, **THEN** the feud
  ends and the news line is the "heaven's judgement" kind; **WHEN** A kills B, **THEN** the line is the "avenged"
  kind.
- **AC-NR-23** [Logic] Edge cases. **GIVEN** A and B kill each other in the same season, **THEN** no feud toward
  either forms at S8b.
- **AC-NR-24** [Integration] Rule 14a, Living World Tick. **GIVEN** FX-W5K with FX-EV-T run for 400 seasons, **THEN**
  violent deaths a season never exceed the tick's budget, and the number of living blood-feud holders after 400
  seasons is within the bound the balance pass sets (first target: ≤ 5 % of the living).

**Tick, sources and save (rules 8, 9, Formula E)**
- **AC-NR-25** [Logic] Rule 9. **GIVEN** one season's queue holding a death, a betrayal, an enmity reaching 90 and a
  new soft tie for the same people, **WHEN** S8b runs, **THEN** they apply in the order death and inheritance, ends,
  hardening, new ties with eviction, strength changes, and only the people named are touched.
- **AC-NR-26** [Logic] Rule 8. **GIVEN** FX-W5K, **WHEN** a season passes with an empty queue, **THEN** no tie record
  changes.
- **AC-NR-27** [Integration] Rule 8, Power Rankings. **GIVEN** two NPCs whose ratings differ by 80 fight a world fight,
  **THEN** they gain rival 30; **WHEN** the loser is crippled, **THEN** the loser gains enmity 40 toward the winner.
- **AC-NR-28** [Integration] Formula E. **GIVEN** FX-W5K with FX-EV-T for 400 seasons, **THEN** the record count never
  exceeds 20,000 and no ordinary person holds more soft ties than `cap_ordinary` minus their pinned count.
- **AC-NR-29** [Integration] Save / Load. **GIVEN** FX-W5K after 100 seasons, **WHEN** saved and loaded, **THEN**
  every record (both ids, flags, soft kind, direction, strength, `last_season`) round-trips exactly.
- **AC-NR-30** [Integration] World Generation. **GIVEN** a new game, **THEN** each authored master tie and parent of
  the cast exists as a sư đồ or kin record.
- **AC-NR-31** [Performance] **GIVEN** FX-W5K with FX-EV-T, **THEN** S8b takes ≤ 5 ms a season for 200 queued
  changes, and 10,000 tie lookups take ≤ 10 ms.

**Hooks (Formula F, rule 15a)**
- **AC-NR-32** [Logic] Formula F. **GIVEN** a disciple whose master lives at a higher realm, **THEN** their sheet holds
  a `cultivation_speed_pct` row +5 with source `tie`; **WHEN** the disciple reaches the master's realm, **THEN** the
  row is gone.
- **AC-NR-33** [Logic] Formula F. **GIVEN** đạo lữ in the same place at season close, **THEN** each gains +8 for that
  season; **GIVEN** different places, **THEN** 0.
- **AC-NR-34** [Logic] Formula F boundary. **GIVEN** `help_min` 30, **THEN** `p_help` is 0 at opinion 30 and below,
  0.5 at 65, 1 at 100.
- **AC-NR-35** [Integration] Rule 15a, Combat. **GIVEN** the player with 3 sworn siblings within one travel step who
  all answer (`p_help` forced 1), **WHEN** the player calls for help in a fight event, **THEN** exactly `help_max` (1)
  joins as one companion source; a sibling who is the opponent is never called; after the fight the sibling who
  joined holds friend strength 40 less toward the player (or, with no friend tie, the player owes them ân tình 40),
  and the two who did not join are unchanged.
- **AC-NR-36** [Integration] Rule 15a, Dialogue. **GIVEN** the player is a disciple, **WHEN** they ask their master
  for teaching of one of the master's own techniques, **THEN** it is accepted whatever the score.
- **AC-NR-37** [Integration] Rule 15a, Quests. **GIVEN** the player with 2 disciples, **WHEN** a season passes, **THEN**
  at most 2 Errand-tier errands resolve for the player, and their rewards are counted as found money; **GIVEN** a
  Trúc Cơ disciple (stipend 20), **WHEN** the player sends an errand, **THEN** 20 linh thạch leave the player's purse;
  **WHEN** the purse holds less, **THEN** the errand cannot be sent.
- **AC-NR-38** [Integration] Rule 16. **GIVEN** an NPC with attitude 10 to the player, **WHEN** a kết nghĩa forms with
  the player, **THEN** the stored attitude stays 10 and the NPC's opinion of the player rises by 40.

- **AC-NR-40** [Logic] Rule 14. **GIVEN** B owes ân tình 60 to A, **WHEN** the debt is repaid, **THEN** the soft kind
  becomes friend 30 (`repay_friend`).
- **AC-NR-41** [Integration] Rule 15, Event Engine. **GIVEN** an event whose condition is "has blood feud toward the
  player", **WHEN** checked for one NPC with that feud and one without, **THEN** it is eligible only for the first.

**Presentation**
- **AC-NR-39** [UI] **GIVEN** the person card of an NPC with a pinned and a soft tie to the player, **THEN** both show
  with their names (Vietnamese and English) and the soft tie's strength band; screenshot retained.

## Open Questions

| # | Question | Owner | By |
|---|---|---|---|
| 1 | The "richer records" for notable people (hybrid decision 2026-11-20): today they get a higher cap and may start kết nghĩa and đạo lữ. Should they also store more, such as a short history of the tie (how it formed) for narration? | user | Before the review |
| 2 | Grudge gained trait against enmity tie: keep both with the no-stack rule (Formula A), or retire the targeted Grudge trait and let enmity carry it? Changes NPC Traits F3 | user, NPC Traits | Before the review |
| 3 | Values marked *(guess)*: soft weights, fade rates, Δ defaults, `feud_threshold` 90, inheritance strengths, `master_cult_pct` +5, `daolu_cult_pct` +8, `help_min` 30, `help_max` 1. Set by a balance run over FX-W5K (blood-feud share, record count) | systems-designer | Balance pass |
| 4 | A person as a Combat companion source needs a power share (Combat Formula J reads Spirit Beasts' share). Who owns it, and is it the companion's power number over the owner's? | Combat | Before building rule 15a |
| 5 | Successor play: if the game lets the player go on as an heir after death (not designed), disciples and children are the candidates and inherit the player's ties by rule 13 | user | Later |
| 6 | Do NPC-to-NPC sworn siblings and đạo lữ fight for each other in Power Rankings world fights (rating rolls), or only in the player's fight events? | Power Rankings | Later |
