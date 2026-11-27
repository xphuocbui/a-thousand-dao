# /setup-engine — Section 4: Update AGENTS.md Technology Stack

> Part of `/setup-engine`. `SKILL.md` names when to read this file; the settings it
> resolved and the rules under its later headings still apply here.

## 4. Update AGENTS.md Technology Stack

### Language Selection (Godot only)

If Godot was chosen, ask the user which language to use **before** showing the proposed Technology Stack:

> "Godot supports two primary languages:
>
>   **A) GDScript** — Python-like, Godot-native, fastest iteration. Best for beginners, solo devs, and teams coming from Python or Lua.
>   **B) C#** — .NET 8+, familiar to Unity developers, stronger IDE tooling (Rider / Visual Studio), slight performance advantage on heavy logic.
>   **C) Both** — GDScript for gameplay/UI scripting, C# for performance-critical systems. Advanced setup — requires .NET SDK alongside Godot.
>
> Which will this project primarily use?"

Record the choice. It determines the `AGENTS.md` template, naming conventions, specialist routing, and which agent writes code files throughout the project.

### Primary Language (Unreal)

If Unreal was chosen, ask: "Will most gameplay logic live in
C++ or in Blueprints?" — `[A] C++ (Blueprints for tuning and prototyping)` /
`[B] Blueprint-primary (C++ only where needed)`. Default to C++ if the user has no
preference. The answer sets `engine.language` (`"C++"` or `"Blueprint"`).

---

Read `AGENTS.md` with `read_file` and show the user the proposed Technology Stack changes.
Ask: `"May I write these engine settings to AGENTS.md?"`

Wait for confirmation before making any edits.

Update the Technology Stack section, replacing the `[CHOOSE]` placeholders with the actual values:

**For Godot** — use the template matching the language chosen above. See `references/godot-language-config.md` (**A1**) for all three variants (GDScript, C#, Both).

**For Unity:**
```markdown
- **Engine**: Unity [version]
- **Language**: C#
- **Build System**: Unity Build Pipeline
- **Asset Pipeline**: Unity Asset Import Pipeline + Addressables
```

**For Web** — the four lines in `references/web.md` (W3).

**For Unreal:**
```markdown
- **Engine**: Unreal Engine [version]
- **Language**: [C++ (primary), Blueprint (gameplay prototyping) | Blueprint (primary), C++ where needed]
- **Build System**: Unreal Build Tool (UBT)
- **Asset Pipeline**: Unreal Content Pipeline
```
The Language line follows the primary-language answer above: the first form for
`[A]` (`engine.language: "C++"`), the second for `[B]` (`"Blueprint"`).

### Engine reference pointer

In the same `AGENTS.md` edit, set the **Engine Version Reference** pointer to the
chosen engine. Find the `ENGINE-REFERENCE-IMPORT` comment. If a reference line
under it already points at another engine, edit it with `edit_file` to point at
the configured engine; if it already points there, leave it as-is. If there is
none (the template ships with no reference until an engine is set), insert the
line on its own right after the comment's closing `-->`:
- Godot → `Active engine reference: \`docs/engine-reference/godot/VERSION.md\` (read with \`read_file\` before using engine APIs)`
- Unity → `Active engine reference: \`docs/engine-reference/unity/VERSION.md\` (read with \`read_file\` before using engine APIs)`
- Unreal → `Active engine reference: \`docs/engine-reference/unreal/VERSION.md\` (read with \`read_file\` before using engine APIs)`
- Web → `Active engine reference: \`docs/engine-reference/web/VERSION.md\` (read with \`read_file\` before using engine APIs)`

This keeps a Unity or Unreal project from pointing at Godot docs, and a project
with no engine from pointing at any. It is idempotent — re-running `/setup-engine`
for a different engine rewrites the same line. (The target
`docs/engine-reference/<engine>/` directory is created in Section 7, Populate
Engine Reference Docs, if it does not yet exist.)

---
