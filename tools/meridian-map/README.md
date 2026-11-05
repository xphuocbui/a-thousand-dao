# Meridian map viewer

Builds the interactive Kinh Mạch Đồ page from the generated map.

1. Export the graph next to the builder:
   `godot --headless --path . -s res://tools/balance/export_tree.gd -- tools/meridian-map/meridian.json`
2. Lay it out and fill the page: `node tools/meridian-map/build.js`

The builder prints crossings, clearance and edge lengths, and writes `meridian-map.html`. A layout
is good when it reports 0 crossings and 0 acupoints too close to an edge. If it does not, try
another layout seed with `MAP_SEED=<n>`. `meridian.json` and `meridian-map.html` are outputs.
