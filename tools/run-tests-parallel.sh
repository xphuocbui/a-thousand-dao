#!/usr/bin/env bash
# Runs the gdUnit4 suites in parallel and exits 0 only when every one passes. The serial runner (tools/run-tests.sh)
# stays for the smoke session.
#   JOBS=10 tools/run-tests-parallel.sh                 every *_test.gd its own Godot process, slowest first
#   ONLY="tests/unit/session tests/unit/ui" JOBS=6 tools/run-tests-parallel.sh   a subset (folders or files)
#   SPLIT=0 tools/run-tests-parallel.sh                 the old way: one process per folder (tests/unit/<dir>, ...)
# Balance (2026-11-26, user: "some finished too early and some took too long"): one process per test FILE, started
# longest first by the times of the last run (reports/test-times.tsv; a file with no time yet starts first), so no
# single big folder holds the run open while the other slots sit idle (longest-processing-time first scheduling).
# A file that only passes after another file ran (shared test state) shows up here as a failure: that is a test
# isolation bug to fix, not a reason to run serially.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_CONSOLE="${GODOT_CONSOLE:-/c/Godot/Godot_v4.7.1-stable_win64_console.exe}"
JOBS="${JOBS:-10}"   # user 2026-11-26: 8-10 workers now that the files are balanced
SPLIT="${SPLIT:-1}"
TIMES="$ROOT/reports/test-times.tsv"
cd "$ROOT"
"$GODOT_CONSOLE" --headless --path . --import >/dev/null 2>&1

OUT="$(mktemp -d)"
units=()
if [ -n "${ONLY:-}" ]; then
  for d in $ONLY; do
    if [ "$SPLIT" = 1 ] && [ -d "$d" ]; then
      while IFS= read -r f; do units+=("$f"); done < <(find "${d%/}" -name "*_test.gd" | sort)
    else
      units+=("${d%/}")
    fi
  done
elif [ "$SPLIT" = 1 ]; then
  while IFS= read -r f; do units+=("$f"); done < <(find tests/unit tests/integration tests/parity -name "*_test.gd" | sort)
else
  for d in tests/unit/*/ tests/integration/*/ tests/parity/; do
    [ -d "$d" ] && units+=("${d%/}")
  done
fi

# Slowest first: the last run's seconds per unit; units with no time yet go first (assume they are slow).
order() {
  local u t
  for u in "${units[@]}"; do
    t=""
    [ -f "$TIMES" ] && t="$(awk -F'\t' -v k="$u" '$1 == k { print $2 }' "$TIMES" | tail -1)"
    printf '%s\t%s\n' "${t:-999999}" "$u"
  done | sort -t$'\t' -k1,1nr | cut -f2
}
mapfile -t units < <(order)

run_unit() {
  local g="$1" name t0
  name="$(echo "$g" | tr '/.' '__')"
  t0=$(date +%s)
  # Same flags as the serial runner; -rd gives each process its own report folder.
  timeout 2400 "$GODOT_CONSOLE" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 \
    res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://$g" -rd "reports/parallel/$name" --ignoreHeadlessMode \
    >"$OUT/$name.log" 2>&1
  echo $? >"$OUT/$name.code"
  echo $(( $(date +%s) - t0 )) >"$OUT/$name.secs"
}

start=$(date +%s)
running=0
for g in "${units[@]}"; do
  run_unit "$g" &
  running=$((running + 1))
  if [ "$running" -ge "$JOBS" ]; then
    wait -n
    running=$((running - 1))
  fi
done
wait

fail=0
total=0
slow=""
mkdir -p "$(dirname "$TIMES")"
newtimes="$(mktemp)"
[ -f "$TIMES" ] && cp "$TIMES" "$newtimes"
for g in "${units[@]}"; do
  name="$(echo "$g" | tr '/.' '__')"
  secs="$(cat "$OUT/$name.secs" 2>/dev/null || echo 0)"
  awk -F'\t' -v k="$g" '$1 != k' "$newtimes" >"$newtimes.tmp" && mv "$newtimes.tmp" "$newtimes"
  printf '%s\t%s\n' "$g" "$secs" >>"$newtimes"
  summary="$(sed 's/\x1b\[[0-9;]*m//g' "$OUT/$name.log" | grep -E "Overall Summary" | tail -1)"
  n="$(echo "$summary" | sed -nE 's/.*Overall Summary: ([0-9]+) test cases.*/\1/p')"
  total=$((total + ${n:-0}))
  if grep -q "No test cases found" "$OUT/$name.log"; then
    echo "skip    $g  (no gdUnit tests: a script folder, run by tools/run-tests.sh)"
    continue
  fi
  if ! echo "$summary" | grep -q "0 errors | 0 failures"; then
    fail=1
    echo "FAILED  $g  ${summary:-no summary (crashed or timed out)}"
    sed 's/\x1b\[[0-9;]*m//g' "$OUT/$name.log" | grep -E " FAILED|^  [^r].*expected|SCRIPT ERROR|Parse Error" | head -20
  else
    echo "ok      $g  ($n cases, ${secs} s)"
  fi
done
mv "$newtimes" "$TIMES"
slowest="$(sort -t$'\t' -k2,2nr "$TIMES" | head -3 | awk -F'\t' '{ printf "%s %ss; ", $1, $2 }')"
echo "== $total test cases in ${#units[@]} processes at JOBS=$JOBS, $(( $(date +%s) - start )) s; slowest: ${slowest}logs in $OUT =="
exit $fail
