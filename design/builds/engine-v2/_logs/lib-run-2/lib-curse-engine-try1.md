# Job transcript: lib-curse-engine (try 1)

I rebuilt `curse-engine` from library arts and ran it on engine v2. It wins its same-realm matchups but loses the top-end foe at the next realm up and in the Ket Dan file. `--matrix` was run on the Nascent Soul file only; Ket Dan ran once without it.

**Build**
- Main method is `hunters-reach-canon`, with `hundred-blades-canon` and `nine-seal-ledger` as auxiliaries.
- Nascent Soul carries six arts: `pinning-arrow`, `needle-rain`, `sundering-wedge`, `ambush-talisman`, `frozen-hour-seal` and `branding-seal`. Ket Dan has five slots, so it drops `ambush-talisman`.
- Kept as Effects: Litany (four fixed if-chains), Driven Nail, Weight of Names, Marked Prey and Blood Drinker.

**Results (Nascent Soul file)**
- Typical foe at the same realm: 1.9 s, 20-0, full health.
- Top-end foe at the same realm: 5.2 s, 20-0, 95 % health left.
- Top-end foe one realm up: 0-20, you run dry at 4.0 s.
- Ket Dan file against the top-end foe: 0-20 at 8.3 s, you run dry at 7.8 s.

**`--without` tests (typical foe, same realm)**
- `--without tech:hunters-reach-canon`: 1.9 s to 2.0 s, still 20-0.
- `--without driven-nail`: no change, 1.9 s both times.
- Against the same-realm top-end foe the main method moves 5.2 s to 5.3 s and Driven Nail does not move it. Driven Nail only changes the one-realm-up top-end matchup, 4.3 s to 4.5 s, still lost.

Choices worth knowing about:
- **Fight length:** every fight is far under the 30–60 s band.
- **Guide claims:** the guide's 1.5 s win at 70 % health against the top-end foe does not reproduce. Its claim that Driven Nail is core does not hold at the same realm either.
- **NEVER_FIRED:** four arts never fire in the typical same-realm fight because it ends first. `needle-rain`, `sundering-wedge`, `frozen-hour-seal` and `branding-seal` all fire in the other matchups.
- **Purity:** the old file had no `purity`, so I wrote `{"metal": 80, "wood": 40}` from the guide's "Metal–Wood, Metal higher". The amounts are my reading of that.
- **Wood:** all three techniques name only metal, so the wood root is unused.
- **Iron Nail:** no library art matches it, so `branding-seal` stands in. The loss is recorded in the results file.
- **Not checked:** I did not look at whether Sealed Meridian or the fourth Heavy Breath name actually landed in the fights.

Files are in `design/builds/engine-v2/`:
- `curse-engine.md`
- `builds/curse-engine.fight.json`
- `builds/curse-engine.ket-dan.fight.json`

LIB-DONE design/builds/engine-v2/curse-engine.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/curse-engine.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/curse-engine.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/curse-engine.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/curse-engine.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/curse-engine.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/curse-engine.md) instead (Edit rules cover all file-editing tools).
```
