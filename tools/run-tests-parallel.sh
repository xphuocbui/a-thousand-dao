#!/usr/bin/env bash
# Runs the gdUnit4 suites in parallel: one Godot process per test group (tests/unit/<dir>, tests/integration/<dir>,
# tests/parity), up to JOBS at a time, each with its own report folder. Prints each group's summary and the failures,
# and exits 0 only when every group passes. The serial runner (tools/run-tests.sh) stays for the smoke session.
#   JOBS=10 GODOT_CONSOLE=/path/to/godot tools/run-tests-parallel.sh
# A group that only passes after another group ran (shared test state) shows up here as a failure: that is a test
# isolation bug to fix, not a reason to run serially.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_CONSOLE="${GODOT_CONSOLE:-/c/Godot/Godot_v4.7.1-stable_win64_console.exe}"
JOBS="${JOBS:-10}"
cd "$ROOT"
"$GODOT_CONSOLE" --headless --path . --import >/dev/null 2>&1

OUT="$(mktemp -d)"
groups=()
for d in tests/unit/*/ tests/integration/*/ tests/parity/; do
  [ -d "$d" ] && groups+=("${d%/}")
done

run_group() {
  local g="$1" name
  name="$(echo "$g" | tr '/' '_')"
  # Same flags as the serial runner; -rd gives each process its own report folder.
  timeout 2400 "$GODOT_CONSOLE" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 \
    res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://$g" -rd "reports/parallel/$name" --ignoreHeadlessMode \
    >"$OUT/$name.log" 2>&1
  echo $? >"$OUT/$name.code"
}

start=$(date +%s)
running=0
for g in "${groups[@]}"; do
  run_group "$g" &
  running=$((running + 1))
  if [ "$running" -ge "$JOBS" ]; then
    wait -n
    running=$((running - 1))
  fi
done
wait

fail=0
total=0
for g in "${groups[@]}"; do
  name="$(echo "$g" | tr '/' '_')"
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
    echo "ok      $g  ($n cases)"
  fi
done
echo "== $total test cases in ${#groups[@]} groups, $(( $(date +%s) - start )) s, logs in $OUT =="
exit $fail
