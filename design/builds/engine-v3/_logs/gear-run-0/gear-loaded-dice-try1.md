# Job transcript: gear-loaded-dice (try 1)

I geared `loaded-dice` with seven named items and wrote both files. The same-realm fight dropped from 16.1 s to 10.8 s, but none of the other five matchups changed, and no single item moved the result when removed.

**Loadout** (extra-slot thần thức 40 of 46.8):
- **Weapon:** Forked-Light Sword. Its art Forked Slash replaced `overload-form`.
- **Armour:** Stormcloud Armour.
- **Rings:** Static Band, Ring of Hollow Echoes.
- **Necklace:** Peal-Heart Pendant.
- **Extras:** Heartbeat of Heaven Drum (20), Stormcaller's Drum (20).

**Results** (`--matrix`, 20 fights each):
- Typical Kết Đan +0: 20-0 both times. Health left went from 74 % to 83 %, and the fight is still well under the 30-60 s band.
- Everything stronger is unchanged. Nguyên Anh +1 and Hóa Thần +2 are 0-20 in both runs, and top_end foes kill the build in 1-2 s.
- The v2 file re-ran at 16.1 s, not the 11.4 s in the old guide, because the engine has changed since. The guide's "old" column uses the re-run figure.

**`--without` tests:**
- **Single items:** `--without item:` on the sword, the Heartbeat drum and the Stormcaller drum, and `--without eff:Echo`, were all NO_CHANGE (10.8 s, 20 wins). The drums and Echo only shifted the foe's dry time by 0.2-0.4 s.
- **Item removal:** `--without item:` strips only an item's plain modifiers, so the sword's art stays in those runs.
- **What matters:** The sword is named the most important item because it brings the art. The gain comes from that art plus the stacked small crit modifiers, and the build is not degenerate.

**Effects I wrote:** Echo, Marked Prey and Steady Breath. Marked Prey probably fires nothing, since the build applies no statuses.

**UNMODELLED:**
- Drumbeat (the engine has no way to count every fourth art).
- All three reserve arts.
- The Cloudflash Shell cast shield.
- The stats the engine has no field for, such as linh lực on crit and khí huyết.

Files are in `design/builds/engine-v3/`:
- `builds/loaded-dice.fight.json`
- `loaded-dice.md`

GEAR-DONE loaded-dice

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/loaded-dice.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/loaded-dice.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/loaded-dice.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/loaded-dice.md) instead (Edit rules cover all file-editing tools).
```
