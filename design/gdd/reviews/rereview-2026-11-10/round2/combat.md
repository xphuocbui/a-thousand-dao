**Re-review of `design/gdd/combat.md`: NEEDS REVISION (minor).** The triage's combat.md fixes landed, with the exceptions listed below. The `rereview-2026-11-10/round2/` folder was untracked, so I did not read it. Nothing here needs a design decision.

**Landed**
- Typical ehp is 1,376.2, or 218 U, in Formulas A and B.
- The Poison example uses 0.019 stacks.
- The `c_tick` range is re-based.
- `upkeep_share` is gone.
- Resistance is in points with no cap in the formulas.
- Parameter keys lists the #44 keys (`fatigue_*`, `regen_k`, removals).

I did not re-check the Game Feel "30–60 s" fix.

**Still wrong, most important first**
1. **Stale resistance model in the fixtures (`combat.md:577`, `:580–583`).** These lines still use the pre-Q1 model.
   - `:577` says "Common Ward (all resistance 0.625, drain 0.328), so r 0.8175 at ws 30.8".
   - `:580` says "resistance at its cap, r 0.75 … rising to 0.90 with cap raises".
   - The thể tu fixture at `:583` gives Physical resistance as shares (0.30, 0.20, 0.10) and body shield 0.90, against the triage's 0.51.
   - These should be in points: Common Ward 342.5 points, which stops 81.75 % at Qi Refining. The top-end build needs a points figure. The thể tu ehp is still unfixed, as the triage notes.
2. **Wrong point value (`:761`).** The Poison example says "the Common Ward's 448 points". The triage records 342.5 points, and 448 does not match 81.75 %. The 0.1825 pass share (1 − 0.8175) is fine.
3. **Retired keys still live in Parameter keys.**
   - `:946` still lists `resist_cap`, `resist_cap_max` and `resist_floor`, and `:951` lists `resist_cap_pct`.
   - `:1132` lists `curse_shred_max` as active, while `:744` marks it retired.
   - Move them to the removed list, and state that resistance is in points.
4. **Header dates.** `:6–7` still read Last Updated 2026-11-09 and Last Verified 2026-11-08, though the sweep was 2026-11-10.
5. **Mirror-length table (`:589–593`).** The "old sim" columns still show 6.5–7.6 s, and every other ehp cell reads "re-derive". The triage lists the simulator as not yet re-run in points, so this is a known gap and not a regression.

I could not confirm the "element stacks in the fight" pointer to Effects rule 9a. My grep for "9a" and that phrase found nothing in `combat.md`, so it appears not to have been added.