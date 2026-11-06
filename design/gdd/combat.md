# Combat

> **Status**: Designed (pending review; reworked 2026-11-06 to one health bar and wards)
> **Build status**: On hold (user decision 2026-11-06). The full fight is not built until items, techniques, abilities and passives exist. Until then fights keep using today's power duel (`CombatPower`, `combat_rules.json`) unchanged, so the Character Stats and Cultivation Techniques edits that cite this GDD describe the target, not the running game.
> **Author**: user + agents
> **Last Updated**: 2026-11-06
> **Last Verified**: 2026-11-06
> **Implements Pillar**: Power Is Built, Not Given (3); Your Dao, Your Name (1); Every Number Is Bounded and Visible (2)

## Summary

Combat tests a cultivator's whole build: the player prepares, then the engine resolves a seeded, round-based
fight and explains every hit. Khí huyết is the one health bar, linh lực pays for arts and wards off damage,
and thần thức strikes past wards for a share of both. Bonuses add inside a layer and multiply
across layers, so an assembled build far outscales a single stacked stat and can win one realm up, or
about half the time two realms up. It replaces today's power-ratio duel, hosts the Way's arts and
Heavenly Tribulation, and collapses to a rating only for wars and great battles.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Character Stats, Realms, Cultivation Techniques, Meridian Map, Artifact Refining, Formations, Talismans, Spirit Beasts`

## Overview

Combat is where a cultivator's whole build is put to the test. A fight between two
cultivators, or a cultivator and a creature, is prepared by the player and then resolved by the
engine as a deterministic, seeded exchange of rounds. Every hit is logged with a Breakdown that
shows which layers of the build produced it, so a player can see why a build won or lost
(Pillar 2). The fight itself is auto-resolved: the choices that decide it are made before it
starts, in the build (spiritual root, techniques, Meridian Map [Kinh Mạch Đồ], the Way [Đạo], artifacts [pháp bảo],
spirit beasts [linh thú]) and in the preparation (formations [trận pháp] laid, talismans [phù lục] drawn, poison
applied, ground chosen, arts slotted). This replaces today's single power-ratio duel, which
cannot host skills or the Way's arts.

Four ideas shape the design, all committed by the user on 2026-11-06, with the defence model reworked
the same day:

- **Scaling layers.** Bonuses add within a layer and multiply across layers, so a build that works
  several layers far outscales one that stacks a single number. Big numbers come from how a build
  is assembled, not from a stat race (Pillar 3). Meridian Map and Way W stay additive and keep
  buying the inside of one layer; the other layers are priced separately.
- **Tags, conversion and triggers.** Arts, techniques and Way nodes carry tags (element, sword,
  soul, poison), and modifiers key off them. A Dao can convert one tag to another (Fire to Lava),
  and "when X happens, do Y" triggers give builds their signature combos (Pillar 1).
- **Several kinds of threat.** Body and qi attacks, soul strikes, damage over time, curses and
  layered defences mean a one-note build gets punished and must answer more than damage.
- **Spiritual power (linh lực) as mana and as defence, and preparation.** Linh lực pays for arts and
  powers the ward that blocks most damage, so every art cast is defence spent. A cultivator out of
  linh lực who is not a body cultivator (thể tu) is little more than a mortal. What is set up before
  the fight (Pillar 4: time and resources spent beforehand) counts as much as what happens in it.

Combat feeds Heavenly Tribulation (Thiên Kiếp), the Event Engine and NPC Builds, and is the system the Way's arts wait on.
Fighting above one's realm (vượt cấp) is possible only through what the build earns, against realm
suppression. The design must stay deterministic from the seed, readable in the Debug Terminal, and
cheap enough for a world of 5,000 NPC cultivators: their individual duels stay rare, and wars settle
through an abstract rating.

## Detailed Design

### Core Rules

Numbers are not set here; named values are defined in Formulas and live in `combat_rules.json`, except
`slot_count` (Open Question 9). Rules marked **(assumption)** are the
author's reading and wait for confirmation (see Open Questions).

1. **A fight is two sides and a seeded round loop.** A side is one combatant (a cultivator or a
   creature) plus its attached companions (rule 19). A fight is resolved from its inputs alone: the
   two compiled profiles (rule 2), the preparation (rule 12), the ground tags and one seed. The same
   inputs always give the same result and the same log. Nothing is saved mid-fight; a fight is
   atomic.
2. **Every combatant compiles to a combat profile.** `compile(character or creature, preparation)`
   is a pure function that returns the health and linh lực maxima, thần thức, the ward, the body guard,
   the layered modifiers, the art loadout, the triggers and the tag set. The full fight and the mass-battle
   form (rule 17) both read the profile, so the player's power and an NPC's stay comparable.
   `compile` replaces today's `CombatPower.compute`, and every stored use of its total moves to
   `display_power` or the profile (Formulas K).
3. **One health bar.** Khí huyết is the only bar that ends a fight. It starts at its maximum × `max(v, 0.4)`,
   where v is the vitality fraction. At 0 the side is **Down** with a mortal wound, dying unless the winner
   spares it. Linh lực starts full. Combat reports the knockout; the caller decides what it costs
   (rule 14). The thần thức that equipped artifacts occupy (Artifact Refining) stays a separate loadout
   limit and does not lower the thần thức a side fights with (user decision 2026-11-06).
4. **Three threat kinds, and how each gets through.** Every attack has a kind. **Body** and **qi** attacks
   meet the ward (rule 22), and what passes meets the body guard (rule 23), before reaching health.
   **Soul** attacks skip both (rule 24). Damage over time (rule 7) and curses (rule 8) are statuses that
   carry a kind too.
5. **Layers add inside and multiply across.** Every modifier belongs to exactly one layer, fixed by
   its authoring and never chosen in play. Within a layer the bonuses add; across layers the layer
   totals multiply. The layer list is small and fixed in data. **W stays additive:** the Meridian
   Map's and the Way's `attack_pct`-style bonuses keep their W price and fill the first
   (increased) layer exactly as they do today. The other layers are filled by sources priced
   separately: tagged art modifiers, equipment and companions, preparation and ground, and
   conversion and trigger effects. A hit's damage is `base × Π layers`, and each layer appears as a
   line in the Breakdown (rule 16). Soul attacks are the exception (rule 24).
6. **Tags decide what a modifier touches.** Every art, hit, status, modifier and piece of ground has
   a tag set: element (the five elements and the eight variants), form (sword, palm, seal, beast,
   formation), kind (body, qi, soul), mode (hit, over time, curse, ward), source (art,
   artifact, talisman, formation, companion) and effect (pierce, lock, poison, cleanse, escape). A modifier applies to a hit when its required tags are
   all in the hit's tags. **Conversion** turns a share of a hit's element or kind tags into another
   (Fire to Lava, body to qi) before layers are summed; the converted share keeps the original tags
   as well, so both tag families' modifiers apply to it. Conversions run in a fixed order and a tag
   cannot be converted back in the same hit.
7. **Damage over time is a status.** An over-time effect has a kind, tags, a strength, a duration in
   rounds and a stacking rule (refresh, stack to a cap, or the stronger wins). It ticks at the
   start of every round inside the ward, so only body guard reduces it, and it is an ordinary line in the log.
8. **Curses are statuses that change rules, not pools.** A curse can lower a defence, lock one
   layer, raise an art's cost, block regeneration or block a tag. It has a duration and a source and
   can be cleansed by an art or a talisman with a matching cleanse tag. A curse never
   reduces health or linh lực by itself.
9. **Triggers: "when X, do Y".** A trigger is an event (on hit, on being hit, on a pool below
   a threshold, on round start, on a status applied, on an art fired) plus a condition, a limit
   (per round, per fight, or a cooldown) and an effect (a free hit, a status, a refund, a ward, a
   conversion toggle). Triggers resolve in a fixed order, a trigger caused by a trigger resolves at
   most to `trigger_depth`, and the per-round trigger count is capped, so no build can loop forever.
10. **The round loop.** Both sides act at once.
    1. Round start: triggers for the round start, then over-time statuses tick. If a tick empties
       health, the defeat check of step 6 runs at once and a Down side takes no action.
    2. Each side's autocast ward is cast if it is on (rule 22). Each side then reads the
       **round-start snapshot** and picks its action by its priority list (rule 13), so neither side
       sees the other's choice.
    3. Every action is calculated from the snapshot; all damage and effects are then applied
       together. A side with no health left is **Down** from this moment.
    4. Resulting triggers resolve in the fixed order of rule 9. A Down side's triggers do not fire.
    5. End of round: sides that are not Down regenerate linh lực. Cooldowns and curse durations fall
       by 1, except those set this round. An art with cooldown c therefore skips c rounds.
    6. Defeat check. If one side has no health, the fight ends. If both have none, the side with
       the larger overkill loses, where overkill is the damage past zero as a share of maximum
       health. If equal, the side with more linh lực as a share of its maximum at the start of the
       round wins. If still equal, a 50/50 draw decides, which fortune does not shift. The winner
       of a double knockout is left at 1 health and is not Down.
    There is no speed or initiative: no stat decides who acts first, so no single stat can dominate
    the order of a fight. Round `round_limit` is played; if no side is Down after it, the fight is a
    **stalemate** and each side keeps what it has left (rule 14).
11. **Linh lực is mana and defence.** Arts cost linh lực, the pool regenerates at a small rate per round
    (sustain builds raise it), and blocked damage drains it (rule 22). Nothing reserves it: a side may
    spend it all, and every point spent on arts is a point its ward no longer has. With no affordable
    art a side uses the basic attack. A long fight favours the build that brought sustain, and a burst
    build must win before its own spending drops its guard.
12. **Preparation counts.** Before a fight the player may prepare, within what the situation allows.
    The Event Engine tells Combat which kind of situation the fight is:

    | Situation | What can be prepared |
    |---|---|
    | **Foreseen** (a challenge, a hunt, a planned raid, a tribulation) | Everything: a formation laid on the ground, talismans slotted, a poison or coating applied, pills taken, the ward chosen, the priority list set, the ground chosen where there is a choice |
    | **Ambush** (an event fight with little warning) | What is carried and what a standing formation already holds: talismans, pills with a ready dose, the priority list |
    | **Blind** (a sudden attack) | Only the loadout, including its ward and any talisman already slotted, and the saved priority list |

    Each prepared item adds modifiers to a layer, costs the time, goods and upkeep its own system
    sets, and appears in the fight's opening Breakdown. Combat does not price preparation: Artifact
    Refining, Formations, Talismans and the Alchemy pills each own their cost, and Combat owns
    only what the prepared item does inside the fight.
13. **Arts and the priority list.** An **art** has an id, tags, a kind, a linh lực cost, a cooldown in
    rounds and an effect. The sources are: the divine abilities (thần thông) that the main and
    auxiliary techniques unlock (Cultivation Techniques owns when they unlock, Combat owns what they
    do), the Way's art nodes (**on hold** until this GDD is approved; the art format here is
    the one the Way's data lint will accept), an artifact's active effect, and the always-available
    basic attack (body kind, tags body, hit and art, no cost). A combatant's **loadout** has `slot_count` art slots (rises with realm), a
    ward slot (rule 22) and the basic attack. The **priority list** is an ordered list of rules `(condition, art)`; each round
    the first rule whose condition is true and whose art is ready and affordable fires, otherwise
    the basic attack. Conditions come from a fixed vocabulary: own and enemy pool percentages, a
    status on either side, the round number, the enemy's dominant threat kind (the kind of most of
    its slotted arts; ties go body, soul, qi), and "no art ready".
    A talisman is an art that is used up when it fires. Escape is an art too: a fight
    ends by flight if the escape art succeeds (a seeded chance against the pursuer's tags and
    realm), with the result recorded as such.
14. **A fight ends with a result, never with a consequence.** The result is: the winning side, how
    it ended (knockout, stalemate or flight), the rounds, each side's health and linh lực at the end, the
    resources spent (talismans, linh lực), the deciding layer (the layer with the highest
    damage-weighted total over the winner's hits; ties take the lower number), and the full log. Combat itself
    changes nothing outside the fight. The caller applies consequences: it decrements spent stock, Character Stats takes the
    vitality loss (Formulas A), the Event Engine decides death, mercy or capture and offers taming of a beaten
    creature, Realms receives the defeat for capability #9, and the World Database records the
    event. **Death rests on the caller:** Combat only says a side was mortally wounded.
15. **All randomness is explicit and seeded.** One random stream per fight, seeded from the world
    seed and the fight id, is drawn from in a fixed order. Randomness enters only through explicit
    `chance` fields (a critical hit, an evade, a status chance, a trigger chance, an escape) and the
    tiebreak draw. A build whose chances are all 0 or 100 per cent is fully deterministic, and
    the design aims at that: chance is a flavour of a build, not the base of the outcome. Hits
    have no base damage spread (user decision 2026-11-06). Fortune (khí vận) shifts every chance
    roll that is not already 0 or 100 per cent (Formulas I).
16. **Every hit explains itself.** Each hit logs its actor, art, tags, kind, the Breakdown of every
    layer (the bonuses inside each layer and the layer total), what the ward blocked and drained, the body guard, and health and
    linh lực before and after. The terminal shows a one-line summary per round by default and the
    full Breakdown on request; the log is data and the Game UI reads the same structure.
17. **Mass battles use the rating profile.** Great battles and wars (a sect war, a besieged city) do
    not run as fights. Each force compiles to a **rating profile** (offence, defence and sustain per
    threat kind, over the force's members under a size rule) and the clash is
    a closed-form comparison plus one seeded roll. Individual NPC duels do not collapse: they run
    the full fight of rules 1 to 16, and the Living World keeps them rare (Interactions). The
    rating profile is derived from the same compiled profile, and its win rate must agree with
    the full fight on sampled one-on-one pairs within a stated tolerance (Acceptance Criteria).
18. **Enemies are profiles.** A creature, a monster and an NPC all use the profile of rule 2. An
    enemy's character comes from its modifiers, art list and priority list: a body-crusher, a
    soul-piercer, a poisoner, an armoured beast. Content authors add enemies by data, with no new rule.
    Each realm tier has at least one enemy that attacks with each threat kind, one with a ward that
    resists each kind and one that drains linh lực hard, so a one-note build meets something it cannot answer. A top-end build
    may end an ordinary fight in a round or two; that is its payoff (user decision 2026-11-06).
    Bosses and tribulations carry a `boss_pool_mult`, set so that a top-end build
    needs at least 4 rounds against them.
19. **Companions.** A spirit beast attached to a side adds the power share it already has
    (Spirit Beasts) as one more attack source in each round, with its own tags and a simple fixed art.
    A companion cannot be targeted in this version, and cannot be removed from the fight except by its
    owner's defeat (user decision 2026-11-06).
20. **Fighting above one's realm (vượt cấp) is paid for by the build.** A side whose realm is lower
    than its enemy's by `g` major realms has the damage it deals reduced by a suppression
    factor that grows with `g`, on top of the gap in fight power (damage × effective health) of about ×10
    per realm: ×6.3 from the fight unit and the rest from the W a higher realm holds (Formulas A). A modifier with
    the **pierce** tag reduces the suppression by its own share. A build that has stacked several
    layers can overcome the gap, a build with a single stat cannot.
21. **Fights are readable and testable.** The fight engine is a pure function of its inputs with
    no clock, no engine nodes and no global state; the Balance Harness runs it headlessly and the Debug
    Terminal prints its log.
22. **Warding spells.** A ward is resistance-based blocking. Every cultivator has a default ward from
    linh lực itself, and a **warding spell** in the loadout's ward slot replaces it. The spell sets how much
    of a hit gets through, by threat kind and by tag, and what it costs. **The default cost model is
    drain:** each blocked point takes linh lực, so more block means more drain. A spell may define another
    model, such as a fixed mana cost per hit for a fixed share blocked whatever the hit's size, or a cost
    per round. New models are data, so wards stay a place for creative builds. Two build stats act on
    any ward: **ward strength** blocks more and **ward efficiency** costs less.
    A ward is an **autocast** by default: it is cast free of the round's action at the start of every
    round, and it is up that round if its cost can be paid. A spell may instead be cast by hand as an
    art in the priority list. The player can switch a ward off for a fight, to save linh lực for arts.
    One ward is up at a time. With little linh lực a drain ward simply blocks little, and with none it
    blocks nothing, so no separate "fallen" state exists.
23. **Body guard, and being a mortal.** Body guard is a mitigation anyone can build from physique
    (căn cốt), body techniques (luyện thể) and body items, and it works with no linh lực. A body cultivator
    (thể tu) is simply a build that stacked it. Damage that gets past the ward then meets the body guard.
    A side with no linh lực has no ward and cannot pay for arts. Unless it built body guard or a
    gimmick that replaces the ward, every hit lands nearly in full. Arts may be authored to cost health
    instead, so a body build can still act.
24. **Thần thức attacks.** A soul attack is an ordinary art of the soul kind: it has a cost and a cooldown
    like any other, and fires whenever the priority list says. It ignores wards and body guard and takes
    a share of maximum linh lực and of maximum health at once. The share rises steeply with the attacker's
    thần thức over the defender's, so it is only dangerous across a big gap in power and small between
    equals. It is rarely a main attack unless a build is made for it. The reliable defences are the
    defender's own thần thức and the Way; other sources are rare. Its balance waits on the technique
    content (Open Question 16).

### States and Transitions

A fight has these states; a combatant has the sub-states under it.

| State | Entered when | Leaves when |
|---|---|---|
| Requested | The Event Engine, Tribulation or the player opens a fight | The situation (rule 12) is known |
| Preparing | The situation allows preparation | The player confirms the setup (or the situation allows none), and the profiles compile |
| Round (steps 1 to 6 of rule 10) | The profiles have compiled | The defeat check ends the fight, the round limit is reached, or an escape art succeeds |
| Resolved | An end is reached | The caller reads the result; the fight is then discarded |

| Combatant state | Entered when | Leaves when |
|---|---|---|
| Fighting | The fight starts | Health is empty, or its escape succeeds |
| Down: mortal wound | Health is empty | The caller finishes or spares it |
| Fled | Its escape art succeeds | The fight ends |

A Down side acts no more. A ward is not a state: each round it is up if it was cast and paid for.

### Interactions with Other Systems

Artifact Refining, Formations, Talismans, Spirit Beasts, Alchemy, the Event Engine, NPC Builds and
the Living World have no GDD yet (quick specs at most). Rows marked **provisional** hold the contract
this GDD expects, to be matched when those systems are designed.

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| Character Stats (#7) | in / out | In: vitality, spiritual power and divine sense, `attack_pct`, `defense_pct` (as ward strength), `khi_huyet_pct`, `linh_luc_pct`, `than_thuc_pct`, `artifact_power_pct`, the artifact-local keys, `single_artifact`, resistance keys, the realm term of power, the vitality factor floor. Out: vitality loss after a fight, `+2` heart demon on a kill with capability #9 | Character Stats (keys, units); Combat (what each key does in the fight) |
| Realms & Bottlenecks (#8) | in / out | In: realm, stage multiplier, the realm gap `g`. Out: defeats for capability #9, and the result for a tribulation | Realms |
| Cultivation Techniques (#9) | in | `tech_power` (through spiritual power), the unlocked divine abilities with their unlock layer, and `t_b` from body techniques (**provisional**) | Cultivation Techniques (which and when); Combat (what they do) |
| Meridian Map (#10) | in | Only the stat modifiers, through Character Stats. Combat hosts no capability behaviour: each capability has one host, and an effect such as #1 or #3 reaches Combat only as the artifact values its host supplies. For #9, Combat only reports the defeat | Meridian Map |
| The Way (#39) | in | Passive modifiers through Character Stats; art nodes once this GDD fixes the art format (**provisional**; arts stay on hold until it is approved) | The Way; Combat (art format) |
| Artifact Refining (#16) | in | Equipped artifacts: attack, defense (ward, or body guard if body-tagged), affixes, thần thức cost, an optional active effect (**provisional**) | Artifact Refining; Combat (how they act) |
| Formations (#17) | in | A laid formation's modifiers, upkeep and ground tags (**provisional**) | Formations |
| Talismans (#18) | in | Consumable arts and their tags (**provisional**) | Talismans |
| Spirit Beasts (#19) | in / out | In: the companion power share and fixed art. Out: a beaten creature offered for taming (the Event Engine hook) (**provisional**) | Spirit Beasts |
| Alchemy (#15) | in | Pills with timed buff or cleanse effects taken in preparation | Alchemy |
| Event Engine (#23) | in / out | In: a fight request with the enemy, the situation (foreseen, ambush, blind) and the ground tags. Out: the result | Event Engine (requests, consequences); Combat (the result) |
| NPC Builds (#24) | in | An NPC's compiled profile, art list and a generated priority list | NPC Builds |
| Living World Tick (#28) | in | Mass battles via the rating profile. It must keep NPC-against-NPC duels rare | Living World; Combat (rating profile) |
| Heavenly Tribulation (#22) | out | The fight engine and its result, with a tribulation as an enemy profile (the system after this one) | Heavenly Tribulation |
| Time & Turn (#4) | in | A fight takes no seasons itself; the time of preparation is the preparing system's | the preparing system |
| World Database (#3) | out | The event record of a notable fight | World DB |
| Balance Harness (#33) | out | A headless fight run and the rating-profile clash | Balance Harness |
| Debug Terminal (#36), Game UI (#37) | out | The fight log and the preparation screen's data | the presentation system |

## Formulas

All values are provisional until the Balance Harness confirms them (Open Questions). The win rates
below come from a one-pool simulation with no rotation, statuses or triggers, so they show
direction, not final odds. Keys live in `combat_rules.json`.

### A. Fight unit, health and linh lực

The fight_unit formula is defined as:

`U_r = B_p[r] ^ fight_unit_exponent`

The pool_max formula is defined as:

`n_k = clamp(stat_k / ref_k[r], pool_n_min, pool_n_max)` ; `health_max = health_rounds · U_r · n_body · boss_pool_mult` ; `qi_max = qi_rounds · U_r · n_qi · boss_pool_mult` ; `health_start = health_max · max(v, v_c)` ; `ehp = min(health_max / (pass · f), health_max / f + qi_max / drain)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| B_p[r] | float | 100 / 1,000 / 10,000 / 100,000 / 1,000,000 | data file (`power_base`, Character Stats) | Realm power base |
| fight_unit_exponent | float | 0.35–0.5, default 0.4 | data file | Sets the realm gap |
| U_r | float | 6.31 / 15.85 / 39.81 / 100 / 251.19 | calculated | Fight unit of realm r |
| stat_k | float | ≥ 0 | calculated (Character Stats Formulas C) | vitality_max and spiritual_power; each already holds stage_mult, talent and pct keys. Divine sense is read raw for soul attacks and is not a pool |
| ref_k[r] | float | body 450 / 1,800 / 6,750 / 22,500 / 67,500; qi 100 / 800 / 6,000 / 50,000 / 400,000 | calculated from Character Stats data | The stat of a talent-45, stage-1.00, no-bonus character |
| n_k | float | 0.25–8 | calculated | Relative pool size |
| pool_n_min, pool_n_max | float | 0.25, 8 | data file | Bounds on absurd stacks |
| health_rounds | float | 12–22, default 16 | data file | Health in fight units; smaller than linh lực, so most staying power sits in the ward |
| qi_rounds | float | 18–36, default 26 | data file | Linh lực in fight units |
| boss_pool_mult | float | 1–10, default 1 | data file (enemy profile) | Bosses and tribulations only; applied after `pool_n_max`, to both pools (rule 18) |
| v, v_c | float | 0.05–1; 0.4 | calculated; data file (`duel.injured_power_floor`) | Vitality fraction and its floor |
| pass, drain, f | float | see D | calculated | Ward pass share, drain rate, and what gets through body guard |
| ehp | float | ≥ 0 | calculated | Effective health before art spending and regeneration: health alone if it dies with the ward still up, otherwise health plus what the linh lực can block |

