# Antigravity Game Studios — Game Studio Agent Architecture

Indie game development managed through 49 coordinated Antigravity subagents and 78 skills.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## Technology Stack

- **Engine**: Godot 4.7.1
- **Language**: GDScript
- **Version Control**: Git with trunk-based development
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal with
> dedicated sub-specialists. Use the set matching your engine.

## Project Structure

```text
/
├── AGENTS.md                    # Master studio instructions (auto-discovered)
├── project.yaml                 # Machine-readable project config — engine, modes, stage (source of truth)
├── .agents/                     # Agent definitions, skills, rules, docs, engines, genres, scripts
├── <code root>/                 # Game source code — THE PATH IS ENGINE-SPECIFIC, see below
├── assets/                      # Game assets (art, audio, vfx, shaders, data)
├── design/                      # Game design documents (gdd, narrative, levels, balance)
├── docs/                        # Technical documentation (architecture, api, postmortems)
│   └── engine-reference/        # Curated engine API snapshots (version-pinned)
├── tests/                       # Game test suites (unit, integration, performance, playtest)
├── tools/                       # Build and pipeline tools (ci, build, asset-pipeline)
├── prototypes/                  # One-shot games, throwaway prototypes (outside the code root)
├── production/                  # Production management (sprints, milestones, releases)
│   ├── session-state/           # Ephemeral session state (active.md — gitignored)
│   └── session-logs/            # Session audit trail (gitignored)
└── studio-tests/                # QA for the skills/agents themselves — /skill-test, /skill-improve
```

### The code root is engine-specific

**Two of the four supported engines will not build a project whose code sits in `src/`.** This is a hard constraint of the engine's toolchain:

| `engine.name` | Code root | Test root | Notes |
|---|---|---|---|
| **Godot** | `src/` | `tests/unit/`, `tests/integration/` | Godot loads from `res://` anywhere under the project root. |
| **Unity** | `Assets/` | `Assets/Tests/EditMode/`, `Assets/Tests/PlayMode/` | Unity compiles **only** `Assets/` and `Packages/`. |
| **Unreal** | `Source/<Module>/` | `Source/<Module>/Private/Tests/` | UnrealBuildTool discovers modules under `Source/`; content lives in `Content/`. |
| **Web** | `src/` | `tests/unit/` (Vitest), `tests/integration/` (Playwright) | Vite builds what `index.html` imports. |

Resolve the code root from `engine.name` before writing any source file (from `.agents/engines/engines.tsv`; `engine.code_root` and `engine.test_root` in `project.yaml` override the defaults). Read `src/…` or `tests/unit/[system]/` anywhere as the resolved code/test root for the active engine.

## Engine Version Reference

<!-- ENGINE-REFERENCE-IMPORT: the line under this comment is engine-specific,
     and there is none until an engine is set. /setup-engine, the grow record
     step, and /project-settings (engine.name) write the active reference pointer
     (`docs/engine-reference/<engine>/VERSION.md`) here for the chosen engine.
     Skills that need the pinned version read that file on demand with read_file. -->
Pinned reference: `docs/engine-reference/godot/VERSION.md` (Godot 4.7, installed 4.7.1).
Read it before using any Godot API: 4.5-4.7 postdate the model's training data.

## Technical Preferences

`project.yaml` at the repo root is the primary config store — engine, specialists, naming, platform, performance, modes. Resolve it by reading `project.yaml` (and `project.local.yaml`, if present) with `read_file` according to `.agents/docs/config-resolution.md`.

`.agents/docs/technical-preferences.md` is the **legacy fallback**, read on demand when a key is absent from `project.yaml`.

## Cross-Platform Helpers (Windows / macOS / Linux)

This template works natively on **Windows, macOS, and Linux**:

- **Configuration resolution (`project.yaml` / `project.local.yaml`)**: Always read directly with `read_file` following `.agents/docs/config-resolution.md` — no Bash or Python required.
- **Helper scripts (`.agents/scripts/*.sh`)**: On macOS, Linux, or Windows with Git Bash, you may run helper scripts via `run_command`. On Windows without Bash (or if any helper script fails), perform the equivalent file inspection or update directly using `read_file`, `edit_file`, `write_file`, and native OS commands via `run_command`.
- **Helpers emit observations, never verdicts.** A script that scores or judges will eventually contradict a mode or override it cannot see.

## Coordination Rules

1. **Vertical Delegation**: Leadership agents delegate to department leads, who delegate to specialists. Never skip a tier for complex decisions.
2. **Horizontal Consultation**: Agents at the same tier may consult each other but must not make binding decisions outside their domain.
3. **Conflict Resolution**: When two agents disagree, escalate to the shared parent. If no shared parent, escalate to `creative-director` for design conflicts or `technical-director` for technical conflicts.
4. **Change Propagation**: When a design change affects multiple domains, the `producer` agent coordinates the propagation.
5. **No Unilateral Cross-Domain Changes**: An agent must never modify files outside its designated directories without explicit delegation.
6. **Read Design Docs by Section**: A brief names the sections an agent needs by heading. Locate headings first and read the target range with `StartLine`/`EndLine` in `read_file`; read a large (>40 KB) doc whole only when the task needs all of it, and state why.
7. **Nothing Goes Upstream**: Never file, open, or comment on an issue or pull request in an engine, plugin, or vendor repository, even when asked. Write a draft (`/bug-report` drafts only) and let the user submit it.

