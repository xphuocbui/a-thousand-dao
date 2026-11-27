## Summary

Stage 6 record pass for `phat_y` (Phất Y Cốc, Valley of the Brushed Sleeve) is complete and verified cleanly across all staged catalogues (`design/stage6-staging/phat_y/`). All 3 techniques, 5 active arts, 4 Effects (1 technique Effect `Serve a Term` + 1 item Effect `Gone Before Thanks` + 1 shared item/set Effect `Paid in Full` + 1 full-set Effect `The Last Step`), 4 unique signature items, and 2 two-piece sets run directly on the shipped engine vocabulary with `0` linter findings (`lint_arts.py`, `lint_techniques.py`, `lint_items.py`), `0` pending engine words, `0` stand-ins, `0` beasts, `0 REFUSED` fighters in `sect_fight.py` at `--gap 0` and `--gap 1`, `0 NEVER_FIRED` arts, and `0` standalone Effect counter/state errors.

### Băng Tâm Pilot Checklist
- [x] Every Effect changes the fight with and without it on its holders, or has a written reason (`Gone Before Thanks` runs `5` times across 5 seeds at `--gap 0` and `0` times at `--gap 1` because `thang_vo_ta` is defeated before dropping the `nguyen_anh` typical foe to `25 %` `broken`; `Marked Prey` from `blade-thousand-cut-sword` is an `on: "always"` modifier Effect so `Fight.do()` logs `runs 0` even though it changes fight time `12.1 s` vs `12.3 s`).
- [x] Every art fires (`0 NEVER_FIRED` across all 17 living holders at both `--gap 0` and `--gap 1`; `brushed-sleeve-step` arts `brush-the-sleeve` and `a-thousand-sleeves` sit past `MAX_ARTS = 6` on `thang_vo_ta` in default `sect_fight.py` and were verified in a targeted `thang_vo_ta` probe).
- [x] No holder slots two stances without a combined stance: only `noon-guard` (`dry-road-sword-primer`, whose holders have no other stance) uses `states`; `brushed-sleeve-step`, `contract-sword-canon`, and all Effects use counters/timed mods only so `thang_vo_ta`'s `flurry-stance` (`afterimage-sword-canon`) is never overwritten.
- [x] Every art defines every stance it sets (`noon-guard` defines `states: [{"id": "noon-guard", ...}]`).
- [x] Every Effect in `design/stage6-staging/phat_y/effects/phat_y.effects.json` declares in its own `counters` array every counter `id` it reads or writes (`STANDALONE_EFFECT_CHECK: OK 4`), with no two `"mod"` actions in one record without `"stack": true` and no `decay_per_pulse: 1` off-by-one decay.
- [x] Vague words pinned in `rule` (`Heat`, `Term (Khoản)`, `vanish`, `Return to the Scabbard`).
- [x] Technique bonuses and passives sized against the same-tier catalogue and marked as new below.

---

## §A Auto-Accepted Decisions (Headless Stage 6 Job)

1. **`Serve a Term` wired via `contract-sword-canon.effects` (`unlock_layer: 1`) + counter-based `final-count`:**
   - *Reason:* `contract-sword-canon.concept` defines the `Term (Khoản)` rule ("each second you are Pressing and strike nothing serves a Term, and each hit you take strikes one Term off"), while `final-count` (`unlock_layer: 1`) spends all served Terms. Implementing `Serve a Term` as a `layer 1` technique Effect (`technique-effects`) and declaring `term`/`term_struck` on both `Serve a Term` and `final-count` makes the Term rule visible in `sect_fight.py` `with`/`without` probes and standalone-compilable in GDScript.
