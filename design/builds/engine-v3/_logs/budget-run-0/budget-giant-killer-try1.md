# Job transcript: budget-giant-killer (try 1)

"giant-killer" is now within budget: `layers` went from `[200, 225, 250, 130, 100]` to `[200, 70, 54, 20, 10]`, and `fight.py` prints `layer_budget` at a 17% claim (was 88%). I re-ran `--matrix` on the new file and updated the guide. The report is written.

- **What I cut:** L4 and L5 went to the typical enemy's own values first, since "Against the Heavens" is unmodelled and the techniques and items already run as Effects. L1 stayed at 200. The leftover budget went to L2 (+30) and L3 (+14).
- **Fights, 20 seeds, old → new:**

| Matchup | Old | New |
|---|---|---|
| typical, same realm (`ket_dan`) | 1.0 s, 20 wins | 3.2 s, 20 wins |
| typical, `nguyen_anh`+1 | 1.9 s, 20 wins | 5.8 s, 20 wins |
| typical, `hoa_than`+2 | 4.4 s, 17 wins | 8.1 s, 0 wins |
| top-end, `ket_dan` | 0 wins | 0 wins |
| top-end, `nguyen_anh`+1 | 0 wins | 0 wins |
| top-end, `hoa_than`+2 | 0 wins | 0 wins |

- **Still too fast:** the same-realm typical fight is 3.2 s, well under the 10–20 s the budget aims for. Crit and the +50% art speed carry it, not `layers`. Cutting techniques or items to slow it was out of scope, so I left them alone.
- **Cleave never fires:** `shatter-edge-cleave` never fires at the same realm.
- **Missing pieces:** the report lists what the build would want from the catalogue: a realm-gap damage piece, physical penetration or realm pierce, a per-hit Metal stack bonus, and a drain-ward armour.
- **Not re-run:** the `--without` tests. The guide's old `--without` table was removed, with a note that they are worth repeating now the fights are longer.

I removed no techniques, items or arts. I also reworded the stale L5 line under UNMODELLED in the guide, and updated the `_comment` in the fight file to record the cut.

The files are in `design/builds/engine-v3`:
- `builds/giant-killer.fight.json`
- `giant-killer.md`
- `_logs/budget/giant-killer.md`

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/giant-killer.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/giant-killer.md) instead (Edit rules cover all file-editing tools).
```
