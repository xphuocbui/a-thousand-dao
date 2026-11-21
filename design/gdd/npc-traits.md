# NPC Traits (Tính Cách)

> **Status**: In Design (started 2026-11-14 from the seed written for the Sects GDD)
> **Author**: user + Claude
> **Last Updated**: 2026-11-20 (rule 16 and F3 `tie` amended by NPC Relationships #46; Dependencies rows; OQ 8)
> **Last Verified**: 2026-11-14
> **Implements Pillar**: A fixed world with a written history; Living world tick; Power is built, not given

## Summary

NPC Traits gives every person, NPCs and the player alike, a small set of traits in four kinds: 3 personality traits from
18 opposed sets, 1 calling, up to 2 fate-given (bẩm sinh) and up to 2 gained from events, which fade. Each trait trades a
small stat boon for a cost through the Modifier System, and carries pulls: weights on people's choices, on how they regard
each other (computed, never stored per pair), and on how a sect they lead behaves. It makes the world's 5,000 cultivators
act like people, and gives the player a character whose nature colours choices without ever blocking one.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha (provisional)` · Key deps: `Modifier System, Character Stats, NPC Builds, World Database, Time & Turn; read by Sects, Living World Tick, Event Engine, NPC Interaction & Dialogue, LLM Game Master, Quests`

## Overview

Every person in the world, NPC or player, carries a small set of **traits** (tính cách) in four kinds: **personality**
(3, in opposed sets), a **calling** (1, the lifestyle), **fate-given** traits (0–2, born with) and **gained** traits (from
events, added and lost in play). A trait does two things and nothing more. It gives plain **stat modifiers** through the
Modifier System, and it gives **pulls**: weights on what a person chooses, how they regard others, and how a sect they lead
behaves (Sects F15). Traits are why two cultivators of the same realm and build act differently when a rival insults
them, a friend asks for help or a sect is at war, and they are how the world feels lived-in rather than rolled. For the
player they are a source of build identity and of choices that open or close (a Vengeful life reads a feud differently
from a Forgiving one), never a restriction on the player's own choices. The engine owns every trait record and number;
the LLM game master only reads traits to voice people.

## Detailed Design

### Core Rules

**What a trait is**

1. **A trait is catalogue data with three parts:** an id, a kind and (for personality) an opposed set; **stat rows**, which
   are plain modifiers on Modifier System stats; and **pulls**, which are weights read by other systems. It has a
   Hán-Việt name with an English gloss, a short description the LLM may read, and the conditions that grant or remove it.
   A trait has no rule of its own: anything that needs a rule is an Effect (Modifier vs Effect).
2. **Four kinds** (user decision 2026-11-14):
   - **Personality** (tính tình): **3** per person, never both sides of an opposed set. Fixed for life, with one narrow
     exception (rule 15).
   - **Calling** (nghề nghiệp): **1** per person, the person's lifestyle (strategist, steward, alchemist, swordsman...). It
     follows the person's chosen path and may change when the path does (rule 14).
   - **Fate-given** (bẩm sinh; not *thiên định*, which is Character Stats' Fated birth mode): **0–2** per person, born with (heaven-favoured, ill-starred...). Rare, never lost. Fate-given traits come in opposed pairs too (Heaven-favoured / Ill-starred), and a person never holds both sides: the second draw (F4) removes the first trait and its opposite from the pool, as for personality.
   - **Gained** (hậu thiên): **0–2** per person, from events (scarred, embittered, humbled, renowned...). Added and lost in
     play (rules 11–13).
3. **A person's traits** are a short list of trait ids on the person record in the World Database, plus, for each gained
   trait, the season it expires and, for a **targeted** gained trait (Lovestruck, a grudge), one person id as its target
   (user decision 2026-11-14). The **player** record also holds one int, `heart_demon_used` (F7's season counter, reset
   each season, saved so a mid-season save keeps the cap). At most 8 ids per person (3 + 1 + 2 + 2). Everything else, the
   modifiers and the pulls, is derived from the catalogue when read.
4. **Both NPCs and the player have traits** (user decision 2026-11-14). The record and the rules are the same.

**What traits change: stats**

5. **Every trait carries stat rows** (user decision 2026-11-14: all kinds carry stats). Each row is a catalogue modifier
   (Modifier System rule 1) with the person's trait as its source, so it lasts exactly as long as the trait (Modifier
   rule 2). Traits use only the **flat** and **increased** operations, never `more` (L2/L4 is budgeted by other sources),
   and never a stat that the Modifier System marks rare or Pending.
6. **Every trait has a boon and a cost.** A personality or calling trait has one boon row and one cost row, each at the
   **small** grade (about 1.2 W), on stats that fit the trait (Brave: +maximum health `khi_huyet_pct`, −evade
   `evade_pct`). The opposed trait swaps the flavour and the trade, not the power, so no personality is
   simply better than its opposite. A fate-given or gained trait may be one-sided at the **notable** grade (about 8 W):
   heaven-favoured is a boon with a visible price elsewhere in play (rule 9). W grades are a sizing guide only: **no price
   check runs until the game is finished** (user decision, effects hand-designed and unpriced).
7. **Stat rows target the stats the trait is about.** Talent rows (`ngo_tinh`, `khi_van`, `dao_tam`, `than_hon`,
   `can_cot`) appear only at the notable grade, on fate-given or gained traits; presence (`mi_luc`) may appear at small
   (user decision 2026-11-14: a small talent row would be invisible). Personality and calling rows use tâm ma and
   status resistance, cultivation speed, mission income, stealth, escape, evade, healing and healing taken, health,
   alchemy and refining success, travel speed, and (catalogue, user decision 2026-11-14) qi deviation chance, formation
   power, thần thức, companion health and herb growth. Not the damage layers: traits never touch `attack_pct`, crit or the combat
   offence rows, so personality cannot decide a fight on its own (builds are the game).

**What traits change: choices and regard (pulls)**

8. **Pulls come in three groups.**
   - **Sect pulls:** the 16 kinds of Sects F15 (dial deltas, war odds, weariness, pact line and so on). A sect reads the
     sum over its leader's traits.
   - **Choice weights:** every event choice carries **choice tags** (aggressive, merciful, greedy, deceitful, loyal,
     cautious, vengeful, devout, social...). A person's weight for a choice is the choice's base weight times the product of
     the trait weights for its tags. The Event Engine and the Living World Tick read this to pick an NPC's choice.
   - **Regard pulls:** how the trait colours the opinion others hold of this person and this person holds of others
     (rule 16).
9. **For the player, pulls never restrict choices.** Choice weights are shown as a hint and a cost modifier: a trait
   may add an extra option that fits it (a Vengeful life may take revenge in a feud scene), may make a fitting option
   cheaper, and may make an unfitting one cost heart-demon or standing (tâm ma, standing). It never greys an option out.
   A fate-given boon is paid for by the world: heaven-favoured raises the fortune rows and the chance of fortunate
   events, and its owner is more often the target of envy, in the Event Engine's weights.

**Gaining and losing traits**

10. **Where traits come from at creation.** An ordinary NPC rolls personality and calling (rule 17) and fate-given traits
    rarely. An authored person has a fixed list. The player's personality comes from the chosen origin and its questions,
    the calling from the starting path, and fate-given traits from the same roll as other people.
11. **Events add gained traits.** An event outcome may grant a gained trait from the catalogue, inside the event's
    budget (the engine validates it; the LLM may propose a trait id, never a number). A person holds at most 2 gained
    traits. When both slots are full, a new one replaces the oldest held gained trait whose grade is at most its own;
    if there is none, the grant is refused and logged (F6).
12. **Gained traits fade.** Each gained trait expires `fade_seasons` (a guess: 40) after it was gained. The expiry moves
    forward whenever the trait's trigger happens again; the trigger is a **trigger id** carried by the catalogue trait
    and raised by the Event Engine when an outcome matches it (a trait with no trigger id never refreshes). At its expiry the trait is removed (Formulas F6). People change
    slowly in both directions: a scarred warrior stops flinching after a long peace, and a renowned one is forgotten.
13. **Deeds remove traits.** An event outcome may remove a named gained trait (an atonement, a reconciliation, a rite).
    A gained trait that is opposed to a held **gained** trait replaces it outright when its grade is **equal or higher**
    (notable over small); a small trait opposed to a held notable one is refused and logged, like a full-slot grant
    (rule 11). One opposed to a personality trait is held beside it (Edge Cases). Every replacement rule in this
    document uses "grade at most its own" (rule 11); "stronger" in the States table means the same.
14. **A calling follows the path.** A person who changes their path (a sect rank into a different duty, a new craft
    mastery, a new technique focus) may be offered a new calling by the event engine; the new one replaces the old.
15. **One narrow change to personality.** A breakthrough that ends in a heart-demon crisis (Realms & Bottlenecks) may offer
    one personality swap to the opposed trait of a set, once per realm. It is a choice for the player, and a seeded roll
    for NPCs weighted by Dao heart.

**Regard**

16. **Opinion is computed, not stored.** A person's opinion of another person is derived on demand from the two trait
    sets: shared traits add, opposed traits subtract, the regard pulls adjust, plus any authored tie (master, disciples,
    sect head) and the person's own stored attitude to the player when the other is the player (Formulas). No opinion is
    stored for a pair of NPCs, so the save does not grow with the number of relationships.
    **Amended 2026-11-20 by NPC Relationships (#46):** named ties (kin, sư đồ, kết nghĩa, đạo lữ, friend, enmity…) are
    the one stored exception: a small capped set of records per person (`npc-relationships.md` rules 1–7, Formula E),
    which F3's `tie` term reads. Opinion itself is still never stored, and reading it never writes a tie (AC-NT-21
    holds).
    The stored **attitude to the player** stays as built (Quests, Formulas E), and traits set its starting value when the
    player first meets someone.

**Creation, inheritance and teaching**

17. **Rolling an ordinary NPC.** Personality is 3 draws without replacement from the catalogue by weight, rejecting any
    trait whose opposite is held; weights come from the person's archetype and, for a sect member, the sect (a martial sect
    leans Brave and Warlike). The calling is 1 draw by weight from the person's path. Fate-given traits are drawn rarely from
    a birth roll tied to the spiritual root (Formulas).
18. **Inheritance and teaching.** A person with known parents inherits each parent's personality trait with a chance, once,
    before the weighted roll fills the rest. A disciple's roll weights lean toward their master's traits. Neither
    overrides rule 3's opposed-set limit.

**Reading traits**

19. **Who reads them.** Sects (leaders' and elders' pulls), the Living World Tick and Event Engine (choice weights),
    NPC Interaction & Dialogue (opinion and tone), Quests (offers and refusals, through attitude), the LLM game master
    (names and descriptions for voicing), and Character Stats (the modifier rows, through the Modifier System).
20. **The LLM game master reads, never writes.** It receives each person's trait names and one-line descriptions. It
    may propose a gained-trait id inside an event outcome; the engine validates it against the catalogue, the event budget
    and rule 11, or refuses it and logs the refusal. A proposal that carries a number, or names a personality, calling
    or fate-given trait, is refused.
21. **Cost.** Per season the engine touches only the gained traits that expire (a queue by expiry) and the people an
    event touched, so the
    season tick is proportional to events, not to the 5,000 cultivators.

**Interim choice-tag vocabulary (provisional, 2026-11-14 review).** Every event choice carries one or more of:
`aggressive`, `merciful`, `greedy`, `generous`, `deceitful`, `honest`, `loyal`, `disloyal`, `cautious`, `bold`, `vengeful`,
`forgiving`, `devout`, `pragmatic`, `social`, `solitary`, `ambitious`, `humble`, `diligent`, `indulgent`. This list is handed
to the Event Engine (#23), which owns the final vocabulary and may rename, add or remove tags; the trait-by-tag table in the
catalogue follows it. Until then the tested set is FX-CAT's tags.

### States and Transitions

Traits have no state machine of their own beyond the life of each trait on a person. Each kind follows one line:

| Kind | Enters | Can change | Leaves |
|---|---|---|---|
| Personality (3) | At creation (roll, inheritance, origin or authored) | Once per realm: a heart-demon crisis may swap one to its opposite (rule 15) | Never otherwise |
| Calling (1) | At creation, from the path | When the path changes, an event may offer a new calling (rule 14) | Replaced only |
| Fate-given (0–2) | At birth (rule 17) | Never | Never |
| Gained (0–2) | An event outcome (rule 11) | Its expiry moves forward when its trigger repeats (rule 12) | Expires, removed by a deed, or replaced by a trait of equal or higher grade, including an opposed one (rules 11–13) |

**A gained trait's life**

```
        event grants (budget ok, slot free or weaker/oldest replaced)
 none ──────────────────────────────────────────────▶ held (expires = now + fade_seasons)
  ▲                                                     │  trigger repeats: expires = now + fade_seasons
  │                                                     │
  └──── expiry reached  /  a deed removes it  /  replaced by an equal-or-higher-grade or opposed trait
```

**Season tick order** (inside the Living World Tick, after events resolve):
1. Apply trait grants and removals that this season's events produced (rules 11, 13).
2. Remove the gained traits whose expiry is this season (a queue sorted by expiry, so only those are touched; rule 12).
3. Recompute the modifier rows of the people whose traits changed (Character Stats sheet sums).
Nothing else runs per season: opinion and choice weights are computed when read.

### Interactions with Other Systems

| System | Direction | What passes between them |
|---|---|---|
| **Modifier System** (#40) | out | Each trait's stat rows as catalogue modifiers, source `trait`; F and I only, never rare or Pending stats (rules 5–7) |
| **Character Stats** (#7) | out / in | Out: the modifier rows on the sheet. In: talents (Dao heart for rule 15's swap; fortune and the root for the fate-given roll) |
| **Sects & Missions** (#26) | out | The sect pulls of a leader's and elders' traits (`design/gdd/sects.md` F15); leaders hold 3 personality traits and 1 calling |
| **Event Engine** (#23) | in / out | Out: choice weights by tag, trait-gated extra options for the player, event-kind weights (envy, betrayal...). In: outcomes that grant or remove traits, inside budgets |
| **Living World Tick** (#28) | in / out | Calls the trait season steps; uses choice weights for NPC actions |
| **NPC Interaction & Dialogue** (#30) | out | Computed opinion between two people; the starting attitude to the player at first meeting; tone hints |
| **Quests** (#31) | out | Offers and refusals read attitude, which traits shape at first meeting; quest outcomes may grant gained traits |
| **LLM Game Master** (#29) | out / in | Out: trait names and one-line descriptions. In: proposed gained-trait ids, validated by the engine (rule 20) |
| **NPC Builds** (#24) | in / out | In: archetype and path for the roll weights. Out: the trait list replaces today's `traits_per_person` flavour roll |
| **World Generation & History** (#27) | in | Authored people's fixed traits; parents and masters for inheritance |
| **Realms & Bottlenecks** (#8) | in | The heart-demon crisis that offers rule 15's swap |
| **World Database** (#3) | in / out | Per person: ≤ 8 trait ids, ≤ 2 expiry seasons, ≤ 2 target ids; the player also `heart_demon_used` |
| **Save/Load** (#5) | out | Per person: ≤ 8 trait ids, ≤ 2 expiry seasons, ≤ 2 target ids; the player also `heart_demon_used` |
| **NPC Relationships** (#46) | in / out | In: the recorded tie value for F3 (its Formula A). Out: opinion, which weights help, revenge and the sworn-sibling help chance |

### Trait list

The full catalogue lives in `design/gdd/npc-traits-catalogue.md` (2026-11-14): 37 personality traits in 18 opposed sets,
14 callings, 10 fate-given traits in 5 pairs and 16 gained traits, each with its stat rows, choice-tag weights, regard
pulls, roll weight and sect pulls. It replaced the provisional list seeded from Sects. Sects (`design/gdd/sects.md`,
Formulas F15) reads only the pull kinds, so a trait's sect effect must be expressed in those kinds. Compassionate is
opposed to both Callous and Cruel; Callous and Cruel may be held together.

**Migration of the 12 built flavour traits** (`world_names.json`): tham_lam → Greedy, hao_sang → Gregarious, an_dat →
Reclusive, da_nghi → Paranoid, chinh_truc → Honest, am_hiem → Deceitful, lanh_dam → Callous, cuong_ngao → Arrogant,
than_trong → Cautious, hieu_chien → Warlike, trung_thanh → Loyal, si_tinh → Lovestruck (gained, with no target: it is
dropped on load, since a target cannot be inferred). A person who held two opposed migrated traits keeps the first.

## Formulas

Proposed by `systems-designer` (2026-11-14), with the user's decisions on talents, names, gaps and targets. All values
are **guesses**. Random draws use ADR-0002 keyed streams; the key tuple is given. Values live in a new data file,
`assets/data/traits.json`, beside the trait catalogue.

### F1. Trait stat row size

The trait_row formula is defined as:

`value = d · floor(B · P_t / (price · u) + 1e-6) · u` (Modifier System Formulas C, unscoped, breadth 1.0)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| B | float | small 1.2; notable 8 | constant (Modifier System E) | Grade budget in W |
| P_t | float | 1.0 | data file | Trait premium (a sizing guide; no price check until the game is finished) |
| price | float | per stat | data file (`modifier_prices`) | W per unit of the stat |
| u | float | 0.01 / 0.1 / 1 | Character Stats I | The stat's grid |
| d | int | +1 boon; −1 cost | catalogue | Direction |

**Output Range:** a small row is worth about 1.2 W, a notable one about 8 W. A row that floors to 0 is not allowed at
that grade. Talent rows only at notable (rule 7): comprehension +1.6, presence +1.2 at small.
**Example:** Brave: +2.0 % `khi_huyet_pct` (1.2 / 0.6) and −0.8 pp `evade_pct`; Cautious mirrors it. Greedy: +1.7 %
`mission_income_pct` and −0.8 % `tam_ma_resist_pct`. Heaven-favoured (fate-given, notable): +26.6 % `co_duyen_pct`, paid
for through pulls (envy events ×1.5). Ill-starred: −26.6 % `co_duyen_pct` and +5.3 % `tam_ma_resist_pct`. Scarred (gained,
notable cost): −5.3 % `tam_ma_resist_pct`.

### F2. An NPC's choice weight

The choice_weight formula is defined as:

`w(c) = base_c · clamp(Π_t Π_{g ∈ tags(c)} m(t, g), m_lo, m_hi)`, or 0 if any (t, g) is flagged `never`
Pick: `u = rand01(key: "choice", event_id, person_id, season)`; take the first choice whose running sum ≥ u · Σ w.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_c | float | > 0 | Event Engine data | The choice's base weight |
| m(t, g) | float | 2.0 core affinity; 1.5 affinity; 1.0; 0.67 aversion; 0.5 core aversion | data file (catalogue) | Trait-by-tag weight; "core" when the trait is named for the tag |
| never | bool | explicit flag only | catalogue | E.g. Honest on `deceitful` (matches Sects F15's pact keeping) |
| m_lo, m_hi | float | 0.1; 5.0 | data file | Clamp on the product |

**Output Range:** 0.1 · base to 5 · base, or 0 with `never`. If every choice is 0, base weights are used.
**Example:** "a rival insults you", a Wrathful, Vengeful NPC: retaliate (aggressive, vengeful) 1.5 · 2.0 = 3.0; endure
(cautious) 0.67; reconcile (merciful) 0.67 (Vengeful's aversion): odds **69 / 15 / 15 %**.

### F3. Opinion and the starting attitude to the player

The opinion formula is defined as:

`op(a → b) = clamp(s · n_sh − o · n_op + Σ_{t ∈ T_b} bias_all(t) + Σ_{t ∈ T_a} bias_dir(t, b) + tie(a, b) + sect(a, b) + target(a, b), −100, 100)`
`att0 = clamp(round(op(npc → player) + k_st · standing), hostile_threshold + 1, att0_max)` at the first meeting

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_sh | int | 0–4 | calculated | Shared personality traits plus a shared calling |
| n_op | int | 0–5 | calculated | Opposed pairs between the two people's personality and gained traits (never within one person) |
| s, o | int | 10; 10 | data file | Equal, so the world's mean opinion stays near 0 |
| bias_all | int | Humble +5; Arrogant −5; Renowned +5 | catalogue (same numbers as Sects F15) | Held by b; everyone's view |
| bias_dir | int | Devout −10 to the opposite alignment; Cruel −10 to rivals: people whose sect is at feud or war with a's sect (Sects F7's lines; user decision 2026-11-21) | catalogue | Held by a, toward b |
| tie | int | master or disciple +30; kin +30; Dao companion +50; own sect head +15 | data file | Authored and recorded ties. Since 2026-11-20 the recorded part is NPC Relationships Formula A (`tie_value`, −70 to +105 before F3's clamp: these values plus kết nghĩa, companion, blood feud, soft ties and a debt of gratitude at their strength; a Grudge target and the tie's feud plus enmity form one term, the more negative, 2026-11-21); own sect head +15 stays here, computed from the sect |
| sect | int | same sect +10; else 0.2 · A_sect (−20 – 20) between NPCs; toward the player only +10 for the same sect, else 0 (standing already counts through k_st) | Sects F7 | Sect colouring |
| target | int | ±50 | catalogue | A targeted gained trait toward its target (Lovestruck +50, grudge −50) |
| standing | float | −100 – 100 | Sects F10 | The player's standing with the NPC's sect |
| k_st | float | 0.25 | data file | Weight of standing |
| hostile_threshold | int | −30 | Sects & Missions (`session_actions.json`, read only; Quests reads it too) | The floor is −29: traits alone never make a stranger hostile |
| att0_max | int | 30 | data file | Ceiling at a first meeting |

**Output Range:** op −100 to 100; att0 −29 to 30. After the first meeting the stored attitude moves as Quests says.
**Example:** a Brave, Vengeful, Devout (chính) NPC meets a Brave, Forgiving, Humble, ma-aligned player with standing −20:
+10 − 10 + 5 − 10 − 5 = **att0 −10**. A Brave master and a Brave disciple in different sects: 10 + 30 = **40** (50 in the same sect).

### F4. Creation roll

The trait_roll formula is defined as:

Personality: `w_t = b_t · m_arch(t) · m_sect(t) · m_master(t)`; 3 draws, each removing t and opp(t) from the pool.
Calling: 1 draw from `w_c` over the callings the path allows. Fate-given: P(0 / 1 / 2) = 0.90 / 0.09 / 0.01, then
`w_f = b_f · g_f`; the second draw removes the first trait and its opposite from the pool (a person never holds
Heaven-favoured with Ill-starred). Key ("traits", person_id).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| b_t, b_f | float | b_f 1.0; b_t 0.5–1.0 (1.0 except Cruel 0.5, Arbitrary 0.7; catalogue) | data file | Base weights |
| m_arch, m_sect | float | 0.5 / 1 / 2 | data file | Leans (a martial sect ×2 on Brave and Warlike) |
| m_master | float | 3 on the master's traits | data file (F5) | Teaching |
| p_any, p_second | float | 0.10; 0.10 | data file | Fate-given count |
| g_f | float | 0.25–3 | calculated | Heaven-favoured clamp(eff(khi_van) / 45); Ill-starred clamp(45 / eff(khi_van)); root-bound traits 0 unless the root qualifies |

**Output Range:** 3 distinct, non-opposed personality traits; 1 calling; 0–2 fate-given traits.
**Example:** fortune 72 gives Heaven-favoured g 1.6 and Ill-starred 0.63. In 5,000 cultivators, about 450 hold one
fate-given trait and 50 hold two; each personality trait is held by about 3/37 of people (about 400).

### F5. Inheritance and teaching

The inherit formula is defined as:

For each known parent, one roll with chance h (key ("inherit", child_id, parent_id)); on success, one of that parent's
personality traits not held and not opposed, chosen uniformly. F4 fills the rest, with `m_master` on the master's traits.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| h | float | 0.5 | data file | Chance per parent |
| m_master | float | 3 | data file | Lean toward a master known at creation |

**Output Range:** 0–2 inherited traits (about 1 with two known parents).
**Example:** a disciple shares 0.60 of the master's traits on average (an expected count out of 3, not a 60 % fraction), against 0.24 at random (3 · 3/37; checked by
`qa-lead` over 100,000 rolls). A master taken later passes on
only a calling (rule 14).

### F6. Gained traits: expiry, replacement and the world's stock

The fade formula is defined as:

`expires` is the stored field (rule 3): set to `now + F` on a grant and on a refresh; removed when `now ≥ expires`
Replacement: an opposed trait replaces outright; otherwise the new trait replaces the oldest held one whose grade is ≤ its
own; if none, the grant is refused and logged. Steady state: `N_gained ≈ λ · F`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| F | int | 40 seasons | data file | `fade_seasons` |
| expires | int | season | World DB | Stored expiry season, reset to now + F by a grant or refresh |
| λ | float | about 25 grants a season (unknown) | Event Engine | World grant rate |

**Output Range:** about 1,000 gained traits held at once; 18 % of people hold one or more, 1.8 % hold two.
**Example:** Scarred gained in season 100 expires in season 140; a second battle in season 130 moves it to 170.

### F7. The player acting against or with a trait

The trait_conflict formula is defined as:

`Δtâm_ma = min(tm_a · n_against, tm_cap − heart_demon_used)` per choice, the cap counted across all of a season's
choices (`heart_demon_used`, the player record's saved counter, adds the pre-resistance gain and resets each season) and
applied before Character Stats' heart-demon resistance;
when the choice carries a **sect id** (a sect-affecting choice, set by the Event Engine), `Δstanding = −st_a` with that sect;
acting in character: `cost' = cost · (1 − r)^min(n_with, 2)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| tm_a | float | 2 | data file | Heart demon per conflicting trait (a failed breakthrough is 15) |
| tm_cap | float | 6 | data file | Cap a season, so heart demon cannot become a soft lock |
| st_a | int | 3 | data file | Standing cost |
| r | float | 0.10 | data file | Cost reduction in character |
| n_against, n_with | int | 0–8 | calculated | Per held trait t, take its product `p_t = Π_{g ∈ tags(c)} m(t, g)` over the choice's tags: t counts **against** when `p_t < 1`, **with** when `p_t > 1`, and neither when `p_t = 1` (so a trait with an affinity and an aversion across one choice's tags nets out by product; `never` counts as against) |