2. **`Serve a Term` tracks art hits (`kind: "art"`) and enemy art hits (`kind: "art"`, `cooldown: 3.0` s) rather than basic attacks:**
   - *Reason:* Basic attacks fire every `1.0` s on both sides; if basic attacks counted as "striking" or "hits taken", `term` would stay near `0` all fight and `final-count`'s `>= 5 Terms` empower would never fire (`0` empowers in initial test). Filtering `hit_landed`/`was_evaded` and `was_hit` to `kind: "art"` (matching `Return to the Scabbard` and `The Called Blow`) plus `evaded` (`per_pulse: 1`) and `step-back` (`cooldown: 1.55` s) lets pure `contract-sword-canon` holders reach `5+` Terms (`12` empowers across 5 seeds on `au_duong_kien`, `thoi_an_thu`, `kieu_tinh_son`).
3. **`brushed-sleeve-step` (`brush-the-sleeve`, `a-thousand-sleeves`) uses counters/decoys/evade instead of `states` (`stance`):**
   - *Reason:* `thang_vo_ta` (the only living holder) pairs `brushed-sleeve-step` with `afterimage-sword-canon` (`flurry-stance`, which uses `states: [{"id": "flurry"}]`). Using `decoy`, `evade`, `dampen_taken`, and `thousand_sleeves` counter avoids clobbering `flurry`.
4. **`Gone Before Thanks` (`py-grey-sleeve`) triggers on `broken` (foe falling to `25 %` HP) in 1v1 duels:**
   - *Reason:* Depth text triggers vanish when a foe "dies or flees", which ends a 1v1 duel immediately (`engine.py` does not emit `kill`). Triggering on `broken` (plus `Return to the Scabbard` in `The Last Step`) makes the vanish window (`1 decoy`, `+40 evade` for `2 s`, next Metal strike sure crit) active in real 1v1 fights, matching `The Last Step`'s own `Broken -> vanish` link.
5. **`Paid in Full` (`py-contract-seal` + `py-hired-pair` 2pc) adapted for 1v1 combat with idempotent limits:**
   - *Reason:* Depth text ("while you fight to protect someone who has hired you / a hirer") assumes a multi-ally fight (`spatial_words_check.py` flags `paid-in-full` as `postponed`). Per `DECISIONS-2026-11-26.md` single-side fight rules, `Paid in Full` runs directly in 1v1 duels (`was_hit` `cooldown: 4.0` -> `dampen_taken: 20` for `2.0 s`; `crit` `per_pulse: 1` -> `heal: 0.02`), and its limits/overwrite-by-id ensure wearing both `py-contract-seal` and `py-hired-pair` never doubles the Effect. The post-fight "if the hirer leaves alive, healed in full once" clause is unmodelled in 1v1.
6. **`The Last Step` (`py-grey-seal` 2pc) bundles `Return to the Scabbard (Quy Sao)` under `"The Last Step"`:**
   - *Reason:* `depth_gap.py` reads the Effect key before `(` (`"The Last Step"`). Implementing both `The Last Step` (`evaded` / `broken` / vanish -> `+30 %` `dmg_more` on next sword art within `2 s`) and `Return to the Scabbard` (`scabbard_acted`/`scabbard_idle` -> after `3` idle pulses without damaging art hits, re-arms first sword art `acc: 500` and triggers vanish) inside `"The Last Step"` closes `py-grey-seal` cleanly without colliding with `thinh_vu`'s `"Return to the Scabbard"` Effect key.
7. **`noon-guard` (`dry-road-sword-primer`) authored as element-free Physical (`element: ""`, `kind: "phys"`):**
   - *Reason:* `dry-road-sword-primer` (`names: ["kim", "hoa"]`) is used by both Metal-rooted miners (`hua_ngan_son`, `cat_da_binh`) and Fire-rooted steppe disciples (`hoac_ngo_lo`, `yen_lac_tu`, `giang_bich_sa`) as well as `loose-south` (`tu_ban_kiem`) and `market-folk` (`dieu_thiet_tien`). Element-free Physical fits all holders equally and passes `lint_techniques.py`.
8. **R6 common-art/ward exception & `unique: true` on signature items:**
   - *Reason:* Applied per standing Băng Tâm rulings (`py-grey-sleeve`, `py-contract-seal`, `py-contract-blade` carry the R6 `exception` mark; `py-sleeve-token` is `ngoc_boi` necklace so no exception needed; all 4 carry `unique: true` and `sources: ["npc"]`).

