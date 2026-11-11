# Earth (Thổ) signature arts

Eight authored arts in `family-earth.json`: 3 standalone, 5 engine, in two suites. Built from the first draft (`_draft1/family-earth.json`), which gave the stance, echo, summon, shield and offering ideas; Strata Hammer, Sinking Weight, Bastion Reprisal, Quarry Offering and Stone Warden Call are upgraded into engine arts, Millstone Palm is new. The commons (Gravel Strike, Tremor Palm, Packed Earth Stance, Landslide, Gate Hammer) are untouched.

**Lint status: NOT RUN.** Python execution needed approval this session and none was available, so `python -I tools/design/arts/lint_arts.py design/arts/family-earth.json` has not been run and the "0 findings" result is unconfirmed. I checked the numbers by hand (lint = 1 + 24·cost + 0.25·(cd−1), less the buff/debuff charge): Strata Hammer 3.8 of 4.42; Sinking Weight 2.6 of 2.69; Bastion Reprisal 2.2 of 4.44; Quarry Offering 2.4 of 2.57; Stone Warden Call 3.0 of 4.69; Aftershock Slam 2.9 of 3.20; Millstone Palm 2.0 of 2.02; Mountain Stance 0. Costs 0.03-0.08 and cooldowns 3-10 s are in range. Expected `engine_payoff` of the full forms: Strata Hammer Collapse x4.3, Sinking Weight step 2 x3.4, Bastion Reprisal (both empowers) about x3.7, Quarry Offering step 2 x4.7, Stone Warden Call step 2 x3.2. **Run the lint before trusting any of this.**

