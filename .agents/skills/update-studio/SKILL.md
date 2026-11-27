---
name: update-studio
description: "Updates both studio layers to the newest paired release: .claude/ from Claude Code Game Studios and .agents/ from its Antigravity port, keeping local edits. Use when the user asks to update, upgrade or check the studio or template version."
---

# /update-studio: update both studio layers

This repo carries the studio twice, on one release:

| Layer | Read by | Upstream | Remote |
|---|---|---|---|
| `.claude/`, `CLAUDE.md` | Claude Code | Claude Code Game Studios | `template` |
| `.agents/`, `AGENTS.md` | Antigravity | Antigravity Game Studios (a port of the same releases) | `ag-studio` |

`.agents/studio-upstream.json` records which Antigravity commit the layer matches.
Local edits live in both layers (filled-in `CLAUDE.md`/`AGENTS.md`, project rules
in `rules/`, `.agents/hooks.json` and `.agents/hooks/guard_shell.py`); an update must keep them.

All git work goes through `python -I tools/studio/update_studio.py` (`status`,
`merge-ccgs`, `apply-ag`, `record-ag`, `check`). It reports what it sees and never
commits; you decide with the user.

**Writes**, after the plan is approved in Phase 2: the framework files the merge and
patch change, conflict resolutions, `.agents/studio-upstream.json`. **Commits**, only as
approved in Phase 2 or after a yes. The session checkpoint append needs no ask.

Ask with the question tool. Without one, list the options numbered and end your turn
to wait. A skipped or dismissed question is not an answer: ask again in plain text.

## Hard rules

- Never `git merge ag-studio/main`: its release commit renames `.claude/` to `.agents/`.
- Never `git restore`/`checkout --source=ag-studio/...` over `.agents/`: it deletes the
  local hook files and drops local edits. `apply-ag` applies only the upstream diff.
- Never stash, `reset --hard`, `clean -f`, `--allow-unrelated-histories` or push.
- Never edit `design/gdd/*` or the entity registry.
- Another session may share this checkout. The update touches the index: run it only
  when the user confirms no other session is running jobs.

## Phase 1: Status

Run `python -I tools/studio/update_studio.py status` and read all of it.

- A side whose fetch failed is **NOT ASSESSED**: say so by name, and offer only what was assessed.
- `UP TO DATE` and the argument was not `status`: run Phase 4's `check`, report, stop.
- Argument `status`: report the output in a few lines and stop.

## Phase 2: Plan and approval

**Pick the targets.**
- **Default (paired):** Claude side to tag `v<X>`, where X is what the Antigravity port
  covers (`ports framework X`); Antigravity side to `ag-studio/main`.
- **`LAG`** (Claude latest newer than the port): offer
  1. wait for the port (recommended unless a fix in the new release is needed now);
  2. update the Antigravity side only, if it has new commits;
  3. update the Claude side to the latest anyway, `.agents/` stays behind. Warn: the two
     harnesses then run different skills and agents, and the `project.yaml` format may differ.
- Argument `claude` or `antigravity` limits the run to one side; `--to` picks the version.

**Read the release notes for the Claude side.** In the target's `UPGRADING.md`
(`git show <tag>:UPGRADING.md`), find the `## vA → vB` headings between the current and
the target version with grep, and read only those sections. Note *Files: Delete*,
*Files: Merge Carefully* and any config migration.

**Show the plan**: per side, version from → to, new commits, files changed, whether the
Antigravity patch applies cleanly, the UPGRADING steps, and the no-other-session rule.
Ask once:
1. Proceed, commit each side when its check passes (Recommended)
2. Proceed, ask me before each commit
3. Change the target
4. Cancel

## Phase 3: Claude side (skip if not in the plan)

1. `python -I tools/studio/update_studio.py merge-ccgs --to <tag>`. On `REFUSED`, show
   why and stop; never clear the way yourself.
2. Resolve each conflict: keep project content (engine, filled settings, project rules
   such as the `PlaceholderArt` line in `rules/ui-code.md`), take structural changes,
   follow *Merge Carefully*. Likely files: `CLAUDE.md`, `project.yaml`,
   `.claude/docs/technical-preferences.md`, `.claude/rules/*`. Then `git add -- <file>`.
3. Apply the UPGRADING deletes (`git rm -- <file>`) and migrations.
4. If `merge-ccgs` warned that the merge touches `AGENTS.md`, `GEMINI.md` or `.agents/`,
   stop and ask: upstream has started shipping its own Antigravity files.
5. `git grep -n -E "^(<<<<<<<|>>>>>>>) " -- .claude CLAUDE.md project.yaml` must print nothing.
6. Commit (option 1) or ask (option 2): `git commit -m "chore: merge studio template release <version>"`
   with a body naming the UPGRADING section. First confirm `git diff --cached --name-only`
   holds only merge files; anything else staged means stop and ask.

## Phase 4: Antigravity side (skip if not in the plan)

1. `python -I tools/studio/update_studio.py apply-ag --to <ref>`. It 3-way applies only
   the upstream diff of `.agents/` and `AGENTS.md` files onto the local ones. Files it
   lists as *not applied* are shared files, which come from the Claude side.
2. Conflicts: resolve as in Phase 3 (keep the engine lines in `AGENTS.md`, mirrored
   project rules, the hook), `git add -- <file>`, then
   `python -I tools/studio/update_studio.py record-ag --commit <sha it printed>`.
   A clean apply records itself.
3. `python -I tools/studio/update_studio.py check`. Fix every FAIL that is yours to fix:
   - unmirrored project rule: copy the lines into `.agents/rules/<same file>`, keeping its
     `trigger: glob` frontmatter;
   - lost engine lines in `AGENTS.md`: restore them from `project.yaml` (`engine.*`);
   - conflict markers: resolve them.
   Re-run until no FAIL remains that you can fix. Skill/agent parity and release FAILs are
   expected only when the user chose option 3 in Phase 2: say so. List every NOT ASSESSED
   item with its reason; never call it a pass.
4. Commit (option 1, check passed) or ask (option 2):
   `git commit -m "chore: update Antigravity studio layer to <version>" -- <paths apply-ag listed> .agents/studio-upstream.json`.

## Phase 5: Report

- Per side: from → to, commit SHA, conflicts and how each was resolved.
- The final `check` table, verbatim, with its overall verdict.
- Anything skipped, by name, with the reason (side not in the plan, fetch failed, LAG choice).
- Append a three-line checkpoint to `production/session-state/active.md`.
- Never push unless the user asks.
