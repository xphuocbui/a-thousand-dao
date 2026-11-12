# Job transcript: unique-chaos-primordial-mirror (try 1)

I built and fought the Unmaker, and the Mirror of Primordial Chaos does nothing measurable in this sim. Every `--without` run matched the full build exactly.

**The build** is Core Formation (ket_dan) on an Earth (`tho`) root. The main technique is Mountain Heart Canon and the auxiliary is Ruin Ledger Scripture. The five arts are Fraying Thread, Ripening Curse, Gathered Ruin Verdict, Settle the Account (from the weapon) and Sinking Weight. It uses the Mirror, six other force-chaos pieces, and two extra slots at 33 thần thức against a limit of 51.3. Layers sit at the typical Core Formation anchor.

**Unmaking Glass** is written as `eff:Unmaking Glass`. It strips 1 buff stack on a hit and adds 1 Fray, but only when the foe holds a buff stack. The engine's `strip` doesn't raise `status_applied`, so the "counts as a status landed" half isn't modelled.

**Fights** (`--matrix`, 20 each):

| Matchup | Result |
|---|---|
| typical ket_dan+0 | 8.9 s, 20-0-0, foe dry at 8.3 s, you never dry |
| typical nguyen_anh+1 | 8.1 s, 0-20-0 |
| typical hoa_than+2 | 4.0 s, 0-20-0 |
| top_end (all three) | 1-2 s, 0-20-0 |

**What the unique is worth:** nothing measurable. `--without item:force-chaos-primordial-mirror`, `--without eff:Unmaking Glass` and `--without tech:mountain-heart-canon` all gave the same numbers as the full build. The likely cause is that the typical foe carries no buff stacks, so the Effect never fires. The run doesn't print Effect firings, so that is inferred, not observed.

**Other points:**
- Fights are far below the 30-60 s band.
- Most of the Mirror's modifiers are unmodelled or scoped to `hon_don`, which no art here carries.
- Gathered Ruin Verdict, Settle the Account and Sinking Weight never fired at typical hoa_than+2, and nothing fired against top_end.

I tuned nothing.

Files are in `design/builds/engine-v3/`:
- `builds/unique-chaos-primordial-mirror.fight.json`
- `unique-chaos-primordial-mirror.md`

UNIQUE-DONE unique-chaos-primordial-mirror

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/unique-chaos-primordial-mirror.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/unique-chaos-primordial-mirror.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/unique-chaos-primordial-mirror.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/unique-chaos-primordial-mirror.md) instead (Edit rules cover all file-editing tools).
```
