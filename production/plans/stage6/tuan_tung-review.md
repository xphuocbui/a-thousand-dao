# Tuần Tùng Đường (`tuan_tung`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in [design/stage6-staging/tuan_tung/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tuan_tung/); nothing exported, nothing written outside allowed paths):**
- **3 techniques** ([catalogue-sect-tuan_tung.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tuan_tung/techniques/catalogue-sect-tuan_tung.json)): `pine-warden-staff-and-bow-canon` (Profound main, `names: []`), `three-nights-on-the-road` (Profound secret, `names: []`), and `wolf-winter-arrow` (Profound secret, `names: []`). Existing outer body method `unbroken-flesh-canon` is already in [catalogue-body.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/techniques/catalogue-body.json). New bonuses and passives are sized to Tier 1 budgets (§C) while preserving `b1` + `b10` passives on `pine-warden-staff-and-bow-canon`.
- **3 new active arts + 1 passive art** ([part-sect-tuan_tung.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tuan_tung/arts/part-sect-tuan_tung.json)): `wolf-ring`, `second-night` (`d3`), and `the-leader-first` (`a1, b10`), all element-free (`element: ""`, `kind: "phys"`). The passive art `Geese Line (Nhạn Hàng)` (`d17`) is staged as layer-2 technique Effect `Warden Geese Line` on `pine-warden-staff-and-bow-canon` (`technique-effects`). Art IDs were inserted into [tuan_tung.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/tuan_tung.techniques.json). Existing library arts `pinning-arrow` and `nocked-arrow` ([family-blade.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/arts/family-blade.json)) are referenced unchanged.
- **4 Effects** ([tuan_tung.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tuan_tung/effects/tuan_tung.effects.json)): `Warden Geese Line` (`pine-warden-staff-and-bow-canon` L2 passive), `The Pack Turns` (`ttg-wolf-winter-bow`), `Ring for the Wardens` (`ttg-caravan-bell`), and `Dawn Shot` (`ttg-three-nights` full set). Every Effect declares every counter it reads or writes locally (`STANDALONE_OK 4`).
- **3 signature items and 1 set** ([items/catalogue-sect-tuan_tung.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tuan_tung/items/catalogue-sect-tuan_tung.json), [sets-tuan_tung.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tuan_tung/items/sets-tuan_tung.json)): `ttg-wolf-winter-bow` (`cham` 3), `ttg-caravan-bell` (`chuong` 3), `ttg-three-nights-coat` (`giap` 2), and set `ttg-three-nights` (2 pieces). All 3 carry `sources: ["npc"]`, `unique: true`, and the R6 `exception` mark.
- **0 stand-ins, 0 early promotions, 0 pending words** (`pending.json` not needed). **1 beast** (`thuong_muc` in [tuan_tung.beasts.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/tuan_tung.beasts.json)) is already wired on `diem_lac_nhan.beasts` in [tuan_tung.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/tuan_tung.cast.json).

