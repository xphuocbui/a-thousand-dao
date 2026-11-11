# Job transcript: lib-armoury-mind (try 2)

I rebuilt `armoury-mind` and fought it on engine v2. The fights end in about 1.4 s, far under the 30–60 s band. There were no old fight files to copy from.

- **Old fight files:** the Glob for `armoury-mind*.fight.json` found none, so only the one realm file exists. I derived layers (266/265/250/130/0), the ward (+83/+83) and purity (metal 95) from the guide's numbers. Crit, body, keystones and curses are left at engine defaults.
- **Techniques:** `nine-temper-scripture` (main), `hundred-blades-canon` and `iron-hide-manual`. The last is there for its passives only; its art is not slotted, so it is a thin pick that could be dropped.
- **Arts:** six, filling the six slots: `shatter-edge-cleave`, `sundering-wedge`, `flying-blade-retinue`, `whetstone-pass`, `sheathed-edge`, `blood-quench-blade`.
- **Effects kept as Effects:** Garrison Mind, Full Rack, Humming Shields, Opened Seams, Steady Breath and Iron Skin Renewed.
- **Strike size:** Garrison Mind's 0.1 per weapon is my own value, since the guide only says "small".
- **Lost:** Re-Temper (heal) and Shut the Armoury Door (soul cleanse) have no library equivalent in the Metal suites, and Edge Past the Rack is not modelled by the engine.
- **Fight length:** 1.4 s against the typical enemy at Nascent Soul (20-0), 3.0 s one realm up. The top-end enemy kills the build in about 1.5 s.
- **Arts firing:** only `whetstone-pass` fires (0.8 per fight); the other five are NEVER_FIRED.
- **`--without` tests:**
  - **`tech:nine-temper-scripture`:** no change, 1.4 s before and after.
  - **`garrison-mind`:** 1.4 s becomes 1.9 s at typical Nascent Soul, so the effect is real.

No numbers were tuned and no existing files were edited.

LIB-DONE design/builds/engine-v2/armoury-mind.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/armoury-mind.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/armoury-mind.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/armoury-mind.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/armoury-mind.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/armoury-mind.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/armoury-mind.md) instead (Edit rules cover all file-editing tools).
```
