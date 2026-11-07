# Effects System (Hiệu Ứng)

> **Status**: Designed 2026-11-08, pending an independent `/design-review` in a fresh session
> **Author**: user + agents
> **Last Updated**: 2026-11-07
> **Last Verified**: 2026-11-07
> **Implements Pillar**: Your Dao, Your Name (1); Power Is Built, Not Given (3); Every Number Is Bounded and Visible (2)
> **Scope**: Every build piece with a rule in it: conditions, scaling, triggers, conversion, overflow, rule changes, keystones and enablers. An Effect usually grants Modifier System modifiers (`design/gdd/modifiers.md`) as its payload (user decision 2026-11-07). Plain numbers on a stat are Modifiers, not Effects.
> **Reference only**: Part 2 of `design/quick-specs/modifier-inventory.md` (361 effect candidates, mostly from the overnight run). This GDD is designed from scratch and adopts only what passes its rules.

## Summary

The Effects System holds every build piece with a rule in it: conditions, scaling, triggers, conversion, rule
changes, statuses, keystones and enablers. Each Effect is hand-designed as one plain sentence, usually granting
Modifier System modifiers as its payload, and works only through the engine's listed reads and actions under
Combat's limits. Effects give builds their identity and stay unpriced until the end-of-project balance pass.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Modifier System, Combat, Combat Defence & Healing, Combat Damage Types`

## Overview

An **Effect** is any build piece with a rule in it. "+12 % sword damage while your linh lực is above
half", "when you crit, your other arts' timers shorten by 0.5 s", "your basic attack carries your root's
element", "once a fight, a killing blow leaves you at 1 health": each is an Effect. Most Effects grant
plain modifiers from the Modifier System as their payload; some change a rule outright. Keystones (strong
rules that close something off) and enablers (the piece a build is built on) are Effects too, and so are
statuses, the burns, poisons and curses placed on a target.

Every Effect is hand-designed (user decision 2026-11-07): it has its own one-sentence rule, its own limits
and, for keystones and enablers, what it closes. There is no composing grammar and no price yet. Effects
are balanced once the game is finished. What this system fixes is the shape every Effect must take: the
record, what an Effect may read and do, the limits the engine enforces on all of them, and the rules for the
hard cases, such as costs that outlive the fight, what happens at Down, counted chance and statuses with
no end.

Effects are where builds get their identity (Pillar 1). Modifiers make a build bigger; Effects make it
different.

## Detailed Design

### Core Rules

> `game-designer` and `systems-designer` not consulted for this section — Lean mode. Review manually before production.

**What an Effect is**

1. **An Effect is a hand-designed rule piece** (user decision 2026-11-07). Each one is authored on its own, with
   no shared grammar. Every Effect record nonetheless states the same fields, so the engine, the Breakdown and
   NPC Builds can handle it:

   | Field | Meaning |
   |---|---|
   | `id`, name | English name with Hán-Việt, e.g. Flowing Water (Lưu Thủy) |
   | `kind` | One of the kinds in rule 2. Descriptive, for designers and filters |
   | `rule` | One plain sentence the player reads. It is the specification |
   | `reads` | What it looks at, from the readable list (rule 5), each with its read time: compile, instant start or live (events need none) |
   | `payload` | Catalogue modifiers (Modifier System) and/or actions (rule 6) |
   | `limits` | How often and how much: per pulse, per fight, cooldown, caps |
   | `closes` | Keystones and enablers only: what it forbids or costs |
   | `domain`, `tags` | Classification tags from the shared vocabulary (Modifier System rule 9), plus its kind |
   | `hosts` | Which sources may carry it (rule 13). `affix` (a rolled affix) is a host value; enablers may never list it |
   | `npc` | `true` if NPC Builds may use it (rule 15) |
   | `tier` | `minor`, `major`, `keystone` or `enabler` (rule 4): a rough size set by eye, so hosts can bound how much a build holds |
   | `price` | `unpriced` until the end-of-game balance pass (user decision 2026-11-07) |

2. **Kinds describe an Effect; they do not build it.**

   | Kind | It… | Example |
   |---|---|---|
   | Conditional | grants its payload while something holds | +12 % sword damage while linh lực is above 50 % |
   | Scaling | grows with a count, to a cap | +2 % damage per empty art slot, to +12 % |
   | Trigger | does something when an event happens | on a crit, your other arts' timers shorten by 0.5 s |
   | Conversion | changes a part's damage type or tags, or counts one quantity as another | 40 % of Physical damage becomes Fire |
   | Overflow | uses what a cap clipped | tick damage the cap clips burns the target's linh lực |
   | Rule change | changes a rule outright | your basic attack carries your root's element |
   | Status | is placed on a target: a tick or a curse | Burn, Poison, Weaken (rule 9) |
   | Keystone | a strong rule paid for by what it closes | no ward ever; +large body shield |
   | Enabler | opens a channel, rule or resource and closes something | arts may be paid in spirit stones; linh lực pays for nothing |

3. **Modifier or Effect.** If a piece is a plain number on one stat, optionally narrowed by tags, it is a
   modifier (Modifier System), never an Effect. Anything with a condition, a count, an event or a rule is an
   Effect. An unconditional "+X" inside an Effect must use a stat from the Modifier System's Stat List, with an
   operation that stat allows. While Effects are unpriced (rule 4) its value is the designer's, not a
   catalogue grade; the balance pass prices it with the rest of the Effect.

4. **Effects are unpriced for now, but every Effect has a tier** (user decisions 2026-11-07 and 2026-11-08). An
   Effect carries `price: unpriced`: no W value, no price check, no budget. Its value depends too much on the
   build around it for one price to be right. Instead every Effect carries a **tier**, a rough size a designer
   sets by eye:

   | Tier | Meaning | Typical host slot |
   |---|---|---|
   | `minor` | A small edge that helps a build it fits | a Way node, a technique's lesser art, an item affix line on a named item |
   | `major` | Changes how a build plays or what it is good at | a Way branch node, a technique's main art, a named artifact |
   | `keystone` | A strong rule paid for by what it closes (rule 14) | a tree keystone, a Way capstone |
   | `enabler` | The piece a build is built on, opening and closing something (rule 14) | a named artifact, a technique, a Way capstone |

   Each host GDD says how many Effects of each tier its slots hold, so the total power a build carries stays
   bounded without valuing anything exactly. Engine limits (rule 7) still apply, because they keep fights finite
   and readable. The end-of-project balance pass measures Effects with the harness (Open Questions 1).

**What an Effect may read and do**

