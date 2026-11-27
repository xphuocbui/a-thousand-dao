## Summary

Stage 6 Hydrogen record pass for OWNER `market-folk` (`design/world/depth/people/market-folk.*`, Batch `b06`) is complete and staged cleanly under `design/stage6-staging/market-folk/`.

- **Techniques (`8`)**: Preserved committed `censer-smoke-manual` verbatim; authored the 3 proposal techniques (`golden-valley-ledger-canon`, `second-spring-needle-art`, `loom-of-letters-array`) plus 4 stand-in methods (`buried-vault-coin-canon`, `bronze-sounding-canon`, `market-scale-breath`, `river-road-breath`) in `techniques/catalogue-sect-market-folk.json` (`0 findings` in `lint_techniques.py`).
- **Signature Arts (`12`)**: Preserved committed `pill-smoke` verbatim; authored the 6 proposal arts (`balance-the-books`, `call-the-debt`, `draw-the-poison`, `apricot-second-spring`, `relay-the-grid`, `walking-ward`) plus 5 stand-in arts (`vault-coin-toss`, `gold-buys-the-blow`, `ring-the-flaw`, `weighed-palm`, `ferryman-step`) in `arts/part-sect-market-folk.json` (`0 findings` in `lint_arts.py`). Renamed `second-spring-needle-art`'s `"Second Spring (Hồi Xuân)"` art ID to `apricot-second-spring` to avoid clashing with committed `design/arts/family-wood.json`'s `second-spring`.
- **Items & Sets (`25` items, `8` sets)**: Staged all 25 items (`0 findings` in `lint_items.py`, applying the R6 base common-art/ward exception to the 13 items whose bases carry a common art or ward, and giving `mf-peach-spring-painting` `"base": "ky", "rarity": 5`) and all 8 sets in `items/catalogue-sect-market-folk.json` and `items/sets-market-folk.json`.
- **Effects (`17` authored + `1` existing ref)**: Staged all 17 `market-folk`-owned Effects in `effects/market-folk.effects.json` (`"source": "world-depth:market-folk"`), every Effect standalone-complete in `counters`/`states` and passing `engine.validate` + solo fight simulation. Resolved the `"Know the Way Out"` clash (`mf-way-out-knot`) by setting `"new": false` (already shipped in `assets/data/combat_effects.json` from `world-depth:thien_xu`), and resolved the `"Second Spring"` item-vs-set name collision by renaming `mf-apricot-clinic`'s 3pc Effect to `"Apricot Clinic's Spring (Hạnh Quán Hồi Xuân)"`.
- **Stand-ins (`20 -> 0`)**: Replaced all 20 stand-ins across `market-folk.cast.json` (4) and `market-folk.2.cast.json` (16), and linked `censer-smoke-manual`, `second-spring-needle-art`, and `loom-of-letters-array` onto their lore holders (`lac_dan_thanh`, `gia_hoi_xuan`, `ve_van_co`).
- **Verification**: `lint_arts.py` (0), `lint_techniques.py` (0), `lint_items.py` (0), standalone `engine.validate` (17/17 OK), spatial scan on staged + `market-folk.*` files (0 hits), `depth_check.py` (0 `market-folk` findings; 2 unrelated `demonic.cast.json` staged-main warnings), `depth_gap.py --sect market-folk` (0 `stand_ins`, 0 `unknown_ids`, 0 `wishes_open`, 0 `engine_words`), `stage6_merge.py market-folk --check` (`0 failure(s)`), `sect_fight.py market-folk --seeds 5` at `--gap 0` and `--gap 1` (exit 0, zero `REFUSED`, every slotted art fires), plus targeted Effect probes for all conditional/pill/cleanse/always Effects.

## Auto-Accepted Decisions (Headless Stage 6 Policy)

