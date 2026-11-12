# Job transcript: gear-dry-well (try 1)

I geared `dry-well` with seven Ice items and fought it again. Gear changed no win or loss, and means moved by about a second.

**Loadout.** Every item comes from the Ice family.
- **Base slots:**
  - weapon: Winter Toll Seal (`ice-winter-toll-seal`)
  - armour: Glacier Plate (`ice-glacier-plate`)
  - rings: Deep Freeze Ring (`ice-deep-freeze-ring`, grade-4 unique) and Rimed Band (`ice-rimed-band`)
  - necklace: Sleeping Marrow Pendant (`ice-sleeping-marrow-pendant`)
- **Extra slots:** Moonrime Flying Sword (`ice-moonrime-sword`, TT 20) and Black Ledger Mirror (`ice-black-ledger-mirror`, TT 18), 38 of the 45 allowed.
- **Arts swapped in:** I replaced Shatter Palm with Toll Stamp (`ice-toll-stamp`) and Black Ice Glaze with Moon Stills the Tide (`ice-moon-stills-tide`). I tried only this one swap, not the alternatives.

**Before and after.** Twenty fights each, seeded.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 7.5 | 6.8 | 20-0-0 | 20-0-0 |
| typical hoa_than+1 | 63.5 | 64.8 | 20-0-0 | 20-0-0 |
| top_end nguyen_anh+0 | 18.1 | 17.1 | 0-20-0 | 0-20-0 |
| top_end hoa_than+1 | 11.9 | 10.2 | 0-20-0 | 0-20-0 |

The old numbers are the engine-v2 file run today, so they differ from the 4.0 s and 13.7 s in the old guide. At typical hoa_than+1, health left fell from 66 % to 49 %.

**`--without` results.** All three were run at top_end nguyen_anh+0, where the geared mean is 17.1 s. Each removed only the item's modifiers. The arts stay in, and no item Effect is run.
- **Winter Toll Seal:** 18.5 s.
- **Moonrime Sword:** 17.7 s.
- **Deep Freeze Ring:** 17.7 s.
- **Foe running dry:** without the Seal the foe runs dry at 13.3 s instead of 10.8 s. The Ring does the same at 13.9 s.

**UNMODELLED.** I wrote no engine Effects, because the engine cannot express any of the three item Effects the build leans on, so there is no `--without eff:` run.
- **Deep Freeze:** the engine has no event for Ice stacks crossing a multiple of 10.
- **Toll Taker:** there is no readable for the extra art cost the foe pays because of your Ice stacks.
- **Shattering Ward:** the build's ward is a drain ward, so there is no shield to break.
- **Carried over:** the Glacier Shell ward does not beat the build's ward, so I kept it. The reserve arts and the item modifiers with no engine stat are listed in the guide.

**Observations.**
- **Fight length:** only typical hoa_than+1 is near the 30-60 s band, and at 64.8 s it is just over. The other three rows run 6.8 to 17.1 s.
- **Degeneracy:** no item made the build degenerate.
- **What fired:** every swapped-in art fired in every row. Glacier Plate, the Sleeping Marrow Pendant and the Black Ledger Mirror add nothing the engine runs.

**Missing pieces.** The guide lists items the catalogue lacks:
- a foe's-ward bill raise
- linh lực debt repaid to the wearer
- Ice sustain for the necklace slot
- a cheap utility piece to fill the last 7 TT points

Files are in `design/builds/engine-v3/`:
- `builds/dry-well.fight.json`
- `dry-well.md`

GEAR-DONE dry-well

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/dry-well.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/dry-well.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/dry-well.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/dry-well.md) instead (Edit rules cover all file-editing tools).
```
