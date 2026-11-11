# Job transcript: lib-two-clocks (try 1)

I rebuilt two-clocks from the library and fought it on engine v2. The rebuilt build wins every fight against a typical foe and loses every fight against a top-end foe.

The old build had only one fight file (nguyen_anh), so there is no second-realm file.

- **Techniques:** red-sun-scripture (main), ashen-phoenix-canon and rotting-canopy-canon (auxiliary).
- **Arts:** flint-volley, heat-haze, furnace-heart, thorn-rain, blight-canker and thornling-grove, which fill the six slots at nguyen_anh.
- **Purity:** I added fire 80 and wood 80 from the guide, because the old file carried none.

| Matchup | Mean s | W-L |
|---|---|---|
| typical nguyen_anh | 20.5 | 20-0 |
| typical hoa_than+1 | 54.7 | 20-0 |
| top_end nguyen_anh | 8.0 | 0-20 |
| top_end hoa_than+1 | 3.7 | 0-20 |

- **Fight length:** 20.5 s at the same realm is under the 30-60 s band; 54.7 s one realm up is inside it.
- **Guide's claims:** they no longer hold. The guide has the ordinary cultivator dead at about 4 s and a strong foe beaten at about 8 s; the engine gives 20.5 s and a loss at 8.0 s.
- **Lost pieces:** Ember Rain and Rot Seed are common arts, and a common technique brings only one art. flint-volley and thorn-rain stand in for them. Spring Sap and Golden Light Shield have no carried library art in these techniques and were dropped.
- **Identity test:** Ash Ledger is unmodelled and has no library equivalent, so I used blight-canker as the identity test. Without it the typical nguyen_anh fight goes from 20.5 s to 26.3 s. At hoa_than+1 it goes from 54.7 s to 66.0 s, and health left falls from 100 % to 30 %.
- **Main technique test:** removing `tech:red-sun-scripture` barely moves anything (20.5 s to 20.2 s at typical nguyen_anh).
- **Top-end results:** the `--without` runs left them unchanged (0-20).
- **Never fired:** flint-volley never fires against the top-end foe. At top_end hoa_than+1 heat-haze, thorn-rain, blight-canker and thornling-grove never fire either.
- **Unmodelled:** the Incense Clock, Ash Ledger, Spillover, Embers Feed the Hearth, Cinder Debt, tick billing against the ward, and several technique passives with no engine stat. The write-up lists each with its reason.

Files are in `design/builds/engine-v2/`:
- `builds/two-clocks.fight.json`
- `two-clocks.md`

LIB-DONE design/builds/engine-v2/two-clocks.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/two-clocks.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/two-clocks.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/two-clocks.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/two-clocks.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/two-clocks.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/two-clocks.md) instead (Edit rules cover all file-editing tools).
```
