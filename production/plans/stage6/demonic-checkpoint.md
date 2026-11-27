# Stage 6 Checkpoint Review — Ma Đạo Outside the Tower (`demonic`, Batch `b06`)

Unanchored checkpoint review of `design/stage6-staging/demonic/` and `design/world/depth/people/demonic.*` against [\_brief-review.md](file:///C:/Users/xphuo/IdeaProjects/my-game/production/plans/stage6/_brief-review.md), [\_brief-record.md](file:///C:/Users/xphuo/IdeaProjects/my-game/production/plans/stage6/_brief-record.md), [DECISIONS-2026-11-25.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/DECISIONS-2026-11-25.md), [DECISIONS-2026-11-26.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/DECISIONS-2026-11-26.md), and [FIGHT-INPUT.md](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/FIGHT-INPUT.md) (verified directly against [engine.py](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/engine.py), [fight.py](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/fight.py), [sect\_fight.py](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/sect_fight.py), [lint\_techniques.py](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/arts/lint_techniques.py), [cong\_phap.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/cultivation/cong_phap.gd), [fight.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/combat/fight/fight.gd), and [effect\_runner.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/combat/fight/effect_runner.gd)).

---

## 1. Ranked Findings

### MUST-FIX

1. **[MUST-FIX — FIXED] `techniques/catalogue-sect-demonic.json` — Missing `"suite"` on 5 techniques (`SUITE_SPLIT` on whole-catalogue lint)**
   - **What was wrong:** All 6 new arts in [part-sect-demonic.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/arts/part-sect-demonic.json) declare `"group": "<tech_id>"`, but only `black-ice-method` declared `"suite": "<tech_id>"` in [catalogue-sect-demonic.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/techniques/catalogue-sect-demonic.json). Explicit-path `lint_techniques.py` skips missing-suite checks, so the gap was hidden, whereas whole-catalogue `lint_techniques.py` (no args, run by `stage6_gate.py serial`) would fail with 5 `SUITE_SPLIT` errors on `shade-orchid-breath`, `black-wind-blood-sabre`, `withered-branch-method`, `copper-mountain-bell-canon`, and `night-moth-karst-canon`.
   - **Fix applied:** Added `"suite": "<id>"` to all 5 techniques in [catalogue-sect-demonic.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/techniques/catalogue-sect-demonic.json). Verified `0` `SUITE_SPLIT` warnings across the merged catalogue + `demonic` staging.

2. **[MUST-FIX — FIXED] `effects/demonic.effects.json` — `Draw the Ink` (`dm-ink-needle`) `status_dur` filter miss & unpaid `hp_cost`**
   - **What was wrong:**
     1. `eff:Draw the Ink spend` emitted `"mod": {"status_dur": 100, "tags": ["seal"], "for": 0.5}`. In both `engine.py:1645` and `fight.gd:1495`, `apply_status()` reads `status_dur` with `sctx = {"status": sid, "kind": d.kind, "tags": (d.kind, sid)}`, which lacks `"seal"`, so `status_dur: 100` never matched and gave **0 %** duration bonus.
     2. `eff:Draw the Ink spend` used `"refund": {"share": 1.0}` (linh lực) and claimed in `"approx"` that `blood-ink-writ` has no `hp_cost`, whereas [family-soul-song-seal.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/arts/family-soul-song-seal.json#L97) gives `blood-ink-writ` `"hp_cost": 0.03`.
   - **Fix applied:** Added `eff:Draw the Ink no_hp` (`on: "always"`, `if: [own.counter.ink_drawn >= 1]`, `mod: {"hp_cost_red": 1.0, "art_id": "blood-ink-writ"}` — `pay()` checks `art_ctx` which includes `"art_id"`), and updated `eff:Draw the Ink spend` to `"mod": {"status_dur": 100, "kind": "curse", "for": 0.1}` (matching `sctx` during `blood-ink-writ`'s synchronous hit), plus updated `"approx"` in [demonic.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/effects/demonic.effects.json).

3. **[MUST-FIX — FIXED] `effects/demonic.effects.json` — `Sealed in His Name` (`dm-blood-seal`) `always` `art_id` never matched `sctx`**
   - **What was wrong:** `eff:Sealed in His Name` used `"on": "always"` with `"mod": {"status_dur": 100, "art_id": "blood-ink-writ"}`. Because `apply_status()` passes `sctx` (which never carries `"art_id"`), `eff:Sealed in His Name` gave **0 %** duration bonus in both engines.
   - **Fix applied:** Changed `eff:Sealed in His Name` to `"on": "art_fired"`, `"filter": {"art_id": "blood-ink-writ"}`, `"do": [{"mod": {"status_dur": 100, "curse_fast": 1, "kind": "curse", "for": 0.1}}]` in [demonic.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/effects/demonic.effects.json), matching `sctx` (`kind: "curse"`), doubling curse duration (up to `curse_duration_max = 5 s`), and making the writ unclearnsable (`curse_fast: 1`). Verified in Probe P1: `stagnation` duration increased from `1000 ms` (bare) to `3300 ms` (`+15%` Needle + `+15%` Seal + `+100%` Draw the Ink + `+100%` Sealed in His Name).

4. **[MUST-FIX — FIXED] `effects/demonic.effects.json` — `His Sister's Water` (`dm-bitter-well-gourd`) `qi_drained` fired on drainer, not victim**
   - **What was wrong:** `eff:His Sister's Water ward` listened `"on": "qi_drained"`. In both `engine.py:2072` and `effect_runner.gd:485`, `burn_qi` emits `"qi_drained"` on `s` (the **drainer**), not `o` (the **victim**), so `ward` never fired when a foe drained `tra_ham_tuyen` and instead fired on his own `marrow-siphon-palm` drains.
   - **Fix applied:** Changed `eff:His Sister's Water ward` to `"on": "was_hit"`, `"filter": {"tags": ["drain"]}` (`gain_qi {share: 0.02}` during `gourd_ward`) and updated `"approx"` in [demonic.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/effects/demonic.effects.json). Verified in Probe P3 against a `drain`-tagged foe (`drink: 1`, `ward: 2`).

---

### SHOULD

5. **[SHOULD — FIXED] `effects/demonic.effects.json` — `Nine Wicks` (`dm-borrowed-wick-lamp`) false physical-kill save & `< 1 HP` at `luyen_khi`**
   - **What was wrong:** `eff:Nine Wicks soul mark` armed `last_hit_soul` on any `soul_taken` (including non-lethal or reflected soul hits), and `eff:Nine Wicks clear mark` required `own.hp_share > 0` on `was_hit`. If a non-lethal soul hit armed `last_hit_soul` and a single lethal physical hit dropped HP from `> 0` to `<= 0` within `1 s`, `clear mark` skipped (`own.hp_share == 0`) and `Nine Wicks save` falsely rescued a physical kill. Also `refuse_down: {"hp_share": 0.002}` leaves `0.88 < 1` HP at `luyen_khi`.
   - **Fix applied:** Gated `eff:Nine Wicks soul mark` on `own.hp_share <= 0` and `event.reflected == 0` (arming only when an unreflected soul art actually drops HP to `<= 0`), cleared `last_hit_soul = 0` inside `save`, removed the redundant `clear mark`, and used `{"refuse_down": {}}` (`1.0` HP at all realms) in [demonic.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/effects/demonic.effects.json). Verified `5/5` lethal soul saves and `0/5` false saves on non-lethal soul + lethal physical hits.

6. **[SHOULD — FIXED] `effects/demonic.effects.json` — `Writ in Their Blood` (`dm-set-blood-ink-study` 3pc) cost refund & empower window**
   - **What was wrong:** `eff:Writ in Their Blood free` used `gain_qi {share: 0.03}` (twice `blood-ink-writ`'s actual `0.015 * qi_base` linh lực cost after `cost_scale = 0.5`, while leaving `hp_cost: 0.03` unpaid), and `eff:Writ in Their Blood empower` left `+20 % dmg_more` on `tags: ["seal"]` for `0.5 s`.
   - **Fix applied:** Replaced `gain_qi {share: 0.03}` with `refund {share: 1.0}` + `heal {share: 0.03, ignore_taken: true}`, tightened `for: 0.5` -> `for: 0.1`, and updated `"approx"` in [demonic.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/effects/demonic.effects.json). Verified in Probe P1b (`free: 7`, `empower: 6`).

7. **[SHOULD — FIXED] `effects/demonic.effects.json` — `The Robe Drinks First` (`dm-blood-red-robe`) 0-damage `was_hit` guard**
   - **What was wrong:** `eff:The Robe Drinks First save` checked only `own.hp_share < 0.5`, allowing a 0-damage blocked hit after a tick dropped HP below `50 %` to waste the `per_fight: 1` save with `0` heal.
   - **Fix applied:** Added `{"read": "event.amount", "op": ">", "value": 0}` to `eff:The Robe Drinks First save` in [demonic.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/effects/demonic.effects.json).

8. **[SHOULD — OPEN FOR STAGE 7/9] `design/world/depth/people/demonic.2.cast.json` — `khoai_hong_ngac` root fit under `CongPhap.usable()`**
   - **What was found:** `khoai_hong_ngac` (`huyen_kim` L7 -> `black-wind-blood-sabre` L7) has root `{"elements": {"kim": 52, "thuy": 30, "tho": 28}, "variants": {}}` (no `"hoa"`), whereas `black-wind-blood-sabre` has `"names": ["kim", "hoa"]`. Under `CongPhap.usable()` (`src/gameplay/cultivation/cong_phap.gd:43`), she cannot equip `black-wind-blood-sabre` at Stage 7 export without either a Fire root or a `kim`-only method (`nine-temper-scripture` caps at layer 6 and is `bo_thiet_sinh`'s non-blood method). All other `24/25` living `demonic` cast members pass `CongPhap.usable()`.
   - **Action:** Kept `black-wind-blood-sabre` L7 unedited to remain faithful to `demonic.md` §5 (`Metal, Fire`), `demonic.md` §11 Roster (`Metal 52, Water 30, Earth 28`), and `khoai_hong_ngac.build.note` (`"Stand-in for the Black Wind Blood Sabre."`), and logged for Stage 7/9 ruling (matching `cung_tinh` / `cuu_cao` / `tung_dao` precedent).

9. **[SHOULD — OPEN FOR STAGE 7/9] `design/world/depth/people/demonic.cast.json` — `ham_tan_chung` pre-existing `main`-in-`aux` slot (`hollow-bell-canon`)**
   - **What was found:** `ham_tan_chung` holds `aux: [{"tech": "hollow-bell-canon", "layer": 6}]`, where `hollow-bell-canon` has `tech_kind: "main"` (`CongPhap.set_slot("aux", ...)` rejects `main` methods; his `build.note` names `borrowed-wick-sutra`, which is `secret` and carries the same two arts).
   - **Action:** Left unedited as pre-existing Stage 5 cast data and logged for Stage 7/9 cleanup.

---

### NIT

10. **[NIT — FIXED] `effects/demonic.effects.json` — `Lullaby of the Karst` (`dm-karst-lamp`, `d40`) `sleep` duration `4` -> `3`**
    - **What was wrong:** `eff:Lullaby of the Karst` set `"dur": 4` on `sleep`, whereas [auth-eff-2.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/builds/authored/auth-eff-2.json#L655) (`d40`) and `combat_engine.json` `STATUS["sleep"]` specify `3` pulses.
    - **Fix applied:** Changed `"dur": 4` -> `"dur": 3` in [demonic.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/effects/demonic.effects.json).

11. **[NIT — OPEN FOR `s6-serial-b06`] `items/catalogue-sect-demonic.json` — `dm-cracked-bell` (`scope: ["soul"]` vs depth `["song"]`, `lint-song-scope`)**
    - **What was found:** [demonic.items.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/demonic.items.json#L179) scopes `dm-cracked-bell`'s `art_speed_pct 10` to `["song"]` (per `auth-mod.json`, intentionally speeding `soul-ledger-chime` and `tolling-bell-requiem` without speeding `lamp-oil-lance`), while staged `catalogue-sect-demonic.json` changed it to `["soul"]` because `lint_techniques.py` `TIER` lacks `"song"`. Both `fight.py` and GDScript already support `"song"` in `tags`.
    - **Action:** Kept `["soul"]` in staged `catalogue-sect-demonic.json` so `lint_items.py` passes pre-serial with `0 findings`, and flagged **`lint-song-scope`** (already queued in `b06` by `hermits-sages`) for `s6-serial-b06` to add `"song": "family"` to `lint_techniques.py` `TIER` and restore `"scope": ["song"]` on `dm-cracked-bell`.

---

## 2. Specific Focus Audits & Consolidated Checklist

- **Techniques (`9`) & Arts (`6`):**
  - All 9 techniques carry `owner: "demonic"`, `origin: "authored"`, tier-matched `bonuses`, valid passive scopes, `suite` matching their arts' `group`, and `black-ice-method` preserves `curse_effect_pct: 8` (`NOT_PRICED` note only, `0 findings`).
  - All 6 staged arts (`borrowed-sleep`, `drink-within-a-breath`, `move-the-sickness`, `black-frost-seal`, `soul-ledger-chime`, `night-moth-ink`) pass `lint_arts.py` (`0 findings`), use `within_a_breath` `add: 1` + `event.share` scaling, `pay_per_stack: 0.005`, `black-frost-seal` `Withering` on `hit_landed` (`empower` `x1.54`, gated), and `0` `"consume"` counter calls.
- **Items (`12`) & Sets (`3`):**
  - All 12 `dm-*` items match `demonic.items.json` modifiers (modulo `dm-cracked-bell` `["soul"]` pre-serial bridge), carry `sources: ["npc"]`, `unique: true`, `rarity: 4/5` on treasures, and R6 `exception` on the 8 weapon/body_gear/ward_gear items.
  - All 3 sets (`dm-set-blood-ink-study`, `dm-soul-pedlar`, `dm-u-lan-keeper`) match `demonic.items.json` names, Hán-Việt tags, 2pc modifiers, and 3pc rules verbatim.
- **Effects (`15`) & Pitfall Checklist:**
  - Top-level `demonic.effects.json` has `"_doc"` and `"source": "world-depth:demonic"`. All 14 runnable Effects declare every counter they read/write locally and pass standalone `E.validate()` (`0` stances set, `0` `always`+`filter`, `0` multi-`mod` without `stack: true`, `0` `temp_mods` with `art_id`/`status`, `0` `set: 1` on `each_for`+`cap: 1`, `0` `decay_per_pulse: 1`, `0` `"consume"` counter calls). `Fed in Blood` is `not_run` (`records: []`).
  - `Drink from the Dark` `1.1 s` `regen` `pulse` mod spans the `1.0 s` pulse cycle cleanly (`240` runs gap 0, `276` runs gap 1).
  - Uniqueness & spatial checks: `0` ID or Effect-name collisions across `assets/data/combat_effects.json`, committed `design/`, and other `design/stage6-staging/` dirs; `spatial_words_check.py --sect demonic`: `0` demonic hits.

---

## 3. Pending Words

- `pending.json` is absent (`0` new engine words required).
- `Fed in Blood` (`dm-sons-lamp`) remains `not_run` (`out-of-fight seasonal upkeep and narrative hook`).

---

## 4. Post-Fix Verification & Holder Table

### Linters & Gates (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\demonic`)
- `lint_techniques.py`: `checked 9 techniques, 0 findings` (`5/5` new suite techniques carry `"suite"`, `0` `SUITE_SPLIT` across merged catalogue + staging).
- `lint_arts.py`: `checked 6 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 12 items, 22 bases, 9 common arts, 0 findings`.
- `spatial_words_check.py --sect demonic`: `0` demonic hits (`67` committed/shipped records).
- `depth_check.py --sect demonic --quiet`: `findings: none`.
- `depth_gap.py --sect demonic`: `stand_ins: 0`, `unknown_ids: 0`, `ties_unmapped: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 59 (6 open: 5 game [am], 1 rule text [curse_effect_pct])`.
- `stage6_merge.py demonic --check`: `0 failure(s)`.
- Standalone `E.validate()`: `15/15` pass (`0` failures).
- Targeted probes: `P1` (`Draw the Ink` + `Sealed in His Name`: `stagnation` `1000 ms -> 3300 ms`), `P1b` (`Writ in Their Blood` vs Bleed foe: `free: 7`, `empower: 6`), `NW` (`Nine Wicks`: `5/5` lethal soul saves, `0/5` false physical saves), `P3` (`His Sister's Water` vs `drain` foe: `drink: 1`, `ward: 2`), `P4` (`black-ice-method` + `rime-lotus`: `Black Thaw: 57`, `empowered: 12`), `P5` (`move-the-sickness`: `sickness-moved: 13`, `wound-moved: 13`).

### `sect_fight.py demonic --seeds 5` (`--gap 0` & `--gap 1`, `0` `REFUSED`)

| Holder | Realm | Slotted arts (gap 0 fires) | Gap 0 (`mean_s`, wins, hp) | Gap 1 (`mean_s`, wins, hp) | Effects (`with` vs `without`, gap 0 / gap 1 runs) |
|---|---|---|---|---|---|
| `trieu_huyet_y` | `ket_dan` | `marrow-siphon-palm` (3.0), `hollow-husk-stance` (6.0), `hollowing-strike` (2.0), `debt-blade` (4.0), `seep-through-palm` (4.0), `marrow-to-dew` (1.0) | `10.8 s`, `5/5`, `100%` | `10.6 s`, `0/5`, `0%` | `Draw the Ink`: `10.8s 100%` vs `10.8s 100%` (`5` / `5` + P1); `The Robe Drinks First`: `0` / `5` (`10.6s` vs `10.0s`) |
| `ham_tan_chung` | `ket_dan` | `soul-ledger-chime` (4.0), `tolling-bell-requiem` (3.6), `lamp-oil-lance` (1.2) | `13.6 s`, `5/5`, `77%` | `10.2 s`, `0/5`, `0%` | `The Held Voice`: `13.6s 77%` vs `14.4s 77%` (`10` / `10`); `Nine Wicks`: `13.6s 77%` vs `13.6s 77%` (`5` / `5` + NW probe `5/5`); `A Breath Bought`: `13.6s 77%` vs `13.0s 80%` (`20` / `7`) |
| `sao_an_lan` | `ket_dan` | `night-moth-ink` (11.8), `seep-through-palm` (15.0), `marrow-to-dew` (8.8), `drag-of-the-deep` (11.2) | `51.2 s`, `5/5`, `99%` | `58.7 s`, `0/5`, `0%` | `Drink from the Dark`: `51.2s 99%` vs `51.2s 99%` (`240` / `276`); `Lullaby of the Karst`: `51.2s 99%` vs `31.7s 96%` (`56` / `65`); `A Breath That Costs No One`: `51.2s 99%` vs `51.2s 16%` (`570` / `656`) |
| `khoai_thiet_ung` | `ket_dan` | `debt-blade` (7.2), `shearing-palm` (7.2), `drink-within-a-breath` (7.2) | `21.6 s`, `5/5`, `84%` | `8.0 s`, `0/5`, `0%` | `Within a Breath`: `21.6s 84%` vs `21.6s 85%` (`68` / `22`) |
| `tra_ham_tuyen` | `ket_dan` | `marrow-siphon-palm` (3.0), `hollow-husk-stance` (6.0), `hollowing-strike` (2.0), `seep-through-palm` (4.0), `marrow-to-dew` (1.0), `drag-of-the-deep` (2.0) | `10.8 s`, `5/5`, `82%` | `11.9 s`, `0/5`, `0%` | `His Sister's Water`: `10.8s 82%` vs `10.8s 82%` (`1` / `5` + P3 `ward: 2`) |
| `ngu_mong_te`, `sung_ngoc_khe` | `truc_co` | `thorn-lullaby` (9.0), `borrowed-sleep` (11.0) | `55.6 s`, `5/5`, `88%` | `9.0 s`, `0/5`, `0%` | — |
| `khoai_hong_ngac` | `truc_co` | `debt-blade` (7.6), `shearing-palm` (7.2), `drink-within-a-breath` (7.2) | `23.6 s`, `5/5`, `56%` | `8.0 s`, `0/5`, `0%` | — |
| `duong_kho_chi` | `truc_co` | `seed-of-spring` (2.0), `rooted-form` (2.0), `second-spring` (0.6), `harvest-bloom` (2.0), `thorn-rain` (2.0), `blight-canker` (2.0) | `12.8 s`, `5/5`, `100%` | `12.8 s`, `0/5`, `0%` | — (`move-the-sickness` overflows `MAX_ARTS = 6`; verified in P5) |
| `cao_sa_lang` | `truc_co` | `crescent-of-red-sand` (7.8), `pay-in-blood` (3.0) | `32.0 s`, `5/5`, `40%` | `8.0 s`, `0/5`, `0%` | `Wine in the Night-Glow Cup`: `32.0s 40%` vs `32.0s 37%` (`282` / `32`) |
| `mat_thu_ninh` | `truc_co` | `deep-lake-stance` (10.2), `gathering-wave` (6.2), `brimming-cup` (5.0) | `27.7 s`, `5/5`, `100%` | `10.6 s`, `0/5`, `0%` | `Fed in Blood`: `0` / `0` (`not_run`) |
| `chi_da_hanh`, `an_tieu_mac` | `luyen_khi` | `thorn-lullaby` (8.0), `borrowed-sleep` (9.4) | `49.2 s`, `5/5`, `90%` | `8.4 s`, `0/5`, `0%` | — |

CHECKPOINT DONE
