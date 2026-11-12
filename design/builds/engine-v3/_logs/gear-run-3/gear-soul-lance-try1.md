# Job transcript: gear-soul-lance (try 1)

I geared `soul-lance` with eight soul-song-seal items and re-ran it. Gear did not help: the fight at hoa_than+1 went from a win to a loss in all 20 fights.

The geared file is `design/builds/engine-v3/builds/soul-lance.fight.json` and the guide is `design/builds/engine-v3/soul-lance.md`.

**Loadout**
- **Base slots:** Thousand-String Zither (weapon), Mourning Robe (armour), Echoing Ring and Quiet Mind Ring (rings), Waking-Soul Jade (necklace).
- **Extra slots:** Ninth Vigil Heart-Lamp, Muffled Temple Bell and Sandalwood Censer, for 50 thần thức against a limit of 57.6. The two empty slots stay empty.
- **Art slot:** the Zither's Thousand-String Dirge replaces `mountain-splitting-thought`, which never fired.
- **Effects written:** `eff:Plucked Time` and `eff:Echo`. Final Clause, Lamp-Lit Reading, Marked Prey and the item wards are listed as UNMODELLED. I did not change the build's ward.

**Results (mean seconds, W-L)**

| Matchup | Old | Geared |
|---|---|---|
| typical nguyen_anh+0 | 26.7 s, 20-0 | 22.0 s, 20-0 |
| typical hoa_than+1 | 30.7 s, 20-0 | 62.0 s, 0-20 |
| top_end nguyen_anh+0 | 25.4 s, 0-20 | 25.7 s, 0-20 |
| top_end hoa_than+1 | 11.5 s, 0-20 | 11.8 s, 0-20 |

The old v2 numbers changed under the current engine. The old guide said 21.7 / 30.7 / 15.9 / 6.9 s.

- **Zither:** removing it moves the typical nguyen_anh fight by one second (21.0 s).
- **Plucked Time:** removing it changes nothing.
- **Echo:** removing it gives 22.8 s, the only visible item Effect.
- **Dirge:** it never fired at nguyen_anh, and fired only at hoa_than+1 against the typical foe.
- **Toll art:** `tolling-bell-requiem` fires about half as often as before (12.9 against 26.0 per fight). I did not find out why.

GEAR-DONE soul-lance

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/soul-lance.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/soul-lance.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/soul-lance.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/soul-lance.md) instead (Edit rules cover all file-editing tools).
```
