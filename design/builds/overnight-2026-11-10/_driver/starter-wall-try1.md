# Session transcript: starter-wall-try1

> Final message of one headless `claude -p` session.

**The Patient Wall (Nại Bích) is designed and verified except for one failed check.** It is a single-root Earth player build at ordinary power, from Luyện Khí to Kết Đan. Offence is low on purpose, and it relies on filled ward, body and regeneration layers. A same-realm fight with a typical foe lasts about 65 s, over the 30–60 s target, so the fight check fails.

**Fight results** (20 fixed seeds, simulator):
- **Foundation, typical foe:** 20–0, 65.2 s, about 71 % health left. The foe's linh lực runs dry at 48 s; the build's own never does.
- **Core Formation, typical foe:** 20–0, 66.0 s, about 54 % health left. The build's linh lực runs dry at 28 s, so regeneration matters most there.
- **Against stronger foes:** it loses to a foe one realm above (0–20, 13.7 s at Foundation) and to top-end builds (0–20 in 2 s), as an ordinary build should.
- **Identity test:** removing the identity piece (Packed Earth Stance) changes the Foundation +0 and +1 matchups, but only by 0.1–1.2 s. The build's weight is really in its filled defence layers.

**Checks:**
- **Passed (7):** budgets, validity, stack, reuse, NPC use, counterplay and originality.
- **Failed (1):** the fight length. Extra offence and art speed barely moved it, so I left it slow, as the seed asks.
- **Not assessed (1):** scaling. `fight.py` printed no `m_static`; by hand the multiplier is about 2.1 against 4.19 typical.
- **Part not assessed:** the thần thức budget for the two artifacts, because I did not read the thần thức pool.
- **Not modelled by the simulator:** Mending Breath's guard, Iron Skin Renewed, the formation and talisman, and the new Stone Does Not Hurry modifier.

**Direction:** I chose the patient wall: a common ward and a body wall worn together, kept up by one guarded heal. I rejected a pure body build with No Ward, which would remove the ward the build is meant to teach, and a reflecting wall, which needs new rules.

**Staged:** 4 new pieces, 6 reused, and no new system or rule needed. The new pieces are Stone Does Not Hurry (a modifier) and three arts: Packed Earth Stance, Tremor Palm and Mending Breath. I read the "guard" in your seed as the art guard condition on the heal.

Files are in `design/builds/overnight-2026-11-10/builds/`:
- starter-wall.sheet.md
- starter-wall.md
- starter-wall.fight.json
- starter-wall.ket-dan.fight.json
- starter-wall.staging.md
- starter-wall.ledger.md
- starter-wall.suggestions.md

BUILD-RESULT: slug=starter-wall status=DONE staged_new=4 staged_reused=6 suggestions=0 checks_fail=1 checks_na=1
