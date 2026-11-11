# Fight re-check, 2026-11-11

The overnight sheets' fight numbers came from the retired `fight_calc.py` (pre-#44) or from paper models. This
re-runs every build that had a fight file on the current simulator, after the ward and body layers
(Combat Defence & Healing Formulas A0). Observations only; the sheets were not edited.

**How:** each v1 fight file was converted by `tools/design/combat_sim/migrate_fight_v1.py` (overnight builds with
`--top-end`, so their wards get every ward layer at cap; the two older builds with `--pre44`, costs halved), then
run with `.claude/skills/design-build/scripts/fight.py <file> --matrix` (20 seeds). The overnight v1 files were
overwritten in place and were never in git (the `builds/` ignore rule, fixed the same day), so the exact v1 text
is gone; every v1 field survives either as a field or as a `v1 …` line in the file's `unmodelled`.

**Read with care:** most engines are not modelled. Curses, guards and conditions, soul arts, triggers, applied
statuses and the builds' own Effects (Cold Toll, the Iron Nail, Ash Ledger, Stored Breath …) are only listed.
What runs is each build's layers, arts, pools and ward. So a result below is the build's skeleton, not the build.

| Build | Realm | vs typical, same realm | vs typical +1 | vs top-end, same realm | Engine modelled? |
|---|---|---|---|---|---|
| first-volley | Nguyên Anh | wins 20/20, 1.3 s | wins, 1.3 s | loses 20/20, 4.0 s, dry at 3.9 s | No (opening haste, guards) |
| curse-engine | Nguyên Anh | wins 20/20, 1.5 s | wins, 3.0 s | loses 20/20, 9.9 s, dry at 8.4 s | No (curse litany, Iron Nail) |
| curse-engine | Kết Đan | wins 20/20, 1.5 s | wins, 3.5 s | loses 20/20, 9.9 s | No |
| dry-well | Nguyên Anh | wins 20/20, 1.0 s | wins, 2.0 s | loses 20/20, 6.8 s, dry at 5.6 s | No (Ice, Cold Toll, Water Table) |
| dry-well | Trúc Cơ | wins 20/20, 6.2 s | wins, 16.9 s | loses 20/20, 8.1 s | No |
| two-clocks | Nguyên Anh | 7 wins, 7 losses, 6 draws, 65 s | loses, 27.9 s | loses 20/20, 6.5 s | No (ticks are its engine) |
| bare-fist | Nguyên Anh | wins 20/20, 26.9 s | wins 19/20, 66 s | loses 20/20, 7.4 s | No (Stored Breath; basic attack only) |
| bare-fist | Kết Đan | wins 20/20, 41.7 s | 20 draws, 66 s | loses 20/20, 7.8 s | No |
| soul-lance | Nguyên Anh | wins 20/20, 66 s | 11 wins, 9 draws | loses 20/20, 19.1 s | No (soul arts; basic attack only) |
| soul-lance | Kết Đan | wins 20/20, 66 s | draws | loses 20/20, 20.0 s | No |
| burial-shroud (older, "strong") | Kết Đan | wins 20/20, 20.4 s | loses, 29.4 s | loses 20/20, 3.2 s | No (Spillover) |
| ninth-bell (older, "ordinary") | Kết Đan | wins 20/20, 6.0 s | loses, 13.4 s | loses 20/20, 2.1 s | Partly (heavy hits on the beat) |

**What it suggests, not proves:**
- Against a typical foe the three art-hit top-end builds (first-volley, curse-engine, dry-well) end the fight in
  their first volley or two, as Combat rule 18 allows.
- Against the new top-end anchor every converted top-end build loses, and each runs dry first (3.9–8.4 s). The
  anchor now keeps its ward up for about 35 s; these builds were designed for 2 s fights and spend their linh lực
  in a few volleys. Under #44 "sustain is king", so a top-end build needs sustain to match the anchor. Since
  their engines are unmodelled, this is a flag for a redesign pass, not a verdict.
- "The fight" stays **NOT ASSESSED** on every sheet: the engine of each build is outside the simulator.

**Builds with no fight file** (written with no simulator): armoury-mind, beast-carry, cooldown-floor, giant-killer,
home-fortress, one-art, slow-thunder, triple-convert, unkillable. A future run can write them with the
simulator on (`tools/headless/run_builds.py` now allows `fight.py` by default).
