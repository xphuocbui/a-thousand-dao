# Fire (Hỏa) signature arts

8 authored arts in `family-fire.json`, lint 0 findings. The commons (Fire Bolt, Kindle Palm, Ember Rain, Flame Lance,
Warm the Hearth) stay as they are. Burn is the family's currency: every art either lays it, reads it, burns it off or
turns its ticks into something else.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Flint Volley (Đả Thạch Liên Hỏa) | Charges and bursts | charges, art speed, fire stacks, cooldown cut | 3 charges, each a Fire hit laying 2 Burn; quick Fire arts quicken all arts, stacking. |
| Furnace Heart (Lô Tâm Tích Nhiệt) | Build-up then cash-in (counter, consume) | fire stacks, heat, free hits, crit | Fire hits build Heat (+1 % Fire more each, no cap); at 10 Heat it vents up to 40 Burn into free hits and resets. |
| Brazier Form (Lô Hỏa Thế) | Stance / form (state) | burn ticks, healing, damage taken, dmg more | Toggle: more damage and less taken, slower arts, Ember Rain suppressed; hits taken lay Burn on the attacker, Burn ticks mend you. |
| Scorch Fist (Chước Hỏa Quyền) | Conversion | conversion, physical, burn on foe, crit | Physical fist, half converted to Fire, lays Burn, +3 % per 10 Burn on the foe. |
| Blood-Fed Pyre (Huyết Dưỡng Hỏa) | Paying with health, conditional payoff | low health, health cost, leech, healing | Costs 5 % health; +8 % per 10 % health missing; returns 15 % of damage as health. |
| Ash Rebirth (Tro Tàn Tái Sinh) | Rebirth from a counter (ash), refuse Down | burn ticks, ash, healing, fire stacks | Burn ticks gather Ash (no cap); once per fight, at 3+ Ash, refuse Down, heal 3 % per Ash, 12 Fire stacks. |
| Twin Flame Echo (Song Diễm Hưởng) | Echo and repeat | echo, art speed, crit, repeat hits | Every Fire art counts a flame; at 3 this art refires your last art at half. |
| Heat Haze (Nhiệt Phù Chướng) | Curse pattern, delay (Slowed Time) | burn stacks, slowed time, tick damage, timer delay | Lays Burn and Slowed Time; at 25+ Burn each tick adds Slowed Time. |

## Library arts replaced

- Burning Reply (`burning-reply`) and Cinder Cloak (`cinder-cloak`) are covered by Brazier Form (the pain-to-Burn
  reflex is now a stance with a price).
- Flare Up (`flare-up`) is covered by the vent of Furnace Heart (same consume-for-free-hits idea, now fed by a
  counter and repeatable by any Fire build).
- Red Lotus Ring, Feed the Fire, Rekindle and Hearth Mending are kept: they are enablers, not signatures.
  (Remove the replaced three from part-a/part-b when this family is merged.)

## Shape gaps left open

No summon (Cinder Wisp) and no shield-as-weapon art in this family; Fire's ward role stays with the kept arts.

## What the engine could not express

- **Per-fight refusal scaled by a counter, then spending it:** Ash Rebirth needs the heal scaled by Ash and Ash reset
  in one Effect. The engine scales every number in a `do` list, so the reset sits in a second `down` Effect and relies on
  Effect order; a `do` list with its own per-action scale, or a `scale` that reads before a `counter set`, is missing.
- **`state` toggle by art that names its form:** the toggle works, but `suppress` can only name art ids, not tags,
  so Brazier Form suppresses Ember Rain by id; suppression by tag (`quick`) is missing.
- **Heat vent order:** Furnace Heart assumes its `art_fired` Heat grant resolves before the `hit_landed` vent; the
  engine has no explicit ordering between the two events.
- **Echo target:** `fire_art` "last" may refire the echo art itself; an "except this art" option is missing.
- **Mod filter on tags with `scale`:** `dmg_more` filtered by art tag under an `always` scale (Scorch Fist, Pyre)
  has not been run through a fight, only linted.
- **Charge cost:** the lint treats Flint Volley's c_art per firing; a charge-aware c_art budget (per volley) is not
  defined.
