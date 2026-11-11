# Build session transcript: soul-lance-try1

> The final message of one headless `claude -p` session, saved by the overnight driver.

I've designed the Soul Lance (Hồn Thương) build, Kết Đan to Hóa Thần, top-end, for players. All outputs are written. Two of the nine checks could not be assessed: the fight check and the budget check. None failed.

**Direction chosen: The Mountain-Bearing Lance.** A soul build gets nothing from a weapon, and it has two or three times the thần thức its gear needs. So it spends its artifact budget on weight. It wears six or seven heavy treasures (bells, a seal, a banner) as armour, and a new Effect, **Thousand-Weight Thought** (Thiên Quân Niệm), turns the thần thức those treasures bind into soul damage (`x_soul` +1 per 1 % bound, cap +60). Thần thức feeds four things at once: the lance (squared), +2 free ward slots, room to carry the treasures, and the treasures' weight. The build never moves `soul_cap` or `soul_lockout`, so it stays inside the rules. Its ceiling is the channel's own: 30 % a second, four lances to kill. The two directions I didn't pick (The Empty Hall, The Lamp-Thief) are recorded in the sheet.

**Results:**
- **fight_calc:** at Nguyên Anh the strong foe dies at 4.000 s, lances landing at 1, 2, 3 and 4 s.
- **Identity test (fight_calc):** at Kết Đan the build wins at 11.0 s; without Thousand-Weight Thought it loses at 12.0 s with the foe at 24 %. At Nguyên Anh, removing it moves the kill from 4.0 s to 5.0 s.
- **By hand (formula E2 is exact for soul hits):** ordinary foes die at 4–4.5 s. A strong foe with a Soul-Guarding Lamp dies at 6.0 s (Nguyên Anh) or 5.0 s (Hóa Thần). An ordinary foe one realm up dies at 6.0 s.
- **What beats it:** bosses (×4 pool takes about 14 s), a rival soul build (an even fight, about 26 s), a realm gap of two or a strong foe one realm up, and a Silence that names the soul tag.

**Why two checks are not assessed:**
- **The fight:** `fight_calc.py` reports CONSTANT_DRIFT on 31 of 60 constants. It can't model Slackened Soul, soul shields, Soul Wound or the new Effects. I also wrote a paper model on the main combat simulator (`soul-lance.sim.py`), but it has **not been run**: running a new script needed approval this unattended session didn't have. Running it is the first thing to do.
- **Budgets:** Combat has no lint for soul arts. I sized all four soul arts to a proposed one, which is a suggestion, not a rule.

**Files**, all in `design/builds/overnight-2026-11-10/`:
- `builds/`: `soul-lance.sheet.md` (the design sheet), `soul-lance.md` (the player guide), `soul-lance.fight.json` (Nguyên Anh), `soul-lance.fight-ket-dan.json` (the second realm), `soul-lance.sim.py` (not run).
- `staging-catalogue.md`: 21 rows. 20 are new; Mother Lode is copied from the by-root missing pieces and used here as a gain. Another session overwrote my Đạo rows once; I re-added them and all 21 are now present.
- `ledger.md`: my rows added to each table.
- `suggestions.md`: three entries — a lint for soul arts, a reference table of thần thức and soul resistance by realm, and a readable for the linh lực a soul hit takes.

BUILD-RESULT: slug=soul-lance status=DONE staged_new=20 staged_reused=1 suggestions=3 checks_fail=0 checks_na=2
