# Art Library (Thần Thông / Võ Kỹ)

> **Status**: First draft, 2026-11-11. Merged by three headless Sonnet sessions from the 136 arts the overnight builds
> invented (`design/builds/overnight-2026-11-10/staging-catalogue.md` § Arts), gaps filled per element. Not reviewed
> yet, not in game data. Numbers are first guesses inside the GDD limits.
> **Rules**: an art is a Combat art record (Combat rule 13); techniques carry them as divine abilities (`cong-phap.md`
> rules 1, 13, 17). `common` arts are what generated techniques roll (one each, user decision 2026-11-11);
> `authored` arts are signatures for authored techniques, Ways and items.
> **Check**: `python -I tools/design/arts/lint_arts.py` lints every art against the art lint, heal lint, stack and
> curse charge, soul pricing, cost and cooldown ranges, and the combat engine's schema. 127 arts, 0 findings.

## Files

| File | Holds | Notes |
|---|---|---|
| `part-a.json` / `.md` | Fire, Earth, Metal, element-less Physical (sword, saber, fist, spear) | merged ids and gaps per element in the `.md` |
| `part-b.json` / `.md` | Water, Ice, Wood, and the heal and ward-art roles | |
| `part-c.json` / `.md` | Thunder, Wind, element-less Force, Chaos and soul, control and utility | |

Each art: `id`, `name`, `element`, `role` (damage, stacks, curse, heal, ward, soul, utility, control, summon),
`tier` (common, authored), `tags`, the art numbers, optional `effects` / `counters` in the combat engine's schema
(`.claude/skills/design-build/references/content-formats.md` § Fight input), `rule` (one sentence) and `sources`
(the staged ids merged into it).

## Coverage (2026-11-11)

127 arts: 50 common, 77 authored. By element: none 35, thunder 14, wood 13, fire 12, metal 12, wind 12, earth 11,
water 10, ice 8. By role: damage 36, stacks 29, utility 16, heal 10, ward 11, control 10, curse 8, soul 6, summon 1.

## Engine gaps the arts ran into

The sessions approximated or dropped these; each is a small addition to `tools/design/combat_sim/engine.py`:
- a conversion field on an art (Iron Spark 60 % Physical; Physical → Fire arts);
- cleansing curses by tag (`curse`, `soul`, `seal`) and OR-guards;
- an art paid partly in health; an art's own L2 points in the library record (`x`);
- the art's cost passed into `heal_restored` (heal refunds), tag filters on that event;
- companion targets (shield, heal, Down), summons, escape, boss phases and telegraphs.

## Next

1. A review pass (headless, like the Đạo batches) and triage.
2. The authored technique catalogue (~40, `cong-phap.md` rule 17) carrying these arts, with combat passives under
   the per-tier budget (rule 1).
3. Rebuild the builds from the library and run them on the engine (`design/builds/engine-v2/jobs-*.json`, prepared).
