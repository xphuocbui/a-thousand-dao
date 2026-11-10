# Combat

> **Status**: Revised 2026-11-10 after the combat review: fatigue is a flat amount growing with n² (not a share of health), `time_limit` and the stalemate are retired, soul resistance may go below 0, ticks have no floor of 1 (user decisions). Revised 2026-11-09 for the Combat economy revision (#44), part 1 (fight length, fatigue, linh lực costs and regeneration, no tick caps; decisions in `design/research/economy-revision-44-decisions.md`; part 2 re-derived the ward-dependent numbers the same day). Earlier: revised 2026-11-08 for the Combat revision (#43): the defence path, wards, shields and healing move to Combat Defence & Healing (#21a); damage types and conversion to Combat Damage Types (#21b); modifier records, operations and scopes to the Modifier System (#40); statuses, curses and the Down step to the Effects System (#41). This GDD keeps the fight frame: the timeline, offence, the defeat check, results and the rating. Earlier: reworked 2026-11-06 to a timeline of seconds with no rounds (user decision); seventh review fixes applied the same day (ward pass clamp, since retired; defeat check judged after all of an instant's damage, a draw on equal overkill, guards read after the pulse), not re-reviewed; ninth-pass fixes applied the same day (wake-up events, ward expiry tie), not re-reviewed. Simulated numbers predate the timeline and are provisional. Earlier: fourth design-review fixes, cooldown timers and hit order, escape step, one health bar and wards
> **Build status**: On hold (user decision 2026-11-06). The full fight is not built until items, techniques, abilities and passives exist. Until then fights keep using today's power duel (`CombatPower`, `combat_rules.json`) unchanged, so the Character Stats and Cultivation Techniques edits that cite this GDD describe the target, not the running game.
> **Author**: user + agents
> **Last Updated**: 2026-11-10 (third review round: tick formula in points, heal-versus-fatigue note, start-maximum art costs, `ward_cap` retired). Earlier: 2026-11-10 (review sweep `reviews/combat-review-2026-11-10/combat.md`: flat n² fatigue, `time_limit` and stalemate retired, soul resistance without a floor, no tick floor (user decisions); stale ACs re-based; resistance in points throughout). Earlier: 2026-11-10 (#44 follow-ups: resistance in points, regeneration curve, re-review fixes)
> **Last Verified**: 2026-11-10 (fourth confirming review, `reviews/combat-review-2026-11-10/round4/`; its fixes applied)
> **Implements Pillar**: Power Is Built, Not Given (3); Your Dao, Your Name (1); Every Number Is Bounded and Visible (2)

## Summary

Combat tests a cultivator's whole build: the player prepares, then the engine resolves a seeded
fight on a timeline of seconds and explains every hit. Khí huyết is the one health bar, linh lực pays for arts and for the wards that cut damage,
and thần thức strikes past every defence except the soul's own, for a share of both pools. Bonuses add inside a layer and multiply
across layers, so an assembled build far outscales a single stacked stat and can win one realm up, or
about half the time two realms up. It replaces today's power-ratio duel, hosts the Way's arts and
Heavenly Tribulation, and collapses to a rating only for wars and great battles.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Combat Defence & Healing, Combat Damage Types, Modifier System, Effects System, Character Stats, Realms, Cultivation Techniques, Meridian Map, Artifact Refining, Formations, Talismans, Spirit Beasts`

## Overview

Combat is where a cultivator's whole build is put to the test. A fight between two
cultivators, or a cultivator and a creature, is prepared by the player and then resolved by the
engine as a deterministic, seeded exchange on a timeline of seconds. Every hit is logged with a Breakdown that
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
  soul, poison), and modifiers key off them. A Dao can convert one damage type to another (Physical to Fire; Combat Damage Types rule 6),
  and "when X happens, do Y" triggers give builds their signature combos (Pillar 1).
- **Eight damage types.** Physical, Force, Fire, Cold, Lightning, Light, Chaos and Soul, plus damage over
  time and curses, so a one-note build gets punished and must answer more than damage (Combat Damage Types).
- **Spiritual power (linh lực) as mana and as defence, and preparation.** Linh lực pays for arts and
  for the wards, which stack: their resistance, block and shields add together and cut most of the damage a
  side takes (Combat Defence & Healing). So every art cast is defence spent. A cultivator out of
  linh lực who is not a body cultivator (thể tu) is little more than a mortal. What is set up before
  the fight (Pillar 4: time and resources spent beforehand) counts as much as what happens in it.

Combat feeds Heavenly Tribulation (Thiên Kiếp), the Event Engine and NPC Builds, and is the system the Way's arts wait on.
Fighting above one's realm (vượt cấp) is possible only through what the build earns, against realm
suppression. The design must stay deterministic from the seed, readable in the Debug Terminal, and
cheap enough for a world of 5,000 NPC cultivators: their individual duels stay rare, and wars settle
through an abstract rating.

## Detailed Design

### Core Rules

Numbers are not set here; named values are defined in Formulas and live in `combat_rules.json`. Rules marked **(assumption)** are the
author's reading and wait for confirmation (see Open Questions).

1. **A fight is two sides and a seeded timeline.** A side is one combatant (a cultivator or a
   creature) plus its attached companions (rule 19). A fight is resolved from its inputs alone: the
   two compiled profiles (rule 2), the preparation (rule 12), the ground tags, any starting shares (rule 3), the request's `no_heal` flag (Combat Defence & Healing rule 19; Heavenly Tribulation sets it on every wave) and one seed. The same
   inputs always give the same result and the same log. Nothing is saved mid-fight; a fight is
   atomic.
2. **Every combatant compiles to a combat profile.** `compile(character or creature, preparation)`
   is a pure function that returns the health and linh lực maxima and the reserved share, thần thức, the wards and ward slots,
   resistances by damage type, block, shields, healing stats, soul and status defence (Combat Defence & Healing),
   the layered modifiers, the art loadout with its derived tags, the triggers and Effects, and the tag set. The full fight and the mass-battle
   form (rule 17) both read the profile, so the player's power and an NPC's stay comparable.
   `compile` replaces today's `CombatPower.compute`, and every stored use of its total moves to
   `display_power` or the profile (Formulas K).
3. **One health bar.** Khí huyết is the only bar that ends a fight. It starts at its maximum × `max(v, 0.4)`,
   where v is the vitality fraction. At 0 the side is **Down** with a mortal wound; whether it dies or is
   spared rests on the caller (rule 14). Linh lực starts at its usable maximum, `qi_max · (1 − Σ reserved)` (Combat
   Defence & Healing rule 10). A fight request may instead carry **starting shares** for health and linh lực (user
   decision 2026-11-06, for Heavenly Tribulation's waves): health then starts at that share of `health_max` and linh lực
   at that share of the usable maximum (Combat revision D6, 2026-11-08), with no vitality floor. Health may rise
   during a fight through healing (Combat Defence & Healing rules 16–19), never above `health_max`; vitality never
   rises. Combat reports the knockout; the caller decides what it costs
   (rule 14). The thần thức that equipped artifacts occupy (Artifact Refining) stays a separate loadout
   limit and does not lower the thần thức a side fights with (user decision 2026-11-06).
4. **Damage types, and the defence path.** Every part of every hit and every tick has one of eight damage types
   (Combat Damage Types rule 1). After offence (rule 5, Formulas C and H), a hit part meets Combat Defence &
   Healing's defence path: evade, then resistance, then block, then shields, then health (that GDD's rule 1).
   Element stacks that change damage taken act on the part before resistance (that GDD's rule 1). A
   tick on health meets resistance and the shields it does not pass, never evade or block. A tick on linh lực (Qi
   Disruption) meets resistance and comes off linh lực, passing every shield. A soul hit meets only soul
   resistance and soul wards (rule 24). Curses carry no damage type and deal no damage (rule 8).
5. **Layers add inside and multiply across.** Every modifier belongs to exactly one layer, fixed by
   its authoring and never chosen in play. Within a layer the bonuses add; across layers the layer
   totals multiply. The layer list is small and fixed in data. **W stays additive:** the Meridian
   Map's and the Way's `attack_pct`-style bonuses keep their W price and fill the first
   (increased) layer exactly as they do today. The other layers are filled by sources priced
   separately: tagged art modifiers, equipment and companions, preparation and ground, and
   Effects (conditions, triggers, conversions with a rule). A hit's damage is `base × Π layers`, and each layer
   appears as a line in the Breakdown (rule 16). Soul attacks are the exception (rule 24). Modifier records,
   operations (flat, increased, more), scopes and W prices are the Modifier System's (its rules 1–8, 12). `more`
   fills L2 and L4 and is budgeted in layer points (Modifier System Formulas D). L3 comes from gear only. L5 is
   granted only as an Effect's payload (Modifier System rule 6; Effects System).
6. **Tags decide what a modifier touches.** Every art, hit, status, modifier and piece of ground has a tag set:
   - **element**: the five elements and the root variants; art tags only, never defence;
   - **form**: sword, palm, seal, beast, formation;
   - **damage type**: physical, force, fire, cold, lightning, light, chaos, soul (owned by Combat Damage Types);
   - **mode**: hit, over_time, curse, ward;
   - **source**: art, artifact, talisman, formation, companion;
   - **effect**: pierce, lock, poison, cleanse, escape, bleed, seal (cleanse tags stay here, Combat revision D17);
   - **derived art tags**: basic, quick, slow, cheap, costly, which compile assigns from an art's authored
     cooldown and cost (Combat revision D5; thresholds in Modifier System rule 10).

   The status family (one tag per status) is the Effects System's, and the full vocabulary is Modifier System
   rule 9. The foe tags (`cultivator`, `creature`) stay Pending: compile does not stamp them on profiles until
   content needs them (user decision CB-08, 2026-11-08). A modifier applies to a hit part when its scope tags are all in that part's tags.

   **Conversion** turns a share of a part's damage type into another (Physical → Fire). It comes from an art, an
   Effect with a condition, or the ordinary modifier `convert_pct`. There are at most 2 per hit, in the steps art,
   then Effects, then modifiers. Element tags never convert, nothing converts to or from Soul, and a type cannot
   convert back in the same hit. A converted part keeps its earlier types as tags for offence modifiers;
   resistance, penetration and block read its final type only. The full rules (order inside a step, one
   conversion per `convert_pct` key, per-part scaling, parts at share 0) are Combat Damage Types rule 6 and
   Formulas A.
7. **Damage over time is a status.** An over-time status has a damage type, tags, a strength, a duration in
   pulses and a stacking rule (Effects System rule 9, which owns the status catalogue). It ticks at every pulse
   and meets the resistance of its type; the attacker's penetration counts, read when the status is applied
   (Combat revision D11). It passes ward shields by default but meets the body shield unless it is Chaos (Combat
   Defence & Healing rules 1, 9; Combat Damage Types rule 7). It never meets evade or block. A tick deals exactly
   what reaches health, with no floor of 1 (user decision 2026-11-10; a hit keeps its floor). A qi burn status (Qi Disruption) ticks linh lực instead. A
   standing status has no duration and is bounded by the standing fee its caster pays (Effects Formulas B). Combat
   keeps the tick formula (Formulas F). **Element stacks** (a buff on yourself, a debuff on the foe, per element) are the
   Effects System's (rule 9a): their batch timers fall at each pulse, and a cleansing ward removes its share then. Ticks have no cap, on health or on linh lực (user decision 2026-11-09,
   #44 item C3): resistance and cleansing answer them. Each tick is an ordinary line in the log.
8. **Curses are statuses that change rules, not pools.** A curse can lower resistance, soul resistance or
   healing taken, lock one layer, raise an art's cost or a drain ward's bill, dampen linh lực and health
   regeneration (Modifier System rule 6a), or block a tag (Formulas F). Curse units are percentage points: Slackened Soul is −15 pp per
   stack, 2 stacks so −30 pp (Combat revision D12), and soul resistance has no floor: below 0 it amplifies soul
   hits (Formulas E2; user decision 2026-11-10). The curse catalogue is
   the Effects System's. It has a duration and a source and
   can be cleansed by an art or a talisman with a matching cleanse tag. A curse never
   reduces health or linh lực by itself.
9. **Triggers: "when X, do Y".** A trigger is an event, plus a condition, a limit (per pulse, per fight, or a
   cooldown) and an action from the Effects System's closed action list (its rule 6). Trigger records are Effects;
   Combat keeps the event list, the order and the limits.
   - **Trigger events** (user decision CB-03, 2026-11-08; the same list as Effects System rule 5's events): a hit
     landing, being hit, a crit, an evade, a knockout, an art fired, a status applied, a pulse, a pool crossing a
     threshold, a shield breaking, a named cap clipping (`cooldown_min`, a layer cap, regeneration lost at a full pool and
     the others an Effect names), ward payments made against your hits, and the Down step (step 1, a refusal; step
     2, a last act). Everything else an Effect may read (shares, counts, tags, the realm gap, sheet values) is a
     read-only quantity (Effects System rule 5) and never sets a trigger off.
   - **Order.** Triggers resolve by event time; within one event, the requesting side's first (rule 10); within a
     side, by the slot order of the host that carries them (slotted hosts first, then hosts with no slot, as in
     Combat Damage Types rule 6), then by record id. A trigger set off by a trigger resolves right after the one
     that set it off, at most to `trigger_depth`, and the per-pulse trigger count is capped, so no build can loop
     forever.
10. **The timeline.** A fight runs in simulated seconds from t = 0 until one side is Down, a draw or a flight (fatigue guarantees it; no time limit since 2026-11-10), with no rounds (user
    decision 2026-11-06). Times are whole milliseconds, never floats, so two events tie only in the same millisecond, and no real clock is involved (rule 21). An art's effective cooldown rounds to the nearest millisecond (half up), and its timer restarts as the firing time plus that value. Every other time key (`pulse_interval`, `basic_cooldown`, `escape_channel`, `soul_lockout`, `recharge_delay`, `fatigue_start`) is authored in seconds and rounded the same way at load. The engine always
    resolves the next scheduled event: an art firing, a basic attack, a companion hit, a pulse, an escape
    resolving or a **wake-up** (below). Both sides share one clock.
    - **Wake-ups (review fix 2026-11-06).** Some things stop an art that is otherwise ready, and each ending is a
      scheduled event, so a waiting art fires in the instant its blocker ends, not at whatever event comes next: a
      `soul_lockout` ending (rule 24); the fight time reaching a time guard's threshold (rule 13); an escape
      channel ending (already the escape event). A wake-up joins the instant at its millisecond and adds nothing but
      the chance for waiting arts to fire, in the art-cost step. The expiry of a cast ward (its
      authored duration, Combat Defence & Healing rule 7) or of an Effect's timed ward change (Combat revision D9)
      is also a scheduled time, but it fires nothing: a ward **stays up through the whole millisecond it expires
      in** (user decision 2026-11-06), so hits in that instant meet it, and it is Expired from the next
      millisecond. A trigger's own cooldown ending is a wake-up (Effects System, States).
    - **Start.** Linh lực is at its start (rule 3); reservations are taken and standing wards are Up; cast wards
      are Waiting until their first firing (Combat Defence & Healing rules 7, 10). Every art's timer starts at its full effective
      cooldown (rule 13), so nothing fires at t = 0. The basic attack and the companion first act at
      `basic_cooldown`, and the first pulse is at `pulse_interval`.
    - **Pulse.** Every `pulse_interval`: pulse triggers fire (counted in the window that is ending, so nothing they do counts toward the
      next); standing statuses take their caster's standing fee before they tick (Effects Formulas B); over-time
      statuses tick; status and curse durations fall; sides that are not Down regenerate linh lực and health;
      **fatigue** strikes from `fatigue_start` (below); and the per-pulse limits reset (`trig_cap`, the trigger
      budget). Healing and ticks have no per-pulse cap (#44 items C1, C3). A status or curse applied
      between pulses first counts at the next one. A tick may take health to 0 or below, but nothing ends the
      fight until the instant's defeat check (see Same instant).
    - **Firing.** An art fires the moment its timer has ended, its guard is true and its cost can be paid. The
      **guard is read once the instant's pulse has resolved and before any art cost is paid** (user decision
      2026-11-06), so a tick that opens the instant can switch it and a hit landing later in the same instant
      cannot; **affordability is read live**, as each slot pays in slot order, so a later
      slot sees what an earlier slot paid. Its cost is paid then and its timer restarts (rule 13).
    - **Hit.** A hit lands at once, against the defender's live linh lực, its parts in conversion order.
      Each part then meets the defence path (Combat Defence & Healing rule 1).
      Triggers it sets off resolve right after it, in the fixed order of rule 9. A side whose health has fallen
      to 0 or below keeps acting until the instant ends (see Same instant).
    - **Same instant.** Events at exactly the same time form one **instant**, resolved in this order: the
      pulse; both sides' art costs, in slot order; the **requesting side's** hits; the other side's hits;
      escapes. The requesting side is the one the Event Engine names as opening the fight, the player's side
      when the player did, else side A. A side's hits in an instant follow the **hit order**: arts in slot
      order, then the basic attack, then the companion. **All of an instant's damage is calculated before anyone
      is judged** (user decision 2026-11-06): health may fall to 0 or below during the instant, and the pulse's
      ticks, both hit lists and the triggers they set off all resolve in full. Only the defeat check decides who is
      Down, so neither side gains by being first and a double knockout stays possible. Random draws follow the
      same order (Formulas I).
    - **Follow-up instants (user decision 2026-11-06).** Guards are read at the start of an instant (see Firing), so a
      hit can make a waiting art eligible only after the fact (an escape art guarded on own health below 30 %, a
      refund that makes an art affordable). If the fight is not over after an instant's defeat check, every art
      that is ready, whose guard is now true and whose cost can now be paid fires in a **follow-up instant at the
      same t**, with the same order (art costs, the requesting side's hits, the other side's hits, escapes) and no
      pulse. Follow-ups repeat until no art can fire. Each firing restarts that art's timer, so each art fires at
      most once per timer and the loop ends. A follow-up is not a new event: it does not move the clock, and its
      draws continue the same order (Formulas I).
    - **Escape.** An escape art pays its cost when it fires and starts a channel of `escape_channel` seconds,
      during which hits keep landing. A side has **one channel open at a time** (user decision 2026-11-06): while it
      is open no escape art of that side fires, and a ready one waits. When the channel ends, a side with health above 0 rolls its escape chance
      (Formulas I). A success makes that side **Fled**, and the fight ends there: if the other side's health is 0
      or below at that point, the fleeing side wins by knockout. Otherwise the fight ends in flight with no winner,
      whether one side fled or both did, and the result names the side or sides that left (the caller treats it as
      the failure branch for the side that needed the win). A failed escape ends nothing and the fight
      goes on.
    - **Defeat check.** After every instant, once all of its damage is in. A side with no health first runs the
      Down step (Effects System rule 11, Formulas C): a refusal may set it to 1, and its last acts resolve once,
      entering a follow-up check at the same t. A last act's damage counts toward its target's overkill for the
      instant, whether or not the target is already Down. Only a side still at 0 or below after that is **Down**,
      and its health is set to 0. If one side is Down, the fight ends. If both are, the side with the larger overkill
      **share** loses (overkill as a share of that side's own `health_max`, Formulas C, so a bigger pool is not
      punished for a bigger absolute number), and the other wins and is left at 1 health, not Down. If the two
      shares differ by less than `overkill_epsilon` (1e-9, so a last-digit float difference cannot break a mirror),
      the fight ends in a **draw** (user decision 2026-11-06): no winner, both sides left at 1 health with
      `wound: grave` and neither `mortal`. The result carries a `wound` value per side: `none`, `grave` (a draw's
      survivors) or `mortal` (a Down side). The caller decides what a grave wound costs (rule 14). No random draw
      decides it and fortune does not enter.
    - **Fatigue (#44 item A3; flat since 2026-11-10).** From `fatigue_start` (60 s), every pulse takes from **both**
      sides a **flat** amount, `fatigue_units` × U_r × n², where n counts fatigue pulses (1 at 60 s, 2 at 61 s …)
      and U_r is the side's own realm fight unit (6.31 at Qi Refining, so the first pulses take 3.16, 12.6, 28.4,
      50.5 …; Formulas A2). It does
      not depend on the side's health, so a build that bought health keeps that toughness (user decision 2026-11-10:
      a share of health punished high-health builds). Fatigue is not damage of any type and not a status: it passes
      wards, shields, resistance and block, no Effect or modifier changes it, fortune does not touch it, and it
      cannot be cleansed. It is logged as its own line. It can take a side to 0, and the instant's Down step and
      defeat check apply as usual, so a refusal can still save a side once. A typical side at full health falls to
      fatigue alone at 66 s, the thể tu (484.6 health) at 67 s, and the largest legal pool (n 8, `boss_pool_mult`
      10) at 90 s. Fatigue keeps long, sustain-heavy fights from stalling now that healing neither fades nor is
      capped, and a big-pool boss outlasts its challenger in overtime, so a build that cannot kill it loses. Healing
      cannot hold it off for long: a heal art is bounded by the heal lint and its cooldown, while fatigue grows
      without bound (113.6 a pulse at 65 s, 381.8 at 70 s at Qi Refining); the harness checks the largest legal heal
      stack (Combat Defence & Healing AC-CD-45, Open Question 11).
    - **No time limit** (user decision 2026-11-10). Fatigue grows without bound, so every fight ends in a knockout,
      a draw or a flight; `time_limit` and the stalemate are retired. A fight still running at 120 s is a bug the
      Balance Harness flags (AC-CB-29).

    No stat decides who acts first. A side's pace comes from the arts it slots and from art speed
    (rule 13), which is bounded, so no single stat can dominate the order of a fight. Shield recharge is computed
    when a shield is read and schedules no event of its own (Combat revision D19; Combat Defence & Healing rule 9).
11. **Linh lực is mana and defence.** Arts cost linh lực, the pool regenerates at a small rate each pulse
    (sustain builds raise it), and wards pay from it in four ways: reserved, per hit, drain and cast (Combat
    Defence & Healing rules 8, 10; upkeep wards were removed, #44 item C2). A reserved ward holds a share off the
    top for the whole fight, which leaves fewer casts. Every point spent on arts is a point that drain and per-hit
    wards no longer have, and with strong wards a side whose pool runs dry takes several times the damage (user
    decision 2026-11-09, #44 item A4). With no affordable art a side still has the basic attack, which always runs.
    **Sustain is king** (user decision 2026-11-08): a long fight favours the build that brought sustain, and a burst
    build must win before its own spending drops its guard. Healing keeps full strength all fight (#44 item C1);
    fatigue (rule 10) is what ends a fight neither side can win.
12. **Preparation counts.** Before a fight the player may prepare, within what the situation allows.
    The Event Engine tells Combat which kind of situation the fight is:

    | Situation | What can be prepared |
    |---|---|
    | **Foreseen** (a challenge, a hunt, a planned raid, a tribulation) | Everything: a formation laid on the ground, talismans slotted, a poison or coating applied, pills taken, wards placed in ward slots and art slots and standing wards switched on or off, the slot order set, the ground chosen where there is a choice |
    | **Ambush** (an event fight with little warning) | What is carried and what a standing formation already holds: talismans, pills with a ready dose, the slot order |
    | **Blind** (a sudden attack) | Only the loadout, including its wards and any talisman already slotted, and the saved slot order |

    Each prepared item adds modifiers to a layer, costs the time, goods and upkeep its own system
    sets, and appears in the fight's opening Breakdown. Combat does not price preparation: Artifact
    Refining, Formations, Talismans and the Alchemy pills each own their cost, and Combat owns
    only what the prepared item does inside the fight.
13. **Arts, cooldown timers and slot order.** An **art** has an id, tags, damage parts with their types (Combat
    Damage Types rule 1), a linh lực cost, a cooldown in seconds, an effect and optionally a heal payload under the
    heal lint (Combat Defence & Healing Formulas E). The sources are: the divine abilities (thần thông) that the main and
    auxiliary techniques unlock (Cultivation Techniques owns when they unlock, Combat owns what they
    do), the Way's art nodes (rare: arts usually come from techniques; the art format here is
    the one the Way's data lint accepts, dao.md rule 3), an artifact's active effect, and the always-available
    basic attack (Physical, tags physical, hit, art and basic, no cost). A combatant's **loadout** has `slot_count` art slots (Formulas A2), its
    free ward slots (Combat Defence & Healing rule 5 and Formulas D) and the basic attack. The art slots are one pool: a divine ability, a Way art, an artifact's
    active effect, a talisman, the escape art and a ward placed in an art slot each take one, so carrying an escape costs a
    damage art. The basic attack and wards in ward slots take none. Every slotted ward is up at once, so a side can layer
    wards (Combat Defence & Healing rule 5). **Every art runs on its own cooldown timer**
    (user decision 2026-11-06, in the manner of an auto-battler's item cooldowns). Every art starts on its
    full effective cooldown, so its first firing comes one cooldown into the fight (user decision 2026-11-06).
    When its timer ends, an art whose **guard** (below) is true and whose cost the side can pay **fires on its
    own**, and its timer restarts. An art that cannot fire yet stays ready and fires the moment it can; its next
    cooldown counts from that firing. There is no choice in the fight: the choices are which arts are slotted,
    in what order, and each art's guard. **Art speed** divides a cooldown: +100 % art speed halves it, +300 % quarters it, and
    a cooldown never falls below `cooldown_min` (user decision 2026-11-06, Formulas A2). Bonuses add together like
    other percentage keys, and each point is worth less than the last. It applies to arts only. Compile gives each art its derived tags (rule 6) from its authored cooldown and cost
    share; art speed and cost reduction do not change them (Combat revision D5). The basic attack carries only
    `basic`, never `quick` or `cheap` (user decision C4, 2026-11-08). The **basic attack** is a
    free art on its own timer of `basic_cooldown` and **always runs**, whatever else fires (user decision
    2026-11-06). A **guard** is an optional single condition on an art record, from a fixed vocabulary:
    own or enemy health or linh lực below or above a share, a status on either side, or the fight time. Comparisons are inclusive: "below" means at or below and "above" means at or above, so a time guard "above 10 s" is true from t = 10.000. An
    art with no guard fires whenever ready. Talismans and the escape art carry a guard by authoring (for
    example own health below 30 %), or they would fire as soon as their first cooldown ends. The **slot order**
    is the player's one ordering tool and the NPC generator's output: it settles the order inside an instant,
    so with little linh lực the earlier slot pays and the later one waits, and it sets the hit order (rule 10).
    A talisman is an art that is used up when it fires; with no stock left it is skipped. Escape is an art too:
    a fight ends by flight if the escape art succeeds (a seeded chance against the pursuer's tags and
    realm), with the result recorded as such.
14. **A fight ends with a result, never with a consequence.** The result is: the winning side, how
    it ended (knockout, draw or flight), the fight time, each side's health, linh lực and `wound` (`none`, `grave` or `mortal`) at the end, the
    resources spent (talismans, linh lực), the deciding layer (the layer with the highest
    damage-weighted total over the winner's hits; ties take the lower number; a soul win, a draw or a flight
    has no deciding layer and the result says so), the costs and gains that outlive the fight (heart demon,
    lifespan, toxicity and the rest) and wounds that run on, which the caller applies (Effects System rules 10,
    11), and the full log. Combat itself
    changes nothing outside the fight. The caller applies consequences: it decrements spent stock, Character Stats takes the
    vitality loss (Formulas A), the Event Engine decides death, mercy or capture and offers taming of a beaten
    creature, Realms receives a knockout of a cultivator for capability #9 (a flight, a draw or a creature never counts, and mercy does not undo it; user decision 2026-11-06), and the World Database records the
    event. **Death rests on the caller:** Combat only says a side was mortally wounded.
15. **All randomness is explicit and seeded.** One random stream per fight, seeded from the world
    seed and the fight id, is drawn from in a fixed order. Randomness enters only through explicit
    `chance` fields (a critical hit, an evade, a status chance, a trigger chance, an escape). A build whose chances are all 0 or 100 per cent is fully deterministic, and
    the design aims at that: chance is a flavour of a build, not the base of the outcome. Hits
    have no base damage spread (user decision 2026-11-06). Fortune (khí vận) shifts every chance
    roll that is not already 0 or 100 per cent (Formulas I). A keystone may turn one chance into a counted
    chance, which uses no draw and is not shifted by fortune (Effects System rule 12, Formulas A).
16. **Every hit explains itself.** Each hit logs its actor, art, tags, each part's damage type and
    history, the Breakdown of every layer (the bonuses inside each layer and the layer total), then the defence path
    as Combat Defence & Healing lists it (evade, resistance in points and the share it stops, block, each ward shield, the body shield,
    health, and each ward's payment), heals, fatigue, the Effects that fired, and health and linh
    lực before and after. The terminal shows a one-line summary per pulse by default and the
    full Breakdown on request; the log is data and the Game UI reads the same structure.
17. **Mass battles use the rating profile.** Great battles and wars (a sect war, a besieged city) do
    not run as fights. Each force compiles to a **rating profile** (offence by damage-type mix,
    defence by Combat Defence & Healing Formulas G, and sustain, over the force's members under a size rule; in a
    clash each side's effective health uses the attacker's own damage-type mix, and `display_power` uses a fixed
    `reference_type_mix` fitted by the balance harness, Combat revision D7) and the clash is
    a closed-form comparison plus one seeded roll. Individual NPC duels do not collapse: they run
    the full fight of rules 1 to 16, and the Living World keeps them rare (Interactions). The
    rating profile is derived from the same compiled profile, and its win rate must agree with
    the full fight on sampled one-on-one pairs within a stated tolerance (Acceptance Criteria).
18. **Enemies are profiles.** A creature, a monster and an NPC all use the profile of rule 2. An
    enemy's character comes from its modifiers, art list, slot order and guards: a body-crusher, a
    soul-piercer, a poisoner, an armoured beast. Content authors add enemies by data, with no new rule.
    Each realm tier has at least one enemy that deals each damage-type group (Physical/Force;
    Fire/Cold/Lightning/Light; Chaos; Soul), one with high resistance to each group (at least 150 points against it,
    stopping 60 %, with its wards up), one that drains linh lực hard (it carries Qi Disruption or a soul art) and one that heals (a heal
    art or heal Effect) (Combat revision D8; thresholds user decision C3, 2026-11-08). Every enemy profile lists its damage types, its wards and a soul
    defence (Combat Damage Types Open Question 5; Combat Defence & Healing rule 14), so a one-note build meets something it cannot answer. A top-end build
    may end an ordinary fight with its first volley or two; that is its payoff (user decision 2026-11-06).
    Bosses and tribulation bosses carry a `boss_pool_mult`. An ordinary boss is set so that a top-end build
    needs at least 4 seconds against it; a tribulation boss is exempt, because it must stay beatable by a typical build (user decision 2026-11-06, thien-kiep.md Formulas C).
19. **Companions.** A spirit beast attached to a side adds the power share it already has
    (Spirit Beasts) as one more attack source every `basic_cooldown`, with its own tags and a simple fixed art whose damage type is
    authored, like every damaging art (Combat Damage Types rule 1).
    A companion cannot be targeted in this version, and cannot be removed from the fight except by its
    owner's defeat (user decision 2026-11-06).
20. **Fighting above one's realm (vượt cấp) is paid for by the build.** A side whose realm is lower
    than its enemy's by `g` major realms has the damage it deals reduced by a suppression
    factor that grows with `g`, on top of the gap in fight power (damage × effective health, Combat Defence & Healing Formulas G) of about ×10
    per realm: ×6.3 from the fight unit and the rest from the W a higher realm holds (Formulas A). A modifier with
    the **pierce** tag reduces the suppression by its own share. A build that has stacked several
    layers can overcome the gap, a build with a single stat cannot.
21. **Fights are readable and testable.** The fight engine is a pure function of its inputs with
    no clock, no engine nodes and no global state; the Balance Harness runs it headlessly and the Debug
    Terminal prints its log.
22. **Wards.** Wards are spells. They sit in free ward slots or in art slots, every slotted ward is up at once,
    and each carries payloads (resistance, block, shield, status, soul, evade) and one of four payments
    (reserved, per hit, drain, cast). The default ward is the fallback for any hit part that no other ward
    covers. Ward strength and ward efficiency scale every ward (Combat Defence & Healing Formulas A0). Combat
    Defence & Healing owns all of this (rules 5–11, Formulas A0–D, F, H). Combat keeps three things:
    - a cast ward fires on the timeline like an art (rule 13);
    - a ward stays up through the millisecond it expires in (rule 10);
    - compile takes reservations at t = 0.

    A side flagged `cannot_slot_wards` cannot slot any ward, soul wards included. One flagged `no_default_ward`
    has no default ward. Compile reads both flags, and the No Ward keystone (Effects System) sets them (Combat
    Defence & Healing rule 5).
23. **Body defence, and being a mortal.** Body guard is retired. The body defends with block, body shields and
    resistance from căn cốt, body techniques (luyện thể) and body gear, and none of it needs linh lực (Combat
    Defence & Healing rule 12). A body cultivator (thể tu) is a build that stacked them, and its weakness is Chaos,
    which passes body shields. A side with no linh lực has no default ward and no drain or per-hit ward,
    and cannot pay for arts. Unless it built block, body shields, resistance from other sources or a reserved
    ward, every hit lands nearly in full. Arts may be authored to cost health instead, so a body build can still
    act (Formulas E; the Effects System's pay-in-health action can also put the side Down, Combat revision D14).
24. **Thần thức attacks.** A soul attack is an ordinary art whose hit is all Soul: it has a cost and a cooldown
    like any other, and fires whenever its timer and guard allow, but a side's soul arts share a
    **`soul_lockout`**: after one fires, no other soul art of that side fires until the lockout ends, and
    ready ones wait (an interim limit until the technique content exists, Open Question 16). A soul hit is all
    Soul; a hit that mixes Soul with other types is rejected at compile (Combat Damage Types rule 1). It ignores
    every defence except soul resistance and soul wards, and takes
    a share of maximum linh lực and of maximum health at once. The share rises steeply with the attacker's
    thần thức over the defender's, so it is only dangerous across a big gap in power and small between
    equals. It is rarely a main attack unless a build is made for it. The defences are the defender's
    thần thức, soul resistance (from the Way, rare items and soul wards; it raises the defender's side of rho) and
    soul shields, which soak a share of each loss from their own bar (Combat Defence & Healing rule 14, Formulas B). Its balance waits on the technique
    content (Open Question 16).

### States and Transitions

A fight has these states; a combatant has the sub-states under it.

| State | Entered when | Leaves when |
|---|---|---|
| Requested | The Event Engine, Tribulation or the player opens a fight | The situation (rule 12) is known |
| Preparing | The situation allows preparation | The player confirms the setup (or the situation allows none), and the profiles compile |
| Running (the timeline of rule 10) | The profiles have compiled | The defeat check ends the fight (fatigue makes sure it does) or an escape art succeeds |
| Resolved | An end is reached | The caller reads the result; the fight is then discarded |

| Combatant state | Entered when | Leaves when |
|---|---|---|
| Fighting | The fight starts | Health is empty, or its escape succeeds |
| Down: mortal wound | Health is still empty after the Down step at an instant's defeat check (Effects System rule 11) | The caller finishes or spares it |
| Fled | Its escape art succeeds | The fight ends |

A Down side acts no more. Ward states (Off, Waiting, Up, Down, Broken, Expired) are Combat Defence & Healing's, and
the default ward is Up for any hit part no other ward covers. Effect states (Idle, Active, Fired, On cooldown, Spent)
are the Effects System's.

### Interactions with Other Systems

Artifact Refining, Formations, Talismans, Spirit Beasts, Alchemy, the Event Engine, NPC Builds and
the Living World have no GDD yet (quick specs at most). Rows marked **provisional** hold the contract
this GDD expects, to be matched when those systems are designed.

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| Combat Defence & Healing (#21a) | in / out | In: the defence path, wards and their payments, resistance, block, shields, healing, ward slots, soul and status defence, effective health (its Formulas G, for Formulas K). Out: the timeline, hit parts after offence, art slots for cast wards, the defeat check | Combat Defence & Healing (defence and healing); Combat (the timeline and offence) |
| Combat Damage Types (#21b) | in | The eight damage types, the conversion rules and steps, which damage types pass which shields | Combat Damage Types |
| Modifier System (#40) | in | Modifier records, operations (flat, increased, more), scopes, W prices and the Stat List keys Combat reads | Modifier System (records, prices); Combat (what each layer does) |
| Effects System (#41) | in / out | In: the status catalogue, trigger Effects and their actions, the Down step, counted chance, reported life costs. Out: events, readable quantities, the timeline and the defeat check | Effects System (records, the Down step); Combat (events, the timeline) |
| Character Stats (#7) | in / out | In: vitality, spiritual power and divine sense, `attack_pct`, `defense_pct` (ward strength, which scales ward payloads), `khi_huyet_pct`, `linh_luc_pct`, `than_thuc_pct`, `artifact_power_pct`, the artifact-local keys, `single_artifact`, the defence and offence keys of Parameter keys, the realm term of power, the vitality factor floor. Out: vitality loss after a fight, `+2` heart demon on a cultivator knockout with capability #9, and the life costs Effects report (applied by the caller) | Character Stats (keys, units); Combat (what each key does in the fight) |
| Realms & Bottlenecks (#8) | in / out | In: realm, stage multiplier, the realm gap `g`. Out: defeats for capability #9, and the result for a tribulation | Realms |
| Cultivation Techniques (#9) | in | `tech_power` (through spiritual power), the unlocked divine abilities with their unlock layer, and body techniques' block, body shield and resistance (Combat Defence & Healing rule 12, Formulas H) | Cultivation Techniques (which and when); Combat (what they do) |
| Meridian Map (#10) | in | Only the stat modifiers, through Character Stats. Combat hosts no capability behaviour: each capability has one host, and an effect such as #1 or #3 reaches Combat only as the artifact values its host supplies. For #9, Combat only reports the defeat | Meridian Map |
| The Way (#39) | in | Stat lines through Character Stats; Effects on notables; rare art nodes in rule 13's format (dao.md rules 3 and 10) | The Way; Combat (art format) |
| Item Database (#13) | in | Equipped pieces with their role tags (weapon, ward_gear, body_gear, utility; D2), attack, defence and affixes; the equipped set limited by thần thức; consumable arts' items (item-database.md rules 6, 11) | Item Database (what an item is, its roles and whether it counts); Combat (what a piece adds) |
| Artifact Refining (#16) | in | Equipped artifacts: attack; defence (ward gear feeds ws, we and block up to a = 1; body gear gives 12 block and 0.60 body shield per a_b, Combat Defence & Healing Formulas A0, A2, B); affixes, thần thức cost, an optional active effect (**provisional**) | Artifact Refining; Combat (how they act) |
| Formations (#17) | in | A laid formation's modifiers, upkeep and ground tags (**provisional**) | Formations |
| Talismans (#18) | in | Consumable arts and their tags (**provisional**) | Talismans |
| Spirit Beasts (#19) | in / out | In: the companion power share and fixed art. Out: a beaten creature offered for taming (the Event Engine hook) (**provisional**) | Spirit Beasts |
| Alchemy (#15) | in | Pills with timed buff or cleanse effects taken in preparation | Alchemy |
| Event Engine (#23) | in / out | In: a fight request with the enemy, the situation (foreseen, ambush, blind), the ground tags and an optional `no_heal`. Out: the result, with the life costs and wounds that run on for the caller to apply | Event Engine (requests, consequences); Combat (the result) |
| NPC Builds (#24) | in | An NPC's compiled profile, art list, slot order and guards | NPC Builds |
| Living World Tick (#28) | in | Mass battles via the rating profile. It must keep NPC-against-NPC duels rare | Living World; Combat (rating profile) |
| Heavenly Tribulation (#22) | in / out | In: starting shares for each wave after the first, and `no_heal` on every wave. Out: the fight engine and its result, with a tribulation boss as an enemy profile | Heavenly Tribulation |
| Time & Turn (#4) | in | A fight takes no seasons itself; the time of preparation is the preparing system's | the preparing system |
| World Database (#3) | out | The event record of a notable fight | World DB |
| Balance Harness (#33) | out | A headless fight run and the rating-profile clash | Balance Harness |
| Debug Terminal (#36), Game UI (#37) | out | The fight log and the preparation screen's data | the presentation system |

## Formulas

All values are provisional until the Balance Harness confirms them (Open Questions). The win rates
below come from a one-pool simulation with no rotation, statuses or triggers, so they show
direction, not final odds. Keys live in `combat_rules.json`.

**Timeline note.** Those simulations ran in rounds, before the timeline (rule 10). Read a round as 1 s. They
do not include the always-running basic attack or the first-fire delay, so every simulated figure below is
provisional until re-run (Open Question 20). Worked examples of one hit are unaffected.

**Owned elsewhere (Combat revision #43, 2026-11-08).** The defence path's formulas are Combat Defence &
Healing's (Formulas A0–I: ward strength, resistance, block, shields, payments, ward slots, healing, the ward
price check, effective health), damage parts and conversion are Combat Damage Types' (Formulas A), modifier
values and prices are the Modifier System's (Formulas A–E), and the Down step and standing statuses are the
Effects System's (Formulas B, C). This section keeps offence, time, linh lực, soul attacks, ticks, triggers,
suppression, evade and escape, companions and the rating.

### A. Fight unit, health and linh lực

The fight_unit formula is defined as:

`U_r = B_p[r] ^ fight_unit_exponent`

The pool_max formula is defined as:

`n_k = clamp(stat_k / ref_k[r], pool_n_min, pool_n_max)` ; `health_max = health_units · U_r · n_body · boss_pool_mult` ; `qi_max = qi_units · U_r · n_qi · boss_pool_mult` ; `health_start = health_max · max(v, v_c)`, or `health_max · start_health_share` when the request carries shares ; `qi_use = qi_max · (1 − Σ reserved)` ; `qi_start = qi_use`, or `qi_use · start_qi_share` likewise (Combat revision D6) ; `ehp` is Combat Defence & Healing Formulas G

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
| health_units | float | 48–104, default 64 (×4, user decision 2026-11-09, #44 item A4); fatigue ends every fight, so the old unbuilt-mirror limit is retired | data file | Health in fight units, now larger than linh lực; most staying power still sits in wards, which linh lực pays for |
| qi_units | float | 18–36, default 26 | data file | Linh lực in fight units |
| boss_pool_mult | float | 1–10, default 1 | data file (enemy profile) | Bosses and tribulations only; applied after `pool_n_max`, to both pools (rule 18) |
| v, v_c | float | 0.05–1; 0.4 | calculated; data file (`duel.injured_power_floor`) | Vitality fraction and its floor |
| start_health_share, start_qi_share | float | above 0 to 1; 0 to 1 | fight request (optional) | Starting shares (rule 3). Both or neither are sent |
| Σ reserved, qi_use | float | 0–0.9; ≥ 0 | Combat Defence & Healing rule 10 | Reserved share and the usable maximum linh lực starts at |
| ehp | float | ≥ 0 | Combat Defence & Healing Formulas G | Effective health by damage type, before art spending and regeneration. Typical Qi Refining **1,376.2** (#44; was 297.8) |

There is no time limit: fatigue from 60 s ends every fight (rule 10). After a fight, `v_after = min(v, health_end / health_max)`, so vitality never rises, even
when healing restored health during the fight (Combat Defence & Healing rule 19).
The caller applies Character Stats' floor rules.

**Why not the full base.** Fight power F is damage × ehp. If both scaled with B_p, F would rise ×100 per
realm and no build could cross a realm. With exponent 0.4 the base gap is ×6.3 per realm, and the extra W
and technique power a higher realm holds lift it to about ×10, the concept's "roughly 10× power per
major realm".

**Output Range:** health runs from about 101 to about 128,600 and linh lực from 41 to about 52,250, before
`boss_pool_mult`. Linh lực starts at most at its usable maximum. Only health ends a fight.

**Example:** typical at Qi Refining, n_body 1.0883, n_qi 1.053: health = 64 × 6.31 × 1.0883 = **439.5**;
linh lực = 26 × 6.31 × 1.053 = **172.7**. At v = 0.7 health starts at 307.6. At v = 0.3 the floor applies
and it starts at 175.8.

### A2. Time and cooldowns

The cooldown formula is defined as:

`cd_eff = round_ms(max(cooldown_min, cooldown / (1 + art_speed_pct / 100)))`, where `round_ms` rounds to the nearest millisecond, half up (rule 10)

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| cooldown | float | 0.5–12 s (was 0.5–30 s; #44 item A2) | data file (art record) | The art's authored cooldown |
| art_speed_pct | float | ≥ 0 (percentage points) | Modifier System (`art_speed_pct`, 0.6 W) | How much faster arts cycle, summed over sources. +100 means twice as fast, so half the cooldown (user decision 2026-11-06) |
| cooldown_min | float | 0.5 s | data file | Floor on any art's cooldown, so the rate of hits stays bounded |
| basic_cooldown | float | 1 s | data file | The basic attack's and the companion's timer. Art speed does not touch it |
| pulse_interval | float | 1 s | data file | Beat of regeneration, ticks, durations and per-pulse limits |
| ~~time_limit~~ | — | retired 2026-11-10 | — | Fatigue grows without bound, so no fight needs a limit; no stalemate |
| fatigue_start | float | 60 s | data file | First fatigue pulse (#44 item A3) |
| ~~fatigue_step~~ | — | retired 2026-11-10 | — | Replaced by the flat `fatigue_units` (fatigue no longer reads `health_max`) |
| fatigue_units | float | 0.5 (0.25–1.0) | data file | Fatigue's first pulse in fight units: 0.5 × U_r (3.16 at Qi Refining) |
| fatigue_pow | float | 2 (2–3) | data file | Growth: the n-th fatigue pulse takes `fatigue_units` × U_r × n^`fatigue_pow`. 2.5 or 3 if fights run long |
| escape_channel | float | 1 s (guess) | data file | Delay between an escape art firing and its roll |
| soul_lockout | float | 1 s (guess) | data file | Minimum gap between a side's soul arts |

**Output Range:** `cd_eff` runs from `cooldown_min` to the authored cooldown. Dividing never reaches 0 on its own, so the floor is the only hard stop.

The fatigue formula is defined as:

`fatigue(t) = fatigue_units · U_r · n^fatigue_pow`, with `n = 1 + (t − fatigue_start) / pulse_interval`, at each pulse with t ≥ `fatigue_start`, and 0 before it. U_r is the side's own realm fight unit (Formulas A), never scaled by `boss_pool_mult` or the side's health

**Output Range:** at Qi Refining 3.16, 12.6, 28.4, 50.5, 78.9, 113.6, 154.6 … at 60, 61, 62 … s, with no upper
bound. The running total after N pulses is `fatigue_units · U_r · N(N + 1)(2N + 1) / 6`: 441.7 after 7 pulses, so a
typical side (439.48) at full health with nothing else touching it falls at **66 s**, the thể tu (484.6) at 67 s, and
the largest legal pool (`health_units` 64, n 8, `boss_pool_mult` 10: 32,305) at **90 s**. Typical same-realm fights
end at 30–60 s (#44 item A1) and never meet it; a healer mirror ends by fatigue by about 65 s
(`tools/design/combat_sim/sim.py`, 2026-11-10).

**Example:** Qi Refining (U 6.31) at t = 65, so n = 6: 0.5 × 6.31 × 36 = **113.6** taken from each side, whatever its
health.

**Example:** cooldown 10 s at +100 %: 10 / 2 = **5 s**. Sources of +100 % and +50 % add to +150 %: 10 / 2.5 = **4 s**. Cooldown 1 s at +300 % would be 0.25 s and stops at **0.5 s**. Cooldown 10 s at +200 % is 3.333 s, so **3,333 ms**: firings at 3.333, 6.666 and 9.999 s, and the third is a separate instant from the 10 s pulse.

The slot_count formula is defined as:

`slot_count = slots_by_realm[r] + Σ bonus_slots`

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| slots_by_realm | int | 3 / 4 / 5 / 6 / 7 | data file | Base art slots, Qi Refining to Deity Transformation. Provisional until the harness measures them |
| bonus_slots | int | ≥ 0 | Modifier System (`bonus_slots`, 20 W, rare) | Slots earned through the build. There is no cap (user decision 2026-11-06): the total is limited only by the sources authored. Ward slots are separate (Combat Defence & Healing Formulas D) |

**Why slots grow slowly.** Power already rises about ×10 per realm, so slots add one per realm and mostly add
choice. Art costs are a share of `qi_max`, so a bigger pool buys no extra casts: arts at `cost_share` 0.075 on 3 s
cooldowns fire nothing before 3 s, and each volley then costs 0.225, 0.375 and 0.525 of the pool for 3, 5 and 7 slots, against 0.105 regenerated in 3 s. Seven slots empty it by the third volley (9 s), five by the fourth (12 s), and three last seven volleys (21 s), and every point spent is a point drain and per-hit wards no longer have. A reserved ward is paid before the fight, so it does not compete with arts.

**Output Range:** 3 and up, with no cap on earned slots.

**Example:** Core Formation with one earned slot: 5 + 1 = **6**. Qi Refining with 3 bonus sources: 3 + 3 = **6**.

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
| L1 | Increased | The increased sum of damage modifiers: `attack_pct` and its scoped rows (Modifier System rule 5; Meridian Map and Way W, 1 W = +1). **W fills only this layer** |
| L2 | Art "more" | `damage_more` points on techniques, arts and Way art nodes (Modifier System rule 6, Formulas D); typical +40, up to the cap |
| L3 | Gear | `100 · Σ artifact attack / (B_p · stage_mult)`, with each artifact's attack after `artifact_power_pct` and its other multipliers, as built |
| L4 | Preparation and ground | `damage_more` on L4 from formations, talismans, pills, coatings and ground tags (rule 12); typical +20. When blind, x4 holds ground tags only |
| L5 | Effects | `damage_more` on L5, granted only as an Effect's payload (Modifier System rule 6), applied only while active |

**Output Range:** anchors per realm, all at stage 1.00. These are targets until real builds are measured.
W shares are attack / ward strength / ward efficiency / linh lực / health.

- **Typical:** 25 / 5 / 5 / 5 / 10 %, L2–L5 at 1.4, 1.4, 1.2, 1.1, artifact defence 0.85 × B_p, mean art
  coefficient 1.6 at 15 % crits of ×1.7; the Common Ward (all 342.5 resistance points, drain 0.328), so 448 points at ws 30.8 (stops 81.75 %),
  plus block rating 15.0 (Combat Defence & Healing Formulas A, A2).
- **Top-end:** 45 / 10 / 7.5 / 7.5 / 20 %, L2–L5 at 4.0, 3.5, 2.5, 2.0, artifact defence 5 × B_p, 50 % crits
  of ×2; resistance about 900 points (stops 90 %) at Qi Refining, rising to about 1,900 (95 %) by Deity Transformation, no cap
  (Combat Defence & Healing Formulas A).
- **Thể tu:** Combat Defence & Healing's Formulas G fixture: block 88.3 rating (flesh 5.3, gear 12, Iron Body Art
  tier 3 30, W 41), body shield 0.90 (technique 0.30, gear 0.60), Physical resistance 36.1 points (Iron Body tier 3 25,
  Black Iron Armour's Physical affix 11.1), body gear 1.0 × B_p, the default ward only. Its W shares need a harness
  re-fit (Open Question 6).

| Realm (end) | Tree W | Typical M | Typical ehp (U) | Typical mirror, s (old sim, superseded) | Top-end M | Top-end ehp (U) | Top-end mirror, s (old sim, superseded) |
|---|---|---|---|---|---|---|---|
| Qi Refining | 106 | 3.27 | 218 (#44; was 47) | 7.6 (#44: 30–60 s) | 103 | re-derive | 1 |
| Foundation Establishment | 248 | 4.19 | re-derive | 6.7 | 148 | re-derive | 1 |
| Core Formation | 447 | 5.48 | re-derive | 6.7 | 210 | re-derive | 1 |
| Nascent Soul | 739 | 7.37 | re-derive | 6.5 | 256 | re-derive | 1 |
| Deity Transformation | 1,172 | 8.96 | re-derive | 7.0 | 325 | re-derive | 1 |

Typical ehp at Qi Refining is Combat Defence & Healing Formulas G's 1,376.2 / 6.31 = 218 U (#44; was 297.8, 47.2 U). Defence calibrated
Qi Refining only, so the other ehp cells are re-derived from its Formulas G by the balance harness (the old
values 56 / 73 / 94 / 127 and 125 / 163 / 217 / 315 / 460 assumed the retired ward and body guard). Open
Question 20 still applies to the mirror columns.

**#44 note:** the mirror columns and the spot checks below predate the Combat economy revision and are
superseded. **The canonical typical mirror is the simulator's** (`tools/design/combat_sim/sim.py`, three arts, 20
seeds, 2026-11-10): about **37 s** (36.7), linh lực dry at about 16 s. The other figures measure other things: the
hand-worked FX-T mirror ends at 34.000 s because its one art fires every second while affordable (dry at 10 s); the
FX-U mirror ends at 64.000 s by fatigue (AC-CB-30), both draws; Formulas K's 55.8 s is the rating model's averaged
rotation (art uptime 0.3) and is compared with the full fight only through win chances (AC-CB-52), never through
length. The harness re-derives the realm columns.

An unbuilt mirror (M = 1, basic attack only, default ward) lasted about 25 s, inside the old time limit, under the old
ward; with the default ward and flesh block an FX-U mirror is a draw at exactly 25.000 s (AC-CB-30).
Mirror columns come from the old round simulation with no soul arts, statuses or triggers. One spot check on
the timeline: the FX-T mirror (one 1 s art plus the basic attack) ends at exactly 6.000 s, a draw (AC-CB-30); it
spends its arts up front, so it is shorter than Formulas K's averaged typical rotation (7.95 s).

**Example:** typical at Qi Refining: L1 1.265 × 1.4 × 1.4 × 1.2 × 1.1 = **3.27**.

### C. Hit damage

The hit_damage formula is defined as:

`base = U_att · stage_att · c_art` ; `part_j = base · s_j · M(T_j) · crit` ; `D_j = part_j · supp` ; `D_j` then meets the defence path: resistance `a_j = D_j ÷ (1 + R_j / 100)` with R_j in points, or `D_j · (1 + |R_j| / 100)` below 0 (Combat Defence & Healing Formulas A), its share `k_j` of block (A2), shields (B), and `dealt_j = 0` if nothing reaches health, else `max(1, h_j)` for a hit (ticks have no floor, Formulas F) ; `overkill = max(0, damage_in_instant − health_at_instant_start) / health_max`, where `damage_in_instant` is everything that removed health from that side in the instant (ticks, hits, trigger hits and last acts, after the defence path) and health is not floored until the defeat check

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| c_art | float | basic 1.0; arts 1.2–6.75 (the lint's maximum at cost 0.125 and 12 s; #44) | data file (`basic_coef`, art record) | Art coefficient. Lint: `c_art ≤ basic_coef · (1 + art_coef_per_cost · cost_share) + art_coef_per_cooldown · (cooldown − 1)`, on the authored cooldown in seconds. An art that grants element stacks lints at `lint · (1 − charge)` (Effects System Formulas D, #44) |
| art_coef_per_cost, art_coef_per_cooldown | float | 24 (was 12: costs were halved, so each share of cost buys twice the coefficient and arts keep their damage; user decision 2026-11-09), 0.25 | data file | Art power is paid for in linh lực and cooldown |
| s_j | float | 0–1, Σ = 1 | Combat Damage Types Formulas A | Share of the hit in part j |
| T_j | tag set | — | calculated | The art's tags, plus part j's damage type and its earlier types (Combat Damage Types rule 6) |
| crit | float | 1 or `crit_mult` | calculated | Rolled once per hit. Chance = `clamp(crit_base + Σ crit_chance_pct/100, 0, crit_chance_cap)`; `crit_mult = min(crit_mult_base + Σ crit_damage_pct/100, crit_mult_cap)` |
| crit_base, crit_chance_cap | float | 0, 0.5 | data file | Base chance is 0, so a build with no crit is deterministic (rule 15) |
| crit_mult_base, crit_mult_cap | float | 1.5, 3.0 | data file | Crit multiplier |
| supp | float | 0.25–1 | calculated (H) | Realm suppression |

Order: the evade roll (an evaded hit deals nothing, drains nothing and fires no on-hit trigger), conversions
(at most 2 per hit, in Combat Damage Types' order; the part's final damage type decides its defence), layers
per part, one crit roll, suppression, then the defence path (Combat Defence & Healing rule 1). Within an instant each side pays its art costs first; hits then
apply one at a time against live linh lực. Soul attacks skip all of this (Formulas E2).

**Output Range:** 0 if block or shields take all of a part, otherwise at least 1. Unbounded above except through
`M` ≤ 350 and crit ≤ 3.

**Example:** Qi Refining, stage 1.00, c_art 2.0, typical M 3.27: base 12.62, D **41.30**. An all-Physical hit
on FX-T (the Common Ward, 448 points, stopping 81.75 %; block 0.946): after resistance 41.30 × 0.1825 = 7.54; after block **6.59**
dealt; the drain bill is 0.1917 × 33.76 = **6.47** linh lực. With every ward switched off, the default ward (all
60 points, stopping 37.5 %) covers it: 41.30 × 0.625 − 0.946 = **24.87**. With no linh lực, no ward is up: 41.30 − 0.946 = **40.35**. On a
×1.7 crit with the Common Ward: 70.21 × 0.1825 − 0.946 = **11.87**. Conversion: base 100, Physical +30 %, Fire
+40 %, 40 % Physical → Fire: 0.6 × 1.3 + 0.4 × 1.7 = 1.46, so **146** against 130 (Combat Damage Types Formulas A).

### D. Wards and body defence (moved)

These formulas moved to Combat Defence & Healing in the Combat revision (#43, 2026-11-08):
- ward strength, ward efficiency and artifact defence (`ws`, `we`, `a_w`, `a_b`, `ward_gear_scale` 0.30,
  `ward_floor` −90; `ward_cap` retired 2026-11-10): its Formulas A0;
- resistance by damage type: A; block: A2; shields: B; the five payments: C; ward slots: D; healing: E; the
  ward price check: F; effective health: G; the starter wards: H.

Body guard is retired; the body defends with block, body shields and resistance (that GDD's rule 12).
**Retired keys:** `pass_kind`, `drain_kind`, `pass_tag`, `pass_min`, `drain_min`, `default_ward_pass` and
`default_ward_drain` (replaced by `default_resist` 0.30 and `default_drain` 2.0), `hit_cost_share`,
`upkeep_share` (now on each ward record), `guard_base`, `guard_pool_slope`, `guard_cap`, `guard_max_mit`,
`guard_half`, `guard_share_kind`, `body_guard_pct`, `trig_ward_strength`, `trig_ward_seconds` (Combat revision
D9) and `ward_art_duration`.

### E. Linh lực

The art_cost formula is defined as:

`cost = cost_share · (1 − cost_red) · (1 + cost_raise) · qi_max`, with `qi_max` read at the fight's start (a live change from Water stacks does not move costs; user decision 2026-11-10) ; `affordable if pool_qi ≥ cost − 1e-6` ; `regen = qi_max · (regen_base + regen_k · ln(1 + regen_bonus / regen_k))` per pulse ; `body_cost = body_cost_share · health_max` ; with `art_cost_health_pct` X: linh lực pays `cost ÷ (1 + X / 100)` and health pays the rest, point for point, never below 1 health (user decision 2026-11-10)

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| cost_share | float | 0.02–0.125 (halved, #44 item B1) | data file (art record) | Share of maximum per use |
| cost_red | float | 0–0.5 | calculated (new key `art_cost_pct`) | Sustain build's reduction |
| cost_raise | float | 0–0.5 | calculated | Curse raise |
| regen_base | float | 0.035 (was 0.02; #44 item B1) | data file | Regeneration per pulse |
| regen_bonus | float | ≥ 0 | calculated (key `linh_luc_regen_pct`, plus Water stacks) | Sustain bonus, before diminishing returns |
| regen_k | float | 0.08 | data file | Diminishing returns on the bonus, a log curve with no ceiling (user decision 2026-11-10, "no caps"; replaced `bonus / (1 + bonus / k)`, which levelled off at +8 pp): +6 pp of bonus counts as +4.48 pp, +30 pp as +12.47 pp, +100 pp as +20.82 pp |
| body_cost_share | float | 0.01–0.04 (halved with `cost_share`) | data file (art record, optional) | An art paid in health; the art lint counts it as 2 × `cost_share`. It is not damage and cannot take health below 1. An Effect's health payment is different: it can put the side Down (Effects System rule 6; Combat revision D14) |

**Output Range:** linh lực runs 0 to the usable maximum, `qi_max · (1 − Σ reserved)`. Art costs read the full `qi_max`
at the fight's start; regeneration and the pool's ceiling follow the live maximum, and every point Water stacks add
is usable (Combat Defence & Healing rule 10, AC-CD-74). A heal art refunds what it paid when it restores any health,
and Ice raises an art-slot ward's cast cost but no ward-slot payment (Combat Defence & Healing rule 16, Edge Cases). A side may spend itself to 0. Health
regeneration and heals are Combat Defence & Healing's Formulas E.

**Example:** typical at Qi Refining, `cost_share` 0.075 costs 12.96 and regeneration is 6.05. With nothing incoming a 1 s art
fires **24 times** in a row, then about every other second on regeneration. A regeneration bonus of +6 pp gives
7.98 % a pulse, 13.78. Under #44 the FX-T mirror runs dry at 10 s and ends at 34 s (AC-CB-30).

### E2. Soul attacks

The soul_attack formula is defined as:

`rho = divine_sense_att / (divine_sense_def · (1 + soul_res_pct/100))` when `soul_res_pct` ≥ 0, and `rho = divine_sense_att · (1 + |soul_res_pct|/100) / divine_sense_def` below 0 (no floor, user decision 2026-11-10) ; `pct = 0 if rho < rho_min, else min(soul_pct · (1 + x_soul/100) · rho^soul_beta · supp, soul_cap)` ; `health_loss = pct · health_max / boss_pool_mult` ; `qi_loss = pct · qi_max / boss_pool_mult`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| soul_pct | float | 0.03–0.08 | data file (art record) | Share of maximum at equal souls; a guess |
| x_soul | float | ≥ 0 | calculated | Soul-tagged modifiers, so a soul build has something to stack |
| soul_beta | float | 2 (1.5–3) | data file | Steepness: a big gap is frightening and parity is small |
| rho_min | float | 0.25 | data file | Below this the attack cannot touch the soul |
| soul_res_pct | float | any; below 0 amplifies | Modifier System (`soul_res_pct`); soul wards | Way nodes, rare items and soul-ward payloads (scaled by ws). Lowered by Slackened Soul, −15 pp per stack (Combat revision D12), with no floor since 2026-11-10, like resistance |
| soul_cap | float | 0.30 | data file | Most one hit can take |
| supp | float | 0.25–1 | calculated (H) | Suppression applies, and pierce works on it |

Only soul resistance and soul wards apply. After `pct` sets the losses, a soul shield takes its share of each loss
off its own bar until the bar is empty (Combat Defence & Healing rule 14, Formulas B). Evade, crit, damage-type
resistance, block and every other shield do not apply. Cost and cooldown are the art's own. Percent is taken on the pools
before `boss_pool_mult`, so a ×8 boss loses at most 3.75 % a hit.

**Output Range:** 0 to 0.30 of each pool per hit.

**Example:** `soul_pct` 0.05: equal souls take **5 %** of maximum health and linh lực; a soul twice the defender's
takes **20 %** (22.0 health and 34.5 linh lực at the typical Qi Refining pools); three times is capped at **30 %**;
half takes **1.25 %**; a fifth takes **0**.

### F. Over-time statuses and curses

The status_tick formula is defined as:

`raw = U_src · stage_src · c_tick · stacks · L1..L4(tags) · supp` ; `tick = raw ÷ (1 + R_eff / 100)` when R_eff ≥ 0 and `raw · (1 + |R_eff| / 100)` below 0, with no cap (#44 item C3), where `R_eff` is the target's resistance points for the status's damage type less the source's penetration points, both read when the status is applied (Combat Defence & Healing Formulas A; Combat revision D11) ; the tick then meets the shields it does not pass, and what reaches health is dealt exactly, with no floor of 1 (user decision 2026-11-10) ; `p_status = chance` when chance is 0 or 1, otherwise `clamp(chance · (1 − resist), 0.05, 0.95)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| c_tick | float | 0.15–0.5 per stack | data file (status record) | Lint: `c_tick · duration ≤ 1.2 · c_art` of an equal-cost art. A standing status has no duration, so instead `c_tick ≤ 0.15`, bounded by its caster's standing fee (Effects System Status Catalogue; Combat revision D13) |
| stacks, stack_cap | int | 1–5; 5 | calculated; data file | Stacks on the target |
| duration | int | 2–6, or none for a standing status | data file (status record) | Pulses, one tick per pulse (1 s each at the default `pulse_interval`). A standing status is bounded by its caster's standing fee instead (Effects System Formulas B) |
| curse_slots | int | 3 | data file | Most curses on one target |
| resist | float | ≥ 0, no cap (user decision 2026-11-10; the apply-chance clamp of 5–95 % is the only bound, so every status stays possible) | Modifier System (`status_resist_pct`) | Target's resistance to statuses. Status payloads on wards add to it (Combat Defence & Healing rule 15). It sets the chance to avoid a status; a tick's damage is cut by damage-type resistance, not by this |

The status catalogue is the Effects System's (rule 9). A tick on health meets resistance and the shields it does
not pass: by default it passes ward shields and meets the body shield unless it is Chaos (Combat Defence & Healing
rules 1, 9). It never meets evade or block. A **qi burn** status (Qi Disruption) ticks linh lực instead: all + Force
resistance, passing every shield, with no cap (`qi_burn_cap` removed, user decision 2026-11-09). Drain wards bill a qi tick like any
part, so a drain ward can make it cost more than no ward (a known weakness, Combat Defence & Healing Formulas C). A duration counts ticks and falls at each tick, so duration 3 ticks three
times. A tick uses the source's values from when it was applied.

Curse bounds, each a data key (restated for the new defence, Combat revision D12; Effects System Open Question 2):

| Key | Value | Meaning | Change |
|---|---|---|---|
| ~~`curse_shred_max`~~ | retired 2026-11-10 | Resistance is in points with no floor; Sundered −150 and Exposed −100 points may push it below 0, which amplifies | Retired |
| `curse_pass_raise_max` | — | — | **Retired**: there is no ward pass now |
| `curse_drain_raise_max` | +50 % | Drain wards bill more (Leaking Ward) | Kept, drain wards only |
| `curse_cost_raise_max` | +50 % | Art cost raise | Kept |
| `curse_heal_taken_max` | 0.50 | Healing taken down (Withering). One floor of −50 % across all sources, Blood Casting included | **New** |
| ~~`curse_soul_shred_max`~~ | retired 2026-11-10 | Soul resistance has no floor, like resistance; Slackened Soul (−15 pp per stack, 2 stacks) may push it below 0, which amplifies | Retired |
| `curse_reapply_lockout` | 2 pulses | Sealed Meridian and Silence cannot be put back on a target for 2 pulses after they end | **New** |
| `curse_layer_lock_max`, `curse_tag_block_max`, `curse_duration_max` | 2, 3, 5 pulses | A locked layer counts as 1.0; a blocked tag stops arts carrying it and modifiers needing it. Silence may not name `ward`, `basic` or `escape` | Kept, one note added |
| regeneration dampen | 1 % per Stagnation stack, no cap | Divides linh lực **and** health regeneration by (1 + D / 100) (Stagnation) | Changed 2026-11-10: was a full block |

A curse past `curse_slots` replaces the one with the least duration left. Curse durations are counted in pulses,
like statuses.

**Output Range:** a tick has no upper bound (`dot_pool_cap` and `dot_pulse_cap` removed, #44 item C3) and no floor:
what reaches health is dealt exactly, so element stacks scale as priced (user decision 2026-11-10).

**Example:** Poison (Wood's debuff, Chaos, c_tick 0.019 per stack, 5 stacks), L1 × L2 = 1.265 × 1.4 = 1.771, on FX-T
(the Common Ward's 448 points stop 81.75 % of Chaos; Chaos passes the body shield): 6.31 × 0.019 × 5 × 1.771 × 0.1825 =
**0.19** per pulse, dealt exactly (ticks have no floor of 1). (Burn and Poison are element stacks priced by Effects Formulas D, exempt
from the `c_tick` range above.)
A Chaos tick at c_tick 0.3 and 5 stacks is **3.06**, with no cap.

### G. Triggers

The trigger_budget formula is defined as:

`free_hit = U · stage · c_trig · L1..L4(tags) · supp`, then the defence path as any hit (Combat Defence & Healing rule 1) ; `Σ trigger_damage ≤ trig_budget · max(direct_damage_this_pulse, 0.5 · U · stage)`, both counted since the last pulse

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| c_trig | float | ≤ 0.8 | data file | Free-hit coefficient; a chance trigger needs `chance · c_trig ≤ 0.5` |
| trigger_depth | int | 2 | data file | Chain depth, the first trigger being 1; one trigger id never fires twice in a chain |
| trig_cap | int | 6 per side | data file | Firings between two pulses; a firing past it is dropped and logged "trigger cap" |
| trig_budget | float | 0.5 | data file | Trigger damage is at most half of the direct damage since the last pulse |
| direct_damage_this_pulse | float | ≥ 0 | calculated | Per side: the health that side's own hits (arts, basic attack, companion) have removed from the defender since the last pulse, after the defence path, including the hit that set the trigger off. Ticks and trigger hits are excluded |

A refund trigger returns at most the fired art's cost, which drain and per-hit wards can then spend.
Trigger records and their actions are the Effects System's (rules 6, 7); a trigger that changes a ward uses its
"raise or lower a ward" action, with the duration on the Effect record (Combat revision D9). Combat keeps the
free-hit formula, the chain depth, `trig_cap` and the budget.

A trigger's free hit can be evaded (an evaded one deals nothing and sets off nothing) and cannot crit, like a companion hit. Its evade draw comes right after the draws of the hit that set it off, in trigger order (Formulas I).

**Output Range:** triggers add at most +50 % of the direct damage since the last pulse, or 0.25 · U · stage when that is
larger. Overflow is clipped and logged as "trigger budget".

**Example:** typical, c_trig 0.5, against FX-T with the Common Ward: free hit D 6.31 × 0.5 × 2.975 = 9.39, and
9.39 × 0.1825 − 0.946 = 0.77, so the floor of 1 applies: **1.00** dealt. Six of them make 6.00, clipped to
0.5 × 6.59 = **3.30** (one art hit's 6.59 is the direct damage since the last pulse).

### H. Realm suppression

The suppression formula is defined as:

`supp(g, P) = 1 − s_g · (1 − P)` ; `P = min(pierce_cap, Σ pierce_pct / 100)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| g | int | 0–4 | calculated (Realms) | Major realms the actor is below its target; no bonus for being higher |
| s_g | float | 0 / 0.10 / 0.25 / 0.50 / 0.75 | data file (`suppression`) | Reduction by gap |
| pierce_pct | float | ≥ 0 (percentage points) | Modifier System (`pierce_pct`) | Realm pierce. One value per hit, so it takes no damage-type scope (Modifier System rule 8) |
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
17 % and 76 %, because these fights last a few seconds. At the same realm a top thể tu beats a top-end
ward build about 75 % of the time (49 % at Deity Transformation); the user chose to measure this with real builds
first (Open Question 17).

**Example:** g = 2, P = 0.5: 1 − 0.25 × 0.5 = **0.875**.

### I. Evade, escape and fortune

The chance_roll formulas are defined as:

`p_evade = clamp(evade − accuracy + evade_realm_step · max(0, r_def − r_att), 0, evade_cap)` ; `p_escape = clamp(e_art + escape_realm_step · (r_esc − r_purs) − escape_lock_penalty · lock + escape_bonus, 0.05, 0.95)` ; `p' = p + (eff(khi_van_self) − eff(khi_van_other)) · khi_van_per_point` when 0 < p < 1, added before each roll's own cap

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| evade, accuracy | float | 0–1 | Modifier System (`evade_pct`, `accuracy_pct`, ÷ 100); evade payloads on wards | Evade applies to every hit except Soul, and never to ticks (Combat Defence & Healing rules 6, 13). Accuracy is one value per hit and takes no damage-type scope |
| evade_cap, evade_realm_step | float | 0.40, 0.02 | data file | Bounds |
| e_art | float | 0.40–0.70 | data file (art record) | Escape art base |
| escape_realm_step, escape_lock_penalty | float | 0.10, 0.15 | data file | Realm and lock terms |
| escape_bonus | float | 0–0.3 | Modifier System (`escape_pct`) | The escape sum |
| lock | int | 0 or 1 | calculated | The pursuer has a lock tag |
| khi_van_per_point | float | 0.001 | data file (kept from `duel`) | **User decision 2026-11-06:** fortune shifts every crit, evade, status, trigger and escape roll |

A chance of exactly 0 or 1 is not shifted and takes no draw, so a build with no chance effects stays
deterministic. A counted chance (a keystone, Effects System rule 12) takes no draw either. Draws run in one fixed order within each instant (a follow-up instant continues the order, rule 10): the pulse's draws; the requesting side's
hits in hit order (per hit: evade, crit, status, then that hit's trigger draws, each free hit drawing its own evade); the other side's hits the same
way; then escape rolls, requesting side first. Separate instants simply draw in time order. Times are whole
milliseconds (rule 10), so only events in the same millisecond share an instant, and events one millisecond apart are two instants. If both sides escape in one instant, the fight ends in
flight with no winner. If the other side's health is 0 or below at that point, the fight ends as a win, not a flight.

**Output Range:** evade 0–0.40; escape 0.05–0.95.

**Example:** evade 0.25, accuracy 0.05, defender one realm up: **0.22**. A 30-point fortune lead
adds 0.03 to it, so **0.25**. Escape art 0.55, one realm below a locking pursuer: **0.30**.

### J. Companions and creatures

The companion_hit formula is defined as:

`c_comp = min(c_comp_cap, share / (B_p · stage_mult))` ; `companion_hit = U_owner · stage_owner · c_comp · M(companion tags) · supp`, then the defence path as any hit

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| share | float | ≥ 0 | calculated (Spirit Beasts, `BeastKeeper.power_shares`) | The beast's power share |
| c_comp_cap | float | 1.0 (guess) | data file | A companion never out-hits a basic attack before layers |
| creature_mult | float | 1.1 | data file (replaces `beast.power_mult`) | A creature enemy has `base` and pools × 1.1, applied with `boss_pool_mult` |

A companion hit takes the damage type of its art (authored, Combat Damage Types rule 1), can be evaded, cannot
crit, deals at least 1 when anything reaches health, and counts as direct damage.

**Output Range:** `c_comp` runs 0–1. A companion hits once per `basic_cooldown` for no linh lực (rule 19).

**Example:** share 40 at Qi Refining, stage 1.00: c_comp = 0.4, so D = 6.31 × 0.4 × 3.273 = 8.26, which deals 8.26 × 0.1825 − 0.946 = 0.56, so the floor gives **1.00**, against FX-T with the
Common Ward.

### K. Rating profile and power score

The rating_clash formula is defined as:

`Off = U · stage · c_rate · M · crit_EV` per second, with `crit_EV = 1 + chance · (crit_mult − 1)` and `c_rate = basic_coef / basic_cooldown + Σ_a (c_art_a · uptime_a / cd_eff_a)` ; `D = Off · (1 − p_evade) · supp` ; `t_w = Q_use / (D · b + n_hits · fee + net_spend)` ; `t_h = (S / λ_all + (H + heal(T0)) / λ_all) / D` ; `T0 = t_h if t_h ≤ t_w, else t_w + (S + H + heal(T0) − t_w · D · λ_all) / (D_late · λ_fix)`, then `T0 = min(T0, t_fat)`, where `t_fat` is the time fatigue alone empties the health left at `fatigue_start`: 59 s plus the smallest N with `fatigue_units · U_r · N(N + 1)(2N + 1) / 6` ≥ that health (66 s from full health; Formulas A2) ; `T = T0 / (1 + pi_s · T0)` ; `R = T_(B→A) / T_(A→B)` ; `P(A wins) = clamp(1 / (1 + R^(−κ)) + (eff(khi_van_A) − eff(khi_van_B)) · khi_van_per_point, 0.02, 0.98)`

For a force: `N_eff = min(N, mass_width) + mass_reserve_weight · max(0, N − mass_width)`. Members are ranked by
`display_power`, and a force's Off, health and linh lực are its weighted member means × N_eff, with weighted means of
b, λ_all and λ_fix, so numbers count squared in R. In a clash, each side's b, λ and counted shields use the
attacker's own damage-type mix (Combat revision D7). A force's realm for `g` and its fortune are its leader's.

The power_score formula is defined as:

`display_power = B_p · sqrt(F / F_unbuilt)`, where `F = Off · ehp`, and ehp is Combat Defence & Healing Formulas G
against a fixed `reference_type_mix` fitted by the balance harness (Combat revision D7), leaving out healing.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| uptime_a | float | 0–1 | calculated | Share of its ready moments in which art a can actually fire (guard true, cost payable) |
| c_art_a, cd_eff_a | float | 1.2–12; ≥ 0.5 s | calculated | Each damage art's coefficient and effective cooldown (Formulas A2), so any number of arts sum into one rate |
| net_spend | float | any | calculated | Own art cost per second minus regeneration per second |
| Q_use | float | ≥ 0 | Combat Defence & Healing rule 10 | Usable linh lực, `qi_max · (1 − Σ reserved)` |
| b | float | ≥ 0 | Combat Defence & Healing Formulas C, G | Linh lực the defender's drain wards pay per incoming point |
| n_hits, fee | float | ≥ 0 | Combat Defence & Healing Formulas C | The attacker's hits per second, and the defender's per-hit ward fees |
| λ_all, λ_fix | float | 0.02–1.5 | Combat Defence & Healing Formulas G | Share of a hit that reaches health with every ward up; with only reserved wards, body defence and other sources. Uses the attacker's mean hit size D̄ over the whole fight, for the late phase too (user decision C2, 2026-11-08) |
| S, H | float | ≥ 0 | Combat Defence & Healing Formulas B, G | Standing ward shields and body shield that the attacker's types do not pass; starting health |
| heal(T0) | float | ≥ 0 | Combat Defence & Healing Formulas E | Healing over the fight; no decay and no cap since #44 |
| D_late | float | ≥ 0 | calculated | The attacker's D on the basic attack alone (`basic_coef / basic_cooldown`) if its own linh lực runs out first |
| pi_s | float | 0–0.3 | calculated | Soul attack rate: Σ `pct / cd_eff`, at most `soul_cap / soul_lockout` |
| κ | float | 12–16, default 14 | data file (`rating_kappa`) | One-on-one steepness: a 10 % edge wins about 79 %, a 20 % edge about 93 % |
| kappa_mass | float | 4 (guess) | data file | Force steepness; wars keep more upsets |
| mass_width, mass_reserve_weight | int, float | 12, 0.25 | data file | The first 12 members count fully, the rest at a quarter |
| F_unbuilt | float | — | calculated | F of an unbuilt stage-1.00 character of that realm |

If the denominator of `t_w` is 0 or less (only reserved wards and body defence), the wards never run out and
`T0 = t_h`.

`display_power` replaces today's chiến lực total wherever one number is shown or stored: screens, NPC
records and beast power shares. An unbuilt character shows about B_p. Rating profiles are cached and
rebuilt only when a build changes.

**Output Range:** P is 0.02–0.98. One roll decides a clash.

**Example** (#44): a typical Qi Refining mirror, on one rotation (user decision CB-02, 2026-11-08): the typical anchor's
1 s art (c_art 2.0, cost 12.96) up 30 % of the time, the basic attack, and 15 % crits of ×1.7 (crit_EV 1.105). So
c_rate = 1.0 + 2.0 × 0.3 = 1.6 and Off = 6.31 × 3.273 × 1.6 × 1.105 = 36.51; net spend = 12.96 × 0.3 − 6.05 = −2.16
(regeneration outruns the art). With the Common Ward (b = 0.1917 × 0.8175 = 0.1567), λ_all 0.1825 − 0.946 / 36.51 =
0.1566, health 439.48, linh lực 172.74, no shields and no healing: t_w = 172.74 / (36.51 × 0.1567 − 2.16) =
**48.5** s; health-only t_h = 439.48 / 0.1566 / 36.51 = **76.9** s. The wards fall first, with 277.2 health lost
and 162.3 left; then only the basic attack runs (D_late 22.82) against flesh block (λ_fix 0.974), so 162.3 /
22.23 = 7.3 s more, and T0 = **55.8** s, before fatigue's 66 s (`t_fat`). Forces of 40 against 20 identical members:
N_eff 19 against 14, R = 1.84, κ 4, P = **92 %**.

**Agreement test.** Pairs come from the harness's build generator, each side with at least one chance
effect, because a chance-free pair gives the same result under every seed. Over 200 seeds per pair, for
pairs with R of 0.5–2.0, the mean |P_rating − P_full| ≤ 0.10, and for R outside 0.9–1.1 no pair is off by
more than 0.20. Outside 0.5–2.0 the two pick the same winner in at least 97 % of pairs. The point where the
wards run out makes this harder near R = 1.

### Parameter keys

New in `combat_rules.json`: every `data file` value above. Defence keys (`default_resist`, `default_drain`,
`ward_gear_scale`, `ward_floor` and the
rest) live in its `defence` section and are owned by Combat Defence & Healing (Combat revision D18). New stat keys
for Character Stats, all in percentage points unless noted, with W prices in the Modifier System's Stat List:
`crit_chance_pct`, `crit_damage_pct`, `evade_pct`, `accuracy_pct`, `pierce_pct`, `art_speed_pct`, `art_cost_pct`,
`linh_luc_regen_pct`, `status_resist_pct`, `ward_efficiency_pct`, `soul_res_pct`, `x_soul`, `escape_pct`,
`resist_pct` (points), `resist_pen_pct` (points), `block_rating` (flat), `body_shield_pct`, `health_regen_pct`,
`healing_pct`, `healing_taken_pct`, `reserve_eff_pct`, `convert_pct`, `damage_more` (layer points), `bonus_slots` and
`bonus_ward_slots` (flat). `defense_pct` now means ward strength. New data keys from the revision:
`reference_type_mix` (Formulas K), `advisor_min_ehp_ratio` 1.25 (UI Requirements), `curse_heal_taken_max`
and `curse_reapply_lockout` (Formulas F). From the Combat economy revision (#44): `fatigue_start` and `regen_k` are new, and since 2026-11-10 `fatigue_units` and `fatigue_pow` (`fatigue_step`, `time_limit` and `curse_soul_shred_max` retired); `regen_cap`, `dot_pool_cap`, `dot_pulse_cap` and the Effects System's `qi_burn_cap` are removed.

**Removed from `combat_rules.json`:** `power.base_offense_share`, `power.base_defense_share`,
`power.cong_phap_share` (tech_power acts through linh lực, and arts come from techniques),
`power.khi_huyet_weight`, `power.linh_luc_weight`, `duel.ratio_exponent`, `duel.rounds`; and, with the Combat revision (#43): `default_ward_pass`,
`default_ward_drain`, `pass_min`, `drain_min`, `guard_base`, `guard_pool_slope`, `guard_cap`, `guard_max_mit`,
`guard_half`, `guard_share_kind`, `body_guard_pct`, `ward_art_duration`, `curse_pass_raise_max`,
`trig_ward_strength` and `trig_ward_seconds`; `hit_cost_share` moves onto ward records, and `upkeep_share` is gone with upkeep wards (#44). Kept:
`duel.injured_power_floor`, `duel.khi_van_per_point`, `duel.min_win_chance`, `duel.max_win_chance` (the
last two for the rating clash only). `beast.power_mult` becomes `creature_mult`.

## Edge Cases

**Ending a fight**

- **If both sides lose all health in the same instant:** each first runs the Down step (Effects System rule 11),
  the requesting side first; a last act's damage still adds to its target's overkill. Then rule 10's defeat check
  decides: the larger overkill share (of own `health_max`) loses, and overkill shares within `overkill_epsilon` of each other are a draw with both left at 1 health and `wound: grave`.
- **If a tick empties health:** the side keeps acting until the instant ends, and the defeat check runs
  after the instant's damage is all in. If both sides are emptied, the overkill comparison and the draw of rule 10 apply.
- **If healing or refusals keep a side up past 60 s:** fatigue grows as n² with no bound, so it ends the fight
  anyway; there is no time limit and no stalemate (retired 2026-11-10).
- **If neither side can hurt the other:** block can take every part to 0 (Combat Defence & Healing rule 12), so
  fatigue ends it: from full health both sides fall at 66 s with equal overkill shares, a draw. Otherwise a hit part
  that reaches health deals at least 1 (a tick deals its exact amount).
- **If fatigue takes both sides to 0 in one pulse:** the defeat check compares overkill shares as usual; equal
  shares are a draw with both at 1 health and `wound: grave`.
- **If a side holding a refusal falls to fatigue:** the Down step runs as for any other loss, so the refusal sets
  it to 1 health once; the next fatigue pulse is larger.
- **If a side would be Down but holds an unspent refusal:** it is set to 1 health and fights on (Effects System
  rule 11). If both sides are saved, both stand at 1 and the fight goes on.
- **If a heal and lethal damage land in the same instant:** the heal counts, and only the defeat check decides
  (Combat Defence & Healing Edge Cases).
- **If a lethal hit lands during an escape channel:** damage applies first. A side whose health is 0 or below when its
  channel ends does not flee, because an escape cannot dodge the blow that ends the fight.
- **If a side is taken from full health to 0 by one hit:** a health guard never had a moment to be true, so
  its escape art does not fire. This is intended: a far stronger enemy can kill outright.
- **If an escape art fails:** its linh lực cost and cooldown are still paid, and the fight goes on.

**Health, linh lực and wards**

- **If a pool stat is 0 or very low:** `n_k` stops at `pool_n_min`, so both pools have a size.
- **If vitality is below `v_c`:** health starts at `v_c` of its maximum (Formulas A).
- **If a request carries starting shares:** they replace the vitality start and the full linh lực, and the floor does not apply. A health share of 0 or below, a share above 1, or only one of the two is rejected at the request.
- **If a side spends all its linh lực on arts in an instant:** its drain, per-hit and default wards cover
  nothing against that instant's hits, because its own cost is paid first; reserved wards, cast wards already up and
  body defence still stand.
- **If a drain bill is larger than the live pool:** each drain ward pays the same fraction of its own bill, and the
  unpaid share of the prevented damage rejoins the part (Combat Defence & Healing rule 8, Formulas C).
- **If linh lực is 0:** each pulse's regeneration still arrives, so drain wards can pay only that small amount
  until it is gone.
- **If a per-hit ward cannot pay:** it is Down for that hit, and it is tried again at the next hit.
- **If the player switches standing wards off:** they take no payment, the default ward covers any part no other
  ward covers, and body defence still stands. They stay off for the whole fight; a cast ward in an art slot still
  fires.
- **If a side carries No Ward:** it has no default ward and cannot slot wards (rule 22's flags).
- **If regeneration is dampened by a curse:** linh lực and health still rise, divided by (1 + D / 100), until the curse
  ends; no number of stacks stops regeneration.
- **If `attack_pct` goes below −90 from penalties:** L1 stops at 0.1, so a hit is never negative.
- **If a soul attack is below `rho_min`:** it deals nothing, but its cost and cooldown are paid.
- **If a soul attack drains linh lực to 0:** drain, per-hit and default wards are down, as with any other
  loss; reserved wards stay up.
- **If a creature has no `divine_sense`:** its profile must state one; the data lint rejects a profile
  without it.

**Arts, tags and triggers**

- **If no art is ready, guarded in or affordable:** the basic attack keeps running on its timer and the arts wait.
- **If two arts are ready and only one is affordable:** the earlier slot pays and fires; the later one stays ready and fires the moment it can pay.
- **If an art's guard stays false for a long time:** it stays ready and fires the moment the guard is true; its next cooldown counts from that firing.
- **If art speed would take an art below `cooldown_min`:** it stops at `cooldown_min`.
- **If a loadout holds more arts than `slot_count`:** `compile` keeps the earliest slots and the rest do not enter the fight; the preparation screen warns first.
- **If two events differ by even one millisecond:** they are two instants, resolved in time order. Only events in the same millisecond share an instant.
- **If a character has no usable main method:** it has no divine abilities and fights with its other
  arts and the basic attack.
- **If a slotted talisman has no stock left:** it is skipped.
- **If an art's tag or a modifier's tag is unknown:** the data lint rejects it at load, and it never
  reaches a fight.
- **If conversions on a hit total over 100 %, repeat a type in a part's history, exceed 2 or touch Soul:** Combat
  Damage Types' Edge Cases decide (scaled per part in one step; a conversion back into the history moves nothing;
  a third is ignored and logged; to or from Soul is ignored and not counted).
- **If old content carries `body` or `qi` kind tags:** it loads as Physical and Force, with a warning (Combat
  Damage Types rule 10).
- **If an art declares no damage type:** compile rejects it (Combat Damage Types rule 1).
- **If triggers exceed `trigger_depth`, `trig_cap` or `trig_budget`:** the excess is dropped or clipped
  and logged, in the fixed order of rule 9.
- **If two statuses with "the stronger wins" have equal strength:** the one already on the target stays. The status
  catalogue and its stacking rules (refresh, stack to a cap, the stronger wins, or none) are the Effects System's.

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

- **Stalling with pure defence:** fatigue ends it with a draw at best, and a draw gives no win. The Event Engine
  treats a draw or a flight as the failure branch for the side that needed the win.
- **Reloading to re-roll a fight:** blocked by the fixed seed unless the setup changes, and then only
  a build's own chance effects can move.
- **Chaining triggers for unbounded damage:** blocked by the three trigger limits (Formulas G).

## Dependencies

**Upstream (Combat needs these).**

| System | Type | Interface | State |
|---|---|---|---|
| Combat Defence & Healing (#21a) | Hard | The defence path, wards, shields, block, healing and effective health; owns old rule 22, rule 23 and Formulas D | GDD approved 2026-11-08; lists Combat |
| Combat Damage Types (#21b) | Hard | Damage types and conversion | GDD approved 2026-11-08; lists Combat |
| Modifier System (#40) | Hard | Modifier operations, scope, W prices, the Stat List | GDD approved 2026-11-08; lists Combat |
| Effects System (#41) | Hard | The status catalogue, trigger Effects, the Down step, counted chance, reported costs | GDD approved 2026-11-08; lists Combat |
| Character Stats (#7) | Hard | Pool stats, stat keys, resistances, vitality | GDD in review. 11 stat keys, the fortune line and the `defense_pct` meaning added 2026-11-06; the new defence and offence keys of Parameter keys are still to add (consistency C14) |
| Realms (#8) | Hard | Realm, `stage_mult`, `power_base`, gap `g` | GDD in review |
| Cultivation Techniques (#9) | Hard | `tech_power`, unlocked divine abilities | GDD in review. Its Open Question 3 is answered here once abilities are authored |
| Time & Turn (#4) | Soft | A fight takes no seasons; preparation time belongs to the preparing system | Built, no GDD |
| Sim Core (#2), Config (#1) | Hard | Seeded stream, `Breakdown`, `combat_rules.json` | Built, no GDD |
| Meridian Map (#10) | Soft | Stat keys through Character Stats only | GDD in review |
| The Way (#39) | Soft | Stat lines, Effects and rare art nodes | GDD in review (2026-11-10). Arts need no W price: the Way's slot table bounds them (dao.md Open Question 3, closed) |
| Item Database (#13) | Soft | Equipped pieces with role tags, attack, defence and affixes; consumable arts' items | GDD complete (item-database.md rules 6, 11); lists Combat |
| Artifact Refining (#16) | Soft | Equipped artifacts, ward-gear and body-gear defence, active effects | Quick spec only; **provisional** |
| Formations (#17), Talismans (#18), Alchemy (#15) | Soft | Prepared modifiers, consumable arts, timed pills | Quick spec or no GDD; **provisional** |
| Spirit Beasts (#19) | Soft | Power share, companion art | Quick spec only; **provisional** |

**Downstream (these need Combat).**

| System | Type | Interface | State |
|---|---|---|---|
| Heavenly Tribulation (#22) | Hard | The fight engine, a tribulation as an enemy profile | GDD approved for rules (design/gdd/thien-kiep.md); build on hold with the full fight |
| Quests (#31) | Soft | A `defeat` stage opens a fight and reads the result; fight power F for the fight ratio | GDD designed (`design/gdd/quests.md`), in review; `defeat` waits on the full fight |
| Event Engine (#23) | Hard | Fight request, result | Built, no GDD; today's `duel` callers move to the result |
| NPC Builds (#24) | Hard | Compiled profile, slot order and guards | Built, no GDD |
| Living World Tick (#28) | Hard | Rating clash; keeps NPC duels rare | Built, no GDD |
| Balance Harness (#33) | Hard | Headless fights, the agreement test | Built, no GDD |
| Debug Terminal (#36), Game UI (#37) | Soft | Log, preparation data, `display_power` | Terminal built, Game UI not started |
| World DB (#3) | Soft | Notable fight record | Built, no GDD |

**Bidirectional check.** Character Stats, Realms, Cultivation Techniques, the Meridian Map and the Way
already list Combat, and so do the four sub-systems (Combat Defence & Healing, Combat Damage Types, the Modifier
System and the Effects System); Combat lists them above. No circular dependency is added:
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
| `health_units`, `qi_units`, `fatigue_start`, `fatigue_units`, `fatigue_pow` | Fight length, how much staying power sits in wards and shields, and when fatigue ends a fight |
| `pulse_interval`, `basic_cooldown`, `cooldown_min`, `escape_channel`, `soul_lockout` | The pace of a fight |
| `slots_by_realm` | How many arts a build carries, and so its burst and linh lực burn |
| `basic_coef`, `art_coef_per_cost`, `art_coef_per_cooldown` | Art power against its cost |
| `l1_soft_start`, `l1_soft_slope`, `layer_caps` | How far a build can scale |
| `crit_chance_cap`, `crit_mult_cap`, `evade_cap` | How swingy fights are |
| Defence knobs (`default_resist`, `default_drain`, `ward_gear_scale`, `ward_floor`, block, shields, healing) | Combat Defence & Healing's Tuning Knobs: how much wards, the body and healing hold |
| `regen_base`, `regen_k` | Sustain |
| `stack_cap`, `curse_slots`, `curse_drain_raise_max`, `curse_cost_raise_max`, `curse_heal_taken_max`, `curse_reapply_lockout`, `curse_layer_lock_max`, `curse_tag_block_max`, `curse_duration_max` | Status and curse strength |
| `pool_n_min`, `pool_n_max`, `duel.injured_power_floor` | Bounds on absurd stacks; the vitality floor |
| `crit_base`, `crit_mult_base`, `evade_realm_step`, `escape_realm_step`, `escape_lock_penalty`, `khi_van_per_point` | Chance rolls and fortune |
| `c_trig` cap, `c_comp_cap`, `creature_mult` | Triggers, companions and creatures |
| `soul_pct` (per art), `rating` clamp `duel.min_win_chance`, `duel.max_win_chance` | Soul art size; rating clash bounds |
| `trigger_depth`, `trig_cap`, `trig_budget` | Combo strength |
| `suppression`, `pierce_cap` | Crossing realms |
| `soul_beta`, `rho_min`, `soul_cap` | How dangerous a soul gap is |
| `overkill_epsilon` (1e-9) | When a double knockout counts as a draw |
| `rating_kappa`, `kappa_mass`, `mass_width`, `mass_reserve_weight` | Mass battle outcomes |
| `reference_type_mix` (fitted by the harness, Open Question 24) | The damage-type mix `display_power`'s ehp is read against |
| `advisor_min_ehp_ratio` (1.25) | When the Advisor warns about a build with no defence once its linh lực is spent |
| `boss_pool_mult` (per enemy) | Boss toughness |

**Knobs that move together.**

- `fight_unit_exponent`, `layer_caps`, `suppression`, `health_units` and `qi_units` jointly set the
  realm-crossing targets (Formulas H). Change one and re-run all the checks.
- `fatigue_start`, `fatigue_units` and `fatigue_pow` must start after the 30–60 s band typical fights end in and
  end a typical fight from full health by about 70 s (66 s at the defaults); the largest legal pool falls by 90 s.
- After a change to the tree's W totals, re-measure the anchors in Formulas B.

## Visual/Audio Requirements

Today's surface is the Debug Terminal, so these are the terminal's needs plus intent for the Game UI
(#37), to be settled there. Art and audio assets are deferred with those systems.

- **Terminal.** Each damage type uses its colour from Combat Damage Types (Visual/Audio), and each line also names
  the type, so nothing depends on colour alone. Critical hits, linh lực running out and a fight's end are marked
  in the log.
- **Game UI intent.** A fight plays as an ink scroll that unrolls moment by moment, with health and linh lực in
  the print layer and never in the brushwork (art pillar "Numbers in print"). Art tags map to
  glyphs (art pillar "Glyphs, not paintings"), so a new art needs no hand-painted asset.
- **Events that need a visual and a sound later:** hit by damage type, resistance cut, block, shield soak and
  break, heal and heal cap, Down refused, critical hit, status applied, trigger fired, conversion, linh lực spent
  out, escape, fight end. Combat Defence & Healing's own cue table covers the defence events.

## Game Feel

The fight is read, not played, so feel means pacing and clarity. **The moment that matters is seeing your
build work.**

- **Before the fight:** preparing is the tense part. The player should finish it knowing what their
  plan is and what could beat it.
- **During the fight:** a typical fight of 30–60 seconds (#44) reads in a few minutes at the default log level; the per-pulse summary keeps it scannable.
  One line per pulse; the player can open any hit's Breakdown.
- **After the fight:** the result names the deciding factor: when linh lực ran out and which layer did
  the most. A loss must point at something the player can change.
- **Top-end payoff:** a first-volley win over an ordinary enemy shows the whole multiplied Breakdown, so
  the number itself is the reward.
- **Upsets are rare and earned.** With no base damage spread, a surprising result comes from a build's
  own chance effects, and the log shows that.

## UI Requirements

| Screen or element | Must show | Must allow |
|---|---|---|
| Preparation | The situation (foreseen, ambush, blind), the enemy's profile as far as Open Question 4 allows, the player's health, linh lực, ward slots and their wards, the resistance panel, block and shields (Combat Defence & Healing UI Requirements), the loadout, and what each prepared item adds | Slot arts, fill ward slots and art slots with wards, switch standing wards off, set the slot order and each art's guard, use prepared items, confirm |
| Slot order editor | Slots in order, each art's cooldown, cost and guard, and which arts are ready now | Reorder slots; set an art's guard from the fixed vocabulary |
| Fight log | One line per pulse: actions, damage by type, resistance, block, shield soaks, heals, health and linh lực after | Open a hit's full Breakdown; switch between summary and full log |
| Result | Winner, how it ended, the fight time, resources spent, the deciding layer | Continue to the caller's consequences |
| Character sheet | `display_power`, health, linh lực, ward strength and efficiency, resistances by type, block, body shield, ward slots, thần thức, layer totals | Open the breakdown |

All of these work in the Debug Terminal first, with numbered menus as elsewhere. The Advisor should warn
when a build's Physical effective health at 0 linh lực is below `advisor_min_ehp_ratio` × `health_max` (1.25; Combat
Defence & Healing Formulas G with x = 0; Guidance, #35; a data knob, Combat revision D16).

> **📌 UX Flag — Combat:** this system has UI requirements. In Pre-Production, run `/ux-design` for the
> preparation screen, slot order editor and fight log before writing epics. Stories that touch
> this UI should cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD | Refers to | Mechanic or value | Note |
|---|---|---|---|
| Rule 3, Formulas A, E2 | character-stats.md Formulas C | `vitality_max`, `spiritual_power`, `divine_sense`, vitality floor 0.4 | Read only |
| Formulas B | character-stats.md | Additive pct stacking, `attack_pct`; low-vitality and heart-demon modifiers | Read only |
| Formulas I | character-stats.md (the fortune table) | Fortune line | Edited 2026-11-06: fortune now shifts chance rolls |
| Formulas C, E, E2, F, H, I; Parameter keys | character-stats.md stat keys | 11 keys added 2026-11-06, `defense_pct` as ward strength; the defence and offence keys of Parameter keys | Partly added; the rest is consistency C14 |
| Rule 20, Formulas A, H | canh-gioi.md | `power_base`, `stage_mult`, the realm ladder | Read only |
| Rule 14 | canh-gioi.md rule 16; character-stats.md | Capability #9: defeat reported, +2 heart demon | Closed 2026-11-06 (Open Question 12): knockout only; both GDDs still say "defeat" and "kill" |
| Rule 13, Formulas A, D | cong-phap.md rules 13–14, Formulas C | Divine abilities, `tech_power`, body techniques (block, body shield and resistance, combat-defence.md rule 12), the technique line | `cong_phap_share` line removed; cong-phap.md rule 14 and AC-CP-39 edited 2026-11-06 |
| Formulas B | kinh-mach-do.md Formulas A and A2; registry `stat_power_weights` | 1 W = +1 %; about 106 W to 1,172 W by realm end | W stays additive |
| Rule 13, Formulas B | dao.md rule on arts, Open Question 3 | Art format, `dao_premium` | Arts remain on hold until this GDD is approved |
| Interactions, rule 12 | item-database.md rules 6, 11, Formulas E | Role tags (weapon, ward_gear, body_gear, utility; D2 applied 2026-11-08), equipped set, consumable arts | Read only |
| Rules 4, 22, 23; Formulas A, C, D, F, G, J, K | combat-defence.md | The defence path, wards, body defence, healing, effective health | Replaced old rules 22–23 and Formulas D (Combat revision #43) |
| Rules 6, 7; Formulas C | combat-damage-types.md | Damage types, conversion, which types pass shields | Replaced the kind family |
| Rule 5; Formulas B; Parameter keys | modifiers.md | Operations, scope, W prices, `damage_more` layer points, the Stat List | Read |
| Rules 7–10, 14, 15; Formulas F, I | effects.md | Status catalogue, trigger Effects, the Down step, counted chance, reported costs | Read; the status catalogue moved there |
| Formulas J | design/quick-specs/phu-luc-linh-thu-thanh-tuu.md | Beast power share | Provisional |
| Rule 12 | design/quick-specs/luyen-khi-and-tran-phap.md | Formation and artifact inputs | Provisional |

## Acceptance Criteria

Drafted by qa-lead, then updated by the main session for the rulings after its report and for the rework to one
health bar and wards. Revised by qa-lead 2026-11-08 for the Combat revision (#43): criteria that the four
sub-system GDDs now test are one-line pointers to them (Combat revision D15), and every number was recomputed
from this GDD's Formulas and the fixtures below. Performance budgets are proposals and have not been measured.

Evidence: Logic tests under `tests/unit/combat/`, Integration tests under `tests/integration/combat/`,
Balance Harness output under `production/qa/evidence/balance/`, terminal evidence under
`production/qa/evidence/debug-terminal/`. **[Harness]** means the check runs in the Balance Harness
(`tools/balance/autoplay.gd`), not in the gdUnit suite, and its record goes to `production/qa/evidence/balance/`
(Open Question 25).

**Pointers.** A pointer names the criteria in Combat Defence & Healing (AC-CD), Combat Damage Types (AC-DT), the
Modifier System (AC-MD) or the Effects System (AC-EF) that test the rule. It passes when those criteria pass. It
keeps its ID so numbering never shifts.

**Fixtures.** Values are the `combat_rules.json` defaults at full precision, with no rounding between
steps. Tolerance is ±0.01 unless stated. A pointer uses its owner's tolerance (±0.1 in Combat Defence & Healing).

- **FX-T (typical Qi Refining):** B_p 100, stage 1.00, U 6.30957. Layer points 26.5 / 40 / 40 / 20 / 10, so M
  3.27281. n_body 1.08833, n_qi 1.053, so health 439.48 and linh lực 172.74. The Common Ward (all 342.5 points,
  drain 0.328 since #44; was a 0.50 share and 1.64) in a ward slot, ws = we = 30.8, so 448 points (stops 81.75 %) and a drain rate of 0.19172 per point prevented. Block
  rating 15.0 (flesh 4.79 + armour 10.2), so 0.946 points. No reservation, no ward shield, no body shield. One
  Physical art: c_art 2.0, cost_share 0.075, cooldown 1 s, plus the basic attack (Physical). No chance fields.
  These match Combat Defence & Healing's FX-T (AC-CD-54).
- **FX-U (unbuilt Qi Refining):** talent 45, stage 1.00, no bonuses, technique power 1.0, basic attack only, the
  default ward (all 60 points, stopping 37.5 %, drain 0.40, not scaled by ws or we). Health 403.81, linh lực 164.05, block
  rating 4.4 (0.278 points).
- **FX-C (chance fixture):** FX-T plus crit chance 0.30 at ×2.0, evade 0.20, one status at chance 0.50, one
  trigger at chance 0.50, and an escape art.
- **Thể tu fixture:** Combat Defence & Healing's (Formulas G): block rating 88.3 (5.57 points), body shield 436.1,
  Physical resistance 36.1 points from body sources plus the default ward's all 60 points (Physical 96.1 points),
  health 484.6, linh lực 164.1.

**Fight shell and determinism**

- **AC-CB-01** [Logic] Rules 1, 15. **GIVEN** FX-C against FX-C with one seed, **WHEN** the fight runs twice in one process and once more after 50 unrelated fights, **THEN** the results and serialized logs are byte-identical on that platform (damage values are floats, so identity across platforms is not promised; Open Question 15). **GIVEN** 20 different seeds, **THEN** at least two logs differ. **GIVEN** a draw spy on one instant, **THEN** draws occur in the order of Formulas I: the pulse's draws, the requesting side's hits (evade, crit, status, triggers per hit), the other side's hits, escape rolls; swapping which side requested swaps the two hit groups.
- **AC-CB-02** [Logic] Rule 15. **GIVEN** a world seed and fight id, **WHEN** the fight stream is built twice, **THEN** its first 10 draws match, and a different fight id gives different draws. **GIVEN** any outer `RandomNumberGenerator`, **WHEN** a fight runs, **THEN** that generator's state is unchanged.
- **AC-CB-03** [Logic] Rule 15. **GIVEN** two builds whose chance fields are all 0 or 1, **WHEN** they fight under 100 seeds, **THEN** all logs are identical except the seed field. **GIVEN** the same hit at two times with the same state, **THEN** its damage is equal.
- **AC-CB-04** [Logic] Formulas I, fortune. **GIVEN** a roll spy: evade 0.22 with a +30 lead rolls at 0.25; evade 0.40 with a +99 lead stays at `evade_cap`; escape stops at 0.95 and 0.05; crit stops at `crit_chance_cap`. **GIVEN** chance 0 and chance 1 with leads of ±99 over 1,000 seeds, **THEN** neither is shifted, neither takes a draw, the chance-0 effect never fires and the chance-1 effect always fires.
- **AC-CB-05** [Logic] Rules 2, 21. **GIVEN** the fight engine source, **WHEN** scanned, **THEN** it has no `Time.`, `OS.`, `Node`, `get_tree` or autoload reference. **GIVEN** a character, **WHEN** `compile` runs twice, **THEN** the profiles are equal and the serialized character is unchanged. The fight runs under `--headless` with no scene tree.
- **AC-CB-06** [Logic] Rules 1, 14. **GIVEN** a character and world DB fixture, **WHEN** a fight runs, **THEN** both serialize unchanged and the world clock has not moved. The call returns synchronously. The result holds the winning side, how it ended (knockout, draw or flight), the fight time, each side's end health, linh lực and `wound` (`none`, `grave` or `mortal`), resources spent, the deciding layer, the reported costs and gains that outlive the fight, and the log. **GIVEN** two layers with equal damage-weighted totals over the winner's hits, **THEN** the lower-numbered layer is the deciding layer. **GIVEN** a soul win, a draw or a flight, **THEN** the result has no deciding layer and says so.

**Profile and pools**

- **AC-CB-07** [Logic] Rules 2, 18. **GIVEN** a cultivator, a creature and an NPC, **WHEN** compiled, **THEN** all three return the same schema: health and linh lực maxima and the reserved share, thần thức, wards and ward slots, resistance by damage type, block, shields, healing stats, soul and status defence, layered modifiers, the art loadout with its derived tags, triggers and Effects, and the tag set. **GIVEN** a new enemy added only as fixture JSON, **WHEN** it fights, **THEN** the fight completes with no code change.
- **AC-CB-08** [Logic] Formulas A. **GIVEN** `power_base` at the defaults, **THEN** U is 6.31 / 15.85 / 39.81 / 100.00 / 251.19.
- **AC-CB-09** [Logic] Formulas A. **GIVEN** FX-T's stats, **THEN** health is 439.48 and linh lực 172.74. **GIVEN** stat 0, **THEN** n is 0.25, health 100.95 and linh lực 41.01. **GIVEN** Deity Transformation at n ≥ 8, **THEN** health is 128,608.3 and linh lực 52,247.2 (±0.5).
- **AC-CB-10** [Logic] Rule 3, Formulas A. **GIVEN** FX-T, **THEN** v 0.7 starts health at 307.64, v 0.3 at 175.79 (the 0.4 floor), v 1.0 at 439.48, and linh lực starts at its usable maximum, 172.74. **GIVEN** FX-T with Still Lake reserving 0.4333, **THEN** linh lực starts at 97.90. **GIVEN** a fight ending with health at 50 % and v 0.7, **THEN** `v_after` is 0.5; ending at 90 %, it stays 0.7.
- **AC-CB-78** [Logic] Rule 3, Formulas A (D6). **GIVEN** FX-T at v 0.7 and starting shares 0.25 and 0.5, **THEN** health starts at 109.87 and linh lực at 86.37, below the vitality floor with no floor applied. **GIVEN** the same shares on FX-T with Still Lake reserving 0.4333, **THEN** linh lực starts at 48.95 (0.5 of the usable 97.90), not 86.37. **GIVEN** no shares, **THEN** the start is unchanged (AC-CB-10). **GIVEN** a linh lực share of 0, **THEN** it is accepted and linh lực starts at 0. **GIVEN** a health share of 0, a share above 1, or only one share, **THEN** the request is rejected.
- **AC-CB-11** [Logic] Rules 3, 4. **GIVEN** a Physical hit, a Poison tick, a Qi Disruption tick and a soul hit, **WHEN** each resolves, **THEN** the hit meets evade, resistance, block, shields and health in that order; the Poison tick meets resistance and the shields it does not pass, never evade or block; the Qi Disruption tick meets resistance and comes off linh lực, passing every shield; and the soul hit meets only soul resistance and soul wards (numbers: AC-CD-01, 02, 03). **GIVEN** a curse, **THEN** it carries no damage type and changes no pool. **GIVEN** health at 0 after the instant and no refusal, **THEN** the side is Down with a mortal wound and acts no more. **GIVEN** linh lực at 0 and health above 0, **THEN** the fight goes on.
- **AC-CB-12** Pointer (D15). The drain ward's numbers on FX-T (7.54 through resistance, bill 6.47, 6.59 dealt, the short-pool leak) are tested by AC-CD-22; the default ward's by AC-CD-32.
- **AC-CB-13** Pointer (D15). Resistance in points with no cap or floor: AC-CD-09 (negative R amplifies), AC-CD-10 (share stopped; `resist_cap_pct` rejected at load). Ward strength floor, no ceiling: AC-CD-16. Drain bill across ws −90 to 400: AC-CD-24. Body guard is retired.

**Layers and hits**

- **AC-CB-14** [Logic] Rule 5. **GIVEN** FX-T, **THEN** M is 3.2728 and the Breakdown has one line per layer. **GIVEN** two +10 `damage_more` in L2, **THEN** L2 is 1.20. **GIVEN** +10 in L2 and +10 in L4, **THEN** L2 × L4 is 1.21.
- **AC-CB-15** [Logic] Formulas B. x1 200 gives L1 3.00; x1 293 gives 3.465; x1 1,000 gives 5.00; x1 −120 gives 0.1 and a positive hit; all layers over their caps give M 350.
- **AC-CB-16** [Logic] Formulas B anchors. **GIVEN** x1 at 25 % of W for 106 / 248 / 447 / 739 / 1,172 W and L2–L5 at 1.4, 1.4, 1.2, 1.1, **THEN** M is 3.27 / 4.19 / 5.48 / 7.37 / 8.96. **GIVEN** 45 % of W and L2–L5 at 4.0, 3.5, 2.5, 2.0, **THEN** M is 103.4 / 148.1 / 210.4 / 256.4 / 324.6.
- **AC-CB-17** [Logic] Formulas B, L3. **GIVEN** Σ artifact attack 40 at B_p 100, **THEN** x3 is 40 at stage 1.00 and 27.59 at stage 1.45. **GIVEN** a W-priced key, **WHEN** compiled, **THEN** it fills L1 and leaves L2–L5 unchanged.
- **AC-CB-18** [Logic] Rules 6, 12. Scope matching (a modifier scoped [sword, hoa] applies to a sword art of element hoa only) is tested by AC-MD-09. **GIVEN** ground with two tags, **THEN** each applies independently, and each shows as its own line in the opening Breakdown.
- **AC-CB-19** Pointer. Conversion totals (146 against 130): AC-DT-14. Offence modifiers on a part's earlier types: AC-DT-18. Resistance by final type: AC-DT-08. Element tags never meet defence: AC-DT-11, AC-CD-11.
- **AC-CB-20** Pointer. Over-100 % scaling: AC-DT-16. Conversion back into the history, and to or from Soul: AC-DT-17. A third conversion ignored and logged: AC-DT-21. Order and same-step chains: AC-DT-27, AC-DT-28. A part at share 0: AC-DT-29.
- **AC-CB-21** [Logic] Formulas C. **GIVEN** FX-T's art against FX-T, **THEN** base is 12.62, D 41.30 and dealt 6.59. **GIVEN** the Common Ward switched off (the default ward covers the hit), **THEN** 24.87 is dealt. **GIVEN** linh lực 0 (no ward up), **THEN** 40.35 is dealt. **GIVEN** g 2 and P 0.5 with the Common Ward, **THEN** 5.65 is dealt.
- **AC-CB-22** [Logic] Formulas C, crit. **GIVEN** a ×1.7 crit on AC-CB-21's hit with the Common Ward, **THEN** 11.87 is dealt. Summed chance 0.7 stops at 0.5. Summed multiplier 3.4 stops at 3.0. A two-part hit takes one crit draw. A build with no crit bonus never crits.
- **AC-CB-23** [Logic] Formulas C, floor and overkill. **GIVEN** a basic attack (c 1.0) with M 0.1 against FX-U, **THEN** a part deals at least 1, and a two-part hit at least 1 per part. **GIVEN** the same hit against FX-T, **THEN** block takes it to 0 and it deals 0, logged "blocked" (AC-CD-05). **GIVEN** health_before 10, dealt 30, health_max 100, **THEN** overkill is 0.20, health may read −20 until the instant's defeat check, and is 0 after it unless the Down step refuses.

**Timeline**

- **AC-CB-24** [Logic] Rule 10. **GIVEN** an event spy, **THEN** an instant logs in this order: the pulse (pulse triggers; standing statuses' fees; ticks; durations; linh lực and health regeneration; fatigue from `fatigue_start`; the reset of `trig_cap` and the trigger budget); both sides' art costs in slot order; the requesting side's hits in hit order with their triggers; the other side's hits; escapes; the Down step; the defeat check. **GIVEN** a successful escape, **THEN** no later event follows it, and the result is a flight (or a knockout win for the escaper if the other side is Down). **GIVEN** a follow-up instant, **THEN** only arts fire in it (no pulse, and no basic attack or companion hit, since none is due).
- **AC-CB-25** [Logic] Rule 10. **GIVEN** a linh lực loss that lands before B's art is due and leaves it unaffordable, **THEN** the art waits ready and fires the moment it can pay. **GIVEN** that loss and B's art in the same instant, **THEN** B's cost is paid first and the art fires. **GIVEN** two sides that would each knock out the other in one instant, **THEN** both hits land. **GIVEN** chance-free fixtures with A and B swapped, **THEN** the winner and pools mirror. **GIVEN** a side's art cost and an incoming hit in one instant, **THEN** the costs are paid first, in slot order, and drain and per-hit wards use what remains.
- **AC-CB-26** [Logic] Rule 10, defeat check. **GIVEN** both sides at 0 health after an instant's damage, with no refusal or last act on either side: overkill 0.30 against 0.10 means the 0.10 side wins and stands at 1 health; overkill shares within `overkill_epsilon` are a draw with no winner, both sides at 1 health with `wound: grave` and neither `mortal`, whatever their linh lực shares, and the same result under every seed with no random draw taken. **GIVEN** unequal pools with 40 against 30 absolute overkill on `health_max` 400 and 100, **THEN** the 100-pool side (0.30) loses and the 400-pool side (0.10) wins. **GIVEN** a side whose health reaches 0 partway through an instant, **THEN** its remaining hits and their triggers in that instant still land. Overkill counts ticks, hits, trigger hits and last acts in the instant against health at the instant's start.
- **AC-CB-27** [Logic] Rules 10, 22 (D9, D19). **GIVEN** FX-T with Still Lake and a drain ward, **THEN** at t = 0 the reservation is taken before any event, and both wards are Up with no art firing and no payment made. **GIVEN** a cast ward in an art slot with cooldown 4 s and duration 3 s, **THEN** it fires at t = 4.000 like any art, paying in the art-cost step in its slot order. **GIVEN** a hit at t = 7.000, the millisecond its duration ends, **THEN** the hit meets the ward; a hit at t = 7.001 does not. **GIVEN** an Effect's timed ward change ending at a millisecond, **THEN** the same rule holds. **GIVEN** either expiry, **THEN** it fires nothing: no art fires and no pool changes because of it. **GIVEN** a standing ward shield partly soaked, **THEN** no recharge event is scheduled, and the shield read at the next event has AC-CD-28's recharge for the time passed. Ward states and switching off: AC-CD-17, AC-CD-18.
- **AC-CB-28** [Logic] Rule 10, pulse. **GIVEN** a tick that empties health, **THEN** that side still acts in the same instant, the Down step and defeat check run after the instant, and with no refusal that side is Down and the fight ends (it is never left at 0 or below with the fight going on). **GIVEN** ticks that down both sides, **THEN** AC-CB-26's chain applies. **GIVEN** a status applied between pulses, **THEN** it first ticks at the next pulse.
- **AC-CB-29** [Logic, Harness] No time limit (user decision 2026-11-10). **GIVEN** the result enum, **THEN** it holds knockout, draw and flight only, and a record or caller naming `stalemate` or `time_limit` is rejected at load. **GIVEN** a side with the largest legal pool (n 8, `boss_pool_mult` 10, health 32,305 at Qi Refining) that nothing else harms, **THEN** fatigue empties it at t = 90. **GIVEN** any harness fight still running at t = 120, **THEN** the harness reports it as a bug (a reporting threshold, not a game rule: the fight itself has no limit).
- **AC-CB-30** [Logic] Formulas B, E (#44, worked by hand). **GIVEN** FX-U against FX-U, **THEN** each basic hit deals 3.666 (6.31 × 0.625 − 0.278) and bills 0.947 linh lực against 5.74 regenerated, so the default ward never falls; health is 400.15, 396.48, 392.82 … after t = 1, 2, 3, fatigue joins from t = 60, and the fight ends at t = 64.000 as a draw (equal overkill; flat n² fatigue). **GIVEN** FX-T against FX-T, **THEN** the art (12.96) fires every second while affordable, linh lực first falls below 1 at t = 10, and from then the drain bills take only what regeneration pays, so part of each prevented share leaks; health after t = 1 to 4 is 430.07, 420.65, 411.24, 401.83 (±0.02), and the fight ends at t = 34.000 as a draw. Formulas K's averaged rotation gives 55.8 s (AC-CB-49).
- **AC-CB-31** [Logic] Rules 11, 23 (D14). **GIVEN** FX-T that spends all its linh lực in an instant, **THEN** its drain, per-hit and default wards cover nothing against that instant's hits, and reserved wards, cast wards already Up and body defence still stand. **GIVEN** regeneration of 6.05 at the next pulse and a hit of D 41.30, **THEN** the Common Ward's bill of 6.47 is paid at 0.934, the pool ends at 0 and 8.82 is dealt. **GIVEN** no linh lực, **THEN** no linh lực art fires, the basic attack still fires, and an art with `body_cost_share` still fires and cannot take health below 1. An Effect's health payment can put the side Down (AC-EF-07).

**Arts and linh lực**

- **AC-CB-32** [Logic] Rule 13, Formulas A2. **GIVEN** three slotted arts with cooldowns 1, 1 and 3 s, all affordable, **THEN** nothing fires at t = 0, the first two fire at t = 1 in slot order, and the 3 s art fires at t = 3 and next at t = 6. **GIVEN** linh lực for only one at t = 1, **THEN** the first slot fires and the other stays ready and fires when it can pay. An art whose guard is false stays ready, fires the moment the guard is true, and its next cooldown counts from that firing. **GIVEN** an escape art guarded on own health below 30 % and a hit at t = 5 that takes health from 40 % to 20 %, **THEN** the art fires in a follow-up instant at t = 5 (cost paid, then hits, no pulse), not at the next event, and fires once. **GIVEN** the same guard and health already at 20 % at the start of the instant, **THEN** it fires in that instant, before that instant's hits. **GIVEN** a tick in the instant's pulse that takes health from 40 % to 20 %, **THEN** the guard reads true and the art fires in that same instant, before that instant's hits. **GIVEN** two ready arts and linh lực for one, **THEN** the second slot sees the pool after the first paid. **GIVEN** an escape channel open, **THEN** no second escape art of that side fires until it ends. The basic attack fires at every `basic_cooldown` whatever else fires. Cooldown 10 s at `art_speed_pct` 100 gives 5 s, sources of 100 and 50 give 4 s, and 1 s at 300 stops at 0.5 s. Art speed leaves `basic_cooldown` unchanged. Cooldown 10 s at `art_speed_pct` 200 is 3,333 ms: firings at 3.333, 6.666 and 9.999 s, and the 9.999 s firing is a separate instant from the 10 s pulse. A guard outside the fixed vocabulary is rejected at load.
- **AC-CB-76** [Logic] Rule 10, hit order. **GIVEN** a side firing two arts, the basic attack and a companion in one instant against FX-T with linh lực for one full drain bill, **THEN** the first slot's hit is billed in full, the second is billed what remains and its unpaid share leaks (Combat Defence & Healing Formulas C), and the basic attack and the companion land after them in that order; swapping the slot order swaps which hit is billed in full. **GIVEN** the same inputs twice, **THEN** the log order is identical. A side that goes Down in an instant still lands its whole hit list for that instant.
- **AC-CB-77** [Logic] Rule 13, Formulas A2. **GIVEN** no bonus sources, **THEN** `slot_count` is 3 / 4 / 5 / 6 / 7 by realm. **GIVEN** Core Formation with one source, **THEN** 6; **GIVEN** Qi Refining with three, **THEN** 6, with no cap on sources. A talisman, the escape art and a ward in an art slot each take a slot; the basic attack and wards in ward slots do not. **GIVEN** more arts than slots, **THEN** only the earliest slots enter the fight.
- **AC-CB-33** [Logic] Rule 13, edge cases. **GIVEN** a talisman with stock 1, **THEN** it fires once and is skipped afterwards. **GIVEN** no usable main method, **THEN** the character fights with its other arts and the basic attack: Physical, tags physical, hit, art and basic, coefficient 1.0, no cost.
- **AC-CB-34** [Logic] Formulas E. **GIVEN** cost_share 0.075 at `qi_max` 172.74, **THEN** the cost is 12.96 and regeneration 6.05, and with nothing incoming a 1 s art fires 24 times in a row. **GIVEN** Still Lake reserving 0.4333, **THEN** the cost and regeneration are unchanged and the art fires 13 times in a row. **GIVEN** pool exactly equal to the cost, **THEN** the art fires. **GIVEN** a regeneration bonus of +6 pp, +30 pp and +100 pp, **THEN** regeneration is 7.98 %, 15.97 % and 24.32 % of `qi_max` a pulse (`regen_k` 0.08, log curve), and keeps rising with more bonus. The pool never exceeds its usable maximum.
- **AC-CB-35** [Logic] Rule 11, edge cases. **GIVEN** 100 Stagnation stacks and regeneration of 6.05 linh lực and 4.0 health a pulse, **THEN** 3.03 and 2.0 are restored; at 200 stacks 2.02 and 1.33; at any count regeneration stays above 0. **GIVEN** a soul attack that empties linh lực, **THEN** drain, per-hit and default wards are down and reserved wards stay up. No rule stops a side spending to 0.
- **AC-CB-36** [Logic] Formulas I, escape. **GIVEN** e_art 0.55, one realm below a locking pursuer, **THEN** p is 0.30. A failed escape pays its cost and cooldown. The roll comes `escape_channel` after the art fires, and hits landing in the channel apply. A success gives Fled and a flight result. A side whose health is 0 or below when its channel ends does not flee. If both escape in one instant, the fight ends in flight with no winner. If the other side's health is 0 or below at that point, it is a win. A channel still open when the fight ends (a knockout or a draw) never rolls.
- **AC-CB-37** [Logic] Formulas I, evade. Evade 0.25, accuracy 0.05, defender one realm up gives 0.22. Evade 0.60 stops at 0.40. Evade below accuracy gives 0. At evade 0.40, soul hits and ticks are never evaded over 1,000 rolls. An evaded hit deals nothing and fires no on-hit trigger.

**Statuses**

- **AC-CB-38** [Logic] Rule 7, Formulas F. **GIVEN** a Chaos tick at c_tick 0.3, 5 stacks, L1..L4 1.771, on FX-T, **THEN** the tick after resistance is 3.06, with no cap. **GIVEN** a Qi Disruption tick on FX-T, **THEN** it takes linh lực with no cap. **GIVEN** three statuses that tick 5.5 each, **THEN** the pulse takes 16.5 and nothing is clipped or logged "dot cap". Which shields a tick meets: AC-CD-02.
- **AC-CB-39** [Logic] Formulas F. **GIVEN** a duration-3 status, **THEN** it ticks three times, the first at the next pulse after it is applied. Stacking (refresh, stack to a cap, the stronger wins) is tested by AC-EF-19, AC-EF-20 and AC-EF-21.
- **AC-CB-40** [Logic] Rule 8, Formulas F (D12, D13). Shred by Sundered (−150 points a stack) and Exposed (−100 points), with no floor: AC-EF-24. Healing taken (one floor of −50 %): AC-EF-60. **GIVEN** Leaking Ward raising drain by 80 % on FX-T's Common Ward, **THEN** a D 41.30 hit bills 9.71 (6.47 × 1.5, +50 %), not 11.65. **GIVEN** Slackened Soul at its 2-stack cap, **THEN** soul resistance falls by 30 pp. **GIVEN** a test record with the stack cap raised to 3, **THEN** it falls by 45 pp (`curse_soul_shred_max` is retired). **GIVEN** soul resistance 20 and 2 stacks, **THEN** it is −10, and an equal soul's `rho` is 1.10 (no floor). **GIVEN** Sealed Meridian ended at pulse 4, **THEN** it cannot be reapplied at pulses 5 and 6 and can be at pulse 7. **GIVEN** L2 locked on FX-T, **THEN** M is 2.3377. No curse lowers health or linh lực. A matching cleanse removes it; a non-matching one does not. A fourth curse replaces the one with the least duration left. A cost raise of +50 % makes FX-T's art cost 19.44 (12.96 × 1.5).
- **AC-CB-41** [Logic] Formulas F. Chance 0.8 with resist 0.5 gives 0.40. Chance 0.02 gives 0.05. Chance 1.0 stays 1.0 and chance 0 stays 0, whatever the resist.
- **AC-CB-80** [Logic] Rule 7, Formulas F (D11). **GIVEN** a Chaos test status (*test fixture*: c_tick 0.15, 5 stacks, L1..L4 1.771, supp 1) on FX-T, **THEN** each tick deals 1.53 and the Common Ward bills 1.31 for it. **GIVEN** the source has Chaos penetration 100 points when it applies the status, **THEN** R is 348 (stops 77.68 %), each tick deals 1.87 and the bill is 1.25. **WHEN** the source's penetration or the target's Chaos resistance changes after the status is applied, **THEN** the running status still deals 1.87; a status applied after the change uses the new values. **GIVEN** a Fire tick that a full body shield soaks entirely, **THEN** 0 reaches health. **GIVEN** a tick of which 0.40 reaches health, **THEN** 0.40 is dealt (no floor for ticks).

**Triggers**

- **AC-CB-42** [Logic] Formulas G (D9). **GIVEN** c_trig 0.5 against FX-T with the Common Ward, **THEN** a free hit has D 9.39 and deals 1.00 (the floor). **GIVEN** six free hits (6.00) and direct damage 6.59, **THEN** trigger damage is clipped to 3.30 and the log says "trigger budget". **GIVEN** direct damage 0, **THEN** the budget is 1.58. **GIVEN** two art hits removing 10 and 3.34 health and a tick of 4, **THEN** `direct_damage_this_pulse` is 13.34 (ticks and trigger hits excluded), and it resets at the next pulse. **GIVEN** a trigger that raises a ward, **THEN** it uses the Effects System's ward action with its duration on the Effect record, and no `trig_ward_*` key is read. A free hit never crits, and an evaded one deals nothing and fires no trigger.
- **AC-CB-43** [Logic] Rule 9, Formulas G. **GIVEN** a trigger loop A to B to A, **THEN** the fight terminates and no id fires twice in a chain. A chain stops at depth 2, counting the first trigger as 1. The seventh firing between two pulses is dropped and logged. Each event in rule 9 fires its fixture trigger. A refund returns at most the art's cost.

**Realm and companions**

- **AC-CB-44** [Logic] Formulas H, rule 20. supp(0, 0) is 1, supp(1, 0) 0.90, supp(2, 0.5) 0.875, supp(3, 0) 0.50, supp(4, 0) 0.25. `pierce_pct` 90 stops at P 0.75. An actor above its target has g 0 and supp 1.
- **AC-CB-45** [Logic] Rule 19, Formulas J. **GIVEN** share 40 at Qi Refining against FX-T, **THEN** c_comp is 0.4, D is 8.26 and the hit deals 1.00 (8.26 × 0.1825 − 0.946 = 0.56, raised to the hit floor of 1; Formulas J). Share 500 caps c_comp at 1.0. The companion hits once per `basic_cooldown` for no linh lực with its authored damage type, cannot crit or be targeted, can be evaded, and stops when its owner is Down.
- **AC-CB-46** [Logic] Rule 18, Formulas A, J. An FX-U creature has health 111.05, linh lực 180.45 and base damage ×1.1. A creature with no realm uses its stated equivalent for g. **GIVEN** n 8 and `boss_pool_mult` 10 at Qi Refining, **THEN** health is 32,305.2 and linh lực 13,123.9 (±0.5). (The 4-second boss check needs a top-end build and lives in AC-CB-54.)

**Preparation**

- **AC-CB-47** [Logic] Rule 12, edge cases. **GIVEN** an item adding x4 +30: foreseen accepts everything and L4 is 1.30; ambush accepts talismans, ready pills and a standing formation, and refuses a new formation or coating; blind accepts only the loadout and saved slot order, and L4 is 1.00 with no ground tags. **GIVEN** a ward change, **THEN** foreseen accepts filling ward slots and art slots with wards and switching standing wards off, and ambush and blind keep the loadout's wards as they are. Each accepted item appears in the opening Breakdown.
- **AC-CB-48** [Integration] Edge cases. **GIVEN** a pill chosen in preparation, **WHEN** the player backs out, **THEN** stock is unchanged; on confirm it is consumed once. **GIVEN** a save, a fight, a reload and the same setup and fight id, **THEN** the result is identical. **GIVEN** a changed setup on FX-C, **THEN** the log differs.

**Rating profile**

- **AC-CB-49** [Logic] Formulas K (#44). **GIVEN** the typical rotation (art uptime 0.3, so c_rate 1.6 and Off 36.51), the Common Ward (b 0.1567), λ_all 0.1566, λ_fix 0.974, health 439.48, linh lực 172.74, net spend −2.16, no shields and no healing, **THEN** t_w is 48.5, t_h 76.9, health left when the wards fall 162.3, D_late 22.82 and T0 55.8 (±0.1), below `t_fat` 66. **GIVEN** a `t_w` denominator of 0 or less (only reserved wards and body defence), **THEN** T0 is t_h. R 0.5 clamps P to 0.02 and R 2 to 0.98. At κ 14, R 1.1 gives 0.792 and R 1.2 gives 0.928. A +30 fortune lead adds 0.03.
- **AC-CB-50** [Logic] Formulas K, forces. N 40 gives N_eff 19, N 20 gives 14, N 12 gives 12, N 13 gives 12.25. Forces of 40 against 20 identical members give R 1.84 and P 0.920 at κ 4. One clash takes one draw, and the same seed gives the same outcome.
- **AC-CB-51** [Logic] Formulas K, power score (D7). An unbuilt stage-1.00 character shows `display_power` equal to B_p. A build with 4 × F_unbuilt shows 2 × B_p. c_rate with basic 1.0 at 1 s and one art of 2.0 at 4 s with uptime 1 is 1.5. Two such arts give 2.0. **GIVEN** the thể tu fixture as defender in a clash, **THEN** its b, λ and counted shields use the attacker's damage-type mix: against an all-Chaos attacker its body shield counts 0, against an all-Physical attacker it counts 109.0. **GIVEN** one build compiled twice with different `reference_type_mix` data, **THEN** `display_power` changes; **GIVEN** different opponents, **THEN** it does not. `display_power`'s ehp leaves out healing.
- **AC-CB-52** [Integration, Bot: Balance Harness] Agreement test. Formulas K sums any number of arts through `c_rate`, so multi-art pairs are included. **GIVEN** at least 100 sampled pairs from the harness's build generator, each side holding a chance effect, at 200 seeds each: for R 0.5–2.0, mean |P_rating − P_full| ≤ 0.10, and for R outside 0.9–1.1 no pair is off by more than 0.20. Outside 0.5–2.0 the two pick the same winner in at least 97 % of pairs. Output goes to `production/qa/evidence/balance/[date]-combat-agreement.md`.

**Balance Harness**

- **AC-CB-53** [Integration, Bot: Balance Harness] Formulas H. **GIVEN** top-end at pierce 0.5 against typical, with the Formulas B anchors at stage 1.00, at least 200 runs per cell: g 1 wins at least 95 % from each of four starting realms; g 2 wins 40–75 % from each of three; g 3 wins at most 2 % at P 0.5 and 0.75; a typical build wins at most 2 % one realm up. Run once with no soul arts, and report a second run with them (Open Question 16). Provisional: these targets were simulated in rounds and must be re-run on the timeline (Open Question 20). Output goes to `production/qa/evidence/balance/[date]-combat-realm-crossing.md`.
- **AC-CB-54** [Integration, Bot: Balance Harness] Formulas A, B. With the rotation stated in the run header: typical mirrors last 30–60 s (#44 item A1; the simulator gives about 37 s at Qi Refining with linh lực dry at about 16 s, 2026-11-10), a sustain build with the same budget does not run dry before 30 s, top-end mirrors end well before typical ones, an unbuilt mirror ends by fatigue by about 65 s, a one-realm gap ends inside 12 s, and F rises ×7 to ×14 per realm for typical builds (target about ×10). **GIVEN** an ordinary boss with its `boss_pool_mult`, **THEN** a top-end build needs at least 4 seconds (tribulation bosses are exempt, rule 18).
- **AC-CB-55** [Integration, Bot: Balance Harness] Rule 20. **GIVEN** equal W, **THEN** an all-attack build (L2–L5 at 1.0) one realm up wins at most 2 %, and a top-end multi-layer build wins at least 95 %.

**Data**

- **AC-CB-56** [Config/Data] Parameter keys (D18). `combat_rules.json` is valid JSON and holds every Formulas `data file` key, with the defence keys in its `defence` section. These are gone: `power.base_offense_share`, `power.base_defense_share`, `power.cong_phap_share`, `power.khi_huyet_weight`, `power.linh_luc_weight`, `duel.ratio_exponent`, `duel.rounds`, `default_ward_pass`, `default_ward_drain`, `pass_min`, `drain_min`, `guard_base`, `guard_pool_slope`, `guard_cap`, `guard_max_mit`, `guard_half`, `guard_share_kind`, `body_guard_pct`, `ward_art_duration`, `curse_pass_raise_max`, `trig_ward_strength`, `trig_ward_seconds`, `hit_cost_share` and `upkeep_share` (the last two live on ward records). These stay: `duel.injured_power_floor`, `duel.khi_van_per_point`, `duel.min_win_chance`, `duel.max_win_chance`. `beast.power_mult` is `creature_mult`. The new curse bounds are present: `curse_heal_taken_max` 0.50, `curse_reapply_lockout` 2. Also gone since 2026-11-10: `time_limit`, `fatigue_step`, `curse_soul_shred_max` and `resist_cap`; present: `fatigue_units` 0.5, `fatigue_pow` 2.
- **AC-CB-57** [Config/Data] Data lint. c_art at cost_share 0.075, cooldown 1 s: 2.80 passes, 2.81 fails (`art_coef_per_cost` 24). At 0.125, cooldown 5 s: 5.00 passes. A cooldown below `cooldown_min` or above 12 s fails, and so does a `cost_share` above 0.125. At cost 0.125 and 12 s, 6.75 passes and 6.76 fails; at cost 0.02 and 0.5 s, 1.355 passes and 1.36 fails. An art with `body_cost_share` 0.025 and no linh lực cost, cooldown 1 s, lints as cost 0.05: 2.20 passes, 2.21 fails. An L2 `damage_more` of 4 or 51 points fails (Modifier System Stat List, 5–50 per piece). c_tick · duration above 1.2 · c_art fails. A standing status (no duration, such as Corpse Rot) is exempt from that check; instead a standing status at `c_tick` 0.15 passes and at 0.16 fails. c_trig 0.81 fails. chance · c_trig: 0.625 × 0.8 passes, 0.7 × 0.8 fails. An unknown tag is rejected at load. A `more` with no layer or with L3: AC-MD-06.
- **AC-CB-58** [Logic] Knob invariant (user decision C1, 2026-11-08). Fatigue (#44 item A3; flat n² since 2026-11-10). **GIVEN** two FX-T sides at full health that cannot hurt each other (block takes every part), **THEN** fatigue takes 3.16, 12.62, 28.39 … at t = 60, 61, 62 …, both sides reach 0 at t = 66.000 with equal overkill shares (0.005), and the fight is a draw with both at 1 health and `wound: grave`. **GIVEN** one side at 50 % health at t = 60, **THEN** it falls at t = 65. **GIVEN** a side with twice FX-T's health, **THEN** each fatigue pulse is the same amount as FX-T's. **GIVEN** fatigue on a side with every ward up, a body shield and resistance 900 points, **THEN** the full amount is taken. **GIVEN** a refusal held, **THEN** the side is set to 1 health once and falls at the next fatigue pulse. Fatigue is logged on its own line and fires no hit, crit or status trigger.
- **AC-CB-83** [Config/Data] Rule 6 (D17). **GIVEN** the tag registry, **THEN** the effect family holds pierce, lock, poison, cleanse, escape, bleed and seal; Bleed's cleanse tag is `bleed`, and Sealed Meridian's and Silence's is `seal`, and all three statuses load with no unknown-tag error. The status family (one tag per status) is the Effects System's.
- **AC-CB-84** [Config/Data] Rule 18 (D8). **GIVEN** the enemy profile data, **WHEN** the data scan runs, **THEN** it reports how many profiles it scanned per realm tier, and each tier has at least one enemy dealing each group (Physical/Force; Fire/Cold/Lightning/Light; Chaos; Soul), at least one whose resistance against each non-Soul group is at least 150 points (stopping 60 %) with its wards up (rule 18, user decision C3), at least one carrying Qi Disruption or a soul art, and at least one with a heal art or heal Effect; and every profile lists its damage types, its wards and a soul defence.

**Cross-system integration**

- **AC-CB-59** [Integration] Character Stats. **GIVEN** a real sheet with `attack_pct` +26.5, `defense_pct` +16, `khi_huyet_pct` +30, `linh_luc_pct` +20, **THEN** compile's pools equal Formulas A applied to `CharacterRules.khi_huyet_max` and `.linh_luc`, x1 is 26.5, and `defense_pct` reaches ws and scales only ward payloads (flesh block, gear block and non-ward resistance are unchanged). An artifact over thần thức capacity adds nothing. The new keys of Parameter keys appear in the sheet and its labels.
- **AC-CB-60** [Integration] Cultivation Techniques. **GIVEN** AC-CP-09's fixture, **THEN** the abilities in the profile equal its unlocked list at each step. With no main method at Qi Refining, spiritual power is 50, n_qi 0.5, the qi pool 82.02, and no ability is listed. **GIVEN** Iron Body Art at tier 3, **THEN** the profile gains block rating 30, body shield σ_b 0.30 and Physical resistance 25 points, none of it scaled by ws. AC-CP-39 is rewritten first.
- **AC-CB-61** [Integration] The Way. **GIVEN** a Way node worth +10 `attack_pct`, **THEN** x1 rises by 10 and L2–L5 are unchanged. **GIVEN** a fixture art node in the rule 13 format, **THEN** the Way's lint accepts it. (On hold with the arts.)
- **AC-CB-62** [Integration] Event Engine request. **GIVEN** a combat choice carrying enemy, situation and ground tags, **WHEN** resolved, **THEN** a win takes the success branch, and a loss, a draw and a flight take the failure branch, and the check line shows how it ended and the fight time.
- **AC-CB-63** [Integration] Consequences stay with the caller. **GIVEN** each ending, **THEN** vitality loss applies once, by the caller. The caller decides mercy. Capability #9 applies on a cultivator knockout only: not on a flight, a draw, a creature, or after mercy is chosen. Taming is offered only by the Event Engine after a won creature fight. A notable fight writes one World DB record. The fight engine imports no writer of these.
- **AC-CB-64** [Integration] Duel callers migrated. `CombatPower.duel` has no callers and `ratio_exponent` is read nowhere, covering `event_resolver.gd`, `world_ticker.gd` and `advisor.gd`. Stored `power` uses (`build_generator.gd`, `state_snapshot.gd`, `world_generator.gd`, `BeastKeeper.power_shares`) read `display_power`. `tools/run-tests.sh` exits 0.
- **AC-CB-65** [Integration, Bot: `world_census.gd`] Living World. **GIVEN** a headless run of 40 years, **THEN** every NPC duel winner comes from a full fight result, a draw writes no winner, a sect war resolves through the rating clash, there is no SCRIPT ERROR, and two runs on one world seed give identical news.

**Performance (proposed budgets, not measured)**

These run in the harness, not the gdUnit suite, because testing standards forbid time-dependent assertions there.
Results go to `production/qa/evidence/balance/[date]-combat-performance.md`.

- **AC-CB-66** [Integration, Bot: Balance Harness] Full fight, log on, median of 1,000 runs after 50 warm-ups. An FX-T mirror takes at most 2 ms. A worst-case fixture (120 s, `slot_count` arts at `cooldown_min`, `trig_cap` on both sides, 5 stacks, 3 curses, 3 parts, a companion, every ward slot filled with one ward of each payment, a ward shield, a body shield and a heal art) takes at most 75 ms with a log of at most 768 KB (three times the old 40 s budget for three times the time). `compile` takes at most 1 ms.
- **AC-CB-67** [Integration, Bot: Balance Harness] A season at 5,000 cultivators. Against a baseline measured in the same run, combat adds at most 10 ms to the mean season tick over 400 seasons. One clash on cached rating profiles takes at most 0.05 ms. A 500-against-500 clash takes at most 5 ms.

**Terminal and retained evidence**

- **AC-CB-68** [UI] Fight log transcript. **GIVEN** a scripted fight in the Debug Terminal, **THEN** it prints one line per pulse (actions, damage by type, resistance, block, shield soaks, heals, health and linh lực after), and on request a hit's full Breakdown: actor, art, tags, each part's damage type and history, every layer's bonuses and total, the defence path steps of AC-CD-48, each ward's payment, heals, fatigue, the Effects that fired, and health and linh lực before and after. It marks crits, linh lực running out, a refused Down and the fight's end. Exit 0, no SCRIPT ERROR. Retained in `production/qa/evidence/debug-terminal/`.
- **AC-CB-69** [UI] Retained screenshot. **GIVEN** the same fight in a real Windows Terminal window, **THEN** each damage type's damage lines use its Combat Damage Types colour, and each line also names the type. Retained in `production/qa/evidence/debug-terminal/`. (The Breakdown's colour table is AC-DT-22.)
- **AC-CB-70** [UI] Preparation and slot order. **GIVEN** a foreseen fight, **THEN** the numbered menus show the situation, enemy profile (Open Question 4), own health, linh lực, ward slots and their wards, the resistance panel, block, shields, the loadout and what each item adds. The player can slot arts, fill ward slots and art slots with wards, switch standing wards off, reorder slots, set an art's guard, and see which arts are ready now. Retained transcript plus one screenshot per screen.
- **AC-CB-71** [UI] Result and sheet (D16). The result screen shows the winner, how it ended, the fight time, resources spent and the deciding layer. The sheet shows `display_power`, health, linh lực, ward strength and efficiency, resistance by type, block, body shield, ward slots, thần thức and layer totals. **GIVEN** FX-T (Physical ehp at 0 linh lực 1.03 × `health_max`), **THEN** the Advisor warning of UI Requirements fires; **GIVEN** the thể tu fixture (3.47 ×), **THEN** it does not. Retained transcript plus one screenshot per screen.
- **AC-CB-72** Pointer (D15). Payment models: per hit AC-CD-21, a per-hit ward that cannot pay AC-CD-32. Upkeep wards were removed (#44 item C2).
- **AC-CB-73** Pointer (D15). Ward strength and efficiency effects: AC-CD-16, AC-CD-24. Ward payload limits: AC-CD-41. The default ward beside other wards: AC-CD-18, AC-CD-63.
- **AC-CB-74** [Logic] Rule 23. **GIVEN** no linh lực, **THEN** a Physical hit of D 41.30 on FX-T deals 40.35 (97.7 %), with no default ward. **GIVEN** the thể tu fixture at no linh lực (no default ward, so Physical R 36.1 points), **THEN** a Physical hit of D 41.30 loses 10.95 to resistance and 5.57 to block, the body shield falls by 24.78 and 0 reaches health; a Chaos hit of D 41.30 meets no resistance, loses 5.57 to block, passes the body shield and deals 35.73 (86.5 %).
- **AC-CB-75** [Logic] Rule 24, Formulas E2. **GIVEN** `soul_pct` 0.05 and equal souls, **THEN** a soul attack takes 5 % of maximum health and of maximum linh lực. Rho 2 takes 20 %, rho 3 stops at 30 %, rho 0.5 takes 1.25 %, rho 0.2 takes 0. Only soul resistance and soul wards apply (AC-CD-03); evade, crit, damage-type resistance, block and every other shield do not. **GIVEN** a reserved share, **THEN** the linh lực loss comes off the usable pool (AC-CD-26). A soul shield's share: AC-CD-62. It has the art's own cost and cooldown, and first fires one cooldown into the fight. **GIVEN** `boss_pool_mult` 8, **THEN** a 30 % hit takes 3.75 %. `soul_res_pct` 100 halves rho. **GIVEN** a side with two ready soul arts, **THEN** the first in slot order fires and the second stays ready and fires at the millisecond `soul_lockout` ends (a wake-up event, not the next unrelated event). **GIVEN** an art guarded on fight time above 10 s, **THEN** it fires at t = 10.000 with no other event due.

**Added in the Combat revision (#43)**

- **AC-CB-79** [Logic] Rule 22, compile. **GIVEN** FX-T with its Common Ward removed and the side flagged `no_default_ward`, at full linh lực, **WHEN** a Physical hit of D 41.30 lands, **THEN** r is 0, 40.35 is dealt and no drain is billed; without the flag the default ward covers it, 24.87 is dealt and 6.20 is billed. **GIVEN** a side flagged `cannot_slot_wards` with a ward in an art slot, or a soul ward in a ward slot, **WHEN** compiled, **THEN** compile rejects each and names it (the ward-slot case is AC-CD-63). **GIVEN** No Ward taken, **THEN** the compiled profile carries both flags (AC-EF-40).
- **AC-CB-81** [Logic] Rule 10, the Down step (D10). **GIVEN** both sides at 0 or below after an instant, A at overkill share 0.30 holding an unspent refusal and B at 0.10 holding none, **THEN** A's refusal runs before any overkill comparison, A stands at 1, B is Down, and A wins by knockout. **GIVEN** B is the requesting side, **THEN** B's Down step resolves before A's. **GIVEN** a last act, **THEN** it resolves as a follow-up at the same t: the clock does not move, no pulse runs, and a draw spy shows its draws continuing the instant's order. The overkill and draw cases of a last act are AC-EF-28; two refusals are AC-EF-29.
- **AC-CB-82** [Logic] Rules 6, 13 (D5). **GIVEN** arts authored at cooldown 1.5 s and cost share 0.05, at 2.5 s and 0.12, and at 6.0 s and 0.25, **WHEN** compiled, **THEN** their derived tags are {quick, cheap}, none, and {slow, costly}, and the basic attack carries only `basic`, not `quick` or `cheap`, though it is 1 s and free (user decision C4). **GIVEN** the second art with `art_speed_pct` +100 (cd_eff 1.25 s) and the third with `art_cost_pct` −40, **THEN** their derived tags are unchanged. The thresholds are AC-MD-13.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | **Closed 2026-11-06:** the user replaced the three pools with one health bar and wards, so the reserve floor is gone | — | — |
| 2 | **Closed 2026-11-06:** the user confirmed that the thần thức artifacts occupy does not lower the thần thức a side fights with (rule 3) | — | — |
| 3 | **Closed 2026-11-06:** the user confirmed that companions cannot be targeted in this version (rule 19) | — | — |
| 4 | How much of the enemy's profile does the player see while preparing? The working default is all of it (Pillar 2), but no rule states this yet, and scouting by divine sense is an alternative. Tribulation pools already use the working default, showing the whole profile (Heavenly Tribulation rule 5, user decision 2026-11-06); other fights stay open | user | UI Requirements, rule 12 |
| 5 | **Closed 2026-11-08 (Combat revision #43):** the Modifier System's Formulas D prices `more` in layer points and gives the exchange rate to W; L5 is granted only by Effects. The Way's art tier credit reads the same rate | — | — |
| 6 | Measure real typical and top-end builds in the Balance Harness, then re-fit Formulas B and H. All anchors are targets from a one-pool simulation. Top-end against two realms up from Qi Refining is 54 %, inside the 40–75 % target but sensitive (17–76 % at top-end damage ±20 %, Formulas H) | systems-designer, Balance Harness | Approval of the numbers |
| 7 | With near-deterministic fights, should preparation show a predicted result? It helps planning and may remove tension. The Advisor's odds preview (`advisor.gd`) needs this answer, since it reads today's duel | user | UI Requirements, Guidance |
| 8 | Fights with more than one cultivator per side are not supported. Are sequences of duels enough, or does a party fight need rules? | user | Event Engine, Sects |
| 9 | **Closed 2026-11-06:** `slots_by_realm` 3 / 4 / 5 / 6 / 7 plus uncapped earned slots (Formulas A2, user decision). The values are provisional until Open Question 20 measures them | — | — |
| 10 | **Closed 2026-11-06 for the built bases:** `body_gear` is an authored role tag on the artifact base (item-database.md rule 6, Formulas E); Giáp is body_gear and Thuẫn is ward_gear (renamed from `body` and `ward` by D2, 2026-11-08). New bases are authored the same way | — | — |
| 11 | How rare are NPC duels? The Living World needs a budget per season. Wars also become more decided than today's duel odds; check `kappa_mass` against that | world-builder, Living World | Living World |
| 12 | **Closed 2026-11-06:** a knockout of a cultivator side counts (rule 14, user decision). Realms says "defeating" and Character Stats says "a combat kill", so both should be reworded to "knockout" | — | — |
| 13 | The divine ability catalogue: what each ability does (Cultivation Techniques Open Question 3) | game-designer | Content pass |
| 14 | Two design intents have no measured target yet: a sustain build should beat a burst build at equal W in long fights (rule 11), and chance effects should rarely change a winner (rule 15). Set the numbers after the first harness run. Also check whether bots over-stack health: 10 W on it adds about 5 % fight length against 2 % for ward strength | systems-designer | Rules 11, 15 |
| 15 | The fight log's format and float precision (byte-identical logs depend on them, and damage values are floats, so identity across platforms is not promised (fight times are whole milliseconds, rule 10)), and the terminal command that starts a test fight | gameplay-programmer | AC-CB-01, AC-CB-68 |
| 16 | Soul attack balance waits on real techniques (user decision 2026-11-06). `soul_pct`, `soul_beta` and `soul_cap` are guesses, none of the simulated targets include soul arts, and a higher realm's soul attacks may hurt realm crossing. Rule on which layers a soul build can use once content exists. The soul numbers must now also cover soul wards, soul shields (Combat Defence & Healing rule 14) and Slackened Soul (−15 pp per stack) | user, systems-designer | Formulas E2, H |
| 17 | A top thể tu beat a top-end ward build about 75 % of the time at the same realm under the old body guard. Restated for the new defence: block, body shield and Physical resistance against layered wards, with Chaos as the thể tu's weakness. `t_b` is gone; Iron Body Art tiers stand in for it (Combat Defence & Healing Formulas H). Measure with real builds, then decide (user decision 2026-11-06). The Way's soul-resist nodes are also unset | systems-designer | Formulas H; Combat Defence & Healing Formulas G |
| 18 | The full ward catalogue for the content pass, including hand-cast wards. A starter catalogue of 12 wards exists (Combat Defence & Healing Formulas H) | game-designer | Content pass |
| 19 | **Closed 2026-11-06:** today's power duel resolves fights while the full fight is on hold (user decision) | — | — |
| 20 | **Rounds were removed for a timeline of seconds (user decision 2026-11-06, rule 10).** Formulas K now sums any number of arts, but the anchors in Formulas B, the win rates in Formulas H and the mirror lengths came from a round simulation with one action a round and no always-running basic attack. Only AC-CB-30's two mirrors have been checked on the timeline. Re-simulate all of it on real multi-art builds, including `slots_by_realm` and hit rates at high slot counts near `cooldown_min` | systems-designer, Balance Harness | Approval of the numbers |
| 21 | Art speed: the Modifier System prices `art_speed_pct` (0.6 W). Added to Character Stats' keys 2026-11-09 (consistency C14). Still to do: author its sources, checking it against the art lint, since it raises hit rate and spending together | systems-designer | Character Stats, content authoring |
| 22 | Sources of `bonus_slots` (priced by the Modifier System at 20 W, rare). The user plans skill tree nodes that scale slots and similar values, but only after the tree is reworked once all systems are implemented (user decision 2026-11-06). Until then no source is authored and every build has its base slots. Candidate modifiers: design/quick-specs/tree-modifier-catalogue.md | user, systems-designer | Tree rework, content authoring |
| 23 | What does `wound: grave` (a draw's survivors) cost? Combat only reports it (rule 14). Character Stats needs a vitality or injury rule for it, and the Event Engine a branch | user, Character Stats, Event Engine | Rule 14, caller consequences |
| 24 | The `reference_type_mix` values for `display_power` (Combat revision D7): the balance harness fits them, per realm if needed | systems-designer, Balance Harness | Formulas K |
| 25 | Re-derive the ehp and mirror cells of Formulas B outside Qi Refining, and run the rating's agreement test with the full fight (AC-CB-52, AC-CD-46). Done 2026-11-10: the FX-T and FX-U mirrors are worked by hand (AC-CB-30), the canonical typical mirror is the simulator's 36.7 s, and #44 part 2 re-derived K's T0 | Balance Harness | Acceptance Criteria, Formulas B |
| 26 | ~~Planned revision (systems-index #44): a sustain-first economy~~ **Decided 2026-11-09:** every item answered in `design/research/economy-revision-44-decisions.md` (fights of 30–60 s, fatigue from 60 s, health ×4 with ward resistance ×1.4, halved costs, regeneration 3.5 % with diminishing returns, no healing decay, no upkeep wards, no heal or tick caps, element stacks). Part 1 applied here; parts 2–5 apply it to Combat Defence & Healing, the Effects System, the Modifier System and Character Stats | — | — |
| 27 | **Future extension (recorded 2026-11-10, Way review D-03):** fights with allies, a party, mounts, disciples, troops, a taunt or world followers. Combat is one fighter plus attached companions today. The Way's facets that need them are archived (dao.md Catalogue, marked ◇): Vũ Đạo's Hội, Thú Đạo's Tọa Kỵ, Hiếu Đạo's Gia Tộc, Sư Đạo's Đệ Tử, Hoàng Đạo's Thần Dân, Thủ Đạo's Hộ Vệ and Khiêu Khích, Thần Đạo's Tín Đồ, Mị Đạo's Ngưỡng Mộ, Cô Đạo's Khắc Thân, and all of Binh Đạo (mass battle) | user, game-designer | Those facets and Binh Đạo |
