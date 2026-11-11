# Job transcript: lib-armoury-mind (try 1)

I stopped before building anything: the old fight files don't exist, and the rebuild depends on them.

- **What I checked:** `design/builds/overnight-2026-11-10/builds/armoury-mind*.fight.json` matched nothing. A wider glob, `design/builds/**/armoury-mind*`, found only `armoury-mind.md`, `armoury-mind.sheet.md` and `_driver/armoury-mind-try1.md`.
- **What is missing:** Rule 1 says to keep the old build's `layers`, `crit`, `ward`, `body`, `keystones`, `curses` and `purity`. Those numbers live only in the fight files. The guide gives the arithmetic (L3 capped at 250, ward +83, multiplier ≈ ×180) and the root (single Metal, purity 90 or more). It doesn't give the L1, L2, L4 or L5 points, crit, body block and resistance, ward payload, or the realm's other fight files.
- **Why I didn't carry on:** Reconstructing them would be tuning numbers, which rule 5 forbids, and it would present invented values as the old build. Reading `armoury-mind.sheet.md` or the driver log would break the "read nothing else" limit, so I left them alone. Nothing was written and no runs were made.

The design side is settled enough to resume from. What I'd choose from the library:

- **Main technique:** `nine-temper-scripture` (Yellow main, Metal; arts at layers 1, 2, 4 and 6). It fits a Metal root and gives `whetstone-pass` and `sheathed-edge`, which count things the build is already doing.
- **Auxiliary:** `hundred-blades-canon` (secret, Metal) for the `flying-blade-retinue` blades, which lay Metal debuff stacks like Garrison Mind does. It carries `sundering-wedge`, the nearest match to Hook and Chain's Sundered.
- **Third slot:** `iron-hide-manual`, or none.
- **Likely losses:** Garrison Mind, Full Rack, Edge Past the Rack, Humming Shields and Opened Seams are Effects from Đạo and the tree, so they stay as they are. The invented arts have no direct library match. Called Blade, Peg-Line Cut (the common art `peg-line-cut` is close), Re-Temper, Rack-Wide Volley and Shut the Armoury Door would each go to the closest library art.

To continue, I need one of these:
- the old fight files at a path I can read,
- permission to read `armoury-mind.sheet.md`, if it holds the numbers,
- the numbers given directly.

LIB-DONE design/builds/engine-v2/armoury-mind.md — NOT WRITTEN. The old fight files were missing, so the build was not rebuilt or fought.

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/armoury-mind.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/armoury-mind.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/armoury-mind.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/armoury-mind.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/armoury-mind.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/armoury-mind.md) instead (Edit rules cover all file-editing tools).
```
