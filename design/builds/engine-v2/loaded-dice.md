# The Loaded Dice (Quán Cốt), rebuilt on the library: a Thunder gambler whose crit rhythm is fed by chained bolts and a fist that turns every crit into a faster timer.

Realm Kết Đan (defining), root Thunder (`purity` thunder 80; 90 at Nguyên Anh), layers, crit 0.30 x 2.0 (0.40 x 2.2 at Nguyên Anh), evade 10, ward and gain on hit kept from the old files. The old files held no Effects, counters or states, so none were removed.

## Piece map

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Cast the Bones (fast Thunder crit filler) | `chain-arc` (five hits, each rolls a crit, each crit +6 crit) | thousand-bolt-scripture (2) |
| Counting Blade (Metal) | none: the root has no Metal purity; loss recorded | - |
| Thunder Debt (crit-taken stacks) | `answering-peal` (crit/slow counted, 3 Peals refire the last art) | thousand-bolt-scripture (4) |
| Winnings (refund on payout) | `overload-form` (crit gives Thunder stacks and a little lightning back) | thousand-bolt-scripture (1) |
| Raise the Stakes (slow big hit) | `capacitor-palm` (every landed Lightning art and crit stores a Charge, released as hits) | thousand-bolt-scripture (6) |
| Flowing Water (crit shortens timers) | `rolling-barrage-fist` (crits shorten other timers, charges, +6 % crit stacks) | hundred-echo-palm-scripture (4) |
| House Takes All (Nguyên Anh, Cash Out) | `twin-shadow-fist` (shadow double quickened by each crit) | hundred-echo-palm-scripture (2) |

The Nguyên Anh file adds `twin-shadow-fist` as the sixth art. The Kết Đan file holds five arts (5 slots).

## Techniques chosen and why

- **Main: `thousand-bolt-scripture`** (Yellow, loi). It is the only Thunder main whose passives are crit chance, crit damage and art speed, and every one of its four arts reads or feeds crits. `heavenly-tribulation-scripture` (the other Thunder main) is stacks and heaven-strike oriented, closer to Thunder Debt but not to a crit meter, and only one main is allowed.
- **Auxiliary: `hundred-echo-palm-scripture`** (Profound, body, always usable). Its passives add crit chance +4 and crit damage +20 (both palm-scoped) and its fist arts turn crits into timer shortening: the nearest library match for Flowing Water. A body technique was the only way to add crit-minded arts, since every secret technique that carries crit names Metal and the root has no Metal.
- A second auxiliary was not taken: the slot budget (5 at Kết Đan) is already full with the 4 + 1 arts.

## What was lost

- **Counting Blade and Raise the Stakes were Metal arts.** The root is Thunder only, so no Metal technique is usable. Raise the Stakes is replaced by `capacitor-palm`, a Charge payout.
- **Thunder Debt (crit-taken stacks) has no equivalent** in the chosen suite (`tribulation-seal` is in the other main).
- **House Takes All / Cash Out (spend the meter on demand):** no library art; `twin-shadow-fist` is a loose stand-in, not a payout choice.
- **Winnings (linh lực refund):** no refund art in the suite; `overload-form` gives a small lightning back. It also costs -25 evade while on, which cuts against the counted-evade side of the Loaded Table.
- Stacked Meter's folded L2 average (+6 / +8 / +10 / +12) is no longer in `x`, since overrides on arts are not allowed.

## Fight results (fight.py, `loaded-dice.fight.json`, --matrix; 20 fights each)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical ket_dan+0 | 11.4 | 20-0-0 | never | 9.9 | overload-feed 19.0, palm-gather-crit 42.2, peal-answer 41.6, barrage-crit-refund 2.6, trig_budget 2.4 |
| typical nguyen_anh+1 | 7.3 | 0-20-0 | 6.0 | never | overload-feed 1.6, palm-gather-crit 8.9, peal-answer 8.3, barrage-crit-refund 0.5 |
| typical hoa_than+2 | 3.1 | 0-20-0 | 2.8 | never | palm-gather-crit 0.7, peal-answer 0.2 |
| top_end ket_dan+0 | 1.6 | 0-20-0 | 1.0 | never | none |
| top_end nguyen_anh+1 | 1.0 | 0-20-0 | 1.0 | never | none |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never | none |

Nguyên Anh file (`loaded-dice.nguyen-anh.fight.json`, no matrix): typical nguyen_anh+0 mean 9.7 s, 20-0-0, you dry never, foe dry 7.8, health left 63 %. Clipped: overload-feed 18.4, palm-gather-crit 33.4, peal-answer 32.4, shadow-quicken 34.5, barrage-crit-refund 1.8, trig_budget 1.7.

## --without tests (typical ket_dan+0, before -> after)

- `--without tech:thousand-bolt-scripture`: mean 11.4 -> 11.5 s, wins 20 -> 20 (changed, marginally; at nguyen_anh+1 and above NO_CHANGE). The technique's passives (+6 crit chance, +10 crit damage, +5 art speed) hardly move this build; the arts it carries do the work.
- `--without chain-arc` (the identity piece, the crit-feeding multi-hit): mean 11.4 -> 20.0 s, wins 20 -> 15, you dry never -> 15.1, foe dry 9.9 -> 14.1, health left 69 % -> 32 %. At nguyen_anh+1: 7.3 -> 7.2 s, still 0 wins.

## UNMODELLED

- Loaded Table (counted crit and evade meters fed by khí vận, pre-filled to half): the simulator uses crit chance as a mean, so the counted order and the pre-fill are not tested.
- Jackpot (every third counted crit +1.0 multiplier): folded into `crit.mult`.
- Counted evade meter: approximated as `evade_pct` 10 (and `overload-form` takes 25 of it away while on).
- Stacked Meter: not modelled; the old folded average went with the invented arts.
- Spilled Luck: folded into `crit.mult`.
- Escape closed by the enabler: no escape art is modelled anyway.
- thousand-bolt-scripture passive `art_speed_pct` [lightning]: the engine reads art speed without hit context, so it applies to every art.
- hundred-echo-palm-scripture passive `art_speed_pct` [physical] and `art_cost_pct` [physical]: same reason, applied to every art.

## Observations

At the same realm (typical ket_dan+0) the fight lasts 11.4 s, well under the 30-60 s band, and it is won 20-0 with 69 % health left and never dry on linh lực; at Nguyên Anh the same-realm fight is 9.7 s, also 20-0. The guide's old figures (about 17 s at Kết Đan, about 12 s at Nguyên Anh with linh lực running dry near 9 s) do not hold: the build is faster and its mana does not run out in this run, but the old file's numbers came from invented arts and folded averages, so the two are not like for like. Against one realm up (nguyen_anh+1) it loses 0-20 in 7.3 s and is dry at 6.0 s, and against top_end it dies in 1.0-1.6 s, which matches the guide's warning about top-end foes. The guide's claim that crits come in a fixed rhythm is not tested (counted meter unmodelled); its claim that the crit-feeding arts carry the build does hold, as `chain-arc` is worth about 9 s and 5 wins at the same realm. NEVER_FIRED: at hoa_than+2 `overload-form`, `capacitor-palm` and `rolling-barrage-fist`; at top_end (all three realms) every art; none in the same-realm typical fights. Many trigger pieces are clipped (palm-gather-crit, peal-answer about 40 per fight at Kết Đan), so the engine's per-pulse limits cap the crit-chaining.
