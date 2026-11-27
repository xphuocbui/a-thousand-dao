# Stage 6 Checkpoint Review — Ẩn Sĩ / Hermits and Sages (`hermits-sages`, Batch `b06`)

Unanchored checkpoint review of `design/stage6-staging/hermits-sages/` and `design/world/depth/people/hermits-sages.*` against `production/plans/stage6/_brief-review.md`, `_brief-record.md`, `design/world/depth/DECISIONS-2026-11-25.md`, `design/world/depth/DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md` (verified directly against `tools/design/combat_sim/engine.py`, `fight.py`, `sect_fight.py`, `tools/design/items/lint_items.py`, `tools/design/arts/lint_techniques.py`, `src/gameplay/cultivation/cong_phap.gd`, `src/gameplay/combat/fight/build_file_compiler.gd`, and `effect_runner.gd`).

---

## 1. Ranked Findings

### MUST-FIX

1. **[MUST-FIX — FIXED] `effects/hermits-sages.effects.json` — `The World Before` (`eff:The World Before tick` vs `eff:The World Before spill`)**
   - **What was wrong:** `eff:The World Before spill` (`on: "pulse"`) sets `world_before_win = 2` and stops the foe's clock for `2.0 s`, and `eff:The World Before tick` (`on: "pulse"`, `if: own.counter.world_before_win >= 1`, `add: -1`) was ordered **after** `spill`. In `engine.py`, `fire_event("pulse")` iterates listeners in order, so on the exact pulse where the Vase spilled (`t = 8000 ms` in the `mac_quy_khu` tribulation probe), `tick` immediately ran on the same pulse (`2 -> 1`), then ticked `1 -> 0` at `t = 9000 ms`, cutting the `2 s` element-laying window in half to **`1.0 s`** (`[8000, 9000)` instead of `[8000, 10000)` — `backwash-seal` cast at `t = 9000 ms` missed `eff:The World Before cast`).
   - **Fix applied:** Reordered `eff:The World Before tick` **before** `eff:The World Before spill` in [hermits-sages.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/hermits-sages/effects/hermits-sages.effects.json), and added `"approx"` explaining why Mạc Quy Khư's seven stack-bearing elements (`fire`, `water`, `earth`, `metal`, `wood`, `ice`, `light`) are listed explicitly (Effects cannot read `own.purity.<el>`).
   - **Verification:** Re-running the `mac_quy_khu` `tags=["tribulation"]` probe confirms `spill` at `8000 ms`, `cast` at `8181 ms`, `tick` at `9000 ms` (`2 -> 1`), `cast` at `9000 ms` (`backwash-seal`), and `tick` at `10000 ms` (`1 -> 0`).

2. **[MUST-FIX — FIXED] `arts/part-sect-hermits-sages.json` — `plum-falls-between-notes` (`plum-between-notes-strike`) & `the-fifth-month-tune`**
   - **What was wrong:**
     1. `plum-falls-between-notes` guarded only on `own.counter.fifth_month_tune >= 1`. Because `act()` iterates slotted arts sequentially, `plum-falls-between-notes` fired on the **exact same instant (`t + 0 ms`, e.g., `5738 ms`)** right after `the-fifth-month-tune`, ending the tune before a single pulse elapsed (`tune_notes == 2`).
     2. On `hit_landed` of `plum-falls-between-notes` (`c_art: 1.4`), `fifth-month-soul-cut` (`0.7 c Soul` `free_hit`) fired first and consumed **100 % of `trig_budget`** (`0.5 * direct_dmg`), causing `plum-between-notes-strike` (`0.35 * tune_notes c Force` `free_hit`) and `eff:The Falling Plum Tune cut` (`0.45 c Soul`) to be **clipped to `0.000` net damage** (`trig_budget: 25` clips in one A-5 probe fight).
   - **Fix applied:** In [part-sect-hermits-sages.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/hermits-sages/arts/part-sect-hermits-sages.json), added `{"read": "own.counter.tune_notes", "op": ">=", "value": 2}` to `plum-falls-between-notes`'s `guards` so at least one note/pulse elapses before the finisher fires, and replaced the `free_hit` `plum-between-notes-strike` Effect with gated `empower` `split` branches (`tune_notes == 2 -> split [0.65, 0.65]` (`1.82 c`); `== 3 -> [0.55, 0.55, 0.55]` (`2.31 c`); `>= 4 -> [0.5, 0.5, 0.5, 0.5]` (`2.80 c`)) so the per-note Force strikes land as direct art hits without being zeroed by `trig_budget`.

### SHOULD

