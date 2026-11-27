# Instructions for Gemini / Antigravity agents

This project is set up for Claude Code. You get no hooks, no deny rules and no
auto-loaded memory, so you must read the sources yourself and obey them on your own.

## Read first, every session
1. `CLAUDE.md` and every file it imports (the lines starting with `@`):
   `.claude/docs/directory-structure.md`, `docs/engine-reference/godot/VERSION.md`,
   `.claude/docs/coordination-rules.md`, `.claude/docs/coding-standards.md`.
2. The user's standing rules (memory): `C:\Users\xphuo\.claude\projects\C--Users-xphuo-IdeaProjects-my-game\memory\MEMORY.md`,
   then every memory file relevant to your task. They bind as much as CLAUDE.md. Read only, never edit.
3. `production/session-state/active.md` (the session checkpoint; long, so read the end first).
4. The `.claude/rules/*.md` file for the kind of file you touch (data files, design docs, gameplay code...).

## Rules the Claude hooks enforce, which you must enforce yourself
- Ask "May I write this to <path>?" before writing, and show a draft first,
  unless your task says the user waived it (headless jobs).
- Never commit without the user's instruction. Commit only your own paths:
  `git commit -- <paths>`, never a plain commit (another session shares the repo).
  Conventional Commits, task or doc reference in the body.
- Never run `rm -rf`, `git reset --hard`, `git clean -f`, `git push --force` or `git stash`.
- Never edit `design/gdd/*` or the entity registry unless the task says so.
- Docs over 40 KB: find the heading with grep and read only that section.
- Python: `python -I`. Shell: Git Bash on Windows.
- Godot 4.7: check `docs/engine-reference/godot/` before using an engine API.

## Skills
`.claude/skills/<name>/SKILL.md` are procedures. When asked for `/name`, read that
file and follow it by hand (ignore its `model:` line).
