# Stage 6: Thiên Xu Tông (record pass, progress file)

Brief: `production/plans/stage6/_brief-record.md` (OWNER = thien_xu). Headless job, decisions auto-accepted (user,
2026-11-26) and logged in `production/plans/stage6/thien_xu-review.md`. Resume here: do the first unchecked step.
Staging folder: `design/stage6-staging/thien_xu/` (mirrors `design/`). Never run git.

## Scope (gap report 2026-11-27, `python -I tools/design/world/depth_gap.py --sect thien_xu`)
- 5 techniques: weighing-stone-primer (Yellow main), dipper-handle-canon (Profound main), heavenly-pivot-true-canon
  (Heaven main), boundary-stele-array-canon (Earth secret), army-breaker-spear (Earth secret). Existing beside them:
  hundred-blades-canon, nine-seal-ledger, deep-vein-scripture, drawn-out-edge-canon, mountain-bone-body-art.
- 9 new arts (no ids yet); 9 referenced library arts (all run).
- 30 items, 10 sets, 21 Effects (11 item, 10 set); technique Effects from the authored wishes: d9 When the Handle Loses
  Count (dipper-handle-canon), d21 The Army Fights, the Marshal Waits (army-breaker-spear), d8 The Pole Draws from the
  Vein (passive art).
- 8 stand-ins (all servants, tạp dịch); 0 beasts.
- Cross-owner: loose-south's doan_moc_thinh and loc_bat_quy use this sect's methods (close when promoted);
  do_vo_cuu wears loose-south's `ls-white-wind-hook` (theirs to promote).

## Steps
- [x] 1. Verify first: the mechanic table (in the review file, §B). No early promotion existed; DEPTH_STAGE is live.
- [x] 2. Techniques and arts (staged): 6 techniques (the 5 lineage ones + new `water-clock-breath`), 9 arts.
      lint_arts 0 findings; lint_techniques 0 findings (OVER_BUDGET notes only, unpriced).
- [x] 3. Effects (staged): 22 entries (11 item, 10 set, 1 passive art). All validate in engine.validate.
- [x] 4. Items and sets (staged): 30 items, 10 sets. lint_items 0 findings.
- [x] 5. Stand-ins: 8 servants written in thien_xu.3/.4.cast.json (5 Earth to the primer, 3 Water/Wood to the new
      water-clock-breath). Gap report stand_ins 0.
- [x] 6. Beasts: none for this owner (gap report beasts 0, no `<owner>.beasts.json`).
- [x] 7. Holder check: the three linters at 0 findings; `sect_fight.py thien_xu` and `--gap 1` (10 seeds), real-kit
      probes for the item holders (spears, seal, fan, sword common arts), `tree_effects` for The Pole Draws, synthetic
      kits for the Regalia and the Armoured Horse. Fixed on the way:
      - the Dipper Handle never pointed (paced: one star a breath);
      - The Weakest File's `pierce` was suppression only (now `pen`);
      - the palm's "(or the reverse)" (it was only half built);
      - retunes after Băng Tâm's baseline (Handle 2.3, Weigh 3.0, Writ 1.4, Pivot 4 % per Weight, the Dipper's
        damage_more 3, the Pivot's regeneration 16).
      All five lessons checked (review §H).
- [x] 8. Review file: `production/plans/stage6/thien_xu-review.md` (Summary, decisions §A, the mechanic table §B,
      records §C-§G, holders §H, open items §I).
- [x] 9. Finish: `production/plans/stage6/thien_xu.done` written.

## Exact commands (DEPTH_STAGE=design/stage6-staging/thien_xu)
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/thien_xu/arts/part-sect-thien_xu.json`
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/thien_xu/techniques/catalogue-sect-thien_xu.json`
- `python -I tools/design/items/lint_items.py design/stage6-staging/thien_xu/items/catalogue-sect-thien_xu.json`
- `python -I tools/design/combat_sim/sect_fight.py thien_xu [--gap 1] --seeds 10`

RECORD PASS DONE
