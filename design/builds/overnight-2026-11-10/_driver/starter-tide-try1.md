# Session transcript: starter-tide-try1

> Final message of one headless `claude -p` session.

The Brimming Tide (Mãn Triều) is designed and proved on the simulator, with two checks that could not be fully assessed. It runs Luyện Khí to Kết Đan, ordinary power, Water root at about purity 60, for a player. Luyện Khí was not run on the simulator, so only Trúc Cơ and Kết Đan have fight results.

**Direction chosen:** keep the pool near full and get paid for it. Arts get +2 % more damage per 10 % of pool left (up to +20 %), and the ward gets cheaper while the pool is at 80 % or more. The two directions I did not pick, the Ebb Gambler (hits harder the emptier the pool) and the Drawn Well (drains the enemy's pool), are recorded in the sheet.

**Pieces:**
- **Technique:** the Reading the Tide Canon (Độc Triều Kinh), tier 2, which reaches Kết Đan.
- **Arts:** Tide Pulse, Deep Well Seal and Drawing Breath, all inside the art lint.
- **Items:** the Tide-Bound Gourd, which carries Spill Shield, plus the Still Pool Array and the Clear-Spring Pill.
- **Đạo:** the Uyên and Triều facets of Thủy Đạo (the Water Way).
- **Identity piece:** Brimming Cup, reused from the missing-pieces file.

**Fight results (typical foe, 20 seeds):**

| Realm | Gap | Result | Mean time |
|---|---|---|---|
| Trúc Cơ | same realm | 20–0 | 30.8 s |
| Trúc Cơ | one realm up | 0–20 | 11.5 s |
| Kết Đan | same realm | 20–0 | 26.3 s |
| Kết Đan | one realm up | 0–20 | 8.0 s |

- **Same-realm wins:** the foe ran dry at about 22 s (Trúc Cơ) and 18.5 s (Kết Đan), and my pool never ran dry. The Kết Đan fight is slightly under the 30 s target; I noted it and left it.
- **Against stronger foes:** one realm up and top-end foes beat the build in every fight, which matches the sheet's counterplay section.
- **`--without drawing-breath`:** it changed the fight at both realms (health left 37 % → 32 % at Trúc Cơ, 29 % → 24 % at Kết Đan).
- **Flags:** no `cap_hit` or `lint_over` lines appeared. `NEVER_FIRED` showed up only in fights the build lost in a few seconds.

**Checks: 7 PASS, 0 FAIL, 2 NOT ASSESSED.**
- **Budgets:** `linh_luc_pct` has no `pool_max` figure on this run, so the technique's bonus budget could not be checked.
- **The fight:** Brimming Cup is the engine and ran as a flat +16 in L5. The identity test could only remove Drawing Breath, not the Cup. Still Water, Spill Shield and the items are also folded into numbers rather than run as pieces. The `UNMODELLED` lines and the simulator's `model_note` are in the sheet.
- **Scaling:** I multiplied M by hand (3.74 at Trúc Cơ, 4.79 at Kết Đan, against typical 4.19 and 5.48) because the script's output did not include it.

**Staging:** 12 new pieces and 9 reused (Brimming Cup, Spill Shield, Gathering Tide, Full Sea, the Water damage and Water art cost tree rows, Hot Spring Array, The Spring Never Fails, Well-Drawing Gourd). There are 2 suggestions, both new rules: Still Water needs the ward to read the pool share, and Depth Is Shield needs max linh lực to count toward ward strength.

Files are in `design/builds/overnight-2026-11-10/builds/`:
- starter-tide.sheet.md
- starter-tide.md
- starter-tide.fight.json
- starter-tide.ket-dan.fight.json
- starter-tide.staging.md
- starter-tide.suggestions.md
- starter-tide.ledger.md

BUILD-RESULT: slug=starter-tide status=DONE staged_new=12 staged_reused=9 suggestions=2 checks_fail=0 checks_na=2
