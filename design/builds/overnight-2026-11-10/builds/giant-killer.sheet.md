# The Needle Under the Mountain (Sơn Hạ Châm)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: "Built to fight upward: pierce to pierce_cap, suppression answered, damage that reads the gap between
> realms. Weak against equals, deadly against the realm above. The player's tool for punching above their weight."
> **Direction**: Half a Realm (Bán Cảnh): every pressure of the realm above gets one answer, and the fight-unit gap
> itself is halved.
> **Realm span**: Qi Refining to Deity Transformation, always fighting one realm up · **Power level**: top-end · **Use**: player
> **Fit**: 6 Fits today · 8 Needs key · 4 Needs rule (new pieces only; reused pieces keep their own labels)
> **Checks**: 8 PASS · 0 FAIL · 2 NOT ASSESSED (The fight and the identity test: no simulator this run, user decision 2026-11-11)

## Directions considered

**Chosen: Half a Realm (Bán Cảnh).** A stack in which each piece answers one named pressure of the realm above:
pierce for suppression, soul resistance for the thần thức gap, accuracy for the realm evade step, a per-hit ward
for heavy hits, an L5 that exists only upward, and one rule-swap enabler that halves the fight-unit gap from both
ends. It answers the whole seed: pierce to the cap, suppression answered, damage that reads the gap, and weak
against equals by construction (its L5 and its enabler both turn off against equals).

**Not picked: The Ledger of Insults (Nhục Trướng).** An overflow that banks what suppression strips from your hits
and pays it back as free hits. Combat Formulas G caps trigger damage at half the direct damage since the last
pulse, and suppression takes only 10 % one realm up, so the bank is tiny exactly where the build lives.

**Not picked: The Tribulation-Eater (Thực Kiếp).** A Kiếp Đạo build tuned to Thiên Kiếp waves, where the player is
always one realm below (thien-kiep.md rule 6). The step table holds one row today (Nascent Soul to Deity
Transformation), so it would be a build for one fight in a life.

**Not picked: The Unkneeling Soul (Bất Quỳ Hồn).** A soul build that borrows the enemy's thần thức. Upward,
rho starts near 0.3 (M_ts 1/3/10/30/100), so every soul art does about 0.5 % a hit. Bending that needs a rule
on the soul formula itself, and soul ignores every layer, so the build would be one stat.

## The Spine

- **The channel:** art hit, Physical with the Metal (Kim) element, few and heavy. Uses L1 to L5; L5 is filled only
  against a foe above you. Caps that matter: `pierce_cap` 0.75, L5's cap 100, `crit_chance_cap` 0.5.
