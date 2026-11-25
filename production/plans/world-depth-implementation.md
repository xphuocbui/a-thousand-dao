# World depth in the running game: plan (2026-11-25)

**Status:** PLAN. The content review and its fixes are done (below); Stage 0 is next.

**Asked:** the user, 2026-11-25: "before the implementation work, could you please first mark down the plan, then
before the plan execution, do a full review of the casts, events, builds that we did tonight, content-wise".

**Design:** the GDDs amended 2026-11-25 from the user's rulings (`design/world/depth/DECISIONS-2026-11-25.md`, groups
1-12):
- Linh Căn rule 2 and Formulas A2 / D4;
- Provinces rules 2a / 3a;
- Sects rules 3a, 19b, 20b-20d and F20-F22;
- World Generation rules 3a, 5, 5a, 6, 6a, 8a, 16, 16a and Formulas E / F / G;
- NPC Traits (v2) and its catalogue;
- Item Database rules 20f / 20g / 22 and Formulas J;
- Combat rules 25 / 26 and Formulas L; Effects rules 17-19.

The content is in `design/world/depth/` (`SUMMARY-2026-11-25.md`).

## Start here (for a new session)

1. **Read these, in order:**
   - this plan;
   - `design/world/depth/README.md` and `SUMMARY-2026-11-25.md` (what the content is);
   - `design/world/depth/DECISIONS-2026-11-25.md`, groups 1-14 (every user ruling);
   - `design/world/depth/schema.md` (record fields);
   - `design/world/depth/art/README.md` (the art method), only if you touch the art.
2. **Checkers to keep green:**
   - `python -I tools/design/world/depth_check.py` (content: roots, admission, bands, opposite traits, routes, ties);
   - `python -I tools/design/world/art_prompt_check.py` (art prompts).
3. **Commits so far (all on main, not pushed):**
   - 7a5d139f: the content and GDD amendments;
   - 4f89c796: the Phất Y rename and the builds folder;
   - 5ababc91: story pass B;
   - 4f5305a2: depth and tone;
   - 251d240e: the art prompts.

   The later art fixes are uncommitted. **Commit only your own paths** (`git commit -- <paths>`). Another session owns
   the "Formation teaching" bullet in `design/gdd/sects.md`: never stage that hunk.
4. **Do not touch** `design/world/depth/art/` or `tools/asset-pipeline/portraits/` while the paint run (started
   2026-11-25 evening in the content session) is going. Check `production/session-state/active.md` for its state.

## Where things stand (updated 2026-11-25, late)

- **Content:** 1,891 people (1,748 living) in 50 sects and 6 outside groups; 490 items in 166 sets; 180 proposed
  techniques; ~264 new dated events; 435 hand-picked Đạo Đồ routes. The content review is done (below), and
  `depth_check.py` reports no findings.
- **Keys renamed during the fixes**, so the export must use the new keys:
  - `thach_tang_danh` became `thang_vo_ta`, already changed in `assets/data` too;
  - the founder `quach_vo_tich` became `quach_linh_thu`;
  - `ta_bat_luu` became `cat_da_binh`;
  - Thải Chi's five Nghiêm herb names became `nghiem_kim_ngan`, `nghiem_bac_ha`, `nghiem_ha_kho`, `nghiem_hoi_huong`
    and `nghiem_ngu_vi`.
