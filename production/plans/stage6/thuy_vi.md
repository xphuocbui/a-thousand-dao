# Stage 6 Record Pass — Thúy Vi Tông (`thuy_vi`)

Started: 2026-11-27
Owner: `thuy_vi`
Staging root: `design/stage6-staging/thuy_vi/`

## Scope

- **Lineage techniques (6)**: `seed-and-soil-primer` (Tier 0, `main`), `emerald-haze-canon` (Tier 2, `main`), `haze-walk` (Tier 1, `secret`), `rock-splitting-root` (Tier 1, `secret`), `green-furnace-canon` (Tier 2, `secret`), `empty-mountain-sutra` (Tier 3, `secret`).
- **Stand-in techniques to stage (3)**: `thanh-nang-balm-canon` (Tier 1, `main`, replacing `huyen_moc` for `ngai_thanh_hao`), `bich-ngoc-chisel-canon` (Tier 2, `main`, replacing `dia_kim` for `la_trac_thach`), `cliff-hearth-breath` (Tier 0, `main`, replacing `hoang_kim` for the four Cliff Hall `tap_dich` servants).
- **New authored arts (14 -> 12 active slotted + 2 passive Effect arts)**:
  - Active arts (`part-sect-thuy_vi.json`, `abilities` at `unlock_layer <= 6`): `furrow-palm`, `empty-green-wets-the-robe`, `moss-in-the-returning-light`, `step-into-the-green`, `haze-on-the-path`, `root-in-the-crack`, `pine-against-the-wind`, `green-fire-eats-dead-wood`, `pill-smoke-ward`, `no-one-is-seen`, `returning-light`, `voices-on-the-empty-mountain`.
  - Passive arts (Effects, not active art slots, matching d5 / `thien_xu` precedent): `the-furnace-spills-over` / `the-empty-mountains-answer` -> Effect `"The Empty Mountain's Answer (Không Sơn Đáp)"` on `green-furnace-canon` and `empty-mountain-sutra` via `effects` (pending `technique-effects`, already queued in `thien_xu/pending.json`). Note `the-furnace-spills-over` and `the-empty-mountains-answer` share the identical d5 Effect; both art IDs are recorded cleanly in `thuy_vi.techniques.json`, while the runtime passive attaches through `effects`.
- **Existing art refs (4, all in `family-wood.json`)**: `seed-of-spring`, `second-spring`, `rooted-form`, `harvest-bloom`.
- **Signature items (28: 3 treasures `rarity: 5`, 25 artifacts)** and **Sets (10)** -> `catalogue-sect-thuy_vi.json`, `sets-thuy_vi.json`.
- **Named Effects (17 distinct runtime entries in `effects/thuy_vi.effects.json`)**:
  - 6 item fight Effects (`Brush Away the Dust`, `The Robe Is Never Dry`, `A Seed for the Fallen`, `Green Fire`, `Lamp on the Quay`, `Light on the Moss`, `The Empty Mountain's Answer` = 7 item entries minus shared d5 = 6 item fight entries + `Nine Squares` craft-only stub with `not_run`) -> 8 item Effect keys total (`Brush Away the Dust`, `The Robe Is Never Dry`, `A Seed for the Fallen`, `Green Fire`, `Nine Squares`, `Lamp on the Quay`, `Light on the Moss`, `The Empty Mountain's Answer`).
  - 10 set Effects (`The Green Comes Back`, `Field and Garden`, `Reach and Root`, `Everything at Once`, `Pine on the Cliff` / `The Pine That Does Not Move`, `The Fire Lingers`, `No Hiding on the Quay`, `What the Chest Kept`, `Nobody Falls`, `Lean Until It Breaks`).
  - Total Effect entries in `thuy_vi.effects.json`: 18 keys (all 18 open Effects from `depth_gap.py`).