`round_limit` is 40. After a fight, `v_after = min(v, health_end / health_max)`, so a fight never heals.
The caller applies Character Stats' floor rules.

**Why not the full base.** Fight power F is damage × ehp. If both scaled with B_p, F would rise ×100 per
realm and no build could cross a realm. With exponent 0.4 the base gap is ×6.3 per realm, and the extra W
and technique power a higher realm holds lift it to about ×10, the concept's "roughly 10× power per
major realm".

**Output Range:** health runs from 25 to about 32,150 and linh lực from 41 to about 52,250, before
`boss_pool_mult`. Only health ends a fight.

**Example:** typical at Qi Refining, n_body 1.0883, n_qi 1.053: health = 16 × 6.31 × 1.0883 = **109.9**;
linh lực = 26 × 6.31 × 1.053 = **172.7**. At v = 0.7 health starts at 76.9. At v = 0.3 the floor applies
and it starts at 43.9.

### B. Layers

The layer_total formula is defined as:

`x1_eff = x1 if x1 ≤ l1_soft_start, else l1_soft_start + l1_soft_slope · (x1 − l1_soft_start)` ; `L1 = 1 + min(x1_eff, cap_1)/100` ; `L_i = 1 + min(x_i, cap_i)/100` for i = 2 to 5 ; `M = L1 · L2 · L3 · L4 · L5`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| x_i | float | ≥ −90 for L1 (penalties such as low vitality); ≥ 0 for the others (percentage points) | calculated | Sum of layer i's modifiers whose required tags are all in the hit's tags |
| l1_soft_start, l1_soft_slope | float | 200, 0.5 | data file | Past +200, each point of Increased counts half |
| cap_1 to cap_5 | float | 400 / 300 / 250 / 150 / 100 | data file (`layer_caps`) | Hard caps |
| M | float | 0.1–350 | calculated | Offence multiplier; crit is separate |

