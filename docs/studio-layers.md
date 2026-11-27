# Studio layers: Claude Code + Antigravity

This repo runs the game studio framework in two AI tools at once. Read this before
changing, updating or debugging either copy.

## What lives where

| | Claude Code | Antigravity |
|---|---|---|
| Entry file (always loaded) | `CLAUDE.md` | `AGENTS.md` + `GEMINI.md` |
| Skills, agents, rules, docs, scripts | `.claude/` | `.agents/` |
| Hooks | `.claude/settings.json` + `.claude/hooks/` (17 hooks) | `.agents/hooks.json` + `.agents/hooks/guard_shell.py` (one: blocks destructive shell commands) |
| Comes from | [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios), remote `template` | [Antigravity Game Studios](https://github.com/ammarsufyan/Antigravity-Game-Studios), remote `ag-studio`, a port of the same releases |
| Version record | merge-base with `template/main` | `.agents/studio-upstream.json` |

**Shared by both, one copy:** `project.yaml`, `project.local.yaml`,
`production/session-state/active.md`, `design/`, `docs/`, `src/`, `assets/`, `tests/`.

Local edits that must survive every update:
- `CLAUDE.md` and `AGENTS.md`: Godot 4.7.1 / GDScript stack and the engine-reference pointer.
- `rules/ui-code.md` in both layers: the `PlaceholderArt` rule.
- `GEMINI.md`: project rules for Antigravity (memory pointer, headless waiver, shared-repo rules).
- `.agents/hooks.json`, `.agents/hooks/guard_shell.py`.

## Daily use

Nothing to set up or type first. Open a thread at the repo root and work.

- **The provider decides the setup, not the model.** In T3 Code, the Claude provider
  (`claudeAgent`, `Muoi`) loads `CLAUDE.md`, `.claude/`, Claude memory and all Claude hooks.
  The Antigravity provider loads `AGENTS.md`, `GEMINI.md`, `.agents/` and the guard hook,
  whatever model it runs (Gemini or Claude).
- **Changing model:** T3 Code's model picker per thread; in the Claude Code CLI, `/model`
  or `claude --model <name>`. A skill's `model:` line applies in Claude Code only (when the
  skill is typed), never in Antigravity.
- **Skills:** type `/name` in either tool (`/dev-story`, `/update-studio`...). If T3 Code does
  not offer the slash command, write "run the dev-story skill".

Watch out for, in Antigravity:
- Never run `/start` or `/setup-engine`: the project is set up; they rewrite `project.yaml` and `AGENTS.md`.
- It reads Claude memory (`MEMORY.md`) but never writes it. Give standing rules in a Claude session.
- No hook updates `active.md`. Ask for a checkpoint at the end of a long session.
- Only destructive commands are hard-blocked (`git stash`, `git reset --hard`, `git clean -f`,
  `git push --force`, `rm -rf`, `Remove-Item -Recurse`). Claude's other hooks (commit
  message, registry, read size, assets) are written rules there, not enforced.
- Folder `AGENTS.md` files (`design/`, `src/`, `docs/`, `studio-tests/`) are not auto-loaded
  from the repo root; their content is mostly repeated in the root file and `.agents/rules/`.

## Adding a project rule

Add it to `.claude/rules/<file>.md` **and** `.agents/rules/<file>.md`. Antigravity rule
files need frontmatter (`trigger: glob` plus `globs: "..."`) or they are silently ignored.
`python -I tools/studio/update_studio.py check` fails if a line added to `.claude/rules/`
is missing from `.agents/rules/`.

Same for a new project skill: put it in both `.claude/skills/<name>/` and
`.agents/skills/<name>/`. The Antigravity copy's frontmatter is only `name` and `description`.
`check` fails on any skill or agent present in one layer only.

## Updating the studio

Run **`/update-studio`** in either tool. It fetches both upstreams, shows one plan, and
updates each side with your approval:

| Command | Does |
|---|---|
| `/update-studio status` | report only: versions, new commits, whether the port has caught up |
| `/update-studio` | update both sides to the newest paired release |
| `/update-studio claude` / `antigravity` | one side only |
| `/update-studio --to v1.4.0` | a specific version |

Before running it: no other session running jobs (it touches the shared git index),
nothing staged, no uncommitted edits in `.claude/`, `.agents/`, `CLAUDE.md`, `AGENTS.md`,
`GEMINI.md` or `project.yaml`. The helper refuses otherwise and never clears the way itself.

**The port lags.** Claude Code Game Studios releases first; the Antigravity port follows
(1.3.0 took 11 days). When `status` says `LAG`, the default is to wait and update both
together. Updating the Claude side alone leaves the two tools on different skills and
possibly different `project.yaml` formats.

### Manual fallback

What the skill runs, if you need to do it by hand
(`tools/studio/update_studio.py` wraps all of it):

```bash
python -I tools/studio/update_studio.py status

# Claude side: merge the release tag, resolve conflicts keeping project content,
# apply that version's UPGRADING.md section, then commit the merge
python -I tools/studio/update_studio.py merge-ccgs --to v1.4.0
git commit -m "chore: merge studio template release 1.4.0"

# Antigravity side: 3-way apply only the upstream diff of .agents/ and AGENTS.md
python -I tools/studio/update_studio.py apply-ag            # records the version when clean
python -I tools/studio/update_studio.py record-ag --commit <sha>   # after resolving conflicts
git add -- <paths it listed> .agents/studio-upstream.json
git commit -m "chore: update Antigravity studio layer to <version>" -- <paths it listed> .agents/studio-upstream.json

python -I tools/studio/update_studio.py check               # must end "Overall: PASS"
```

Never:
- `git merge ag-studio/main`: its release commit renames `.claude/` to `.agents/`.
- `git restore --source=ag-studio/main -- .agents` (or `checkout`): it deletes the guard hook
  and drops local edits.
- `--allow-unrelated-histories`, `git stash`, `git reset --hard`, `git clean -f`, force-push.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `check`: project rule not mirrored | copy the listed lines into `.agents/rules/<same file>`, keep its frontmatter |
| `check`: `AGENTS.md` lost the engine lines | restore the stack lines and the pointer under `ENGINE-REFERENCE-IMPORT` from `project.yaml` `engine.*` |
| `check`: skill/agent only in one layer | add the missing copy, or accept it while the port lags |
| `check`: layers on different releases | expected during a `LAG` you chose; otherwise update the lagging side |
| `check`: conflict markers | resolve them, `git add -- <file>`, re-run `check` |
| Remote missing | `status` re-adds `template` and `ag-studio` from `.agents/studio-upstream.json` |
| Guard blocked a command you need | do it another way; the guard mirrors Claude's deny list. To change the list, edit `.agents/hooks/guard_shell.py` and run `check` |
| Antigravity seems to ignore the rules | start a new session (running sessions do not reload); ask it to run `git stash list`, which must be refused |

## History

- `985892fd`: Antigravity layer added (from `ag-studio` `c1e29d3d`, 1.3.0-antigravity.1,
  built on Claude Code Game Studios `abc0de79`, v1.3.0).
- `96e9cf4d`: `/update-studio` skill and `tools/studio/update_studio.py`.
