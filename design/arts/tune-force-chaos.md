# Tune: family-force-chaos

## suite_check before

```
suite_check	force-chaos	suite hollow-tide-scripture	truc_co	mean 15.6 s, typical mirror 25.6 s, x0.61 (near typical)	W-L 20-0
suite_check	force-chaos	suite hollow-tide-scripture	ket_dan	mean 12.2 s, typical mirror 20.0 s, x0.61 (near typical)	W-L 20-0
suite_check	force-chaos	suite ruin-ledger-scripture	truc_co	mean 4.8 s, typical mirror 25.6 s, x0.19 (FAST)	W-L 20-0
suite_check	force-chaos	suite ruin-ledger-scripture	ket_dan	mean 4.3 s, typical mirror 20.0 s, x0.22 (FAST)	W-L 20-0
suite_check	force-chaos	art bloodletting-rite	truc_co	mean 9.6 s, typical mirror 25.6 s, x0.37 (FAST)	W-L 20-0
suite_check	force-chaos	art bloodletting-rite	ket_dan	mean 8.3 s, typical mirror 20.0 s, x0.42 (FAST)	W-L 20-0
suite_check	force-chaos	art shearing-palm	truc_co	mean 26.9 s, typical mirror 25.6 s, x1.05 (near typical)	W-L 2-18
suite_check	force-chaos	art shearing-palm	ket_dan	mean 21.6 s, typical mirror 20.0 s, x1.08 (near typical)	W-L 4-16
```
NEVER_ENGAGED before: hollowing-strike (Trúc Cơ), fraying-thread and gathered-ruin-verdict (both realms, ruin suite).

## suite_check after

```
suite_check	force-chaos	suite hollow-tide-scripture	truc_co	mean 14.8 s, typical mirror 25.6 s, x0.58 (FAST)	W-L 20-0
suite_check	force-chaos	suite hollow-tide-scripture	ket_dan	mean 12.2 s, typical mirror 20.0 s, x0.61 (near typical)	W-L 20-0
suite_check	force-chaos	suite ruin-ledger-scripture	truc_co	mean 12.0 s, typical mirror 25.6 s, x0.47 (FAST)	W-L 20-0
suite_check	force-chaos	suite ruin-ledger-scripture	ket_dan	mean 12.2 s, typical mirror 20.0 s, x0.61 (near typical)	W-L 20-0
suite_check	force-chaos	art bloodletting-rite	truc_co	mean 13.9 s, typical mirror 25.6 s, x0.54 (FAST)	W-L 20-0
suite_check	force-chaos	art bloodletting-rite	ket_dan	mean 10.1 s, typical mirror 20.0 s, x0.50 (FAST)	W-L 20-0
suite_check	force-chaos	art shearing-palm	truc_co	mean 26.9 s, typical mirror 25.6 s, x1.05 (near typical)	W-L 2-18
suite_check	force-chaos	art shearing-palm	ket_dan	mean 21.6 s, typical mirror 20.0 s, x1.08 (near typical)	W-L 4-16
```
No NEVER_ENGAGED lines remain. Top-step rates: Siphon step 2 0.1/fight, Hollowing empower 0.8-0.9, Ruin suite arts 1-2 each. Lint: 0 findings.

## Not met

Hollow Tide at Trúc Cơ (x0.58), Ruin Ledger at Trúc Cơ (x0.47) and Bloodletting Rite at both realms (x0.54/x0.50) are still below their target band. Cutting `c_art` barely moves these fights; the status durations and the Qi Disruption burn did most of the work. Hollowing's top step and the Ruin top steps could not be told apart from their lower routes in the engine counts (suite_check lists one "empower" row per art), so "top fires rarely" is unverified.

## Changes

- Marrow-Siphon Palm: c_art 2.3 -> 1.6, cooldown 3 -> 4, Disruption 2 -> 1 stack, step 1 c_mult 2.0 -> 1.5, step 3 c_mult 5.0 -> 4.0.
- Hollowing Strike: c_art 3.0 -> 2.2, cost 0.07 -> 0.05, cooldown 7 -> 5, Disruption 2 -> 1 stack. It never engaged, so the empowers were rebuilt.
- Hollowing Strike top empower: now two conditions (foe linh lực <= 40 % AND 3 Drink spent), 3.5x with +10 % linh lực. The old three routes (dry foe alone, 6 Drink alone, Husk stance) are gone.
- Hollowing Strike lower empower: free 2.2x on any Qi Disruption on the foe (was Husk stance + 2 Disruption 4x). Shown to engage ~0.9 per fight.
- Fraying Thread: c_art 1.4 -> 0.5, Sundered dur 4 -> 2, 6-Fray empower 4.0x -> 3.0x, distinct-status route 4 statuses at 3.5x -> 3 statuses at 1.8x (so it now engages; third route's gate moved to under 3 statuses to stay exclusive).
- Gathered Ruin Verdict: c_art 2.2 -> 0.8, Exposed dur 3 -> 2, banked damage more 12 -> 3 per batch.
- Ripening Curse: c_art 2.0 -> 0.7, Stagnation dur 3 -> 2, bloom 6 -> 3 damage more per distinct status, step 2 1.8x -> 1.4x, step 3 4.0x -> 3.0x.
- Bloodletting Rite: c_art 2.5 -> 0.7, cooldown 5 -> 9, damage more 6 -> 4 per 10 % health missing, leech 20 -> 12 %. Added `convert` chaos->force 0.5; it changed nothing measurable (a try, could be removed).
- Routes that could never open: none found in this family (no Water debuff reads).
- Rule texts in the JSON and the two table rows in family-force-chaos.md updated to match.
