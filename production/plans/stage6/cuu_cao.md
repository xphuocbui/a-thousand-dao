# Stage 6: Cửu Cao Phái (`cuu_cao`, progress file)

Method: `production/plans/stage6/_brief-record.md` and `production/plans/world-depth-implementation.md` Stage 6 (decisions auto-accepted per user ruling 2026-11-26).

## Scope (`python -I tools/design/world/depth_gap.py --sect cuu_cao`)
- **Techniques (2):** `marsh-reed-breath` (Yellow main, Wood, outer), `crane-bond-rite` (Profound secret, Wind + Wood, inner). Existing catalogue methods used: `gale-courier-scripture`, `slow-hour-scripture`.
- **New arts (4 in depth, 3 active + 1 passive Effect):**
  - `marsh-reed-breath`: `reed-bed` (Reed Bed, L1)
  - `crane-bond-rite`: `crane-descends` (Crane Descends, L1), `cry-in-the-nine-marshes` (Cry in the Nine Marshes, L4), `A Crane for the Rider` (L2 passive art in `crane-bond-rite.effects` + `cuu_cao.effects.json`)
- **Items (3) & Sets (1):** `cc-green-field-bell` (`chuong` 4, treasure rarity 5, `The King Answers`), `cc-winter-terrace-cloak` (`dao_bao` 3), `cc-crane-down-robe` (`dao_bao` 3), set `cc-green-field-riders` (`Rider and King`).
- **Stand-ins:** 0 across all 17 living members (`cuu_cao.cast.json` + `cuu_cao.5.cast.json`).
- **Beasts (3):** `thanh_dien` (`ung_hac_minh`), `han_vu` (`cu_van_ly`), `bat_phi` (`mai_lo_tuyet`).
- **Events (3):** `N-cuu_cao-01`, `N-cuu_cao-02`, `N-cuu_cao-03` (structured; close at Stage 7 export).

## Mechanic Table (Step 1)
| Record | Kind | Mechanic | Engine Status | Decision |
|---|---|---|---|---|
| `marsh-reed-breath` | Technique (T0 main, `moc`) | New Yellow passives (`health_regen_inc_pct 8`, `stack_duration_pct 8 [moc,debuff]`, `status_duration_pct 8 [curse]`, `attack_pct 2 [moc]`) | Exists | Sized 7.7 W <= 8 W |
| `crane-bond-rite` | Technique (T1 secret, `phong+moc`) | New Profound bonus (`khi_huyet_pct 10`) & passives (`attack_pct 8 [companion]`, `evade_pct 4`, `art_speed_pct 6 [phong]`, `stack_effect_pct 8 [phong,buff]`); L2 passive Effect | Exists (`technique-effects` b01) | Sized 14.7 W <= 16 W; `cry-in-the-nine-marshes` unlocked at L4 so `tong_phi_thu` & `banh_da_hang` cast it |
| `reed-bed` | Art (`marsh-reed-breath` L1) | 8 s Field state; per pulse `slowed_time` (1, 2 s), `wood` stack (1, 6 s), `heal 0.015` | Exists (`states` `field`, `pulse`) | Timed 8 s Field via `reed_bed` pulse counter |
| `crane-descends` | Art (`crane-bond-rite` L1) | Wind strike + knockback + open + evade & speed | Exists (`timer`, `off_guard`, `mod`) | Non-spatial knockback = `timer` delay 0.3 s + `off_guard` 1 s; `mod` evade +8, art_speed +10 for 4 s; `crane` tag |
| `cry-in-the-nine-marshes` | Art (`crane-bond-rite` L4) | Wind burst + break concentration + lengthen buffs; not music | Exists (`timer`, `refresh`) | `c_art 1.2`, `buff [1, 6]`, `timer` 0.8 s, `refresh {side: own, kind: buff}`; `crane` tag, no `song` tag |
| `A Crane for the Rider` | Passive Effect (`crane-bond-rite` L2) | Crane companion hits -> Wind buff; no companion -> `crane-descends` summons 8 s crane spirit (20 s cd) | Approx (`summon` lacks tags; no `own.companions`) | `crane_bonded` latches on `crane` companion hit/evade; `crane_spirit` (`each_for: 8`) tracks summon Wind stacks when `crane_bonded == 0` |
| `The King Answers` | Item Effect (`cc-green-field-bell`) | Once/fight bell calls Thanh Điền (Wind strike) + crane arts cast twice for a few s | Exists (`free_hit`, `fire_art`, `each_for`) | Rings on first `crane` art fired (`free_hit 1.2 force`, `king_answers` `each_for: 8`) + `fire_art {which: "last", share: 1.0}` |
| `Rider and King` | Set Effect (`cc-green-field-riders`) | Evade -> crane king Wind strike (1/s); while beside you -> 1% HP/s | Approx (no live `own.companions`) | `king_beside` latches on `crane` companion hit/evade; `evaded` `free_hit 0.6 force` (`per_pulse: 1`); `pulse` `heal 0.01` |
| Signature items (3) | Items | `sources: ["npc"]`, `unique: true`, R6 `exception`, `rarity: 5` on treasure | Exists | All 3 bases (`chuong`, `dao_bao`) carry R6 `exception` |
| Beasts (3) | Cast wiring | `han_vu` -> `cu_van_ly`, `bat_phi` -> `mai_lo_tuyet` (`thanh_dien` already on `ung_hac_minh`) | Exists (`beasts` field) | Added `beasts` to `cu_van_ly` and `mai_lo_tuyet` in `cuu_cao.cast.json` |

## Steps
- [x] 1. Verify first: mechanic table & `spatial_words_check.py --sect cuu_cao` (0 removed/postponed).
- [x] 2. Techniques and arts (staged under `design/stage6-staging/cuu_cao/` + art ids in `cuu_cao.techniques.json`).
- [x] 3. Effects (`design/stage6-staging/cuu_cao/effects/cuu_cao.effects.json`).
- [x] 4. Items and sets (`design/stage6-staging/cuu_cao/items/catalogue-sect-cuu_cao.json`, `sets-cuu_cao.json`).
- [x] 5. Stand-ins (0 open).
- [x] 6. Beasts (`beasts` wired on `cu_van_ly` and `mai_lo_tuyet` in `cuu_cao.cast.json`).
- [x] 7. Holder check:
  - `lint_arts.py`: 0 findings (3 arts).
  - `lint_techniques.py`: 0 findings (`marsh-reed-breath` 7.7 W of 8, `crane-bond-rite` 14.7 W of 16).
  - `lint_items.py`: 0 findings (3 items, all unique, R6 exceptions).
  - `depth_check.py`: `findings: none`.
  - Standalone `engine.validate` on all 3 Effects in `cuu_cao.effects.json`: all 3 VALID.
  - `sect_fight.py cuu_cao --seeds 5` at `--gap 0` and `--gap 1` + remaining 4 members (`--people`): 0 REFUSED across all 17/17 living members; every slotted art fires.
  - 20-seed crane companion probes (`ung_hac_minh` + `thanh_dien`, `cu_van_ly` + `han_vu`) at `--gap 0` and `--gap 1`: `A Crane for the Rider` (161/221/247/233 runs), `The King Answers` (134/141 runs), and `Rider and King` (274/394 runs) all run and change fight outcomes.
- [x] 8. Review file (`production/plans/stage6/cuu_cao-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` and `production/plans/stage6/cuu_cao.done`).

RECORD PASS DONE
