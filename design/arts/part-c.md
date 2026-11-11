# Art library, part C: thunder, wind, element-less, control and utility

49 arts in `part-c.json` (16 common, 33 authored). `lint_arts.py` prints 0 findings. Every `c_art` sits at the art lint after its stack and curse charge (soul arts at the soul lint), so the arts are as strong as a plain art may be, and builds stack on top.

## Thunder (Lôi): crits

| Art | Role | Tier | What it does |
|---|---|---|---|
| Forked Light (Xoa Điện) | damage | common | Cheap lightning hit; the follower after bigger bolts. |
| Thread-Lightning Brand (Lôi Ấn) | stacks | common | Lays 3 Thunder debuff stacks for 10 s (foe takes more crits and crit damage). |
| Static Charge (Tĩnh Điện) | stacks | common | Grants you 3 Thunder buff stacks for 12 s (accuracy, crit chance). |
| Rolling Peal (Cổn Lôi) | damage | common | Slow heavy lightning hit, 8 s cooldown. |
| Cloud-Splitting Bolt (Phá Vân Lôi) | damage | authored | The volley's largest bolt (a drain ward spends on it first); its crit lays 4 Thunder debuff stacks. |
| Thunder Needle (Lôi Châm) | curse | authored | Applies Leaking Ward: drain wards bill 50 % more. |
| Far Flash (Viễn Thiểm) | stacks | authored | 4 Thunder debuff stacks; crits on a marked foe lay more. |
| Rolling Thunder (Hậu Lôi) | damage | authored | Fires only when the foe is at or below 50 % health. |
| Iron Spark (Thiết Tinh) | damage | authored | Physical hit that keeps the lightning tag. |
| Lightning Step (Lôi Độn) | utility | authored | Escape at 30 % health or less. |
| Winnings (Thắng Lợi) | utility | authored | Lightning hit that returns 3 % linh lực. |
| Ice-Breaking Peal (Phá Lăng Lôi) | damage | authored | The longest cooldown (12 s); 30 % damage more against a dry foe. |
| Forking Verdict (Phân Lôi Phán) | damage | authored | Each crit forks into a free 0.6 lightning hit (2 a pulse). |

## Wind (Phong): speed

| Art | Role | Tier | What it does |
|---|---|---|---|
| Chaff Needle (Khang Châm) | stacks | common | Quick physical hit; 1 Wind buff stack, 1 s cooldown. |
| Reed-Cutting Breeze (Tước Phong Nhận) | damage | common | Plain wind cut. |
| Sieve Palm (Sàng Chưởng) | stacks | common | Lays 1 Wind debuff stack (less evade). |
| Empty-Husk Gust (Không Xác Phong) | damage | common | Plain gust, no stacks. |
| Falling Leaf (Điệp Lạc) | damage | common | Heavier cut; 1 Wind stack for 8 s. |
| Threshing Rain (Đả Cốc Vũ) | stacks | authored | One Wind buff stack on you and one debuff stack on the foe. |
| Hollow Step (Hư Bộ) | utility | authored | Small hit, 2 Wind stacks, 2 % linh lực back. |
| Scatter Gale (Tán Phong) | utility | authored | Blows 2 debuff batches off you. |
| Riding the Gust (Thừa Phong) | stacks | authored | Each evade grants a Wind buff stack: dodging makes you faster. |
| Gale Crown (Cuồng Phong Quán) | damage | authored | Heavy hit; 3 Wind stacks for 10 s. |
| Sweeping the Floor (Tảo Trường) | utility | authored | Cleanse when Silenced; carries no wind tag, so a wind Silence cannot stop it. |

## Element-less (no element, Force, Chaos, soul)

| Art | Role | Tier | What it does |
|---|---|---|---|
| Qi-Shaking Palm (Chấn Khí Chưởng) | damage | common | Plain force palm. |
| Shockwave (Chấn Ba) | damage | common | Slow heavy force blow. |
| Chaos Bolt (Hỗn Độn Tiễn) | damage | common | Plain chaos bolt. |
| Mind Thorn (Tâm Thích) | soul | common | Plain soul hit. |
| Mountain-Splitting Thought (Phá Sơn Niệm) | soul | common | Middle soul hit. |
| Drowning Palm (Nịch Thủy Chưởng) | curse | authored | Force palm; Qi Disruption ×3 burns linh lực. |
| Unravelling Seal (Hỗn Giải Ấn) | curse | authored | Applies Sundered. |
| Exposing Thread (Hiển Tuyến) | curse | authored | Applies Exposed. |
| Withering Touch (Khô Héo Chỉ) | curse | authored | Applies Withering: healing taken halved. |
| Lamp-Threading Needle (Xuyên Đăng Châm) | soul | authored | Soul hit; Slackened Soul ×2. |
| Heart-Lamp Lance (Tâm Đăng Thương) | soul | authored | The biggest soul hit. |
| Deaf Verdict (Tuyệt Thính Phán) | soul | authored | Soul hit, fires only against a boss. |
| Bell of Waking (Tỉnh Hồn Chung) | utility | authored | Cleanse when your soul is Slackened. |

