### meta-hunter: A curse on how costs are paid

- **Kind:** New Effect (curse) and a readable.
- **Touches:** `design/gdd/effects.md` (curse table, rule 5 readables); `design/gdd/combat-defence.md` Formulas E (cost payment, `art_cost_health_pct`).
- **Proposal:** Dear Blood, a curse: the foe's health-paid art costs are 1.5×. A readable gives the health a side has paid on costs this fight and in the last pulse; Called Debt returns 15 % of the last pulse's amount as a tick. Both need a holder of the Ledger Seal.
- **Why the build needs it:** `notes.md` § 2 says health-paid costs have no counter, and Withering only hurts the builds that also heal. Without a rule on the payment itself, the Hunter would have a bigger number and no answer.
- **Trade-off:** It gives a counter to one pattern, so a health-payer must now weigh meeting a hunter. A foe with status resistance can ignore it. If the 1.5× is too hard it can fall to 1.25×.

### meta-hunter: Incoming status stack cap with overflow

- **Kind:** Rule extension.
- **Touches:** `design/gdd/effects.md` rule 9 (stacking); `design/quick-specs/tree-modifier-catalogue.md` (a keystone row).
- **Proposal:** A wearer's cap on stacks of one named status (here Stagnation, 20). A stack that would exceed it is not applied and adds a small bonus (+0.4 % more, L5, capped at +40 %).
- **Why the build needs it:** Stagnation on hit is the other pattern the sect hunts; at 1 % per stack a cap of 20 removes the curse as a threat, and the overflow makes the pattern feed the hunter.
- **Trade-off:** It makes one curse nearly harmless for holders of the keystone. Applies per status, one keystone, so it does not answer Silence or Sealed Meridian.

### meta-hunter: Quarry knowledge

- **Kind:** Rule change.
- **Touches:** `design/gdd/combat.md` rule 12 (blind fights); world and NPC generation (a sect's listed quarry).
- **Proposal:** A sect may list a pattern as its quarry (health-payers, Stagnation appliers). Against a foe of that pattern the fight is not blind for the hunter, so L4 preparation counts.
- **Why the build needs it:** The hunter's L4 (150 points, a ×2.5 factor in the simulator run) only exists if the fight is not blind, which makes the build the right answer to a known foe.
- **Trade-off:** It gives sect members a prepared layer in some fights, so the world must tag patterns. It does not apply to the player unless the player joins the sect.
