# The Flash Before the Thunder (Tiên Điện Hậu Lôi)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10, unattended). Not in game data. Numbers on new content are first guesses.
> **Seed**: Everything goes into the first second the arts can fire: art speed pulls the first firing earlier, every layer is filled for one volley, crit at cap. A glass cannon that ends ordinary fights before the ward matters, and must answer what happens when the volley does not kill.
> **Direction**: The Flash Before the Thunder: opening haste brings every art's first firing to the 0.5 s floor; a costly Breaker spends the enemy's ward pool, cheap followers land through it in the same instant, and a guarded finisher fires in the follow-up instant if anything survives.
> **Realm span**: Nguyên Anh (Nascent Soul), with a Kết Đan (Core Formation) check · **Power level**: top-end · **Use**: player
> **Fit**: 18 Fits today · 14 Needs key · 3 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (The fight: `fight_calc.py` reports CONSTANT_DRIFT on 31 of 60 constants, and the engine, opening haste, is not in its model; hand arithmetic from the current GDD formulas stands in, see Fight Results)

## Directions considered

- **Chosen: The Flash Before the Thunder (Tiên Điện Hậu Lôi).** Thunder root. Opening haste plus art speed put the whole volley at `cooldown_min`; slot order breaks the ward; follow-up instant, refusal and last act answer a survivor. The only direction that uses the seed's own levers (art speed, layers, crit) and the timeline's real rules.
- **The Drawn Bow (Mãn Cung)**, Metal, "win before the fight": L4 talismans, coatings and Ambush (arts ready at t = 0 in a stealth-opened fight) all fire at once. Not picked: it is crippled in every blind fight and its key piece (Ambush) depends on the Event Engine's fight situation, not on the build.
- **The Borrowed Second (Tá Thời)**, the surprise reading: do not get faster, make the enemy slower (Thunderclap, Soul Wound, Rime Lock) so an ordinary volley still lands first. Not picked: control arts on long cooldowns fire after the enemy's opener, so it fails exactly where the seed must win; it suits a control build better than a min-max alpha strike.

## The Spine

- **The channel:** art hit. Every layer L1 to L5 is filled for one instant (L2, L3 and L4 at their caps in a foreseen fight); crit chance and crit multiplier at their caps (0.5, ×3.0). The caps that matter are `cooldown_min` (0.5 s, the earliest any art may fire) and L5 (100).
- **The enabler:** none. The build is a stack of what exists plus one new stat, opening haste.
- **The loop:** at 0.500 s all four volley arts fire in one instant; slot 1 (the Breaker) spends the enemy's drain-ward pool, slots 2 to 4 land through the broken ward. If anything is left, Rolling Thunder fires in the follow-up instant at the same millisecond. Crits pull the next volley closer (Flowing Water) and pay for it (linh lực on crit).
- **The engine:** a drain ward bills linh lực for each point it prevents, so one very large hit empties the pool, and hits later in the same instant meet no drain ward at all (Combat Defence & Healing Formulas C; Combat rule 23). Put that hit first, and put it at the floor, where only a tie can reach you; a tie is judged on overkill share and refusals, which a four-art volley and Unyielding Breath win.
- **The sacrifice:** health and staying power. Glass Meridians (−25 % health) and Unyielding Breath (−15 %) leave about 6,100 health at Nascent Soul; nothing in the build blocks a top-end hit. It refuses to fix long fights: against a boss with top-end damage and a big pool it loses.
- **The arc:** at Kết Đan it is a fast caster whose volley comes at 0.8 s and kills everything but the realm two above; at Nguyên Anh the volley reaches the floor; at Hóa Thần it needs a Thiên giai Thunder canon that does not exist yet.

## The Legend

The Thunder Emperor True Canon (Lôi Đế Chân Kinh) is old and common enough that half the Thunder-rooted in the south own a copy. What they do not own is the habit its author kept: he never let an opponent finish a sentence. The sect that kept his manual called the habit "the flash before the sound": you see the light, and by the time the thunder reaches you there is no one left to hear it.

The ones who walk this path now are duellists and hired blades. They do not train endurance. They train the first half-second, until four arts leave the hand together, and they carry a banner from the old war sect whose first stroke fell before the herald finished speaking. They die young, often of the one fight that did not end at once.

Who wants them gone: sects whose elders are worth more alive than a duel is worth, and every boss of a secret realm, which is built to outlast a first strike.

