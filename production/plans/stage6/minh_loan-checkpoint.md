# Minh Loan Các (`minh_loan`): Stage 6 checkpoint review (2026-11-27, headless, decisions auto-accepted)

## What this review read
This review audited the staged files, depth source text, rulings, both combat engines, and `sect_fight.py` runs unanchored against `minh_loan-review.md`:
- **All staged files** in `design/stage6-staging/minh_loan/`: `techniques/catalogue-sect-minh_loan.json` (4 techniques), `arts/part-sect-minh_loan.json` (7 active arts), `effects/minh_loan.effects.json` (3 Effects), `items/catalogue-sect-minh_loan.json` (6 signature items), and `items/sets-minh_loan.json` (2 sets). No `pending.json` (`0` pending words).
- **Depth source of truth:** `design/world/depth/sects/minh_loan.techniques.json`, `minh_loan.items.json`, `minh_loan.md`, `minh_loan.cast.json` (11 living, 2 dead), and `minh_loan.5.cast.json` (7 living).
- **Rules & engine:** `production/plans/stage6/_brief-review.md`, `_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `FIGHT-INPUT.md`, `assets/data/combat_engine.json`, `assets/data/combat_effects.json`, `tools/design/combat_sim/engine.py`, `fight.py`, `sect_fight.py`, `tools/design/items/export_named.py`, `src/gameplay/cultivation/cong_phap.gd`, `src/gameplay/combat/fight/effect_compiler.gd`, `effect_runner.gd`, `fighter_profile_loader.gd`, `fight.gd`, `defence_path.gd`, and `combat_service.gd`.
- **Verification runs (post-edit):** `lint_techniques.py`, `lint_arts.py`, `lint_items.py`, `depth_check.py`, `depth_gap.py --sect minh_loan`, `sect_fight.py minh_loan --seeds 5 --gap 0` and `--gap 1`, plus uniqueness, standalone Effect counter/compilation, and edge-branch probes (`was_evaded`, long-CD `bell < 2` expiry, `tag.foreseen` when enabled in `REQUEST_TAGS`).

## Findings, most severe first

| # | File | Record | What was wrong | Fix applied | Rank |
|---|---|---|---|---|---|
| 1 | `design/stage6-staging/minh_loan/techniques/catalogue-sect-minh_loan.json` & depth cast | `clay-mould-primer`, `hanging-bells-array` | Cast root check against `CongPhap.usable()` (`src/gameplay/cultivation/cong_phap.gd:42`, which requires every element in `names`): `clay-mould-primer` (`names: ["tho", "kim"]`) has `2/6` living holders lacking one element (`so_thanh_dac` `kim, moc` lacks `tho`; `dau_tieu_hoa` `hoa, tho` lacks `kim`, while `minh_loan.md` §5 writes "Earth or Metal" and §6 notes `dau_tieu_hoa` as an exception), and `hanging-bells-array` (`names: ["kim", "tho"]`) has `1/5` living holder lacking `tho` (`ong_hai_linh`, root `kim, thuy`). `lint_techniques.py` also requires both `kim` and `tho` in `hanging-bells-array` because it carries `hang-the-bells` (`metal`) and `alarm-line` (`earth`). | **Not applied** (consistent with `b01` checkpoints: authored lineage `names` are not silently altered in review). Logged as an open item for Stage 7/9 (`CongPhap` any-of rule or lineage/cast ruling). | SHOULD |
| 2 | `design/world/depth/sects/minh_loan.techniques.json` | `hang-the-bells` (`concept`) | Typo `"Sains four Bell charges"` instead of `"Gains four Bell charges"`. | Fixed `"Sains"` -> `"Gains"` in `design/world/depth/sects/minh_loan.techniques.json:52`. | NIT |

### Checked and verified
- **GDScript standalone compilation parity (`minh_loan.effects.json`):**
  - `Rings as It Moves` reads/writes `luan_bell_cd` and declares `"counters": [{"id": "luan_bell_cd", "cap": 1, "each_for": 1}]`.
  - `Struck, She Rings` reads/writes no counters.
  - `Forty Answer` reads `own.counter.bell` and declares `"counters": [{"id": "bell", "each_for": 10}]`.
  - All 3 Effects validate cleanly through `engine.validate()` with every counter declared locally, matching `EffectCompiler` (`test_every_library_effect_compiles()`).
- **`tag.foreseen >= 1` GDScript compilation parity (`hang-the-bells`):**
  - Verified directly in `src/gameplay/combat/fight/effect_compiler.gd:206-210`: `_read()` accepts any `tag.<param>` (`r.side = 2; r.key = "tag"; r.param = key.substr(4)`) without checking `REQUEST_TAGS` (`_k.request_tags`), and `EffectRunner.read()` (`effect_runner.gd:23-24`) returns `1.0 if f.tags.has(r.param) else 0.0` (matching `engine.py:417-418`). So `hang-bells-foreseen` compiles cleanly in GDScript even before `"foreseen"` is added to `assets/data/combat_engine.json` `REQUEST_TAGS`; it simply evaluates to `0.0` until `REQUEST_TAGS` and `FightRequest` situation-to-tag wiring are added.
- **Effect & record name uniqueness:**
  - Confirmed `0` collisions for `Rings as It Moves`, `Struck, She Rings`, and `Forty Answer` against `assets/data/combat_effects.json` and all other staged `design/stage6-staging/*/effects/*.effects.json` files (`bach_vu`, `muc_van`, `nam_pho`, `nhan_van`, `phan_vu`, `truc_thuc`, `xuyen_lam`).
  - Confirmed `0` ID collisions across all 4 techniques, 7 arts, 6 items, and 2 sets against committed `design/` and all staged files.
- **`fired-mould` vs `mountain-stance` coexistence:**
  - `fired-mould` raises the stance ward via `ward_grow` (`0.08` HP) + timed `block` (`+20` for 3 s) + `mould_ward = 1` without touching `s.state`, while `mountain-stance` (`family-earth.json`) toggles `state: "mountain"` without touching the stance ward. Both coexist cleanly on L2–L3 outer-gate holders (`bien_tieu_linh`, `mao_tieu_huong`, `so_thanh_dac`, `tri_vien_lac`), with `fired-mould-set` (`260`), `fired-mould-break` (`208`), `mountain-toggle` (`194`), `mountain-take` (`640`), and `mountain-answer` (`201`) all firing in `sect_fight` probes.
- **Pulse toll & trigger budget behavior (`carriage-bell`, `the-bell-that-rings-itself`, `Forty Answer`, `Rings as It Moves`, `Struck, She Rings`):**
  - Verified `summon {c, dtype: "phys", cd: 0.5, for: 0.6}` on `pulse` tolls (`carriage-bell-press`, `self-ring-toll`, `eff:Forty Answer`) avoids `pulse` `trig_budget` starvation (`A.clipped: {}`) across both `engine.py` and `effect_runner.gd`, and `scale: own.counter.bell` scales `summon.c` linearly (`0.25 * n`) in both engines.
  - Note: in `engine.py`, `s.summons` does not add to `cands`, so a `0.5 s` summon fires at the next `act()` (`<= 1.0 s` after the pulse), and `carriage-bell-dodge` (`was_evaded`) also uses `summon`. Both `carriage-bell-dodge` (`57` runs) and `eff:Rings as It Moves dodge` (`12` runs) were verified against a `40` evade foe; `hang-bells-quiet` (`1` run) was verified with a long `hang-the-bells` cooldown; `hang-bells-foreseen` (`1` run) was verified with `foreseen` enabled in `REQUEST_TAGS`.
- **Items, Sets & `ml-luan-bell`:**
  - Verified all 6 items and 2 sets match `minh_loan.items.json` verbatim on modifiers, lore, build_use, holder, made_by, made_year, set, pieces, and bonus rules.
  - `ml-luan-bell` carries `kind: "treasure"`, `grade: 4`, `rarity: 5`, `unique: true`, `sources: ["npc"]`, `effects: ["Rings as It Moves"]`, `arts: []`, and R6 `exception`. (`export_named.py:42` currently skips `kind != "artifact"`, logged in Open items.)
- **Techniques & Stand-ins:**
  - All 4 techniques' bonuses and passives fit tier budgets (`7.8/8`, `15.1/16`, `15.4/16`, `24.0/24`), keep depth passive `b3` on `singing-luan-bell-canon`, and unlock all suite arts by layer 4 (`<= 6`). `0` stand-ins, `0` beasts, `0` cross-owner refs.
- **Design rules:** No environment conditions, no spatial fight rules, no caps (`bell`, `ward-peal`, `Forty Answer` scale uncapped), Effects unpriced.

## Decisions on the pending words

None (`0` pending words; no `pending.json`).

## Holder table after the fixes

Same realm, typical foe, 5 seeds (`python -I tools/design/combat_sim/sect_fight.py minh_loan --seeds 5 --gap 0` and `--gap 1`, `0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN`).

| Holder(s) (realm) | Result (same realm, 5 seeds) | `--gap 1` (5 seeds) | Effects: with / without (runs) | Note |
|---|---|---|---|---|
| `yen_boi_ngoc` (`ket_dan`) | `19.8 s, 5/5, 100%` | `13.1 s, 0/5, 0%` | `Rings as It Moves` `19.8 s 100% / 20.6 s 100%` (`33` gap 0, `26` gap 1); `Struck, She Rings` `19.8 s 100% / 22.7 s 95%` (`83` gap 0, `62` gap 1) | 6 arts fire `2.0–3.0/fight` (`1.0` at `--gap 1`). |
| `nguy_tram_am` (`ket_dan`) | `29.6 s, 5/5, 92%` | `11.2 s, 0/5, 0%` | — | 4 arts fire `3.0–4.6/fight` (`0.4–1.0` at `--gap 1`). |
| `tham_huong_nhi` (`truc_co`) | `34.0 s, 5/5, 85%` | `9.3 s, 0/5, 0%` | `Forty Answer` `34.0 s 85% / 37.4 s 85%` (`48` gap 0, `3` gap 1) | 4 arts fire `4.0–5.2/fight` (`1.0` at `--gap 1`). |
| `chiem_thinh_ba`, `ong_hai_linh` (`truc_co`) | `40.8 s, 5/5, 83%` | `9.1 s, 0/5, 0%` | — | 4 arts fire `4.8–6.4/fight` (`1.0` at `--gap 1`). |
| `ve_soc_linh` (`luyen_khi`) | `42.8 s, 5/5, 82%` | `8.6 s, 0/5, 0%` | — | 3 arts fire `4.8–6.8/fight` (`0.4–1.0` at `--gap 1`). |
| `lo_hong_pham`, `khang_vien_dac`, `uy_chu_dong` (`truc_co`) | `63.0 s, 1/5, 0%` | `9.2 s, 0/5, 0%` | — | 2-art defensive core (`carriage-bell 9.2`, `ward-peal 7.4`; `1.0` at `--gap 1`). |
| `uong_lac_chuy`, `phi_ngoc_thanh`, `than_lac_am` (`luyen_khi`) | `52.0 s, 0/5, 0%` | `8.2 s, 0/5, 0%` | — | 2-art defensive core (`carriage-bell 7.4`, `ward-peal 5.8`; `1.0` at `--gap 1`). |
| `bien_tieu_linh`, `mao_tieu_huong`, `so_thanh_dac`, `tri_vien_lac` (`luyen_khi`) | `49.2–49.8 s, 0/5, 0%` | `9.8 s, 0/5, 0%` | — | Outer-gate L2–L3 primer (`fired-mould 8.2`, `mountain-stance 9.6–10.0`; `1.2–1.8` at `--gap 1`). |
| `dau_tieu_hoa`, `do_ne_huong` (`luyen_khi`) | `51.6 s, 0/5, 0%` | `8.6 s, 0/5, 0%` | — | Outer-gate L1 single ward (`fired-mould 9.6`; `1.2` at `--gap 1`). |

- **Linters & depth checks after final edit:**
  - `lint_techniques.py`: `checked 4 techniques, 0 findings`.
  - `lint_arts.py`: `checked 7 arts in 1 files, 0 findings`.
  - `lint_items.py`: `checked 6 items, 22 bases, 9 common arts, 0 findings`.
  - `depth_check.py`: `findings: none`.
  - `depth_gap.py --sect minh_loan`: `unknown_ids: 0`, `cross_owner: 0`, `stand_ins: 0`, `engine_words: 0`, `wishes_open: 0`.

## Open items (for the user, Stage 7/9, or serial step)
1. **Cross-root lineage `names` vs `CongPhap.usable()` (finding #1):** `clay-mould-primer` (`["tho", "kim"]`) has `2/6` living holders lacking one element (`so_thanh_dac` lacks `tho`, `dau_tieu_hoa` lacks `kim`), and `hanging-bells-array` (`["kim", "tho"]`) has `1/5` living holder lacking `tho` (`ong_hai_linh`). Needs a Stage 7/9 ruling (`CongPhap` any-of rule or lineage/cast ruling).
2. **`export_named.py` `kind == "treasure"`:** `ml-luan-bell` (`kind: "treasure"`, `grade: 4`, `rarity: 5`) requires `export_named.py` to include `treasure` items at export (same as `ct-star-lake-mirror` et al.).
3. **`REQUEST_TAGS` `"foreseen"`:** `hang-bells-foreseen` (`tag.foreseen >= 1`) compiles cleanly in both engines today; adding `"foreseen"` to `assets/data/combat_engine.json` `REQUEST_TAGS` and wiring `FightRequest.Situation.FORESEEN` will activate it automatically.

CHECKPOINT DONE