## Control and utility

| Art | Role | Tier | What it does |
|---|---|---|---|
| Dragging Moment (Duyên Thời) | control | authored | Slowed Time ×2. |
| Binding Seal (Phong Mạch Ấn) | control | authored | Sealed Meridian. |
| Silencing Seal (Cấm Ngôn Ấn) | control | authored | Silence on one tag. |
| Stagnant Qi Seal (Trệ Khí Ấn) | control | authored | 3 Stagnation. |
| Heavy Breath Mark (Trọng Tức Ấn) | control | authored | Heavy Breath: art cost up. |
| Delaying Gong (Hoãn Chung) | control | authored | Hit delays the foe's art timers by 1 s. |
| Lustral Toll (Tẩy Chung) | control | authored | Strips 5 buff stacks and steals them. |
| Sheathe and Breathe (Thu Kiếm Điều Tức) | utility | common | Restores 6 % linh lực. |
| Second Wind (Hồi Khí) | heal | common | Heals at 70 % health or less. |
| Ash of the Effigy (Hình Nhân Tro) | utility | authored | Cleanse 3 batches when Silenced; untagged. |
| Lantern Out (Đăng Tắt) | utility | authored | Generic escape at 30 % health or less. |
| Whistle In (Hô Hổ) | summon | authored | Companion acts 20 % faster for 3 s. |

## Merged staged ids

Listed in each art's `sources`: thaw-rumble + rolling-peal → Rolling Peal; thunder-debt → Thread-Lightning Brand; thunder-needle + leaking-seal → Thunder Needle; sieve-palm + husk-splitting-cut; threshing-rain + winnowing-toss; the four escapes (lantern-out, paper-boat-crossing, homeward-step, sweepers-exit) → Lantern Out; ash-of-the-effigy + shedding-bark + quench + clean-the-page; bell-of-waking + shut-the-armoury-door; slipper-blow + hook-and-chain + ore-splitting-cut → Unravelling Seal; heart-lamp-lance + ninth-weight-lance; sheathe-and-breathe + ink-line-breath.

## Gaps filled (not staged)

Thunder: Static Charge's twin as a plain stack builder, Forking Verdict (crit identity). Wind: Riding the Gust (evade → speed), Reed-Cutting Breeze and Falling Leaf as commons. Element-less: Qi-Shaking Palm, Shockwave, Chaos Bolt, Mind Thorn, Exposing Thread, Withering Touch, Second Wind. Control: Dragging Moment, Binding Seal, Silencing Seal, Stagnant Qi Seal, Heavy Breath Mark, Delaying Gong, Lustral Toll.

## Not left to part C (staged rows another part takes)

All Fire, Water, Earth, Metal, Wood and Ice rows, the starter-* rows and Metal/Earth heals. Staged rows with no part-C home: open-hand-reckoning (Earth), gate-hammer (Earth), closing-palm (Metal), cold-ledger (Ice), still-tide (Water).

## Could not express in the schema

- **Conversion inside a hit** (Iron Spark's 60 % Physical, Ore-Splitting Cut's Physical → Fire): no art field. Iron Spark is a `phys` art with the Thunder element, which approximates it; the exact conversion needs an art-record key.
- **Cleanse by tag** (`curse`, `soul`, `seal`): the engine cleanses a number of batches only, so the cleanse arts use `cleanse: N` and a guard instead of a tag filter.
- **Escape** is not modelled by the engine; the two escape arts carry the guard only.
- **House Takes All's Cash Out**, Lustral Bell's 1.5 s telegraph and Deaf Verdict's phase guard (`foe.boss` stands in), Whistle In's companion-timer move (a `companion_speed` mod stands in), Bark Mantle, Old-Tree Sap and Rouse (companion shield, heal and Down): need effects rules naming the companion (`beast-in-the-open`) and are left out or approximated.
- **Cloud-Splitting Bolt's "largest hit of the volley"** is a slot-order rule outside the schema; the art is the heaviest bolt and carries the `breaker` tag.
- Curses carry no lint charge for the curse's strength beyond duration; curse arts therefore sit lower in `c_art` than the staged guesses.
- Counts: Thunder 13, Wind 11, element-less 25 (the control and utility group included), so the part runs above the target of about 40.
