# Job transcript: unique-unbroken-edge-ring (try 2)

I wrote the build file and the guide, and ran the matrix and the three `--without` tests. The ring is worth little here: the fights end before any counter has time to bank.

**The build:** a pure Metal Core Formation build. Hunter's Reach Canon is the main method, with Afterimage Sword Canon and Hundred-Blades Canon as auxiliaries. Five arts: Phantom Sword, Flying Sword, Triple Draw, Sword Rain Descends (the weapon's art) and Coiling Thrust.

**Matrix:** it wins 20-0 against a typical Core Formation foe in 8.2 s, with 94 % health left and never dry. It loses 0-20 against every higher realm and every top-end foe.

| Test (typical Core Formation, same realm) | Mean s |
|---|---|
| Everything | 8.2 |
| `--without item:blade-unbroken-edge-ring` | 9.2 |
| `--without eff:Lingering Afterimage` | 8.4 |
| `--without tech:hunters-reach-canon` | 8.5 |

- **Fight length:** 8.2 s is far under the 30-60 s target, and I did not tune it.
- **Ring:** removing it costs 1.0 s, and that is only its plain modifiers.
- **Effect:** it is worth about 0.2 s, because the foe dies before the counters build up.
- **Never fired:** Flying Sword and Triple Draw against typical Hóa Thần+2, and every art against top-end foes. Sword Rain's two-Afterimages-a-pulse cap wasted about 3.9 per fight.

- **Lingering Afterimage:** the engine has no "counter does not decay" verb. I ran it as pulse Effects that add back the 0.1 a pulse the engine's decay takes, so the hold may be off by a tenth. It is three Effect records, and `--without eff:Lingering Afterimage` removes only the Afterimage hold. The Coil hold and the 30 % basic-attack cut stayed in during that test.
- **Ring slots:** I counted the unique as one of the two ring slots. The spec could also be read as the unique plus two more rings.
- **Thần thức:** 36 of 45 used, with one extra slot left empty.

The `.fight.json` I wrote was reported as "updated" rather than created, so a file may have been there before.

Files are in `design/builds/engine-v3/`:
- `builds/unique-unbroken-edge-ring.fight.json`
- `unique-unbroken-edge-ring.md`

UNIQUE-DONE unique-unbroken-edge-ring

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/unique-unbroken-edge-ring.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/unique-unbroken-edge-ring.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/unique-unbroken-edge-ring.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/unique-unbroken-edge-ring.md) instead (Edit rules cover all file-editing tools).
```
