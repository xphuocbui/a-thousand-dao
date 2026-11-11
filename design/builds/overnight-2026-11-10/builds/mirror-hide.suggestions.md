### mirror-hide: Return channel

- **Kind:** new channel (rule)
- **Touches:** `design/gdd/combat.md` Formulas G (Triggers) and rule 9, with a new G2; `design/gdd/combat-defence.md` rule 1 (the defence path)
- **Proposal:** a free-hit channel "Return": for each incoming hit part that enters the defence path (ticks at weight 0.25), the owner returns `return_share × pre_defence_damage × L1..L4(return) × supp`, delivered as a free Physical hit that meets the target's defence path. Clipped at `ret_cap × U × stage` per hit (ret_cap 2.0). Not a trigger: it uses no `trig_budget` or `trigger_depth`, and a return never causes a return.
- **Why the build needs it:** triggers are capped at half of your own direct damage, so a thorns build cannot be built from triggers. Return scales with what the enemy throws, which is the seed.
- **Trade-off:** a new channel that is strongest against the highest-damage foe; the per-hit cap and depth 1 bound it. Two return builds mirroring each other only end by fatigue.

### mirror-hide: Bait curse changes the enemy's basic cooldown

- **Kind:** rule change
- **Touches:** `design/gdd/combat.md` rule 8 (curses change rules, never pools); `design/gdd/effects.md` Status Catalogue
- **Proposal:** one curse, Bait (Mồi Nhử), shortens the enemy's basic attack cooldown by 20 % for its duration.
- **Why the build needs it:** a return build earns by being hit; the curse is the lever against enemies that attack slowly.
- **Trade-off:** it helps the enemy as well as the cursing build against anything that does not return. Duration is short and it takes a curse slot.

### mirror-hide: Health paid counts as a hit taken

- **Kind:** rule change
- **Touches:** `design/gdd/combat-defence.md` rule 1; `design/gdd/effects.md` event vocabulary
- **Proposal:** when an art costs health, that health is read as one hit taken for the Return channel, at most once per cast.
- **Why the build needs it:** enemies that evade, wait or stall give a thorns build nothing to return; this makes the build its own supply of hits, paid for by health regeneration.
- **Trade-off:** it gives any health-pay build a free return source; limited by the health cost and the art's cooldown.
