#!/bin/bash
# Blind visual comparison of our tree with PoE 1 and PoE 2, judged by a fresh headless Claude session.
#
# usage: judge.sh <work_dir> <letter for ours> <letter for PoE 1> <letter for PoE 2> <model> <our tree.html> <trees.json>
#   e.g. judge.sh /tmp/round1 B C A opus out/tree.html poe-out/trees.json
#
# - <our tree.html> is build_tree.py's page; <trees.json> is the PoE graph file from poe_study/analyse.py (third-party
#   data: keep it outside the repo, see poe_study/README.md).
# - All three trees are drawn by tree_viewer.html in "Node kind only" mode (no element colours, no land glow), so the
#   judge compares layouts, not art. Each gets a whole view and two same-scale close-ups.
# - The judge sees only A/B/C images in its own folder (Read tool only). Rotate the letters across runs: Sonnet showed a
#   strong preference for whatever sat at B (2026-11-09), so trust only a balanced set (each tree at A, B and C once).
# - Needs Microsoft Edge for headless screenshots (EDGE overrides the path) and the `claude` CLI.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
J="$1"; O=$2; P1=$3; P2=$4; MODEL=$5; SRC="$6"; POE="$7"
EDGE="${EDGE:-/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe}"
mkdir -p "$J" "$J-view"
python -I "$HERE/poe_view.py" "$POE" "$HERE/../tree_viewer.html" "$J-view" > /dev/null
cp "$SRC" "$J-view/ours.html"
shot() {
  local W P
  W=$(cygpath -w "$J-view/$1"); P=$(cygpath -w "$J/$2")
  "$EDGE" --headless=new --disable-gpu --hide-scrollbars --window-size=1400,1400 --virtual-time-budget=6000 \
    --screenshot="$P" "file:///${W//\\//}#$3" > /dev/null 2>&1
}
shot ours.html "${O}_full.png" "big&mode=kind"
shot ours.html "${O}_zoom.png" "big&mode=kind&box=-48,-20,-12,16"
shot ours.html "${O}_mid.png" "big&mode=kind&box=30,-32,66,4"
shot poe1.html "${P1}_full.png" "big&mode=kind"
shot poe1.html "${P1}_zoom.png" "big&mode=kind&box=-34,-18,2,18"
shot poe1.html "${P1}_mid.png" "big&mode=kind&box=2,2,38,38"
shot poe2.html "${P2}_full.png" "big&mode=kind"
shot poe2.html "${P2}_zoom.png" "big&mode=kind&box=-36,-18,0,18"
shot poe2.html "${P2}_mid.png" "big&mode=kind&box=14,-6,50,30"
cd "$J" && claude -p "$(cat "$HERE/judge_prompt.md")" --model "$MODEL" --allowedTools "Read" --output-format text > "verdict_$MODEL.txt"
cat "verdict_$MODEL.txt"
