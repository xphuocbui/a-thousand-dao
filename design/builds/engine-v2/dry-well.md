# The Dry Well (Khô Tỉnh), rebuilt on the library: an Ice-stacking Water-root cultivator whose Winter Toll suite taxes the foe's art costs until it runs dry.

Realm Nguyên Anh (nguyen_anh), root Water 90 + Ice 72 (`purity`), files `builds/dry-well.fight.json` and `builds/dry-well.truc-co.fight.json`.

## Old piece to library piece

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Rime Needle (8 Ice stacks, cheap, every second) | `sleet-volley` (charges, icicles, 1 Ice stack each) | stilled-hour-sutra (1) |
| Leaking Seal (curse: drain wards bill +50 %) | `rime-lock-seal` (Ice stacks read into Heavy Breath, art costs up) | winter-toll-canon (1) |
| Drowning Palm (Qi Disruption burn) | no equivalent kept (see losses); `shatter-palm` takes the heavy cold palm slot | winter-toll-canon (6) |
| Undertow (blade, fires on a dry foe) | `black-ice-glaze` (primes the next art, Exposed + Ice stacks) | winter-toll-canon (4) |
| Dry Riverbed (second blade) | `stilled-instant` (freezes foe timers per 10 Ice stacks) | stilled-hour-sutra (2) |
| Spring at the Well's Mouth (heal) | dropped, no Ice/Water heal in the chosen suites | none |
| Dry Well Scripture passive (+60 Cold L2, etc.) | `winter-toll-canon` and `stilled-hour-sutra` passives | both |
| (new, no old piece) | `deep-winter-form` (stance: slower casts, every hit lays 2 Ice) | winter-toll-canon (2) |

Kept untouched: concept, realm, `purity` (the old files carried none; Water 90 and Ice 72 are taken from the guide's Water 90, Ice = 0.8 × Water), layers, crit, ward, body, art speed, and every Effect, item and keystone line (all still in `unmodelled`).

## Techniques chosen and why

- **Main: Winter Toll Canon (Đông Toán Kinh, `winter-toll-canon`, Profound, bang).** A whole suite of four arts (layers 1, 2, 4, 6, all open at Nguyên Anh) built around Ice stacks on the foe: the Seal turns stacks into art-cost curses, the Palm cashes them. It is the closest library match to "Ice makes their arts cost more".
- **Auxiliary: Stilled Hour Sutra (Đình Thời Kinh, `stilled-hour-sutra`, Heaven secret, bang).** Two of its arts: Sleet Volley (the Ice stacker, the needle's role) and Stilled Instant (reads Ice stacks to freeze timers). Passives add Ice stack effect and duration.
- Second auxiliary slot left empty: no Water/Ice-usable catalogue technique served the concept without crowding the six slots. Hollow Tide Scripture (Qi Disruption) is a main method, so it could not sit beside Winter Toll.
- Arts at Nguyên Anh (6 slots): rime-lock-seal, sleet-volley, deep-winter-form, black-ice-glaze, stilled-instant, shatter-palm. At Trúc Cơ (4 slots, layers up to 6): rime-lock-seal, sleet-volley, deep-winter-form, shatter-palm.

## Lost in the move

- **Leaking Ward curse (drain wards bill +50 %) and Leaking Seal**: the library has no art that makes a ward bill more. The Seal raises art costs instead; the bill raise stays only as the unmodelled Absolute Zero / Weighted Bucket lines.
- **Drowning Palm's Qi Disruption (pool burn) and Owed Water's synergy**: the burn arts live in Hollow Tide Scripture, a main method, so one cannot be taken beside Winter Toll.
- **The two guarded "blades" (Undertow, Dry Riverbed)**: no library art fires on "enemy linh lực ≤ 5 %" and library arts take no overrides; the Bare Vessel payoff has no art to ride.
- **Spring at the Well's Mouth (heal)**: dropped for slots.
- The guards, the art order and the "bucket / blade" design of the old build are gone. What remains is an Ice-stack build, not a dry-the-pool build.

## Results (Nguyên Anh, 20 fights each, seeded)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical nguyen_anh+0 | 4.0 | 20-0-0 | never | 4.0 | trig_budget 3.0 |
| typical hoa_than+1 | 7.2 | 20-0-0 | never | 6.7 | trig_budget 1.2, trig_cap 0.8 |
| top_end nguyen_anh+0 | 13.7 | 0-20-0 | 11.9 | never | trig_budget 1.0, trig_cap 2.0 |
| top_end hoa_than+1 | 7.4 | 0-20-0 | 6.7 | never | trig_budget 0.1 |

Trúc Cơ file (typical, one run, no matrix): mean 15.0 s, 20-0-0, you dry never, foe dry 9.4, clipped trig_budget 2.0.

## `--without` tests (typical, same realm nguyen_anh+0)

- `--without tech:winter-toll-canon` (main technique's passives; its arts stay): mean 4.0 → 4.0 s, wins 20 → 20 (NO_CHANGE). Top-end +0: 13.7 → 12.6 s, still 0 wins.
- `--without rime-lock-seal` (the identity art): mean 4.0 → 4.0 s, wins 20 → 20 (NO_CHANGE). At the +1 realm: 7.2 → 7.7 s; top-end +0: 13.7 → 16.0 s, still 0 wins.

## UNMODELLED

- Cold Toll / Absolute Zero: no engine action lets Ice stacks raise the foe's drain bills; the identity keystone is not run.
- Owed Water: the engine has no linh lực debt concept.
- Water Table: no readable for the foe's ward payment feeding your linh lực (its regeneration close is modelled).
- Frost Tithe: no readable for the extra art cost your Ice made them pay.
- Still Water: linh lực overflow healing is not expressed.
- Weighted Bucket: `ward_bill_pct` is a stat the engine does not apply here; unmodelled.
- Cracked Clay: scaling L5 on the foe's Ice stack count is not expressed as an Effect in this file.
- Mountain Screen and Thousand-Layer Cloud: reserved shields; only their reservation is modelled.
- #44 defence (resistance in points, drain scaling): carried from the old file.
- v1 reserve_share, regen_bonus_pct, pierce_pct: retired fields from the migration, kept as notes.
- Bare Vessel (v1 conditional_mods): its guard on the foe's pool is not expressed as a field; the old build modelled it with a retired v1 key.
- Technique passives with no engine stat (stack effect / duration / status duration / body shield) and the seal- and cold-scoped speed and cost passives, which the engine applies to every art.
- Weighted Bucket at Trúc Cơ (+10 %), Frost Tithe there too (same reasons as above).

## Observations

At Nguyên Anh against the typical foe the fight lasts 4.0 s, well under the 30-60 s band; at one realm up (hoa_than+1) 7.2 s, still short; against top_end it runs 13.7 s and is lost every time, 0-20, with the build running dry at 11.9 s. Trúc Cơ typical lasts 15.0 s, also under the band. The guide's claims do not hold on the library build: it said top-end is won at 2.0 s with 81 % health, here the top-end foe wins every fight and the Ice never empties its pool, because the Absolute Zero bill raise, the Weighted Bucket, Water Table and the guarded blades are all missing. The foe never goes dry in the top-end runs. The identity tests barely move the typical fight (NO_CHANGE at the same realm), so the Ice tax is not what decides it. Removing the Seal makes the top-end fight slower, not faster, 13.7 to 16.0 s, which says it does help. No art was NEVER_FIRED in any matchup; all six fire in every row.