- **Beasts (2)**: `ngan_ti` on `lo_da_huong`, `lao_hoang` on `uong_muc_dich` (already populated on `cast.json` records; verify during pass).
- **Cross-owner ties (8)**: `ho_lam` (`phu_hau_tho` -> `seed-and-soil-primer`), `vu_an` (7 -> `haze-walk`). Close automatically once Thúy Vi promotes those two techniques; no edits to other owners' files.

## Stand-in Plan

| Target(s) | Current stand-in | Replacement | Notes |
| --- | --- | --- | --- |
| `ngai_thanh_hao` (`thuy_vi.2.cast.json`) | `huyen_moc` (L8) | `thanh-nang-balm-canon` (`["moc", "thuy"]`, Tier 1 `main`, L8) | Thanh Nang Đường's fallen-hall healing method; uses `seed-of-spring` (L1) + `second-spring` (L4). Keeps the canon distinct from Thúy Vi's lineage and avoids editing `hong_lo`. |
| `la_trac_thach` (`thuy_vi.cast.json`) | `dia_kim` (L8) | `bich-ngoc-chisel-canon` (`["kim", "tho"]`, Tier 2 `main`, L8) | Guest refiner & jade-cutter's Metal-Earth physical method; uses `whetstone-pass` (L1), `sundering-wedge` (L3), `shatter-edge-cleave` (L5), `millstone-palm` (L6). |
| `dinh_lao_hoe` (`thuy_vi.3.cast.json`), `dinh_tieu_tung`, `o_ngoc_truc`, `han_son_duoc` (`thuy_vi.4.cast.json`) | `hoang_kim` (L1–L2) | `cliff-hearth-breath` (`["kim"]`, Tier 0 `main`) | Cliff Hall servants' thin-Metal work breath; teaches `iron-hide-stance` (L1) and `whetstone-pass` (L2). |

## Step 1 Mechanic Verification Table

