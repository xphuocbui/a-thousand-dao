# Job transcript: lib-giant-killer (try 1)

I rebuilt `giant-killer` on the Metal tempering and blade suites, fought it on engine v2, and wrote the fight file and the results `.md`. The rebuild loses the build's identity: no library piece does Half a Realm, so the upward edge does not appear.

- **Techniques:**
  - Main: `nine-temper-scripture` (kim).
  - Secrets: `hundred-blades-canon` (kim) and `iron-hide-manual` (kim). The last is carried only for its physical-resistance passive, and its stance art is not slotted.
- **Arts (5 of 5 slots):** `whetstone-pass`, `sheathed-edge`, `shatter-edge-cleave`, `flying-blade-retinue`, `sundering-wedge`.
- **Realm files:** the old build had no fight file, so there is only the `ket_dan` file.
- **Assumed numbers:** layers [200, 225, 250, 130, 100], crit 0.5 at ×2.0, art speed +50, art cost −20 %, regen +6 pp, accuracy +10, purity metal 80 and earth 80. These come from the sheet and guide, and are in `_comment` and the `.md`.

Results, 20 seeds:
- **Against a typical foe**, same realm and one realm up are 20-0-0, at 1.0 s and 2.0 s. Two realms up is 0-12-8 at 3.9 s.
- **Against a top-end foe**, every row is a loss, at 1.0–1.6 s.
- **Against the 30–60 s band:** all rows are far under it.
- **Why:** the assumed layers, with L5 +100 applied at every gap, overpower the typical foe. No number was tuned.
- **`--without tech:nine-temper-scripture`** and **`--without whet-temper-edge`:** neither changes the same-realm typical row (1.0 s, 20-0-0, before and after). Both only add 2–3 losses of 20 at +2.
- **`--without whetstone-pass`:** this is not an effect id, so I used `whet-temper-edge` as the identity effect instead.
- **NEVER_FIRED:** `shatter-edge-cleave` and `flying-blade-retinue` in every matchup. `sundering-wedge` fires only at typical +2, and `sheathed-edge` in about half the rows.

Lost in the move:
- Half a Realm, Stiff Neck, Through the Ceiling, Mountain Notches, Needle's Eye and the Realm-Piercing affix: no library equivalent.
- Realm pierce and Physical penetration: the engine has no field for them.
- Against the Heavens: kept only as a flat L5 +100, so the gap-0 row overstates.
- Golden Bell and Soul-Guarding Lamp: run as the typical Common Ward.
- Sweeper's Exit: escape is not modelled.
- Bearing the Mountain: no library match, so `iron-hide-manual`'s passives stand in.

LIB-DONE design/builds/engine-v2/giant-killer.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/giant-killer.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/giant-killer.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/giant-killer.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/giant-killer.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/giant-killer.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/giant-killer.md) instead (Edit rules cover all file-editing tools).
```
