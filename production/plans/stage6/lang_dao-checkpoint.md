# Stage 6 Checkpoint Review — `lang_dao` (Batch `b05`)

Unanchored audit of [design/stage6-staging/lang_dao/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/lang_dao) against [lang_dao.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/lang_dao.md), [lang_dao.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/lang_dao.techniques.json), [lang_dao.items.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/lang_dao.items.json), [lang_dao.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/lang_dao.cast.json), [lang_dao.5.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/lang_dao.5.cast.json), [cong_phap.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/cultivation/cong_phap.gd), [engine.py](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/engine.py), and [effect_runner.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/combat/fight/effect_runner.gd).

## 1. Ranked Findings

1. **MUST-FIX (FIXED) — [arts/part-sect-lang_dao.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/lang_dao/arts/part-sect-lang_dao.json#L3-L40) :: `pole-vault` (`held` + `filter` engine trap)**
   - **What was wrong:** `pole-vault` used `"on": "art_fired", "filter": {"art_id": "pole-vault"}, "held": {"until": "hit_landed", "cap": 1}`. Both `engine.py` (`bank()` runs before `filter` matching) and `effect_runner.gd` execute `bank()` ignoring `filter`, so casting `rooted-form` or `backwash-seal` also banked `pole-vault-bank` (`24` banks from `13.6` `pole-vault` casts in pre-fix runs).
   - **Fix applied:** Replaced `held` with a self-counter `pole_vault_ready` (`cap: 1`), `pole-vault-arm` (`on: "art_fired", filter: {"art_id": "pole-vault"}` setting `pole_vault_ready = 1`), and `pole-vault-delay` (`on: "hit_landed", if: own.counter.pole_vault_ready >= 1` applying `timer side: foe, which: next, by: 0.3` and clearing `pole_vault_ready = 0`); updated `"rule"` wording from `"banks"` to `"arms"`.
   - **Verified:** On `uc_tieu_bong` (`seed=1`), `pole-vault` fired `14` times and `rooted-form` fired `8` times; `pole-vault-arm=14`, `pole-vault-delay=14`.

2. **SHOULD (FIXED) — [effects/lang_dao.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/lang_dao/effects/lang_dao.effects.json#L5-L89) :: `Pay the Toll` (`eff:Pay the Toll:hit`, `eff:Pay the Toll:evade`)**
   - **What was wrong:** `eff:Pay the Toll:hit` (`was_hit`) and `eff:Pay the Toll:evade` (`evaded`) have separate `per_pulse: 1` counters. A split-hit art landing at least one hit and having at least one hit evaded on the same timestamp could charge two tolls on one cast.
   - **Fix applied:** Added `toll_tick` (`{"id": "toll_tick", "each_for": 0.001, "cap": 1}`) to `Pay the Toll`'s own `counters`, guarded both listeners with `own.counter.toll_tick == 0`, and set `toll_tick = 1` when charging.
   - **Verified:** Standalone split-hit probe (`Fourfold Palm`, 4 splits with `35%` evade, `seed=3`) charged `hit=2 + evade=2 = 4 <= 4` foe casts; passes standalone `engine.validate()`.

3. **SHOULD (FIXED) — [effects/lang_dao.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/lang_dao/effects/lang_dao.effects.json#L90-L125) :: `The Boat That Did Not Burn` (`eff:The Boat That Did Not Burn:burn_mark`, `eff:The Boat That Did Not Burn:survive`)**
   - **What was wrong:** `sail_burn_tick` had `each_for: 2.0`, `burn_mark` lacked an `event.amount > 0` check, and `survive` used `any: [own.counter.sail_burn_tick >= 1, own.debuff.fire >= 1]`. That allowed `refuse_down` to fire on non-Burn direct-hit kills between pulses whenever any Fire stack existed (observed in the prior review probe triggering at `21.72 s`), and allowed 0-damage ticks to mark `sail_burn_tick`.
   - **Fix applied:** Guarded `burn_mark` with `if: [{"read": "event.amount", "op": ">", "value": 0}]`, tightened `sail_burn_tick` to `each_for: 0.001, cap: 1`, and removed `own.debuff.fire >= 1` from `survive` so `refuse_down` fires strictly when a damaging Fire Burn tick kills on that pulse.
   - **Verified:** Against lethal Burn (`thuong_bach_pham` vs pure-stack `kindle-brand`), `refused` fired at exact pulse `11000 ms` (`11.240 s` vs `9.000 s` without); against lethal Physical direct hit with 5 Fire Burn stacks present (`cinder-axe`), `thuong_bach_pham` died at `27.880 s` with `refused=[]` and `burn_mark=26`.

4. **SHOULD (FIXED) — [effects/lang_dao.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/lang_dao/effects/lang_dao.effects.json#L126-L175) :: `Round the Bend, Then the Anchor` (`eff:Round the Bend, Then the Anchor:drop`)**
   - **What was wrong:** `{"mod": {"bypass": 0.5, "pen": 150}}` had no hit-kind scope (`0.001 s` `temp_mods`), risking leaking `bypass` and `+150 pen` onto other damaging hits landing at the same millisecond as the 9th evade.
   - **Fix applied:** Added `"kind": "trigger"` to `mod` (`{"mod": {"bypass": 0.5, "pen": 150, "kind": "trigger"}}`) so the modifier scopes strictly to `free_hit`.
   - **Verified:** Passes standalone `engine.validate()` and fires cleanly in `giang_cuu_khuc` `sect_fight.py` runs and `gap+1` probe (`anchor_count=19, anchor_drop=2`).

5. **NIT (kept per precedent) — [lang_dao.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/lang_dao.techniques.json) :: `nine-bends-art`**
   - Depth prose still references `swallow-stance` and `"from behind"`, whereas staged [catalogue-sect-lang_dao.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/lang_dao/techniques/catalogue-sect-lang_dao.json#L61-L85) cleanly keeps `"names": ["thuy"]` (omitting Wind `swallow-stance` so Water+Wood holders pass `CongPhap.usable()`, matching `tung_dao`'s `startled-goose-step` precedent) and staged [part-sect-lang_dao.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/lang_dao/arts/part-sect-lang_dao.json#L106-L164) omits spatial wording. Kept depth prose untouched (`spatial_words_check.py --sect lang_dao` reports 0 rule hits).

### Audited & Confirmed Clean
- **Techniques (`3`):** `ferry-pole-primer` (`7.9 / 8 W`), `washing-waves-canon` (`23.3 / 24 W`), `nine-bends-art` (`16.0 / 16 W`) pass `lint_techniques.py` with `0` findings and match all `lang_dao` + `loose-south` (`trinh_tieu_do`, `yen_hoi_do`) roots in `CongPhap.usable()`.
- **Arts (`3`):** `pole-vault`, `a-thousand-washings` (unscoped `mod` for `pierce` / `acc` verified intentional where `engine.mod(..., None)` reads with empty ctx), `ninth-bend` pass `lint_arts.py` with `0` findings.
- **Items (`4`) & Set (`1`):** `ld-nine-bend-toll-seal` (`kind: "treasure", rarity: 5`, R6 exception), `ld-last-white-sail`, `ld-first-fleet-anchor`, `ld-ferry-master-oilskin`, and `ld-nine-landings` match `lang_dao.items.json` and pass `lint_items.py` with `0` findings.
- **Uniqueness & Spatial:** `0` ID/Effect-name collisions against [assets/data/combat_effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/assets/data/combat_effects.json), committed `design/`, and `design/stage6-staging/`; `0` hits from `spatial_words_check` on all 6 staged files; `depth_check.py --sect lang_dao` reports `findings: none`.
- **Standalone Effects (`3`):** Every Effect in `lang_dao.effects.json` declares all read/written `own` counters in its own `counters` list and passes standalone `engine.validate()`.

---

## 2. Pending Words Decision

- [design/stage6-staging/lang_dao/pending.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/lang_dao/pending.json) is empty (`"words": []`, `"arts": []`, `"effects": {}`). No new engine words were needed or pending.

---

## 3. Post-Fix Holder Table (`sect_fight.py lang_dao --seeds 5`)

Ran post-edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\lang_dao`. All 18 living cast members ran with **0 REFUSED**, exit `0`, and every slotted art fired:

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins/5`, `hp_left`) | Gap 1 (`mean_s`, `wins/5`, `hp_left`) | Effects (`with / without`, `runs` Gap 0 / Gap 1) |
|---|---|---|---|---|---|
| `tiet_an_thuy` | `truc_co` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep`, `backwash-seal` | `16.8 s`, `5`, `100%` | `8.6 s`, `0`, `0%` | — |
| `uc_lang_hoa` | `truc_co` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep` | `34.2 s`, `4`, `60%` | `8.7 s`, `0`, `0%` | — |
| `uc_tieu_bong` | `luyen_khi` | `pole-vault`, `rooted-form` | `62.2 s`, `5`, `74%` | `13.0 s`, `0`, `0%` | — (`pole-vault` `14.0` fires / `2.6` Gap 1) |
| `to_lenh_chu` | `luyen_khi` | `gathering-wave`, `a-thousand-washings` | `30.8 s`, `0`, `0%` | `8.0 s`, `0`, `0%` | — |
| `bo_tay_sa` | `luyen_khi` | `pole-vault`, `rooted-form` | `62.2 s`, `5`, `74%` | `13.0 s`, `0`, `0%` | — (`pole-vault` `14.0` fires / `2.6` Gap 1) |
| `ngo_da_do` | `luyen_khi` | `gathering-wave`, `a-thousand-washings` | `30.8 s`, `0`, `0%` | `8.0 s`, `0`, `0%` | — |
| `ky_chu_nhi` | `luyen_khi` | `pole-vault`, `rooted-form` | `62.6 s`, `5`, `67%` | `13.0 s`, `0`, `0%` | — (`pole-vault` `14.2` fires / `2.6` Gap 1) |
| `giang_cuu_khuc` | `ket_dan` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep`, `ninth-bend`, `backwash-seal` | `11.4 s`, `5`, `100%` | `24.8 s`, `0`, `0%` | `Pay the Toll`: `11.4 vs 13.1 s` (`runs 26`) / `24.8 vs 15.6 s` (`runs 26`); `Round the Bend, Then the Anchor`: `11.4 vs 11.8 s` (`runs 27`) / `24.8 vs 23.5 s` (`runs 69`) |
| `thuong_bach_pham` | `ket_dan` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep`, `ninth-bend` | `22.5 s`, `5`, `100%` | `12.9 s`, `0`, `0%` | `The Boat That Did Not Burn`: `22.5 vs 22.5 s` (`runs 0 NEVER_RAN` vs Fire-free `typical` foe; verified in targeted Fire-Burn probe below) / `12.9 vs 12.9 s` (`runs 0`) |
| `giang_hoi_lan` | `truc_co` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep`, `backwash-seal` | `16.8 s`, `5`, `100%` | `8.6 s`, `0`, `0%` | — |
| `lai_bat_khuc` | `truc_co` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep`, `ninth-bend` | `20.5 s`, `5`, `99%` | `10.5 s`, `0`, `0%` | — |
| `sai_ket_lam` | `truc_co` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep` | `34.2 s`, `4`, `60%` | `8.7 s`, `0`, `0%` | — |
| `thuong_thien_dao` | `truc_co` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep` | `34.2 s`, `4`, `60%` | `8.7 s`, `0`, `0%` | — |
| `le_tieu_pham` | `luyen_khi` | `gathering-wave`, `a-thousand-washings` | `30.8 s`, `0`, `0%` | `8.0 s`, `0`, `0%` | — |
| `ma_truong_cao` | `luyen_khi` | `gathering-wave`, `a-thousand-washings` | `30.8 s`, `0`, `0%` | `8.0 s`, `0`, `0%` | — |
| `thach_thap_dinh` | `luyen_khi` | `pole-vault`, `rooted-form` | `62.6 s`, `5`, `67%` | `13.0 s`, `0`, `0%` | — (`pole-vault` `14.2` fires / `2.6` Gap 1) |
| `giang_tieu_loan` | `luyen_khi` | `pole-vault`, `rooted-form` | `62.6 s`, `5`, `67%` | `13.0 s`, `0`, `0%` | — (`pole-vault` `14.2` fires / `2.6` Gap 1) |
| `dong_cuu_mon` | `luyen_khi` | `gathering-wave`, `a-thousand-washings` | `30.8 s`, `0`, `0%` | `8.0 s`, `0`, `0%` | — |

### Targeted Verification Probes (post-edit)
- **Standalone Effects (`engine.validate`):** All 3 Effects compiled standalone (`0` errors, all `own` counters declared locally).
- **`pole-vault` (`uc_tieu_bong`, `seed=1`):** `pole-vault` `14` casts, `rooted-form` `8` casts, `pole-vault-arm=14`, `pole-vault-delay=14` (`win=A`, `63.00 s`).
- **`The Boat That Did Not Burn` (`thuong_bach_pham`):**
  - Positive probe (heavy Fire Burn): `burn_mark=59`, `refused` triggered on exact Burn pulse `11000 ms` leaving `1` HP (`t=11.240 s` vs `9.000 s` without).
  - Negative probe (lethal Physical hit with 5 Fire Burn stacks active): died at `27.880 s` (`burn_mark=26`, `refused=[]`).
- **`Pay the Toll` standalone (`giang_cuu_khuc`, `35%` evade vs 4-split earth art, `seed=3`):** `B_casts=4`, `stamp=1`, `hit=2`, `evade=2` (`total_tolls=4 <= 4`).
- **`Round the Bend, Then the Anchor` + `ninth-bend` (`giang_cuu_khuc` vs `gap+1`, `seed=1`):** `anchor_count=19`, `anchor_drop=2`, `ninth_arm=2`, `ninth_unleash=2` (`t=32.68 s`).

CHECKPOINT DONE
