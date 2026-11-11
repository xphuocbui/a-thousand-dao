# The Flash Before the Thunder (Tiên Điện Hậu Lôi), rebuilt on the library

A Lightning volley that leaves your hands together at the opening floor, before most foes act.

Fight file: `design/builds/engine-v2/builds/first-volley.fight.json` (Nguyên Anh, the only realm the old build had a file for; no other realm file written). Root: `purity {"thunder": 60}`. The old fight file had no `purity` field; the value 60 comes from the guide ("purity 60 or more").

## Library mapping

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Cloud-Splitting Bolt (Breaker) | `chain-arc` (five hits, each rolls a crit) | thousand-bolt-scripture (2) |
| Forked Light | `forked-light` | generated common technique (common art, layer 1) |
| Thunder Needle (Leaking Ward) | `answering-peal` (closest: crit and slow feed) | thousand-bolt-scripture (4) |
| Iron Spark (60 % Physical) | none, dropped | n/a |
| Rolling Thunder (finisher) | `capacitor-palm` (releases stored Charges) | thousand-bolt-scripture (6) |
| Lightning Step (escape) | none, dropped | n/a |
| (no old equivalent) | `overload-form` (+25 % art speed, +15 crit toggle) | thousand-bolt-scripture (1) |
| Opening haste +250, Unyielding Breath, Flowing Water, linh lực on crit, Unanswered | kept as build pieces: `opening_haste_pct 250`, `refusals 1`, three Effects | n/a |

## Techniques chosen and why

- **Main: `thousand-bolt-scripture`** (Yellow main, loi). It is the only Thunder main whose suite is about crits and bursts: chain-arc rolls five crits, capacitor-palm banks Charges from crits, and answering-peal fires the last art again on crits. The build's crit caps (50 % / ×3.0) and Flowing Water feed it directly.
- **Common art `forked-light`** in place of an auxiliary technique: it is the old Forked Light and a cheap thunder follower.
- **No auxiliary catalogue technique.** The Thunder root has only `heavenly-tribulation-scripture` (a second main, not allowed as an auxiliary). Body techniques were usable but their arts (palm, fist, stances) add nothing to a volley and would exceed the 6 slots with the main's 4 arts. One slot stays empty (5 of 6 used).

## What was lost

- **Iron Spark's Physical conversion** (answer to a Lightning-only resistance wall): no Thunder library art converts. Lost.
- **Lightning Step** and Cold Feet (escape): no library equivalent; the engine models no escape anyway.
- **Breaker identity** (one huge hit that empties the ward in an instant): chain-arc is five small hits, not one big one. The guide's ward-emptying claim no longer has a carrier.
- **Thunder Needle's Leaking Ward curse**: not carried by any chosen art.
- **L2 Lightning more (300) and L4 preparation (150)**: the old file held them in per-art `x`, and library arts take no overrides, so both are absent. This lowers damage versus the old file; the numbers below are not comparable with it.
- **First Move, Eruption, Taut String, Final Clause, Cold Feet**: not carried over (the arts they served are gone, or the engine lacks the read).

## Matchups (`--matrix`, 20 fights each)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, same realm | 1.5 | 20-0-0 | never | 1.1 s | flowing-water 17.0, overload-feed 15.3, palm-gather-crit 18.7, peal-answer 17.1 |
| typical, +1 realm (hoa_than) | 2.0 | 20-0-0 | never | 1.5 s | 17.9 / 16.1 / 20.6 / 19.1 |
| top_end, same realm | 4.7 | 0-20-0 | 4.3 s | never | 40.8 / 34.4 / 46.0 / 44.5 |
| top_end, +1 realm | 2.2 | 0-20-0 | 2.1 s | never | 18.0 / 15.9 / 20.9 / 19.4 |

Clipped lists, in order: flowing-water, overload-feed, palm-gather-crit, peal-answer (per fight).

## --without tests (typical, same realm, nguyen_anh+0)

| Test | Before | After |
|---|---|---|
| `--without tech:thousand-bolt-scripture` | 1.5 s, 20-0, foe dry 1.1 s | 1.5 s, 20-0, foe dry 1.1 s (no change at any of the four matchups) |
| `--without unanswered` (identity piece: Effect) | 1.5 s, 20-0, foe dry 1.1 s | 1.5 s, 20-0, foe dry 1.5 s (hoa_than+1: 2.0 s becomes 2.5 s) |

Opening haste is a build field, not an Effect, so `--without` cannot remove it; no test was run on it.

## UNMODELLED

- L2 Lightning more (300) and L4 preparation (150): library arts take no overrides, so per-art `x` cannot be written.
- First Move, Eruption, Taut String, Final Clause, Cold Feet: arts or reads absent.
- Lightning Step escape art: no library equivalent.
- Technique thousand-bolt-scripture passive `art_speed_pct` scoped `[lightning]`: the engine reads art speed without hit context, so it applies to every art.

## Observations

Against the typical foe at the same realm the fight lasts 1.5 s, far under the 30-60 s band; at +1 realm it lasts 2.0 s. Against top-end at the same realm it lasts 4.7 s and is lost 20 of 20; at +1 realm it is lost in 2.2 s. The guide's claims that the volley wins at the floor against a top-end profile at the same realm, and that Unyielding Breath wins the tie, do not hold here: the top-end foe wins every time with the refusal set to 1, though L2 and L4 are missing and make this a weaker build than the old one. The claim that most opponents never act holds for the typical foe (foe dry at 1.1 s, the build never dry). Removing the main technique changes nothing, which suggests its passives are redundant with the capped crit and the 200 % art speed, or that the loader does not apply them here; this was not investigated. The Unanswered test shortens nothing at the same realm and lengthens the +1 realm fight by 0.5 s when removed. NEVER_FIRED arts: none; answering-peal, capacitor-palm and forked-light fire under one time per typical fight (0.9), overload-form 1.9, chain-arc 3.0.
