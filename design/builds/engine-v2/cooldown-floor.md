# cooldown-floor: The Winnowing Gale (Dương Khang Phong), rebuilt from the library: cheap quick Wind arts held at the 0.5 s cooldown floor, paid by per-hit linh lực.

## Assumed numbers (no old fight file)

This build had no fight file. Realm is Nguyên Anh (nguyen_anh), the guide's defining realm; there is no other-realm file. Everything below is read from the guide and sheet or **assumed**, and the same list sits in the file's `_comment`:

- Root: Wind (phong) purity **80** (guide: 70 or more; the sheet computes at 80). No other element, so only Wind techniques and body techniques are usable.
- Layers `[185, 0, 170, 0, 0]`: L1 is the sheet's +200 minus the scripture's +15 (lost); L2 0 because Light Chaff (scripture +60, Way +80) is lost; L3 +170 (fan and needle); L4 0 (blind, no foreseen fight); L5 0 because Overheat and Eruption are lost, Steady Breath is an Effect.
- Crit 0.5 / 3.0 (the caps, guide rung 4). `art_speed_pct` 190 = tree 87 + fan 30 + Glass Meridians 40 + 33 for Way lines (**assumed**; the sheet's +310 included the scripture's +40 and Light Chaff-era Way lines). `art_cost_pct` 33 (tree). `gain_on_hit_pct` 0.44 (tree 0.29 + fan 0.15). `leech_health_pct` 6 (fan).
- Glass Meridians (−25 % health, half body shield): `n_body` 0.9, body shield 0.15; `n_qi` 1.1; typical Common Ward and typical body block and resistance. `bonus_slots` 1 (the fan): 6 + 1 = 7 slots, 7 arts.
- Kept as Effects: Steady Breath (L5 +12 at qi share ≥ 0.5, written unscoped) and Still Water (overflow heals half).

## The move

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Chaff Needle, Winnowing Toss, Threshing Rain (stack-granting strokes) | Hundred-Feather Flurry | gale-courier-scripture (2) |
| Husk-Splitting Cut, Sieve Palm (foe Wind debuff) | Trailing Gale | slow-hour-scripture (1) |
| Empty-Husk Gust, plain strokes | Held Breath | gale-courier-scripture (6) |
| More strokes per second | Three-Step Chase | gale-courier-scripture (4) |
| Echo (25 % free strike) | Echo of the Dodge | slow-hour-scripture (4) |
| Wind buff stacks as art speed | Gale Sprite, Reckless Gale (art speed from missing health) | slow-hour-scripture (2), (6) |
| Slipstream, Light Chaff, Breath Between Blows, Eruption, Overheat, Trigger limit | none (lost) | - |
| Sweeping the Floor (cleanse) | none (lost) | - |
| Glass Meridians, Still Water, Steady Breath | kept as modifiers and Effects | - |

## Techniques chosen and why

