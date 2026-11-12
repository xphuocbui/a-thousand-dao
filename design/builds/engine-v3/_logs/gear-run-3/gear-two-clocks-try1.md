# Job transcript: gear-two-clocks (try 1)

I geared Two Clocks with seven items and fought it again. Gear helped only against the typical foe, and only a little. The top-end foe still wins all 40 fights.

**Loadout:**
- **Base slots:** Ashen Phoenix Fan (weapon), Grave-Silk Robe (armour), Ring of the Slow Garden, Cinder Ring, and Hearth-Keeper Pendant.
- **Extra slots:** Undying Ember Lantern and Furnace-Mouth Gourd, for 40 thần thức against a limit of 54. Three extra slots are empty.
- **Art swaps:** Ash-Feather Gale replaced heat-haze, and the Gourd's art replaced thornling-grove.
- **Effect written:** Kindled Wound, as `eff:Kindled Wound`.

**Results (20 seeds each):**

| Matchup | Mean s, old | Mean s, geared | W-L-other (both) |
|---|---|---|---|
| typical nguyen_anh+0 | 34.6 | 29.8 | 20-0-0 |
| typical hoa_than+1 | 66.0 | 65.0 | 20-0-0 |
| top_end nguyen_anh+0 | 13.9 | 12.8 | 0-20-0 |
| top_end hoa_than+1 | 5.8 | 5.7 | 0-20-0 |

- **Old numbers:** The "old" column is the engine-v2 file run on today's engine. It gives 34.6 s where the v2 guide said 20.5 s, so the engine has changed since that guide was written.
- **Fight length:** The typical nguyen_anh+0 fight at 29.8 s is just under the 30-60 s band, and typical hoa_than+1 at 65.0 s is over it.
- **`--without` tests:** Run against the typical foe, since the file's default enemy is top_end.
  - Removing Kindled Wound costs 3.2 s (29.8 s to 33.0 s).
  - Removing the Gourd's modifiers costs 0.9 s.
  - Removing the Fan's, the Robe's or the Lantern's modifiers changes nothing, which points to cap clipping. The `--without` flag removes an item's modifiers only, not its art, so the Fan's art Ash-Feather Gale was not isolated.
- **Unmodelled:** Fan the Pyre, Spillover, Grave-Silk Shroud and Embers Never Die can't be expressed in the engine. Much of the gear's value also sits in stack-duration and stack-effect modifiers that the engine has no stat for.

The Grave-Silk Veil ward was not swapped in for the build's ward, so the old ward model stays. The guide lists the upgrades to look for and the missing pieces.

Files are in `design/builds/engine-v3/`:
- `builds/two-clocks.fight.json`
- `two-clocks.md`

GEAR-DONE two-clocks

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/two-clocks.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/two-clocks.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/two-clocks.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/two-clocks.md) instead (Edit rules cover all file-editing tools).
```
