# Wind (Phong) signature arts

8 authored arts (3 standalone, 5 engine), lint 0 findings (`python -I tools/design/arts/lint_arts.py design/arts/family-wind.json`).
Wind is speed, evade, many light hits and tempo. Evade and the basic attack are the fuel; the engine arts turn them into
counts, held payloads and gated multi-step payoffs (engine_payoff 2.2-4.8x of the lint; the full steps 3.0-4.8x).

| Art | Power | Mechanic shape | Hooks | One-line rule | Engine (how to feed it) |
|---|---|---|---|---|---|
| Hundred-Feather Flurry (Bách Vũ Loạn Phong) | engine | Build-up, cash-in (counter, no cap) | basic speed, basic_coef, evade, Wind stacks, free hits, crit | Basics and evades gather Feathers; firing releases a 0.1 hit each and spends them | Step 2 (x2): 5 Feathers OR Swallow Stance. Step 3 (x3.5, burns 3 Wind stacks, 0.4 hit per stack burned): 8 Feathers AND (Slowed Time on foe OR Swallow Stance OR 3 courier arts in a pulse) |
| Swallow Stance (Yến Hành Thế) | standalone | Stance (state) | basic speed, evade, Wind stacks, art speed | Toggle: basics +10 % speed, +12 evade, arts -25 % speed; evades in it give Wind stacks | Feeds others: it is a step-2 / empower key for Flurry and Echo |
| Three-Step Chase (Tam Bộ Truy Phong) | standalone | Charges and bursts, timed momentum | charges, cooldown recovery, dash-tag more, evade | 3 charges, each gives evade; each Stride in 6 s adds 4 % more to dash arts | Counts as a courier art fired (group condition) |
| Held Breath (Bế Tức Phong) | engine | Held payload ("your next art") | evade, held size, any art, Wind stacks, free hits | Each evade banks a Breath (cap 10); your next art spends them as 0.2 hits + Wind stacks (the count resets only when Held Breath fires) | Empower (x3.5): 2 Breath AND (Swallow Stance OR Slowed foe OR 3 Wind stacks OR 3 courier arts in a pulse). Breath fed by every evade |
| Echo of the Dodge (Hồi Phong Ảnh) | engine | Echo and repeat (counter, no cap) | evade, crit, last art's power, free hits | Evades and crits count Echoes; firing replays your previous art once per Echo at 25 % | Empower (x3.5): 3 Echoes AND (Slowed foe OR Swallow Stance). Echoes fed by evade OR crit |
| Reckless Gale (Mệnh Phong Bộ) | engine | Paying with health, low-health payoff, steps | low health, leech, healing, art speed, Wind stacks | Costs 6 % health; +10 % art speed per 10 % health missing | Step 2 (x2): <=60 % health OR refired within 5 s. Step 3 (x3.5, 12 % health, burns 4 Wind, 0.3 hit per stack burned): <=50 % health AND (foe <=30 % OR 6 Wind stacks) |
| Trailing Gale (Lưu Phong Chướng) | engine | Curse pattern, delays (Slowed Time) | evade, Slowed stacks, curse duration, timer pressure | Lays 2 Slowed Time; evades delay the Slowed foe's longest timer | Step 2 (x2, delay 1 s): Slowed Time 2 OR foe dry. Step 3 (x3.5, delay all 1 s): Slowed 3 AND (Slowed 5 OR 3 slow-hour arts in a pulse OR 3 Echoes) |
| Gale Sprite (Phong Linh Đồng) | standalone | Summon scaled by stacks | companion speed, Wind stacks, evade | Sprite strikes 0.45 a second for 12 s; Wind stacks and evades speed it | Counts as a slow-hour art fired |

## Suites (group ids)

**gale-courier-scripture** (Flurry, Swallow Stance, Three-Step Chase, Held Breath): the basic-attack and evade tempo set.
Swallow Stance raises basic speed and evade, so Feathers and Breath fill faster and it is itself a step key. Chase's
charges fire two or three arts in one pulse, which satisfies the "3 courier arts fired in one pulse" gate of the Flurry
step 3 and the Held Breath empower; Held Breath's spent Wind stacks are what Flurry step 3 burns.

**slow-hour-scripture** (Trailing Gale, Reckless Gale, Echo of the Dodge, Gale Sprite): the borrowed-time set. Trailing
Gale's Slowed Time unlocks steps in Echo and (via the foe) the others; Echo's counter unlocks Trailing step 3; Reckless
Gale's art-speed rises as health falls and its Wind-stack route lets the Sprite's stack scaling pay twice; the Sprite
adds a body that keeps firing while the build spends health.

## Library arts replaced

- Threshing Rain, Winnowing Toss -> Hundred-Feather Flurry.
- Riding the Gust, Cooldown Floor, Evade Dancer -> Swallow Stance.
- Hollow Step -> Three-Step Chase.
- Gale Crown (Cuồng Phong Quán) -> Reckless Gale.
- Held Breath, Echo of the Dodge, Trailing Gale, Gale Sprite are new.
- Kept as they are: the five commons (Chaff Needle, Reed-Cutting Breeze, Sieve Palm, Empty-Husk Gust, Falling Leaf).
  Gale Veil, Scatter Gale, Sweeping the Floor left in part-b/c.

## Shapes not used

Conversion and split hits: Wind has no natural damage-type story and eight shapes already differ.

## What the engine could not express (or was not confirmed)

- **Tag-based stance suppression**: `suppress` takes art ids only; Swallow Stance uses an art-speed malus instead.
- **Counter spend as an explicit action**: Flurry, Echo and Held Breath reset with `counter set 0` in the same event;
  this assumes `scale` reads before the actions run. The lint only checks schema; none of these ran in `fight.py`.
- **Step `pay` with a short pool**: `consume` of own Wind stacks takes what is there; whether a step still fires when
  fewer stacks exist than `n` is as in the engine (it does not refuse), so those "burn 3/4 Wind" costs are soft.
- **Step override `hp_cost`** (Reckless Gale step 2) passed the lint; the fight engine was not run to confirm it is applied.
- **Held payload cap**: `held` without a `cap` replaces rather than accumulates, so Held Breath carries cap 10 - a cap the
  art states itself.
- **A banked `mod`** is dropped by `spend_banked`, so the held payload uses a free hit and stacks, not "+X % more".
- **Free hits are trigger-budgeted** (`trig_cap`, `trig_budget`): big Feather, Breath or Echo counts are clipped by the
  budget, so scaling is limited by the engine, not the art. A rule question for the review.
- **`fire_art which: last`** inside Echo: whether "last" excludes Echo itself is unconfirmed.
- **`companion_speed`** units (percent vs fraction) unverified; read as percent.
