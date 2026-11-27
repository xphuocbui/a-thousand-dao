# Stage 6: Thối Tinh Môn (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method", and `production/plans/stage6/_brief-record.md` (headless job, decisions auto-accepted).

## Scope (gap report 2026-11-27, `python -I tools/design/world/depth_gap.py --sect thoi_tinh`)
- 2 proposal techniques: `star-quench-canon` (Profound main, Metal), `fallen-star-forging-rite` (Earth secret, Metal + Fire). Existing in lineage: `nine-temper-scripture`, `iron-hide-manual`.
- 5 new arts in `thoi_tinh.techniques.json`: 4 active (`quench-strike`, `ninth-blow`, `white-heat`, `the-makers-fold`) + 1 passive art (`Brittle from Its Own Blow`, `d30`, wired via `effects` on `star-quench-canon` at layer 4).
- 5 items (`tht-three-years-tax`, `tht-river-tongs`, `tht-coal-black-apron`, `tht-star-brand`, `tht-quench-robe`), 1 set (`tht-fallen-star-forge`).
- 4 Effects (`Brittle from Its Own Blow` d30, `Sky Iron Sings`, `Drawn from the River`, `Heat the Edge` d43).
- 0 stand-ins, 0 beasts, 0 cross-owner references, 0 open engine words.

## Steps
- [x] 1. Verify first: mechanic table (all 4 active arts, 4 Effects, 2 techniques, 5 items, 1 set covered by existing engine words; no new engine words needed).
- [x] 2. Techniques and arts (staged in `design/stage6-staging/thoi_tinh/`).
- [x] 3. Effects (staged in `design/stage6-staging/thoi_tinh/effects/thoi_tinh.effects.json`).
- [x] 4. Items and sets (staged in `design/stage6-staging/thoi_tinh/items/`).
- [x] 5. Stand-ins (none needed: 0 open in depth_gap).
- [x] 6. Beasts (none: 0 beasts).
- [x] 7. Holder check (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\thoi_tinh`):
      - `lint_arts.py`: 4 arts checked, 0 findings.
      - `lint_techniques.py`: 2 techniques checked (`star-quench-canon` 14.7 W of 16, `fallen-star-forging-rite` 23.0 W of 24), 0 findings.
      - `lint_items.py`: 5 items checked, 0 findings.
      - `sect_fight.py thoi_tinh --seeds 5` and `--gap 1`: all 4 active arts fire on their real holders; `Brittle from Its Own Blow` and `Heat the Edge` run in `--gap 0`; `Drawn from the River` runs in `--gap 1` (`runs 5`); `Sky Iron Sings` (`runs 0` in typical `--gap 0/1` since typical foes lack Thunder arts and fights end at 10.2-14.6 s before 5 Fire casts) verified in targeted Thunder-foe (`thunder: 5`, `strike: 7`) and 50x-HP (`Heat the Edge quench: 1`, `Sky Iron Sings strike: 3`) probes.
      - Standalone Effect validation (`engine.validate` per Effect): all 4 Effects compile standalone.
- [x] 8. Review file (`production/plans/stage6/thoi_tinh-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` and `production/plans/stage6/thoi_tinh.done`).

RECORD PASS DONE