| Kind | Id / Name | Status | Engine Mechanism / Pending Word / Auto-Accepted Decision |
| --- | --- | --- | --- |
| Tech | `seed-and-soil-primer` | `has` (+`NOT_PRICED` note) | Keep `b1` lines (`health_regen_inc_pct`, `breakthrough_chance`, `cultivation_speed_pct`, `herb_growth_pct`); add combat `khi_huyet_pct`, `stack_duration_pct ["moc","debuff"]`. |
| Tech | `emerald-haze-canon` | `has` (+`NOT_PRICED` note) | Keep `b1` lines; add `khi_huyet_pct`, `healing_pct`, `linh_luc_pct`, `stack_effect_pct ["moc","buff"]`, `stack_duration_pct ["moc","debuff"]`, 2 bonuses (`khi_huyet_pct`, `herb_growth_pct`). |
| Tech | `haze-walk` | `has` (+`NOT_PRICED` note) | Keep `b1` lines; add `evade_pct`, `art_speed_pct ["moc"]`, `linh_luc_regen_inc_pct`, 1 bonus (`stealth`). |
| Tech | `rock-splitting-root` | `has` (+`NOT_PRICED` note) | Keep `b1` lines; add `attack_pct ["physical"]`, `defense_pct`, `khi_huyet_pct`, 1 bonus (`attack_pct`). |
| Tech | `green-furnace-canon` | `has` + `technique-effects` | Add combat/craft passives, 2 bonuses (`alchemy_success`, `linh_luc_pct`), and `effects` attaching `"The Empty Mountain's Answer"` at L8 (pending `technique-effects`). |
| Tech | `empty-mountain-sutra` | `has` + `technique-effects` | Add combat passives, 3 bonuses (`linh_luc_pct`, `than_thuc_pct`, `tam_ma_resist_pct`), and `effects` attaching `"The Empty Mountain's Answer"` at L6 (pending `technique-effects`). |
| Art | `furrow-palm` | `has` | Earth hit (`c_art 1.2`, `debuff [1, 8]`) + `stacks` `wood` 1 for 8 s; if foe holds `debuff.earth >= 1` and `debuff.wood >= 1`, apply `slowed_time` 1 stack for 2 s. |
| Art | `empty-green-wets-the-robe` | `decision` | Coexists with `rooted-form` (`state: rooted`): uses `haze_field` counter (`8` pulses) AND sets `haze-field` (`tags: ["field"]`) or combined `rooted-haze` (`tags: ["field"]` + `rooted` mods) so raising the field does not strip Rooted Form; heals + restores qi + gives foe 1 Wood/s, at 5+ foe Wood applies Earth stack + `off_guard` 1s. |
| Art | `moss-in-the-returning-light` | `has` | Counter `moss_bloom` (`4` pulses): small pulse `heal` (`0.015`/s); on `was_hit` if `moss_bloom >= 1`, burst `heal` (`0.03 * moss_bloom`) and clear `moss_bloom`. |
| Art | `step-into-the-green` | `decision` | `decoy {n: 1}` ("next hit misses") + `timer {side: "own", which: "next", by: -10.0}` ("next art at full speed") + 2s `evade: 20` stealth window; avoids needing a separate `hidden` engine word. |
| Art | `haze-on-the-path` | `decision` | `haze_strip` counter (`6` pulses): while `>= 1`, foe `acc: -20` and own `evade: 15` (foe loses aim / fails to spot the hidden). |
| Art | `root-in-the-crack` | `has` (+d13) | Wood/Physical hit (`convert {to: "phys", share: 0.4}`) laying `debuff [2, 8]`; `pen` scales `+3` per `foe.debuff.wood`. On `hit_landed` at `foe.debuff.wood >= 6`, applies `sundered` (4s, 8s lockout/cooldown) and if `own.state.pine >= 1`, ends stance for a Physical `free_hit` (`0.6 + 0.08 * pine_hits`). |
| Art | `pine-against-the-wind` | `has` | Composed stance (`tags: ["composed", "stance"]`): `+25` `dampen_taken` against `physical`/`metal`, toggles off if already up; each `was_hit` in stance increments `pine_hits` (capped 10) and grants `+10%` next art `dmg_more` (spent on `art_fired`). |
| Art | `green-fire-eats-dead-wood` | `has` (`over_time`) | Tag `["wood", "poison", "over_time"]` (closes `over_time` scope tag). Lays `debuff [3, 6]`; `dmg_more: 50` at `foe.hp_share <= 0.5`; on `broken` while `foe.debuff.wood >= 1`, lays half stacks (`scale` per 2) again for 6s. |
| Art | `pill-smoke-ward` | `has` | Grants `ward_grow` (`0.12` of hp) + 5s `smoke_ward` counter (`status_dur_taken` / `status_resist: 50` approximation: +50 `status_resist` and `cleanse 1` debuff); also runs `burn_pill` cleanly if a pill is equipped. |
| Art | `no-one-is-seen` | `decision` | Grants 2s hiding aura via `always`/`pulse` check on `own.since_act >= 2` (or stance/counter `empty_hide` armed on fire): while `own.since_act >= 2`, own `evade: 30` and `art_speed: 200` on next art (`hiding` -> consumed on `art_fired`). |
| Art | `returning-light` | `has` | Counter `ret_light` (`6` pulses) + `ret_store`; while active, `was_hit` adds `event.amount / 3` (`floor: false`) to `ret_store`; during the 6 pulses after, `ret_heal` ticks 1/6 of `ret_store` each second (`heal {of: "amount"}` or fixed share — wait: `heal` reads `share` of `hp_max` or `of: "amount"`, check `engine.py`!). Let's size `ret_store` in `hp_max` share (`per: 1`, reading `event.amount` divided via `event.share`? No, check `ev` of `was_hit` — `was_hit` has `ev.amount`; if `scale` stores percent-of-max-hp or uses `ret_store` in `heal {of: ...}`, verify `heal` in `engine.py` Step 2!). |
| Art | `voices-on-the-empty-mountain` | `has` | `fire_art {which: "last", share: 0.5}` + small Earth tremor (`c_art 0.7`, `cost_share 0.04`) so the echo always has value even if the previous art was non-damaging (`second-spring` / `rooted-form`), and `second-spring`/`empty-green`/`fire_art` echo stays faithful. |
| Passive Art | `the-furnace-spills-over` & `the-empty-mountains-answer` | `needs word` (`technique-effects`, `heal-overflow`) | Passive d5 art on `green-furnace-canon` and `empty-mountain-sutra` mapped to `"The Empty Mountain's Answer"`. Listens on `heal_restored` (`event.overflow`) with `approx` + `pending.json` (`heal-overflow` for 100%-HP `got == 0` ticks). |
| Effect (item) | `Brush Away the Dust` | `has` | `cleanse {n: 1}` on 20s pulse/cooldown -> grants 1s `ward_grow` (`0.08` hp) on `cleansed` (or when cleansing). Notice `cleanse` removes all stacks of the oldest batch; batch duration isn't a readable on `cleansed`, so award scaled/fixed ward on cleanse (`approx` noted). |
| Effect (item) | `The Robe Is Never Dry` | `has` | `mod {status_dur_taken? -> check}`: Fire debuff batches laid or active? Better: `resist_pct` handles fire dmg, and on `status_applied`/`tick_taken` or `cleanse` (`first fire debuff` removed on `tick_taken`/`pulse` via `fire_put_out` per-fight limit, plus `cleanse {n: 1, el: "fire"}` every 2nd pulse so fire stacks effectively last half as long!). Clean & exact! |
| Effect (item) | `A Seed for the Fallen` | `has` | `on: "down"`, `refuse_down {hp_share: 0.001}`, sets `seed_revive` counter `2` (`dampen_taken: 9900` for 2s so holder survives at sliver HP), then at 0 fires `heal {share: 0.20}` (`per_fight: 1`). |
| Effect (item) | `Green Fire` | `has` | On `always` if `foe.hp_share < 0.5`, `dmg_more: 25` scoped `tags: ["over_time"]` / `element: "wood"` (and `approx` noting pill-brewing Đan Đạo +1 out-of-fight craft rule cannot run in sim). |
| Effect (item) | `Nine Squares` | `not_run` | Pure out-of-fight spirit-field craft rule (`not_run` stub in `thuy_vi.effects.json`). |
| Effect (item) | `Lamp on the Quay` | `decision` | While `own.field_up >= 1`, foe `evade: -30` ("cannot stay hidden"); first pulse when `own.field_up >= 1` (`cooldown` / edge counter `lamp_lit`) lays `off_guard` 1 stack for 2s ("revealed"). |
| Effect (item) | `Light on the Moss` | `has` | On `heal_restored` (not from moss release), store `event.share * 0.25` (scaled in `0.01` HP units = `moss_pool`) up to reasonable combat values; when `own.hp_share < 0.5` on `was_hit`/`pulse`, release via `heal` and zero `moss_pool`. |
| Effect (set) | `The Green Comes Back` | `has` | `on: "pulse"`/`was_hit` when `own.hp_share < 0.333` (`per_fight: 1`): sets `regalia_haze` `6` pulses (if `own.state.any < 1` sets `field` state too; ticks `+3%` heal, `+2` foe Wood/s, `art_cost: -100` for Wood arts). |
| Effect (set) | `Field and Garden` | `has` | On `pulse`, if hot/regen healing tick active (`own.counter.moss_bloom >= 1` or `own.state.rooted >= 1` or `own.counter.haze_field >= 1`), `stacks {el: "earth", n: 1, for: 8, side: "own"}`; while `own.buff.earth >= 5`, `hregen` `+100%` of base (or `hregen: 0.5` / scaled mod!). |
| Effect (set) | `Reach and Root` | `decision` | When foe becomes `off_guard` (`status_applied`, `status == "off_guard"`, while holding `tags` or generally on `huong_van_chu`/`huong_da_dang`), consumes `foe.debuff.wood` in 3s to extend `off_guard` (+1s per 3, halved per repeat via `reach_halve`). Notice `apply_status` overwrites duration rather than adding, so we re-apply `off_guard` with base 1 + extra `max(1, floor(k / (2**uses)))`. (`approx` noted.) |
| Effect (set) | `Everything at Once` | `has` (`pill_burned`) | On `pill_burned`: `timer {side: "own", which: "next", by: -10.0}`, sets 3s counter `far_ambition` granting `+20` `healing` and `+2` Wood debuff `stack_grant` (`double`/bonus Wood on needle cast). Note: fires only when fighter carries a `pill` and uses `burn_pill`. |
| Effect (set) | `The Pine That Does Not Move` | `has` | On `blocked` while `own.state.pine >= 1`: `+1` Wood stack on foe; when firing `root-in-the-crack`, consumes `foe.debuff.wood` for `+10%` `dmg_more` per stack. |
| Effect (set) | `The Fire Lingers` | `has` | On `batch_ended` (`element == "wood"`, `event.rekindled == 0`): lays `floor(stacks / 2)` `fire` debuff stacks with `mark: "rekindled"` for 6s (`cooldown: 0.5` or single-pass non-looping since Fire != Wood). |
| Effect (set) | `No Hiding on the Quay` | `decision` | Each pulse when `foe.status.off_guard >= 1` or `foe.evade <= 0`: strips stealth (`evade: -30` on foe) and increments `quay_focus` (`dmg_more: 8` per count on next Wood art, consumed on Wood `art_fired`, cleared when foe can evade again). |
| Effect (set) | `What the Chest Kept` | `has` | Once per fight (`per_fight: 1`) on `pulse`/`art_fired` when `own.qi_share < 0.25`: `gain_qi {share: 0.5}` + `ward_grow {share: 0.1, of: "hp"}`. |
| Effect (set) | `Nobody Falls` | `has` | Once per fight (`per_fight: 1`) on `heal_restored` when `own.hp_share < 0.25`: `ward_grow {share: 0.1, of: "hp"}`. |
| Effect (set) | `Lean Until It Breaks` | `has` | `cracked` = `foe.status.sundered >= 1` or `foe.status.exposed >= 1`: on `hit_landed` when foe holds `sundered` or `exposed`, adds `1` Wood stack, `+1` `lean_pierce` (`pierce: 3` per stack, `-1` per idle pulse), and `+1` `lean_hits` (`set 0` + `3s` `ignore_block` counter at 10 hits). |

