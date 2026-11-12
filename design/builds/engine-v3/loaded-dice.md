# The Loaded Dice (Quán Cốt), geared: a Thunder gambler whose crit rhythm is fed by chained bolts and a fist that turns every crit into a faster timer.

Realm Kết Đan (Core Formation). Root Thunder (`purity` thunder 80). Same build as `design/builds/engine-v2/loaded-dice.md`; this page adds named items. Fight file: `design/builds/engine-v3/builds/loaded-dice.fight.json`.

## Loadout

Grade cap at this realm is 4. The build has no `divine_sense` (1.0) and its items give than_thuc +4 % (the pendant), so the extra-slot limit is 45 x 1.0 x 1.04 = **46.8**.

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Forked-Light Sword (Phân Quang Lôi Kiếm) `thunder-forked-light-sword` | 2 | Its art Forked Slash counts as a Thousand-Bolt Scripture art, so the suite's Palm, Chain Arc and Peal count it; its crits stack crit chance. Slotted in place of `overload-form` |
| Armour | Stormcloud Armour (Vân Lôi Giáp) `thunder-stormcloud-armour` | 3 | Lightning crit chance, crit damage and speed on the body slot; a fast cast shield (not run) |
| Ring | Static Band (Tĩnh Điện Giới) `thunder-static-band` | 1 | Lightning crit chance and crit damage; linh lực back on crit (not run) |
| Ring | Ring of Hollow Echoes (Không Hưởng Giới) `wind-hollow-echo-ring` | 3 | Echo: a quarter of art hits strike again; flat crit chance +5 and some evade |
| Necklace | Peal-Heart Pendant (Lôi Tâm Bội) `thunder-peal-heart-pendant` | 3 | Lightning crit chance +10 and crit damage +40; Marked Prey; the only item that gives than_thuc (+4 %) |
| Extra (TT 20) | Heartbeat of Heaven Drum (Thiên Tâm Lôi Cổ) `thunder-heartbeat-of-heaven-drum` | 4 unique | The crit item: crit +12, speed +12, crit damage +60; Drumbeat would make every 4th art a crit (not run) |
| Extra (TT 20) | Stormcaller's Drum (Hô Lôi Cổ) `thunder-stormcaller-drum` | 2 | Crit +10, speed +10, crit damage +30; Steady Breath |
| **Extra total** | | | **40 of 46.8 thần thức** (6.8 left; no piece that small fits the build) |

Four extra slots are allowed; two are used. Another 20-TT piece would break the limit; a 10-TT needle (Spark Needle, Stitchwind Needles) was left out because both arts are weaker than the five already slotted.

## Before and after

`fight.py --matrix`, 20 fights each. "Old" is the engine-v2 file re-run today (the engine has changed since the old guide, which quoted 11.4 s at Kết Đan, so the old column here is 16.1 s).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical ket_dan+0 | 16.1 | 10.8 | 20-0-0 | 20-0-0 |
| typical nguyen_anh+1 | 8.8 | 9.6 | 0-20-0 | 0-20-0 |
| typical hoa_than+2 | 4.3 | 4.2 | 0-20-0 | 0-20-0 |
| top_end ket_dan+0 | 2.0 | 2.0 | 0-20-0 | 0-20-0 |
| top_end nguyen_anh+1 | 1.0 | 1.1 | 0-20-0 | 0-20-0 |
| top_end hoa_than+2 | 1.0 | 1.1 | 0-20-0 | 0-20-0 |

Typical ket_dan+0: health left 74 % -> 83 %, foe dry 12.7 s -> 8.9 s, you dry never in both.

`--without` (typical ket_dan+0, geared 10.8 s, 20 wins):

| Test | Result |
|---|---|
| `--without item:thunder-forked-light-sword` (its plain modifiers only; the art stays) | NO_CHANGE, 10.8 -> 10.8 s, 20 -> 20 wins |
| `--without item:thunder-heartbeat-of-heaven-drum` | NO_CHANGE, 10.8 -> 10.8 s, 20 -> 20 wins; foe dry 8.9 -> 9.3 s |
| `--without item:thunder-stormcaller-drum` | NO_CHANGE, 10.8 -> 10.8 s, 20 -> 20 wins; foe dry 8.9 -> 9.2 s |
| `--without eff:Echo` | NO_CHANGE, 10.8 -> 10.8 s, 20 -> 20 wins; foe dry 8.9 -> 9.1 s |

