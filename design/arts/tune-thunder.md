# Thunder tuning (suite_check)

## Before
```
suite_check	thunder	suite thousand-bolt-scripture	truc_co	mean 9.9 s, typical mirror 25.6 s, x0.39 (FAST)	W-L 20-0
suite_check	thunder	suite thousand-bolt-scripture	ket_dan	mean 9.5 s, typical mirror 20.0 s, x0.47 (FAST)	W-L 20-0
suite_check	thunder	suite heavenly-tribulation-scripture	truc_co	mean 8.0 s, typical mirror 25.6 s, x0.31 (FAST)	W-L 20-0
suite_check	thunder	suite heavenly-tribulation-scripture	ket_dan	mean 8.0 s, typical mirror 20.0 s, x0.40 (FAST)	W-L 20-0
```
NEVER_ENGAGED: tribulation-seal and thunderclap-bind (both realms).

## After
```
suite_check	thunder	suite thousand-bolt-scripture	truc_co	mean 15.7 s, typical mirror 25.6 s, x0.61 (near typical)	W-L 18-2
suite_check	thunder	suite thousand-bolt-scripture	ket_dan	mean 14.0 s, typical mirror 20.0 s, x0.70 (near typical)	W-L 18-2
suite_check	thunder	suite heavenly-tribulation-scripture	truc_co	mean 15.9 s, typical mirror 25.6 s, x0.62 (near typical)	W-L 20-0
suite_check	thunder	suite heavenly-tribulation-scripture	ket_dan	mean 12.2 s, typical mirror 20.0 s, x0.61 (near typical)	W-L 20-0
```
Every engine art now engages (Palm, Chain Arc step 1+2, Peal empower, Seal step 1, Bind step 1). Lint: 0 findings.
The top steps of the Palm, Seal and Bind did not fire in these typical-build runs (the build has not built the engine); Chain Arc step 2 fires 0.9 per fight.
The standalone arts (Overload Form, Stormcloud Familiar, Storm Bank) print no suite_check row of their own; they are inside the suite runs.

## Changes
- Capacitor Palm: c_art 2.0 -> 1.0; discharge strike 0.22 -> 0.15 per Charge; step 1 gate 4 -> 3 Charges, c_mult 2 -> 1.6.
- Capacitor Palm step 2: gate was one OR-group (8 Charges / 6 foe stacks / 3 scripture arts); now 6 Charges AND (6 foe stacks OR 3 scripture arts); c_mult 6 -> 4.
- Chain Arc: c_art 0.9 -> 0.5; step 1 c_mult 2 -> 1.6.
- Chain Arc step 2: gate now needs a Thunder stack condition (2 own or 4 foe) AND (3 Peals, 4 Charges or 3 scripture arts); consume 4 -> 2 own stacks so it can be paid; c_mult 3 -> 2.5.
- Answering Peal: c_art 1.8 -> 0.9; empower c_mult 4 -> 3; empower gate now (3 Peals or 3 scripture arts) AND (3 foe or 2 own Thunder stacks); the 5-foe-stack route is folded into the AND.
- Overload Form: art_speed 35 -> 25, crit 20 -> 15.
- Tribulation Seal: c_art 1.2 -> 0.4; heaven-strike 0.18 -> 0.02 per 4 stacks (uncapped scaling kept); step 1 gate 8 -> 4 foe stacks (or 4 Charges, or a Slowed foe), c_mult 2.5 -> 2.
- Tribulation Seal step 2: gate was a 4-way OR; now 6 foe stacks AND (Slowed x2, foe at 50 % health or 3 scripture arts); consume 8 -> 6 foe stacks; c_mult 7 -> 5.
- Thunderclap Bind: c_art 1.2 -> 0.4; step 1 gate gains a 4-foe-stack route (Seal feeds it) and the dry-foe route is 60 % linh lực (was 25 %), c_mult 2.5 -> 2.
- Thunderclap Bind step 2: gate was an OR-group needing 3 Slowed Time (unreachable: it lays 2); now 4 foe stacks AND (Slowed x2, 3 Peals or 3 scripture arts); c_mult 6 -> 4.
- Stormcloud Familiar: c_art 1.5 -> 0.2; summon strike 0.55 -> 0.08 (the suite was FAST while this and Storm Bank were high).
- Storm Bank: c_art 2.2 -> 0.9; per-bolt damage ramp 25 -> 2 %.
- Rule texts in the JSON and the table in family-thunder.md updated to match.