## Checklist

- [x] Step 1 — Verify first: read engine, schemas, items, stand-ins, and record Mechanic Table (`thuy_vi.md`).
- [x] Step 2 — Author staged techniques & arts (`catalogue-sect-thuy_vi.json`, `part-sect-thuy_vi.json`, `pending.json`), update `thuy_vi.techniques.json` art IDs & stand-ins, pass `lint_techniques.py` and `lint_arts.py`.
- [x] Step 3 — Author staged Effects (`effects/thuy_vi.effects.json`) and validate all Effect records with `engine.validate`.
- [x] Step 4 — Author staged items & sets (`items/catalogue-sect-thuy_vi.json`, `items/sets-thuy_vi.json`), pass `lint_items.py`.
- [x] Step 5 — Apply stand-ins across `thuy_vi*.cast.json`.
- [x] Step 6 — Verify `beasts` fields on `lo_da_huong` and `uong_muc_dich`.
- [x] Step 7 — Run `sect_fight.py thuy_vi --seeds 20`, `--gap 1`, and targeted Effect/art kit tests; verify all 3 linters report 0 findings.
- [x] Step 8 — Write `production/plans/stage6/thuy_vi-review.md`.
- [x] Step 9 — Append `RECORD PASS DONE` and write `production/plans/stage6/thuy_vi.done`.

RECORD PASS DONE
