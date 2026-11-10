## Confirming re-review: `design/gdd/effects.md` (headless, read-only)

**Verdict: nearly clean. 3 small items remain, none blocking.**

I checked every effects.md item in the triage against the file. I did not re-review the document as a whole.

**Landed:**
- The stale tick-cap text is gone. Rule 7 (line 173) and the Corpse Rot row (line 331) are fixed, and the only remaining mentions are "removed by #44".
- AC-EF-16 now uses Exposed instead of retired Shock.
- Formulas D (line 579) states the 60 s "for the fight" charge, rounding down to 0.01, and the 0.05-stack removal threshold.
- Rule 9's status bounds exempt Burn and Poison (line 319).
- The Formulas B example uses Corpse Rot's 0.02 and gives 3.45, and AC-EF-18 labels 0.03 as a test fixture.
- The Spiritual Roots dependency row is added (line 671).
- The cleansing-ward owner is named as Combat Defence & Healing (line 670), and `combat-defence.md` mentions cleanse in 3 places.

**Still wrong, most important first:**
1. **The header's `Last Verified` is still 2026-11-08** (line 6), while Last Updated is 2026-11-10. The next review's receipt would be meaningless. Update it, or leave it and say why.
2. **The registry still has no entries for the element-stack numbers.** `w_kind` 0.010 / 0.015, `cleanse_share` 0.25, the 0.6 charge cap, the per-stack table and `c_tick` 0.019 are not in `design/registry/`. They are stated in rule 9a, Formulas D, Tuning Knobs and the ACs, so a refit can drift. The triage lists this as left to do, and it is still open.
3. **`dot_pool_cap` still lists `effects.md` in `referenced_by`** (`entities.yaml:2544`), although it is deprecated and the GDD no longer relies on it. Remove that line.

**Minor:**
- **Tuning Knobs:** the 0.05 removal threshold and the 60 s horizon are in Formulas D but have no row in Tuning Knobs. Review item 4 asked for the threshold to be a knob.
- **AC-EF-69 and the Formulas D example:** these say "2.55 passes, 2.56 fails". They now agree with the stated round-down rule, but the AC does not mention the rule. Add "(rounded down to 0.01)" so a tester sees why 2.556 passes.
- **Recommended items 5–8:** Combat's matching Burn and Poison exemption, the Heavy Breath × Ice cost compounding note in UI Requirements, AC ordering, and the Open Question 11 overlap note were not checked. Treat them as open unless done elsewhere.