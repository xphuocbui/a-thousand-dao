# Job transcript: gear-starter-venom (try 1)

I geared `starter-venom` with seven Wood items and fought it again. The geared fight against a same-realm typical foe is 27.0 s, down from 36.8 s, and the build still wins 20 of 20 at full health. Against stronger foes nothing changed.

The old file was run on the current engine, so its numbers differ from the engine-v2 guide's 30.9 s. The "old" column in the guide is that fresh run.

| Matchup | Mean s, old | Mean s, geared | W-L-other (old and geared) |
|---|---|---|---|
| typical, same realm | 36.8 | 27.0 | 20-0-0 both |
| typical, one realm up | 8.5 | 8.7 | 0-20-0 both |
| typical, two realms up | 4.0 | 4.0 | 0-20-0 both |
| top_end, all three realms | 1.6 / 1.0 / 1.0 | 1.6 / 1.0 / 1.0 | 0-20-0 both |

- **Loadout:**
  - Base slots: Heartwood Hatchet (weapon), Ironbark Cuirass (armour), Ring of the Slow Garden and Sprout Ring (rings), Sap-Heart Pendant (necklace).
  - Extra slots: Verdant Cycle Seal (30 thần thức) and Heartwood Bulwark (15), a total of 45 against a limit of 45. The third extra is empty.
- **Art swap:** the hatchet's art replaced `harvest-bloom`.
- **`--without` results:** removing the hatchet's modifiers gives 30.2 s, and removing the Cycle Seal gives 30.4 s. Both are still 20-0. The two matter about equally.
- **Sap Rises:** I wrote it as an Effect, and removing it changes nothing, because the build ends the fight at 100 % health.
- **What the engine ran:** only the attack and art-speed lines from the items reached the fight. The cuirass, pendant, regeneration and stack lines are listed as unmodelled.
- **Unmodelled:**
  - Spillover is unmodelled because I could not confirm an engine action for draining the foe's linh lực, and its rule text was not in the files I was told to read.
  - The cast wards, the Verdant Aura reserve and the Cycle Seal's art are unmodelled too.
- **30-60 s band:** the fight now sits just under it at 27.0 s.
- **Degeneracy:** nothing became degenerate. The build was never in danger, so the sustain gear has no real test yet.

A `head` pipe broke the first `--without` runs, so I reran them with `grep`.

Files are in `design/builds/engine-v3/`:
- `builds/starter-venom.fight.json`
- `starter-venom.md`

GEAR-DONE starter-venom

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/starter-venom.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/starter-venom.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/starter-venom.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/starter-venom.md) instead (Edit rules cover all file-editing tools).
```