---

## §B Mechanic Table

| Source | Depth Text | Engine Form | Deviation |
|---|---|---|---|
| `dry-road-sword-primer` | Outer method for Metal or Fire, short exchanges, stronger on the road | Tier 0 `main`, `names: ["kim", "hoa"]`, `attack_pct 4 [sword]`, `art_speed_pct 4 [sword]`, `khi_huyet_pct 4` (`6.7 W of 8`) | Bonuses/passives new (none in depth) |
| `noon-guard` | Stance: each hit taken partly turned onto sword, grants Heat strengthening next cut | Stance `noon-guard` (`dampen_taken: 18`); `was_hit` adds `heat`; `always` `+12 % dmg_more` per `heat`; cleared on direct `hit_landed` | Quantified `dampen_taken: 18` and `+12 %` per Heat; element-free `phys` |
| `contract-sword-canon` | Pressing & strike nothing serves a Term; hit taken strikes 1 Term off | Tier 1 `main`, `names: ["kim"]`, `attack_pct 10` bonus, passives `15.7 W of 16`, `effects: ["Serve a Term"]` | Bonuses/passives new; `Serve a Term` filters `kind: "art"` (`cooldown: 3 s` on `was_hit`) |
| `final-count` | Spends all Terms on Metal strike scaling dmg & crit; >=5 Terms ignores part of defence | `c_art: 2.2`, cd `7.0 s`, `debuff: [2, 6]`; `+18 % dmg_more` & `+6 % crit` per Term; at `>=5` Terms `empower` (`c_mult: 1.6`, `bypass: 0.4`) + `pen: 80` | Quantified scaling per Term and `bypass: 0.4` / `pen: 80` at `>=5` |
| `step-back` | Hit makes foe Broken or breaks ward -> evade 1 s | Active `movement` art (`cd 1.55 s`, `+18 evade 1.5 s`) + on `broken` / `foe.qi_share <= 0.05` (`per_fight: 1`) grants `+35 evade 1.0 s` | Added active `movement` cast so holders enter `Pressing`; ward-break read as `foe.qi_share <= 0.05` |
| `brushed-sleeve-step` | Founder's Wind secret step, faster blades, turns attacks | Tier 2 `secret`, `names: ["phong"]`, `attack_pct 10` + `travel_speed_pct 12` bonuses, passives `22.0 W of 24` | Bonuses/passives new |
| `brush-the-sleeve` | Turns next attack with sleeve; faster Metal strikes for a breath | `decoy {n: 1}` on cast; on `decoy_struck` grants `art_speed: 25 [metal]` for `2.0 s` | Uses `decoy`/`decoy_struck` cleanly |
| `a-thousand-sleeves` | Strikes leave afterimages for a few s; foe cannot single holder out | Wind cut `c_art: 1.5`, cd `7.0 s`, `debuff: [2, 6]`; `4 s` window: `1 decoy`, `+20 evade`, `15 dampen_taken`, `free_hit` Force `0.4` (`per_pulse: 2`) | "Cannot single out" modelled as decoy + evade + dampen (no spatial/stance) |
| `Gone Before Thanks` (`py-grey-sleeve`) | Vanish 2 s on foe dies/flees: untargetable + next Metal strike crit | On `broken`: `decoy {n: 1}`, `+40 evade 2.0 s`, `vanish_crit = 1` (`sure_crit: 1 [metal]` until Metal `crit`) | Triggers on `broken` (`25 %` HP) since death/flight ends 1v1 fights |
| `Paid in Full` (`py-contract-seal`, `py-hired-pair`) | Protect hirer: -20 % dmg taken, heal on strike; 2pc heal 2 % on crit, full heal if hirer lives | On `was_hit` (`cd 4 s`): `dampen_taken: 20` for `2 s`; on `crit` (`per_pulse: 1`): `heal: 0.02` | Adapted for 1v1 duel; post-fight hirer-survival full heal unmodelled |
| `The Last Step` (`py-grey-seal` 2pc) | Vanish/evade -> next sword art in 2 s +30 % dmg; Broken -> vanish; Return to Scabbard (3 s no dmg art -> unstruck + vanish) | `evaded` / `broken` / `scabbard_idle >= 3` arm `last_step` (`each_for: 2`, `+30 % dmg_more [sword]`); 3 idle pulses reset `first_sword_done` (`acc: 500`) and trigger vanish | Matches `thinh_vu` `Return to the Scabbard` pulse counter idiom |

