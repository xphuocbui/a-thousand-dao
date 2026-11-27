# Stage 6 checkpoint review: Lê Hoa Am (`le_hoa`)

Unanchored audit of `design/stage6-staging/le_hoa/` against `design/world/depth/sects/le_hoa.*` (`md`, `techniques.json`, `items.json`, `cast.json`, `5.cast.json`), `design/techniques/catalogue-ice.json`, `design/arts/family-ice.json`, `design/items/catalogue-ice.json`, `assets/data/combat_engine.json`, `assets/data/combat_effects.json`, Stage 6 rules (`_brief-record.md`, `_brief-review.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `FIGHT-INPUT.md`), and both combat engines (`tools/design/combat_sim/{engine,fight,sect_fight}.py` and `src/gameplay/combat/fight/{effect_compiler,effect_runner,fighter_profile_loader,defence_path,fight}.gd`).

## Ranked findings (1 MUST-FIX applied, 1 SHOULD applied, 1 NIT noted)

| # | Severity | File | Record / ID | What was wrong | Fix applied |
|---|---|---|---|---|---|
| 1 | **MUST-FIX** | [part-sect-le_hoa.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/le_hoa/arts/part-sect-le_hoa.json) | `one-branch-of-pear` (`empower[0].pay[0]`) | `pay` wrote `{"mod": {"pen": 120, "art_id": "one-branch-of-pear"}}`. Both `engine.py:1845` and `effect_runner.gd:396` only copy `("dtype", "element", "tags", "kind")` into `temp_mods` filters and drop `"art_id"`. With `"for"` omitted (`until = t + 1`), `pen: 120` compiled with an empty `{}` filter and applied to any other hit (basic attack, trigger, or another art) firing in the same millisecond `t`. | Replaced `"art_id": "one-branch-of-pear"` with `"tags": ["pierce"], "kind": "art"`, which both engines preserve in `temp_mods`, excluding `basic`/`trigger`/`companion` hits and uniquely matching `one-branch-of-pear` across `le_hoa` and `winter-toll-canon`. |
| 2 | **SHOULD** | [part-sect-le_hoa.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/le_hoa/arts/part-sect-le_hoa.json) | `lay-the-seal` (`lay-seal-hold`, `lay-seal-sit`) | `lay-seal-hold` (`on: "art_fired"`) unconditionally ran `{"counter": {"id": "seal_hold", "set": 7}}` alongside `timer`. On `thai_le_tuyet` with `Until It Stops Wanting` (`seal_hold +1` per `winter-toll-canon` art), re-casting `lay-the-seal` when `seal_hold` had been extended (e.g. `10` at `t = 13.33 s` in `--gap 1` seed 1) overwrote `seal_hold` downward to `7`, erasing accumulated bell extensions. | Split `lay-seal-delay` (`timer {side: "foe", which: "next", by: 1.0}`, always fires on `art_fired`) from `lay-seal-hold` (`if: own.counter.seal_hold < 7 -> set 7`), and updated `lay-seal-sit` (`if: sit_door >= 1, seal_hold < 10 -> set 10`) so re-casting guarantees at least 6 pulses (9 pulses while sitting) without shortening a longer extended hold. |
| 3 | **NIT** | [le_hoa.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/le_hoa.cast.json) | `manh_tinh_chi` (`ties.note`, `tree.intent`) | `spatial_words_check.py --sect le_hoa` emits two `soft` commentary matches (`beside`, `behind it`) in `manh_tinh_chi`'s narrative/intent fields; 0 non-soft spatial hits anywhere in `le_hoa`. | Left untouched (narrative text only, no fight rule impact). |

---

## Checked & verified

### 1. GDScript compilation parity & uniqueness
- **Uniqueness:** `set(le_hoa.effects) & set(assets/data/combat_effects.json)` = `set()`, and 0 ID or Effect name collisions against committed `design/` files or any other staged `design/stage6-staging/*` directory.
- **Standalone Effect & Art compilation parity (`effect_compiler.gd`, `fighter_profile_loader.gd`, `engine.validate`):**
  - Every Effect in [le_hoa.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/le_hoa/effects/le_hoa.effects.json) passes `engine.validate()` standalone and declares in its own `"counters"` every counter it reads or writes (`Toll of the Frozen Bolt`: `bell_toll`; `Until It Stops Wanting`: `seal_hold` with `decay_per_pulse: 1`, `vigil_toll` with `each_for: 10`; `None Shall Pass`: `gate_blocks`, `gate_pass`; `missing_counters=set()`).
  - Every art in [part-sect-le_hoa.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/le_hoa/arts/part-sect-le_hoa.json) declares its own counters (`bar-the-gate`: `gate_raised`, `gate_guard`; `eighth-month-snow`: `petal_field`; `lay-the-seal`: `seal_hold`, `seal_count`, `sit_door`; `sit-against-the-door`: `sit_door`).
  - Stance safety: `bar-the-gate`, `eighth-month-snow`, and `sit-against-the-door` use `decay_per_pulse: 1` self-counters (`set: 5` -> 4 pulses; `set: 7` -> 6 pulses) so none overwrites `winter-toll-canon`'s `deep-winter` state.
  - Zero `always` records carry a record-level `filter` (all scopes sit inside `mod`), zero multi-`mod` records lack `"stack": true`, and `None Shall Pass` arms on `"blocked"` and spends on `"crit"` (`tags: ["sword"]`), avoiding any same-hit arm-and-spend bug.

### 2. Specific focus checks (`Until It Stops Wanting`, `Toll of the Frozen Bolt`, `None Shall Pass`)
- **`Until It Stops Wanting` (`lh-pear-blossom-vigil` 3pc):**
  - At `--gap 0` (`thai_le_tuyet`, 5 seeds): purely defensive (`seal_hold +1` + `vigil_toll` `dampen_taken 5.26` per `winter-toll-canon` cast while sealed). Against a same-realm typical foe that dies in `14.091 s` with `368.7` vs `372.7` damage dealt (`92.78 %` vs `92.70 %` HP, both rounding to `14.1 s 93 %`), the fight ends too quickly for damage reduction to change kill time.
  - At `--gap 1` (`nguyen_anh` typical foe): genuinely shifts survival by **+9.0 s** over 20 seeds (`33.0 s` vs `24.0 s`, `377` runs; `+8.17 s` over 5 seeds: `33.712 s` vs `25.540 s`), proving the uncapped `each_for: 10` scaling works as written.
- **`Toll of the Frozen Bolt` (`lh-bolt-ice-bell`):**
  - At `--gap 1` (`thai_le_tuyet`, 20 seeds): extends survival by **+1.7 s** (`33.0 s` vs `31.3 s`, `491` runs; `+2.04 s` over 5 seeds: `33.712 s` vs `31.668 s`, reducing foe dealt from `5377.5` to `5287.4`).
  - At `--gap 0` (5 seeds): `14.091 s` vs `13.940 s` (`65` runs; `seed=3` `14.091 s` vs `13.334 s` from `stop_clock 0.5 s` shifting foe timer/damage cadence).
- **`None Shall Pass` (`lh-the-gate` 3pc):**
  - At `--gap 0` (`manh_tinh_chi`, 5 seeds): speeds win by **−3.0 s** (`12.3 s` vs `15.3 s`, `97 %` HP, `80` runs).
  - At `--gap 1` (20 seeds): both run `12.7 s` (`280` runs; `15028.6` vs `15253.4` foe HP left in seed 1) because the offensive sure-crit/pierce proc (`225` extra damage in seed 1) does not delay death against a one-realm-up `nguyen_anh` foe.
- **7th-slot probe (`manh_tinh_chi` with `bar-the-gate` replacing `black-ice-glaze`, 5 seeds, `--gap 0`):** `17.2 s`, `5/5`, `94 %` HP, `bar-the-gate` fires `4.4`/fight, `None Shall Pass` `111` runs; coexists cleanly with `deep-winter-form` (`3.4`) and `eighth-month-snow` (`2.4`).

### 3. Techniques, items, sets, and stand-ins
- **Techniques (`catalogue-sect-le_hoa.json`):** `gate-sword-primer` (`7.9 W of 8`), `pear-blossom-snow-sword` (`15.5 W of 16`), `sealed-cold-sutra` (`22.3 W of 24`). All bonuses/passives are new and tier-sized; unlock layers match `le_hoa.cast.json` and `le_hoa.5.cast.json` holders.
- **Items & sets (`catalogue-sect-le_hoa.json`, `sets-le_hoa.json`):** All 24 depth modifier lines preserved verbatim (`24/24 runs`), `sources: ["npc"]`, `unique: true`, `rarity: 5` on grade-4 treasure `lh-bolt-ice-bell`, R6 `exception` on the 4 weapon/ward/armour items, and `lh-pear-blossom-vigil` properly references `ice-moonrime-sword` (`catalogue-ice.json`).
- **Stand-ins & root fit:** `stand_ins: 0`, `cross_owner: 0`. All 9 living `ngoai_mon` members hold `gate-sword-primer` (Metal, matching their `kim` 30–62 roots, including `diep_quang_nhi`'s `kim 40 / hoa 34 / quang 22` per `le_hoa.md` §6), and all 9 living `noi_mon`+ members hold `winter-toll-canon` (matching their `bang` 26–76 roots).

---

## Pending word decisions

None (`0` pending words; no `pending.json` in `design/stage6-staging/le_hoa/`).

---

## Linters & Holder table after final fixes

### Linters & structural checks (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\le_hoa`)
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/le_hoa/techniques/catalogue-sect-le_hoa.json`: `checked 3 techniques, 0 findings`
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/le_hoa/arts/part-sect-le_hoa.json`: `checked 5 arts in 1 files, 0 findings`
- `python -I tools/design/items/lint_items.py design/stage6-staging/le_hoa/items/catalogue-sect-le_hoa.json`: `checked 5 items, 22 bases, 9 common arts, 0 findings` (`unique 5 of 5`)
- `python -I tools/design/world/depth_check.py --quiet`: `findings: none`
- `python -I tools/design/world/depth_gap.py --sect le_hoa`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 24/24 runs`
- `python -I tools/design/combat_sim/sect_fight.py le_hoa --seeds 5` & `--gap 1` (20 seeds): **0 REFUSED**, **0 NEVER_FIRED**, **0 NEVER_RAN**

### Holder table (`sect_fight.py le_hoa`, post-fix: `--gap 0` 5 seeds / `--gap 1` 20 seeds)

| Holder | Realm | `gap 0` (`mean_s`, wins, HP) | `gap 1` (`mean_s`, wins, HP) | Arts & Effects (`with` vs `without`, `runs`) |
|---|---|---|---|---|
| `thai_le_tuyet` | Kết Đan 2 | `14.1 s`, `5/5`, `93 %` | `33.0 s`, `0/20`, `0 %` | `lay-the-seal` `3.0`/`5.8`, `sit-against-the-door` `2.0`/`3.5`. **Toll of the Frozen Bolt**: `14.1 s 93%` vs `13.9 s 93%` (`65` runs) / `33.0 s` vs `31.3 s` (`491` runs). **Until It Stops Wanting**: `14.1 s 93%` vs `14.1 s 93%` (`45` runs) / `33.0 s` vs `24.0 s` (`377` runs). |
| `manh_tinh_chi` | Kết Đan 0 | `12.3 s`, `5/5`, `97 %` | `12.7 s`, `0/20`, `0 %` | `eighth-month-snow` `1.2`/`1.1`, `one-branch-of-pear` `3.2`/`2.0` (`bar-the-gate` in 7th slot verified via probe). **None Shall Pass**: `12.3 s 97%` vs `15.3 s 97%` (`80` runs) / `12.7 s` vs `12.7 s` (`280` runs). |
| `ung_le_am` | Trúc Cơ 1 | `14.6 s`, `5/5`, `85 %` | `8.8 s`, `0/20`, `0 %` | `eighth-month-snow` `2.0`/`1.0`, `one-branch-of-pear` `3.4`/`1.9` |
| `ton_han_y` | Trúc Cơ 2 | `14.3 s`, `5/5`, `85 %` | `8.8 s`, `0/20`, `0 %` | `eighth-month-snow` `1.8`/`1.0`, `one-branch-of-pear` `3.2`/`1.9` |
| `huong_thiet_lan`, `dinh_ngan_cau` | Trúc Cơ 0 | `48.4 s`, `0/5`, `0 %` | `8.5 s`, `0/20`, `0 %` | `bar-the-gate` `11.0`/`1.4` |
| `tieu_ngoc_hoe`, `banh_tieu_thien`, `diep_quang_nhi`, `doan_han_bich`, `tieu_ngoc_khe`, `khuong_thach_luu`, `khau_ngan_linh` | Luyện Khí | `41.6 s`, `0/5`, `0 %` | `8.1 s`, `0/20`, `0 %` | `bar-the-gate` `9.4`/`1.4` |
| `uc_han_chan`, `gian_to_y`, `thuong_suong_mi`, `chu_tuyet_thanh`, `mac_lien_suong` | Trúc Cơ / Luyện Khí | — | — | `winter-toll-canon` only (no staged `le_hoa` art or named item; excluded from `sect_fight` authored-holder filter) |

CHECKPOINT DONE
