# Stage 6: Băng Tâm Các (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method" (user-approved 2026-11-26).
Resume here: read this file, then do the first unchecked step.

## User rulings for this sect (2026-11-26)
- Commit after every unit, own paths only.
- Stand-ins as proposed (table below). hang_minh_sa's method (Dạ Quang's `red-sand-sabre-primer`) is promoted early
  with this sect, per the method's step 4, so Băng Tâm's gap reaches zero.
- Review format: `production/plans/stage6/bang_tam-review.md`, each rule beside its engine form.

- After this sect: the other sects run as headless Sonnet jobs via `tools/headless/run_jobs.py`, two in parallel
  (plan Stage 6). Băng Tâm's pass is the template for their brief.

## Scope (gap report 2026-11-26, `python -I tools/design/world/depth_gap.py --sect bang_tam`)
- 4 techniques: clear-frost-breath (Yellow main, outer), jade-vessel-ice-heart-canon (Earth main),
  snow-plum-sword (Profound secret), frost-lotus-array-canon (Earth secret). Existing in the lineage: winter-toll-canon,
  stilled-hour-sutra.
- 9 new arts (no ids yet).
- 23 items, 9 sets, 11 Effects (2 item, 9 set).
- 2 beasts (ngoc_dieu, han_tich; owner lam_tuyet_dieu), 5 events (structured).
- 1 person over the tie cap: on_sa_ngoc (export trims, Stage 7).
- 5 cross-owner references to clear-frost-breath (hermits-sages, loose-north, tam_kiem): these close when it is
  promoted.
- Authored wish records to take as written: d18 `frost-answers-the-blow` (auth-eff-1.json, Heart in the Jade Vessel);
  the a1 rewordings (Ice in the Vessel, The Peak Does Not Move, Sitting on the Ice). e9 `black-ice-method` (for
  cung_mac_suong) is held until her story turns (WIRED.md); it is not in this pass.

