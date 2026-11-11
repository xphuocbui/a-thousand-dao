# Job transcript: tech-wood (try 1)

I wrote `design/techniques/catalogue-wood.json` (two techniques) and `design/techniques/catalogue-wood.md`. The lint reports 0 findings on the single file, with the expected "whole-catalogue checks skipped" note. I did not run the whole-catalogue lint.

- **Verdant Cycle Scripture (Thanh Hoàn Kinh):** main method, Profound tier, 9 layers, names `moc`. It carries seed-of-spring (layer 1), rooted-form (2), second-spring (4) and harvest-bloom (6). Passives use 15.9 W of 16, and the bonus is `khi_huyet_pct` +12.
- **Rotting Canopy Canon (Hủ Quan Điển):** secret art, Earth tier, 12 layers, names `moc`. It carries thorn-rain (layer 1), blight-canker (2), bloodroot-pact (4) and thornling-grove (6). Passives use 22.1 W of 24, and the bonuses are `tam_ma_resist_pct` +10 and `lifespan_years` +10.
- **Carriers:** none were needed, because all 8 wood arts belong to a suite.

Each suite has 4 arts, which the lint notes as above rule 17's "1-3 signature abilities". That note is the open GDD question already in your checkpoint.

The lint prints W per technique, not per passive line. I tuned the passive values by re-running it. The `.md` has a table per technique, its passives, bonuses and a short build note.

TECH-DONE wood

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-wood.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-wood.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-wood.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-wood.md) instead (Edit rules cover all file-editing tools).
```