## How It Fights

Nothing happens at t = 0. At 0.500 s, before either side's first basic attack or the first pulse, four Lightning arts fire in slot order. The Cloud-Splitting Bolt lands first and is large enough that the enemy's ward spends its whole pool stopping it; the three cheap followers land on an enemy with no drain ward left. Against a typical or top-end cultivator of the same realm, the fight ends there. If the enemy refuses Down at 1 health, or the volley left it under half health, Rolling Thunder fires in the follow-up instant of the same millisecond and ends it. If the enemy's opener arrives in the same instant, Unyielding Breath holds you at 1 health while the enemy, who took the volley, goes Down.

**Signature moment:** the Breakdown of a single instant at 0.500 s: four Lightning hits, the enemy's ward billing its last linh lực on the first one, then three hits with no ward line at all, then the enemy's opener landing on you, your refusal, and the result: knockout, fight time 0.500 s.

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1. Base | Lôi Đế Chân Kinh arts | Breaker c 4.15 at cost 0.10; followers c 2.35 at cost 0.025; all on 4 s authored cooldowns, at the #44 lint maximum | Flat base | art | none | ○ | Technique abilities | variant-thunder builds |
| 2. Rate | Art speed (`art_speed_pct`) | +200 %: 4 s arts cycle at 1.333 s | Increased | art | none | ◐ | Tree (Thunder island), Glass Meridians +40, Lôi Đạo Thiểm Điện | any art build |
| 2. Rate | **Opening Haste (Tiên Phát)**, `opening_haste_pct` | +250 %: first firing = 1.333 ÷ 3.5 = 0.381 s, floored at 0.500 s | Timing | art | none | ○ | Technique passive +80, Lôi Đạo +80, Herald's Banner +40, Thunder-Gall Pill +30, Drawn Bowstring +20 | slow-thunder, soul and talisman openers, Ám Đạo assassins |
| 3. L1 | Damage [lightning] and `attack_pct` | about +360 raw (+280 after the knee): tree, Thunder root (0.30 per purity), technique +15 | Increased | art, basic | L1 | ● / ◐ | Tree, root, technique | any art build |
| 3. L2 | `damage_more` [loi], [lightning] | +300 (cap): technique +50, the art's own +40, Lôi Đạo three notables +40, two aux techniques +45 | More | art | L2 | ◐ | Technique, Way, aux techniques | variant-thunder builds |
| 3. L3 | Gear | Two Cực phẩm Nguyên Anh seals (`an`, attack 40 × 3.0 × 1,000 = 120,000 each = 120 points) with Liệt affixes: capped at 250 | (gear) | art, basic | L3 | ● | Artifacts | any build |
| 3. L4 | Thunder-Gall Pill +70 [lightning]; Ringing Ground (Nine Rods Array) +80 | Foreseen fights only: 150 (cap); blind fights 0 | More | art | L4 | ○ | Pill, formation | any Lightning or prepared art build |
| 3. L5 | **Unanswered (Vô Ứng)** | +40 on arts while the enemy has fired no art this fight | Conditional | art | L5 | ○ | Lôi Đạo Thiểm Điện major | Ám Đạo assassins, soul openers |
| 3. L5 | **Eruption (Phún Trào)** | +5 per other art you fired this instant, cap +25 (a 4-art volley gives +15) | Per | art | L5 | ○ | Way notable, technique | cooldown-floor, synchronised kits |
| 4. Crit | Crit chance, crit damage | To 0.50 and ×3.0 (the caps): +50 pp from tree and Way [lightning] notables; +150 pp crit damage from four element notables | Flat | art | none | ◐ | Tree, Lôi Đạo | every crit build |
| 5. Reach | Slot order | The Breaker first: the largest hit empties the drain ward's pool; later hits of the instant meet none | (rule) | art | none | ● | Loadout | any alpha strike |
| 5. Reach | Iron Spark's own conversion | 60 % Lightning → Physical: the Physical part ignores Lightning resistance, keeps [lightning] for offence | Conversion | art | none | ○ | Art record | any element-locked build |
| 6. Past the cap | **Taut String (Huyền Căng)** | Opening haste that the 0.5 s floor clips becomes L5 on that first firing: +1 per 5 pp clipped, cap +30 (here +16.7) | Overflow | art | L5 | ○ | Drawn Bowstring cluster | signature |
| 7. Fuel | First Move (Tiên Thủ) | The Breaker's first firing costs nothing: the first volley costs 234 linh lực (6 %) | Rule swap | art | none | ● (designed) | Herald's Banner | every alpha strike |
| 7. Fuel | `art_cost_pct` −20, `linh_luc_on_crit_pct` +1.26 | Reload volleys cost 546 (14 %); each crit returns 49 | Increased, flat | art | none | ◐ | Tree | any art build |
| 8. Survival | Unyielding Breath (Bất Khuất) | Once a fight, a blow that would put you Down leaves you at 1. Closes −15 % health | Trade | — | none | ● (designed) | Meridian Map keystone | body builds, escape builds |
| 8. Survival | Rolling Thunder's guard | Enemy health at or below 50 %: waits through the volley, fires in the follow-up instant | (rule) | art | none | ● (rule 13 guard) | Art record | any execute |
| 8. Survival | Flowing Water (Lưu Thủy) | Each crit pulls your other arts' timers 0.5 s closer (3 a pulse): with 2 crits the second volley comes at 1.0 s | Trigger | art | none | ● (designed) | Meridian Map | crit tempo builds |
| 8. Survival | Final Clause (Mạt Khoản) | As you go Down, your longest-cooldown art (the Breaker, by slot order) fires free | Trigger | art | none | ● (designed) | Technique layer 12 | dark paths, burst builds |
| 8. Survival | Glass Meridians (Lưu Ly Kinh Mạch) | +40 % art speed; closes −25 % health, body shields half | Trade | art | none | ● (designed) | Meridian Map | tempo, crit casters |
| 9. Identity | **Opening Haste** | See rung 2. Delete it and the volley comes at 1.333 s, after the enemy's first basic attack | Timing | art | none | ○ | as above | as above |

