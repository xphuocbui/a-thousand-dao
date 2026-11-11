# Art library, part A: Fire, Earth, Metal, Physical

42 arts (19 common, 23 authored) in `part-a.json`. `python -I tools/design/arts/lint_arts.py design/arts/part-a.json`: 0 findings.
`c_art` of each art sits at or just under the art lint after its stack and curse charge (scaled down for arts with a payoff Effect).
Tags starting with the art's own name (`flare`, `press`, `chorus`...) are the filter hooks its Effects use.

## Fire (Hỏa), 10 arts

| Art | Role | Tier | What it does |
|---|---|---|---|
| Fire Bolt (Hỏa Tiễn) | damage | common | A plain Fire hit |
| Kindle Palm (Dẫn Hỏa Chưởng) | stacks | common | Fire hit, 2 Burn stacks for 8 s |
| Ember Rain (Tàn Hỏa Vũ) | stacks | common | Fast Fire hit, 20 Burn stacks for 2 s (front-loaded clock) |
| Flame Lance (Liệt Diễm Thương) | stacks | common | Slow Fire hit, 4 Burn stacks for 8 s |
| Warm the Hearth (Noãn Lô Quyết) | stacks | common | Small hit, 3 Fire buff stacks for 15 s on you |
| Red Lotus Ring (Xích Liên Ấn) | stacks | authored | Fire hit, 3 Burn on the foe and 2 Fire buff on you |
| Feed the Fire (Đầu Hỏa) | stacks | authored | No hit; at 40 % linh lực or more, 12 Fire buff stacks for 5 s |
| Flare Up (Bạo Diễm) | damage | authored | Fire hit that consumes up to 20 Burn stacks; each is a 0.12 Fire free hit |
| Rekindle (Phục Hỏa) | stacks | authored | Fire hit; each crit (2 a pulse) lays 3 more Burn stacks for 4 s |
| Burning Reply (Hỏa Báo) | utility | authored | 4 Fire buff stacks; every hit you take stokes 1 more |

## Earth (Thổ), 10 arts

| Art | Role | Tier | What it does |
|---|---|---|---|
| Gravel Strike (Sạn Kích) | damage | common | A plain Earth hit |
| Tremor Palm (Chấn Thổ Chưởng) | stacks | common | Earth hit, 2 Earth debuff stacks (accuracy down) for 8 s |
| Packed Earth Stance (Hậu Thổ Trụ Thế) | stacks | common | No hit; 5 Earth buff stacks for 12 s (Physical taken dampened) |
| Landslide (Băng Nham) | damage | common | Heavy Earth hit, 4 Earth buff stacks for 10 s on you |
| Gate Hammer (Quan Chùy) | damage | common | Heavy Earth slam, 4 Earth debuff stacks for 6 s |
| Mending Breath (Hồi Khí Tức) | heal | authored | At 60 % health or less: heals and refunds its cost |
| Mountain-Press Seal (Áp Sơn Ấn) | damage | authored | Heavy Physical hit; free 0.8 hit if the foe bears 4+ Earth debuff stacks |
| Iron Mountain Shield (Thiết Sơn Thuẫn) | ward | authored | A body shield of 8 % of health |
| Stone Rebuke (Thạch Báo) | utility | authored | 3 Earth buff stacks; a hit you take is answered by a 0.5 free hit (every 3 s) |
| Bedrock Breath (Nham Tức) | heal | authored | 6 Earth buff stacks; holding 6+ gives +0.5 pp health regeneration |

## Metal (Kim), 10 arts

| Art | Role | Tier | What it does |
|---|---|---|---|
| Quick Draw Cut (Tật Xuất Kiếm Trảm) | damage | common | Fast cheap sword hit, the crit-roll source |
| Notch the Foe (Khắc Ngân) | stacks | common | Sword hit, 3 Metal debuff stacks for 8 s |
| Closing Palm (Hợp Chưởng) | stacks | common | Palm hit, 3 Metal debuff stacks for 10 s |
| Peg-Line Cut (Đinh Tuyến Trảm) | stacks | common | Sword hit, 4 Metal buff stacks for 10 s on you |
| Through the Mountain (Xuyên Sơn) | damage | authored | Heavy hit, 10 % ward bypass |
| Last Stitch (Mạt Tuyến) | damage | authored | Only when the foe is below 35 % health; 10 % ward bypass |
| Thorn Chorus (Kinh Hợp Xướng) | damage | authored | +5 % damage per hit you have taken, up to 10 |
| Ledger Reckoning (Tính Sổ) | damage | authored | +4 L5 per distinct status on the foe |
| Writ of Reckoning (Thúc Nợ Trạng) | curse | authored | 3 Metal debuff stacks and Withering for 2 pulses |
| Quench (Tôi Thiết) | utility | authored | While Sealed Meridian is on you, cleanses seal-tag curses |

## Element-less Physical (sword, saber, fist, spear), 12 arts

