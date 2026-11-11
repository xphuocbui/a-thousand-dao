# Session transcript: loaded-dice-try1

> Final message of one headless `claude -p` session.

The Loaded Dice build is finished: the sheet, guide, staging, suggestions and ledger files are written, and both fight files ran on the simulator. Three of the ten checks are NOT ASSESSED and none fail.

**The build.** It is a Thunder (Lôi) gambler on Mệnh Đạo, with the "Counted House" as the chosen direction. Crit and evade are counted on visible meters (the designed Called Blow Effect) instead of rolled. A new enabler, The Loaded Table, adds khí vận to every meter (+0.002 per point, at most +0.15). The player raises khí vận at home with dice, a formation and a pill. Every third crit is a Jackpot. The meters are deterministic, so it is swingy but not random.

**Directions not chosen** (recorded in the sheet):
- **The Reroll Rider** needs rerolls, which bring randomness back (rule 15).
- **The Ill Star** is weak damage. It stays as the build's counter.
- **The Banker** pays outside the fight and doesn't use dice.

**Fight results** (20 fixed seeds):

| Realm | Opponent | Result | Mean time |
|---|---|---|---|
| Kết Đan | same-realm typical | wins 20/0 | 16.8 s |
| Kết Đan | one realm up | loses | 7.4 s |
| Nguyên Anh | same-realm typical | wins 18/2 | 12.2 s |
| Nguyên Anh | one realm up | loses | 5.2 s |

- **Top-end opponents:** the build loses within about 1.6 s at both realms.
- **Sustain:** at Nguyên Anh the build runs dry around 9.5 s, so it has thin sustain there.
- **Speed:** it beats typical foes faster than the 30–60 s band, so it is above typical. I noted it and did not pull it back.

**Checks:** 7 PASS, 0 FAIL, 3 NOT ASSESSED.
- **Technique budget:** NOT ASSESSED. The sutra's bonus keys are not in `bonus_pool`.
- **Identity test:** NOT ASSESSED. The Loaded Table is unmodelled in the simulator, so it cannot be removed. A stand-in run of `--without winnings` did change the Nguyên Anh fight from 18 wins to 14.
- **The fight:** NOT ASSESSED. The counted-meter engine is unmodelled, so the simulator ran a mean-crit stand-in. The sheet lists everything it could not model.
- **Scaling:** `fight.py` printed no `m_static` line, so I judged it on fight times and marked it PASS with an INFO note.

**Staging and suggestions:** 26 new staged pieces, 5 reused. Two suggestions, one for each rule change:
- Let fortune feed a counted chance through one keystone (Effects rule 12).
- Make counted payouts a readable event.

All files are in `design/builds/overnight-2026-11-10/builds/`. Both `loaded-dice.fight.json` and `loaded-dice.nguyen-anh.fight.json` are there.

BUILD-RESULT: slug=loaded-dice status=DONE staged_new=26 staged_reused=5 suggestions=2 checks_fail=0 checks_na=3
