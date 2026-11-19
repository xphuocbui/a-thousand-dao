#!/bin/sh
# usage (repo root): sh design/dao-do/cells/openai/check.sh <tag> <oai files...>  -- the v2 tree with the given files in place of islands.py / chaos.py
D=design/dao-do/cells; T=tools/design/dao_do_rework/cells; TAG=$1; shift
sh $T/check_land.sh $TAG $D/cell14.py $D/cell93.py $D/lands/fire.py $D/lands/earth.py $D/lands/metal.py $D/lands/water.py $D/lands/wood.py $D/borders.py "$@" | grep -v "nodes per cell"
