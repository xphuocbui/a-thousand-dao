# Đạo Đồ layout edits (2026-11-20)

`design/dao-do/layout/v5-layout-2026-11-20.json` holds the layout edits on top of the frozen v5 map; the export
(`tools/design/dao_do_rework/content/export_game.py`) applies it when it writes `assets/data/dao_do_map.json`. The
frozen map and its content stay the design source.

The edits were made in the tree viewer first, on a scratch copy of the frozen map, with these scripts (kept for
provenance and to redo the steps; they never write repo files):

| Script | Step |
|---|---|
| `scale_islands.py <repo> <scale> <out>` | the four islands (Sun, Moon, Shadow Shrine, Thunder) scaled about their centres and moved outward so their inner edge stays (scale 1.6) |
| (inline, see the layout file's `lotus`) | the Moon lotus (cluster 9782) scaled 1.5x and lifted 2 units; its two lines to the crescent cut from 6 to 3 small nodes each (6 node ids removed) |
| `grow_pieces.py <repo> <scratch>` | crowded pieces scaled about their road entry just enough to clear (51 pieces) |
| (inline) | 85 nodes nudged away from the node they touched (median 0.13, max 0.60 units) |
| `hand_sheet.py <repo> <scratch> <out.jpg>` | contact sheet of the pieces left for hand work, overlaps in red |

Road nodes 637 and 667 (the bridges from the ring to the Moon horns) were then placed by hand at (±35.08, -116.5) so
no link crosses (export check). The export's checks after the edits: crossings 0, too close 0, grazing 0, unreached 0.
