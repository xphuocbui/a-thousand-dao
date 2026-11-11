# Two Clocks (Song Thời) — library rebuild

Never strike: bury the enemy in Burn (fast clock) and Poison (slow clock) until their linh lực runs dry and the rot finishes them.

Files: `design/builds/engine-v2/builds/two-clocks.fight.json` (nguyen_anh, the defining realm; the old build had no other realm file, so there is no second file).

## Piece map

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Ember Rain (fast Burn clock, 20 stacks / 2 s) | flint-volley (Burn, 3 charges) | red-sun-scripture (2) |
| Red Censer (second Burn source) | heat-haze (Burn + Slowed Time, reads 25 Burn) | ashen-phoenix-canon (3) |
| Burn engine / Banked Coals-style payoff | furnace-heart (Heat: +1 % Fire per Heat) | red-sun-scripture (4) |
| Rot Seed (thin long Poison) | thorn-rain (6 thorns, 1 Poison each) | rotting-canopy-canon (1) |
| Green Censer (second Poison source) | blight-canker (Poison + Stagnation, ticks add Stagnation) | rotting-canopy-canon (2) |
| Sap Rising / Spring Sap (Wood buff) | none | none (dropped) |
| Golden Light Shield | none | none (dropped) |
| (Poison depth) | thornling-grove (summon, Poison seeding) | rotting-canopy-canon (6) |

Kept as in the old file: realm, layers, crit, ward, n_body/n_qi, regen, enemy. Added `purity` fire 80 and wood 80 from the guide (the old file carried none; it had folded purity into c_tick). Every Effect the old file had was already in `unmodelled`, so none were carried over.

## Techniques chosen and why

- **red-sun-scripture** (Profound main, hoa): the Fire suite. flint-volley lays Burn, furnace-heart turns every Fire hit into Heat, a standing "more" for the Burn clock. Its +3 Fire more fits the fast clock.
- **ashen-phoenix-canon** (Earth secret, hoa): passive damage_more +4 and attack +8 on `over_time, hoa`, which is the Burn tick channel. heat-haze is the closest library stand-in for the Burn-stack-reading Red Censer.
- **rotting-canopy-canon** (Earth secret, moc): the whole Poison suite (thorn-rain, blight-canker, thornling-grove), with stack_duration +16 and stack_effect +10 on Wood. It is the Poison clock, and blight-canker's Stagnation matches the old Ruin/Wither role.

Six arts fill the six slots at nguyen_anh. The unused library arts of the three techniques (brazier-form, twin-flame-echo, blood-fed-pyre, ash-rebirth, bloodroot-pact) were left out for slots.

## What was lost

- **Ember Rain** (20 Burn stacks for 2 s, every second) exists in the library only as a common art, and a common technique brings exactly one art and displaces a catalogue technique. flint-volley (2 stacks for 6 s) is a much slower fast clock. The "front-loaded Burn" identity is gone.
- **Rot Seed** likewise (common art); thorn-rain (6 thorns of 1 stack for 6 s) replaces it.
- **Spring Sap / Sap Rising** and the Wood regeneration buff: no carried library art in these techniques. Sustain is lost.
- **Golden Light Shield**: no library equivalent in the chosen suites.
- **Ash Ledger, Spillover, Embers Feed the Hearth, Cinder Debt, Incense Clock price**: all UNMODELLED in the old file too; still unmodelled. The identity piece (Ash Ledger) has no library equivalent, so the `--without` identity test uses blight-canker, the closest first-clock-style art (it feeds Stagnation off Poison ticks).
- Technique passives with no engine stat (stack_effect, stack_duration, status_duration, art_cost_health) are not run.

## Matchups (20 seeds, nguyen_anh unless noted)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical nguyen_anh+0 | 20.5 | 20-0-0 | never | 16.9 s | canker-spread 174.9, canker-wither 154.8 |
| typical hoa_than+1 | 54.7 | 20-0-0 | never | 33.7 s | canker-spread 850.5, canker-wither 855.5, grove-seed 9.2 |
| top_end nguyen_anh+0 | 8.0 | 0-20-0 | 7.8 s | never | canker-spread 10.5 |
| top_end hoa_than+1 | 3.7 | 0-20-0 | 3.6 s | never | none |

## `--without` tests (typical, nguyen_anh+0)

| Removed | Before | After |
|---|---|---|
| `tech:red-sun-scripture` (main technique passives) | 20.5 s, 20-0, foe dry 16.9 s | 20.2 s, 20-0, foe dry 16.5 s |
| `blight-canker` (identity stand-in) | 20.5 s, 20-0, foe dry 16.9 s | 26.3 s, 20-0, foe dry 20.7 s |

For completeness: removing blight-canker at typical hoa_than+1 takes the fight from 54.7 s to 66.0 s and health left from 100 % to 30 %. Top-end results do not change in either test (still 0-20; 8.0 s and 3.7 s).

## UNMODELLED

- Twin-Wick Incense Clock: L5-on-ticks and "your hits deal no damage"; library arts take no overrides, so hits stay.
- Ash Ledger: needs a tick-prevented readable the engine lacks.
- Spillover and Embers Feed the Hearth: were not Effects in the old file; left out.
- Drain-ward billing of ticks and the ward falling at 0 linh lực (the first clock): not modelled for ticks.
- Cinder Debt: cleansed-stack burn on the cleanser.
- Common Ward and Mountain Screen: ward block is the old pass model.
- Purity fire/wood 80: added from the guide, not from the old file.
- Technique passives: red-sun art_speed and art_cost_pct scoped [fire] apply to every art; stack_effect/stack_duration/status_duration passives of all three techniques and rotting-canopy's art_cost_health are not run; rotting-canopy art_speed [moc] applies to every art.

## Observations

At the same realm the typical fight lasts 20.5 s at nguyen_anh, under the 30-60 s band, and 54.7 s at hoa_than+1, inside it; the top-end foe kills this build in 8.0 s (3.7 s one realm up) with the build never drying, so it loses all 40 top-end fights. The guide's claims do not hold on the engine: the "first bell" at about 3 s and a 4 s kill against an ordinary cultivator is now a 17 s linh lực drain and a 20 s kill, and the strong-foe win at about 8 s is a loss at 8.0 s. That is expected, since the library arts have no 20-stack, 2-second Burn batch and the Incense Clock, Ash Ledger and Spillover are not modelled; the guide's weakness against burst builds ("a bad matchup") is confirmed, and extended here to the top-end foe. flint-volley is NEVER_FIRED in both top_end runs, and heat-haze, thorn-rain, blight-canker and thornling-grove are NEVER_FIRED at top_end hoa_than+1 (the fight ends before they come up). The main technique's passives barely matter here (20.5 to 20.2 s), while blight-canker is the piece the fight leans on (+5.8 s without it, and health left drops to 30 % one realm up). Clipping is heavy for canker-spread and canker-wither, so much of blight-canker's Stagnation spread is cut by a cap.
