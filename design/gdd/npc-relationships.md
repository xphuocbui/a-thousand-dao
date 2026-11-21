# NPC Relationships

> **Status**: In Design
> **Author**: user + Claude
> **Last Updated**: 2026-11-21 (twelfth design-review revision: 3 round-12 blockers, all in favour clearing)
> **Last Verified**: 2026-11-20
> **Implements Pillar**: Pillar 5 "A World That Remembers"; Pillar 4 "Every Season Counts"
> **Creative Director Review (CD-GDD-ALIGN)**: REVISED 2026-11-20 — concern 1 (Pillar 4: free help calls and errands)
> revised with `help_cost` and `errand_cost` (2026-11-21 design-review: `help_cost` replaced by an owed favour, repaid by a deed (a call-in event) or optionally by `favour_cost`; errands bounded by `errands_max` and `errand_margin`); concern 2 (Pillar 3: flat master and đạo lữ cultivation rows) CONCERNS
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
are never evicted; soft ties (friend, rival, enmity) and debts of gratitude (ân tình), which sit beside them, compete for the remaining slots and fade. The player's ties use the same record; the stored attitude to the player (Quests, Formulas E)
is unchanged. Rule 16 is amended: ties are the one stored exception, and reading an opinion never creates or changes a
tie.

Without it the world is a crowd of strangers whose only links are traits and sect membership. Pillar 5, "A World That
Remembers", needs a death to leave a feud, a rescue to leave a debt, and a disciple to carry a master's name.

## Detailed Design

### Core Rules

**The record**