### Subagents & Parallel Task Protocol

Subagents are spawned via `invoke_subagent` (and coordinated with `send_message` when needed). All `team-*` and orchestration skills use this pattern.

- **Spawn in parallel when independent**: If two subagents' inputs do not depend on each other (for example, `/review-all-gdds` Phase 2 consistency and Phase 3 design theory after Phase 1 loads the GDDs), issue both `invoke_subagent` calls in the same turn rather than sequentially.
- **Collect all results** before proceeding to dependent phases.
- **Surface blocks immediately**: If any subagent is BLOCKED, report it immediately — never silently skip, and produce a partial report if some subagents complete while others block.

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask `"May I write this to [filepath]?"` before using `write_file` / `edit_file` (exempt: `production/session-state/active.md` appends, agent memory under `.agents/agent-memory/`, and a subagent's new file at the exact path named by its orchestrating skill under `production/`, `docs/`, or `tests/`; see `.agents/rules/agent-memory.md`).
- Agents MUST show drafts or summaries before requesting approval.
- Multi-file changes require explicit approval for the full changeset.
- No commits without user instruction.
- A skipped or dismissed question is not an answer: act on nothing, re-ask in plain text, and wait.

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** Say "make me a game" (`/prototype`), or run `/start` to begin the guided onboarding flow.

## Coding Standards

- All game code must include doc comments on public APIs.
- Architecture decisions are recorded as ADRs in `docs/architecture/`. **How many is set by `modes.workflow`** — all ADRs at `full`, *critical* ADRs only at `standard`, and none required at `minimal` (see `.agents/docs/workflow-modes.md`).
- Gameplay values must be data-driven (external config), never hardcoded.
- All public methods must be unit-testable (dependency injection over singletons).
- **Commit messages**: Use Conventional Commits format (`feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`) and reference the relevant design doc or story ID in the body (e.g., `Story: EPIC-001-S02`).
- **Verification-driven development**: Write tests first when adding gameplay systems. For UI changes, verify with screenshots. Compare expected output to actual output before marking work complete.
- **A parse check is not a run.** Every story that changes something player-observable must be launched and observed before closing, with a retained screenshot in `production/qa/evidence/`. Procedure per engine: `.agents/docs/run-and-observe.md`. Not waived at `qa.level: minimal`.

### Design Document Standards

- All design docs use Markdown; each mechanic has a dedicated document in `design/gdd/`.
- **Required GDD sections depend on `modes.workflow`** (`.agents/docs/workflow-modes.md`): all 8 at `full`; 5 (+ Formulas when numeric rules exist) at `standard`; none at `minimal` (`design/game-brief.md` is the design record).
  1. **Overview** — one-paragraph summary
  2. **Player Fantasy** — intended feeling and experience
  3. **Detailed Rules** (alias: **Detailed Design**) — unambiguous mechanics
  4. **Formulas** — all math defined with variables
  5. **Edge Cases** — unusual situations handled
  6. **Dependencies** — other systems listed
  7. **Tuning Knobs** — configurable values identified
  8. **Acceptance Criteria** — testable success conditions
- Balance values must link to their source formula or rationale.

### Testing Standards

| Story Type | Required Evidence | Location | Default Gate Level |
|---|---|---|---|
| **Logic** (formulas, AI, state machines) | Automated unit test — must pass | `tests/unit/[system]/` | BLOCKING |
| **Integration** (multi-system) | Integration test OR documented playtest | `tests/integration/[system]/` | BLOCKING |
| **Visual/Feel** (animation, VFX, feel) | Retained screenshot + lead sign-off | `production/qa/evidence/` | BLOCKING |
| **UI** (menus, HUD, screens) | Retained screenshot of each screen touched | `production/qa/evidence/` | BLOCKING |
| **Config/Data** (balance tuning) | Smoke check pass | `production/qa/smoke-[date].md` | ADVISORY |

`testing.strict.{logic,integration,visual,ui,config}` in `project.yaml` overrides the defaults above (`true` = BLOCKING, `false` = ADVISORY). Exception: `/smoke-check` defaults `testing.strict.config` to **BLOCKING**.

- **Naming**: per engine — see `.agents/rules/test-standards.md`.
- **Determinism & Isolation**: No random seeds or time-dependent assertions; each test sets up and tears down its own state with no external I/O (use dependency injection) and no hardcoded magic fixtures.
- **Do NOT automate**: visual fidelity, "feel" qualities, platform-specific rendering, or full gameplay sessions.
- **CI/CD**: Automated tests run on push/PR and block merge on failure. Never disable or skip failing tests.
  - **Godot**: `godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode`
  - **Unity**: `game-ci/unity-test-runner@v4` (GitHub Actions)
  - **Unreal**: headless runner with `-nullrhi` flag

## Context Management

Read `.agents/docs/context-management.md` on demand — it is a reference, not session context. Key checkpoint rule:

- **`production/session-state/active.md` is the session checkpoint.** The file is the memory, not the conversation. Read it first after any compaction, crash, or new session.
