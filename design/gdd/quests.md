# Quests

> **Status**: Approved (design-review 2026-11-08, lean, sixth pass): no blockers, 8 recommendations open. Numbers are guesses; Event Engine, LLM GM and Dialogue contracts are provisional. See `reviews/quests-review-log.md`
> **Author**: user + agents
> **Last Updated**: 2026-11-07
> **Last Verified**: 2026-11-07
> **Implements Pillar**: Every Number Is Bounded and Visible (2); A World That Remembers (5)

## Summary

Quests are multi-season threads of two to five linked stages, offered by people, sects and town boards because of
something recorded in the world's history. They give the player a plan with a deadline and a cost in seasons, and they
pay mostly in items, access and relationships, about level with missions in money. They turn the world's stored facts
into things the player can act on, and a finished quest changes the people tied to it, while every number stays inside
an engine-set budget.

> **Quick reference** — Layer: `Presentation` · Priority: `Vertical Slice` · Key deps: `Event Engine, LLM Game Master, NPC Interaction & Dialogue, World Database`

## Overview

A quest is a thread of two to five linked stages that runs across several seasons and is held as engine state in the
World Database. Each stage is an ordinary event (Event Engine) or a mission-like action, with its checks, effects and
reward budgets validated and clamped as for any event. The engine sets the brief and owns the state. For a quest offered
by a person or sect, the LLM Game Master designs the whole quest at offer time, inside that brief, and the engine
validates the plan and then freezes it, so no number reaches the player unchecked (Pillar 2). A quest is born from a recorded fact, and it is never invented from nothing (Pillar 5): a registered person,
sect or place offers it because of something in the world's history, such as a grudge, a shortage or a death. Where no
person fits, a standing board at a sect hall or town offers a quest from a fixed list as the fallback.
A player who takes a quest commits seasons to it and can fail it or let it lapse, which makes it a plan with a cost
(Pillar 4). The reward is mostly buildable assets (items, techniques, materials), access and relationships, with only a small share in spirit stones.
In rare cases it may be a bounded permanent gain or a valuable insight, and the rarest quests can pay an item above the
realm's usual rarity cap. Every reward sits inside a quest budget derived
from the event budgets, and lasting gains have a lifetime cap, so quests are never the main source of power (Pillar 3).
An offerer only asks for what serves them, and a quest's ending reaches the people around it: their attitudes shift, a
quest can really change an NPC's fortunes, and the ending becomes a new recorded fact.
Quests are not Sects & Missions (#26): a mission stays a repeatable, stateless, one-season income action, and a quest may use one as a stage.

## Detailed Design

### Core Rules

Named values are defined in Formulas and live in `quest_rules.json`. Event Engine, LLM Game Master and NPC Interaction
& Dialogue have no GDD yet, so every contract with them is **provisional**. Rules marked **(assumption)** are the
author's reading and wait for confirmation (Open Questions).

1. **A quest is a record in the World Database.** It holds: a quest id, the `offerer` (a registered person or sect,
   or a place's board), the `source_fact` (a World DB record that justifies it), the frozen `plan` (rule 4), the
   `deadline` in seasons, the tier, the `stake`, any `adversary` and `outcomes` (rules 15–18), the state (States and
   Transitions) and the stage reached. It is saved with the world, so it needs no save
   path of its own.
2. **Where quests come from.** There are two sources:
   - **A person or sect offers it** when the world state holds a fact that fits an offer: a grudge, a shortage, a
     death, an unpaid debt. The source fact is chosen by the engine from the World DB and written on the quest.
   - **A board offers it.** A sect hall or town has a standing board (`board_size` open quests, refreshed each
     season), which the player can read whether or not a person has an offer. A board quest comes from the fixed list
     in `quest_templates.json`, with no LLM call (user decision 2026-11-06), and is always Errand or Ordinary (rule 14). It
     has no individual offerer but is still tied to a place and a recorded fact of that place.

   An offer is considered at the points where the Event Engine already looks for events (the season's random-event
   check and arrival at a place), and never more than `offers_per_season` per character per season. Board quests do
   not count against that limit, because a board is a list.
3. **The engine sets the brief; the LLM designs the quest (user decision 2026-11-06).** For each person or sect offer
   the engine builds a brief: the offerer and source fact, the player's realm band, the stage count range `stages_min`
   to `stages_max`, the allowed stage kinds (rule 5), the deadline range, the budget rates and caps (Formulas A), the offerer's stake,
   the possible adversaries and the world effect limits (rules 15–17).
   The brief cannot hold B itself, because B depends on the stages the LLM returns. The LLM returns the whole quest at
   once: every stage, with its text, its checks and its effects, and the reward plan.
4. **The plan is validated, then frozen.** The validator checks every stage as an event would be checked (the
   `events_budgets` limits: allowed check stats, effect types and per-realm maxima), checks the whole plan against the
   quest budget (Formulas A) and checks the stage graph (rule 5). A plan that fails once is repaired by the LLM at
   most `repair_tries` times with the validator's reasons, and then replaced by an ordinary **template quest** from
   the fixed list for that place type (`quest_templates.json`), so a failed
   Major or Legendary plan drops to Ordinary. **Templates use only the stage kinds `event`, `visit`, `deliver`, `craft`
   and `mission` (design-review 2026-11-07).** `defeat` and `reach` depend on the player's power and progress at the
   offer, which a load-time check cannot see, so a template holding either is rejected at load. A template that
   passes the load check against the realm bounds passes the validator at the offer too, with two exceptions. The load check
   assumes `travel_seasons` at `template_travel_max` (4, a guess, in `quest_rules.json`), so a trip longer than that can push
   `window_sum` over `deadline_max`. And rule 15's person-offer test can fail. In either case a failing fallback makes no
   offer, and a board omits it (design-review 2026-11-07). A plan over any limit is rejected, not trimmed: the event clamp at payment stays as
   the last guard and should never bite on a validated plan. Once offered, the plan
   never changes: nothing is regenerated in a later season, so a reload after the offer gives the same quest. The LLM may still narrate
   a stage when it begins, but the stage's checks, effects and numbers are the frozen ones.
5. **Stages.** A quest has `stages_min` to `stages_max` stages by tier (rule 14), taken in order. Each stage has one
   kind from a closed list, a place if it needs one, a season window and an effect set:

   | Stage kind | The player must | Completed when |
   |---|---|---|
   | `event` | Meet a scripted scene (an Event Engine event at the named place or person) and make its choice | The event resolves with any outcome the plan lists as passing |
   | `visit` | Reach a place, or meet a person. Needs no action | Arrival (Travel & Map) or a conversation (Dialogue) |
   | `deliver` | Hand over a stated item or amount (an item class and quality floor, or spirit stones), priced at most `deliver_share` of B | The goods are handed over; they leave the inventory |
   | `craft` | Make an item of a class and a quality floor inside the realm's Item Database bounds (a pill, an artifact, a talisman, a formation) | Crafted after the quest was accepted, and in the inventory |
   | `mission` | Spend one or more seasons on a mission (Sects & Missions) | The seasons are spent |
   | `reach` | Reach a realm or level, or a stat threshold. Needs no action | The threshold is met at a season end |
   | `defeat` | Win a Combat fight against a named opponent (**provisional**; waits on the full fight) | A knockout win; a kill only where the plan lists `death` (rule 17) |

   A stage names no number outside the budget. Three limits keep stages honest (user decision 2026-11-06):
   - **A `mission` stage pays no mission income.** Its seasons earn the quest budget only.
   - **`visit` and `reach` stages add no seasons to the budget** (Formulas A), because the player meets them by normal
     play, and `travel_seasons` already pays for a trip. A plan holds at most one `reach` stage and at least one stage
     that costs a season. The validator rejects a `reach` already met at the offer, or one the player cannot meet
     inside its window at their current rate (Realms' estimate, **provisional**).
   - **A `defeat` stage is bounded by the fight ratio** (Formulas B), checked at the offer and again when the stage
     begins. Only a player Down fails the stage. A draw, a stalemate or a flight leaves it open for a later season.

   **A stage's target can be lost (user decision 2026-11-06, design-review re-review).** A stage that names a person (a
   `visit` meeting, a `defeat` opponent, a `deliver` recipient) has a **target**. The target is lost when that person
   dies or the sect they were named for is gone. Each such stage carries `if_target_lost`, one value from a closed list,
   chosen by the LLM when it designs the plan and frozen with it (not decided during play, so a reload gives the same
   outcome). Templates set it too. The default, used when a plan omits it, is `orphan`:

   | `if_target_lost` | When the target is lost | Allowed on |
   |---|---|---|
   | `orphan` (default) | The quest is Orphaned at once (rule 10) and the current stage becomes the last. If the lost target belongs to the current stage, the quest is Dropped instead (the paragraph below) | Any stage |
   | `skip` | When that stage begins (or at once, if it is current) it completes with no stage pay, and the quest goes on. The skipped stage's pay is never paid and does not move to the final stage, whose pay is unchanged (B is a ceiling) | Any stage but the last. The validator rejects it on the last stage |
   | `drop` | The quest is Dropped at once with no penalty. Stage pay already paid stays | Any stage |

   If the lost target belongs to the **current** stage and the clause is `orphan`, that stage can no longer be finished, so the quest is Dropped at once with no penalty, as if by `drop`. A target killed by the
   player, their party or their sect is different: the quest is **Failed** (rule 10), whatever the clause says, except a
   `defeat` stage whose plan allows a kill, where the kill completes the stage. A named unique item destroyed by anyone
   is covered by rule 10 (Failed) and is not a target.
6. **Seeing a quest before taking it (assumption).** The offer shows: the offerer, the source fact, the stage count,
   the deadline, the reward budget as a Breakdown (kinds and bounds, Pillar 2), the adversary and world effects, and the
   first stage in full. Later
   stages are shown as their kind and place only, and are revealed in full when reached. Every check shows its chance
   when its stage begins (Event Engine), so no roll is hidden.
7. **Taking and leaving.** The player may hold `active_cap` quests (3, a guess). Accepting is free and takes a slot.
   A person's offer is Declined if the player refuses it or `offer_seasons` seasons pass, and that source fact is not
   offered again for `reoffer_cooldown` seasons (Formulas C). A board quest stays until the board replaces it, and
   reading it or leaving the place starts no cooldown. **What an ending does to the source fact (design-review 2026-11-06):** a Completed quest spends its fact (for a board quest, the fact of its place: the template is not offered at that place again until the fact changes, design-review 2026-11-07), which is recorded in the World DB and never offered again; Declined, Lapsed, Orphaned and Dropped put it on the 8-season cooldown, Failed on the 16-season one, and Withdrawn on none (the offerer is gone). The player may **abandon** an
   active quest at any time: it fails by rule 10 with no extra penalty beyond that rule.
8. **Time.** Progress is checked at the end of each season (Time & Turn). Each stage has a season window, and the
   windows plus slack size the quest's `deadline` (Formulas C), counted in season ends from acceptance. Windows only
   size the deadline: the deadline alone ends a quest, so a stage may run past its own window. Every stage but `visit`
   and `reach` consumes the season's action like any action (Pillar 4), so a quest never makes time free. A quest does
   not pause the lifespan clock. Within one season end the order is: stages resolve, then orphaning (offerer, sect,
   place or stage target lost), then the deadline. A quest orphaned at the deadline's own season end therefore ends
   that season as Dropped, never Lapsed.
9. **Rewards are paid by stage and at the end.** Each stage but the last pays a small reward when completed, in
   proportion to the seasons it costs (Formulas A, user decision 2026-11-06), and the final stage pays the rest, so
   effort before a failure is not all lost. B is a ceiling: a plan's rewards may total less, never more. Each stage's pay, and the final pay, is likewise a maximum: a stage that pays less leaves the difference unpaid, and it never moves to the final stage. At most
   `quest_cash_share` of B may be spirit stones, and the rest must be items (user decision 2026-11-06). All effects use the Event Engine's effect types and its clamp: the engine validates, clamps and records
   every amount in the World DB. A non-final stage pays at most `max_effects_per_outcome` effects (3), and the final stage pays
   at most `quest_final_effects_max` (6), because it carries the rest of B and any rare reward. Every reward line paid to the player counts as one effect, including relationship, access, `tu_vi` and each rare reward, and a multi-key `quest_boon` is one line (user decision 2026-11-07). `outcomes` entries do not count: they have their own cap (rule 17). B is a ceiling, so a plan that wants more lines picks its best ones. `quest_boon`, `recipe` and `access` are not event effect types today, and the Event
   Engine must add them (**provisional**). Three kinds of reward are normal: **items** (herbs, materials, pills, artifacts,
   talismans, techniques), **access** (a sect's favour, an unsealed place, an introduction) and **relationships**.
   Three are rare (rules 11 and 14): a **lasting gain**, an **insight or recipe**, and an **above-cap item**.
10. **Failing, lapsing and orphaning.** A quest ends one of these ways:
    - **Completed**: all stages done in time.
    - **Failed**: the player abandons it, a `defeat` stage is lost, a required item is gone for good, or the player,
      their party or their sect kills a stage's target (rule 5). The offerer's
      relationship drops by `fail_relationship` (bounded) if the offerer is a person or a sect's speaking member (rule 16; a board has no offerer), their ties react (rule 16), and
      paid stage rewards stay.
    - **Lapsed**: the deadline passes. The same cost as failed, with half the relationship loss.
    - **Orphaned**: the offerer dies, or the sect is gone, or a named place no longer exists, or a stage's target is
      lost with `if_target_lost` `orphan` (rule 5), before the quest is complete. It is **not** a failure. If the lost place or target belongs to the current stage, the quest is Dropped at once with no penalty (rule 5). Otherwise the current stage becomes the last, and the player may finish it for
      `floor(orphan_reward_share · unpaid · s' / S')`, where `unpaid` is the planned pay of the current stage and every later stage (the final pay included, a skipped stage's pay excluded), `s'` is the current stage's `s_i` (at least 1) and `S'` is the
      seasons of the original plan from the current stage to its end (at least `s'`), so a quest cut short never pays more
      per season than a finished one. It is paid from the dead offerer's estate (their `linh_thach` in the World DB at death, a new rule for Living World, **provisional**) or the sect (if the offerer is alive because a stage target was lost, the offerer pays; a board quest is paid by the board's sect or town), with no relationship
      penalty. An orphaned quest keeps its slot and its deadline. Dropping it, or reaching the deadline, ends it as
      Dropped with no penalty, and if no estate or sect remains to pay, it is Dropped at once. An orphaned quest never
      pays a lasting gain or an above-cap item. A death
      caused by the player, their party or their sect is **Failed**, not Orphaned (user decision 2026-11-06), so
      killing the offerer is never a shortcut.

    An orphaned quest whose deadline falls in the same season end is Dropped at that season end (the order is in rule 8), with no penalty.
    Every ending is recorded in the World DB with the stages done, the seasons spent and the rewards paid.
11. **The rare rewards (user decision 2026-11-06).** A quest may pay, rarely, one **lasting gain** (a permanent stat
    line within a W budget, held as the sheet modifier source `quest_boon` in Character Stats, or meridian tree
    points) or a **valuable insight or recipe**. Only Major and Legendary quests (rule 14) may pay these. At most one lasting gain per
    quest, and the character's total lasting gains from quests are capped (Formulas D) so quests can never become the
    main source of power (Pillar 3). The cap is applied again at payment, because two frozen plans can both expect the
    same room. **An insight** is the Nascent Soul breakthrough insight (Realms rule 7), the requirement for Deity Transformation. It is not
    charged to B, a quest pays at most one, and the validator allows it only for a player in Nascent Soul who holds none, so
    it always does something. **A recipe is deferred (user decision 2026-11-07):** the validator rejects it until Alchemy
    has recipe knowledge to learn (Open Question 11).
12. **Randomness.** The offer, the choice of source fact, the brief and the template fallback use one seeded stream
    derived from the world seed, character id, season and offer index. Stage checks use the Event Engine's own stream.
    The same save always gives the same brief. The LLM is not deterministic, so its plan is only fixed once stored:
    every save after the offer holds the same plan, and a reload to before the offer may return a different plan for
    the same brief. Board quests use no LLM, so they are always the same.
13. **Anything new must be registered first (Pillar 5).** If the LLM's plan names a person, a place, an item or a
    sect that is not in the World DB, the validator rejects the plan unless the Event Engine's rule for creating a
    new entity allows it (provisional), in which case the entity is registered before the quest is offered.
14. **Quest tiers (user decision 2026-11-06).** Every quest has one of four tiers, drawn at the offer with `tier_share`
    and shown on it. All values are guesses:

    | Tier | Share of person and sect offers | Stages | `quest_reward_mult` | `cap_mult` | `quest_fight_ratio_max` | `deadline_max` | Rare rewards |
    |---|---|---|---|---|---|---|---|
    | Errand (tạp vụ) | 45 % | 2–3 | 1.25 | 0.5 | 0.20 | 12 | None |
    | Ordinary | 45 % | 2–5 | 1.5 | 1.0 | 0.35 | 20 | None |
    | Major | 8 % | 4–5 | 2.0 | 2.0 | 0.60 | 32 | Lasting gain, insight or recipe |
    | Legendary (truyền kỳ) | 2 % | 5 | 2.5 | 3.0 | 0.80 | 40 | As Major, plus one above-cap item |

    Boards offer Errand and Ordinary quests only. Legendary quests exist from `legendary_min_realm` (Core Formation): a
    Legendary drawn below it becomes Major. A Legendary quest may pay **one above-cap item**, up to
    `legendary_rarity_bonus` (1) above the realm's rarity cap, which reaches `rarity_max` 6 from Core Formation. The
    item must still fit inside B at its price. There is no limit per life (user decision 2026-11-06). The Event Engine's
    clamp at payment must honour this one exception (**provisional**).
15. **An offer must serve the offerer (user decision 2026-11-07).** A person or sect offer needs all three:
    - **A stake:** the offerer, their sect or one of their direct ties (rule 16) is named in the source fact. The plan
      records how the quest serves them as its `stake`.
    - **A benefit (design-review 2026-11-07):** the plan's `outcomes` (rule 18) hold at least one `completed` entry that
      gains something for the offerer's side (`offerer`, `offerer_ties` or `offerer_sect`), and no `completed` entry
      harms that side. This is a structured test the validator can run. `stake` is display text only and is not
      validated. **Templates:** every template tagged for person or sect offers must carry such an entry, or it is
      rejected at load. If a fallback template for a person offer still fails this rule (for instance no role resolves),
      no offer is made that season.
    - **No hostility:** the attitude of the NPC making the offer is above `hostile_threshold`. A sect's offer always
      comes through a member, whose attitude is the one read and who is the quest's root (rule 16). It is read at the offer only, so a later fall does not end
      an accepted quest.

    Boards have no offerer, so this rule does not apply to them. A board quest has no `adversary` of its own, and its effects follow rule 18.
16. **Related NPCs react (user decision 2026-11-07).** A plan may name one `adversary`, a registered person or sect that
    the quest acts against, and never the player. This adversary (đối thủ) is separate from a stage's target (rule 5), though one person can be both. Each side has a root (the offerer, the adversary) and its **direct ties**:
    the root's master, their disciples and the head of their sect. Only the head speaks for a sect, so a quest never
    shifts a whole sect's members. Ties are read at the ending, and only the living react. Each reacts once, by Formulas
    E. NPC-to-NPC relationships are not tracked, so what changes is each NPC's attitude to the player.

    **Sect roots (design-review 2026-11-07).** A root is always a person. When the offerer is a sect, the root is the
    **speaking member**, the member whose attitude rule 15 reads. `offerer` resolves to that member, `offerer_ties` to
    their master and disciples, and `offerer_sect` to their sect. The fail relationship loss (rule 10) and Formulas E run
    on that member like on any person offerer. When the adversary is a sect, the root is its **head**: `adversary`
    resolves to the head, `adversary_ties` to the head's master and disciples, and `adversary_sect` to the sect. The head
    takes the `adversary` effects, and `rank` and `death` obey rule 17 as for any person. A board has no root (rule 18).
17. **Quests change the world (user decision 2026-11-07).** The changes a quest makes to NPCs and sects are the entries
    of its `outcomes` list (rule 18), the one format for them (design-review 2026-11-07). Each entry's effect comes from
    a closed list, and rule 17 owns that list and its limits. Entries are shown at the offer and apply at the ending each
    one names, except `death`:

    | Effect | Lowest tier | Limit |
    |---|---|---|
    | `wealth` | Errand | An NPC gains or loses spirit stones, at most `world_wealth_share` of B |
    | `standing` | Errand | A sect's `sect_standing` moves by up to `world_standing_max`. This is a new sect field (**provisional**) |
    | `injury` | Ordinary | An NPC loses up to `world_injury_max` of its vitality |
    | `rank` | Major | An NPC's `sect_rank` moves one step. A sect head's rank never moves, and nobody becomes head this way |
    | `death` | Major | Only the adversary, and only by the player's knockout in a `defeat` stage. This entry is what allows that stage's kill, so below Major a `defeat` cannot kill |

    **`death` lands at the knockout (design-review 2026-11-07).** It is the one effect that is not held to an ending:
    when the player wins the `defeat` stage by knockout, the adversary dies at once, the ties' reaction (Formulas E) is
    applied then, and it stands whatever happens to the quest afterwards (Failed, Lapsed, abandoned or Dropped). A `death`
    entry is written with `on: completed`, because it is allowed only where the quest is meant to end that way, but its
    timing is the knockout. **The player cannot spare the adversary (design-review 2026-11-07):** with `death` in the plan, any knockout win kills, and a plan without it cannot kill (rule 5). Sparing is a design choice for later (Combat). The adversary's killer is the player, and rule 5's Failed-on-kill does not apply (the stage
    allows it).

    A plan holds at most `world_effects_max` entries for each ending (`death` counts under `completed`), across all
    roles. The player is never affected. An effect on a dead NPC is skipped. The `wealth` limit applies to each entry,
    and the `offerer_ties` split is one entry. These write fields the Living World owns (**provisional**).

    Every ending is logged as a new World DB event naming the people involved, and the source fact follows rule 7. The
    new event can source later offers from anyone who passes rule 15. An NPC turned hostile cannot offer the player a
    quest, so their grudge reaches play through the Event Engine's hostile events (**provisional**).
18. **The quest format (user decision 2026-11-07).** Every quest, whether an LLM plan or an entry in
    `quest_templates.json`, may carry an optional `outcomes` list of rewards and penalties for NPCs, sects and direct
    ties. Each entry names an ending, a role, an effect and an amount. Roles let a template work without naming anyone:

    | Role | Resolves to | Effects allowed |
    |---|---|---|
    | `offerer`, `adversary` | That person | `wealth`, `injury`, `rank`; `death` on `adversary` only |
    | `offerer_ties`, `adversary_ties` | That root's master and disciples | `wealth`, split evenly and rounded down; `injury`, at `tie_share` of the amount for each |
    | `offerer_sect`, `adversary_sect` | That root's sect | `standing` |

    | `on` | Applies when | Allowed direction |
    |---|---|---|
    | `completed` | Completed, or a finished Orphaned quest (a `death` entry lands at the knockout instead, rule 17) | Gains for the offerer's side, losses for the adversary's |
    | `failed` | Failed or Lapsed | Losses for the offerer's side, gains for the adversary's. Never `death` |

    Dropped, Declined and Withdrawn apply nothing, and abandoning during stage 1 applies no `failed` outcomes, so a quest
    cannot be taken only to harm its offerer. `amount_share` is a share of B (so 0.3 on FX-PLAN is 18); `amount` is an
    absolute number, and a negative value is a loss. **Which field each effect uses (design-review 2026-11-07):** `wealth` takes `amount_share` or `amount` in spirit stones; `injury` takes `amount` as a share of vitality (0.4 is 40 %); `standing` takes `amount` as points; `rank` and `death` take neither and move one step or kill. An entry that gives a field its effect does not use is rejected. Roles resolve at the offer. On a board, `offerer` is the head of the sect
    that owns the place and `offerer_sect` is that sect, but only as targets of `outcomes` entries: a board quest moves
    nobody's attitude (Formulas E does not run for it, user decision 2026-11-07), and it cannot pay a relationship reward
    with that head. An `adversary` role needs a second party named in the source
    fact. An entry whose role does not resolve is dropped and not shown. Every resolved entry is shown at the offer and
    obeys rule 17's limits. For example:

    ```json
    "outcomes": [
      {"on": "completed", "role": "offerer", "effect": "wealth", "amount_share": 0.3},
      {"on": "completed", "role": "offerer_sect", "effect": "standing", "amount": 5},
      {"on": "failed", "role": "offerer_ties", "effect": "wealth", "amount_share": -0.2}
    ]
    ```

### States and Transitions

| State | Entered when | Leaves when |
|---|---|---|
| Offered | An offer passes validation (or the template fallback does) | The player accepts or refuses, the offer times out, or the offerer, sect or a named place is lost |
| Active | The player accepts and has a free slot | The last stage is done, or it fails, lapses or is orphaned |
| Stage k | Stage k-1 is done (or the quest was accepted, for stage 1) | Stage k's condition is met, or the deadline passes |
| Completed | The last stage is done in time | Terminal (the final reward is paid; the source fact is spent) |
| Failed | The player abandons, loses a `defeat`, or loses a required item | Terminal |
| Lapsed | The deadline passes with stages left | Terminal |
| Orphaned | The offerer, sect or place is gone, or a stage target is lost with `orphan` | The player finishes the last stage (then Completed), or it is Dropped |
| Dropped | The player drops an orphaned quest, its deadline passes, nobody remains to pay, the current stage's place or target is lost, or a stage target is lost with `drop` | Terminal; no penalty |
| Declined | The player refuses a person's offer, or `offer_seasons` pass | Terminal; the source fact is on cooldown |
| Withdrawn | The offerer dies, or the sect or a named place is gone, while the quest is only Offered | Terminal; no cooldown, no penalty |

| Transition | Condition | Effect |
|---|---|---|
| Offered to Active | Accept with a free slot | Slot taken; stage 1 begins |
| Offered to Declined | The player refuses, or `offer_seasons` pass | Cooldown on the source fact |
| Offered to Withdrawn | The offerer dies, or the sect or a named place is gone | None |
| Stage k to Stage k+1 | Stage condition met before the deadline | Stage reward paid (rule 9) |
| Last stage to Completed | Condition met within the deadline | Final reward; source fact spent; World DB record |
| Active to Failed | Abandon, lost `defeat`, goods gone, a stage target killed by the player, party or sect | Rule 10 penalty; World DB record |
| Active to Lapsed | Season end past the deadline | Rule 10 half penalty; World DB record |
| Active to Orphaned | Offerer, sect or place gone, or a stage target lost with `orphan` (not the current stage's place or target: that is Dropped) | Reduced last stage offered |
| Active to Dropped | The current stage's place or target is lost (`orphan` or `drop`), or any stage target is lost with `drop` | No penalty; World DB record |
| Orphaned to Completed | The last stage is finished before the deadline | The reduced reward; World DB record |
| Orphaned to Dropped | The player drops it, the deadline passes, or nobody remains to pay | No penalty; World DB record |

### Interactions with Other Systems

Event Engine, LLM Game Master and NPC Interaction & Dialogue have no GDD yet. Rows marked **provisional** hold the
contract this GDD expects.

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| Event Engine (#23) | in / out | Out: the brief, the stage events, the budgets. In: the validated stage, the check result and its Breakdown (**provisional**) | Event Engine (events, budgets, validator, resolver); this GDD (the quest plan and its quest budget) |
| LLM Game Master (#29) | out / in | Person and sect offers only. Out: the brief. In: the whole quest plan, repaired on a failed validation (**provisional**) | LLM Game Master (the provider); this GDD (the brief and the repair limit) |
| NPC Interaction & Dialogue (#30) | out / in | Out: the offer and the stage talk. In: a conversation completes a `visit` (**provisional**) | Dialogue |
| World Database (#3) | in / out | In: source facts, people, places, sects. Out: the quest record and its endings | World DB |
| Time & Turn (#4) | in | The season end that checks progress and deadlines | Time & Turn |
| Sects & Missions (#26) | in | The mission action as a `mission` stage, with its income withheld; the sect's board place; the base income that sizes the quest budget | Sects & Missions |
| Character Stats (#7) | out | The `quest_boon` sheet line for a lasting gain; stat checks | Character Stats (keys); this GDD (the gain) |
| Item Database (#13) | in / out | Item classes, rarity bounds, recipe and technique items; the reward items | Item Database |
| Living World Tick (#28) | out | World effects on NPC wealth, vitality, rank and life (**provisional**) | Living World |
| Realms & Bottlenecks (#8) | in | The player's realm band, which sets the budget; a `reach` stage and its time estimate (**provisional**) | Realms |
| Combat (#21) | out / in | A `defeat` stage opens a fight and reads the result (**provisional**; the full fight is on hold) | Combat |
| Travel & Map (#25) | in | Places, travel and arrival for `visit` | Travel & Map |
| Save/Load (#5) | in | The quest record is saved with the World DB | Save/Load |
| Debug Terminal (#36), Game UI (#37) | out | The journal, the offer, the stage and the ending | the presentation system |

## Formulas

All values are guesses until the Balance Harness measures quests against missions (Open Question 3). `systems-designer`
proposed them; the main session corrected the tree point price, the fight ratio and the `reach` budget rule against
the source GDDs.

Value is measured in spirit stones. `E_r` is the realm's `linh_thach_max` in `events_budgets.json` and `I_r` is one
season of base sect mission income (`sect_base_income` × `income_realm_scale`, before build multipliers):

| Realm | Qi Refining | Foundation Establishment | Core Formation | Nascent Soul | Deity Transformation |
|---|---|---|---|---|---|
| `I_r` | 10 | 80 | 600 | 4,000 | 30,000 |
| `E_r` | 80 | 600 | 5,000 | 40,000 | 300,000 |

### A. Quest reward budget

The quest_budget formula is defined as:

`S_plan = Σ s_i + travel_seasons` ; `B = floor(min(quest_reward_mult · I_r · S_plan, cap_mult · E_r))` ; `stage_pay_i = floor(stage_reward_share · B · s_i / S_plan)` for every stage but the last ; `final_pay = B − Σ stage_pay_i` ; `cash ≤ floor(quest_cash_share · B)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| I_r, E_r | int | table above | calculated; data file | Income and event ceiling at the offer realm |
| s_i | int | 0–4 | data file (by stage kind) | Seasons a stage costs: `event`, `deliver`, `defeat` 1; `craft` 2; `mission` its stated 1–4; `visit`, `reach` 0 |
| travel_seasons | int | 0+ | calculated (Travel & Map, **provisional**) | Shortest travel between the stage places, from the offer place |
| S_plan | int | ≥ 1 | calculated | Minimum seasons the plan costs. Rule 5 requires a stage that costs a season, so it is never 0 |
| n | int | 2–5 | LLM, validated | Stage count |
| quest_reward_mult | float | 1.25 / 1.5 / 2.0 / 2.5 by tier | data file | Budget per season, in units of `I_r` |
| cap_mult | float | 0.5 / 1.0 / 2.0 / 3.0 by tier | data file | Hard cap on B, in units of `E_r` |
| stage_reward_share | float | 0.2–0.4, default 0.30 | data file | Share of B paid across the stages before the last |
| quest_cash_share | float | 0–1, default 0.2 (user decision 2026-11-06) | data file | Most of B that may be spirit stones |
| deliver_share | float | 0–1, default 0.5 | data file | Most of B a `deliver` stage may ask for, at price |
| B | int | ≥ 1 | calculated | The quest budget, a ceiling. Items count at their Item Database price |

Relationship, access, `tu_vi`, insights and lasting gains are not charged to B and have their own limits (an insight's is rule 11): a quest's total
relationship stays inside the event budget's `relationship_max`, and lasting gains follow Formulas D. A quest's total `tu_vi` is at most
`quest_tu_vi_share` (0.5) of the realm's `tu_vi_pct_max`, so quests are not a cultivation source. Every effect still
passes the event clamps and its stage's effect cap (rule 9), so a large B needs several effects.

**Output Range:** B runs from 1.25 · `I_r` (an Errand at S_plan 1) to 3 · `E_r` (a Legendary quest at its cap). `final_pay` takes the
rounding, so the budget split always sums to exactly B. The B cap uses the raw `E_r`, whatever a single effect's clamp
allows.

**Value check.** Items sell at 0.6 of price. With 20 % of B in stones and 80 % in items, a quest pays at most
`quest_reward_mult` · (0.2 + 0.8 · 0.6) = 0.68 · `quest_reward_mult` of `I_r` per season if everything is sold:

| Tier | Errand | Ordinary | Major | Legendary |
|---|---|---|---|---|
| Sold value per season | 0.85 `I_r` | 1.02 `I_r` | 1.36 `I_r` | 1.70 `I_r` |
| Most stage pay per season | 0.375 `I_r` | 0.45 `I_r` | 0.60 `I_r` | 0.75 `I_r` |

An Errand pays a little below missions in money, an Ordinary quest about level, and the two rare tiers above them. The
edge of a low-tier quest is the items themselves, access and relationships. At the default `stage_reward_share` 0.30, stage pay is below mission income (0.375 to 0.75 `I_r` per season at face value). At the 0.4 limit, Legendary face value reaches 1.0 `I_r`, and 0.68 once sold,
so taking a quest only for its stage pay and abandoning always loses to missions. The value check is gross: a `deliver` stage hands over goods worth up to `deliver_share` of B and a `craft` stage costs materials, so the net is lower. Gains from an `outcomes` `wealth` entry are not drawn from anywhere: an NPC's `wealth` rises as a World DB write with no source, up to `world_wealth_share` of B, which is small against the economy (Open Question 9).

**Examples:**
- Qi Refining ordinary, `event`, `craft`, `deliver`, no travel: S_plan 4, B = min(60, 80) = **60**. Stages pay 4 and 9, the last pays **47**, and at most 12 of the 60 may be stones.
- The same quest at Deity Transformation: B = min(180,000, 300,000) = **180,000**. Stages pay 13,500 and 27,000, the last pays **139,500**.
- Qi Refining major, n 5, S_plan 8: B = min(160, 160) = **160**, exactly at the cap.

### B. Fight ratio

The fight_ratio formula is defined as:

`r = F_opp / F_player`, accepted when `quest_fight_ratio_min ≤ r ≤ quest_fight_ratio_max`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| F_opp, F_player | float | > 0 | calculated (Combat Formulas K) | Fight power F = Off × ehp, the player's at current vitality |
| quest_fight_ratio_max | float | 0.20 / 0.35 / 0.60 / 0.80 by tier (user decision 2026-11-06) | data file | Ceiling on r |
| quest_fight_ratio_min | float | 0.02 | data file | Floor at the offer, so a `defeat` is a real fight |
| stage_hold | int | 0–8, default 4 | data file | Most seasons a stage may wait, off the deadline, for r to fall back under the ceiling |

By Heavenly Tribulation's estimate r is about the share of the player's effective health the fight costs. It is an
estimate, not a win chance: it ignores threat kinds, so a build with no answer can still lose at a low r, and no GDD
maps r to a win chance yet (Open Question 4).

**Output Range:** 0.02 up to the tier's ceiling, at most 0.80. If the player grows after the offer, r may fall below the floor
and the stage stays valid. If r is over the ceiling when the stage begins (an injured player), the stage holds for up
to `stage_hold` seasons, and those seasons do not count against the deadline. After that the fight is open at the
player's own risk.

**Example:** `F_player` 1.41e7 (typical Nascent Soul) against Off 400, ehp 8,000: F 3.2e6, **r 0.227**, accepted. Off 400,
ehp 14,100 gives **r 0.40**, rejected for an ordinary quest and accepted for a major one.

### C. Deadline and offers

The quest_deadline formula is defined as:

`window_sum = Σ w_i + travel_seasons` ; `deadline = min(ceil(window_sum · (1 + slack)), deadline_max)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| w_i | int | `s_i` (at least 1) to 12 | plan, validated (design-review 2026-11-06) | Stage window, set by the plan. A window below the stage's own `s_i` or above 12 is rejected. Defaults for templates and briefs: `event`, `visit`, `deliver`, `defeat` 2; `craft` 3; `mission` its stated seasons; `reach` up to 12 |
| slack | float | 0.3–1.0, default 0.5 | data file | Spare time over the windows |
| deadline_max | int | 12 / 20 / 32 / 40 by tier | data file | Ceiling in seasons. The validator rejects a plan whose `window_sum` is above it |

**Output Range:** 3 to 12 seasons Errand, 3 to 20 Ordinary, 6 to 32 Major, 8 to 40 Legendary. 20 seasons is 5 years, about 4 % of the 120-year Qi Refining
lifespan.

A `defeat` hold (Formulas B) moves the deadline later by the seasons held, up to `stage_hold` per `defeat` stage. `deadline_max` bounds the deadline at the offer, not the moved one.

**Examples:** windows 2 and 2 give **6**. Windows 2, 2, 3, 2, 2 give ceil(16.5) = **17**.

Offer values, all in `quest_rules.json`:

| Value | Default | Meaning |
|---|---|---|
| `stages_min`, `stages_max` | 2, 3 / 2, 5 / 4, 5 / 5, 5 by tier | Stage count |
| `active_cap` | 3 | Quests held at once |
| `offer_seasons` | 4 | Seasons a person's offer stays open |
| `reoffer_cooldown` | 8 after Declined, Lapsed, Orphaned or Dropped; 16 after Failed; a Completed fact is spent and never re-offered | Seasons before a source fact can be offered again |
| `offers_per_season` | 1 | Person or sect offers per character per season |
| `board_size` | 3 | Open quests per board; the oldest is replaced each season |
| `repair_tries` | 2 | LLM repairs before the template fallback |
| `quest_final_effects_max` | 6 (a guess) | Most reward effects the final stage may pay. Every other stage keeps the Event Engine's `max_effects_per_outcome` (3). All other clamps still apply (design-review 2026-11-06) |

### D. Lasting gains and endings

The quest_gain_cap formula is defined as:

`gain_w = Σ (amount_key · W_key) + tree_points · tree_point_w` ; `gain_w ≤ min(quest_boon_w, quest_gain_cap_w − quest_gain_total_w)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| amount_key, W_key | float | ≥ 0; > 0 | LLM, validated; data file (`stat_power_weights`) | A stat key's amount and W price |
| tree_points | int | 0 up to the realm's `tree_point_max` | LLM, validated | Meridian tree points paid |
| tree_point_w | float | 2.07 | data file (Meridian Map `w̄_target`) | W price of a tree point |
| quest_boon_w | float | 4–12, default 8 | data file | Most W in one lasting gain |
| quest_gain_cap_w | float | 24–60, default 48 | data file | Lifetime W from quests, about 4 % of the 1,172 W a full tree holds at Deity Transformation |
| quest_gain_total_w | float | 0 to the cap | calculated | W already gained from quests this life |
| quest_tree_point_cap | int | default 3 | data file | Tree points from quests per life |
| tier_share | float | 0.45 / 0.45 / 0.08 / 0.02 by tier, summing to 1 | data file | Chance a person or sect offer has each tier |
| legendary_rarity_bonus | int | 0–1, default 1 | data file | Ranks above the realm's rarity cap for a Legendary quest's one item |
| legendary_min_realm | string | default Core Formation | data file | Lowest realm with Legendary quests. Below it the budget cannot hold a top item |
| orphan_reward_share | float | 0–1, default 0.5 | data file | Share of the unpaid reward an orphaned quest pays, scaled by `s' / S'` (rule 10). Example: Qi Refining Major, B 160, orphaned in stage 1 (a 2-season `craft`, plan seasons 8): floor(0.5 · 160 · 2 / 8) = **20**, 10 a season |
| fail_relationship | int | −15 failed, −8 lapsed | data file | Relationship change with a person offerer |

**Output Range:** `gain_w` 0 to 8 per quest, and 0 to 48 per life, so at most 6 full-size gains. With the tribulation's
60 W a character's one-off gains total about 9 % of a full tree. If the room left at payment is below the gain, a stat
gain shrinks to fit, and tree points pay only the whole points that fit. At 0 the quest pays no lasting gain, and
an offer made then says so. On a long life the cap binds: at one quest per 8 seasons and a 0.10 share of
Major and Legendary, a 2,000-year life sees about 100 such quests, so the cap, not the chance, bounds this source.
Above-cap items have no such cap: that life would see about 20 Legendary quests, so `tier_share` and the supply of
top items are what bound them.

A `fail_relationship` loss, and the ripple it sends to ties, never moves a person below `hostile_threshold` + 1 (−29,
Sects & Missions data) and never raises them, so failing a quest alone cannot make an enemy. Acting against a target can
(Formulas E).

**Examples:** a gain of +8 `attack_pct` costs **8 W**. Three tree points cost **6.21 W**. With 44 W already gained, a gain
shrinks to **4 W**. A failure at relationship 0 gives −15; a second gives **−29**, not −30.

### E. Reactions

The quest_reaction formula is defined as:

`d_adversary = −min(Σ severity_e, adversary_attitude_max)` ; `d_tie = trunc(d_root · tie_share)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| severity_e | int | wealth 5, standing 5, injury 10, rank 15, death 30 | data file | Attitude weight of each `completed` loss on the adversary's side |
| adversary_attitude_max | int | default 30 | data file | Most an adversary's attitude can fall from one quest |
| d_root | int | −30 to 30 | calculated | The root's own change: the plan's relationship reward on Completed, `fail_relationship` on Failed or Lapsed, `d_adversary` for the adversary. A killed root counts as −30 for its ties |
| tie_share | float | master or disciple 0.5, sect head 0.25 | data file | Share of the root's change a tie feels |
| d_tie | int | −15 to 15 | calculated | A tie's change, rounded toward 0 |
| world_effects_max | int | 1 / 1 / 3 / 3 by tier (Major raised from 2, design-review 2026-11-07) | data file | `outcomes` entries per ending in a plan (rule 17). Rule 15 uses one `completed` entry for the offerer's gain, so Errand and Ordinary have no room to harm an adversary on completion, and Major and Legendary have two |
| world_wealth_share | float | 0–1, default 0.5 | data file | Most of B one `wealth` effect may move |
| world_injury_max | float | 0–1, default 0.4 | data file | Most vitality an `injury` may take |
| world_standing_max | int | 0–20, default 10 | data file | Most one `standing` effect may move a sect |
| sect_standing | int | −100 to 100, starts at 0 | calculated (World DB, new field) | A sect's standing. Nothing reads it yet (Open Question 10) |

**Output Range:** attitude stays within `relationship_min` and `relationship_max` (−100 to 100). A tie with two roles on one
side reacts only by the larger share. An NPC on both sides takes both changes, the offerer's side first. Failed and Lapsed
move only the offerer's side, and Dropped moves nobody. A board quest moves nobody at any ending (rule 18). An Orphaned quest that is finished counts as Completed, with the
dead skipped.

**Examples:** a Completed Major quest with an offerer gain and `wealth` and `injury` on the adversary (3 entries, the Major cap) gives `d_adversary` **−15**, its master **−7** and its
sect head **−3**. If the plan paid the offerer +12, their master gains **+6** and their sect head **+3**. Killing an adversary gives
its master **−15** and its sect head **−7**.

## Edge Cases

`systems-designer` and `narrative-director` not consulted on this section (Lean mode). Review manually before production.

**Offers and plans**

- **If the LLM is unavailable or times out:** the template fallback runs at once, with no repair tries, and the player sees an ordinary offer.
- **If the plan fails after `repair_tries`:** an ordinary template quest replaces it, even for a Major or Legendary plan. Templates pass the same validator at load (with no `defeat` or `reach` stage, rule 4), so a template that fails is rejected at load and can never reach play.
- **If no source fact fits and the place has no board:** no quest is offered that season.
- **If the player holds `active_cap` quests:** person and sect offers are not generated, and a board can be read but its quests cannot be accepted.
- **If the plan names an unregistered person, place, item or sect:** rule 13 applies, and without a registered entity the plan fails validation.
- **If the player reloads to before an offer:** the brief is the same, but the LLM may return a different plan (rule 12). The template fallback is identical.
- **If the offerer dies, or the sect or a named place is gone, while the quest is only Offered:** it is Withdrawn, with no cooldown and no penalty.

**Stages**

- **If a plan holds two `reach` stages, or no stage that costs a season:** it fails validation (rule 5).
- **If the player already holds a `craft` stage's item:** it does not count, because the item must be made after acceptance.
- **If two active quests need the same goods:** one handed-over item serves one stage only.
- **If one season's action could serve two quests:** it counts for one, chosen by the player. A `visit` or `reach` needs no action and completes every quest it satisfies.
- **If a `deliver` stage names a class of item:** it can never fail for lack of goods, only lapse. Only a named, unique item can be lost for good (rule 10).
- **If the player is not in a sect at a `mission` stage:** bounty work counts, and it also pays no income.
- **If a `defeat` fight ends in a draw, stalemate or flight:** the stage stays open for a later season, and the deadline keeps running.
- **If the player is Down in a `defeat` and lives:** the quest fails, and Combat decides what the defeat costs.
- **If a stage's target dies (not by the player, party or sect):** rule 5's `if_target_lost` decides: `orphan` (the default), `skip` or `drop`. A plan that omits the clause gets `orphan`; an unknown value or `skip` on the last stage fails validation.
- **If a stage's target is killed by the player, their party or their sect:** the quest is Failed, whatever the clause says, unless the stage is a `defeat` whose plan allows a kill.
- **If the current stage's place no longer exists:** the quest is Dropped at once with no penalty, as for a person target (rule 10). A later stage's place orphans it.
- **If the realm changes during a quest:** B and the plan stay frozen at the offer realm.
- **If a stage runs past its window but not the deadline:** nothing happens, because only the deadline ends a quest.

**Endings**

- **If the last stage is done in the deadline's final season:** it counts, because stages resolve before the deadline check.
- **If the offerer dies in the season the quest completes:** the completion stands, because stages resolve first. The reward is paid from the estate or the sect.
- **If the player, their party or their sect kills the offerer:** the quest is Failed, and no relationship change applies because the person is dead.
- **If a person who is already below −29 is failed:** their relationship does not change.
- **If the player abandons at the last stage:** it is Failed with the normal penalty, and paid stage rewards stay.
- **If the player dies with active quests:** each ends as Failed with no relationship change, and none carries to a later life. Its `failed` outcomes apply (the offerer's side loses, the adversary's gains) unless the player was still in stage 1, and the source fact goes on the 16-season cooldown (design-review 2026-11-07).
- **If `quest_gain_cap_w` is reached:** Major and Legendary quests are still offered and pay B, with no lasting gain.
- **If the Legendary tier is drawn below Core Formation:** the quest becomes Major.
- **If a planned insight is no longer needed at payment:** the player gained one elsewhere first, so it pays nothing and nothing replaces it.
- **If a Legendary plan's above-cap item costs more than B, or a plan holds two:** it fails validation.

**Related NPCs**

- **If the offerer's attitude falls after acceptance:** the quest stays active (rule 15).
- **If the adversary dies before the quest ends:** effects on it are skipped and the quest goes on, unless it is also a stage's target, when rule 5 applies.
- **If the adversary's tie is also the player's master or sect head:** it reacts as any tie, so the offer's shown adversary is the player's warning.
- **If the root has no master, disciples or sect:** only the root reacts.
- **If a plan's `completed` outcomes harm the offerer's side, or hold no gain for that side:** it fails validation (rule 15).
- **If the fallback template for a person offer fails rule 15:** no offer is made that season (rule 15).
- **If the adversary is killed at a knockout and the quest later Fails, Lapses or is dropped:** the adversary stays dead and the ties' reaction stays applied (rule 17).
- **If an outcome's role does not resolve at the offer:** it is dropped and not shown (rule 18).
- **If an `offerer_ties` or `adversary_ties` role has nobody:** the entry does nothing.
- **If a sect is fallen at the ending:** `standing` on it is skipped.
- **If a quest would rank a sect head, or make someone head:** it fails validation (rule 17).

**Degenerate strategies watched for**

- **Accepting for stage pay, then abandoning:** at most 0.375, 0.45, 0.60 or 0.75 `I_r` per season by tier (Formulas A), with a relationship loss and a cooldown.
- **Farming a board:** about level with missions in money (Formulas A), and board quests are only Errand or Ordinary, so they pay no rare reward.
- **Double pay from normal play:** `mission` stages pay no income, and `visit` and `reach` stages add no budget (rule 5).
- **Killing the offerer to skip stages:** Failed, not Orphaned (rule 10).
- **Taking quests against a rival to farm its enemies' favour:** only the offerer's side gains, and only by the plan's budgeted relationship, while the adversary's side falls.
- **Taking a quest only to hurt the offerer through `failed` penalties:** abandoning in stage 1 applies none. Later it costs the stages done, the relationship loss and the cooldown, and pays nothing.
- **Prompting the LLM for a big reward:** the validator and the budget decide every number, whatever the plan's text says.
- **Re-running a settled grievance:** a Completed quest spends its source fact (rule 7), so the same request is never offered again.

## Dependencies

**Upstream (this system needs these).**

| System | Type | Interface | State |
|---|---|---|---|
| Event Engine (#23) | Hard | Budgets, validator, resolver, stage events | Built, no GDD; **provisional** |
| LLM Game Master (#29) | Soft | The plan from a brief. The template fallback keeps quests running without it | Built, no GDD; **provisional** |
| World Database (#3) | Hard | Source facts, entities, the quest record | Built, no GDD |
| Time & Turn (#4) | Hard | Season end | Built, no GDD |
| Config (#1), Sim Core (#2), Save/Load (#5) | Hard | `quest_rules.json`, `quest_templates.json`, seeded stream, saving | Built, no GDD |
| Sects & Missions (#26) | Hard | Mission action, base income, `hostile_threshold`, sect boards | Built, no GDD |
| Character Stats (#7) | Hard | The `quest_boon` modifier source; stat checks | GDD in review; lists this system as a modifier source |
| Meridian Map (#10) | Soft | `stat_power_weights`, `w̄_target`, tree points | GDD in review; lists this system |
| Item Database (#13) | Hard | Prices, rarity bounds, item classes | GDD approved; lists this system |
| Realms & Bottlenecks (#8) | Soft | Realm band; time estimate for `reach` | GDD in review; lists this system |
| NPC Interaction & Dialogue (#30) | Soft | Offers, `visit` by conversation | Built (thin), no GDD; **provisional** |
| Travel & Map (#25) | Soft | Places, arrival, travel seasons | Built, no GDD; **provisional** |
| Combat (#21) | Soft | `defeat` fights, fight power F | Approved for rules; build on hold; lists this system |
| Living World Tick (#28) | Soft | NPC fields changed by world effects; its population rule replaces the dead | Built (abstract), no GDD; **provisional** |

**Downstream (these need this system).**

| System | Type | Interface | State |
|---|---|---|---|
| Debug Terminal (#36), Game UI (#37) | Soft | Journal, offer, stage, ending | Terminal built, Game UI not started |
| Balance Harness (#33) | Soft | Headless quest runs and the value check | Built, no GDD |
| Heavenly Tribulation (#22) | Soft | None at runtime. Its reward content pass waits on this GDD (its Open Question 9) | Approved for rules |

**Bidirectional check.** Character Stats, Meridian Map, Item Database, Realms, Combat and Heavenly Tribulation list this system (added
2026-11-06 and 2026-11-07). The other upstream systems have no GDD to list it in.

## Visual/Audio Requirements

`art-director` not consulted (Lean mode). Review manually before production. Today's surface is the Debug Terminal;
assets are deferred with the Game UI (#37).

- **Terminal.** A quest's offer, stage and ending are marked in the log, with the offerer's name. Rewards use the existing Breakdown lines.
- **Game UI intent.** A quest reads as a letter or a notice on the scroll, with numbers kept in the print layer (art pillar "Numbers in print").
- **Events that need a visual and a sound later:** offer, accept, stage done, completed, failed, lapsed, orphaned.

## Game Feel

The quest is read, not played, so feel means weight and memory. An offer should feel like it came from someone with a
reason, so it always names the fact behind it. A deadline should press on the season plan without nagging, and an
ending should read as a line in the character's history.

## UI Requirements

| Screen or element | Must show | Must allow |
|---|---|---|
| Offer | Tier, offerer, source fact, adversary and world effects, stage count, deadline, reward budget as a Breakdown, the first stage in full, later stages by kind and place; whether a lasting gain is on offer | Accept, refuse, or wait |
| Board | The open quests at this place, as the offer shows them | Open one; accept if a slot is free |
| Journal | Active quests, stage reached, seasons left to the deadline, what the current stage needs; a warning if a quest's remaining `s_i` exceed its seasons left | Open a quest; abandon it |
| Stage | The stage's text, its checks with their chance, its reward | Choose, as any event |
| Ending | How it ended, stages done, seasons spent, rewards paid, each NPC's attitude change, world effects applied | Continue |

All of these work in the Debug Terminal first, with numbered menus as elsewhere.

> **📌 UX Flag — Quests:** this system has UI requirements. In Pre-Production, run `/ux-design` for the offer, journal
> and ending screens before writing epics. Stories that touch this UI should cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD | Refers to | Mechanic or value | Note |
|---|---|---|---|
| Rules 3, 4, 9; Formulas A | `assets/data/events_budgets.json` (Event Engine, no GDD) | Per-realm limits, `linh_thach_max`, `tu_vi_pct_max`, `tree_point_max`, `relationship_max` | Read only |
| Formulas A, D | `assets/data/session_actions.json` (Sects & Missions, no GDD) | `sect_base_income`, `income_realm_scale`, `hostile_threshold` −30 | Read only |
| Rule 5, Formulas B | combat.md rule 1, Formulas K | The fight, F = Off × ehp | Read only |
| Formulas B | thien-kiep.md Formulas C | r as the share of effective health a fight costs | The estimate is reused, not owned here |
| Rule 11, Formulas D | kinh-mach-do.md; registry `stat_power_weights` | W prices, `w̄_target` 2.07 W | Read only |
| Formulas D | thien-kiep.md Formulas E | `tempered_buff_w` 60, the 1,172 W full tree | Read only |
| Rule 11 | character-stats.md | `quest_boon` as a modifier source | Listed in its Dependencies |
| Rule 11 | canh-gioi.md rule 7; `event_resolver.gd` effect `insight` | The Nascent Soul breakthrough insight | Read only |
| Rule 9 | item-database.md | Prices, rarity bounds | Read only |
| Rule 16, Formulas E | `assets/data/session_actions.json`, World DB people records | `relationship_min`, `relationship_max`, `attitude`, `master_id`, `sect_rank` | Read only |
| Rule 14 | item-database.md Formulas F | `realm_rarity_cap`, `rarity_max` 6 | The above-cap item is an exception that GDD does not name yet (Open Question 8) |
| Rule 5 | canh-gioi.md | Time estimate for a `reach` stage | Provisional; no such estimate is exposed yet |

## Acceptance Criteria

Drafted by `qa-lead`, then re-derived by the main session after the rulings on its report (`visit`, season-based stage
pay, the cash cap, template boards). Nothing has run. Numbers are guesses until Open Question 3. Tests never call a
live model. Sampling ACs use fixed seed lists, so they are deterministic.

Evidence: `tests/unit/quests/`, `tests/integration/quests/`, `production/qa/evidence/balance/`, `production/qa/evidence/debug-terminal/`.

**Fixtures.** Used throughout unless stated; tolerance ±0.0001.

- **FX-R:** Formulas A–D defaults, with the shipped `events_budgets.json` and `session_actions.json`.
- **FX-P:** Qi Refining player, relationship 0, `quest_gain_total_w` 0, free slots. **FX-NS:** `F_player` 1.41e7.
- **FX-LLM:** mock; returns scripted plans or timeouts in order, and records briefs.
- **FX-STUB:** injected fight function; returns scripted results.
- **FX-PLAN:** ordinary, `event`, `craft`, `deliver`, no travel, windows 2, 3, 2: S_plan 4, B 60, pays 4, 9, 47, cash at most 12, deadline 11.
- **FX-MAJ:** Qi Refining major, `craft` ×3, `event`, `deliver`: S_plan 8, B 160, pays 12, 12, 12, 6, 118.
- **Season D:** the D-th season end after acceptance.

**Offers** [Logic]

- **AC-QS-01** Rule 1. Given accepted FX-PLAN, then the record holds id, offerer, source fact, plan, deadline 11, state and stage 1.
- **AC-QS-02** Rule 2. Given two offer points in a season, then 1 person offer is made, and board quests do not count.
- **AC-QS-03** Edge. Given no fitting fact and no board, then no offer and no LLM call.
- **AC-QS-04** Formulas C. Given a full board, when a season passes, then 3 stay open and the oldest is replaced.
- **AC-QS-05** Rule 2. Given a board refresh, then FX-LLM records no call, every quest comes from the template list, and each is Errand or Ordinary.
- **AC-QS-06** Rule 3 (**provisional**). Given a person offer, then the brief lists offerer, fact, realm band, the tier's stage range, kinds, deadline range, budget rates and caps, and holds no B.
- **AC-QS-07** Rule 12. Given one save run twice with different mock plans, then the briefs are byte-identical and the stored plans differ. With the mock timing out, the templates are identical.
- **AC-QS-08** Rule 14. Given 10,000 fixed seeds of person offers at Core Formation (otherwise FX-P), then 0.45, 0.45, 0.08 and 0.02 (±0.01) are Errand, Ordinary, Major and Legendary. At Qi Refining the Legendary draws count as Major (0.45, 0.45, 0.10, 0.00).
- **AC-QS-09** Rule 12. Given a stage check, then the offer stream is unchanged.

**Validation** [Logic] (**provisional**: Event Engine and LLM contracts)

- **AC-QS-10** Rule 4. Given an invalid then a valid plan, then 1 repair carries the reasons and the plan stands.
- **AC-QS-11** Rule 4. Given a valid plan on call 3, it stands. Given 3 invalid plans, an ordinary template is offered and no call 4 is made.
- **AC-QS-12** Rule 4. Given a Major or Legendary plan invalid on all 3 calls, then the offered quest is Ordinary.
- **AC-QS-13** Edge. Given a timeout, then 1 call, no repairs, and a template is offered.
- **AC-QS-14** Rule 5. n 2 and 5 pass; 1 and 6 are rejected. Errand 3 passes and 4 is rejected. Major 4 passes and 3 is rejected. Legendary 5 passes and 4 is rejected. An unknown kind is rejected.
- **AC-QS-15** Rule 5, Edge. Two `reach` are rejected. `visit` plus `reach` is rejected (no stage costs a season). `event` plus `reach` passes.
- **AC-QS-16** Rule 5. Given a Realms stub estimate of 6, window 6 passes and 5 is rejected. A `reach` already met at the offer is rejected.
- **AC-QS-17** Rule 13. Given an unregistered entity, then the plan is rejected. With the creation rule allowing it, the entity is registered before the offer.
- **AC-QS-18** Degenerate. Given text demanding a huge reward, FX-PLAN total value 60 passes and 61 is rejected; a `craft` stage value of 9 passes and 10 is rejected.
- **AC-QS-19** Rule 9. Given FX-PLAN, cash 12 passes and 13 is rejected. A plan totalling 50 of B 60 passes, because B is a ceiling.
- **AC-QS-20** Rule 5. Given FX-PLAN, a `deliver` priced 30 passes and 31 is rejected.
- **AC-QS-21** Rule 11. Given an Errand or Ordinary plan with a tree point or a boon, then it is rejected.

**Formula A** [Logic]

- **AC-QS-22** Given FX-PLAN, then B 60 and pays 4, 9, 47. At Deity Transformation, B 180,000 and pays 13,500, 27,000, 139,500.
- **AC-QS-23** Given `visit` plus `event`, then S_plan 1, B 15, and pays 0, 15.
- **AC-QS-24** Ordinary cap. Qi Refining S_plan 5 is 75, and 6 is 80 (not 90). Foundation Establishment 5 is 600, and 6 is 600.
- **AC-QS-25** Major cap. Qi Refining 7 is 140, 8 is 160 and 9 is 160. Deity Transformation, stages of 2, 2, 2, 2, 2: B 600,000 and pays 36,000 ×4, 456,000.
- **AC-QS-26** Given FX-PLAN plus travel 2, then S_plan 6, B 80, pays 4, 8, 68, deadline 14.
- **AC-QS-27** Given every realm, n 2–5 and s_i 0–4, then the pays sum to exactly B, and no stage pays above 0.375, 0.45, 0.60 or 0.75 `I_r` per season it costs, by tier.
- **AC-QS-28** Total `tu_vi`: Qi Refining 0.25 passes and 0.26 fails; Deity Transformation 0.10 passes and 0.11 fails.
- **AC-QS-29** Edge. Given a promotion mid-quest, then the pays stay 4, 9, 47.

**Formula B** [Logic] (all **provisional**: the full fight; FX-NS, Off 400, FX-STUB)

- **AC-QS-30** Ordinary: ehp 8,000: r 0.22695, accepted (Errand's 0.20 ceiling rejects it).
- **AC-QS-31** Ordinary: ehp 12,337.5 (0.35) passes; 12,338 (0.350014) and 14,100 (0.40) are rejected.
- **AC-QS-32** Major: 14,100 and 21,150 (0.60) pass; 21,151 (0.600028) is rejected.
- **AC-QS-33** Floor at the offer: 705 (0.02) passes; 704 (0.019972) is rejected. If growth gives r 0.01 at stage start, the stage stays valid.
- **AC-QS-34** Given r 0.40 at stage start, falling to 0.30 after 2 seasons, then the stage opens and the deadline moves 2 later.
- **AC-QS-35** Given r 0.40 through 4 held seasons, then the fight opens and season 5 counts against the deadline.
- **AC-QS-36** Edge. A draw, stalemate or flight leaves the stage open and the deadline running.
- **AC-QS-37** Edge. A knockout win completes the stage. Player Down and alive: Failed, −15.

**Formula C and time** [Logic]

- **AC-QS-38** Windows 2, 2 give 6; 2, 2, 3, 2, 2 give 17; 1, 1 give 3; major 1, 1, 1, 1 give 6.
- **AC-QS-39** Ordinary `window_sum` 13, 14 and 20 give 20; 21 is rejected. Major 21 and 32 give 32; 33 is rejected.
- **AC-QS-40** At `slack` 0.3, 7 gives 10 and 10 gives 13.
- **AC-QS-41** Edge. Last stage done at season 11: Completed. Not done: Lapsed.
- **AC-QS-42** Edge. Past a window but before the deadline: no state change.
- **AC-QS-43** Rule 8. Given a `visit` and a `reach` met in a season, then the season's action is unspent. An `event` stage spends it.

**Slots and cooldowns** [Logic]

- **AC-QS-44** Accepting 3 passes and the 4th is refused. No person offers generate, and a board reads but refuses acceptance.
- **AC-QS-45** Given a person's offer, it is open after 3 seasons and Declined after 4. Refusing it Declines it at once.
- **AC-QS-46** Rule 7. Reading a board quest or leaving the place starts no cooldown.
- **AC-QS-47** After Declined, Lapsed, Orphaned or Dropped, the fact is blocked at 7 seasons and open at 8. After Failed, blocked at 15 and open at 16. After Completed it is spent: never offered again.
- **AC-QS-48** Edge. The offerer dies while Offered: Withdrawn, no cooldown, no penalty.

**Endings** [Logic]

- **AC-QS-49** Rule 10. Abandon after stage 1: Failed, −15, the 4 stays, slot freed. The same at the last stage after 13 paid.
- **AC-QS-50** Rule 10. Lapsed: −8, paid rewards stay.
- **AC-QS-51** Formula D. 0 −15 gives −15; −15 −15 gives −29; −21 −8 and −22 −8 give −29; −29, −30 and −40 are unchanged.
- **AC-QS-52** Rule 10, 16. A board quest failed: no relationship change, cooldown 16. A sect's offer failed: the speaking member takes −15 like a person offerer, with cooldown 16 (design-review 2026-11-07).
- **AC-QS-53** Rule 10. Orphaned after 13 paid: finishing pays floor(0.5 × 47) = 23, no penalty. Dropping gives Dropped, 0, no penalty.
- **AC-QS-54** Rule 10. An Orphaned quest keeps its slot. Its deadline passing gives Dropped. With no estate or sect to pay, it is Dropped at once.
- **AC-QS-55** Rule 10. An Orphaned FX-MAJ pays no lasting gain.
- **AC-QS-56** Rule 10, degenerate. Offerer killed by the player, party or sect: Failed, no relationship change, not Orphaned.
- **AC-QS-57** Edge, Rule 8. The offerer dies in the completion season: Completed, 47 paid. The offerer dies in the deadline season with stages left: Orphaned, then Dropped at the same season end, with no penalty and never Lapsed (design-review re-review 2026-11-06).
- **AC-QS-58** Edge. Player dies with 3 active: all Failed, no relationship change, none in the next life.
- **AC-QS-59** Edge. A named unique item destroyed: Failed. A class item gone: the stage stays open, then Lapsed.
- **AC-QS-60** Rule 10. Every ending records stages, seasons and rewards.
- **AC-QS-61** Edge. Two `deliver` stages, one item: one stage completes.
- **AC-QS-62** Edge, Rule 8. One action serves one chosen `mission` stage, and lifespan keeps ticking.
- **AC-QS-63** Edge. A `craft` item held before acceptance does not complete the stage; one crafted after does.

**Formula D** [Logic]

- **AC-QS-64** 8 W passes, 8.01 is rejected, and a second gain in one quest is rejected.
- **AC-QS-65** 3 tree points cost 6.21 W. Qi Refining 1 passes and 2 is rejected; Deity Transformation 3 passes and 4 is rejected; a lifetime 4th is rejected.
- **AC-QS-66** Total 40 allows 8, 44 allows 4, 48 allows 0, and B stays 160.
- **AC-QS-67** Rule 11. Two active major quests each planning 8 W at total 44: the first pays 4 W and the second 0.
- **AC-QS-68** Formula D. At 1 W of room, a 1-point tree gain pays nothing.

**Cross-system** [Integration]

- **AC-QS-69** A `mission` stage, in a sect or on bounty: mission income paid is 0 and the stage completes.
- **AC-QS-70** FX-PLAN with a `reach` before `deliver`: S_plan 4, B 60, pays 4, 9, 0, 47.
- **AC-QS-71** A paid `quest_boon` line survives save and reload, and `quest_gain_total_w` matches.
- **AC-QS-72** Reload at stage 2: plan byte-identical, zero LLM calls.
- **AC-QS-73** Mock narration differs on stage start: checks, effects and numbers do not.
- **AC-QS-74** Degenerate. A 4-season `mission` then a `visit`, abandoned before the `visit`: 18 paid, 0.45 `I_r` per season.
- **AC-QS-75** [Bot: Balance Harness] **Provisional**, Open Question 3. Fixed-seed board farming, everything sold, is within ±10 % (a guess) of mission income.

**Lint** [Config]

- **AC-QS-76** A template that fails the validator at any realm is rejected at load, and a template marked Major or Legendary is rejected. A template holding a `defeat` or `reach` stage is rejected at load (rule 4).
- **AC-QS-77** Golden table: `I_r` 10, 80, 600, 4,000, 30,000; `E_r` 80, 600, 5,000, 40,000, 300,000; `tree_point_w` 2.07; floor −29.
- **AC-QS-78** `stage_reward_share` 0.2 and 0.4 pass, 0.19 and 0.41 fail. `slack` 0.3 and 1.0 pass, 0.29 and 1.01 fail.

**Terminal** [UI]. Screenshots retained in `production/qa/evidence/debug-terminal/`.

- **AC-QS-79** The offer shows every UI Requirements field, and later stages show kind and place only.
- **AC-QS-80** At cap room 0, the offer says no lasting gain.
- **AC-QS-81** Board, journal, stage and ending show their listed fields, and a stage shows each check's chance.

**Tiers** [Logic]

- **AC-QS-82** Rule 14. The Legendary tier drawn at Foundation Establishment gives a Major quest; at Core Formation it stays Legendary.
- **AC-QS-83** Formula A. Errand at Qi Refining: S_plan 3 is 37, and 4 is 40 (not 50). Legendary at Core Formation: S_plan 10 is 15,000, and 11 is 15,000.
- **AC-QS-84** Formula B (**provisional**). Errand r 0.20 passes and 0.21 is rejected. Legendary 0.80 passes and 0.81 is rejected.
- **AC-QS-85** Formula C. Errand `window_sum` 8 and 12 give 12, and 13 is rejected. Legendary 27 and 40 give 40, and 41 is rejected. Legendary windows 1 ×5 give 8.
- **AC-QS-86** Rule 14. A Legendary plan at Core Formation with one rarity 6 item inside B passes. A second above-cap item, or one priced above B, is rejected. The same plan as Major is rejected.
- **AC-QS-87** Rule 14. A second Legendary quest in the same life may pay a rarity 6 item, and the payment clamp pays it unchanged (**provisional**).
- **AC-QS-88** Rule 10. An Orphaned Legendary quest pays no above-cap item.
- **AC-QS-89** [UI] The offer shows the tier.

**Added by design-review 2026-11-06** [Logic]

- **AC-QS-90** Rule 10, Formulas D. Given FX-MAJ orphaned in stage 1 (unpaid 160, `s'` 2, `S'` 8), finishing pays 20. Orphaned in stage 5, the last (`s'` 1, `S'` 1, unpaid 118), it pays 59. A current `visit` stage (`s_i` 0) uses `s'` 1.
- **AC-QS-91** Rule 9. Given a non-final stage, 3 reward effects pass and 4 are rejected. Given the final stage, 6 pass and 7 are rejected. Relationship, access, `tu_vi` and rare rewards each count as one, a `quest_boon` with three keys counts as one, and `outcomes` entries count as none.
- **AC-QS-92** Formulas C. Given an `event` stage (`s_i` 1), window 1 passes and 0 is rejected. Given a `craft` stage (`s_i` 2), window 1 is rejected and 2 passes. A window of 12 passes and 13 is rejected.

**Added by design-review re-review 2026-11-06** [Logic]

- **AC-QS-93** Rule 5. Given FX-PLAN where stage 2 (`craft`) is current and stage 3's `deliver` recipient dies by another cause: with `orphan` (or no clause) the quest is Orphaned, stage 2 becomes the last, no penalty; with `drop` it is Dropped, no penalty, the 4 paid stays.
- **AC-QS-94** Rule 5. Given the current stage's own target dies, then the quest is Dropped at once for `orphan` and for `drop`, with no penalty and paid stage pay kept.
- **AC-QS-95** Rule 5. Given FX-SKIP with `skip` on stage 2 whose recipient dies before it begins: when it begins it completes with 0 stage pay, stage 3 starts, and the final pay stays 58 (not 62). `skip` on the last stage is rejected by the validator, and so is an unknown clause value.
- **AC-QS-96** Rule 5, Rule 10. Given a stage target killed by the player, their party or their sect, the quest is Failed with the normal relationship loss, whatever the clause says. A `defeat` whose plan allows a kill completes on the kill.
- **AC-QS-97** Rule 5, Rule 12. Given a reload after a target dies, the same clause applies and zero LLM calls are made.

**Added by design-review second re-review 2026-11-06** [Logic]. **FX-SKIP:** ordinary, `event`, `deliver` (to a person), `craft`, `deliver`, no travel: S_plan 5, B 75, pays 4, 4, 9, 58.

- **AC-QS-98** Rule 7. Given a Completed quest, its source fact is never offered again (checked at seasons 8, 16 and 100). After Orphaned or Dropped it is blocked at 7 and open at 8. After Withdrawn there is no cooldown.
- **AC-QS-99** Rule 10. Given FX-SKIP with stage 2 skipped, then the offerer dies while stage 3 (`craft`, `s'` 2, `S'` 3) is current: Orphaned, and finishing pays floor(0.5 × 67 × 2 / 3) = 22 (unpaid 9 + 58, the skipped 4 excluded).
- **AC-QS-100** Rule 10, Rule 5. Given the current stage's place no longer exists: Dropped at once, no penalty, paid stage pay kept. Given a later stage's place gone: Orphaned. Given a stage target lost with a living offerer: the offerer pays the orphan reward. Given a board quest orphaned: the board's sect or town pays.
- **AC-QS-101** Formulas C. Given an Errand with deadline 12 and a `defeat` held 4 seasons: the deadline becomes 16, and no new offer is rejected for it.

**Related NPCs** [Logic]

- **AC-QS-102** Rule 15. An offerer not tied to the fact gets no offer. One named in it, or whose master is named in it, does.
- **AC-QS-103** Rule 15. Attitude −30 gives no offer; −29 gives one.
- **AC-QS-104** Rule 15. A plan whose `completed` outcomes harm the offerer's side, or hold no `completed` gain for `offerer`, `offerer_ties` or `offerer_sect`, is rejected. A plan with one such gain and no harm passes.
- **AC-QS-105** Rule 15. Attitude falling to −50 after acceptance leaves the quest Active.
- **AC-QS-106** Rule 16. A plan naming the player as adversary, or two adversaries, is rejected. Stage targets are not limited by this rule (rule 5).
- **AC-QS-107** Formula E. A Major plan with an offerer `wealth` gain and adversary `wealth` and `injury` (3 `completed` entries, the cap). Completed: root −15, master −7, sect head −3. Offerer paid a +12 relationship reward: master +6, sect head +3. A killed adversary: master −15, sect head −7.
- **AC-QS-108** Formula E. A master who is also sect head changes by −7 only. An NPC on both sides takes both changes.
- **AC-QS-109** Formula D, E. Failed: offerer −15, master −7, head −3. Lapsed: −8, −4, −2. A tie at −25 on Failed ends at −29. The adversary's side does not change.
- **AC-QS-110** Formula E. A tie at −95 taking −15 ends at −100. Sum of severity 40 gives `d_adversary` −30.
- **AC-QS-111** Rule 16. A quest never changes attitude for a sect member who is not a root, master, disciple or head.
- **AC-QS-112** Rule 17. Errand `wealth` passes; Errand `injury` and Ordinary `rank` are rejected. Ordinary with 2 effects is rejected. Major with 3 passes and 4 is rejected. Legendary with 3 passes and 4 is rejected.
- **AC-QS-113** Rule 17. With FX-PLAN, `wealth` 30 passes and 31 is rejected. `injury` 0.40 passes and 0.41 is rejected.
- **AC-QS-114** Rule 17. A `death` with no `defeat` stage, or on a non-adversary, is rejected. An Ordinary `defeat` cannot kill. `rank` on a sect head, or into head, is rejected.
- **AC-QS-115** Rule 17. `completed` outcomes (except `death`) apply on Completed and on a finished Orphaned quest, skipping the dead. Dropped, Declined and Withdrawn apply none.
- **AC-QS-116** Rule 17. Every ending logs an event naming the people involved, and that event can source a later offer.
- **AC-QS-117** Rule 17. A tie turned hostile makes no quest offer to the player.
- **AC-QS-118** Rule 18. A template with an `outcomes` list loads and resolves its roles at the offer. A template with a role or effect outside the tables is rejected at load.
- **AC-QS-119** [UI] The offer shows the adversary and world effects, and the ending shows each attitude change.

**Quest format** [Logic]

- **AC-QS-120** Rule 18. With FX-PLAN, `offerer` `wealth` of 30 on `completed` is paid on Completed. On Failed and on Lapsed it is not.
- **AC-QS-121** Rule 18. `offerer` `wealth` of −20 on `failed` applies on Failed and Lapsed, and not on Completed, Dropped, Declined or Withdrawn.
- **AC-QS-122** Rule 18. Abandoning in stage 1 applies no `failed` outcomes. Abandoning in stage 2 applies them.
- **AC-QS-123** Rule 18. `offerer_ties` `wealth` of 30 with 4 ties pays 7 each. `injury` of 0.40 gives a master or disciple 0.20.
- **AC-QS-124** Rule 18. A `completed` loss on `offerer`, a `failed` gain on `offerer`, `death` on `failed`, `death` on `offerer`, and `rank` on a sect role are each rejected.
- **AC-QS-125** Rule 17. `standing` 10 passes and 11 is rejected. `sect_standing` stays within −100 and 100.
- **AC-QS-126** Rule 18. On a board at a sect's place, `offerer_sect` resolves to that sect. At a town with no sect, the entry is dropped and not shown.
- **AC-QS-127** Formula E. A Major plan with an offerer gain and `completed` losses of `wealth` and `standing` on the adversary gives `d_adversary` −10.
- **AC-QS-128** [UI] The offer shows each resolved outcome with its ending, role and amount.

**Added by design-review 2026-11-07** [Logic]

- **AC-QS-129** Rule 17. Given a Major quest with `death` on the adversary (its master and sect head alive), when the player wins the `defeat` stage by knockout in stage 3, then the adversary is dead at once, the master changes by −15 and the sect head by −7 at that moment, and neither is Failed by rule 5.
- **AC-QS-130** Rule 17. Given AC-QS-129 and the quest then Fails, Lapses or is dropped, the adversary stays dead and the ties' changes stay. Given a quest that never reaches the knockout, no `death` applies.
- **AC-QS-131** Rule 17, 18. Given `outcomes` entries counted against `world_effects_max`: Ordinary with 2 entries on `completed` is rejected, and 1 `completed` plus 1 `failed` passes. A `death` entry counts under `completed`.
- **AC-QS-132** Rule 18. `amount_share` 0.3 on FX-PLAN (B 60) gives 18, and a negative `amount_share` is a loss. `amount_share` 0.51 on a `wealth` entry (above `world_wealth_share` 0.5) is rejected.
- **AC-QS-133** Rule 15. A template tagged for person offers with no `completed` gain for the offerer's side is rejected at load. A person offer whose fallback template fails rule 15 makes no offer that season and makes no LLM call after the fallback.
- **AC-QS-134** Rule 18, Formula E. Given a board quest at a sect's place with `offerer` `wealth` on `completed`: on Completed the head gains the wealth, and the attitude of the head, their ties and any adversary is unchanged. On Failed and Lapsed attitudes are also unchanged. A board template paying a relationship reward with the head is rejected at load.
- **AC-QS-135** Rule 11. Given a Major plan for a Nascent Soul player with no insight, an `insight` passes and B is unchanged. It is rejected for a player who holds one, for any other realm, on an Errand or Ordinary plan, and as a second insight in one quest.
- **AC-QS-136** Rule 11, Edge. Given an active quest planning an `insight` and the player gains one elsewhere before payment, the insight pays nothing, nothing replaces it, and the rest of the final pay stands.
- **AC-QS-137** Rule 11. Given any plan with a `recipe` reward, it is rejected until Open Question 11 is closed.
- **AC-QS-138** [Config] Formulas B, D. `stage_hold` 0 and 8 pass, −1 and 9 fail. `quest_boon_w` 4 and 12 pass, 3.9 and 12.1 fail. `quest_gain_cap_w` 24 and 60 pass, 23.9 and 60.1 fail.
- **AC-QS-139** [Bot: Balance Harness] **Provisional**, Open Question 3. Given a fixed-seed 2,000-year life taking one person or sect quest per 8 seasons, about 20 are Legendary and about 100 are Major or Legendary (±30 %, a guess), lifetime `gain_w` stays at most 48, and the report lists the above-cap items paid.

**Added by design-review third re-review, second pass 2026-11-07** [Logic]

- **AC-QS-140** Rule 16. Given a sect's offer through member M (master X, sect Y): `offerer` resolves to M, `offerer_ties` to X and M's disciples, `offerer_sect` to Y. On Failed, M takes −15, X −7 and Y's head −3. A sect offer whose member's attitude is −30 makes no offer.
- **AC-QS-141** Rule 16, 17. Given a Major plan whose adversary is a sect with head H, `adversary` resolves to H. An offerer gain plus a completed `wealth` and `injury` on `adversary` give H −15 and H's master −7 (H is the sect head, so no separate head tie reacts, as in AC-QS-108). A sect adversary whose head is already dead resolves nothing, and the entry is dropped.
- **AC-QS-142** Rule 4, 16. Given a template holding `defeat` or `reach`, then it is rejected at load. A template whose stages with `template_travel_max` 4 added fit `deadline_max` loads, and one that exceeds it at that travel is rejected at load. A fallback for an offer with travel above 4 that would exceed `deadline_max` makes no offer, and a board omits it.

**Added by design-review fifth pass 2026-11-07** [Logic]

- **AC-QS-143** Rule 4. Given a template whose windows plus `template_travel_max` 4 exceed `deadline_max`, then it is rejected at load. Given an Errand template at `window_sum` 8 and an offer with travel 5 (13 over 12), then the fallback makes no offer, and on a board it is omitted.
- **AC-QS-144** Rule 17, 18. Given a Major plan with 3 `completed` entries (an offerer gain, adversary `wealth`, adversary `injury`), it passes rules 15 and 17. Given a 4th, it is rejected. Given an `injury` entry with `amount` 0.4, it is 40 % of vitality, and `rank` with an `amount` is rejected.
- **AC-QS-145** Edge. Given a player who dies in stage 2 with an active quest whose plan has a `failed` outcome, then that outcome applies and the source fact is on the 16-season cooldown. Given a death in stage 1, no `failed` outcome applies and the cooldown still does.

**Not covered.** No AC for per-kind completion of `event`. The `reach` estimate does not exist yet, so AC-QS-16 uses a stub.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | Event Engine, LLM Game Master and Dialogue have no GDD. Confirm the brief, the repair call, the new effect types (rule 9) and the rule for new entities (rule 13). `qa-lead` reports that today's event validator clamps and drops, and never rejects on budget, so plan-level rejection (rule 4) is new work, as are the final-stage cap of 6 effects, the Legendary rarity exception and the `if_target_lost` clause; size all of it | systems-designer | Implementation |
| 2 | Rule 6 (assumption): is showing the first stage in full and later stages by kind and place the right reveal? | user | UI Requirements |
| 3 | Measure quests against missions in the Balance Harness, then re-fit `quest_reward_mult`, `cap_mult`, `stage_reward_share` and `tier_share` | systems-designer, Balance Harness | Approval of the numbers |
| 4 | r has no win-chance meaning yet. Re-fit `quest_fight_ratio_max` once Combat Open Questions 6 and 20 are measured. `defeat` waits on the full fight | systems-designer | `defeat` stages |
| 5 | A person or sect offer needs one LLM call, plus up to `repair_tries` repairs. What latency and cost are acceptable? | technical-director | Implementation |
| 6 | Which stat keys may a `quest_boon` use? | user, systems-designer | Content pass |
| 7 | Feasibility was not checked against the pinned engine: there is no `scripting` module under `docs/engine-reference/godot/modules/` | technical-director | Architecture |
| 8 | The Item Database's `realm_rarity_cap` must name the Legendary exception (rule 14). Rarity 6 items are also scarce today, so this reward needs more hand-authored top items | user, economy-designer | Content pass |
| 9 | World effects write NPC wealth, vitality, rank and life. Confirm those fields and that deaths keep Realms' headcount targets when the Living World is documented | systems-designer | Implementation |
| 10 | `sect_standing` is new and nothing reads it yet. What should it change: offers, prices, recruits, or sect wars? Sects & Missions and the Living World need to decide | user, game-designer | Effect of `standing` |
| 11 | A `recipe` reward has nothing to teach: Alchemy has no recipe knowledge today, and an `items_recipes.json` `price` is the pill's price, not the knowledge's. Decide whether recipes become learnable, then set the reward's price and rarity (rule 11) | user, economy-designer | `recipe` rewards |