- **The enabler:** Half a Realm (Bán Cảnh), on the Iron Pestle Scripture at layer 1. Against a foe one or two
  major realms above you, both sides' hits and ticks are struck as if the gap were half a realm narrower: yours at
  your fight unit × 1.585, theirs at their fight unit ÷ 1.585 (1.585 = √2.512, half a realm's step). It closes:
  against a foe of your realm or below, your hits are struck at your fight unit ÷ 1.26 (a quarter realm down).
- **The loop:** Bearing the Mountain stacks Earth buffs on you; Threaded Needle lays Metal debuffs on them;
  Pestle Grind and Through the Mountain land the heavy hits through a ward that pierce, penetration and the Metal
  stacks have thinned; the Golden Bell pays a flat fee for each of their heavy hits.
- **The engine:** pierce does three jobs at once. Up to the cap it cancels suppression. Through Stiff Neck the same
  capped share becomes soul resistance against the realm above. Past the cap, Through the Ceiling turns it into
  resistance penetration. So "pierce to pierce_cap and past it" is the build's main stat, not a rounding error.
- **The sacrifice:** equals. Against your own realm, L5 is empty (Against the Heavens forbids every other L5) and
  your hits lose a quarter realm, so you deal about 0.3 of a top-end build's damage. Three realms up, every
  gap-reader turns off, and you run. No fix for either is allowed.
- **The arc:** a servant's son with a ground-down iron pestle, beaten by his seniors, who learns to strike only
  upward. Every breakthrough is a tribulation one realm up, his best fight. At Deity Transformation there is no
  realm above. The build becomes the giant it was made to kill, and the next needle comes from below.

## The Legend

The alchemy hall of a minor sect kept a herb-pounder for forty years: a dual-rooted servant no elder thought
worth teaching. His seniors sparred with him the way one spars with a post. He kept the iron pestle he pounded
with, and ground it a little each night, until it was a needle. The manual he left, the Iron Pestle Scripture
(Thiết Xử Kinh), has a famous flaw: it was written by someone who never once fought an equal. It has pages
for leaning on a heavier opponent's weight and none for meeting a peer. Its first line is the proverb every
child knows: grind an iron pestle long enough and it becomes a needle.

The sects of strict seniority ban it. A junior who can kill his elders breaks the order a sect stands on, and
inner halls pay bounties for the scripture's copies, which suits its users, whose Metal root draws bounty money
in any case. Its followers are servants, outer disciples, latecomers: anyone who spends a life one realm below
the people who matter.

The pounder crossed his last tribulation and reached Deity Transformation. There was no one above him. Three
Nguyên Anh who had copied his scripture came for him together, and the old needle, with nothing to lean on,
fell to the same weight he had used all his life.

## How It Fights

Against the realm above, the build opens its arts on the first beat it can afford. Bearing the Mountain wraps you in
Earth buffs, so their Physical hits are dampened; Threaded Needle pins Metal debuffs on them, so your Physical
hits land harder. The heavy arts arrive at 5 and 8 seconds and carry the full Effects layer, which exists only
against a higher foe. Their hits arrive smaller than their realm promises (Half a Realm), each costing your
Golden Bell the same small fee, and their soul arts meet a soul resistance built out of your pierce. Against an
equal it is a plain, middling Metal caster, and it knows it.

**The signature moment:** the Breakdown line "Half a Realm: struck at 1.585 ×" on your Through the Mountain,
the enemy's ward reading "pierce: suppression 0.975", and a Nguyên Anh going Down to a Kết Đan.

## Enabler

**Half a Realm (Bán Cảnh)**, an Effect of tier `enabler`, on the Iron Pestle Scripture (layer 1); second home, the
Nghịch Đạo capstone.

- **Rule:** against a foe one or two major realms above you, every hit, tick and trigger hit between you is struck
  as if the gap were half a realm narrower: yours read `U_att × √(U_next / U_att)` (×1.585), theirs read
  `U_def ÷ 1.585`. At a gap of three or more it does nothing.
- **Reads:** the realm gap, at compile (it cannot change in a fight).
- **Closes:** against a foe of your own realm or below, your hits and ticks read `U_att ÷ 1.26` (a quarter realm
  down, `2.512^0.25`).
- **Where a player finds it:** a ragged copy of the Iron Pestle Scripture, sold by an outer disciple or taken from a
  bounty hunter's corpse. Banned in sect libraries.
- **What it opens:** the fight-unit gap one realm up falls from ×6.31 in fight power (2.512 on damage × 2.512 on
  health) to ×2.512 (1.585 × 1.585).
- **Fit:** Needs rule. Combat Formulas C (`base = U_att · stage_att · c_art`), F (`raw = U_src · …`) and G
  (`free_hit = U · …`) read the attacker's own fight unit with no hook; Effects rule 6's action list has no action
  that changes the unit a side strikes at. Proposal in the guide's last section and in suggestions.md.

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1. Base | Half a Realm (Bán Cảnh) | Hits both ways struck half a realm narrower against a foe 1–2 realms up; a quarter realm down against equals and lower | Rule swap | all hits, ticks | none (outside M) | ○ | Technique (enabler), Nghịch Đạo capstone | any tribulation crosser; Hiệp Đạo duellists |
| 1. Base | Arts at the lint | Through the Mountain c 5.10, Pestle Grind 3.80 | Flat base | art | none | ○ | Iron Pestle Scripture | — (content) |
| 2. Rate | Art speed (`art_speed_pct`) | +40 to +60 total, so Through the Mountain fires every 5–5.7 s | Increased | art | none | ◐ | Tree, technique | every caster |
| 3. Multiplier | Damage, Physical and Metal damage (`attack_pct`, scoped) | +200 to the L1 knee | Increased | art | L1 | ● / ○ | Tree, Way W | every Metal build |
| 3. Multiplier | Needle's Eye (Châm Nhãn) | `damage_more` +60 (technique) / +40 (Way, cluster) on arts tagged [pierce] | More | art | L2 | ○ | Iron Pestle Scripture, Nghịch Đạo Vượt Cấp, Ant's Ladder region | any vượt cấp build; soul-lance (lances are piercing arts) |
| 3. Multiplier | Ore Weight (Khoáng Trọng), reused | `damage_more` +45 [physical] | More | art | L2 | ○ | Ore-Vein Scripture (secret art) | triple-convert, armoury-mind, one-art |
| 3. Multiplier | Cold Iron Order (Hàn Thiết Lệnh), reused | `damage_more` +60 [kim] on the Thiên giai copy | More | art | L2 | ○ | Iron Pestle True Scripture | armoury-mind |
| 3. Multiplier | Artifact attack | Forty-Year Needle, any Giáp, a Chuông | (gear) | art | L3 | ● | Items | every gear build |
| 3. Multiplier | Nine Rods Array; Iron-Sand Hand Bath, reused | L4 +80 and +50, foreseen fights (challenges, tribulations) | More | art | L4 | ○ | Formation, coating | ten builds of this run |
| 3. Multiplier | Against the Heavens (Nghịch Thiên) | L5 +100 against a foe one or two realms above; closes: no other L5 source counts for you | Conditional (keystone) | art, basic | L5 | ○ (tree catalogue idea) | Tree keystone; Nghịch Đạo capstone line | any vượt cấp build; tribulation crossers |
| 4. Crit | Crit chance and damage | To 50 % and ×2.0 | Increased | art | outside M | ◐ | Tree | every hit build |
| 5. Reach | Realm pierce (`pierce_pct`) | To 75 (cap) and past it | Increased (flat pp) | whole hit | outside M | ◐ | Tree, technique (+15), Way lines, Forty-Year Needle (+15), Thấu Cảnh affix | every vượt cấp build |
| 5. Reach | Thấu Cảnh (Realm-Piercing) affix | `pierce_pct` +3 to +10, rolled on any base | Flat | whole hit | outside M | ○ | Generated artifacts | every vượt cấp build, tribulation crossers |
| 5. Reach | Physical penetration (`resist_pen_pct` [physical]) | +60 needle, +100 notables | Increased (flat points) | art | outside M | ◐ | Tree, Forty-Year Needle | every Physical build |
| 5. Reach | Accuracy (`accuracy_pct`) | +10, against the realm evade step (+2 pp per realm) | Flat | whole hit | outside M | ◐ | Tree, Ant's Ladder | anti-evade builds |
| 6. Past the cap | Through the Ceiling (Xuyên Đỉnh) | Pierce that `pierce_cap` clips becomes Physical-and-all penetration, 4 points per pp, at most +120, against a foe above | Overflow | art | outside M | ○ | Nghịch Đạo Vượt Cấp (minor), Forty-Year Needle | any build that overstacks pierce (tribulation crossers, Threshold-style scar builds) |
| 7. Fuel | Golden Bell (Kim Chung Tráo), existing ward | A flat 0.035 of your pool per enemy hit, whatever its size | (ward) | defence | none | ● (Combat Defence H) | Ward slot | boss fighters |
| 7. Fuel | Regeneration, art cost | +6 pp regen, −20 % art cost | Increased | fuel | none | ● / ◐ | Tree, technique | every caster |
| 8. Survival | Stiff Neck (Cường Hạng) | Against a foe above, your soul resistance gains your pierce share: +100 × P pp (up to +75) | Borrow | defence (soul) | none | ○ | Nghịch Đạo Vượt Cấp (major) | soul-lance's victims; any build crossing realms |
| 8. Survival | Soul-Guarding Lamp, thần thức | +22.5 pp soul res (× ws), soul shield; `than_thuc_pct` +40 | (ward), Increased | defence (soul) | none | ● | Ward or art slot, technique, tree | anyone facing soul builds |
| 8. Survival | Earth buff stacks (Bearing the Mountain) | 10 stacks: Physical damage taken 11 % dampened (× purity) | (element stacks) | defence | none | ● (Effects rule 9a) | Art | every Earth build |
| 8. Survival | Beneath Notice (Bất Túc Đạo), existing | +15 escape against a higher realm | Conditional | escape | none | ● (Effects, starter) | Tree, Way | escape builds |
| 9. Identity | Mountain Notches (Sơn Ngân) | +1 `pierce_pct` and +3 Physical penetration per higher-realm cultivator you have knocked out this life, up to +20 and +60 | Per | whole hit | outside M | ○ | Forty-Year Needle | Hiệp Đạo duellists, bounty hunters |

**Identity piece:** Half a Realm. It is the only piece that touches the fight unit, the largest single term of the
realm gap (×2.512 a realm on both damage and health, Combat Formulas A). Everything else answers a smaller
pressure. Mountain Notches is the arc's piece: the needle grows a notch for each giant it fells.
**Empty rungs:** L5 against equals (a sacrifice, enforced by Against the Heavens); L4 in an ambush (a gap: the
coating still applies in an ambush, the array does not).

**Forms used:** Rule swap, Flat base, Increased, More, Conditional, Per, Overflow, Borrow, Trade (the enabler's
close). Nine forms.

**Layer totals at Kết Đan against a Nguyên Anh (the defining fight), first guesses from the anchors:**

| Layer | Points at Kết Đan | Multiplier | Sources |
|---|---|---|---|
| L1 | +200 | ×3.00 | `attack_pct`, Physical, Metal, tree W; stop at the knee (past +200 each point counts half) |
| L2 | +225 (Huyền), +285 (Thiên) | ×3.25 / ×3.85 | Needle's Eye 60 + 40 + 40, Ore Weight 45, Ant's Ladder 40; Cold Iron Order +60 on the Thiên copy. Cap 300 |
| L3 | anchor | ×3.5 | Forty-Year Needle, Giáp, Chuông (top-end anchor; the Châm base costs only 10 thần thức) |
| L4 | +130 foreseen / 0 or +50 blind | ×2.3 / ×1.0–1.5 | Nine Rods Array, Iron-Sand Hand Bath |
| L5 | +100 above / 0 equal | ×2.0 / ×1.0 | Against the Heavens only |
| Outside M | — | ×1.585 base; supp 0.975 | Half a Realm; pierce at the cap (0.90 with none) |

`M` upward, foreseen: 3.0 × 3.25 × 3.5 × 2.3 × 2.0 ≈ **157** (top-end anchor at Kết Đan 210). Times Half a Realm
and suppression: 157 × 1.585 × 0.975 ≈ **243**, against the generic top-end's 210 × 0.95 = 200 one realm up (pierce 0.5).
Against an equal: 3.0 × 3.25 × 3.5 × 2.3 × 1.0 ÷ 1.26 ≈ **62**, about 0.3 of the anchor.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Dual Metal–Earth (Kim–Thổ), purity 80+ each. Earth generates Metal (the cycle `moc, hoa, tho, kim, thuy`) | Metal arts and Metal debuffs (+1.8 % Physical taken per stack); Earth buffs (Physical taken 1.1 % dampened per stack) answer heavy Physical hits. Purity powers both by `1 + 0.002 × P`. Metal's life role (bounty income) suits the lore |
| Key talents | Soul (thần hồn) high; physique (căn cốt) moderate; comprehension | Thần thức is half the soul answer (rho reads it); physique for health; comprehension for the scripture |
| The Way (Đạo) | Nghịch Đạo · Nghịch Thiên Cải Mệnh (Defy Heaven, Change Fate), catalogue #85. Facet Vượt Cấp (Fighting Upward) for Stiff Neck, Through the Ceiling, Needle's Eye and pierce lines; Nghịch Kiếp (Defying Tribulation) for the tribulation; capstone carries Against the Heavens or a second Half a Realm | The catalogue already names this Way "the weaker you are, the harder you strike" |

## Công Pháp

### Iron Pestle Scripture (Thiết Xử Quyết) — main, Huyền giai (to Kết Đan); Iron Pestle True Scripture (Thiết Xử Chân Kinh) — main, Thiên giai (to Hóa Thần)

"Grind it long enough and it becomes a needle."

```json
{"id": "thiet_xu_quyet", "name": "Thiết Xử Quyết", "tier": 1, "tech_kind": "main",
 "names": ["kim", "tho"], "layers": 9,
 "bonuses": [{"stat": "than_thuc_pct", "value": 15}, {"stat": "khi_huyet_pct", "value": 15}],
 "abilities": [{"ability_id": "half_a_realm", "unlock_layer": 1},
               {"ability_id": "threaded_needle", "unlock_layer": 1},
               {"ability_id": "through_the_mountain", "unlock_layer": 3},
               {"ability_id": "needles_eye_60", "unlock_layer": 4},
               {"ability_id": "bearing_the_mountain", "unlock_layer": 5},
               {"ability_id": "pierce_15", "unlock_layer": 6},
               {"ability_id": "pestle_grind", "unlock_layer": 7},
               {"ability_id": "sweepers_exit", "unlock_layer": 9}],
 "origin": "authored"}
```

The Thiên giai copy (`thiet_xu_chan_kinh`, tier 3, 15 layers) has the same abilities, adds Cold Iron Order (+60
[kim], layer 6) and Last Stitch (layer 10), and carries `than_thuc_pct` 22, `khi_huyet_pct` 20, `attack_pct` 18.

**Fit:** Needs key (combat passives, Effects and ability records have no field in `items_cong_phap.json` yet; the
bonuses fit today) · **Budget:** Huyền 15/15 + 15/15 = **2.0 / 2.0**;
Thiên 22/15 + 20/15 + 18/15 = 1.47 + 1.33 + 1.20 = **4.0 / 4.0**; each single ≤ 1.5 pool maxima. Pierce and Needle's
Eye are abilities (passives), outside the budget (cong-phap.md Formulas D).

**Secret art (aux):** Ore-Vein Scripture (staged, `ore-vein-scripture`) for Ore Weight +45 [physical]. Metal, in
harmony with the Metal main method.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Threaded Needle (Xuyên Tuyến) | Iron Pestle, 1 | hit; kim, physical, hit, art, pierce | 2.05 | 0.05 | 3 s | — | Needs key (art record) |
| Through the Mountain (Xuyên Sơn) | Iron Pestle, 3 | hit; kim, physical, hit, art, pierce; slow, costly | 5.10 | 0.10 | 8 s | — | Needs key (art record) |
| Bearing the Mountain (Phụ Sơn) | Iron Pestle, 5 | buff; tho, art | 0 | 0.03 | 6 s | — | Needs key (art record) |
| Pestle Grind (Ma Xử) | Iron Pestle, 7 | hit; kim, physical, hit, art, pierce | 3.80 | 0.075 | 5 s | — | Needs key (art record) |
| Last Stitch (Mạt Tuyến) | Iron Pestle True, 10 | hit; kim, physical, hit, art, pierce | 3.15 | 0.06 | 4 s | enemy health below 35 % | Needs key (art record) |
| Sweeper's Exit (Tảo Môn Độn) | Iron Pestle, 9 | escape; tho, escape | — | 0.04 | 6 s | own health below 30 % | Needs key (art record) |

- **Threaded Needle. Effect:** a hit that grants 3 Metal debuff stacks for 5 s. Lint 1 × (1 + 24 × 0.05) + 0.25 ×
  2 = 2.70; charge 0.015 × 15 = 0.225; 2.70 × 0.775 = 2.09, so 2.05. **Description:** a thread drawn through the
  meridian, and the thread stays.
- **Through the Mountain. Effect:** a single heavy hit with its own `pierce_pct` +10 (source: art scope). Lint
  1 × (1 + 2.4) + 0.25 × 7 = **5.15**. **Description:** the pestle's forty years in one push.
- **Bearing the Mountain. Effect:** grants you 10 Earth buff stacks for 6 s (charge 0.010 × 60 = 0.60, the maximum;
  it has no hit, so the lint discount costs nothing). **Description:** the servant's back under the weight.
- **Pestle Grind. Effect:** a hit. Lint 1 + 1.8 + 1.0 = **3.80**. **Description:** pounding, as in the hall.
- **Last Stitch. Effect:** a hit, ready only below 35 % enemy health. Lint 1 + 1.44 + 0.75 = **3.19**.
  **Description:** close the wound you opened.
- **Sweeper's Exit. Effect:** an escape art, `e_art` 0.55, with Beneath Notice's +15 against a higher realm.
  **Description:** out by the kitchen door, as always.

## Loadout by Realm

Art slots 3 / 4 / 5 / 6 / 7; free ward slots 1 / 1 / 2 / 3 / 4 (Combat Formulas A2; Combat Defence & Healing D).

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Qi Refining (Luyện Khí) | 3 | Threaded Needle, Through the Mountain, Soul-Guarding Lamp (art-slot ward) | Golden Bell | Huyền copy, layers 1–3 |
| Foundation Establishment (Trúc Cơ) | 4 | + Bearing the Mountain | Golden Bell | Earth stacks arrive |
| Core Formation (Kết Đan) | 5 | Bearing, Threaded, Through, Pestle Grind, Sweeper's Exit | Golden Bell, Soul-Guarding Lamp | The defining realm |
| Nascent Soul (Nguyên Anh) | 6 | + Last Stitch (Thiên copy) | + Common Ward | The tribulation to Hóa Thần is the build's best fight |
| Deity Transformation (Hóa Thần) | 7 | + Clear Heart Ward in the art slot | + Clear Heart Ward or a second resistance ward | No realm above; see the arc |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Forty-Year Needle (Tứ Thập Niên Châm) | artifact, weapon | `cham` (10 thần thức), cực phẩm, realm tier | `pierce_pct` +15, `resist_pen_pct` [physical] +60, Through the Ceiling, Mountain Notches | Needs rule (Notches' readable) |
| Any Giáp | artifact, body gear | `giap` | Health and block; 5 thần thức | Fits today |
| A Chuông with the Thấu Cảnh affix | artifact, weapon or ward | `chuong` | Pierce +3–10 rolled; defence | Fits today (affix row) |
| Nine Rods Array, reused | formation | — | L4 +80 in foreseen fights | Needs key (staged) |
| Iron-Sand Hand Bath, reused | coating | — | L4 +25–50, foreseen and ambush | Needs key (staged) |

**The Forty-Year Needle.** The pounder's own pestle, ground down. It carries a notch for every Elder he put down.
Each owner adds their own (Mountain Notches).

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Against the Heavens (Nghịch Thiên), keystone | L5 +100 above; no other L5 | The only L5 the build may have | Fits today (tree catalogue idea; Effects lists it as deferred) |
| 2 | Realm pierce notables | +8 pp, +10 pp (art) | To the cap and past it | Fits today |
| 3 | Physical and Metal damage | +12 % notables | L1 to the knee | Needs key (scoped rows ○) |
| 4 | Thần thức, soul resistance | +6 % / +6 pp notables | Soul answer | Fits today |
| 5 | Physical penetration | +100 notable | Reach | Fits today (designed) |
| 6 | Beneath Notice | +15 escape upward | Running at three up | Fits today |
| 7 | Accuracy | +3 notables | Realm evade step | Fits today |

### Tree region idea: Ant's Ladder (Nghĩ Thê)

Hidden clusters and `seal_clusters` are retired (cong-phap.md rule 15), so this is an open region for the tree
rework, as slow-thunder's Winter Breath. Theme: crossing realms (Realms system), wider than one build. Metal
affinity. Open, no seal. Size 8: small
acupoints of realm pierce +1.2, accuracy +0.5, Physical penetration +15, soul resistance +1; notables Needle's Eye
+40 [pierce] (middle) and Beneath Notice (far). No capability. An idea for the tree rework, not data.

## Đạo

Nghịch Đạo · Nghịch Thiên Cải Mệnh (catalogue #85, no requirement). Facet **Vượt Cấp (Fighting Upward)**: stat lines
`pierce_pct`, `soul_res_pct`, `accuracy_pct`; `major` Effect notable Stiff Neck; `minor` Through the Ceiling; two
Needle's Eye +40 notables. Facet **Nghịch Kiếp (Defying Tribulation)**: health and soul lines for the tribulation.
Capstone line: Against the Heavens (a second home) or Half a Realm (a second home for the enabler). This session did
not read `design/dao-ways/`, so the graph placement is a proposal only.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | Two arts and a bell; already fights Trúc Cơ thugs | Half a Realm, Threaded Needle, Through the Mountain | The servant who would not stay down |
| Foundation Establishment | Earth stacks blunt the elders' blows | Bearing the Mountain, first pierce notables | First notch on the needle |
| Core Formation | The defining fight: Kết Đan kills Nguyên Anh | Pestle Grind, Stiff Neck, the Forty-Year Needle | A bounty on his head from his own sect |
| Nascent Soul | Best fight of the life: the tribulation is always one realm up | Thiên copy, Last Stitch, Through the Ceiling | Lightning as the last senior |
| Deity Transformation | No one above. A middling caster among three peers; hunts bosses if the boss readable is added | Clear Heart Ward | The giant, waiting for the needle from below |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical, one realm up | wins (target: fast) | Fight-unit gap halved; L5 full; suppression 0.975 |
| Top-end, one realm up | underdog, a real chance (target 25–40 %) | Fight power ×10 above, cut to about ×3.7 by Half a Realm and Stiff Neck; a generic top-end has about 1 % |
| Typical, two realms up | wins usually (target ≥ 80 %) | Generic top-end is 54 % (Formulas H); this build adds ×1.585 both ways and +7 % suppression |
| Any foe three or more up | loses; escapes | Every gap-reader turns off at three; pierce gives 0.875 at most |
| Typical equal | wins, slowly | 0.3 of top-end damage is still ~11 × typical M at Kết Đan |
| Top-end equal | loses | Empty L5 and a quarter realm down |
| Higher-realm soul-piercer | loses or even | Slackened Soul (−15 pp a stack, no floor) eats Stiff Neck; `soul_pct` 0.08 with `x_soul` reaches 15–20 % a hit |
| A needle one realm below you | loses (at Hóa Thần) | The founder's death |

**Counter:** the higher-realm soul-piercer (Combat rule 18's Soul group, a drainer with a soul art). Soul ignores
Half a Realm's fight-unit shift, and Slackened Soul strips the pierce-built soul resistance two stacks at a time.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Technique Huyền 2.0/2.0, Thiên 4.0/4.0, singles ≤ 1.5. Arts inside the lint: 2.05 ≤ 2.09; 5.10 ≤ 5.15; 3.80 ≤ 3.80; 3.15 ≤ 3.19; Bearing's charge 0.60 ≤ 0.6. Slots used 3/4/5/6/7 against `slots_by_realm` 3/4/5/6/7; wards within 1/1/2/3/4. Three artifacts, the needle at 10 thần thức. Combat passives (pierce +15, Needle's Eye) are abilities, outside the bonus budget, so their size is not budget-checked |
| Validity | PASS | Elements `kim`, `tho` (character_elements.json); bases `cham`, `giap`, `chuong` (items_artifacts.json); tiers Huyền (max Kết Đan) and Thiên (max Hóa Thần) cover the span; the aux Ore-Vein Scripture is Metal, in harmony; tags used (`pierce` effect, `kim`, `tho`, `physical`) are in Combat rule 6 |
| Stack | PASS | All nine rungs filled; nine forms; identity piece named; layer totals stated; empty L5 against equals named as the sacrifice. Every modifier serves the art-hit channel or the defence it needs |
| Identity test | NOT ASSESSED | No simulator this run (user decision 2026-11-11). By the formulas, removing Half a Realm multiplies upward kill time by 1.585 and damage taken by 1.585 |
| Scaling | PASS (INFO) | Upward `M` ≈ 157 × 1.585 × 0.975 ≈ 243 at Kết Đan, above the top-end anchor's 200 one realm up. Against equals ≈ 62, about 0.3 of the anchor, by design (the seed asks for it) |
| The fight | NOT ASSESSED | No simulator this run (user decision 2026-11-11). No fight input written. Unmodelled anyway: Half a Realm, Stiff Neck, Through the Ceiling, Mountain Notches |
| Reuse | PASS | Reused Ore Weight, Cold Iron Order, Nine Rods Array, Iron-Sand Hand Bath, the soul reference table; Golden Bell, Soul-Guarding Lamp, Beneath Notice, Common Ward, Clear Heart Ward from the GDDs; Against the Heavens from the tree catalogue. Every new piece names a second home; no signature pieces |
| NPC use | PASS | Every new Effect reads the realm gap (compile or instant start), an owned stat, a named cap's clip, or (Notches) a life count; all are `npc: true` and read the same for an NPC. Breakdown lines: "Half a Realm: struck at ×1.585", "Against the Heavens: L5 +100", "Stiff Neck: soul resistance +75", "Through the Ceiling: +120 penetration (30 pp past the cap)" |
| Counterplay | PASS | Higher-realm soul-piercer; top-end equals; anything three realms up; a needle one realm below you |
| Originality | PASS | All names original. The pestle-into-needle proverb is a public-domain saying, not a work's character or technique |

## Fight Results

Not run. No simulator this run (user decision 2026-11-11): no fight input was written and no simulation was
run. The figures above are read straight from Combat Formulas A, B, C, E2 and H.

**Unmodelled (would be, in any case):** Half a Realm (no hook in fight_calc for the fight unit), Stiff Neck,
Through the Ceiling, Mountain Notches, Earth buff stacks.

## New Concepts

**Shifting the fight unit a side strikes at.** Combat Formulas C, F and G read `U_att`. Half a Realm needs an
Effect action "strike at a shifted fight unit", bounded to ±half a realm (±1.585), read at compile, with the
Breakdown line "struck at ×1.585". It serves this build, any tribulation crosser (thien-kiep.md rule 6 always
sets g = 1), and Hiệp Đạo's Quyết Đấu duellists. A question for the user.

**Gap readers stop at two.** Every Effect that reads the realm gap pays out at gaps 1 and 2 only, so the Formulas H
target "never three realms up" holds whatever stacks on it. A shared convention for Effects rule 5.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Half a Realm | Needs rule | combat.md Formulas C, F, G; effects.md rule 6 (new action) |
| Mountain Notches | Needs rule | effects.md rule 5: compile readable "higher-realm cultivators you have knocked out this life" (Realms reports knockouts for capability #9) |
| Forty-Year Needle | Needs rule | Carries Mountain Notches |
| Boss counts as above (DT arc) | Needs rule | effects.md rule 5: readable "the target is a boss" (`boss_pool_mult` > 1) |
| Ant's Ladder | Needs key | Tree rework region idea (staged: ants-ladder-region); its lines are designed keys, but no region exists until the rework |
| The six arts; the Iron Pestle Scripture's passives and abilities | Needs key | Art records and technique ability fields (no format yet, Combat Open Question 13) |
| Against the Heavens, Stiff Neck, Through the Ceiling, Needle's Eye, Thấu Cảnh, the Nghịch Đạo facet lines | Fits today | Content rows only |
