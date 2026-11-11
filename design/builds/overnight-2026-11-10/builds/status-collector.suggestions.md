### status-collector: A second Effect may raise Marked Prey's cap

- **Kind**: change to an existing rule
- **Touches**: `design/gdd/effects.md`, Starter Effects, Marked Prey (Limits: Cap +16)
- **Proposal**: an Effect, such as Tally Ten, may raise another Effect's stated cap, to a bound the second Effect names (here +48, twelve kinds). The cap shift is read at compile and shown in the Breakdown beside the Effect it raises.
- **Why the build needs it**: Marked Prey stops paying at four kinds, so the eight others a breadth build collects are worth nothing in L5.
- **Trade-off**: a count-reader at twelve kinds fills L5 on its own; the L5 cap of 100 and the three-curse limit bound it.

### status-collector: A live-count Per modifier in L2

- **Kind**: new rule
- **Touches**: `design/gdd/combat.md` Formulas B (L2), `design/gdd/modifiers.md` (Per form)
- **Proposal**: a modifier may grant L2 "more" per distinct own status on the target, read live each hit, with a stated cap (Crowded Ledger: +3 per kind, cap +36). L5 stays Effects-only.
- **Why the build needs it**: the count has two readers, one in L5 (Marked Prey) and one in L2, so the build's payoff comes from two layers.
- **Trade-off**: L2 is compile-time today; a live L2 term makes a Breakdown change during the fight and gives builds a second way to read a state.
