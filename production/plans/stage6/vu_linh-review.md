# Stage 6 Record Pass Review — `vu_linh` (Vũ Linh Đường)

## Summary

- **What was built (`design/stage6-staging/vu_linh/`)**:
  - **Techniques (4)** in [catalogue-sect-vu_linh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_linh/techniques/catalogue-sect-vu_linh.json): `charcoal-burners-primer` (Tier 0 `main`), `canopy-bell-canon` (Tier 1 `main`), `molten-bronze-litany` (Tier 1 `secret`), and `listening-bell-seal` (Tier 2 `secret`), each with `[NEW]` tier-sized unpriced `bonuses` and `passives`.
  - **Active Arts (6)** in [part-sect-vu_linh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_linh/arts/part-sect-vu_linh.json): `bank-the-kiln-stance`, `hang-a-bell`, `the-line-rings`, `pour-molten-bronze`, `hard-as-a-bell`, and `it-rings-for-you`. The two passive arts (`Heard Through the Roots`, `Tuned Bronze`) are wired via `technique-effects` (`b01`) on `canopy-bell-canon` (L4) and `listening-bell-seal` (L4).
  - **Effects (5)** in [vu_linh.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_linh/effects/vu_linh.effects.json): 2 passive-art technique Effects (`Heard Through the Roots`, `Tuned Bronze`), 2 item Effects (`Clear Note`, `The Forest Hears`), and 1 full-set Effect (`The Line Is Tuned`). Every Effect declares all counters it reads or writes in its own `"counters"` array and passes `engine.validate`.
  - **Items (4) & Sets (1)** in [catalogue-sect-vu_linh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_linh/items/catalogue-sect-vu_linh.json) and [sets-vu_linh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_linh/items/sets-vu_linh.json): `vl-clear-bell` (`treasure`, `rarity: 5`), `vl-root-line-banner`, `vl-last-blue-lamp`, `vl-casters-apron`, and 3-piece set `vl-bell-lines`.
  - **Depth edits**: added `"id"` fields before `"new"` for the 6 active arts in [vu_linh.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/vu_linh.techniques.json).
  - **Stand-ins & Beasts**: `0` stand-ins (all 18 living members already use `vu_linh` lineage techniques), `0` beasts, `0` cross-owner references, `0` early promotions.
- **Deviations**: 9 documented engine/collision adaptations (listed below).
- **Decisions taken for the user (auto-accepted)**: 8 decisions with reasons below.
- **Pending words**: None (`pending.json` not needed; all records use existing engine words and `b01` `technique-effects`).
- **Never ran in `sect_fight.py`**: `Tuned Bronze` (`listening-bell-seal` L4 passive) reported `runs 0` against `typical` because `typical` casts no soul or `charmed` arts; its always-on `soul_res 15` and `status_resist 20 [charmed]` are active and its ring/slow triggers (`soul_ring` 106, `charm_stop_ward` 56, `charm_stop_evade` 29) were verified in a 10-seed soul+charm probe.
- **Open items**:
  1. `cast_ward_duration_pct` (`+15` on `vl-clear-bell`): valid in `lint_items.py` / `modifiers.md`, currently has no `CHARACTER_MODS` / `cast_wards` reader in `combat_engine.json` (`depth_gap.py` `lines` 1 open).
  2. Depth `arts_new` rows for passive arts `Heard Through the Roots` and `Tuned Bronze` remain without active art ids in `vu_linh.techniques.json` because they are promoted as `technique.effects` (`thinh_vu` precedent).
  3. R6 `exception` kept on `vl-clear-bell` (`chuong`) and `vl-casters-apron` (`dao_bao`) until authored signature item arts/wards are ruled.
  4. 3 structured events (`N-vu_linh-01..03`) close at Stage 8 export.

---

## Auto-Accepted Decisions (with Reasons)

