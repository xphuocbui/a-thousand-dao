# Job transcript: gear-meta-hunter (try 1)

I geared `meta-hunter` and wrote both files, but gear barely moved the fight. Every matchup is still a 20-0 win and the fights run 2–6 s, well under the 30–60 s band.

**Loadout**
- **Base slots:** Ledger Seal (weapon), Tortoise-Scale Armour, Ring of the Returning Edge, Iron Temper Ring, Whetstone Jade Pendant.
- **Extra slots:** Mirror of the Second Seat, Ledger Branding Iron, Heaven-Minted Coin. That is 41 thần thức against a limit of 50.4.
- **Art swap:** Ledger Stamp from the Ledger Seal replaces Ambush Talisman, so the build loses its control and Chaos hit.
- **Item Effects written:** `eff:Edge Returns the Breath` and `eff:Marked Prey`.

**Results** (all 20-0, mean seconds, old → geared):

| Matchup | Old | Geared |
|---|---|---|
| typical, nguyên_anh | 2.4 | 2.3 |
| top_end, nguyên_anh | 4.5 | 4.5 |
| typical, hóa_thần+1 | 3.5 | 2.8 |
| top_end, hóa_thần+1 | 6.3 | 5.6 |

- **`--without` runs:** Without the Ledger Seal, top_end hóa_thần+1 slows from 5.6 to 5.8 s. Without Marked Prey, typical hóa_thần+1 goes from 2.8 to 2.9 s. Without Edge Returns the Breath, nothing changes. At nguyên_anh nothing changed in any of the three.
- **Old numbers differ from the engine-v2 guide:** The old file's numbers on the current engine differ from that guide's table (2.4 s here against 1.8 s there), so the guide uses what I measured.

**Not modelled**
- The Tortoise-Scale cast ward, Iron Skin Renewed, the Pendant's reserve art, Cold Feet and Seal of Full Payment are written up as UNMODELLED in the guide, as are the item modifiers the engine has no stat for.
- Several scoped art-speed modifiers apply to every art in the run, so they are overstated.
- The ring's "non-Physical hits cannot crit" rule can't be expressed, so Ledger Stamp may still crit in the run.

**Files:** I wrote only the fight file and the guide, plus a temporary helper script in `tools/design/combat_sim/` that I deleted afterwards.
- `design/builds/engine-v3/builds/meta-hunter.fight.json`
- `design/builds/engine-v3/meta-hunter.md`

GEAR-DONE meta-hunter

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/meta-hunter.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/meta-hunter.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/meta-hunter.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/meta-hunter.md) instead (Edit rules cover all file-editing tools).
```
