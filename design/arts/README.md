# Art Library (Thần Thông / Võ Kỹ)

> **Status**: Second draft, 2026-11-11. Not reviewed by the user yet, not in game data. Numbers are first guesses
> inside the GDD limits, tuned on the combat engine.
> **Rules**: an art is a Combat art record (Combat rule 13); techniques carry them as divine abilities (`cong-phap.md`
> rules 1, 13, 17). `common` arts are what generated techniques roll (one each); `authored` arts are signatures.
> **Design direction (user, 2026-11-11)**: authored arts each carry one signature mechanic a build hooks into
> (PoE-skill style); the strongest arts reach full power only once a build has built an engine around them, with
> several ways to feed it (memory: strongest-arts-need-engines). Scaling is limitless; engines are earned, not capped.

## Files

| File | Holds |
|---|---|
| `family-<name>.json` / `.md` | **96 signature arts** in 12 families (fire, water, earth, metal, wood, ice, thunder, wind, blade, body, force-chaos, soul-song-seal), 8 each: 60 engine arts, 36 standalone, 24 suites. The `.md` has each art's mechanic, hooks and how to feed its engine |
| `part-a/b/c.json` / `.md` | the first merge of the 136 build-invented arts: the **50 `common` arts** stay the common pool; its `authored` arts are superseded by the families |
| `tune-*.md`, `tune2-*.md` | what each tuning pass changed, with the suite check before and after |
| `_draft1/` | the first family pass (before the engine-building brief), kept as a record |
| `_logs/` | job files, run logs, `suite-check-after.txt` (the final suite check) |

## The engine-building shape

- **Engine arts** (`power: "engine"`) pass the art lint in their base form. Their full power sits behind gated
  **steps** (a multi-step art: each firing tries the next step, which unlocks only if its condition holds and may pay
  by consuming stacks, else the art fires as step 1) or gated **empowers**. The lint reports each gated payoff's
  multiple of the lint (`engine_payoff`) and never caps it.
- **Feeding routes**: every engine art has at least two: own buff stacks, the foe's debuffs or curses, time windows,
  other arts of the same công pháp fired this pulse (`group`), counters other arts build, foe state, own stance, low
  health. The top payoff needs an easy route **and** a real requirement, or scales with what was fed.
- **Suites**: 24 groups of 3–4 arts that share a `group` (a công pháp name) and feed each other. They seed the
  authored technique catalogue (`cong-phap.md` rule 17).

## Checks

- `python -I tools/design/arts/lint_arts.py design/arts/family-*.json`: 96 arts, **0 findings**.
- `python -I tools/design/arts/suite_check.py`: each suite in an otherwise typical build, each standalone art in the
  typical kit, against the typical foe at Trúc Cơ and Kết Đan, compared with the typical mirror. After two tuning
  passes: every suite at **×0.6–0.9** of the typical mirror, standalone arts roughly even, **every engine art engages**
  (its step or empower fires in its own suite), 0 FAST, 0 never-engaged.

## Known

- The fitted typical enemies above Qi Refining run short: the typical mirror is 25.6 s at Trúc Cơ and 20.0 s at Kết
  Đan, under the 30–60 s band (enemy fitting, Combat Formulas B; not an art issue).
- Suites still win every fight against a typical build with nothing else built (20–0), at a faster but not trivial
  pace. That is the intended edge of a signature suite; whether it is too much is the user's call.
- Not modelled by the engine yet: escape, ward payment models other than drain, companion targets, boss phases.

## Next

1. The user reviews the families (standouts and weak ones).
2. The authored technique catalogue: one technique per suite (24) plus standalone carriers, with combat passives
   under the per-tier budget (`cong-phap.md` rule 1).
3. Rebuild the builds from the library and run them (`design/builds/engine-v2/jobs-*.json`, prepared).