1. **Rename `bank-the-kiln` -> `bank-the-kiln-stance`**: `phan_vu` already holds art id `bank-the-kiln` (`part-sect-phan_vu.json`). Naming Vũ Linh Đường's stance art `bank-the-kiln-stance` prevents a `DUPLICATE` art-id collision while keeping the depth name `Bank the Kiln (Ủ Lò)`.
2. **Use counter `canopy_bell` instead of `bell`**: `minh_loan` uses `bell` (`each_for: 10`). Using fight-long `canopy_bell` prevents counter-definition collisions if a build mixes methods from both sects.
3. **Model `Hang a Bell`'s escalating reservation via `upkeep` (`0.003` qi/s per stack)**: The engine has no runtime action to modify static `b.reserved`. Counter `upkeep` (`{"pool": "qi", "per_stack": 0.003}`) naturally scales linh lực drain with bell count and drops excess bells if linh lực runs dry, honoring *scale without caps*.
4. **Stage `Heard Through the Roots` & `Tuned Bronze` as `technique-effects` (unlock layer 4)**: Matches `thinh_vu` and `b01` `technique-effects`. Unlock layer 4 lets every inner-gate `truc_co` disciple (`dang_quai_linh` L4, `thieu_van_linh` L4, `chung_hong_lo` L5, `trinh_thu_linh` L6) and elder (`chung_tan_huong` L8, `an_thanh_linh` L9) unlock `Heard Through the Roots`, while `an_thanh_linh` (L10) unlocks `Tuned Bronze`.
5. **Toggle `bank-the-kiln-stance` cleanly with `kiln_ember` + `state {toggle: true}`**: Ordered `kiln-leave-ember` (gated on `own.state.kiln-banked >= 1`) before `kiln-toggle` so leaving the stance arms `+30 %` Fire art damage (`kiln_ember`) without immediately re-entering the stance in the same `art_fired` pass, and ensures Luyện Khí outer disciples with only one art keep firing it regularly.
6. **Direct `dmg_more` on `the-line-rings` (`1.0 c`, `+35 %` per bell) & `2.5 s` cooldown on `it-rings-for-you`**: Originally `the-line-rings` used `free_hit` (`0.35 c/bell`) and `it-rings-for-you` used `per_pulse: 1`, which caused `an_thanh_linh` to burn dry of linh lực at `28.08 s` and clip `trig_budget` 17 times. Using direct `dmg_more` on `the-line-rings` and `cooldown: 2.5` on `it-rings-for-you` keeps `an_thanh_linh` at `92 %` HP and `20/20` wins at `--gap 0` while still losing at `--gap 1`.
7. **Size `[NEW]` tier-0/1/2 bonuses and passives to catalogue budgets**: `vu_linh.techniques.json` specifies no bonuses or passives; sized unpriced bonuses (`0 / 1 / 2`) and passives (`8.0 / 15.0 / 15.8 / 23.8 W`) to Wood/Fire defence, evasion, curse duration, and casting speed, marked `[NEW]` below.
8. **Use `rarity: 5` on treasure `vl-clear-bell` and `unique: true` on all 4 items**: Depth specifies `kind: "treasure", grade: 4` on `vl-clear-bell`; `lint_items.py` requires `rarity: 5` (without `grade`) for grade-4 treasures, and `bang_tam` R6/20f marks all signature items unique (`sources: ["npc"]`).

---

## Băng Tâm Pilot Checklist

- [x] Every Effect changes the fight with and without it on its holders (`Heard Through the Roots`, `Clear Note`, `The Forest Hears`, `The Line Is Tuned` in `sect_fight.py`, and `Tuned Bronze` in the 10-seed soul+charm probe); every active art fires across all 18 living holders at `--gap 0`.
- [x] No holder slots two stances without a combined stance (`bank-the-kiln-stance` is the only stance in `vu_linh` and shares no holder with another stance).
- [x] Each `"your X"` Effect works for holders who may lack X (`Clear Note` and `The Line Is Tuned` work even with 0 `canopy_bell` stacks; `The Line Is Tuned` scales up as bells are hung).
- [x] Vague depth phrases (`"a little"`, `"for a few seconds"`, `"warmth"`, `"partly evaded"`, `"worth your apron's attack"`) are resolved to concrete numbers in every `rule`.
- [x] `[NEW]` technique bonuses and passives are sized against the same tier (`0` / `1` / `2`) and explicitly flagged below.

