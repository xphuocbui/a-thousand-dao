# Ice tuning

## Before (suite_check rows)

```
suite_check	ice	suite winter-toll-canon	truc_co	mean 8.9 s, typical mirror 25.6 s, x0.35 (FAST)	W-L 20-0
suite_check	ice	suite winter-toll-canon	ket_dan	mean 8.0 s, typical mirror 20.0 s, x0.40 (FAST)	W-L 20-0
suite_check	ice	suite stilled-hour-sutra	truc_co	mean 16.0 s, typical mirror 25.6 s, x0.63 (near typical)	W-L 20-0
suite_check	ice	suite stilled-hour-sutra	ket_dan	mean 13.1 s, typical mirror 20.0 s, x0.66 (near typical)	W-L 20-0
NEVER_ENGAGED	ice	suite stilled-hour-sutra	ket_dan	shattering-mantle: no step or empower fired
```

## After (suite_check rows)

```
suite_check	ice	suite winter-toll-canon	truc_co	mean 15.7 s, typical mirror 25.6 s, x0.61 (near typical)	W-L 20-0
suite_check	ice	suite winter-toll-canon	ket_dan	mean 14.7 s, typical mirror 20.0 s, x0.73 (near typical)	W-L 20-0
suite_check	ice	suite stilled-hour-sutra	truc_co	mean 17.1 s, typical mirror 25.6 s, x0.67 (near typical)	W-L 20-0
suite_check	ice	suite stilled-hour-sutra	ket_dan	mean 13.5 s, typical mirror 20.0 s, x0.67 (near typical)	W-L 20-0
```

Lint: 0 findings. All engine arts engage. Top steps are rare (Mantle step 2 0.6 per fight at Trúc Cơ, Seal step 2 and Instant step 2 not seen in a typical build). Shatter Palm's empower counts both its tiers: 2.7-3.6 per fight, above the once-or-twice target; its top tier now needs Frost too, so some of that is the smaller 5-stack tier. Not tuned further.

## Changes

- Rime-Lock Seal: step 1 `c_art` 5.0 → 2.5; step 2 `c_art` 6.5 → 3.5.
- Rime-Lock Seal: step 2 gate was one OR-group (Ice ≥ 20 or Palm ≤ 3 s); now Ice ≥ 15 AND (2 Heavy Breath or Palm ≤ 3 s).
- Shatter Palm: top empower now needs Ice ≥ 10 AND Frost ≥ 2 (two conditions); its consume still pays a free hit per stack, uncapped; `c_art` 8.0 → 3.5.
- Shatter Palm: second empower `c_art` 7.0 → 3.0.
- Deep Winter Form: thaw-break empower `c_art` 9.0 → 4.5.
- Black Ice Glaze: `c_art` 1.6 → 1.3; Exposed duration 3 → 2 s; free hit `c` 1.0 → 0.6.
- Stilled Instant: step 1 `c_art` 9.0 → 6.0; step 2 `c_art` 13.0 → 9.0.
- Stilled Instant: step 2 gate was Slowed Time ≥ 4 or Ice ≥ 20; now Ice ≥ 15 AND (Slowed Time ≥ 3 or 2 sutra arts this pulse).
- Shattering Mantle: step 1 gains a route (foe Ice ≥ 6), so it engages at Kết Đan; `c_art` 12.0 → 6.0.
- Shattering Mantle: step 2 gate was one OR-group; now Ice ≥ 12 AND (shield standing or 2 sutra arts this pulse); `c_art` 15.0 → 9.0.
- Shattering Mantle: burst free hit `c` 2.5 → 1.5; brittle free hit `c` 2.0 → 1.2.
- Sleet Volley `c_art` 2.4 → 1.8; Frozen Marrow Pact `c_art` 1.9 → 1.5 (the suite had gone FAST after the Mantle route opened).
- No Water-debuff or other never-opening routes were found in this family; every gate reads Ice stacks, Heavy Breath, Slowed Time, Frost, shield or own state that the family itself produces.
- `rule` strings in family-ice.json and the table in family-ice.md updated to the new gates.
