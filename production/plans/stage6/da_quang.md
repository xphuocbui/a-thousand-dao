# Stage 6: Dạ Quang Môn (`da_quang`, progress file)

Method: `production/plans/stage6/_brief-record.md` (auto-accepted decisions, headless record pass).
Existing committed records preserved: `red-sand-sabre-primer` (`design/techniques/catalogue-sect-da_quang.json`), `cut-the-horse` (`design/arts/part-sect-da_quang.json`).

## Scope (`python -I tools/design/world/depth_gap.py --sect da_quang`)
- **Techniques (2)**: `red-sand-sabre-primer` (game, Yellow main, `hoa`), `night-glow-blood-sabre-canon` (rule text -> staged, Earth main, `hoa` + `kim`).
- **New arts (4)**: `cut-the-horse` (runs), `crescent-of-red-sand` (rule text -> staged), `pay-in-blood` (rule text -> staged), `wine-in-the-night-glow-cup` (passive art Effect `d19`, `a1`).
- **Items (6) & sets (2)**: `dq-night-glow-cup` (treasure -> `rarity: 4`), `dq-night-sabre`, `dq-red-feather-sabre`, `dq-lost-silver-tally`, `dq-felt-rider-coat`, `dq-gamblers-ember-ring`; sets `dq-night-raider` (3pc), `dq-red-band` (3pc).
- **Effects (4)**: `Blood Casting` (already in `combat_effects.json`), `Wine in the Night-Glow Cup`, `Drink After the Raid`, `Cut the Horse First`, `First and Often`.
- **Stand-ins / Beasts**: `0` stand-ins across `16` living cast records (`da_quang.cast.json` + `da_quang.5.cast.json`), `0` beasts.
- **Cross-owner**: `cao_sa_lang` (`demonic.2.cast.json`) uses `night-glow-blood-sabre-canon` at layer 6 (closes on `da_quang` merge/export).

## Steps
- [x] 1. Verify first: mechanic table & `spatial_words_check.py --sect da_quang` (0 rule hits; 3 soft/postponed prose notes in ties/intent).
- [x] 2. Techniques and arts (staged under `design/stage6-staging/da_quang/`, `da_quang.techniques.json` updated with `"id"` fields).
- [x] 3. Effects (staged under `design/stage6-staging/da_quang/effects/da_quang.effects.json`).
- [x] 4. Items and sets (staged under `design/stage6-staging/da_quang/items/`).
- [x] 5. Stand-ins: none (`0` stand-ins in `da_quang`).
- [x] 6. Beasts: none (`0` beasts in `da_quang`).
- [x] 7. Holder check: linters, standalone `engine.validate`, `sect_fight.py da_quang --seeds 5` (`--gap 0` and `--gap 1`), targeted probes.
  - `lint_techniques.py`: `checked 2 techniques, 0 findings` (`3.3 W / 8`, `22.9 W / 24`).
  - `lint_arts.py`: `checked 3 arts in 1 files, 0 findings`.
  - `lint_items.py`: `checked 6 items, 22 bases, 9 common arts, 0 findings`.
  - Standalone `engine.validate`: `4 / 4` Effects valid.
  - `depth_check.py --quiet`: `findings: none`.
  - `spatial_words_check.py --sect da_quang`: `0` rule-field hits (`3` soft/postponed prose notes in ties/intent).
  - `sect_fight.py da_quang --seeds 5` (`--gap 0` and `--gap 1`) + `3x HP` tank probe: every active art fired and all `4` new Effects ran and changed fights on real holders.
- [x] 8. Review file (`production/plans/stage6/da_quang-review.md`).
- [x] 9. Finish (`production/plans/stage6/da_quang.done` + `RECORD PASS DONE`).

RECORD PASS DONE