| # | Layer | Filled by |
|---|---|---|
| L1 | Increased | `attack_pct` from Character Stats (Meridian Map and Way W, 1 W = +1), and "increased" tags. **W fills only this layer** |
| L2 | Art "more" | Tag-keyed modifiers on techniques, arts and Way art nodes, authored at 5–50 points each |
| L3 | Gear | `100 · Σ artifact attack / (B_p · stage_mult)`, with each artifact's attack after `artifact_power_pct` and its other multipliers, as built |
| L4 | Preparation and ground | Formations, talismans, pills, coatings, ground tags (rule 12). When blind, x4 holds ground tags only |
| L5 | Trigger and conversion | "While" and "after" effects, applied only while active |

**Output Range:** anchors per realm, all at stage 1.00. These are targets until real builds are measured.
W shares are attack / ward strength / ward efficiency / linh lực / health.

- **Typical:** 25 / 5 / 5 / 5 / 10 %, L2–L5 at 1.4, 1.4, 1.2, 1.1, artifact defence 0.85 × B_p, mean art
  coefficient 1.6 at 15 % crits of ×1.7, ward pass 0.45 and drain 1.25 (means of kinds).
- **Top-end:** 45 / 10 / 7.5 / 7.5 / 20 %, L2–L5 at 4.0, 3.5, 2.5, 2.0, artifact defence 5 × B_p, 50 % crits
  of ×2, ward pass 0.35 and drain 0.9.
- **Thể tu:** attack 45 %, body guard 25 %, health 20 %, body gear 5 × B_p, body technique 3, default ward.

| Realm (end) | Tree W | Typical M | Typical ehp (U) | Typical mirror, rounds | Top-end M | Top-end ehp (U) | Top-end mirror, rounds |
|---|---|---|---|---|---|---|---|
| Qi Refining | 106 | 3.27 | 47 | 7.6 | 103 | 125 | 1 |
| Foundation Establishment | 248 | 4.19 | 56 | 6.7 | 148 | 163 | 1 |
| Core Formation | 447 | 5.48 | 73 | 6.7 | 210 | 217 | 1 |
| Nascent Soul | 739 | 7.37 | 94 | 6.5 | 256 | 315 | 1 |
| Deity Transformation | 1,172 | 8.96 | 127 | 7.0 | 325 | 460 | 1 |

An unbuilt mirror (M = 1, basic attack only, default ward) lasts about 25 rounds, inside `round_limit`.
Mirror rounds come from a simulation with no soul arts, statuses or triggers.

**Example:** typical at Qi Refining: L1 1.265 × 1.4 × 1.4 × 1.2 × 1.1 = **3.27**.

### C. Hit damage

The hit_damage formula is defined as:

`base = U_att · stage_att · c_art` ; `part_j = base · s_j · M(T_j) · crit` ; `D_j = part_j · supp` ; `dealt_j = max(1, leak_j · (1 − m · guard_share_kind))` ; `overkill = max(0, dealt_total − health_before) / health_max`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| c_art | float | basic 1.0; arts 1.2–5 | data file (`basic_coef`, art record) | Art coefficient. Lint: `c_art ≤ basic_coef · (1 + art_coef_per_cost · cost_share) + art_coef_per_cooldown · cooldown` |
| art_coef_per_cost, art_coef_per_cooldown | float | 12, 0.25 | data file | Art power is paid for in linh lực and cooldown |
| s_j | float | 0–1, Σ = 1 | calculated | Share of the hit in conversion part j |
| T_j | tag set | — | calculated | A converted part keeps its old tags and gains the new (rule 6) |
| crit | float | 1 or `crit_mult` | calculated | Rolled once per hit. Chance = `clamp(crit_base + Σ crit_chance_pct/100, 0, crit_chance_cap)`; `crit_mult = min(crit_mult_base + Σ crit_damage_pct/100, crit_mult_cap)` |
| crit_base, crit_chance_cap | float | 0, 0.5 | data file | Base chance is 0, so a build with no crit is deterministic (rule 15) |
| crit_mult_base, crit_mult_cap | float | 1.5, 3.0 | data file | Crit multiplier |
| supp | float | 0.25–1 | calculated (H) | Realm suppression |
| leak_j | float | ≥ 0 | calculated (D) | What the ward lets through |
| m, guard_share_kind | float | 0–0.86; body 1.0, qi 0.75 | calculated (D); data file | Body guard |

