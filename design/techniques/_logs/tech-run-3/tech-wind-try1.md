# Job transcript: tech-wind (try 1)

I wrote the wind techniques to `design/techniques/catalogue-wind.json` and the write-up to `design/techniques/catalogue-wind.md`. The lint reports 0 findings on 2 techniques. It prints the expected note that it skipped the whole-catalogue checks on one file.

I made two techniques, one per suite. No art in the wind family lacks a `group`, so there are no carrier techniques.

| Technique | Kind | Tier | W used | Arts by layer |
|---|---|---|---|---|
| Gale Courier Scripture (Phong Sứ Kinh) | main, names `phong` | Profound (Huyền), 9 layers | 14.6 of 16 | Swallow Stance 1, Hundred-Feather Flurry 2, Three-Step Chase 4, Held Breath 6 |
| Slow Hour Scripture (Trì Thời Kinh) | secret, names `phong` | Earth (Địa), 12 layers | 23.1 of 24 | Trailing Gale 1, Gale Sprite 2, Echo of the Dodge 4, Reckless Gale 6 |

- **Courier passives:** evade, basic attack speed, Wind stack effect and `quick`-scoped art speed. These feed the Feather and Breath counts and the Wind stacks Flurry burns. Its one bonus is `linh_luc_pct` +10.
- **Slow Hour passives:** evade, curse duration, art speed, health leech and healing. These keep Slowed Time up and carry Reckless Gale's health cost. Its two bonuses are `khi_huyet_pct` +8 and `tam_ma_resist_pct` +8.

Both suites have four arts, which the lint notes as above the 1–3 in cong-phap rule 17. That is an open GDD point, which I recorded in the `.md` header. I did not change any art.

The `.md` ends with the lint's final line.

TECH-DONE wind

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-wind.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-wind.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-wind.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-wind.md) instead (Edit rules cover all file-editing tools).
```
