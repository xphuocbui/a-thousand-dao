# Job transcript: gear-starter-wall (try 1)

I geared `starter-wall` with seven named items and wrote the fight file and the guide. Gear shortened the same-realm fight but left the wall's character alone. I did not check the lint on the new files.

**Loadout:**
- **Base slots:** Mountain-Mooring Anchor (weapon), Boulder-Ring Mail (armour), Ring of Renewed Iron Skin and Clay Seal Ring (rings), Pendant of the Remembering Stone (necklace). All are grade 3 or lower.
- **Extra slots:** Boundary Flag (20 thần thức) and Mountain-Gate Shield (15). That is 35 of 45, with the third slot left empty.
- **Art swap:** the anchor's Mooring Drop replaces `sinking-weight`.

**Results (20 fights per row, the old file re-run today):**

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical Trúc Cơ | 37.1 | 30.8 | 20-0-0 | 20-0-0 |
| typical Kết Đan +1 | 21.5 | 65.7 | 0-20-0 | 1-6-13 |
| typical Nguyên Anh +2 | 4.7 | 7.9 | 0-20-0 | 0-20-0 |

- **Old numbers:** the old Trúc Cơ run came out at 37.1 s, not the v2 guide's 31.7 s, so the engine has moved since that guide.
- **Top-end rows:** the three top_end rows still end in 1–2 s, as they did before gear.
- **Kết Đan +1:** the 13 "other" fights are ones that hit the time limit, so the geared wall now outlasts that foe but still cannot kill it.
- **30–60 s band:** the same-realm fight at 30.8 s sits just inside the bottom edge of it.

**`--without`:**
- Removing the anchor item puts the fight back to 37.4 s. The art stays slotted, so only the anchor's passives are removed; the engine applies its Earth-scoped art speed to every art.
- Removing Iron Skin Renewed changes nothing.
- Removing Planted Banner changes the foe's dry time from 22.9 s to 23.6 s and nothing else.

**Not modelled, and why:**
- The Mountain-Gate ward and the Boulder Shell are not modelled; the build's drain ward is larger.
- The item plain modifiers are not added, since the instructions say never tune a number.
- The pendant's reserve art is not run.

Nothing went degenerate. The guide also lists the upgrades to look for (Kết Đan unique Earth pieces first) and the missing pieces, such as a heal at 60 % health and a stronger armour ward.

GEAR-DONE starter-wall

Files are in `design/builds/engine-v3/`:
- `builds/starter-wall.fight.json`
- `starter-wall.md`

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/starter-wall.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/starter-wall.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/starter-wall.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/starter-wall.md) instead (Edit rules cover all file-editing tools).
```
