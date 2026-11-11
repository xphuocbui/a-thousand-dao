# Tune 2: Soul, Song, Seal

## suite_check before (start of this pass)
```
suite hollow-bell-canon  truc_co  mean 33.5 s, x1.31  W-L 3-16
suite hollow-bell-canon  ket_dan  mean 23.4 s, x1.17  W-L 0-20
art marching-dirge       truc_co  mean 20.9 s, x0.82  W-L 0-20
art marching-dirge       ket_dan  mean 17.4 s, x0.87  W-L 0-20
art blood-ink-writ       truc_co  mean 18.6 s, x0.73  W-L 0-20
art blood-ink-writ       ket_dan  mean 16.4 s, x0.82  W-L 0-20
```

## suite_check after
```
suite hollow-bell-canon  truc_co  mean 22.9 s, x0.89  W-L 20-0   (lance empower 3.0/fight, bell step 1 3.4/fight)
suite hollow-bell-canon  ket_dan  mean 18.6 s, x0.93  W-L 20-0   (lance empower 1.4/fight, bell step 1 3.0/fight)
art marching-dirge       truc_co  mean 24.5 s, x0.96  W-L 12-8
art marching-dirge       ket_dan  mean 19.4 s, x0.97  W-L 14-6
art blood-ink-writ       truc_co  mean 23.6 s, x0.92  W-L 12-8
art blood-ink-writ       ket_dan  mean 18.2 s, x0.91  W-L 13-5
```
Nine Seal Ledger, Thorn Lullaby unchanged (not in scope). Lint: 0 findings.

## Changes
- Finding: a Soul-type `free_hit` did nothing measurable against the typical foe (raising it 30 -> 80 changed no row); Soul hits are resisted. Payoff hits of the canon are now `elem` type.
- tolling-bell-requiem: `cooldown` 4 -> 3; `toll-add` now adds 2 Tolls per soul hit (was 1).
- tolling-bell-requiem: `toll-echo` free hit c 1.5 -> 4.0, Soul -> elem (still scales per Toll, no cap).
- tolling-bell-requiem: step 1 (Great Peal) free hit c 4.5 -> 14.0, Soul -> elem.
- tolling-bell-requiem: step 2 (Death Knell) now needs 7 Tolls (was 5), hit c 7.0 -> 14.0 elem; it fires rarely (0 per fight, only fed).
- lamp-oil-lance: `cooldown` 5 -> 3; `slackened_soul` applied lasts 5 s (was 2).
- lamp-oil-lance: Fully Lit empower now needs 6 Tolls AND one of (2 Slackened Soul, foe dry, 4 Tolls, Bell rang in 2 s); two conditions instead of one OR-group; kept four feeding routes. Hit c 7.0 -> 80.0 elem.
- `soul_pct` of Bell 0.036 -> 0.033 and Lance 0.043 -> 0.036 to stay inside the lint limit after the cooldown cut.
- marching-dirge: March now +35 % art and basic speed (was 20), cost +5 % (was +20 %); finale free hit per Measure c 0.55 -> 1.8.
- blood-ink-writ: c_art 0.7 -> 0.85, cooldown stays 3, `hp_cost` 0.08 -> 0.03, Withering lasts 4 s (was 3) so it stays up between casts, Stagnation 1 stack for 1 s (was 2 stacks 3 s); `ink-spite` 3 -> 3 % per distinct status (value kept, text says 4 %: left unchanged in the rule line, see md).
- Finding: Withering uptime is the lever for Blood-Ink (duration 3 vs cooldown 3 swung 0-20 to 20-0); dmg_more 2 / 3 / 4 gave 3-16 / 12-8 / 18-2.

TUNE-DONE design/arts/tune2-soul-song-seal.md