1. **`Know the Way Out` clash (`mf-way-out-knot`)**: `"Know the Way Out"` already lives in `assets/data/combat_effects.json` under `"source": "world-depth:thien_xu"`. Set `"new": false` in `market-folk.items.json` so `market-folk` references the shared Effect cleanly.
2. **Duplicate `"Second Spring"` Effect name**: `mf-second-spring-needles` (item) and `mf-apricot-clinic` (3pc set) both named `"Second Spring (Hồi Xuân)"` with different rules. Kept `"Second Spring (Hồi Xuân)"` on the needles and renamed the 3pc set bonus to `"Apricot Clinic's Spring (Hạnh Quán Hồi Xuân)"` in `market-folk.items.json`, `sets-market-folk.json`, and `market-folk.effects.json`.
3. **Art ID collision (`apricot-second-spring`)**: Committed `design/arts/family-wood.json` already owns `"second-spring"` (`verdant-cycle-scripture`), so `second-spring-needle-art`'s art uses `"id": "apricot-second-spring"`.
4. **Treasury base & R6 item exceptions**: Gave `mf-peach-spring-painting` (`kind: "treasure"`, `base: null` in depth) `"base": "ky", "rarity": 5, "grade": 4` matching `nv-plain-silk-scroll`; left `"arts": []` with the R6 `exception` string on the 13 items whose bases have a `common_art` or `common_ward`, and omitted `exception` on `huong_lo`, `ky`, `kinh`, `nhan`, `ngoc_boi`.
5. **Non-spatial rule alignment**: Replaced spatial wording in staged and depth rule text (`stand still` -> `Composed`, `once you move` -> `once you are Pressing`, `every foe near you` / `each foe hit` / `hold on foes` -> `the foe` / `each hit`, `ambush or a blind fight` -> `open at fight start`, `knocked back or moved` -> `delayed or moved`, `long river hauls` -> `long river voyages`, `moves debuffs off allies` -> `moves debuffs off patients`).
6. **Cast linking & stand-in resolution**: Linked `censer-smoke-manual@6` on `lac_dan_thanh`, `second-spring-needle-art@6` on `gia_hoi_xuan`, and `loom-of-letters-array@6` on `ve_van_co` (before `mountain-bone-body-art` so all 6 signature array arts run within `MAX_ARTS = 6`). Resolved all 20 stand-ins cleanly without modifying `foreign/` or non-market-folk depth files.

## Stand-In Mapping (20 / 20 Resolved)

| Person | Old Stand-In | Replacement Technique | Layer | Source File |
|---|---|---|---|---|
| `kim_van_ly` | `dia_tho` | `buried-vault-coin-canon` | 8 | `market-folk.cast.json` |
| `tu_binh_quyen` | `huyen_kim` | `golden-valley-ledger-canon` | 7 | `market-folk.cast.json` |
| `quan_phuc_thu` | `huyen_tho` | `golden-valley-ledger-canon` | 5 | `market-folk.cast.json` |
| `lieu_thinh_kim` | `huyen_kim` | `bronze-sounding-canon` | 6 | `market-folk.cast.json` |
| `quan_than_ngon` | `huyen_tho` | `golden-valley-ledger-canon` | 3 | `market-folk.2.cast.json` |
| `tu_thien_toan` | `huyen_kim` | `golden-valley-ledger-canon` | 3 | `market-folk.2.cast.json` |
| `banh_cham_thach` | `huyen_tho` | `mountain-heart-canon` | 4 | `market-folk.2.cast.json` |
| `ho_dien_linh` | `huyen_tho` | `mountain-heart-canon` | 4 | `market-folk.2.cast.json` |
| `hoang_phu_duyen` | `huyen_thuy` | `still-moon-tide-scripture` | 4 | `market-folk.2.cast.json` |
| `bang_thu_khe` | `hoang_moc` | `verdant-cycle-scripture` | 5 | `market-folk.2.cast.json` |
| `su_que_huong` | `hoang_moc` | `verdant-cycle-scripture` | 4 | `market-folk.2.cast.json` |
| `tang_bach_thong` | `hoang_tho` | `market-scale-breath` | 6 | `market-folk.2.cast.json` |
| `tang_phan_ly` | `hoang_tho` | `market-scale-breath` | 3 | `market-folk.2.cast.json` |
| `bi_tieu_tho` | `hoang_tho` | `market-scale-breath` | 2 | `market-folk.2.cast.json` |
| `kim_tich_phuc` | `hoang_thuy` | `river-road-breath` | 6 | `market-folk.2.cast.json` |
| `dai_song_luc` | `hoang_thuy` | `river-road-breath` | 3 | `market-folk.2.cast.json` |
| `quan_liem_chu` | `hoang_thuy` | `river-road-breath` | 4 | `market-folk.2.cast.json` |
| `ha_kho_sam` | `hoang_thuy` | `river-road-breath` | 4 | `market-folk.2.cast.json` |
| `hoang_phu_chu` | `hoang_thuy` | `river-road-breath` | 3 | `market-folk.2.cast.json` |
| `ky_minh_tien` | `hoang_thuy` | `river-road-breath` | 3 | `market-folk.2.cast.json` |

