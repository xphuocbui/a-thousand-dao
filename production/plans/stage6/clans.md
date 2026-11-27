# Stage 6 Record Pass — `clans` (Batch b05)

Owner type: major people group (`design/world/depth/people/clans.*`)
Totals: 5 techniques, 6 new arts, 17 items, 6 sets, 12 Effects (6 item + 6 set), 46 stand-ins, 0 beasts, 9 structured events.

## Checklist
- [x] Step 1 — Load and map all `clans` depth artifacts (`depth_gap.py`, `clans.techniques.json`, `clans.items.json`, `clans.cast.json`, `clans.2.cast.json`, `clans.md`, Effect uniqueness check, spatial wording check)
- [x] Step 2 — Stage techniques & arts (`catalogue-sect-clans.json`, `part-sect-clans.json`), insert `"id"` into `clans.techniques.json`, run `lint_arts.py` & `lint_techniques.py` (0 findings)
- [x] Step 3 — Stage 12 Effects (`clans.effects.json`) and verify standalone compilation (`engine.validate()`: 12/12 pass, `errors: []`)
- [x] Step 4 — Stage 17 items & 6 sets (`catalogue-sect-clans.json`, `sets-clans.json`) and run `lint_items.py` (0 findings)
- [x] Step 5 — Replace all 46 stand-ins in `clans.cast.json` (23) and `clans.2.cast.json` (23)
- [x] Step 6 — Run `sect_fight.py clans --seeds 5 --gap 0` and `--gap 1`, plus targeted probes (`cl-set-old-hall` 3pc, `cl-reeling-thread` 2pc with `needle-rain`, `Under the Locust` water ward grow, `falling-locust-flowers` fire-debuff gate)
- [x] Step 7 — Run `depth_check.py` (`findings: none`), `depth_gap.py --sect clans` (`stand_ins 0`), `stage6_merge.py clans --check` (`0 failure(s)`)
- [x] Step 8 — Write `production/plans/stage6/clans-review.md` and `production/plans/stage6/clans.done`

## Scope & Spatial Notes
- Staging directory: `design/stage6-staging/clans/` (`techniques/catalogue-sect-clans.json`, `arts/part-sect-clans.json`, `items/catalogue-sect-clans.json`, `items/sets-clans.json`, `effects/clans.effects.json`).
- Effect names verified unique against `assets/data/combat_effects.json`.
- Spatial wording flags in source depth files mapped cleanly to non-spatial engine equivalents without requiring new engine words (`pending.json`: none, `0` pending words).

RECORD PASS DONE
