# Job transcript: lib-sect-ladder (try 1)

I rebuilt `sect-ladder` on the library and fought it on engine v2. The build wins 20 of 20 at its own realm, but the fight runs about 20 s, below the 30–60 s band.

- **Techniques:** one technique, `red-sun-scripture` (hoa main). Its four arts sit at layers 1, 2, 4 and 6, so they fill the four Foundation slots exactly. No auxiliary technique was taken, since a fifth art would not fit.
- **Kept pieces:** `k_burn` 0.3 stays as the Embers Feed the Hearth keystone. Kindled Wound is now an Effect, because the arts may carry no overrides.
- **Realm files:** Qi Refining has Brazier Form and Flint Volley. Core Formation has the same four arts as Foundation, since the suite has nothing past layer 6, so its fifth slot is empty.
- **Foundation, typical:** 20.5 s, 20-0-0. At Core Formation the build wins 16, loses 3 and draws 1, in 21.1 s. At Qi Refining it loses all 20, in 40.6 s.
- **Against stronger foes:** one realm up or top-end foes kill it in 1 to 8 s.
- **Guide claims:** "the pool never empties" only partly holds. You run dry at 17.9 s, near the end of a 20.5 s fight, and the foe runs dry first at 13.2 s.
- **`--without tech:red-sun-scripture`:** 20.2 s, 20 wins, so the passives barely matter here. The suite's value is in its arts.
- **`--without kindled-wound`:** 24.5 s, 19 wins, health left drops from 53 % to 35 %. This is the piece that moves the fight.
- **NEVER_FIRED:** `flint-volley` at the realm-above and two-realms-above matchups, `brazier-form` at two realms above, and all four arts against top-end foes.
- **Losses:** the old Kindle Palm / Red Lotus Ring / Cinder Lance trio was invented, with no library equivalent. Flint Volley and Furnace Heart are the closest, but they cash Burn out rather than lay it endlessly.

The Kindled Wound condition reads `foe.debuff.fire >= 1`, which may not count exactly like "your Burn". I only checked that it runs, not that it matches. The full UNMODELLED list is in the results file.

Files are in `design/builds/engine-v2/`:
- `builds/sect-ladder.fight.json`
- `builds/sect-ladder.luyen-khi.fight.json`
- `builds/sect-ladder.ket-dan.fight.json`
- `sect-ladder.md`

LIB-DONE design/builds/engine-v2/sect-ladder.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/sect-ladder.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/sect-ladder.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/sect-ladder.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/sect-ladder.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/sect-ladder.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/sect-ladder.md) instead (Edit rules cover all file-editing tools).
```