---

## Mechanic Table & Depth-vs-Engine Mapping

### Techniques ([catalogue-sect-vu_linh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_linh/techniques/catalogue-sect-vu_linh.json))

| ID | Name | Tier / Kind | Depth Lines | Staged Engine Form | Deviations / `[NEW]` |
|---|---|---|---|---|---|
| `charcoal-burners-primer` | Charcoal-Burner's Primer (Thiêu Thán Quyết) | 0 / `main` | `names: ["hoa", "moc"]`, `layers: 6`, no bonuses/passives | `bonuses: []`; **[NEW]** `passives`: `linh_luc_regen_inc_pct 5 []`, `attack_pct 3 ["fire"]`, `resist_pct 75 ["fire"]` (`8.0 W / 8`); `abilities`: `bank-the-kiln-stance` (L1) | **[NEW]** 3 tier-0 passives. |
| `canopy-bell-canon` | Canon of the Bells in the Canopy (Lâm Linh Kinh) | 1 / `main` | `names: ["moc"]`, `layers: 9`, no bonuses/passives | **[NEW]** `bonuses`: `defense_pct 10`; **[NEW]** `passives`: `evade_pct 4 []`, `art_speed_pct 6 ["moc"]`, `status_duration_pct 10 ["curse"]`, `linh_luc_regen_inc_pct 4.5 []` (`15.0 W / 16`); `abilities`: `hang-a-bell` (L1), `the-line-rings` (L2); `effects`: `Heard Through the Roots` (L4, `passive_art`) | **[NEW]** tier-1 bonus + 4 passives; passive art staged as `technique-effects`. |
| `molten-bronze-litany` | Molten Bronze Litany (Dung Đồng Kệ) | 1 / `secret` | `names: ["hoa"]`, `layers: 9`, no bonuses/passives | **[NEW]** `bonuses`: `attack_pct 10`; **[NEW]** `passives`: `attack_pct 8 ["fire"]`, `stack_effect_pct 10 ["hoa", "debuff"]`, `stack_duration_pct 10 ["hoa", "debuff"]`, `defense_pct 6 []` (`15.8 W / 16`); `abilities`: `pour-molten-bronze` (L1), `hard-as-a-bell` (L2) | **[NEW]** tier-1 bonus + 4 passives. |
| `listening-bell-seal` | Seal of the Listening Bell (Văn Linh Ấn) | 2 / `secret` | `names: ["moc"]`, `layers: 12`, no bonuses/passives | **[NEW]** `bonuses`: `than_thuc_pct 12`, `defense_pct 10`; **[NEW]** `passives`: `soul_res_pct 15 []`, `status_resist_pct 12 []`, `evade_pct 4 []`, `art_speed_pct 10 ["seal"]` (`23.8 W / 24`); `abilities`: `it-rings-for-you` (L1); `effects`: `Tuned Bronze` (L4, `passive_art`) | **[NEW]** 2 tier-2 bonuses + 4 passives; passive art staged as `technique-effects`. |

### Arts ([part-sect-vu_linh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_linh/arts/part-sect-vu_linh.json))

