# Job transcript: gear-cooldown-floor (try 1)

I geared `cooldown-floor` with eight Wind items and wrote the fight file and the guide. The geared build wins the typical fights faster, but every fight is still far under the 30–60 s band.

The loadout:
- **Weapon:** Nine-Gale Heron Fan (unique).
- **Armour:** Cloud-Walker's Mantle (unique).
- **Rings:** Ring of Hollow Echoes and Gale-Step Ring.
- **Necklace:** Swallow-Tail Pendant.
- **Extras:** Four-Winds Banner, Windbreak Shield and Slow-Hour Needle, for 45 thần thức against a limit of 51.3. Two extra slots stay empty because the next cheapest piece would go over.

Two arts were swapped in: Heron Takes Wing replaces Reckless Gale, and Stitch the Hour replaces Gale Sprite. Echo, Wind at Your Back and Phantom Dodge are written as engine Effects.

The "old" column is the engine-v2 file run again on today's engine. It does not match the old guide's figures (3.0 s and 5.9 s); I used the fresh run so the comparison is like for like.

| Matchup | Mean s, old | Mean s, geared | W-L, old | W-L, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 4.3 | 2.7 | 20-0 | 20-0 |
| typical hoa_than+1 | 10.8 | 6.6 | 18-2 | 20-0 |
| top_end nguyen_anh+0 | 2.0 | 3.0 | 0-20 | 0-20 |
| top_end hoa_than+1 | 1.1 | 1.3 | 0-20 | 0-20 |

- **`--without` tests:** Removing the Heron Fan, Phantom Dodge or Echo each moves the typical fights by only about 0.1–0.3 s. Most of the gain comes from plain art speed and attack lines and the two swapped-in arts.
- **Degenerate:** No item made the build degenerate.
- **Fired nothing:** Three-Step Chase never fires against typical same-realm foes. Hundred-Feather Flurry and Three-Step Chase never fire against top_end hoa_than+1.
- **UNMODELLED:**
  - Phantom Dodge is written as Feather and Breath counter steps, because the engine can't raise an evade event.
  - The shield's cast ward, the mantle's ward and Cold Feet/Beneath Notice are not run.
  - The reserve arts and several modifiers with no engine stat are not run.

Files are in `design/builds/engine-v3`:
- `builds/cooldown-floor.fight.json`
- `cooldown-floor.md`

GEAR-DONE cooldown-floor

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/cooldown-floor.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/cooldown-floor.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/cooldown-floor.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/cooldown-floor.md) instead (Edit rules cover all file-editing tools).
```
