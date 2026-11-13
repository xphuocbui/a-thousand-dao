# Budget report: first-volley (2026-11-13)

## Claimed share
- Before: 46 % of the typical-to-top-end gap (OVER_BUDGET). After: 21 %. Budget at Nguyên Anh (nguyen_anh): 23 %.
- 150 for L3 read 23 % and still tripped the flag (rounding), so L3 went to 130.

## Layers
| | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|
| Before | 360 | 0 | 250 | 0 | 0 |
| After | 270 | 0 | 130 | 0 | 0 |

L3 was cut most, L1 least (the concept is the opening volley). The `unanswered` Effect (L5 +40) is an Effect, not `layers`, and is unchanged.

## Fights (20 each; mean time, wins-losses)
| Matchup | Before | After |
|---|---|---|
| typical, same realm | 1.0 s, 20-0 | 1.5 s, 20-0 |
| typical, +1 realm (hoa_than) | 2.5 s, 20-0 | 3.7 s, 20-0 |
| top_end, same realm | 33.1 s, 19-1 | 48.2 s, 15-5 |
| top_end, +1 realm | 4.0 s, 0-20 | 4.0 s, 0-20 |

Typical same realm is still 1.5 s, not the 10-20 s a budgeted build should take. The speed comes from the crit and art-speed fields and item modifiers, which `layers` does not hold, so the budget alone does not slow it.

## Pieces removed
None. No technique, item or art was changed.

## What the build lacks to stay strong
- A Thunder `more` multiplier (L2) that library arts can carry; the old L2 300 is gone, as the guide already listed.
- A grade 2-3 Thunder ring and a grade 3-4 Thunder sword whose art joins the suite.
- A Thunder ward armour with a drain ward, for the top-end same-realm fight (it loses 5 of 20 now).
- Preparation (L4) and an escape or step item for Lightning Step.