| ID | Name | Role / Cost / CD | Depth Text | Staged Engine Form | Deviations |
|---|---|---|---|---|---|
| `bank-the-kiln-stance` | Bank the Kiln (Ủ Lò) | `utility`, `0.03`, `5.0 s` | A stance: linh lực regenerates faster while Composed; next Fire art after leaving it deals more damage. | Toggle stance `kiln-banked` (`tags: ["composed"]`): `+0.007` `regen` while `kiln-banked` & `composed`; toggling off sets `kiln_ember = 1`, giving the next non-stance Fire art `+30 %` `dmg_more`. | **Dev 1**: renamed id from `bank-the-kiln` (collision with `phan_vu`). |
| `hang-a-bell` | Hang a Bell (Quải Linh) | `utility`, `0.04`, `5.0 s` | Gains a Bell charge for the fight; each bell raises evasion a little and reveals the unseen foe, and each reserves more linh lực than the last. | Adds `+1` `canopy_bell` (`upkeep: {"pool": "qi", "per_stack": 0.003}`); `always` grants `+3` `evade` and `+4` `acc` per bell. | **Dev 2–3**: counter named `canopy_bell` (`minh_loan` collision); no dynamic `reserved` action, so uses `upkeep` (`0.003` qi/s per bell) and `+4 acc` for reveal. |
| `the-line-rings` | The Line Rings (Tuyến Hưởng) | `damage`, `0.04`, `6.0 s` | Rings every hung bell at once: foe is slowed and takes light Wood damage per bell. | `c_art: 1.0` Chaos hit; while `canopy_bell >= 1`, adds `+35 %` `dmg_more` per bell on `art_fired` and inflicts `slowed_time` (`1` stack, `3 s`) on `hit_landed`. | **Dev 4**: uses direct `dmg_more` per bell instead of `free_hit` so `an_thanh_linh` does not clip `trig_budget`. |
| `pour-molten-bronze` | Pour (Rót Đồng) | `damage`, `0.04`, `3.0 s` | A Fire strike of molten bronze that leaves a burn and a bronze stack; at three stacks the foe is slowed. | `c_art: 1.5` Fire hit, `debuff: [1, 6.0]` (Burn); adds `+1` `bronze` (`each_for: 12.0`); when `bronze >= 3`, inflicts `slowed_time` (`1` stack, `3 s`). | **Dev 5**: `bronze` tracked as an `own` `each_for: 12.0` counter (same 1v1 target) so per-charge expiry works cleanly in both engines. |
| `hard-as-a-bell` | Hard as a Bell (Kiên Như Chung) | `ward`, `0.04`, `9.5 s` | Spends the foe's bronze stacks to raise the holder's ward for a few seconds, by stack. | Guarded `bronze >= 1`; spends all `bronze` for `ward_grow` (`0.05` hp/stack) and `ward_pct +15` (`for: 4.0`) per stack. | None (combines permanent stance ward growth + timed `ward_pct` boost). |
| `it-rings-for-you` | It Rings for You (Vị Quân Minh) | `ward`, `0.05`, `6.0 s` | Marks one foe: for the fight, the holder's ward rings before each foe art, and the next art is cast at once. | Guarded `listening_mark == 0`; sets `listening_mark = 1` + `ward_grow` (`0.08` hp); on `was_hit`/`evaded` (`kind: "art"`, `cooldown: 2.5`), `timer` `own` `next` `-99`. | **Dev 6**: `cooldown: 2.5` on the reaction prevents draining dry at `cooldown_min` every second. |

### Effects ([vu_linh.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_linh/effects/vu_linh.effects.json))

