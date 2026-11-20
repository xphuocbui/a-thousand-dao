# Đạo Đồ Effects in the fight engine (2026-11-20)

Night run, ADR-0004 decision 3 (the user chose "extend the runtime"). Every Effect the v5 map names (43 keystones, 12
crown notables: 55 Effects) has an engine form in `assets/data/combat_effects.json`, written by
`tools/design/dao_do_rework/content/tree_effects.py` from `design/gdd/effects.md` ("Đạo Đồ Effects (content pass,
2026-11-19)" and the Starter Effects the keystones reuse). The game passes a Character's held Effects to the fight by
name (build-file field `tree_effects`); their closing numbers (maximum health -15 % and the like) are stat lines on the
character's sheet. **For the user's review:** the "Engine choice" column lists every place where the rule text left an
engine detail open and a choice was made; the section "Other choices made tonight" lists the rest. All of them
are open to change.

**Totals:** 48 run in full, 3 run with a part Pending, 4 Pending (their host system does not exist inside
fights yet: shown, adding nothing; the keystone's plain modifiers still apply).

## New engine vocabulary (both engines; parity fixtures `tests/parity/fixtures/t9_tree_exact_a.json` and `_b.json`)

- Events: `blocked` (block stopped part of a hit), `buff_gained`, `batch_ended` (a stack batch ran out on its own).
- Mod flags: `no_block`, `ignore_block`, `no_evade`, `no_body_shield`, `speed_locked`, `delay_immune`,
  `no_gain_on_hit`, `sure_crit`, `status_immune` (status filter), `reflect_first`, `counted_crit` (Effects Formulas
  A). Mod values: `ward_pct` (live ward strength), `stack_more` (own buff stacks), `shield_hold` (body-shield bars and
  gains), `overheat` (clipped art speed into L5, capped), `crit_cap_to` (a lower crit cap).
- Readables: `own.evade`, `own.since_hit`, `own.hp_max_lead`, `cycle.<n>`. Filter keys: `is_crit`, `not_tags`,
  `source` (a heal's source: `regen`). Hit events carry the art's `cost`.
- Action `return_damage`; arguments `refuse_down.hp_share`, `refresh.at_least`, `heal.ignore_taken`, `shield.refill`,
  `stacks.mark`. Limits `per_firing`, `scale_per_pulse`.
- Build compile (fight.py `expand_library` and the game's `BuildFileCompiler`; compile-parity cases `tree_00` to
  `tree_09`): `tree_effects`, `tree_lines_on_sheet`, `counts` (`empty_extra_slots`, `carried_sword`, `root_elements`
  from the game; `empty_art_slots`, `art_elements` counted by the compiler), library `count` (`of`, `cap`), `fixed`
  closing records, `lines`, `pool_more`, `stack_alias`, `no_ward`, `only_tag`; `sheet_from` on the game's sheet only.
- Two engine.py fixes on the way: `mod()` evaluates only Effects that carry the key (an Effect scaled by `own.evade`
  recursed through an unrelated key's sum; reads are pure, so no sum changed), and `stack_more` is read with a re-entry
  guard (Rising Tide's linh lực condition would read itself through the pool's own Water stacks).

## Other choices made tonight (to review)

- **"Deal N % less" closings** are a `dmg_more` multiplier (-0.5, -0.3, -0.25, -0.2). For Ten Thousand Poisons the GDD
  names `attack_pct [hit] -25` (L1 points); the multiplier was used instead, so ticks are not touched either way.
- **Open Sky's** `defense_pct +5` per empty extra slot is run as live ward strength (`ward_pct`), counted at compile.
- **Glass Meridians** adds the starter rule's `art_speed_pct +40` on top of the keystone's own plain +41.6 % art speed
  (the content's positive side). If the content pass meant the 41.6 to replace the 40, remove the 40 line.
- **Burning Lifespan** runs its fury without its closing (the lifespan the fight burns needs a host), while the four
  fully Pending Effects add nothing at all.
- **Counts:** a sword artifact is a piece on the `phi_kiem` base (`dao_do_tree.json sword_bases`); "elements your root
  owns" (Before Heaven) is the base element count; `speed_locked` also ignores buff-stack speed.
- **Map rules in the loader:** another start can be opened as a 1-point path node (no bonus); the player may move the
  start with `tree start <element>` until the first Dao mark; the Ice start's figure scales as Water land (ADR-0004).

## Behaviour check (`tools/design/combat_sim/tree_effects_check.py`)

Every runnable Effect fought with and without on the same seeds (a Deity Transformation kit with Burn, Poison, Ice,
Water and Wood buff, Metal, Earth and sword arts, evade, crit and block, against the typical enemy): 43 change fights
in that kit. Of the rest, Ageless Pine, Burning Lifespan, Still Water, Nirvana and Tide change fights in a closer
matchup or with Water damage arts. Three do nothing yet for a known reason: **Daybreak** (no art carries the `light`
tag), **Eruption** (no costly Fire art in the library), **Immovable Mountain** (only matters against Slowed Time,
delays and art-speed modifiers, none in the kit). Bare Rack's companion half did nothing (fixed, see its row).

## Scoped lines in fights (`export_game.py --check`)

About 2,900 scoped tree lines run scoped. **38 apply to every hit**, because their engine key is read without a hit
context (33 `linh_luc_on_hit_pct`, 5 `leech_linh_luc_pct`), and **257 match nothing yet**: `attack_pct [over_time]`
78 (ticks never read L1), `[light]` 110 (no Light arts), `[formation]` 47 (no formations in fights), `status_resist_pct
[burn]` 2.

## Every Effect

| Effect | Node kind | Nodes | Status | New vocabulary it uses | Engine choice (to review) |
|---|---|---|---|---|---|
| Ageless Pine (Vạn Niên Tùng) | keystone | #9002 | Runs | `buff_gained` |  |
| Alchemist's Heart (Đan Tâm) | keystone | #2978 | **Pending** (host outside fights): pills are not taken inside fights yet (Alchemy: pill use in combat has no host) | today's vocabulary |  |
| Autumn Harvest (Thu Hoạch) | keystone | #4786 | Runs | today's vocabulary |  |
| Bare Rack (Không Giá) | keystone | #6497 | Runs, part Pending: the [basic] half, until Combat adopts the basic tag (#43; re-review EF 24) | `count empty_art_slots` | companion hits skip the damage layers, so L5 +5 a slot is run as 5 % more damage a slot |
| Boundless Sea (Vô Biên Hải) | keystone | #5585 | Runs | `no_gain_on_hit`, `pool_more` |  |
| Burning Lifespan (Nhiên Thọ) | keystone | #2893 | Runs, part Pending: the lifespan the fight burns: the fight result does not report years yet (Realms / Time & Turn host) | today's vocabulary |  |
| Called Blow (Báo Chiêu) | keystone | #4678 | Runs | `counted_crit`, `crit_cap_to` |  |
| Earth Vein Tap (Địa Mạch Dẫn) | keystone | #3839 | **Pending** (host outside fights): formations do not stand inside fights yet (Formations host) | today's vocabulary |  |
| Earthen Armour (Thổ Giáp) | keystone | #9010 | Runs | `own.since_hit`, `refill` | 10 % of the starting bar a pulse, up to the starting bar |
| Ebb Tide (Triều Rút) | keystone | #9004 | Runs | today's vocabulary | checked after each art you fire and each hit you take |
| Ever-Burning Furnace (Vĩnh Nhiên Lô) | keystone | #2892 | Runs | `scale_per_pulse` |  |
| Fire Feeds Fire (Dĩ Hỏa Dưỡng Hỏa) | keystone | #8998 | Runs | `at_least` | each hit you land keeps every Burn batch of yours on the foe until at least 3 s later |
| Fire Lotus (Hỏa Liên) | keystone | #9008 | Runs | today's vocabulary | the two stacks last 6 s, a typical Fire art's Burn batch |
| Flowing Water (Lưu Thủy) | keystone | #5507 | Runs | today's vocabulary |  |
| Frost Seal (Băng Phong) | keystone | #9001 | Runs | today's vocabulary |  |
| Glass Meridians (Lưu Ly Kinh Mạch) | keystone | #8996 | Runs | `shield_hold` |  |
| Heaven's Eye (Thiên Nhãn) | keystone | #8994 | Runs | `is_crit` |  |
| Hidden Moon (Ẩn Nguyệt) | keystone | #8997 | Runs | `no_block`, `no_body_shield`, `own.evade` |  |
| Hundred Refinements (Bách Luyện) | keystone | #9012 | Runs | `sheet_from` |  |
| Immovable Mountain (Bất Động Sơn) | keystone | #3838 | Runs | `speed_locked`, `delay_immune`, `status_immune` |  |
| Keen Edge (Lợi Phong) | keystone | #9000 | Runs | `no_block`, `ignore_block` |  |
| Layered Earth (Hậu Thổ Tích) | keystone | #8999 | Runs | `blocked`, `no_evade`, `ward_pct` | defence is ward strength, read live (ward_pct) |
| Metal Begets Water (Kim Sinh Thủy) | keystone | #9011 | Runs | today's vocabulary | the stack lasts 10 s, a typical Water art's buff batch |
| Mountain's Weight (Sơn Nhạc Trọng) | keystone | #9009 | Runs | `own.hp_max_lead` |  |
| Nirvana (Niết Bàn) | keystone | #9007 | Runs | `hp_share` |  |
| No Ward (Vô Hộ) | keystone | #3727 | Runs | `no_ward` |  |
| Open Sky (Không Thiên) | keystone | #3726 | Runs | `ward_pct`, `count empty_extra_slots` |  |
| Overheat (Quá Nhiệt) | keystone | #2979 | Runs | `overheat` |  |
| Returning Wave (Hồi Lãng) | keystone | #9014 | Runs | `reflect_first` | the hit's damage before your defence strikes the foe through its defence |
| Rising Tide (Triều Dâng) | keystone | #9003 | Runs | `stack_more` | your own Water buff stacks; the half reads linh lực without the stacks' own pool bonus |
| Spirit Garden (Linh Viên) | keystone | #6496 | **Pending** (host outside fights): spirit fields and seasons are outside fights (Spirit Herbs & Spirit Fields host); its closing waits with it | today's vocabulary |  |
| Still Water (Tĩnh Thủy) | keystone | #5508 | Runs | `ignore_taken` |  |
| Strangling Vines (Đằng Triền) | keystone | #9015 | Runs | today's vocabulary |  |
| Sun That Never Sets (Bất Lạc Nhật) | keystone | #8995 | **Pending** (host outside fights): seasons and đạo tâm are outside fights (Cultivation / Time & Turn host); its closings wait with it | today's vocabulary |  |
| Sun and Rain (Nhật Vũ) | keystone | #6619 | Runs | `source` |  |
| Ten Thousand Poisons (Vạn Độc) | keystone | #6618 | Runs | today's vocabulary |  |
| Ten Thousand Swords Return (Vạn Kiếm Quy Tông) | keystone | #4677 | Runs | `count carried_sword`, `only_tag` |  |
| Thousand Talismans (Thiên Phù) | keystone | #5586 | Runs, part Pending: talisman stock: the rule switches on with the Talismans GDD (the closing runs now) | `not_tags` |  |
| Unyielding Breath (Bất Khuất) | keystone | #4787 | Runs | today's vocabulary |  |
| Utmost Yang (Dương Cực) | keystone | #9005 | Runs | `count art_elements` |  |
| Utmost Yin (Âm Cực) | keystone | #9006 | Runs | `count art_elements` |  |
| Water Begets Wood (Thủy Sinh Mộc) | keystone | #9013 | Runs | `stack_alias` |  |
| Wood Begets Fire (Mộc Sinh Hỏa) | keystone | #9016 | Runs | `stack_alias` |  |
| Before Heaven (Tiên Thiên) | notable | #8197 | Runs | `count root_elements` |  |
| Burning Ground (Địa Hỏa) | notable | #3366 | Runs | `per_firing` |  |
| Dark of the Moon (Sóc Ám) | notable | #7381 | Runs | `sure_crit` |  |
| Daybreak (Phá Hiểu) | notable | #6779 | Runs | today's vocabulary | a Light hit is a hit of an art tagged light (no art in the library carries it yet) |
| Eruption (Bộc Phát) | notable | #2739 | Runs | today's vocabulary |  |
| First Thunder (Tiên Lôi) | notable | #7959 | Runs | today's vocabulary |  |
| Grinding Weight (Trọng Ma) | notable | #3327 | Runs | `per_firing` |  |
| Heaven's Verdict (Thiên Phán) | notable | #8096 | Runs | today's vocabulary |  |
| Reflection (Phản Chiếu) | notable | #4947 | Runs | today's vocabulary |  |
| Thorns (Đảo Thích) | notable | #6252 | Runs | `blocked`, `return_damage` | the returned damage meets the attacker's defence |
| Tide (Thủy Triều) | notable | #5012 | Runs | `cycle.6` | a triangle over 6 pulses: 0, 6.67, 13.33, 20, 13.33, 6.67 |
| Wildfire (Dã Hỏa) | notable | #2642 | Runs | `batch_ended`, `mark` |  |
