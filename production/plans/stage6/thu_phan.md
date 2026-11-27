# Stage 6 Record Pass: `thu_phan` (Thu Phần Các / Pavilion of the Autumn Graves)

- **Owner**: `thu_phan`
- **Stage path**: `design/stage6-staging/thu_phan`
- **Brief**: `production/plans/stage6/_brief-record.md`

## Checklist
- [x] **Step 1 — Verify first**: `depth_gap.py --sect thu_phan` + `spatial_words_check.py` (0 spatial hits on rules; 0 beasts; 0 stand-ins; 0 pending engine words needed; 30/30 cast lines run)
- [x] **Step 2 — Decisions**: Logged all auto-accepted design decisions, tier-matched technique bonuses/passives, and proxy scopes in `thu_phan-review.md`
- [x] **Step 3 — Techniques & Arts**: Staged `techniques/catalogue-sect-thu_phan.json` (3) and `arts/part-sect-thu_phan.json` (6), linked `"id"` in `design/world/depth/sects/thu_phan.techniques.json`
- [x] **Step 4 — Effects & Items**: Staged `effects/thu_phan.effects.json` (4), `items/catalogue-sect-thu_phan.json` (6), `items/sets-thu_phan.json` (2)
- [x] **Step 5 — Static Lint & Depth Check**: `lint_arts.py` (0), `lint_techniques.py` (0), `lint_items.py` (0), `depth_check.py` (`findings: none`), `depth_gap.py --sect thu_phan` (`0` unknown/cross-owner/beasts/stand-ins/wishes, `30/30` lines run), and standalone `engine.validate` (`STANDALONE_OK` on all 4 Effects and 6 arts)
- [x] **Step 6 — Combat Sim**: `sect_fight.py thu_phan --seeds 5` at `--gap 0` and `--gap 1` (`0 REFUSED`, all 6 arts fire, all 4 Effects run on real holders with verified `with` vs `without` deltas, including `2.5x` HP `Blood Turns to Jade` probe)
- [x] **Step 7 — Review & Done**: Wrote `production/plans/stage6/thu_phan-review.md` (`REVIEW DONE`), `production/plans/stage6/thu_phan.done`, and finalized progress

RECORD PASS DONE
