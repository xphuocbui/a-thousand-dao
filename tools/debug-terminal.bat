@echo off
rem Ten Thousand Daos - debug terminal (Windows cmd / double-click).
rem Uses the Godot CONSOLE build so the game can read your typing.
rem Override the editor path with:  set GODOT_CONSOLE=C:\path\to\Godot_v4.7.1-stable_win64_console.exe
rem Extra arguments are passed through, e.g.:  debug-terminal.bat --seed 42 --color
rem DeepSeek: set DEEPSEEK_API_KEY=sk-...   (or type "llm key sk-..." inside the terminal)

chcp 65001 >nul
if "%GODOT_CONSOLE%"=="" set "GODOT_CONSOLE=C:\Godot\Godot_v4.7.1-stable_win64_console.exe"
if not exist "%GODOT_CONSOLE%" (
  echo Godot console build not found at "%GODOT_CONSOLE%".
  echo Set GODOT_CONSOLE to your Godot_v4.7.1-stable_win64_console.exe and retry.
  pause
  exit /b 1
)
"%GODOT_CONSOLE%" --headless --path "%~dp0.." -s res://src/debug_terminal/terminal_main.gd -- %*
