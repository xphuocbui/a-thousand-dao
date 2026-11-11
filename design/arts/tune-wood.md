# Wood tuning

## suite_check before
```
suite_check	wood	suite verdant-cycle-scripture	truc_co	mean 10.0 s, typical mirror 25.6 s, x0.39 (FAST)	W-L 20-0
suite_check	wood	suite verdant-cycle-scripture	ket_dan	mean 10.0 s, typical mirror 20.0 s, x0.50 (FAST)	W-L 20-0
suite_check	wood	suite rotting-canopy-canon	truc_co	mean 16.9 s, typical mirror 25.6 s, x0.66 (near typical)	W-L 20-0
suite_check	wood	suite rotting-canopy-canon	ket_dan	mean 15.9 s, typical mirror 20.0 s, x0.80 (near typical)	W-L 20-0
```

## suite_check after
```
suite_check	wood	suite verdant-cycle-scripture	truc_co	mean 16.2 s, typical mirror 25.6 s, x0.63 (near typical)	W-L 20-0
suite_check	wood	suite verdant-cycle-scripture	ket_dan	mean 14.2 s, typical mirror 20.0 s, x0.71 (near typical)	W-L 20-0
suite_check	wood	suite rotting-canopy-canon	truc_co	mean 16.9 s, typical mirror 25.6 s, x0.66 (near typical)	W-L 20-0
suite_check	wood	suite rotting-canopy-canon	ket_dan	mean 16.1 s, typical mirror 20.0 s, x0.80 (near typical)	W-L 20-0
```
No NEVER_ENGAGED lines. Seed of Spring's empower fires 3.8 / 2.5 per fight, Harvest Bloom 2.0, Second Spring step 1 0.6 (step 2 never fires), Thornling step 2 1.0, Canker 1.0-1.4.

## Changes
- Seed of Spring: top empower now needs 4 Seeds AND 8 own Wood stacks (was 4 Seeds alone), c_mult 5 -> 3.5.
- Seed of Spring: Poison route consumes 8 with `per` 4 and a 0.4 Chaos free hit per 4 eaten, c_mult 5 -> 2.5; exclusive of the first route.
- Seed of Spring: removed the lone Rooted Form / half-health OR-route (4.5x for a single OR-group); c_art 1.4 -> 1.1.
- Harvest Bloom: c_mult 4 -> 3 (Poison), 4 -> 2.5 (Seeds), 4 -> 2.5 (own stacks); c_art 2.0 -> 1.6; bloom-ripple free hit 1.0 -> 0.7.
- Second Spring: step 1 c_heal 4.5 -> 3.5, c_art 5 -> 2.5; step 2 c_heal 9 -> 6, c_art 12 -> 6.
- Thornling Grove step 2: gate now 15 foe Poison AND (3 Stagnation OR 3 canopy arts); the lone 25-Poison route is gone.
- Blight Canker: top empower now needs 6 Stagnation AND 6 Poison, c_mult 4 -> 3.5.
- No dead routes found in Wood (Poison and Stagnation both come from Wood arts).
- Lint: 0 findings after the changes.
