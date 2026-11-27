# Bình Thủy Môn (`binh_thuy`): Stage 6 Checkpoint Review

Unanchored checkpoint review of `design/stage6-staging/binh_thuy/` against `design/world/depth/sects/binh_thuy.*`, `binh_thuy.md`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

---

## 1. Ranked Findings

1. **SHOULD — `design/world/depth/sects/binh_thuy.items.json` :: `bth-the-crossing` (`Somewhere Else by Morning`)**
   - **What was wrong:** Line 325 still carried the pre-2026-11-26 spatial clause `"carries you behind the attacker and turns all five into a tide..."` (`behind the attacker` was not matched by `spatial_words_check.py`, which only checks `behind the foe` and `behind (you|them|it|him|her)`), whereas the staged `sets-binh_thuy.json` and `binh_thuy.effects.json` had already rewritten it non-spatially.
   - **Fix applied:** Rewrote `binh_thuy.items.json` line 325 to `"each time you evade, gain one Water buff stack; while you hold 5 or more Water buff stacks, your next evade spends 5 of them to raise a tide that heals you 1 % of your health per stack each second for 5 s."` matching `sets-binh_thuy.json` and `DECISIONS-2026-11-26.md`.

2. **NIT — `design/world/depth/sects/binh_thuy.items.json` :: `bth-ferry-token-ring.lore`**
   - **What was wrong:** Line 180 misspelled `"Hạng Thiên Nhai"` as `"Hang Thiên Nhai"` (the staged `catalogue-sect-binh_thuy.json` had already corrected it to `"Hạng Thiên Nhai"`).
   - **Fix applied:** Updated `"Hang Thiên Nhai"` -> `"Hạng Thiên Nhai"` in `binh_thuy.items.json` line 180 so depth and staged lore match `binh_thuy.cast.json`.

3. **NIT (informational, no edit) — `bui_phieu_binh` committed family stances (`deep-lake-stance` + `swallow-stance`)**
   - `bui_phieu_binh`'s pre-existing build (`still-moon-tide-scripture` + `gale-courier-scripture`) slots both `deep-lake-stance` (`design/arts/family-water.json`) and `swallow-stance` (`design/arts/family-wind.json`), which share the fighter's single stance slot and overwrite each other when cast. Both are committed family arts outside `binh_thuy`'s Stage 6 files, so no edits were made.

---

## 2. Specific Audits & Parity Verification

- **`Slack Water` / `The Tenth Layer` handshake (`slack_armed`, `slack_water_threshold`, `slack_just_healed`):**
  - Both Effects declare all shared handshake counters (`slack_water_threshold`, `slack_just_healed`) in their own `"counters"` arrays, and `fight.py` / `build_file_compiler.gd` deduplicate counters by ID, giving order-independent standalone compilation parity (`test_every_library_effect_compiles`).
  - `eff:Slack Water arm` listens on `buff_gained` (`element: "water"`, `own.buff.water >= 5` or `>= 4` when `slack_water_threshold >= 1`) before `swelling-tide-palm` can consume Water buff stacks in `shape()` ahead of `art_fired`.
  - `eff:Slack Water heal` wraps `heal {share: 0.04}` with `slack_just_healed = 1 -> 0`. Both `heal_restored` and `heal_overflow` listeners in `The Tenth Layer` clear `slack_just_healed = 0` on firing, preventing double grants when a heal partially overflows (`5` `heal` + `29` `heal_overflow` = `34` `Slack Water heal` at gap 0; `52` + `14` = `66` at gap 1).
  - `eff:The Tenth Layer refresh` fires on `blocked` (`event.amount > 0`) and refreshes `el: "water", side: "own", kind: "buff"` in both `engine.py` and `effect_runner.gd`.
  - Verified `Slack Water` standalone (without `The Tenth Layer` on `luong_bach_tan` over 5 seeds): `10.5 s`, `5/5` wins, `100 %` HP, `block: 87`, `arm: 40`, `heal: 13`.
- **`Every Day of the Year` (`slowed_time` + `delay_immune`):**
  - Split cleanly into two `always` records (`eff:Every Day of the Year slow` and `eff:Every Day of the Year delay`) gated on `own.buff.water >= 1`, plus `eff:Every Day of the Year evade` (`per_fight: 1`, `+2` Water buffs for `8 s`).
  - Verified against `engine.py` and `fight.gd`/`effect_runner.gd`: `status_immune` checks `{"status": sid}` (`slowed_time`) and `delay_immune` checks `null` context.
  - Verified in targeted probe (`bui_phieu_binh` vs `drag-of-the-deep` + `frost-breath-palm`): `0` `slowed_time` hits and `0` delays taken (`22.8 s` seed 1; `22.7 s` 5-seed mean) vs `5` `slowed_time` hits and `2` delays without (`26.8 s` seed 1; `25.2 s` 5-seed mean). `"approx"` accurately documents that foe art element is not exposed.
