# Stage 6: Băng Tâm Các (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method" (user-approved 2026-11-26).
Resume here: read this file, then do the first unchecked step.

## User rulings for this sect (2026-11-26)
- Commit after every unit, own paths only.
- Stand-ins as proposed (table below). hang_minh_sa's method (Dạ Quang's `red-sand-sabre-primer`) is promoted early
  with this sect, per the method's step 4, so Băng Tâm's gap reaches zero.
- Review format: `production/plans/stage6/bang_tam-review.md`, each rule beside its engine form.

- After this sect: the other sects run as headless Opus jobs with Fable as the advisor, three in parallel, via
  `tools/headless/run_jobs.py` (plan Stage 6). Băng Tâm's pass is the template for their brief.
- **From 2026-11-26 (user): decisions are auto-accepted.** Take the recommended option, thought through against the
  design philosophy, and log it in the review file. This applies to the rest of Băng Tâm too.
- GDD texts (2026-11-26): W1 grow, hold and release a ward (c14985d9); W2 soul reflect and `soul_taken` (a108d9f3);
  W3 `decoy_struck` and `decoy {n}` (user-approved); W4 needs no GDD text (a conditional modifier, rule 8). Item
  Database rule 20f: signature items always unique, and arts by role use the base's common art (auto-accepted,
  following the user's rulings). Stage 7 must carry `unique: true` into items_named.json and make the game honour it.

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
- [x] 5. Engine words, both engines, parity. DONE 2026-11-26 (978ab58c). Earlier notes: The rulings are ANSWERED (2026-11-26: every recommendation, see
      DECISIONS-2026-11-26.md "Stage 6, Băng Tâm Các review round 1"). Next:
      - (a) show the user the GDD text for W1-W4 (Effects rule 6), section by section;
      - (b) show the rule 20f amendment (signature items unique);
      - (c) build W1-W4 in both engines with parity. **Python DONE 2026-11-26:**
        - engine.py: the stance ward (`sward`, `sward_peak`), soaked after the ward shields;
        - the actions `ward_grow`, `release_ward` and `decoy`; the mods `ward_fixed`, `soul_reflect` (charges, in the
          `mod` verb) and `stack_dur` (read in `add_stacks`);
        - the events `soul_taken` and `decoy_struck`; the readables `own.ward_share` and `own.ward_peak`;
        - the vocabulary in `combat_engine.json`; tests `t_stance_ward`, `t_soul_reflect`, `t_decoy_struck` and
          `t_live_stack_dur`.

        **NEXT: GDScript** (`fight.gd` defend and soul hit, `effect_runner.gd` actions, `fighter_state.gd`, the read
        function), then GdUnit twins and a parity fixture (t25).
      - (d) write the 4 arts and 6 Effects: Walk the Nodes and the Peak use `field_up`, Hidden Half uses `stack_more`
        20 % while cursed, and Ice in the Vessel gets a `tam_ma_resist_pct` line;
      - (e) run the gap report, then review round 2 on those records.
      - Fixed before the review: Every Fifth a Star's sword scope now sits inside the `mod` (an `always` record
        ignores a record-level `filter`).
      - Five Petals' bonus moved to the fifth hit that lands, because `art_fired` fires before the art's hits.