**Forms used:** Flat base, Increased, More, Timing, Conditional, Per, Overflow, Conversion, Rule swap, Trigger, Trade (11).
**Identity piece:** Opening Haste. It is the only piece that moves the volley from 1.333 s to the floor; `fight_calc` shows the difference (Fight Results).
**Empty rungs:** none. Rung 7 is thin by choice: the build is not meant to cycle for long (the sacrifice).

| Layer | Points at Nguyên Anh (foreseen) | Multiplier | Sources |
|---|---|---|---|
| L1 | 360 raw (280 counted past the 200 knee) | ×3.80 | Tree, Thunder root, technique. Stop near +200 raw unless nothing else is left: each point past it counts half |
| L2 | 300 (cap) | ×4.00 | Technique, the arts, Lôi Đạo, two aux techniques |
| L3 | 250 (cap; 240 from two seals before affixes) | ×3.50 | Two Cực phẩm seals |
| L4 | 150 (cap); 0 when blind | ×2.50 (×1.00 blind) | Thunder-Gall Pill, Nine Rods Array |
| L5 | 71.7 in the first volley (Unanswered 40, Eruption 15, Taut String 16.7); 55 in later volleys while Unanswered holds | ×1.72 | Effects only |
| **M** | first volley | **228.3** (blind 91.3) | L1–L4 product 133.0 |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Thunder (Lôi), a convergence of Fire and Metal, purity 60+ | Lightning tags for every scope; `attack_pct` 0.30 per purity point; opens Lôi Đạo (needs Thunder, purity ≥ 30) and the Thunder canon |
| Key talents | Comprehension (ngộ tính) for technique layers; Root bone (căn cốt) only enough to survive realm gates | Layer 12 of the canon holds Lightning Step and Final Clause; the build does not buy health |
| The Way (Đạo) | Lôi Đạo · *Cửu Thiên Lôi*, facet Thiểm Điện (Lightning: crit, speed). Second Way: Ám Đạo (Thích Khách: first strike, crit) or Thời Đạo (Tốc: art speed) | Thiểm Điện holds the opening-haste notables, art speed [loi], crit, three L2 notables and Unanswered |

## Công Pháp

### Lôi Đế Chân Kinh (Thunder Emperor True Canon) — main, Địa giai (tier 2)

The template is in the game (`items_cong_phap.json`, id `loi_de_chan_kinh`); only its abilities are new. "The author never let an opponent finish a sentence."

