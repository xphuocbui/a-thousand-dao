#!/usr/bin/env bash
# Ten Thousand Daos - debug terminal (Git Bash / Linux / macOS).
# Uses the Godot console build so the game can read your typing.
#   GODOT_CONSOLE=/path/to/godot tools/debug-terminal.sh --seed 42 --color
# DeepSeek: export DEEPSEEK_API_KEY=sk-...   (or type "llm key sk-..." inside the terminal)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_CONSOLE="${GODOT_CONSOLE:-/c/Godot/Godot_v4.7.1-stable_win64_console.exe}"
if [ ! -x "$GODOT_CONSOLE" ] && ! command -v "$GODOT_CONSOLE" >/dev/null 2>&1; then
  echo "Godot console build not found at $GODOT_CONSOLE; set GODOT_CONSOLE." >&2
  exit 1
fi
exec "$GODOT_CONSOLE" --headless --path "$ROOT" -s res://src/debug_terminal/terminal_main.gd -- "$@"