---

## §C Techniques (`design/stage6-staging/phat_y/techniques/catalogue-sect-phat_y.json`)

| ID | Kind / Tier | Names | Layers | Bonuses (new) | Passives (new) | W Used / Budget | Abilities & Effects |
|---|---|---|---:|---|---|---:|---|
| `dry-road-sword-primer` | `main` / 0 | `["kim", "hoa"]` | 6 | `—` | `attack_pct 4 [sword]`, `art_speed_pct 4 [sword]`, `khi_huyet_pct 4` | `6.7 W of 8` | `noon-guard` (L1) |
| `contract-sword-canon` | `main` / 1 | `["kim"]` | 9 | `attack_pct 10` | `attack_pct 6 [sword]`, `crit_chance_pct 5 [sword]`, `evade_pct 4`, `linh_luc_regen_inc_pct 3` | `15.7 W of 16` | `final-count` (L1), `step-back` (L2); `Serve a Term` (L1) |
| `brushed-sleeve-step` | `secret` / 2 | `["phong"]` | 12 | `attack_pct 10`, `travel_speed_pct 12` | `evade_pct 5`, `art_speed_pct 10 [sword]`, `attack_pct 8 [kim]`, `stack_duration_pct 12 [phong, debuff]`, `basic_speed_pct 12` | `22.0 W of 24` | `brush-the-sleeve` (L1), `a-thousand-sleeves` (L4) |

---

## §D Arts (`design/stage6-staging/phat_y/arts/part-sect-phat_y.json`)

`lint_arts.py` output: `checked 5 arts in 1 files, 0 findings` (`final-count empower 1: x1.16 of the lint, gated`).

| ID | Group | Element / Kind / Role | `c_art` / Cost / CD | Tags | Wired `"id"` in `phat_y.techniques.json` |
|---|---|---|---|---|---|
| `noon-guard` | `dry-road-sword-primer` | `""` / `phys` / `ward` | `0.0` / `0.03` / `4.0 s` | `sword`, `stance` | Yes (L1) |
| `final-count` | `contract-sword-canon` | `metal` / `elem` / `damage` | `2.2` (`debuff [2, 6]`) / `0.05` / `7.0 s` | `kim`, `sword`, `heavy` | Yes (L1) |
| `step-back` | `contract-sword-canon` | `metal` / `elem` / `ward` | `0.0` / `0.02` / `1.55 s` | `kim`, `sword`, `movement` | Yes (L2) |
| `brush-the-sleeve` | `brushed-sleeve-step` | `wind` / `elem` / `ward` | `0.0` / `0.03` / `5.0 s` | `phong`, `ward`, `movement` | Yes (L1) |
| `a-thousand-sleeves` | `brushed-sleeve-step` | `wind` / `elem` / `damage` | `1.5` (`debuff [2, 6]`) / `0.04` / `7.0 s` | `phong`, `sword`, `movement` | Yes (L4) |

---

## §E Effects (`design/stage6-staging/phat_y/effects/phat_y.effects.json`)