- [x] 6. Review file, then STOP for the user. Round 1 written and answered 2026-11-26 (`production/plans/stage6/bang_tam-review.md`).
- [x] 6b. Review round 2, logged under the auto-accept rule (in the review file).
- [x] 6c. Holder check (advisor, 2026-11-26): fight files from the actual cast builds
      (`$CLAUDE_JOB_DIR/tmp/cast_fight.py` and `probe.py`, which counts each Effect's runs). Fixed:
      - The Vessel and Lotus Seal shared the one stance slot, so they kept overwriting each other. A sealed Vessel
        (`jade-vessel-sealed`, Composed and Field together) now joins them for Cố and Tiết. After the fix, The Peak
        and Walk the Nodes give 69 % against 39 % and 62 % against 43 % health left.
      - Master's Road's "your ward holds" covers the main ward too (Sở Hàn Y has no stance ward).
      - Every Fifth a Star was spent by the sub-hit that armed it. It is now spent on the crit it grants: 98 sure
        crits against 16, and 28.0 s down to 25.7 s.
      - The rest are expected no-ops against a typical foe: Ice in the Vessel, Second Wind and Sitting on the Ice need
        damage taken, or a pause.
      - R2's refinement (stack_grant +1 while cursed) was CONFIRMED by the user ("keep it", 2026-11-26).
- [ ] 7. Stage 7, next. Advisor order:
      - (a) the full suite and full parity --check (launched 2026-11-26; logs `$CLAUDE_JOB_DIR/tmp/full_suite.log` and
        `parity_full.log`);
      - (b) export `combat_library.json`, then add a Băng Tâm build to the compile-parity cases and one exact fixture
        that uses the library arts (the 10 arts have not run in GDScript yet);
      - (c) DONE 2026-11-26. `WorldBuilder` runs `_step_cast` before `_step_named_items`. A holder's authored gear
        makes the item first, and `named_available` then keeps the random rule 20d placement from making a second.
        A holder not yet in the world (Red Plum's, Phượng Minh) falls back to that placement until their sect's pass.
        `unique: true` is on the 23 records, carried by `export_named.py` and honoured by `ItemFactory.is_unique`
        (test `named_items_test.gd`, watched failing first); the rule 20f Counts line is fixed. The original note was:
        check how world generation places unique named items (rule 20d: a Kết Đan+ NPC or Lost). The authored
        `holder` must win, with a fallback for a holder not yet in the world (Red Plum's holder is Phượng Minh's), and
        rule 20f's Counts bullet needs fixing;
      - (d) dry-run `export_world.py --sect bang_tam --check` for missing ids;
      - (e) Đạo Đồ targets: reuse the `cast_builds` shape;
      - (f) commit the record exports and the world export together.

      The work itself:
      - export the records: `export_techniques.py`, `export_named.py` (with `unique: true` carried and honoured) and
        `export_combat_library.py`;
      - `export_world.py --sect bang_tam`: the depth reader (people, merged builds, lineage, beasts, events, ties mapped
        by `TIE_MAP`, the trait trim, `world_data_version`);
      - load the world, open the sect window and the person cards, and fight one authored build. Screenshots go in
        `production/qa/evidence/world-depth-stage7/`; warn the user before the Godot windows;
      - measure the world build time;
      - confirm the gap report reads zero for the sect.

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


## Stage 7 plan for Băng Tâm (written 2026-11-26, before starting)
`export_world.py` has **no depth reader yet**: it reads `design/world/*_proposal.json` and
`design/world/cast_builds.json` only. ADR-0009 decision 5 and the Key Interfaces define the reader. Units, each
committed:
1. **Record exports.** Run `export_techniques.py`, `export_named.py` (items_named and items_sets) and
   `export_combat_library.py`, then `compile_parity_export.py` (it deals every library art and named item into
   cases). Add a parity fixture t26 generated from co_lang_suong's resolved build (fight.py expand_library + to_build,
   `dataclasses.asdict`), using the sealed Vessel, Glacier Bastion and Lotus Seal. Run parity, the compile parity and
   the combat GdUnit group.
2. **The depth reader** in `export_world.py` behind `--sect <key>`. For one sect it builds:
   - the people from the `design/world/depth/sects/<key>*.cast.json` files. The depth record wins on every field it
     carries; old fields are kept; `changed` notes are dropped. People of other sects stay from the old cast; the 18
     fallen-sect people stay;
   - the builds from depth `build`, `root`, `thien_phu` and `stage`, in the `cast_builds` shape. Đạo Đồ targets reuse
     that shape (`tree.targets`). Tier C people with no `thien_phu` are rolled by the builder;
   - the lineage from `<key>.techniques.json` `lineage`;
   - the beasts from `<key>.beasts.json`, into world_history `beasts`, with `WorldBuilder` reading them as people with
     `owner_id`;
   - the events from `design/world/depth/events/<key>.events.json`, merged into `events`;
   - the ties, mapped by depth_gap's `TIE_MAP`. Cap 16; soft ties beyond it trimmed by weight; pinned ones kept
     (on_sa_ngoc has 17 partners);
   - the trait trim (NPC Traits rule 2a's order);
   - `world_data_version` 1 (an int); `data_version` also hashes `design/world/depth/`.

   Run `--check` first, as a dry run for missing ids.
3. **Game side.**
   - `GameSession.load_dict` refuses a save with another `world_data_version`;
   - `CastBuilds._learn` warns on an unknown id;
   - `WorldBuilder` reads `beasts`.

   Each gets a unit test (ADR-0009 Implementation Guidelines).
4. **Load and look.** Warn the user first, then use `--shots` and the cached test world. Open the sect window and
   person cards (Sở Ngọc Hồ, Cố Lăng Sương), and fight one authored build. Screenshots go in
   `production/qa/evidence/world-depth-stage7/`. Measure the world build time.
5. **Gap report** `--sect bang_tam`: zero open. The full suite and the full parity check before the last commit.

### Stage 7 unit 2 design (2026-11-26)
- Unit 1 is DONE (d489875e): the records are exported, t26 parity passes, and the 70 compile cases pass.
- **world_history additions:** `world_data_version: 1`, `beasts: [...]`, `ties: [...]`. `people` and `cast_builds`
  are merged for the exported sects.
- **Ties format:** `{"a": key, "b": key, "kind": <game kind>, "s": <start strength>, "dir": "a_to_b"}`. Mapping is by
  depth_gap `TIE_MAP`; one record per pair, the strongest kind wins. The writers:
  - kin, ket_nghia and dao_lu: `Ties.add_pinned(..., authored=true)`;
  - su_do: `Ties.set_master(disciple, master)`, the current pair only;
  - friend (40), lover (friend, 70), rival (40) and enmity (50): `Ties.write_soft(holder=a, other=b, kind, delta=s)`;
  - former master or disciple: soft friend 30; rival or enmity when the note says they parted badly (a keyword
    list, each one logged);
  - feud: `Ties.set_feud`; debt: `Ties.write_debt`.

  A tie whose other person is not in the world is skipped and reported, and comes with its sect in Stage 8. Over the
  cap of 16: pinned ties are kept, soft ones are kept by strength.
- **People:** a depth record merges over the old one (or is new). The game reads key, name (from `name_hv`),
  name_han, gloss, sex, born, alive, sect, rank, role, realm, home (a place id), the traits (personality, calling,
  fate_given; v2 kinds wait for Stage 10), master, and peak_realm, died and cause when dead. It also carries tier,
  stage, appearance, wants, secret and beasts; `changed` is dropped.
- **Builds:** the depth `build` mapped into the `cast_builds` shape: root, thien_phu (tier C has none, so the builder
  rolls it), archetype, stage, main, aux, gear, skills, and tree {start, targets}.
- **Beasts:** the `<key>.beasts.json` records as given. `WorldBuilder` makes each a people record with `is_beast`,
  `owner_id` and `loyalty`, and the owner lists its id.

### Stage 7 progress (2026-11-26)
- Unit 2, the depth reader, is WRITTEN: `tools/design/world/depth_export.py`, called by `export_world.py --sect <key|all>`.
  - Dry run `--check --sect bang_tam`: 0 failures; 220 people (187 living), 693 events, 136 ties, 2 beasts.
  - Observations: 48 ties name people of sects not exported yet; 20 old-cast members have no build (true before this
    work too). Lãnh Hương Các (fallen in 724, not a game sect) leaves pho_thanh_mai's record with no sect key.
  - A plain export without `--sect` differs from the committed file only in the new keys and `data_version`.
  - NOT written to assets yet: the full suite was running (`$CLAUDE_JOB_DIR/tmp/full_suite2.log`).
- Unit 3, game side, is WRITTEN, not yet run:
  - `WorldBuilder._step_beasts` and `_step_ties`, and `w_meta.world_data_version`;
  - the `GameSession.load_dict` refusal;
  - `CastBuilds._learn` reports unknown ids (`unknown_ids`, push_warning);
  - `NpcTraits.from_authored` reads `gained`;
  - test `tests/unit/world/world_depth_export_test.gd`.
- NEXT:
  1. `python -I tools/design/world/export_world.py --sect bang_tam`;
  2. run the new test and the world group;
  3. commit units 2 and 3;
  4. warn the user, then the screenshots (unit 4).
- Auto-accepted:
  - only the v1 trait kinds are exported (personality, calling, fate_given, gained), so the rule 2a trim of the v2
    kinds waits for Stage 10;
  - former pairs read rival or enmity from keywords in the tie note;
  - soft start strengths: friend 40, lover 70, rival 40, enmity 50, former 30, debt 30.

