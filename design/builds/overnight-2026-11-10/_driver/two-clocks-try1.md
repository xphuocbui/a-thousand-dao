# Build session transcript: two-clocks-try1

> The final message of one headless `claude -p` session, saved by the overnight driver.

The Two Clocks (Song Thời) build is written, but none of its fight numbers have been run in a simulator: they come from a hand-worked model of the current formulas. The skill's `fight_calc.py` is out of date (31 of 60 constants no longer match `combat.md`), and this session was only allowed to run that one script.

**The seed's premise no longer holds.** Revision #44 removed `dot_pulse_cap` and `dot_pool_cap`. Burn and Poison are now element stacks with no cap, held back only by resistance and cleansing. I read "spend what the caps clip" as "spend what the enemy's resistance stops". A drain ward already pays linh lực for every point it stops, ticks included.

**The build** (Wood-Fire root, Kết Đan to Hóa Thần, top-end):
- **The fast clock is Burn:** 20 stacks for 2 s, every second. Fire is resisted heavily, so most of it is stopped. The new identity piece, Ash Ledger, burns 20 % of everything stopped from the enemy's linh lực. The existing Spillover burns 25 % of what lands. Together the enemy runs dry at about the same speed whatever their resistance.
- **The slow clock is Poison:** 4 stacks for 16 s, piling up. It passes every shield and almost nobody resists Chaos.
- **When the first clock rings** (enemy linh lực at 0), they stop casting and their drain ward goes out.
- **The enabler, the Twin-Wick Incense Clock,** lets bonuses that normally touch only hits apply to ticks, so Bare Vessel's +80 % lands on every tick from then on. Its price is that your hits deal no damage at all.
- **Results at Nguyên Anh:**
  - An ordinary foe dies at about 4 s.
  - A strong foe goes silent at about 3 s and dies at about 8 s, with you on about 58 % health.
  - Without Ash Ledger it is about 9 s and about 25 % health.
- **What beats it:** a foe with status resistance past 100 %, which leaves your stacks at the 5 % floor, and burst builds that kill before the third second.

**Two rule gaps found** (both filed in `suggestions.md`):
- **Uncapped stack grant:** AC-EF-69 lets an art whose charge would pass 0.6 simply pay 0.6, so the grant has no ceiling. Read literally, the "fastest legal kill clock" is unbounded today.
- **Short batches are underpriced:** a 1 s batch costs the same as a 10 s batch, yet skips the slow build-up and ticks before a cleanse can thin it.

The build is designed inside the bounds these fixes would set.

**Check results:**

| Check | Result | Reason |
|---|---|---|
| Validity, Reuse, NPC use, Counterplay, Originality | PASS | |
| Budgets | NOT ASSESSED | No source gives the thần thức budget for the named artifacts |
| Stack | NOT ASSESSED | `fight_calc.py` cannot express Ash Ledger, so the identity test cannot run there |
| Scaling | NOT ASSESSED | The top-end anchors in Combat Formulas B are marked "re-derive" since #44 |
| The fight | NOT ASSESSED | 31 drifted constants; the engine is not modelled |

`fight_calc.py` itself reported a loss at 3 s, hitting the retired caps. That result belongs to the pre-#44 model.

I also wrote `two-clocks.sim.py`, which builds on the canonical #44 simulator in `tools/design/combat_sim/` without changing it. It has never been run; running it is the first thing to do to check the hand-worked numbers.

**Shared files:**
- **Staging catalogue:** 16 rows (13 new pieces, plus 3 rows for by-root pieces I reused by name).
- **Reused from the content ledger:** Bare Vessel, Rot Deepens and Corpse-Wax Coating, by name only, with no new rows.
- **`suggestions.md`:** 4 entries, the two gaps above plus two rule changes the build needs.
- **`ledger.md`:** the build's rows.

No restricted files were touched.

Files are in `design/builds/overnight-2026-11-10/builds/`:
- `two-clocks.sheet.md`
- `two-clocks.fight.json`
- `two-clocks.md` (player guide)
- `two-clocks.sim.py`

BUILD-RESULT: slug=two-clocks status=DONE staged_new=13 staged_reused=6 suggestions=4 checks_fail=0 checks_na=4
