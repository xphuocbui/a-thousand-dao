### starter-flame: Effects action "restore linh lực" on a tick event

- **Kind:** change to an existing rule
- **Touches:** `design/gdd/effects.md` rule 6 (action list) and the event list (tick dealt); Combat linh lực rules for the cap on refunds
- **Proposal:** allow an Effect on the "tick dealt" event with the action "restore linh lực" equal to a share of the tick's damage (Embers Feed the Hearth: 25 %), bounded by the pool maximum and reported in the Breakdown as "Embers: +n linh lực".
- **Why the build needs it:** the whole build's forgiveness comes from Burn ticks paying for the arts that apply them. Without it the build falls back to a regeneration stack.
- **Trade-off:** a Burn build gets near-free sustain, so Burn needs a counter that stays real: cleansing and Fire resistance already do that. It must not stack with other refund Effects without a per-pulse cap.
