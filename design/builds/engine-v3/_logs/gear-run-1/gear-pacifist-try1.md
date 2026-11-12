# Job transcript: gear-pacifist (try 1)

I geared `pacifist` and fought it. The gear did not help, because the geared build runs out of linh lực and its healing arts stop firing.

At typical ket_dan+0 the fight went from 64.0 s (old file, re-run on today's engine) to 66.0 s, still 20 wins of 20 but just above the 30–60 s band. Health left fell from 84 % to 50 %, and the build now runs dry at 5.6 s where it never ran dry before. Against typical nguyen_anh+1 it fell from 13 to 3 wins in 20, with 7 fights running out of time. The v2 guide's 48.8 s doesn't reproduce on today's engine, so the guide compares against the fresh 64.0 s.

- **Cause:** one rule from the Mirror of the Drowned Moon, "arts cost 10 % more", written as `cost_red -10`. With it, `gathering-wave`, `brimming-cup` and `drag-of-the-deep` never fire at ket_dan+0. Removing only that Effect gives 62.9 s, never dry and 94 % health.
- **Other gear:** removing the mirror's modifiers, Backflow or the armour each moved the fight by about a second or less. Most item modifiers (regen, linh lực, health regen and others) have no engine stat, so the gear's real value is under-measured.
- **Skipped:** the Nine-Fathom Abyss Seal. Its Water Table Effect stops your linh lực regenerating in fights, which this build can't take.
- **Not slotted:** the Still-Pool Gourd's own art. The five arts are unchanged.
- **Loadout:** the Still-Pool Gourd, Hundred-Patch Armour, Returning Tide and Dewdrop rings, Moon-Well Pendant, with the Mirror and Brimming Shield as extras. Thần thức used is 33 of 50.4.
- **Approximations:** I wrote Backflow, Sea Already Deep, its cost surcharge and Steady Breath as engine Effects. Steady Breath applies to every art, because the engine can't scope it to one host's arts, and Backflow's cap is approximated as one trigger per pulse.

Files are in `design/builds/engine-v3`:
- `builds/pacifist.fight.json`
- `pacifist.md`

GEAR-DONE pacifist

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/pacifist.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/pacifist.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/pacifist.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/pacifist.md) instead (Edit rules cover all file-editing tools).
```
