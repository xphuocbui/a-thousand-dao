#!/usr/bin/env bash
# Runs the gdUnit4 unit suites (tests/unit/**), the scripted debug-terminal smoke session,
# and (when node is installed) the line-by-line pipe check. Exit 0 only when every unit
# test passes, the smoke session exits 0 with no "SCRIPT ERROR", and the pipe check passes.
#   GODOT_CONSOLE=/path/to/godot tools/run-tests.sh [res://tests/unit/<dir or file>]
# Reports: reports/ (gdUnit4 HTML + JUnit XML, gitignored).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_CONSOLE="${GODOT_CONSOLE:-/c/Godot/Godot_v4.7.1-stable_win64_console.exe}"
cd "$ROOT"

# A fresh clone has no class cache; import first or class_name lookups fail.
"$GODOT_CONSOLE" --headless --path . --import >/dev/null 2>&1

echo "== unit tests =="
# Same flags as project.yaml's commands.test. -d turns the script debugger on (gdUnit4 then
# reports orphan-node details). --remote-debug is what keeps it from hanging: with plain -d
# an error stops at an interactive "Debugger Break" prompt forever. Port 0 is deliberate:
# it is invalid, so Godot never connects (two harmless "remote port" errors are printed),
# and it can never attach to an open editor's debugger (6007) and pause there.
# The timeout turns any other crashed-but-idle Godot into a failure.
target="${1:-res://tests/unit}"
timeout 900 "$GODOT_CONSOLE" --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 \
  res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "$target" --ignoreHeadlessMode 2>&1 \
  | sed 's/\x1b\[[0-9;]*m//g' | grep -vE "remote port number must be|Remote Debugger: Unable to connect" \
  | grep -E "FAILED|ERROR:|at '.*\.gd:|Overall Summary|Executed test cases|Exit code"
unit=${PIPESTATUS[0]}

echo "== debug terminal smoke session =="
out="$(mktemp)"
timeout 300 "$GODOT_CONSOLE" --headless --path . -s res://src/debug_terminal/terminal_main.gd -- \
  --no-llm --commands res://tests/integration/debug_terminal/smoke_commands.txt --exit-after-commands >"$out" 2>&1
smoke=$?
errors=$(grep -c "SCRIPT ERROR" "$out" || true)
echo "smoke exit $smoke, script errors $errors, $(wc -l <"$out") lines of output (kept at $out)"
grep -n -A3 "SCRIPT ERROR" "$out" | head -40

echo "== debug terminal, typed line by line =="
pipe=0
if command -v node >/dev/null 2>&1; then
  node tests/integration/debug_terminal/pipe_interactive.js "$GODOT_CONSOLE"
  pipe=$?
else
  echo "node not found: pipe check skipped"
fi

if [ "$unit" -ne 0 ] || [ "$smoke" -ne 0 ] || [ "$errors" -ne 0 ] || [ "$pipe" -ne 0 ]; then
  echo "FAILED"
  exit 1
fi
echo "ALL PASSED"
