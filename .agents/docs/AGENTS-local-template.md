# AGENTS.local.md Template

Copy this file to the project root as `AGENTS.local.md` (or add personal rules in `.agents/rules/local.md`) for personal overrides.
`AGENTS.local.md` is gitignored and will not be committed.

```markdown
# Personal Preferences

## Workflow Preferences
- Always run tests after code changes
- Compact context proactively with `/compact` when sessions get long
- Keep work focused on one task or story per conversation

## Local Environment
- OS: Windows / macOS / Linux
- Shell: PowerShell (Windows) or Bash/Zsh (macOS/Linux)
- Engine CLI path: [optional local path]

## Communication Style
- Keep responses concise
- Show file paths in all code references
- Explain architectural decisions briefly

## Personal Shortcuts
- When I say "review", run `/code-review` on the last changed files
- When I say "status", show `git status` + sprint progress
```

## Setup

1. Copy this template to your project root as `AGENTS.local.md`
2. Edit it to match your preferences
3. Verify `AGENTS.local.md` is listed in `.gitignore`
