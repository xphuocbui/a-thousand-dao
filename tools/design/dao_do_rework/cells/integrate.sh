#!/bin/sh
# usage: sh tools/design/dao_do_rework/cells/integrate.sh [tag]   (run from the repo root)
#   compiles the whole current Đạo Đồ tree onto design/dao-do/cells/base-map.json: cells 14 and 93, the five land files,
#   the borders, Chaos (the purple swirl and the five element motifs round the hub, traced), the islands (Sun, Moon, the Shadow Shrine, Thunder, traced from the underlays the user picked),
#   the rim pagoda (OpenAI's) and the island keystones; checks the union, renders the whole tree and each land into
#   design/dao-do/cells/out/. Report only. (2026-11-19: islands.py and chaos.py are the earlier versions, not compiled.)
T=tools/design/dao_do_rework/cells; D=design/dao-do/cells; O=$D/out
TAG=${1:-tree}
sh "$T/check_land.sh" "$TAG" "$D/cell14.py" "$D/cell93.py" "$D/lands/fire.py" "$D/lands/earth.py" "$D/lands/metal.py" "$D/lands/water.py" "$D/lands/wood.py" "$D/borders.py" "$D/sun_trace.py" "$D/moon_trace.py" "$D/shrine_trace.py" "$D/thunder_trace.py" "$D/chaos_swirl.py" "$D/chaos_elements.py" "$D/openai/pagoda/oai_pagoda2.py" "$D/keystones_islands.py"
python -I "$T/colour_links.py" "$O/$TAG-map.json"        # link colours from the pictures, for the viewer
python -I "$T/render_tree.py" "$O/$TAG-map.json" "$O/$TAG-whole.png" 2400
for L in fire earth metal water wood; do python -I "$T/render_land.py" "$O/$TAG-map.json" $L "$O/$TAG-$L.png" 11 >/dev/null; done
python -I -c "
import json, collections; M=json.load(open(r'$O/$TAG-map.json', encoding='utf-8'))
k=collections.Counter(n['kind'] for n in M['nodes']); print('kinds', dict(k), 'total', len(M['nodes']))"
