# Stage 6: Lạc Hà Tông (record pass, progress file)

Brief: `production/plans/stage6/_brief-record.md` (OWNER = lac_ha). Headless job, decisions auto-accepted (user,
2026-11-26) and logged in `production/plans/stage6/lac_ha-review.md`. Resume here: do the first unchecked step.
Staging folder: `design/stage6-staging/lac_ha/` (mirrors `design/`). Never run git.

## Scope (gap report 2026-11-27, `python -I tools/design/world/depth_gap.py --sect lac_ha`)
- 4 depth techniques: evening-dust-primer (Yellow main), sunset-cloud-canon (Heaven main), evening-song-of-the-boats
  (Profound secret), long-sky-one-colour (Earth secret, parked). Existing beside them: mountain-heart-canon,
  ruin-ledger-scripture, deep-vein-scripture, hundred-blades-canon (bought), iron-hide-manual (guest elder).
- 10 new arts in the depth text (3 parked with long-sky-one-colour; 6 staged as arts + 1 passive art Effect The Glow
  Deepens); 4 referenced library arts (millstone-palm, sinking-weight, second-spring, quarry-offering), all run.
- 30 items, 10 sets, 21 staged Effects (1 passive art, 10 active item, 10 set; Geese in File parked).
- 9 stand-ins (8 servants + the guest armourer vuu_chuoc_kim on `dia_loi`); 0 beasts (no `lac_ha.beasts.json`).
- No `design/techniques/catalogue-sect-lac_ha.json` existed (no early promotion).

## Decisions so far
- **Parked (user ruling 2026-11-26, `design/world/depth/builds/postponed-2026-11-26.json`):** long-sky-one-colour is
  parked whole (its concept and its three new arts: One Colour, Geese Startled by the Cold, Geese Line), and so is the
  Cold Geese Sword's Effect Geese in File. Not staged, no ids, not in pending.json. Its four holders (canh_truong_thien,
  hinh_trong_son, su_thu_thuy, thinh_kinh_han) keep the aux as written.
- The Glow Deepens is a passive art: a technique Effect on `sunset-cloud-canon` (layer 3), same pending word
  `technique-effects` as Thiên Xu.
- Full list of 13 auto-accepted decisions with reasons in `production/plans/stage6/lac_ha-review.md` §A.

## Steps
- [x] 1. Verify first: the mechanic table (review file §B). No early promotion existed; DEPTH_STAGE verified.
- [x] 2. Techniques and arts (staged): 6 techniques (3 active lineage + 3 new stand-in methods: `evening-ferry-breath`,
      `bellows-and-hearth-breath`, `anvil-thunder-canon`), 10 arts (6 depth + 4 stand-in). `lint_arts` 0 findings;
      `lint_techniques` 0 findings (OVER_BUDGET notes only, unpriced).
- [x] 3. Effects (staged): 21 entries (1 passive art, 10 item, 10 set). All 21 validate in `engine.validate`.
      `pending.json` holds `technique-effects`.
- [x] 4. Items and sets (staged): 30 items, 10 sets. `lint_items` 0 findings.
- [x] 5. Stand-ins: all 9 replaced in `lac_ha.cast.json`, `lac_ha.3.cast.json`, `lac_ha.4.cast.json` (`nguy_thu_can` to
      `evening-dust-primer`, 3 Water/Wood servants to `evening-ferry-breath`, 4 Fire/Metal/Earth servants to
      `bellows-and-hearth-breath`, `vuu_chuoc_kim` to `anvil-thunder-canon`). Gap report `stand_ins` 0; `depth_check`
      findings: none.
- [x] 6. Beasts: none for this owner (`beasts` 0, no `lac_ha.beasts.json`).
- [x] 7. Holder check: all three linters at 0 findings; `sect_fight.py lac_ha` and `--gap 1` (10 seeds, 0 REFUSED);
      real-kit and synthetic probes for every Effect + `tree_effects` probe for `The Glow Deepens`. Fixed on the way:
      - `the-ninth-verse` cooldown 10 → 2 s so it fires when Wounded at `--gap 1`;
      - `the-sunset-clouds-fly-with-the-lone-duck` cooldown 10 → 4 s with guard `sunset_cloud <= 1` so the Field opens
        at `--gap 1`;
      - `The Lightning Sleeps` filtered to `kind: "art"` so its own fork hit never re-feeds the fork counter;
      - `Price on the Ribs` tuned from `pen: 15` to `pen: 25` per Earth stack (5 % of ~500-point typical ward);
      - `evening-song-of-the-boats` replaced `timer_resist_pct` (`NOT_PRICED`) with `status_resist_pct` and tidied
        passive W.
      All five lessons checked (review §H).
- [x] 8. Review file: `production/plans/stage6/lac_ha-review.md` (Summary, decisions §A, mechanic table §B, records
      §C–§G, holder table & probes §H, open items §I).
- [x] 9. Finish: `production/plans/stage6/lac_ha.done` written.

## Exact commands (DEPTH_STAGE=design/stage6-staging/lac_ha)
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/lac_ha/arts/part-sect-lac_ha.json`
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/lac_ha/techniques/catalogue-sect-lac_ha.json`
- `python -I tools/design/items/lint_items.py design/stage6-staging/lac_ha/items/catalogue-sect-lac_ha.json`
- `python -I tools/design/combat_sim/sect_fight.py lac_ha [--gap 1] --seeds 10`

RECORD PASS DONE
