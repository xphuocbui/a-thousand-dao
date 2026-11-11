# Job transcript: lib-loaded-dice (try 1)

I rebuilt `loaded-dice` from the library and fought it on engine v2. At the same realm it wins 20-0 in 11.4 s, well under the 30-60 s band.

**The build**
- **Main technique:** `thousand-bolt-scripture`. It is the Thunder main whose passives and arts all read or feed crits.
- **Auxiliary technique:** `hundred-echo-palm-scripture`, a body technique. Its fist arts turn crits into shorter timers, the closest library match to Flowing Water.
- **Arts at Kết Đan (5):** `overload-form`, `chain-arc`, `answering-peal`, `capacitor-palm`, `rolling-barrage-fist`.
- **Nguyên Anh file:** the same five plus `twin-shadow-fist`.

**What was lost**
- **Metal pieces:** Counting Blade and Raise the Stakes are gone, because the root is Thunder only and no Metal technique is usable.
- **Thunder Debt and Winnings:** neither has a library equivalent in the chosen suite.
- **House Takes All:** `twin-shadow-fist` is only a loose stand-in.
- **Stacked Meter:** its folded L2 average is dropped, since overrides on arts are not allowed.

**Results**

| Fight | Mean | Record | Dry |
|---|---|---|---|
| Typical, Kết Đan, same realm | 11.4 s | 20-0 | you never, foe at 9.9 s |
| Typical, Nguyên Anh, one realm up | 7.3 s | 0-20 | you at 6.0 s |
| Typical, Hóa Thần, two realms up | 3.1 s | 0-20 | you at 2.8 s |
| Top-end, all three realms | 1.0-1.6 s | 0-20 | you at 1.0 s |
| Nguyên Anh file, typical, same realm | 9.7 s | 20-0 | you never, foe at 7.8 s |

- **`--without tech:thousand-bolt-scripture`:** 11.4 s becomes 11.5 s with 20 wins either way. The technique's passives barely matter; its arts do the work.
- **`--without chain-arc`** (the identity piece): 11.4 s becomes 20.0 s, wins fall from 20 to 15, and health left falls from 69 % to 32 %.
- **NEVER_FIRED:** none in the same-realm typical fights. At Hóa Thần two realms up, `overload-form`, `capacitor-palm` and `rolling-barrage-fist` never fire. Against top-end foes every art never fires.

The guide's old ~17 s and ~12 s figures do not hold. The old numbers came from invented arts and folded averages, so they are not like for like. The fixed crit rhythm is untested because the counted meter is unmodelled. The write-up covers the UNMODELLED lines and the clipped triggers.

Files are in `design/builds/engine-v2/`:
- `builds/loaded-dice.fight.json`
- `builds/loaded-dice.nguyen-anh.fight.json`
- `loaded-dice.md`

LIB-DONE design/builds/engine-v2/loaded-dice.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/loaded-dice.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/loaded-dice.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/loaded-dice.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/loaded-dice.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/loaded-dice.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/loaded-dice.md) instead (Edit rules cover all file-editing tools).
```
