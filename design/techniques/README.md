# Technique Catalogue (Công Pháp)

> **Status**: First draft, 2026-11-11. Not reviewed by the user yet, not in game data (`assets/data/items_cong_phap.json`).
> **Rules**: `design/gdd/cong-phap.md` rules 1-19 (the record, kinds, tiers, layers, bonuses, abilities, authored vs
> generated); passives priced by `design/gdd/modifiers.md` Formulas A-D against the combat passive budget
> (Yellow 8 W, Profound 16 W, Earth 24 W, Heaven 32 W).

## What it is

The authored techniques that teach the 96 signature arts of `design/arts/`. A player gets an art by learning and
slotting the technique that carries it. One technique per art suite (24), plus 7 carriers for the 11 arts with no
suite. The generated commons (Yellow/Profound, one common art each) are not here; they are rolled (rule 17).

| File | Holds |
|---|---|
| `catalogue-<family>.json` / `.md` | the family's techniques; the `.md` has each one's layer → art table, passives with their W, bonuses, and how a build uses it |
| `_logs/` | the 12 session jobs (one per family) and their run logs |

## Shape

- **31 techniques**: 12 main methods, 16 secret arts, 3 body techniques. Tiers: 12 Yellow, 9 Profound, 6 Earth, 4 Heaven.
- Each suite technique carries its whole suite, with every suite art unlocked by layer 6, so a Foundation
  Establishment (Trúc Cơ) build can use all of it. Higher layers add only passive strength.
- Passives are plain modifier lines that feed the suite's engine: its stacks, curses, cost, cooldowns, heal or ward.
  Each spends 85-100 % of its tier's budget. No technique adds a new Effect.
- Bonuses are the tier's `bonus_count` lines from `bonus_pool`.

## Check

`python -I tools/design/arts/lint_techniques.py` (whole catalogue): 31 techniques, **0 findings**, 96 of 96 arts
carried, no suite split. It checks the schema, layers per tier, that each technique names its arts' element ids,
the bonuses, W-priced passives against the budget, that suite arts unlock by layer 6, and coverage.

## Open

- **Rule 17 says an authored technique carries 1-3 signature abilities.** 14 suite techniques carry 4. Either rule 17
  becomes 1-4, or those suites split across two techniques, which breaks the "same công pháp" link the suite's
  engines read. The lint notes these lines and does not count them as findings.
- **The force-chaos techniques name Primordial Chaos (`hon_don`)**, which needs all five elements in the root, so
  few characters can slot them. Element-less arts may sit in any technique, so these could name one base element
  instead.
- The passives are not yet run on the combat engine: the suite check (`tools/design/arts/suite_check.py`) fights
  arts only. They take effect when the builds are rebuilt from the library (`design/builds/engine-v2/`).
