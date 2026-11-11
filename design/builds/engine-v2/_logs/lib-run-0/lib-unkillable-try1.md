# Job transcript: lib-unkillable (try 1)

I rebuilt `unkillable` on engine v2 and wrote both files, but the fight is too short and the build's main enabler could not be modelled.

The glob found no old `unkillable*.fight.json` files. That means I had no old layers, crit, ward or body to keep, and no other-realm file to write. I wrote only the Hóa Thần (`hoa_than`) file, with those numbers taken from the guide's figures. Several of them (Growth Rings, Sap Rises, Still Water amounts) are my guesses at the engine's units.

**Build**
- **Techniques:**
  - `verdant-cycle-scripture` (main) carries four arts: `seed-of-spring`, `rooted-form`, `second-spring` and `harvest-bloom`.
  - `rotting-canopy-canon` (secondary) carries three: `blight-canker`, `bloodroot-pact` and `thornling-grove`.
  - `unbroken-flesh-canon` (body) adds only its passives and takes no art slot.
- **Slots:** all 7 are filled.
- **Dropped:** `thorn-rain`, because `rooted-form` suppresses it.

**Results**

| Matchup | Mean s | W-L | You dry | Foe dry |
|---|---|---|---|---|
| typical Hóa Thần | 11.3 | 20-0 | never | 9.5 |
| top_end Hóa Thần | 1.6 | 0-20 | 1.6 | never |

- **Fight length:** the typical fight is far under the 30–60 s band.
- **Alpha strike:** the guide's claim holds. The top_end foe kills the build before any art fires, so all seven arts are NEVER_FIRED there.
- **`--without tech:verdant-cycle-scripture`:** 11.5 s, foe dry 9.7.
- **`--without still-water`:** no change. Surplus Life itself can't be written, so Still Water stood in as the identity piece.
- **Guide's claims:** its 25 s and 66–72 s figures do not hold here.

**Losses**
- **Surplus Life:** the engine only emits linh lực overflow, not health overflow, so the build's enabler is unmodelled and this result does not test it.
- **Library gaps:** Underground Spring, Banyan Shade and Shedding Bark have no library art.
- **Wards:** only the realm's Common Ward is modelled.
- **Water purity:** it now feeds nothing.

LIB-DONE design/builds/engine-v2/unkillable.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/unkillable.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/unkillable.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/unkillable.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/unkillable.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/unkillable.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/unkillable.md) instead (Edit rules cover all file-editing tools).
```