1. **One record per pair.** A tie is stored as one record between two people `(a, b)`, indexed from both sides. A record
   holds a **set of pinned kinds** (flags: a father who is also his son's master holds kin and sư đồ; a kinslayer's
   kin hold kin and blood feud), at most **one soft kind** (a master and disciple who fell out hold sư đồ and enmity
   together), at most **one debt of gratitude** (rule 1a) and a **`favour_owed`** flag with its direction (rule 15a).
   Fields: the two ids, pinned flags; the soft kind with its strength and last-set season; the debt with its
   direction, strength and last-set season; `favour_owed`; and a **cause** for the soft kind, the debt and the blood
   feud (rule 1b). **Enmity and a blood feud are held per direction** (2026-11-21 round 3): each direction holds its
   own strength (enmity), last-set season, cause and, on a feud, its own `inherited` flag (rule 13), so A's enmity
   toward B at 70 and B's toward A at 30 are both storable; friend and rival share one strength. The record still
   holds one soft kind: enmity in either direction is that kind. Strengths are stored in hundredths (Formula B).
   **Record-level strength (round 4):** where a rule compares or reads one strength of the soft kind (rule 7's
   eviction strength, rule 10's replace test), it is the larger of the two directions' current strengths. Fade
   (Formula B), writes (Formula C), the sweep (rule 4) and hardening (rule 11) run **per direction**: a direction at
   0 is removed on its own and the kind ends when both are 0; a replacing soft kind wipes both directions. A record
   also holds an `outside_cap` marker on the side of a killer or feud target who holds mourner enmity (rule 7).
   A record counts once against each person's cap, whatever it holds, **except a record marked `outside_cap` on the
   marked side, which does not count there (rule 7)**.
1a. **Debts of gratitude (ân tình) are their own part** of the record, not a soft kind, so a rescued friend stays a
   friend and also owes the rescuer (user decision 2026-11-21). A debt runs debtor → creditor, has a strength, fades
   (Formula B) and passes to heirs (rule 13). A new debt the same way adds to it (Formula C); a new debt the other way
   is netted against it: the larger remains, at the difference, and a difference of 0 removes it.
1b. **Cause (user decision 2026-11-21, answers Open Question 1).** Each soft kind, debt and blood feud stores a cause
   (`authored`, `event`, `fight`, `rescue`, `betrayal`, `kill`, `inherited`, `slight`) and a link to the event-log
   entry that set it. Authored news and person cards read names, places and the dead from that entry, so text never
   needs the LLM. A cause is rewritten only when its part is set anew (a replaced soft kind, a hardened feud), not
   when its strength changes. **The cause carries its own payload** (event kind, the other party, the dead or the
   killer, season and `location_id`), so authored text still reads after the Living World Tick's yearly upkeep prunes
   the event-log entry; the link is kept while the entry lives. **Every end of a part or record writes a `tie_end` log entry** with a
   reason, the old cause payload and, for an end by a death, that death's payload (the place, the season, the cause of
   death and the killer **only when the kill is known**, so a secret kill never leaks through the news). The reasons
   and what produces them (round 5, round 6). **Precedence:** when a feud's holder and target both die in the same
   season, the target's reason (`avenged`, `slain`, `target_died`) wins over `holder_died`.

   | Reason | Produced by | News kind |
   |---|---|---|
   | `avenged` | a feud or enmity's target killed by the holder, or by someone who held a feud or enmity toward that target (rule 14) | `feud_end_avenged` |
   | `slain` | the target killed by anyone else, killer known | `feud_end_slain` |
   | `target_died` | the target dies and there is no known killer: lifespan, failed breakthrough, a hazard or monster, or a secret kill. The payload's cause of death splits the text: lifespan (old age) / failed breakthrough or tribulation (heaven's judgement, thiên phạt) / other | `feud_end_natural` |
   | `holder_died` | the holder dies and no heir takes the feud (rule 13) | `feud_end_holder_died` |
   | `partner_died` | any other record removed because either person died (kin, sư đồ, kết nghĩa, đạo lữ, companion in a fight) | none (the death's own news) |
   | `faded` | strength reaches 0, by fading (rule 4) or by a negative Δ (Formula C) | none; the player's own fades list on the relationships page |
   | `replaced` | a part overridden: a soft kind by a stronger or deed kind (rule 10), soft enmity by hardening (rule 11) or by an inherited feud (rule 13) | none |
   | `cancelled` | a debt netted to 0 (rule 1a) or cancelled by a death (rule 13: the dead owed it) | none |
   | `evicted` | rule 7 or a lost-notability eviction (rule 6) | news for the player's ties |
   | `betrayed` | rule 12 | `betrayal` |
   | `repaid` | rule 14 repayment | `debt_repaid` |
   | `parted` | the companion dismissed or left; sư đồ ended by expulsion or leaving the sect; đạo lữ or kết nghĩa ended by an Event Engine `tie_end` that says so | `parted` |
2. **Tie kinds.**

   | Kind | Class | Direction | Notes |
   |---|---|---|---|
   | Kin (thân tộc) | pinned | both | Parent, child, sibling only. Wider clan is a `clan_id` on the person, not a tie |
   | Master and disciple (sư đồ) | pinned | master → disciple | A disciple has at most one living master |
   | Sworn siblings (kết nghĩa) | pinned | both | |
   | Dao companion (đạo lữ) | pinned | both | At most one living đạo lữ per person |
   | Blood feud (huyết thù) | pinned | holder → target, or both | Hardened enmity (rule 11) or a death's feud (rule 13); passes to heirs |
   | Companion (đồng hành) | pinned | both | Player and NPC only, from the recruit verb (NPC Interaction & Dialogue rule 11); ends when dismissed or when the NPC leaves |
   | Friend (bằng hữu) | soft | both | |
   | Rival (đối thủ) | soft | both | Competitive respect, not hatred |
   | Enmity (thù hận) | soft | holder → target, or both | |
   | Debt of gratitude (ân tình) | debt | debtor → creditor | Its own part, beside the soft kind (rule 1a) |

   Pinned ties have no strength; their weight is fixed per kind (Formulas). Soft kinds and debts carry a strength.
3. **Opinion stays computed (amends NPC Traits rule 16).** Opinion is still derived on demand from NPC Traits F3. The
   `tie(a, b)` term reads this system's record: the largest positive pinned value, plus a blood feud's negative value,
   plus the soft kind's and the debt's values at their current strengths (Formula A). Ties are the one stored
   exception to rule 16. **Reading an opinion or a tie never creates, changes or removes a record**, so AC-NT-21 (save
   byte-identical after 1,000,000 reads) keeps holding.
4. **Strengths fade lazily.** A soft kind's or debt's current strength is computed when read from its stored strength
   and the seasons since it was set (Formula B). Nothing scans ties per season. A part whose current strength is 0 is
   removed the next time either person is touched (a rule 7 change, any S8b change naming them, and every S8b for the
   player's own records). No write ever stores a part at strength 0: a Δ ≤ 0 on a part the record does not hold
   changes nothing.

**Caps**

5. **Cap per person.** An ordinary person holds at most `cap_ordinary` (6) ties; a **notable** person at most
   `cap_notable` (16). Pinned ties count inside the cap. The player uses `cap_notable`. **Soft reserve (user decision
   2026-11-21):** whatever their pinned count, a person may hold up to `soft_reserve` (2 ordinary, 4 notable)
   soft-only records, so a person whose slots are all pinned can still gain a friend, a rival or a debt. A person's
   soft-only limit is `max(soft_reserve, cap − pinned records)`. It is checked **when a soft-only record is added**
   (rule 7); a later pinned tie, an in-place betrayal or repay (rule 9 step 2), a hardening, or an `outside_cap` record that
   gains another part (rule 7: it then counts) may leave the person past it without evicting anything. **Over the limit (round 4):** such a person adds a soft-only record only by
   evicting, weakest first, every candidate needed to stand one below the limit, each strictly weaker than the new
   part's entry strength (rule 7); if there are not enough such candidates the add is refused and nothing changes on
   either side. Apart from these exceptions a person's soft-only records never exceed their cap.
6. **Notable** is computed when a tie is added, from stored facts; notability itself is never stored. A person is
   notable if they are a fixed-cast member, a sect head or elder, a Nguyên Anh or higher cultivator, or on the
   player's **met list**: the `met_notable_max` (500) people the player met most recently (user decision 2026-11-21),
   kept on the player in the World DB, written when the player meets someone (a person already on it moves to the
   front). Notable people may also hold the two kinds an ordinary person cannot start: kết nghĩa and đạo lữ form only
   when at least one of the two is notable, or by an authored event. **Losing notability** (dropping off the met list,
   losing a sect rank, as Sects reports it) queues the person for the next S8b, which, if they are still not notable then, evicts their soft-only records
   down to the ordinary limit (rule 7). Pinned ties are kept.
7. **Eviction.** Only **soft-only records** (no pinned flag; they may hold a soft kind, a debt, or both) are ever
   evicted. **A record whose `favour_owed` flag is set counts as pinned for rules 5, 6 and 7** (round 7): it is never
   a candidate, never counts as soft-only, and so lowers the soft-only limit by one while the flag stands. A record's strength for eviction is the larger of its soft kind's and debt's current strengths; the
   weakest goes first, ties broken by the older last-set season, then the lower partner id. A soft kind or debt on a
   pinned record is never a candidate: dropping it frees no slot. A new **pinned** tie always forms (overflow) and
   evicts nothing. A new **soft-only record** forms only if **both** people can make room within their soft-only
   limit (rule 5), by a free slot or by a candidate strictly weaker than the new part's entry strength (rule 10); the
   evictions on both sides and the new record apply as one change, and if either side cannot make room nothing
   changes on either side. **A soft kind or debt added to a record that already exists never needs room** (the record
   already counts). **Mourner enmity (rule 13) is held outside the cap on the side of the person it is held toward**
   (the killer, or the target of a feud the dead held): there it neither evicts nor counts against that person's cap,
   now or at a later add. **On that side the record is also never an eviction candidate** (round 8): it is neither counted nor evictable there; the other person's side may evict it as soft-only. It is stored as the record's `outside_cap` marker, cleared when the record gains any other
   part (then it counts like any record). It is bounded by `mourner_max` per death.

**Forming and changing ties**

8. **No per-pair roll.** Ties change only through these sources, never through a scan of all pairs:
   - **Event Engine outcomes**: `tie_add`, `tie_strengthen`, `tie_weaken`, `tie_end` effects, inside the event budgets.
   - **Power Rankings world fights**: a close fight can form a rivalry; a crippling or killing blow forms enmity in the
     loser's side (and the loser's close ties on a kill, rule 13).
   - **Rescues and betrayals** reported by the tick or by events: a rescue forms or adds a debt (debtor = the
     rescued); a betrayal turns a pinned kết nghĩa, đạo lữ or sư đồ into enmity (rule 12).
   - **Sect life**: taking a disciple forms sư đồ; succession reads it (Sects).
   - **The player's bond verbs** through NPC Interaction & Dialogue: ask to become a disciple, take a disciple, propose
     kết nghĩa or đạo lữ, repay a debt, declare enmity, call for help. **Declaring enmity** writes enmity +30 in both
     directions (the insult default; an ordinary soft write, not a deed; cause `event`).
   - **World Generation**: authored kin, sư đồ, kết nghĩa and đạo lữ at the start, plus generated kin for ordinary
     people.
9. **One tick step.** Changes from a season's sources are queued and applied in the Living World Tick's reserved step
   **S8b**, after S8 (events), in this order:
   1. deaths and inheritance (rule 13);
   2. ends (betrayal removals, repaid debts, `tie_end`, faded parts of the people touched). A betrayal or a repaid
      debt that leaves a new part (enmity, `repay_friend`) writes it **in place on the same record in this step**, as
      one change that needs no room (rule 7), and a person left over their soft-only limit is over it until
      their next soft-only add (rule 5, over the limit);
   3. evictions for lost notability (rule 6), so later steps compare against the ordinary limit;
   4. strength changes on parts that already exist (Formula C);
   5. new parts and deeds, with eviction (rules 7, 10). A Δ > 0 on an absent part is a new part, made here;
   6. hardening by threshold (rule 11), tested on every direction touched by steps 1-5 **and on every record a
      verb wrote since the previous S8b** (round 7: a verb-written enmity at the threshold hardens at this step);
   7. the hook pass (rule 15a).

   Within a step, changes apply in event-log order, then by the lower person id of the pair; deaths in step 1 apply in
   ascending dead-person id (round 11). Queued changes are
   validated against the record as it stands when they apply (the player's verbs may have changed it); a change naming a person in the season's dead set is dropped (step 1's inheritance is the only write for them). Only people
   named in a queued change are touched, plus the player's sweep (rule 4) and the hook pass. The player's bond verbs
   change the record at once, outside the tick; **hook rows are written only by the hook pass** (rule 15a), so a verb's
   new bond pays from that season's S8b, and a master or đạo lữ who died or parted mid-season is read as absent
   (rule 15a) until then.
10. **Writing a strength.** Every write follows one of four cases:
    - **Same kind:** `str = str_now + Δ` (Formula C), whether the source is an event or a deed (a crippling enmity 40
      then a betrayal 70 reaches 100 and hardens at step 6).
    - **Another soft kind:** it replaces the current soft kind when its entry strength (its Δ) is greater than the
      current kind's `str_now`, and is dropped otherwise (one soft kind per record).
    - **Deeds override:** enmity from a betrayal (rule 12), a crippling or killing world fight (rule 8) or a slight
      (rule 15a) replaces a different soft kind whatever its strength.
    - **Inherited values set a floor, never add:** mourner enmity and an heir's debt (rule 13) set
      `str = max(str_now, inherited value)`, so a mourner who already held enmity 80 keeps 80. The floor applies to
      enmity already held toward the killer; against a friend or rival kind the mourner's enmity is another soft kind
      and is dropped if weaker (rule 13).

    A new part enters at its Δ, and that is the value rule 7 compares. Comparisons read the record-level strength
    (rule 1: the larger direction), a Δ on enmity applies to the holder's own direction, and a replacing kind wipes both. **Enmity never shares a record with a blood
    feud the same way:** enmity added from a person toward someone they already hold a feud against is dropped (the
    feud already carries it), and pinning a feud removes any soft enmity the same way (rules 11, 13).

**Hardening, breaking and inheritance**

11. **Enmity hardens into a blood feud** when its current strength reaches `feud_threshold` after the season's
    strength changes (step 6). The holder's direction of the soft enmity is removed (the other direction keeps its own strength and
    set season) and a pinned blood feud is set on the same record (no record is added; `inherited` false; the cause
    becomes the deed that pushed it over). Hardening tests each direction on its own. A kill of a close tie by someone the
    holder already hated is rule 13's first heirs, not this rule. A verb-written enmity reaching the threshold hardens
    at the next S8b's step 6 (rule 9).
12. **Betrayal breaks a pinned bond.** An event that marks a betrayal removes every pinned kết nghĩa, đạo lữ and sư đồ the pair holds,
    clears `favour_owed` on the pair, and sets soft enmity in the betrayed person toward the betrayer **in place on
    the same record, in the same step 2 change** (rule 9; it needs no room, so it cannot be dropped for lack of one;
    rule 10: added to an enmity already held, replacing any other soft kind). Kin is never removed by
    betrayal; it gains the enmity alongside.
13. **Death passes ties on.** When a person dies, before their records are removed. The dead's **close ties** are their
    kin, master, disciples, kết nghĩa and đạo lữ.
    - **Struck:** the killer and **everyone whose death is queued in this S8b** (the whole season's dead set, built
      before any list below; round 5) are struck from every list below, as heirs, avengers, mourners **and as feud
      targets**; the next in line takes the slot. A person on two lists **toward the same target** takes one slot.
      **Slots, struck sets and de-duplication are per target** (round 8): one death can pass a feud toward the killer K
      and a feud the dead held toward T; each target has its own `inherit_feud_max` and `mourner_max` slots, and a
      person may take one part toward each target. A feud toward a target who
      dies this season passes to no one (rule 14 ends it). So a massacre leaves its feud to the living next in line.
    - **Who counts as known (round 3).** A kill by the Living World Tick or a Power Rankings world fight is known
      unless an event flags the outcome `secret`; a kill by an event is known unless that event says otherwise.
      Living World Tick owns the flag (back-link). A killer revealed later is a `tie_add` from the heirs alive then.
    - **Heirs for any death.** The heirs of feuds and debts the dead held (and of a known kill, below) are the first
      `inherit_feud_max` of children (eldest first), then disciples (eldest first), the struck rule applying. **Order (round 11):** "eldest" is the earlier World DB birth season, ties by the lower person id; children are the people whose World DB parent is the dead; no formed-season field is stored;
      avengers join the list only for a known kill. The mourners of a held feud are the first `mourner_max` of the
      remaining close ties, in the order below.
    - **A known kill.** If the death was a kill and the killer is **known** (above; a killing no one knows of leaves
      no feud):
      - **Avengers** are the close ties who held a blood feud or enmity toward the killer before the death (a
        pinned feud, or enmity with current strength > 0; read before any S8b change this season): feud holders first,
        then enmity strongest first. An avenger's feud is set as their own (`inherited` false, cause `kill`), including
        one who held an inherited feud, so a new kill renews a vendetta; the flag never goes from false to true.
      - **Heirs** are the first `inherit_feud_max` of: avengers, then children (eldest first), then disciples
        (eldest first). Each heir gains a pinned blood feud toward the killer. It is marked *inherited*,
        except for an avenger, whose feud is their own. The heir's enmity toward the killer is removed (the killer's own
        direction stays), and a friend or rival kind on the record is replaced by the feud.
      - **Mourners** are at most `mourner_max` of the remaining close ties, closest first: đạo lữ, then the master,
        then other kin, then kết nghĩa, then other disciples (eldest first). Each takes soft enmity toward the killer: the
        floor `inherit_enmity` applies to enmity already held toward the killer; against a friend or rival kind the
        enmity is another soft kind (rule 10) and is dropped if weaker. A mourner who takes nothing, or has no room
        (rule 7), still uses their slot. Anyone past `mourner_max` takes nothing. Every ordered list in this rule
        breaks ties by the lower person id.
    - **Feuds the dead held.** Each blood feud the dead held passes to the heirs of the death as a pinned blood feud
      toward the same target, marked *inherited*, removing the heir's enmity toward that target (that direction only) and replacing a friend or rival kind on the
      record. A target who is also an heir or mourner is struck from the lists. Here heirs
      are children then disciples, with no avengers. It passes
      to mourners as soft enmity at the floor `inherit_enmity`. An **inherited** feud passes on at its holder's death
      only as soft enmity, never as a pinned feud, so a vendetta fades over generations unless a new kill renews it.
      **Who takes an inherited feud (round 5):** the same heirs and mourners as above (children, then disciples, then the remaining
      close ties), both as soft enmity at the floor `inherit_enmity`, in the same slot counts (`inherit_feud_max` heirs,
      then `mourner_max` mourners). That soft enmity is held outside the cap on the target's side, like mourner enmity (rule
      7), so O_kill's 8 per target per death still holds. Its cause carries the **origin** (the first dead, the killer, season,
      `location_id`) and a `generation` count, so the text still names the original killing. **Generation (round 8):**
      a part created directly by a known kill (a feud, an avenger's feud, mourner enmity) has `generation` 0; each
      hand-down at a holder's death sets the new part's `generation` to the holder's + 1.
    - **Debts.** A debt owed to the dead passes to each heir (children then disciples, no avengers; the debtor is struck from that debt's heirs, the next in line taking the slot, and a debt whose debtor is in the season's dead set is cancelled) at
      `inherit_debt` of its strength, after first
      netting against any debt the heir owes the other way (rule 1a); the floor (rule 10) applies only to a debt the
      same way. Below strength 1 it is not formed. A debt the dead owed is cancelled. `favour_owed` flags on the dead's
      records go with them.
    - **Loans are not ties** (NPC Interaction & Dialogue OQ 2): a dead lender's loan is written off as Dialogue rule
      already says, and a dead borrower's loan is cancelled; neither passes to heirs.
    - **Cause.** Every part this rule creates has cause `inherited` (or `kill`, for an avenger), carrying the death's
      payload and linked to its event-log entry (rule 1b).
    - **Removal and limits.** All other ties of the dead are removed. The event log keeps the history. Inheritance
      obeys each heir's and mourner's cap (rule 7). A dead person passes ties on once. Because the season's dead are
      struck first, nothing inherited this season is ever held by someone who dies this season.
14. **Ending.** A tie ends by any of:
    - **death** (rule 13);
    - **fading to 0** (rule 4);
    - **eviction** (rule 7);
    - **betrayal** (rule 12);
    - **repaying a debt**: an event, or the repay verb, clears it (the verb asks the creditor for a B = 0 Errand-tier deed, the same
      machinery as the favour call-in; completing it clears the debt, and no stone sink is added), and sets a friend
      tie at the floor `repay_friend` when
      the pair holds no soft kind or holds friend, in place on the same record in the same step 2 change (rule 9;
      it needs no room). Clearing a favour (rule 15a) and repaying a loan (Dialogue rule
      15, not a tie) never set `repay_friend`;
    - **an Event Engine `tie_end`** (reason `parted` or as the event gives).

    Kin ends only by death. A **blood feud or enmity ends when its target dies**; the reason is in the rule 1b
    table. It is `avenged` (báo thù) when the holder made the kill, or the killer held a feud or enmity toward that
    target (an avenger or heir of the same feud); `slain` when anyone else made a known kill (a third party, the
    player, a stranger); `target_died` when there is no known killer, and its text is heaven's judgement
    (thiên phạt) only for a failed breakthrough or tribulation. Several holders of one death each get their own
    reason; the news prints one line per death.
14a. **Vendettas are damped, not banned.** Revenge is a Living World Tick choice weighted by ties, inside the tick's
    budget of violent deaths a season (Living World Tick Open Question 4), so blood feuds cannot drive the death rate
    past Realms' headcounts. Revenge never raises a feud's strength by itself; only new deeds do.

**What ties change**

15. Ties feed other systems; this system owns the records, not their behaviour:
    - **Opinion** through F3 `tie` (rule 3), and through it everything that reads opinion.
    - **Event conditions**: events may test "has tie of kind K with b", "has blood feud", "owes a debt", and the
      strength.
    - **Living World Tick actions**: who helps whom and who seeks revenge are tick choices weighted by ties.
    - **Sect succession** prefers the head's disciples (Sects).
    - **Quests and conversation** read the player's ties for offers, refusals and bond verbs.
    - **Narration** (authored text, or the LLM Game Master when enabled) reads tie kinds, names and causes (rule 1b).
15a. **Each pinned kind has one build hook** (user decision 2026-11-20). This GDD names the hook and its size
    (Formulas); the owning system applies it. Hooks that are stat rows are plain Modifier System rows with source
    `tie` (no condition on the row: a modifier has none, `modifiers.md` rule 1).

    **The hook pass.** The rows are added and removed by the **hook pass**, the last part of S8b (user decision
    2026-11-21). It is one pass over the **hook index**: every record holding sư đồ or đạo lữ, a list the World DB
    keeps (about 2,000 records), for NPCs and the player alike. The pass reads the season's deaths, breakthroughs (S2)
    and travel, so:
    - the master row is present while the master lives and is of a higher realm;
    - the đạo lữ row is present while both have the same `location_id` at the end of the season.

    A dead master or a separated đạo lữ loses the row the same season. **The pass reconciles by source (round 5):**
    after the index walk it removes every `tie`-source row on any sheet that no surviving record qualifies (a record
    removed at step 1 or 2 by a death, a betrayal, a `tie_end` or a parting leaves no index entry, so the people
    named in those changes are visited too) and adds the missing ones. A đạo lữ row is per surviving record, so a
    new partner never stacks on an old row.

    | Kind | Hook | Applies to | Applied by |
    |---|---|---|---|
    | Sư đồ, as disciple | `cultivation_speed_pct` +`master_cult_pct` while the master lives and is of a higher realm; the master's teaching verb is always accepted for the master's own techniques (the score's `b_v` is waived) | player and NPCs (teaching: player) | Character Stats; NPC Interaction & Dialogue |
    | Sư đồ, as master | Disciples run errands (gather, deliver, scout) | player | Quests, Event Engine |
    | Kết nghĩa | In a fight event, the player may call for help | player | Event Engine, Combat, NPC Interaction & Dialogue |
    | Đạo lữ | Dual cultivation (song tu, "paired cultivation"): `cultivation_speed_pct` +`daolu_cult_pct` for both while in the same place; "has a Dao companion" is a group condition build Effects may test | player and NPCs | Character Stats, Effects |
    | Companion | Fights beside the player as one Combat companion source at their power share, and travels with them | player | Combat |
    | Kin, blood feud | No build hook; kin and feuds act through opinion, events, the tick and rule 15b | — | — |

    **Errands (sư đồ, as master):**
    - **`errands_max` counts errands in progress at once** (sent this season or earlier and not yet resolved), set by
      the **player's** realm whatever the disciple count, with at most one per disciple. Each is a Quests Errand-tier quest that a disciple completes for the player, resolved
      by the Event Engine.
    - Sending costs `errand_cost` in linh thạch, set by the **higher of the player's and the disciple's realm**. It
      is paid when sent and **burned** (CD-GDD-ALIGN, Pillar 4). The stone share of a resolved errand's reward is
      refunded out of that burn (it is the payer), so the net burn is the cost less the stone share. **The items are
      minted** as raw commons at their Item Database price when the errand resolves; no market stock and no NPC purse
      is touched. Conservation: goods minted at price equal the net stones burned (a 1:1 stone-to-goods sink, with no
      leakage). The stone share is `floor(0.2 × B_errand)` and the items take at most `B_errand` less that share.
    - The reward budget is `B_errand = floor(errand_margin × errand_cost)` (1.0 × cost; Formula F, round 5: no
      `min` with `B_quests`, which always exceeds the cost at the Errand tier). The reward is money and items from
      that budget only, the items being raw market commons: no outcome that Quests does not charge to B (relationship, access, `tu_vi`, insight, lasting
      gain) and no world outcome of Quests rule 17 (`wealth`, `standing`).
    - Errand items are a goods faucet, owed to the world-economy plan.
    - Errands are worth sending for the travel they save: at Item Database price an errand returns at most its cost,
      about 0.68 of it if sold, and raw commons are bought at the Market's bulk price (`bulk` 1.10), so stones and
      goods the player would otherwise buy are worth up to about 1.08 × the cost, a small discount on goods fetched
      without travelling, bounded by `errands_max` a season (Formula F; `errand_margin` is tuned by the Open Question
      3 balance run).
    - A disciple on an errand cannot be sent again until it resolves. An errand that fails or lapses pays nothing
      (its whole cost stays burned), like a disciple's death.
    - If a disciple dies on an errand, its cost is not refunded and its reward is lost.

    **Help calls (kết nghĩa):**
    - Each sworn sibling within one travel step rolls `p_help` (Formula F). Of those who answer, the one with the
      highest `p_help` joins (ties: the lower id), up to `help_max`, each as one Combat companion source (Combat rule
      19) at their power share.
    - A sibling who joined sets **`favour_owed`** (caller → sibling). While it is set, that sibling's `p_help` is 0.
    - **The favour is repaid by a deed** (user decision 2026-11-21): the Event Engine schedules a "calling in the
      favour" event from the sibling to the caller, **one per favour, outside the Event Engine's draw budgets**. It is
      **presented within `favour_call_seasons` of the join, or in the first season after that when the player can be
      reached** (not in seclusion, imprisoned or otherwise unreachable). Until it is presented the flag stays and
      `p_help` stays 0; only the sibling's death (or a betrayal, rule 12) clears it without a deed, so neither seclusion
      nor a parting (`parted` or `tie_end` ends the kết nghĩa, not the flag) is a way to dodge a favour (round 4,
      round 6). There is no second deadline: the player accepts or refuses when it is presented, and an accepted
      task runs on its own Quests deadline. Errand-tier names the size of the task (a fight to join, a delivery, a
      search) only: **the call-in pays no reward (B = 0)**, no items and no `tu_vi`; clearing the flag is its
      payout, so it is repaying, not earning.
    - **A call-in never outlives its favour** (round 8): the sibling's death, or a betrayal on the pair (rule 12), ends
      any scheduled, presented or accepted call-in as Withdrawn with no slight. A slight never writes to a removed
      record. A record holding only the flag, after a refusal or lapse, writes its slight's enmity in place and stays;
      it is removed only when the favour is answered or paid, or the sibling dies (S8b step 4 for a friend tie's fall,
      step 5 for the enmity remainder).
    - **Answered** (round 7) is read from the accepted task's Quests end state: **Completed**, a **lost `defeat`
      stage**, or goods lost to someone else, all answer and clear the flag. **Abandoned**, **Lapsed**, **Dropped**, a
      required item the player disposed of, or a target the player's side killed do not: each is a slight (next
      bullet). Only a call-in is judged this way; the repay verb's deed (rule 14) that ends refused, abandoned or
      with its creditor dead leaves the debt in place and writes no slight.
    - Refusing a presented call-in, or an accepted task that ends unanswered, clears the flag and counts as a **slight**:
      the sibling's friend tie toward the caller falls by `refuse_delta`, or, with no friend tie, the sibling gains
      or adds enmity `refuse_delta` as a deed (rule 10; cause `slight`). A friend tie lower than `refuse_delta` is
      removed and the remainder is added as enmity. Kết nghĩa stays. **When the flag clears (round 11):** an answer or
      a `favour_cost` payment clears it at once (so `p_help` is back that moment); a refusal or an unanswered end
      clears it after the slight's last write (step 4 friend fall, step 5 enmity remainder when there is one). A friend tie that
      the slight takes to 0 ends as `faded`; the enmity remainder is written in place, so that record survives. A
      record left with no pinned kind, no part and no flag after that last write is removed then (`partner_died` or
      `faded` as the table gives).
    - Paying `favour_cost` linh thạch through NPC Interaction & Dialogue's repay verb clears the flag early. This is
      optional, and the stones are burned. It also cancels a call-in that is scheduled, presented or accepted (the
      task ends Withdrawn, no slight).
15b. **Feuds and debts toward the player act** (game-designer and narrative review 2026-11-21):
    - **Revenge.** The Living World Tick's revenge choice may target the player for any NPC holding a blood feud or
      enmity toward them, inside the violent-death budget (rule 14a).
    - **Avenger events.** The Event Engine draws at most `avenger_max` events a season from an avenger pool: a feud
      holder seeks the player out (an ambush, a challenge, a bounty).
    - **Gratitude events.** It draws at most `gratitude_max` events a season from a gratitude pool: an NPC who owes
      the player a debt brings aid, a gift or a warning.

    The Event Engine owns the pools' contents. This rule gives the triggers and the caps. **Pool draws are
    ordinary draws** (round 7): they count against the Event Engine's `player_events_per_season_max` and rule 14's
    per-chain budget; only the favour call-in (above) sits outside them. Event Engine owes the matching line.
15c. **The player is told.** These are rules; the screens are the UX spec's (UI Requirements):
    - **Before a help call:** each sibling's answer chance, **who would join** (only the highest `p_help` answerer up
      to `help_max` joins, so a chance is not a promise to join) and the chance that at least one answers; that a
      sibling who joins will call the favour in within `favour_call_seasons` seasons; and that refusing the call-in
      costs `refuse_delta` (a friend tie falls, or enmity forms). A favour already owed means that sibling cannot
      answer, and is shown so.
    - **While a favour is owed:** its state, on the relationships page, the person card and the call-in itself, one
      of three (round 5): **awaiting call-in** (presented by the latest season `join + favour_call_seasons`, or the
      first season the player is reachable); **presented** (a forced accept-or-refuse choice with no deadline of its
      own, showing the task type, size and the deadline it would run on if accepted); **accepted** (the task's own
      Quests deadline running). Every state shows the refuse cost **as the branch that applies** (the friend tie's band
      before and after, or "no friend tie: enmity forms" with its band), that abandoning the accepted task is a slight,
      and the optional `favour_cost`. The greyed sibling in a help call shows the same state, its season and the repay
      option.
    - **Before a bond verb evicts:** the player's tie it would evict is named. A verb refused for room shows the
      reason in full: the player's soft-only slots are full and the candidate is not weaker, or **their side cannot
      make room** (rule 7). The relationships page shows soft-only slots used out of the limit.
    - **On an eviction in the tick:** a news line names the lost tie.
    - **On a feud or enmity involving the player:** a notice when the player gains an inherited feud or mourner
      enmity, or an NPC gains a feud toward the player. It names the dead and the killer from the cause link (rule
      1b).