3. **[SHOULD — FIXED] `effects/hermits-sages.effects.json` — `Noon on One Side` (`fan` + `fan-gust` overlap & unshared `melt` limit)**
   - **What was wrong:** `melt fan`, `burst fan`, and `sweep fan` (`filter: {"tags": ["fan"]}`) lacked `"not_art_id": "fan-gust"`, and `melt fan` and `melt gust` used separate `limit: {"per_fight": 1}` counters without a shared flag. A build slotting both `fan-gust` and another `fan`-tagged art (`hundred-plumes`, `wing-screen`, etc.) could trigger the "once a fight" frost-ward melt **twice**, and tagging `fan-gust` with `"fan"` in a future pass would double-fire all three branches.
   - **Fix applied:** Added `"not_art_id": "fan-gust"` to `melt fan`, `burst fan`, and `sweep fan`, and added `"counters": [{"id": "noon_melted"}]` gating both `melt` records on `own.counter.noon_melted == 0` (setting `noon_melted: 1`) in [hermits-sages.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/hermits-sages/effects/hermits-sages.effects.json).

4. **[SHOULD — FIXED] `arts/part-sect-hermits-sages.json` — `cold-light-on-iron-mail` (`cold-light-release-sword`)**
   - **What was wrong:** `cold-light-release-sword` listened on `"on": "art_fired"`, firing its `1.1 c` Cold `free_hit` **before** the triggering sword art (`watchmans-gong`) hit, when `s.direct_dmg` was `0.0` (reset each `pulse`). In the A-1 probe, this clipped `cold-light-release-sword` against the bare `0.25 * U_att` floor (`trig_budget: 7` clips) and wasted the stored cut even if the sword art was evaded.
   - **Fix applied:** Switched `cold-light-release-sword` to `"on": "hit_landed"` (`filter: {"tags": ["sword"], "not_art_id": "cold-light-on-iron-mail"}`) in [part-sect-hermits-sages.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/hermits-sages/arts/part-sect-hermits-sages.json), reducing A-1 `trig_budget` clips from `7` to `4` (only `The Unspent Bolt`'s 2.4 c dual proc on basic crits).

5. **[SHOULD — FIXED] `arts/part-sect-hermits-sages.json` — `the-lake-shows-the-moon` (`lake_reflect` lockout on basic/companion ward break)**
   - **What was wrong:** `the-lake-shows-the-moon` guards on `own.counter.lake_reflect < 1`, while `lake_reflect` was cleared only on `ward_absorbed` (`filter: {"kind": "art"}`). If basic or companion hits broke the stance ward before a foe art hit it, `lake_reflect` remained `1` with `ward_share == 0`, locking `the-lake-shows-the-moon` out for the rest of the fight.
   - **Fix applied:** Added `lake-mirror-broken` on `"on": "shield_broken"` (`if: [{"read": "event.stance_ward", "op": ">=", "value": 1}]`, `do: [{"counter": {"id": "lake_reflect", "set": 0}}]`) in [part-sect-hermits-sages.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/hermits-sages/arts/part-sect-hermits-sages.json).

6. **[SHOULD — FIXED] `arts/part-sect-hermits-sages.json` — `smoke-over-the-burner` (`stack: true` on separate record ID `smoke-resist-chaos`)**
   - **What was wrong:** `smoke-resist-chaos` has its own record ID (separate from `smoke-dampen-wood`), so `"stack": true` was unnecessary and allowed overlapping `+18` Chaos resist stacks if `art_speed > 0`.
   - **Fix applied:** Removed `"stack": true` from `smoke-resist-chaos` in [part-sect-hermits-sages.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/hermits-sages/arts/part-sect-hermits-sages.json).

### NIT / Verified Informational Notes

7. **[NIT — OPEN FOR `s6-serial-b06`] `items/catalogue-sect-hermits-sages.json` — `hs-between-the-notes-flute` (`scope: ["song"]` -> `["artifact"]` & `lint-song-scope`)**
   - Checked `design/gdd/modifiers.md` (rule 9 defines `"song"` as a `family` form tag), `tools/design/combat_sim/fight.py` (`passive_effect` puts any non-element/non-dtype tag in `m.tags`), and `src/gameplay/combat/fight/build_file_compiler.gd` + `effect_runner.gd` (supports `m.tags` `"song"` identically). Both engines already support `"song"`; only `tools/design/arts/lint_techniques.py` `TIER` lacks `"song"`. Kept `"scope": ["artifact"]` in staged [catalogue-sect-hermits-sages.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/hermits-sages/items/catalogue-sect-hermits-sages.json) (`lint_items.py` `0 findings`), left `lint_techniques.py` untouched, and flagged **`lint-song-scope`** for `s6-serial-b06` (to add `"song": "family"` to `lint_techniques.py` `TIER` and restore `scope: ["song"]` on `hs-between-the-notes-flute`).

8. **[NIT — VERIFIED] `items/catalogue-sect-hermits-sages.json` — `hs-purple-smoke-furnace` (`55.7 W of 51.2` & `element_affinity_pct`)**
   - `lint_items.py` outputs `55.7 W of 51.2 (grade 4, rarity 5, unique, unpriced, world-depth)` and skips `OVER_BUDGET` on `catalogue-sect-*.json` (`UNPRICED_PREFIX`, per the user rule that Effects/world-depth items are unpriced and keep depth modifiers as given). `element_affinity_pct` (`10 [hoa]`) remains the single open `depth_gap.py` `lines` gap (`1 of 56`) awaiting `CHARACTER_MODS` / GDScript `StatSheet`.

9. **[NIT — VERIFIED] `hermits-sages-review.md` §C table drift (staged JSON & depth JSON are consistent)**
   - The table in [hermits-sages-review.md](file:///C:/Users/xphuo/IdeaProjects/my-game/production/plans/stage6/hermits-sages-review.md) (§C lines 79–84) recorded outdated bonus/passive numbers (and `unlock_layer: 3` instead of `2` on `smoke-over-the-burner`), whereas [catalogue-sect-hermits-sages.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/hermits-sages/techniques/catalogue-sect-hermits-sages.json) and [hermits-sages.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/hermits-sages.techniques.json) match each other cleanly (`0 findings` in `lint_techniques.py`; W totals `30.4, 22.9, 22.6, 24.0, 29.3, 14.6`).

10. **[NIT — VERIFIED] Full Audit Summary (`techniques`, `arts`, `items`, `sets`, `effects`, `cast`)**
    - **Techniques (`6`):** `still-water-mirror-canon`, `north-wind-cold-light-sword`, `purple-smoke-furnace-canon`, `falling-plum-flute-canon`, `lone-crane-metal-canon`, `vermilion-tide-breath` all match `hermits-sages.techniques.json`, carry `owner: "hermits-sages"`, valid `bonus_count` / `bonuses` / `passives` / `abilities`, and `purple-smoke-furnace-canon` carries committed `pill-smoke` (`design/arts/part-sect-market-folk.json` untouched).
    - **Arts (`11` new):** All 11 staged arts pass `lint_arts.py` (`0 findings`), define all stances they set (`still-water-mirror`), and do not conflict with `flurry` (`lone-crane-metal-canon` sets no stance).
    - **Items (`13`) & Sets (`3`):** All 13 items match `hermits-sages.items.json` (modulo `hs-between-the-notes-flute` `artifact` bridge), carry `sources: ["npc"]`, `unique: true`, `rarity: 5` on all 3 treasures, `where: "sealed abode A-*"` on A-1/A-2/A-4/A-5, and R6 `exception` on the 9 weapon/body_gear/ward_gear items. All 3 sets (`hs-what-the-old-man-kept`, `hs-lone-crane-things`, `hs-still-pool`) match exact depth names, Han-Việt parentheticals, and 2pc/3pc modifiers/rules.
    - **Effects (`10`):** Top-level `hermits-sages.effects.json` includes `"_doc"` and `"source": "world-depth:hermits-sages"`. All 9 runnable Effects declare every counter and state they read/write locally and pass standalone `engine.validate()`; `Purple Smoke on the Burner` is `not_run` (`records: []`). Zero name/ID collisions against `assets/data/combat_effects.json`, committed `design/`, or other `design/stage6-staging/` owners (`demonic`, `loose-north`, `market-folk`).
    - **Cast & Stand-ins (`7` stand-ins, `16` living):** Verified `CongPhap.usable()` (`names ⊆ root elements ∪ variants`) returns `True` for **all 16 living cast members** and **all 7 stand-ins** (`tu_khong_hac_nien` -> `lone-crane-metal-canon`; `thu_van_trieu`, `trau_vong_bang`, `thu_tieu_chu` -> `vermilion-tide-breath`; `boc_tuyet_nha`, `bao_tieu_que`, `cam_thu_nguyen` -> `verdant-cycle-scripture`).

---

## 2. Pending Words

- `pending.json` is absent (`0` new engine words required).
- `Purple Smoke on the Burner` remains `not_run` (`out-of-fight alchemy crafting and abode A-2 story event only; no combat rule.`).
- Flagged for `s6-serial-b06` (without modifying `tools/design/arts/lint_techniques.py`): **`lint-song-scope`** — add `"song": "family"` to `lint_techniques.py` `TIER` (matching `modifiers.md` rule 9, `fight.py`, and GDScript) and restore `"scope": ["song"]` on `hs-between-the-notes-flute`.

---

## 3. Post-Fix Verification & Holder Table

### Linters, Checkers & Probes (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\hermits-sages`)
- `spatial_words_check.py --sect hermits-sages` + staged scan: **0 hits** on `people/hermits-sages.*` and all 5 staged JSON files.
- `lint_techniques.py design/stage6-staging/hermits-sages/techniques/catalogue-sect-hermits-sages.json`: **`checked 6 techniques, 0 findings`**.
- `lint_arts.py design/stage6-staging/hermits-sages/arts/part-sect-hermits-sages.json`: **`checked 11 arts in 1 files, 0 findings`**.
- `lint_items.py design/stage6-staging/hermits-sages/items/catalogue-sect-hermits-sages.json`: **`checked 13 items, 22 bases, 9 common arts, 0 findings`**.
- `depth_check.py --quiet`: **`findings: none`**.
- `stage6_merge.py hermits-sages --check`: **`0 failure(s)`**.
- Standalone `engine.validate()`: **9/9 runnable Effects pass** (`Purple Smoke on the Burner` `not_run`).
- `sect_fight.py hermits-sages --seeds 5` (`--gap 0` & `--gap 1`): **0 `REFUSED`**, every slotted art fires `> 0`.

| Holder | Realm | Slotted arts (gap 0 fires) | Gap 0 (`mean_s`, wins, hp) | Gap 1 (`mean_s`, wins, hp) | Effects (`with` vs `without`, gap 0 / gap 1 runs) |
|---|---|---|---|---|---|
| `thu_van_trieu` | `ket_dan` | `long-oar-stroke` (10.8), `backwash-seal` (19.0) | `33.6 s`, `5/5`, `43%` | `8.0 s`, `0/5`, `0%` | — |
| `khuyet_van_ha` | `ket_dan` | `second-brewing` (5.6), `smoke-over-the-burner` (7.6), `pill-smoke` (7.2) | `51.6 s`, `0/5`, `0%` | `8.8 s`, `0/5`, `0%` | — |
| `gian_thu_dich` | `ket_dan` | `swallow-stance` (4.0), `hundred-feather-flurry` (2.6), `three-step-chase` (5.4), `held-breath` (5.8), `trailing-gale` (4.0), `gale-sprite` (2.0) | `16.2 s`, `5/5`, `93%` | `10.1 s`, `0/5`, `0%` | — |
| `nhiem_han_chau` | `truc_co` | `frost-breath-palm` (14.2) | `44.2 s`, `0/5`, `0%` | `8.2 s`, `0/5`, `0%` | — |
| `trau_vong_bang` | `truc_co` | `long-oar-stroke` (15.4) | `53.6 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | — |
| `thu_tieu_chu` | `luyen_khi` | `long-oar-stroke` (13.2) | `47.4 s`, `1/5`, `1%` | `8.0 s`, `0/5`, `0%` | — |
| `mac_quy_khu` | `hoa_than` | `scorch-fist` (7.0), `backwash-seal` (12.0), `bloodletting-rite` (2.0), `sleet-volley` (9.0), `stilled-instant` (2.8), `shattering-mantle` (3.2) | `19.7 s`, `5/5`, `100%` | `19.7 s`, `5/5`, `100%` | `Unmaking Glass`: `95 / 95`; `Where All Waters Return`: `0 / 0` (`typical` foe never hits `<=67%` HP; verified in `tags=["tribulation"]` probe); `The World Before`: `0 / 0` (triggers after Vase spill; verified `8000` spill -> `8181` cast -> `9000` tick+cast -> `10000` tick) |
| `tu_khong_hac_nien` | `nguyen_anh` | `crane-edge-draw` (4.4), `broken-sleeve-stroke` (1.8), `flurry-stance` (2.0), `phantom-sword` (4.4), `triple-draw` (3.0), `flying-sword` (1.0) | `9.8 s`, `5/5`, `88%` | `13.2 s`, `0/5`, `0%` | `A Crane Crosses from the East`: `0 / 0` (sleeps in pure Metal hand as designed); `The Crane Wakes`: `9.8 s 88%` vs `10.5 s 83%` (`21 / 28`) |
| `doan_thuong_hai` | `nguyen_anh` | `deep-lake-stance` (6.8), `gathering-wave` (4.0), `brimming-cup` (3.0), `swelling-tide-palm` (5.6), `answering-palm` (6.8), `twin-shadow-fist` (2.0) | `20.3 s`, `5/5`, `100%` | `15.6 s`, `0/5`, `0%` | `The Blue Sea Becomes Mulberry Fields`: `0 / 0` (`typical` foe casts no `lightning`); `Hears and Answers`: `20.3 s 100%` vs `19.1 s 100%` (`10 / 10`) |

CHECKPOINT DONE
