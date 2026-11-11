# Build session transcript: curse-engine-try1

> The final message of one headless `claude -p` session, saved by the overnight driver.

I finished the `curse-engine` build as **The Straw Effigy (Thảo Nhân Chú)**. The proper fight check could not run: `fight_calc.py` is out of date with the current rules. Its results are recorded, but the fight evidence is my own arithmetic on the current GDDs, not a run (roughly ±20 %). Only `fight_calc.py` is allowed to run here, so I couldn't write and run a simulator to check those figures.

**The build.** It uses a Metal–Wood root (Kim–Mộc), the Sinh Tử Đạo's Diệt facet, and a new main technique, the Straw-Man Litany Scripture (Thảo Nhân Chú Kinh).
- **Enabler: the Petty-Man Effigy (Tiểu Nhân Hình Nhân).** Every hit that lands adds the next missing curse from a fixed list: Sealed Meridian on the enemy's art bonus, Sundered ×3, Exposed, and Heavy Breath at Nascent Soul (Nguyên Anh). Its price: when the enemy cleanses one of your curses, it lands on you.
- **Identity piece: Driven Nail (Đóng Đinh).** Each curse you add brings the main art, the Iron Nail, 0.5 s closer.
- **Payoff: Weight of Names (Danh Trọng).** The Nail deals more for every curse stack on the target, while the curses also take 650 resistance points off the defender.

**What the hand check shows at Nascent Soul, against the top-end reference opponent:**

| Version | Result |
|---|---|
| Full build | Wins at 1.5 s with about 70 % health |
| Without Driven Nail | Wins at 2.0 s with about 3 % health |
| Without Weight of Names | Wins at 2.0 s with about 43 % health |
| Without the Effigy | Loses at 1.0 s (the old calculator agrees) |

It is above the top-end anchors in practice; I noted that and did not pull it back. Two things beat it:
- an alpha striker who opens the fight and lands their burst before the first curse;
- a cleanser, whose cleanses send the curses back.

**Checks:** 6 pass, 0 fail, 3 not assessed:
- **Budgets:** nothing gives the divine-sense (thần thức) budget, and curses cost nothing in today's art pricing.
- **Stack:** the calculator can't test removing Driven Nail.
- **The fight:** the calculator uses outdated constants and doesn't model the build's engine.

**Shared files:**
- **Staging catalogue:** 16 new rows. I also added `curse-engine` to the "Used by" of `nine-rods-array` and `cleansed-stacks-event`.
- **Run ledger:** my rows added in every section.
- **Suggestions:** 4 new entries:
  - an event for "your curse was cleansed";
  - +1 curse slot for one keystone (the Fourth Nail);
  - a new `curse_effect_pct` stat;
  - a clarification that a curse's rule applies at once. The build's defence in the first instant depends on that reading.

Files are in `design/builds/overnight-2026-11-10/builds/`:
- curse-engine.md
- curse-engine.sheet.md
- curse-engine.fight.json
- curse-engine.ket-dan.fight.json

BUILD-RESULT: slug=curse-engine status=DONE staged_new=16 staged_reused=2 suggestions=4 checks_fail=0 checks_na=3
