# Overnight 2026-11-08: morning index

**Result:** everything planned for the night was produced. Nothing failed outright. All four new GDDs are still
**NEEDS REVISION**, with **8 design blockers** (2 per GDD) waiting for your answers, and most of the rest of the
night's work waits on those same answers. Nothing was committed.

About **1 h 45 min** to read everything, or **about 50 min** for the short path (marked ★).

## The files

Reading times assume about 200 words a minute (these are dense, table-heavy files).

| File | What it is | Headline result | Read time |
|---|---|---|---|
| ★ `design/gdd/reviews/overnight-2026-11-08-summary.md` (outside this folder) | Summary of the review loop: 16 `/design-review` passes, 4 on each new GDD | All 4 GDDs NEEDS REVISION. 8 blockers, all design choices. 70 safe fixes applied (29 / 19 / 11 / 11). Every number recomputed and matches | 9 min |
| `design/gdd/reviews/overnight-2026-11-08-decisions.md` (outside this folder) | The full questions and answers behind the summary | Reference only. Open it for the reasoning on a blocker you disagree with | 60 min in full; look things up |
| ★ [`combat-revision-draft.md`](combat-revision-draft.md) | Plan for the Combat revision (#43). combat.md was not edited | 76 changes to combat.md, 19 decisions (**4 before #43 starts**, 11 during, 4 minor). About 5 sessions to apply, plus 1 to review | 10 min for §1–2; 50 min in full |
| ★ [`consistency.md`](consistency.md) | `/consistency-check` across 14 GDDs and the registry, report only | 44 findings: **17 new** (4 high), 16 already covered by #43, 11 already in the review summary. The trouble is mostly the older GDDs, none of which mention the four new ones | 8 min for the top and the High table; 18 min in full |
| ★ [`build-test.md`](build-test.md) | The 69 overnight builds (2026-11-07) checked against the new libraries | **19 buildable now, 16 need 1–2 pieces, 34 no longer work.** Plain builds survive; enabler builds mostly don't. Best next piece: Head of Water (Thủy Đầu), an over-cost art, which serves 3 builds | 8 min for the result and the ranked list; 18 min in full |
| ★ [`modifier-variety.md`](modifier-variety.md) | 24 new plain modifiers in 5 groups, each with an empty **Accept?** column | Top picks: status duration on you; shield recharge delay; damage and resistance against creatures or cultivators; block against one type; cultivation speed in seclusion (bế quan) or travel; pill quality | 12 min |
| ~~`tree-shapes.md`~~ | *Removed 2026-11-08.* Three non-wheel shapes for the Meridian Map redesign | None adopted: the user keeps the old PoE-like layout. Their answers and the PoE study that replaced the brief are in `design/research/passive-tree-study.md` | — |
| `README.md` | This file | — | 2 min |

The four new review logs (`design/gdd/reviews/{combat-defence,combat-damage-types,modifiers,effects}-review-log.md`,
about 6–9 min each) are the per-pass audit trail. You don't need them unless you want to check a single pass.

## Reading order

1. **The review summary.** Answer the 8 blockers first. Most other files assume them.
2. **combat-revision-draft.md, §1 and §2 only.** Its D4 is "answer three of the blockers above". D1–D3 must be
   settled before #43 starts.
3. **consistency.md, the top and the High table.** N1 (artifact role tags), N2 (soul wards) and N5 are the same
   questions as D2, D3 and D1 in step 2, so answer them together. N3 (Tribulation bosses still typed by kind) and N4
   (Đạo passives priced in W) need decisions of their own.
4. **build-test.md.** It shows what the libraries are missing. Its "Things worth knowing" asks one Combat question:
   may an Effect lift the 0.25 art-cost ceiling? If not, Head of Water's 3 builds drop to C.
5. **modifier-variety.md.** Fill in the Accept? column. It overlaps with build-test (status duration, the `cheap` tag).
6. ~~tree-shapes.md~~ (removed; see `design/research/passive-tree-study.md`).
7. The decisions file and the review logs only as reference.

## What failed or was not produced

| Item | Status |
|---|---|
| Planned outputs | **All produced.** The 6 files planned for this folder exist, and so do the review loop's summary, decisions and 4 logs |
| Blockers | **Not resolved.** These need your choices. Passes 3–4 found nothing new, so running more unattended passes won't help |
| Harness (`tools/balance/autoplay.gd`) | **Not run anywhere.** No fights re-run (build-test "A" means the pieces exist, not that the build still wins). No W prices measured (modifier-variety values are all guesses). AC-CD-45 stall check (41 s vs about 43.8 s), combat Formulas K's T0, and the timeline fixtures are still open |
| Combat Formulas K's old T0 (7.77) | **Could not be reproduced** from the formula as written. Flagged in combat-revision-draft, not changed |
| Python check in the #43 draft | **Not run** (needed approval). The numbers were worked by hand and agree with Defence AC-CD-06, 22, 32 |
| Registry edits | **Not made**: Defence blocker 1, Damage Types item 5, consistency K1, K2, N2's note, N17 |
| `docs/consistency-failures.md` | **Not updated.** The 17 new conflicts are logged only in consistency.md |
| kinh-mach-do.md (268 KB) | Only partly read for consistency and tree-shapes (targeted sections). Its numbers were not checked |
| Modifier rows with no owner | Row 13 (demonic foes) and row 23 (sect contribution) have no owning GDD. Road encounter rate was dropped. Formations and talismans exist only as quick specs |
| Wheel rejection wording | tree-shapes could not find your words about the wheel in the index (only "not adopted"), so it asks you. For the record, the session checkpoint has them: "looks so bad, much worse than the old one" |
| Specialist agents | None ran (lean mode) |
| Edits outside the GDDs | `systems-index.md` (status cells only). Small GDD diffs, about 75 lines in total, from safe fixes |
| `project.local.yaml` | Removed by the driver at 02:58, right after this README was written (checked afterwards). Automation is back to guided |
| Commits | None. All of the above is uncommitted |
