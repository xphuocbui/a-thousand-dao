# Job transcript: gear-bare-fist (try 1)

I geared `bare-fist` and wrote the fight file and the guide. Gear barely helped, and both item Effects I modelled fired nothing the fight could see.

**Loadout** (extras total 45 of 45 thần thức):
- **Weapon:** `earth-mountain-mooring-anchor`, whose art `earth-mooring-drop` takes the place of `sinking-weight`.
- **Armour:** `earth-boulder-ring-mail`.
- **Rings:** `body-iron-skin-ring` and `earth-clay-seal-ring`.
- **Necklace:** `earth-remembering-stone-pendant`.
- **Extras:** `earth-unmoving-gate-shield` (15) and `body-flesh-seal` (30).

I wrote Iron Skin Renewed and Shattering Ward as engine Effects. Unmoved Stance and the item wards are listed as UNMODELLED.

**Results** (the old file re-run today, because the old guide's 9.0 s typical-fight figure no longer matches the engine):

| Matchup | Mean s, old | Mean s, geared | Result |
|---|---|---|---|
| typical, Nguyên Anh +0 | 15.1 | 13.1 | 20-0 both |
| typical, Hóa Thần +1 | 31.8 | 29.2 | 20-0 both |
| top_end, Nguyên Anh +0 | 12.8 | 13.9 | 0-20 both |
| top_end, Hóa Thần +1 | 5.2 | 5.5 | 0-20 both |

- **Without the anchor:** the typical Nguyên Anh fight goes from 13.1 to 14.9 s. It is the only item whose numbers the engine reads.
- **Without either Effect:** NO_CHANGE, so neither fired anything the fight could see. My guess in the guide is that the body shield rarely breaks in this engine, but I did not check that.
- **Fight length:** only the Hóa Thần +1 typical fight comes near 30–60 s, at 29.2 s. The Nguyên Anh fight, at 13.1 s, is far below it.
- **Degeneracy:** none.

Most of the items' stats (body shield, Earth stack strength, health regeneration and so on) have no engine stat, so they did not run.

Files are in `design/builds/engine-v3/`:
- `builds/bare-fist.fight.json`
- `bare-fist.md`

GEAR-DONE bare-fist

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/bare-fist.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/bare-fist.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/bare-fist.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/bare-fist.md) instead (Edit rules cover all file-editing tools).
```