## Effect Mechanics, Depth-vs-Engine Diffs & `NEVER_RAN` Audit

| Effect | Holder / Source | Depth vs Engine Notes | `sect_fight` Runs (gap 0) | Targeted Probe / Reason |
|---|---|---|---|---|
| `Ground Like Paint` | `mf-vermilion-azure-censer` (`lac_dan_thanh`) | `pill_burned` echoes `2 * grade` Fire debuffs + `2% * grade` heal 3 s later; failed pill runs once/fight (`event.failed >= 1`). | `0` (`NEVER_RAN`) | Typical builds lack a prepared pill slot. Probe with `pill={element:"fire", grade:2, fail:0/1}` ran `arm=1, grade=1, tick=3, echo=1, fail=1`. |
| `The Way In` | `mf-peach-spring-painting` (unequipped treasure) | `not_run`: out-of-fight Đào Nguyên Cảnh entry key (`records: []`). | N/A | Non-combat exploration rule. |
| `Second Spring` | `mf-second-spring-needles` (`gia_hoi_xuan`) | Below 25% HP once/fight cleanses 3 Wood debuffs + 1 curse and grants `status_resist +50` for 5 s (`approx`). | `0` (`NEVER_RAN`) | `gia_hoi_xuan` wins at 100% HP vs `typical`. Gap+1 burst probe reaching `<0.25` HP ran `eff:Second Spring=1`. |
| `Apricot Clinic's Spring` | `mf-apricot-clinic` 3pc (`gia_hoi_xuan`) | `on: "always"` `tick_to_heal: 50` for `element: "wood"` (`Fight.mod` read, not `Fight.do`). | `0` (`NEVER_RAN`) | `always` mods bypass `Fight.do` counter; probe confirmed `f.mod(A, "tick_to_heal", {"element": "wood"}) == 50.0`. |
| `The Losing Hand` | `mf-losing-hand-ring` (`kim_van_ly`) | Exact: first damaging crit sets `losing_hand_hits = 3` (`acc: 500`), spends 1 per `hit_landed`. | `20` | Active in live `sect_fight`. |
| `Lose to Win` | `mf-losing-hand` 2pc (`kim_van_ly`) | Exact: crits add 4 s `vault_coins` (`each_for: 4.0`); next `coin` art grants `crit +10` + `0.03` body shield/coin and clears. | `37` | Active in live `sect_fight` (`94%` vs `89%` without). |
| `Carried Array` | `mf-loom-of-letters-seal` (`ve_van_co`) | Grants `+100%` formation `art_speed` after first formation cast and refreshes active `stars_bow` / `walking_field` once/fight. | `5` | Active in live `sect_fight` (`17.8 s` vs `20.8 s` without). |
| `The Array Comes With Me` | `mf-carried-array` 3pc (`ve_van_co`) | `opening_haste +20` + `was_hit` (`own.field_up >= 1`, `cooldown: 1.0`) answers with `0.4 c` Physical free hit. | `45` | Active in live `sect_fight` (`17.8 s` vs `18.8 s` without). |
| `Paid in Full` | `mf-golden-valley-seal` (`quan_phuc_thu`, off-gear item note) | `fight_start` `protect {el: "earth"/"metal", for_first: 4.0}` (`approx` half of 8 s duration). | N/A (`quan_phuc_thu` wears 2pc pledge+surety; seal in box) | Cleanse probe on synthetic 3pc + `quan_phuc_thu` confirmed `eff:Paid in Full=1`. |
| `The Books Balance` | `mf-golden-valley-suite` 3pc (split across Từ, Quản, lost pearl) | `on: "cleansed"` deals `0.25 c` shield-piercing Chaos per stack cleansed (`approx`). | N/A | Synthetic 3pc + cleansing foe probe ran `eff:The Books Balance=17`. |
| `Change Expected` | `mf-fair-weights` 2pc (`tu_binh_quyen`) | Immediate `return_damage {share: 0.2, dtype: "phys"}` on damaging `was_hit` (`cooldown: 2.0`, `approx` for next-hit return). | `107` | Active in live `sect_fight`. |
| `Heavy Keel` | `mf-sea-crossing-anchor` (`bao_te_hai`) | `on: "always"` `if: own.composed >= 1` grants `delay_immune: 1, unmoved: 1` (`Fight.mod` read). | `0` (`NEVER_RAN`) | `always` mod; live `Fight` check confirmed `composed=True, delay_immune=1.0, unmoved=1.0`. |
| `Ride Out the Storm` | `mf-bao-hull` 3pc (`bao_te_hai`) | While Composed regains `2%` qi/s + 1 indefinite Water buff/s; each stack gives `dampen_taken +1`; consumes 1 Water buff/s when `composed < 1`. | `65` | Active in live `sect_fight`. |
| `Hear the Flaw` | `mf-listening-bronze-mirror` (`lieu_thinh_kim`) | `flaw_heard` (`cap: 1`) grants `pen: 150` until first `hit_landed` (`approx`). | `5` | Active in live `sect_fight`. |
| `Unstamped` | `mf-scorched-cloud-seal` (`trinh_chu_sa`) | `cost_red: 0.333` on `talisman`; deterministic 10th-talisman misfire (`dmg_more: -1.0`, `approx`). | `131` | Active in live `sect_fight`. |
| `Even Failures Are Pills` | `mf-vermilion-azure` 3pc (`lac_dan_thanh`) | `pill_burned`: +2 Fire stacks (6 s), `1%` heal per Fire stack on foe, `self_hit c: 0.4` Chaos past 3 pills/fight (`approx`). | `0` (`NEVER_RAN`) | Pill probes confirmed `fire=1, heal=1` on both succeeding and failing pills (`cost` awaits multi-pill support). |
| `Paid Back` | `mf-collected-in-full` 2pc (`quan_phuc_thu`) | At `foe.debuff.earth >= 5`, engages `protect {el: "earth"}` once/fight and pulses `0.25 c` Chaos + `1%` heal (`approx`). | `178` | Active in live `sect_fight` (`43.6 s 72%` vs `58.2 s 18%` without). |

