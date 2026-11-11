### deity-warden: Boss phase script

- **Kind:** new system
- **Touches:** `design/gdd/combat.md` rule 10 (time), `design/gdd/combat-defence.md` rule 1 (the one-ward rule)
- **Proposal:** an NPC or boss profile may carry a phase list of up to four entries, each with a duration of at least 8 s, a ward model (drain, per hit, reserved, soul or off) and optional stat swaps. The fight clock moves it from one phase to the next; the order is fixed and shown in the Breakdown ("Phase 2 of 4: Lustration").
- **Why the build needs it:** the Warden is four wards that each shut one channel; without a script it is one ward.
- **Trade-off:** the simulator needs a phase clock to prove any boss, and a boss with a fixed list can be memorised, which is the intent.

### deity-warden: Ward-swap gap

- **Kind:** rule change
- **Touches:** `design/gdd/combat-defence.md` rule 1
- **Proposal:** when a holder's ward model changes mid-fight the old ward's remaining capacity is discarded and the holder has no ward for a short window (2 s here), announced by a Toll.
- **Why the build needs it:** it gives the fight a readable opening and stops a player from stripping one ward and hitting the next.
- **Trade-off:** a ward swap becomes a strong action for any holder; players with the Turning Key also gain it, so the gap must stay at 2 s or longer.
