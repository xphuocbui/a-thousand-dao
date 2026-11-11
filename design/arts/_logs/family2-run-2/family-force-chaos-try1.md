# Job transcript: family-force-chaos (try 1)

I wrote both Force/Chaos files, and the lint prints 0 findings (`checked 8 arts in 1 files, 0 findings`). I did not run any fight simulation, only the lint, so every number is a first guess.

There are 8 arts: 5 engine and 3 standalone, in two suites. The 13 gated payoffs run 1.7 to 4.7 times the lint; the full-power ones are 2.9 to 4.7 times.

- **Hollow Tide Scripture (drain):** Marrow-Siphon Palm and Hollowing Strike are the engine arts, and Hollow Husk Stance is the standalone that feeds them. Qi Disruption burn ticks build a shared Drink counter that both arts spend.
- **Ruin Ledger Scripture (curses):** Fraying Thread, Gathered Ruin Verdict and Ripening Curse are all engine arts. A shared Fray counter rises with every status you land. Each of the three also has a route that needs no Fray, so a stack-heavy build can run the suite without it.
- **Standalone:** Bloodletting Rite (pays health) and Shearing Palm (converts half to Chaos). Hollow Husk Stance also counts as a feed for the Hollow Tide arts.
- **Feeding routes:** every engine art has two or three feeding routes.

The engine could not express a few things, which the .md also names:
- **Held payload:** the Verdict's held payload can be spent by its own firing.
- **Single `pay` per step:** Siphon step 3 takes Drink even when the dry-foe route unlocked it.
- **Status tags:** `status_applied` carries no tags, so Fray and the Verdict also count element stacks.
- **`hp_cost` is not priced by the lint:** I cut Bloodletting Rite from 2.7 to 2.5 to leave room.
- **Stance sign:** the Husk stance's cost rise relies on a negative `cost_red`, and I didn't confirm the sign.

Files are in `design/arts`:
- `family-force-chaos.json`
- `family-force-chaos.md`

FAMILY-DONE design/arts/family-force-chaos.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-force-chaos.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-force-chaos.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-force-chaos.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-force-chaos.md) instead (Edit rules cover all file-editing tools).
```
