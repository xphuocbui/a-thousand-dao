# The Straw Effigy (Thảo Nhân Chú)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses.
> **Seed**: "Triggers can never be the main damage, but they apply statuses, curses and refunds that the damage budget does not count. A build whose triggers keep every curse slot full and whose main damage reads how cursed the target is."
> **Direction**: The Straw Effigy: every hit that lands sets off the Effigy's litany, which lays the next missing curse in a fixed order; every curse laid drives the Iron Nail closer; the Nail reads the stacks and lands on a target whose resistance the curses have already taken.
> **Realm span**: Kết Đan (Core Formation) to Nguyên Anh (Nascent Soul) · **Power level**: top-end · **Use**: player · **Kind**: min-max
> **Fit**: 6 Fits today · 13 Needs key · 3 Needs rule
> **Checks**: 6 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: no source gives the thần thức budget, and curses carry no lint charge today, so a curse payload is priced at 0; Stack: the identity test cannot run in `fight_calc.py` because Driven Nail is a timer move it does not model, and a hand paper model stands in; The fight: `fight_calc.py` reports CONSTANT_DRIFT on 31 of 60 constants and models the pre-#44 defence, and the engine is unmodelled)

## The seed meets the current rules

Four facts of the rules as they stand on 2026-11-11 decide this build.

- **Curses are three slots that change rules** (Combat rule 8, Formulas F: `curse_slots` 3, `curse_duration_max` 5
  pulses; a fourth curse pushes out the one with the least time left). A trigger may apply a status (Effects rule 6),
  and triggers are bounded only by `trig_cap` (6 a pulse), `trigger_depth` (2) and the damage budget, which a curse
  does not touch. So curses are the one thing triggers can deliver without limit worth naming.
- **Resistance is points with no floor** (Combat Defence & Healing Formulas A, decision 2026-11-10). Sundered is
  −150 points a stack to 3 on one damage type; Exposed −100 on all. Below 0 a part is amplified, `× (1 − R/100)`.
  Against a typical Nguyên Anh ward (557 points) three Sundered and one Exposed, plus 100 points of penetration,
  leave −93: a hit takes ×1.93 instead of ×0.15, thirteen times as much. Against a top-end ward (about 1,500) they
  leave 850 (×0.105 against ×0.0625). And once a drain ward's pool is gone, the kept 300 points become −350: ×4.5.
- **Two curses are defence.** Sealed Meridian makes one named layer count as 1.0 for 2 pulses (then a 2-pulse
  reapply lockout): on a top-end foe's L2 (×4.0) it cuts their hits to a quarter. Heavy Breath (+25 % a stack, to
  +50 %) makes their arts dearer, and costs are a share of maximum, so a big pool pays the same share.
- **Top-end fights last one or two seconds.** A top-end opener (M 256, a 1 s art at +100 % art speed) fires at
  0.5 s for about 10,000 against a 1,500-point ward. "Keep every slot full" must mean full by 1.0 s, and the curses
  must protect the caster while they fill.

## Directions considered

- **Chosen: The Straw Effigy (Thảo Nhân Chú).** A named effigy turns every landed hit into the next curse of a fixed
  litany; the main art reads curse stacks and is driven sooner by every curse laid. It is the strongest min-max
  reading because its curses are offence (resistance), defence (a layer lock) and starvation (cost raise) at once,
  and the triggers that lay them are the part of a build the damage budget never counts.
- **Not chosen: The Ledger of Debts (Nghiệp Trướng).** Curses as debts: each curse that runs its full length on the
  target pays out a Nhân Quả "settlement" hit. Elegant in a 30 s fight, useless at the top end, where fights end
  before a 3-pulse curse expires.
- **Not chosen (the surprise): The Willing Vessel (Cam Thụ).** A build that wants to be cursed: each curse on you
  feeds your damage, and you hand them back. It only works against foes who curse, so it is one matchup, not a build.

## The Spine

- **The channel:** art hits, Physical, L1 to L5, no crit. The Iron Nail is the main damage; Slipper Blow, Straw
  Binding and the basic attack are trigger sources whose own hits matter only once the board is full. The real
  multiplier sits outside M, in the defender's resistance, which the curses take away. L5 is a Per (Weight of Names).
- **The enabler:** the Petty-Man Effigy (Tiểu Nhân Hình Nhân), a named artifact. Every hit of yours that lands lays
  the first curse of its litany the target lacks. It closes: a curse of yours that the enemy cleanses lands on you,
  with the time it had left (Backlash, Phản Phệ).
- **The loop:** two cheap quick arts and the basic attack hit three to five times a second; each hit lays a curse
  by its own payload and another by the litany; the litany fills Sealed Meridian, Sundered ×3, Exposed (and Heavy
  Breath at Nguyên Anh) in order; once every name is on, it refreshes the one with the least time left.
