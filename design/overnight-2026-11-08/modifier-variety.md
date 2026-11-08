# Modifier Variety: 24 Proposals

> Overnight run 2026-11-08, unattended. Proposals only: no GDD, registry, code or config was changed.
> Read from: `design/gdd/modifiers.md` (Core Rules 1–16, Stat List, Formulas A–C, General Catalogue),
> `combat-defence.md`, `combat-damage-types.md`, `combat.md` Formulas F, `effects.md`, `item-database.md`,
> `canh-gioi.md`, the formation and talisman quick specs, and `build-test.md`.

## The result

**24 plain modifiers in 5 groups.** Each one is a number on a stat, with an optional tag scope. None has a
condition, a count or a trigger (Modifier rules 1 and 3).

| Group | Rows | Ready once the owner adds a key | Also need a new tag or scope rule |
|---|---|---|---|
| A. Durations and recovery | 5 | 4 | 1 (row 5: a `body_shield` scope on healing) |
| B. Efficiency and quality | 5 | 5 | 0 |
| C. Target-type scopes | 6 | 0 | 6 (a new "foe" tag family) |
| D. Defence variety | 4 | 2 | 2 (typed block; new status tags) |
| E. Life and economy | 4 | 3 | 1 (activity tags for cultivation speed) |

**My top six picks**, the ones that open the most new build space for the least rule work:
1. **#2 Status duration on you**. It is the only answer to curses and statuses that always land, which status resistance cannot touch (Combat F: chance-1 statuses ignore it).
2. **#4 Shield recharge delay**. It answers Combat Defence Open Question 9: shields rarely recharge in a duel at a 2 s delay.
3. **#11–12 Damage and resistance against creatures or cultivators**. Gives monster hunters and duellists (đấu pháp) different gear.
4. **#17 Block against one damage type**. The body cultivator (thể tu) gets a typed answer that is not resistance.
5. **#24 Cultivation speed in seclusion (bế quan) or while travelling**. Two life styles from one stat.
6. **#8 Pill quality chance**. The alchemist (luyện đan sư) can aim for quality, not just success.

**What this needs from the user:** a yes or no per row in the last column. Rows marked **Pending** in the Owner
column cannot be authored until that owner defines the key or tag (Modifier Stat List, "Pending").

## How to read the tables

- **Op**: F flat, I increased. No row uses `more`, which stays damage-only (rule 6).
- **Scope**: the tags it may be narrowed by, and its breadth tier (rule 11). "none" means it cannot be scoped.
- **W guess**: price per displayed unit, as in Formulas A. Every value here is a guess (G) until
  `tools/balance/autoplay.gd` measures it. A guess with a basis says which row it copies.
- **Overlaps** sit at the end of the "Why" cell, naming existing Stat List or catalogue rows.
- A *duration* stat is still a plain modifier. Rule 1 bans a modifier that has its own duration, not a stat
  that measures one. Status duration is already in the Stat List on the same reading.

## A. Durations and recovery