- **New people:** `ha_tinh_can` (Cốc Vũ, tier B) and `mac_thang_kieu` (Tùng Đào, tier C, held in Lô Niệm Ca's cellar).
  **Removed:** none.
- **Chronicle data already changed in `assets/data/world_history.json`** (user approved): A225's text, the Phất Y
  founding with no poem; and C023, Lôi Vô Danh dies of the miasma.
- **Game data otherwise unchanged:** `world_history.json` still holds the old 106 people and 54 authored builds. Only
  `world_cultivators_min` (5000) and the two chronicle texts have changed.
- **Art (DECISIONS group 14):** a portrait for every authored person (1,891) and a picture for 311 story sites,
  painted at low quality from prompts authored per person and place (`design/world/depth/art/`). The painted images
  sit outside git:
  - portraits in `tools/asset-pipeline/portraits/out/authored/<batch>/`;
  - places in `design/world/depth/art/places/out/<batch>/`.

  The review gallery is https://claude.ai/artifact/H45zDrK7quF8PusDZGKAPE. Install is Stage 2b below.

Facts checked 2026-11-25 that shape the stages:
- **Unknown technique ids are dropped silently.** `CastBuilds._learn` matches only templates in
  `items_cong_phap.json`. A build naming a proposal id learns nothing, with no error.
- **Ties.** The game's kinds are pinned (kin, su_do, ket_nghia, dao_lu, companion), soft (friend, rival, enmity), debt
  and feud, with caps of 6 ordinary and 16 notable. The content uses 25 kinds. 18 people hold more than 16 ties (up to
  28), and authored pinned ties may overflow by rule.
- **The map.** Homes point at the new seats (214, 1110, 874, 558, 449 and the minor moves), which are still ruins,
  peaks and towns in `world_continent.json`.
- **Load cost.** The world builds 54 authored builds today; it will build 1,747.
- **Rigor is `standard`.** Only critical ADRs are required. The export merge and the data-version bump are critical
  (saves, the merge with `cast_builds`), so they get one ADR.

## Stages

### Stage 0: decisions and one ADR
- **D1:** DONE. Checkpoints committed (7a5d139f and the three after it).
- **ADR-0009:** the world-depth export, covering how `design/world/depth/` folds into `world_history.json` and the
  data files, the merge with `cast_builds` (keep authored targets, add the new), the data-version bump (a save on the
  old cast is refused), and the stand-in rule for uncatalogued techniques.
- **D2:** the interim technique mapping. Until the catalogue pass, a proposal technique becomes its generated stand-in
  `<hoang|huyen|dia|thien>_<element>` by tier and first element, and its arts are absent. Ask the user whether builds
  may ship that way into a playable world.

### Stage 1: structure what the export needs (tools only)
- Extract the 264 `N-` events from the sect pages into structured JSON (id, year, kind, tier, people, place, text).
  This also feeds the review's timeline check.
- A machine-readable table of the final seat and leans per sect (World Generation OQ 12). Add Formula F on the final
  seats, with the Wind exemption, to `depth_check.py`.
- A tie-kind mapping table from 25 kinds to the game's kinds (kin covers parent, child, sibling, cousin, grandparent,
  grandchild, aunt_uncle, niece_nephew, in_law, ancestor and descendant; su_do covers master, disciple and the former
  pair; ket_nghia covers sworn_sibling; dao_lu covers dao_partner and spouse; lover is soft). Overflow is checked
  against rule 5's authored exception.
- The trait trim for over-band people (NPC Traits rule 2a): 30 people, 36 traits.
- Fields added by the content fixes that the export must carry:
  - `appearance` for every tier;
  - `wants` and `secret` for tier B;
  - talent flaws (with `thien_phu` to match);
  - a `beasts` list on tamers, with records in `**/*.beasts.json`;
  - `changed` notes, which are design-only and not exported.
- Over-band people grew in pass C: about 21 tier B and 20 tier C sit one trait over their band, which the export trims.

### Stage 2: the map (seats move)
- `world_continent.json`: each moved seat place becomes `great_seat` / `minor_seat` with the sect's key. The old seat
  becomes the kind its page names. Routes to the new seats. `seat_array_density` on the new seats. Province seat
  records (Provinces rule 2a). Place lore lines.
- Code effects named by the provinces session: `ProvinceBuildings.payer` and `place_start`'s seat-province test (Provinces
  OQ 11). Re-run the starting-level census.
- Art: moved seats show PlaceholderArt until painted (memory rule; low quality by default when painted).

### Stage 2b: install the authored art (after the user reviews the gallery)
- **Portraits.**
  - Copy each `out/authored/<batch>/<key>.png` to `assets/portraits/cast/<key>.webp` at 400x600, as
    `gen_portraits.install` does.
  - The 10 pilot people use `out/authored/pilot/<key>.png`; this replaces the old 88 cast portraits too.
  - Then rebuild `assets/portraits/portraits.json`, whose `cast` list must hold every authored key.
  - A key without a picture keeps PlaceholderArt (memory rule).
