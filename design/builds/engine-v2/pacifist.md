# The Unquarrelling Ledger (Bất Tranh Trướng), rebuilt on the library: a tide-and-undertow sustain build that wins by outlasting the foe's linh lực pool.

Defining realm Kết Đan (ket_dan, 5 slots); also fought at Nguyên Anh (nguyen_anh, 6 slots). Root `purity` water 80, unchanged. Kept as in the old file: layers, crit, ward, body, curses (stagnation), `healing_pct` 20, regeneration, evade, art speed and cost.

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Still Tide (heal, 2 Water stacks) | `brimming-cup` (restores linh lực, body shield, Water stacks) | still-moon-tide-scripture (4) |
| Still Tide, the sustain stance idea | `deep-lake-stance` (regenerate and heal faster, deal 30 % less) | still-moon-tide-scripture (1) |
| Interest (their spend returns to you) | `gathering-wave` (banked waves heal 2 % each) | still-moon-tide-scripture (2) |
| Cold Ledger (ice stacks, dearer arts) | none usable: ice arts need `bang`, build has water purity only. Nearest: `drag-of-the-deep` (Slowed Time, delays their slowest art) | undertow-litany (5) |
| Silent Tally (Stagnation, Qi Disruption) | none usable (`marrow-siphon-palm` is a hollow-tide art; one main only). Stagnation stays as the build's curse | none |
| Closing the Book (Nguyên Anh) | `marrow-to-dew` (pay health, restore 20 % linh lực), added as 6th art at Nguyên Anh | undertow-litany (3) |
| (new, the suite's payoff) | `swelling-tide-palm` (Tide grows with every heal, no cap) | still-moon-tide-scripture (6) |

Open Palm Vow, Debt Seal, Interest, Backlash Count, Unspent Edge, Dread of the Ledger were never arts in the old fight file. They stay as the guide describes and appear in `unmodelled`.

## Techniques chosen and why

- **Still Moon Tide Scripture** (main, thuy): the guide's identity is healing, ward refill and `healing_pct`. This suite is built on being healed (Tide counts heals), and the build already carries `healing_pct` 20 and extra regeneration to feed it. Its stance cuts your own damage by 30 %, the closest library thing to pacifism.
- **Undertow Litany** (secret, thuy): the only water secret that works on the foe's clock and pool (Slowed Time, delayed arts, linh lực back to you). It stands in for the old Cold Ledger and Silent Tally.
- No body technique: slots are full of the two suites. Ice suites (Winter Toll, Stilled Hour) were rejected because the build has no `bang` purity.

## Lost in the move

- Pacifism: `gathering-wave`, `swelling-tide-palm` and `drag-of-the-deep` deal damage. No library art is a pure no-damage ice-stack art usable by water purity (the common `cold-ledger` is ice).
- Ice stacks raising the foe's art costs (Cold Ledger): gone; nothing usable replaces it.
- Qi Disruption and Silent Tally: gone (hollow-tide needs the one main slot).
- Debt Seal and the health-pay engine: no library art lays Seals; still UNMODELLED.
- Layer-4 Silent Tally and layer-1 Cold Ledger timing of the old sutra no longer exist.

## Fights (20 seeds each)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical ket_dan+0 | 48.8 | 20-0-0 | never | 26.4 | trig_budget 17.8, trig_cap 1.0 |
| typical nguyen_anh+1 | 9.3 | 0-20-0 | 7.7 | never | tide-from-healing 2.4 |
| typical hoa_than+2 | 4.0 | 0-20-0 | 2.8 | never | tide-from-healing 1.0 |
| top_end ket_dan+0 | 1.3 | 0-20-0 | 1.3 | never | none |
| top_end nguyen_anh+1 | 1.0 | 0-20-0 | 1.0 | never | none |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never | none |
| typical nguyen_anh+0 (nguyen-anh file, 6 arts, no matrix) | 48.8 | 20-0-0 | never | 26.5 | trig_budget 23.4, trig_cap 3.9 |

Health left at the end of the typical ket_dan+0 fight: 100 %.

## --without tests (typical ket_dan+0, before -> after)

- `--without tech:still-moon-tide-scripture` (the main technique's passives): 48.8 s -> 53.3 s, 20-0 -> 20-0, foe dry 26.4 -> 28.7, health 100 % -> 100 %.
- `--without drag-of-the-deep` (identity piece, the foe-clock art): 48.8 s -> 61.4 s, 20-0 -> 20-0, foe dry 26.4 -> 26.3, health 100 % -> 96 %. (The art is removed from the loadout, so the other four fire more often.)

## UNMODELLED

- Debt Seal (enemy arts also cost health): no sim field, and no library art lays it.
- Basic attack zeroed by the enabler (Open Palm Vow): the sim basic attack still runs at base.
- Heart-demon Dread and enemy flight: the engine does not model escape.
- Held Reflection / returned costs: not modelled.
- Technique passives `art_speed_pct` scoped [thuy] and [curse]: the engine reads art speed without hit context, so it applies to every art.
- `health_regen_inc_pct +18` and `stack_duration_pct +10` (still-moon-tide), `status_duration_pct +6 [curse]` (undertow-litany): no engine stat, not run.

## Observations

At Kết Đan the typical foe is beaten in 48.8 s, inside the 30-60 s band, with the foe's linh lực dry at about 26 s and the build never dry and at full health: the guide's "never dry, foe runs dry around 21 s" holds in shape, but the guide's 60 % health left and 65 s fight do not (100 % health, 48.8 s). The cause is partly not the guide's mechanism: Seals, Interest, Backlash Count and Cold Ledger's cost stacks are absent, so the win comes from the ward, body and sustain kept from the old file plus the library's healing arts. The win is not shown to depend on the technique: removing the main technique's passives costs only about 4.5 s, and removing `drag-of-the-deep` lengthens the fight to 61.4 s, just above the band. Against a foe one realm above (nguyen_anh+1) the build dies in 9.3 s and against hoa_than+2 in 4.0 s, matching the guide's "dead in 9 s"; top-end builds kill it in 1.0-1.3 s. The nguyen-anh file against a same-realm typical foe gives 48.8 s, the same mean as the ket_dan file; I did not investigate whether that is coincidence or the fitted enemies converging. NEVER_FIRED arts: gathering-wave, brimming-cup and drag-of-the-deep against typical hoa_than+2; every art against all three top_end enemies (the build dies in about a second). The "trig_budget" clip (17.8 per fight) shows the free hits from waves and overflow are being cut by the trigger budget, so the suite's payoff is under-measured. The identity "pacifist" is not kept: three of five arts deal damage.