All 4 Effects passed `STANDALONE_EFFECT_CHECK: OK 4` (every counter read or written is declared in that Effect's own `counters` array; no `states` set; no duplicate `mod` without `stack: true`).

| Effect Name | Source | Declared Counters | Notes |
|---|---|---|---|
| `Serve a Term` | `contract-sword-canon` (L1) | `term`, `term_struck` | Serves `1` Term on `pulse` when `own.pressing >= 1` and `term_struck == 0`, or on `evaded` (`per_pulse: 1`); strips `1` Term on enemy `art` `was_hit` (`cooldown: 3.0`) |
| `Gone Before Thanks` | `py-grey-sleeve` | `vanish_crit` | On `broken`: `decoy {n: 1}`, `evade: 40` (`2.0 s`), `vanish_crit = 1` (`sure_crit: 1 [metal]` until Metal `crit`) |
| `Paid in Full` | `py-contract-seal`, `py-hired-pair` (2pc) | `—` | Idempotent `was_hit` (`cd 4.0 s`) -> `dampen_taken: 20` (`2.0 s`), `crit` (`per_pulse: 1`) -> `heal: 0.02` |
| `The Last Step` | `py-grey-seal` (2pc) | `last_step`, `vanish_crit`, `scabbard_acted`, `scabbard_idle`, `first_sword_done` | `evaded`/`broken` -> `last_step` (`each_for: 2`, `+30 % dmg_more [sword]`); 3 idle pulses -> sheath vanish + un-evadable next sword art (`acc: 500`) |

---

## §F Items and Sets (`design/stage6-staging/phat_y/items/catalogue-sect-phat_y.json`, `sets-phat_y.json`)

`lint_items.py` output: `checked 4 items, 22 bases, 9 common arts, 0 findings`.

| ID | Base / Kind / Grade | W (`of Limit`) | Holder | Set | Effects / Exceptions |
|---|---|---:|---|---|---|
| `py-grey-sleeve` | `dao_bao` / `artifact` / 4 | `33.6 W of 51.2` | `thang_vo_ta` | `py-grey-seal` | `Gone Before Thanks`, `unique: true`, R6 common-art/ward exception |
| `py-contract-seal` | `an` / `artifact` / 3 | `24.8 W of 38.4` | `lam_khe_ngon` | `py-hired-pair` | `Paid in Full`, `unique: true`, R6 common-art/ward exception |
| `py-sleeve-token` | `ngoc_boi` / `artifact` / 3 | `23.2 W of 38.4` | `thang_vo_ta` | `py-grey-seal` | `unique: true` |
| `py-contract-blade` | `phi_kiem` / `artifact` / 2 | `17.8 W of 25.6` | `lam_khe_ngon` | `py-hired-pair` | `unique: true`, R6 common-art/ward exception |

Sets staged:
- `py-grey-seal` (`Grey Sleeve and Seal (Phất Y Khế Ấn)`): 2pc `crit_chance_pct 4 [sword]`, `evade_pct 3`, Effect `The Last Step`.
- `py-hired-pair` (`Hired Sword's Pair (Dung Kiếm Song Bảo)`): 2pc `khi_huyet_pct 6`, `health_regen_inc_pct 10`, Effect `Paid in Full`.

---

## §G Stand-ins, Beasts & Cross-Owner References

- **Stand-ins:** `0` (`phat_y`'s cast already uses `dry-road-sword-primer`, `contract-sword-canon`, `debt-ledger-blade`, `afterimage-sword-canon`, `brushed-sleeve-step`).
- **Beasts:** `0`.
- **Cross-owner references:** `2` incoming references from `loose-south` (`tu_ban_kiem`) and `market-folk` (`dieu_thiet_tien`) to `phat_y`'s `dry-road-sword-primer`; both close once the serial step merges `phat_y`.
- **Events:** `3` structured events (`N-phat_y-01..03`).

---

## §H Holder Check (`sect_fight.py phat_y --seeds 5 --gap 0` and `--gap 1`)

- **Refused:** `0` at `--gap 0`, `0` at `--gap 1`.
- **Never fired:** `0` at `--gap 0`, `0` at `--gap 1` across all 17 living holders.

| Holder | Realm | `--gap 0` (`t` / wins / `hp_left`) | `--gap 1` (`t` / wins / `hp_left`) | Effect With / Without & Runs (`--gap 0`) |
|---|---|---|---|---|
| `thang_vo_ta` | `ket_dan` | `12.1 s` / `5` / `91%` | `15.2 s` / `0` / `0%` | `Serve a Term`: `12.1 s 91%` / `12.3 s 90%` (`190`); `Marked Prey`: `12.1 s 91%` / `12.3 s 91%` (`0`, `always` mod); `Gone Before Thanks`: `12.1 s 91%` / `12.1 s 91%` (`5`); `The Last Step`: `12.1 s 91%` / `12.4 s 91%` (`233`) |
| `lam_khe_ngon` | `truc_co` | `28.4 s` / `5` / `66%` | `10.2 s` / `0` / `0%` | `Serve a Term`: `28.4 s 66%` / `32.2 s 59%` (`222`); `Paid in Full`: `28.4 s 66%` / `28.2 s 53%` (`72`) |
| `khuc_liet_duong`, `tiet_hoanh_sa` | `truc_co` | `31.0 s` / `5` / `28%` | `8.4 s` / `0` / `0%` | `Serve a Term`: `31.0 s 28%` / `35.8 s 15%` (`245`) |
| `au_duong_kien` | `truc_co` | `44.6 s` / `5` / `36%` | `9.8 s` / `0` / `0%` | `Serve a Term`: `44.6 s 36%` / `54.6 s 0%` (`284`) |
| `kieu_tinh_son`, `thoi_an_thu` | `truc_co` | `44.8 s` / `5` / `36%` | `9.8 s` / `0` / `0%` | `Serve a Term`: `44.8 s 36%` / `54.6 s 0%` (`286`) |
| `lo_khinh_tran`, `vien_tich_chieu`, `au_duong_tuyen`, `manh_thu_cam` | `luyen_khi` | `42.2 s` / `4` / `20%` | `9.0 s` / `0` / `0%` | `Serve a Term`: `42.2 s 20%` / `45.6 s 0%` (`237`) |
| `giang_bich_sa`, `cat_da_binh`, `hua_ngan_son`, `lieu_vong_phong`, `hoac_ngo_lo`, `yen_lac_tu` | `luyen_khi` | `61.4 s` / `0` / `0%` | `9.2 s` / `0` / `0%` | `noon-guard` fires `1.0` (`heat` buffs basic attacks) |

**Targeted probes:**
- `brushed-sleeve-step` + `blade-thousand-cut-return` on `thang_vo_ta` (seed 1, overriding 6-slot list to include `brush-the-sleeve`, `a-thousand-sleeves`, `blade-thousand-cut-return`): `win = A`, `t = 12.5 s`, `brush-the-sleeve` `3` fires (`brush-the-sleeve-turn: 3`, `brush-the-sleeve-haste: 4`), `a-thousand-sleeves` `2` fires (`a-thousand-sleeves-enter: 2`, `a-thousand-sleeves-echo: 14`).
- `final-count` 5-seed empower (`term >= 5`) probe: `au_duong_kien`, `thoi_an_thu`, `kieu_tinh_son` each triggered `12` empowers across 5 seeds.
- Never ran at `--gap 1`: `Gone Before Thanks` (`runs 0` on `thang_vo_ta` at `--gap 1` because `thang_vo_ta` falls to the `nguyen_anh` typical foe at `15.2 s` before dropping it to `25 %` `broken`), and `Marked Prey` (pre-existing `on: "always"` Effect on `blade-thousand-cut-sword`, `runs 0` in `Fight.do()`).

---

## §I Open Items

- **Serial merge & export:** Merge `design/stage6-staging/phat_y/` into `design/` and `assets/data/combat_effects.json` via `stage6_merge.py`, and run `export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, and `export_world.py`.
- **`khi_van` out-of-fight reader:** `py-contract-seal`'s `khi_van: 1` remains `game` in `depth_gap.py` until a global GDScript stat-sheet reader consumes `khi_van`.
- **Multi-ally `Paid in Full` full-heal clause:** If allied-companion / multi-fighter contracts are restored later, add the post-fight hirer-survival full heal to `Paid in Full`.

REVIEW DONE
