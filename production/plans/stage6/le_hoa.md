# Stage 6: Lê Hoa Am (`le_hoa`) progress file

Method: `production/plans/stage6/_brief-record.md` (`OWNER = le_hoa`, headless/delegated job, decisions auto-accepted).

## Scope (`depth_gap.py --sect le_hoa`, 2026-11-27)
- 3 depth techniques (`gate-sword-primer`, `pear-blossom-snow-sword`, `sealed-cold-sutra`). Existing lineage main: `winter-toll-canon` (`catalogue-ice.json`).
- 5 new arts (`bar-the-gate`, `eighth-month-snow`, `one-branch-of-pear`, `lay-the-seal`, `sit-against-the-door`).
- 5 items (`lh-bolt-ice-bell` treasure grade 4 / rarity 5, `lh-snow-veil-robe`, `lh-pear-branch-sword`, `lh-miners-gate-coat`, `lh-grey-sisters-beads`), 2 sets (`lh-pear-blossom-vigil`, `lh-the-gate`), 3 Effects (`Toll of the Frozen Bolt`, `Until It Stops Wanting`, `None Shall Pass`).
- 0 stand-ins, 0 beasts, 4 structured events, 0 cross-owner refs, 24 modifier lines (all run).
- `spatial_words_check.py`: only soft hits in `le_hoa.cast.json` (`beside` in tie note, `behind it` in tree intent); 0 rule hits.

## Steps
- [x] 1. Verify first: mechanic table built; `spatial_words_check.py` checked; `deep-winter-form` stance conflict identified and resolved with self-counters (`gate_raised`, `petal_field`, `sit_door`).
- [x] 2. Techniques and arts staged (`design/stage6-staging/le_hoa/techniques/catalogue-sect-le_hoa.json`, `arts/part-sect-le_hoa.json`); art ids registered in `design/world/depth/sects/le_hoa.techniques.json`.
- [x] 3. Effects staged (`design/stage6-staging/le_hoa/effects/le_hoa.effects.json`): all 3 Effects self-declare every counter id they read or write (`bell_toll`, `seal_hold`, `vigil_toll`, `gate_blocks`, `gate_pass`).
- [x] 4. Items and sets staged (`design/stage6-staging/le_hoa/items/catalogue-sect-le_hoa.json`, `items/sets-le_hoa.json`).
- [x] 5. Stand-ins: none (`stand_ins: 0`).
- [x] 6. Beasts: none (`beasts: 0`).
- [x] 7. Holder check: `lint_arts.py` (0 findings), `lint_techniques.py` (0 findings), `lint_items.py` (0 findings), `depth_check.py --quiet` (findings: none), `depth_gap.py --sect le_hoa` (`stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `lines: 24/24`), standalone Effect validation (3/3 OK), `sect_fight.py le_hoa --seeds 5` (`--gap 0` and `--gap 1`, 0 REFUSED, all 5 new arts fire and all 3 Effects run), plus sub-record probes and `manh_tinh_chi + bar-the-gate` probe.
- [x] 8. Review file (`production/plans/stage6/le_hoa-review.md`, ending with `REVIEW DONE`).
- [x] 9. Finish (`RECORD PASS DONE` and `production/plans/stage6/le_hoa.done`).

RECORD PASS DONE