5. **Readable quantities.** An Effect may read only what the engine exposes. Today's list is drawn from the
   inventory's conditions:
   - **in a fight:** own and enemy health and linh lực (as shares); shields and their state; fight time;
     pulses; events this fight (hits, crits, evades, kills, firings, statuses applied); slots and loadout;
     the hit's damage type, element and tags; the realm gap; preparation and ground tags; foreseen or blind;
   - **from the sheet, read at compile:** owned stats; attributes (thiên phú); heart demon (tâm ma) and
     toxicity (đan độc); craft levels; root purity; lifespan and age; free thần thức (thần thức minus what
     artifacts bind); carried spirit stones; the strongest companion's power share;
   - **added with the starter catalogue** (user decision 2026-11-07): health restored to the side this fight; the
     number of distinct statuses of the side's own on the target; the event "a shield breaks";
   - **in life:** the season, the place, the sect, and the World DB facts the Event Engine exposes.

   An Effect that needs something not on the list asks for an engine addition first; the list is extended in
   this GDD. Each read says *when* it is read: at compile (fixed for the fight), at the start of each instant
   (Combat rule 10's guard time), or live.

6. **Actions.** Besides granting modifiers, an Effect may use only the engine's actions:

   | Action | Owner |
   |---|---|
   | Free hit | Combat Formulas G (`c_trig`, trigger budget) |
   | Apply or cleanse a status | this GDD (rule 9); Combat Formulas F |
   | Restore health, linh lực or a body shield | Combat Defence & Healing rules 16–19 (restores count as healing) |
   | Refund an art's cost, up to that cost | Combat rule 9 |
   | Convert a share of a hit | Combat Damage Types rule 6 |
   | Reserve linh lực | Combat Defence & Healing rule 10 |
   | Raise or lower a ward, or change its payload while a condition holds | Combat Defence & Healing rules 5–9 |
   | Move a timer: shorten your own, or delay the enemy's | Combat rule 13. An art's next firing is never sooner than `cooldown_min` after its last |
   | Pay an art's cost in health (not damage, so nothing reduces it; it can put the side Down, and the Down step, refusals included, then runs as usual) | this GDD; it is neither damage nor healing |
   | Pay art and ward costs from carried spirit stones, reported after the fight | this GDD; rule 10 |
   | Report a life cost (rule 10) | this GDD; the caller applies it |

   A new action is an engine addition, added here before any Effect uses it.

7. **Engine limits apply to every Effect.**
   - **Triggers:** Combat rule 9 and Formulas G: a fixed resolution order, chain depth 2, at most 6 firings per
     side between pulses, trigger damage at most half of the direct damage since the last pulse. A trigger
     never fires itself twice in one chain.
   - **Caps** stay with their owners: layer caps, crit, evade and resistance caps, the heal and tick caps, the
     reservation cap. An Effect's modifiers are clipped like any others.
   - **Determinism:** every chance uses the fight's seeded stream (Combat rule 15). A chance of 0 or 1 draws
     nothing.
   - **Readability:** every Effect that applies, fires or is clipped writes a Breakdown line with its name and
     what it did (Combat rule 16).

8. **When an Effect applies.**
   - A **conditional** Effect's condition is read at the start of each instant, as Combat reads guards; its
     payload applies for that whole instant.
   - A **scaling** Effect's count is read when its `reads` says (compile, instant start or live), and its cap
     is part of its record.
   - A **trigger** resolves right after the event that set it off, in Combat rule 9's order.
   - **Life effects** (outside fights) resolve when the Event Engine or the season tick reaches them.

**Statuses**

9. **This system owns the status catalogue** (user decision 2026-11-07). A status is an Effect placed on a
   target by an art, a trigger, a talisman or the ground. Combat keeps the formulas and caps (Combat rules 7–8,
   Formulas F). Each status record states:
   - its **damage type** if it ticks (Combat Damage Types rule 1) or the rule it changes if it is a curse;
   - its **strength** (`c_tick` for a tick), **duration** in pulses, and **stacking** (refresh, stack to a cap,
     or the stronger wins). A recast refreshes unless the record says otherwise;
   - its **cleanse tags**.

   **A status may have no duration** (user decision 2026-11-07; overnight decision 11) only if its caster pays a
   standing cost every pulse while it runs and a cleanse can clear it. It stays inside the tick caps, and it
   ends if the caster cannot pay.

**The hard cases**

10. **Costs that outlive the fight are reported, never applied in the fight** (user decision 2026-11-07;
    overnight decision 4). An Effect may spend or raise heart demon, lifespan years, seasons, toxicity, spirit
    stones or root purity. The values it reads are taken before the fight. The fight's result reports every
    such cost or gain, as it already reports vitality, and the caller applies it afterwards (Combat rule 14).
    Kills still add no heart demon unless an Effect says so.

11. **Down has one defined step** (user decision 2026-11-07; overnight decision 5). At the defeat check
    (Combat rule 10), after all of the instant's damage:
    1. **Refusals.** Each side's Effects that refuse Down (for example "once a fight, a killing blow leaves you
       at 1 health") are checked in that side's slot order, and the first unspent one saves it: health is set to
       1 and that Effect is Spent. Each refusal works once per fight, and at most one fires per Down, so a side
       holding two refusals can survive two separate Downs. A side saved by one is not Down.
    2. **Last acts.** For a side still Down, its Effects that act at Down (a final art, a parting curse) resolve
       once, then the side is Down. Their damage enters a follow-up check. The side making the last act cannot
       refuse a second time; a side the last act puts Down runs this step as usual, refusal included.
    3. **Wounds that run on** (a ledger of deferred damage, a curse that outlives its caster) are not resolved
       in the fight. They are reported in the result, and the caller applies them (rule 10).

    If both sides are saved or both fall, Combat rule 10's overkill and draw rules decide as usual.

12. **Counted chance is a keystone rule** (user decision 2026-11-07; overnight decision 9). A keystone may turn
    one of its owner's chances (crit, evade, a status chance) into a **count**:
    - each time the chance would be rolled, its probability is added to a visible meter instead;
    - when the meter reaches 1, the event happens and 1 is taken off.

    No seeded draw is used, so a counted build is deterministic. Fortune does not shift counted chance. Only a
    keystone may grant it, and only one chance per keystone.

**Keystones, enablers and hosts**

13. **Who may carry Effects.** Hosts are set per Effect, from:
    - the Meridian Map (keystones; its 25 live capabilities are re-expressed in this catalogue: those with a
      real closing cost as keystones, the rest as rule changes, user decision 2026-11-07);
    - the Way (Đạo): nodes, branches and capstones;
    - cultivation techniques and their arts;
    - items: named artifacts, treasures, talismans, pills;
    - formations and ground;
    - spirit beasts;
    - progression edges and spiritual roots;
    - statuses (on the target).

    A keystone is exclusive with any keystone its host marks as rival. An enabler is a named piece (an
    artifact, a technique, a keystone or a Way capstone), never a rolled affix.

14. **Keystones and enablers state what they close.** Their `closes` field is part of the rule and shows in the
    tooltip: "You can never use a ward" is read by the player before "+large body shield". A keystone or enabler
    without a real closing cost is rejected in review.

15. **NPCs and the LLM Game Master.** NPC Builds may use any Effect whose record marks it `npc: true`, under the
    same rules. The LLM Game Master never creates an Effect and, while Effects are unpriced, never grants one;
    it may grant modifiers only (Modifier System rule 16).

### Status Catalogue

> Drafted by `game-designer` 2026-11-07; inserted as drafted (user decision). Bounds are Combat Formulas F:
> `c_tick` 0.15–0.5 per stack, duration 2–6 pulses, stack cap 5, the lint `c_tick · duration ≤ 1.2 · c_art`,
> one tick ≤ 5 % and one pulse's ticks ≤ 8 % of maximum health, at most 3 curses of at most 5 pulses.

**Ticks**

| Status | Damage type | Strength | Duration | Stacking | Cleanse tags | Rule |
|---|---|---|---|---|---|---|
| Burn (Thiêu Đốt) | Fire | c_tick 0.35 | 3 | The stronger Burn wins, judged by tick damage after modifiers; an equal recast refreshes the duration; a weaker one does nothing | fire, cleanse | Burns each pulse and wears down body shields (Fire does not pass them) |
| Poison (Trúng Độc) | Chaos | 0.15 per stack | 5 | Stacks to 5; a new stack refreshes all | poison, cleanse | Passes every shield by default; only Chaos and all resistance cut it |
| Bleed (Xuất Huyết) | Physical | 0.20 per stack | 4 | Stacks to 5; each stack keeps its own timer | bleed, cleanse | Body shields soak it; block never does |
| Frostbite (Đống Thương) | Cold | 0.20 per stack | 4 | Stacks to 3; a new stack refreshes all | cold, cleanse | Three stacks is the threshold Cold Effects read |
| Shock (Lôi Chấn) | Lightning | 0.50 | 2 | Refresh only | lightning, cleanse | A short, sharp spike |
| Qi Disruption (Loạn Khí) | Force (qi burn) | 0.30 per stack | 3 | Stacks to 3 | force, cleanse | Ticks linh lực, not health, at most 5 % of `qi_max` a pulse |
| Corpse Rot (Thi Độc) — **standing** | Chaos | 0.15, one stack | none | Single; a recast does nothing | poison, cleanse | Never ends on its own. Its caster pays 2 % of their maximum linh lực every pulse (Formulas B); it ends the pulse that goes unpaid, or on a cleanse. Counts inside both tick caps; never merges with Poison |

Light has no tick (its status is Exposed) and Soul never ticks (Combat Damage Types rule 1).

**Curses**

| Curse | Rule changed | Strength | Duration | Stacking | Cleanse tags | Rule |
|---|---|---|---|---|---|---|
| Sundered (Phá Giáp) | Resistance down, for the damage type of the hit that applied it | −0.15 per stack | 4 | Stacks to 3 | curse, cleanse | Sundered and Exposed together shred at most 0.5 (`curse_shred_max`), never below the −50 % `resist_floor` |
| Exposed (Hiển Hình) | All resistance down | −0.10 | 3 | Refresh | curse, light, cleanse | Light's status: the target is laid bare |
| Sealed Meridian (Phong Mạch) | Layer lock: one named layer, L2 to L5, counts as 1.0 | — | 2 | None | curse, seal, cleanse | Cannot be reapplied to that target for 2 pulses after it ends |
| Silence (Cấm Ngôn) | Tag block: arts with the named tag cannot fire, and modifiers needing it do not apply | — | 3 | None | curse, seal, cleanse | May not name `ward`, `basic` or `escape`; the same 2-pulse reapply lockout |
| Stagnation (Trệ Khí) | Regeneration block: linh lực and health regeneration stop | — | 3 | Refresh | curse, cleanse | Pairs with drain and Force builds |
| Heavy Breath (Trọng Tức) | Art cost raise | +25 % per stack | 4 | Stacks to 2 (+50 %, `curse_cost_raise_max`) | curse, cleanse | — |
| Leaking Ward (Lậu Hộ) | Drain wards bill more | +50 % (`curse_drain_raise_max`) | 3 | Refresh | curse, ward, cleanse | Drain wards only |
| Withering (Khô Héo) | Healing taken down | −50 % (`curse_heal_taken_max`, new) | 4 | Refresh | curse, cleanse | The healer's answer |
| Slackened Soul (Tùng Hồn) | Soul resistance down | −0.15 per stack (`curse_soul_shred_max` 0.30, new) | 2 | Stacks to 2 | curse, soul, cleanse | — |

### Starter Effects

> Drafted by `game-designer` 2026-11-07, filtered from `modifier-inventory.md` Part 2 and new pieces; inserted
> as drafted (user decision). Every record is `price: unpriced`. **L5 +N** is N points in Combat's layer L5
> (cap 100), granted through `damage_more` on L5, which only Effects may grant (Modifier System rule 6).
> **Tiers** (rule 4): keystones and enablers carry their own tier. Of the rest, these are `major`: Flowing Water,
> Echo, Shattering Ward, Blood Drinker, Final Clause, Marked Prey, Gorged, Flame-Tempered Edge, Thunder Palm,
> Field Walls, Overheat, Elemental Fist, Measured Stroke, Talisman Sleeve and Great Essence-Draining Art. Every
> other starter Effect is `minor`. Statuses carry no tier; the art or Effect that applies them does.
> **Hosts:** MM Meridian Map, Way node or capstone, Tech technique or art, Item named item, Tal talisman, Form
> formation, Beast spirit beast. Every record is `npc: true` except Seal of Full Payment and the four life
> Effects, which NPC Builds summarises its own way.

**Conditional**

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Steady Breath (Bình Tức) | While your linh lực is at 50 % or above, arts in this piece's scope deal more. | Own linh lực, instant start | L5 +12, scope set by the host (e.g. sword) | — | — | Way, Tech, Item | Sword, ward caster, cheap arts | Steady Thread, Steady Breath |
| Spent Breath (Khí Tận) | While your linh lực is at 30 % or below, arts in this piece's scope deal more. | Own linh lực, instant start | L5 +12, scoped | — | — | Way, Tech, Item | Burnout, dark path, Force | Spent Breath, Running Low |
| Kindled Wound (Trì Nhiệt) | Your Fire parts deal more to a target bearing your Burn. | Statuses on the target | L5 +15, scope [fire] | — | — | Way, Tech, Item | Fire arts, Fire-converted sword, status | Heat Held, Keeping Heat |
| Pack Hunt (Quần Liệp) | Your companion's hits deal more to a target bearing any of your statuses. | Statuses on the target | L5 +15, scope [companion] | — | — | Beast, Way, Item | Companion, poison, curse | new |
| Beneath Notice (Bất Túc Đạo) | Against an enemy of a higher realm, your escape is likelier. | Realm gap, compile | `escape_pct` +15 (inside `escape_bonus` 0.3) | — | — | MM, Way, Item | Escape, low-realm survivor, fortune | Beneath Notice |

**Scaling**

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Marked Prey (Tiêu Ký) | Your hits deal more for each different status of yours on the target. | Distinct own statuses on the target, instant start | L5 +4 each | Cap +16 | — | Way, Tech, Item | Curse, poison, companion, Fire | Marked Target, Sick Body, Crowded Sky, Opened Guard |
| Bare Rack (Không Giá) | Your basic attack and companion hits deal more for each empty art slot. | Slots, compile | L5 +5 each, scope [basic] or [companion] | Cap +20 | — | MM, Way | Martial basic attack, companion | Bare Rack, Still Hand, Idle Hands |
| Gorged (Bão Lôi) | Your hits deal more for every 1 % of maximum health restored to you this fight. | Health restored this fight, live | L5 +1 per 1 % | Cap +30 | — | Way, Tech | Healer-fighter, lifesteal body, sword | Gorged |
| Open Sky (Không Thiên) | Your wards are stronger for every 1 % of thần thức not bound to artifacts. | Free thần thức, compile | `defense_pct` +0.5 per 1 % | Cap +30 | — | MM, Way | Ward, soul, artifact-free | Open Sky |

**Trigger**

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Flowing Water (Lưu Thủy) | When you crit, your other arts' timers shorten by 0.5 s. | Crit event | Move timers | 3 firings per pulse; never below `cooldown_min` | — | MM, Way | Crit, sword, tempo | Flowing Water |
| Echo (Hồi Âm) | When one of your arts lands a hit, it has a 25 % chance to strike again for free. | Hit event | Free hit, c_trig 0.5, same tags (chance × c_trig 0.125) | Once per firing; trigger budget | — | Way, Tech, Item | Element arts, sword, talisman | Echo |
| Opening Cut (Khai Huyết) | When a Physical hit of yours crits, it applies one Bleed stack. | Crit event, the hit's type | Apply Bleed | 1 per hit | — | Way, Tech, Item | Sword, crit, fist | Thin Bleed |
| Shattering Ward (Toái Hộ) | When one of your shields breaks, it bursts against the enemy. | Shield breaks (event) | Free Force hit, c_trig 0.6 | 1 per pulse, 3 per fight | — | Way, Tech, Item | Ward shield, body shield (thể tu) | Shattering Ward |
| Blood Drinker (Ẩm Huyết) | When your hit removes enemy health, you restore 6 % of what it dealt. | Hit event | Restore health (healing) | Direct hits only, never ticks or trigger hits; heal cap and decay; 0 under `no_heal` | — | Tech, Item, Way | Sword, body, dark path, beast | new |
| Iron Skin Renewed (Thiết Bì Phục) | When you fire an art with a Physical part, your body shield regains 2 % of maximum health. | Firing event | Restore body shield (healing) | 1 per pulse | — | Tech (luyện thể), Item | Thể tu, Physical sword | new |
| Soul Wound (Thương Hồn) | When your soul art lands, the enemy's next ready art is delayed by 0.5 s. | Soul hit event | Move the enemy's timer | Once per `soul_lockout` | — | Way, Tech | Soul, control, ward stall | Soul Wound |
| Rime Lock (Sương Tỏa) | When your Frostbite reaches 3 stacks on a target, that target's art with the least time left is delayed by 1 s. | Status applied, stack count | Move the enemy's timer | Once per 4 pulses per target | — | Way, Tech, Item | Cold, control, ticker | new |
| Final Clause (Mạt Khoản) | Once a fight, as you go Down, your longest-cooldown art fires at no cost. | Down step 2 | Fire the art and refund its cost (a last act) | Once per fight; its damage enters the follow-up check | — | Tech, Item | Dark path, burst Fire, sword | Final Clause |

**Conversion and overflow**

| Name | Kind | Rule | Reads | Payload / action | Limits | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Flame-Tempered Edge (Hỏa Luyện Phong) | Conversion | 40 % of the Physical in your sword hits becomes Fire. | The hit's tags | Convert a share | Counts toward 2 conversions per hit | Item, Way, Tech | Sword, Fire, anti-thể tu | Conversion share |
| Thunder Palm (Lôi Chưởng) | Conversion | 50 % of the Force in your palm hits becomes Lightning. | The hit's tags | Convert a share | Counts toward the 2 | Tech, Way | Force palm, Lightning | new |
| Rot Seeps In (Hủ Thấm) | Conversion | 25 % of the Physical in your Wood-element hits becomes Chaos. | The hit's tags | Convert a share | Counts toward the 2; low because Chaos passes body shields | Tech, Item | Poison, Wood thorns, anti-thể tu | new |
| Field Walls (Điền Thành) | Conversion | While your formation stands, half of your formation power also counts as ward strength. | Preparation | `defense_pct` = 0.5 × `formation_power_pct` | Nothing in blind fights | Form, Way | Formation, ward | Field Walls |
| Spillover (Dật Độc) | Overflow | Tick damage the pulse cap clips burns the target's linh lực instead. | `dot_pulse_cap` clip | Qi burn of the clipped amount | Inside the 5 % qi burn cap | Way, Tech, Item | Poison, status, anti-ward | Spillover |
| Still Water (Tĩnh Thủy) | Overflow | Linh lực regeneration lost to a full pool restores health at half that amount. | Regeneration clip | Restore health (healing) | Heal cap and decay | MM, Way | Ward caster, healer, cheap arts | Still Water |
| Overheat (Quá Nhiệt) | Overflow | Art speed that `cooldown_min` clips on an art becomes extra damage for that art, point for point. | Art speed (compile), the art's cooldown | L5 on that art | Cap +30 | Way, MM | Tempo, quick arts, crit | Overheat |

**Rule change**

| Name | Rule | Reads | Payload / action | Limits | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|
| Elemental Fist (Ngũ Hành Quyền) | Your basic attack carries your main root's element tag. | Root, compile | Adds a tag (modifier scopes only, never defence) | — | Way, Root, Tech | Element arts, martial basic attack, body | Elemental Fist |
| First Move (Tiên Thủ) | Your first art of the fight costs no linh lực. | Firings this fight | Refund up to the cost | Once per fight | Way, Item | Alpha-strike sword, Fire burst, soul opener | First Move |
| Measured Stroke (Định Trảm) | Your arts with an authored cooldown of 20 s or more cannot be evaded and cannot crit. | The art record | Skips the evade and crit rolls | — | Way, Tech | Slow nukes, formation arts, anti-evasion | Measured Stroke |
| Cold Feet (Hàn Túc) | Your escape art's first firing comes at `cooldown_min`. | — | Move a timer | First firing only | MM, Item, Tal | Escape, low-realm survivor, fortune | Cold Feet |
| Talisman Sleeve (Phù Tụ) | One talisman that carries a guard takes no art slot. | Loadout | Adds a slot | 1 talisman | Item, Way | Talisman, escape, preparation | Talisman sleeve |

**Keystones**

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Called Blow (Báo Chiêu) | Your crit chance is counted on a visible meter, not rolled. | Your crit chance | Counted chance (rule 12) | One chance | Crit chance cap 0.50 → 0.35; fortune never shifts your crits | MM, Way capstone | Crit, sword, deterministic | Called Blow |
| Unyielding Breath (Bất Khuất) | Once a fight, a blow that would put you Down leaves you at 1 health. | Down step 1 | Refusal | Once per fight | Maximum health −15 % | MM | Body, escape window, dark path | Unyielding Breath |
| Burning Lifespan (Nhiên Thọ) | Once a fight, when your health first falls to 30 % or below, you burn years for 5 s of fury. | Own health, live | L5 +40 on all hits and `art_speed_pct` +30, for 5 s | Once per fight | When it fires, the result reports 2 % of your realm's base lifespan in years lost, win or lose (rule 10) | MM, Tech (ma đạo) | Dark path, sword, body comeback | Burning Lifespan |
| No Ward (Vô Hộ) | You can never use a ward, and your body hardens instead. | Hits reaching your health | `body_shield_pct` +25; after each pulse in which no hit reached your health, the body shield regains 2 % of maximum health | Body shield cap | No ward of any kind, including the default ward and soul wards | MM | Thể tu, Physical sword | No Ward |
| Glass Meridians (Lưu Ly Kinh Mạch) | Your arts run far faster, on a fragile body. | — | `art_speed_pct` +40 | `cooldown_min` | Maximum health −25 %; your body shields hold half | MM | Tempo, crit, element caster | Glass Meridians |
| Heart Demon's Blade (Tâm Ma Nhập Đao) | Your hits deal more for every point of heart demon above 30. | Heart demon, compile | L5 +1 per point | Cap +40 | Qi deviation chance × 2; every fight you win reports +1 heart demon | MM | Dark path, sword, soul | Capability #25 |
| Beast Soul Union (Thú Hồn Hợp Thể) | Your strongest companion's power share counts double. | Strongest companion's share, compile | Companion share × 2 | `c_comp_cap` | −1 art slot; only one companion fights with you | MM, Beast | Companion, martial basic attack | Capability #17 |

**Enablers**

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Blood Casting (Huyết Tế) | When your linh lực cannot pay for an art, you pay the shortfall in health, 1 for 1. | Own linh lực | Pay the cost in health: not damage, cannot be refused, can put you Down | — | Healing taken −50 % for the fight | Tech (ma đạo), named Item | Dark path, tempo, body | Blood Casting |
| Water Table (Thủy Mạch) | You gain 30 % of the linh lực the enemy's drain wards pay against your hits. | Ward payments | Restore linh lực | Up to your maximum | Your linh lực never regenerates in fights | Item, Way capstone | Force anti-ward, ward duelist, soul | Water Table |
| Paid in Advance (Tiên Phó) | Your talismans cost no linh lực when they fire. | — | Refund the cost | Stock still runs out | You may slot only talismans, wards and the escape art | Named Item, Tech | Talisman, preparation, escape | Paid in Advance |
| Grave-Silk Shroud (Liệm Thi Y) | Corpse Rot is on the enemy from t = 0 without taking a slot. | — | Apply the standing status | Corpse Rot's standing cost applies | 15 % of maximum linh lực reserved for the fight | Named Item | Poison, dark path, ward caster | Grave-Silk Shroud |
| Seal of Full Payment (Túc Phó Ấn) (`npc: false`) | Your arts and wards are paid in carried spirit stones. | Carried stones, before the fight | Pay costs in stones; stones spent are reported | Stones carried | Linh lực pays for nothing; a winner who knocks you out takes 10 % of your carried stones (reported) | Named Item | Wealth or Kỹ, ward, talisman | Seal of Full Payment |

**Life, cultivation and crafting** (live capabilities re-expressed)

| Name | Kind | Rule | Payload / action | Limits | Closes | Hosts | From |
|---|---|---|---|---|---|---|---|
| Soul Leaves the Body (Linh Hồn Xuất Khiếu) | Keystone | Once per realm, a death in an event leaves you alive at 5 % vitality. | Report a stage loss | Once per realm | You lose one stage | MM | Capability #5 |
| Great Essence-Draining Art (Hấp Tinh Đại Pháp) | Trigger | When you knock out a cultivator, you take cultivation base worth 5 % of your current stage. | Report base gained | Cultivators only | +2 heart demon reported each time | MM, Tech | Capability #9 |
| Strange Pill Reborn (Dị Đan Hóa Sinh) | Rule change | A failed brew has a 30 % chance to yield a random lesser pill instead of ash. | Item output (seeded life stream) | Once per brew | — (reclassified as a rule change: it closes nothing) | MM | Capability #11 |
| Formation Within a Formation (Trận Trung Trận) | Keystone | Your formations may exceed their maximum by 2 levels. | Raises the level cap | +2 levels | Upkeep for those levels × 2 | MM | Capability #15 |

**Capabilities without a closing cost** (user decision 2026-11-07): the live capabilities that close nothing
(about 12, such as #2, #3, #6, #8, #10, #12, #14, #16, #18, #20, #21, #24) are **rule-change Effects**, not
keystones. The ones with a real cost stay keystones. Their place in the tree is decided at the tree rework.

**Inventory filter, in short.** About 55 inventory rows were kept, most merged into the Effects above. The rest:
- about 25 are plain numbers (they belong in the Modifier System);
- about 30 are dead under the new damage and defence model (body guard, the qi kind, the element cycle, ward
  pass or phase, one ward at a time, Lava);
- about 130 need a subsystem invented for one overnight build;
- about 30 read something the engine does not expose;
- about 20 fail the one-sentence rule or break the game;
- about 40 are duplicate grades of kept entries;
- about 30 are deferred, not rejected, until the tree rework or a Combat key: Five Phases Cycle, Sheathed
  Blade, Against the Heavens, Home Ground, Standing Array, Seeing Eye, Soul Pressure, Mirror Ward, Spirit
  Severing, Focused Mind, Empty Hand, One Root, Heaven's Favour (a reroll needs a new action), and the other
  19 capabilities.

### States and Transitions

**An Effect in a fight**

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| Idle | Its host is active, but it is not applying | Fight start, or its condition stops holding | Its condition holds, or its event happens |
| Active | Its payload applies (conditional, scaling, rule change) | Condition true at an instant's start | Condition false at a later instant's start |
| Fired | A trigger resolved this instant | Its event, within limits | The instant ends |
| On cooldown | A trigger waits out its own cooldown | It fired | Its cooldown ends (a scheduled wake-up, Combat rule 10) |
| Spent | A once-per-fight Effect has been used | It fired or refused Down | Never in this fight |

**A status on a target:** Applied → Ticking or Cursing (each pulse) → Expired (duration 0), Cleansed, or Ended
(a standing status whose caster could not pay). A recast refreshes unless the record says otherwise.

### Interactions with Other Systems

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Modifier System (#40) | in | Catalogue modifiers used as payloads; tag vocabulary | Modifier System |
| Combat (#21) | in / out | Events, instants, guards, the trigger order and budget, the defeat check, results. Out: free hits, refunds, timer moves, Breakdown lines, reported life costs | Combat (timeline, limits); this GDD (the Effects) |
| Combat Defence & Healing (#21a) | out | Heals and restores, reservations, ward changes, Down refusals | Combat Defence & Healing (rules); this GDD (sources) |
| Combat Damage Types (#21b) | out | Conversions; statuses' damage types | Combat Damage Types |
| Character Stats (#7), Realms (#8) | in / out | Readable sheet values at compile. Out: reported heart demon, years, toxicity, purity (applied by the caller) | Character Stats; Realms |
| Meridian Map (#10), The Way (#39), Cultivation Techniques (#9) | out | Keystones, Way nodes and capstones, technique and art Effects | each host |
| Item DB (#13), Talismans (#18), Formations (#17), Alchemy (#15), Spirit Beasts (#19) | out | Named items' Effects, talisman statuses, ground Effects, pill Effects, beast Effects | each host |
| Event Engine (#23), Time & Turn (#4) | in / out | Life Effects (season, place, events) | Event Engine |
| NPC Builds | out | Effects marked `npc: true` | NPC Builds |
| Debug Terminal, Game UI (#37) | out | Rule text, `closes`, Breakdown lines, counted-chance meters, status icons | Game UI |

## Formulas

> Effects are unpriced (rule 4), so this section holds only the mechanical rules that need numbers. Trigger
> damage, free hits and the trigger budget are Combat Formulas G; ticks and curse bounds are Combat Formulas F;
> heals and restores are Combat Defence & Healing Formulas E.

### A. Counted chance

The counted_chance formula is defined as:

`meter ← meter + p` at each point where the chance would be rolled ; if `meter ≥ 1`: the event happens and `meter ← meter − 1` ; `meter_0 = counted_start`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| p | float | 0–1 | the chance's own formula (Combat Formulas C, I; Formulas F), after its caps | The chance that would have been rolled. Fortune does not shift it |
| meter | float | 0 to < 2 | calculated, per side, per counted chance | Visible in the Breakdown and the HUD |
| counted_start | float | 0–0.99 | keystone record | Where the meter starts each fight (default 0) |

**Output Range:** over n opportunities, the event happens `floor(counted_start + Σ p)` times: the long-run rate
equals the chance, with no variance. No seeded draw is taken. The meter and p are held as whole thousandths
(per-mille integers), so sums are exact: 0.30 is 300, and the meter pays out at 1,000.

**Example:** crit chance 0.30, counted, starting at 0: hits 1–3 add 0.3 each (0.9); hit 4 reaches 1.2, so it crits
and the meter falls to 0.2; hit 7 reaches 1.1 and crits. Over 10 hits there are exactly **3** crits.

### B. Standing status

The standing_status formula is defined as:

`upkeep_n = standing_cost · qi_max_caster` paid by the caster at every pulse while the status runs, before the status ticks ; if the caster cannot pay, or is Down, the status ends at that pulse without ticking ; the status's ticks stay inside `dot_pool_cap` and `dot_pulse_cap`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| standing_cost | float | 0.01–0.10 | status record | Share of the caster's maximum linh lực per pulse |
| qi_max_caster | float | > 0 | Combat Formulas A | The caster's maximum linh lực |

**Output Range:** the status lasts while the caster pays; a cleanse with a matching tag ends it at once.

**Example:** a standing poison with `standing_cost` 0.03 on a caster with 172.7 linh lực costs **5.2** per pulse,
against the 3.45 per pulse a typical caster regenerates, so it slowly drains them.

### C. The Down step

The down_step order is defined as:

`for each side with health ≤ 0 after the instant: (1) refusals in slot order, first unspent one sets health ← 1 and is Spent ; (2) if still ≤ 0: last acts resolve once, in slot order ; (3) a follow-up defeat check judges (1)–(2)'s damage; the side that made the last act cannot refuse again, and a side newly put Down runs (1)–(2) ; (4) wounds that run on are written to the result`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| refusal | Effect | once per fight | Effect record | "Refuses Down"; health is set to exactly 1 |
| last act | Effect | once per fight | Effect record | Resolves at Down; its damage is ordinary damage |
| follow-up check | step | — | Combat rule 10 | Uses Combat's overkill and draw rules |

**Output Range:** at most one refusal per side per Down, each refusal Effect once per fight, and one round of
last acts per Down, so the step always ends.

**Example:** side A is at −12 after an instant. Its Unyielding Breath refuses Down, so A is at 1 and the keystone
is Spent. Next instant A falls to −3. No refusal is left, so A's Parting Curse (a last act) applies its curse to B,
and A is Down.

## Edge Cases

> `systems-designer` not consulted for this section — Lean mode. Review manually before production.

**Records**
- **If an Effect's record lacks a field rule 1 requires, or its `rule` is more than one sentence**: review rejects
  it.
- **If an Effect reads a quantity not on the readable list, or uses an action not on the action list**: it is
  rejected until the engine addition is made (rules 5–6).
- **If an Effect grants an unconditional plain number not in the modifier catalogue**: rejected (rule 3).
- **If a keystone or enabler has an empty or token `closes`**: rejected (rule 14).
- **If an Effect has no tier, or a keystone or enabler is tiered `minor` or `major`**: rejected (rule 4).
- **If a host slot receives an Effect of a tier the host does not allow there**: rejected; the host GDD's slot
  table decides.
- **If two keystones a host marks as rivals are both taken**: the second cannot be taken.

**In a fight**
- **If a conditional Effect's condition changes mid-instant**: it keeps the state it had at the instant's start
  (rule 8), as Combat's guards do.
- **If triggers would exceed 6 firings, chain depth 2, or the trigger damage budget**: the excess is clipped and
  logged "trigger budget", as Combat Formulas G says.
- **If a trigger sets itself off in its own chain**: it does not fire again in that chain.
- **If a timer move would take an art below `cooldown_min`**: it stops at `cooldown_min`.
- **If a refund would return more than the art cost**: it returns the cost.
- **If an Effect's modifiers pass a cap**: the cap's owner clips them; the Breakdown names the cap.
- **If a counted chance and a rolled chance apply to the same event**: the keystone's counted chance replaces the
  roll for that one chance only; other chances still roll.

**Statuses**
- **If a standing status's caster cannot pay its pulse cost, or is Down**: the status ends at that pulse.
- **If a status is cleansed by a matching tag**: it ends at once and its remaining ticks are lost.
- **If a recast meets a status of the same id**: it refreshes the duration, unless the record says it stacks or
  the stronger wins.
- **If a curse would pass its Combat bound** (`curse_shred_max`, `curse_cost_raise_max` and the rest): it is
  clipped to the bound.

**Life costs and Down**
- **If an Effect reports a life cost the character cannot pay** (more years than remain, more stones than held):
  the caller applies what it can and reports the shortfall; it never makes the fight's result untrue.
- **If two refusals are ready on one side**: only the first in slot order takes effect at that Down; the other
  stays unspent and may save the side at a later Down in the same fight (Formulas C).
- **If both sides refuse Down in the same instant**: both are at 1 health and the fight goes on.
- **If a last act's damage downs the other side**: the follow-up check uses Combat's overkill and draw rules.

**NPCs and the LLM Game Master**
- **If an NPC build picks an Effect without `npc: true`**: NPC Builds skips it.
- **If the LLM Game Master proposes an Effect**: the engine rejects it while Effects are unpriced (rule 15).

## Dependencies

| System | Kind | What this system needs | Status | Lists this system? |
|---|---|---|---|---|
| Modifier System (#40) | Hard | Catalogue modifiers as payloads; tags | Designed | Yes |
| Combat (#21) | Hard | Instants, guards, trigger order and budget, curse bounds, tick formulas, the defeat check, results | Approved for rules | Partly: rule 9 defines triggers; the Combat revision (#43) cites this GDD for statuses and the Down step |
| Combat Defence & Healing (#21a) | Hard | Heal and restore rules, reservation, wards | Designed | Yes |
| Combat Damage Types (#21b) | Hard | Damage types of statuses; conversion | Designed | Yes |
| Character Stats (#7), Realms (#8) | Soft | Readable sheet values; applying reported life costs | In review | Not yet |
| Meridian Map (#10) | Soft (host) | Keystones; its 25 live capabilities move here as Effects | Redesign planned | Not yet |
| The Way (#39), Cultivation Techniques (#9) | Soft (hosts) | Nodes, capstones, technique and art Effects | Approved; in review | Not yet |
| Item DB (#13), Talismans (#18), Formations (#17), Alchemy (#15), Spirit Beasts (#19) | Soft (hosts) | Named-item, talisman, ground, pill and beast Effects | Approved; implemented | Not yet |
| Event Engine (#23) | Soft | Life Effects; World DB reads | Implemented | Not yet |
| NPC Builds | Soft | `npc: true` Effects | Implemented | Not yet |

## Visual/Audio Requirements

> `art-director` not consulted — Lean mode; the current client is the text Debug Terminal.

- Every Effect that fires or applies shows its name in the fight log, in its host's colour.
- Statuses show an icon in their damage type's colour (Combat Damage Types, Visual/Audio) with stacks and
  remaining pulses; curses show a broken-chain mark.
- A counted chance shows a meter that fills and flashes when it pays out.
- A refusal of Down has its own beat: a pause line in the log ("refuses to fall") and, later, a sound (Audio,
  #38).

## Game Feel

- **An Effect should read as a sentence and play as a promise.** When "on a crit, shorten your other timers"
  fires, the player should see the timers jump.
- **Keystones should feel like vows.** The tooltip leads with what is given up.
- **Counted chance should feel planned.** The meter makes the next crit something the player can see coming.
- **Refusing Down should be a moment,** used once, remembered.

## UI Requirements

- **Tooltip shape:** name; kind; the one-sentence rule; limits; then, for keystones and enablers, `closes` first.
- **Filters** by kind and by classification tag, as for modifiers.
- **Fight HUD:** status icons with stacks and pulses; counted-chance meters; Spent marks on once-per-fight
  Effects.
- **Breakdown:** one line per Effect that applied, fired or was clipped, with the reason.
- **Result screen:** reported life costs (rule 10) and wounds that run on (rule 11), each named by the Effect that
  caused it.

> **📌 UX Flag — Effects System**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design`
> for the Effect tooltip, the status HUD and the fight result screen **before** writing epics.

## Cross-References

| This document | References | Value or rule | Use |
|---|---|---|---|
| Rules 1, 3 | modifiers.md rules 1, 9, 16 | Modifier record, tag vocabulary, LLM limits | Read |
| Rules 6–8 | combat.md rules 9, 10, 13, 15, 16; Formulas G | Triggers, instants, guards, timers, seeded draws, Breakdown, trigger budget | Read |
| Rule 6 | combat-defence.md rules 5–10, 16–19 | Wards, reservation, heals and restores | Read |
| Rule 6 | combat-damage-types.md rule 6 | Conversion | Read |
| Rule 9 | combat.md rules 7–8, Formulas F | Statuses, curses, tick caps, curse bounds | Read; the status catalogue moves here |
| Rules 10–12 | overnight `decisions.md` decisions 4, 5, 9, 11 | Life costs, Down, counted chance, standing statuses | Adopted (user decisions 2026-11-07) |
| Rule 10 | combat.md rule 14 | A fight ends with a result, never a consequence | Read |
| Rule 13 | `meridian_capabilities.json` | The 25 live capabilities | Become keystones in this catalogue |

## Acceptance Criteria

> Drafted by `qa-lead` 2026-11-08. Its gaps are fixed in rules 1, 3, 6 and 11, Formulas A–C, Edge Cases and the
> Burn row. Tests go in `tests/unit/effects/` [Logic] and `tests/integration/effects/` [Integration]; screenshots
> in `production/qa/evidence/` [UI]. Effects are unpriced (rule 4), so nothing here checks price or balance.
> Fixtures come from the Starter Effects and the Status Catalogue unless marked *test fixture*.

**Records and validation**

- **AC-EF-01** [Logic] Rule 1. **GIVEN** the Flowing Water record with each rule-1 field removed in turn (including `tier`, `npc` and a read's read time), plus a copy whose `rule` is two sentences, **WHEN** validated, **THEN** each copy is rejected with an error naming the record and the field, and the intact record is accepted.
- **AC-EF-02** [Logic] Rule 2. **GIVEN** two copies of Steady Breath that differ only in `kind`, **WHEN** the same seeded fight runs with each, **THEN** the logs and results are identical.
- **AC-EF-03** [Logic] Rule 3. **GIVEN** an Effect whose unconditional payload names a stat not in the Modifier System's Stat List, or an operation that stat does not allow, **WHEN** validated, **THEN** it is rejected. **GIVEN** No Ward's +25 `body_shield_pct`, **THEN** it is accepted.
- **AC-EF-04** [Logic] Rule 4. **GIVEN** a record with `price` other than `unpriced`, or with a W, weight or budget field, **THEN** it is rejected. **AND** a search of Effect data and the Effects code finds no W value and no price-check call. **GIVEN** a keystone tiered `minor`, or a `major` Effect placed in a host slot that allows only `minor`, **THEN** it is rejected.
- **AC-EF-05** [Logic] Rule 5. **GIVEN** a read not on the readable list, or a read with no read time, **THEN** the record is rejected. **GIVEN** Gorged (live), **WHEN** 5 % of maximum health is restored partway through an instant, **THEN** the next hit in that instant gets L5 +5.
- **AC-EF-06** [Logic] Rule 6. **GIVEN** a record using an action not on the action list, **THEN** it is rejected until the action is added.
- **AC-EF-07** [Integration] Rule 6, paying in health. **GIVEN** Blood Casting, linh lực 10 and an art cost of 25, **WHEN** the art fires, **THEN** linh lực goes to 0 and health drops by exactly 15, with no resistance, ward or shield applied, and nothing counts it as damage or healing (Blood Drinker, Gorged and `heal_pulse_cap` are untouched). **WHEN** that takes health to 0 or below, **THEN** the Down step runs, and a ready refusal may save the side.
- **AC-EF-08** [Integration] Rule 6, delaying an enemy timer. **GIVEN** Soul Wound, **WHEN** a soul art lands, **THEN** the enemy's next ready art is delayed by 0.5 s; a second soul hit inside `soul_lockout` delays nothing.

**Engine limits (rule 7) and timing (rule 8)**

- **AC-EF-09** [Logic] **GIVEN** a chain event → trigger → trigger → trigger, **THEN** the third-level trigger does not fire and is logged. **GIVEN** 8 eligible firings for one side between two pulses, **THEN** 6 fire and 2 are logged "trigger budget".
- **AC-EF-10** [Logic] **GIVEN** six free hits of 3.6 (21.7) against 15.9 direct damage since the last pulse, **THEN** 7.9 is applied and "trigger budget" is logged (Combat Formulas G).
- **AC-EF-11** [Logic] **GIVEN** Echo with its chance forced to 1 (*test fixture*), **WHEN** an art hits, **THEN** exactly one free hit follows, and it does not fire Echo again in that chain.
- **AC-EF-12** [Integration] **GIVEN** Effect modifiers raising the crit sum to 0.62, **THEN** Combat applies 0.50, and the Breakdown names the Effect and the crit cap.
- **AC-EF-13** [Logic] **GIVEN** a fixed seed, **WHEN** the same fight runs twice, **THEN** the logs are byte-identical. **GIVEN** a chance of exactly 0 or 1, **THEN** the seeded stream does not advance.
- **AC-EF-14** [Integration] **GIVEN** a fight where Effects apply, fire and are clipped, **THEN** each event writes one Breakdown line naming the Effect and what it did, and an Effect that does nothing writes none.
- **AC-EF-15** [Logic] Rule 8. **GIVEN** Steady Breath at 55 % linh lực when an instant starts, **WHEN** linh lực falls to 40 % during it, **THEN** every hit in that instant gets L5 +12, and none in the next instant does.

**Statuses (rule 9, Formulas B, catalogue)**

- **AC-EF-16** [Logic] Rule 9. **GIVEN** a status missing its damage type (tick) or rule (curse), or missing strength, duration, stacking or cleanse tags, **THEN** it is rejected. **GIVEN** Shock recast, **THEN** its duration refreshes and it does not stack.
- **AC-EF-17** [Logic] Rule 9. **GIVEN** a status with no duration that lacks a `standing_cost` or a cleanse tag, **THEN** it is rejected.
- **AC-EF-18** [Logic] Formulas B. **GIVEN** a standing status with `standing_cost` 0.03 (*test fixture*) on a caster with `qi_max` 172.7, **THEN** upkeep is 5.181 per pulse (shown 5.2), paid before it ticks. **WHEN** the caster cannot pay, or is Down, **THEN** it ends that pulse without ticking. **WHEN** a matching cleanse lands, **THEN** it ends at once and its remaining ticks are lost.
- **AC-EF-19** [Logic] Burn. **GIVEN** a Burn running, **WHEN** a Burn with higher tick damage after modifiers is applied, **THEN** it replaces the first. **WHEN** an equal Burn is recast, **THEN** only the duration refreshes, back to 3. **WHEN** a weaker one is applied, **THEN** nothing changes.
- **AC-EF-20** [Logic] Poison. **GIVEN** 5 stacks, **WHEN** a 6th is applied, **THEN** there are still 5, all with 5 pulses left.
- **AC-EF-21** [Logic] Bleed. **GIVEN** stacks applied at pulse 0 and pulse 2, **THEN** the first expires after pulse 4 and the second ticks until pulse 6.
- **AC-EF-22** [Logic] Frostbite. **GIVEN** a 4th stack, **THEN** the count stays at 3. **GIVEN** Rime Lock, **WHEN** the 3rd stack lands, **THEN** the art with the least time left is delayed by 1 s, at most once per 4 pulses per target.
- **AC-EF-23** [Logic] Silence. **GIVEN** a Silence naming `ward`, `basic` or `escape`, **THEN** it is rejected. **WHEN** a Silence is reapplied within 2 pulses of ending, **THEN** it fails and is logged.
- **AC-EF-24** [Logic] Sundered and Exposed. **GIVEN** 3 Sundered stacks (−0.45) and Exposed (−0.10), **THEN** the shred is 0.50. **GIVEN** base resistance −0.20, **THEN** the result is −0.50 (`resist_floor`), never lower.
- **AC-EF-25** [Logic] Corpse Rot. **GIVEN** the loaded catalogue, **THEN** Corpse Rot is the only status with no duration. **GIVEN** Corpse Rot and Poison on one target, **THEN** they never merge, and both count inside `dot_pool_cap` and `dot_pulse_cap`.
- **AC-EF-26** [Logic] Qi Disruption. **GIVEN** 3 stacks whose ticks would pass 5 % of the target's `qi_max`, **THEN** linh lực loses exactly 5 % of `qi_max` that pulse and health loses nothing.

**Life costs, Down and counted chance (rules 10–12, Formulas A and C)**

- **AC-EF-27** [Integration] Rule 10. **GIVEN** Heart Demon's Blade with heart demon 50 before the fight, **THEN** the payload is L5 +20. **WHEN** the side wins, **THEN** the result reports +1 heart demon while the sheet still reads 50, and it reads 51 only after the caller applies the result. **GIVEN** a kill with no Effect that adds heart demon, **THEN** none is reported.
- **AC-EF-28** [Logic] Formulas C. **GIVEN** side A at −12 after an instant, holding Unyielding Breath and Final Clause, **THEN** A is set to 1 and Unyielding Breath is Spent. **WHEN** A later falls to −3, **THEN** no refusal fires, Final Clause fires A's longest-cooldown art at no cost, its damage enters a follow-up check using Combat's overkill and draw rules, and A is Down without a second refusal.
- **AC-EF-29** [Logic] Rule 11. **GIVEN** two refusals ready on one side, **THEN** only the first in slot order fires at that Down, and the second saves the side at a later Down. **GIVEN** both sides going Down in one instant, each holding a refusal, **THEN** both are at 1 and the fight continues. **GIVEN** a last act that puts side B Down, **THEN** B may use its own unspent refusal.
- **AC-EF-30** [Logic] Formulas A. **GIVEN** Called Blow with crit chance 0.30 (300 per mille) and the meter at 0, **WHEN** 10 hits land, **THEN** hits 4, 7 and 10 crit (exactly 3), the meter reads 0 after hit 10, and no seeded draw is consumed.
- **AC-EF-31** [Logic] Rule 12. **GIVEN** counted chance from a non-keystone host, or one keystone counting two chances, **THEN** the record is rejected. **GIVEN** Called Blow and Echo together, **THEN** crits are counted and Echo still rolls.

**Hosts, closes and NPCs (rules 13–15)**

- **AC-EF-32** [Logic] Rule 13. **GIVEN** an Effect attached to a host type missing from its `hosts`, or an enabler listing `affix`, **THEN** it is rejected. **GIVEN** a keystone taken, **WHEN** its host's rival keystone is chosen, **THEN** the second cannot be taken.
- **AC-EF-33** [Logic] Rule 14. **GIVEN** a keystone or enabler whose `closes` is empty, "—" or "none", **THEN** it is rejected.
- **AC-EF-34** [Integration] Rule 15. **GIVEN** NPC Builds choosing from the catalogue, **THEN** it never picks an Effect with `npc: false`. **GIVEN** the LLM Game Master proposing an Effect, **THEN** the engine rejects it, while a modifier grant is accepted.

**Starter Effects as fixtures**

- **AC-EF-35** [Logic] Flowing Water. **GIVEN** 4 crits in one pulse, **THEN** timers move 3 times and the 4th is logged as clipped. **GIVEN** an art whose next firing would come sooner than `cooldown_min` after its last, **THEN** the move stops at `cooldown_min`.
- **AC-EF-36** [Logic] Echo. **WHEN** validated, **THEN** chance × `c_trig` = 0.125 and it is accepted; a *test fixture* with 0.8 × 0.8 = 0.64 is rejected.
- **AC-EF-37** [Logic] Blood Drinker. **GIVEN** a direct hit removing 200 health, **THEN** 12 is restored before decay and caps; ticks and trigger hits restore 0; every case restores 0 under `no_heal`.
- **AC-EF-38** [Logic] Iron Skin Renewed. **GIVEN** `health_max` 1,000 with 30 already healed this pulse (cap 40), **WHEN** it fires, **THEN** the body shield regains 10, not 20.
- **AC-EF-39** [Integration] Burning Lifespan. **GIVEN** a realm base lifespan L (*test fixture*), **WHEN** it fires, **THEN** the result reports 0.02 · L years lost on a win and on a loss alike, and age does not change during the fight.
- **AC-EF-40** [Integration] No Ward. *Blocked until Combat Defence & Healing adds its two flags (Open Question 3).* **GIVEN** No Ward, **THEN** there is no default ward, ward and soul-ward arts cannot be slotted, and `body_shield_pct` is +25.
- **AC-EF-41** [Logic] Called Blow. **GIVEN** a crit sum of 0.50 and a fortune modifier, **THEN** the counted p is 0.35, and adding or removing fortune leaves it unchanged.
- **AC-EF-42** [Logic] Elemental Fist. **GIVEN** a Fire root, **THEN** the basic attack takes Fire-element-scoped damage modifiers, and its resistance is still Physical: a defender with Fire resistance 0.5 and Physical 0 takes unreduced damage.
- **AC-EF-43** [Integration] Seal of Full Payment. **GIVEN** 1,000 carried stones, **THEN** linh lực pays for nothing and stones spent are reported, not deducted mid-fight; a knockout reports a 100-stone loss to the winner; NPC Builds never picks it.
- **AC-EF-44** [Logic] L5 payloads. **GIVEN** a `damage_more` L5 modifier on a source that is not an Effect, **THEN** it is rejected (Modifier System rule 6); Kindled Wound's L5 +15 is accepted.

**Data and UI**

- **AC-EF-45** [Config/Data] **GIVEN** the shipped Effect and status data, **WHEN** the smoke check's lint runs, **THEN** every Effect has all rule-1 fields with `price: unpriced` and a valid `tier`, every keystone and enabler has a non-empty `closes`, every tick has a damage type and every curse a rule; it reports how many records it checked, and any failure names the record.
- **AC-EF-46** [UI] **GIVEN** the tooltips for No Ward and for Seal of Full Payment, **THEN** `closes` appears above the payload; one screenshot each is kept in `production/qa/evidence/`.
- **AC-EF-47** [UI] **GIVEN** a fight with Called Blow, **THEN** the HUD meter is visible, fills on each hit and flashes on payout; screenshots before and at a payout are kept in `production/qa/evidence/`.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | **How Effects get priced** (plan agreed 2026-11-08). Not by formula: an Effect's value depends on the build. At the end of the project, once the fight engine and content exist: (a) run reference builds against reference enemies with and without each Effect in `tools/balance/` (autoplay bot, NPC cohort, the overnight fight calculator), deterministic and logged; (b) convert the change in time-to-kill and survival to W, using +1 % increased damage as the yardstick; (c) take the value to the builds that want the Effect, not an average across all builds; (d) fix only outliers that break the macro targets (player edge about 0.70; one realm up wins, two realms up about half the time, never three). Until then tiers bound builds, designers size by eye, and the LLM Game Master grants no Effect | user + systems-designer | Balance pass |
| 2 | Combat Formulas F's curse bounds need restating for the new defence: add `curse_heal_taken_max` 0.5, `curse_soul_shred_max` 0.30 and a reapply lockout; restate `curse_shred_max` as resistance points across Sundered and Exposed; retire or remap `curse_pass_raise_max` (no ward pass any more) | user + systems-designer | Combat revision (#43) |
| 3 | Combat Defence & Healing needs two flags for No Ward: "cannot slot wards" and "no default ward" | systems-designer | Combat Defence & Healing review |
| 4 | Which of the 25 live capabilities close nothing (about 12) and become rule changes, and where each sits in the redesigned tree | user | Meridian Map redesign |
| 5 | About 30 inventory Effects are deferred, not rejected (Five Phases Cycle, Sheathed Blade, Against the Heavens, Home Ground, Standing Array, Seeing Eye, Soul Pressure, Mirror Ward, Spirit Severing, Focused Mind, Empty Hand, One Root, Heaven's Favour and others). Revisit at the tree rework and as Combat keys arrive | game-designer | Meridian Map redesign |
| 6 | The Way, techniques and items will add most Effects. Each new one follows rule 1's record and rules 5–7's limits; the design-build skill should check this catalogue before inventing a piece | user | Way and technique design |
| 7 | Rerolling a chance (Heaven's Favour) needs a new action; decide whether rerolls exist at all next to counted chance | user | When a reroll piece is wanted |
| 8 | Register this GDD's entities: the status catalogue's new curse bounds, `counted_chance`, `standing_status` and the Down step | user | After review |
