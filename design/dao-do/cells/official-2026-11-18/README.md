# Đạo Đồ official version, 2026-11-18

The user called this "the best version yet" and asked to keep it as the official tree (2026-11-18), after the
consolidation pass (groups of small pieces merged into medium and big figures).

- `dao-do-map.json`: the compiled tree. 4,651 nodes (1,116 notables, 10 keystones, 11 starts), 606 hand-placed pieces.
  0 crossings, only the base map's own 4 spacing warnings, all pieces pass R0-R4 (rules-2026-11-18.md 3.2).
  Size mix of the lands' pieces, small / medium / big: 54 / 31 / 15 % (PoE 2 about 50 / 33 / 14).
- `source/`: the cell files that build it, frozen: `cell14.py`, `cell93.py`, `borders.py`, `lands/*.py`. Rebuild from
  the repo root with `sh tools/design/dao_do_rework/cells/check_land.sh <tag> source/cell14.py source/cell93.py
  source/lands/fire.py source/lands/earth.py source/lands/metal.py source/lands/water.py source/lands/wood.py
  source/borders.py` (paths under this folder); the output matches `dao-do-map.json` byte for byte (checked).
- `whole.png`, `<land>.png`: renders. `tree.svg`: the vector drawing used by the zoomable viewer.
- `SHA256SUMS`: hashes of the map and the source files as saved.

The working files in `design/dao-do/cells/` (`cell14.py`, `cell93.py`, `borders.py`, `lands/`) are identical to
`source/` on this date and may change after it; this folder does not.

Known weak spots, not yet decided by the user: Fire's freehand figures, Water's creature figures and straight spikes,
Earth's low density (0.18 nodes per unit²), Metal's figure functions reused up to 3 times, Wood's bare rim edges.

- 2026-11-19: `base-map.json` here is the base map this version was built on. The shared design/dao-do/cells/base-map.json
  later lost the ten keystone spur nodes (keystones folded onto their roads), so rebuild this version against this copy.
