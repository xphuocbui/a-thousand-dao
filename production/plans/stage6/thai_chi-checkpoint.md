# Stage 6 Checkpoint Review — Thải Chi Cốc (`thai_chi`)

**Date**: 2026-11-27
**Owner**: `thai_chi` (Batch `b03`)
**Scope**: Unanchored checkpoint review and direct fixes across `design/stage6-staging/thai_chi/` and `design/world/depth/sects/thai_chi.*`, verified by `lint_techniques.py`, `lint_arts.py`, `lint_items.py`, `depth_gap.py --sect thai_chi`, `depth_check.py --quiet`, `stage6_merge.py thai_chi --check`, `spatial_words_check.py`, standalone `engine.validate` + `Fight` runs, `sect_fight.py thai_chi --seeds 5` (`--gap 0` and `--gap 1`), and targeted probes.

---

## 1. Ranked Findings & Fixes Applied

### MUST-FIX

1. **`design/stage6-staging/thai_chi/effects/thai_chi.effects.json` & `arts/part-sect-thai_chi.json` (`Rain on the Sown Field` + `lingzhi-spores`) — `Rain on the Sown Field:ripen` dropped every 3rd spore ripening.**
   - **What was wrong**: `spores-ripen` (`lingzhi-spores`, on `pulse`) laid 1 Wood debuff, healed `1.5 %`, and decremented `lingzhi_spores` by `-1`. When `lingzhi_spores` was `1` (the 3rd spore of the 3 seeded), `spores-ripen` decremented `lingzhi_spores` to `0` *before* `eff:Rain on the Sown Field:ripen` checked `own.counter.lingzhi_spores >= 1` on the same `pulse`. Consequently, every 3rd spore ripening was silently skipped (`eff:Rain on the Sown Field:ripen` fired only `20` times vs `75` `spores-ripen` runs across 5 seeds in the pill probe).
   - **Fix applied**: Added a short-lived charge counter `{"id": "spore_ripened", "each_for": 0.5}` to `lingzhi-spores` (set to `1` by `spores-ripen`) and declared the same `{"id": "spore_ripened", "each_for": 0.5}` in `Rain on the Sown Field`'s own `counters`, switching `eff:Rain on the Sown Field:ripen` to check `own.counter.spore_ripened >= 1`. Because `each_for: 0.5` expires in `500 ms` (< `1000 ms` pulse interval), it remains `1` for same-pulse set evaluation (including the 3rd spore) and clears before the next pulse, while maintaining standalone Effect compilation parity. Verified in the pill probe (`eff:Rain on the Sown Field:ripen` increased from `20` to `38`) and `sect_fight.py` (`Rain on the Sown Field` runs increased from `97` to `118`).

2. **`design/stage6-staging/thai_chi/arts/part-sect-thai_chi.json` (`taste-and-name`) — Missing `guards` on a `c_art: 0.0`, no-heal, pure-cleanse art wasted linh lực against non-Wood foes and caused `0/5` losses.**
   - **What was wrong**: `taste-and-name` has `c_art: 0.0`, no `c_heal`, and no base buff; its `art_fired` records only apply when `own.debuff.wood >= 1`. Without a guard, `lu_niem_ha` and `nghiem_kim_ngan` cast it `7.6` times/fight against typical non-Wood foes for zero effect (`~23 %` max linh lực wasted), losing `0/5` (`55.6 s`, `0%` HP left).
   - **Fix applied**: Added `"guards": [{"read": "own.debuff.wood", "op": ">=", "value": 1}]` to `taste-and-name` (matching the pattern of pure-cleanse arts such as `quench`, `shedding-bark`, and `bell-of-waking` in `design/arts/part-*.json`). Against non-Wood typical foes `lu_niem_ha` and `nghiem_kim_ngan` now win `5/5` (`61.8 s`, `48%` HP left; `taste-and-name` fires `0.0` with a clear guard reason), while against a Wood poisoner `taste-and-name` still fires (`50` runs across 5 seeds), cleanses, and grants `+25` Chaos resistance per stack tasted.

### SHOULD

