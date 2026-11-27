# Stage 6: Hoa Cái Đường (progress file)

Owner: `hoa_cai`
Method: `production/plans/world-depth-implementation.md` Stage 6, `_brief-record.md` (auto-accept enabled).

## Scope (`depth_gap.py --sect hoa_cai`, 2026-11-27)
- 4 techniques (`cinnabar-washing-primer`, `canopy-furnace-canon`, `nine-cycle-mercury-art`, `sulphur-lung-breath`)
- 6 new arts (5 written in `part-sect-hoa_cai.json`; `pill-smoke` reused from `design/arts/part-sect-market-folk.json`)
- 5 items (`hc-nine-cycle-gourd` treasure g4/r5, `hc-canopy-furnace`, `hc-sulphur-fan`, `hc-fume-censer`, `hc-cinnabar-robe`)
- 2 sets (`hc-canopy-and-lid`, `hc-blind-founder`)
- 4 Effects (`The Unfinished Pill`, `Nine Stars over the Fire`, `Under the Lid`, `A Room Full of Fume`)
- 0 stand-ins, 0 beasts, 0 cross-owner references, 3 structured events (`N-hoa_cai-01..03`).

## Steps
- [x] 1. Verify first: mechanic table built; `spatial_words_check.py` 0 hits for `hoa_cai`; `pill-smoke` verified already promoted in `design/arts/part-sect-market-folk.json`.
  - Existing engine words cover every technique, art, item, set, and Effect. 0 pending words.
- [x] 2. Techniques and arts (`design/stage6-staging/hoa_cai/techniques/catalogue-sect-hoa_cai.json`, `arts/part-sect-hoa_cai.json`, plus art `"id"` fields in `design/world/depth/sects/hoa_cai.techniques.json`).
- [x] 3. Effects (`design/stage6-staging/hoa_cai/effects/hoa_cai.effects.json`, all 4 standalone-validated via `engine.validate`).
- [x] 4. Items and sets (`design/stage6-staging/hoa_cai/items/catalogue-sect-hoa_cai.json`, `sets-hoa_cai.json`).
- [x] 5. Stand-ins (none: 0 stand-ins in cast files).
- [x] 6. Beasts (none: 0 beasts).
- [x] 7. Holder check (`lint_arts.py` 0 findings; `lint_techniques.py` 0 findings; `lint_items.py` 0 findings; `depth_check.py --sect hoa_cai` `findings: none`; `depth_gap.py --sect hoa_cai` `unknown_ids: 0`, `engine_words: 0`; `sect_fight.py hoa_cai --seeds 20 --gap 0` and `--seeds 5 --gap 1` `0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN`).
- [x] 8. Review file (`production/plans/stage6/hoa_cai-review.md`, ending with `REVIEW DONE`).
- [x] 9. Finish (`hoa_cai.done` written).

RECORD PASS DONE
