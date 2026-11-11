# Tune: Metal family

## Before (suite_check rows)
```
suite_check	metal	suite nine-temper-scripture	truc_co	mean 8.2 s, typical mirror 25.6 s, x0.32 (FAST)	W-L 20-0
suite_check	metal	suite nine-temper-scripture	ket_dan	mean 8.0 s, typical mirror 20.0 s, x0.40 (FAST)	W-L 20-0
suite_check	metal	suite hundred-blades-canon	truc_co	mean 7.8 s, typical mirror 25.6 s, x0.30 (FAST)	W-L 20-0
suite_check	metal	suite hundred-blades-canon	ket_dan	mean 6.7 s, typical mirror 20.0 s, x0.34 (FAST)	W-L 20-0
suite_check	metal	art iron-hide-stance	truc_co	mean 32.9 s, typical mirror 25.6 s, x1.29 (near typical)	W-L 4-15
suite_check	metal	art iron-hide-stance	ket_dan	mean 22.2 s, typical mirror 20.0 s, x1.11 (near typical)	W-L 3-15
```
(sundering-wedge NEVER_ENGAGED in both realms.)

## After (suite_check rows)
```
suite_check	metal	suite nine-temper-scripture	truc_co	mean 16.1 s, typical mirror 25.6 s, x0.63 (near typical)	W-L 20-0
suite_check	metal	suite nine-temper-scripture	ket_dan	mean 12.2 s, typical mirror 20.0 s, x0.61 (near typical)	W-L 20-0
suite_check	metal	suite hundred-blades-canon	truc_co	mean 14.4 s, typical mirror 25.6 s, x0.56 (FAST)	W-L 20-0
suite_check	metal	suite hundred-blades-canon	ket_dan	mean 13.8 s, typical mirror 20.0 s, x0.69 (near typical)	W-L 20-0
suite_check	metal	art iron-hide-stance	truc_co	mean 31.4 s, typical mirror 25.6 s, x1.22 (near typical)	W-L 5-14
suite_check	metal	art iron-hide-stance	ket_dan	mean 22.2 s, typical mirror 20.0 s, x1.11 (near typical)	W-L 2-16
```
Every engine art now engages (Wedge step 1, Retinue empower, Cleave, Whetstone, Sheathed steps 1-2); top steps fire about
once per fight. Lint: 0 findings. Open: canon at Trúc Cơ is x0.56, just under the 0.6 floor (further slowing risked
Wedge un-engaging); the scripture sits at the floor (0.61-0.63).

## Changes
- Whetstone Pass: c_art 1.5 -> 0.8; Honed Pass x3.5 -> x2.5, gate now 6 Temper AND (4 foe stacks OR 2 scripture arts in a pulse).
- Shatter-Edge Cleave: c_art 3.0 -> 1.6; all three empowers x6 -> x4; stack route consumes up to 12 (was 6) so the free hits scale with stacks fed; Temper route also needs 3 buff stacks; buff route also needs 2 Temper.
- Sheathed Edge: c_art 2.0 -> 1.1; banked free hit 0.8 -> 0.5; step 3 x5 -> x3.5 and now needs 3 Temper AND (3 scripture arts OR 40 % health).
- Blood-Quench Blade: c_art 1.6 -> 1.1.
- Needle Rain: c_art 2.6 -> 0.5.
- Flying Blade Retinue: c_art 2.0 -> 0.6, cooldown 6 -> 8; summon c 0.45 -> 0.3; empowers x6 -> x3; stack route opens at 4 (was 6) and breaks up to 12 (was 9); second route needs 2 Sundered AND (canon art within 4 s OR 8 buff stacks).
- Sundering Wedge: c_art 1.6 -> 0.6, cooldown 4 -> 5; Sundered lasts 9 s (was 4) so step 1 can engage; removed the Temper routes (the canon never builds Temper, they could not open); step 1 x3 -> x2.5; step 3 x6 -> x4, needs 2 Sundered AND (6 foe stacks OR canon art in the pulse), consume widened to up to 12 with a 0.6 free hit per 3 (scales with stacks fed).
- Needle Rain: cooldown 5 -> 7.
- Iron Hide Stance: art-speed penalty -20 % -> -10 % (Trúc Cơ x1.29 -> x1.22; still loses most fights, W-L 5-14).
- family-metal.md table rows updated for Whetstone, Cleave, Sheathed Edge, Retinue, Wedge.