| Name | Source | Counters | Depth Rule | Engine Form & Deviations |
|---|---|---|---|---|
| `Heard Through the Roots` | `canopy-bell-canon` (L4) | `canopy_bell`, `roots_warned` | First strike each fight while a Bell charge is held is warned and partly evaded. | `always` (`canopy_bell >= 1`, `roots_warned == 0`): `evade +30`, `dampen_taken +100` (50% less damage if hit); cleared on first `was_hit` or `evaded`. |
| `Tuned Bronze` | `listening-bell-seal` (L4) | `[]` | Bells and wards resist soul and charm arts, and each stopped charm rings and slows its caster. | `always`: `soul_res 15`, `status_resist 20` (`status: "charmed"`); `soul_taken` / `evaded` (`tags: ["charm"]`) / `hit_stopped` (`tags: ["charm"]`) apply `slowed_time` (`1`, `3 s`) + `timer` foe `next` `+0.5 s`. |
| `Clear Note` | `vl-clear-bell` | `[]` | Ward rings when struck; each time it stops damage, foe is slowed 0.5 s (once per 3 s). | `on: "ward_absorbed"`, `limit: {"cooldown": 3.0}` -> `timer` `foe` `next` `+0.5 s`. |
| `The Forest Hears` | `vl-root-line-banner` | `[]` | Foe is seen from start of fight, and first ambush each fight on you fails. | **Dev 7**: `on: "fight_start"`, `per_fight: 1` -> `decoy {n: 1}` + `acc: 25` (`for: 8.0`); no stealth/ambush phase in 1v1 `fight.py`. |
| `The Line Is Tuned` | `vl-bell-lines` (3pc) | `canopy_bell`, `pour_cd` | Linked bells add 1 Slowed Time per bell when turning a hit; at 5 Slowed Time, takes apron Fire pour and stacks are spent. | **Dev 8–9**: `ward_absorbed` (while `pour_cd == 0`) adds `1 + canopy_bell` Slowed Time (`3 s`); `status_applied` (`slowed_time >= 5`) sets `pour_cd = 1` (`each_for: 3.0`, pausing bell Slowed Time while the 3 s curse clears since engine lacks foe-side status consume) and fires `free_hit {c: 2.0, dtype: "fire"}` (scaling with apron Fire `attack_pct`). |

### Items & Sets ([catalogue-sect-vu_linh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_linh/items/catalogue-sect-vu_linh.json), [sets-vu_linh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/vu_linh/items/sets-vu_linh.json))

- **4 Unique Items**:
  - `vl-clear-bell` (`treasure`, `chuong`, `rarity: 5` [depth `grade: 4`], `42.3 W / 51.2`, R6 `exception`, `holder: an_thanh_linh`, Effect `Clear Note`, `cast_ward_duration_pct: 15`)
  - `vl-root-line-banner` (`artifact`, `ky`, `grade: 4`, `37.0 W / 51.2`, `holder: an_thanh_linh`, Effect `The Forest Hears`)
  - `vl-last-blue-lamp` (`artifact`, `dang`, `grade: 3`, `28.1 W / 38.4`, `holder: chung_tan_huong`)
  - `vl-casters-apron` (`artifact`, `dao_bao`, `grade: 4`, `28.5 W / 51.2`, R6 `exception`, `holder: an_thanh_linh`)
- **1 Set**:
  - `vl-bell-lines` (`Bells on the Roads`, 3pc on `an_thanh_linh`: 2pc `than_thuc_pct 4`, `evade_pct 4`; 3pc Effect `The Line Is Tuned`).

---

## Holder Check & Combat Probes

All 18 living `vu_linh` members ran in `sect_fight.py` with **`0 REFUSED`** under `$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\vu_linh"`.

