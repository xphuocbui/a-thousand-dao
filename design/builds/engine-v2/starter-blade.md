# The Whetted Edge (Mài Phong Kiếm), engine v2 rebuild

A Metal sword build: crits feed a Temper that sharpens the next crits, a banked keen strike rides every art, and a flying sword keeps cutting.

## Old pieces to library pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Whetted Edge (crit stacks crit, Effect) | `whetstone-pass` (Temper: +1 crit per Metal art, no cap) | nine-temper-scripture (1) |
| Quick Draw Cut (fast crit-roll art) | `needle-rain` (6 needles, each rolls its own crit) | hundred-blades-canon (1) |
| Notch the Foe (Metal debuff) | `sheathed-edge` (crits bank free keen strikes); no debuff art kept | nine-temper-scripture (4) |
| Returning Sword Light / flying sword (Phi Kiếm) | `flying-sword` (sword that keeps cutting, adds Afterimages) | afterimage-sword-canon (6) |
| Ten Thousand Returns (Kết Đan) | `phantom-sword` (a crit with 3 Afterimages refires the last art) | afterimage-sword-canon (2) |
| Sheathe and Breathe (linh lực) | none | - |
| Plain Iron Sword Manual (main, tier 2) | Nine-Temper Scripture (Yellow main, kim) | - |

Truc_co has 4 slots (the first four rows after Whetted Edge); Kết Đan adds `phantom-sword` as the 5th. Arts are all `{"lib": id}`, no overrides.

## Techniques chosen and why

- **nine-temper-scripture (main, kim).** Its suite is a crit engine (Temper, banked keen strikes), which is the build's concept. Passive crit +4 and crit damage +10 on Metal.
- **afterimage-sword-canon (secret, kim).** The flying sword and a crit-fed Afterimage engine. Passives crit +9 and crit damage +30 on sword arts, the largest crit passives on offer.
- **hundred-blades-canon (secret, kim).** `needle-rain` gives the most crit rolls per firing; its passives add crit +4 and art speed +7.
- All three name only kim; the build has Metal purity 65 (old guide: 60 to 70; the old file carried no purity field).

## Lost in the move

- Quick Draw Cut's 1.5 s cheap cut: needle-rain is the closest, but it is a six-needle volley, not a cheap fast cut.
- Notch the Foe's Metal debuff (+1.8 % Physical taken): no library art carries it in this selection.
- Sheathe and Breathe (6 % linh lực): no library equivalent in the chosen suites; the common art is only carried by a generated common technique.
- Ten Thousand Returns: no equivalent; phantom-sword replaces it as a crit-refire.
- The `+10/+12` L2 "sword arts" `x` on each art (an override; arts take none here). L2 stays at the untagged 40.
- The explicit Whetted Edge Effect (crit chance +2 per stack, 8 stacks); the crit chance 0.15/0.18 kept from the old file still bakes in that averaged Whet, so it may double count with Temper.
- Plain Iron Sword Manual layer-4 enabler.

## Results (truc_co file, --matrix, 20 fights each)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical truc_co+0 | 15.0 | 20-0-0 | never | 12.0 | flying-sword-trail 0.1, trig_budget 1.9 |
| typical ket_dan+1 | 8.0 | 0-20-0 | 6.1 | never | none |
| typical nguyen_anh+2 | 3.5 | 0-20-0 | 2.6 | never | none |
| top_end truc_co+0 | 1.6 | 0-20-0 | 1.6 | never | none |
| top_end ket_dan+1 | 1.0 | 0-20-0 | 1.0 | never | none |
| top_end nguyen_anh+2 | 1.0 | 0-20-0 | 1.0 | never | none |

The `--matrix` run printed six rows (three realms by typical and top_end), not nine; `top_end_the_tu` was not in its output.

Other realm: `starter-blade.ket-dan.fight.json` (typical ket_dan+0): 12.1 s, 20-0-0, you dry 11.2 s, foe dry 9.7 s, clipped trig_budget 1.1 per fight.

## --without tests (typical truc_co+0, same realm)

| Test | Before | After |
|---|---|---|
| `--without tech:nine-temper-scripture` | 15.0 s, 20-0, you dry never, foe dry 12.0, health left 66 % | 16.5 s, 20-0, you dry 15.0, foe dry 12.9, health left 61 % |
| `--without whetstone-pass` (identity piece) | 15.0 s, 20-0, you dry never, foe dry 12.0, health left 66 % | 19.5 s, 20-0, you dry never, foe dry 15.2, health left 56 % |

Note: with the main technique's passives removed, the arts it carries stayed in the file; only its Effect `tech:<id>` went.

## UNMODELLED

- Flowing Water timer cut on crit: Kiếm Ý notable not in the game, kept from the old file.
- linh lực regained on crit: a tree notable, not in the game.
- basic attack coefficient add: no engine field set for it in the old file.
- Hot Edge recent-crit condition: L5 held at a flat 10 points.
- crit chance still carries the old averaged Whet stacks.
- nine-temper-scripture art_speed_pct [kim] and hundred-blades-canon art_speed_pct [kim]: the engine reads art speed without hit context, so they apply to every art.
- nine-temper-scripture and hundred-blades-canon stack_duration_pct, afterimage-sword-canon and hundred-blades-canon status_duration_pct: no engine stat, not run.

## Observations

At the same realm the build wins 20 of 20 against typical in 15.0 s at Trúc Cơ and 12.1 s at Kết Đan, below the 30-60 s band, and it ends each fight with 62-66 % health left, so the fight is short because the build is fast, not because it is outlasted. The guide's 16-of-20 at Trúc Cơ (27 s) and 14-of-20 at Kết Đan (20 s) do not hold: both are now 20-0 and much shorter, and the "loses to a realm higher" claim holds (0-20 at ket_dan+1, 8.0 s). The "pool dry at about 15 s" claim does not hold at Trúc Cơ (you dry never), but at Kết Đan you run dry at 11.2 s. The foe dries first in both same-realm fights. Whetted Edge is replaced by whetstone-pass, which fires 11.3 times per fight; removing it lengthens the fight to 19.5 s, so it is the identity piece in the sense of the loop. Removing the main technique's passives costs only 1.5 s, so the passives matter far less than the arts. NEVER_FIRED in the upward matchups: needle-rain and flying-sword (typical ket_dan+1 and nguyen_anh+2; all four arts at top_end except whetstone-pass at top_end truc_co), since the fights end in 1-8 s. At same-realm typical every art fires. At Kết Đan, phantom-sword fires 4.0 times a fight.
