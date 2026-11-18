# Budget report: armoury-mind (2026-11-13)

Files changed: `design/builds/engine-v3/builds/armoury-mind.fight.json` (`layers` only) and `design/builds/engine-v3/armoury-mind.md`. No technique, item, art or Effect was changed or removed.

## Claimed share (nguyen_anh budget 23 %)

- Before: 75 % (OVER_BUDGET).
- After: 23 % (`layer_budget`).

## Layers (L1-L5)

- Before: `[266, 265, 250, 130, 0]`
- After: `[150, 150, 120, 0, 0]`

Why: techniques' passives and items' modifiers already run as Effects, so the old values counted the gear twice. L4 was cut to nothing first (the concept needs it least); L1-L3 were trimmed to a Đạo Đồ-sized base. L5 was already 0 in `layers`; the gear lifts it through the build's own Effects.

## Fights (mean time, wins of 20)

| Matchup | Before | After |
|---|---|---|
| typical nguyen_anh+0 | 1.5 s, 20 wins | 3.7 s, 20 wins |
| typical hoa_than+1 | 3.2 s, 20 wins | 5.6 s, 20 wins |
| top_end nguyen_anh+0 | 2.4 s, 0 wins | 2.4 s, 0 wins |
| top_end hoa_than+1 | 1.5 s, 0 wins | 1.5 s, 0 wins |

The build is still well below the 10-20 s a build at its budget should need against a typical foe (3.7 s), and the top-end enemy still kills it in 2.4 s. The `--without` tests in the guide were not re-run.

## What the build now lacks to stay strong

- An Effect that counts equipped weapon-base pieces (Garrison Mind strikes, Full Rack, Humming Shields are fixed numbers now); metal family.
- A Metal armour with a standing drain ward at the Nascent Soul size (the Tortoise-Scale Shell is a cast ward and is not run as the main ward).
- A soul-defence modifier piece to stand in for the unmodelled Thinned Mind close.
- Engine support for Edge Past the Rack (layer-total readable and a penetration mod key), which would restore some of the lost layer strength as a rule instead of a number.
- Rules of Marked Prey, Whetstone Vow and Blood Casting are not yet written as Effects.

Note: the first probe at `[100, 100, 100, 0, 0]` gave 14 % and a 3.9 s typical fight; `[150, 150, 120, 0, 0]` was chosen as the largest round values that stay at 23 %.