```json
{"id": "loi_de_chan_kinh", "name": "Lôi Đế Chân Kinh", "tier": 2, "tech_kind": "main",
 "names": ["loi"], "layers": 12,
 "bonuses": [{"stat": "attack_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 10}],
 "abilities": [{"ability_id": "forked_light", "unlock_layer": 1},
               {"ability_id": "thunder_needle", "unlock_layer": 3},
               {"ability_id": "cloud_splitting_bolt", "unlock_layer": 5},
               {"ability_id": "iron_spark", "unlock_layer": 7},
               {"ability_id": "before_the_sound", "unlock_layer": 9},
               {"ability_id": "rolling_thunder", "unlock_layer": 11},
               {"ability_id": "lightning_step", "unlock_layer": 12},
               {"ability_id": "final_clause", "unlock_layer": 12}],
 "seal_clusters": ["drawn_bowstring"], "origin": "authored"}
```

`before_the_sound` is a passive: `opening_haste_pct` +80 and `damage_more` +50 scope [loi] (L2).

**Fit:** Needs key (abilities have no field yet) · **Budget:** 15/15 + 10/20 = **1.50 of 3** (tier 2), each value within `bonus_single_cap` 1.5; `max_realm` nguyen_anh reaches the span. Abilities do not count against the budget.

## Arts

Coefficients use the #44 lint, `c ≤ 1 + 24 · cost + 0.25 · (cooldown − 1)` (Combat Formulas C). All are Lightning (`loi`, `lightning`, `art`), cooldown 4 s, so with art speed +200 % they cycle at 1.333 s.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Cloud-Splitting Bolt (Phá Vân Lôi) | Canon, 5 | hit; loi, lightning, costly | 4.15 | 0.10 | 4 s | — | Needs key |
| Forked Light (Xoa Điện) | Canon, 1 | hit; loi, lightning, cheap | 2.35 | 0.025 | 4 s | — | Needs key |
| Thunder Needle (Lôi Châm) | Canon, 3 | hit + curse; loi, lightning, cheap | 2.35 | 0.025 | 4 s | — | Needs key |
| Iron Spark (Thiết Tinh) | Canon, 7 | hit, 60 % to Physical; loi, lightning, cheap | 2.35 | 0.025 | 4 s | — | Needs key |
| Rolling Thunder (Hậu Lôi) | Canon, 11 | hit; loi, lightning | 2.95 | 0.05 | 4 s | enemy health ≤ 50 % | Needs key |
| Lightning Step (Lôi Độn) | Canon, 12 | escape; loi, escape | — | 0.05 | 4 s | own health ≤ 30 % | Needs key |

