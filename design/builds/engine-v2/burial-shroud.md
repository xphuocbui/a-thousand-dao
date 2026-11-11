# The Burial Shroud (Liệm Y Đạo), rebuilt from the library: a ket_dan ward-stripper that burns the foe's linh lực with Qi Disruption and stacks curses on the dying

Input: `design/builds/engine-v2/builds/burial-shroud.fight.json` (ket_dan; the old build had only this one fight file, so there is no other-realm file).

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Spillover (clipped tick damage burns linh lực), the identity piece | Marrow Siphon Palm (`marrow-siphon-palm`): Qi Disruption burns the foe's linh lực each pulse | Hollow Tide Scripture (1) |
| Closing the Lid (heavy finisher on a drained foe) | Hollowing Strike (`hollowing-strike`): 2.2x against a Disruption-wearing foe, more against a low-linh-lực foe | Hollow Tide Scripture (4) |
| Grave Wind (Wither, a second tick) | Fraying Thread (`fraying-thread`): lays Sundered, each batch adds a Fray | Ruin Ledger Scripture (1) |
| Bier Hush (curse that stops regeneration) | Ripening Curse (`ripening-curse`): Stagnation, harder per distinct status on the foe | Ruin Ledger Scripture (3) |
| (none; Closing the Lid's "last courtesy" role) | Gathered Ruin Verdict (`gathered-ruin-verdict`): banks damage-more per status batch landed | Ruin Ledger Scripture (6) |
| Withered Mound Sutra (invented main technique) | Hollow Tide Scripture, main, thuy | - |

Kept unchanged: realm ket_dan, `n_body` 2.6, `n_qi` 2.4, layers [134, 0, 90, 0, 0], regen +3 pp, ward ws 150 / we 150, root Earth and Water (written as `purity` water 50, earth 50; the old file had no purity field, so the 50/50 split is my reading of "Earth and Water"). Every old unmodelled line stays as an UNMODELLED line.

## Techniques chosen and why

- **Hollow Tide Scripture** (Earth main, thuy): its whole suite is the "burn the foe's linh lực" engine the Shroud's Spillover was meant to be, and its force-palm arts are cheap enough for a pool the shroud shrinks.
- **Ruin Ledger Scripture** (Profound secret, tho): the curse suite. Each status or stack batch feeds Fray and the Verdict, so the Rot-style "stack many afflictions" identity survives. Both are usable on tho / thuy purity. Five arts fill the five ket_dan slots exactly (slots_by_realm 5, no bonus slots). Hollow Husk Stance (the suite's third art) was left out: it makes every art cost 35 % more, against a build with a quarter of its pool reserved.
- Not chosen: Undertow Litany (thuy secret, 5-layer drag) and a body technique; the slot count, not the arts, was the limit.

## Lost in the move

- **Grave Rot**, the permanent no-duration tick that is the Shroud's whole enabler, has no library equivalent and no engine field. The tick channel, `dot_pool_cap`/`dot_pulse_cap` clipping and Spillover as overflow-to-burn are gone; Qi Disruption is the nearest burn, and it is an applied status, not a clip rule.
- The 25 % linh lực reservation, `pierce_pct` 30, body guard 40, Bare Vessel (+80 L5 under 5 % enemy linh lực), Corpse-Wax and Rot Deepens (tick-scoped layers): all unmodelled, as in the old file (the old file had them as v1 lines too).
- Closing the Lid's health-paid finisher has no counterpart; Hollowing Strike is the closest.
- The passives of the two techniques partly do not run: status_duration_pct has no engine stat, and the cost and speed scopes are applied to every art.

## Fight (matrix, `--matrix`)

Gap is realms above ket_dan; nguyen_anh+1 is the old "one realm up", hoa_than+2 the "two up". "Clipped" is not reported by the engine's output for this file (there is no tick cap in it), so it is n/a.

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical ket_dan+0 | 7.6 | 20-0-0 | never | 6.7 | n/a |
| typical nguyen_anh+1 | 14.1 | 20-0-0 | never | 10.7 | n/a |
| typical hoa_than+2 | 8.5 | 0-20-0 | 8.0 | never | n/a |
| top_end ket_dan+0 | 3.4 | 0-20-0 | 2.8 | never | n/a |
| top_end nguyen_anh+1 | 2.0 | 0-20-0 | 1.6 | never | n/a |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never | n/a |

Health left on the wins: 96 % (same realm), 61 % (one up).

## --without tests (typical, same realm, before -> after)

- `--without tech:hollow-tide-scripture` (the main technique's passives): 7.6 s -> 7.6 s, 20 wins -> 20 wins, NO_CHANGE. Its passives that run are small (the status-duration one has no engine stat and the cost one is only a few percent); its value is in the arts it carries, which `tech:` does not remove. At typical+1 also no change (14.1 -> 14.1); only typical+2 changed (8.5 -> 8.3 s, still a loss).
- `--without marrow-siphon-palm` (the identity piece, replaces Spillover): 7.6 s -> 9.1 s, 20 wins -> 20 wins, foe dry 6.7 -> 8.1 s, health left 96 % -> 94 %. At typical+1: 14.1 -> 18.6 s, health left 61 % -> 46 %, foe dry 10.7 -> 15.3 s. Still a win in both; the old guide's "a win becomes a loss" does not repeat.

## UNMODELLED

- Grave Rot permanent tick: no engine field for a no-duration status; the old file also had it unmodelled.
- Reservation of 25 % of linh lực: no reservation field.
- `pierce_pct` 30: no field.
- Body guard 40: the typical body is used.
- Spillover: the engine has no clip-to-burn rule; Qi Disruption stands in.
- Bare Vessel: no conditional layer on a foe's linh lực pool.
- Rot Deepens and Corpse-Wax Coating: tick-scoped layers with no tick to scope to.
- Cleansing and the post-fight vitality cost: caller rules.
- Ward shape: modelled as the Common Ward at ws 150, we 150.
- Technique passives: hollow-tide `status_duration_pct` +12 and ruin-ledger `status_duration_pct` +20 have no engine stat; hollow-tide `art_cost_pct` [force], ruin-ledger `art_speed_pct` and `art_cost_pct` [curse] apply to every art because the engine reads them without hit context.

## Observations

Same-realm typical fights last 7.6 s and the one-realm-up win lasts 14.1 s, both well under the 30-60 s band (the old sheet's figures were 4 s and 6 s, so the library arts are slower but not near the band). The guide's claims hold in part: it still wins one realm up (with 61 % health left, not the guide's 6 %), loses two realms up and against every top-end enemy within 1-3.4 s, and the foe's linh lực runs dry before ours (6.7 s and 10.7 s against never), matching the "ward-stripper" arc. The claim that removing the identity piece turns the win into a loss does not hold: without Marrow Siphon Palm it is a slower win. The "never dry for us" line contradicts the old note that own linh lực ran dry at 3 s one realm up, but the shroud's reservation is unmodelled so that comparison is unsafe. NEVER_FIRED: Hollowing Strike and Gathered Ruin Verdict against top_end ket_dan+0; all five arts against top_end nguyen_anh+1 and hoa_than+2, because the fight ends before they come ready.