3. **`design/stage6-staging/thai_chi/arts/part-sect-thai_chi.json` (`grain-rain`) — `grain-rain-close` cleared `state: "grain-rain"` on the 6th pulse before `Rain on the Sown Field` ran.**
   - **What was wrong**: In `grain-rain.effects`, `grain-rain-tick` decremented `grain_rain` from `1 -> 0` and `grain-rain-close` immediately cleared `state` to `null` on pulse 6. Because arts expand before set Effects, `Rain on the Sown Field` (which reads `own.state.grain-rain >= 1` on `pulse`) saw `grain-rain` up for only `5` pulses instead of all `6` pulses of `Grain Rain` (`eff:Rain on the Sown Field:hold` fired `65` times vs `grain-rain-heal` `75` times in the pill probe).
   - **Fix applied**: Reordered `grain-rain-close` ahead of `grain-rain-tick` in `grain-rain.effects`. On pulse 6 `grain-rain-close` sees `grain_rain == 1` (stays open), `grain-rain-heal` and `grain-rain-grow` fire, `grain-rain-tick` decrements `1 -> 0`, and `Rain on the Sown Field` sees `own.state.grain-rain >= 1` for all `6` pulses (`78/78` parity with `grain-rain-heal` in the pill probe); on pulse 7 (at `pulse` start, before any art fires), `grain-rain-close` closes `state` to `null`.

### NIT / Open Post-Batch Items (Verified, No Edit Needed in `thai_chi` Files)

4. **`export_named.py` skips `kind == "treasure"` (`tc-purple-lingzhi-gourd`)**:
   - `tc-purple-lingzhi-gourd` (`kind: "treasure"`, `rarity: 5`, `61.0 W of 51.2` unpriced world-depth, `unique: true`, R6 `exception`, effects `["The Herbs Stay Alive", "The Empty Mountain's Answer"]`) passes `lint_items.py` with `0` findings and compiles in `fight.py` / `export_combat_library.py`. However, `tools/design/items/export_named.py:42` checks `if it.get("kind") != "artifact": continue`, so `tc-purple-lingzhi-gourd` (like `thuy_vi` and `thien_xu` treasures) is omitted from `assets/data/items_named.json` until `export_named.py` supports `kind == "treasure"` (post-batch / Stage 7 exporter item).
