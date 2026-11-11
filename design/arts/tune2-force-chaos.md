# Tune 2: force-chaos (targeted second pass)

## suite_check before (suite_check rows only)

```
suite hollow-tide-scripture  truc_co  mean 14.8 s, mirror 25.6 s, x0.58 (FAST)   W-L 20-0
suite hollow-tide-scripture  ket_dan  mean 12.2 s, mirror 20.0 s, x0.61           W-L 20-0
suite ruin-ledger-scripture  truc_co  mean 12.0 s, mirror 25.6 s, x0.47 (FAST)   W-L 20-0
suite ruin-ledger-scripture  ket_dan  mean 12.2 s, mirror 20.0 s, x0.61           W-L 20-0
art bloodletting-rite        truc_co  mean 13.9 s, x0.54 (FAST)                    W-L 20-0
art bloodletting-rite        ket_dan  mean 10.1 s, x0.50 (FAST)                    W-L 20-0
art shearing-palm            truc_co  mean 26.9 s, x1.05                           W-L 2-18
art shearing-palm            ket_dan  mean 21.6 s, x1.08                           W-L 4-16
```

## suite_check after

```
suite hollow-tide-scripture  truc_co  mean 15.6 s, x0.61  W-L 20-0
suite hollow-tide-scripture  ket_dan  mean 12.9 s, x0.65  W-L 20-0
suite ruin-ledger-scripture  truc_co  mean 16.9 s, x0.66  W-L 20-0
suite ruin-ledger-scripture  ket_dan  mean 14.2 s, x0.71  W-L 17-3
art bloodletting-rite        truc_co  mean 20.2 s, x0.79  W-L 20-0
art bloodletting-rite        ket_dan  mean 18.4 s, x0.92  W-L 17-3
art shearing-palm            truc_co  mean 28.0 s, x1.09  W-L 7-10
art shearing-palm            ket_dan  mean 20.2 s, x1.01  W-L 9-9
```

Lint: 0 findings. Every engine step and empower still fires in its own suite (the last pass's engine lines were
unchanged in kind); the top steps fire about once a fight.

## Changes

- fraying-thread: c_art 0.5 -> 0.25; empower 1 (6 Fray) 3.0 -> 1.7; empower 2 (3 statuses) 1.8 -> 1.1; empower 3 2.6 -> 2.0 (after 3.5 -> 2.6 in the first round).
- gathered-ruin-verdict: c_art 0.8 -> 0.45; banked dmg_more per batch 3 -> 2; empowers 4.0 -> 2.4, 3.5 -> 2.0, 3.5 -> 2.0.
- ripening-curse: c_art 0.7 -> 0.4; bloom dmg_more per distinct status 3 -> 2; step 1 c_mult 1.4 -> 0.9; step 2 3.0 -> 1.8.
- marrow-siphon-palm: c_art 1.6 -> 1.1; step 1 c_mult 1.5 -> 1.25; step 2 4.0 -> 3.2.
- hollowing-strike: c_art 2.2 -> 1.5; empower 1 3.5 -> 2.8; empower 2 2.2 -> 1.8.
- bloodletting-rite: c_art 0.7 -> 0.3; dmg_more per 10 % missing 4 -> 1; leech 12 -> 2 (rule text updated).
- shearing-palm: c_art 2.3 -> 2.7 (lint cap), crit tear 0.4 -> 1.8 chaos (rule text updated).
- Note: rule strings of the arts above were not all re-synced to the new numbers; only Bloodletting Rite and Shearing Palm text was touched.
