# Job transcript: tech-fire (try 1)

I wrote both fire catalogue files, and the lint reports 0 findings. The one-file run printed the expected note that it skips the whole-catalogue checks.

| Technique | Kind | Tier | Passive W | Arts, by layer |
|---|---|---|---|---|
| Red Sun Scripture (Xích Nhật Kinh) | main, names `hoa` | Huyền (1), 9 layers | 15.8 of 16 | Brazier Form 1, Flint Volley 2, Furnace Heart 4, Twin Flame Echo 6 |
| Ashen Phoenix Canon (Hôi Phượng Điển) | secret, names `hoa` | Địa (2), 12 layers | 23.2 of 24 | Blood-Fed Pyre 1, Heat Haze 3, Ash Rebirth 6 |
| Scorch Fist Primer (Chước Quyền Sơ Giải) | secret, names `hoa`, suite "" | Hoàng (0), 6 layers | 7.6 of 8 | Scorch Fist 1 |

- **Carrier:** Scorch Fist is the only fire art with no `group`, so one carrier technique holds it. It is tier 0, so it has no bonuses.
- **Bonuses:** Red Sun gets one line (max linh lực +12 %). Ashen Phoenix gets two (khí huyết +10 %, tâm ma resistance +8 %). All are inside the bonus-pool ranges.
- **Ability count:** the lint prints a note that Red Sun carries 4 abilities where cong-phap rule 17 says 1-3. The suite has four arts, so this is expected.
- **Stack effect pricing:** `stack_effect_pct` and `stack_duration_pct` with an empty scope are priced as universal, not family. My first drafts went over budget for that reason, and I cut those values to fit.

I did not change any art. The `.md` ends with the lint's final line.

TECH-DONE fire

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-fire.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-fire.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-fire.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-fire.md) instead (Edit rules cover all file-editing tools).
```