5. **`herb_growth_pct` and `dan_doc_resist_pct` non-fight passives on techniques**:
   - `lingzhi-pickers-song` (`passives[3]: herb_growth_pct: 6`) and `hundred-herbs-tasting` (`passives[4]: dan_doc_resist_pct: 10`) place out-of-fight keys in `passives` (and `lint_techniques.py` prints `NOT_PRICED` notes because neither key is in `lint_techniques.py`'s `PRICE` table). By contrast, `shang-mountain-lingzhi-canon` (`herb_growth_pct: 20`) and `grain-rain-canon` (`herb_growth_pct: 22`) place `herb_growth_pct` in `bonuses`, which `export_techniques.py` -> `CongPhap.bonus_lines` -> `StatSheet.build` -> `CharacterRules.herb_growth` already read. `StatSheet.build` does not read technique `passives` (combat-only), and `fight.py` skips `OUT_OF_FIGHT` keys silently. Logged for post-batch reader/exporter work (shared with `thuy_vi`).
6. **Multi-element technique `names` vs cast roots (`CongPhap.usable`)**:
   - `lingzhi-pickers-song` and `shang-mountain-lingzhi-canon` faithfully carry `names: ["moc", "thuy"]` from `thai_chi.techniques.json`, while `4` cast members (`phung_luc_ngac` `moc/hoa`, `ong_kho_sam` `moc/tho`, `nghiem_phuc_linh` `moc/tho`, `nghiem_xuyen_khung` `moc/tho`) lack `thuy`. `CongPhap.usable()` currently requires every listed element (`AND`), whereas `thai_chi.md` notes outer gate admits `Wood or Water` and inner gate requires `Wood 45+`. Shared pattern across sects (`bang_tam`, `thuy_vi`, `tung_dao`); kept faithful to `thai_chi.techniques.json` and logged for Stage 7 / `CongPhap` check.
7. **`The Empty Mountain's Answer` (`d5`) shared cross-reference & uniqueness**:
   - Verified `thai_chi.items.json` has `"new": false` on `"The Empty Mountain's Answer (Không Sơn Đáp)"`, `thai_chi.effects.json` does not duplicate it, and `assets/data/combat_effects.json` holds it under `"source": "world-depth:thuy_vi"`. `depth_gap.py --sect thai_chi` reports `0` clashes (`effects: 4 total, 3 open`), `stage6_merge.py thai_chi --check` reports `0 failure(s)`, and cross-repo ID/Effect name checks against committed `design/`, `assets/data/combat_effects.json`, and all staged `b03` folders found `0` collisions.
8. **Standalone Effect parity & multi-`mod` / anti-pattern audit**:
   - All `5` Effects in `thai_chi.effects.json` declare every counter they read/write in their own `counters` and set no undeclared stances; zero stance collisions on shared holders (`grain-rain` is the only stance); zero multi-`mod` records without `stack: true`; zero `decay_per_pulse: 1` off-by-ones; zero `always` records with record-level `filter`; zero arm-and-spend same-hit bugs (`Banked Coals:cast` lays self-burn before setting `coal_flare: 1`; `Banked Coals:double` clears `coal_flare: 0` before adding extra Fire stacks); zero environment conditions or spatial fight rules (`spatial_words_check.py` only flags descriptive prose `"rooted"` in `grain-rain-canon.concept`).
   - Note on `The Herbs Stay Alive`: models in-fight effect on first `pill_burned` (`+50` `healing` for `6.0 s`, `approx` since fight pills are smoke-only) plus `refresh {hold: true}` on own Wood buffs and foe Wood debuffs (consistent with `Frost Seal` / `Ageless Pine` / `Ten Thousand Poisons` / `Verdict Stands`).

---

## 2. Pending Words Decision

- **`pending.json` absent (`0` pending words)**: No pending words were needed; all `thai_chi` mechanics run natively on existing engine vocabulary (`strip`, `foe.buff_elements`, `tick_to_heal`, `heal_overflow`, `pill_burned`, `refresh`, `refuse_down`, `technique-effects`, self-debuff `stacks {side: "own", kind: "debuff"}`, `each_for`).

---

## 3. Verification Summary (After Final Edits)

- `lint_techniques.py`: `checked 4 techniques, 0 findings` (`NOT_PRICED` notes on `herb_growth_pct` in `lingzhi-pickers-song` and `dan_doc_resist_pct` in `hundred-herbs-tasting`).
- `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 4 items, 22 bases, 9 common arts, 0 findings`.
- `depth_check.py --quiet`: `findings: none`.
- `depth_gap.py --sect thai_chi`: `clash: 0`, `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`.
- `stage6_merge.py thai_chi --check`: `0 failure(s)`.
- Standalone `engine.validate` + `Fight`: `5/5 passed`.
- Targeted probes:
  - `Bitter Medicine` (`lu_niem_ha` vs Wood poisoner, 5 seeds): `5/5 wins`, `63.20 s`, `86.56 %` HP left with vs `5/5 wins`, `63.60 s`, `67.75 %` HP left without (`taste-name-learn: 50`, `taste-name-cleanse: 50`).
  - `Weeding Hand` (`nghiem_phuc_linh` vs `seed-of-spring` foe, 5 seeds): `5/5 wins`, `62.20 s`, `78.80 %` HP left with `weeding-strip` (`55` runs) vs `77.73 %` without.
  - `The Herbs Stay Alive` (`nghiem_linh_chi` with Wood grade-2 pill + `pill-smoke-ward`, 5 seeds): `5/5 wins`, `30.60 s` with (`5` runs; `grain-rain-heal: 78`, `Rain on the Sown Field:hold: 78`, `Rain on the Sown Field:ripen: 38`) vs `31.40 s` without.
  - `Cut to the Root` (`nghiem_linh_chi` at `shang-mountain-lingzhi-canon` layer 12 vs `--gap 1`, 5 seeds): `0/5 wins`, `12.80 s` with vs `10.80 s` without (`+2.0 s` survival).
  - `Banked Coals` (`dieu_tan_dan`, 5 seeds): `5/5 wins`, `15.98 s`, `78.80 %` HP left (`10` runs: `5` `cast` + `5` `double`; verified in parity `plog` at `t=2.500 s` self-burn + `t=2.727 s` doubled `scorch-fist` Burn stacks).

---

## 4. Holder Table After Fixes (`sect_fight.py thai_chi --seeds 5`)

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects / Art Fire Notes |
|---|---|---|---|---|---|
| `nghiem_linh_chi` | `ket_dan` | `harvest-bloom`, `lingzhi-spores`, `second-spring`, `taste-and-name`, `grain-rain` | `31.2 s`, `5/5`, `99%` | `11.2 s`, `0/5`, `0%` | `Empty Mountain` `267` runs (`31.2 s` vs `35.0 s`); `Rain on the Sown Field` `118` runs (`31.2 s` vs `33.0 s`). `taste-and-name` `0.0` (guarded on `own.debuff.wood >= 1`, verified vs Wood poisoner); `Bitter Medicine` `0` (verified in probe); `The Herbs Stay Alive` `0` (verified in probe); `grain-rain` `3.0`/fight at gap 0 (`0.0` at gap 1 due to `9.0 s` cd vs `11.2 s` defeat). |
| `dieu_tan_dan` | `ket_dan` | `brazier-form`, `flint-volley`, `furnace-heart`, `twin-flame-echo`, `scorch-fist` | `16.0 s`, `5/5`, `79%` | `8.0 s`, `0/5`, `0%` | `Banked Coals` `10` runs (`with 16.0 s` vs `without 15.7 s`); verified in `plog`. |
| `lu_niem_ha` | `truc_co` | `harvest-bloom`, `lingzhi-spores`, `second-spring`, `taste-and-name` | `61.8 s`, `5/5`, `48%` | `9.0 s`, `0/5`, `0%` | `taste-and-name` `0.0` (guarded vs non-Wood foe; `5/5` wins after fix); `Bitter Medicine` `0` (verified vs Wood poisoner). |
| `nghiem_kim_ngan` | `truc_co` | `harvest-bloom`, `lingzhi-spores`, `second-spring`, `taste-and-name` | `61.8 s`, `5/5`, `48%` | `9.0 s`, `0/5`, `0%` | Same as `lu_niem_ha`. |
| `mai_thu_dien` | `truc_co` | `harvest-bloom`, `lingzhi-spores`, `second-spring`, `grain-rain` | `36.2 s`, `5/5`, `98%` | `9.0 s`, `0/5`, `0%` | `grain-rain` `3.4`/fight at gap 0 (`0.0` at `9.0 s` gap 1). |
| `nghiem_bach_truat`, `phung_luc_ngac`, `ong_kho_sam` | `truc_co` | `harvest-bloom`, `lingzhi-spores`, `second-spring` | `61.8 s`, `5/5`, `39%` | `8.4 s`, `0/5`, `0%` | All 3 arts fired (`8.8`, `9.8`, `3.8` at gap 0). |
| `nghiem_hoi_huong`, `nghiem_hoac_huong`, `nghiem_ngu_vi`, `ung_lo_nhi` | `luyen_khi` | `harvest-bloom`, `lingzhi-spores` | `53.0-53.2 s`, `1/5`, `2%` | `8.0 s`, `0/5`, `0%` | Both arts fired (`7.6`, `7.6` at gap 0). |
| `nghiem_tuc_doan` | `luyen_khi` | `harvest-bloom` (layer 1) | `35.6 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | `harvest-bloom` fired `5.2`/fight at gap 0. |
| `nghiem_bac_ha`, `nghiem_xuyen_khung`, `nghiem_ha_kho`, `nghiem_phuc_linh`, `dau_sa_nhi` | `luyen_khi` | `seed-of-spring`, `weeding-hand` | `30.4-30.6 s`, `5/5`, `100%` | `8.0 s`, `0/5`, `0%` | Both arts fired (`5.8-6.0`, `5.6` at gap 0). |

CHECKPOINT DONE
