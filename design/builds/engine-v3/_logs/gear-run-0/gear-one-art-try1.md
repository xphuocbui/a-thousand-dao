# Job transcript: gear-one-art (try 1)

I geared `one-art` with five Metal items, ran the three fights, and wrote the fight file and the guide.

- **Loadout:** Hundred-Edge Flying Sword (Bách Nhận Phi Kiếm) as the weapon and Tortoise-Scale Armour (Quy Lân Giáp) as the armour. The rings are Ring of the Returning Edge (Phong Hồi Giới) and Iron Temper Ring (Thiết Thối Giới), and the necklace is Whetstone Jade Pendant (Thạch Mài Ngọc Bội). I left all six extra slots empty to keep the Empty Hall idea, so thần thức used is 0 of 45. The sword's own art is not slotted, so the build stays one art.
- **Typical foe, same realm:** the old file ran 12.0 s and the geared file 10.2 s, 20-0-0 in both. Health left went from 94 % to 100 %.
- **Top_end foe:** both files lose all 20 in 2.0 s, and the cleave never fires in either.
- **`--without` (typical foe):**

| Removed | Mean s |
|---|---|
| Ring of the Returning Edge | 10.9 |
| Flying sword | 10.6 |
| `eff:Edge Returns the Breath` | 10.2 (no change) |

- **Result:** the Ring of the Returning Edge was the item that mattered most, but only by about 0.7 s. Edge Returns the Breath fired nothing measurable, because the build is never dry against the typical foe. The fight stays well under 30–60 s, and nothing made the build degenerate.
- **Old guide mismatch:** the old file on disk gives 12.0 s, not the 8.1 s the old guide reports. The new guide uses the on-disk numbers.
- **UNMODELLED:** the ward, the Keen Edge Aura reserve and most item modifiers (stack strength, health and the like) are not run, and the guide lists each with why.

Files are in `design/builds/engine-v3`:
- `builds/one-art.fight.json`
- `one-art.md`

GEAR-DONE one-art

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/one-art.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/one-art.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/one-art.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/one-art.md) instead (Edit rules cover all file-editing tools).
```
