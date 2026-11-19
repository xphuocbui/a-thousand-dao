#!/bin/sh
# quick try (repo root): sh design/dao-do/cells/openai/ul_try.sh <tag> <file.py> <cells> <cx> <cy> <half>
D=design/dao-do/cells; T=tools/design/dao_do_rework/cells; O=$D/out
python -I $T/celllib.py $D/openai/context-map.json $O/$1-map.json $2 | tail -1 && python -I $D/openai/oai_check.py $O/$1-map.json $3 && python -I $T/render_box.py $O/$1-map.json $O/$1.png $4 $5 $6 1100 --ids
