# Session transcript: summary

> Final message of one headless `claude -p` session.

I've written the end-of-run report to `design/builds/overnight-2026-11-10/RUN-SUMMARY.md`. I didn't edit any other file or run git. Besides the files you listed, I also read `queue.json`, `queue-later.json` and the ends of the `_driver/` logs, only to explain what didn't run.

**The run:**
- **Builds:** all 15 finished on the first try, each with a sheet and a guide.
- **Checks:** none failed; 33 are not assessed.
- **Not assessed:** every fight check, plus 12 identity tests, 5 budget checks and 1 scaling check. The last nine builds skipped the fight check by your no-simulator decision. The first six tried `fight_calc.py`, found it out of date, and fell back on hand-worked numbers.
- **Never started:** 23 more builds sit in `queue-later.json`. The driver logged "queue empty" after giant-killer, the only build taken from that file.
- **Retry logs:** four builds also left a failed "try2" log (the 5-hour usage limit), but all four finished, so nothing was lost.

**Suggestions:** the 51 entries are merged into 17, each with a recommendation. The top three:
1. Record fields for technique abilities and passives, and a fight payload for pills, coatings and formations. All 15 builds need this before any staged piece can enter the game.
2. One batch of new things Effects can read, needed by 10 builds.
3. The thần thức and soul reference table by realm. Its absence left a thần thức budget check undone in eight sheets.

**Staging catalogue:** 288 pieces. 259 of them (90 %) are used by one build only. The most reused are Nine Rods Array (11 builds), Iron-Sand Hand Bath (6) and Ore Weight (4).

**Main balance flags:**
- **Unreliable reference:** the top-end reference opponent the builds were measured against is marked "re-derive" since #44, so every power number is provisional.
- **Fight length:** the builds end same-realm top-end fights in 0.5–8 s, against your 30–60 s target. Only unkillable lands in that range.
- **Above the reference:** 11 builds sit above it on at least one measure; the sheets noted this and didn't pull them back.
- **Boss rule missed twice:** dry-well kills a boss in about 3 s and first-volley in 1.5–2 s, below the 4 s minimum.
- **Fighting upward:** giant-killer's Half a Realm lifts a top-end build's chance one realm up from about 1 % to 25–40 %, which touches tribulation odds.

**Decisions waiting for you:** there are 12, each with a recommendation. The first is to re-derive the top-end reference before judging any build. After it come the low-risk batch of rule clarifications, and closing the gaps in the art power limit (the lint) before more content is written.
