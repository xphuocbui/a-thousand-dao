# Setup Requirements

Everything needed to run **Antigravity Game Studios** on **Windows, macOS, and Linux**.

## Required

| Tool | Role | Install |
|---|---|---|
| **Google Antigravity** | AI coding platform (App, IDE, or `agy` CLI) | https://antigravity.google/docs |
| **Git** | Version control & template cloning | https://git-scm.com/ |

## Optional (Recommended)

| Tool | Role | Notes |
|---|---|---|
| **Node.js** (20+) | Growing browser prototypes into Vite + TypeScript web projects and running web tests | https://nodejs.org/ |
| **Chrome, Edge, or Chromium** | Automated browser testing and visual verification screenshots | Antigravity also includes a built-in `browser` subagent |
| **Bash** (macOS/Linux built-in; Git Bash on Windows) | Optional speedup for `.agents/scripts/*.sh` helpers | **Not required on Windows:** all skills natively read and edit `project.yaml`, `project.local.yaml`, and project files directly via `read_file` / `edit_file` / `write_file` |
| **Game Engine** (optional) | Only when building beyond the browser route | Godot 4, Unity, or Unreal Engine 5 — configure via `/setup-engine` |

## Cross-Platform Notes

- **Windows**: Works out of the box without Bash, Python, or `jq`. Always open the repository root folder (the folder holding `AGENTS.md`, `project.yaml`, and `.agents/`) in Google Antigravity so workspace discovery loads all 49 subagents, 78 skills, and 14 glob rules automatically.
- **macOS / Linux**: Works identically; optional `.agents/scripts/*.sh` helpers can run directly via `run_command`.
- **Line Endings**: `.gitattributes` enforces LF (`\n`) on `.sh`, `.awk`, `.tsv`, and `.agents/**/*.md` across all platforms.
