# Job transcript: gear-ninth-bell (try 1)

I geared `ninth-bell` with seven Metal items and wrote the fight file and the guide. Gear mattered: the typical same-realm fight dropped from 8.7 s to 4.5 s. Health left went from 59 % to 89 %. The one-realm-up fight flipped from a 0-20 loss to a 20-0 win.

I ran every matchup of the old and geared files, plus the `--without` tests for the coin and for Edge Returns the Breath.

**Loadout.** The thần thức total is 45 of 45.
- **Base slots:**
  - Weapon: Heaven-Minted Coin.
  - Armour: Tortoise-Scale Armour.
  - Rings: Iron Temper Ring and Ring of the Returning Edge.
  - Necklace: Whetstone Jade Pendant.
- **Extra slots:** Bronze Peal Bell (25) and Hundred-Edge Flying Sword (20).

The coin's art, Golden Coin Rain, replaced `frozen-hour-seal`. It reads the same Temper counter the Nine-Temper Scripture builds. I left the Blood-Seasoned Whetstone out because it is a health-pay item and this build pays in linh lực.

**Results.**

| Matchup | Mean s, old | Mean s, geared | W-L, old | W-L, geared |
|---|---|---|---|---|
| typical ket_dan+0 | 8.7 | 4.5 | 20-0 | 20-0 |
| typical nguyen_anh+1 | 13.7 | 10.5 | 0-20 | 20-0 |
| typical hoa_than+2 | 8.0 | 8.9 | 0-20 | 0-20 |
| top_end ket_dan+0 | 3.0 | 3.9 | 0-20 | 0-20 |

Top_end nguyen_anh+1 (2.0 s) and top_end hoa_than+2 (1.0 s) are lost 0-20 both before and after.

- **Old column:** the old numbers come from running the engine-v2 file today. The v2 guide's own 6.2 s is older than the engine.
- **Fight length:** every fight is shorter than the 30-60 s band, and gearing made the typical one shorter, so the gap to the band grew.
- **Coin:** without the coin the typical fight takes 5.0 s against 4.5 s with it. That is only 0.5 s of the gain.
- **Edge Returns the Breath:** removing it changed nothing. It fired nothing in this build.

**Unmodelled.**
- **Not modelled:**
  - I did not model Seal of Full Payment (the engine has no spirit-stone payment) or Iron Skin Renewed (I didn't read its rule).
  - The Tortoise-Scale Shell and Bronze Peal wards are not shown to beat the build's ward, so I left the build's own ward in place.
- **No engine stat:** many item modifiers print "no engine stat" and did nothing, so the geared result may understate the items. The Hundred-Edge Flying Sword is the clearest case: its art is not slotted and its modifiers are mostly unread.

The guide has the full loadout table, the upgrades table, the missing pieces and every unmodelled line.

Files are in `design/builds/engine-v3/`:
- `builds/ninth-bell.fight.json`
- `ninth-bell.md`

GEAR-DONE ninth-bell

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/ninth-bell.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/ninth-bell.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/ninth-bell.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/ninth-bell.md) instead (Edit rules cover all file-editing tools).
```