The one change that moved the fight is the art swap (Forked Slash for `overload-form`) together with the plain modifiers taken as a whole; no single item can be named as the one that matters, because each removal alone is NO_CHANGE. The sword is listed as the item that matters most because it brings the art.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Lightning crit chance / crit damage on a Thousand-Bolt art | More crits for Chain Arc, Peal and Palm to count | Craft, Thunder sect elder | Catalogue: `thunder-ninth-tribulation-seal` (unique, Verdict Stands; heavier, stack-oriented) | Low |
| Ring | Linh lực back on crit (Storm Battery) at a higher grade | Refund for the crit rhythm | Craft, event | Missing: only the grade-1 Static Band exists | High |
| Ring | A second Thunder ring above grade 1 | Lightning crit damage without a foreign family | Craft | Missing | Medium |
| Armour | A ward that beats the Common Ward | Survives the same-realm trade | Craft, quest | Catalogue: `thunder-stormcloud-armour` (cast shield, not modelled) | Medium |
| Necklace | Crit-taken stacks (Thunder Debt) | The old Debt piece | Event, quest | Missing | Medium |
| Extra | Counted crit meter (Loaded Table) | The build's namesake rhythm | Unique or Way | Missing | High |
| Extra | Every-4th-art crit (Drumbeat) | A steady crit beat | Unique drop | Catalogue: `thunder-heartbeat-of-heaven-drum` (worn, effect not run) | Medium |

## Missing pieces

- A ring or treasure that refunds linh lực on crit at grade 3 or 4 (Winnings); owner: thunder.
- A treasure that holds a counted crit and evade meter, pre-filled, fed by khí vận (Loaded Table); owner: general (fortune) or thunder.
- A necklace or ring that turns crits taken into stacks (Thunder Debt); owner: thunder.
- A payout piece that spends the crit meter on demand (House Takes All / Cash Out); owner: general.
- A second Thunder ring above grade 1; owner: thunder.

## UNMODELLED

- Drumbeat (every 4th art a guaranteed crit, others -8 crit): the engine has no modulo or per-count read, and a counter reset cannot be ordered safely; left out.
- Reserve arts (Peal-Heart Aura 15 %, Heaven's Pulse 20 %, Stormcaller's Cadence 10 %): the engine does not deduct the reserved linh lực nor run the grants; together they would reserve 45 %.
- Cloudflash Shell (cast shield): not a drain ward, and the build already has the typical Common Ward; no better ward was modelled.
- Static Band linh lực on crit, pendant and drum linh_luc_pct, defence, khí huyết, than_thuc: no engine stat.
- Item `art_speed_pct` passives scoped to lightning or wind apply to every art (engine reads speed without hit context).
- Steady Breath and Marked Prey are written as untagged L5, so they also reach the basic attack; Marked Prey reads the foe's distinct statuses, which this build seldom applies (likely 0).
- Echo's free hit cannot copy the firing art's tags; one Echo is written, the rules do not say how a second source would stack.
- The build's old unmodelled lines (Loaded Table, Jackpot, counted evade, Stacked Meter, Spilled Luck, escape) stay.

## Observations

Gear shortened the same-realm fight from 16.1 s to 10.8 s and raised health left from 74 % to 83 %, still 20-0, but 10.8 s is well under the 30-60 s band (the old build was already under it). Against stronger foes nothing changed: nguyen_anh+1 and hoa_than+2 stay 0-20 and top_end dies in 1-2 s, so the loadout does not close any realm gap. No single item moved the result when removed (all NO_CHANGE; the drums and Echo only shift the foe's dry time by 0.2-0.4 s), so the gain comes from the Forked Slash art in the suite plus the stack of small crit modifiers, and the build is not degenerate. Echo fired a lot (45 clipped triggers per fight, so the per-pulse limit binds) and changed nothing. Marked Prey probably fires nothing, since the build applies no statuses. NEVER_FIRED: `rolling-barrage-fist` at hoa_than+2, and every art at top_end. The old overload-form (the evade penalty) is no longer slotted.

GEAR-DONE loaded-dice