- **Cloud-Splitting Bolt.** Effect: a Lightning hit. Slot 1. Description: the first light, wide enough to split a cloud bank.
- **Forked Light.** Effect: a Lightning hit. Description: the branch that follows the main stroke down.
- **Thunder Needle.** Effect: a Lightning hit that applies Leaking Ward (the target's drain wards bill +50 %, 3 pulses). Against a survivor with a big pool, the second volley drains it faster. Curses carry no lint charge today, so c is the plain lint (first guess). Description: a needle of charge left in the meridians.
- **Iron Spark.** Effect: a Lightning hit, 60 % converted to Physical by the art itself (first conversion step). Description: the Metal in the Thunder root, struck like flint.
- **Rolling Thunder.** Effect: a Lightning hit. Its guard is false at the volley's instant start, so it waits, and fires in the follow-up instant if the volley leaves the enemy at or below half health, including at 1 health after a refusal. Description: the sound arrives after the light.
- **Lightning Step.** Effect: escape (Combat rule 10, Formulas I). With Cold Feet its first firing comes at `cooldown_min`. Description: leave before the echo does.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Kết Đan | 5 | Breaker, Forked Light, Thunder Needle, Rolling Thunder, Lightning Step | Common Ward in a free ward slot | Volley at 0.8 s (art speed +150 %, opening haste +100 %: 4 ÷ 2.5 ÷ 2 = 0.8); Iron Spark not yet learned |
| Nguyên Anh | 6 | Breaker, Forked Light, Thunder Needle, Iron Spark, Rolling Thunder, Lightning Step | Common Ward in free ward slots (3 by realm) | Volley at 0.500 s. Swap Lightning Step for another damage art only when you are sure of the matchup |
| Nguyên Anh, boss or tribulation | 6 | Breaker, Forked Light, Thunder Needle, Iron Spark, Rolling Thunder, Thunderclap (by-root, delays every enemy art 1 s) | add a reserved ward | Drop Glass Meridians for health; expect to win only bosses with ordinary damage |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Two seals | Artifacts, weapon | `an`, Cực phẩm, Thông thiên linh bảo (Nguyên Anh), Liệt affix | L3 to its cap (120 points each before affixes) | Fits today |
| Herald's Banner (Tiên Thanh Kỳ) | Named artifact, utility | `ky`, Cực phẩm, Nguyên Anh | First Move; `opening_haste_pct` +40. History: an old war sect's banner whose first stroke fell before the herald finished speaking | Needs key |
| Thunder-Gall Pill (Lôi Đởm Đan) | Pill, preparation | Alchemy | For one fight: L4 +70 [lightning], opening haste +30; pill toxicity as its recipe sets | Needs key |
| Nine Rods Array (Cửu Can Trận) | Formation, preparation (foreseen) | Formations | Ringing Ground +80 (L4). Nine iron rods drawing the storm to one spot | Needs key |

Equipped artifacts: two seals, the banner and ward gear (four of `equip.max_slots` 6).

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Glass Meridians (keystone) | art speed +40; −25 % health | Reload speed; the glass in the glass cannon | Fits today (designed) |
| 2 | Unyielding Breath (keystone) | one refusal; −15 % health | Wins every floor tie | Fits today (designed) |
| 3 | Drawn Bowstring cluster (sealed) | opening haste +20, Taut String | The last of the opening haste, and its overflow | Needs key |
| 4 | Flowing Water | crit pulls timers 0.5 s | Second volley at 1.0 s | Fits today (designed) |
| 5 | Crit chance and crit damage notables [lightning] | to the caps | Expected crit factor ×2.0 | Fits today (Modifier System) |
| 6 | Art speed notables [loi] / [lightning] | to +200 % with the Way | The reload cycle | Fits today |
| 7 | `attack_pct` [lightning] | to about +200 raw | Past the knee each point counts half | Fits today |
| 8 | Cold Feet | escape's first firing at the floor | Exit after a refusal | Fits today (designed) |

### Hidden cluster idea: Drawn Bowstring (Mãn Huyền)

Theme: the first stroke of any fight (wider than this build: assassins, soul openers, talisman openers). Affinity: Thunder or Wind. Kind: sealed; seal: the Lôi Đế Chân Kinh lists it in `seal_clusters`. Size: 8 acupoints. Smalls: opening haste +4, art speed +2, crit chance +1.2. Notables: opening haste +12; the farthest, Taut String. No capability. An idea for the tree rework, not data.

## Đạo

No new Way. Lôi Đạo's Thiểm Điện facet takes: two stat notables "Before the Sound" (opening haste +40 each; the key joins Lôi Đạo's `theme_stats`), art speed [loi] (+53 per 16 W notable), crit chance [lightning], three L2 notables +40 [lightning], and Unanswered as the facet's `major` Effect.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Trúc Cơ | A Lightning caster with a quick opener | Thunder root awakened; Lôi Đạo glimpse | Learns the canon from a common copy |
| Kết Đan | Volley at about 0.8 s, before any basic attack | Breaker, Rolling Thunder; Glass Meridians | Takes the first duel that ends before the herald speaks |
| Nguyên Anh | Volley at the 0.5 s floor; floor ties won by refusal | Herald's Banner, Iron Spark, Drawn Bowstring, the pill and array | Hunted by sects whose elders it shamed; avoids secret-realm guardians |
| Hóa Thần | Needs a Thiên giai Thunder canon (not in the game) | — | The manual's author died of the one fight that did not end |

## Matchups

Hand arithmetic from the current formulas (Fight Results). P = chance the 0.5 s volley alone ends it.

