# Build session transcript: dry-well-try1

> The final message of one headless `claude -p` session, saved by the overnight driver.

I've designed **The Dry Well (Khô Tỉnh)**, a top-end Water and Ice qi-burn build for Trúc Cơ to Nguyên Anh. All outputs are written. The fight results are hand-worked, not run: the fight calculator still uses the pre-#44 rules and can't express the build's main pieces.

**How it wins.** Ice stacks make the enemy's arts cost more. Heavy, cheap Cold hits make their drain ward spend their pool. The identity piece, **Cold Toll (Hàn Thuế)**, makes each Ice stack also raise the enemy's ward bill against your hits; in exchange, Ice's raise on their art costs is halved. The build's arts are guarded two ways: three opening arts fire only while the enemy has 5 % linh lực or more. Two finishers fire only when they have 5 % or less, so they land on a cultivator with no ward.

**Surviving the opening.** The existing Water Table effect, carried on a new named gourd, returns 30 % of what the enemy's ward pays against your hits. Its price is that your own linh lực never regenerates. While the enemy is still full, their well is your fuel.

**Results at Nguyên Anh (worked by hand on today's GDD formulas, first-guess numbers):**

| Opponent | Result |
|---|---|
| Typical foe | Win at 1.0 s |
| Heavily warded foe with ordinary offence | Win at 2.0 s, no health lost; its arts never fire |
| Top-end foe whose arts first fire at 2.0 s | Win at 2.0 s with 81 % health, own linh lực about 4 % |
| Same foe, without Cold Toll | Loss at 2.0 s: it can still afford two arts |
| Boss with four times the pools | Win at about 3.0 s |
| Anyone striking before 1.5 s | Loss |
| A drainer with a reserved ward | Loss: starving it does nothing, and it starves you |

- **Calculator, old rules:** win against its typical profile at 1.0 s, loss against its top-end profile at 1.0 s. That profile fires an art every second, which matches the "faster than 1.5 s" counter.
- **Owed Water (Thủy Trái), the linh lực-debt piece:** it keeps a dry enemy dry and feeds you half of what they repay. It changed no result in these short fights, and the sheet says so; its value would be in long fights, which I did not model.
- **A boss dies in about 3 s.** Combat rule 18 wants at least 4 s for a top-end build. I noted this as information, not a failure.

**Checks:** 6 pass, 0 fail, 3 not assessed.
- **Budgets:** no source I read gives the thần thức budget.
- **Identity test:** the calculator can't remove Cold Toll because it can't express it; the hand model shows a win turning into a loss.
- **Fight check:** the calculator is out of date for 31 of its 60 constants.

**Staging catalogue:** 21 new rows: 4 effects, 2 modifiers, 1 technique, 6 arts, 2 items, 2 Đạo placements in Vụ Đạo, 4 concepts and keys. One reused row: I added `dry-well` to Nine Rods Array's "Used by". Bare Vessel and Ringing Ground are reused by name from earlier work.

**Suggestions file, 5 entries:**
1. Let one keystone carry Ice onto drain bills. This bends your 2026-11-10 decision that Ice never touches a ward-slot payment.
2. A new linh lực debt concept.
3. Two new readables for effects.
4. A new `ward_bill_pct` stat.
5. A lint charge for curses. The build doesn't need it; it exposes that curse-applying arts pay nothing for the curse today.

Files are in `design/builds/overnight-2026-11-10/`:
- `builds/dry-well.sheet.md`
- `builds/dry-well.fight.json`
- `builds/dry-well.truc-co.fight.json` (an extra input for the Trúc Cơ run)
- `builds/dry-well.md` (the player guide)
- I also added rows to `ledger.md` and `suggestions.md` there.

BUILD-RESULT: slug=dry-well status=DONE staged_new=21 staged_reused=1 suggestions=5 checks_fail=0 checks_na=3
