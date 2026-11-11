### pacifist: Opposed cost payment (Debt Seal, Interest)

- **Kind:** change to an existing rule
- **Touches:** `design/gdd/effects.md` (Blood Casting, rule 11 pay-in-health) and `design/gdd/combat.md` rule 11 (linh lực as one pool)
- **Proposal:** an Effect on one side can make the other side pay a share of each art's cost in health, per stack, capped at 10 stacks and 50 % of a cost; and a second Effect returns 20 % of the linh lực the other side spends, up to 2 % of maximum a pulse.
- **Why the build needs it:** it is the only thing in the build that wounds the foe, and it is the engine.
- **Trade-off:** it puts a health cost on NPC casters, so anti-caster builds are stronger against caster sects; the simulator needs a new foe-side field to test it.

### pacifist: Flight is a win

- **Kind:** change to an existing rule
- **Touches:** `design/gdd/combat.md` Escape (lines about "the fight ends in flight with no winner")
- **Proposal:** when the fleeing side's opponent holds Open Palm Vow, the fight ends as a win for the opponent. A forced escape (Dread of the Ledger) starts the foe's escape channel at 8 or more Seals and half health.
- **Why the build needs it:** "outlast them until they flee" is only a win if the rules call it one.
- **Trade-off:** flight with no winner exists so callers can treat it as a failure; the proposal narrows that for one enabler. Soul Pressure builds would want the same.

### pacifist: Borrow attack into ward strength

- **Kind:** new rule
- **Touches:** `design/gdd/combat-defence.md` Formulas A0 (ward and body layers)
- **Proposal:** Unspent Edge: the character's `attack_pct` counts 50 % as ward strength and body strength.
- **Why the build needs it:** its offence is zero by the Vow, so every attack bonus on gear would otherwise be wasted.
- **Trade-off:** it makes attack gear a defence source for any build that wears it, which can bring up defence above its offence twin, against Combat rule 18.
