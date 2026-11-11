# Fire (Hỏa) signature arts

8 authored arts in `family-fire.json`, lint 0 findings: 3 standalone, 5 engine (engine_payoff x3.0-x3.6 of the lint,
all gated). Commons (Fire Bolt, Kindle Palm, Ember Rain, Flame Lance, Warm the Hearth) and the kept enablers (Red Lotus
Ring, Feed the Fire) are untouched. Burn is the currency: arts lay it, read it, burn it off, or turn its ticks into
something else. Group ids: `red-sun-scripture`, `ashen-phoenix-canon`. "Group in 3 s" = `own.fired_within.3.group.<id>`.

| Art | Mechanic shape | Power | Hooks | Engine (how to feed it) | One-line rule |
|---|---|---|---|---|---|
| Scorch Fist (Chước Hỏa Quyền) | Conversion | standalone | conversion, physical, fire stacks, burn on foe, crit | Burn on the foe at 8+ turns the three-quarter conversion into a full one (empower) | Physical fist, three-quarters Fire, lays Burn; fully Fire against a foe with 8+ Burn. |
| Blood-Fed Pyre (Huyết Dưỡng Hỏa) | Paying with health, low-health payoff | standalone | low health, health cost, leech, healing | none; it also feeds Ash Rebirth's low-health route | Costs 5 % health; +8 % per 10 % health missing; returns 15 % of damage as health. |
| Brazier Form (Lô Hỏa Thế) | Stance / form | standalone | burn ticks, healing, damage taken, dmg more, stance | none; its state is a feed for Twin Flame Echo | Toggle: +15 % damage, -8 % taken, -15 % art speed, Ember Rain suppressed; hits taken lay Burn on the attacker, Burn ticks mend you. |
| Furnace Heart (Lô Tâm Tích Nhiệt) | Build-up then cash-in (counter, consume) | engine | fire stacks, heat, free hits, crit, counters | Vent step unlocks on 4 Heat (own counter, built by every Fire hit) AND (15 Burn on the foe OR 2 Red Sun arts in 3 s); pays 4 Heat and consumes up to 60 Burn into free hits (more Burn, more hits) | Fire hits build Heat (+1 % Fire more each); the vent hits 2.5x and cashes Burn as free hits. |
| Flint Volley (Đả Thạch Liên Hỏa) | Charges and bursts, split hits | engine | charges, art speed, buff stacks, split hits, cooldown cut | Flashfire step (4 hits at 0.9x) unlocks on (6 own Fire buff stacks, consumed, OR 15 Burn on the foe) AND another Red Sun art in 3 s | 3 charges laying Burn; quick Fire arts quicken all arts; fed, a firing is 4 big hits. |
| Twin Flame Echo (Song Diễm Hưởng) | Echo and repeat | engine | echo, art speed, crit, repeat hits, counters | Bloom step (2.2x and an echo of your last art at 75 %) unlocks on 3 Twin flames (every Fire art counts one) AND (Brazier Form OR 30 Burn OR 3 Red Sun arts in 3 s) | Count Fire arts; when full, hit 2.2x and fire your last art again. |
| Ash Rebirth (Tro Tàn Tái Sinh) | Rebirth from a counter, refuse Down | engine | burn ticks, ash, healing, refuse down, low health | Phoenix Pyre step (5x, 8 Burn, 10 % heal) unlocks on (6 Ash, Burn ticks gather it, spent, OR below 35 % health, Blood-Fed Pyre) AND (20 Burn on the foe OR 2 Ashen Phoenix arts in 3 s) | Burn ticks gather Ash; once a fight 3+ Ash refuses Down and heals; fed, a 5x pyre. |
| Heat Haze (Nhiệt Phù Chướng) | Curse pattern, delay (Slowed Time) | engine | burn stacks, slowed time, tick damage, timer delay, curse | Stifling Heat step (3.5x, +2 Slowed Time, burns 25 Burn into foe delays) unlocks on 25 Burn OR foe dry (linh lực 40 % or less) OR 2 Slowed Time on the foe OR another Ashen Phoenix art in 3 s | Lays Burn and Slowed Time; at 25+ Burn ticks add Slowed Time; fed, a 3.5x delay burst. |

## Suites

**Red Sun Scripture (Xích Nhật Kinh)** `red-sun-scripture`: Furnace Heart, Flint Volley, Twin Flame Echo, Brazier Form.
A tempo suite. Every art counts as a "Red Sun art fired" for the others' steps; Flint's quicken shortens the window, Twin
Flame Echo's bloom echoes whichever art came last (ideally a fresh Vent or Flashfire), Brazier Form is a feed for Twin
Flame Echo and its Burn thorns keep foe Burn above the 30/40 thresholds. Its price: Brazier slows arts by 15 %.

**Ashen Phoenix Canon (Hôi Phượng Điển)** `ashen-phoenix-canon`: Ash Rebirth, Heat Haze, Blood-Fed Pyre. A
grinding-down suite: Heat Haze's Burn and Slowed Time keep the foe ticking (Ash), Blood-Fed Pyre pays health into the
below-35 % route of Ash Rebirth and heals back through its leech, and any two or three of the arts in a row open the
Stifling Heat and Phoenix Pyre steps.

## Library arts replaced

- Burning Reply (`burning-reply`), Cinder Cloak (`cinder-cloak`): Brazier Form.
- Flare Up (`flare-up`): the vent step of Furnace Heart.
- (Remove these three from part-a/part-b when the family is merged.)

## Shape gaps left open

No summon (Cinder Wisp) and no shield-as-weapon art in the family (the engine has summon; no slot was left).

## What the engine could not express

- **Ash heal scaled by a counter, then reset:** the `down` rise needs the scale read and the reset in two Effects and
  relies on Effect order. A per-action scale, or `counter set` after a scaled action, is the missing piece.
- **Suppress by tag:** Brazier Form suppresses Ember Rain by id; `suppress` cannot name a tag (`quick`).
- **Echo target:** `fire_art` "last" may refire the art itself; an "except this art" option is missing. Twin Flame
  Echo's bloom relies on the last art being another one.
- **Charges and `c_art`:** the lint counts Flint Volley per firing, not per volley; there is no charge-aware budget.
- **Step conditions are OR only inside `any`:** "Brazier AND 3 Heat" style compound unlocks cannot be written.
- **No readable for a charge count or an art's own cooldown state**, so no step can key on "charges spent".
- **Heat vent subtracts 10 flat:** a vent that spends all Heat and scales its free hits with it needs a pay that reads a
  counter.
- Untested in a fight: `dmg_more` with an element filter under `scale` (Furnace Heart), `consume` ... `then` inside a
  step `pay` (Furnace Heart, Heat Haze), and `timer` in a foe `then`; only linted.
