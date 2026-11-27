# Subagent Model Tier Guidance

How **Antigravity Game Studios** maps studio hierarchy roles to Antigravity subagent model options (`invoke_subagent` `Model` parameter: `inherit`, `pro`, `flash`, `flash_lite`).

## Default Rule

All 49 subagent definitions in `.agents/agents/*.md` omit any hardcoded vendor model field — by default, every subagent runs on **`inherit`** (your active Antigravity session's model).

When an orchestrating skill spawns subagents via `invoke_subagent`, you may leave `Model` as `inherit` (recommended default) or optionally override it by role tier when optimizing speed vs. depth:

| Studio Tier | Roles | Recommended `invoke_subagent` Model |
|---|---|---|
| **Tier 1 — Directors** | `creative-director`, `technical-director`, `producer`, `art-director` | `inherit` (or `pro` for deep cross-system gates & architecture reviews) |
| **Tier 2 — Department Leads** | `lead-programmer`, `game-designer`, `systems-designer`, `level-designer`, `narrative-director`, `audio-director`, `qa-lead`, `release-manager`, `localization-lead` | `inherit` |
| **Tier 3 — Specialists & Engine Specialists** | Gameplay/engine/AI/network/UI/tools programmers, Godot/Unity/Unreal specialists, QA, audio, art, narrative, operations | `inherit` (or `flash` for lightweight, read-only lookups) |

## Authoring Rule

- Never add hardcoded vendor `model:` keys to `.agents/agents/*.md` or `.agents/skills/*/SKILL.md` frontmatter.
- Let the user's active Antigravity model selection govern the session unless the user explicitly asks to switch models for a specific subagent.
