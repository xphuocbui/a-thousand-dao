# Job transcript: tech-body (try 1)

I wrote three body techniques covering all 8 body-family arts, and the lint reports `checked 3 techniques, 0 findings`. On a single file the lint skips the whole-catalogue checks, so that note appeared as expected.

| Technique | Tier | Passive W used | Arts and unlock layers |
|---|---|---|---|
| Unbroken Flesh Canon (Bất Hoại Nhục Kinh) | 0, 6 layers, 0 bonuses | 7.9 of 8 | Marrow Tithe Strike 1, Bulwark Knuckle 3, Last Breath Fist 5 |
| Hundred Echo Palm Scripture (Bách Hưởng Chưởng Kinh) | 1, 9 layers, 1 bonus (linh lực +10 %) | 15.9 of 16 | Answering Palm 1, Twin Shadow Fist 2, Rolling Barrage Fist 4 |
| Mountain Bone Body Art (Sơn Cốt Thể Thuật), carrier | 0, 6 layers, 0 bonuses | 7.7 of 8 | Mountain Root Stance 2, Bone-Turning Palm 5 |

All three are body technique kind with `names` []. One carrier was enough because the two group-less arts have no element, and I made it tier 0. The passives feed each suite's engine:
- **Unbroken Flesh Canon:** body shield, increased health regeneration and maximum health.
- **Hundred Echo Palm Scripture:** palm crit and damage, plus art speed and art cost for physical arts.
- **Mountain Bone Body Art:** block, body shield, physical resistance and force damage.

Files are in `design/techniques/`:
- `catalogue-body.json`
- `catalogue-body.md`

TECH-DONE body

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-body.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-body.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-body.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-body.md) instead (Edit rules cover all file-editing tools).
```
