# Thiên Bảo Trai: Stage 6 checkpoint review (2026-11-27, unanchored review)

Reviewed all staged records in `design/stage6-staging/thien_bao/` against the depth source of truth (`design/world/depth/sects/thien_bao.*`, `thien_bao.md`), `tools/design/combat_sim/FIGHT-INPUT.md`, both engines (`tools/design/combat_sim/engine.py` and `src/gameplay/combat/fight/effect_runner.gd` / `effect_compiler.gd`), and the standing design rulings (`DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`).

All **5 MUST-FIX** and **4 SHOULD** findings were applied to the staged files and verified with all three linters (0 findings), `depth_gap.py`, `spatial_words_check.py` (0 rule hits), `sect_fight.py thien_bao --seeds 5` at gap 0 and `--gap 1` (0 `REFUSED`, 0 `NEVER_FIRED`, 0 `NEVER_RAN`), and targeted regression probes.

---

## 1. Ranked findings (all MUST-FIX and SHOULD fixed)

| # | Severity | File & Record | What was wrong | Fix applied & verified |
|---|---|---|---|---|
| 1 | **MUST-FIX** | `design/stage6-staging/thien_bao/effects/thien_bao.effects.json` (`Going Once, Going Twice`, `Grown, Not Made`) & `arts/part-sect-thien_bao.json` (`pawn-the-pearl`) | **Fatal `down` deadlock + pulse spam:** `Going Once, Going Twice` synced `seal_ward_protects` only on `pulse` (`ward_check` / `ward_gone`), and `Grown, Not Made save` required `seal_ward_protects == 0`. Whenever a lethal hit broke the Seal's stance ward mid-pulse (reducing `own.ward_share` to `0` before `defeat_check()`), `pearl_ward` failed (`ward_share == 0`) AND `Grown, Not Made save` failed (`seal_ward_protects == 1`), killing `phan_vat_hoa` with **zero Down saves** (reproduced 3/3 seeds against a high-damage nuke after `Sold`). The pulse listeners also inflated `Going Once, Going Twice` to 80–86 fake `ward_gone` runs per 5 seeds even when `Sold` never fired. | Replaced `seal_ward_protects`, `ward_check`, and `ward_gone` with a one-time `fight_start` flag `has_hammer_pearl_set = 1` in `Going Once, Going Twice`, and gated `Grown, Not Made save` on `any: [has_hammer_pearl_set == 0, own.ward_share <= 0]`. Removed dead `seal_ward_protects` from `pawn-the-pearl`. Verified: 3/3 nuke-after-`Sold` seeds now trigger `Grown, Not Made save` (`refused`, `cracked=1`); lethal Soul hit while `ward_share > 0` triggers `Going Once, Going Twice pearl_ward` (`refused`, `sward=0`, `cracked=0`). |
| 2 | **MUST-FIX** | `design/stage6-staging/thien_bao/arts/part-sect-thien_bao.json` (`the-treasure-answers` / `treasure-answers-buff`) | **Primary buff silently deleted on cast + cooldown lockstep:** `treasure-answers-buff` put two non-stacking `mod` actions (`L3 +35 / dmg_more 0.15 [artifact]` and `stack_dur +50 [metal, debuff]`) inside the same `art_fired` record. Both engines (`engine.py:1831`, `effect_runner.gd:392`) clear all `temp_mods` sharing `e.id` before each non-stacking `mod` action, so the second action immediately wiped `L3 +35` and `dmg_more 0.15` before they existed for a single ms. In addition, `cooldown: 8.0` matched `hammer-price` (`8.0`) in slot order after it, so `the-treasure-answers` fired after `hammer-price` and expired before the next `hammer-price`. | Split into two distinct records (`treasure-answers-grade` and `treasure-answers-stacks`) and set `cooldown: 7.0` with duration `5 s` (rule updated). Verified: `hammer-price` at `t=6.78 s` and `13.56 s` now sees all three temp mods (`L3 +35`, `dmg_more +0.15`, `stack_dur +50`) active. |
| 3 | **MUST-FIX** | `design/stage6-staging/thien_bao/arts/part-sect-thien_bao.json` (`hammer-price` / `hammer-consume`) | **`dmg_more` leaked to other hits at the same timestamp:** `consume.then` applied unscoped `{"mod": {"dmg_more": 0.14}}` with `until = t + 1`. Any `basic` attack, `crucible-retaliate` trigger, or co-firing art on the same millisecond stole the full `+14 % per stack` (`+140 %+`) multiplier (verified on `tien_ngu_phan` at `t=8.0 s` and `16.0 s`, where a basic attack dealt 777 dmg). | Stored consumed stacks in counter `hammer_stacks` (reset in `hammer-reset`, added in `hammer-consume`), applied `dmg_more: 0.14` via `always` record `hammer-bonus` scoped `tags: ["heavy"], kind: "art"` scaled by `hammer_stacks`, and cleared `hammer_stacks = 0` immediately on `hit_landed` and `was_evaded` for `art_id: "hammer-price"` (plus `hammer-clear` on `pulse` fallback). Verified: 0 non-art hits leak the bonus. |
| 4 | **MUST-FIX** | `design/stage6-staging/thien_bao/arts/part-sect-thien_bao.json` (`third-price` / `third-price-mod`) | **Free buff on basic attacks and triggers:** `third-price-mod` (`on: "always"`) granted `pen: 120, dmg_more: 0.25` unscoped while `third-price-spend` only spent charges on `hit_landed` with `filter: {"kind": "art"}`. All basic attacks and `crucible-retaliate` triggers received `+120 pen, +25 % dmg_more` without spending charges (verified: 11 hits buffed for 3 charges on `tien_ngu_phan`). | Added `"kind": "art"` inside `third-price-mod`'s `mod`, matching both `third-price-spend` and the rule text ("your next 3 art hits"). Verified: 0 basic or trigger hits receive `third-price`. |
| 5 | **MUST-FIX** | `design/stage6-staging/thien_bao/arts/part-sect-thien_bao.json` (`pawn-the-pearl` / `pawn-pearl-crack`) | **Double crack penalty on `phan_vat_hoa`:** `pawn-pearl-crack` checked only `pearl_cracked >= 1` and omitted `has_grown_pearl == 0`. When `Grown, Not Made` cracked on `phan_vat_hoa`, both `pawn-pearl-crack` and `eff:Grown, Not Made crack` activated, doubling her penalty to `ward_pct -20, L1 -20` (verified at gap 1). | Added `{"read": "own.counter.has_grown_pearl", "op": "==", "value": 0}` to `pawn-pearl-crack`. Verified: `phan_vat_hoa` now takes exact single crack penalty (`ward_pct -10`, `L1 -10`, `stack_dur -24 [metal, buff]`). |
| 6 | **SHOULD** | `design/stage6-staging/thien_bao/arts/part-sect-thien_bao.json` (`crucible-guard`) | **Builder/spender lockstep:** `crucible-guard` (`cooldown: 8.0`, `dur: 6 s`) fired on the exact same millisecond as `hammer-price` (`cooldown: 8.0`), so Cycle 1 `hammer-price` never benefited from `crucible-guard`'s Earth/Metal stacks and `Sold` showed `0 runs NEVER_RAN` at `--gap 1`. | Adjusted `crucible-guard` to `cooldown: 6.5` and duration `5 s` (`crucible_t = 5`, rule text updated) so the stance opens ahead of `hammer-price` while keeping a 1.5 s downtime window. Verified: `Sold` now runs 10 times / 5 seeds at gap 0 and 5 times / 5 seeds at `--gap 1` (0 `NEVER_RAN`). |
| 7 | **SHOULD** | `design/stage6-staging/thien_bao/effects/thien_bao.effects.json` (`Going Once, Going Twice` / `fate_arm`) | **First `Bought Fate` flip did not pay from Seal ward:** `fate_arm` set `fate_flip_seen = 1` without deducting from the stance ward even when `own.ward_share > 0`, despite the rule text ("the Coin's Bought Fate is paid from the ward the Seal has taken from the foe instead of from your spirit stones, and may flip twice a fight"). | Split `fate_arm` into `fate_first_ward` (when `own.ward_share > 0`, spends `ward_grow -0.04 hp` and sets `fate_flip_seen = 1`) and `fate_first` (when `own.ward_share <= 0`, sets `fate_flip_seen = 1`), both after `fate` (the 2nd flip). |
| 8 | **SHOULD** | `design/stage6-staging/thien_bao/effects/thien_bao.effects.json` (`Grown, Not Made`) | **Missing `approx` note:** `Grown, Not Made` had no `"approx"` field even though its unstealable/unsellable clause is out-of-fight and mid-fight removal of static modifiers (`khi_huyet_pct 15`, `than_thuc_pct 8`, `stack_effect_pct 24 [kim, buff]`) is approximated by `ward_pct -10, L1 -10, stack_dur -24 [metal, buff]`. | Added concise `"approx"` documenting both. |
| 9 | **SHOULD** | `design/stage6-staging/thien_bao/techniques/catalogue-sect-thien_bao.json` (`heaven-treasure-refining-canon`) | **Earth passive scope mismatch:** carried `stack_effect_pct 10 ["tho", "debuff"]` (accuracy reduction) rather than `["tho", "buff"]` (physical dampening), whereas the canon's concept states "Earth holds the refiner up while the treasures work" and `crucible-guard` grants `[2, 8]` Earth buff stacks. | Changed passive scope to `["tho", "buff"]` (W budget unchanged at `23.7 W of 24`). |
| 10 | **NIT** | `design/world/depth/sects/thien_bao.cast.json` (`quan_tay_ngoc`) | `build.note` still reads `"A washer; a stand-in method."` after assignment of `brook-wash-breath`. | Logged only (no edit needed to depth cast prose). |

