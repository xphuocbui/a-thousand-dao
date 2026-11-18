# Đạo Đồ viewer

Builds the interactive Đạo Đồ page from the generated map.

1. Export the graph next to the builder:
   `godot --headless --path . -s res://tools/balance/export_tree.gd -- tools/dao-do/dao-do.json`
2. Lay it out and fill the page: `node tools/dao-do/build.js`

The builder prints crossings, clearance and edge lengths, and writes `dao-do.html`. A layout
is good when it reports 0 crossings and 0 Dao marks too close to an edge. If it does not, try
another layout seed with `MAP_SEED=<n>`. `dao-do.json` and `dao-do.html` are outputs.
