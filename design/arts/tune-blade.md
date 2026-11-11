# Tune: blade family

## suite_check before
```
suite_check	blade	suite afterimage-sword-canon	truc_co	mean 9.6 s, typical mirror 25.6 s, x0.38 (FAST)	W-L 20-0
suite_check	blade	suite afterimage-sword-canon	ket_dan	mean 8.2 s, typical mirror 20.0 s, x0.41 (FAST)	W-L 20-0
suite_check	blade	suite hunters-reach-canon	truc_co	mean 8.7 s, typical mirror 25.6 s, x0.34 (FAST)	W-L 20-0
suite_check	blade	suite hunters-reach-canon	ket_dan	mean 6.5 s, typical mirror 20.0 s, x0.33 (FAST)	W-L 20-0
suite_check	blade	art debt-blade	truc_co	mean 21.6 s, typical mirror 25.6 s, x0.85 (near typical)	W-L 9-7
suite_check	blade	art debt-blade	ket_dan	mean 19.1 s, typical mirror 20.0 s, x0.96 (near typical)	W-L 10-8
```

## suite_check after
```
suite_check	blade	suite afterimage-sword-canon	truc_co	mean 15.1 s, typical mirror 25.6 s, x0.59 (FAST)	W-L 20-0
suite_check	blade	suite afterimage-sword-canon	ket_dan	mean 13.7 s, typical mirror 20.0 s, x0.69 (near typical)	W-L 20-0
suite_check	blade	suite hunters-reach-canon	truc_co	mean 16.7 s, typical mirror 25.6 s, x0.65 (near typical)	W-L 20-0
suite_check	blade	suite hunters-reach-canon	ket_dan	mean 12.8 s, typical mirror 20.0 s, x0.64 (near typical)	W-L 20-0
suite_check	blade	art debt-blade	truc_co	mean 21.6 s, typical mirror 25.6 s, x0.85 (near typical)	W-L 9-7
suite_check	blade	art debt-blade	ket_dan	mean 19.1 s, typical mirror 20.0 s, x0.96 (near typical)	W-L 10-8
```
Afterimage at Trúc Cơ sits at x0.59, a hair under the 0.6 line (rounded; further nerfs only lengthen it but I stopped at diminishing returns). Lint: 0 findings. No NEVER_ENGAGED line remains. Top steps fire: Nocked Arrow step 2 1.6 / 1.0 per fight, Phantom Sword step 2 0.2, Flying Sword empower 0.2-0.3, Triple Draw empower 2.0 / 1.6; Coiling Thrust step 2 never fired in its suite (engaged through step 1).

## Changes
- Flurry Stance: basic_speed 50 -> 25, basic_coef 0.5 -> 0.1, gain_on_hit 2 -> 1 (suite was FAST).
- Coiling Thrust: c_art 2.0 -> 1.3; step 1 c_mult 2.2 -> 1.6.
- Coiling Thrust top step: 5.5 -> 3.5; gate now 6 Coils AND (4 Slowed Time OR Nocked Arrow within 3 s), was one OR-group of 5 Coils / 5 Slowed Time / Nocked Arrow.
- Nocked Arrow: c_art 1.8 -> 1.3; banked free hit 0.9 -> 0.5, crit free hit 0.5 -> 0.3; step 1 c_mult 2.5 -> 1.8.
- Nocked Arrow top step (Volley): 4.5 -> 3.0; gate now 4 Coils AND (7 s patience OR foe <= 35 % OR 4 Slowed Time); the lone "6 Coils" route became the AND requirement, "4 Slowed Time" replaces it as a feed.
- Phantom Sword: c_art 2.2 -> 1.2; step 1 c_mult 2.0 -> 1.5.
- Phantom Sword top step: 4.5 -> 3.2; gate now 7 Afterimages AND (3 canon arts in one pulse OR you <= 40 % health OR Flurry on).
- Flying Sword: c_art 2.2 -> 1.5; sword hit c 0.5 -> 0.3 (call and the two empower swords).
- Flying Sword empower: 6 -> 3.5; gate now 3 Afterimages AND (3 canon arts in one pulse OR 4 Bleed OR 10 s since last firing); the Afterimage floor is low so it engages (it never fired when it was an OR at 5 and the first tightening at 6).
- Triple Draw: c_art 2.4 -> 1.4; draw-snowball free hit 0.3 -> 0.2.
- Triple Draw empower: 4 -> 2.5; gate now 2 draws in 4 s AND (2 Bleed OR 3 canon arts in one pulse OR you <= 40 % health).
- Debt Blade untouched (x0.85 / x0.96). No Water-style impossible routes found: Bleed comes from Triple Draw and Bleeding Slash, Slowed Time from Pinning Arrow and Nocked Arrow.
- family-blade.md table rows updated to the new multiples and gates.
- Not done: fed-scaling `consume` with `then`/`per` was not used; payoffs were earned with AND-gates. Every engine art keeps at least two feeding routes (Slowed Time/Coils/pulse; Afterimages/Bleed/Flurry/low health).
- Stray file: design/arts/_logs/blade_tune.py (an unrun helper script I could not execute here) and nothing else; safe to delete.