**Checks (after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\tuan_tung`):**
- `lint_arts.py design/stage6-staging/tuan_tung/arts/part-sect-tuan_tung.json`: **3 arts, 0 findings**.
- `lint_techniques.py design/stage6-staging/tuan_tung/techniques/catalogue-sect-tuan_tung.json`: **3 techniques, 0 findings** (`NOT_PRICED` note on `can_cot 1.33`).
- `lint_items.py design/stage6-staging/tuan_tung/items/catalogue-sect-tuan_tung.json`: **3 items (`unique 3 of 3`), 0 findings**.
- `depth_check.py --quiet`: **findings: none**.
- `depth_gap.py --sect tuan_tung`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 18/19 runs` (`can_cot` rule text).
- `spatial_words_check.py`: **0 hits** in `design/stage6-staging/tuan_tung/`.
- Standalone `engine.validate`: **STANDALONE_OK 4**.
- `sect_fight.py tuan_tung --seeds 5` (`--gap 0`, `--gap 1`, plus `--people` for the 5 outer `unbroken-flesh-canon` disciples) + 10-seed targeted probes: **0 REFUSED across all 16/16 living members**, every slotted art fires, and every Effect runs and changes the fight.

**Counts:**
- **Deviations:** `7` (§C–§F).
- **Decisions taken for the user:** `6` (§A).
- **Pending words:** `0`.
- **Early promotions:** `0`.
- **Never ran in `sect_fight.py`:** `0` at `--gap 0` (all 4 Effects ran in default `sect_fight.py` at `--gap 0`). At `--gap 1`, `The Pack Turns` reports `runs 0 NEVER_RAN` only because `hua_van_cung` (`truc_co`) falls at `10.1 s` before the `ket_dan` typical foe crosses `<= 25 %` HP (`broken`); verified active at `--gap 0` (`5` runs, `15.3 s 100 %` vs `15.1 s 99 %`) and in `PROBE_GLOW_30` (`10` runs).

**Open items (for serial step / Stage 7):**
- Serial merge of `design/stage6-staging/tuan_tung/` into `design/` and `assets/data/combat_effects.json`, followed by exporters (`export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, `export_world.py --sect tuan_tung` to close `thuong_muc` beast and `N-tuan_tung-01..02` events).
- `b10` `["bow"]` scope: restore `scope: ["bow"]` on `pine-warden-staff-and-bow-canon` (`attack_pct`, `crit_damage_pct`) and `ttg-wolf-winter-bow` (`attack_pct`) once `"bow"` enters `lint_techniques.py` `TIER` (currently mapped to `["physical"]`).
- Out-of-fight `can_cot 1.33` on `pine-warden-staff-and-bow-canon` has no `StatSheet` / `fight.py` reader yet (`depth_gap.py` `lines: 1` open).
- Item DB base gap (pre-existing note): no dedicated bow or staff base exists in `bases.json`, so `ttg-wolf-winter-bow` remains on `cham`.

---

## §A Auto-Accepted Decisions (user rule 2026-11-26), with reasons

1. **Adapt `Geese Line (Nhạn Hàng)` (`d17`) under the distinct Effect key `"Warden Geese Line"` (`technique-effects`, layer 2).**
   - *Choice:* Name `tuan_tung`'s `d17` passive art `"Warden Geese Line"` (unlock layer 2 on `pine-warden-staff-and-bow-canon`) and adapt multi-fighter ally counting (`postponed-2026-11-26.json`) into 3 1v1 anchors (`warden_brace` on Pine Warden art fired, `ring_wardens` from `ttg-caravan-bell`, `warden_companion` on companion hit/evade, `+8 block` each).
   - *Reason:* `"Geese Line"` is already claimed in [combat_effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/assets/data/combat_effects.json) by `world-depth:nhan_tran` (checking Nhạn Trận counters `banner_planted` / `geese_stance`), and `put_effects.py` refuses duplicate Effect keys across sources. Naming it `"Warden Geese Line"` avoids any clash, runs on every `tuan_tung` layer-2+ warden (`+8` solo, `+16` with `ttg-caravan-bell` or `thuong_muc`), and preserves `d17`'s intent cleanly.
2. **Map `b10` `scope: ["bow"]` to `["physical"]` in staged technique/item catalogues while keeping `"bow"` in art `tags`.**
   - *Choice:* Map `pine-warden-staff-and-bow-canon` `attack_pct 6` / `crit_damage_pct 20` and `ttg-wolf-winter-bow` `attack_pct 21` from `["bow"]` to `["physical"]`, and keep `"tags": ["bow", ...]` on `the-leader-first` (alongside library arts `pinning-arrow` and `nocked-arrow`).
   - *Reason:* `lint_techniques.py` (and `lint_items.py`) does not yet include `"bow"` in `TIER` (`SCOPE` finding), whereas `"physical"` is valid, matches the pre-`b10` bow modifier scope, and passes both linters with 0 findings (matching `b02`/`b03` `["song"]` -> `["soul"]` precedent).
3. **Use `names: []` directly on all 3 element-free techniques (`lint-element-free-techniques`) and size Tier 1 bonuses/passives to budget.**
   - *Choice:* Keep `names: []` on all 3 techniques (all carried arts have `element: ""`), add 1 Tier-1 bonus each (`khi_huyet_pct 10` on `pine-warden-staff-and-bow-canon` and `three-nights-on-the-road`, `attack_pct 10` on `wolf-winter-arrow`), preserve `b1` + `b10` passives verbatim on `pine-warden-staff-and-bow-canon`, and size new passives on `three-nights-on-the-road` (`16.0 W of 16`) and `wolf-winter-arrow` (`15.8 W of 16`).
   - *Reason:* Matches `b02` `lint-element-free-techniques` and Tier 1 (`16 W`, `bonus_count: 1`) catalogue norms; `pinning-arrow`, `nocked-arrow`, `wolf-ring`, `second-night`, and `the-leader-first` fit cleanly in `<= 5` active slots (`<= MAX_ARTS = 6`) for all holders.
4. **Implement `second-night` (`d3`) as an active breathing heal (`c_heal: 0.6`, `cd: 6.0`) carrying the `glow_clock` pulse/hit counters and `>= 30 s` sustain/damage bonuses.**
   - *Choice:* Advance `glow_clock` by `+1` per pulse and `+1.5` per damaging `was_hit` (`event.amount > 0`, matching `lac_ha`'s `The Glow Deepens`); at `glow_clock >= 30`, heal `1.5 %` max HP/pulse and grant `+15 %` `dmg_more` to `tags: ["staff"]` and `tags: ["bow"]` (two separate `always` records).
   - *Reason:* `lint_techniques.py` requires every technique to carry an active ability in `abilities`. Giving `second-night` a `c_heal: 0.6` active cast ensures it always contributes even in short (`< 20 s`) fights while unlocking full `d3` sustain and staff/bow damage in longer fights (`PROBE_GLOW_30`: `153` regen runs, `+6.6 %` HP left, `-1.5 s`).
5. **Implement `the-leader-first` and `The Pack Turns` using `marked_leader`, `bypass: 0.25 [bow]`, and `on: "broken"` `slowed_time` / `stop_clock 3 s`.**
   - *Choice:* `the-leader-first` sets `marked_leader = 1` on `art_fired`, grants `always` `bypass: 0.25` scoped to `tags: ["bow"]` while `marked_leader >= 1`, and applies 2 `slowed_time` (4 s) on `broken`; `The Pack Turns` runs `stop_clock {side: "foe", seconds: 3.0}` on `broken` when `marked_leader >= 1`.
   - *Reason:* `bypass` is in `CTX_MODS` (scoping cleanly to `bow` arts), and `engine.py` has no foe-`creature` tag readable, so running `stop_clock 3 s` on any marked foe falling to `25 %` HP keeps `The Pack Turns` active in duels against cultivators as well as beasts.
6. **Implement `Ring for the Wardens` on a 10 s pulse cooldown (`ring_wardens`, `each_for: 3`) and `Dawn Shot` at `1.5 %/s` `dmg_more` + `0.25` `[bow]` `bypass`, plus `unique: true` and R6 `exception` on all 3 signature items.**
   - *Choice:* `Ring for the Wardens` triggers `ring_wardens` (`each_for: 3`) every 10 s (`dampen_taken: 20` and `dmg_more: 0.2` for `kind: "companion"`). `Dawn Shot` increments `dawn_wait` per pulse, resets on `the-leader-first` `hit_landed`, and while `marked_leader >= 1` grants `+1.5 %/s` `dmg_more` on `the-leader-first` (matching `15 %` per `10 s` without rounding 6 s casts down to `0 %`) and `+25 %` `bypass` on `[bow]` (`0.50` total with `the-leader-first`, hitting `bypass_cap`).
   - *Reason:* `ttg-caravan-bell` uses the `chuong` common ward under R6 rather than an active bell art, so the 10 s pulse cadence makes the bell rally reliably in combat; `1.5 %/s` scaling keeps `Dawn Shot` responsive across `6 s` `the-leader-first` cooldowns.

---

## §B Mechanic Table (Step 1)

`spatial_words_check.py --sect tuan_tung`: flagged `Geese Line` (`Pieces`, `allies`, `ally`) in `tuan_tung.techniques.json` (`d17`, `postponed-2026-11-26.json`) and `"on breath alone"` in `three-nights-on-the-road`'s concept. Staged files in `design/stage6-staging/tuan_tung/` have **0** spatial hits.

| Record | Mechanic | Engine Status | Staged Implementation |
|---|---|---|---|
| `pine-warden-staff-and-bow-canon` / `wolf-ring` | Physical staff hit + delay foe's soonest ready art `0.5 s` | Has (`timer` `which: "next"`) | `c_art: 1.5`, `cd: 3.5`, `tags: [physical, staff, ward]`, `hit_landed` (`per_pulse: 1`) `timer {side: foe, which: next, by: 0.5}` |
| `pine-warden-staff-and-bow-canon` / `Warden Geese Line` (`d17`) | +8 block per anchor beyond self | Rewritten 1v1 + renamed (avoids `nhan_tran` `Geese Line` clash) | `warden_brace` (canon art fired), `ring_wardens` (bell rally), `warden_companion` (companion hit/evade); `always` `+8 block` each |
| `three-nights-on-the-road` / `second-night` (`d3`) | `glow_clock` (`time + 1 s / 2 % HP lost`); at `>= 30 s`, regen + staff/bow dmg | Has (`glow_clock` pattern from `lac_ha`) | `c_heal: 0.6`, `cd: 6.0`; `glow_clock` (`+1/pulse`, `+1.5/damaging was_hit`); at `>= 30`: `heal 0.015`/pulse + `always` `dmg_more 0.15` (`[staff]`, `[bow]`) |
| `wolf-winter-arrow` / `the-leader-first` (`a1, b10`) | Mark foe; bow arts bypass ward; on Broken, `slowed_time` ×2 | Has (`bypass`, `broken`, `slowed_time`) | `c_art: 2.0`, `cd: 6.0`, `tags: [physical, bow, heavy]`; `marked_leader = 1` on `art_fired`; `always` `bypass: 0.25 [bow]`; `broken` `slowed_time 2 (4 s)` |
| `The Pack Turns` (`ttg-wolf-winter-bow`) | Marked creature foe Broken -> foe arts wait 3 s | Approx (no foe `creature` tag readable) | `on: "broken"` (`marked_leader >= 1`) -> `stop_clock {side: foe, seconds: 3.0}` |
| `Ring for the Wardens` (`ttg-caravan-bell`) | 3 s `-20 %` dmg taken & companions `+20 %` dmg | Approx (no active bell-ring art) | `on: "pulse"` (`cd: 10`) -> `ring_wardens` (`each_for: 3`); `always` `dampen_taken: 20` & `dmg_more: 0.20 [kind: companion]` |
| `Dawn Shot` (`ttg-three-nights` 2pc) | Marked foe: `+15 % / 10 s` since last arrow + pierce wards | Has (`bypass`, `dmg_more`, `scale`) | `dawn_wait` `+1/pulse` (reset on `the-leader-first` `hit_landed`); while `marked_leader >= 1`: `+1.5 %/s` `dmg_more` on `the-leader-first`, `bypass: 0.25 [bow]` |

---

## §C Techniques (`design/stage6-staging/tuan_tung/techniques/catalogue-sect-tuan_tung.json`)

`lint_techniques.py`: **3 techniques, 0 findings** (`NOT_PRICED` note on `can_cot`).

| Technique | Tier, Kind | Bonuses (NEW) | Passives | Arts / Effects (Unlock) | W Used / Budget |
|---|---|---|---|---|---|
| `pine-warden-staff-and-bow-canon` | 1 / `main` | `khi_huyet_pct 10` | `khi_huyet_pct 6.6 []` (`b1`), `can_cot 1.33 []` (`b1`), `health_regen_inc_pct 13.3 []` (`b1`), `attack_pct 6 [physical]` (`b10` proxy), `crit_damage_pct 20 [physical]` (`b10` proxy) | `pinning-arrow` (1), `wolf-ring` (2), `nocked-arrow` (4); passive Effect `Warden Geese Line` (2) | `NOT ASSESSED` (`17.55 W` priced + `can_cot`) |
| `three-nights-on-the-road` | 1 / `secret` | `khi_huyet_pct 10` | **NEW:** `health_regen_inc_pct 16 []`, `khi_huyet_pct 8 []`, `status_resist_pct 8 []`, `block_rating 8 []` | `second-night` (1) | `16.0 W of 16` |
| `wolf-winter-arrow` | 1 / `secret` | `attack_pct 10` | **NEW:** `attack_pct 6 [physical]`, `crit_chance_pct 5 [physical]`, `accuracy_pct 8 []`, `pierce_pct 3 []` | `the-leader-first` (1) | `15.8 W of 16` |

---

## §D Arts (`design/stage6-staging/tuan_tung/arts/part-sect-tuan_tung.json`)

`lint_arts.py`: **3 arts, 0 findings**.

| Art | Depth Text | Engine Form | Deviation |
|---|---|---|---|
| `wolf-ring` | Full turn of the staff that strikes the foe and its soonest art waits `0.5 s` | Physical `c_art 1.5`, `cost 0.03`, `cd 3.5`, `tags: [physical, staff, ward]`; `hit_landed` (`per_pulse: 1`): `timer {side: foe, which: next, by: 0.5}` | none |
| `second-night` | Once `glow_clock` (`time + 1 s / 2 %` HP lost) passes 30 s, regen HP/s and staff/bow arts deal more dmg | Physical heal `c_heal 0.6`, `cost 0.04`, `cd 6.0`, `tags: [physical, heal]`; `glow_clock` (`+1/pulse`, `+1.5/damaging was_hit`); at `>= 30`: `heal 0.015`/pulse + `always` `dmg_more 0.15` (`[staff]`, `[bow]`) | **D1:** Added active `c_heal 0.6` cast so `second-night` contributes before `glow_clock >= 30`; `glow_clock` advances `1.5 s` per damaging hit (matching `lac_ha`) |
| `the-leader-first` | Marks the foe; arrows ignore part of its ward; when Broken, gains 2 Slowed Time stacks | Physical `c_art 2.0`, `cost 0.05`, `cd 6.0`, `tags: [physical, bow, heavy]`; `art_fired` sets `marked_leader = 1`; `always` (`marked_leader >= 1`) `bypass: 0.25 [bow]`; `broken` `slowed_time 2 (4 s)` | **D2:** Pinned ward ignore as `bypass: 0.25 [bow]` and `slowed_time` duration `4 s` |

---

## §E Effects (`design/stage6-staging/tuan_tung/effects/tuan_tung.effects.json`)

All 4 Effects pass standalone `engine.validate` (`STANDALONE_OK 4`).

| Effect (Source) | Depth Rule | Engine Form | Deviation |
|---|---|---|---|
| `Warden Geese Line` (`pine-warden-staff-and-bow-canon` L2) | `Geese Line (d17)`: +8 block per ally beyond self | `warden_brace` on canon `art_fired`; `warden_companion` on companion `hit_landed`/`was_evaded`; `always` `+8 block` per active `warden_brace` / `ring_wardens` / `warden_companion` | **D3:** Renamed from `Geese Line` (owned by `nhan_tran`) and adapted 1v1 using warden file, bell rally, and companion anchors |
| `The Pack Turns` (`ttg-wolf-winter-bow`) | Marked foe Broken -> creature foe's arts wait 3 s | `on: "broken"` (`marked_leader >= 1`): `stop_clock {side: foe, seconds: 3.0}` | **D4:** Triggers on any marked foe Broken (`engine.py` has no foe `creature`-tag readable) |
| `Ring for the Wardens` (`ttg-caravan-bell`) | Ringing bell: 3 s `-20 %` dmg taken & companions `+20 %` dmg | `on: "pulse"` (`cd: 10`): `ring_wardens` (`each_for: 3`); `always` (`ring_wardens >= 1`): `dampen_taken: 20` and `dmg_more: 0.20 [kind: companion]` | **D5:** Rings on 10 s pulse cooldown (`ttg-caravan-bell` uses `chuong` common ward under R6) |
| `Dawn Shot` (`ttg-three-nights` 2pc) | Next arrow at marked foe: `+15 % / 10 s` since last such arrow + pierce wards; resets on hit | `dawn_wait` `+1/pulse` (reset on `the-leader-first` `hit_landed`); while `marked_leader >= 1`: `+1.5 %/s` `dmg_more` on `the-leader-first` (`scale per: 1`), `bypass: 0.25 [bow]` | **D6:** Continuous `+1.5 %/s` scaling avoids rounding 6 s casts to `0 %`; ward pierce pinned as `bypass: 0.25 [bow]` |

---

## §F Items and Sets (`items/catalogue-sect-tuan_tung.json`, `sets-tuan_tung.json`)

- **3 items** (`sources: ["npc"]`, `unique: true`, R6 `exception` on all 3): `ttg-wolf-winter-bow` (`cham` 3, `blade`, `38.8 W`, **D7:** `attack_pct 21 [bow]` mapped to `["physical"]` lint proxy), `ttg-caravan-bell` (`chuong` 3, `body`, `26.8 W`), `ttg-three-nights-coat` (`giap` 2, `body`, `14.8 W`).
- **1 set** (`ttg-three-nights`, 2 pieces): `health_regen_inc_pct 10`, `accuracy_pct 6`, full-set Effect `Dawn Shot (Lê Minh Xạ)`.

---

## §G Stand-ins and Beasts

- **Stand-ins:** `0` (all 16 living members already use `pine-warden-staff-and-bow-canon` or `unbroken-flesh-canon`).
- **Beasts:** `thuong_muc` (`tuan_tung.beasts.json`) is already wired on `diem_lac_nhan.beasts` in `tuan_tung.cast.json`.

---

## §H Pending Words

None (`[]`).

---

## §I Holder Table (`sect_fight.py tuan_tung --seeds 5`, `--gap 0` & `--gap 1`, + targeted 10-seed probes)

**0 REFUSED across all 16/16 living members; every slotted art fires.**

| Holder / Probe | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects / Art fires |
|---|---|---|---|---|---|
| `hua_van_cung` | `truc_co` | `pinning-arrow`, `wolf-ring`, `nocked-arrow`, `the-leader-first`, `second-night` | 15.3 s, 5/5, 100 % | 10.1 s, 0/5, 0 % | All 5 arts fire (4.8/4.2/4.8/2.0/2.0 G0; 3.0/2.0/3.0/1.0/1.0 G1). `Warden Geese Line`: 5 G0 / 5 G1. `The Pack Turns`: 5 G0 (`15.3 s 100 %` vs `15.1 s 99 %`), 0 G1 (foe > 25 % HP). `Dawn Shot`: 86 G0 / 55 G1. |
| `trang_thiet_cuoc` | `truc_co` | `pinning-arrow`, `wolf-ring`, `nocked-arrow`, `second-night` | 22.2 s, 5/5, 100 % | 11.3 s, 0/5, 0 % | All 4 arts fire (7.4/6.0/7.4/3.4 G0; 3.4/2.6/3.0/1.0 G1). `Warden Geese Line`: 5 G0 / 5 G1 (`22.2 s` vs `21.6 s`). `Ring for the Wardens`: 15 G0 / 8 G1 (`11.3 s` vs `10.7 s` G1). |
| `diem_lac_nhan` | `truc_co` | `pinning-arrow`, `wolf-ring`, `nocked-arrow`, `the-leader-first` | 19.8 s, 5/5, 77 % | 9.7 s, 0/5, 0 % | All 4 arts fire (6.6/5.6/6.6/3.0 G0; 3.0/2.0/2.4/1.0 G1). `Warden Geese Line`: 5 G0 (`77 %` vs `75 %` HP) / 5 G1. |
| `lac_tung_lang` | `truc_co` | `pinning-arrow`, `wolf-ring`, `nocked-arrow` | 22.9 s, 5/5, 71 % | 9.8 s, 0/5, 0 % | All 3 arts fire (7.6/6.2/7.6 G0; 3.0/2.0/2.6 G1). `Warden Geese Line`: 5 G0 (`71 %` vs `68 %` HP) / 5 G1. |
| `canh_da_tuan`, `tu_tien_suong` | `truc_co` | `pinning-arrow`, `wolf-ring`, `nocked-arrow`, `marrow-tithe-strike`, `bulwark-knuckle`, `last-breath-fist` | 14.8 s, 5/5, 91 % | 25.6 s, 0/5, 0 % | All 6 arts fire (4.8/4.0/4.8/1.0/2.0/2.8 G0; 8.2/6.6/8.2/2.0/3.6/4.6 G1). `Warden Geese Line`: 5 G0 (`14.8 s` vs `14.6 s`) / 5 G1 (`25.6 s` vs `24.1 s`). |
| `ly_hanh_lo`, `lieu_khe_nhi`, `hua_tich_van`, `khau_toan_lo` | `luyen_khi` | `pinning-arrow`, `wolf-ring` | 37.5 s, 2/5, 7 % | 8.6 s, 0/5, 0 % | Both arts fire (12.0/9.6 G0; 2.0/2.0 G1). `Warden Geese Line`: 5 G0 (`7 %` vs `5 %` HP) / 5 G1. |
| `sam_thanh_tung` | `luyen_khi` | `pinning-arrow` | 47.2 s, 1/5, 0 % | 8.7 s, 0/5, 0 % | `pinning-arrow` fires (15.2 G0; 2.0 G1). |
| `vuong_tieu_nhi`, `doan_bat_mien`, `hoang_thiet_huyen` (`--people`) | `luyen_khi` | `marrow-tithe-strike`, `bulwark-knuckle` | 31.0 s, 5/5, 67 % | — | Both arts fire (3.4/5.0 G0). |
| `trang_tieu_da`, `lam_tieu_tien` (`--people`) | `luyen_khi` | `marrow-tithe-strike` | 32.6 s, 5/5, 13 % | — | `marrow-tithe-strike` fires (4.0 G0). |
| `PROBE_GLOW_30` (`hua_van_cung` vs `n_body=3.0`, 10 seeds) | `truc_co` | same | **24.4 s, 10/10, 99.8 %** (vs `25.9 s, 93.2 %` without `second-night`) | — | `second-night-clock-pulse`: 243, `second-night-clock-hit`: 266, `second-night-regen`: 153. |
| `PROBE_DAWN` (`hua_van_cung` vs `n_body=3.0`, 10 seeds) | `truc_co` | same | **24.4 s, 10/10, 99.8 %** (vs `24.6 s, 99.9 %` without `Dawn Shot`) | — | `eff:Dawn Shot tick`: 243, `eff:Dawn Shot reset`: 39. |
| `PROBE_DIEM_EAGLE` (`diem_lac_nhan` + `thuong_muc`, 10 seeds) | `truc_co` | same + `eagle` companion | **16.6 s, 10/10, 81.2 %** (vs `16.6 s, 77.0 %` without `Warden Geese Line`) | — | `eff:Warden Geese Line brace`: 10, `eff:Warden Geese Line companion hit`: 10. |
| `PROBE_TRANG_COMPANION` (`trang_thiet_cuoc` + companion, 10 seeds) | `truc_co` | same + companion | **19.3 s, 10/10, 99.9 %** (vs `19.5 s, 100.0 %` without `Ring for the Wardens`) | — | `eff:Ring for the Wardens ring`: 24; hits taken reduced (`200` vs `243`). |

REVIEW DONE
