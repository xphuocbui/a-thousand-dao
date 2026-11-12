# Job transcript: gear-starter-flame (try 1)

I geared `starter-flame` and wrote the fight file and the guide. Gear cut the same-realm fight from 27.7 s to 19.1 s and did not change any losing matchup.

I counted five extra-slot rules: a 7-item loadout, 45 of 45 thần thức, a grade-4 cap, two empty extra slots, and the build's ward kept.

- **Loadout:** the Ashen Phoenix Fan (weapon, unique), Phoenix Plume Armour, two rings, the Hearth-Keeper Pendant, the Red Sun Seal and the Undying Ember Lantern. The Seal and Lantern are the extras (30 + 15 = 45 of 45 thần thức). The two other extra slots are empty because the Furnace-Mouth Gourd and the Smouldering Robe would break the limit.
- **Arts:** Red Sun Descends replaced Twin Flame Echo, and Ash-Feather Gale replaced Heat Haze.
- **Effect run:** only Phoenix Mend. Fan the Pyre, Embers Never Die and Blood Casting are listed as UNMODELLED in the guide.
- **Results:** every matchup keeps its win-loss record. Geared typical Nguyên Anh is 11.6 s (old 11.2); the other four are unchanged. Same-realm health left is 100 % (old 97 %). That 19.1 s is further below the 30-60 s band, and the old file was already below it.
- **`--without` tests:** removing Phoenix Mend gives 21.3 s, so it is the item that matters most. Removing the Fan or the Seal moved the fight by about 0.1-0.2 s, but `--without item:` strips only an item's plain modifiers and leaves its art slotted, so that says little about the art.
- **Old numbers differ from the v2 guide:** the engine-v2 file now runs at 27.7 s, not the 17.9 s the v2 guide printed, so the engine has changed since then. The guide's old column uses today's run.
- **Temp file:** I wrote a temporary helper script into `tools/design/combat_sim/` and deleted it afterwards. Nothing else outside the fight file and the guide was touched.

Files are in `design/builds/engine-v3/`:
- `builds/starter-flame.fight.json`
- `starter-flame.md`

GEAR-DONE starter-flame

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/starter-flame.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/starter-flame.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/starter-flame.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/starter-flame.md) instead (Edit rules cover all file-editing tools).
```