- **Main: Gale Courier Scripture (gale-courier-scripture)**, Profound, names phong. It is the only Wind main in the catalogue, and its passives (art speed +6 [quick], basic speed, Wind stack effect) point at a fast-stroke build. Three of its four arts are in the file (layers 2, 4, 6).
- **Auxiliary secret: Slow Hour Scripture (slow-hour-scripture)**, phong, all four arts (layers 1, 2, 4, 6): Trailing Gale (the foe's Wind-side slow), Gale Sprite (a companion that strikes), Echo of the Dodge, Reckless Gale (art speed rising as health falls, which suits Glass Meridians).
- **Swallow Stance dropped** to fit 7 slots: it makes arts 25 % slower, against a build that wants the floor. Seven arts fill 6 + 1 slots. No second auxiliary (a body technique would add arts beyond the slots).
- Both suites are almost whole, so their group conditions ("3 courier arts in a pulse", "3 slow-hour arts in a pulse") can open.

## What was lost

- **Slipstream** (the identity Effect, art speed clipped by the floor makes cost cheaper): no library equivalent, lost. Nothing in the library pays the 12-fire-a-second bill; the build relies on plain `gain_on_hit_pct` instead.
- Light Chaff L2 "more" for quick cheap arts, Breath Between Blows, Eruption, Trigger limit, Overheat: staged or unreadable, lost.
- The scripture's own passives (art speed +40, on-hit +0.10, cost −20, damage, ward, linh lực bonuses) and its seven arts, including the Wind-stack granting and the six-arts-on-one-timer idea. The library arts carry few Wind buff stacks.
- Sweeping the Floor (cleanse of curses), and Echo as a free-standing Effect (replaced by an art).
- The "13 hits a second" identity does not exist in this build; the arts are slower, heavier engine arts, and several want evades the build does not have (evade 0).

## Matchups

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical nguyen_anh+0 | 3.0 | 20-0-0 | never | 2.7 | echo-crit 4.0 |
| typical hoa_than+1 (one realm up) | 5.9 | 17-3-0 | never | 5.1 | echo-crit 9.0, sprite-dance 0.1 |
| top_end nguyen_anh+0 | 1.4 | 0-20-0 | 1.4 | never | echo-crit 0.6 |
| top_end hoa_than+1 | 1.1 | 0-20-0 | 1.1 | never | echo-crit 0.1 |

## Without tests

| Test | Same-realm typical, before | After | One realm up (typical hoa_than+1), before → after |
|---|---|---|---|
| `--without tech:gale-courier-scripture` | 3.0 s, 20-0, foe dry 2.7 | 3.0 s, 20-0, foe dry 2.8 | 17-3, 85 % health left → 11-9, 55 % left |
| `--without hundred-feather-flurry` (identity piece: the original identity, Slipstream, is lost, so the main suite's engine art stands in) | 3.0 s, 20-0, foe dry 2.7 | 3.1 s, 20-0, foe dry 2.9 | 17-3, 85 % → 16-4, 76 % |

Same-realm typical does not move in either test; the difference shows only one realm up.

## UNMODELLED

- Slipstream: staged, no library equivalent, lost.
- Light Chaff L2 more [quick, cheap]: staged, lost.
- Breath Between Blows, Eruption, Trigger limit, Overheat: staged or no readable for clipped art speed, lost.
- Guide's Echo (25 % free strike): host unspecified, replaced by the library art.
- Winnowing Wind Scripture passives and arts: replaced by library techniques.
- Steady Breath's [phong] scope and the fan's other lines: carried as plain modifiers.
- Wind buff stacks as the art-speed engine: few library arts grant them.
- gale-courier-scripture passive stack_effect_pct +8 [phong]: no engine stat.
- gale-courier-scripture passive art_speed_pct [quick]: the engine applies it to every art.
- slow-hour-scripture passive status_duration_pct +10 [curse]: no engine stat.

## Observations

Against a typical Nguyên Anh foe the fight lasts 3.0 s, far under the 30-60 s band; one realm up it is 5.9 s, still far under, and against top_end the build dies in 1.4 s, so it is lopsided either way and the numbers I assumed (art speed 190, L1 185, L3 170, crit 0.5 / 3.0) may drive that more than the arts do. The guide's claims do not hold in this build: 13 hits a second, six arts on one 0.5 s timer and the 6.6 % linh lực bill all depended on Slipstream, Light Chaff and the scripture's Wind arts, which are lost; "dry you" is never against typical foes, so linh lực was not tested as a limit in fights this short, and the guide's claim that Golden Bell foes go dry cannot be read here (typical foe dry at 2.7 s only). At the top end the foe is never dry and the build is dry at 1.4 s. NEVER_FIRED against top_end (both realms): hundred-feather-flurry, three-step-chase, gale-sprite, reckless-gale (held-breath, trailing-gale and echo-of-the-dodge fire 0.4 or less); against typical foes every art fires. Echo-crit is the only clipped cap.