| Art | Mechanic shape | Engine (how to feed it) | Hooks | One-line rule |
|---|---|---|---|---|
| Strata Hammer (Tầng Nham Chùy) · engine | Build-up then cash-in (counter, no cap), 3-step chain | Strata laid by every Earth art or hit taken in Stance; foe's Earth debuff stacks; foe Slowed 3 deep; 3 canon arts within 2 s | Earth art count, art speed, heavy hits, Earth debuff stacks, Sundered | Plain, then Fault Line x2.2 (4 Strata), then Collapse x5 that Sunders (8 Strata AND Slowed foe, 3 canon arts in 2 s, or Mountain Stance) |
| Sinking Weight (Trầm Trọng Ấn) · engine | Delay and Slowed Time (steps that spend the foe's debuff stacks) | Foe's Earth stacks (6, then 9); your Strata; Mountain Stance; foe already Slowed 4 deep | Earth debuff stacks, Slowed Time, timer delay, art speed | Spend the foe's Earth stacks for harder hits, Slowed Time and a 2 s delay on every foe art |
| Bastion Reprisal (Bích Lũy Báo) · engine | Shield as a weapon (empowers, shield-break burst) | A standing body shield or Mountain Stance (x3); spending 8 own Earth stacks (x2.5); shield breaks add their own bursts | body shield size, shield breaking, Earth buff stacks, free-hit damage | A 12 % health shield that bursts into a 2.5 hit when broken; the slam grows while the wall stands |
| Quarry Offering (Thạch Tế) · engine | Paid in health, second currency (steps) | Own Earth stacks (8 for step 1; 14 AND (3 deep-vein arts in 8 s or under 40 % health) for step 2) | health cost, Earth buff stacks, healing, dmg_more, low health | Pay 7 % health for 8 Earth stacks; spend them for x2.5 and x5 hits that heal back |
| Stone Warden Call (Thạch Vệ Triệu) · engine | Summon, scaled and multiplied by steps | Own Earth stacks (6 for step 1; 12 AND (3 deep-vein arts in 10 s, under half health or foe Slowed 2 deep) for step 2) | companion speed, companion damage, summon duration, Earth buff stacks | A 14 s warden; spend stacks for a second warden, then two fast wardens and a x5 slam |
| Mountain Stance (Trấn Sơn Thế) · standalone | Stance (state toggle) | Feeds the suite: its Strata and Earth stacks, and it is itself a gate for Sinking Weight, Bastion Reprisal, Warden | dampen taken, Earth stacks, block, free hits on being hit, health regeneration | Slower, tougher; each hit taken gives an Earth stack, a Stratum and a 0.6 answer |
| Aftershock Slam (Dư Chấn Kích) · standalone | Echoes and repeats on a tag | Any heavy art counts (Strata Hammer, Quarry Offering, Gate Hammer, Landslide) | heavy tag, art speed, echo damage, cooldown reduction | Every third heavy art repeats itself at half |
| Millstone Palm (Ma Thạch Chưởng) · standalone | Conversion (half Physical) into Bleed | Lays Earth stacks that Strata Hammer and Sinking Weight spend, and grinds them into Bleed meanwhile | Physical, Bleed, Earth debuff stacks, conversion | Half Physical, lays Earth stacks and Bleed; every 4 foe stacks add another Bleed |

## Suite 1: Mountain Heart Canon (`mountain-heart-canon`)

Strata Hammer, Sinking Weight, Bastion Reprisal and Mountain Stance. The stance is the hinge: each hit taken in it lays a Stratum (Hammer step 1), opens Sinking Weight's step 2 and Bastion Reprisal's x3, and a Bastion shield break lays 2 more Strata. Sinking Weight lays Slowed Time, which opens the Hammer's Collapse. Fire three of the four within 2 s and the Collapse opens with no Strata. A tanky build lives in the stance and counters with Collapses; a faster build uses Sinking Weight as a Strata source.

## Suite 2: Deep Vein Scripture (`deep-vein-scripture`)

Quarry Offering, Stone Warden Call, Aftershock Slam and Millstone Palm. Quarry Offering's stacks pay for the Warden's second warden; any three of the four arts in 8-10 s open the second tier of both engines; Quarry Offering and Aftershock Slam are heavy, so they count for each other's tremors and the echo repeats Quarry's whole hit. Millstone Palm is the quick filler that keeps arts inside the window. A health-pay build leans on Quarry's under-half-health routes; a steadier one rides the group window.

## Library arts these replace

- `mountain-press-seal`, `stake-driving-seal` -> Strata Hammer.
- `stone-rebuke` -> Mountain Stance.
- `iron-mountain-shield`, `stone-skin-seal` -> Bastion Reprisal.
- `bedrock-breath` -> Quarry Offering (its regeneration half should become a technique passive).
- Sinking Weight, Stone Warden Call, Aftershock Slam and Millstone Palm replace nothing.

## What the engine could not express, or I could not verify

- **Lint not run** (see above); `step_unlocked` filters and `event.step` were written from the engine source (`shape()` fires it with `art_id` and the 1-based step) but not executed.
- **Payment is whatever exists.** A `consume` pay is clamped to what is held, so an OR-guard route (low health, group window) spends fewer or no stacks. I could not make a pay depend on which route opened the step; a `pay_if` or per-route steps is the missing piece.
- **Shield spend.** No action removes body shield, so Bastion's empower reads the shield but never spends it.
- **Shield-break filter.** `shield_broken` cannot be limited to Bastion's own shield, so any body shield of yours bursts.
- **`fire_art` repeats only the hit.** It does not repeat Effects, stacks or statuses, so Aftershock Slam's echo of Quarry Offering is damage only.
- **Float stacks.** `consume ... then` passes a fractional count to the follow-up; I avoided it and used `add_statuses` on steps instead.
- **Step effects need `event.step`.** The delay (Sinking Weight), heals (Quarry Offering) and extra wardens (Warden) hang on `step_unlocked`; an override key for `timer`, `heal` or `summon` on a step would be cleaner.
- **Unpriced stacks.** Quarry's 8 Earth stacks for 15 s and Bastion's 6 foe stacks are Effects, so the lint does not charge them (hand-designed effects, unpriced).
- **Stance units.** `dampen_taken` 10 is a guess against Effects rule 6a.
