# Gear baseline

> 2026-11-13. What "typical gear" means in the combat sim, and how named items sit beside it. Observations, not
> verdicts. Numbers from `tools/design/items/lint_items.py` pricing and `tools/design/combat_sim/fight.py`.

## What the typical cultivator already carries

The sim's typical enemy (`fight.py enemy_file`, Combat Formulas B) carries gear in three places:

- **L3, the gear layer: 40 points.** This is the weapon's artifact attack (base × grade × tier, Item Database Formulas
  D) and its Liệt affix. A named weapon of the same grade fills L3 the same way, so it does not double count.
- **Ward strength and block** at the realm's typical values (ward gear's defence through `a_w`).
- **The pools** (`n_body` 1.0883, `n_qi` 1.053), which cover typical health and linh lực from every source.

It carries **no** increased damage from gear: the rolled affix pool (Item Database Formulas D) has no `attack_pct`,
crit or art speed at all. Its affixes are artifact attack and defence, thần thức cost, cultivation speed, health,
pill-toxin and heart-demon resistance, fortune, element affinity and (planned) Physical resistance.

## Rolled against named, by plain W

Both price their modifiers on one scale (Formulas I: 12.8 W per affix a grade allows).

| Realm | Slots (base + extra) | Default grade | Typical rolled gear, every slot filled | Named loadouts in engine-v3 (median, max) |
|---|---|---|---|---|
| Qi Refining | 5 + 2 | 1 | 89 W | — |
| Foundation Establishment | 5 + 3 | 2 | 204 W | 182 W, 200 W (5 builds) |
| Core Formation | 5 + 4 | 3 | 345 W | 212 W, 230 W (16 builds) |
| Nascent Soul | 5 + 5 | 3 | 383 W | 221 W, 252 W (13 builds) |
| Deity Transformation | 5 + 6 | 3 | 422 W | 199 W, 266 W (4 builds) |

- **The same budget works as intended:** a named piece carries about what a rolled piece of its grade does. Named
  loadouts here carry less in total because builds leave extra slots empty for thần thức.
- **What differs is where the W goes.** Rolled W lands mostly outside the fight (health, resistances, cultivation,
  fortune); named W is aimed at the build's engine (damage by element or form, stacks, art speed, crit). So a named
  loadout adds fight power the typical cultivator does not have, and it is meant to: that is what makes it a build piece.
- **Double counting is small.** Named items' damage lines do not overlap anything in the damage layers the builds
  assumed, because no rolled gear gives them. The only shared part is L3, used the same way by both.

## For scale

| Source | Plain W |
|---|---|
| A Meridian Map small node / notable | 1.2 / 8 |
| A technique's passives (Hoàng / Huyền / Địa / Thiên) | 8 / 16 / 24 / 32 |
| One named item, Hạ / Trung / Thượng / Cực | 12.8 / 25.6 / 38.3 / 51.1 |
| A full named loadout at Core Formation | about 210–230 |

One Cực item outweighs a Thiên technique's passives, and a full loadout outweighs any single technique several times.
Gear is a large share of a build's plain power. That may be the intent (Path of Exile style); it is a balance question
for the user, not a sim fault.

## What the sim does with this

- **No change to the typical enemy.** Its gear assumptions are consistent with named items sitting on top. (The typical
  mirror fight is 35 / 38 / 44.5 / 53 / 61 s from Qi Refining to Deity Transformation, inside or at the edge of the
  30–60 s band; see ROUND-SUMMARY's correction.)
- **Optional parity:** the typical enemy could carry the combat share of typical rolled affixes (about +10 % health from
  Hộ Thân, some Physical resistance once Thiết Bích exists). Small; not done.
