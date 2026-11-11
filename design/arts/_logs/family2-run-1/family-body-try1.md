# Job transcript: family-body (try 1)

I wrote the body-form family: 8 signature arts in `design/arts/family-body.json` and the table, suites and gap notes in `design/arts/family-body.md`. The lint prints 0 findings. I did not run any of them in a fight.

**Engine arts (5)**
- **Marrow Tithe Strike (Tủy Cống Quyền)** pays health. It writes Debt, which its two steps spend. The 4x and 11x steps are opened by Debt, low health, or three canon arts fired within 2 s.
- **Last Breath Fist (Tàn Tức Quyền)** hits harder the more health you are missing. Its 3x and 6x steps are opened by low health, Debt, or the canon-arts group; the 6x step also Exposes.
- **Bulwark Knuckle (Thuẫn Quyền)** uses a body shield as the weapon. Its 3.5x and 10x Force steps are opened by shield size plus the stance, a Ram counter, or the group.
- **Answering Palm (Ứng Hưởng Chưởng)** is the echo. Its 3.5x and 6x steps are opened by echo count, group arts, a Slowed foe, four distinct arts in a pulse, or a Rolling Barrage Fist just fired.
- **Rolling Barrage Fist (Cổn Liên Quyền)** has 4 charges. Tempo from any fist art opens a 4x Cascade and then a four-hit Rain, with group or Slowed Time as alternative routes.

**Standalone arts (3)**
- **Twin Shadow Fist (Song Ảnh Quyền)** is the summon.
- **Mountain Root Stance (Sơn Căn Thế)** is the toggle stance.
- **Bone-Turning Palm (Chuyển Cốt Chưởng)** is the conversion, with half the blow landing as Force.

**Suites**
- **Unbroken Flesh Canon (Bất Hoại Nhục Kinh)** is Marrow Tithe Strike, Last Breath Fist and Bulwark Knuckle.
- **Hundred Echo Palm Scripture (Bách Hưởng Chưởng Kinh)** is Answering Palm, Rolling Barrage Fist and Twin Shadow Fist.

The lint reports full-step payoffs at 4.1–5.3x the art lint. First steps run 1.4–3.0x. No library art is replaced.

Engine gaps, all listed in the `.md`:
- An art cannot grant a refused fall, so I dropped that from Last Breath Fist.
- A step's `pay` runs whichever route opened it, so a low-health route still spends Debt (floored at 0).
- There is no `own.charges` readable.
- Shield can only gate a step, not be spent as a cost.
- Conversion does not retag the hit for Force-scaled modifiers.

FAMILY-DONE design/arts/family-body.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-body.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-body.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-body.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-body.md) instead (Edit rules cover all file-editing tools).
```