Order: the evade roll (an evaded hit deals nothing, drains nothing and fires no on-hit trigger), conversions
(at most 2 per hit, fixed order; the kind follows the part's final tag), layers per part, one crit roll,
suppression, the ward, body guard, floor. Within step 3 a side pays its own art cost first; hits then
apply one at a time against its live linh lực. Soul attacks skip all of this (Formulas E2).

**Output Range:** at least 1 per part. Unbounded above except through `M` ≤ 350 and crit ≤ 3.

**Example:** Qi Refining, stage 1.00, c_art 2.0, typical M 3.27: base 12.62, D **41.3**. Against the
Formulas D ward the body hit deals **15.9** and drains 18.5 linh lực; with the ward off it deals **38.5**.
On a ×1.7 crit the warded hit deals **27.0**. Conversion: base 100, Fire +30 %, Lava +40 %, 40 % converted:
0.6 × 1.3 + 0.4 × 1.7 = 1.46, so **146** against 130.

### D. Ward and body guard

The ward formula is defined as:

`pass_raw = clamp(pass_kind + Σ pass_tag, pass_min, 1)` ; `pass = max(pass_min, pass_raw / (1 + ws/100))` ; `drain = max(drain_min, drain_kind / (1 + we/100))` ; `blocked = min(D · (1 − pass), pool_qi / drain)` ; `qi_loss = blocked · drain` ; `leak = D − blocked` ; `ws = min(ward_cap, defense_pct + Σ ward_strength + 100 · ward_gear_scale · a_w)` ; `we = min(ward_cap, ward_efficiency_pct + 100 · ward_gear_scale · a_w)`

This is the default **drain** model. A ward record may name another `cost_model`: **per hit** pays
`hit_cost_share · (1 − we/(100 + we)) · qi_max` for each hit and blocks `D · (1 − pass)` if it can pay, whatever
D is; **per round** pays `upkeep_share`, reduced the same way, when it is cast. A ward that cannot pay blocks
nothing that hit or round. Further models are added by data and a matching rule here.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| D | float | ≥ 1 | calculated (C) | The part after layers, crit and suppression |
| pass_kind, drain_kind | float | spell pass 0.2–0.55, drain 0.6–1.5 | data file (ward record) | Per kind. A common ward is pass 0.54 body and 0.36 qi, drain 1.0 body and 1.5 qi, so body hits leak more and qi hits burn more linh lực |
| default_ward_pass, default_ward_drain | float | 0.70, 2.0 | data file | The ward anyone has; every warding spell beats it |
| pass_tag | float | −0.25 to +0.25 | data file (ward record) | Element or form resistance; a Fire ward may be −0.2 on Fire and +0.1 on Water |
| ws, we | float | 0–400 | calculated | Ward strength and efficiency |
| defense_pct | float | ≥ −100 | calculated (Character Stats) | Now means ward strength, so tree nodes keep their W price |
| ward_efficiency_pct | float | ≥ 0 | calculated (new key, 1 W per point is a guess) | Costs less |
| a_w | float | ≥ 0 | calculated | Artifact defence without the body tag / (B_p · stage_mult) |
| ward_gear_scale | float | 0.30 | data file | Artifact defence 0.85 × B_p gives +25.5 to both ws and we |
| pass_min, drain_min | float | 0.05, 0.15 | data file | A ward never blocks everything or runs free |
| ward_cap | float | 400 | data file | Cap on ws and we |
| hit_cost_share, upkeep_share | float | 0–0.10 | data file (ward record) | Costs of the other models |

The body_guard formula is defined as:

`g_b = min(guard_cap, (guard_base + a_b + t_b + guard_pool_slope · (n_body − 1)) · (1 + body_guard_pct/100) · (1 − shred))` ; `m = guard_max_mit · g_b / (g_b + guard_half)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| guard_base | float | 0.15 | data file | Anyone's flesh |
| a_b | float | ≥ 0 | calculated | Defence of body-tagged items / (B_p · stage_mult). An artifact feeds a_w or a_b, never both |
| t_b | float | 0–5 | calculated (body technique records) | Luyện thể techniques |
| guard_pool_slope | float | 0.15 | data file | Physique's share, through n_body |
| body_guard_pct | float | ≥ −100 | calculated (new key, 1 W per point is a guess) | The W lever |
| shred | float | 0–0.5 | calculated | Curse reduction |
| guard_cap | float | 40 | data file | Ceiling on guard |
| guard_max_mit, guard_half | float | 0.90, 2.0 | data file | Mitigation approaches 0.90 and never reaches 1 |
| guard_share_kind | float | body 1.0, qi 0.75 | data file | Qi partly gets past flesh, the thể tu's weakness |

**Output Range:** pass 0.05–1, drain 0.15 and up, and `qi_loss` never exceeds the pool; the excess leaks. m runs
0.063 to 0.857.

**Being a mortal, in numbers.** With no ward, 94 % of a hit lands on an unbuilt character, 93 to 88 % on a
typical one, and 25 to 15 % of a body hit on a thể tu, from Qi Refining to Deity Transformation.

**Example:** typical at Qi Refining, ws = we = 30.8, common ward, D 41.3. Body: pass 0.413, drain 0.765, blocked
24.25, linh lực lost **18.5**, leak 17.05, and m 0.068 leaves **15.9**. Qi: pass 0.275, drain 1.147, blocked
29.9, linh lực lost **34.3**, **10.8** dealt. A body hit with 10 linh lực left: blocked 13.1, **26.3** dealt.
A thể tu at Qi Refining: (0.15 + 8 + 0.03) × 1.265 = 10.35, so m = **0.754**.

### E. Linh lực

The art_cost formula is defined as:

`cost = cost_share · (1 − cost_red) · (1 + cost_raise) · qi_max` ; `affordable if pool_qi ≥ cost − 1e-6` ; `regen = qi_max · min(regen_base + regen_bonus, regen_cap)` per round ; `body_cost = body_cost_share · health_max`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| cost_share | float | 0.04–0.25 | data file (art record) | Share of maximum per use |
| cost_red | float | 0–0.5 | calculated (new key `art_cost_pct`) | Sustain build's reduction |
| cost_raise | float | 0–0.5 | calculated | Curse raise |
| regen_base | float | 0.02 | data file | Regeneration per round |
| regen_bonus | float | 0–0.06 | calculated (new key `linh_luc_regen_pct`) | Sustain bonus |
| regen_cap | float | 0.08 | data file | Regeneration ceiling |
| body_cost_share | float | 0.02–0.08 | data file (art record, optional) | An art paid in health; the art lint counts it as 2 × `cost_share`. It is not damage and cannot take health below 1 |

**Output Range:** linh lực runs 0 to `qi_max`. A side may spend itself to 0.

**Example:** typical at Qi Refining, `cost_share` 0.15 costs 25.9 and regeneration is 3.45. With nothing incoming the art
fires **7 rounds**. In a mirror with the ward on, it fires **4 rounds**, then the basic attack, and the
ward is nearly empty from round 5.

### E2. Soul attacks

The soul_attack formula is defined as:

`rho = divine_sense_att / (divine_sense_def · (1 + soul_res_pct/100))` ; `pct = 0 if rho < rho_min, else min(soul_pct · (1 + x_soul/100) · rho^soul_beta · supp, soul_cap)` ; `health_loss = pct · health_max / boss_pool_mult` ; `qi_loss = pct · qi_max / boss_pool_mult`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| soul_pct | float | 0.03–0.08 | data file (art record) | Share of maximum at equal souls; a guess |
| x_soul | float | ≥ 0 | calculated | Soul-tagged modifiers, so a soul build has something to stack |
| soul_beta | float | 2 (1.5–3) | data file | Steepness: a big gap is frightening and parity is small |
| rho_min | float | 0.25 | data file | Below this the attack cannot touch the soul |
| soul_res_pct | float | 0–100 | calculated (new key) | Way nodes and rare items |
| soul_cap | float | 0.30 | data file | Most one hit can take |
| supp | float | 0.25–1 | calculated (H) | Suppression applies, and pierce works on it |

Wards, body guard, evade and crit do not apply. Cost and cooldown are the art's own. Percent is taken on the pools
before `boss_pool_mult`, so a ×8 boss loses at most 3.75 % a hit.

**Output Range:** 0 to 0.30 of each pool per hit.

**Example:** `soul_pct` 0.05: equal souls take **5 %** of maximum health and linh lực; a soul twice the defender's
takes **20 %** (22.0 health and 34.5 linh lực at the typical Qi Refining pools); three times is capped at **30 %**;
half takes **1.25 %**; a fifth takes **0**.

### F. Over-time statuses and curses

The status_tick formula is defined as:

`tick = clamp(U_src · stage_src · c_tick · stacks · L1..L4(tags) · supp · (1 − m · guard_share_kind), 1, dot_pool_cap · health_max)` ; `p_status = chance` when chance is 0 or 1, otherwise `clamp(chance · (1 − resist), 0.05, 0.95)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| c_tick | float | 0.15–0.5 per stack | data file (status record) | Lint: `c_tick · duration ≤ 1.2 · c_art` of an equal-cost art |
| stacks, stack_cap | int | 1–5; 5 | calculated; data file | Stacks on the target |
| duration | int | 2–6 | data file (status record) | Rounds |
| dot_pool_cap | float | 0.05 | data file | One tick is never above 5 % of maximum health |
| curse_slots | int | 3 | data file | Most curses on one target |
| resist | float | 0–0.9 | calculated (new key `status_resist_pct`) | Target's resistance to statuses |

Ticks work inside the ward: it does not block them, and body guard applies. A **qi burn** status ticks linh lực
instead, capped at 5 % of `qi_max`. A duration counts ticks and falls at each tick, so duration 3 ticks three
times. A tick uses the source's values from when it was applied.

Curse bounds: body guard shred ≤ 0.5 (shreds add), ward pass raised at most ×1.5, drain raised at most +50 %, art
cost raise ≤ +50 %, one layer locked for ≤ 2 rounds (it counts as 1.0), a tag blocked for ≤ 3 rounds (arts
carrying it cannot fire, and modifiers needing it do not apply), regeneration blocked or not, duration ≤ 5. A
curse past `curse_slots` replaces the one with the least duration left.

**Output Range:** a tick is at least 1 and at most `dot_pool_cap` of maximum health.

**Example:** poison, c_tick 0.3, 3 stacks, L1 × L2 = 1.77, typical target: 6.31 × 0.3 × 3 × 1.77 × 0.932 = 9.4, capped
to **5.5 per round** on 109.9 health.

### G. Triggers

The trigger_budget formula is defined as:

`free_hit = U · stage · c_trig · L1..L4(tags) · supp`, then the ward and body guard as any hit ; `Σ trigger_damage ≤ trig_budget · max(direct_damage_this_round, 0.5 · U · stage)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| c_trig | float | ≤ 0.8 | data file | Free-hit coefficient; a chance trigger needs `chance · c_trig ≤ 0.5` |
| trigger_depth | int | 2 | data file | Chain depth, the first trigger being 1; one trigger id never fires twice in a chain |
| trig_cap | int | 6 per side | data file | Firings per round |
| trig_budget | float | 0.5 | data file | Trigger damage is at most half of the round's direct damage |
| trig_ward_strength | float | 50 (guess) | data file | A ward trigger adds this to ws until the end of the next round |

A refund trigger returns at most the fired art's cost, which is now also defence.

**Output Range:** triggers add at most +50 % of the round's direct damage, or 0.25 · U · stage when that is
larger. Overflow is clipped and logged as "trigger budget".

**Example:** typical, c_trig 0.5, through the body ward: **3.6**. Six of them make 21.7, clipped to 0.5 × 15.9 = **7.9**.

### H. Realm suppression

The suppression formula is defined as:

`supp(g, P) = 1 − s_g · (1 − P)` ; `P = min(pierce_cap, Σ pierce_pct / 100)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| g | int | 0–4 | calculated (Realms) | Major realms the actor is below its target; no bonus for being higher |
| s_g | float | 0 / 0.10 / 0.25 / 0.50 / 0.75 | data file (`suppression`) | Reduction by gap |
| pierce_pct | float | ≥ 0 (percentage points) | calculated (new key) | Modifiers with the pierce tag |
| pierce_cap | float | 0.75 | data file | Pierce ceiling |

**Output Range:** `supp` runs 0.25–1.

**Targets (user decision 2026-11-06):** a top-end build wins reliably one realm up, about a coin flip
two realms up, and never three up. Simulated with the Formulas B anchors at stage 1.00, top-end with
pierce 0.5, against a typical build, with no soul arts, statuses or triggers:

| Gap | Top-end win rate by starting realm | Target | Thể tu |
|---|---|---|---|
| g = 1 | 100 / 100 / 100 / 100 % | ≥ 95 % | 100 % |
| g = 2 | 54 / 54 / 60 % | 40–75 % | 0 / 0 / 18 % |
| g = 3 | 0 / 0 % | ≤ 2 % | 0 % |

A typical build wins 0 % one realm up. **The two-realm result is sensitive:** top-end damage ±20 % moves it between
17 % and 76 %, because these fights last a few rounds. At the same realm a top thể tu beats a top-end
ward build about 75 % of the time (49 % at Deity Transformation); the user chose to measure this with real builds
first (Open Question 17).

**Example:** g = 2, P = 0.5: 1 − 0.25 × 0.5 = **0.875**.

### I. Evade, escape and fortune

The chance_roll formulas are defined as:

`p_evade = clamp(evade − accuracy + evade_realm_step · max(0, r_def − r_att), 0, evade_cap)` ; `p_escape = clamp(e_art + escape_realm_step · (r_esc − r_purs) − escape_lock_penalty · lock + escape_bonus, 0.05, 0.95)` ; `p' = p + (eff(khi_van_self) − eff(khi_van_other)) · khi_van_per_point` when 0 < p < 1, added before each roll's own cap

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| evade, accuracy | float | 0–1 | calculated (new keys `evade_pct`, `accuracy_pct`, ÷ 100) | Evade applies to body and qi hits only, never soul hits or ticks |
| evade_cap, evade_realm_step | float | 0.40, 0.02 | data file | Bounds |
| e_art | float | 0.40–0.70 | data file (art record) | Escape art base |
| escape_realm_step, escape_lock_penalty | float | 0.10, 0.15 | data file | Realm and lock terms |
| escape_bonus | float | 0–0.3 | calculated | Modifiers with the escape tag |
| lock | int | 0 or 1 | calculated | The pursuer has a lock tag |
| khi_van_per_point | float | 0.001 | data file (kept from `duel`) | **User decision 2026-11-06:** fortune shifts every crit, evade, status, trigger and escape roll |

A chance of exactly 0 or 1 is not shifted and takes no draw, so a build with no chance effects stays
deterministic. Draws run in a fixed order: the requesting side first, then per hit evade, crit, status,
then triggers. If both sides escape in one round, the fight ends in flight with no winner. If the other
side goes Down in that round, the fight ends as a win, not a flight.

**Output Range:** evade 0–0.40; escape 0.05–0.95.

**Example:** evade 0.25, accuracy 0.05, defender one realm up: **0.22**. A 30-point fortune lead
adds 0.03 to it, so **0.25**. Escape art 0.55, one realm below a locking pursuer: **0.30**.

### J. Companions and creatures

The companion_hit formula is defined as:

`c_comp = min(c_comp_cap, share / (B_p · stage_mult))` ; `companion_hit = U_owner · stage_owner · c_comp · M(companion tags) · supp`, then the ward and body guard as any hit

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| share | float | ≥ 0 | calculated (Spirit Beasts, `BeastKeeper.power_shares`) | The beast's power share |
| c_comp_cap | float | 1.0 (guess) | data file | A companion never out-hits a basic attack before layers |
| creature_mult | float | 1.1 | data file (replaces `beast.power_mult`) | A creature enemy has `base` and pools × 1.1, applied with `boss_pool_mult` |

A companion hit takes the kind of its art, can be evaded, cannot crit, has a floor of 1 and counts as
direct damage.

**Output Range:** `c_comp` runs 0–1. A companion hits once per round for no linh lực (rule 19).

**Example:** share 40 at Qi Refining, stage 1.00: c_comp = 0.4, so D = 6.31 × 0.4 × 3.27 = 8.26, which deals **3.2** through the typical ward.

### K. Rating profile and power score

The rating_clash formula is defined as:

`Off = U · stage · c_avg · M · crit_EV`, with `crit_EV = 1 + chance · (crit_mult − 1)` and `c_avg = basic_coef + (c_art_avg − basic_coef) · uptime` ; `D = Off · (1 − p_evade) · supp` ; `t_w = qi / (D · (1 − pass) · drain + net_spend)` ; `t_h = health / (D · pass · f)` ; `T0 = t_h if t_h ≤ t_w, else t_w + (health − t_w · D · pass · f) / (D_late · f)` ; `T = T0 / (1 + pi_s · T0)` ; `R = T_(B→A) / T_(A→B)` ; `P(A wins) = clamp(1 / (1 + R^(−κ)) + (eff(khi_van_A) − eff(khi_van_B)) · khi_van_per_point, 0.02, 0.98)`

For a force: `N_eff = min(N, mass_width) + mass_reserve_weight · max(0, N − mass_width)`. Members are ranked by
`display_power`, and a force's Off, health and linh lực are its weighted member means × N_eff, with weighted means of
pass, drain and f, so numbers count squared in R. A force's realm for `g` and its fortune are its leader's.

The power_score formula is defined as:

`display_power = B_p · sqrt(F / F_unbuilt)`, where `F = Off · ehp`.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| uptime | float | 0–1 | calculated | Share of rounds the priority list fires an art |
| c_art_avg | float | 1–5 | calculated | Mean coefficient of the arts the priority list fires |
| net_spend | float | any | calculated | Own mean art cost minus regeneration, per round |
| f | float | 0–1 | calculated | `1 − m · guard_share_kind`, share-weighted over kinds |
| D_late | float | ≥ 0 | calculated | The attacker's D at `basic_coef` if its own linh lực runs out first |
| pi_s | float | 0–0.3 | calculated | Soul attack `pct / (cooldown + 1)` |
| κ | float | 12–16, default 14 | data file (`rating_kappa`) | One-on-one steepness: a 10 % edge wins about 79 %, a 20 % edge about 93 % |
| kappa_mass | float | 4 (guess) | data file | Force steepness; wars keep more upsets |
| mass_width, mass_reserve_weight | int, float | 12, 0.25 | data file | The first 12 members count fully, the rest at a quarter |
| F_unbuilt | float | — | calculated | F of an unbuilt stage-1.00 character of that realm |

If the denominator of `t_w` is 0 or less, the ward never runs out and `T0 = t_h`.

`display_power` replaces today's chiến lực total wherever one number is shown or stored: screens, NPC
records and beast power shares. An unbuilt character shows about B_p. Rating profiles are cached and
rebuilt only when a build changes.

**Output Range:** P is 0.02–0.98. One roll decides a clash.

**Example:** a typical Qi Refining mirror: Off 36.51, pass 0.344, drain 0.956, f 0.932, health 109.9, linh lực 172.7,
net spend 6.91. t_w 5.80, t_h 9.39, T0 **7.77**, against 7.6 simulated. Forces of 40 against 20 identical members:
N_eff 19 against 14, R = 1.84, κ 4, P = **92 %**.

**Agreement test.** Pairs come from the harness's build generator, each side with at least one chance
effect, because a chance-free pair gives the same result under every seed. Over 200 seeds per pair, for
pairs with R of 0.5–2.0, the mean |P_rating − P_full| ≤ 0.10, and for R outside 0.9–1.1 no pair is off by
more than 0.20. Outside 0.5–2.0 the two pick the same winner in at least 97 % of pairs. The point where a
ward runs out makes this harder near R = 1.

### Parameter keys

New in `combat_rules.json`: every `data file` value above. New stat keys for Character Stats, all in
percentage points: `crit_chance_pct`, `crit_damage_pct`, `evade_pct`, `accuracy_pct`, `pierce_pct`,
`art_cost_pct`, `linh_luc_regen_pct`, `status_resist_pct`, `ward_efficiency_pct`, `body_guard_pct`,
`soul_res_pct`. `defense_pct` now means ward strength.

**Removed from `combat_rules.json`:** `power.base_offense_share`, `power.base_defense_share`,
`power.cong_phap_share` (tech_power acts through linh lực, and arts come from techniques),
`power.khi_huyet_weight`, `power.linh_luc_weight`, `duel.ratio_exponent`, `duel.rounds`. Kept:
`duel.injured_power_floor`, `duel.khi_van_per_point`, `duel.min_win_chance`, `duel.max_win_chance` (the
last two for the rating clash only). `beast.power_mult` becomes `creature_mult`.

## Edge Cases

**Ending a fight**

- **If both sides lose all health in the same round:** rule 10 step 6 decides the winner.
- **If a tick at round start empties health:** the defeat check runs at once and a Down side takes no
  action that round. If both sides go Down from ticks, step 6's tiebreak applies.
- **If the fight reaches `round_limit`:** it is a stalemate with no winner. Each side keeps what it has
  left, and the caller applies any health loss as usual.
- **If neither side can hurt the other:** the damage floor of at least 1 per part still applies, so
  health falls until a side is Down or `round_limit` is reached.
- **If a side escapes in a round it also takes a lethal hit:** damage applies first. A side that is
  Down at the end of step 3 does not flee, because an escape cannot dodge the blow that ends the fight.
- **If an escape art fails:** its linh lực cost and cooldown are still paid, and the fight goes on.

**Health, linh lực and wards**

- **If a pool stat is 0 or very low:** `n_k` stops at `pool_n_min`, so both pools have a size.
- **If vitality is below `v_c`:** health starts at `v_c` of its maximum (Formulas A).
- **If a side spends all its linh lực on arts in a round:** its ward blocks nothing against that round's
  hits, because its own cost is paid first.
- **If a hit needs more blocking than the linh lực can pay:** it blocks what the pool allows, the pool
  reaches 0 and the rest leaks.
- **If linh lực is 0 at the start of a round:** regeneration from the last round still applies, so a
  drain ward blocks only that small amount.
- **If a per-hit or per-round ward cannot pay:** it blocks nothing for that hit or round, and it is
  tried again next time.
- **If the player switches the ward off:** no ward cost is paid and only body guard stands. The ward
  stays off for the whole fight unless a priority rule casts one by hand.
- **If regeneration is blocked by a curse:** linh lực does not rise until the curse ends.
- **If `attack_pct` goes below −90 from penalties:** L1 stops at 0.1, so a hit is never negative.
- **If a soul attack is below `rho_min`:** it deals nothing, but its cost and cooldown are paid.
- **If a soul attack drains linh lực to 0:** the ward has nothing to block with, as with any other loss.
- **If a creature has no `divine_sense`:** its profile must state one; the data lint rejects a profile
  without it.

**Arts, tags and triggers**

- **If a priority list is empty or no rule fires:** the side uses the basic attack every round.
- **If a character has no usable main method:** it has no divine abilities and fights with its other
  arts and the basic attack.
- **If a rule names a talisman with no stock left:** the rule counts as not ready and the list moves on.
- **If an art's tag or a modifier's tag is unknown:** the data lint rejects it at load, and it never
  reaches a fight.
- **If conversions on a hit total over 100 %:** shares are scaled down to 100 %. A conversion to the
  tag a part already has does nothing. A third conversion on a hit is ignored, and the log says so.
- **If triggers exceed `trigger_depth`, `trig_cap` or `trig_budget`:** the excess is dropped or clipped
  and logged, in the fixed order of rule 9.
- **If two statuses with "the stronger wins" have equal strength:** the one already on the target stays.

**Preparation and setup**

- **If a fight is blind:** x4 holds ground tags only, even when a prepared item is in the bag.
- **If the ground has several tags:** each applies independently through rule 6.
- **If a pill is taken in preparation and the player then leaves before confirming:** nothing is spent.
  The preparation step consumes pills on confirm, and the caller decrements talismans the result lists.
- **If a fight is reloaded and repeated with the same setup:** it gives the same result, because the
  seed comes from the world seed and the fight id, which the caller issues and saves with the event.
  Changing the setup changes the fight.
- **If a side would hold more than one cultivator:** the full fight does not support it. The Event
  Engine sends a sequence of duels or a mass battle (Open Questions).

**Realm and companions**

- **If a creature has no realm of its own:** its profile states an equivalent realm for `g`.
- **If `Σ pierce_pct` exceeds `pierce_cap`:** it stops at `pierce_cap`.
- **If the actor's realm is higher than its target's:** `g` is 0, and there is no bonus beyond its
  own larger fight unit.
- **If the owner of a companion goes Down:** the companion stops acting and takes no injury in this version.

**Degenerate strategies watched for**

- **Stalling to `round_limit` with pure defence:** a stalemate gives no win. The Event Engine treats a
  stalemate or a flight as the failure branch for the side that needed the win.
- **Reloading to re-roll a fight:** blocked by the fixed seed unless the setup changes, and then only
  a build's own chance effects can move.
- **Chaining triggers for unbounded damage:** blocked by the three trigger limits (Formulas G).

## Dependencies

**Upstream (Combat needs these).**

| System | Type | Interface | State |
|---|---|---|---|
| Character Stats (#7) | Hard | Pool stats, stat keys, resistances, vitality | GDD in review. 11 new stat keys, the fortune line and the `defense_pct` meaning added 2026-11-06 |
| Realms (#8) | Hard | Realm, `stage_mult`, `power_base`, gap `g` | GDD in review |
| Cultivation Techniques (#9) | Hard | `tech_power`, unlocked divine abilities | GDD in review. Its Open Question 3 is answered here once abilities are authored |
| Sim Core (#2), Config (#1) | Hard | Seeded stream, `Breakdown`, `combat_rules.json` | Built, no GDD |
| Meridian Map (#10) | Soft | Stat keys through Character Stats only | GDD in review |
| The Way (#39) | Soft | Passive modifiers; art nodes after this GDD is approved | GDD approved. Art pricing is open (its Open Question 3) |
| Artifact Refining (#16) | Soft | Equipped artifacts, defence by kind, active effects | Quick spec only; **provisional** |
| Formations (#17), Talismans (#18), Alchemy (#15) | Soft | Prepared modifiers, consumable arts, timed pills | Quick spec or no GDD; **provisional** |
| Spirit Beasts (#19) | Soft | Power share, companion art | Quick spec only; **provisional** |

**Downstream (these need Combat).**

| System | Type | Interface | State |
|---|---|---|---|
| Heavenly Tribulation (#22) | Hard | The fight engine, a tribulation as an enemy profile | Not designed; waits on this GDD |
| Event Engine (#23) | Hard | Fight request, result | Built, no GDD; today's `duel` callers move to the result |
| NPC Builds (#24) | Hard | Compiled profile, generated priority list | Built, no GDD |
| Living World Tick (#28) | Hard | Rating clash; keeps NPC duels rare | Built, no GDD |
| Balance Harness (#33) | Hard | Headless fights, the agreement test | Built, no GDD |
| Debug Terminal (#36), Game UI (#37) | Soft | Log, preparation data, `display_power` | Terminal built, Game UI not started |
| World DB (#3) | Soft | Notable fight record | Built, no GDD |

**Bidirectional check.** Character Stats, Realms, Cultivation Techniques, the Meridian Map and the Way
already list Combat. No circular dependency is added:
the assets expose read-only contributions, and hooks such as taming stay with the Event Engine
(systems index, circular dependency 2).

## Tuning Knobs

These are the values that must live in `combat_rules.json` and never in code. Defaults are in Formulas.
Safe ranges are left out on purpose (user decision 2026-11-06): with no techniques, arts or enemies yet,
any range would be a guess. Add them after the first Balance Harness run on real builds. Values owned
elsewhere, such as `power_base` and `attack_pct` prices, stay in their own GDDs.

| Knobs | What they affect |
|---|---|
| `fight_unit_exponent` | The gap between realms |
| `health_rounds`, `qi_rounds`, `round_limit` | Fight length, and how much staying power sits in the ward |
| `basic_coef`, `art_coef_per_cost`, `art_coef_per_cooldown` | Art power against its cost |
| `l1_soft_start`, `l1_soft_slope`, `layer_caps` | How far a build can scale |
| `crit_chance_cap`, `crit_mult_cap`, `evade_cap` | How swingy fights are |
| `default_ward_pass`, `default_ward_drain`, `ward_gear_scale`, `ward_cap` | How much wards block and cost |
| `guard_base`, `guard_pool_slope`, `guard_max_mit`, `guard_half`, `guard_cap`, `guard_share_qi` | The thể tu's strength and weakness |
| `regen_base`, `regen_cap` | Sustain |
| `stack_cap`, `dot_pool_cap`, `curse_slots` | Status strength |
| `trigger_depth`, `trig_cap`, `trig_budget` | Combo strength |
| `suppression`, `pierce_cap` | Crossing realms |
| `soul_beta`, `rho_min`, `soul_cap` | How dangerous a soul gap is |
| `rating_kappa`, `kappa_mass`, `mass_width`, `mass_reserve_weight` | Mass battle outcomes |
| `boss_pool_mult` (per enemy) | Boss toughness |

**Knobs that move together.**

- `fight_unit_exponent`, `layer_caps`, `suppression`, `health_rounds` and `qi_rounds` jointly set the
  realm-crossing targets (Formulas H). Change one and re-run all the checks.
- `health_rounds` and `round_limit` must keep an unbuilt mirror inside the limit.
- After a change to the tree's W totals, re-measure the anchors in Formulas B.

## Visual/Audio Requirements

Today's surface is the Debug Terminal, so these are the terminal's needs plus intent for the Game UI
(#37), to be settled there. Art and audio assets are deferred with those systems.

- **Terminal.** Each threat kind has its own colour on its damage lines, and each line also names the kind,
  so nothing depends on colour alone. Critical hits, linh lực running out and a fight's end are marked
  in the log.
- **Game UI intent.** A fight plays as an ink scroll that unrolls round by round, with health and linh lực in
  the print layer and never in the brushwork (art pillar "Numbers in print"). Art tags map to
  glyphs (art pillar "Glyphs, not paintings"), so a new art needs no hand-painted asset.
- **Events that need a visual and a sound later:** hit by kind, ward block, critical hit, status applied,
  trigger fired, conversion, linh lực spent out, escape, fight end.

## Game Feel

The fight is read, not played, so feel means pacing and clarity. **The moment that matters is seeing your
build work.**

- **Before the fight:** preparing is the tense part. The player should finish it knowing what their
  plan is and what could beat it.
- **During the fight:** a typical fight of 7–8 rounds reads in under a minute at the default log level.
  One line per round; the player can open any hit's Breakdown.
- **After the fight:** the result names the deciding factor: when linh lực ran out and which layer did
  the most. A loss must point at something the player can change.
- **Top-end payoff:** a one-round win over an ordinary enemy shows the whole multiplied Breakdown, so
  the number itself is the reward.
- **Upsets are rare and earned.** With no base damage spread, a surprising result comes from a build's
  own chance effects, and the log shows that.

## UI Requirements

| Screen or element | Must show | Must allow |
|---|---|---|
| Preparation | The situation (foreseen, ambush, blind), the enemy's profile as far as Open Question 4 allows, the player's health, linh lực, ward, body guard and loadout, and what each prepared item adds | Slot arts, choose the ward and switch it on or off, set the priority list, use prepared items, confirm |
| Priority list editor | Rules in order, each rule's condition and art, and which rule would fire now | Add, remove, reorder; choose conditions from the fixed vocabulary |
| Fight log | One line per round: actions, damage by kind, what the ward blocked, health and linh lực after | Open a hit's full Breakdown; switch between summary and full log |
| Result | Winner, how it ended, rounds, resources spent, the deciding layer | Continue to the caller's consequences |
| Character sheet | `display_power`, health, linh lực, ward strength and efficiency, body guard, thần thức, layer totals | Open the breakdown |

All of these work in the Debug Terminal first, with numbered menus as elsewhere. The Advisor should warn
when a build would be left with no ward and under 0.2 body guard mitigation after a typical fight's linh
lực use (Guidance, #35; the threshold is a guess).

> **📌 UX Flag — Combat:** this system has UI requirements. In Pre-Production, run `/ux-design` for the
> preparation screen, priority list editor and fight log before writing epics. Stories that touch
> this UI should cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD | Refers to | Mechanic or value | Note |
|---|---|---|---|
| Rule 3, Formulas A, E2 | character-stats.md Formulas C | `vitality_max`, `spiritual_power`, `divine_sense`, vitality floor 0.4 | Read only |
| Formulas B | character-stats.md | Additive pct stacking, `attack_pct`; low-vitality and heart-demon modifiers | Read only |
| Formulas I | character-stats.md (the fortune table) | Fortune line | Edited 2026-11-06: fortune now shifts chance rolls |
| Formulas C, D, E, E2, F, H, I | character-stats.md stat keys | 11 new keys, `defense_pct` as ward strength | Added 2026-11-06 |
| Rule 20, Formulas A, H | canh-gioi.md | `power_base`, `stage_mult`, the realm ladder | Read only |
| Rule 14 | canh-gioi.md rule 16; character-stats.md | Capability #9: defeat reported, +2 heart demon | See Open Question 12 |
| Rule 13, Formulas A, D | cong-phap.md rules 13–14, Formulas C | Divine abilities, `tech_power`, body techniques (`t_b`), the technique line | `cong_phap_share` line removed; cong-phap.md rule 14 and AC-CP-39 edited 2026-11-06 |
| Formulas B | kinh-mach-do.md Formulas A and A2; registry `stat_power_weights` | 1 W = +1 %; about 106 W to 1,172 W by realm end | W stays additive |
| Rule 13, Formulas B | dao.md rule on arts, Open Question 3 | Art format, `dao_premium` | Arts remain on hold until this GDD is approved |
| Formulas J | design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Beast power share | Provisional |
| Rule 12 | design/quick-specs/luyen-khi-and-tran-phap.md | Formation and artifact inputs | Provisional |

## Acceptance Criteria

Drafted by qa-lead, then updated by the main session for the rulings after its report and for the rework to one health bar and wards. The rework has not been through qa-lead. Performance budgets are proposals
and have not been measured.

Evidence: Logic tests under `tests/unit/combat/`, Integration tests under `tests/integration/combat/`,
Balance Harness output under `production/qa/evidence/balance/`, terminal evidence under
`production/qa/evidence/debug-terminal/`.

**Fixtures.** Values are the `combat_rules.json` defaults at full precision, with no rounding between
steps. Tolerance is ±0.01 unless stated.

- **FX-T (typical Qi Refining):** B_p 100, stage 1.00, U 6.30957. Layer points 26.5 / 40 / 40 / 20 / 10, so M
  3.27279. n_body 1.08833, n_qi 1.053, so health 109.87 and linh lực 172.74. Common ward (pass 0.54 body, 0.36 qi;
  drain 1.0 body, 1.5 qi), ws = we = 30.8, so body pass 0.4128 and drain 0.7645. Body guard g 0.1633, m 0.0679.
  One body art: c_art 2.0, cost_share 0.15, cooldown 0. No chance fields.
- **FX-U (unbuilt Qi Refining):** talent 45, stage 1.00, no bonuses, technique power 1.0, basic attack only, default
  ward. Health 100.95, linh lực 164.05, m 0.0628.
- **FX-C (chance fixture):** FX-T plus crit chance 0.30 at ×2.0, evade 0.20, one status at chance 0.50, one
  trigger at chance 0.50, and an escape art.

**Fight shell and determinism**

- **AC-CB-01** [Logic] Rules 1, 15. Given FX-C against FX-C with one seed, when the fight runs twice in one process and once more after 50 unrelated fights, then the results and serialized logs are byte-identical. Given 20 different seeds, at least two logs differ.
- **AC-CB-02** [Logic] Rule 15. Given a world seed and fight id, when the fight stream is built twice, then its first 10 draws match, and a different fight id gives different draws. Given any outer `RandomNumberGenerator`, when a fight runs, then that generator's state is unchanged.
- **AC-CB-03** [Logic] Rule 15. Given two builds whose chance fields are all 0 or 1, when they fight under 100 seeds without reaching the tiebreak, then all logs are identical except the seed field. Given the same hit in two rounds with the same state, then its damage is equal.
- **AC-CB-04** [Logic] Formulas I, fortune. Given a roll spy: evade 0.22 with a +30 lead rolls at 0.25; evade 0.40 with a +99 lead stays at `evade_cap`; escape stops at 0.95 and 0.05; crit stops at `crit_chance_cap`. Given chance 0 and chance 1 with leads of ±99 over 1,000 seeds, then neither is shifted, neither takes a draw, the chance-0 effect never fires and the chance-1 effect always fires.
- **AC-CB-05** [Logic] Rules 2, 21. Given the fight engine source, when scanned, then it has no `Time.`, `OS.`, `Node`, `get_tree` or autoload reference. Given a character, when `compile` runs twice, then the profiles are equal and the serialized character is unchanged. The fight runs under `--headless` with no scene tree.
- **AC-CB-06** [Logic] Rules 1, 14. Given a character and world DB fixture, when a fight runs, then both serialize unchanged and the world clock has not moved. The call returns synchronously. The result holds the winning side, how it ended (knockout, stalemate or flight), rounds, each side's end health and linh lực, resources spent, the deciding layer and the log.

**Profile and pools**

- **AC-CB-07** [Logic] Rules 2, 18. Given a cultivator, a creature and an NPC, when compiled, then all three return the same schema: health and linh lực maxima, thần thức, ward, body guard, layered modifiers, art loadout, triggers, tag set. Given a new enemy added only as fixture JSON, when it fights, then the fight completes with no code change.
- **AC-CB-08** [Logic] Formulas A. Given `power_base` at the defaults, then U is 6.31 / 15.85 / 39.81 / 100.00 / 251.19.
- **AC-CB-09** [Logic] Formulas A. Given FX-T's stats, then health is 109.87 and linh lực 172.74. Given stat 0, then n is 0.25, health 25.24 and linh lực 41.01. Given Deity Transformation at n ≥ 8, then health is 32,152.1 and linh lực 52,247.2 (±0.5).
- **AC-CB-10** [Logic] Rule 3, Formulas A. Given FX-T, v 0.7 starts health at 76.91, v 0.3 at 43.95, v 1.0 at 109.87; linh lực starts full. Given a fight ending with health at 50 % and v 0.7, then `v_after` is 0.5; ending at 90 %, it stays 0.7.
- **AC-CB-11** [Logic] Rules 3, 4. Given a body, a qi and a soul attack, when each lands, then the body and qi attacks meet the ward and then body guard, and the soul attack meets neither. Given health at 0, then the side is Down: mortal wound and acts no more. Given linh lực at 0 and health above 0, then the fight goes on.
- **AC-CB-12** [Logic] Formulas D, ward. Given FX-T and D 41.30: a body hit blocks 24.25, drains 18.54, leaks 17.05 and deals 15.89; a qi hit drains 34.33 and deals 10.79; a body hit with 10 linh lực left blocks 13.08 and deals 26.30, and the pool ends at 0.
- **AC-CB-13** [Logic] Formulas D, bounds. pass never falls below 0.05 and drain never below 0.15. ws and we stop at 400. Given g_b 40 or higher, then m is 0.8571. Given a thể tu fixture of g_b 10.35, then m is 0.754. Given `body_guard_pct` −100, then g_b and m are 0.

**Layers and hits**

- **AC-CB-14** [Logic] Rule 5. Given FX-T, then M is 3.2728 and the Breakdown has one line per layer. Given two +10 in L2, then L2 is 1.20. Given +10 in L2 and +10 in L3, then L2 × L3 is 1.21.
- **AC-CB-15** [Logic] Formulas B. x1 200 gives L1 3.00; x1 293 gives 3.465; x1 1,000 gives 5.00; x1 −120 gives 0.1 and a positive hit; all layers over their caps give M 350.
- **AC-CB-16** [Logic] Formulas B anchors. Given x1 at 25 % of W for 106 / 248 / 447 / 739 / 1,172 W and L2–L5 at 1.4, 1.4, 1.2, 1.1, then M is 3.27 / 4.19 / 5.48 / 7.37 / 8.96. Given 45 % of W and L2–L5 at 4.0, 3.5, 2.5, 2.0, then M is 103.4 / 148.1 / 210.4 / 256.4 / 324.6.
- **AC-CB-17** [Logic] Formulas B, L3. Given Σ artifact attack 40 at B_p 100, then x3 is 40 at stage 1.00 and 27.59 at stage 1.45. Given a W-priced key, when compiled, then it fills L1 and leaves L2–L5 unchanged.
- **AC-CB-18** [Logic] Rule 6. Given a modifier requiring {fire, sword}, then it applies to a {fire, sword, hit} hit and not a {fire, palm, hit} hit. Given ground with two tags, then each applies independently.
- **AC-CB-19** [Logic] Rule 6, Formulas C. Given base 100, Fire +30 and Lava +40 in one layer, 40 % converted, then the hit is 146 against 130. Given a body-to-qi conversion of 40 %, then each part uses its own kind's ward pass, drain and `guard_share_kind`. Given a ward with a Fire `pass_tag`, then a converted part with Fire and Lava tags still gets it.
- **AC-CB-20** [Logic] Edge cases. Conversions totalling 120 % scale to 100 %. Converting to a tag the part has does nothing. A third conversion is ignored and logged. A tag is not converted back in the same hit.
- **AC-CB-21** [Logic] Formulas C. Given FX-T's art against FX-T, then base is 12.62, D 41.30 and dealt 15.89. With the ward off, 38.50. With g 2 and P 0.5, dealt is 13.91.
- **AC-CB-22** [Logic] Formulas C, crit. A ×1.7 crit on AC-CB-21 deals 27.02. Summed chance 0.7 stops at 0.5. Summed multiplier 3.4 stops at 3.0. A two-part hit takes one crit draw. A build with no crit bonus never crits.
- **AC-CB-23** [Logic] Formulas C, floor and overkill. Given an attacker with M 0.1 against FX-U, then a part deals at least 1, and a two-part hit at least 1 per part. Given health_before 10, dealt 30, health_max 100, then health stops at 0 and overkill is 0.20.

**Round loop**

- **AC-CB-24** [Logic] Rule 10. Given a step spy, then each round logs in order: round-start triggers, ticks, choices, simultaneous apply, triggers, regeneration with cooldowns and durations, defeat check.
- **AC-CB-25** [Logic] Rule 10. Given a drain that would make B's art unaffordable in the same round, then B's art still fires from the snapshot. Given two sides that would each knock out the other, then both hits land. Given chance-free fixtures with A and B swapped, then the winner and pools mirror. Given a side's art cost and an incoming hit in one round, then the cost is paid first and the ward uses what remains.
- **AC-CB-26** [Logic] Rule 10 step 6. Given both sides at 0 health: overkill 0.30 against 0.10 means the 0.10 side wins; equal overkill with A's linh lực share 0.6 and B's 0.4 at round start means A wins; all equal means the draw decides, the same seed gives the same winner, and over 1,000 seeds each side wins 45–55 %. The winner stands at 1 health.
- **AC-CB-27** [Logic] Rule 22. Given an autocast ward, then it is cast in step 2 of every round at no action cost. Given a ward switched off, then no ward cost is paid, no hit is blocked, and body guard still applies. Given a hand-cast ward, then it is up only after a priority rule fires it.
- **AC-CB-28** [Logic] Rule 10 step 1. Given a tick that empties health, then the defeat check runs before step 2 and no action is logged that round. Given ticks that down both sides, then AC-CB-26's chain applies.
- **AC-CB-29** [Logic] `round_limit`. Given two attackers dealing 1 damage a round with health 41, then 40 rounds play and the fight is a stalemate with 1 left on each side. Given one side starting at 39.37, then it empties in round 40 and that is a defeat.
- **AC-CB-30** [Logic] Formulas B. Given FX-U against FX-U, then the fight ends in round 25 through the draw. Given FX-T against FX-T, then four art rounds and four basic rounds end it in round 8 through the draw, with linh lực under 10 from round 4.
- **AC-CB-31** [Logic] Rules 11, 23. Given a side that spends all its linh lực in a round, then its drain ward blocks nothing against that round's hits. Given regeneration of 3.45 the next round, then the ward blocks at most what 3.45 can pay. Given no linh lực, then no linh lực art fires, and an art with `body_cost_share` still fires and cannot take health below 1.

**Arts and linh lực**

- **AC-CB-32** [Logic] Rule 13. Given a three-rule list, then the first rule whose condition is true and whose art is ready and affordable fires; with none, the basic attack fires. An empty list uses the basic attack every round. A condition outside the fixed vocabulary is rejected at load. An art with cooldown 2 fired in round 1 next fires in round 4.
- **AC-CB-33** [Logic] Rule 13, edge cases. Given a talisman with stock 1, then it fires once and its rule then counts as not ready. Given no usable main method, then the character fights with its other arts and the basic attack, a body-kind hit at coefficient 1.0.
- **AC-CB-34** [Logic] Formulas E. Given cost_share 0.15 at `qi_max` 172.74, then the cost is 25.91 and regeneration 3.45, and with nothing incoming the art fires 7 rounds. Given pool exactly equal to the cost, the art fires. Regeneration never passes 8 %, and the pool never exceeds its maximum.
- **AC-CB-35** [Logic] Rule 11, edge cases. Given a regeneration curse, linh lực does not rise until it ends. Given a soul attack that empties linh lực, the ward then blocks nothing. No rule stops a side spending to 0.
- **AC-CB-36** [Logic] Formulas I, escape. Given e_art 0.55, one realm below a locking pursuer, then p is 0.30. A failed escape pays its cost and cooldown. A success gives Fled and a flight result. A side Down at the end of step 3 does not flee. If both escape, the fight ends in flight with no winner. If the other side goes Down that round, it is a win.
- **AC-CB-37** [Logic] Formulas I, evade. Evade 0.25, accuracy 0.05, defender one realm up gives 0.22. Evade 0.60 stops at 0.40. Evade below accuracy gives 0. At evade 0.40, soul hits and ticks are never evaded over 1,000 rolls. An evaded hit deals nothing and fires no on-hit trigger.

**Statuses**

- **AC-CB-38** [Logic] Rule 7, Formulas F. Given poison at c_tick 0.3, 3 stacks, L1 × L2 1.771, against FX-T, then the raw tick is 9.37 and it stops at the cap of 5.49. The ward blocks nothing and drains nothing from a tick. A tick is never below 1. A qi burn ticks linh lực, at most 5 % of `qi_max`.
- **AC-CB-39** [Logic] Rule 7, edge cases. Refresh resets duration without adding stacks. Stack-to-cap stops at 5. With stronger-wins, a weaker status is refused and an equal one leaves the existing status. A duration-3 status ticks three times.
- **AC-CB-40** [Logic] Rule 8, Formulas F. Shred 0.5 halves g_b; shreds add and stop at 0.5. Pass is raised at most ×1.5 and drain at most +50 %. The other bounds hold. No curse lowers health or linh lực. A matching cleanse removes it; a non-matching one does not. A fourth curse replaces the one with the least duration left. A cost raise of +50 % raises an art's cost by half.
- **AC-CB-41** [Logic] Formulas F. Chance 0.8 with resist 0.5 gives 0.40. Chance 0.02 gives 0.05. Chance 1.0 stays 1.0 and chance 0 stays 0, whatever the resist.

**Triggers**

- **AC-CB-42** [Logic] Formulas G. Given c_trig 0.5 against FX-T, then a free hit deals 3.61 through the ward. Given six free hits and direct damage 15.89, then trigger damage is clipped to 7.95 and the log says "trigger budget". Given direct damage 0, then the budget is 1.58. A ward trigger adds `trig_ward_strength` to ws until the end of the next round.
- **AC-CB-43** [Logic] Rule 9, Formulas G. Given a trigger loop A to B to A, then the fight terminates and no id fires twice in a chain. A chain stops at depth 2, counting the first trigger as 1. The seventh firing in a round is dropped and logged. Each event in rule 9 fires its fixture trigger. A refund returns at most the art's cost.

**Realm and companions**

- **AC-CB-44** [Logic] Formulas H, rule 20. supp(0, 0) is 1, supp(1, 0) 0.90, supp(2, 0.5) 0.875, supp(3, 0) 0.50, supp(4, 0) 0.25. `pierce_pct` 90 stops at P 0.75. An actor above its target has g 0 and supp 1.
- **AC-CB-45** [Logic] Rule 19, Formulas J. Given share 40 at Qi Refining against FX-T, then c_comp is 0.4 and the hit deals 3.18. Share 500 caps c_comp at 1.0. The companion hits once a round for no linh lực, cannot crit or be targeted, can be evaded, and stops when its owner is Down.
- **AC-CB-46** [Logic] Rule 18, Formulas A, J. An FX-U creature has health 111.05, linh lực 180.45 and base damage ×1.1. A creature with no realm uses its stated equivalent for g. Given n 8 and `boss_pool_mult` 10 at Qi Refining, then health is 8,076.3 and linh lực 13,123.9 (±0.5). A top-end build needs at least 4 rounds against a boss.

**Preparation**

- **AC-CB-47** [Logic] Rule 12, edge cases. Given an item adding x4 +30: foreseen accepts everything and L4 is 1.30; ambush accepts talismans, ready pills and a standing formation, and refuses a new formation or coating; blind accepts only the loadout and list, and L4 is 1.00 with no ground tags. Each accepted item appears in the opening Breakdown.
- **AC-CB-48** [Integration] Edge cases. Given a pill chosen in preparation, when the player backs out, then stock is unchanged; on confirm it is consumed once. Given a save, a fight, a reload and the same setup and fight id, then the result is identical. Given a changed setup on FX-C, then the log differs.

**Rating profile**

- **AC-CB-49** [Logic] Formulas K. Given Off 36.51, pass 0.344, drain 0.956, f 0.932, health 109.87, linh lực 172.74, net spend 6.91, then t_w is 5.80, t_h 9.39 and T0 7.77 (±0.02). Given a net spend and drain that sum to 0 or less, then T0 is t_h. R 0.5 clamps P to 0.02 and R 2 to 0.98. At κ 14, R 1.1 gives 0.792 and R 1.2 gives 0.928. A +30 fortune lead adds 0.03.
- **AC-CB-50** [Logic] Formulas K, forces. N 40 gives N_eff 19, N 20 gives 14, N 12 gives 12, N 13 gives 12.25. Forces of 40 against 20 identical members give R 1.84 and P 0.920 at κ 4. One clash takes one draw, and the same seed gives the same outcome.
- **AC-CB-51** [Logic] Formulas K, power score. An unbuilt stage-1.00 character shows `display_power` equal to B_p. A build with 4 × F_unbuilt shows 2 × B_p. c_avg with basic 1.0, c_art_avg 2.0, uptime 0.5 is 1.5.
- **AC-CB-52** [Integration, Bot: Balance Harness] Agreement test. Given at least 100 sampled pairs from the harness's build generator, each side holding a chance effect, at 200 seeds each: for R 0.5–2.0, mean |P_rating − P_full| ≤ 0.10, and for R outside 0.9–1.1 no pair is off by more than 0.20. Outside 0.5–2.0 the two pick the same winner in at least 97 % of pairs. Output goes to `production/qa/evidence/balance/[date]-combat-agreement.md`.

**Balance Harness**

- **AC-CB-53** [Integration, Bot: Balance Harness] Formulas H. Given top-end at pierce 0.5 against typical, with the Formulas B anchors at stage 1.00, at least 200 runs per cell: g 1 wins at least 95 % from each of four starting realms; g 2 wins 40–75 % from each of three; g 3 wins at most 2 % at P 0.5 and 0.75; a typical build wins at most 2 % one realm up. Run once with no soul arts, and report a second run with them (Open Question 16). Output goes to `production/qa/evidence/balance/[date]-combat-realm-crossing.md`.
- **AC-CB-54** [Integration, Bot: Balance Harness] Formulas A, B. With the rotation stated in the run header: typical mirrors last 6.5–7.6 rounds (±1), top-end mirrors end in round 1 or 2, an unbuilt mirror ends inside `round_limit`, and F rises about ×10 per realm for typical builds. Given a boss with its `boss_pool_mult`, a top-end build needs at least 4 rounds.
- **AC-CB-55** [Integration, Bot: Balance Harness] Rule 20. Given equal W, an all-attack build (L2–L5 at 1.0) one realm up wins at most 2 %, and a top-end multi-layer build wins at least 95 %.

**Data**

- **AC-CB-56** [Config] Parameter keys. `combat_rules.json` is valid JSON and holds every Formulas `data file` key. These are gone: `power.base_offense_share`, `power.base_defense_share`, `power.cong_phap_share`, `power.khi_huyet_weight`, `power.linh_luc_weight`, `duel.ratio_exponent`, `duel.rounds`. These stay: `duel.injured_power_floor`, `duel.khi_van_per_point`, `duel.min_win_chance`, `duel.max_win_chance`. `beast.power_mult` is `creature_mult`.
- **AC-CB-57** [Config] Data lint. c_art at cost_share 0.15, cooldown 0: 2.80 passes, 2.81 fails. At 0.25, cooldown 4: 5.00 passes. An L2 modifier of 4 or 51 points fails. c_tick · duration above 1.2 · c_art fails. c_trig 0.81 fails. chance · c_trig: 0.625 × 0.8 passes, 0.7 × 0.8 fails. An unknown tag is rejected at load. A modifier with no layer, or with two, fails.
- **AC-CB-58** [Config] Knob invariant. At `round_limit` 40, `health_rounds` 26 passes and 27 fails for an unbuilt mirror under the default ward.

**Cross-system integration**

- **AC-CB-59** [Integration] Character Stats. Given a real sheet with `attack_pct` +26.5, `defense_pct` +16, `khi_huyet_pct` +30, `linh_luc_pct` +20, then compile's pools equal Formulas A applied to `CharacterRules.khi_huyet_max` and `.linh_luc`, x1 is 26.5, and `defense_pct` reaches ws and not body guard. An artifact over thần thức capacity adds nothing. The 11 new keys appear in the sheet and its labels.
- **AC-CB-60** [Integration] Cultivation Techniques. Given AC-CP-09's fixture, then the abilities in the profile equal its unlocked list at each step. With no main method at Qi Refining, spiritual power is 50, n_qi 0.5, the qi pool 82.02, and no ability is listed. AC-CP-39 is rewritten first.
- **AC-CB-61** [Integration] The Way. Given a Way node worth +10 `attack_pct`, then x1 rises by 10 and L2–L5 are unchanged. Given a fixture art node in the rule 13 format, then the Way's lint accepts it. (On hold with the arts.)
- **AC-CB-62** [Integration] Event Engine request. Given a combat choice carrying enemy, situation and ground tags, when resolved, then a win takes the success branch, and a loss, a stalemate and a flight take the failure branch, and the check line shows how it ended and the rounds.
- **AC-CB-63** [Integration] Consequences stay with the caller. Given each ending, then vitality loss applies once, by the caller. The caller decides mercy. Capability #9 applies per Open Question 12. Taming is offered only by the Event Engine after a won creature fight. A notable fight writes one World DB record. The fight engine imports no writer of these.
- **AC-CB-64** [Integration] Duel callers migrated. `CombatPower.duel` has no callers and `ratio_exponent` is read nowhere, covering `event_resolver.gd`, `world_ticker.gd` and `advisor.gd`. Stored `power` uses (`build_generator.gd`, `state_snapshot.gd`, `world_generator.gd`, `BeastKeeper.power_shares`) read `display_power`. `tools/run-tests.sh` exits 0.
- **AC-CB-65** [Integration, Bot: `world_census.gd`] Living World. Given a headless run of 40 years, then every NPC duel winner comes from a full fight result, a stalemate writes no winner, a sect war resolves through the rating clash, there is no SCRIPT ERROR, and two runs on one world seed give identical news.

**Performance (proposed budgets, not measured)**

These run in the harness, not the gdUnit suite, because testing standards forbid time-dependent assertions there.
Results go to `production/qa/evidence/balance/[date]-combat-performance.md`.

- **AC-CB-66** [Integration, Bot: Balance Harness] Full fight, log on, median of 1,000 runs after 50 warm-ups. An FX-T mirror takes at most 2 ms. A worst-case fixture (40 rounds, `trig_cap` on both sides, 5 stacks, 3 curses, 3 parts, a companion) takes at most 25 ms with a log of at most 256 KB. `compile` takes at most 1 ms.
- **AC-CB-67** [Integration, Bot: Balance Harness] A season at 5,000 cultivators. Against a baseline measured in the same run, combat adds at most 10 ms to the mean season tick over 400 seasons. One clash on cached rating profiles takes at most 0.05 ms. A 500-against-500 clash takes at most 5 ms.

**Terminal and retained evidence**

- **AC-CB-68** [UI] Fight log transcript. Given a scripted fight in the Debug Terminal, then it prints one line per round (actions, damage by kind, ward blocks, health and linh lực after), and on request a hit's full Breakdown: actor, art, tags, kind, every layer's bonuses and total, what the ward blocked and drained, body guard, health and linh lực before and after. It marks crits, linh lực running out and the fight's end. Exit 0, no SCRIPT ERROR. Retained in `production/qa/evidence/debug-terminal/`.
- **AC-CB-69** [UI] Retained screenshot. Given the same fight in a real Windows Terminal window, then each threat kind has its own colour on its damage lines, and each line also names the kind. Retained in `production/qa/evidence/debug-terminal/`.
- **AC-CB-70** [UI] Preparation and priority list. Given a foreseen fight, then the numbered menus show the situation, enemy profile (Open Question 4), own health, linh lực, ward, body guard, loadout and what each item adds. The player can slot arts, choose the ward, switch it off, add, remove and reorder rules, and see which rule would fire now. Retained transcript plus one screenshot per screen.
- **AC-CB-71** [UI] Result and sheet. The result screen shows the winner, how it ended, rounds, resources spent and deciding layer. The sheet shows `display_power`, health, linh lực, ward strength and efficiency, body guard, thần thức and layer totals. The Advisor warning of UI Requirements fires on a fixture build. Retained transcript plus one screenshot per screen.
- **AC-CB-72** [Logic] Rule 22, cost models. Given a per-hit ward with pass 0.5 and `hit_cost_share` 0.05, then a hit of 10 and a hit of 1,000 cost the same linh lực and each blocks half. Given a per-round ward, then it pays once when cast and blocks with no drain. Given a ward that cannot pay, then it blocks nothing for that hit or round and is tried again next time. Given a new `cost_model` not in Formulas D, then it is rejected at load.
- **AC-CB-73** [Logic] Rule 22, ward stats. Given FX-T with ws raised by 10, then pass falls and drain is unchanged, so more is blocked and more linh lực drains per hit. Given we raised by 10, then drain falls and pass is unchanged. Given a default ward and a warding spell in the slot, then only the spell is up. The lint rejects a spell with pass above 0.55 or drain above 1.5.
- **AC-CB-74** [Logic] Rule 23. Given no linh lực, then at least 93 % of a body hit lands on FX-T and at most 25 % on a thể tu fixture with m 0.754. A qi hit on that fixture lands at 43.4 % (`guard_share_qi` 0.75).
- **AC-CB-75** [Logic] Rule 24, Formulas E2. Given `soul_pct` 0.05 and equal souls, then a soul attack takes 5 % of maximum health and of maximum linh lực. Rho 2 takes 20 %, rho 3 stops at 30 %, rho 0.5 takes 1.25 %, rho 0.2 takes 0. Wards, body guard, evade and crit do not apply. It has the art's own cost and cooldown, and can fire in round 1. Given `boss_pool_mult` 8, then a 30 % hit takes 3.75 %. `soul_res_pct` 100 halves rho.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | **Closed 2026-11-06:** the user replaced the three pools with one health bar and wards, so the reserve floor is gone | — | — |
| 2 | **Closed 2026-11-06:** the user confirmed that the thần thức artifacts occupy does not lower the thần thức a side fights with (rule 3) | — | — |
| 3 | **Closed 2026-11-06:** the user confirmed that companions cannot be targeted in this version (rule 19) | — | — |
| 4 | How much of the enemy's profile does the player see while preparing? The working default is all of it (Pillar 2), but no rule states this yet, and scouting by divine sense is an alternative | user | UI Requirements, rule 12 |
| 5 | What do L2–L5 sources cost in W terms? A specialist suggestion is about 25 W per +10 points of "more", untested. The Way's art tier credit needs the same answer | systems-designer | The Way's arts, content authoring |
| 6 | Measure real typical and top-end builds in the Balance Harness, then re-fit Formulas B and H. All anchors are targets from a one-pool simulation. Top-end against two realms up from Qi Refining is 18 %, below the 40–75 % target | systems-designer, Balance Harness | Approval of the numbers |
| 7 | With near-deterministic fights, should preparation show a predicted result? It helps planning and may remove tension. The Advisor's odds preview (`advisor.gd`) needs this answer, since it reads today's duel | user | UI Requirements, Guidance |
| 8 | Fights with more than one cultivator per side are not supported. Are sequences of duels enough, or does a party fight need rules? | user | Event Engine, Sects |
| 9 | `slot_count` per realm has no value yet (rule 13) | systems-designer | Formulas, NPC Builds |
| 10 | Artifacts need a way to mark defence as body-tagged (Formulas D feeds it to body guard, not the ward). Who authors that tag? | systems-designer, Artifact Refining | Formulas D |
| 11 | How rare are NPC duels? The Living World needs a budget per season. Wars also become more decided than today's duel odds; check `kappa_mass` against that | world-builder, Living World | Living World |
| 12 | Capability #9 says "defeating a cultivator" in Realms and "a combat kill" in Character Stats. Which outcome counts, given mercy? | systems-designer | Rule 14 |
| 13 | The divine ability catalogue: what each ability does (Cultivation Techniques Open Question 3) | game-designer | Content pass |
| 14 | Two design intents have no measured target yet: a sustain build should beat a burst build at equal W in long fights (rule 11), and chance effects should rarely change a winner (rule 15). Set the numbers after the first harness run. Also check whether bots over-stack health: 10 W on it adds about 5 % fight length against 2 % for a ward stat | systems-designer | Rules 11, 15 |
| 15 | The fight log's format and float precision (byte-identical logs depend on them), and the terminal command that starts a test fight | gameplay-programmer | AC-CB-01, AC-CB-68 |
| 16 | Soul attack balance waits on real techniques (user decision 2026-11-06). `soul_pct`, `soul_beta` and `soul_cap` are guesses, none of the simulated targets include soul arts, and a higher realm's soul attacks may hurt realm crossing. Rule on which layers a soul build can use once content exists | user, systems-designer | Formulas E2, H |
| 17 | A top thể tu beats a top-end ward build about 75 % of the time at the same realm and rarely crosses two realms. Measure with real builds, then decide (user decision 2026-11-06). The Way's soul-resist nodes and `t_b` values are also unset | systems-designer | Formulas D, H |
| 18 | The ward spell catalogue, including wards with other cost models, and hand-cast wards | game-designer | Content pass |
| 19 | **Closed 2026-11-06:** today's power duel resolves fights while the full fight is on hold (user decision) | — | — |
