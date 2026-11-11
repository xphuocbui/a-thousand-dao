# Tune: Water family

## Before
```
suite_check	water	suite still-moon-tide-scripture	truc_co	mean 9.2 s, typical mirror 25.6 s, x0.36 (FAST)	W-L 20-0
suite_check	water	suite still-moon-tide-scripture	ket_dan	mean 8.0 s, typical mirror 20.0 s, x0.40 (FAST)	W-L 20-0
suite_check	water	suite undertow-litany	truc_co	mean 26.1 s, typical mirror 25.6 s, x1.02 (near typical)	W-L 20-0
suite_check	water	suite undertow-litany	ket_dan	mean 22.1 s, typical mirror 20.0 s, x1.10 (near typical)	W-L 20-0
suite_check	water	art backwash-seal	truc_co	mean 25.9 s, typical mirror 25.6 s, x1.01 (near typical)	W-L 11-8
suite_check	water	art backwash-seal	ket_dan	mean 21.3 s, typical mirror 20.0 s, x1.06 (near typical)	W-L 10-6
```

## After
```
suite_check	water	suite still-moon-tide-scripture	truc_co	mean 17.6 s, typical mirror 25.6 s, x0.69 (near typical)	W-L 20-0
suite_check	water	suite still-moon-tide-scripture	ket_dan	mean 14.4 s, typical mirror 20.0 s, x0.72 (near typical)	W-L 20-0
```
The other four rows were not re-run after the last edits; the Undertow Litany and Backwash Seal runs
(x1.02/x1.10, x1.01/x1.06) came from the middle run, which already contained the Drag step-3 change. Engine firings
in the Moon Tide suite: Cup step 1 0.8/0.5, Deep Lake 2.8/2.0, Wave 2.0/2.0, Palm 2.0/1.5 per fight (Trúc Cơ/Kết Đan).

## Changes
- Swelling Tide Palm: removed the foe-Water-debuff route (it can never open: Water has no debuff).
- Swelling Tide Palm: top empower now needs 5 Tide AND 3 own Water stacks, eats the stacks for a free hit each (0.3 c per stack, no cap), c_mult 3.0 -> 1.8.
- Swelling Tide Palm: second route is 3 Tide AND health <= 60 % (3 waves, c_mult 1.5), so two feeding routes remain.
- Gathering Wave: crest c_art 9.0 -> 3.5; each route is now two conditions (2 Tide + Deep Lake, 2 Tide + 2 Slowed Time, or 3 Tide spent + health <= 70 %).
- Gathering Wave: banked wave 1.1 -> 0.8, surge hit 3.0 -> 1.5, surge bank cap 3 -> 2.
- Deep Lake Stance: release c_art 7.0 -> 3.5; Water-stack trigger in its any-group needs Tide >= 5 (was 4).
- Brimming Cup: step 2 gate is 1 Tide AND (linh lực >= 70 % or Deep Lake), c_art 4.0 -> 2.2 (first try with 2 Tide never engaged).
- Brimming Cup: step 3 gate is 3 Tide AND (shield standing or half health), c_art 11.0 -> 5.0.
- Drag of the Deep: step 3 lost its never-opening "foe 6 Water stacks" route; needs 5 Slowed Time AND 2 litany arts this pulse, c_art 9.0 -> 6.0.
- Drag of the Deep: step 3 now eats your own Water stacks (consume per stack, linh lực back) instead of the foe's.
- Rules text in the JSON and the md table updated to match; lint stays at 0 findings.