| Holder(s) | Realm | Slotted Arts | Gap 0 (`--seeds 5`) | Gap 1 (`--seeds 5`) | Effect Runs & Art Fires (Gap 0) |
|---|---|---|---|---|---|
| `an_thanh_linh` | `ket_dan` | `hang-a-bell`, `the-line-rings`, `it-rings-for-you`, `pour-molten-bronze`, `hard-as-a-bell` | `45.8 s`, `5/5`, `92%` (`48.0 s`, `20/20`, `92%` at 20 seeds) | `17.0 s`, `0/5`, `0%` | Arts fire `8.9 / 6.7 / 1.0 / 11.2 / 3.0` (20 seeds). Effects: `Heard Through the Roots` `48.0s 92%` vs `49.8s 92%` (`runs 20`), `Clear Note` `48.0s 92%` vs `47.5s 88%` (`runs 250`), `The Forest Hears` `48.0s 92%` vs `46.3s 87%` (`runs 20`), `The Line Is Tuned` `48.0s 92%` vs `63.3s 21%` (`runs 551`), `Tuned Bronze` `runs 0` (see probe). |
| `chung_tan_huong` | `ket_dan` | `hang-a-bell`, `the-line-rings`, `pour-molten-bronze`, `hard-as-a-bell` | `51.8 s`, `1/5`, `1%` | `11.0 s`, `0/5`, `0%` | Arts fire `6.6 / 4.6 / 8.8 / 2.0`. `Heard Through the Roots` `51.8s 1%` vs `48.5s 0%` (`runs 5`). |
| `chung_hong_lo`, `thieu_van_linh`, `chung_dong_am` | `truc_co` | `hang-a-bell`, `the-line-rings`, `pour-molten-bronze`, `hard-as-a-bell` | `34.8 s`, `0/5`, `0%` | `9.0 s`, `0/5`, `0%` | Arts fire `5.0 / 3.4 / 7.0 / 2.0` (`hard-as-a-bell` `0.0` at `--gap 1`: 9.0 s loss before 9.5 s cd). `Heard Through the Roots` `runs 5`. |
| `trinh_thu_linh`, `dang_quai_linh`, `la_dang_huyen` | `truc_co` | `hang-a-bell`, `the-line-rings` | `35.3 s`, `0/5`, `0%` | `8.5 s`, `0/5`, `0%` | Arts fire `6.0 / 5.0`. `Heard Through the Roots` `runs 5`. |
| `doan_thinh_moc` | `luyen_khi` | `hang-a-bell`, `the-line-rings` | `33.2 s`, `0/5`, `0%` | `8.5 s`, `0/5`, `0%` | Arts fire `5.4 / 4.4`. |
| 9 outer disciples (`thang_tieu_hoa`, `hach_chi_dien`, `bach_mien_thanh`, `nguy_tieu_dac`, `canh_tinh_am`, `giang_phong_lo`, `au_tuong_thu`, `co_thang_nhi`, `phan_linh_sach`) | `luyen_khi` | `bank-the-kiln-stance` | `37.2 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | `bank-the-kiln-stance` fires `6.8` at gap 0, `1.0` at gap 1. |

### Targeted Probes
- **`Tuned Bronze` vs soul+charm Kết Đan foe (`10` seeds)**: `with 10/10 wins, 54.4 s, 75% HP left` vs `without 10/10 wins, 53.7 s, 71% HP left`; runs: `soul_ring: 106`, `charm_stop_ward: 56`, `charm_stop_evade: 29`.
- **`Bank the Kiln + Pour` (`truc_co`, `5` seeds)**: `bank-the-kiln-stance` `8.2` fires, `pour-molten-bronze` `13.2` fires; `kiln-toggle: 41`, `kiln-leave-ember: 19`, `kiln-fire-boost: 17`.

---

## Verification Ledger

- `lint_arts.py design/stage6-staging/vu_linh/arts/part-sect-vu_linh.json`: `checked 6 arts in 1 files, 0 findings`
- `lint_techniques.py design/stage6-staging/vu_linh/techniques/catalogue-sect-vu_linh.json`: `checked 4 techniques, 0 findings`
- `lint_items.py design/stage6-staging/vu_linh/items/catalogue-sect-vu_linh.json`: `checked 4 items, 22 bases, 9 common arts, 0 findings`
- `depth_check.py --quiet`: `people 1891 ... techniques known 258, items known 661`, `findings: none`
- `depth_gap.py --sect vu_linh`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `ties_unmapped 0`, `ties_over_cap 0`, `engine_words 0`, `wishes_open 0`, `beasts 0`, `lines 19/20 runs` (1 `cast_ward_duration_pct` noted)
- Standalone `engine.validate`: `STANDALONE_OK 5`
- `sect_fight.py vu_linh --seeds 5 --gap 0` & `--gap 1` (+ `--people an_thanh_linh --seeds 20 --gap 0`): `0 REFUSED`, all 6 active arts fire, 4 of 5 Effects `runs > 0` on `typical` and 5th (`Tuned Bronze`) verified in soul+charm probe

REVIEW DONE
