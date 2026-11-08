# PoE passive tree study scripts

These scripts back the measurements in `design/research/passive-tree-study.md`. Every script takes its data
paths as arguments. The PoE 1 `data.json` and PoE 2 `tree.json` exports are third-party data and are **not**
kept in this repo. Download them yourself, put them in their own empty folder, and run the scripts with `-I`:

| Script | What it does |
|---|---|
| `analyse.py <poe1> <poe2> <out> [ours]` | Turns both trees into one graph form, writes `trees.json` and `metrics.json` (findings 1–22) |
| `themes.py <poe1> <poe2> <ours json> <ours html> <out>` | Gives each cluster a theme (mastery names in PoE 1, stat text in PoE 2) and measures where themes sit |
| `patch_themes.py`, `themetab.js` | Add the "Where a theme sits" mode to the survey page |
| `build_page.py <template> <out_dir> <page>` | Builds the survey page from `template.html` (with `clusters_section.html`) and the JSON |
| `crop.py`, `crop2.py <1\|2> <tree> <out.html> <radius> <targets>` | Close-up SVG crops around named nodes or class starts |
| `study3.py <poe1> <poe2>` | Third pass: joins to the nearest node, small nodes before a notable, start webs (findings 23–26) |
| `audit.py <poe1> <poe2> <out>` | Cluster shape audit: writes `audit.json` and `gallery.html` |
| `audit2.py <poe1> <poe2>` | Clusters per road node, cluster size by distance from the centre, small clusters beside big ones (findings 27–29) |
| `shape_page.py` | Turns `audit/gallery.html` into the readable shape-audit page that `regions/pens.py` was drawn from |

How to author a land with these findings: `design/research/meridian-land-authoring.md`.