## Stand-ins (ruled)
| Person | Root | Pick |
|---|---|---|
| trac_on_tuyen | Water, Wood | clear-frost-breath, layer 1 (lineage) |
| giai_tieu_hoa | Fire, Earth | red-sun-scripture (Dương Lô's method, the note) |
| dao_han_mac | Earth, Fire | new Băng Tâm Yellow servants' method (Earth, Wood, Fire) |
| ma_thao_nhi | Earth, Wood | the same new method |
| quy_to_nga | Wood, Water | the same new method ("a Wood breath of her own in the washing steam") |
| hang_minh_sa | Fire, Metal | red-sand-sabre-primer (Dạ Quang outer method, promoted early) |

## Steps
- [x] 1. Verify first: the mechanic table (exists / needs a word / needs a ruling), spatial_words_check.
- [x] 2. Checkers up front: lint_techniques, lint_arts, suite_check, lint_items (known broken), exporters' --check,
      sets export in export_named.py. Done 2026-11-26:
      - `lint_items.py` works again. Its GDD parser was in the removed Đạo Đồ editor; it is restored as
        `tools/design/items/gdd_catalogue.py`.
      - Both linters treat `catalogue-sect-*.json` as unpriced: the W sum is still noted, and NOT_PRICED and
        OVER_BUDGET are notes there, not findings.
      - Both linters accept the depth fields (`rank`, `concept`, `owner`; `set`, `made_by`, `made_year`,
        `legendary_key`, `where`). The item lint counts an Effect named in `combat_effects.json` as known.
      - The technique lint's signature arts are `family-*.json` plus `part-sect-*.json`.
      - `export_named.py` also writes `items_sets.json` from `design/items/sets-*.json`, and its `--check` covers both
        files.
      - Both engines run a full set's Effect from `combat_effects.json` by name when the set has no inline record
        (`add_sets` / `_add_sets`). Tests: `test_engine.py` t_item_sets (watched it fail first) and
        `fight_depth_test.gd` `test_a_full_set_naming_a_library_effect_runs_its_record`.
      - `lint_arts.py` reads `part-*.json` already. `export_combat_library.py` and `export_techniques.py` glob the sect
        files already.
      - Carried over for later sects (not Băng Tâm's): `export_techniques.py` does not export a technique's own
        `effects` (black-ice-method has two), and `export_named.py` skips `kind: treasure` (58 depth treasures).
- [~] 3a. Techniques and arts (+ the servants' method, red-sand-sabre-primer). Done 2026-11-26 except the four arts
      that need W1-W3 (heart-in-the-jade-vessel, clear-heart-mirror, hidden-fragrance, glacier-bastion: written in
      step 5 after their words):
      - `design/techniques/catalogue-sect-bang_tam.json`: 5 techniques, the 4 lineage ones plus the new
        `warm-hearth-breath` (Earth, Wood and Fire, Yellow, the servants' method, art `warm-hands`).
      - `design/techniques/catalogue-sect-da_quang.json`: `red-sand-sabre-primer`, promoted early (art
        `cut-the-horse`).
      - `design/arts/part-sect-bang_tam.json`: frost-breath-palm, rime-lotus, five-petals-of-cold,
        plum-falls-on-snow, lotus-seal-ground (a Field that stays up), warm-hands. `part-sect-da_quang.json`:
        cut-the-horse.
      - The depth files carry the art ids, and warm-hearth-breath is registered in `bang_tam.techniques.json`.
      - Checks: lint_arts 0 findings; lint_techniques' 4 findings are the 4 arts still to write. The unpriced W notes
        are clear-frost-breath 9.1 of 8 and warm-hearth-breath 8.6 of 8. A fight.py run (Kết Đan, typical foe:
        `$CLAUDE_JOB_DIR/tmp/bt_arts.fight.json`) went 20-0 in 45 s, and every art fired with no engine error.
- [~] 3b. Effects (11) into combat_effects.json. Done 2026-11-26: 5 of 11 that need no new word:
      - The Keeper's Stillness, Twin Plums, Second Wind on the Ice, Every Fifth a Star (approx: bypass 0.5 for "ignores
        the ward") and Sitting on the Ice.
      - Source: `design/world/depth/effects/bang_tam.effects.json`, merged by the new
        `tools/design/combat_sim/put_effects.py` (same-source rerun replaces; another source's key is refused; the
        other entries' text is kept verbatim).
      - Each one was run in fight.py with and without it, and each changed the fight.
      - Engine fix found on the way: hit events did not carry the art's `group`, in Python at all and in GDScript for
        an empowered or stepped art, so `filter.group` on `hit_landed` or `crit` missed. Fixed in engine.py `hit` and
        art_override.gd. Tests: test_engine.py `t_hit_carries_group` and fight_mechanisms_test.gd
        `test_an_empowered_arts_hit_still_carries_its_technique`, both watched failing first.
        `test_every_library_effect_compiles` now counts the world-depth Effects apart from the fixed 109.
      - Left for step 5: Ice in the Vessel, Clear-Heart Reflection, The Peak Does Not Move, Walk the Nodes, Master's
        Road, Hidden Half.
      - Note: `fight.py --timeline` crashes in sim.py (`k_water_pp`); the bug predates this work and is not fixed here.
- [x] 3c. Items (23) and sets (9). Done 2026-11-26:
      - `design/items/catalogue-sect-bang_tam.json` (23 items, sources `npc`, Effects by plain English name). The
        weapons, armour and shield carry the R6 `exception` mark.
      - `design/items/sets-bang_tam.json` (9 sets; a full-set bonus has `effect` (name) and `rule`).
      - The depth items file is kept whole, so the gap report still reads its Effect rows.
      - lint_items: 2 findings, Ice in the Vessel and Clear-Heart Reflection (step 5).
      - fight.py with the 9 sets: 5 full-set Effects run from the library; Peak, Walk the Nodes, Master's Road and
        Hidden Half are listed as not run (step 5).
      - NOT exported yet (method: export after the user's review, Stage 7), so the exporters' `--check` reports the
        game data stale until then. That is expected, and no test asserts otherwise.
- [x] 4. Stand-ins and beasts (owner's `beasts` field). Done 2026-11-26:
      - The six picks are written in the cast files (layers: trac 1, giai 2, dao 2, ma 1, quy 1, hang 6, the
        primer's top).
      - lam_tuyet_dieu carries `beasts: [ngoc_dieu, han_tich]`. The beast records stay in `bang_tam.beasts.json`
        and close at the Stage 7 export.
      - Gap report: stand-ins 0. effects 5 runs, 6 open.
      - Tool fixes: depth_check.py does not count a `catalogue-sect-*` item as a duplicate of its depth record, and
        depth_gap.py does not call a sect's own merged Effect (source `world-depth:<owner>`) a clash.
- [ ] 5. Engine words, both engines, parity. BLOCKED on review round 1 (the rulings R1-R6, W2 and W3 calls, and
      the GDD text for W1-W4).
      - Fixed before the review: Every Fifth a Star's sword scope now sits inside the `mod` (an `always` record
        ignores a record-level `filter`).
      - Five Petals' bonus moved to the fifth hit that lands, because `art_fired` fires before the art's hits.
- [x] 6. Review file, then STOP for the user. Round 1 written 2026-11-26: `production/plans/stage6/bang_tam-review.md`. WAITING for the user's answers.
- [ ] 7. Stage 7 (after approval).

## Step 1 result: the mechanic table (2026-11-26)
`spatial_words_check.py`: Băng Tâm's hits are false positives ("banner" is an item base, "beside" or "alone" sit in
tie notes, "Stillness" is a name). No art or Effect text is flagged.

**Words to build** (both engines, parity):
- **W1, a growing ward** (the frost ward). It serves six records: Heart in the Jade Vessel, Glacier Bastion, Ice in
  the Vessel, The Peak Does Not Move, Master's Road and Walk the Nodes.
  - The parts: an action that raises or grows a ward shield, a share of health (`ward_shields` in both engines);
    readables for its size now and its peak this fight or stance (as shares of maximum health); and a "release"
    action that deals what is left as damage of a type, more for each stack it consumes.
  - It already fires `ward_absorbed` and `shield_broken`. Today nothing can grow a ward shield (the `shield` action
    grows only the body bar, which fires neither event).
- **W2, a soul reflect.** Clear-Heart Mirror (art) and Clear-Heart Reflection (item). The next soul art that lands on
  you does no harm and strikes its caster as Cold damage equal to its own. `soul_hit` fires only for the attacker, and
  `reflect_first` takes any first hit.
- **W3, an afterimage.** Hidden Fragrance: an action that grants a decoy (decoys exist, R6 `avoid_budget`, but nothing
  grants one) and an event when a decoy takes the hit (2 Ice stacks on the striker).
- **W4, a live stack duration.** Master's Road: Ice stacks last twice as long while your ward holds. Today
  `stack_dur` is build-static only, and the live mod `stack_more` changes the effect, not the duration.

**Rulings needed from the user** (to put in the review file):
- **R1, a formation inside a fight.** Walk the Nodes ("inside your own formation", "regains 4 % of its strength",
  "cannot be broken") and The Peak Does Not Move ("while your diagram is laid"). The fight has a Set combat diagram
  (GDScript `Diagrams.apply_payload`, node mods and feeds) but no formation strength.
  - Proposal: "diagram laid" means fighting with a Set diagram (a readable `own.diagram`), and the formation's
    strength means your growing ward (W1).
  - Alternative: read both as your Field stance (`field_up`).
- **R2, Hidden Half.** "Your curses on it count as Ice debuffs for your stack effect" has no word; the reverse,
  `counted_curse_per`, exists. Proposal: while the foe carries your curse, your Ice stacks on it count 20 % more
  (`stack_more`, debuff side), or build a new word.
- **R3, Ice in the Vessel's out-of-fight half.** "Heart-demon odds at a breakthrough fall by a third". Proposal: a
  `tam_ma_resist_pct` line on the item, sized to a third, since `character_rules.gd` already reads it at a
  breakthrough.
- **R4, "freezes for a breath".** Rime Lotus and Plum Falls on Snow. Proposal: `stop_clock` on the foe for 1 s (Stop a
  side's clock, Effects rule 6). No new Freeze status.
- **R5, Heart in the Jade Vessel's "above half its peak".** Proposal: half of the 25 % release size (12.5 % of health),
  read from W1's size. Or build the peak readable, which W1 includes anyway.

- **R6, the signature items' own arts.** Item Database rule 20a says a named item carries "the arts its role gives
  (rule 21), authored instead of common". The depth items name none, and rule 21 is a blueprint with marked
  exceptions. Băng Tâm has 9 weapons, 4 robes or armours and 1 shield.
  - Proposal: each weapon and armour piece uses its base's common art or ward, marked with
    `exception: "world-depth signature item: the base's common art"`, and authored arts come later only where a story
    names one.
  - Alternative: author an attack art or ward per piece (about 14 here, about 300 across the world).
  - Until ruled, promote with the exception mark (reversible).

**Covered by existing words:** Frost-Breath Palm (`timer` next), Five Petals (`split`, `debuff`, an empower scaled by
Ice), Plum Falls on Snow (`empower`, `consume`), Lotus Seal Ground (a state tagged `field`, pulse `stacks`,
`slowed_time`), The Keeper's Stillness (`wounded`, `stop_clock`, `stacks`), Twin Plums (filter `group`, `crit`,
`fire_art`), Second Wind (`was_hit` + `hp_share`, `per_fight`, `hregen`, `gain_qi`, counter), Every Fifth a Star
(`status_applied` + `check_cross`, `sure_crit`, `bypass`), Sitting on the Ice (`composed_time`, `regen`, `hregen`,
`held`), The Peak's broken-shield clause (`shield_broken`, `off_guard`).

## Notes from the first read (2026-11-26)
Mechanics that look like they need an engine word or a ruling (to confirm in step 1):
- a frost ward that grows each second, and its peak (Heart in the Jade Vessel, Ice in the Vessel, The Peak Does Not
  Move);
- reflecting a soul or heart-demon art as Cold damage (Clear-Heart Mirror art, Clear-Heart Reflection); the mod key
  `reflect_first` exists, so check it;
- a freeze status ("freezes them for a breath": Rime Lotus, Plum Falls on Snow); no `freeze` in STATUS;
- formation strength regained, "cannot be broken", and "while your diagram is laid" (Walk the Nodes, The Peak Does Not
  Move); `diagram_always` is not built;
- "your curses count as Ice debuffs for your stack effect" (Hidden Half), the reverse of `counted_curse_per`;
- heart-demon odds at a breakthrough (Ice in the Vessel), outside the fight;
- possibly spatial: "walks into them", "stands inside the seal", "a Field", "afterimage".
Existing words that cover parts: `stop_clock`, `wounded`/`broken` events, `composed`/`composed_time`, `ward_absorbed`,
`shield_broken`, `off_guard`, `sure_crit`, `bypass`, `states` with `suppress` and `tags`.
