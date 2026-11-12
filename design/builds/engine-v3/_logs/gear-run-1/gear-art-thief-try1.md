# Job transcript: gear-art-thief (try 1)

I geared `art-thief` with seven named items and wrote the fight file and the guide. Gear changed little. The same-realm typical fight is 2.8 s (old 3.0 s) and the top-end Nguyên Anh fight is 11.2 s, both far under the 30–60 s band.

**Matrix (old → geared, 20 fights each)**

| Matchup | Mean s | W-L-other |
|---|---|---|
| typical, nguyen_anh+0 | 3.0 → 2.8 | 20-0-0 → 20-0-0 |
| typical, hoa_than+1 | 3.7 → 4.8 | 20-0-0 → 20-0-0 |
| top_end, nguyen_anh+0 | 8.9 → 11.2 | 19-1-0 → 20-0-0 |
| top_end, hoa_than+1 | 4.7 → 4.5 | 0-20-0 → 0-20-0 |

**Loadout**
- The weapon is the Shock-Wave Zither (`force-chaos-shock-zither`). Its Resonant Shockwave art replaces Twin Shadow Fist, which never fired in the old matrix.
- Armour is the Hollow Robe (`force-chaos-hollow-robe`); rings are the Echoing Ring (`soul-song-seal-echoing-ring`) and the Hollow Ring (`force-chaos-hollow-ring`); the necklace is the Ledger-Murmur Pendant (`force-chaos-ledger-murmur-pendant`).
- The extras are the Echo-Skin Drum (`body-echo-skin-drum`) and the Twin-Edge Flying Sword (`blade-twin-edge-sword`), 20 thần thức each.
- Total thần thức is 40 against a limit of 49.5 (45 if the robe's and ring's thần thức bonuses don't count), so two extra slots stay empty.
- The robe's ward (264) is weaker than the build's own (342.5), so I kept the old ward.

**Item Effect:** Echo is the only item Effect the build relies on, written once as `eff:Echo`. The engine's free hit cannot carry the art's tags. I did not stack a second Echo from the other item, because the rules don't say whether it would.

**`--without` results:** Removing the zither's modifiers changed nothing in any row, because the swapped-in art stays. Removing `eff:Echo` moved only the top-end Nguyên Anh row, from 11.2 s and 20-0 to 10.0 s and 19-1. So the Echo Effect is the one thing that visibly mattered, and it reads as survival rather than speed. I did not isolate why the typical hoa_than+1 fight got slower (3.7 s to 4.8 s) with the same wins.

**Observations:** No item made the build degenerate. Marrow-Siphon Palm and Hollowing Strike never fired in the typical Nguyên Anh fight, which ends first. Most of the other items' modifiers have no engine stat, so they do close to nothing here. The guide also covers the upgrades table, the missing pieces (a foe-art-copying piece, a Force-scoped attack piece) and the UNMODELLED list.

Files are in `design/builds/engine-v3/`:
- `builds/art-thief.fight.json`
- `art-thief.md`

GEAR-DONE art-thief

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/art-thief.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/art-thief.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/art-thief.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/art-thief.md) instead (Edit rules cover all file-editing tools).
```
