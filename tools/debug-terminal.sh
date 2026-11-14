#!/usr/bin/env bash
# Ten Thousand Daos - debug terminal (Git Bash / Linux / macOS).
# Runs the RELEASE build (build/bench/combat_bench.console.exe --terminal): Power Rankings fights are several times
# faster there than in the editor's debug binary. It is re-exported first (about a minute) whenever src/, assets/data/
# or project.godot changed since the last export.
#   DEBUG_TERMINAL_EDITOR=1 tools/debug-terminal.sh   runs the editor binary instead (slower; for debugging scripts)
#   GODOT_CONSOLE=/path/to/godot tools/debug-terminal.sh --seed 42 --color
# DeepSeek: export DEEPSEEK_API_KEY=sk-...   (or type "llm key sk-..." inside the terminal)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_CONSOLE="${GODOT_CONSOLE:-/c/Godot/Godot_v4.7.1-stable_win64_console.exe}"
if [ ! -x "$GODOT_CONSOLE" ] && ! command -v "$GODOT_CONSOLE" >/dev/null 2>&1; then
  echo "Godot console build not found at $GODOT_CONSOLE; set GODOT_CONSOLE." >&2
  exit 1
fi
if [ "${DEBUG_TERMINAL_EDITOR:-0}" != "1" ]; then
  PCK="$ROOT/build/bench/combat_bench.pck"
  BENCH="$ROOT/build/bench/combat_bench.console.exe"
  if [ ! -f "$PCK" ] || [ ! -f "$BENCH" ] || [ -n "$(find "$ROOT/src" "$ROOT/assets/data" "$ROOT/project.godot" -newer "$PCK" -print -quit)" ]; then
    echo "Building the release terminal (about a minute, only after code or data changed)..." >&2
    "$GODOT_CONSOLE" --headless --path "$ROOT" --export-release "Windows Combat Bench" "$ROOT/build/bench/combat_bench.exe" >/dev/null 2>&1 || true
  fi
  if [ -f "$BENCH" ]; then
    exec "$BENCH" --headless -- --terminal --color "$@"
  fi
  echo "The release export failed (are the Godot 4.7.1 export templates installed?); using the editor binary." >&2
fi
exec "$GODOT_CONSOLE" --headless --path "$ROOT" -s res://src/debug_terminal/terminal_main.gd -- --color "$@"