16. **The player.** The player's ties use the same record and rules. The stored attitude to the player (Quests,
    Formulas E) is separate and unchanged; a tie adds to the NPC's opinion of the player through F3 but does not write
    to that attitude.

### States and Transitions

The state of a pair is its record's pinned kinds, soft kind, debt and `favour_owed` flag; "none" means no record.

| From | To | Trigger | Rule |
|---|---|---|---|
| none | friend, rival, enmity | Event outcome, world fight | 8 |
| none or any | + debt (ân tình) | A rescue (debtor = the rescued); a debt the other way is netted | 1a, 8 |
| none | kin, sư đồ, kết nghĩa, đạo lữ | World Gen, birth, taking a disciple, bond verb or event (rule 6 gate) | 6, 8 |
| friend | kết nghĩa or đạo lữ | Bond verb or event; friend soft kind stays until it fades | 6, 8 |
| debt | (debt cleared) + friend | Debt repaid: friend at the floor `repay_friend` when no other soft kind | 14 |
| friend, rival | enmity | Event outcome (insult, theft); replaces the soft kind when stronger; betrayal and crippling or killing fights always replace | 8, 10 |
| rival | friend | An event outcome adds friend stronger than the rivalry | 10 |
| kết nghĩa | + favour owed | A sworn sibling joins the caller's fight | 15a |
| favour owed | awaiting call-in, presented, accepted | The call-in is due by `join + favour_call_seasons` or the first reachable season; the player accepts it (the task's own deadline runs) | 15a |
| favour owed | (flag cleared) | The caller answers the favour's call-in event (accepted task Completed or a lost `defeat` stage; abandoning is a slight), or pays `favour_cost`; a `parted` or `tie_end` of the kết nghĩa leaves the flag standing | 15a |
| favour owed | (flag cleared) + slight | The caller refuses the call-in, or the accepted task lapses or is dropped: friend −`refuse_delta`, or enmity `refuse_delta` | 15a |
| enmity | blood feud | Strength ≥ `feud_threshold` after the season's strength changes | 11 |
| any or none | blood feud | A known kill of a close tie: heirs, avengers first | 13 |
| blood feud, enmity | none | The target dies (avenged if the holder's side killed) | 14 |
| none | companion | Player's recruit verb accepted | 8 |
| companion | none | Dismissed, or the NPC leaves (attitude hostile, or an event) | 2 |
| kết nghĩa, đạo lữ, sư đồ | enmity | Betrayal (favour owed cleared) | 12 |
| kin | kin + enmity | Betrayal | 12 |
| any soft or debt | none (that part) | Fades to 0, evicted, replaced by a stronger soft kind, `tie_end` | 4, 7, 10, 14 |
| any | removed | Death of either person (after inheritance) | 13 |
| blood feud held by the dead | blood feud held by heirs | Death | 13 |

### Interactions with Other Systems

| System | Direction | What passes | Owner of the interface |
|---|---|---|---|
| **NPC Traits** (#42) | out | Rule 3's tie value into F3 `tie(a, b)`; rule 16 amended. A Grudge gained trait and an enmity tie toward the same person do not stack: F3 takes the more negative of `target` and the enmity value (provisional, Open Question 2) | This GDD (record); NPC Traits (formula) |
| **Living World Tick** (#28) | in / out | In: the S8b slot, deaths, breakthroughs (S2), travel, rescues and betrayals of the season. Out: tie lookups for help and revenge choice weights, including revenge on the player (rule 15b) | Tick owns the step order; this GDD owns S8b's contents and its seven sub-steps |
| **Event Engine** (#23) | in / out | In: `tie_add`, `tie_strengthen`, `tie_weaken`, `tie_end` effects, betrayal and rescue flags, call-in answers. Out: tie conditions; the favour call-in event (rule 15a); the avenger and gratitude pools (rule 15b) | Event Engine owns effect syntax, budgets and the pools' contents |
| **NPC Interaction & Dialogue** (#30) | in / out | In: the player's bond verbs, the repay verb, the met list (meeting writes it). Out: the player's ties, the gate for each verb, the tie a verb would evict | Dialogue owns the verbs and their attitude gates |
| **Power Rankings** (#44) | in | World-fight results: closeness, injury, kill | Power Rankings |
| **Sects & Missions** (#26) | in / out | In: taking disciples, ranks for notability and rank loss. Out: sư đồ for succession | Sects owns succession |
| **Quests** (#31) | out | The player's ties for offers; disciples' errands as Errand-tier quests with a capped, money-and-items-only reward; attitude to the player stays Quests' | Quests |
| **World Generation & History** (#27) | in | Authored ties of the fixed cast; generated kin | World Gen |
| **Realms & Bottlenecks** (#8) | in | Deaths by lifespan and failed breakthroughs (via the tick) | Realms |
| **World DB** (#3), **Save/Load** (#5) | in / out | The tie records indexed by both ids; the hook index; the player's met list; event-log entries the causes link to | This GDD (shape); Save/Load (format) |
| **LLM Game Master** (#29, parked) | out | Tie kinds, names and causes for narration; the game plays without it | — |

## Formulas

Scale notes for every number below: 4 seasons a year; lifespans 120 / 200 / 500 / 1,000 years by realm
(`cultivation_realms.json`); opinion runs −100 to 100 (NPC Traits F3); `cultivation_speed_pct` sources today run
+3 a generating pair (0–15 a root), +11 for a Chaos 55 variant, +0.5 to +3.6 a modifier roll (Modifier System).
Values marked *(guess)* are first numbers for the balance pass.

### A. Tie value in opinion

The tie_value formula is defined as:

`tie(a, b) = max(0, max_{k ∈ P} pin(k, a → b)) + feud(a → b) + soft(k_s, a → b) · str_now / 100 + debt(a → b) · d_now / 100`

The positive pinned kinds do not add up: a father who is also the master counts +30 once. A blood feud is the one
negative pinned kind and adds on top (a kinslayer's brother: 30 − 60 = −30). Divisions are exact (no rounding); F3
rounds the whole opinion once. The maximum over an empty set of pinned kinds is 0. A part whose current strength is
0 reads as absent everywhere (opinion, event conditions, eviction strength), swept or not (Formula B).

It replaces the `tie` term of NPC Traits F3; the rest of F3 is unchanged (the sect head +15 stays in F3, computed
from the sect, not stored).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P, k_s | set; enum | the record's pinned flags (blood feud excluded); its soft kind or none | calculated (the record) | Rule 1 |
| pin | int | kin +30; sư đồ +30 both ways; kết nghĩa +40; đạo lữ +50; companion +20 | data file (kin, sư đồ, đạo lữ: NPC Traits F3 values, unchanged) | Fixed positive pinned weight |
| feud | int | −60 for a holder of a blood feud toward b; 0 otherwise (a target who does not hold it back feels nothing from it) | data file *(guess)* | The negative pinned weight |
| soft | int | friend +25; rival −10; enmity −50 holder → target, 0 the other way unless held both ways | data file *(guess)* | Soft weight at full strength |
| debt | int | ân tình +30 debtor → creditor, +10 creditor → debtor; 0 with no debt | data file *(guess)* | Debt weight at full strength (rule 1a). A favour owed (rule 15a) has no weight |
| str_now, d_now | float | 0–100 | Formula B | Current soft and debt strengths |

**Output Range:** −70 to +105 before F3's clamp. The low end is a blood feud −60 plus a full rivalry −10: a feud and
a soft enmity never share a record the same way (rules 10, 11, 13; opposite directions can, and each direction reads
only its own), and a debt only adds. The high end is đạo lữ +50, a full friend
+25 and a full debt +30 as debtor. A record with no pinned kind and a full enmity gives −50. F3's clamp to −100…100
applies to the whole opinion.
**Example:** sworn siblings who are friends at strength 60: 40 + 25 × 0.6 = **55**. A rescued friend (friend 60, owes
a debt at 60): 15 + 18 = **33**. A brother who betrayed his brother, held at enmity 70 (kin stays, rule 12):
betrayed → betrayer 30 − 50 × 0.7 = **−5**; betrayer → betrayed **30**.

The enmity weight −50 equals the Grudge trait's `target` −50 (NPC Traits F3), and the two do not stack: F3 takes
`min(target, feud + soft(enmity) · str_now / 100)` for the same person, one term, so a hardened feud (−60) does not
add to a Grudge (−50) to reach −110 (provisional, Open Question 2; owed to NPC Traits F3 as a back-link).

### B. Lazy fade

The soft_strength formula is defined as (for a soft kind and for a debt alike):

`s_now = max(0, s − rate(k) · max(0, season_now − set_season))` ; `str_now = s_now / 100`

Strengths are stored in **hundredths** (`s`, 0–10,000) and fade rates are whole hundredths a season, so fading is
exact: no write ever loses part of a fade to rounding, however often a tie is touched. A read never writes (rule 3).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| s | int | 1–10,000 | the record | Strength in hundredths when last set |
| rate | int | friend 100; rival 100; enmity 50; debt 25 (hundredths a season; > 0 for every kind) | data file *(guess)* | Friend from 100 fades in 25 years, enmity in 50, a debt in 100: a full debt outlasts most of a Luyện Khí life (120 years) but not all of it. At 0 a part never vacates its slot, so 0 is rejected when the data loads |
| season_now, set_season | int | ≥ 0 | clock; the record | `season_now − set_season` is clamped at 0 |
| shown | int | 1–100 | calculated | `ceil(s_now / 100)`, the strength shown in the tooltip and used for bands. A part whose `s_now` is 0 (faded, not yet swept) **reads as absent on every read** (opinion, event conditions, eviction strength, tooltip), so a shown 0 never occurs |

**Output Range:** `str_now` 0–100. At 0 the part is removed the next time either person is touched (rule 4).
**Example:** a friend tie set to 70 twelve years (48 seasons) ago: 70 − 48 = **22**. Enmity 30, insulted again one
season later (+30): 29.5 + 30 = **59.5**, shown 60.

### C. Strength changes

The strength_change formula is defined as:

`s = clamp(s_now + 100 · Δ, 0, 10,000)` ; `set_season = season_now` (same kind, rule 10)

A **new** part enters at `s = 100 · Δ` (Δ > 0; a Δ ≤ 0 on an absent part changes nothing, rule 4), and that is the
value rule 7 and rule 10 compare. An **inherited** value sets `s = max(s_now, 100 · value)` and `set_season = season_now` (rule 10); a new part likewise sets `set_season = season_now`. A result of 0
removes the part at once.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| Δ | int | −100 – 100 | the source (event effect, or the defaults below) | Positive strengthens; negative weakens |
| Δ defaults | int | shared event friend +20; close world fight (rating gap ≤ `rival_gap`) rival +30; rescue debt +60; crippling world fight enmity +40; insult or theft enmity +30; betrayal enmity +70; repaid debt friend floor `repay_friend` 30; refused favour `refuse_delta` 30 (friend −30, or enmity +30) | data file *(guess)* | Used when a source gives no Δ of its own |
| rival_gap | int | 100 rating points | data file *(guess)* | "Close" in Power Rankings rating terms |

**Output Range:** 0–100.
**Example:** a rescue (Δ 60) of a person who already owed a debt at 30: **90**. A crippling (enmity 40) then a
betrayal ten seasons later: 40 − 5 + 70 = 105, clamped to **100**, hardens at step 6.

### D. Hardening and inheritance

The feud_rules are defined as:

`enmity → blood feud` when `str_now(enmity) ≥ feud_threshold` at S8b step 6 (rule 11)
`heirs = first inherit_feud_max of [avengers by enmity, strongest first] ++ [children, eldest first] ++ [disciples, eldest first]` (a known kill; for feuds the dead held, avengers are left out)
`s(mourner enmity) = max(s_now, 100 · inherit_enmity)` ; `s(heir debt) = floor(s_now(debt owed to the dead) · inherit_debt)`, not formed below 100

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| feud_threshold | int | 90 | data file *(guess)* | At enmity's fade of 0.5 a season: a crippling (+40) then a betrayal (+70) harden within 40 seasons of each other, a betrayal plus an insult (+30) within 20; three insults harden only in the same season (one season apart: 30, 59.5, 89) |
| inherit_feud_max | int | 3 | data file *(guess)* | Heirs who take a pinned blood feud, avengers included; bounds the cascade (rule 13) |
| inherit_enmity | int | 50 | data file *(guess)* | Mourners' soft enmity floor |
| inherit_debt | float | 0.5 | data file *(guess)* | Share of a debt of gratitude the heirs are owed |
| mourner_max | int | 5 | data file *(guess)* | Mourners who take soft enmity per death; bounds the cascade and the killer's overflow (rule 7) |

**Output Range:** at most `inherit_feud_max` pinned feuds per death per target; mourners' enmity 50 fades to 0 in 25
years (Formula B). `inherit_feud_max = 0` turns all heirs into mourners.
**Example:** K kills H, a sect head with 2 children and 30 disciples, in public; no one held enmity toward K. C1, C2
and D1 take a pinned inherited blood feud on K. Up to 5 mourners take enmity 50: the sibling S, then D2–D5. D6–D30
take nothing. K gains 8 records (3 feuds, 5 enmities); the feuds overflow on K's side and the enmities are held
outside its cap, so nothing is evicted (rule 7). Had D6 held enmity 10 toward K before the kill, D6 is an avenger:
the heirs are D6 (own feud, not inherited), C1 and C2, and the mourners S and D1–D4.

### E. Caps and the save bound

The tie_bound formula is defined as:

`records ≤ Σ_p cap_p / 2 + P + M_out` (P: pinned records; soft-only records per person ≤ max(cap_p, soft_reserve) = cap_p, because the data load rejects a `soft_reserve` above its cap, rule 5)

`M_out` is mourner enmity held outside a killer's cap (rule 7). The estimate below splits the sum into a capped term
and the overflow above it.

`estimate = (N_ord · cap_ordinary + N_not · cap_notable) / 2 + O_sd + O_kill + O_other + O_res`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cap_ordinary | int | 6 (safe 2–6, never below `soft_reserve`; above 6 re-derive the target) | data file | Ties per ordinary person (user decision 2026-11-20) |
| cap_notable | int | 16 (safe ≥ cap_ordinary) | data file | Ties per notable person and the player (user decision 2026-11-20) |
| soft_reserve | int | 2 ordinary, 4 notable (safe 1 – its class's cap; the data load rejects a value above the cap so the bound's premise holds; 0 brings back soft-tie starvation) | data file *(guess)* | Soft-only records always allowed (rule 5; user decision 2026-11-21) |
| met_notable_max | int | 500 (safe 100–650: N_not = 252 + `met_notable_max`, each 100 adds about 500 records, and 1,000 gives 24,660, over the 23,000 target; break-even about 668) | data file *(guess)* | The player's met list (rule 6; user decision 2026-11-21) |
| N_ord, N_not | int | 4,248 and at most 752 | calculated | Notables: 72 fixed cast, about 150 sect heads and elders (30 sects), about 30 Nguyên Anh and Hóa Thần, and at most `met_notable_max` 500 on the met list. The met list is a hard limit; the other three are World Generation and Realms numbers |
| O_sd | int | ≈ 1,500 *(estimate)*; ≤ N | calculated | Sư đồ records past a master's cap. One living master per disciple caps sư đồ records at N; the estimate is World Generation's `master_share` 0.3 × 5,000 with all of them counted as overflow |
| O_kill | int | ≤ `inherit_feud_max` + `mourner_max` = 8 per known kill | calculated | Pinned feuds and mourner enmity on a killer's or feud target's side (rules 7, 13). Per known death: 8 × (1 + the feuds the dead held), since each held feud passes to up to `inherit_feud_max` heirs and `mourner_max` mourners again (rule 13). The 100-kill design case counts player kills with no held feuds: 800. Mourner enmity fades in 100 seasons and is swept when its holder or the killer is touched (rule 4; the player every season). NPC kills add 8 each while those records last; their number is the Living World Tick's violent-death budget (its Open Question 4), **pending** |
| O_other | int | ≤ 500 *(estimate)* | calculated | Kin past a cap (large families) and kết nghĩa (notables and authored events only) |
| O_res | int | ≈ 600 *(estimate)*; ≤ `soft_reserve` per person whose pinned ties fill the cap | calculated | Soft-only records the reserve allows above the cap: about 300 overflowing masters × 2 |

**Output Range:** (4,248 × 6 + 752 × 16) / 2 = 18,760; 18,760 + 1,500 + 800 + 500 + 600 = **22,160** records expected.
Each record is about 80 bytes (two ids, flags, per-direction enmity and feud fields, soft kind and debt with
strengths and set seasons, `favour_owed`, three causes with their payloads and event-log links) before the save
format, so about 1.8 MB raw. The design target is **≤ 23,000 records** at 5,000 cultivators with 100
known player kills (AC-NR-28). The target is **provisional**: NPC kills' share of O_kill is restated once Living World
Tick Open Question 4 sets the violent-death budget.

**Per-source bounds.** A person's soft-only records never exceed their cap (rule 5 checks the soft-only limit when one is
added), so `records ≤ Σ_p cap_p / 2 + P + M_out`, where P is the number of pinned records. Each source is bounded
by its own rule: the met list caps N_not, one master per disciple caps sư đồ at N (5,000 at the extreme; the 1,500 term
is the expectation), and the per-death limits cap feuds and mourner enmity. The total is a measured target, not a
mathematical guarantee: the NPC-kill share and the kin and kết nghĩa overflow are tracked outside this document
(Living World Tick Open Question 4). Halving `cap_ordinary` to 3 lowers the capped term to 12,388 (plus the same O_sd, O_kill, O_other and O_res: about 15,788 in all).

### F. Hooks

The tie_hooks are defined as:

`cultivation_speed_pct += master_cult_pct` (disciple, master alive and of a higher realm, at the hook pass)
`cultivation_speed_pct += daolu_cult_pct` (each đạo lữ, while in the same place at the hook pass)
`p_help = 0` if `favour_owed(caller → sibling)`, else `clamp((op(sibling → caller) − help_min) / (100 − help_min), 0, 1)`
`favour_cost = ceil(stip_r(sibling's realm) · favour_cost_mult)`
`errand_cost = ceil(stip_r(max(player's realm, disciple's realm)) · errand_cost_mult)` ; `B_errand = floor(errand_margin · errand_cost)` (round 5: the `min` with `B_quests` is dropped, it never bound)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| master_cult_pct | int | +5 | data file *(guess)* | About two generating pairs; a good master matters but is not a root |
| daolu_cult_pct | int | +8 | data file *(guess)* | Dual cultivation (song tu), the best-known pairing bonus, below a five-element root's +15 |
| help_min | int | 30 (safe 0–99) | data file *(guess)* | Opinion below which a sworn sibling never answers. At 100 the formula divides by zero, so 99 is the safe ceiling |
| help_max | int | 1 | data file *(guess)* | Sworn siblings who may join one fight: Combat rule 19 has no total cap on companion sources |
| favour_call_seasons | int | 4 (safe 1–8) | data file *(guess)* | Seasons after the join within which the sibling's call-in event is presented, when the player can be reached (rule 15a) |
| favour_cost_mult | float | 1.0 (safe > 0) | data file *(guess)* | Seasons of the sibling's realm stipend to clear a favour early with stones (optional, rule 15a) |
| errands_max | int | 2 / 3 / 4 / 6 / 8 by the player's realm | data file *(guess)* | Errands in progress at once (sent this season or earlier, not yet resolved), whatever the disciple count, one per disciple (a payout bound, not a bond cap; user decision 2026-11-21) |
| errand_margin | float | 1.0 (safe 0.6–1.0) | data file *(guess)* | An errand's reward budget (at Item Database price) as a multiple of its cost. At 1.0 the budget never exceeds the cost at price; goods used rather than sold are worth up to 1.08 of it at bulk prices (a small bounded discount, not a stone profit); above 1.0 errands would be a profit |
| B_quests | int | Quests Formulas A | Quests | Not used by `B_errand`; Quests' Errand-tier budget is far above `errand_cost`, so the errand budget is set here |
| errand_cost, favour_cost | int | `stip_r` × the multiplier | calculated | Linh thạch, burned when paid (an errand's stone share is refunded from its burn when it resolves); `stip_r` is the Sects stipend per season by realm (3 / 20 / 50 / 325 / 2,500, Sects anchors) |
| errand_cost_mult | float | 1.0 | data file *(guess)* | One season's stipend per errand, at the higher of the two realms: a price scale only, burned when paid; nobody receives it (no NPC purse is credited) |
| avenger_max, gratitude_max | int | 1 each a season | data file *(guess)* | Event Engine draws from the avenger and gratitude pools (rule 15b) |
| op | int | −100 – 100 | NPC Traits F3 | The sibling's opinion of the caller |

**Output Range:** `cultivation_speed_pct` gains 0, +5, +8 or +13 from ties. `p_help` 0–1. `errand_cost` and
`favour_cost` 3–2,500 linh thạch by realm at multiplier 1.0 (rounded up). An errand's reward budget is at most 1.0 × its cost at Item Database
price, so at that price no more than the cost. The items are raw market commons, bought at the bulk price (1.10), so
stones plus goods are worth 0.2 + 0.8 × 1.10 = **1.08** of the cost to a player who would otherwise buy them (retail
goods at `buy_markup` 1.5 would be 1.40, which is why errand items are limited to commons): a small discount on
goods, not a stone profit, since the stone share is paid out of the burn. Sold at Quests' 20 % stones and
80 % items with items at 0.6 of price (Quests Formulas A, value check), it returns at most 0.68 × 1.0 = **0.68** of
its cost, however many disciples. What they buy is goods fetched without the player travelling.
**Example:** a Kết Đan sworn sibling with opinion 65 (kết nghĩa 40 + friend 25 at full): (65 − 30) / 70 = **0.5**.
They join; their `p_help` is then **0** until the player answers their call-in event (presented within 4 seasons of the join) or pays 50
linh thạch (`favour_cost`). Sixteen siblings give sixteen calls, each followed by a call-in the player must answer or
refuse. A Nguyên Anh player sending a Luyện Khí disciple pays 325 (the higher realm), not 3.

**Feedback loops.** (1) Đạo lữ and masters speed cultivation, a higher realm makes a person notable, and notables hold
more ties: a mild rich-get-richer loop, intended (famous cultivators gather bonds), damped by the one-đạo-lữ and
one-master limits. (2) Kills create feuds and feuds cause kills: damped by rule 14a (the tick's violent-death budget),
`inherit_feud_max`, and inherited feuds passing on only as soft enmity. (3) Feuds and debts toward the player feed
avenger and gratitude events, at most `avenger_max` and `gratitude_max` a season.

## Edge Cases

**Deaths and inheritance**
- **If two people kill each other in the same season** (or the killer dies before S8b): the whole season's dead set is
  struck first (rule 13) and order does not matter; no one gets a feud or enmity toward a member of that set, so
  neither side's heirs gain a feud from that exchange. Mourners still take soft enmity only toward a living killer.
- **If an heir is the killer** (a disciple kills the master, a son the father): the killer is struck from the heirs,
  avengers and mourners; the next in line takes the slot (rule 13). Their own record with the dead is removed with the
  others.
- **If one person is both kin and disciple of the dead**, or an avenger and a child: they take one slot, once (rule 13).
- **If more close ties held enmity toward the killer than `inherit_feud_max`**: the strongest avengers take the heir
  slots; the rest are mourners in the usual order, within `mourner_max`, and a mourner who already held enmity keeps
  the stronger value (floor, rule 10). Past `mourner_max` they keep what they held.
  The pinned feuds per death **toward the killer** never exceed `inherit_feud_max` (and each feud the dead held
  passes at most `inherit_feud_max` more toward its own target: the limit is per death, per target).
- **If an avenger's enmity had faded to 0 but the record was not yet swept**: it is not held (current strength 0);
  the person is an ordinary close tie.
- **If the dead has no children, disciples or close ties**: no feud or enmity passes; the kill is still in the event
  log for a later reveal.
- **If the killer was unknown and is revealed later** by an event: that event may add the feuds then (`tie_add`),
  computed from the heirs alive at the reveal; nothing is back-dated.
- **If the player kills many people with heirs**: each known kill adds at most `inherit_feud_max` pinned blood feuds
  (overflow on the player's side, evicting nothing) and `mourner_max` soft enmities (held outside the player's cap),
  rule 7. 100 such kills is at most 800 extra records (Formula E). The soft reserve still lets the player form
  friends and debts (rule 5), and each feud feeds the avenger pool (rule 15b).
- **If a person with ties dies mid-season**: until S8b removes the records, readers treat ties with a dead person as
  absent (no opinion, no help call). The hook pass at the end of the same S8b removes the dead master's or đạo lữ's
  row, so no bonus lingers into the next season.
- **If a companion dies in a fight**: the companion tie ends by death (rule 13) at S8b; the fight's result stands.

**Caps and records**
- **If an heir's or mourner's slots are all pinned**: an inherited pinned feud still forms (overflow); a mourner's soft
  enmity forms if the mourner has room within their soft-only limit (`soft_reserve`, rule 5) or a weaker soft-only
  record to evict. The killer's side always takes it (outside the cap).
- **If a betrayed sworn sibling was also a friend at 80**: the friend kind is replaced by enmity 70 (deeds override,
  rule 10), and any `favour_owed` on the pair is cleared (rule 12).
- **If a person loses notability** (off the met list, a lost rank): at the next S8b their soft-only records are evicted,
  weakest first, down to the ordinary limit; pinned ties stay (rule 6).
- **If `cap_ordinary`, `cap_notable` or `soft_reserve` is lowered by a data change in a running game**: existing
  records stay; a person over the new limit is over the limit under rule 5 until their next soft-only add (no
  unconditional eviction, round 11).
- **If a second pinned kind is added to a pair** (a disciple becomes đạo lữ): the flag is added to the same record;
  no second record, no extra cap use (rule 1).
- **If a new soft kind is weaker than the pair's current one**: it is dropped (rule 10). A rescue never meets this
  case: its debt is its own part (rule 1a), so a rescued friend or even an enemy owes the rescuer.
- **If a debt is owed both ways** (each rescued the other): the two are netted; the larger remains at the difference
  (rule 1a). Two equal rescues cancel.
- **If a record ends holding only `favour_owed`**: it can. A kết nghĩa ended by `parted` or an Event Engine `tie_end`
  does **not** clear `favour_owed` (a parting is no way to dodge the deed, rule 15a): the record stays holding only
  the flag, counts once against each cap, keeps the call-in scheduled, and is removed when the favour is answered or
  paid or the sibling dies; after a refusal or lapse the slight's enmity is written in place and the record stays
  (rule 15a). Only a betrayal clears the flag with the
  kết nghĩa (rule 12).
- **If `season_now − set_season` is negative** (a corrupt or hand-edited save): it is clamped to 0 (Formula B).
- **If a fade rate of 0 is loaded**: the data load rejects it (Formula B).

**Bonds and verbs**
- **If a person already has a living đạo lữ or master and is offered another**: the verb or event is not available;
  the bond verb shows greyed with the requirement (NPC Interaction & Dialogue rule 5). Leaving a master first needs an
  event that ends sư đồ (expulsion, leaving the sect).
- **If the master falls to or below the disciple's realm** (the disciple breaks through past him): `master_cult_pct`
  stops at the same season's hook pass; the tie stays.
- **If đạo lữ are in different places at the end of the season**: no dual-cultivation bonus that season; the tie is
  unchanged.
- **If a sworn sibling is the opponent, or is already fighting on the other side**: they are not called. A sibling
  already in another fight is not called either.
- **If the player calls for help and no sibling answers**: the fight runs as it would have; no favour is owed. Only a
  sibling who joins is owed.
- **If a sibling owed a favour dies before calling it in**: the flag goes with the record (rule 13); nothing passes to
  heirs.
- **If the player is away, imprisoned or in seclusion when the favour would be called in**: the call-in waits until
  the player can be reached; the flag stays and `p_help` stays 0 meanwhile, and no slight accrues (rule 15a).
- **If the player cannot or will not pay `favour_cost`**: nothing more happens; the favour is still called in by its
  event (rule 15a). Paying is only an early way out.
- **If a disciple dies on an errand**: the cost is not refunded and the reward is lost (rule 15a).
- **If the player's realm is below the disciple's**: the errand costs the disciple's realm stipend (the higher of the
  two, Formula F), so a strong disciple is not a cheap one.

**Degenerate strategies**
- **Farming help:** many sworn siblings would add a companion source each, since Combat rule 19 has no total cap.
  `help_max` 1 a fight bounds it. Each join leaves a favour that the sibling calls in by an event within
  `favour_call_seasons`; refusing is a slight (rule 15a). Sixteen siblings give sixteen calls, each repaid in deeds.
- **Farming disciples for errands:** pinned overflow lets a player take any number of disciples, so the count of
  disciples is not the bound. `errands_max` (by the player's realm) and one errand per disciple bound the errands a
  season; each costs `errand_cost` at the higher realm, burned; and the reward is money and items only, capped at
  `errand_margin` (1.0) × the cost at price, no more than the cost at price, a loss once sold, and a discount on goods when used at market prices (Formula F). Owner of the reward contents:
  Quests and Event Engine.
- **Farming standing or cultivation through errands:** errands carry no relationship, access, `tu_vi`, insight,
  lasting-gain, `wealth` or `standing` outcome (rule 15a).
- **Farming friend through repayment:** only a repaid rescue debt sets `repay_friend`, and only as a floor; loans and
  favours never do (rule 14). A rescue needs a real rescue.
- **Cycling a đạo lữ for the bonus:** only one living đạo lữ; ending one needs a betrayal (which leaves enmity, a
  lasting enemy each time) or an authored `tie_end` parting event, and the hook pass reconciles rows by source, so a
  new partner never stacks on an old row (rule 15a).
- **Rescue farming for ân tình:** a debt has no build hook; it raises opinion, which attitude already bounds (NPC
  Interaction & Dialogue), and feeds at most `gratitude_max` gratitude events a season (rule 15b).

**Narrative**
- **If a feud's target dies of old age or a failed breakthrough**: the feud ends (`target_died`); old age reads as a
  natural death and a failed breakthrough or tribulation as heaven's judgement, never as avenged (rules 1b, 14). **If a stranger, a third party or the player kills the target**: the feud
  ends as `slain` (`feud_end_slain`), with the killer in the entry's payload (rule 14).
- **If a blood feud is held both ways and one side's heir kills the other**: the killed person's heirs take a new
  feud (a renewal, rule 13); the inherited one held by the killer ends with the target.

## Dependencies

**Upstream (this system needs them)**

| System | Hard / Soft | Interface | Has GDD |
|---|---|---|---|
| World Database (#3) | Hard | Tie records indexed by both ids; the hook index (rule 15a); the player's met list (rule 6); people, deaths, the event log (killer known or not; the entries causes link to, rule 1b) | No (built) |
| Save / Load (#5) | Hard | Saves the records (Formula E bound) | No (built) |
| Living World Tick (#28) | Hard | Calls step S8b and its seven sub-steps (rule 9); supplies the season's deaths, breakthroughs, travel, rescues, betrayals; owns the violent-death budget (rule 14a) and revenge on the player (rule 15b) | Yes |
| NPC Traits (#42) | Hard | F3 opinion, whose `tie` term this GDD now defines (Formula A); rule 16 amended | Yes |
| Event Engine (#23) | Hard | `tie_add`, `tie_strengthen`, `tie_weaken`, `tie_end` effects, betrayal and rescue flags, errand and help-call fight events, the favour call-in event (rule 15a), the avenger and gratitude pools (rule 15b), budgets | Yes |
| Time & Turn (#4) | Hard | `season_now`, 4 seasons a year | No (built) |
| NPC Interaction & Dialogue (#30) | Soft | The player's bond verbs and their acceptance gates (rule 11 there); the repay verb asks the creditor for a deed that clears a debt (rule 14) or, optionally, pays `favour_cost` to clear an owed favour (rule 15a); meeting writes the met list (rule 6) | Yes |
| Power Rankings (#44) | Soft | World-fight results: rating gap, injury, kill | Yes |
| Sects & Missions (#26) | Soft | Taking disciples, ranks (notability) and rank loss, sect succession | Yes |
| World economy plan (`production/plans/world-economy.md`) | Soft | Errand items are a goods faucet; the `errand_cost` and `favour_cost` burns are stone sinks not on the user's sink list (Open Question 7) | Plan |
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

**Back-links written 2026-11-21** (after approval):
- **NPC Interaction & Dialogue** rule 11: favour and `favour_cost` replace `help_cost`; the repay verb's entries and
  deed; declare enmity +30 both ways; meeting writes the met list; a bond verb names the tie it would evict.
- **Quests** Dependencies row: the errand rules (`errands_max` in progress, one per disciple, cost at the higher
  realm, `B_errand`, money and raw commons only, no outcomes outside B, no `wealth` or `standing`); the call-in's B = 0.
- **Living World Tick** rule 20 and the S8b row: the seven sub-steps and the hook pass; revenge on the player;
  known kills unless `secret`; S11 keeps the cause payloads.
- **Character Stats** #46 row: rows added and removed by the hook pass.
- **Event Engine** Downstream row (new): tie effects and conditions, the favour call-in, the avenger and gratitude
  pools and their budgets.
- **NPC Traits** F3 `tie` row: the debt term, range −70 to +105, Grudge and feud plus enmity as one term.
- **Sects** #46 row: a lost rank is reported to the S8b queue; the errand cost at the higher realm.
- **World-economy plan** (open items): errand items as a goods faucet; the burns for Open Question 7.

**Still owed:** World DB (#3) has no GDD; its shape for the hook index, the met list and the cause links lands with
`/reverse-document` of the World DB. The repay verb's menu and verb details stay Dialogue's to fill in.

**Back-links written 2026-11-20** (user-approved):
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
  jade), blood feud (a red-stained blade, so it never shares kin's seal). Kind is never told by colour alone: each has its own glyph, and warm or cold
  tint is a backup (accessibility floor).
- **Strength.** Soft ties show a band (faint, firm, deep for 1–33 / 34–66 / 67–100), drawn as one to three strokes
  under the glyph; no raw number on the card, the number in the tooltip (Pillar 2, "Every Number Is Bounded and
  Visible").
- **News.** Tie events appear as *tin đồn* (rumour) lines with the tick's bracketed tag (Living World Tick Visual/Audio):
  bonds sworn, feuds declared, avenged (báo thù), heaven's judgement, a debt repaid.
- **Audio.** No new cues required; a single short ink-stroke sound for a bond formed and a low drum for a blood feud
  on the player are candidates for the audio pass (Audio #38, not designed).
- `art-director` lens applied (full mode); no art bible principles 1–4 exist to cite.

## Game Feel

Optional for a Narrative system; one target only. A bond formed or broken with the player is acknowledged in the same
screen, the moment the verb or event resolves (the news line and the card glyph update before the player can act
again), so a deed and its consequence read as one beat.

## UI Requirements

The rules of what the player must be told are rule 15c. The screens, gamepad and screen-reader routes, news templates
and font scaling belong to a UX spec (`design/ux/relationships-page.md`, to author with `/ux-design` before
implementation).

- **Person card** (NPC Interaction & Dialogue): the card lists the NPC's ties to the player first, then up to 3 of
  their other notable ties (master, đạo lữ, a blood feud), each with its glyph, name in Vietnamese and English, and
  band. Bond verbs greyed with their missing requirement stay Dialogue's.
- **Relationships page** on the player's character screen:
  - every tie the player holds, grouped pinned, then soft and debts, sortable by kind and by strength, with the
    partner's location if known;
  - owed favours marked with their state (awaiting, presented, accepted) and the rule 15c favour block, also on the
    person card; inherited feuds marked, each with its cause (rule 1b); enmity and feuds show their direction
    (toward you / toward them) with each direction's band;
  - the cap shown as `ties / 16`, with ties held outside the cap (overflow pinned, mourner enmity) counted
    separately;
  - when the player is full, the soft-only record that would be evicted next is named (rule 7 picks it
    deterministically).
- **Help call** in a fight event: an option listing the sworn siblings in range, each with their answer chance
  (`p_help` as a percentage), who would join first if they answer (highest `p_help`), the chance that at least one
  answers, and the consequences (rule 15c): one who joins will call the favour in within `favour_call_seasons`, and
  refusing the call-in costs `refuse_delta`; no one answering costs nothing. A sibling already owed is shown greyed
  with the reason as text.
- **Notices**: an inherited feud or mourner enmity on the player, a feud toward the player, and an eviction of the
  player's tie each give a news line naming the people involved (rule 15c).
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
| Formula F, Edge Cases | Errand-tier reward budget `B` | `quests.md` Formulas A | Errand reward cap (`errand_margin`) |

## Acceptance Criteria

Tags and where each kind of test lives:
- **[Logic]** is an automated gdUnit4 unit test in `tests/unit/relationships/`.
- **[Integration]** is an automated integration test in `tests/integration/relationships/`.
- **[Performance]** is a timed test in `tests/performance/relationships/`. It runs on the reference machine (the
  owner's development PC; the first run records its CPU model) from a release export, not the editor. It reports the
  median and p95 over 5 runs, which are kept in `production/qa/evidence/`. A later run may not exceed the first passing
  run by more than 20 %.
- **[UI]** is a retained screenshot in `production/qa/evidence/`, under the file name given.

Test files follow `.claude/rules/test-standards.md` (`relationships_[feature]_test.gd`). Numbers come from the data
file: a test reads the value it checks, except where the boundary itself is the point. Strengths in GIVEN lines are
current strengths at the test's season. AC ids are stable, so other GDDs can cite them; new ones are added at the end
of their group.

**Fixtures**
- **FX-PAIR:** two Luyện Khí NPCs A and B. Same sect, no shared or opposed traits, no gained traits, ordinary (not
  notable), season 100. Each holds no other tie. Ties a GIVEN line sets (kết nghĩa, đạo lữ included) are written
  directly as authored records (round 11; rule 6's notable gate applies to the add path, AC-NR-15).
- **FX-FAM:** a sect head H (notable). H has:
  - 2 children, C1 (elder) and C2;
  - 30 disciples, D1 (eldest) to D30;
  - a sibling S.

  K is a known killer. K holds 16 ties (4 pinned, 12 soft-only), none of them with H, an heir or a mourner.
  `inherit_feud_max` is 3 and `mourner_max` is 5. No one holds enmity toward K. Every heir and mourner has at least
  2 free slots. There is no đạo lữ.
- **FX-FAM-2:** FX-FAM where C1 also has children X1 and X2 and a disciple Y1, and holds an inherited blood feud
  toward K at `generation` 0, cause origin (W, K, season 90, place L) with W an already-dead person outside FX-FAM (round 9; AC-NR-20). K is notable in FX-FAM; fixture variants that add enmity or feuds
  toward K write those records directly, so K's count then exceeds 16.
- **FX-W5K:** NPC Traits' generated world of 5,000 people from a fixed seed, plus World Generation's authored cast
  and its ties.
- **FX-EV-T:** an Event Engine stub that emits, each season from a fixed seed, 40 `tie_add`, 40 `tie_strengthen`, 10
  `tie_end`, 5 rescues, 2 betrayals and 5 known kills.
- **FX-STUBS:** stubs that each emit a fixed, scripted result:
  - Power Rankings: a world-fight result with its rating gap, injury and kill;
  - Combat: a companion source recorder;
  - Quests: an Errand plan builder with settable `B_quests`;
  - Dialogue: the repay, bond and recruit verbs and meeting;
  - Modifier System: a row recorder.

**Record and kinds**
- **AC-NR-01** [Logic] Rule 1.
  - **GIVEN** FX-PAIR, **WHEN** sư đồ, then kin, then enmity 40, then a debt 30 (A owes B) are added to (A, B),
    **THEN** exactly one record exists. It holds flags {sư đồ, kin}, soft kind enmity 40 and debt 30 A → B, and A's
    and B's tie counts are each 1.
- **AC-NR-02** [Logic] Rule 2.
  - **GIVEN** a disciple with a living master, **WHEN** a second sư đồ to another master is added, **THEN** it is
    refused.
  - The same holds for a second living đạo lữ.
- **AC-NR-03** [Logic] Rule 2.
  - **GIVEN** an NPC, **WHEN** a companion tie to another NPC (not the player) is added, **THEN** it is refused.

**Opinion (Formula A, rule 3)**
- **AC-NR-04** [Logic] Formula A.
  - **GIVEN** FX-PAIR with kết nghĩa and friend strength 60, **THEN** `tie(A, B)` is 55.
  - **WHEN** the friend kind is removed, **THEN** 40.
  - **WHEN** kin and sư đồ are both set and nothing else, **THEN** 30 (not 60).
  - **WHEN** friend 60 and a debt 60 owed by A to B are set with no pinned kind, **THEN** `tie(A, B)` is 33 and
    `tie(B, A)` is 21.
- **AC-NR-05** [Logic] Formula A.
  - **GIVEN** B holds a blood feud toward A and the pair are kin, **THEN** `tie(B, A)` is −30 and `tie(A, B)` is 30.
  - **GIVEN** a feud plus a full rivalry, **THEN** −70.
  - **GIVEN** đạo lữ, full friend and a full debt as debtor, **THEN** 105, which F3 clamps to 100 in the opinion.
  - **GIVEN** A holds a blood feud toward B, **WHEN** B cripples A (enmity +40 from A toward B), **THEN** no soft
    enmity is stored and `tie(A, B)` stays −60.
- **AC-NR-06** [Logic] Formula A, Open Question 2.
  - **GIVEN** A holds a Grudge gained trait toward B and an enmity tie toward B at strength 80, **WHEN** NPC Traits
    F3 computes A's opinion of B, **THEN** the tie-and-grudge part is −50 (the more negative of −50 and −40), not
    −90.
  - **WHEN** a player verb writes the enmity to 100 (before S8b hardens it), **THEN** −50; **WHEN** it has hardened
    into a feud, **THEN** `min(−50, −60)` = −60.
- **AC-NR-07** [Integration] Rule 3, NPC Traits AC-NT-21.
  - **GIVEN** FX-W5K after 20 seasons with ties, **WHEN** 10,000 opinions and 10,000 tie lookups are read, **THEN**
    the save is byte-identical before and after.

**Fade, strength and eviction (Formulas B, C, rules 4, 5, 7, 10)**
- **AC-NR-08** [Logic] Formula B.
  - **GIVEN** a friend tie set to 70 at season 100, **THEN** its strength reads 22 at season 148, 1 at season 169
    and 0 at season 170.
  - At season 170 the record still exists until either person is touched. **WHEN** A is touched by a rule-7 change,
    **THEN** the soft kind is removed (and the record too, if it holds nothing else).
- **AC-NR-09** [Logic] Formula B boundary.
  - **GIVEN** a set season greater than `season_now`, **THEN** the strength reads as stored (no increase, no error).
  - **GIVEN** a data file with a fade rate of 0, **THEN** the load rejects it.
- **AC-NR-10** [Logic] Formula C.
  - **GIVEN** a debt at 30, **WHEN** a rescue (Δ 60) applies, **THEN** it is 90 and its set season is now.
  - **GIVEN** friend 50, **WHEN** Δ +20 applies, **THEN** 70.
  - **WHEN** Δ −100 applies, **THEN** the soft kind is removed at once.
- **AC-NR-11** [Logic] Rules 1a, 10.
  - **GIVEN** enmity 80 on (A, B), **WHEN** rival Δ 30 is added, **THEN** the soft kind stays enmity 80.
  - **WHEN** instead enmity is 20, **THEN** the soft kind becomes rival 30.
  - **GIVEN** enmity 80, **WHEN** a rescue adds a debt Δ 60, **THEN** the enmity stays 80 and the record also holds
    the debt 60.
- **AC-NR-12** [Logic] Rule 7.
  - **GIVEN** at season 100 an ordinary person A with 6 records:
    - 2 pinned;
    - 4 soft-only friend ties: P1 stored 10 and set at 100; P2 stored 30 and set at 90 (reads 20); P3 stored 20 and
      set at 100; P4 stored 50 and set at 100.
  - **WHEN** a friend tie Δ 30 is added with B, who has a free slot, **THEN** (A, P1) is removed, P1's tie count falls
    by 1, and A and B each gain the new record.
  - **WHEN** a second friend tie Δ 30 is added with C, who has a free slot, **THEN** (A, P2) is evicted (equal 20s:
    the older set season goes).
- **AC-NR-13** [Logic] Rules 5, 7.
  - **GIVEN** an ordinary person with 6 pinned ties, **WHEN** a soft tie is added, **THEN** it forms (7 records:
    `soft_reserve` 2).
  - **WHEN** a second soft tie forms, **THEN** 8 records.
  - **WHEN** a third soft tie stronger than both is added, **THEN** the weaker reserve tie is evicted (8 records).
  - **WHEN** a pinned tie is added, **THEN** it forms and nothing is evicted (9 records).
- **AC-NR-14** [Logic] Rules 5–7.
  - **GIVEN** a sect elder holding 12 records (4 pinned, 8 soft-only), **WHEN** Sects reports the lost rank, **THEN**
    at the next S8b the soft-only records are evicted, weakest first, until 2 remain (6 records).
  - Before that S8b, nothing changes.
- **AC-NR-15** [Logic] Rule 6.
  - **GIVEN** two ordinary NPCs, **WHEN** a non-authored source adds kết nghĩa or đạo lữ, **THEN** it is refused.
  - **GIVEN** one of them is notable, **THEN** it forms.
- **AC-NR-42** [Logic] Rule 7.
  - **GIVEN** A at cap 6 with 2 pinned records, one of which holds a soft part at strength 5, and 4 soft-only records
    at 15, 40, 40 and 40, **WHEN** a soft tie of 30 to B is added and B has a free slot, **THEN** the record at 15 is
    evicted and the pinned record keeps its soft part.
  - **GIVEN** instead B at its soft-only limit with every soft-only record at 30 or more, **THEN** nothing changes for
    A or B (30 is not strictly weaker than 30).
- **AC-NR-44** [Logic] Rules 1a, 4, Formula B.
  - **GIVEN** enmity 60, **WHEN** Δ +1 applies every season for 20 seasons, **THEN** it reads 70 (no fade is lost to
    rounding).
  - **GIVEN** no friend tie, **WHEN** Δ −10 friend applies, **THEN** no record is created.
- **AC-NR-45** [Logic] Rule 1a.
  - **GIVEN** A owes B a debt 60, **WHEN** a rescue of B by A adds Δ 40 the other way, **THEN** A owes B 20.
  - **WHEN** a further Δ 20 B → A applies, **THEN** the debt is removed.

**Hardening, betrayal, death (Formula D, rules 11–14a)**
- **AC-NR-16** [Logic] Rules 11, 13.
  - **GIVEN** enmity 50, **WHEN** Δ +40 applies in an S8b, **THEN** after step 6 the pair holds a pinned blood feud
    (`inherited` false, cause the deed) and no soft enmity, on the same record.
  - **GIVEN** FX-FAM with D6 holding enmity 10 toward K before the death, **WHEN** K kills H in public, **THEN** the
    heirs are D6, C1 and C2:
    - D6's feud has `inherited` false, its soft enmity is removed, and D6 and K share one record;
    - C1's and C2's feuds have `inherited` true;
    - the mourners are S and D1–D4.
- **AC-NR-17** [Logic] Rules 10, 12.
  - **GIVEN** kết nghĩa (A, B) with `favour_owed`, **WHEN** an event marks B's betrayal of A, **THEN** the kết nghĩa
    flag and `favour_owed` are removed, A holds enmity 70 toward B, and B holds nothing toward A.
  - The same holds for sư đồ and for đạo lữ.
  - **GIVEN** kin instead, **THEN** kin stays and enmity is added.
  - **GIVEN** kết nghĩa plus friend 80, **THEN** A's soft kind is enmity 70.
  - **GIVEN** A already held enmity 40 toward B, **THEN** it reaches 100 and is a blood feud after step 6.
  - **GIVEN** kết nghĩa plus đạo lữ, **THEN** both are removed.
- **AC-NR-18** [Logic] Formula D, rules 7, 13.
  - **GIVEN** FX-FAM, **WHEN** K kills H in public, **THEN**:
    - C1, C2 and D1 each hold a pinned inherited blood feud toward K;
    - S and D2–D5 hold soft enmity 50 toward K, and D6–D30 hold nothing toward K;
    - K holds exactly 24 records (8 new) and all 12 of its earlier soft ties remain;
    - H has no records left.
- **AC-NR-19** [Logic] Rule 13 (Struck).
  - **GIVEN** FX-FAM, **WHEN** the kill is not known, **THEN** no feud or enmity toward K forms.
  - **WHEN** D1 is the killer, **THEN** D1 is struck, D2 takes the third heir slot, and the mourners are S and
    D3–D6.
- **AC-NR-20** [Logic] Rule 13.
  - **GIVEN** FX-FAM-2 (FX-FAM where C1 has children X1 and X2 and a disciple Y1, and holds an inherited blood feud
    toward K at `generation` 0), **WHEN** C1 dies naturally, **THEN** X1, X2 and Y1 hold soft enmity 50 toward K (outside K's cap,
    `outside_cap` set), none holds a pinned feud, and the cause carries the origin (W, K, 90, L) with
    `generation` 1.
- **AC-NR-21** [Logic] Rule 13.
  - **GIVEN** B (3 free slots) owes a debt 80 to H, **WHEN** H dies, **THEN** B owes a debt 40 to each of H's three
    heirs (C1, C2, D1). With only 2 free slots, B owes C1 and C2 and D1 is skipped (B's other records are not weaker).
  - **GIVEN** a debt of 1, **THEN** no debt passes.
  - **GIVEN** H owed a debt to B, **THEN** it is cancelled.
- **AC-NR-22** [Logic] Rule 14.
  - **GIVEN** A holds a blood feud toward B, **WHEN** B dies of old age, **THEN** the feud ends and the news line has
    the kind id `feud_end_natural`.
  - **WHEN** instead A kills B, **THEN** the kind id is `feud_end_avenged`.
  - **WHEN** instead a stranger kills B, **THEN** the kind id is `feud_end_slain` and the entry carries the killer.
- **AC-NR-23** [Logic] Edge cases.
  - **GIVEN** A and B kill each other in the same season, **THEN** no feud toward either forms at S8b.
- **AC-NR-24** [Integration] Rule 14a, Living World Tick. **Blocked until** Living World Tick Open Question 4 sets the
  violent-death budget.
  - **GIVEN** FX-W5K with FX-EV-T run for 400 seasons, **THEN** violent deaths never exceed the tick's
    `violent_death_budget` (read from its data) in any season.
  - The share of living blood-feud holders after 400 seasons is ≤ `feud_share_max` (test data, first value 0.05).
- **AC-NR-46** [Logic] Rules 10, 13 (avengers and floors).
  - **GIVEN** FX-FAM where, before the death, D1, D2 and D3 hold enmity 85 toward K and D4 holds 80, **WHEN** K kills
    H in public, **THEN** the heirs are D1–D3 (own feuds, children displaced).
  - The mourners are C1, C2, S, D4 and D5: D4 keeps 80, and the others hold 50.
- **AC-NR-40** [Logic] Rule 14.
  - **GIVEN** B owes a debt 60 to A from a rescue, **WHEN** the debt is repaid, **THEN** the debt is removed and the
    soft kind is friend 30 (`repay_friend`).
  - **GIVEN** friend 50 already, **THEN** friend 50.
  - **WHEN** instead a loan is repaid or a favour is cleared, **THEN** no tie changes.

**Tick, sources and save (rules 1b, 6, 8, 9, Formula E)**
- **AC-NR-25** [Logic] Rule 9.
  - **GIVEN** one season's queue for A, where B is notable, M's only tie is A (so A is M's only avenger and heir and
    M has no mourners), and every person has a free slot:
    - A's master M is killed by K in public (a known kill), and A held enmity 20 toward K;
    - A's kết nghĩa B betrays A;
    - C insults A when A already holds enmity 70 toward C;
    - a friend tie Δ 20 forms with D, who has a free slot.
  - **WHEN** S8b runs, **THEN**:
    - A holds a pinned feud toward K (avenger, own);
    - (A, B) holds enmity 70 and no kết nghĩa;
    - (A, C) is a blood feud (enmity 70 + 30 = 100 at step 4, hardened at step 6);
    - (A, D) is friend 20.
  - A snapshot diff shows changes only on the records of A, M, K, B, C and D.
  - **WHEN** the same event-log entries are enqueued in a different order (the log order itself kept), **THEN** the
    result is the same.
- **AC-NR-26** [Logic] Rule 8.
  - **GIVEN** FX-W5K, **WHEN** a season passes with an empty queue, **THEN** no tie record changes except the
    player's swept faded parts and the hook pass's rows.
- **AC-NR-27** [Integration] Rule 8, Power Rankings (FX-STUBS).
  - **GIVEN** two NPCs whose ratings differ by 100 fight a world fight, **THEN** they gain rival 30.
  - **GIVEN** a gap of 101, **THEN** no rivalry.
  - **WHEN** the loser is crippled, **THEN** the loser gains enmity 40 toward the winner, replacing a rivalry.
- **AC-NR-28** [Integration] Formula E. Provisional until Living World Tick Open Question 4.
  - **GIVEN** FX-W5K with FX-EV-T for 400 seasons, plus a player who makes 100 known kills, **THEN** at the end of
    every season the record count is ≤ 23,000.
  - No soft-only record is ever added to a person already at their soft-only limit without an eviction (rule 5), and
    no person's soft-only records exceed their cap, not counting mourner enmity held toward them, people queued
    for a lost-notability eviction that has not run yet, and people left over their limit by an in-place betrayal or
    repay (rule 9 step 2) or a hardening until their next soft-only add.
- **AC-NR-29** [Integration] Save / Load.
  - **GIVEN** FX-W5K after 100 seasons, **WHEN** saved and loaded, **THEN** every record round-trips exactly: both
    ids, flags, the soft kind and debt with directions, strengths and set seasons, `inherited`, `favour_owed`, and
    the causes with their links.
  - The player's met list and the hook index also round-trip exactly.
- **AC-NR-30** [Integration] World Generation.
  - **GIVEN** a new game, **THEN** each authored tie in the World Generation cast data (kin, sư đồ, kết nghĩa, đạo
    lữ) exists as a record of that kind, pair by pair; no record with cause `authored` lies outside the cast data;
    and each ordinary person's generated kin records match World Generation's kin rule.
- **AC-NR-31** [Performance]
  - **GIVEN** FX-W5K with FX-EV-T (about 102 source changes a season, plus the cascades they cause), run for 400
    seasons, **THEN** over those 400 seasons S8b takes ≤ 5 ms at the 95th percentile of the 400 samples, in each of 5
    runs.
  - The hook pass over the hook index takes ≤ 2 ms at the 95th percentile over the same samples (it is the last
    part of S8b, so it counts inside the 5 ms).
  - 10,000 tie lookups, timed as 100 batches of 100, take ≤ 0.1 ms a batch at the 95th percentile of the batch times
    (10 ms for the 10,000).
- **AC-NR-43** [Logic] Rule 6.
  - **GIVEN** a player who has met X and then 499 others, and X's only notability is the met list, **WHEN** a soft
    tie is added to X while X holds 15 records (2 pinned), **THEN** it forms (16).
  - **WHEN** the player meets one more person, **THEN** X is off the list and, at the next S8b, X's soft-only
    records are evicted down to 4 (6 records).
  - **WHEN** the player meets X again, **THEN** X moves to the front of the list.
- **AC-NR-47** [Logic] Rule 1b.
  - **GIVEN** FX-FAM, **WHEN** K kills H, **THEN** C1's feud has cause `inherited` linking the death's event-log
    entry.
  - A rescue's debt has cause `rescue` linking the rescue entry.
  - A strength change keeps the cause, and a replaced soft kind takes the new one.
- **AC-NR-48** [Integration] Rules 7, 9, property test.
  - **GIVEN** 10,000 seeded random S8b queues (adds, deeds, ends, deaths, rescues, betrayals) on FX-W5K, **THEN**
    after every S8b:
    - each record is indexed from both sides;
    - no stored part has strength 0;
    - no soft-only record was added past its holder's soft-only limit, and no person's soft-only records exceed their
      cap, beyond the rule 5, rule 6 and rule 7 exceptions;
    - no record holds a blood feud and soft enmity the same way;
    - for each death and each target, pinned feuds created are ≤ `inherit_feud_max`, and soft enmity created toward
      that target is ≤ `inherit_feud_max` + `mourner_max` (≤ `mourner_max` when a pinned feud was created toward it);
    - no record names a person who died this S8b or pairs a person with themselves.

- **AC-NR-52** [Logic] Rules 1, 7, 10, 11, Formulas A–C (per direction). Each WHEN below starts again from the
  GIVEN.
  - **GIVEN** FX-PAIR with enmity A → B at 70 and B → A at 30 and no pinned kind, **THEN** `tie(A, B)` is −35 and
    `tie(B, A)` is −15.
  - **WHEN** 60 seasons pass, **THEN** B → A is removed on its own and A → B reads 40; the kind ends only when both
    are 0.
  - **WHEN** a rival Δ 30 is added while A → B is 70, **THEN** it is dropped (the larger direction is compared).
  - **WHEN** A → B reaches 90, **THEN** A holds a pinned blood feud toward B and B → A stays soft enmity.
  - The save round trip keeps each direction's strength, set season, cause and `inherited` flag.
- **AC-NR-53** [Logic] Rule 5 (over the limit), rule 9 step 2.
  - **GIVEN** an ordinary master M with 8 pinned sư đồ records and 2 soft-only friend records at 10 and 20 (soft-only
    limit 2), **WHEN** one disciple betrays M (in place), **THEN** M holds 3 soft-only records and nothing is evicted.
  - **WHEN** a soft tie Δ 30 is added with a partner who has a free slot, **THEN** the friends at 10 and 20 are
    evicted and the add forms. With friends at 10 and 50 instead, **THEN** the add is refused and nothing changes.
- **AC-NR-54** [Logic] Rule 13 (feuds the dead held).
  - **GIVEN** FX-FAM where H holds a non-inherited blood feud toward T and D1 holds enmity 20 toward T, **WHEN** H
    dies naturally, **THEN** C1, C2 and D1 take a pinned inherited feud toward T, D1's enmity is removed (that
    direction only), S and D2–D5 take soft enmity 50, and a feud inherited this season does not pass on again.
  - **GIVEN** T is C2, **THEN** C2 is struck and D2 takes the third slot.
  - **GIVEN** D5 holds enmity 85 toward T and no one else does, **THEN** D5 is a mourner (an avenger only for a known
    kill), not an heir.
  - **GIVEN** FX-FAM-2 (C1 holds an inherited feud toward K before this season) where H also holds a non-inherited
    feud toward T, and H and C1 both die naturally in the same S8b, **THEN** H's lists skip C1 (the season's dead
    are struck first), so H's feud toward T passes as pinned inherited feuds to C2, D1 and D2; C1 takes nothing from
    H's death; C1's feud toward K passes only as soft enmity 50 toward K, held outside K's cap, by C1's living heirs
    and mourners (X1, X2, Y1, and C2 as C1's kin). FX-FAM has no master, so no master mourns here.
  - **GIVEN** a dead disciple who has a master M and a đạo lữ P, **WHEN** a known K kills them, **THEN** the mourners
    are taken in the order P, M, other kin, kết nghĩa, disciples.
- **AC-NR-55** [Logic] Rule 13 (avengers and mourners).
  - **GIVEN** FX-FAM where D1 holds an inherited blood feud toward K, **WHEN** K kills H in public, **THEN** the
    heirs are D1 (own feud, `inherited` false, cause `kill`), C1 and C2, and the mourners are S and D2–D5.
  - **GIVEN** a mourner who holds friend 60 toward K, **THEN** the enmity 50 is dropped (weaker) and the mourner
    still uses a mourner slot.
  - On K's side the mourner records carry the `outside_cap` marker, which clears when the record gains another part.
  - **GIVEN** K at its soft-only limit also holding three `outside_cap` enmities at 50, **WHEN** K adds a friend tie at
    60, **THEN** none of the three is evicted from K's side (not counted, not a candidate); a mourner's own side may
    evict its record as soft-only.
  - **GIVEN** H, who held a non-inherited feud toward T, is killed by K and C1 is first in both lists, **THEN** C1 takes
    one pinned feud toward K and one toward T (slots are per target).
  - **GIVEN** a rule 15a `favour_owed` record on A with 2 pinned and 3 soft-only records (soft-only limit
    max(2, 6 − 3) = 3), **WHEN** a soft add Δ 30 forms, **THEN** the weakest soft-only record under 30 is evicted and
    the favour record never is.
- **AC-NR-56** [Logic] Rules 1b, 14.
  - **GIVEN** a cause whose event-log entry is pruned, **THEN** the news line still reads the names, the dead and the
    place from the cause payload.
  - One sub-case per reason in the rule 1b table, each with its trigger, written `tie_end` reason, news kind and
    payload (the old cause payload; an end by a death also carries the death's payload, the killer only when known):
    - (a) `avenged`: A kills B; (a2) A's brother, who held enmity toward B, kills B; (a3) A's brother with no enmity
      kills B, giving `slain`;
    - (b) `slain`: a stranger kills B (killer in the payload); (b2) a secret kill gives `target_died` with no killer;
    - (c) `target_died`: B dies of old age, a failed breakthrough, a monster; the text differs for the first two;
    - (d) `holder_died` with no heir; (e) `partner_died` for a kin or sư đồ record at a death;
    - (f) `faded`; (g) `evicted`; (h) `betrayed`; (i) `repaid`;
    - (j) `parted`: a companion dismissed, a sư đồ ended by expulsion, an Event Engine `tie_end` saying so;
    - (k) `replaced`: a deed enmity replaces a friend kind, and hardening removes the soft enmity;
    - (l) `cancelled`: a debt netted to 0 (AC-NR-45), and a debt the dead owed;
    - (m) the holder and the target die in the same season: the written reason is the target's, not `holder_died`.
- **AC-NR-57** [Logic] Rules 8, 14 (verbs).
  - **WHEN** the player declares enmity on a friend at 80, **THEN** enmity +30 is written both ways as an ordinary
    soft write: it is dropped against the stronger friend 80.
  - **WHEN** the player repays a rescue debt they owe, **THEN** the creditor offers a B = 0 deed, completing it
    clears the debt and sets `repay_friend`, and the world's stone total is unchanged.

**Hooks (Formula F, rules 15a, 15b)**
- **AC-NR-32** [Integration] Formula F, hook pass (FX-STUBS).
  - **GIVEN** a disciple, NPC or player, whose master lives at a higher realm, **THEN** after the hook pass their
    sheet holds exactly one `cultivation_speed_pct` row +5 with source `tie`. It is still one row after 3 seasons.
  - **WHEN** the disciple breaks through to the master's realm at S2, or the master dies, **THEN** the row is removed
    by the same season's hook pass.
- **AC-NR-33** [Integration] Formula F, hook pass (FX-STUBS).
  - **GIVEN** đạo lữ with the same `location_id` at the end of the season, **THEN** each holds +8.
  - **WHEN** one has moved by the next season's end, **THEN** both rows are removed.
  - A null `location_id` gives no row.
  - A disciple with a higher-realm master and a đạo lữ in the same place holds +5 and +8 (+13).
- **AC-NR-34** [Logic] Formula F boundary.
  - **GIVEN** `help_min` 30, **THEN** `p_help` is 0 at opinion 30 and below, 0.5 at 65, and 1 at 100.
- **AC-NR-35** [Integration] Rule 15a, Combat (FX-STUBS).
  - **GIVEN** the player has 3 Kết Đan sworn siblings within one travel step at `p_help` 0.9, 0.7 and 0.5, all forced
    to answer, plus a fourth sibling who is the opponent, **WHEN** the player calls for help, **THEN**:
    - exactly 1 joins, the 0.9 sibling, as one companion source;
    - the opponent is never called;
    - only the joiner's pair gains `favour_owed`, and on the next call the joiner's `p_help` is 0.
- **AC-NR-49** [Integration] Rule 15a, the favour.
  - **GIVEN** the AC-NR-35 joiner and a reachable player, **THEN** a call-in event from them is presented within
    `favour_call_seasons` of the join, with B = 0 and no item or `tu_vi` outcome.
  - **WHEN** the player accepts and the task ends Completed or in a lost `defeat` stage, **THEN** the flag clears at
    once, `p_help` is 0.9 again, and opinion is unchanged. A refusal's slight is written at the next S8b.
  - **WHEN** the player accepts and then abandons the task (or it lapses, is dropped, or its item is disposed of),
    **THEN** it is a slight, as for a refusal.
  - **WHEN** the player pays `favour_cost` after the call-in is presented or accepted, **THEN** the task ends
    Withdrawn with no slight.
  - **WHEN** instead the player refuses, or accepts and the task ends unanswered, **THEN** the flag clears and
    the sibling's friend tie falls by 30 (a friend tie below 30 is removed and the remainder added as enmity). With no
    friend tie, the sibling gains enmity 30 (or adds 30 to an enmity), cause `slight`.
  - **GIVEN** the player enters seclusion after the join and stays unreachable past join + `favour_call_seasons`,
    **THEN** nothing is presented while unreachable, the flag stays, `p_help` stays 0 and no slight accrues; on the
    first reachable season the call-in is presented.
  - **GIVEN** the sibling dies before the call-in, **THEN** the flag goes with the record and nothing passes to heirs.
  - **GIVEN** the call-in is presented or accepted, **WHEN** the sibling dies or betrays the player, **THEN** the
    call-in ends Withdrawn, no slight is written and no record is created for the dead.
  - **WHEN** instead the player pays `favour_cost` (50) before the call-in, **THEN** the world's stone total falls by
    50 and the flag clears.
  - **GIVEN** two siblings at equal `p_help`, **THEN** the lower id joins.
- **AC-NR-36** [Integration] Rule 15a, Dialogue.
  - **GIVEN** the player is a disciple, **WHEN** they ask their master for teaching of one of the master's own
    techniques, **THEN** it is accepted whatever the score.
  - A technique not the master's own is scored normally.
- **AC-NR-37** [Integration] Rule 15a, Quests (FX-STUBS).
  - **GIVEN** a Trúc Cơ player (`errands_max` 3) with 5 Trúc Cơ disciples (stipend 20), 100 linh thạch and
    `B_quests` 60, **WHEN** the player sends errands in one season, **THEN**:
    - 3 are sent and a 4th is refused, and a disciple already out on an errand cannot be sent again;
    - each sent errand lowers the world's stone total by 20 at send and raises it by the stone share of its reward
      (4 of 20) when it resolves;
    - each reward budget is 20 (`floor(1.0 × 20)`, whatever `B_quests` is), and no errand plan holds a relationship, access, `tu_vi`, insight, lasting-gain,
      `wealth` or `standing` outcome.
  - A Luyện Khí disciple of this player costs 20, not 3.
  - **GIVEN** a purse of 19, **THEN** no errand can be sent and the purse stays 19.
  - For each realm, `errands_max` is 2, 3, 4, 6 and 8, counting errands in progress at once (sent this season or
    earlier and not yet resolved): with 3 in flight at `errands_max` 3 a new send is refused until one resolves.
  - **GIVEN** `errand_margin` 0.7 and cost 20, **THEN** the budget is 14; items in the reward are raw commons only.
- **AC-NR-38** [Integration] Rule 16.
  - **GIVEN** an NPC with attitude 10 to the player, **WHEN** a kết nghĩa forms with the player, **THEN** the stored
    attitude stays 10 and the NPC's opinion of the player rises by 40.
- **AC-NR-41** [Integration] Rule 15, Event Engine.
  - **GIVEN** an event whose condition is "has blood feud toward the player", **WHEN** checked for one NPC with that
    feud and one without, **THEN** it is eligible only for the first.
- **AC-NR-50** [Integration] Rule 15b, Event Engine.
  - **GIVEN** 5 NPCs with feuds toward the player and 5 who owe the player a debt, and Event Engine pool stubs that
    each hold at least 1 eligible entry, **WHEN** 40 seasons pass, **THEN** no season draws more than `avenger_max`
    avenger events or `gratitude_max` gratitude events, and with stubs that always draw, exactly that many. A feud or
    debt toward the player gained or lost changes pool membership the same season.
  - **GIVEN** empty pools, **THEN** each draws 0.
  - Every drawn event names a holder of a feud or debt toward the player.

**Presentation**
- **AC-NR-39** [UI] Rule 15c.
  - **GIVEN** the person card of an NPC with a pinned and a soft tie to the player, **THEN** both show with their
    names (Vietnamese and English) and the soft tie's band (faint, firm or deep: 1–33, 34–66, 67–100). Screenshot:
    `relationships-card.png`.
- **AC-NR-51** [UI] Rule 15c.
  - **GIVEN** a help call with one sibling owed a favour and two not, **THEN** the two show their answer chance and
    the call-in consequence, and the owed one shows greyed with the reason. Screenshot: `relationships-help-call.png`.
  - **GIVEN** the player inherits a feud, **THEN** a news line names the dead and the killer. Screenshot:
    `relationships-inherited-feud.png`.
  - **GIVEN** a full relationships page, **THEN** the next soft-only record to be evicted is named, and the soft-only
    slots used out of the limit are shown. Screenshot: `relationships-page-full.png`.
  - **GIVEN** a help call with 2 siblings at known `p_help`, **THEN** the display shows each chance, who would
    join, the chance that at least one answers, `favour_call_seasons`, and the `refuse_delta` cost of refusing the
    call-in. Screenshot: `relationships-help-call-detail.png`.
  - **GIVEN** a favour awaiting its call-in, then the same favour presented, **THEN** the page, the card and the
    call-in show the state, the refuse cost, that abandoning the accepted task is a slight and `favour_cost`. Screenshot: `relationships-favour-owed.png`.
  - **GIVEN** a bond verb refused because the NPC's side cannot make room, **THEN** the greyed verb says so; and
    **GIVEN** a verb that would evict the player's tie, **THEN** it names that tie. Screenshot:
    `relationships-verb-refused.png`.
  - **GIVEN** the tick evicts a player tie, or an NPC gains a feud toward the player, **THEN** a news line names the
    people involved. Screenshot: `relationships-news.png`.

## Open Questions

| # | Question | Owner | By |
|---|---|---|---|
| 1 | ~~The "richer records" for notable people: should they store how a tie formed?~~ **Answered 2026-11-21:** every soft kind, debt and blood feud stores a cause and an event-log link, for everyone (rule 1b); no separate history | user | Answered |
| 2 | Grudge gained trait against enmity tie: keep both with the no-stack rule (Formula A), or retire the targeted Grudge trait and let enmity carry it? Changes NPC Traits F3 | user, NPC Traits | Before the review |
| 3 | Values marked *(guess)*: soft and debt weights, fade rates, Δ defaults, `feud_threshold` 90, inheritance strengths, `master_cult_pct` +5, `daolu_cult_pct` +8, `help_min` 30, `help_max` 1, `mourner_max` 5, `soft_reserve` 2 / 4, `met_notable_max` 500, `favour_call_seasons` 4, `refuse_delta` 30, `favour_cost_mult` 1.0, `errands_max`, `errand_margin` 1.0, `avenger_max` and `gratitude_max` 1. Set by a balance run over FX-W5K (blood-feud share, record count) | systems-designer | Balance pass |
| 4 | A person as a Combat companion source needs a power share (Combat Formula J reads Spirit Beasts' share). Who owns it, and is it the companion's power number over the owner's? | Combat | Before building rule 15a |
| 5 | ~~Successor play~~ **Answered 2026-11-21 by Codex & Karmic Carryover (#12) rule 4:** in Continue mode the player may go on as a living child or disciple (rule 13 runs first; the heir keeps their own ties, at a karma cost by realm) or as a reborn stranger | user | Answered |
| 6 | Do NPC-to-NPC sworn siblings and đạo lữ fight for each other in Power Rankings world fights (rating rolls), or only in the player's fight events? | Power Rankings | Later |
| 7 | The `errand_cost` and `favour_cost` burns are stone sinks from the CD-GDD-ALIGN gate, not from the user's sink list (formation fuel, crafting, cave abode, fields). Keep them as fees, or route them into a listed sink? | user | Before building rule 15a |