- **The engine:** Driven Nail. Every curse laid moves the Iron Nail's timer 0.5 s closer (3 times a pulse). The same
  blows that fill the board bring the Nail; the Nail fires in the follow-up instant of the millisecond the board
  completes, reads the stacks (Weight of Names), and its bill on the enemy's drain ward empties their pool.
- **The sacrifice:** no crit, no answer to a foe who acts first, and nothing against a cleanser except its own
  cleanse: Backlash turns a purifier's cleanse into your curse. It refuses to fix the alpha strike that opens the
  fight, and it does not fight well without hits that land (evasion, status resistance).
- **The arc:** at Kết Đan a needle-and-straw curser with three names; late Kết Đan the Way of Death (Diệt) teaches
  the nail to come when called; at Nguyên Anh the Fourth Nail opens a fourth curse slot, and Heavy Breath starves
  even a boss's pool.

## The Legend

Under the old stone bridges of the river towns there have always been women who beat paper men for hire. You bring
them a name, they write it on a cut-paper figure, and they strike it with a worn cloth slipper while they chant: beat
his mouth so he cannot lie, beat his hands so he cannot steal. Most of them are mortals and the custom is harmless.
One of them, a ferry-keeper's widow whose name the river towns no longer agree on, beat effigies under the same
bridge for forty years, and somewhere in the third decade the beatings began to land.

The Straw-Man Litany Scripture is what a wandering cultivator copied from her when he found her dead under the bridge,
her slippers worn through and a last effigy of black paper in her lap with nine iron nails in it. It is not a manual
of power. It is a manual of order: the first name you write must bind the hand, the second must open the skin, the
third must strip the cloak, and only then do you drive the nail. The widow's last page says plainly that she died the
night a travelling monk washed her curses off a merchant, and every one of them came home.

The purifying schools of Light hate this path and say so. Their monks cleanse its curses on sight and call it a just
death when the curses find their maker. The path's walkers answer that a cleanse is only a slipper beaten the other
way, and carry a little ash of their own.

## How It Fights

Half a second in, a slipper blow lands and the enemy's hand goes numb: Sealed Meridian locks their art "more", so the
opener they fire in the same instant hits a quarter as hard. The cord binds and the skin opens, Sundered and Exposed,
and by the second blow the Effigy has nothing left to write. Every one of those blows has been driving the nail. At
1.0 s, in the follow-up instant after the board completes, the Iron Nail lands on a target with seven curse stacks
and 650 points of resistance gone, and their drain ward pays for it with nearly everything they had left. At 1.5 s
their opener costs half again what it should, they cannot pay it, and the next straw cord finds no ward at all.

**The signature moment:** the Iron Nail fires in a follow-up instant at exactly 1.000 s, the same millisecond the
fourth name went on, and the enemy's linh lực bar drops from half to nothing on one hit.

## Enabler

**The Petty-Man Effigy (Tiểu Nhân Hình Nhân)**, a named artifact on a new utility base, `hinh_nhan` (a cut-paper or
straw figure). A player finds it as an event reward under a bridge shrine in a river town (the widow's last effigy),
or buys a lesser copy from a curse-seller at a night market.

- **Opens (the Litany, Chú Văn):** "When one of your hits lands, it lays the first curse of the Effigy's litany that
  the target lacks or holds below its stack cap, skipping any curse in a reapply lockout; if every name is on, it
  refreshes the one with the least time left." The litany is three curses written on the Effigy in preparation (four
  with the Fourth Nail), saved for blind fights. A Sundered it lays is on the damage type the Effigy names
  (Physical). A Sealed Meridian names a layer (L2 by default). Trigger limits apply (`trig_cap`, `trigger_depth`).
- **Closes (Backlash, Phản Phệ):** "When a curse of yours is cleansed from the target, it is placed on you with the
  time it had left." A purifier's cleanse becomes your Sealed Meridian on your L2 and your Sundered on your Physical
  resistance.
