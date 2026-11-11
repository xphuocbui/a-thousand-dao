# Tune: body family

## suite_check before
```
suite_check	body	suite unbroken-flesh-canon	truc_co	mean 15.8 s, typical mirror 25.6 s, x0.62 (near typical)	W-L 20-0
suite_check	body	suite unbroken-flesh-canon	ket_dan	mean 14.9 s, typical mirror 20.0 s, x0.75 (near typical)	W-L 20-0
suite_check	body	suite hundred-echo-palm-scripture	truc_co	mean 14.4 s, typical mirror 25.6 s, x0.56 (FAST)	W-L 20-0
suite_check	body	suite hundred-echo-palm-scripture	ket_dan	mean 14.4 s, typical mirror 20.0 s, x0.72 (near typical)	W-L 20-0
suite_check	body	art mountain-root-stance	truc_co	mean 40.0 s, typical mirror 25.6 s, x1.56 (near typical)	W-L 20-0
suite_check	body	art mountain-root-stance	ket_dan	mean 31.0 s, typical mirror 20.0 s, x1.55 (near typical)	W-L 18-2
suite_check	body	art bone-turning-palm	truc_co	mean 19.5 s, typical mirror 25.6 s, x0.76 (near typical)	W-L 18-1
suite_check	body	art bone-turning-palm	ket_dan	mean 16.8 s, typical mirror 20.0 s, x0.84 (near typical)	W-L 19-1
```

## suite_check after
Suite rows from the run before the Mountain Root change; the Mountain Root rows from the final run (the other rows did not change in it).
```
suite_check	body	suite unbroken-flesh-canon	truc_co	mean 18.1 s, typical mirror 25.6 s, x0.71 (near typical)	W-L 20-0
suite_check	body	suite unbroken-flesh-canon	ket_dan	mean 14.9 s, typical mirror 20.0 s, x0.75 (near typical)	W-L 20-0
suite_check	body	suite hundred-echo-palm-scripture	truc_co	mean 18.6 s, typical mirror 25.6 s, x0.73 (near typical)	W-L 20-0
suite_check	body	suite hundred-echo-palm-scripture	ket_dan	mean 16.5 s, typical mirror 20.0 s, x0.83 (near typical)	W-L 20-0
suite_check	body	art mountain-root-stance	truc_co	mean 25.3 s, typical mirror 25.6 s, x0.99 (near typical)	W-L 20-0
suite_check	body	art mountain-root-stance	ket_dan	mean 20.1 s, typical mirror 20.0 s, x1.00 (near typical)	W-L 20-0
suite_check	body	art bone-turning-palm	truc_co	mean 20.8 s, typical mirror 25.6 s, x0.81 (near typical)	W-L 18-2
suite_check	body	art bone-turning-palm	ket_dan	mean 17.3 s, typical mirror 20.0 s, x0.86 (near typical)	W-L 18-1
```
Lint: 0 findings. No NEVER_ENGAGED line; the top steps no longer fire in the typical build (0 per fight), which is under the "once or twice" target, not over it. Further loosening would reopen the FAST range, so I left it.

## Changes
- Marrow Tithe step 2 (x11): gate is now Debt >= 6 AND (health <= 30 % OR three canon arts in 2 s); pays 6 Debt (was 4, one OR-group).
- Last Breath Fist step 2 (x6): gate is now Debt >= 5 AND (health <= 25 % OR three canon arts in 2 s); pays 5 Debt (was 6).
- Answering Palm: c_art 1.9 -> 1.5; step 1 c_mult 3.5 -> 2.8; step 2 c_mult 6.0 -> 5.0, gate now two scripture arts in 2 s AND (four arts in a pulse OR Barrage just fired OR Slowed 3 deep).
- Rolling Barrage Fist: c_art 1.1 -> 0.9; step 1 c_mult 4.0 -> 3.0; step 2 gate now Tempo >= 6 AND (three scripture arts in 2 s OR three fist arts in 3 s OR Slowed 3 deep), pays 6 Tempo (was 8), c_mult 4.0 -> 3.0 per rain hit.
- Bone-Turning Palm: c_art 2.6 -> 2.3 (was FAST at Trúc Cơ x0.76).
- Mountain Root Stance: was x1.55 slow. dampen_taken 20 -> 14, block 15 -> 8, art_speed -20 -> -8, hregen 0.3 -> 0.2; c_art 0.0 -> 1.0; strike-back free hit 0.45 -> 1.0.
- Routes: Slowed Time is kept as an outside key (Ice carries it), so no route removed. Bulwark Knuckle step 2 was already an AND, unchanged. No `consume`/`then`/`per` scaling added: Debt, Ram and Tempo pay flat amounts.
- family-body.md table updated for the rules above.
