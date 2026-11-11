# Build session transcript: first-volley-try1

> The final message of one headless `claude -p` session, saved by the overnight driver.

I designed **The Flash Before the Thunder (Tiên Điện Hậu Lôi)**: Thunder root, Nguyên Anh, top-end. All three files are written. Eight checks pass; the fight check is NOT ASSESSED because `fight_calc.py` runs on out-of-date rules (31 of its 60 constants are from before the #44 economy revision). A small current-rules script I wrote could not run unattended.

**How it wins.** A new stat, **opening haste (Tiên Phát)**, shortens only each art's first wait. Together with art speed it puts four Lightning arts at the 0.500 s floor, before anyone's first basic attack. Slot 1 is a costly "Breaker" hit big enough to empty the enemy's ward pool, so the three cheap arts behind it land almost in full in the same instant.

**When the volley doesn't kill:**
- If the enemy is left at half health or less, or refuses Down at 1 health, the finisher Rolling Thunder fires in the follow-up instant at the same millisecond.
- If the enemy's opener also fires at 0.5 s, Unyielding Breath keeps you at 1 health while they stay Down. Without it you win about 4 in 10 of those ties.
- Crits pull the second volley in to 1.0 s; Final Clause fires the Breaker free as you go Down; Lightning Step is the escape.

**Numbers:**
- Multiplier for the first volley is 228, with crits at both caps.
- `fight_calc.py`, with the volley moved to the floor: wins at 0.500 s against the typical and top-end profiles, at your realm and up to two realms up.
- Without opening haste the volley comes at 1.333 s, and the top-end profile's first basic attack knocks the build out at 1.000 s. That is the identity test, and it changes the fight.
- By hand with current rules: even a volley with no crits deals about 42,000 to a top-end opponent with 22,400 health. One realm up it wins about 3 in 4 at 0.5 s.

**What beats it:** bosses with top-end damage and a ×10 pool (it loses at about 2 s), tribulation waves, a reserved ward of 3,000+ points, and its own mirror, which is about even.

**Check in the morning:**
- `first-volley.volley.py` in the builds folder was written but **not run**; it is labelled so. Run it once and compare with the sheet's Fight Results before trusting either.
- Removing Unanswered changes no `fight_calc` result, because the volley overkills anyway. It only matters against big pools and in floor ties; the sheet says so.
- The temporary `fight_calc` inputs (`fv-opening.fight.json`, `fv-ketdan.fight.json`) are in `%TEMP%`, outside the repo.
- Enemy pool sizes at Nguyên Anh are my guesses, because those cells in the GDD still say "re-derive".

**Shared files:** 17 new staging rows, none reused (Eruption and Ringing Ground are reused by name from the by-root list and the tree catalogue). Two suggestions: the opening timer stat (Combat rule 13 and Formulas A2), and two Effects readables. Ledger rows added. No GDD, registry, asset, source or Đạo file was touched, and git was not run.

Files are in `design/builds/overnight-2026-11-10/builds/`:
- `first-volley.sheet.md`
- `first-volley.fight.json`
- `first-volley.md`
- `first-volley.volley.py`

BUILD-RESULT: slug=first-volley status=DONE staged_new=17 staged_reused=0 suggestions=2 checks_fail=0 checks_na=1