| # | Stat (key) | Op | Scope | Why it adds variety | Owner that needs a key | W guess | Accept? |
|---|---|---|---|---|---|---|---|
| 1 | Cast ward duration (`cast_ward_duration_pct`) | I | none (implied [ward], family) | Cast wards (Black Tortoise Shell, up 2 s) get longer uptime, a third ward axis after strength and payment. Overlaps: ward strength, ward efficiency | Combat Defence rule 7. Owner must cap duration below cooldown, so a cast ward is never always up | 0.5 / % | **Yes** (added to modifiers.md, 2026-11-08) |
| 2 | Status duration on you (`status_duration_taken_pct`) | I, lower is better | incoming status: [over_time], [curse] (family) | Shortens what lands on you. The only defence against statuses that always land. Overlaps: status resistance [over_time]/[curse] (chance, not length) | Combat F (`duration`, `curse_duration_max`) | 0.3 / % reduced | **Yes** (added to modifiers.md, 2026-11-08) |
| 3 | Shield recharge rate (`shield_recharge_pct`) | I | none (implied [shield], family) | A layered-shield build refills faster without paying for ward efficiency's other halves. Overlaps: ward efficiency, which already speeds recharge (Defence rule 6) | Combat Defence Formulas B (`shield_recharge` 0.25/s) | 0.4 / % | Held (user, 2026-11-08) |
| 4 | Shield recharge delay (`recharge_delay_pct`) | I, lower is better | none (implied [shield], family) | Lets a standing shield come back inside a duel. Overlaps: none; nothing touches `recharge_delay` today | Combat Defence Formulas B (`recharge_delay` 2.0 s) | 0.6 / % reduced | **Yes** (added to modifiers.md, 2026-11-08) |
| 5 | Body-shield restore (`healing_pct` scoped [body_shield]) | I | heal: [body_shield] (narrow) | Body cultivators who restore their shield by Effect grow that restore alone. Overlaps: healing (restoring is healing, Defence Formulas B), so a scope, not a new key | Combat Defence E: a `body_shield` tag on restores. Pending | 0.5 / % (healing's price; narrow breadth sizes it) | **Yes** (added to modifiers.md, 2026-11-08) |

## B. Efficiency and quality

| # | Stat (key) | Op | Scope | Why it adds variety | Owner that needs a key | W guess | Accept? |
|---|---|---|---|---|---|---|---|
| 6 | Formation upkeep (`formation_upkeep_pct`) | I, lower is better | none | A formation master can hold more levels at home for the same yearly spirit stones (linh thạch). Overlaps: Earth (Thổ) purity's upkeep cut | Formations quick spec (`upkeep_lt_per_level`) | 0.15 / % reduced | **Yes** (added to modifiers.md, 2026-11-08) |
| 7 | Talisman ink cost (`talisman_ink_pct`) | I, lower is better | none | Cheaper drawing for talisman spammers (phù sư). Overlaps: talisman keep chance (Pending), both economy only | Talismans quick spec (`ink_lt`). Pending | 0.15 / % reduced | **Yes** (added to modifiers.md, 2026-11-08) |
| 8 | Pill quality chance (`pill_quality_chance`) | F (pp) | none | Chance a brew comes out one quality grade higher (cap at grade 3). Aims at potency, not success. Overlaps: alchemy success, pill effect | Alchemy; Item DB (`quality` 0–3) | 1.0 / pp | **Yes** (added to modifiers.md, 2026-11-08) |
| 9 | Artifact grade chance (`refine_grade_chance`) | F (pp) | none | Shifts refining's grade roll (40/30/18/9/3) one step up. A refiner (luyện khí sư) can chase grade, not just success. Overlaps: refining success | Artifact Refining; Item DB grade roll | 1.5 / pp | **Yes** (added to modifiers.md, 2026-11-08) |
| 10 | Herb potency (`herb_potency_pct`) | I | none | Better herbs from the same field. **Strong overlap**: herb growth, which already raises age and so potency. Lean reject unless potency is split from age | Spirit Herbs / Item DB herb potency | 0.6 / % | Held (user, 2026-11-08) |

## C. Target-type scopes (a new "foe" tag family)

These need one new rule: a **foe** tag family (`cultivator`, `creature`, `demonic`, `tribulation`) stamped on each
combat profile at compile, and rule 8 extended so offence stats may match the *defender's* foe tag and
resistance the *attacker's*. A foe tag never changes inside a fight, so it is a tag match like a damage type,
not a condition. The tag name `beast` is already taken by the form family, so creatures use `creature`.

| # | Stat (key) | Op | Scope | Why it adds variety | Owner that needs a key | W guess | Accept? |
|---|---|---|---|---|---|---|---|
| 11 | Damage against cultivators (`attack_pct` [cultivator]) | I | outgoing hit: [cultivator] (broad) | Duellist and sect-war gear. Overlaps: universal damage (most fights are against cultivators, so broad) | Combat rules 2, 18: foe tags on profiles. Pending | 1.0 / % (×1.25 breadth) | **Yes** (added to modifiers.md, 2026-11-08) |
| 12 | Damage against creatures (`attack_pct` [creature]) | I | outgoing hit: [creature] (family) | Monster hunters and beast-tamer bait builds. Overlaps: universal damage | Combat rule 18, Formulas J (`creature_mult`). Pending | 1.0 / % (×1.5) | **Yes** (added to modifiers.md, 2026-11-08) |
| 13 | Damage against demonic foes (`attack_pct` [demonic]) | I | outgoing hit: [demonic] (narrow) | The righteous-path exorcist. Overlaps: Light damage, if Light is the anti-demon type. **No GDD has demonic foes yet** | World Gen / NPC Builds would define them. Pending | 1.0 / % (×2.0) | Held (user, 2026-11-08) |
| 14 | Damage against tribulation (`attack_pct` [tribulation]) | I | outgoing hit: [tribulation] (narrow) | Builds that break tribulation (thiên kiếp) by force. Waits on tribulation boss fights, which are deferred until builds are designed | Heavenly Tribulation (#22). Pending | 1.0 / % (×2.0) | Held (user, 2026-11-08) |
| 15 | Resistance against cultivators or creatures (`resist_pct` [cultivator] / [creature]) | F (pp) | incoming hit: foe tag (broad / family); may pair with a type, e.g. [fire, creature] | The matching defence: a hunter's hide armour, a duellist's robe. Overlaps: all resistance, typed resistance | Combat Defence rule 3 (today resistance matches only the final damage type). Pending | 1.25 / pp (all-resistance price, then breadth) | **Yes** (added to modifiers.md, 2026-11-08) |
| 16 | Resistance against tribulation (`resist_pct` [tribulation]) | F (pp) | incoming hit: [tribulation] (narrow) | Prepares for a breakthrough without the Lightning resistance that also helps in duels. Overlaps: Lightning resistance, which tribulation already uses. **Risk**: it bends the breakthrough gates (edge 0.30 / 0.20); Realms must check it. Price is set to breakthrough value, not combat value | Heavenly Tribulation; Realms. Pending | 2.0 / pp | Held (user, 2026-11-08) |

## D. Defence variety

| # | Stat (key) | Op | Scope | Why it adds variety | Owner that needs a key | W guess | Accept? |
|---|---|---|---|---|---|---|---|
| 17 | Block against one damage type (`block_rating` [type]) | F (rating) | incoming hit part: [physical]/[force] (broad), other types (family) | A Physical-only block pool for the iron-body cultivator. Overlaps: universal block, typed resistance | Combat Defence A2: a typed rating blocks only matching parts, after the shared pool. Rule change. Pending | 0.4 / rating (block's price, then breadth) | **Yes** (added to modifiers.md, 2026-11-08) |
| 18 | Ward shield size (`shield_size_pct`) | I | none (implied [shield], family) | Grows shields only, so a shield build does not pay for resistance and block it does not use. Overlaps: ward strength (scales every ward payload, shields included) | Combat Defence Formulas B (σ) | 0.7 / % | Held (user, 2026-11-08) |
| 19 | Status resistance per status (`status_resist_pct` [burn] / [bleed] / [frostbite] / [qi_burn]) | F (pp) | incoming status: one status tag (narrow) | Lets a defence answer one enemy family's status. Overlaps: status resistance [poison] and [over_time] rows | Modifier tag vocabulary (effect family has only `poison`); Damage Types Open Question 4 (status catalogue). Pending | 0.4 / pp (×2.0) | **Yes** (added to modifiers.md, 2026-11-08) |
| 20 | Body shield, increased (`body_shield_pct`, op I) | I | none | Lets many small sources multiply one body shield, as health does. Overlaps: body shield flat (today F only) | Combat Defence Formulas B (`body_shield_cap` still applies) | 0.6 / % | **Yes** (added to modifiers.md, 2026-11-08) |

## E. Life and economy

| # | Stat (key) | Op | Scope | Why it adds variety | Owner that needs a key | W guess | Accept? |
|---|---|---|---|---|---|---|---|
| 21 | Buy price (`buy_price_pct`) | I, lower is better | none | The thrifty merchant cultivator. Overlaps: presence (mị lực), about 0.4 % trade both ways per point | Market (#20) (buy markup 1.5 today) | 0.3 / % reduced | **Yes** (added to modifiers.md, 2026-11-08) |
| 22 | Sell price (`sell_price_pct`) | I | none | Crafters who sell their output. Overlaps: presence. **Risk**: Market must keep sell below buy (0.6 vs 1.5 today), or buy-and-sell becomes a loop | Market (`market.sell_ratio` 0.6) | 0.3 / % | **Yes** (added to modifiers.md, 2026-11-08) |
| 23 | Sect contribution (`sect_contribution_pct`) | I | none | Rise in the sect (tông môn) by service rather than by stones. Overlaps: mission income (stones, not standing). **No contribution key found in any GDD** | Sects & Missions (#26). Pending | 0.7 / % (mission income's price) | Held (user, 2026-11-08) |
| 24 | Cultivation speed by activity (`cultivation_speed_pct` [secluded] / [travelling]) | I | cultivation season: one activity tag (family) | The hermit (bế quan) and the wanderer (du lịch) build differently. Overlaps: universal cultivation speed; Realms' `closed_door_efficiency` 1.2 | Realms rule on closed-door cultivation; Time & Turn: activity tags on each season. Stat target changes from "none". Pending | 2.2 / % (×1.5) | **Yes** (added to modifiers.md, 2026-11-08) |

**Left out: road encounter rate.** It was asked for, but it has no "better" direction: a hunter wants more
encounters and a hermit fewer. Rule 3 needs one. It could be two keys (hostile encounter rate, lower is better,
next to stealth; and the existing cơ duyên rate), but I found no road-encounter key in Travel to hang it on.
Without the user's call on direction I did not add it.

## Things worth knowing

- **Two new scope targets are the real cost.** Group C needs the foe family, and row 24 needs activity tags.
  Both are tag matches on fixed facts, which keeps them inside rule 1. If the user reads "against a creature" as
  a condition instead, all of Group C moves to Effects and only rows 15–16 survive, as Effects.
- **Three rows mostly repeat an existing stat.** #3 (ward efficiency), #10 (herb growth) and #18 (ward strength).
  Each is the narrow half of a broad stat, so it should be priced lower or rejected.
- **#16 touches the difficulty targets.** Tribulation resistance that does nothing in duels is cheap to stack.
  Its price must come from breakthrough value, and Realms should re-run its gate check before accepting it.
- **#22 needs a Market guard.** No sell bonus may push the sell price above the buy price.

## What I could not do

- **Formations and Talismans** have only quick specs, no GDD. Rows 6–7 read their keys from
  `quick-specs/luyen-khi-and-tran-phap.md` and `quick-specs/phu-luc-linh-thu-thanh-tuu.md`.
- **Demonic foes** (row 13) and **sect contribution** (row 23) are not in any GDD I searched. Both rows wait on an
  owner who does not exist yet.
- **Road encounter rate** was not added (see Group E).
- **No W price was measured.** All 24 are guesses, and the catalogue generator was not run.
