# Job transcript: tech-earth (try 1)

I wrote the two earth techniques to `design/techniques/catalogue-earth.json` and `catalogue-earth.md`. The lint on the JSON ends `checked 2 techniques, 0 findings`.

Each technique carries one whole suite, so all 8 earth arts are carried and no carrier techniques were needed.

| Technique | Kind | Tier | W used | Arts and unlock layers |
|---|---|---|---|---|
| Mountain Heart Canon (Sơn Tâm Kinh) | main, names `tho` | 1 (Huyền), 9 layers | 15.8 of 16 | Mountain Stance 1, Sinking Weight 2, Bastion Reprisal 4, Strata Hammer 6 |
| Deep Vein Scripture (Thâm Mạch Kinh) | secret, names `tho` | 3 (Thiên), 15 layers | 31.9 of 32 | Quarry Offering 1, Stone Warden Call 2, Millstone Palm 4, Aftershock Slam 6 |

The passives lean on Earth stacks plus the suite's own resource: body shield and block for the Canon, health cost and leech for the Scripture. Bonuses are `khi_huyet_pct` 12 for the Canon, and `linh_luc_pct` 15, `lifespan_years` 10 and `tam_ma_resist_pct` 10 for the Scripture.

The lint notes that both techniques carry 4 abilities, above rule 17's "1-3". That is the open GDD point already in the session notes.

The whole-catalogue check for uncarried arts was skipped, as expected for a single file.

TECH-DONE earth

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-earth.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-earth.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-earth.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-earth.md) instead (Edit rules cover all file-editing tools).
```
