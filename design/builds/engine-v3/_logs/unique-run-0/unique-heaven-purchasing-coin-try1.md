# Job transcript: unique-heaven-purchasing-coin (try 1)

I wrote the build file and the guide and ran the four fights. The coin does not make the build, and one of its three flip branches never ran.

**The build.** Core Formation, Metal root (purity 80). Techniques: Nine-Temper Scripture as main, Hundred-Blades Canon as auxiliary, and Unbroken Flesh Canon (body, passives only). Five arts: Last Coin Flick, Whetstone Pass, Sheathed Edge, Needle Rain, Blood-Quench Blade. Thần thức use is 38 against a limit of 46.35. I wrote two Effects: `eff:Bought Fate` and `eff:Edge Returns the Breath`.

**Same-realm fight** (typical Core Formation+0): 17.6 s, 20 wins, 0 losses, 68 % health left. The foe runs dry at 14.4 s and you never do. It loses 0-20 against every higher-realm and top-end foe.

| `--without` | Mean s (typical ket_dan+0) |
|---|---|
| nothing removed | 17.6 |
| `item:general-heaven-purchasing-coin` | 20.2 |
| `eff:Bought Fate` | 17.6 (no change) |
| `tech:nine-temper-scripture` | 18.4 |

- **The coin's worth:** removing it lengthens the same-realm fight by 2.6 s and costs about 4 points of health left. That is the coin's plain modifiers only, since Last Coin Flick stays slotted.
- **Bought Fate:** the engine can't flip a roll already made, so I approximated the crit branch. The first crit taken each fight heals back 40 % of that hit. The failed-evade and failed-escape branches have no model, and the spirit-stone price isn't charged. The guide lists all three as UNMODELLED.
- **Never fired:** Needle Rain fires only 2.0 times a fight at same realm. Sheathed Edge, Blood-Quench Blade and Needle Rain never fire against top-end foes, because those fights end in 1–2 s.
- **Fight length:** 17.6 s is under the 30–60 s band. Nothing looks degenerate.

The first `--without` output looked identical to the baseline only because my grep filtered out the `without` and `identity` lines. I re-ran all three and read the `identity` lines, and the figures above come from those.

Files are in `design/builds/engine-v3/`:
- `builds/unique-heaven-purchasing-coin.fight.json`
- `unique-heaven-purchasing-coin.md`

UNIQUE-DONE unique-heaven-purchasing-coin

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/unique-heaven-purchasing-coin.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/unique-heaven-purchasing-coin.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/unique-heaven-purchasing-coin.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/unique-heaven-purchasing-coin.md) instead (Edit rules cover all file-editing tools).
```
