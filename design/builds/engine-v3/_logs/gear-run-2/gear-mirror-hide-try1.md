# Job transcript: gear-mirror-hide (try 1)

I geared `mirror-hide` and wrote the fight file and the guide. Gear barely changed the results, and most of what the items carry is not modelled.

**Loadout.** The weapon is Mountain-Mooring Anchor (grade 3). Armour is Boulder-Ring Mail (grade 3). The rings are Ring of Renewed Iron Skin (grade 3) and Clay Seal Ring (grade 1), and the necklace is Necklace of Stone Debt (grade 3). One extra slot holds Unmoving Gate Shield (unique, grade 4, 15 thần thức, against a limit of 46.8). The other three extra slots are empty.

**File changes.** Mooring Drop replaces Sinking Weight. The ward is a drain ward modelled from Boulder Shell. I wrote two engine Effects, `eff:Iron Skin Renewed` and `eff:Shattering Ward`, and kept everything else.

**Results** (20 fights per row; the old file was re-run on the current engine, so its numbers differ from the v2 guide):

| Matchup | Old mean s | Geared mean s | Old W-L | Geared W-L |
|---|---|---|---|---|
| typical, same realm | 5.0 | 5.0 | 20-0 | 20-0 |
| typical, nguyen_anh+1 | 7.1 | 7.5 | 20-0 | 20-0 |
| typical, hoa_than+2 | 24.5 | 19.8 | 20-0 | 20-0 |
| top_end, same realm | 65.0 | 66.1 | 20-0 | 20-0 |
| top_end, nguyen_anh+1 | 51.6 | 46.9 | 11-9 | 9-11 |
| top_end, hoa_than+2 | 2.6 | 2.6 | 0-20 | 0-20 |

- **Linh lực.** The geared build runs dry in all three top_end rows; the old one never did.
- **`--without` tests.** I ran them for the anchor, `eff:Iron Skin Renewed` and `eff:Shattering Ward`. All three gave NO_CHANGE at typical ket_dan+0 (5.0 s, 20-0).
- **Anchor test.** Mooring Drop still fired with the anchor removed, because the file slots its art by hand. That test only removed the anchor's passives, which the engine mostly cannot run.
- **Strata Hammer.** The swap starved it: 3.4 fires per fight at top_end ket_dan+0, down from 10.0. I did not check the cause.
- **Not checked.** I did not read per-Effect fire counts for Shattering Ward, so I don't know if it fired. The guide says so.

**Not modelled.** Unmoved Stance, the Gate Screen standing ward and Debt of Stone could not be run. Debt of Stone would never fire anyway, because the build pays no art in health. Almost every plain modifier on the items has no engine stat, and the guide lists them. The old Return-channel pieces are still unmodelled too.

**Missing pieces.** The guide lists items the build wanted that the catalogue lacks: a Return-channel Effect, a Physical-and-Metal armour that pays Return from block, a health-payment art, and a treasure that banks clipped return.

Files are in `design/builds/engine-v3/`:
- `builds/mirror-hide.fight.json`
- `mirror-hide.md`

GEAR-DONE mirror-hide

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/mirror-hide.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/mirror-hide.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/mirror-hide.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/mirror-hide.md) instead (Edit rules cover all file-editing tools).
```
