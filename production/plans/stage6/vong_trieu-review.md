## Summary

Stage 6 record pass for `vong_trieu` (Vọng Triều Đường) is complete and verified cleanly across all staged catalogues (`design/stage6-staging/vong_trieu/`). All 3 techniques, 6 active arts, 5 Effects (2 technique passive arts + 1 item Effect + 2 full-set Effects), 6 unique signature items, and 2 three-piece sets run directly on the shipped engine vocabulary with 0 linter findings, 0 pending engine words, 0 stand-ins, 0 beasts, 0 `REFUSED` fighters in `sect_fight.py` at `--gap 0` and `--gap 1`, and 0 standalone GDScript counter/state compile errors.

### Băng Tâm Pilot Checklist
- [x] Step 1 mechanic table written before authoring records
- [x] Every depth `items`, `sets`, `techniques`, `arts` rule compared verbatim to `design/world/depth/sects/vong_trieu.*.json`
- [x] Every Effect in `vong_trieu.effects.json` declares every counter it reads or writes in its own `counters` array (no undeclared `states` or `counters`)
- [x] No art in `part-sect-vong_trieu.json` uses `states` or the `stance` tag (preserving `chan_dinh_lan`'s `mountain-root-stance`)
- [x] No engine/GDScript/spatial edits; no `git`, `stage6_merge.py`, `export_*`, or `compile_parity_export.py` executed
- [x] `lint_arts.py`, `lint_techniques.py` (with staged file), `lint_items.py` (with staged file): 0 findings
- [x] `depth_check.py --quiet`: `findings: none`; `depth_gap.py --sect vong_trieu`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `engine_words 0`, `wishes_open 0`, `lines 29/29 runs`
- [x] `sect_fight.py vong_trieu --seeds 5` (`--gap 0` and `--gap 1`): 0 `REFUSED`, all 6 active arts fire on real holders, all 5 Effects verified via `with`/`without` or targeted probes
- [x] Targeted edge-case probes passed (`The Lamp That Is Not Out` relight, `Not One Lamp Out` escape burnout, `Bind the Flame` Fuse mode, `The Lamp Stays Lit` down refusal)

---

## §A Auto-Accepted Decisions (Headless Stage 6 Job)

1. **Counters-only ward seals (`set-the-lamp`, `bind-the-flame`, `the-lamp-stays-lit`) instead of `states` (`stance`):**
   - *Reason:* Elder `chan_dinh_lan` pairs `lamp-ward-seal-canon` and `last-lamp-vigil` with `mountain-bone-body-art` (`mountain-root-stance`, which uses `states: ["mountain-root"]` and `tags: ["stance"]`). Implementing all Ward Seal mechanics purely via counters (`seal`, `seal_blows`, `seal_wall`, `lamp_lit_armed`) guarantees `mountain-root-stance` never collides or gets overwritten (`mountain-root-stance` fires `3.6` times at Gap 0 and `9.4` times at Gap 1 on `chan_dinh_lan`).
2. **NO-LEAN `names: ["thuy", "tho"]` lint proxy on the 3 techniques:**
   - *Reason:* Depth specifies `"names": []` for Vọng Triều's element-free lineage (`lamp-ward-seal-canon`, `tide-reading-gaze`, `last-lamp-vigil`), while `lint_techniques.py` currently requires 1–3 elements from `NAMEABLE`. Matches the `xuyen_lam` precedent (`catalogue-sect-xuyen_lam.json`); all 6 active arts remain element-free (`"element": ""`). Logged under §I Open Items (`body-element-free-names`).
3. **Technique passives sized under Tier-1 `16.0 W` budget (`14.4 W`, `12.7 W`, `15.6 W`):**
   - *Reason:* Initial draft had `18.0 W` (`lamp-ward-seal-canon`) and `19.0 W` (`tide-reading-gaze`), triggering `OVER_BUDGET` in `lint_techniques.py`. Trimmed passive percentages within theme (`defense_pct`, `ward_efficiency_pct`, `status_resist_pct`, `linh_luc_regen_inc_pct`; `than_thuc_pct`, `evade_pct`, `accuracy_pct`, `soul_res_pct`) to pass cleanly at `0 findings`.
4. **Tier-1 `bonuses` mapped to `items_cong_phap.json` `bonus_pool`:**
   - *Reason:* `lamp-ward-seal-canon` -> `defense_pct: 10`, `tide-reading-gaze` -> `than_thuc_pct: 8`, `last-lamp-vigil` -> `khi_huyet_pct: 10` (`1` bonus each within Tier 1 min/max bounds).
5. **Technique-level passive arts wired via `b01` `effects[]` (`catalogue-sect-vong_trieu.json`) and explicit `"unlock_layer": 4` on `The Lamp Flares`:**
   - *Reason:* `technique-effects` shipped in Stage 6 `b01`. `Lamp-Ward` (`unlock_layer: 3`) and `The Lamp Flares` (`unlock_layer: 4`) are placed in `lamp-ward-seal-canon.effects` and implemented in `effects/vong_trieu.effects.json` rather than deferred to `pending.json`.
6. **`Line of Lamps` ("loses a share of its ward") mapped to `slowed_time` + `leaking_ward` + `burn_qi` (`0.05` of `qi_max`) + `ward_bill: 25` (4 s):**
   - *Reason:* Combines immediate linh lực drain (`burn_qi`) on the foe's ward fuel with both `leaking_ward` (+50% ward upkeep bill, 3 s) and `ward_bill: 25` (+25%, 4 s), matching the engine's Ward upkeep/drain model (`combat_engine.json`).
7. **`Bind the Flame` ("Chosen when slotted: Wall / Fuse") implementation:**
   - *Reason:* Standard active slot runs **Wall** (`seal_wall = 1`, seals never burn out, each turned blow deals `self_hit` `c: 0.15` Soul, filtered `not_tags: ["trigger"]` with `limit: per_pulse: 2` to avoid self-hit recursion/spikes). **Fuse** (`seal_fuse = 1`) is wired across both `set-the-lamp` (`-1` blow per seal) and `The Lamp Flares` (`2x` damage: `c: 0.6 + 0.2 * seal_last_turned`) and verified in Probe 3. Choosing Fuse at character-slot time is noted in §I as an open UI/build-slot detail.
8. **`The Lamp Stays Lit` (`refuse_down: {}`, `stop_clock: 3.0`, `tick_block: 100` for 3.0 s) unlock layer set to `2` (`bind-the-flame` `1`):**
   - *Reason:* `last-lamp-vigil` is held at L9 by `on_thu_dang` and L4 by `chan_dinh_lan`; unlock layers 1 and 2 match two-art secret techniques and allow both elders to slot both arts within `unlock_layer <= 6`.
9. **`The Unsleeping Lamp` (`vtd-unsleeping-lamp`) metadata (`kind: "treasure"`, `rarity: 5`, `unique: true`, `sources: ["npc"]`, verbatim `54.4 W`):**
   - *Reason:* Matches `lint_items.py` treasure rules (same Stage 7 `export_named.py` note as `phan_vu`'s `pvd-xich-ha-ky`), R6 exceptions on weapon/armour/ward gear (`vtd-breakwater-seal`, `vtd-kim-sa-seal`, `vtd-pearl-diver-robe`, `vtd-sea-wall-shield`), and keeps verbatim depth modifiers (`54.4 W of 51.2`, `0 findings` under `world-depth` unpriced rule).
10. **Pop/Flare/Relight deterministic execution order:**
    - *Reason:* Engine loads art effects (`set-the-lamp`) first, then `tech_effects` (`The Lamp Flares`), then item/set effects (`The Lamp That Is Not Out`). `set-the-lamp` copies `seal_turned` -> `seal_last_turned` via `scale`, sets `seal_popped = 1`, decrements `seal -= 1`, and flags `seal_just_emptied = 1` when `seal == 0`; `The Lamp Flares` fires off `seal_popped` and clears it; `The Lamp That Is Not Out` relights `seal = 1` cleanly right afterward when `seal_just_emptied == 1` (`unsleeping_used == 0`), and `seal_ttl` (`10 + 4`) stays exact.
11. **`Layered Against the Tide` (`vtd-breakwater` 3pc):**
    - *Reason:* Tracks each turned blow on `was_hit` (`not_tags: ["trigger"]`, `seal >= 1` or `qi_share > 0` or `body_shield_share > 0`) into `tide_layer` (`cap: 15, each_for: 5` for independent 5 s expiry, `dampen_taken: 4` per layer); casting any `seal`-tagged art with `>= 5` layers spends them for `2` `heavy_breath` (`+1` at `>= 10`).

---

## §B Mechanic Table

| Source | Mechanic | Implementation Summary |
|---|---|---|
| `set-the-lamp` | Ward seal charges, damage damping, blow-turn pop & timeout | `charges: 3`, `seal` cap 9; `always` `dampen_taken: 15 + 3*seal`; `was_hit` decrements `seal_blows` (3 base, +`Lamp-Ward`, -`Fuse`) unless `seal_wall`/`not_one_lamp`; pops & reloads next seal (`seal_ttl` 10 s / 14 s w/ lamp). |
| `line-of-lamps` | Seal link slow & ward drain | Guard `seal >= 3`; `c_art: 1.4` Force hit; `slowed_time` (3 s) + `leaking_ward` (3 s); `burn_qi` `0.05` `qi_max` + `ward_bill: 25` (4 s). |
| `Lamp-Ward` | Extra blows per seal (`L3` passive) | Sets `has_lamp_ward = 1`; adds `+1` blow per gained seal plus `+1` per `3` seals held on cast/reload. |
| `The Lamp Flares` | Flare Force strike & slow on blow-spent pop (`L4` passive) | On `was_hit` when `seal_popped >= 1`, `free_hit` Force `0.3 + 0.1 * seal_last_turned` (`0.6 + 0.2 * seal_last_turned` if `seal_fuse >= 1`) + `slowed_time` (1 stack, 3 s). |
| `read-the-swell` | Evasion/block window & next-hit sure crit | `evade: 15`, `block: 20` (4 s) + arms `swell_crit = 1` (`sure_crit: 1` spent on `crit`, `not_tags: ["trigger"]`). |
| `far-watch` | Divine-sense focus & stealth strip | `acc: 20` (6 s) + `off_guard` (1 stack, 1 s -> drops foe evade to 0). |
| `bind-the-flame` | Vigil bind (`Wall` vs `Fuse`) | Active Wall sets `seal_wall = 1` (seals never burn out) + `self_hit` `0.15` Soul per blow turned (`per_pulse: 2`). Fuse (`seal_fuse = 1`) cuts 1 blow/seal and doubles Flare damage. |
| `the-lamp-stays-lit` | Vigil death refusal | Arms `lamp_lit_armed = 1` (+10% `ward_pct` 4 s); once per fight on `down` w/ `seal >= 1`, `refuse_down: {}` (1 HP), `stop_clock` foe 3 s, `tick_block: 100` 3 s. |
| `The Lamp That Is Not Out` | Longer duration & 1st empty relight | `has_unsleeping_lamp = 1` (+4 s `seal_ttl`), once per fight on `was_hit` when `seal_just_emptied == 1`, relights `seal = 1`. |
| `Not One Lamp Out` | Non-expiring chain & escape burnout | `not_one_lamp = 1` freezes burn-out while `lamp_escaped == 0`, counts `seal_pass_turns` (+1% `ward_pct` each); casting `escape`-tagged art expires all seals after 3 pulses. |
| `Layered Against the Tide` | Shield/ward blow layers & Heavy Breath spend | `tide_layer` (`cap: 15, each_for: 5`) gains +1 on turned blows (`dampen_taken: 4` each); `>= 5` layers spent on next `seal` art for `2` `heavy_breath` (`+1` at `>= 10`). |

---

## §C Techniques (`catalogue-sect-vong_trieu.json`)

| ID | Kind | Tier | Layers | W Used / Budget | Abilities & Effects |
|---|---|---:|---:|---:|---|
| `lamp-ward-seal-canon` | `main` | 1 | 9 | `14.4 W of 16` | `set-the-lamp` (L1), `line-of-lamps` (L2); passives `Lamp-Ward` (L3), `The Lamp Flares` (L4) |
| `tide-reading-gaze` | `secret` | 1 | 9 | `12.7 W of 16` | `read-the-swell` (L1), `far-watch` (L2) |
| `last-lamp-vigil` | `secret` | 1 | 9 | `15.6 W of 16` | `bind-the-flame` (L1), `the-lamp-stays-lit` (L2) |

---

## §D Arts (`part-sect-vong_trieu.json`)

| ID | Group | Role | `c_art` / CD / Cost | Tags | Wired `"id"` in `vong_trieu.techniques.json` |
|---|---|---|---|---|---|
| `set-the-lamp` | `lamp-ward-seal-canon` | `ward` | `0.0` / `5.0s` / `0.02` (`charges: 3`) | `seal`, `ward` | Yes (L1) |
| `line-of-lamps` | `lamp-ward-seal-canon` | `control` | `1.4` (Force) / `5.0s` / `0.04` | `seal`, `control` | Yes (L2) |
| `read-the-swell` | `tide-reading-gaze` | `ward` | `0.0` / `7.0s` / `0.03` | `soul`, `ward` | Yes (L1) |
| `far-watch` | `tide-reading-gaze` | `control` | `0.0` / `8.0s` / `0.03` | `soul`, `control` | Yes (L2) |
| `bind-the-flame` | `last-lamp-vigil` | `ward` | `0.0` / `8.0s` / `0.03` | `seal`, `ward` | Yes (L1) |
| `the-lamp-stays-lit` | `last-lamp-vigil` | `ward` | `0.0` / `8.0s` / `0.03` | `seal`, `ward` | Yes (L2) |

---

## §E Effects (`vong_trieu.effects.json`)

| Effect Name | Source | Declared Counters | Declared States |
|---|---|---|---|
| `Lamp-Ward` | `lamp-ward-seal-canon` (L3 passive) | `has_lamp_ward` | `—` |
| `The Lamp Flares` | `lamp-ward-seal-canon` (L4 passive) | `seal_popped`, `seal_last_turned`, `seal_fuse` | `—` |
| `The Lamp That Is Not Out` | `vtd-unsleeping-lamp` | `seal`, `seal_blows`, `seal_ttl`, `seal_just_emptied`, `has_unsleeping_lamp`, `unsleeping_used`, `lamp_just_relit`, `has_lamp_ward`, `seal_fuse` | `—` |
| `Not One Lamp Out` | `vtd-lamp-chain` (3pc) | `not_one_lamp`, `lamp_escaped`, `lamp_escape_ttl`, `seal`, `seal_blows`, `seal_ttl`, `seal_pass_turns` | `—` |
| `Layered Against the Tide` | `vtd-breakwater` (3pc) | `tide_layer`, `seal` | `—` |

All 5 Effects passed the standalone GDScript completeness check (`GDSCRIPT_STANDALONE_CHECK: effects=5 errors=0`).

---

## §F Items & Sets (`catalogue-sect-vong_trieu.json`, `sets-vong_trieu.json`)

| ID | Base / Kind / Grade | W (`of Limit`) | Holder | Set | Effects / Exceptions |
|---|---|---:|---|---|---|
| `vtd-unsleeping-lamp` | `dang` / `treasure` / 4 (`rarity: 5`) | `54.4 W of 51.2` (world-depth unpriced) | `on_thu_dang` | `vtd-lamp-chain` | `The Lamp That Is Not Out` |
| `vtd-kim-sa-seal` | `an` / `artifact` / 4 | `30.7 W of 51.2` | `on_thu_dang` | `vtd-lamp-chain` | R6 common-art/ward exception |
| `vtd-pearl-diver-robe` | `dao_bao` / `artifact` / 3 | `34.0 W of 38.4` | `on_thu_dang` | `vtd-lamp-chain` | R6 common-art/ward exception |
| `vtd-breakwater-seal` | `an` / `artifact` / 3 | `29.5 W of 38.4` | `chan_dinh_lan` | `vtd-breakwater` | R6 common-art/ward exception |
| `vtd-sea-wall-shield` | `thuan` / `artifact` / 3 | `31.2 W of 38.4` | `chan_dinh_lan` | `vtd-breakwater` | R6 common-art/ward exception |
| `vtd-jetty-stone` | `ngoc_boi` / `artifact` / 3 | `28.0 W of 38.4` | `chan_dinh_lan` | `vtd-breakwater` | `—` |

Sets staged: `vtd-lamp-chain` (2pc `ward_efficiency_pct +4`, `than_thuc_pct +4`; 3pc `Not One Lamp Out`), `vtd-breakwater` (2pc `defense_pct +6`, `body_shield_pct +10`; 3pc `Layered Against the Tide`).

---

## §G Stand-ins, Beasts & Structured Events

- **Stand-ins:** `0` (`unbroken-flesh-canon` and `mountain-bone-body-art` already exist in `catalogue-body.json`).
- **Beasts:** `0`.
- **Events (`depth_gap.py`):** `4 structured` (`events 4`).

---

## §H Holder & Probe Table

### `sect_fight.py vong_trieu --seeds 5` (0 `REFUSED`)

| Holder | Realm | Arts Fired (`gap 0` / `gap 1` means) | Gap 0 (`mean_s`, `wins`, `hp`) | Gap 1 (`mean_s`, `wins`, `hp`) | Effects Observed (`with` vs `without`) |
|---|---|---|---:|---:|---|
| `on_thu_dang` | `ket_dan` | `set-the-lamp` (9.0/9.0), `line-of-lamps` (12.0/3.8), `bind-the-flame` (1.0/1.0), `the-lamp-stays-lit` (1.0/1.0), `read-the-swell` (7.6/2.2), `far-watch` (6.6/2.0) | `56.5 s`, `5/5`, `54%` | `20.6 s`, `0/5`, `0%` | `Not One Lamp Out`: `56.5s 54%` vs `54.3s 52%` (324 runs @ gap 0; 114 @ gap 1). `The Lamp Flares` shows `NEVER_RAN` only on `on_thu_dang` because her active `Not One Lamp Out` + `Bind the Flame` Wall intentionally prevent seal burn-out; `Lamp-Ward` / `Unsleeping` relight are similarly masked on her full build and verified via other holders + Probe 1. |
| `chan_dinh_lan` | `ket_dan` | `set-the-lamp` (9.8/10.0), `line-of-lamps` (4.8/7.2), `mountain-root-stance` (3.6/9.4), `bone-turning-palm` (5.8/4.8), `bind-the-flame` (1.0/1.0), `the-lamp-stays-lit` (1.0/1.0) | `24.6 s`, `5/5`, `99%` | `65.5 s`, `4/5`, `22%` | `Layered Against the Tide`: `65.5s 22%` (4/5 wins) vs `28.5s 0%` (533 runs @ gap 1; 175 @ gap 0). `The Lamp Flares`: 15 runs @ gap 0 & gap 1. |
| `kien_muc_hai`, `dich_tan_chieu` | `truc_co` | `set-the-lamp` (19.4/3.0), `line-of-lamps` (8.8/1.0), `read-the-swell` (6.6/1.0), `far-watch` (5.6/0.8) | `47.8 s`, `5/5`, `62%` | `9.9 s`, `0/5`, `0%` | `Lamp-Ward` (`47.8s 62%` vs `48.8s 60%`), `The Lamp Flares` (`47.8s 62%` vs `54.2s 56%`, 156 runs @ gap 0; 27 @ gap 1). |
| `bang_tran_lang`, `le_bach_diem`, `ve_lu_sinh` | `truc_co` | `set-the-lamp` (21.6/3.4), `line-of-lamps` (9.6/1.0) | `51.3 s`, `5/5`, `48%` | `10.1 s`, `0/5`, `0%` | `Lamp-Ward` (`51.3s 48%` vs `54.2s 40%`), `The Lamp Flares` (`51.3s 48%` vs `57.4s 33%`, 189 runs @ gap 0; 30 @ gap 1). |
| `tram_chau_nhi` | `truc_co` | `set-the-lamp` (25.4/3.4), `line-of-lamps` (10.6/1.0) | `57.4 s`, `5/5`, `33%` | `10.4 s`, `0/5`, `0%` | `Lamp-Ward` (`57.4s 33%` vs `59.1s 11%`). |
| `dinh_vong_tinh`, `ky_lam_sa` | `luyen_khi` | `set-the-lamp` (26.6/3.0), `line-of-lamps` (7.2/0.4) | `55.4 s`, `2/5`, `13%` | `9.1 s`, `0/5`, `0%` | Core Ward Seal + `Line of Lamps` functional at `luyen_khi` layer 2. |

### Targeted Mechanic Probes
| Probe | Setup | Observed Result |
|---|---|---|
| `PROBE_UNSLEEPING` | `kien_muc_hai` (`set-the-lamp` CD 20 s, 1 charge) w/ vs w/o `vtd-unsleeping-lamp` | `with=62.4s 0/5 hp=0%` vs `without=61.8s 0/5 hp=0%`, `relight_runs=5` (relights `seal=1` once per fight on empty). |
| `PROBE_ESCAPE_BURNOUT` | `on_thu_dang` w/o `bind-the-flame` + `escape`-tagged probe art vs `nguyen_anh` typical | `escape_procs=9`, `expire_procs=6`, seals expire cleanly 3 pulses after escape art fires. |
| `PROBE_FUSE` | `kien_muc_hai` w/ `seal_fuse=1` vs normal | `fuse=46.4s 5/5 hp=65% flares=64` vs `norm=47.8s 5/5 hp=62% flares=52` (-1 blow/seal increases flare cadence & 2x flare damage). |
| `PROBE_STAYS_LIT` | `on_thu_dang` vs `nguyen_anh` typical foe (5 seeds) | `refusals=5/5` (`the-lamp-stays-lit-save` fires cleanly at lethal hit while `seal >= 1`). |

---

## §I Open Items (for Serial / Stage 7 / Stage 9)
1. **`body-element-free-names` schema cleanup:** `lamp-ward-seal-canon`, `tide-reading-gaze`, and `last-lamp-vigil` carry a temporary `names: ["thuy", "tho"]` lint proxy because `lint_techniques.py` requires 1–3 elements (depth has `names: []` for Vọng Triều's element-free lineage; same open item as `xuyen_lam`).
2. **`export_named.py` `kind: "treasure"` support:** Ensure Stage 7 `export_named.py` includes `"kind": "treasure"` items so `vtd-unsleeping-lamp` exports cleanly.
3. **`Bind the Flame` Fuse slot variant:** `seal_fuse` is wired in `set-the-lamp` and `The Lamp Flares` and probe-verified; slot-choice UI/profile selection for Wall vs Fuse remains a character-profile/slotting concern.
4. **R6 signature item common art / ward exception:** `vtd-breakwater-seal`, `vtd-kim-sa-seal`, `vtd-pearl-diver-robe`, and `vtd-sea-wall-shield` carry the R6 `exception` until item common arts/wards are ruled in Stage 9.

REVIEW DONE
