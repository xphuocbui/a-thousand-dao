### starter-blade: Crit as an event and a self-stack source

- **Kind**: New rule.
- **Touches**: `design/gdd/effects.md` (status families and events), `design/gdd/combat.md` rule 8 (crit).
- **Proposal**: Make "you land a crit" a readable event for Effects. Allow a self-status family (Whet) that gains a stack on that event, with its own timer per stack, a stack cap of 8, and +2 pp crit chance per stack. Also let "you crit within the last N seconds" be a readable condition for an L5 bonus.
- **Why the build needs it**: Whetted Edge, Hot Edge and Flowing Water all hang off the crit event; without it crit is only a flat chance and the build has no loop.
- **Trade-off**: Crit feeding crit adds variance, and Combat rule 15 wants chance to stay a flavour. The stack cap (8 x 2 pp = 16 pp) and the existing `crit_chance_cap` 0.5 bound it, and the loop is deterministic given the seed.

### starter-blade: Overflow on the crit-chance cap

- **Kind**: Rule change (a cap overflow).
- **Touches**: `design/gdd/combat.md` rule 8 and Formulas C (`crit_chance_cap` 0.5, `crit_mult_cap` 3.0).
- **Proposal**: Crit chance above the cap converts to crit multiplier at 1 pp of multiplier per 2 pp over, still bounded by `crit_mult_cap`. Shown in the Breakdown as "crit chance over the cap".
- **Why the build needs it**: A crit build otherwise hits a wall at 0.5 and has nothing to stack; this is the top-end upgrade that turns a working crit build into a finished one.
- **Trade-off**: It gives crit builds a long tail of useful stacking; `crit_mult_cap` 3.0 still stops it, so top-end offence is not raised by more than the multiplier cap already allows.