- **`close-over-the-stone` (`was_hit` `event.amount > 0` guard):**
  - Both `engine.py` and `fight.gd` populate `ev["amount"] = dealt` on `was_hit`. Paired with `own.counter.duckweed_mend == 0`, `limit: {"cooldown": 6.0}`, and explicit `add: -1` inside `close-over-pulse` (avoiding `decay_per_pulse: 1` off-by-one). Runs `45` hits / `131` pulses at gap 0 (`5` seeds) and `10` hits / `20` pulses at gap 1 (`5` seeds) on `ba_lang_nhi`.
- **`Somewhere Else by Morning` (`evaded` consume order):**
  - `eff:Somewhere Else by Morning tide` (`own.buff.water >= 5` -> `consume` 5 Water buffs + `crossing_tide = 5`) precedes `eff:Somewhere Else by Morning stack` (`+1` Water buff) in `records`. Both `engine.py` and `fighter_profile.gd`/`effect_runner.gd` preserve listener array order, so reaching 5 stacks waits for the *next* evade to spend 5 and pulse-heal `5 %` HP/s for `5 s` (`5` tides / `21` heals at gap 0; `6` tides / `26` heals at gap 1).
- **Standalone compilation, multi-`mod`, `temp_mods`, collisions & spatial check:**
  - `4/4` Effects pass `E.validate()` standalone with `0` undeclared counters and `0` stances.
  - `0` multi-`mod` records without `"stack": true`; `0` `temp_mods` filtering by `"art_id"`; `0` `always` records with record-level `filter`; `0` `decay_per_pulse: 1`.
  - `0` ID, Effect-name, record-ID, or counter-name collisions against `assets/data/combat_effects.json`, committed `design/`, or other staged `b04` directories (`coc_vu`, `ham_nguyet`, `van_hac`, `van_khoi`, `vu_an`).
  - `spatial_words_check.py --sect binh_thuy --depth`: `1` non-soft hit (`rename`: false-positive `"Still"` in `"Still Moon Tide"` on `slack-water`) and `1` soft hit (`"behind it"` in `luong_bach_tan.build.tree.intent`).
  - All `18` living cast members (`11` living in `binh_thuy.cast.json`, `7` living in `binh_thuy.5.cast.json`) use `binh_thuy` / `still-moon-tide-scripture` methods (`0` stand-ins, `0` beasts), and all roots fit admission rules (`thuy`/`moc >= 30` outer, `thuy >= 45` inner).

---

## 3. Pending Words

None (`pending.json` absent; all mechanics expressed cleanly with existing engine words).

---

## 4. Holder Table (after final edits)

### Linters (`DEPTH_STAGE=design/stage6-staging/binh_thuy`)
- `lint_techniques.py`: `checked 1 techniques, 0 findings` (`duckweed-drift-primer`: `7.9 W of 8`, `close-over-the-stone` @ L1, `chance-meeting` @ L2).
- `lint_arts.py`: `checked 2 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 7 items, 22 bases, 9 common arts, 0 findings` (`7 of 7` unique, R6 `exception` on the 4 weapons/armour/shield).

### `sect_fight.py binh_thuy --seeds 5` (`--gap 0` and `--gap 1`, `0` `REFUSED`)

| Holder | Realm | Arts (gap 0 fires) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (gap 0 with vs without, runs; gap 1 runs) |
|---|---|---|---|---|---|
| `ba_lang_nhi`, `nhu_thanh_can`, `hoan_khach_nhi`, `ngo_ba_can`, `ong_tieu_pham`, `ton_niem_trieu`, `dam_thuy_sinh`, `ngo_tan_tan` (8 outer) | `luyen_khi` | `close-over-the-stone` (9.6), `chance-meeting` (24.2) | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` (1.0 / 3.4 fires) | — (`close-over-hit`: 45 / 10, `close-over-pulse`: 131 / 20) |
| `ong_te_do` | `truc_co` | `deep-lake-stance` (5.2), `gathering-wave` (3.0), `brimming-cup` (2.0), `swelling-tide-palm` (4.0), `backwash-seal` (8.0) | `13.6 s`, `5/5`, `100%` | `9.0 s`, `0/5`, `0%` | — (`bth-crossing-lamp` stat-only) |
| `bui_phieu_binh` | `ket_dan` | `deep-lake-stance` (6.2), `gathering-wave` (3.8), `brimming-cup` (3.2), `swelling-tide-palm` (5.0), `swallow-stance` (5.8), `hundred-feather-flurry` (3.4) | `19.2 s`, `5/5`, `100%` | `14.8 s`, `0/5`, `0%` | `Every Day of the Year`: 19.2s 100% vs 18.8s 100% (`5` / `5`); `Somewhere Else by Morning`: 19.2s 100% vs 19.8s 100% (`61` / `54`) |
| `luong_bach_tan` | `ket_dan` | `deep-lake-stance` (4.8), `gathering-wave` (2.2), `brimming-cup` (1.8), `swelling-tide-palm` (3.0), `backwash-seal` (5.2), `seep-through-palm` (4.8) | `10.6 s`, `5/5`, `100%` | `22.0 s`, `0/5`, `0%` (20 seeds: `24.1 s`, `1/20`, `2%`) | `Slack Water`: 10.6s 100% vs 12.6s 100% (`199` / `485`); `The Tenth Layer`: 10.6s 100% vs 10.1s 100% (`122` / `275`) |

CHECKPOINT DONE
