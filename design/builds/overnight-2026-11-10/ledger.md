# Build Content Ledger — overnight 2026-11-10 run

> **Status**: Proposals. Nothing here is in game data or a GDD unless its State says `promoted`.
> **Purpose**: What the design-build skill has made, so a new build reuses pieces instead of inventing
> near copies. Modifier definitions live in `design/quick-specs/tree-modifier-catalogue.md`; this file
> records who uses them.
> **Rule**: rows are added, and `Used by` grows. A row is never rewritten by a later build.

## Builds

| Build | Channel | Enabler | Identity piece | Sheet |
|---|---|---|---|---|
| Two Clocks (Song Thời) | Tick (Burn + Poison), then linh lực burn | Twin-Wick Incense Clock | Ash Ledger | [two-clocks.sheet.md](builds/two-clocks.sheet.md) |
| The Flash Before the Thunder (Tiên Điện Hậu Lôi) | Art hit: one synchronised volley at `cooldown_min` | None (a stack, plus one new key) | Opening Haste (Tiên Phát) | [first-volley.sheet.md](builds/first-volley.sheet.md) |
| Soul Lance (Hồn Thương) | Soul art: one lance per `soul_lockout`, at `soul_cap` | None (a stack, plus one identity Effect) | Thousand-Weight Thought (Thiên Quân Niệm) | [soul-lance.sheet.md](builds/soul-lance.sheet.md) |
| The Dry Well (Khô Tỉnh) | Linh lực burn through the enemy's own drain ward and Ice-taxed art costs, then Cold art hits into an empty ward | Water Table (existing Effect) on the Well-Drawing Gourd | Cold Toll (Hàn Thuế) | [dry-well.sheet.md](builds/dry-well.sheet.md) |
| The Brimming Hand (Mãn Tức Quyền) | Basic attack only: never casts; wards fill the art slots | Closed Hand Vow (Bế Thủ Thệ): ward efficiency +100, no damaging art | Stored Breath (Tàng Tức) | [bare-fist.sheet.md](builds/bare-fist.sheet.md) |
| The Straw Effigy (Thảo Nhân Chú) | Art hit (Physical): quick curse arts and the basic attack lay a litany of curses; the Iron Nail reads curse stacks into a ward the curses have cut | Petty-Man Effigy (Tiểu Nhân Hình Nhân): every landed hit lays the next litany curse; closes Backlash | Driven Nail (Đóng Đinh) | [curse-engine.sheet.md](builds/curse-engine.sheet.md) |
| Raising the Tiger (Dưỡng Hổ) | Companion hit: two timers (its own and the keeper's lent basic attack) floored at 0.5 s by art speed; the keeper's arts only buff, heal and shield | Shared-Heart Contract (Đồng Tâm Khế): Lent Hand and the beast in the open; closes every art that touches the enemy | Straining Leash (Căng Xích) | [beast-carry.sheet.md](builds/beast-carry.sheet.md) |
| The Three Smeltings (Tam Luyện) | Art hit: every art struck Physical, turned to Fire by its own record, then to Chaos by `convert_pct` (two steps, the legal chain), so each hit carries three damage-type families and lands as Chaos | None (a stack of existing rules) | Former Shapes (Tiền Hình) | [triple-convert.sheet.md](builds/triple-convert.sheet.md) |
| The Thousand-Year Banyan (Thiên Niên Dung Thụ) | Poison ticks laid by overheal, then fatigue: regeneration and refunding heals keep the bar full, healing past full becomes Poison, and the bigger bar outlasts flat fatigue from 60 s | Surplus Life (Dư Sinh): overheal lays Poison; closes Rooted (evade cap 0, no escape) | Surplus Life (Dư Sinh) | [unkillable.sheet.md](builds/unkillable.sheet.md) |
| The Hearth Mountain (Trạch Sơn) | Art hit: slow Earth formation seals with L4 at its cap from all five kinds of preparation; the surplus past the cap becomes ward strength | Threshold Binding (Trấn Môn), on the Threshold Flags: home formations count wherever a foreseen fight is laid; closes 25 % of linh lực reserved in any fight where no formation of yours counts | Overbuilt Walls (Lũy Thặng) | [home-fortress.sheet.md](builds/home-fortress.sheet.md) |
| The Armoury Mind (Tàng Binh Thức) | Art hit (Physical, Metal) with L3 held at its cap; weapon pieces strike each pulse as a status engine laying Metal stacks; ward pieces are walls and linh lực; the count is an L5 Per | Garrison Mind (Thủ Khố Tâm): each controlled weapon piece strikes each pulse and lays a Metal stack; closes Thinned Mind (only free thần thức and half the bound defend against soul hits) | Garrison Mind (Thủ Khố Tâm) | [armoury-mind.sheet.md](builds/armoury-mind.sheet.md) |
| The Empty Hall (Không Đường) | Art hit, one art only: the lint's largest art (c 6.75, cost 0.125, 12 s), made fast and heavier by the art slots left empty | Vow of the One Stroke (Nhất Chiêu Thệ): +0.4 coefficient per empty art slot past the lint; closes every second art, talisman, escape and art-slot ward | Empty Hall (Không Đường) | [one-art.sheet.md](builds/one-art.sheet.md) |
| The Winnowing Gale (Dương Khang Phong) | Art hit, many and small: six cheap, quick Wind arts at `cooldown_min` plus the basic attack, 13 hits a second at Nguyên Anh; per-hit sustain and Wind stacks paid per hit | None (a stack; one named fan carries the +1 slot) | Slipstream (Thuận Phong) | [cooldown-floor.sheet.md](builds/cooldown-floor.sheet.md) |
| The Slow Thunder (Trì Lôi) | Art hit, few and huge: three cheap slow Lightning peals (8, 10, 12 s at cost 0.02, the lint's best coefficient per linh lực) and a herald; the full pool is a full ward, its overflow heals and loads the 12 s peal, and the single huge hit overdraws drain wards | None (a stack, plus one identity Effect) | Thunderhead (Tích Lôi Vân) | [slow-thunder.sheet.md](builds/slow-thunder.sheet.md) |
| The Needle Under the Mountain (Sơn Hạ Châm) | Art hit, Physical with Metal, few and heavy, built for one realm up: pierce to the cap (suppression), past it (penetration) and as soul resistance; an L5 that exists only against a higher foe | Half a Realm (Bán Cảnh): against a foe 1–2 realms above, both sides strike half a realm closer (×1.585 / ÷1.585); closes: a quarter realm down (÷1.26) against equals and lower | Half a Realm (Bán Cảnh) | [giant-killer.sheet.md](builds/giant-killer.sheet.md) |

## Modifiers

| Modifier | Form | Channel | Layer | Fit | Used by | Second home | State |
|---|---|---|---|---|---|---|---|
| Ash Ledger (Tro Trướng) | Overflow (Effect) | tick → linh lực | none | Needs rule | two-clocks | dry-well, any tick build vs wards | proposal (staging) |
| Cinder Debt (Tẫn Trái) | Overflow (Effect) | cleanse → linh lực | none | Needs rule | two-clocks | starter-venom, status-collector | proposal (staging) |
| Banked Coals (Than Ủ) | More | tick [burn] | L2 | Fits today | two-clocks | any Burn build | proposal (staging) |
| Fuel for the Fire (Tân Hỏa) | Per (Effect) | tick [burn] | L5 | Needs rule | two-clocks (from by-root dual-wood-fire) | any Wood-Fire stack build | reused, by-root |
| Bare Vessel (Lộ Đỉnh) | Conditional (Effect) | tick, via the Incense Clock | L5 | Needs key | two-clocks (also Burial Shroud, Ninth Bell in the content ledger) | any ward-breaker | reused, content ledger |
| Rot Deepens (Thi Độc Thâm) | More | tick [poison] | L2 | Needs key | two-clocks (also Burial Shroud) | any poison build | reused, content ledger |
| Corpse-Wax Coating (Thi Lạp) | More | tick, prepared | L4 | Needs key | two-clocks (also Burial Shroud) | any poison build | reused, content ledger |
| Spillover (Dật Độc), #44 form | Overflow (Effect) | tick → linh lực | none | Fits today (designed in effects.md) | two-clocks | any poison build | in the Effects GDD |
| Kindled Wound (Trì Nhiệt), Marked Prey (Tiêu Ký) | Conditional, Scaling (Effects) | tick via the Incense Clock | L5 | Fits today (designed), Needs rule to reach ticks | two-clocks | Fire, status builds | in the Effects GDD |
| Damage over time, poison, stack effect, stack duration, penetration [fire]/[chaos] | Increased, flat | tick | L1, none | Fits today (Modifier System, Designed) | two-clocks | any tick build | in the Modifier System |
| Opening Haste (Tiên Phát), `opening_haste_pct` | Timing | art hit | none | Needs rule | first-volley | slow-thunder, soul and talisman openers, Ám Đạo assassins | proposal (staging) |
| Unanswered (Vô Ứng) | Conditional (Effect) | art hit | L5 | Fits today if enemy firings are readable | first-volley | Ám Đạo assassins, soul openers | proposal (staging) |
| Taut String (Huyền Căng) | Overflow (Effect) | art hit, first firing | L5 | Needs rule | first-volley | signature (any opening-haste build) | proposal (staging) |
| Eruption (Phún Trào) | Per (Effect) | art hit | L5 | Needs rule | first-volley (from by-root triple-fire-earth) | cooldown-floor, synchronised kits | reused, by-root |
| Ringing Ground (Hưởng Địa) | More | art hit, prepared | L4 | Needs key | first-volley (also Ninth Bell in the content ledger) | any prepared art build | reused, tree catalogue |
| Art speed, opening and reload; crit chance and damage to their caps; `attack_pct` [lightning]; `damage_more` [lightning]/[loi]; `art_cost_pct`; `linh_luc_on_crit_pct`; `accuracy_pct` | Increased, flat, More | art hit | L1, L2, none | Fits today (Modifier System, Designed) | first-volley | any art build | in the Modifier System |
| First Move, Flowing Water, Final Clause, Cold Feet, Unyielding Breath, Glass Meridians; Leaking Ward (curse) | Effects and keystones | art hit, survival | none | Fits today (effects.md Starter Effects, Status Catalogue) | first-volley | alpha strikes, crit tempo, dark paths | in the Effects GDD |
| Thousand-Weight Thought (Thiên Quân Niệm) | Per / Borrow (Effect) | soul | none (`x_soul`) | Fits today | soul-lance | Mind Blade, Incense Burner, any soul build carrying treasures | proposal (staging) |
| Splinters of Thought (Niệm Tiết) | Overflow (Effect) | soul → enemy timers | none | Fits today | soul-lance | Mirage, any soul build | proposal (staging) |
| Lamp-Oil Siphon (Hấp Đăng Du) | Trigger (Effect) | soul → linh lực | none | Needs rule | soul-lance | dry-well, Phệ Đạo soul drain | proposal (staging) |
| Soul-Piercing affix (Thấu Hồn), `x_soul` | Increased | soul | none | Fits today | soul-lance | every soul build | proposal (staging) |
| Mother Lode (Mẫu Khoáng) | Trade (Effect) | soul, via Thousand-Weight Thought | none | Fits today | soul-lance (from by-root dual-earth-metal) | dual-earth-metal (as a cost) | reused, by-root |
| `than_hon`, `than_thuc_pct`, `x_soul`, `art_speed_pct`, `pierce_pct`, `linh_luc_regen_pct` | Flat, Increased, Timing | soul | none | Fits today (Character Stats live, Modifier System designed) | soul-lance | every soul build | in the Modifier System |
| Slackened Soul (curse), Soul Wound, Open Sky, First Move, Unyielding Breath | Curse, Effects, keystone | soul, survival | none | Fits today (effects.md) | soul-lance | soul builds, ward builds | in the Effects GDD |
| Cold Toll (Hàn Thuế) | Redirect (keystone Effect) | linh lực burn via the enemy's drain ward | none | Needs rule | dry-well | variant-ice Frozen Treasury and Frost Lock, Ice + Force anti-ward builds | proposal (staging) |
| Owed Water (Thủy Trái) | Overflow (Effect) | linh lực burn past an empty pool | none | Needs rule | dry-well | two-clocks, soul-lance, Qi Disruption builds | proposal (staging) |
| Weighted Bucket (Trụy Dũng), `ward_bill_pct` | Increased | linh lực burn via the enemy's drain ward | none | Needs key | dry-well | Water Table builds, first-volley's Breaker, Force anti-ward | proposal (staging) |
| Cold Depths (Hàn Uyên) | More | art hit [cold] | L2 | Fits today | dry-well | any Cold build | proposal (staging) |
| Cracked Clay (Nẻ Đất) | Per (Effect) | art hit [cold] | L5 | Fits today | dry-well | variant-ice builds, Cold stack builds | proposal (staging) |
| Frost Tithe (Sương Thuế) | Trigger (Effect, keystone) | Ice → own linh lực | none | Needs rule | dry-well (from by-root variant-ice) | every Ice build | reused, by-root |
| Bare Vessel (Lộ Đỉnh) | Conditional (Effect) | art hit, basic | L5 | Needs key | dry-well (also two-clocks; Burial Shroud, Ninth Bell in the content ledger) | any ward-breaker | reused, content ledger |
| Ringing Ground (Hưởng Địa), via Nine Rods Array | More | art hit, prepared | L4 | Needs key | dry-well (also first-volley; Ninth Bell) | any prepared art build | reused, staging and tree catalogue |
| Ice stacks; `stack_effect_pct`, `stack_duration_pct`, `stack_grant` [bang, debuff]; `art_speed_pct` [bang]; `attack_pct` [cold]; `resist_pen_pct` [force]; `linh_luc_pct` | Flat, Increased, rare Flat | Ice debuff, art hit | L1, none | Fits today (Effects rule 9a; Modifier System, Designed) | dry-well | every Ice build | in the GDDs |
| Water Table (enabler), Still Water, Leaking Ward (curse), Qi Disruption (status) | Enabler, Overflow, curse, status | linh lực | none | Fits today (effects.md Starter Effects, Status Catalogue) | dry-well (Leaking Ward also first-volley) | Force anti-ward, ward duelists, Water builds | in the Effects GDD |
| Stored Breath (Tàng Tức) | Overflow (Effect, major) | basic | none (base coefficient) | Needs key, Needs rule | bare-fist | unkillable, Guide Hound-type owners, full-pool ward casters | proposal (staging) |
| Heavy Knuckle (Trọng Quyền), `basic_coef_add` | Flat base | basic | none (base) | Needs key | bare-fist | starter-blade, martial NPCs | proposal (staging) |
| Worn Knuckles (Chai Quyền) | More | basic | L2 | Fits today | bare-fist | starter-blade, any build keeping a strong basic attack | proposal (staging) |
| Basic attack speed (Khoái Quyền), `basic_speed_pct` | Increased (timing) | basic | none | Needs rule | bare-fist | starter-blade, per-hit-ward breakers | proposal (staging; Modifier System row Pending) |
| Quiet Channels (Tĩnh Mạch) | Per (Effect, minor) | regeneration → Stored Breath | none | Fits today | bare-fist | unkillable, pacifist, Guide Hound, ward casters | proposal (staging) |
| Settled Dust (Lắng Trần) | Trigger (Effect, minor) | basic → Earth buff | none | Fits today | bare-fist | starter-wall, mirror-hide | proposal (staging) |
| Full Sea (Mãn Hải) | Conditional (keystone) | basic | L5 (+30 while linh lực ≥ 80 % of usable) | Needs key | bare-fist | Full Sea's own "efficient, cheap arts" family | reused, tree catalogue (size is this build's guess) |
| Steady Breath [basic], Bare Rack [basic], Elemental Fist, Still Water, Unyielding Breath | Conditional, Scaling, Rule change, Overflow, Keystone (Effects) | basic, survival | L5, none | Fits today (effects.md Starter Effects) | bare-fist | martial, ward and body builds | in the Effects GDD |
| Ringing Ground (Hưởng Địa), via Nine Rods Array | More | basic (it carries the `art` tag) | L4 | Needs key | bare-fist (also first-volley, dry-well; Ninth Bell) | any prepared art build | reused, staging and tree catalogue |
| Iron-Sand Hand Bath (Thiết Sa Dục Thủ) | More | basic, body hits, prepared | L4 | Needs key | bare-fist | any thể tu | reused by name from the 2026-11-07 ledger (staged) |
| `attack_pct` [basic] (Bình Kích), [earth], [physical]; `resist_pen_pct` [physical]; crit chance and damage; `linh_luc_regen_pct`; `defense_pct`; `ward_efficiency_pct`; `khi_huyet_pct` | Increased, flat | basic, ward | L1, none | Fits today (Modifier System, Live or Designed) | bare-fist | any basic or ward build | in the Modifier System |
| Driven Nail (Đóng Đinh) | Trigger / Timing (Effect, major) | curse laid → main art's timer | none | Fits today | curse-engine | dry-well's blades, Ice builds with a slow finisher, status-collector | proposal (staging) |
| Weight of Names (Danh Trọng) | Per (Effect, major) | art, basic | L5 (+10 a curse stack, cap +80) | Fits today | curse-engine | dry-well, soul-lance, any curse kit | proposal (staging) |
| Paid in Nails (Đinh Trả) | Trigger (Effect, minor) | art → refund | none | Fits today | curse-engine | any curse finisher (dry-well, first-volley) | proposal (staging) |
| The Fourth Nail (Đệ Tứ Đinh) | Cap shift (keystone) | curses | none | Needs rule | curse-engine | any curse kit, status-collector | proposal (staging) |
| Deeper Nails (Đinh Sâu), `curse_effect_pct` | Increased | any hit, via curses | none | Needs key | curse-engine | dry-well, first-volley, soul-lance | proposal (staging) |
| Tolled Seal (Chung Ấn) | More | art hit [seal] | L2 | Needs key | curse-engine (also Ninth Bell in the content ledger) | any seal build | reused, content ledger |
| Ringing Ground (Hưởng Địa), via Nine Rods Array | More | art hit, prepared | L4 | Needs key | curse-engine (also first-volley, dry-well, bare-fist; Ninth Bell) | any prepared art build | reused, staging and tree catalogue |
| Nail Into Straw (Đinh Nhập Thảo), `damage_more` +60 [kim] | More | art hit | L2 | Fits today (key designed; the passive has no field) | curse-engine | any Metal art build | proposal (staging, inside the Scripture row) |
| Marked Prey, Blood Drinker; Sundered, Exposed, Sealed Meridian, Heavy Breath, Withering, Leaking Ward (curses) | Scaling, Trigger (Effects); curses | all hits, survival | L5, none | Fits today (effects.md Starter Effects, Status Catalogue) | curse-engine | curse, poison, companion; sword, body | in the Effects GDD |
| `art_speed_pct` and `art_cost_pct` [curse]; status duration [curse] (Pending); `attack_pct` [physical]; `resist_pen_pct` [physical]; `accuracy_pct`; `linh_luc_on_hit_pct` | Increased, flat | art, all hits | L1, none | Fits today (Modifier System, Designed); status duration Needs key | curse-engine | any curse kit, any Physical or many-hit build | in the Modifier System |
| Straining Leash (Căng Xích) | Overflow (Effect, major) | companion | L5 (+5 per 0.1 of share over `c_comp_cap`, cap +50) | Fits today | beast-carry | Salamander Keeper, Living Sword (by-root), Herd-Child (2026-11-07), any companion build | proposal (staging) |
| Fang and Claw (Nha Trảo), `damage_more` +40 [companion] | More | companion | L2 | Fits today | beast-carry | every companion build | proposal (staging) |
| Companion attack speed (Khoái Trảo), `companion_speed_pct` | Increased (timing) | companion | none | Needs rule | beast-carry | Herd-Child, Guide Hound, Salamander Keeper | reused, tree catalogue (given a key; staging) |
| Bonded Spirit (Linh Khế) | Redirect (keystone) | companion | none | Needs rule | beast-carry | any keeper with art speed | reused, tree catalogue (staging) |
| Sure Bite (Ngoạm Chắc) | Rule change (Effect, minor) | companion | none | Fits today | beast-carry | any companion build against evaders | proposal (staging) |
| Thick Hide (Hậu Bì), `companion_health_pct` | Increased | defence (companion bar) | none | Needs key + rule | beast-carry | guardian companions, any beast in the open | proposal (staging) |
| Beast-Bond (Thú Khế) affix, companion power share | Flat base | companion | none | Needs key | beast-carry | every companion build | proposal (staging) |
| Blood-Meal Pill (Huyết Thực Đan), L4 +70 [companion] | More | companion, prepared | L4 | Needs key | beast-carry | every companion build | proposal (staging) |
| Full Trough (Mãn Tào) | Per | companion | L4 | Needs key | beast-carry (from the 2026-11-07 ledger: herd-child, guide-hound, the-puppeteer) | any beast keeper | reused, 2026-11-07 ledger (staging) |
| Rain on Both (Vũ Lưỡng) | Effect (heal target) | healing | none | Needs rule | beast-carry (from by-root dual-water-wood) | Turtle and Snake, Spring Rain | reused, by-root (staging) |
| Beast Soul Union, Pack Hunt, Marked Prey; Rot Seeps In (`convert_pct` [moc]); `attack_pct` [companion]; `art_speed_pct`; `stack_effect_pct` [hoa, buff], `stack_grant` | Keystone, Conditional, Per (Effects); Conversion; Increased | companion, Fire buff | L5, L1, none | Fits today (Effects GDD; Modifier System, Designed) | beast-carry | companion, poison, Fire buff builds | in the Effects GDD and the Modifier System |
| Smoke from the Flame (Hỏa Sinh Yên), `convert_pct` Fire → Chaos [art] | Conversion | art hit | none | Fits today | triple-convert | any Fire build wanting a Chaos finish (by-root dual-wood-fire) | proposal (staging) |
| Slag and Soot (Xỉ Yên), two-type scopes [fire, chaos], [physical, chaos] | Increased, More | art hit (converted parts) | L1, L2 | Needs rule (clarification) | triple-convert | any two-link converter | proposal (staging) |
| Kiln Heat (Diêu Nhiệt), L2 +50 [fire] | More | art hit | L2 | Fits today | triple-convert | every Fire art build | proposal (staging) |
| Lingering Fume (Tàn Yên), L2 +45 [chaos] | More | art hit | L2 | Fits today | triple-convert | every Chaos hit build | proposal (staging) |
| Ore Weight (Khoáng Trọng), L2 +45 / +25 [physical] | More | art hit | L2 | Fits today | triple-convert | sword and Metal builds, curse-engine's Iron Nail | proposal (staging) |
| Former Shapes (Tiền Hình) | Per (Effect, major) | art hit | L5 | Needs key + rule (clarification) | triple-convert | first-volley's Iron Spark, any conversion build | proposal (staging) |
| Festering Wound (Hủ Thương) | Conditional (Effect, minor) | art hit [chaos] | L5 | Fits today | triple-convert | two-clocks, starter-venom | proposal (staging) |
| The Fourth Smelting (Đệ Tứ Luyện) | Cap shift (Effect, keystone) | art hit | none | Needs rule | triple-convert (optional) | any converter with a fourth family | proposal (staging) |
| Soot Coating (Yên Mặc Đồ), L4 +50 [chaos] | More | art hit, prepared | L4 | Needs key | triple-convert | every Chaos hit build | proposal (staging) |
| Deeper Nails (Đinh Sâu), `curse_effect_pct` | Increased | any hit | none | Needs key | triple-convert (also curse-engine) | curse kits | reused (staging) |
| Kindled Wound, Marked Prey, Blood Drinker; Sundered; `convert_pct`, `resist_pen_pct` [chaos], `attack_pct` by type, `crit_chance_pct` | Conditional, Per, Trigger (Effects); curse; Conversion, Flat, Increased | art hit | L5, L1, none | Fits today (Effects GDD; Modifier System, Designed) | triple-convert | Fire, curse, status and sustain builds | in the Effects GDD and the Modifier System |
| Growth Rings (Niên Luân) | Per (Effect, minor) | sustain (health regeneration by age) | none | Fits today | unkillable | NPC sect elders and guardians, long-lived body builds | proposal (staging) |
| Spring Returns (Hồi Xuân) affix, `health_regen_pct` | Flat | sustain | none | Fits today | unkillable | every healer and tank | proposal (staging) |
| Sap Rises (Nhựa Thăng) | Per (Effect, minor) | sustain (healing per Wood stack) | none | Fits today | unkillable (from by-root single-wood) | Evergreen Wall, Spring Rain | reused, by-root (staging) |
| The Spring Never Fails (Tuyền Bất Kiệt) | Rule swap (keystone) | linh lực | none | Needs rule | unkillable (from by-root single-water) | single-water, Spring Rain, Lotus on Still Water | reused, by-root (staging) |
| Quiet Channels (Tĩnh Mạch) | Per (Effect, minor) | linh lực | none | Fits today | unkillable (also bare-fist) | ward casters | reused (staging) |
| Rot Deepens (Thi Độc Thâm), +40/+60 [poison]; Corpse-Wax Coating (Thi Lạp) | More | tick [poison] | L2, L4 | Needs key | unkillable (also Burial Shroud, two-clocks) | any poison build | reused, content ledger |
| Thực affix, `resist_pen_pct` [chaos] | Flat | tick [poison] | none | Fits today | unkillable (also triple-convert) | every Chaos or Poison build | reused (staging) |
| Still Water, Spillover; Withering, Stagnation (curses); `health_regen_pct`, `health_regen_inc_pct`, `healing_pct`, `healing_taken_pct`, `khi_huyet_pct`, `reserve_eff_pct`, `stack_duration_pct` and `stack_effect_pct` [moc], `attack_pct` [poison], `linh_luc_regen_pct`, `status_resist_pct` | Overflow (Effects); curses; Flat, Increased | sustain, tick, linh lực | L1, none | Fits today (Effects GDD; Modifier System, Designed) | unkillable | every healer, tank and Poison build | in the Effects GDD and the Modifier System |
| Overbuilt Walls (Lũy Thặng) | Overflow (Effect, major) | defence (L4 surplus → ward strength) | none | Needs rule | home-fortress | every build that passes L4's cap (dry-well, bare-fist, curse-engine) | proposal (staging) |
| Five Preparations (Ngũ Bị) | Per (Effect, minor) | art hit | L5 | Fits today | home-fortress | any preparation build | proposal (staging) |
| Host's Advantage (Chủ Lợi) | Conditional (Effect, major) | art hit | L5 | Needs key | home-fortress | Hoàng Đạo, Thần Đạo home grounds; bosses in a lair | proposal (staging) |
| Primed Talismans (Phù Dĩ Khai) | Timing (Effect, minor) | talisman | none | Fits today | home-fortress | first-volley, talisman openers | proposal (staging) |
| Pressing Mountain (Áp Sơn) | Trigger (Effect, minor) | reach (Sundered from the ground) | none | Fits today | home-fortress | curse-engine, triple-convert | proposal (staging) |
| Taken Ground (Chiếm Địa) | Rule swap (Effect, major) | the enemy's L4 | L4 | Needs rule | home-fortress (from 2026-11-07 level-ground) | level-ground, ant-general, forum-build | reused, 2026-11-07 ledger (staging) |
| Laid Stone (Lũy Thạch), +60/+40 [formation] | More | art hit | L2 | Fits today | home-fortress | array casters, sect guardians | proposal (staging) |
| Tolled Seal (Chung Ấn), +40 [seal] | More | art hit | L2 | Needs key | home-fortress (also Ninth Bell) | any seal build | reused, content ledger |
| Ringing Ground via Nine Rods Array (+80); Iron-Sand Hand Bath (+50); Landing Ground (+40, ground) | More | art hit, prepared | L4 | Needs key | home-fortress (array also first-volley, dry-well, bare-fist, curse-engine, triple-convert; bath also bare-fist; ground from 2026-11-07 already-waited) | any prepared art build | reused (staging) |
| Field Walls, Formation Within a Formation, Talisman Sleeve, Steady Breath, Cold Feet; `formation_power_pct`, `pill_effect_pct`, `dan_doc_resist_pct`, `dan_doc_decay`, `defense_pct`, `attack_pct` [formation], `art_speed_pct`, talisman power and stock, `formation_upkeep_pct` | Conversion, keystone, rule changes (Effects); Increased, Flat | defence, preparation, art hit | L1, L5, none | Fits today (Effects GDD; Modifier System, Live or Designed; talisman rows and upkeep Pending) | home-fortress | every formation and talisman build | in the Effects GDD and the Modifier System |
| Cold Iron Order (Hàn Thiết Lệnh), L2 +60 / +40 [kim] | More | art hit | L2 | Fits today | armoury-mind | curse-engine, single-metal Thousand Cuts, every Metal art build | proposal (staging) |
| Kindred Vessels affix (Đồng Khí), `artifact_power_pct` +4–10 | Increased | all hits (L3), ward | L3 | Fits today | armoury-mind | every gear build, ward casters | proposal (staging) |
| Weapon efficiency (Khinh Binh), `than_thuc_cost_pct` [weapon] | Increased | budget (thần thức) | none | Needs key | armoury-mind | flying-sword builds, single-metal Gold Rain | reused, tree catalogue (staged) |
| Full Rack (Mãn Giá) | Per (Effect) | art, basic | L5 | Needs rule | armoury-mind | soul-lance (heavy bells), NPC armourers, flying-sword builds | proposal (staging) |
| Edge Past the Rack (Giá Ngoại Phong) | Overflow (Effect) | art, basic (reach) | none (`resist_pen_pct` [physical]) | Needs rule | armoury-mind | any Physical gear build with one heavy weapon | proposal (staging) |
| Humming Shields (Thuẫn Minh) | Per (Effect) | sustain (linh lực) | none | Needs rule | armoury-mind | home-fortress, unkillable, bare-fist (overflow) | proposal (staging) |
| Opened Seams (Khai Phùng) | Conditional (Effect) | art, basic | L5 | Fits today | armoury-mind | curse-engine, every Metal stack build | proposal (staging) |
| Ore Weight (Khoáng Trọng), via Kim Đạo Lò Rèn nodes (+25 ×2) | More | art hit | L2 | Fits today | armoury-mind (made by triple-convert) | sword and Metal builds | reused (staging) |
| Ringing Ground via Nine Rods Array (+80); Iron-Sand Hand Bath (+50) | More | art hit, prepared | L4 | Needs key | armoury-mind (array and bath from earlier builds) | any prepared art build | reused (staging) |
| Thousand-Weight Thought (optional side channel) | Per / Borrow (Effect) | soul | none (`x_soul`) | Fits today | armoury-mind (made by soul-lance) | any soul build carrying treasures | reused (staging) |
| Iron Skin Renewed (Thiết Bì Phục); Steady Breath (Bình Tức) | Trigger; Conditional (existing Effects) | body shield; art | none; L5 | Fits today | armoury-mind | thể tu, Physical swords; ward casters | in the game (Effects starter catalogue) |
| Empty Hall (Không Đường) | Trigger, Per (Effect) | art hit → element stacks | none | Fits today | one-art | any element caster with 2–3 arts and empty slots | proposal (staging) |
| Clear Path (Thông Lộ) | Per (Effect) | art hit (rate) | none | Fits today | one-art | any build of 1–2 arts, slow nukes | proposal (staging) |
| Undivided (Chuyên Nhất) | Per (Effect) | art hit | L5 | Fits today | one-art | any few-art build (Bare Rack's art twin) | proposal (staging) |
| Whole Weight (Toàn Trọng), +40 [costly, slow] | More | art hit | L2 | Fits today | one-art | curse-engine, home-fortress, triple-convert, dry-well slow arts | proposal (staging) |
| Room to Grow (Dư Địa), `art_coef_add` +0.4 per empty slot (the Vow's payload) | Flat base | art hit | none | Needs key, Needs rule | one-art | any one-art build | proposal (staging) |
| Quiet Channels; Opening Haste; Ore Weight (+45 [physical]) | Per (Effect); Timing; More | linh lực; art hit | none; none; L2 | Fits today; Needs rule; Fits today | one-art (also bare-fist, unkillable; first-volley; triple-convert, armoury-mind) | — | reused (staging) |
| Called Blow, Measured Stroke, Steady Breath [sword], Marked Prey, Blood Drinker, Open Sky; `art_speed_pct`, `art_cost_pct`, `crit_damage_pct`, `resist_pen_pct` [physical], `than_thuc_pct`, `bonus_slots` | Keystone, rule changes, conditional, scaling, trigger (Effects); Increased, Flat | art hit, defence | L5, none | Fits today (Effects GDD; Modifier System); Measured Stroke's 20 s threshold is unreachable | one-art | every crit, sword and ward build | in the Effects GDD and the Modifier System |
| Slipstream (Thuận Phong) | Overflow (Effect, `major`) | art hit (fuel) | none | Needs rule | cooldown-floor | variant-wind Gale Dancer, beast-carry keeper, curse-engine quick curses | proposal (staging) |
| Light Chaff (Khinh Khang), +60/+40 [quick, cheap] | More | art hit | L2 | Fits today | cooldown-floor | curse-engine, two-clocks, dry-well quick arts | proposal (staging) |
| Trigger limit (Dư Hưởng), `trig_cap` +1 | Cap shift (rare) | trigger | none | Needs rule | cooldown-floor (from the tree catalogue) | curse-engine, armoury-mind, one-art | proposal (staging) |
| Breath Between Blows (Gian Tức) | Trigger (keystone) | linh lực | none | Fits today | cooldown-floor (from by-root variant-wind) | every Wind build | reused, by-root (staged) |
| Eruption; Basic attack speed | Per (Effect); Increased (timing) | art hit; basic | L5; none | Needs rule | cooldown-floor (also first-volley; bare-fist) | — | reused (staging) |
| Overheat, Steady Breath [phong], Still Water, Glass Meridians, Echo; `art_speed_pct`, `art_cost_pct`, `linh_luc_on_hit_pct`, `leech_health_pct`, `stack_effect_pct` and `stack_duration_pct` [phong], crit, `accuracy_pct`, `resist_pen_pct`, `bonus_slots` | Overflow, conditional, keystone, trigger (Effects); Increased, Flat, rare | art hit, sustain | L5, none | Fits today (Effects GDD; Modifier System, Designed) | cooldown-floor | every art-speed and many-hit build | in the Effects GDD and the Modifier System |
| Thunderhead (Tích Lôi Vân) | Overflow, held (Effect, `major`) | art hit | none (`art_coef_add`) | Needs rule | slow-thunder | unkillable, any ward caster with one big art, NPC hermits | proposal (staging) |
| Thunder Breaks the Dam (Lôi Phá Đê) | Trigger (Effect, `minor`) | control (enemy timer) | none | Fits today | slow-thunder | dry-well, first-volley's Breaker, any big-hit build vs drain wards | proposal (staging) |
| Long Fuse (Trường Dẫn), +50/+40 [slow, cheap] | More | art hit | L2 | Fits today | slow-thunder | any cheap slow caster, sect guardians | proposal (staging) |
| Heavy Sky (Thiên Trầm), +40 [lightning] | More | art hit | L2 | Fits today | slow-thunder | first-volley, variant-thunder builds, every Lightning art build | proposal (staging) |
| Opening Haste; Weighted Bucket; Undivided; Bare Vessel; `art_coef_add` | Timing; Increased; Per (Effect); Conditional (Effect); Flat base | art hit; art (via the enemy's ward) | none; none; L5; L5; none | Needs rule; Needs key; Fits today; Needs key; Needs key and rule | slow-thunder (made by first-volley, dry-well, one-art, Burial Shroud, one-art) | — | reused (staging; Bare Vessel from the content ledger) |
| Still Water, Steady Breath [slow], Final Clause, Leaking Ward, Measured Stroke (optional); `linh_luc_regen_pct`, `art_cost_pct` [slow], `art_speed_pct` [slow], `ward_efficiency_pct`, `attack_pct` [lightning] and [slow], `crit_chance_pct` [slow], `crit_damage_pct` [loi], `resist_pen_pct` [lightning] | Overflow, conditional, trigger, curse, rule change (Effects); Increased, Flat | art hit, sustain, linh lực | L5, none, L1 | Fits today (Effects GDD; Modifier System); Measured Stroke's 20 s threshold is unreachable | slow-thunder | every ward caster and slow caster | in the Effects GDD and the Modifier System |
| Needle's Eye (Châm Nhãn) | More | art hit ([pierce] arts) | L2 | Fits today | giant-killer | soul-lance, any vượt cấp build | proposal (staging) |
| Realm-Piercing affix (Thấu Cảnh) | Flat (affix row) | whole hit | none | Fits today | giant-killer | every vượt cấp build, tribulation crossers | proposal (staging) |
| Against the Heavens (Nghịch Thiên) | Conditional keystone (Effect) | art, basic | L5 | Fits today | giant-killer | any vượt cấp build, tribulation crossers | proposal (staging; idea from the tree catalogue) |
| Stiff Neck (Cường Hạng) | Borrow (Effect) | defence (soul) | none | Fits today | giant-killer | any build crossing realms | proposal (staging) |
| Through the Ceiling (Xuyên Đỉnh) | Overflow (Effect) | art hit (penetration) | none | Fits today | giant-killer | pierce overstackers, tribulation crossers | proposal (staging) |
| Mountain Notches (Sơn Ngân) | Per (Effect) | whole hit | none | Needs rule | giant-killer | Hiệp Đạo duellists, bounty hunters | proposal (staging) |
| Ore Weight; Cold Iron Order; Nine Rods Array; Iron-Sand Hand Bath (reused) | More | art hit | L2, L4 | as staged | giant-killer (added to Used by) | as staged | proposal (staging) |
| `pierce_pct`, `resist_pen_pct` [physical], `accuracy_pct`, `soul_res_pct`, `than_thuc_pct`, `attack_pct` [physical] and [kim], crit; Beneath Notice | Increased, Flat; Conditional (existing Effect) | any | L1, outside M | Fits today / Needs key (scoped rows) | giant-killer | every vượt cấp build | in the game (designed keys; Effects starter) |

## Enablers

| Enabler | Kind | Lives on | Opens | Closes | Used by | State |
|---|---|---|---|---|---|---|
| Twin-Wick Incense Clock (Song Tâm Hương Chung) | Scaling bridge | Named artifact, utility | L5 payloads apply to your ticks | Your hits deal no damage | two-clocks | proposal (staging) |
| Water Table (Thủy Mạch), on the Well-Drawing Gourd (Cấp Tỉnh Hồ Lô) | Loop opener (existing Effect; the host item is new) | Named artifact, utility (`ho_lo`) | 30 % of what the enemy's drain wards pay against your hits restores your linh lực | Your linh lực never regenerates in fights | dry-well | Effect in the GDD; host item proposal (staging) |
| Closed Hand Vow (Bế Thủ Thệ) | Resource swap (Effect, enabler) | Uncarved Stone Fist (technique); fits a Thể Đạo capstone | Ward efficiency +100 while no damaging art is slotted | No damaging arts, damaging talismans or cast wards | bare-fist | proposal (staging) |
| Petty-Man Effigy (Tiểu Nhân Hình Nhân), the Litany | Loop opener, free channel (Effect, enabler) | Named artifact, utility, new base `hinh_nhan` | Every landed hit lays the next missing curse of a 3-name litany (4 with the Fourth Nail) | Backlash: a curse cleansed from the target is placed on you with its time left | curse-engine | proposal (staging) |
| Shared-Heart Contract (Đồng Tâm Khế) | Free channel and redirect (Effect, enabler) | Shared-Heart Tiger-Rearing Scripture (layer 9 / Thiên 12); Thú Đạo capstone | Lent Hand (your basic attack is a second companion strike); the beast in the open (a bar of half your health, takes 30 % of what reaches you, healable and shieldable) | No art or talisman that hits, ticks or curses the enemy; with the beast Down your side deals nothing | beast-carry | proposal (staging) |
| Surplus Life (Dư Sinh) | Scaling bridge and overflow (Effect, keystone) | Mộc Đạo Sinh Trưởng keystone; Thousand-Root Spring Scripture (Địa L11, Thiên L12) | Healing lost to a full bar lays 1 Poison stack (10 s) per 1 % of maximum health, at most 30 a pulse | Rooted: evade cap 0, no escape art | unkillable | proposal (staging) |
| Threshold Binding (Trấn Môn), on the Threshold Flags (Môn Hạn Kỳ) | Free channel: preparation carried from home (Effect, enabler) | Named artifact, utility (`ky`); Trận Đạo Động Phủ capstone | Planted before a foreseen fight, your home-only formations count there and the ground carries `own_abode` | 25 % of maximum linh lực reserved in any fight where no formation of yours counts | home-fortress | proposal (staging) |
| Garrison Mind (Thủ Khố Tâm) | Free channel: a status engine with no art slot (Effect, enabler) | Pass-Garrison Armoury Scripture (Thiên L11, Địa L9); Kim Đạo capstone (Binh Khố) | Each controlled weapon piece strikes each pulse (free hit, `c_trig` 0.3) and lays 1 Metal stack for 6 s; `trig_cap` 6 | Thinned Mind: against soul hits only free thần thức plus half the bound defends | armoury-mind | proposal (staging) |
| Vow of the One Stroke (Nhất Chiêu Thệ) | Slot bender (Effect, enabler) | Whetstone Scripture (layer 1); Đại Đạo capstone | Room to Grow: the one art's coefficient +0.4 per empty art slot past the lint, cap +2.8 | One art only: no second art, talisman, escape art or art-slot ward | one-art | proposal (staging) |
| Half a Realm (Bán Cảnh) | Rule swap (Effect, enabler) | Iron Pestle Scripture (layer 1); Nghịch Đạo capstone | Against a foe 1–2 major realms above: your hits struck at U × 1.585, theirs at U ÷ 1.585 (the fight-unit gap in fight power ×6.31 → ×2.51) | Against your realm or below: your hits struck at U ÷ 1.26 | giant-killer | proposal (staging; Needs rule) |

## Other pieces

| Piece | Type | Fit | Used by | State |
|---|---|---|---|---|
| Green Flame Scripture (Thanh Diễm Quyết / Thiên Kinh) | Technique, main, moc + hoa | Needs key | two-clocks (name from by-root dual-wood-fire) | proposal (staging) |
| Ember Rain, Rot Seed, Red Censer, Green Censer, Spring Sap | Arts | Fits today | two-clocks | proposal (staging) |
| Embers Feed the Hearth (Tàn Hỏa Dưỡng Lô) | Meridian Map keystone | Needs rule | two-clocks (from by-root single-fire) | reused, by-root |
| Hỏa Đạo Tro Tàn: Ash Ledger notable; Độc Đạo Nọc: Spillover notable | Đạo pieces | Needs rule / Fits today | two-clocks | proposal (staging) |
| Common Ward, Mountain Screen, Golden Light Shield, Clear Heart Ward, Thousand-Layer Cloud | Wards | Fits today (combat-defence.md Formulas H) | two-clocks | in the defence GDD |
| Lôi Đế Chân Kinh abilities (the template is in the game; its abilities are new) | Technique, main, loi, Địa giai | Needs key | first-volley | proposal (staging) |
| Cloud-Splitting Bolt, Forked Light, Thunder Needle, Iron Spark, Rolling Thunder, Lightning Step | Arts | Needs key | first-volley | proposal (staging) |
| Herald's Banner (Tiên Thanh Kỳ) | Named artifact, utility (`ky`) | Needs key | first-volley | proposal (staging) |
| Thunder-Gall Pill (Lôi Đởm Đan); Nine Rods Array (Cửu Can Trận) | Pill; formation | Needs key | first-volley | proposal (staging) |
| Lôi Đạo Thiểm Điện: Before the Sound notables, Unanswered as the facet's major | Đạo pieces | Needs key | first-volley | proposal (staging) |
| Drawn Bowstring (Mãn Huyền) | Hidden cluster idea | Needs key | first-volley | proposal (staging) |
| Lamp-Threading Scripture (Xuyên Đăng Bí Điển), passive Still Flame | Technique, secret, thuy, Thiên giai | Needs key | soul-lance | proposal (staging) |
| Lamp-Threading Needle, Mountain-Splitting Thought, Heart-Lamp Lance, Ninth-Weight Lance, Lamp-Light, Lantern Out, Bell of Waking | Arts (four soul, heal, escape, cleanse) | Needs key | soul-lance | proposal (staging) |
| Bronze Shrine Bell (Đồng Từ Chung) | Named artifact, ward (`chuong`) | Fits today | soul-lance | proposal (staging) |
| Lamp-Clear Pill (Minh Đăng Đan) | Pill | Needs key | soul-lance | proposal (staging) |
| Hồn Đạo: Thần Thức (Thousand-Weight Thought), Hồn Kích (Splinters of Thought), Hồn Hộ lines | Đạo pieces | Fits today | soul-lance | proposal (staging) |
| Lamp Wick (Đăng Tâm) | Hidden cluster idea | Fits today | soul-lance | proposal (staging) |
| Huyền Thủy Địa Quyết, Huyền Thủy Thiên Kinh | Technique, main, thuy | Fits today (in the game) | soul-lance | in game data |
| Common Ward, Golden Bell, Mountain Screen, Thousand-Layer Cloud, Soul-Guarding Lamp, Clear Heart Ward, Surging Tide, Golden Light Shield | Wards | Fits today (combat-defence.md Formulas H) | soul-lance | in the defence GDD |
| Dry Well Scripture (Khô Tỉnh Quyết / Khô Tỉnh Kinh) | Technique, main, thuy + bang, Huyền and Địa giai | Needs key | dry-well | proposal (staging) |
| Rime Needle, Leaking Seal, Drowning Palm, Undertow, Spring at the Well's Mouth, Dry Riverbed | Arts (bucket arts guarded "enemy linh lực ≥ 5 %", blade arts guarded "≤ 5 %", a heal) | Needs key | dry-well | proposal (staging) |
| Well-Drawing Gourd (Cấp Tỉnh Hồ Lô) | Named artifact, utility (`ho_lo`), hosts Water Table | Fits today (Water Table); Needs key (`ward_bill_pct` line) | dry-well | proposal (staging) |
| Cold-Marrow Pill (Hàn Tủy Đan); Nine Rods Array (reused) | Pill; formation | Needs key | dry-well (array also first-volley) | proposal (staging) |
| Vụ Đạo: Chìm (Cold Toll, Owed Water, Bare Vessel, Weighted Bucket lines), Hàn Vụ (Ice stack lines, Cold Depths, Cracked Clay) | Đạo pieces | Needs rule / Fits today | dry-well | proposal (staging) |
| Well-Rope (Tỉnh Thằng) | Hidden cluster idea | Needs key | dry-well | proposal (staging) |
| Common Ward, Mountain Screen, Thousand-Layer Cloud | Wards | Fits today (combat-defence.md Formulas H) | dry-well | in the defence GDD |
| Uncarved Stone Fist (Phác Thạch Quyền / Phác Thạch Quyền Kinh) | Technique, body, Huyền and Thiên giai, no arts | Needs key | bare-fist | proposal (staging) |
| Hậu Thổ Địa Quyết, Hậu Thổ Thiên Kinh; Kim Cang Thể, Long Tượng Công | Techniques, main tho; body | Fits today (in the game) | bare-fist | in game data |
| Quarry-Master's Knuckle Rings (Thạch Tượng Quyền Hoàn), base `quyen_hoan` | Named artifact, weapon | Needs key | bare-fist | proposal (staging) |
| Stone-Marrow Pill (Thạch Tủy Đan); Iron-Sand Hand Bath; Nine Rods Array (reused) | Pill; coating; formation | Needs key | bare-fist | proposal (staging) |
| Thể Đạo Không Thủ lines (Stored Breath major, Quiet Channels minor); Thổ Đạo Trần Bích (Settled Dust) | Đạo pieces | Needs key / Fits today | bare-fist | proposal (staging) |
| Porter's Shoulder (Phu Kiên) | Hidden cluster idea | Needs key | bare-fist | proposal (staging) |
| Common Ward, Qi-Scattering Robe, Fire-Shunning Veil, Mountain Screen, Thousand-Layer Cloud, Iron Shirt, Clear Heart Ward, Soul-Guarding Lamp, Still Lake Aura | Wards (in ward slots and art slots) | Fits today (combat-defence.md Formulas H) | bare-fist | in the defence GDD |
| Straw-Man Litany Scripture (Thảo Nhân Chú Kinh) | Technique, main, kim + moc, Địa giai | Needs key | curse-engine | proposal (staging) |
| Slipper Blow, Straw Binding, Iron Nail, Ash of the Effigy, Paper Boat Crossing, Paper Money Burning | Arts (two quick curse arts, the Nail, a curse cleanse, escape, heal) | Needs key | curse-engine | proposal (staging) |
| Insect-Waking Incense (Kinh Trập Hương); Nine Rods Array (reused) | Pill-incense; formation | Needs key | curse-engine | proposal (staging) |
| Coffin-Nail Needles (Quan Đinh Châm) | Artifact, weapon (`cham`, generated, authored flavour) | Fits today | curse-engine | in game data (as a generated base) |
| Sinh Tử Đạo Diệt: Driven Nail major, the Fourth Nail keystone, Marked Prey minor, curse stat lines | Đạo pieces | Needs rule / Needs key | curse-engine | proposal (staging) |
| Nine Knots (Cửu Kết) | Hidden cluster idea | Needs key | curse-engine | proposal (staging) |
| Common Ward, Mountain Screen | Wards | Fits today (combat-defence.md Formulas H) | curse-engine | in the defence GDD |
| Shared-Heart Tiger-Rearing Scripture (Đồng Tâm Dưỡng Hổ Kinh / Thiên Kinh) | Technique, main, moc + hoa, Địa and Thiên giai, no art that touches the enemy | Needs key | beast-carry | proposal (staging) |
| Whistle In, Feed the Fire, Hearth Song, Bark Mantle, Old-Tree Sap, Rouse | Arts (command, two Fire buffs, beast shield, heal, revive) | Needs rule / Fits today (the two Fire buffs) | beast-carry | proposal (staging) |
| Moss-Striped Tiger (Đài Văn Hổ) and its fixed art Moss-Fang Bite | Companion (creature species record), element-tagged | Needs key | beast-carry | proposal (staging) |
| Tiger-Tally Seal (Hổ Phù Ấn) | Named artifact, weapon (`an`), carries Sure Bite | Needs key | beast-carry | proposal (staging) |
| Thú Đạo: Linh Khế (Straining Leash major, Bonded Spirit, Fang and Claw, capstone the Contract), Bầy (companion speed, Pack Hunt, Marked Prey), Thú Thể (Thick Hide); Mộc Đạo Rừng (Rot Seeps In, Fang and Claw) | Đạo pieces | Needs rule / Needs key / Fits today | beast-carry | proposal (staging) |
| Shepherd's Path (Mục Lộ) | Hidden cluster idea | Needs key | beast-carry | proposal (staging) |
| Common Ward, Mountain Screen, Clear Heart Ward | Wards | Fits today (combat-defence.md Formulas H) | beast-carry | in the defence GDD |
| Three Smeltings Canon (Tam Luyện Chân Kinh) | Technique, main, kim + hoa + moc, Địa giai; every damaging art carries its own Physical → Fire 100 % | Needs key | triple-convert | proposal (staging) |
| Green-Smoke Rot Sutra (Thanh Yên Hủ Kinh); Ore-Vein Scripture (Khoáng Mạch Kinh) | Techniques, secret, moc; kim; Địa giai | Needs key | triple-convert | proposal (staging) |
| Ore-Splitting Cut, Bellows Flame, Charcoal Smoke, Third Smelting, Charcoal Poultice, Quench | Arts (four chained hits laying Sundered, Burn, Poison; a heal; a seal cleanse) | Needs key | triple-convert | proposal (staging) |
| Kiln-Hook Sword (Diêu Câu Kiếm) | Named artifact, weapon (`phi_kiem`), carries Blood Drinker | Fits today | triple-convert | proposal (staging) |
| Smelting affixes (Hóa Yên, Thực) | Artifact affix rows | Fits today | triple-convert | proposal (staging) |
| Nine Rods Array (reused); Soot Coating | Formation; coating | Needs key | triple-convert | proposal (staging) |
| Kim Đạo Lò Rèn: Former Shapes major, Slag and Soot and Ore Weight L2 art nodes, the Fourth Smelting keystone | Đạo pieces | Needs rule / Needs key | triple-convert | proposal (staging) |
| Slag Heap (Xỉ Đôi) | Hidden cluster idea | Needs rule (via two-type scopes) | triple-convert | proposal (staging) |
| Thousand-Root Spring Scripture (Thiên Căn Tuyền Kinh / Quyết) | Technique, main, moc + thuy, Địa and Thiên giai; no art hits above 0.69 | Needs key | unkillable | proposal (staging) |
| Underground Spring, Banyan Shade, Shedding Bark; Spring Sap (reused) | Arts (two buff hits, a refunding heal, a curse cleanse) | Needs key / Fits today | unkillable (Spring Sap also two-clocks) | proposal (staging) |
| Banyan-Bark Mantle (Dung Bì Bào) | Named artifact, body armour (`giap`), carries Growth Rings | Fits today | unkillable | proposal (staging) |
| Thousand-Year Sap Pill (Thiên Niên Dịch Đan); Hot Spring Array (by-root, reused) | Pill; formation | Needs key | unkillable | proposal (staging) |
| Mộc Đạo Sinh Trưởng (Surplus Life keystone, Sap Rises, Still Water via Rễ); Sinh Tử Đạo Trường Sinh (Growth Rings) | Đạo pieces | Needs rule / Fits today | unkillable | proposal (staging) |
| Heartwood (Tâm Mộc) | Hidden cluster idea | Fits today | unkillable | proposal (staging) |
| The Salt-Sower (Tát Diêm Giả) | Enemy profile (the counter) | Fits today | unkillable | proposal (staging) |
| Common Ward, Still Lake Aura, Clear Heart Ward, Mountain Screen, Thousand-Layer Cloud, Soul-Guarding Lamp, Golden Bell | Wards | Fits today (combat-defence.md Formulas H) | unkillable | in the defence GDD |
| Hearth-Mountain Scripture (Trạch Sơn Quyết) | Technique, main, tho, Địa giai | Needs key | home-fortress | proposal (staging) |
| Stake-Driving Seal, Warm Stone, Mountain-Press Seal, Landslide, Homeward Step | Arts (three Earth formation seals, a refunding heal, escape) | Needs key | home-fortress | proposal (staging) |
| Mountain-Root Pill (Sơn Căn Đan); Boundary-Stake Talisman (Giới Trụ Phù) | Pill; talisman | Needs key | home-fortress | proposal (staging) |
| Alarm Array (Cảnh Linh Trận); Hộ Sơn Trận (in the game); Hot Spring Array (reused, by-root via unkillable); Nine Rods Array (reused) | Formations (home) | Needs rule / Fits today / Needs key | home-fortress | proposal (staging); Hộ Sơn Trận in game data |
| Challenge Letter (Chiến Thiếp) | Talisman, life use | Needs rule | home-fortress | proposal (staging) |
| Landing Ground (Độ Khẩu Địa) | Ground tag (L4) | Needs key | home-fortress (from 2026-11-07 already-waited) | reused, 2026-11-07 ledger (staging) |
| Threshold Flags (Môn Hạn Kỳ) | Named artifact, utility (`ky`), hosts Threshold Binding | Needs rule | home-fortress | proposal (staging) |
| Trận Đạo: Trận Pháp (Overbuilt Walls major, Pressing Mountain, Laid Stone), Phù Lục (Talisman Sleeve, Primed Talismans), Động Phủ and Hộ Trận (Host's Advantage, Five Preparations, Field Walls, Threshold Binding capstone) | Đạo pieces | Needs rule / Needs key | home-fortress | proposal (staging) |
| Quartermaster's Ledger (Quân Nhu Bạ) | Hidden cluster idea | Needs key | home-fortress | proposal (staging) |
| Common Ward, Mountain Screen, Golden Bell, Soul-Guarding Lamp | Wards | Fits today (combat-defence.md Formulas H) | home-fortress | in the defence GDD |
| Pass-Garrison Armoury Scripture (Quan Khố Chân Kinh / Quan Khố Quyết) | Technique, main, kim (Thiên giai; Địa giai copy) | Needs key | armoury-mind | proposal (staging) |
| Called Blade, Hook and Chain, Peg-Line Cut, Re-Temper, Rack-Wide Volley, Shut the Armoury Door | Arts | Needs key | armoury-mind | proposal (staging) |
| The Pass-Garrison Rack (Quan Ải Binh Giá), new base `gia` | Named artifact, utility | Needs key | armoury-mind | proposal (staging) |
| Kim Đạo Binh Khố: Full Rack and Edge Past the Rack majors, Cold Iron Order notables, `artifact_slots` notable, Garrison Mind capstone | Đạo pieces | Needs rule / Needs key | armoury-mind | proposal (staging) |
| Hồn Đạo: Thần Thức lines and Hồn Hộ lines (reused) | Đạo pieces | Fits today | armoury-mind (made by soul-lance) | reused (staging) |
| Peg Wall (Đinh Bích) | Cluster idea (tree rework region; clusters retired 2026-11-10) | Needs key / Needs rule | armoury-mind | proposal (staging) |
| Soul-Guarding Lamp (Hộ Hồn Đăng); Common Ward; Golden Bell | Wards | Fits today | armoury-mind | in the game (ward catalogue) |
| Capabilities #1 Twin Arms, #2 Divided Divine Sense, #3 Treasure Nurtured Within | Meridian Map capabilities | Fits today | armoury-mind | in the game |
| Whetstone Scripture (Ma Thạch Kinh; Thiên: Ma Thạch Chân Kinh) | Technique (main, kim; Địa and Thiên) | Needs key | one-art | proposal (staging) |
| Grindstone Stroke (Ma Thạch Trảm) | Art | Needs key | one-art | proposal (staging) |
| Single-Notch Sword (Nhất Khuyết Kiếm) | Named artifact, weapon (`phi_kiem`) | Fits today | one-art | proposal (staging) |
| Đại Đạo: Giản, Nhất, Bỏ and the capstone Less Is Everything | Đạo pieces | Fits today / Needs rule (via the Vow) | one-art | proposal (staging) |
| Swept Floor (Tảo Địa) | Hidden cluster idea | Fits today | one-art | proposal (staging) |
| Ore-Vein Scripture; Nine Rods Array; Iron-Sand Hand Bath | Secret art; formation; coating | Needs key | one-art (also triple-convert; six builds; bare-fist, home-fortress, armoury-mind) | reused (staging) |
| Treasure Nurtured Within (capability #3); Common Ward, Mountain Screen, Thousand-Layer Cloud, Golden Bell, Clear Heart Ward, Soul-Guarding Lamp | Capability; wards | Fits today | one-art | in game data / the defence GDD |
| Winnowing Wind Scripture (Dương Khang Phong Quyết) | Technique (main, phong; Địa giai) | Needs key | cooldown-floor | proposal (staging) |
| Chaff Needle, Husk-Splitting Cut, Winnowing Toss, Sieve Palm, Threshing Rain, Empty-Husk Gust, Sweeping the Floor | Arts | Needs key | cooldown-floor | proposal (staging) |
| Granary-Mother's Fan (Thương Mẫu Phiến) | Named artifact, weapon (`phien`) | Fits today | cooldown-floor | proposal (staging) |
| Gale affixes: Tật, Hồi Khí, Hấp Huyết | Artifact affix rows | Needs key | cooldown-floor | proposal (staging) |
| Phong Đạo: Cuồng Phong and Phiêu facets, capstone line | Đạo pieces | Needs rule (via Slipstream, Trigger limit, Eruption) | cooldown-floor | proposal (staging) |
| Threshing Floor (Cốc Trường) | Tree region idea (clusters retired 2026-11-10) | Fits today | cooldown-floor | proposal (staging) |
| Nine Rods Array; Iron-Sand Hand Bath; preparation fight payload; arts fired this instant | Formation; coating; concepts | Needs key / Needs rule | cooldown-floor (also first-volley and others) | reused (staging) |
| Common Ward, Clear Heart Ward; a Cực phẩm needle (`cham`, Liệt) | Wards; artifact | Fits today | cooldown-floor | in the game (defence GDD; item data) |
| Long Winter Thunder Scripture (Trường Đông Lôi Kinh) | Technique (main, loi; Địa giai) | Needs key | slow-thunder | proposal (staging) |
| Far Flash, Thaw Rumble, Rolling Peal, Ice-Breaking Peal | Arts | Needs key | slow-thunder | proposal (staging) |
| Ice-Jam Seal (Phá Lăng Ấn) | Named artifact, weapon (`an`) | Fits today | slow-thunder | proposal (staging) |
| Động Tĩnh Đạo: Tĩnh and Tĩnh Cực Sinh Động facets; Lôi Đạo: Thiên Lôi facet | Đạo pieces | Needs rule (via Thunderhead); Fits today (Thiên Lôi) | slow-thunder | proposal (staging) |
| Winter Breath (Đông Tức) | Tree region idea (clusters retired 2026-11-10) | Fits today (Weighted Bucket needs key) | slow-thunder | proposal (staging) |
| Nine Rods Array; Thunder-Gall Pill; Herald's Banner; held payload; Swept Floor region; empty-art-slot meaning | Formation; pill; artifact; concepts | Needs key / Needs rule | slow-thunder (also first-volley, bare-fist, one-art and others) | reused (staging) |
| Common Ward, Soul-Guarding Lamp, Mountain Screen, Clear Heart Ward; generated `phi_kiem`/`an`, `thuan`, `giap` pieces | Wards; artifacts | Fits today | slow-thunder | in the game (defence GDD; item data) |
| Iron Pestle Scripture (Thiết Xử Quyết; Thiết Xử Chân Kinh) | Technique (main, Huyền and Thiên) | Needs key | giant-killer | proposal (staging) |
| Threaded Needle, Through the Mountain, Bearing the Mountain, Pestle Grind, Last Stitch, Sweeper's Exit | Arts | Needs key | giant-killer | proposal (staging) |
| Forty-Year Needle (Tứ Thập Niên Châm) | Named artifact (`cham`) | Needs rule (Mountain Notches) | giant-killer | proposal (staging) |
| Nghịch Đạo, Vượt Cấp and Nghịch Kiếp facet lines | Đạo pieces | Fits today (graph not drawn) | giant-killer | proposal (staging) |
| Ant's Ladder (Nghĩ Thê) | Tree region idea | Needs key | giant-killer | proposal (staging) |
| Ore-Vein Scripture (reused, secret art) | Technique | as staged | giant-killer (added to Used by) | proposal (staging) |
| Golden Bell, Soul-Guarding Lamp, Common Ward, Clear Heart Ward; generated `giap`, `chuong` pieces | Wards; artifacts | Fits today | giant-killer | in the game (defence GDD; item data) |

## New concepts

| Concept | Rule needed | Serves | State |
|---|---|---|---|
| L5 on ticks (via an enabler) | combat.md Formulas F | two-clocks; any tick build that takes the close | suggestion |
| Stack grant bounded at the charge cap | effects.md Formulas D, AC-EF-69 | every stack art | suggestion |
| Front-loaded batch pricing or floor | effects.md rule 9a, Formulas D | every stack build; cleansing as a counter | suggestion |
| Tick prevented points; cleansed-stacks event | effects.md rule 5 | two-clocks, dry-well, starter-venom | suggestion |
| Opening timer (`opening_haste_pct`) | combat.md rule 13, Formulas A2; modifiers.md Stat List | first-volley, slow-thunder, assassins, soul openers | suggestion |
| Arts fired this instant; enemy firings readable | effects.md rule 5 | first-volley (Eruption, Unanswered), cooldown-floor | suggestion |
| A hit part's earlier types as scope and readable (two-type scopes; history count) | modifiers.md rule 8; effects.md rule 5 | triple-convert; any conversion build | suggestion |
| A third conversion per hit on one keystone | combat-damage-types.md rule 6, Tuning Knobs (safe range 1–3) | triple-convert (optional); Thunder and quad roots | suggestion |
| Ice raising drain bills, for one keystone (Cold Toll) | combat-defence.md Edge Cases and Formulas C; effects.md rule 9a | dry-well; variant-ice builds | suggestion |
| Linh lực debt | combat.md rule 11, Formulas E; combat-defence.md rule 8; effects.md rules 5, 6 | dry-well (Owed Water); two-clocks, soul-lance as second homes | suggestion |
| Pool shortfall and Ice extra-cost readables | effects.md rule 5 | dry-well (Owed Water, Frost Tithe) | suggestion |
| `ward_bill_pct` stat | modifiers.md Stat List; combat-defence.md Formulas C | dry-well; Water Table builds | suggestion |
| A lint charge for curses | combat.md Formulas C; effects.md Formulas D | every curse art (dry-well's Leaking Seal, first-volley's Thunder Needle) | suggestion |
| Soul-art lint (`soul_pct` priced by cost and cooldown) | combat.md Formulas C or E2 | soul-lance and every soul build | suggestion |
| Reference thần thức and soul resistance by realm | combat-defence.md rule 14, Open Question 12 | soul-lance, every soul matchup, NPC Builds | suggestion |
| The linh lực a soul hit takes, as a readable | effects.md rule 5 | soul-lance (Lamp-Oil Siphon), Phệ Đạo soul drain | suggestion |
| Basic attack speed (`basic_speed_pct`) | combat.md rule 13, Formulas A2; modifiers.md Stat List | bare-fist, starter-blade, per-hit-ward breakers | suggestion |
| Flat basic coefficient (`basic_coef_add`) | modifiers.md Stat List; combat.md Formulas C | bare-fist (Heavy Knuckle, Stored Breath's payload), any martial build | suggestion |
| Held payload ("until your next X") | effects.md rule 8 | bare-fist (Stored Breath); any "your next art" Effect | suggestion |
| Linh lực shares read against the usable maximum | effects.md rule 5; combat.md rule 13 guards | bare-fist (Steady Breath, Full Sea with reserved auras); every reserved-ward build | suggestion |
| Your curse cleansed from the target (event; extends the cleansed-stacks event) | effects.md rule 5; combat.md rule 9 | curse-engine (Backlash); two-clocks (Cinder Debt) | suggestion |
| Curse slots +1 for one keystone's owner | combat.md Formulas F (`curse_slots`) | curse-engine (the Fourth Nail); any curse kit | suggestion |
| Curse effect stat (`curse_effect_pct`) | modifiers.md Stat List | curse-engine; dry-well, first-volley, soul-lance | suggestion |
| When a curse starts working (rule now, duration at the next pulse) | combat.md rule 10 | curse-engine (Sealed Meridian in the 0.5 s instant); every curse art | suggestion |
| Beast in the open (a companion bar that shares damage, can be healed and shielded, goes Down and rises) | combat.md rule 19, Formulas J; combat-defence.md rule 16; effects.md rule 5 | beast-carry; Turtle and Snake (by-root), Herd-Child (2026-11-07) | suggestion |
| Redirect the basic attack to the companion (a new Effect action) | effects.md rule 6; combat.md rule 13 | beast-carry (Lent Hand); any keeper who casts nothing | suggestion |
| The companion's timer obeys speed and "move a timer" (`companion_speed_pct`, Bonded Spirit) | combat.md Formulas A2; effects.md rule 6; modifiers.md Stat List | beast-carry; Herd-Child, Guide Hound | suggestion |
| Fire buff's "damage dealt": its layer, and whether companion hits count | effects.md rule 9a, Formulas D; combat.md Formulas B | beast-carry; every Fire buffer | suggestion |
| Element-tagged creature records | creatures_linh_thu.json; effects.md rule 9a | beast-carry; Salamander Keeper, Living Sword, Artisan General (by-root) | suggestion |
| Health overflow (overheal) as a readable | effects.md rule 5 | unkillable (Surplus Life); Spring Rain, Evergreen Wall, any "overheal becomes X" Effect | suggestion |
| Whether granted element stacks roll a status chance | effects.md rule 6, 9a; combat.md Formulas F | unkillable; every Burn and Poison stack build | suggestion |
| `own_abode` ground tag; home-only formations read by Combat (and carried by the Threshold Flags) | combat.md rule 12; Event Engine request (#23, no GDD); `crafting_formations.json` `applies` | home-fortress; sect guardians, Hoàng Đạo and Thần Đạo home grounds, bosses in a lair | suggestion |
| Raising a fight's situation one step (Alarm Array, Challenge Letter) | combat.md rule 12; Event Engine (#23) | home-fortress; every cave-abode owner; Hiệp Đạo duels | suggestion |
| A layer's total before its cap, as a compile readable | effects.md rule 5; combat.md Formulas B | home-fortress (Overbuilt Walls); any L4 or L2 overflow Effect | suggestion |
| A fight payload for pills, coatings and talismans | combat.md rule 12; item-database.md; Alchemy and Talismans quick specs | home-fortress and every staged pill and coating of this run | suggestion |
| How many formations count on one ground, and whose | combat.md rule 12 | home-fortress (home vs away; Taken Ground); level-ground, curse-engine, dry-well (Nine Rods with another array) | suggestion |
| The pieces you control, as a compile readable (`equipped-pieces-readable`) | effects.md rule 5 | armoury-mind (Garrison Mind, Full Rack, Humming Shields); soul-lance, flying-sword builds, NPC armourers | suggestion |
| Thinned Mind: bound thần thức counts only in part for soul defence (`thinned-mind`) | combat.md rule 3, Formulas E2; effects.md rule 6 | armoury-mind (Garrison Mind's close); any treasure-hoard keystone | suggestion |
| A layer's total before its cap (second user) | effects.md rule 5; combat.md Formulas B | armoury-mind (Edge Past the Rack, on L3), with home-fortress | suggestion (home-fortress's) |
| Top-end gear anchor against `equip.max_slots` and thần thức | combat.md Formulas B; combat-defence.md Formulas A0 | the balance harness; every top-end build | suggestion |
| An art coefficient past the lint, from one enabler (`art_coef_add`) | combat.md Formulas C; modifiers.md Stat List | one-art (Vow of the One Stroke); any one-art build | suggestion |
| Measured Stroke's threshold (20 s, unreachable since cooldowns stop at 12 s) | effects.md Starter Effects; combat.md Formulas A2 | one-art; every slow nuke against evaders | suggestion |
| One meaning of "empty art slot" | effects.md rule 5 | one-art (Empty Hall, Clear Path, Undivided, the Vow); bare-fist (Quiet Channels); Bare Rack | suggestion |
| Art cost accepts the dampened op | combat.md Formulas E; modifiers.md Stat List (Art cost) | cooldown-floor (Slipstream); any art-speed build past the floor | suggestion |
| Trigger limit +1 as a rare cap shift | combat.md Formulas G (`trig_cap`); modifiers.md rare table | cooldown-floor; curse-engine, armoury-mind, one-art | suggestion |
| What "a hit landed" means for on-hit sustain (trigger hits, blocked hits) | modifiers.md rule 1, AC-MD-33 | cooldown-floor; every many-hit build | suggestion |
| Overflow is read whole by every Effect that reads it | effects.md rule 5 | slow-thunder (Still Water with Thunderhead); bare-fist (Stored Breath with Still Water) | suggestion |
| A second, capped `art_coef_add` source as a held payload (Thunderhead) | combat.md Formulas C; modifiers.md Stat List; effects.md rule 8 | slow-thunder; one-art (the first source) | suggestion |
| Strike at a shifted fight unit (± half a realm), a new Effects action | combat.md Formulas C, F, G; effects.md rule 6 | giant-killer (Half a Realm); tribulation crossers; Hiệp Đạo duellists | suggestion |
| Readable: higher-realm knockouts this life | effects.md rule 5 | giant-killer (Mountain Notches); bounty hunters; duellist NPCs | suggestion |
| Readable: the target is a boss | effects.md rule 5 | giant-killer (Hóa Thần arc); any boss hunter | suggestion |
| Gap readers stop at two | effects.md rule 5; combat.md Formulas H target | giant-killer; every future vượt cấp Effect | suggestion |