---

## 2. Pending words (`design/stage6-staging/thien_bao/pending.json`)

`pending.json` contains **0 pending words** (`{"words": [], "arts": [], "effects": {}}`).

Verified each approximation against the dual-engine bar ("must be worth building in two engines for builds that will really use it"):
- **Artifact suppression / modifier lowering (`hammer-price`, `third-price`) and mid-fight pearl modifier loss (`Grown, Not Made`):** tracking per-item static modifier contributions for mid-fight disable/strip in both Python and GDScript would be a large architectural change for three records of one sect; `sundered` + `silence [artifact]`, scoped `pen` + `dmg_more`, and `ward_pct` / `L1` / `stack_dur` penalties preserve the combat intent cleanly using existing words.
- **Second Down refusal (`Going Once, Going Twice`):** Effects rule 11 deliberately caps Down refusals at 1 per fight (`refusals: 1`). Spending the Seal's stance ward instead of cracking the Pearl keeps the synergy without breaching the rule.
- **20 % defence ignore (`Fights With What He Made`):** `pen: 95` (~20 % of a typical Kết Đan ward) works at both gap 0 and gap 1 without adding a new percentage-penetration stat for one set.
- **`artifact_attack_pct` (2 open modifier lines in `depth_gap.py`):** already a known item modifier key in `lint_items.py` and `CombatPower.artifact_numbers`; set-level and `fight.py` support remain an open serial/game-side item rather than a `pending.json` Effect word.