**Output Range:** heart demon +0 to +6 a season; costs down by at most 19 %. Acting in character never heals heart demon.
**Example:** an Honest, Loyal player who breaks an oath gains 4 heart demon (3.8 with 5 % resistance). A Greedy player pays
90 instead of 100 for a bribe option.

### F8. A personality swap at a heart-demon crisis (NPC)

The swap formula is defined as:

`P_swap = max(0, p_s · (100 − eff(dao_tam)) / 55)` (the maximum is 0.545 at Dao heart 1, so no cap is needed); the trait is chosen uniformly among those that may swap,
key ("swap", person_id, realm)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p_s | float | 0.30 | data file | Chance at Dao heart 45 |
| eff(dao_tam) | float | 1–150 | Character Stats B | Effective Dao heart |

**Output Range:** 0 to 0.54 in practice (0 at Dao heart 100 or more).
**Example:** Dao heart 1 / 20 / 45 / 80 → 0.54 / 0.44 / 0.30 / 0.11. A Callous person cannot swap to Compassionate while
Cruel is held. Compassionate swaps to Callous or Cruel by a seeded pick (key ("swap_to", person_id, realm)).

**Riskiest values:** opinion's s against o (F3); λ, which depends on event volume (F6); tm_a and tm_cap (F7); keeping
`never` to explicit flags (F2).

