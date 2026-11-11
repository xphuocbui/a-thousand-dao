# Tune: Earth family

## Before (suite_check rows)

```
suite_check	earth	suite mountain-heart-canon	truc_co	mean 15.7 s, typical mirror 25.6 s, x0.61 (near typical)	W-L 20-0
suite_check	earth	suite mountain-heart-canon	ket_dan	mean 15.9 s, typical mirror 20.0 s, x0.79 (near typical)	W-L 18-2
suite_check	earth	suite deep-vein-scripture	truc_co	mean 8.9 s, typical mirror 25.6 s, x0.35 (FAST)	W-L 20-0
suite_check	earth	suite deep-vein-scripture	ket_dan	mean 8.0 s, typical mirror 20.0 s, x0.40 (FAST)	W-L 20-0
```
Also NEVER_ENGAGED for quarry-offering and stone-warden-call at both realms.

## After (suite_check rows)

```
suite_check	earth	suite mountain-heart-canon	truc_co	mean 16.1 s, typical mirror 25.6 s, x0.63 (near typical)	W-L 20-0
suite_check	earth	suite mountain-heart-canon	ket_dan	mean 16.2 s, typical mirror 20.0 s, x0.81 (near typical)	W-L 17-3
suite_check	earth	suite deep-vein-scripture	truc_co	mean 15.4 s, typical mirror 25.6 s, x0.60 (near typical)	W-L 20-0
suite_check	earth	suite deep-vein-scripture	ket_dan	mean 18.1 s, typical mirror 20.0 s, x0.90 (near typical)	W-L 18-2
```
No NEVER_ENGAGED lines. Lint: 0 findings. Engine firings per fight: Strata Hammer step 2 (top) 1.0 / 0.8; Sinking Weight step 2 0.8; Bastion empower 0.1; Quarry Offering step 1 1.0 / 0.6 (step 2 not seen in a typical build); Stone Warden step 1 1.0 (step 2 not seen).

## Changes

- Strata Hammer: step 1 `c_mult` 2.5 -> 2.2.
- Strata Hammer: Collapse (step 2) now needs 8 Strata AND one of (foe Slowed 3 deep, 3 canon arts in 2 s, Mountain Stance); was a three-way OR-group where Strata alone opened it. Mountain Stance added as a third route.
- Quarry Offering: step 1 gate simplified to 8 own Earth stacks (the old 10-stack / under-half-health OR never opened in a 12-18 s fight), pays 8, `c_mult` 1.8.
- Quarry Offering: step 2 now needs 14 Earth stacks AND (3 deep-vein arts in 8 s or under 40 % health), pays 14, `c_mult` 5.0 -> 4.5; the free "20 stacks" route removed.
- Stone Warden Call: step 1 gate simplified to 6 own Earth stacks (pays 6, `c_mult` 1.5); step 2 now needs 12 stacks AND (3 deep-vein arts in 10 s, under half health, or a Slowed foe), `c_mult` 5.0 -> 4.0. The Mountain Stance route replaced by the Slowed-foe and group routes (Mountain Stance is in the other suite).
- Warden summons: base 0.7/3 s -> 0.3/4 s; step 1 1.2/3 s -> 0.4/4 s; step 2 two wardens 1.5/2.5 s -> 0.7/3 s each (no effect on length alone, kept as a flat-value cut).
- Aftershock Slam echo share 0.5 -> 0.35.
- Deep Vein suite was FAST: `c_art` Quarry 2.4 -> 0.8, Warden 3.0 -> 0.7, Aftershock 2.9 -> 0.6, Millstone 2.0 -> 0.6; `cost_share` Quarry 0.04 -> 0.08, Warden 0.06 -> 0.08, Aftershock 0.05 -> 0.07 (also Millstone 0.04 -> 0.07 was set, see JSON); cooldowns Quarry 6 -> 5, Warden 10 -> 9, Aftershock 5 -> 6, Millstone 3 -> 6. Linh lực drain (cost) was the strongest lever on fight length.
- Feeding routes kept at two or more per engine art (Strata/Sinking Weight/Bastion unchanged apart from Collapse). No dead Water-debuff routes existed in this family.
- Not done: no `consume ... then/per` scaling payoff added; top steps are earned by AND-gates and higher stack costs instead.
