# Soul Lance (Hồn Thương) — carry heavy treasures, push a needle of thought through the enemy's soul once a second until the fourth kills; rebuilt from the library as a Hollow Bell Canon toll-engine.

Defining realm: Nguyên Anh (nguyen_anh). The old build had only one fight file, so there is no other-realm file. Root: Water (`purity` `{"water": 70}`; the old fight file carried no purity, so this is taken from the guide's "single Water, purity 70+").

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Lamp-Threading Needle (soul hit + Slackened Soul) | lamp-oil-lance (loosens the soul, Slackened Soul) | hollow-bell-canon (3) |
| Heart-Lamp Lance (big soul hit, engine of the cycle) | tolling-bell-requiem (Toll counter, Great Peal / Death Knell soul strikes) | hollow-bell-canon (1) |
| Mountain-Splitting Thought | mountain-splitting-thought | generated common technique (common art) |
| Lamp-Threading Scripture (+22.5 % divine sense, Still Flame +30 soul damage) | hollow-bell-canon passives (x_soul +4, art_speed +4 soul, art_cost -3 costly) | hollow-bell-canon |
| (none: fuel and curse support) | seep-through-palm, marrow-to-dew, drag-of-the-deep | undertow-litany (1, 3, 5) |
| Lamp-Light (heal) | none | lost |
| Lantern Out (escape) | none | lost |
| Bell of Waking (cleanse) | none | lost |
| Ninth-Weight Lance (Deity Transformation) | none | lost |

Kept untouched: root, realm, layers, crit, ward, body, n_body/n_qi, art_speed_pct 100, regen_bonus_pp 1. The old file had no effects, counters or states of its own (every v1 art was dropped by the migration), so none were removed. I removed the three `v1 art ... dropped` lines and the Slackened Soul line (now modelled by the art), which belonged only to the invented arts.

## Techniques chosen and why

- **hollow-bell-canon** (Yellow main, thuy): the only technique built on soul arts. Its Toll counter feeds on every soul hit, which fits a soul-lance concept. I took the whole suite (both arts).
- **undertow-litany** (Yellow secret, thuy): usable by a Water root; its marrow-to-dew restores linh lực (stand-in for the missing Lamp-Oil Siphon fuel) and drag-of-the-deep delays the foe's timers (stand-in for Soul Wound).
- **Generated common technique**: brings mountain-splitting-thought, the one old art that exists in the library unchanged. 6 arts, which fills the 6 slots at nguyen_anh.

## Lost in the move

- Heart-Lamp Lance, Lamp-Threading Needle, Lamp-Light, Lantern Out, Bell of Waking and Ninth-Weight Lance have no library equivalent. The nearest are tolling-bell-requiem and lamp-oil-lance, which are different rules (Toll-based and divine-sense-paid), not the same pieces.
- Lamp-Threading Scripture's +22.5 % divine sense and Still Flame +30 soul damage: no library technique carries them.
- No heal, no escape, no cleanse art. Survival rests on the ward and body of the old file.
- The old file's numbers that carry the soul build (v1 x_soul 157, divine_sense 7800, pierce 30, soul_res 45) were already in `unmodelled` and still are, so the soul share the simulator uses is the engine default, not the guide's. This is the biggest reason the fights below are much slower than the guide's 4 s.

## Matchups (nguyen_anh file, `--matrix`)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical nguyen_anh+0 | 21.7 | 20-0-0 | never | 11.6 | trig_budget 29.0 |
| typical hoa_than+1 | 30.7 | 20-0-0 | never | 21.7 | trig_budget 30.2 |
| top_end nguyen_anh+0 | 15.9 | 0-20-0 | never | never | none reported |
| top_end hoa_than+1 | 6.9 | 0-20-0 | never | never | none reported |

## --without tests (typical nguyen_anh+0, before and after)

| Run | Mean s | W-L-other | Foe dry | Health left |
|---|---|---|---|---|
| full build | 21.7 | 20-0-0 | 11.6 | 50 % |
| `--without tech:hollow-bell-canon` (main technique passives) | 21.0 | 20-0-0 | 11.8 | 55 % |
| `--without tolling-bell-requiem` (identity piece) | 56.5 | 14-6-0 | 7.5 | 4 % |

Same tests at hoa_than+1: full 30.7 s, 20-0; without the main technique 44.1 s, 20-0 (health left 5 %); without tolling-bell-requiem 62.0 s, 0-20. The identity piece used is tolling-bell-requiem; the guide's real identity piece, the Effect Thousand-Weight Thought, is not in the library and cannot be removed.

## UNMODELLED

- Thousand-Weight Thought is inside x_soul (60 of the 157): it is a Đạo Effect not in the engine or library.
- Soul shields (Soul-Guarding Lamp on the foe): the engine has no soul-ward payload.
- Soul Wound and Splinters of Thought: enemy timer delays per soul hit and per clipped share are not modelled by the old file's inputs.
- Lamp-Oil Siphon (25 % of the linh lực a soul hit takes comes back): no readable for the power a soul hit takes.
- First Move (first soul art free): not expressed in the file.
- The fortress (5 free ward slots, 7 defensive artifacts, Open Sky): ws/we 180 stands in for it.
- enemy_divine_sense is one ratio for every row: the matrix's gap rows do not scale the foe's thần thức.
- health_units 16 vs 64 (CONSTANT_DRIFT): the foe's hits take 4x more of our health than they would.
- v1 stage 1.3, pierce_pct 30, soul_res_pct 45, x_soul 157, divine_sense 7800, enemy_divine_sense 4260, guard, enemy_overrides soul_res_pct 15, retired ward shape: old-format fields with no counterpart in the loader; kept as the old file listed them.
- hollow-bell-canon passives art_speed_pct [soul] and art_cost_pct [costly] apply to every art (engine reads them without hit context); status_duration_pct [curse] has no engine stat; undertow-litany art_speed_pct [curse] likewise, and its status_duration_pct is not run.

## Observations

Fights at nguyen_anh+0 last 21.7 s against a typical foe: below the 30-60 s band, and far longer than the guide's 4.0 s. At hoa_than+1 the fight is 30.7 s, at the bottom edge of the band. The guide's claims do not hold in this model: the 4 s kill and the cap-hitting lances are not reproduced (the old soul inputs are unmodelled, so soul share is the engine default), the build loses 0-20 to both top_end foes (15.9 s and 6.9 s), and the foe runs dry at 11.6 s while we never do, so the fuel story at least holds. NEVER_FIRED in every row: lamp-oil-lance (lamp-oil-lance is paid in than_thuc and the file sets no divine_sense; that is a likely cause, not confirmed; no cause is known for mountain-splitting-thought) and mountain-splitting-thought. With tolling-bell-requiem removed they fire (17.0 and 25.6 per fight) but the fight takes 56.5 s and is lost 6 times in 20, so the Toll engine is carrying the build. Removing the technique passives changes little at nguyen_anh (21.0 s) but hurts at hoa_than+1 (44.1 s). I did not tune any number; the NEVER_FIRED arts and unset divine sense are left as the inputs produced them.
