# Job transcript: unique-ninth-tribulation-seal (try 1)

I wrote the build file and the guide and ran the four matrix runs. The seal does not make this build: against a same-realm foe it is worth about 1.1 s.

**What the build is.** The Verdict Under the Seal (Cửu Kiếp Ấn Phán) is a Core Formation (Kết Đan) Thunder (lôi) 100 build. Its main method is Heavenly Tribulation Scripture, with Thousand-Bolt Scripture and Unbroken Flesh Canon as auxiliaries. It slots the four Scripture arts plus the seal's Ninth Verdict art. Thần thức is 40 against a limit of 46.8.

**Fights.** Typical Core Formation (Kết Đan) foe at the same realm: 20-0 in 13.4 s, 90 % health left, and you never run dry. Against every higher-realm or top-end foe it loses 0-20, in 1 to 10 s.

**`--without` results at the same realm.** I took these from the `without` rows of each `--matrix` run. Every other matchup was unchanged.

| Test | Mean s | W-L |
|---|---|---|
| nothing removed | 13.4 | 20-0 |
| `item:thunder-ninth-tribulation-seal` | 14.5 | 20-0 |
| `eff:Verdict Stands` | 13.9 | 20-0 |
| `tech:heavenly-tribulation-scripture` | 13.4 | 20-0 |

- **Seal:** `--without item:` strips only the seal's modifiers and leaves the art slotted, so the 1.1 s is not the art's worth.
- **Effect:** Verdict Stands is written as one extra permanent Thunder stack per pulse in which a Thunder batch lands on a Slowed foe. The engine cannot stretch a batch already laid, so this undercounts the real rule. The `--without` gap for it is a stand-in measurement.
- **Main technique:** removing it changed nothing. Its Thunder stack-effect and stack-duration passives have no engine stat, so that test only shows its other passives don't move this fight.

**Other observations.**
- 13.4 s is well under the 30–60 s band.
- Nothing looks degenerate.
- The Ninth Verdict fires 1.8 times a fight at the same realm and 0.5 at one realm up.
- At 2 realms up and at top end nothing fires, because the foe ends the fight first.

The `UNMODELLED` lines for this build are in the guide.

Files are in `design/builds/engine-v3/`:
- `builds/unique-ninth-tribulation-seal.fight.json`
- `unique-ninth-tribulation-seal.md`

UNIQUE-DONE unique-ninth-tribulation-seal

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/unique-ninth-tribulation-seal.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/unique-ninth-tribulation-seal.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/unique-ninth-tribulation-seal.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/unique-ninth-tribulation-seal.md) instead (Edit rules cover all file-editing tools).
```
