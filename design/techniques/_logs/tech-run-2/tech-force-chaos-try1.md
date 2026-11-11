# Job transcript: tech-force-chaos (try 1)

I wrote three techniques for the force-chaos family, and the lint reports 0 findings. The lint skips its whole-catalogue checks on a single file, as expected.

| Technique | Tier | Kind | Passive W | Arts carried (unlock layer) |
|---|---|---|---|---|
| Hollow Tide Scripture (Không Triều Kinh) | Earth (Địa), 12 layers | main | 23.9 of 24 | Marrow-Siphon Palm (1), Hollow Husk Stance (2), Hollowing Strike (4) |
| Ruin Ledger Scripture (Phế Trướng Kinh) | Profound (Huyền), 9 layers | secret | 15.6 of 16 | Fraying Thread (1), Ripening Curse (3), Gathered Ruin Verdict (6) |
| Tearing Force Rites (Xé Chấn Nghi) | Yellow (Hoàng), 6 layers | secret | 7.4 of 8 | Shearing Palm (1), Bloodletting Rite (3) |

- **Element id:** every arts in this family is element-less, so I named `hon_don` in all three. It is the closest fit for Chaos, and you may want a different id.
- **Passives:** each technique's passives feed its own engine. Hollow Tide gets force and over-time damage, a status-duration line, a force art-cost cut and a linh lực leech. Ruin Ledger gets curse art speed, curse status duration, chaos damage and a curse art-cost cut. Tearing Force Rites gets force crit chance, health leech and chaos resistance penetration.
- **Bonuses:** Hollow Tide has linh lực +12 % and khí huyết +10 %. Ruin Ledger has tâm ma resist +10. Tearing Force Rites has none, because Yellow has `bonus_count` 0.
- **Carrier:** Shearing Palm and Bloodletting Rite are the only arts with no group, and I put both in one tier 0 carrier since they share no element.

Files are in `design/techniques/`:
- `catalogue-force-chaos.json`
- `catalogue-force-chaos.md`

TECH-DONE force-chaos

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-force-chaos.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-force-chaos.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-force-chaos.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-force-chaos.md) instead (Edit rules cover all file-editing tools).
```
