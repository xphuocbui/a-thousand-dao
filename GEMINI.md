# Project rules for Antigravity sessions

`AGENTS.md` and `.agents/` (Antigravity Game Studios, same 1.3.0 base as `.claude/`)
carry the studio rules, skills and agents. This file adds what is specific to this repo.

## Read first, every session
1. The user's standing rules: `C:\Users\xphuo\.claude\projects\C--Users-xphuo-IdeaProjects-my-game\memory\MEMORY.md`,
   then every memory file relevant to your task. They bind as much as AGENTS.md. Read only, never edit.
2. `production/session-state/active.md` (long; read the end first).

## Headless jobs
A task that waives the ask-first protocol ("May I write...", drafts, approval) waives it
whether it names CLAUDE.md or AGENTS.md: write the files the task names without asking.

## Shared repo, two harnesses
- Another session (Claude Code or Antigravity) may share this checkout. Commit only when
  the user or your task says so, and only your own paths: `git commit -- <paths>`.
  Conventional Commits, task or doc reference in the body.
- Never run `rm -rf`, `git reset --hard`, `git clean -f`, `git push --force` or `git stash`
  (`.agents/hooks.json` blocks them).
- Never edit `design/gdd/*` or the entity registry unless the task says so.
- Python: `python -I`. Shell: Git Bash on Windows.
- Use the `.agents/` copies of skills, rules and docs; read a `.claude/` file only when a task names it.
  A project rule added to `.claude/rules/` must also go in `.agents/rules/` (with `trigger: glob` frontmatter).
