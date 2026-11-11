# Earth (Thổ) signature arts

Seven authored arts in `family-earth.json`. Lint: `python -I tools/design/arts/lint_arts.py design/arts/family-earth.json` gives 0 findings (7 arts). Numbers are first guesses. The commons (Gravel Strike, Tremor Palm, Packed Earth Stance, Landslide, Gate Hammer) are untouched.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Strata Hammer (Tầng Nham Chùy) | Build-up then cash-in (counter, no cap) | Earth art count, art speed, heavy hits, free-hit damage | Every Earth art lays a Stratum; each landing spends every 4 for a free 1.2 Physical hit. |
| Mountain Stance (Trấn Sơn Thế) | Stance (state toggle) | dampen taken, Earth stacks, block, health regeneration | Slower strikes and casts, less damage taken; each hit taken adds an Earth stack and a 0.6 free hit answer. |
| Quarry Offering (Thạch Tế) | Paid in health, stacks as a second currency | health cost, Earth buff stacks, healing, dmg_more, leech | Pay 7 % health for 8 Earth buff stacks; every 5 held makes Earth hits deal 3 % more. |
| Sinking Weight (Trầm Trọng Ấn) | Delay: spends debuff stacks for Slowed Time | Earth debuff stacks, Slowed Time, timer delay, accuracy loss | Lays 3 Earth debuff stacks, then spends up to 9 of the foe's, each 3 laying a Slowed Time. |
| Stone Warden Call (Thạch Vệ Triệu) | Summon scaled by stacks | companion speed, Earth buff stacks, summon duration, companion damage | A 14 s warden hits 0.7 every 3 s, 8 % faster per 3 Earth buff stacks. |
| Aftershock Slam (Dư Chấn Kích) | Echo and repeat on a tag | heavy tag, art speed, echo damage, cooldown reduction | Every heavy art counts a tremor; each third repeats your last art at half. |
| Bastion Reprisal (Bích Lũy Báo) | Shield as a weapon | body shield size, Earth debuff stacks, free-hit damage | A 12 % health body shield that bursts into a 2.5 free hit and 6 Earth debuff stacks when it breaks. |

## Library arts these replace

- Mountain-Press Seal (`mountain-press-seal`, `stake-driving-seal`) is replaced by Strata Hammer.
- Stone Rebuke (`stone-rebuke`) is replaced by Mountain Stance.
- Iron Mountain Shield (`iron-mountain-shield`) and Stone-Skin Seal (`stone-skin-seal`) are replaced by Bastion Reprisal.
- Bedrock Breath (`bedrock-breath`) is replaced by Quarry Offering. Its endurance-to-recovery idea is partly kept, so the library should keep the regeneration part as a technique passive.
- Mending Breath (`mending-breath`) is a Water/heal-shaped art and is left alone.
- Sinking Weight, Stone Warden Call and Aftershock Slam replace nothing; they fill the delay, summon and echo shapes the library lacked for Earth.

## What the engine could not express (or I could not verify)

- **Strata and tremor counters** are decremented with a negative `counter` add, scaled by `floor(count / 4)`. Check the engine accepts negative adds and that the add-then-read order of two Effects on one event is stable; if not, a `counter` spend action is the missing piece.
- **Stance `suppress`** is empty. The brief's shape wants the stance to switch off other arts, but no Earth art needed it. Mountain Stance's slowing mods do the trade-off instead.
- **Stance toggle filter** uses a tag (`mountain`) because I did not confirm filtering on `art_id`.
- **Units of `dampen_taken`** (10 in the stance) are a guess. Rule 6a's dampen scale should be checked against it, and the `own.state.<id>` readable against `>= 1`.
- **`fire_art` repeats the last art's hit only.** It does not repeat its Effects, stacks or statuses. That is why Aftershock Slam's echo is damage only.
- **Stack grants through Effects are unpriced** (hand-designed effects, no price check yet), so Quarry Offering's 8 stacks for 15 s and Bastion's 6 stacks are not charged by the lint. They need a pass when Effects get a price.
- **A shield-break filter** is missing: `shield_broken` cannot be limited to the art's own shield, so any body shield of yours triggers Bastion Reprisal's burst.
- **A health-payment refund** hook does not exist. Quarry Offering pays health but nothing in the engine lets a build read "health paid" as a modifier source.
