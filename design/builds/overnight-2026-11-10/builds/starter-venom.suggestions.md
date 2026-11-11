### starter-venom: Stack-count Per modifier on ticks
- **Kind:** Rule change
- **Touches:** `design/gdd/modifiers.md` (Per form, scope readables); `design/gdd/effects.md` rule 9a (element stack reads)
- **Proposal:** A modifier may read the number of the applier's element stacks on the target at each tick, as "X % more per N stacks, up to a cap", in layer L2 (not L5, which ticks never use).
- **Why the build needs it:** Patient Venom, the reward for a long poison fight, is a Per on stack count; without it the build's late-game scaling is a flat number.
- **Trade-off:** a tick now reads live state, so the Breakdown must show it. It is bounded by its cap and is NPC-safe.

### starter-venom: Cleanser telegraph in preparation
- **Kind:** Rule change
- **Touches:** `design/gdd/combat.md` rule 12 (preparation and what a foreseen fight reveals); the Guidance Layer
- **Proposal:** Before a foreseen fight, show whether the enemy carries a cleanse (a cleansing ward payload or a cleanse art), as one line on the enemy profile.
- **Why the build needs it:** The build loses 0 to 19 to a cleanser, and the lesson is meant to be learnt in preparation, not by dying. Without the line, a new player has no way to adapt (swap Rot Bloom for a hit art, take Seeds Left Behind).
- **Trade-off:** It gives away part of an enemy's profile, which Combat Open Question 4 treats as information worth paying for; keep it for foreseen fights only.