- **Places.**
  - Copy each `places/out/<batch>/paint_<id>.png` to `assets/art/places/<id>.webp`, the window banner, at 1536x864
    for seats and 960x540 for the rest (as `tools/asset-pipeline/places/install_place_paintings.py` does).
  - Replace the old 254 banners.
  - The map's miniatures (`assets/map/places/`) are NOT changed.
- **Check:** open the character window and a sect window, and keep screenshots in `production/qa/evidence/`
  (run-and-observe). Measure the import size; 1,891 webp portraits come to about 60 MB.
- **Open:** batch p07 has 41 flagged portraits the user may want fixed and repainted, for about $0.40 (ask). Retry
  any refused or failed images from the paint logs.

### Stage 3: one sect end to end (Băng Tâm Các)
- `tools/design/world/export_world.py` reads `design/world/depth/` for one sect: people, merged builds, lineage,
  items, sets, events and ties (mapped), and writes `world_history.json` plus the item, set and technique stand-ins.
- Load the world, open the sect window and person cards, and keep a screenshot in `production/qa/evidence/`
  (run-and-observe).
- Measure world build time with this sect.

### Stage 4: everyone
- Export the other 49 sects and the 6 groups. Measure world build time with all 1,747 authored builds; budget and
  optimise if needed.
- The census: realm counts against the targets (5,000 world), sect sizes, the admission pass rates.

### Stage 5: roots and admission in code
- Linh Căn: the weighted Fisher-Yates, the purity shift, the variant boost (Formulas A2, D4). The map export writes
  province `land_qi`, `variant_max` and `land_element_means` (Provinces rule 3a).
- World Generation rule 8a: birthplace, the land roll, Sects admission (F20), intake (F21), no-lean sects.
- Living World Tick: births read the mother's home province.
- Golden tests: even land equals the old roll (AC-LC-59). The world-totals AC is AC-LC-66.

### Stage 6: traits v2 in code
- `traits.json` gets the new kinds. NpcTraits: roll, inherit with talent drift, likes and dislikes in opinion (F3),
  doubled personality rows, the 15 choice-weighted v2 traits, the talent grade display (the character sheet's C3).
- Dialogue verbs (#30) are the first `opens` consumer: a separate plan.

### Stage 7: item sets in code
- `items_sets.json`. The set bonus is counted on worn pieces (Item DB rule 22). The 2-piece Modifiers compile now.
  Full-set Effects compile where their hooks exist; the rest are flagged as engine wishes.
- Repair the item lint (it imports the removed Đạo Đồ editor) and lint the 490 items.

### Stage 8: combat readings in code
- The fight engine: ally, alone, foe_moved, still, moving, displace with planted, rooted with pinned, at_range,
  broken and wounded (Combat rule 25, Formulas L). Remove the `own_abode` and `vein` fight bonuses (rule 26; AC-CB-104).
- The 24 engine wishes (`design/world/depth/builds/engine-wishes.md`) are their own backlog.

### Stage 9: the catalogue pass and balance
- Price and lint the 180 proposal techniques and their arts (records, not concepts), then swap the stand-ins for the
  real ids.
- Fight-test the authored builds against Power Rankings' bands. Re-check Realms' calibration with the land roll
  (Linh Căn OQ 16).
- The one design review over everything (the user's rule: one pass at the end).

## Before Stage 0: the content review (DONE 2026-11-25)

Review: `design/world/depth/review/RANKED.md`. The user chose to fix all groups but the voice pass. Commits:
- 7a5d139f: the checkpoint and sweep A;
- 4f89c796: the Phất Y rename and the builds folder;
- 5ababc91: story pass B;
- 4f5305a2: depth and tone passes C and C2.

The checker is clean. Content after the fixes: 1,891 people; 41 % carry a dark trait, each with a deed; tier B has
wants and secrets; tier C has looks.

## Risks

- **Load time** with 1,747 authored builds (Stage 3 measures one sect, Stage 4 all of them).
- **Silent technique drops** until the stand-in mapping is in the export (Stage 0, D2).
- **Ties over the caps** for 18 people. The authored overflow rule covers pinned ties; soft ties beyond the cap are
  trimmed by weight.
- **Saves:** the data-version bump refuses old saves (pre-release, development saves only).
- **Other sessions:** the formations session owns `formations.md` and the uncommitted sects.md bullet; the provinces
  session owns the provinces runtime code.