---

## 3. Faithfulness, design rules, and stand-ins

- **Design rules:** zero environment/time-of-day conditions, zero spatial-fight hits in rule fields (`spatial_words_check.py --sect thien_bao`: 1 non-rule tie note `"flag-poles"` on `khang_thien_chuy`), uncapped scaling on `hammer-price` (`+14 %` per consumed Metal stack), all Effects unpriced, all 6 items carry `sources: ["npc"]`, `unique: true`, and R6 `exception` on the 4 weapon/body_gear/ward_gear bases (`an`, `giap`, `phi_kiem`, `thuan`).
- **Stand-ins:** verified all 18 living cast members in `thien_bao.cast.json` and `thien_bao.5.cast.json`. Only `quan_tay_ngoc` (`moc 44, thuy 34`) and `quan_tay_lan` (`moc 42, thuy 30`) had stand-ins (`hoang_moc`); neither has Metal and both are hired Khê Thanh brook-washers excluded from the canon (`thien_bao.md` §2, §6). `brook-wash-breath` (`moc, thuy`, Yellow main, `tap_dich`) follows the stand-in priority order and fits both roots. `depth_gap.py` reports `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`.
- **Linters & static checks after fixes:** `lint_techniques.py` (4 techniques, 0 findings; `23.7/24`, `15.9/16`, `23.4/24`, `8.0/8`), `lint_arts.py` (8 arts, 0 findings), `lint_items.py` (6 items, 0 findings), GDScript `EffectCompiler` static vocabulary/filter/action check (0 errors).

