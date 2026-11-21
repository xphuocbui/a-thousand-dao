# Auto decisions — Codex & Karmic Carryover (unattended review loop)

## Round 1 (2026-11-21)
- Item 5 (heir birth mode): chose (a) the heir takes the dead life's birth mode; `cheated` stays per save. Why: smallest change; reborn picks birth mode as a new character as before.
- Item 3 (perk refund): chose to cap `perk_extra` at max(0, unheld - 3) and not offer it in Self-made birth; removes the refund path. Why: names the smaller fix, no new mechanics.
- Item 4 (K_new): Lives book excluded; K_new is a counter kept in the save, rolled back with it. Why: matches reload rule, finite set.
- Item 6 (playthrough id): one id in the save, recorded on the Lives entry. Why: only way to key death_reloaded.
- Item 7 (states): fixed one cell, added Ended-is-a-save-property sentence.
- Item 8 (no-realm heir): costs heir_cost[0].
- Item 9 (r_max of an heir): only realms the heir reaches during the life as successor count, i.e. r_max starts at the heir's realm at succession and karma counts only when r_max exceeds it. Chosen simplest: realm_karma applies to the highest realm reached above the starting realm; an heir who gains none earns realm_karma[start realm] = not counted -> 0. Why: keeps pay-and-die a strict loss.

## Round 2 (2026-11-21, lean)
- Verdict APPROVED with 0 blockers; no GDD edit made. Why: the round-1 fixes hold; remaining items are recommended only and the run rules forbid applying them on approval.
