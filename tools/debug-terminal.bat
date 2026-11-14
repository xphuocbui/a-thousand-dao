@echo off
rem Ten Thousand Daos - debug terminal (Windows cmd / double-click).
rem Runs the RELEASE build (build\bench\combat_bench.console.exe --terminal): Power Rankings fights are several times
rem faster there than in the editor's debug binary (about 36 s of rating work a season instead of about 2 minutes).
rem The release build is re-exported first (about a minute) whenever src\, assets\data\ or project.godot changed
rem since the last export, so it never runs stale code or data.
rem   set DEBUG_TERMINAL_EDITOR=1   to run in the editor binary instead (slower; for debugging scripts)
rem Override the editor path with:  set GODOT_CONSOLE=C:\path\to\Godot_v4.7.1-stable_win64_console.exe
rem Extra arguments are passed through, e.g.:  debug-terminal.bat --seed 42 --color
rem DeepSeek: set DEEPSEEK_API_KEY=sk-...   (or type "llm key sk-..." inside the terminal)

chcp 65001 >nul
set "ROOT=%~dp0.."
if "%GODOT_CONSOLE%"=="" set "GODOT_CONSOLE=C:\Godot\Godot_v4.7.1-stable_win64_console.exe"
if not exist "%GODOT_CONSOLE%" (
  echo Godot console build not found at "%GODOT_CONSOLE%".
  echo Set GODOT_CONSOLE to your Godot_v4.7.1-stable_win64_console.exe and retry.
  pause
  exit /b 1
)
if "%DEBUG_TERMINAL_EDITOR%"=="1" goto editor
set "BENCH=%ROOT%\build\bench\combat_bench.console.exe"
powershell -NoProfile -Command "$r = '%ROOT%'; $p = Join-Path $r 'build\bench\combat_bench.pck'; $e = Join-Path $r 'build\bench\combat_bench.console.exe'; if (-not (Test-Path $p) -or -not (Test-Path $e)) { exit 1 }; $t = (Get-Item $p).LastWriteTime; $n = Get-ChildItem -Recurse -File (Join-Path $r 'src'), (Join-Path $r 'assets\data') | Where-Object { $_.LastWriteTime -gt $t } | Select-Object -First 1; if ($n -or (Get-Item (Join-Path $r 'project.godot')).LastWriteTime -gt $t) { exit 1 }; exit 0"
if errorlevel 1 (
  echo Building the release terminal ^(about a minute, only after code or data changed^)...
  "%GODOT_CONSOLE%" --headless --path "%ROOT%" --export-release "Windows Combat Bench" "%ROOT%\build\bench\combat_bench.exe" >nul 2>&1
)
if not exist "%BENCH%" (
  echo The release export failed ^(are the Godot 4.7.1 export templates installed?^); using the editor binary.
  goto editor
)
"%BENCH%" --headless -- --terminal %*
exit /b %errorlevel%

:editor
"%GODOT_CONSOLE%" --headless --path "%ROOT%" -s res://src/debug_terminal/terminal_main.gd -- %*
