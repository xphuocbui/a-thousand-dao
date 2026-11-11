### loaded-dice: Fortune may feed a counted chance (through a keystone)

- **Kind**: Change to an existing rule
- **Touches**: Effects System rule 12 and Formulas A ("Fortune does not shift counted chance"); Combat Formulas I (`khi_van_per_point`)
- **Proposal**: One named keystone, The Loaded Table, may add `0.002 × khí vận` (at most +0.15) to every counted chance its owner has, after the chance's own cap and inside the global caps. It also counts the owner's evade (one chance, as rule 12 allows). The meter still takes no seeded draw, so the fight stays deterministic.
- **Why the build needs it**: It is the whole fantasy. The player gets "luck as a stat" but the luck is prepared (items, formation, pill) and shows as a number on a meter, so nothing is rolled. Without it fortune does nothing for a counted build.
- **Trade-off**: One more path from a soft stat (khí vận) into combat power. It is bounded (+0.15, a named keystone, escape closed) but a gambler with very high fortune hits the bound early; an Ill Star curse (Mệnh Đạo) is its counter.

### loaded-dice: Counted payouts as a readable event

- **Kind**: New system (small)
- **Touches**: Effects System rule 12 and the event list; Combat rule 9 (triggers)
- **Proposal**: When a counted meter reaches 1 it emits a `counted_payout` event with the chance's name. Per modifiers and Effects may read it (Stacked Meter: payouts in the last 8 s; Jackpot: every third crit payout; Winnings: refund on a crit payout). An art guard may read and spend a meter (Cash Out).
- **Why the build needs it**: A counted build has predictable moments but today nothing can hang a reward on them. This lets the payout be the thing the build is built around.
- **Trade-off**: Counted payouts become a trigger source, so they count against `trig_budget` and `trigger_depth` when they fire free hits. The Per cap and Jackpot's crit multiplier cap bound the rest.