## Edge Cases

**Holding and replacing**

- **A roll would draw an opposed trait.** It cannot: each draw removes the trait and its opposite from the pool (F4).
  If the pool empties (possible only if a lean of 0 is allowed), the remaining draws are skipped and the person holds
  fewer than 3; this is logged, and no AC band allows it above 0.1 % of people.
- **Two parents give opposed traits.** The first inherited trait is kept; the second roll skips any trait opposed to it.
- **A gained trait arrives and both slots are full of stronger traits.** The grant is refused and logged (F6); the event's
  other outcomes still apply.
- **A gained trait is opposed to a personality trait** (Humbled on an Arrogant person). It is allowed: gained traits
  colour, they do not erase. Opinion counts the pair as opposed only between two people, never within one.
- **A targeted gained trait's target dies.** The target id is cleared from the save and the target term drops to 0. A
  Grudge stays until it expires, keeping its own tag weights (vengeful affinity 1.5 on choices tagged `vengeful`, as F2
  multiplies over a choice's own tags only), so it reads as a general bitterness. Lovestruck whose target dies is replaced by Grieving (a gained trait) at once.
- **The player is the target of an NPC's grudge.** The target term (−50) enters the NPC's opinion of the player; the stored
  attitude to the player is not changed by it, so Quests' attitude rules stay the only writer of that number.

**Stats and sizes**

- **A trait row would floor to 0 at its grade.** That stat is not allowed for the trait at that grade (F1); the catalogue
  lint rejects it.
- **A trait row names a Pending, rare or damage-layer stat.** Data validation rejects it (rules 5, 7).
- **A personality swap would break an opposed set** (Callous to Compassionate while holding Cruel). The swap picks another
  trait, or none if none may swap (F8).
- **The player refuses the rule-15 swap.** Nothing changes; the offer does not return for that realm.

**Choices and the player**

- **Every choice of an NPC's event has weight 0** (all `never`). Base weights are used (F2).
- **A player choice is against several traits.** Heart demon gain is capped at 6 a season (F7); the option is never
  greyed out (rule 9).
- **An LLM outcome proposes a trait id not in the catalogue, a personality or fate-given trait, or a trait over budget.**
  Refused and logged (rule 20); only gained traits may be granted by events.

**Migration and authored people**

- **An old save holds the 12 built flavour ids.** The migration also retires `traits_per_person`
  (`assets/data/world_generation.json`, read in `build_generator.gd`), which F4 replaces. They map as the migration table says; si_tinh is dropped (no target); a
  person with fewer than 3 personality traits after mapping is filled by F4 with its seeded key, and every migrated
  person rolls a calling and fate-given traits by F4 with the same key.
- **An authored person's fixed traits break a rule** (two opposed, four personality). The world data load fails and names
  the person and the rule.

**Sects**

- **A sect leader changes traits mid-season** (a gained trait, a swap). Sects reads the new pulls from the next tick, as
  with succession (Sects rule 15).
- **Gained and fate-given traits carry sect pulls.** Allowed; a sect sums over all its leader's traits (Sects F15). The
  sums stay within F15's stated output range, or the catalogue lint flags the trait.

## Dependencies

**Upstream (this system reads them)**

| System | Hard / soft | Interface | Lists NPC Traits back? |
|---|---|---|---|
| Modifier System (#40) | Hard | Stat List keys, F and I operations, grades (small 1.2, notable 8), rounding grid | Yes (modifiers.md, added 2026-11-14) |
| Character Stats (#7) | Hard | Talents (fortune for F4, Dao heart for F8); the sheet that sums the rows; heart-demon gain (F7) | Yes (character-stats.md, added 2026-11-14) |
| World Database (#3) | Hard | Person records: trait ids, expiries, targets, parents, master | — (no GDD) |
| NPC Builds (#24) | Hard | Archetype and path for the roll leans; replaces `traits_per_person` | — (no GDD) |
| Time & Turn (#4) | Hard | The season clock for expiries | — (no GDD) |
| Event Engine (#23) | Hard | Choice tags on every choice; outcomes that grant or remove gained traits | — (no GDD) |
| World Generation & History (#27) | Soft | Authored people's traits, ties, parents and masters | — (no GDD) |
| Realms & Bottlenecks (#8) | Soft | The heart-demon crisis that offers rule 15's swap | Yes (canh-gioi.md, added 2026-11-14) |
| Sects & Missions (#26) | Soft | Sect leans for the roll (F4); standing for att0 (F3); sect attitude (F3) | Yes (F15, rule 11) |
| NPC Relationships (#46) | Soft | The recorded part of F3's `tie` term (its Formula A); without it `tie` is 0 except the sect head | Yes (npc-relationships.md, 2026-11-20) |

**Downstream (they read this system)**

| System | Hard / soft | Interface | Lists NPC Traits back? |
|---|---|---|---|
| Sects & Missions (#26) | Hard | Sect pulls of leaders and elders (F15 contract) | Yes |
| Living World Tick (#28) | Hard | Trait season steps; choice weights for NPC actions | — (no GDD) |
| Event Engine (#23) | Hard | Choice weights, trait-gated options, event-kind weights | — (no GDD) |
| NPC Interaction & Dialogue (#30) | Soft | Opinion, att0, tone hints | — (no GDD) |
| Quests (#31) | Soft | att0 at first meeting; gained traits from outcomes | Yes (quests.md, added 2026-11-14) |
| LLM Game Master (#29) | Soft | Names and descriptions; proposals validated | — (no GDD) |
| Save/Load (#5) | Hard | ≤ 8 ids, ≤ 2 expiries and ≤ 2 targets per person | — (no GDD) |
| NPC Relationships (#46) | Hard | F3 opinion for help and revenge weights and `p_help`; rule 16 (amended) | Yes |
| Codex & Karmic Carryover (#12) | Soft | An heir successor keeps their traits' stat rows, and trait-gated event options appear for the player; nothing is forced (`codex-karmic-carryover.md` Edge Cases) | Yes |

**Links:** Modifier System, Character Stats, Realms & Bottlenecks, Quests and Sects & Missions all list NPC Traits back.
Every other row marked "no GDD" is fixed when that system is designed.

## Acceptance Criteria

Drafted with `qa-lead` (2026-11-14); the F5 example was corrected from its check, and its gaps were settled in the
sections above. Nothing has run yet; every value is a guess until AC-NT-36 passes. Tests never call a live model. Every
draw uses an ADR-0002 keyed stream. Unit tests in `tests/unit/npc_traits/`, integration tests in
`tests/integration/npc_traits/`, timing and statistics in `production/qa/evidence/balance/`. Tolerance ±0.01 or one grid
step unless stated.

**Fixtures**
- **FX-D:** the Formulas defaults in `assets/data/traits.json` (s = o = 10, F 40, m_lo 0.1, m_hi 5, h 0.5, m_master 3,
  p_any = p_second 0.10, tm_a 2, tm_cap 6, st_a 3, r 0.10, p_s 0.30, k_st 0.25, att0_max 30), with the Modifier
  System prices `khi_huyet_pct` 0.6, `evade_pct` 1.5, `mission_income_pct` 0.7, `tam_ma_resist_pct` 1.5, `co_duyen_pct`
  0.3, `ngo_tinh` 5, `mi_luc` 1.0.
- **FX-CAT:** the catalogue's 37 personality traits in 18 sets and its 6 seed callings (`npc-traits-catalogue.md`) plus test gained traits Scarred (notable),
  Renowned (small, bias_all +5), Humbled (small), Grudge (targeted, −50), Lovestruck (targeted, +50), Grieving. Tag weights:
  Wrathful × aggressive 1.5, Vengeful × vengeful 2.0, Wrathful × cautious 0.67, Vengeful × merciful 0.67, Honest × deceitful
  `never`; all other pairs 1.0.
- **FX-W5K:** a generated world of 5,000 people from a fixed seed, default leans, no authored people.
- **FX-EV:** an Event Engine stub granting λ = 25 gained traits a season to keyed, uniformly drawn people, half small and
  half notable.
- **FX-LLM:** a mock returning scripted outcomes. **FX-OLD:** a save from the current build (`traits_per_person` 2 from the
  12 built ids).

**Record and kinds**

- **AC-NT-01** [Logic] Rules 2–3. **GIVEN** any person in FX-W5K, **THEN** they hold 3 personality traits with no opposed
  pair, 1 calling, 0–2 fate-given and 0–2 gained traits (≤ 8 ids); each gained trait has one expiry, and only targeted ones
  a target. **WHEN** an API call adds a 4th personality trait, a 2nd calling or a 3rd fate-given trait, **THEN** it is
  rejected.
- **AC-NT-02** [Logic] Rule 4. **GIVEN** the player and an NPC with identical trait ids, **THEN** their stat rows and F2
  tag multipliers are identical.

**Stat rows (F1, rules 5–7)**

- **AC-NT-03** [Logic] F1. **GIVEN** FX-D, **THEN** Brave gives +2.0 % `khi_huyet_pct` (not 1.9: the +1e-6 term is
  load-bearing) and −0.8 pp `evade_pct`; Greedy +1.7 % `mission_income_pct` and −0.8 % `tam_ma_resist_pct`;
  Heaven-favoured +26.6 % `co_duyen_pct`; Ill-starred −26.6 % `co_duyen_pct` and +5.3 % `tam_ma_resist_pct`; Scarred −5.3 %
  `tam_ma_resist_pct`; a notable `ngo_tinh` row +1.60; a small `mi_luc` row +1.20.
- **AC-NT-04** [Config] Rules 5–7 lint. **GIVEN** catalogue entries each breaking one rule (a `more` row; `attack_pct`,
  crit or a combat offence row; a Pending or rare stat; a talent row at small; a personality or calling trait without
  exactly one boon and one cost row; a row that floors to 0), **THEN** the load rejects each and names the trait and rule.
- **AC-NT-05** [Integration] Rule 5. **GIVEN** Scarred gained in season 100 by a person at 0 % `tam_ma_resist_pct`,
  **THEN** the sheet reads −5.3 %; **WHEN** season 140 runs, **THEN** after tick step 3 it reads 0 % and no `trait`
  modifier for Scarred remains.

**Pulls and the player rule (F2, F7, rules 8–9)**

- **AC-NT-06** [Logic] F2. **GIVEN** a Wrathful, Vengeful NPC and choices retaliate (aggressive, vengeful), endure
  (cautious), reconcile (merciful), base 1 each, **THEN** weights are 3.0 / 0.67 / 0.67 (Σ 4.34), odds 69.1 / 15.4 / 15.4 %;
  u = 0.50 picks retaliate, 0.75 endure, 0.90 reconcile.
- **AC-NT-07** [Logic] F2 bounds. **GIVEN** a product of 2.0⁴, **THEN** the weight is 5.0 · base; 0.5⁴ gives 0.1 · base;
  Honest on a deceitful choice gives 0; every choice at 0 falls back to base weights.
- **AC-NT-08** [Integration] Rule 8, sect pulls. **GIVEN** a Greedy, Cruel, Cautious Strategist leader, **THEN** Sects
  receives Tax +1, loyalty −1, war odds 0.8 (lowest of 0.8 / 1.2 / 0.9) and first track Military; **GIVEN** the leader
  also holds a gained trait with a Tax pull, **THEN** it is summed too. Every catalogue pull is one of Sects F15's kinds, or
  the lint fails.
- **AC-NT-09** [Integration] Rule 9, never blocked. **GIVEN** every event template, each single trait in the loaded catalogue (FX-CAT: 37 personality, 6 callings and
  the 6 test gained traits) and 1,000 keyed random trait sets, **THEN** the player's selectable options with traits are a superset of those with no traits; no
  option is disabled or hidden.
- **AC-NT-10** [Logic] F7. **GIVEN** an Honest, Loyal player at 0 % resistance breaking an oath on a choice carrying a sect id, **THEN**
  heart demon +4 and standing −3 (3.8 at 5 % resistance); 3 traits against give +6 (5.7 at 5 %), 4 against +6; a second
  against-choice (2 traits) the same season after +4 adds only +2, and the cap resets next season. In-character costs: 100
  → 90 with 1 trait, 81 with 2, 81 with 3; in character never lowers heart demon. **GIVEN** a Wrathful person (aggressive
  1.5, cautious 0.67) and a choice tagged aggressive and cautious (product 1.005), **THEN** the trait counts as neither
  with nor against; a choice tagged only cautious counts it against.

**Gaining and losing (F6, rules 11–15)**

- **AC-NT-11** [Logic] F6 expiry. **GIVEN** Scarred gained in season 100, **THEN** it expires at 140; **WHEN** its trigger
  repeats in season 130, **THEN** it expires at 170 (held in 169, gone after 170's step 2). Granting a held trait refreshes
  it, never duplicates it.
- **AC-NT-12** [Logic] F6, full slots. **GIVEN** Scarred (notable, season 100) and Renowned (small, season 120) held,
  **WHEN** a small trait arrives in season 130, **THEN** it replaces Renowned; **WHEN** a notable one arrives instead, **THEN**
  it replaces Scarred; **GIVEN** two notable traits held, **WHEN** a small one arrives, **THEN** it is refused and logged and
  the event's other outcomes apply.
- **AC-NT-13** [Logic] Rule 13. **GIVEN** a gained trait opposed to a held gained trait of equal or lower grade, **THEN**
  it replaces it whatever its age; **GIVEN** a small trait opposed to a held notable one, **THEN** the grant is refused
  and logged; **GIVEN** Humbled on an Arrogant person, **THEN** both are held, and the pair never counts in n_op within one
  person.
- **AC-NT-14** [Logic] Rule 13, deeds. **WHEN** an outcome removes a held gained trait, **THEN** it is gone that season;
  removing one not held is a logged no-op; removing a personality or fate-given trait by event is refused.
- **AC-NT-15** [Logic] Rule 14. **WHEN** a path change's new calling is accepted, **THEN** exactly 1 calling is held, with
  the old rows gone and the new present.
- **AC-NT-16** [Logic] Target dies. **GIVEN** A holds Grudge → B, **THEN** op(A → B) includes −50; **WHEN** B dies in
  season s, **THEN** the target id is cleared, the Grudge keeps its expiry and its target term is 0; **GIVEN** Lovestruck →
  B instead, **THEN** in season s it becomes Grieving, expiring at s + 40.
- **AC-NT-17** [Integration] **GIVEN** an NPC with Grudge → player, **THEN** op(NPC → player) includes −50, and the stored
  attitude to the player is byte-identical before and after the grant.
- **AC-NT-18** [Logic] F8. **GIVEN** Dao heart 1 / 20 / 45 / 80 / 100 / 150, **THEN** P_swap is 0.54 / 0.436 / 0.30 /
  0.109 / 0 / 0; **GIVEN** a Callous, Cruel, Brave person, **THEN** only Brave → Cautious may swap; a Compassionate swap picks
  Callous or Cruel by its key; a second crisis in the same realm makes no roll; a player who refuses is not asked again that
  realm.

**Regard (F3, rule 16)**

- **AC-NT-19** [Logic] F3. **GIVEN** the Formulas example (no shared calling, sect term 0), **THEN** op = −5 and att0 =
  −10; **GIVEN** a Brave master and Brave disciple in different sects, **THEN** op = 40, and 50 in the same sect.
- **AC-NT-20** [Logic] F3 clamps. **GIVEN** a raw op of +150, **THEN** op = 100; op −100 with standing −100 gives att0 −29;
  op 100 gives att0 30; att0 is written only at the first meeting.
- **AC-NT-21** [Integration] Rule 16. **WHEN** 1,000,000 opinions are read in FX-W5K, **THEN** the save is byte-identical
  before and after and holds no pair records.

**Creation and inheritance (F4, F5, rules 10, 17–18)**

- **AC-NT-22** [Logic] F5. **GIVEN** two known parents, **THEN** over 100,000 keyed rolls 0 / 1 / 2 inherited traits occur
  25 / 50 / 25 % ± 1 pp; parents holding Brave and Cautious never give a child both; with uniform weights and m_master 3 a
  disciple shares 0.60 ± 0.02 of the master's 3 traits, against 0.24 ± 0.02 at random.
- **AC-NT-23** [Logic] F4. **GIVEN** fortune 72, **THEN** g is 1.6 (Heaven-favoured) and 0.625 (Ill-starred); fortune 5
  clamps them to 0.25 and 3; a root-bound trait has weight 0 when the root does not qualify.
- **AC-NT-24** [Logic] F4 opposed sets. **WHEN** Compassionate is drawn, **THEN** Callous and Cruel leave the pool; **WHEN**
  Callous is drawn, **THEN** only Compassionate leaves. Over 100,000 rolls no opposed pair appears, and Callous with Cruel
  appears at least once.
- **AC-NT-25** [Logic] Rule 10. **GIVEN** a fixture origin and its answers, **THEN** the player's 3 personality traits are
  the origin table's, the calling follows the starting path, and fate-given traits use key ("traits", player_id).

**LLM and reading (rules 19–20)**

- **AC-NT-26** [Integration] Rule 20. **GIVEN** FX-LLM proposals of an unknown id, a personality id, a fate-given id, an
  over-budget gained id and a gained id with a number, **THEN** each is refused and logged with its reason and the other
  outcomes apply; a valid in-budget gained id is granted.
- **AC-NT-27** [Integration] Rule 20. **THEN** the LLM payload for a person holds trait names and one-line descriptions only.

**Migration and authored data**

- **AC-NT-28** [Integration] Migration. **GIVEN** FX-OLD, **THEN** all 12 ids map as the table says; [hao_sang, an_dat]
  becomes Gregarious plus 2 F4 fills (never Reclusive); [si_tinh, tham_lam] becomes Greedy plus 2 fills, no Lovestruck;
  [chinh_truc, am_hiem] keeps Honest; every person gets a calling and a fate-given roll, then passes AC-NT-01; loading twice
  gives identical traits.
- **AC-NT-29** [Config] **GIVEN** an authored person with Brave + Cautious, 4 personality traits, an unknown id, 2
  callings or 3 fate-given traits, **THEN** the world load fails and names the person and the rule.

**Timing, cost and determinism**

- **AC-NT-30** [Integration] Sect read timing. **GIVEN** a leader who gains Greedy in season s's events, **THEN** the
  sect's Tax uses the old pulls through season s and includes +1 from s + 1; a swap behaves the same.
- **AC-NT-31** [Logic] Determinism. **GIVEN** one seed twice, **THEN** every person's ids, expiries and targets hash
  equal; person 4,321 generated alone equals the same person in a full run; changing person 1 leaves person 2's roll
  unchanged; F2, F5 and F8 reproduce from their keys.
- **AC-NT-32** [Integration] Rule 21. **GIVEN** a season with 25 grants and 25 expiries, **THEN** at most 50 people are
  touched, at 5,000 and at 50,000 people.
- **AC-NT-33** [Integration] Performance (guess; no minimum-spec PC is set yet). **GIVEN** FX-W5K and FX-EV in a release
  export, **THEN** the three season steps take ≤ 2 ms median and ≤ 5 ms p99 over 200 seasons; 50,000 people take ≤ 1.25 ×
  the time of 5,000; creating 5,000 people ≤ 300 ms; 10,000 opinion reads ≤ 50 ms.
- **AC-NT-34** [Integration] Save size. **GIVEN** FX-W5K after 200 seasons of FX-EV, **THEN** every person has ≤ 8 ids,
  ≤ 2 expiries and ≤ 2 targets, and the world's trait data is ≤ 200 KB (a guess).

**World statistics** [Integration] (bands are guesses)

- **AC-NT-35** **GIVEN** FX-W5K, **THEN** people with ≥ 1 fate-given trait are 8.5–11.5 % and with 2 are 0.6–1.4 %; opposed
  personality pairs held together are exactly 0, and so are Heaven-favoured with Ill-starred; people with fewer than 3 personality traits ≤ 0.1 %; with uniform weights
  each personality trait is held by 7.0–9.3 %, and with default leans by 4–13 %; everyone holds exactly 1 calling.
- **AC-NT-36** **GIVEN** FX-W5K after 200 seasons of FX-EV, **THEN** the gained-trait stock is 850–1,100 (λ · F = 1,000),
  people holding ≥ 1 are 15.5–20.5 %, and holding 2 are 1.0–2.8 %.

## Open Questions

User direction, 2026-11-10 and 2026-11-14: traits work like the character traits of grand-strategy games; they decide how
people act around events and lightly affect stats; leaders' personalities drive sect policy (Sects). Decided 2026-11-14:
NPCs and the player both have traits; four kinds; all kinds carry stats; gained traits fade; opinion is computed; weighted
roll with inheritance and teaching; 18 sets; fate-given named bẩm sinh; talents only at notable; one stored target per
gained trait.

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | ~~The full catalogue~~ **Answered 2026-11-14:** `design/gdd/npc-traits-catalogue.md` (37 personality, 14 callings, 10 fate-given, 16 gained); its own open items cover leans, trigger ids and world-price events | user, game-designer | — |
| 2 | The final choice-tag vocabulary; an interim list stands in Core Rules, and the Event Engine (#23), which has no GDD, owns the final one | game-designer | F2 beyond FX-CAT, AC-NT-09 |
| 3 | The event budget's unit for granting a gained trait (Event Engine) | systems-designer | rule 11 |
| 4 | Origin questions that set the player's 3 personality traits (Game UI and origins) | user | AC-NT-25 |
| 5 | The world grant rate λ (about 25 a season) depends on event volume, unknown until the Event Engine is designed | systems-designer | AC-NT-36 |
| 6 | A minimum-spec PC and frame budget for AC-NT-33 (`project.yaml` has none) | technical-director | AC-NT-33 |
| 7 | Whether opinion s and o should differ (o > s makes the world quarrelsome) | user | F3 |
| 8 | Grudge (targeted gained trait, `target` −50) against an NPC Relationships enmity tie toward the same person: no-stack for now (F3 takes the more negative), or retire Grudge in favour of the tie (`npc-relationships.md` OQ 2) | user | F3 |