| Art | Role | Tier | What it does |
|---|---|---|---|
| Plain Sword Cut (Bình Kiếm Trảm) | damage | common | Plain sword hit |
| Broad Saber Sweep (Khoan Đao Tảo) | damage | common | Heavy saber hit |
| Iron Fist (Thiết Quyền) | damage | common | Fast cheap fist hit |
| Spear Thrust (Thương Đột) | damage | common | Plain spear hit |
| Bleeding Slash (Xuất Huyết Trảm) | stacks | common | Saber hit, 1 Bleed stack |
| Sundering Cut (Phá Giáp Trảm) | curse | authored | Sword hit, 1 Sundered stack |
| Binding Thrust (Phược Thích) | curse | authored | Spear hit, Exposed for 3 pulses |
| Iron Nail (Thiết Đinh) | damage | authored | Heavy spear hit; fires only while the foe is Exposed |
| Shattering Fist (Toái Quyền) | control | authored | Heavy fist hit, strips 4 stacks of the foe's largest buff pile |
| Haft Sweep (Côn Tảo) | control | authored | Spear hit, delays the foe's art timers 0.5 s (once a pulse) |
| Chain Sword (Liên Hoàn Kiếm) | utility | authored | Sword hit; each crit (2 a pulse) shortens your other timers 0.5 s |
| Reaping Saber (Cát Đao) | damage | authored | Heavy saber hit; culls a foe left at 8 % health or less |

## Merged staged ids

- Kindle Palm: spark-palm, kindle-palm, kindling-seal, ember-brand (all 1-2 Burn for 6-10 s; kept 2 for 8 s).
- Ember Rain: ember-rain, red-censer. Flame Lance: flame-lance, cinder-lance.
- Warm the Hearth: warm-the-hearth, hearth-banner. Feed the Fire: feed-the-fire, hearth-song (the longer 6-for-10 s batch is a tuning variant).
- Tremor Palm: tremor-palm, cracked-earth-brand. Packed Earth Stance: packed-earth-stance, bearing-the-mountain (8-for-16 s and 10-for-6 s both break the 0.6 stack-second charge; set to 5 for 12 s).
- Mountain-Press Seal: mountain-press-seal, stake-driving-seal.
- Quick Draw Cut: quick-draw-cut, called-blade, returning-sword-light (all plain Metal sword hits).
- Notch the Foe: notch-the-foe, needle-mark, whetted-tally. Closing Palm: closing-palm, cold-iron-brand.
- Through the Mountain: through-the-mountain, threaded-needle, pestle-grind. Last Stitch: last-stitch, closing-the-book, bloodhound-count.
- Sundering Cut: slipper-blow, hook-and-chain, ore-splitting-cut, grindstone-stroke. Binding Thrust: straw-binding.

## Gaps filled (sources `(gap)`)

Fire Bolt, Gravel Strike, Plain Sword Cut, Broad Saber Sweep, Iron Fist, Spear Thrust (plain damage arts); Bleeding Slash (Physical stacks);
Flare Up, Rekindle, Burning Reply (Fire payoff, crit, and defensive hooks); Iron Mountain Shield, Stone Rebuke, Bedrock Breath (Earth ward, retaliation, recovery);
Shattering Fist, Haft Sweep, Chain Sword, Reaping Saber (Physical control, crit-chaining, execute).

## Not expressed in the schema (left out or approximated)

- **Own conversion** (bellows-flame, charcoal-smoke, third-smelting, ore-splitting-cut conversion): arts carry no conversion field, so those Physical-to-Fire arts are not here; Sundering Cut only keeps the curse.
- **Self-damage effects** (third-smelting, rack-wide-volley, grindstone-stroke: `damage_more` +30 L2 for the art itself; grindstone's per-empty-slot Vow bonus): no per-art L2 key; dropped from the merged arts.
- **Held Reflection / return bank** (open-the-mirror) and **health-paid costs** (offering-cut): `bank` does nothing in the engine and arts have no health cost; not written.
- **Phase-guarded boss arts** (lustral-bell, open-hand-reckoning, deaf-verdict): need boss phase readables and a telegraph; not written.
- **Cleanse OR-guards** (Quench for Sealed Meridian or Silence): guards are all-of, so only Sealed Meridian is named.
- **Refund on heal** (Mending Breath): written in the rule text from combat-defence rule 16; the art record has no field for it.
- **Iron Mountain Shield** size 0.08 of health is a guess; the shield formula (`shield_per_cost`) is in qi-max terms and was not converted.
- **Effects the lint cannot judge**: lint checks event, verb and mod-key names only. `cull`, `scale` with `tags`, and `dmg_more` units (percent assumed) are untested in a fight run. Scope tags on `mod` (`chorus`, `ledger`) assume the engine scopes by art tag.
- The generator script used to compute `c_art` was not kept; values follow lint = 1 + 24 cost + 0.25 (cd - 1), times (1 - charge), times a payoff factor.
