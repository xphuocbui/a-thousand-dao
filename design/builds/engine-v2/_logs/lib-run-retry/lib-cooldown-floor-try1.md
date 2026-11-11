# Job transcript: lib-cooldown-floor (try 1)

I rebuilt `cooldown-floor` from the library and fought it at Nguyên Anh. The build barely resembles the guide: Slipstream, which the guide calls the identity piece, has no library equivalent and is lost. The `--without tech:` run printed only the first fight line until I re-ran it, and its numbers are in the .md.

Fights are very short. Against a typical Nguyên Anh foe the build wins 20-0 in 3.0 s, and one realm up it wins 17-3 in 5.9 s. Both are far under the 30-60 s band. Against top-end foes it loses all 20 in about 1.4 s.

**Assumed numbers.** The build had no old fight file, so I assumed the numbers the guide and sheet don't give, and listed them in the file's `_comment` and the .md's first section. I assumed Wind purity 80 and art speed 190, with the scripture's lost passives removed from the sheet's figures. Layers are `[185, 0, 170, 0, 0]` and crit is 0.5 / 3.0. The short fights may owe more to these than to the arts.

**What I chose:**
- **Main technique:** Gale Courier Scripture (`gale-courier-scripture`). It is the only Wind main in the catalogue.
- **Auxiliary technique:** Slow Hour Scripture (`slow-hour-scripture`).
- **Slots:** seven arts fill the 6 + 1 slots. I dropped Swallow Stance because it slows arts 25 %, against the floor.
- **Kept as Effects:** Steady Breath and Still Water.

**What was lost:**
- Slipstream, Light Chaff, Breath Between Blows, Eruption, Overheat and Trigger limit.
- The scripture's own passives and arts, so the build no longer reaches 13 hits a second.
- Sweeping the Floor, the cleanse art.

**`--without` tests:**
- **Main technique removed:** same-realm typical is unchanged (3.0 s, 20-0). One realm up it falls from 17-3 with 85 % health left to 11-9 with 55 %.
- **Hundred-Feather Flurry removed:** this stands in as the identity piece, since Slipstream is lost. Same-realm typical is 3.1 s, 20-0, and one realm up it is 16-4.

**NEVER_FIRED** against top-end foes: Hundred-Feather Flurry, Three-Step Chase, Gale Sprite and Reckless Gale. Against typical foes every art fires.

There is no other-realm file, because the old build had none.

LIB-DONE design/builds/engine-v2/cooldown-floor.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/cooldown-floor.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/cooldown-floor.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/cooldown-floor.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/cooldown-floor.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/cooldown-floor.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/cooldown-floor.md) instead (Edit rules cover all file-editing tools).
```
