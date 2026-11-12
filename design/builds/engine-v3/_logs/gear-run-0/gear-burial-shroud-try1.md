# Job transcript: gear-burial-shroud (try 1)

I geared `burial-shroud` with seven items and wrote the fight file and the guide. Gear helped a little, but no matchup changed its win or loss result.

**Loadout.** The weapon is Balance-Sheet Seal, the armour is Hollow Robe, the rings are Hollow Ring and Wayfarer's Ring, and the necklace is Ledger-Murmur Pendant. The two extras, Ledger Branding Iron and Shock-Wave Zither, cost 40 thần thức against a limit of 49.5.

**Item arts.** The Seal's art, Settle the Account, replaces Gathered Ruin Verdict in the five art slots. I did not slot the Zither's art, so the Zither is there for its modifiers only. The Robe's ward does not beat the build's own ward, so I left the ward alone.

**Item Effect.** Marked Prey from the Branding Iron is written as `eff:Marked Prey`. The engine reads statuses on the foe, which is the nearest match to the catalogue's wording.

**Results.**

| Matchup | Old mean s | Geared mean s |
|---|---|---|
| typical ket_dan+0 | 9.3 | 8.5 |
| typical nguyen_anh+1 | 20.8 | 16.3 |
| typical hoa_than+2 | 15.8 | 14.8 |
| top_end, all three | 4.0 / 2.0 / 1.6 | unchanged |

- **Wins and losses:** it still wins at ket_dan and nguyen_anh+1, and still loses at hoa_than+2 and against every top-end foe.
- **Fight length:** the fights stay well under the 30–60 s band.
- **`--without`:** removing the Seal's modifiers costs 0.2 s, and removing Marked Prey costs 0.2 s. The `--without item:` test only strips an item's modifiers, so the Seal's art is not isolated.
- **Engine stats:** many item modifiers (stack strength, status duration, health) have no engine stat, so the geared numbers understate the items.
- **Old guide figures:** the old file ran at 9.3 s and 20.8 s today, not the 7.6 s and 14.1 s in the engine-v2 guide, because the engine and library changed since it was written.

Files are in `design/builds/engine-v3/`:
- `builds/burial-shroud.fight.json`
- `burial-shroud.md`

GEAR-DONE burial-shroud

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/burial-shroud.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/burial-shroud.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/burial-shroud.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/burial-shroud.md) instead (Edit rules cover all file-editing tools).
```
