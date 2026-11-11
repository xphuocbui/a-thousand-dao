# Blade family, second tuning pass

## suite_check before (afterimage-sword-canon only)

suite_check	blade	suite afterimage-sword-canon	truc_co	mean 15.1 s, typical mirror 25.6 s, x0.59 (FAST)	W-L 20-0
suite_check	blade	suite afterimage-sword-canon	ket_dan	mean 13.7 s, typical mirror 20.0 s, x0.69 (near typical)	W-L 20-0

## suite_check after

suite_check	blade	suite afterimage-sword-canon	truc_co	mean 15.9 s, typical mirror 25.6 s, x0.62 (near typical)	W-L 20-0
suite_check	blade	suite afterimage-sword-canon	ket_dan	mean 14.2 s, typical mirror 20.0 s, x0.71 (near typical)	W-L 20-0
suite_check	blade	suite hunters-reach-canon	truc_co	mean 16.7 s, typical mirror 25.6 s, x0.65 (near typical)	W-L 20-0
suite_check	blade	suite hunters-reach-canon	ket_dan	mean 12.8 s, typical mirror 20.0 s, x0.64 (near typical)	W-L 20-0
suite_check	blade	art debt-blade	truc_co	mean 21.6 s, typical mirror 25.6 s, x0.85 (near typical)	W-L 9-7
suite_check	blade	art debt-blade	ket_dan	mean 19.1 s, typical mirror 20.0 s, x0.96 (near typical)	W-L 10-8

Lint: 0 findings. No NEVER_ENGAGED line; every Afterimage engine art still fires at least one step or empower at both realms.

## Changes

- phantom-sword step 1: c_mult 1.5 -> 1.3.
- phantom-sword step 2 (top): c_mult 3.2 -> 2.8.
- flying-sword empower: c_mult 3.5 -> 2.8.
- triple-draw empower: c_mult 2.5 -> 1.9.
- triple-draw draw-snowball: free-hit c 0.2 -> 0.15 per draw in window.
- Rule texts in family-blade.json and the table in family-blade.md updated to the new numbers. Gates and feeding routes unchanged.

Note: Trúc Cơ x0.62 is near the bottom of the band. Each flat cut moved it only about 0.01, so the suite's speed comes mostly from the base arts and the engines' frequent firing, not the top payoffs. A further change would have to hit base c_art or cooldowns.
