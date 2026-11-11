# Session transcript: sect-ladder-try1

> Final message of one headless `claude -p` session.

The Red Hearth Ladder is designed: a mid-sized Fire sect's standard disciple kit for Qi Refining, Foundation and Core Formation. All the outputs are written to the run folder. Staged new pieces: 8, reused: 10.

**The build.** Disciples win by Burn stacks from two cheap Fire arts, Kindle Palm and Red Lotus Ring. Core Formation adds Cinder Lance.

**Identity piece.** Embers Feed the Hearth returns linh lực on each Burn tick, and costs direct Fire hits 15 %. Removing it cuts wins against a same-realm typical foe from 11 to 4 of 20 at Foundation, 12 to 6 at Core Formation, and 19 to 14 at Qi Refining.

**Fight results** (20 fixed seeds, same-realm typical enemy):

| Realm | Result | Mean time |
|---|---|---|
| Qi Refining | 19-1 | 32.3 s |
| Foundation | 11-9 | 29.2 s |
| Core Formation | 12-7-1 | 20.8 s |

Core Formation is under the 30–60 s band. Against an enemy one realm up the disciple loses every fight, as expected from suppression. The Qi Refining file runs strong because the enemy anchor is exact there and no gear is modelled.

**Checks.** 8 PASS, 0 FAIL, 1 NOT ASSESSED. The one NOT ASSESSED is the technique budget, because `bonus_pool` does not hold the two bonus keys the Canon uses. The art lint passes on all four arts.

**Not modelled by the fight script.**
- Kindled Wound is applied unconditionally.
- Embers Feed the Hearth is approximated by `k_burn`, with its 15 % cost folded into the art coefficients.
- Deep Heat, Hearth Banner, the pill, the array, the Đạo nodes and the robe affixes are carried by typical points or not run.

**Tuning.** I reduced the Foundation disciple's L1 points to 26.5, against roughly 62 for the typical anchor, to bring it to even odds. The thin tree is paid for by the sustain.

**Staged.** New: Deep Heat, Red Hearth True Canon, four arts, the sect-curriculum concept and the Hearth Keeper's Line cluster idea. Kindle Palm and Cinder Lance are near-duplicates of starter-flame's Spark Palm and Flame Lance, and the staging file says to merge them if the numbers agree.

**Suggestion.** One: a sect-curriculum record for NPC Builds (#24) and Sects & Missions (#26), neither of which has a GDD yet.

**Files.** All in `design/builds/overnight-2026-11-10/builds/`:
- `sect-ladder.sheet.md`
- `sect-ladder.md` (player guide)
- `sect-ladder.fight.json`
- `sect-ladder.luyen-khi.fight.json`
- `sect-ladder.ket-dan.fight.json`
- `sect-ladder.staging.md`
- `sect-ladder.suggestions.md`
- `sect-ladder.ledger.md`

BUILD-RESULT: slug=sect-ladder status=DONE staged_new=8 staged_reused=10 suggestions=1 checks_fail=0 checks_na=1
