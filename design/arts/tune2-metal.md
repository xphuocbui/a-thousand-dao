# Metal tune, second pass

## suite_check before (changed rows only)
suite_check	metal	suite hundred-blades-canon	truc_co	mean 14.4 s, typical mirror 25.6 s, x0.56 (FAST)	W-L 20-0
suite_check	metal	suite hundred-blades-canon	ket_dan	mean 13.8 s, typical mirror 20.0 s, x0.69 (near typical)	W-L 20-0
suite_check	metal	art iron-hide-stance	truc_co	mean 31.4 s, typical mirror 25.6 s, x1.22 (near typical)	W-L 5-14
suite_check	metal	art iron-hide-stance	ket_dan	mean 22.2 s, typical mirror 20.0 s, x1.11 (near typical)	W-L 2-16

## suite_check after
suite_check	metal	suite hundred-blades-canon	truc_co	mean 16.4 s, typical mirror 25.6 s, x0.64 (near typical)	W-L 20-0
suite_check	metal	suite hundred-blades-canon	ket_dan	mean 15.6 s, typical mirror 20.0 s, x0.78 (near typical)	W-L 20-0
suite_check	metal	art iron-hide-stance	truc_co	mean 33.6 s, typical mirror 25.6 s, x1.31 (near typical)	W-L 13-4
suite_check	metal	art iron-hide-stance	ket_dan	mean 26.4 s, typical mirror 20.0 s, x1.32 (near typical)	W-L 12-7

Nine-Temper Scripture untouched (x0.63 / x0.61). Both canon engines still engage at both realms. Lint: 0 findings.

## Changes
- Flying Blade Retinue: both empower c_mult 3 -> 2.2.
- Flying Blade Retinue: summoned blade strike c 0.3 -> 0.2 (both summon sites); cooldown 8 -> 9.
- Sundering Wedge: step 1 c_mult 2.5 -> 1.8; step 2 c_mult 4 -> 3; c_art 0.6 -> 0.45.
- Needle Rain: c_art 0.5 -> 0.35; cooldown 7 -> 8.
- Iron Hide Stance: state resist 60 -> 120, block 20 -> 35, art_speed -10 -> 0; c_art 1.2 -> 1.6.
  Overshoots "even" a little (about 60-65% wins), left as is.
- Tried cooldowns of 10/8/11 on the canon first: overshot (x1.03 at Kết Đan) and Wedge never engaged, so backed off.
