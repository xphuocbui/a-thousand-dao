# Tune: Soul, Song, Seal

## suite_check before
```
suite_check	soul-song-seal	suite hollow-bell-canon	truc_co	mean 33.9 s, typical mirror 25.6 s, x1.32 (near typical)	W-L 5-13
suite_check	soul-song-seal	suite hollow-bell-canon	ket_dan	mean 23.4 s, typical mirror 20.0 s, x1.17 (near typical)	W-L 0-20
NEVER_ENGAGED	soul-song-seal	suite hollow-bell-canon	ket_dan	tolling-bell-requiem: no step or empower fired
suite_check	soul-song-seal	suite nine-seal-ledger	truc_co	mean 9.0 s, typical mirror 25.6 s, x0.35 (FAST)	W-L 20-0
suite_check	soul-song-seal	suite nine-seal-ledger	ket_dan	mean 8.7 s, typical mirror 20.0 s, x0.44 (FAST)	W-L 20-0
NEVER_ENGAGED	soul-song-seal	suite nine-seal-ledger	ket_dan	branding-seal: no step or empower fired
suite_check	soul-song-seal	art marching-dirge	truc_co	mean 20.9 s, typical mirror 25.6 s, x0.82 (near typical)	W-L 0-20
suite_check	soul-song-seal	art marching-dirge	ket_dan	mean 17.4 s, typical mirror 20.0 s, x0.87 (near typical)	W-L 0-20
suite_check	soul-song-seal	art thorn-lullaby	truc_co	mean 37.9 s, typical mirror 25.6 s, x1.48 (near typical)	W-L 5-14
suite_check	soul-song-seal	art thorn-lullaby	ket_dan	mean 24.1 s, typical mirror 20.0 s, x1.21 (near typical)	W-L 3-17
suite_check	soul-song-seal	art blood-ink-writ	truc_co	mean 19.0 s, typical mirror 25.6 s, x0.74 (near typical)	W-L 0-20
suite_check	soul-song-seal	art blood-ink-writ	ket_dan	mean 16.6 s, typical mirror 20.0 s, x0.83 (near typical)	W-L 0-20
```
(Before, Frozen Hour engaged 2.0 / 1.9 per fight and Ambush 1.6+1.0 / 1.0+1.0; the Bell's step 1 and 2 fired 0.8 / 0.6 per fight at Trúc Cơ only.)

## suite_check after
```
suite_check	soul-song-seal	suite hollow-bell-canon	truc_co	mean 33.5 s, typical mirror 25.6 s, x1.31 (near typical)	W-L 3-16
suite_check	soul-song-seal	suite hollow-bell-canon	ket_dan	mean 23.4 s, typical mirror 20.0 s, x1.17 (near typical)	W-L 0-20
suite_check	soul-song-seal	suite nine-seal-ledger	truc_co	mean 18.7 s, typical mirror 25.6 s, x0.73 (near typical)	W-L 18-2
suite_check	soul-song-seal	suite nine-seal-ledger	ket_dan	mean 16.2 s, typical mirror 20.0 s, x0.81 (near typical)	W-L 15-5
suite_check	soul-song-seal	art marching-dirge	truc_co	mean 20.9 s, typical mirror 25.6 s, x0.82 (near typical)	W-L 0-20
suite_check	soul-song-seal	art marching-dirge	ket_dan	mean 17.4 s, typical mirror 20.0 s, x0.87 (near typical)	W-L 0-20
suite_check	soul-song-seal	art thorn-lullaby	truc_co	mean 35.4 s, typical mirror 25.6 s, x1.38 (near typical)	W-L 10-10
suite_check	soul-song-seal	art thorn-lullaby	ket_dan	mean 24.6 s, typical mirror 20.0 s, x1.23 (near typical)	W-L 7-12
suite_check	soul-song-seal	art blood-ink-writ	truc_co	mean 18.6 s, typical mirror 25.6 s, x0.73 (near typical)	W-L 0-20
suite_check	soul-song-seal	art blood-ink-writ	ket_dan	mean 16.4 s, typical mirror 20.0 s, x0.82 (near typical)	W-L 0-20
```
Engine rows after: Bell step 1 fires 1.4 / 0.9 per fight (step 2 never in a typical build), Lance empower 5.1 / 2.9; Ambush step 1 3.2 / 2.8, step 2 1.8 / 1.2; Frozen Hour 2.1 / 1.6; Branding 2.9 / 2.0. No NEVER_ENGAGED line. Lint: 0 findings.

## Open (not met)
- Hollow Bell Canon stays slow (x1.31 / x1.17, target 0.6-1.0). Soul arts are held by the lint's `soul_pct` limit (0.036 / 0.043 at cooldown 4 / 5); raising `soul_pct` or shortening cooldown hit SOUL_OVER, and larger `free_hit` values in `pay` / the echo barely moved the fight (trigger budget clipping). A run with soul_pct 0.12 reached x0.82 / x1.01, so the gap is the lint cap, not the gates. Needs the engine's soul budget or a `soul_pct` override in steps.
- Thorn Lullaby is slow (x1.38 / x1.23, target 0.8-1.2): the heal sustains the fight; changes to c_heal, c_art and thorn power moved it only a little.

## Changes
- Tolling Bell: step 1 gate now Toll >= 3, or 1 Slackened Soul, or the canon fired the same pulse (was 5 / 2 / canon), so it engages in its own suite at both realms.
- Tolling Bell: step 2 (Death Knell) gate is now two conditions: Toll >= 5 AND (2 Slackened Soul OR you at 40 % health or less) (was an OR of 8 Tolls / low health); it still spends 6 Tolls for the 7.0 hit and scales with the per-Toll echo.
- Tolling Bell: echo free hit per Toll 0.3 -> 1.5; Great Peal free hit 3.0 -> 4.5 (to speed the suite; little effect).
- Lamp-Oil Lance: Fully Lit free hit 3.5 -> 7.0 (little effect on the suite); routes unchanged (4 routes).
- Ambush Talisman: c_art 1.2 -> 0.5, bank free hit 0.8 -> 0.5, Snare c_mult 3 -> 2.2 (suite was x0.35 FAST).
- Ambush Talisman: Death Trap gate is now 4 Seals AND (foe at 50 % health or less OR you at 40 % or less) (was an OR of 5 Seals / either at 40 %); c_mult 7 -> 5.
- Frozen Hour Seal: c_art 1.6 -> 1.2; Hour Stopped gate is now 2 Seals AND (1 Slowed Time OR Ambush set in the last 3 s OR 4 Seals) (it never engaged: a 2-stack Slowed Time laid 5 s ago has expired); c_mult 5 -> 2.5, other arts' timer cut 2 -> 1 s.
- Branding Seal: c_art 2.9 -> 1.0; Sunk to the Soul gate is now 2 Seals AND (2 Slackened Soul OR foe at 50 % health or less OR another ledger seal this pulse) (never engaged at Kết Đan), spends 2 Seals (was 4), c_mult 4 -> 3.
- Thorn Lullaby: now also strikes (c_art 0 -> 1.8), heal c_heal 2.4 -> 0.6, thorn free hit 0.35 -> 1.0 (still slow).
- Blood-Ink Writ: c_art 0.9 -> 0.7, +4 % -> +3 % per distinct foe status (was x0.74 / x0.83, in range).
- Marching Dirge: unchanged (x0.82 / x0.87, in range).
- No Water-debuff style dead routes existed in this family; all kept routes (Slackened Soul from the Lance, Exposed from Ambush, Slowed Time from Frozen Hour) can open.