- **Kind:** loop opener and free channel: curses without art slots, lint or cost.

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Iron Nail coefficient | c 4.65 at cost 0.10, cooldown 6 s (the current lint exactly) | Flat base | art hit | none | ○ | Technique art | — |
| 2 Rate | **Driven Nail (Đóng Đinh)** | Each curse you lay on the target (new, a stack or a refresh, any source) shortens your longest-cooldown art's timer by 0.5 s; 3 times a pulse; never sooner than `cooldown_min` after its last firing | Timing (trigger) | art hit | none | ○ | Sinh Tử Đạo, Diệt facet (`major`) | Rime Lock and Ice builds with a slow finisher; status-collector; dry-well's blades |
| 2 Rate | Art speed [curse] (`art_speed_pct`, mode: curse) | +20 % a notable; puts the 1 s curse arts at the 0.5 s floor | Increased | art hit | none | ◐ | Diệt facet stat lines, tree | any curse kit |
| 3 L1 | Damage [physical] (`attack_pct`) and tree W | about 330 points at Nguyên Anh | Increased | art, basic | L1 | ● / ◐ | Tree, technique bonus | any Physical build |
| 3 L2 | Nail Into Straw (Đinh Nhập Thảo) | `damage_more` +60 [kim] | More | art hit | L2 | ○ (key designed) | Technique passive, layer 2 | any Metal art build |
| 3 L2 | Tolled Seal (Chung Ấn) | `damage_more` +40 [seal] | More | art hit | L2 | ○ (reused, content ledger) | Nine Knots cluster, far notable | Ninth Bell |
| 3 L2 | Diệt notables | `damage_more` +40 [physical] ×2, +40 [seal] ×1 | More | art hit | L2 | ○ (key designed) | Diệt facet | any Physical build |
| 3 L3 | Gear | Cực phẩm `cham` needles, top-end L3 150 | Flat | all hits | L3 | ● | Artifact | — |
| 3 L4 | Ringing Ground (Hưởng Địa) | +80 [art], prepared | More | art hit | L4 | ○ (reused, staging) | Nine Rods Array | Ninth Bell, first-volley, dry-well |
| 3 L4 | Insect-Waking Incense (Kinh Trập Hương) | +70 [seal], prepared | More | art hit | L4 | ○ | Pill-incense | any seal build |
| 3 L5 | **Weight of Names (Danh Trọng)** | Your hits deal more for each curse stack of yours on the target: L5 +10 a stack, cap +80 (read at instant start) | Per (Effect) | art, basic | L5 | ○ | Technique passive, layer 7 (`major`) | dry-well (Leaking Seal), soul-lance (Slackened Soul), any curse kit |
| 3 L5 | Marked Prey (Tiêu Ký) | L5 +4 per distinct status of yours on the target, cap +16 | Scaling (Effect) | all hits | L5 | ● (designed) | Diệt facet `minor` | curse, poison, companion |
| 4 Certainty | None: no crit | The Nail cannot crit; its "crit" is the curses' resistance cut | Sacrifice | — | — | — | — | — |
| 5 Reach | Sundered ×3, Exposed (by the litany) | −450 Physical, −100 all, in points; below 0 amplifies | Curse | all hits | (defence path) | ● (designed) | Effigy litany, arts' payloads | every hit build |
| 5 Reach | Penetration [physical] (`resist_pen_pct`) | +100 points a notable | Flat | all hits | none | ◐ | Tree | any Physical build |
| 5 Reach | **Deeper Nails (Đinh Sâu)**, `curse_effect_pct` | +4 % small, +25 % notable to your curses' numbers (Sundered −150 → −187.5 at +25 %); clipped by each curse's own max | Increased | all hits (via curses) | none | ○ | Nine Knots cluster, Diệt lines | dry-well, first-volley (Leaking Ward), soul-lance (Slackened Soul) |
| 5 Reach | Accuracy (`accuracy_pct`) | +16 a notable: an evaded hit lays nothing | Flat | all hits | none | ◐ | Tree | any hit build |
| 6 Past the cap | **The Fourth Nail (Đệ Tứ Đinh)** | Your curses may fill one more slot on a target (`curse_slots` +1 for your curses). Closes: curses on you last twice as long (`status_duration_taken_pct` +100, scoped curse) | Cap shift (keystone) | all hits | none | ○ | Diệt facet keystone (Nguyên Anh) | any curse kit |
| 7 Fuel | Paid in Nails (Đinh Trả) | When your longest-cooldown art lands on a target bearing every curse of your litany, refund its cost | Trigger (Effect) | art | none | ○ | Technique passive, layer 10 (`minor`) | dry-well (Leaking Seal), any curse finisher |
| 7 Fuel | Art cost [curse] (`art_cost_pct`) | −20 % a notable | Increased | art | none | ◐ | Diệt lines, tree | any curse kit |
| 7 Fuel | Linh lực on hit (`linh_luc_on_hit_pct`) | +0.19 pp a notable, 3–5 hits a second | Flat | all hits | none | ◐ | Tree | any many-hit build |
| 8 Survival | Sealed Meridian (L2), Heavy Breath, Withering (by the litany) | Their art "more" counts 1.0; their arts cost +50 %; healing taken −50 % | Curse | — | — | ● (designed) | Effigy litany | — |
| 8 Survival | Blood Drinker (Ẩm Huyết) | 6 % of direct damage dealt restores health | Trigger (Effect) | art, basic | none | ● (designed) | Item (the Effigy's second line) | sword, body, beast |
| 8 Survival | Status duration [curse] (key Pending) | +26.6 % a notable: curses outlast refreshes, more surplus blows | Increased | curses | none | ◐ (Pending) | Nine Knots cluster | any curse kit |
| 9 Identity | **Driven Nail** | (rung 2) | Timing | art hit | none | ○ | Diệt facet | as above |

**Identity piece:** Driven Nail. The litany fills the board, Weight of Names makes the board count, but Driven Nail
is what turns the trigger stream (which can never be damage) into the main art's rate: the Nail fires at 1.0 s
instead of 3.0 s, and every 1.2 s after instead of 3.0 s. In the paper model, without it the build still wins the
top-end mirror at Nguyên Anh, but at 2.0 s with about 3 % health instead of 1.5 s with 70 %.
**Empty rungs:** crit (a sacrifice: the build is deterministic against a foe with no status resistance). No
conversion (Sundered names one type, so splitting the Nail would halve the curse's reach).

| Layer | Points at Nguyên Anh (the Nail, foreseen, full board) | Multiplier | Sources |
|---|---|---|---|
| L1 | 330 (counts 265 past the knee) | ×3.65 | Tree W, technique `attack_pct` 15, [physical] notables |
| L2 | 220 | ×3.20 | Nail Into Straw 60, Tolled Seal 40, Diệt notables 120 |
| L3 | 150 | ×2.50 | Top-end gear |
| L4 | 150 (blind: 0) | ×2.50 | Ringing Ground 80, Insect-Waking Incense 70 |
| L5 | 86 (7 stacks, 4 curses) | ×1.86 | Weight of Names 70, Marked Prey 16 |
| **M** | | **135.8** (blind 54.3) | Below the top-end anchor 256 (and its expected crit ×1.5): the build's power is in the defence path, not M |

At Kết Đan: L1 250 (×3.25 with the knee at 200: 225), L2 180, L3 150, L4 150, L5 62 (5 stacks, 3 curses): M about 98.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Dual Metal–Wood (Kim–Mộc), Metal the higher, purity 60+ | Metal overcomes Wood: the nail through the straw. The arts are [kim] (Nail Into Straw scope) and Straw Binding [moc]. The build uses no element stacks, so purity matters only for technique speed |
| Key talents | Root bone (căn cốt), Comprehension (ngộ tính) | Căn cốt for health and flesh block: the build must stand two openers under Sealed Meridian. Ngộ tính to reach layers 7 and 10 (Weight of Names, Paid in Nails) by mid Kết Đan |
| The Way (Đạo) | Sinh Tử Đạo · *Sinh Diệt*, facet Diệt (Death: curses, withering) | Driven Nail (`major`), the Fourth Nail (facet keystone), Marked Prey (`minor`), stat lines art speed and cost [curse], `curse_effect_pct`, `damage_more` notables. Needs: none |

## Công Pháp

### Straw-Man Litany Scripture (Thảo Nhân Chú Kinh) — main, Địa giai (tier 2)

A widow's chant written down by a stranger: first bind the hand, then open the skin, then strip the cloak, then drive the nail.

```json
{"id": "thao_nhan_chu_kinh", "name": "Thảo Nhân Chú Kinh", "tier": 2, "tech_kind": "main",
 "names": ["kim", "moc"], "layers": 12,
 "bonuses": [{"stat": "attack_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 20}, {"stat": "khi_huyet_pct", "value": 15}],
 "abilities": [{"ability_id": "da_hai_chuong", "unlock_layer": 1},
               {"ability_id": "dinh_nhap_thao", "unlock_layer": 2},
               {"ability_id": "thao_phuoc", "unlock_layer": 3},
               {"ability_id": "thiet_dinh", "unlock_layer": 5},
               {"ability_id": "danh_trong", "unlock_layer": 7},
               {"ability_id": "hinh_nhan_tro", "unlock_layer": 9},
               {"ability_id": "dinh_tra", "unlock_layer": 10},
               {"ability_id": "chi_thuyen_do", "unlock_layer": 11},
               {"ability_id": "phan_chi_tien", "unlock_layer": 12}],
 "seal_clusters": ["cuu_ket"], "origin": "authored"}
```

**Fit:** Needs key (combat passives and ability records have no field in `items_cong_phap.json` yet) · **Budget:**
15/15 + 20/20 + 15/15 = **3.0 of 3.0** (Địa giai), each 1.0 ≤ `bonus_single_cap` 1.5. `max_realm` nguyen_anh reaches
the span. The passives (Nail Into Straw, Weight of Names, Paid in Nails) are outside `bonus_pool` and the budget.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Iron Nail (Thiết Đinh) | Scripture, 5 | Physical hit; kim, physical, seal, art, costly | 4.65 | 0.10 | 6 s | Enemy has the litany's last curse (default Exposed; Heavy Breath at Nguyên Anh) | Needs key |
| Slipper Blow (Đả Hài Chưởng) | Scripture, 1 | Physical hit; kim, physical, palm, curse, art, quick, cheap | 1.48 | 0.02 | 1 s | — | Needs key |
| Straw Binding (Thảo Phược) | Scripture, 3 | Physical hit; moc, physical, curse, art, quick, cheap | 1.48 | 0.02 | 1 s | — | Needs key |
| Ash of the Effigy (Hình Nhân Tro) | Scripture, 9 | Cleanse; cleanse, curse, art | — | 0.03 | 3 s | Own status Sealed Meridian | Needs key |
| Paper Boat Crossing (Chỉ Thuyền Độ) | Scripture, 11 | Escape; escape, art | — | 0.05 | 4 s | Own health at or below 30 % | Needs key |
| Paper Money Burning (Phần Chỉ Tiền) | Scripture, 12 | Heal; moc, heal, art | c_heal 4.13 (heal lint 1.4 × 2.95) | 0.05 | 4 s | Own health at or below 70 % | Needs key |

- **Iron Nail. Effect:** hit. Slot 1, so it pays first in a shared instant; its guard makes it wait for a full board
  and fire in the follow-up instant when the last name goes on (Combat rule 10). **Description:** the ninth nail of
  the widow's last effigy, driven through the paper heart.
- **Slipper Blow. Effect:** hit; applies Sundered (one stack, on its own largest part: Physical). Each landing also
  sets off the litany. **Description:** a cloth slipper, worn through, that has struck ten thousand paper mouths.
- **Straw Binding. Effect:** hit; applies Exposed. **Description:** seven cords knotted round a straw waist; the
  knots are names.
- **Ash of the Effigy. Effect:** cleanse every curse with the `curse` cleanse tag from its owner. The answer to
  Backlash. **Description:** burn a little of your own effigy and the curses forget whose they were.
- **Paper Boat Crossing. Effect:** escape (Combat Formulas I). **Description:** a folded paper boat set on any water.
- **Paper Money Burning. Effect:** heal (Combat Defence & Healing Formulas E), refunding its cost when it heals (rule
  16). **Description:** burnt offerings for the dead, and the smoke remembers the living.

**Lint note:** the curse each quick art applies is free in today's lint (curses carry no charge). dry-well's suggestion
"Charge curses and non-element statuses in the art lint" would cut both quick arts' coefficients; the build does not
depend on their damage, so it would lose little.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Kết Đan, early | 5 | Iron Nail, Slipper Blow, Straw Binding, (empty), (empty) | Common Ward + Mountain Screen | Litany: Sealed Meridian (L2), Sundered, Exposed. No Driven Nail yet: the Nail at 3.0 s |
| Kết Đan, late | 5 | Iron Nail, Slipper Blow, Straw Binding, Ash of the Effigy, Paper Boat Crossing | as above | Diệt facet reached: Driven Nail; the Nail at 1.0 s |
| Nguyên Anh | 6 | Iron Nail, Slipper Blow, Straw Binding, Ash of the Effigy, Paper Money Burning, Paper Boat Crossing | as above, ws higher | The Fourth Nail: litany Sealed Meridian (L2), Sundered, Exposed, Heavy Breath. Iron Nail's guard moves to Heavy Breath |

Litany swaps for foreseen fights: Withering for Heavy Breath against a healer; Leaking Ward against a drain-ward
tank with a deep pool; Sealed Meridian on L5 instead of L2 against a foe whose damage is a condition.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Petty-Man Effigy (Tiểu Nhân Hình Nhân) | Named artifact, utility | new base `hinh_nhan` (attack 0, defence 10, thần thức 20, first guess), Cực phẩm, realm tier of the finder | The enabler (Litany, Backlash); second authored line Blood Drinker | Needs rule |
| Coffin-Nail Needles (Quan Đinh Châm) | Artifact, weapon | `cham`, Cực phẩm, affix Liệt (`artifact_attack_pct`) | L3. A generated weapon with authored flavour: nine iron nails taken from a pauper's coffin lid | Fits today |
| Ward gear | Artifact, ward | `chuong`, Thượng–Cực phẩm, affix Kiên | Ward strength: the build must stand two openers | Fits today |
| Body gear | Artifact, body | `giap`, Thượng phẩm, affix Hộ Thân | Health, block | Fits today |
| Insect-Waking Incense (Kinh Trập Hương) | Pill-incense, preparation (foreseen, ambush) | — | L4 `damage_more` +70 [seal] for one fight; pill toxicity as its recipe sets | Needs key |
| Nine Rods Array (Cửu Can Trận) | Formation, preparation (foreseen) | — | Ringing Ground +80 L4 on art hits (reused from first-volley and dry-well) | Needs key |

Four artifacts of `equip.max_slots` 6. **Insect-Waking Incense:** burnt at the Waking of Insects, when the river
towns beat their paper men; its smoke makes every seal heavier.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Art speed (universal, [curse]) to +100 % | +13.3 / +20 notables | The quick arts at the 0.5 s floor: the trigger stream is the engine's fuel | Fits today (designed) |
| 2 | Damage [physical], tree W | to about 330 L1 | Everyday stack | Fits today |
| 3 | Penetration [physical] | +100 notable | 100 more points under the curses: past 0, each point is +1 % damage taken | Fits today (designed) |
| 4 | Accuracy | +16 notable | An evaded hit lays nothing and moves no nail | Fits today (designed) |
| 5 | Nine Knots cluster | see below | Curse effect, status duration, Tolled Seal | Needs key |
| 6 | Linh lực on hit, art cost [curse] | +0.19 pp, −20 % | Fuel for 3–5 hits a second | Fits today (designed) |
| 7 | Health, root bone | — | Two openers under Sealed Meridian | Fits today |

**When to stop:** art speed at +100 % (the 1 s arts reach `cooldown_min`; the Nail does not need more, Driven Nail
moves it). L5 stops at 100: Weight of Names 80 plus Marked Prey 16 is 96, so nothing else in L5. Penetration has no
cap, and below 0 each point is worth as much as the last: keep taking it after the others stop. `curse_effect_pct`
stops mattering on Heavy Breath, Leaking Ward and Withering (their own maxima), so value it only for Sundered and
Exposed.

### Hidden cluster idea: Nine Knots (Cửu Kết)

Theme: binding and curses, wider than one build (any curse kit, seal arts). Element affinity Metal. Kind: sealed.
Seal: the Straw-Man Litany Scripture lists it in `seal_clusters`. Size 9 acupoints. Smalls: `curse_effect_pct` +4
(×2), `art_speed_pct` [curse] +3 (×2), `art_cost_pct` [curse] −3, status duration [curse] +4 (×2). Notables:
`curse_effect_pct` +25, and farthest, Tolled Seal (`damage_more` +40 [seal], reused from the content ledger). No
capability. An idea for the tree rework, not data.

## Đạo

Uses **Sinh Tử Đạo** · *Sinh Diệt*, facet **Diệt (Death: curses, withering)**, from the catalogue (dao.md § Catalogue,
row 27). This session did not read `design/dao-ways/` (outside its scope), so the nodes wanted are named, not placed:

- Stat lines on the way in: `art_speed_pct` [curse], `art_cost_pct` [curse], `curse_effect_pct` (needs the key in
  the Way's `theme_stats`), `damage_more` notables +40 [physical] ×2 and +40 [seal].
- `minor`: Marked Prey (existing, Way host).
- `major`: Driven Nail.
- Facet keystone at the far end: the Fourth Nail (Nguyên Anh), whose close (curses on you last twice as long) is the
  Way's warning about Backlash.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Kết Đan, early | Three names, a slow nail at 3 s; wins on curses alone against ordinary foes | The Effigy, Scripture to layer 5 | The widow's bridge; the first paper man that bled |
| Kết Đan, late | The nail comes when called: 1.0 s, every 1.2 s after | Driven Nail (Diệt facet), Weight of Names (layer 7), Ash of the Effigy | A purifier washes your curses off a rival, and you learn what Backlash is |
| Nguyên Anh | Four names; their pool fails under Heavy Breath and the Nail's bill | The Fourth Nail, Paid in Nails, Paper Money Burning | Every curse on you now lasts twice as long: the price of the fourth nail |

## Matchups

Paper model at Nguyên Anh unless stated (see Fight Results).

| Enemy | Result | Why |
|---|---|---|
| Typical cultivator (rule 18 ordinary) | wins, 0.5–1.0 s | Resistance 557 falls below 0 after two blows: ×1.93 instead of ×0.15 |
| Top-end alpha peer (opener at 0.5 s, M 256) | wins, 1.5 s, about 70 % health | Sealed Meridian on their L2 from 0.5 s; the Nail at 1.0 s empties their pool; Heavy Breath makes their 1.5 s opener unaffordable |
| Boss (top-end, `boss_pool_mult` 10) | wins, about 3–3.5 s | Costs are shares of a ×10 pool, so Heavy Breath drains it as fast; then the ward falls to −350 points |
| Healer (rule 18) | wins | Withering in the litany halves their healing |
| Drain-ward tank, deep pool | wins | The Nail's bill is the drain; Leaking Ward in the litany if needed |
| Body cultivator (thể tu), no ward | even | No pool to starve; Sundered still cuts Physical resistance, but body shields soak Physical hits |
| Cleanser (Quang Đạo Tịnh, a cleanse art) | even to loses | Backlash: their cleanse puts your Sealed Meridian on your L2 (Nail ×3.2 → ×1); Ash of the Effigy answers once per 1.5 s |
| 50 % status resistance or 40 % evade | even against a top-end peer | Each curse lands half the time or each hit lays nothing 40 % of the time: the board fills at 1.5–2.0 s, after their openers |
| An alpha striker who opens the fight (first-volley, ambush) | loses | Their hits come first in the 0.5 s instant, before Sealed Meridian is on; a top-end volley ends it there |

**Counter:** the alpha striker who opens the fight. Combat rule 10 resolves the requesting side's hits first, so a
first-volley build that ambushes this one lands its whole 0.5 s volley before the first curse. Second: the purifier,
a Light-Way cultivator with status resistance and a cleanse art, who turns Backlash on its maker.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 3.0 of 3.0, singles 1.0 ≤ 1.5: pass. Arts at the current lint exactly (Slipper and Straw 1.48 at 0.02/1 s; Nail 4.65 at 0.10/6 s; heal 4.13 ≤ 1.4 × 2.95). Slots 5/5 Kết Đan, 6/6 Nguyên Anh. Artifacts 4 of `equip.max_slots` 6. Not assessed: no source gives the thần thức budget for four pieces, and the curse payloads cost nothing in today's lint (dry-well's suggestion would price them). `fight_calc.py` flags all three arts OVER because it still uses the pre-#44 12-per-cost lint |
| Validity | PASS | Elements `kim`, `moc`; tier `dia` (max_realm nguyen_anh) reaches the span; bases `cham`, `chuong`, `giap` exist; `hinh_nhan` is new (Needs key, listed); realms ket_dan, nguyen_anh; curses and Effects reused by their catalogue names. No aux technique, so no harmony check |
| Stack | NOT ASSESSED | Ladder: every rung filled except crit (a sacrifice). Forms: Increased, More, Flat, Per, Trigger, Timing, Cap shift (7). No modifier targets an unused channel (L5 only on hits). Layer totals above; none empty in a foreseen fight, L4 empty when blind (M 135.8 → 54.3). Identity test: `fight_calc.py` cannot move a timer, so removing Driven Nail there changes nothing by construction. The hand paper model shows it changes the fight (1.5 s at 70 % → 2.0 s at about 3 %); `--without weight_of_names` in `fight_calc.py` does change the result (the top-end peer is left at 50 % instead of a double knockout) |
| Scaling | PASS | `m_static` 9.12 (L1 and L3 only; the calc keeps tagged layers out). The Nail's M 135.8 is below the top-end anchor 256 and has no crit, but its curses take 650 points off the defender: against the typical ward that is ×12.7, against the top-end ward ×1.76, and against an emptied drain ward ×4.5 on every hit. INFO: in the paper model it beats the top-end anchor profile at both realms, so it sits above the anchors in practice. Not pulled back (only macro targets matter) |
| The fight | NOT ASSESSED | `fight_calc.py` reports CONSTANT_DRIFT (29 of 60 constants verified) and models the pre-#44 defence; the engine (Driven Nail, the litany, Sealed Meridian, curses in points) is unmodelled. Its observations are below for the record. The hand paper model is the evidence used. No `cap_hit` lines in the calc; in the paper model the cap that binds is Driven Nail's 3 a pulse |
| Reuse | PASS | Reused: Tolled Seal (content ledger), Ringing Ground via the Nine Rods Array (staging), Marked Prey and Blood Drinker (Effects GDD), art speed and cost [curse], status duration [curse], penetration, accuracy, linh lực on hit (Modifier System), the staged cleansed-stacks event (extended to curses). Second homes named for every new modifier and Effect; no signature modifiers (the Effigy is the enabler) |
| NPC use | PASS | The litany is a fixed order with no player input; the generator writes a default (Sealed Meridian L2, Sundered, Exposed) and swaps by its foe tag when foreseen. Each new piece has a one-line Breakdown: "Driven Nail: Iron Nail −0.5 s (Sundered laid)", "Weight of Names: +70 (7 curse stacks)", "Backlash: Sealed Meridian returned to you (1 pulse left)" |
| Counterplay | PASS | Rule 18 types: the alpha striker who opens the fight (requesting side's hits first) wins; the purifier (cleanse, status resistance) makes Backlash the build's own death; a 40 % evade foe slows the board past the top-end openers |
| Originality | PASS | The beating of paper "petty men" is a public folk custom, not anyone's IP; no novel or game names. All names are new working titles |

## Fight Results

**Formal input:** `curse-engine.fight.json` (Nguyên Anh) and `curse-engine.ket-dan.fight.json`, run with
`fight_calc.py --matrix`. Observations, pre-#44 model, not a verdict:

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical, Nguyên Anh | 0 | win | 0.500 s | never | none |
| typical | 1 | win | 1.000 s | never | none |
| typical | 2 | win | 1.500 s | never | none |
| top_end, Nguyên Anh | 0 | loss (double knockout, overkill) | 1.000 s | 1.000 s | none |
| top_end | 1, 2 | loss | 1.000 s | 1.000 s | none |
| typical, Kết Đan | 0 / 1 / 2 | win / win / loss | 0.5 / 1.0 / 1.0 s | — | none |
| top_end, Kết Đan | 0 / 1 / 2 | loss (0: double knockout) | 1.000 s | — | none |

`--without effigy` changes almost nothing there (the arts' own curses already fill the old model's slots), and
`--without weight_of_names` leaves the top-end peer at 50 % health instead of a double knockout. The losses to top_end
are the losses the paper model predicts **without Sealed Meridian**, which the calc cannot express; the Nail never
fires (3.0 s cooldown, no timer moves).

**Paper model (hand arithmetic, current GDDs, expected values for crits, ±20 %).** Combat rule 10 instants (the
player opens the fight), Formulas A–C, E; Combat Defence & Healing Formulas A (points), A2 (block), C (drain bill on
prevented damage). Profiles: the top-end peer from first-volley's script (health 22,400, linh lực 4,030, R 1,500 of
which 300 kept, drain rate 0.0332 a point, M 256, 50 % crits ×2, opener c 4.0 at 0.125 every 0.5 s, main art at
2.0 s); the build at Nguyên Anh: health 19,200, linh lực 3,900, R 1,400.

| Scenario | Result | Time | Own health at end | What decides it |
|---|---|---|---|---|
| Nguyên Anh, top-end peer, full build | win | 1.5 s | about 70 % | Board full at 1.0 s; the Nail in the follow-up instant (D 63,150, 6,600 dealt, bill 1,876: their pool 2,016 → 140); their 1.5 s opener costs 756 under Heavy Breath and cannot fire; Straw Binding at R −350 deals ×4.5 |
| … without Driven Nail | win | 2.0 s | about 3 % (1 health on an overkill win if their 2.0 s opener crits) | The Nail waits to 3.0 s; Sealed Meridian ends at the 2.0 s pulse and their unprotected opener lands in the instant that kills them |
| … without Weight of Names | win | 2.0 s | about 43 % | The Nail bills 1,170, not 1,876; Heavy Breath still starves them by 2.0 s |
| … without the Effigy | loss | 1.0 s | 0 | No Sealed Meridian, no Heavy Breath: their opener at full M deals about 10,240 every 0.5 s (fight_calc agrees) |
| Kết Đan, top-end peer, full build | win | 1.5 s | about 59 % | The same shape with three names; no Heavy Breath, but the Nail's bill leaves them 283, and 1.5 s empties it |
| … without Driven Nail | double knockout, won on overkill share | 2.0 s | 1 health | Their unprotected 2.0 s opener and main art land in the instant the Straw Binding kills them |
| Typical, either realm | win | 0.5–1.0 s | above 90 % | Two blows put the typical ward below 0 |
| Boss, Nguyên Anh, ×10 pools | win | about 3–3.5 s | about 40 % | Heavy Breath costs are shares of a ×10 pool; dry near 2.5–3 s, then any hit at ×4.5. Under rule 18's 4 s floor for an ordinary boss: INFO |
| Enemy opens the fight (top-end peer) | win | 1.5 s | about 35 % | One unprotected opener at 0.5 s before Sealed Meridian |
| Enemy opens the fight (first-volley build) | loss | 0.5 s | 0 | Its whole volley lands before the first curse |

**Unmodelled (in `fight_calc.py`):** Driven Nail; the litany (approximated by fixed-curse triggers); Sealed Meridian;
curses as resistance points (mapped to the old shred and pass raise); Weight of Names by stacks (mapped to count);
the Fourth Nail; Backlash and Ash of the Effigy; Paid in Nails' condition; Blood Drinker; linh lực on hit; the heal
and escape arts; the current art lint. **Unmodelled in the paper model:** shields, the build's own drain bill exactly,
crit variance beyond expected values, a cleansing enemy (described in Matchups, not computed).

## New Concepts

None beyond rule changes listed below. The build reuses the staged event "stacks removed by a cleanse" (two-clocks)
and extends it to curses.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Petty-Man Effigy (Litany, Backlash) | Needs rule | effects.md rule 5: the event "your curse was cleansed from the target" (the staged cleansed-stacks event, extended to curses), and reading a reapply lockout as "cannot be placed now"; a new artifact base `hinh_nhan` in `items_artifacts.json` |
| The Fourth Nail | Needs rule | combat.md Formulas F: an Effect may raise `curse_slots` for its owner's curses on a target, by at most 1; `status_duration_taken_pct` (Pending) for its close |
| Diệt facet pieces | Needs rule | via the Fourth Nail; `curse_effect_pct` in Sinh Tử Đạo's `theme_stats` |
| Deeper Nails, `curse_effect_pct` | Needs key | modifiers.md Stat List (Combat: offence, status family): op I, target own curses, each curse's own max still clips |
| Straw-Man Litany Scripture | Needs key | ability and passive fields in `items_cong_phap.json` |
| Six arts | Needs key | art records (no JSON format yet) |
| Insect-Waking Incense | Needs key | a pill's fight payload (as Thunder-Gall Pill) |
| Nine Knots cluster | Needs key | `curse_effect_pct`, status duration [curse] (Pending) |
| Tolled Seal, Nine Rods Array | Needs key | as their own rows (reused) |
| Curse timing | Clarification | combat.md rule 10, "a status or curse applied between pulses first counts at the next one": the build reads it as the duration waiting, the rule applying at once. Sealed Meridian protecting in the 0.5 s instant depends on it |