Foreign `NEVER_RAN` entries in `sect_fight.py` (untouched by this owner pass): `hoang_phu_duyen`'s `Know the Way Out` (`world-depth:thien_xu`; requires `escape_failed`), `kim_van_ly`'s `Seal of Full Payment` (foreign item `metal-heaven-minted-coin`), and `trinh_chu_sa`'s `Paid in Advance` (foreign technique/item condition).

## Holder Table (`sect_fight.py market-folk --seeds 5 --gap 0`)

- **All 25 authored/stand-in holders ran cleanly with 0 `REFUSED` errors.**
- **Signature art firing rates** (`--gap 0`): `lac_dan_thanh` (`pill-smoke` 2.2/fight), `gia_hoi_xuan` (`draw-the-poison` 3.0, `apricot-second-spring` 2.0), `kim_van_ly` (`vault-coin-toss` 10.8, `gold-buys-the-blow` 4.6), `ve_van_co` (`relay-the-grid` 7.0, `walking-ward` 3.0), `tu_binh_quyen` (`balance-the-books` 9.4, `call-the-debt` 6.0), `quan_phuc_thu` (`balance-the-books` 8.6, `call-the-debt` 5.8), `lieu_thinh_kim` (`ring-the-flaw` 11.4), `market-scale-breath` (`weighed-palm` 11.6-13.2), `river-road-breath` (`ferryman-step` 9.6-11.4).
- **Outcomes (`--gap 0` / `--gap 1`)**: Ket Đan heads (`lac_dan_thanh` 5 wins 72%, `gia_hoi_xuan` 5 wins 100%, `kim_van_ly` 5 wins 94%, `ve_van_co` 5 wins 100%, `tu_binh_quyen` 5 wins 55%, `bao_te_hai` 5 wins 100%, `lieu_thinh_kim` 5 wins 7%, `trinh_chu_sa` 5 wins 100%) and Trúc Cơ broker `quan_phuc_thu` (5 wins 72%) defeat same-realm `typical` foes; `quan_than_ngon` & `tu_thien_toan` win 3/5 at Luyện Khí. At `--gap 1`, one-realm-up `typical` foes defeat market folk as expected (`0` wins), verifying no runaway scaling.
