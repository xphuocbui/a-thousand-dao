# Wind (Phong) signature arts

7 authored arts, lint 0 findings (`python -I tools/design/arts/lint_arts.py design/arts/family-wind.json`). Wind is speed,
evade, many light hits and tempo; its stacks (+7.5 % art speed, −1.2 pp evade on the foe) are what most hooks feed.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Hundred-Feather Flurry (Bách Vũ Loạn Phong) | Build-up, cash-in (counter, no cap) | basic attack speed, basic_coef, free-hit damage, crit | Basic attacks gather Feathers; firing releases one 0.28 hit per Feather and spends them |
| Swallow Stance (Yến Hành Thế) | Stance (state) | basic speed, evade, wind stacks, art speed | Toggle: basics +50 % speed, +12 evade, arts −25 % speed; evades in it give Wind stacks |
| Three-Step Chase (Tam Bộ Truy Phong) | Charges and bursts, timed momentum | charges, cooldown recovery, art speed, dash-tag more, evade | 3 charges, each firing gives evade; each Stride in 6 s adds 10 % more to dash arts |
| Reckless Gale (Mệnh Phong Bộ) | Paying with health, low-health payoff | low health, leech, health regeneration, art speed | Costs 6 % health; grants +10 % art speed for 8 s per 10 % health missing |
| Trailing Gale (Lưu Phong Chướng) | Curse pattern, delays (Slowed Time) | evade, Slowed Time stacks, curse duration, status chance | Lays 2 Slowed Time; while foe is Slowed each evade delays their longest timer 0.5 s |
| Echo of the Dodge (Hồi Phong Ảnh) | Echo and repeat | evade, last art's power, trigger damage, crit | Every 3rd evade fires your last art again at 60 % |
| Gale Sprite (Phong Linh Đồng) | Summon, scaled by stacks | companion speed, wind stacks, companion damage | Sprite strikes for 0.45 a second for 12 s; 2 Wind stacks make it 8 % faster |

## Library arts replaced

- Threshing Rain → Hundred-Feather Flurry (its stack-pair idea is plain stacks; the Feather count is the identity).
- Riding the Gust → Swallow Stance (the evade-to-Wind-stack loop now lives inside the stance).
- Hollow Step → Three-Step Chase.
- Gale Crown → Reckless Gale.
- Trailing Gale, Echo of the Dodge and Gale Sprite are new (no source).
- Kept as they are: the five commons (Chaff Needle, Reed-Cutting Breeze, Sieve Palm, Empty-Husk Gust, Falling Leaf).
  Not touched, left in part-b/c for the review: Gale Veil, Scatter Gale, Sweeping the Floor (utility/ward, no signature
  claimed).

## Shapes left out

Conversion, split hits and held payloads are not used: Wind has no natural damage-type story, and the 7 shapes above
already differ. A held "your next art" payload (bank evades, spend on the next art) would suit Wind well and is a spare.

## What the engine could not express (or I could not confirm)

- **Stance suppression of other arts**: `suppress` needs art ids known at authoring time. Swallow Stance's penalty is an
  art-speed malus instead; a tag-based `suppress` (all arts with tag X) is the missing piece.
- **Counter spend as a clean read**: Feather and Echo reset with `counter set 0` in the same `do` as the payoff. This
  assumes the Effect's `scale` is read before the actions run, and (Echo) that effects on one event run in array order;
  an explicit `consume` for counters would make this safe.
- **`mod` scoped to a tag on `always` with `scale`** (Three-Step Chase's `dash` more): the schema accepts `tags` on a
  mod; I could not confirm the engine applies it only to arts with that tag.
- **Hit-side evade hooks**: the Flurry's "evade becomes Feathers" idea needs a `counter` gain on `evaded` filtered per
  build; as written it is a hook for builds to add, not part of the art.
- **Free hits are trigger-budgeted** (`trig_cap`, `trig_budget`): a huge Feather count is clipped, so "limitless
  scaling" is bounded by the trigger budget, not by the art. This is a rule question for the review.
- **Summon scaling**: `companion_speed` units (percent vs. fraction) were not verified; 8 is read as percent.
- None of the 7 arts has been run in `fight.py`; only the lint and the schema check ran.
