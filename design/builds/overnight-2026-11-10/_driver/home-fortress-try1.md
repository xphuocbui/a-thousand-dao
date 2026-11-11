# Session transcript: home-fortress-try1

> Final message of one headless `claude -p` session.

I've designed the home-fortress build as **The Hearth Mountain (Trạch Sơn)**. Status is DONE, with two checks not assessed because there was no simulator this run.

**Direction chosen:** an Earth formation master who fills L4 (the preparation layer) from all five kinds of preparation at home, and turns the surplus past the cap into walls. Its life tools all exist to force fights onto its own ground. The two directions I did not pick are recorded in the sheet:
- **The Travelling Array:** carry the preparation everywhere. It would soften "crippled in a blind one".
- **The Usurper's Ground:** take the enemy's preparation for yourself. It is a counter, not a top-end stack; one piece of it, Taken Ground, is kept.

**The engine, from the GDD formulas (combat.md Formulas B, combat-defence.md Formulas A):**
- L4 keeps at most 150 points, which multiplies damage by ×2.5.
- A full home setup brings about 310 prepared points (Nine Rods 128, pill 93.6, coating 50, ground 40).
- **Overbuilt Walls (Lũy Thặng)**, the identity piece, turns the 161.6 points the cap clips into +100 ward strength.
- At Nascent Soul (Nguyên Anh) ward strength comes to about 407 at home against 165 blind on the road. The Common Ward then stops 94.6 % of a hit at home and 90.1 % on the road.
- The damage multiplier is about 235 at home (the top-end mark is 256) and about 88 blind on the road.
- **The enabler** is Threshold Binding, carried by the Threshold Flags. Planted before a fight you chose, they make your home formations count on that ground. In a fight where none of your formations count, 25 % of your linh lực is locked away and does nothing.
- **Forcing the fight:** the Alarm Array turns a blind fight at home into an ambush, the Challenge Letter turns a hunter's next fight into a planned one at your home, and Taken Ground holds a rival's preparation to +20.

**Checks:** 7 pass and none fail. Two are not assessed, "The fight" and the identity test, both because there was no simulator this run (user decision 2026-11-11). No fight input was written and nothing was run. The sheet works out by formula that removing Overbuilt Walls lets about a quarter more damage through at home and leaves damage unchanged.

**What I changed:**
- **Staging catalogue:** 27 new rows. I added home-fortress to the "Used by" cell of three rows already staged by other builds: Nine Rods Array, Iron-Sand Hand Bath and Hot Spring Array. Tolled Seal from the content ledger is also reused.
- **Copied from the 2026-11-07 run:** Taken Ground and Landing Ground were not in this run's reuse sources, so I staged them with credit and counted them as new.
- **Run ledger:** one build row and rows in every section.
- **Suggestions:** five, all in `suggestions.md` and in the guide's last section:
  - an `own_abode` ground tag;
  - a way to raise a fight's situation one step;
  - a compile-time readable for a layer's total before its cap;
  - a fight payload for pills, coatings and talismans;
  - a rule for how many formations count on one ground.

Files are in `design/builds/overnight-2026-11-10/builds/`:
- home-fortress.sheet.md
- home-fortress.md

BUILD-RESULT: slug=home-fortress status=DONE staged_new=27 staged_reused=4 suggestions=5 checks_fail=0 checks_na=2
