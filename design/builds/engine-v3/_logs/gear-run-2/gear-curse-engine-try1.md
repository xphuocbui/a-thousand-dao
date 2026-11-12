# Job transcript: gear-curse-engine (try 1)

I geared `curse-engine` and wrote the fight file and guide, but the gear did not help. Against a top-end same-realm foe the fight went from 6.2 s to 8.7 s.

The loadout is the Thousand-Cut Returning Sword, Hollow Robe, Hollow Ring, Ring of the Open Vein and Ledger-Murmur Pendant in the base slots. The extra slots hold the Ledger Seal (30 thần thức) and the Ledger Branding Iron (15), which comes to 45 of 45. I counted only the build's own thần thức percentage (none), not the items' own bonuses. The Ledger Stamp replaced `ambush-talisman` in the art slots.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 2.5 | 2.5 | 20-0-0 | 20-0-0 |
| typical hoa_than+1 | 4.7 | 4.9 | 20-0-0 | 20-0-0 |
| top_end nguyen_anh+0 | 6.2 | 8.7 | 20-0-0 | 20-0-0 |
| top_end hoa_than+1 | 6.5 | 7.8 | 0-20-0 | 0-20-0 |

- **Old numbers:** these come from a fresh run of the old file. They differ from the old guide's printed numbers because the engine has changed since.
- **Dry-out:** the geared top-end same-realm fight now runs out of linh lực at 8.8 s. The old build never did.
- **Which item matters:** removing the sword gives 8.8 s and never runs dry. Removing the Ledger Seal gives 8.6 s and removing the Branding Iron 8.9 s. The sword's art speed applies to every art, which probably drains the linh lực.
- **Fights stay short:** every fight is well under the 30–60 s band.
- **Most of the loadout fires nothing:** the engine cannot run status duration, stack effect or stack duration, and the pendant's reserve art is not run.
- **No item Effects written:** I wrote no `eff:` records, so there is no `--without eff:` run. The Scripture already carries Marked Prey and Blood Drinker, and a second copy would have double-counted. Both are listed as UNMODELLED.
- **Stray file removed:** my first attempt to build the fight file with a helper script was blocked, so I wrote the JSON by hand and deleted the helper afterwards.

Files are in `design/builds/engine-v3`:
- `builds/curse-engine.fight.json`
- `curse-engine.md`

GEAR-DONE curse-engine

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/curse-engine.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/curse-engine.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/curse-engine.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/curse-engine.md) instead (Edit rules cover all file-editing tools).
```
