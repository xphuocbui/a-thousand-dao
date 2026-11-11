# Fire family tuning

## Before
suite_check	fire	suite ashen-phoenix-canon	truc_co	mean 19.6 s, typical mirror 25.6 s, x0.76 (near typical)	W-L 20-0
suite_check	fire	suite ashen-phoenix-canon	ket_dan	mean 16.1 s, typical mirror 20.0 s, x0.81 (near typical)	W-L 20-0
suite_check	fire	suite red-sun-scripture	truc_co	mean 9.3 s, typical mirror 25.6 s, x0.37 (FAST)	W-L 20-0
suite_check	fire	suite red-sun-scripture	ket_dan	mean 9.0 s, typical mirror 20.0 s, x0.45 (FAST)	W-L 20-0
suite_check	fire	art scorch-fist	truc_co	mean 28.8 s, typical mirror 25.6 s, x1.12 (near typical)	W-L 6-14
suite_check	fire	art scorch-fist	ket_dan	mean 20.9 s, typical mirror 20.0 s, x1.04 (near typical)	W-L 5-15

(Before, furnace-heart was NEVER_ENGAGED in red-sun-scripture at both realms.)

## After
suite_check	fire	suite ashen-phoenix-canon	truc_co	mean 20.1 s, typical mirror 25.6 s, x0.78 (near typical)	W-L 20-0
suite_check	fire	suite ashen-phoenix-canon	ket_dan	mean 16.1 s, typical mirror 20.0 s, x0.81 (near typical)	W-L 20-0
suite_check	fire	suite red-sun-scripture	truc_co	mean 15.9 s, typical mirror 25.6 s, x0.62 (near typical)	W-L 20-0
suite_check	fire	suite red-sun-scripture	ket_dan	mean 12.6 s, typical mirror 20.0 s, x0.63 (near typical)	W-L 20-0
suite_check	fire	art scorch-fist	truc_co	mean 28.8 s, typical mirror 25.6 s, x1.12 (near typical)	W-L 6-14
suite_check	fire	art scorch-fist	ket_dan	mean 20.9 s, typical mirror 20.0 s, x1.04 (near typical)	W-L 5-15

Engagement now (per fight, Trúc Cơ / Kết Đan): flint-volley 1.6 / 1.6, furnace-heart 1.0 / 0.7, twin-flame-echo 3.0 / 3.0, ash-rebirth 1.0 / 1.0, heat-haze 2.5 / 2.0. No NEVER_ENGAGED.

## Changes
- furnace-heart: the vent gate was one OR-group and never opened. It is now 4 Heat AND (15 Burn on the foe OR 2 Red Sun arts in 3 s). c_mult 5.5 -> 2.5. The consume cap rose from 40 to 60 Burn, and each stack burnt is one free hit, so the payoff scales with what was fed and has no cap. It pays 4 Heat.
- flint-volley: Flashfire gate is now (6 Fire buff OR 15 Burn) AND another Red Sun art in 3 s. c_mult 2.5 -> 0.9 per hit. Quicken 8 % -> 4 % per quick Fire art. It consumes 6 buff stacks.
- twin-flame-echo: bloom gate is now 3 flames AND (Brazier OR 30 Burn OR 3 Red Sun arts in 3 s). c_mult 5.0 -> 2.2. It still blooms about 3 times a fight, above the 1-2 target, because the flames fill fast. I left it because tightening further risked pushing the suite out of x0.6-1.0.
- ash-rebirth: the Phoenix Pyre gate is now (6 Ash OR below 35 % health) AND (20 Burn OR 2 Ashen Phoenix arts in 3 s). The 50 Burn and 3-art routes were folded into the second group.
- heat-haze, scorch-fist, blood-fed-pyre, brazier-form: unchanged (in range and engaged). No never-opening routes found in this family.
- family-fire.md table rows updated to match. Lint: 0 findings.
- Caveats: Red Sun sits near the low edge (x0.62 / x0.63). Ashen Phoenix is x0.78 / x0.81, under the typical mirror. A fight is 20 runs per cell, so these are noisy.
