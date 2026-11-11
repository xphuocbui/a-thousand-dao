# Job transcript: tech-water (try 1)

I wrote the water catalogue with three techniques, and `lint_techniques.py` reports 0 findings on it.

| Technique | Kind and tier | W used | Arts and unlock layers |
|---|---|---|---|
| Still Moon Tide Scripture (Tĩnh Nguyệt Triều Kinh) | main, Earth, 12 layers | 23.6 of 24 | Deep Lake Stance 1, Gathering Wave 2, Brimming Cup 4, Swelling Tide Palm 6 |
| Undertow Litany (Hạ Lưu Kệ) | secret, Yellow, 6 layers | 7.8 of 8 | Seep-Through Palm 1, Marrow to Dew 3, Drag of the Deep 5 |
| Returning Wake Verse (Hồi Lưu Thi) | secret, Yellow, 6 layers | 7.6 of 8 | Backwash Seal 1 |

- **Names:** all three name `thuy`. Still Moon Tide Scripture is the main method. Returning Wake Verse is a carrier with no suite, since Backwash Seal has no `group`.
- **Passives:** these are plain numbers aimed at each engine. Still Moon Tide Scripture takes healing, regeneration and Water art speed for Tide. Undertow Litany takes curse speed and duration for Slowed Time. Returning Wake Verse takes Water art speed and crit damage for the echo.
- **Bonuses:** Still Moon Tide Scripture has `linh_luc_pct` +12 and `khi_huyet_pct` +10. The two Yellow techniques have none.
- **Arts:** I did not change any art.
- **Lint run:** it ran on the one file, so the whole-catalogue checks (arts carried across all families) were skipped, as expected. It prints one note: Still Moon Tide Scripture carries 4 arts, above rule 17's "1-3" signature abilities.
- **Files:** the technique list is in `design/techniques/catalogue-water.json`. `design/techniques/catalogue-water.md` has the layer tables, passives with W, bonuses, build notes and the lint's final line.

TECH-DONE water

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-water.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-water.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-water.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-water.md) instead (Edit rules cover all file-editing tools).
```
