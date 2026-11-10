I'm wrapping up. I checked `combat-defence.md` against the triage list and found some fixes landed and several did not. The round-2 review output (`round2/combat-defence.json`) is empty, so this is my own read of the GDD. I did not check the other three GDDs or the registry.

**Landed:** the default ward is 0.375 / 0.40 (rule 11 and the knobs table). AC-CD-33 is retired and AC-CD-37 has no decay. Fatigue is in the rule 1 table, and leech is in healing sources. Q3 (Water's live maximum) is in the Edge Cases. The Q4 refund is in rule 16 and Formulas E. Q5 has a cleanse payload row and Clear Heart Ward is updated. Q8 is in AC-CD-57, with the parity dropped. Formulas I health regeneration is 9.9, and `T_ref · φQ` is fixed.

**Still wrong, most important first:**

1. **Stale cap and resistance-share wording after the move to points.**
   - Edge Cases lines 812–813 still say a part's resistance sum "is capped" and that over-cap resistance absorbs penetration. Line 816 in the same list says there is no cap.
   - AC-CD-13 (line 1048) says penetration lowers r "before the cap" and uses 0.30 shares. AC-CD-48 (line 1107) lists "cap" in the Breakdown. Line 949 says "and the cap".
   - Rule 4 (around line 111) says "before the cap".
   - Formulas G (line 720) still gives r a range of −0.5–0.9.
2. **Pre-#44 fixtures not updated.**
   - AC-CD-06 (line 1037) says the body shield is "σ_b 0.30 (131.8)". Formulas G gives a body shield of 436.1 for σ_b 0.90, so 131.8 is the old value.
   - AC-CD-04 (line 1036) says "the default ward would add 0.30". The default ward is now 60 points, a 0.375 stop.
   - Line 1023 still describes the fixture as "R_Physical 0.30 (so Physical 0.675…)". That is the old share arithmetic, not points.
3. **Thể tu ehp numbers (Formulas G, AC-CD-42).** The triage says these were not redone for points. The table (line 739) is labelled "points, 2026-11-10", but I did not recompute 2,098.8 / 1,570.7 / 1,025.8, so treat them as unverified.
4. **Q2 is not clearly in the defence path.** I found no explicit statement that element-stack damage-taken effects apply on the hit before resistance. Rule 1 is the place for it. Only a search of the file turned up nothing, so this could be me missing it.
5. **Simulator and registry formula text** are still open per the triage. I did not verify them.

The Common Ward at 342.5 points, Golden Bell 0.035 and Still Lake 0.71 are consistent with the new price check, so I would not touch them.