| Enemy | Result | Why |
|---|---|---|
| Typical, same realm | wins at 0.500 s | The Breaker alone, without a crit, deals about 67,500 against 11,520 health |
| Typical, blind fight | wins at 0.500 s | L4 gone (M 91.3): the Breaker empties the pool, the second hit kills |
| Top-end, opener at 1.0 s or later | wins at 0.500 s | Even an all-non-crit volley deals about 42,000 against 22,400 |
| Top-end, opener at the 0.5 s floor | wins at 0.500 s | Both sides are put Down; Unyielding Breath refuses yours, theirs stays Down. Without the refusal, about 4 in 10 (overkill share, crits) |
| Top-end with its own refusal | wins at 0.500 s | It is at 1 health; Rolling Thunder fires in the follow-up instant |
| Top-end, evade at the 40 % cap | wins at 0.500 s about 95 % | Accuracy 15 leaves 25 % evade; two landed hits are enough |
| Top-end, reserved ward +1,000 points | wins at 0.500 s | An all-non-crit volley still deals about 22,900 against 22,400 |
| Mirror (another first-volley build) | even | Both refuse, both Rolling Thunders, both Final Clauses: crits decide |
| Top-end, one realm up (Hóa Thần) | wins about 75 % at 0.500 s | Suppression ×0.9; the pool breaks if the Breaker crits or two followers do; otherwise its opener at 1.0 s takes the refusal and the build has no linh lực left |
| Boss, ×10 pools, ordinary damage | wins at about 1.5–2 s | Its hits cannot break the build's ward; the third volley breaks its pool |
| Boss, ×10 pools, top-end damage | loses at about 2 s | Its opener takes the refusal at 1.0 s and empties your pool; its basic at 2.0 s ends you; Final Clause adds one free Breaker |