---

## 4. Holder table after fixes (`sect_fight.py thien_bao --seeds 5`, gap 0 and `--gap 1`)

**Zero `REFUSED`, zero `NEVER_FIRED`, zero `NEVER_RAN` across both gap 0 and `--gap 1`.**

| Holder (realm) | Gap 0 (5 seeds) | `--gap 1` (5 seeds) | Effects: with / without (runs) | Notes / Probes |
|---|---|---|---|---|
| `phan_vat_hoa` (NA) | 13.6 s, 5/5, 100 % | 16.4 s, 0/5, 0 % | `Bought Fate` gap 0: 13.6/13.6 s (4), gap 1: **16.4/16.0 s** (5); `Sold` gap 0: 13.6/13.7 s (10), gap 1: **16.4/15.6 s (5)**; `Grown, Not Made` gap 0: 13.6/13.6 s (5), gap 1: 16.4/16.4 s (10; yields to `pawn-the-pearl` when removed); `Going Once, Going Twice` gap 0: 13.6/13.6 s (22), gap 1: 16.4/16.4 s (16) | Deadlock nuke probe: 3/3 wins, `Grown, Not Made` saves cleanly (`cracked=1`); Soul probe: `pearl_ward` saves while `sward > 0` (`cracked=0`); sturdy+crit probe (10 seeds): `keep` 20, `fate` (2nd flip) 10. |
| `khang_thien_chuy` (KĐ) | 13.0 s, 5/5, 100 % | 14.4 s, 0/5, 0 % | `Fights With What He Made` gap 0: 13.0/13.0 s (107 block runs), gap 1: 14.4/14.4 s (123 block runs) | Real-kit probe (+`flying-sword-strike` for `whetstone-pass`, 10 seeds): **gap 0: 10.00 s with vs 13.01 s without** (58 sword strike runs); gap 1: 47 sword runs, 10/10 `pawn-pearl-save` runs. |
| `tien_ngu_phan` (TC) | 16.0 s, 5/5, 88 % | 8.0 s, 0/5, 0 % | n/a | All 5 arts fire at gap 0 and gap 1; 0 leakage from `hammer-price` or `third-price`. |
| `ho_tam_ky`, `thuong_toi_kim` (TC) | 12.4 s, 5/5, 77 % | 8.0 s, 0/5, 0 % | n/a | All 6 arts fire at gap 0 and gap 1. |
| `phong_tu_gia` (TC) | 20.0 s, 5/5, 88 % | 8.0 s, 0/5, 0 % | n/a | All 4 arts fire at gap 0 and gap 1. |
| `an_toan_chau`, `vien_hong_kim` (TC) | 31.1–31.7 s, 5/5, 86 % | 8.0 s, 0/5, 0 % | n/a | `assay-the-ore` and `crucible-guard` fire at both. |
| `nguy_minh_giam`, `ta_thuc_bao` (LK) | 14.4 s, 5/5, 53 % | 8.0 s, 0/5, 0 % | n/a | All 5 arts (`nine-temper` + `appraisers-eye`) fire at both. |
| `quan_tay_ngoc`, `quan_tay_lan` (LK) | 46.2 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | n/a | `brook-rinse` fires 8.2/fight at gap 0, 1.0/fight at gap 1. |

---

## 5. Open items (carried to serial step / Stage 7)

- `export_named.py` skips `kind: treasure` (`tb-land-riches-seal`, `tb-grown-red-pearl`), same carry-over as other sects with treasures.
- `artifact_attack_pct` (2 open modifier lines in `depth_gap.py`: `tb-red-gold-furnace-sword` and `tb-xich-kim-furnace` 2-piece set): item-level read by `CombatPower.artifact_numbers`, set-level and `fight.py` recognition open.
- Out-of-fight halves: `Grown, Not Made` unstealable/unsellable rule; `Going Once, Going Twice` spirit-stone exemption and Effects rule 11 `refusals = 1` cap.
- `phan_vat_hoa` has 18 ties (> 16 cap, trimmed at Stage 7 export).

CHECKPOINT DONE
