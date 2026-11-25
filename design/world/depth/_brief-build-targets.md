# Brief: Đạo Đồ targets for tier A and B builds (world-depth pass, builds stage)

The cast's builds are loadouts: archetype, lineage methods, gear and skills, with a tree `start` and an `intent`
sentence but no Đạo Đồ targets. You give every **living tier A and B person** in your batch a real route:
`build.tree.targets`, an ordered list of node ids. The game opens the start, then the shortest route to each target
in order, one point per node, and spends any leftover points near the start
(`src/gameplay/world/cast_builds.gd`).

## Read first

1. `design/world/depth/_inputs/dao_do/README.md`: starts, points by realm and stage, and which land file to read
   for which start (Ice is in `el-thuy.md`).
2. The land files for the starts your people use (`design/world/depth/_inputs/dao_do/*.md`): every notable and
   keystone with its lines, effect, capability and distance from the start.
3. For each sect in your batch: its page `design/world/depth/sects/<key>.md` (section 5, lineage) and
   `<key>.techniques.json`, so you know what the lineage fights with: its arts' tags (cold, sword, seal, fire...)
   and passives.
4. The person: root, realm, stage, archetype, main and aux techniques, gear and items, traits (especially `path`),
   `tree.intent` and `build.note`.

## Do

1. **Sect route first.** For each sect, choose a **lineage route** of 2-4 notables or keystones near its usual start
   that its methods teach: the notables every member of that lineage takes early. Add it to the sect's
   `<key>.techniques.json` as `"lineage": {..., "tree_route": [ids], "tree_route_note": "why"}`. Outside groups have no
   sect route.
2. **Each person** (living, tier A or B, with a build and no `targets` yet):
   - **Count:** 5-9 targets for tier A, 3-6 for tier B.
   - **Order:** the sect route first if they run the lineage, then their own notables in the order they would
     take them.
   - **Fit:** the targets must express their build and story (`intent`, `note`, techniques, path traits, items).
     Elders reach deeper than disciples. A master and their disciple share part of a route, and rivals differ.
   - **Capability notables** only for Kết Đan and above. A Chaos-gated node only for a root that passes the gate.
   - **Start:** keep `tree.start` unless it is wrong (it must be an element or variant the root owns). If you change
     it, add a `changed` note.
   - Add `"targets_note": "<one line: what the route builds>"` to `tree`. Keep `intent`.
   - Six old cast members changed their start in this pass and lost their old targets: `so_ngoc_ho`, `so_han_y`,
     `ung_hac_minh`, `thai_le_tuyet`, `chau_phi_van`, `ha_thinh_tung`. Write theirs fresh if they are in your batch.
3. **Check every route** with `python -I tools/design/world/depth_tree.py route <key> <key>...`. It prints points,
   points spent, and targets reached, unreached or past the budget. Fix any that don't fit.
4. Write changes with a small Python script that loads each cast file, sets the fields and writes it back
   (`json.dump(..., ensure_ascii=False, indent=1)`). Never hand-edit large JSON. Prefix scratchpad files with your
   batch name.

## Rules

- Edit only the cast files and `*.techniques.json` of the sects or groups in your batch, and only the fields above.
  Do not touch other batches' files, `README.md`, game data, GDDs or code. Do not commit. Do not run Godot.
- Run `python -I tools/design/world/depth_check.py` at the end. It now checks routes (`tree` findings) and prints
  "builds with Đạo Đồ targets". Fix every finding in your files.
- Report briefly (under 200 words): people given targets per sect, the sect routes chosen (ids and names), any
  start changes, and the checker's final lines.