**Counter:** a boss with top-end damage and a large pool, or a tribulation's waves (each wave begins after the pool was spent on the last). The build cannot outlast either, and refuses to: it is a duellist. The world's answer is a sect enforcer with a reserved ward of 3,000 points or more, which the volley cannot break, and its own floor opener.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Technique 1.50 of 3 (tier 2), each value ≤ 1.5; arts at or under the #44 lint (Breaker 4.15 = max 4.15, followers 2.35 = max, Rolling Thunder 2.95 = max); 6 of 6 slots at Nguyên Anh, 5 of 5 at Kết Đan; 4 of 6 artifacts. Not checked: the thần thức of four Cực phẩm Nguyên Anh pieces (no thần thức budget figure read) |
| Validity | PASS | `loi` root (convergence of hoa + kim), `loi_de_chan_kinh` tier 2 with `max_realm` nguyen_anh, bases `an` and `ky`, realm nguyen_anh. The two aux techniques are generic Lightning secret techniques (none in data), so their harmony with the main was not checked |
| Stack | PASS | All nine rungs filled; 11 forms; layers stated (M 228.3 first volley, 91.3 blind). Identity test in `fight_calc` (proxy, see below): with the opening at the floor, win at 0.500 s against the top-end profile; without it, knocked out at 1.000 s by that profile's first basic attack. The fight changes |
| Scaling | PASS (INFO: above the anchors) | M 228.3 against the top-end anchor 256, but with crits at both caps (expected ×2.0 against the anchor's ×1.5), so the effective 457 beats the anchor's 384. Not pulled back |
| The fight | NOT ASSESSED | CONSTANT_DRIFT (31 of 60 constants; pre-#44 ward, guard, health and lint), and opening haste is not in the model. Observations and hand arithmetic below. Cap hits: L2, L3, L4, crit chance, crit multiplier; `cooldown_min` on every first firing |
| Reuse | PASS | Reused: First Move, Flowing Water, Final Clause, Cold Feet, Unyielding Breath, Glass Meridians, Leaking Ward, Ringing Ground (Ninth Bell), Eruption and Thunderclap (by-root). One signature piece (Taut String) |
| NPC use | PASS | Opening haste is a plain stat the generator can roll; Unanswered, Eruption and Taut String each fit one Breakdown line ("Unanswered: +40 L5, the enemy has fired no art"); no player input anywhere |
| Counterplay | PASS | Bosses with top-end damage (rule 18 bosses); tribulation waves; reserved wards of 3,000+ points; the mirror |
| Originality | PASS | Names are composed from images (cloud, fork, needle, flint, banner, bowstring); no novel or game names, characters or techniques |

## Fight Results

Input: `first-volley.fight.json`. `fight_calc.py` observations under its drifted constants (expected values for chance), plus hand arithmetic from the GDDs as they stand on 2026-11-11. Neither is the game.

**`fight_calc.py`, as the file stands** (art speed +200 %, no opening haste: the volley comes at 1.333 s):

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | win | 1.333 s | never | L2, L3, L4 |
| typical | 1, 2 | win | 1.333 s | never | as above |
| top_end | 0 | **loss** | 1.000 s (the enemy's first basic attack) | 1.000 s | — |
| top_end | 1, 2 | **loss** | 1.000 s | 1.000 s | — |

**`fight_calc.py`, opening proxy** (a temporary copy with art speed +700 %, which puts every first firing at 0.500 s, as opening haste +250 % does; it also speeds later volleys, which never happen here):

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0, 1, 2 | win | 0.500 s | never | L2, L3, L4, `cooldown_min` |
| top_end | 0, 1, 2 | win | 0.500 s | never | as above |

The Breaker dealt 50 % of the volley against the typical profile (168,452 health). `--without unanswered` changes no result: the volley overkills, so Unanswered matters only against big pools and in floor ties. Second realm (Kết Đan, layers at about 3/4 of the anchors, volley at 0.8 s): wins at 0.800 s against every profile except top_end two realms up (loss at 1.000 s).

**Hand arithmetic (current rules).** Pools are guesses from the Formulas B W shares: build 6,118 health and 3,900 linh lực; typical 11,520 and 3,380 (557 points, drain 0.124 per point, block 40); top-end 22,400 and 4,030 (1,500 points, drain 0.0332, block 47, M 256, crits 50 % ×2, its opener c 4.0). Hits at the volley's M 228.3: the Breaker deals 94,745 before defence (×3 on a crit), a follower 53,650.

- Top-end, Breaker without a crit: it prevents 88,823 for a bill of 2,948, leaving the pool at 578 and dealing 5,875. Forked Light's bill (1,669) exceeds that, so 65 % of what it would prevent leaks: 36,191 dealt. Dead at 0.500 s before the last two hits.
- Floor tie against a top-end opener: its hit puts the build at an overkill share of 10.9 (27.6 on a crit); the volley puts it at 5.7 to over 20. Without a refusal the build wins about 41 % of ties; with Unyielding Breath, all of them.
- The volley costs 234 linh lực (First Move pays the Breaker); a reload volley costs 546; regeneration is 150 a pulse; each crit returns 49.

`first-volley.volley.py` (this folder) implements this arithmetic as a seeded timeline for the morning. **It was not run in this session**: the unattended sandbox only allows `fight_calc.py`. Treat its output as unverified until it is run once and compared with the numbers above.

**Unmodelled:** opening haste (proxied), First Move, Unyielding Breath, Final Clause, Flowing Water, linh lực on crit, Iron Spark's conversion, Lightning Step and Cold Feet, Eruption and Taut String (folded into one conditional), shields, and the post-#44 defence path (resistance points, drain on prevented points, leak, flat block) in `fight_calc`.

## New Concepts

**Opening timer (`opening_haste_pct`).** Rule: Combat rule 13 and Formulas A2. An art's first timer is `max(cooldown_min, cd_eff ÷ (1 + opening_haste_pct / 100))`; later firings are unchanged. Bounds: `cooldown_min`, so the race ends in floor ties settled by overkill share and refusals. Breakdown line: "Opening haste +250 %: first firing 0.500 s (floor; 0.381 s clipped)". Other builds: slow-thunder (long arts before the first basic attack), soul openers, Ám Đạo assassins, talisman openers. NPCs: the generator rolls it like art speed. Question for the user: adopt it, and price it at half of art speed?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Opening Haste `opening_haste_pct` | Needs rule | Combat rule 13, Formulas A2; Modifier System Stat List |
| Taut String | Needs rule | Depends on opening haste |
| Eruption | Needs rule | Effects rule 5 readable "arts you fired this instant" |
| Unanswered | Needs key | Confirm that the enemy's firings are readable (Effects rule 5) |
| Six arts | Needs key | Art records (no JSON format yet) |
| Lôi Đế Chân Kinh abilities | Needs key | Abilities field and the passive "Before the Sound" |
| Herald's Banner, Thunder-Gall Pill, Nine Rods Array | Needs key | Named item; a pill fight payload; a combat formation |
| Ringing Ground | Needs key | Tree catalogue ○ row |
| Lôi Đạo Thiểm Điện nodes | Needs key | `opening_haste_pct` in Lôi Đạo's `theme_stats`; the graph is not drawn |
| Drawn Bowstring | Needs key | Cluster idea for the tree rework |
