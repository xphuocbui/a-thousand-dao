# Session transcript: status-collector-try1

> Final message of one headless `claude -p` session.

The build is written up with one check failing: at Hóa Thần the arts never fire against a typical foe.

**The build:** The Hundred-Ailment Ledger (Bách Bệnh Lục), a five-element-root breadth build for Kết Đan to Hóa Thần. Six cheap element "brand" arts each lay a different affliction. The Tally Gourd adds three more kinds. Marked Prey and Crowded Ledger pay per kind. One hit, Ledger Reckoning, cashes in the count.

**Fight results (`fight.py` on the simulator, 20 fixed seeds):**
- **Kết Đan, typical foe, same realm:** wins 20-0 in 5.8 s. Every art fires.
- **Kết Đan, typical foe one realm up (Nguyên Anh):** wins 8, loses 12.
- **Hóa Thần, top_end foe:** wins 14, loses 5, one draw, in 9.5 s. This only holds with pools and health at n 2.0 and ward strength 84.1; at n 1.2 it lost 0-20. Those two settings are my assumptions.
- **Hóa Thần, typical foe:** wins 20-0 in 1.6 s, but all seven arts show NEVER_FIRED. The basic attack at L1 400 ends it first. That is the failing check.
- **Identity test:** I removed Ledger Reckoning, not Tally Ten, because Tally Ten is unmodelled. That changed the fight in four of the seven matchups run. At Hóa Thần against top_end, wins went up (14 to 16) and time went up (9.5 to 12.6 s), because its 6 % cost dries the pool.

**Checks:** 6 PASS, 1 FAIL (the fight), 2 NOT ASSESSED (Budgets, NPC use). Inside the PASS rows, aux harmony and the identity test on Tally Ten were also not assessed.

**Unmodelled:**
- The count itself is flat on Reckoning's `x` and gives the basic attack nothing.
- The Gourd's echo statuses and the extra curses are not applied.
- Rolling Refresh, guards, conditions and triggers are not modelled.
- The 30 % enabler cut is approximated as `c_art` 0.7 on the brands.

**Staged:** 22 new pieces, 4 reused (`nine-rods-array`, `deeper-nails`, `cleanser-telegraph`, `preparation-fight-payload`), 2 suggestions: a second Effect raising Marked Prey's cap, and a live-count Per in L2.

I did not run the matchups against `top_end_the_tu` or a cleanser; those two counters in the sheet are reasoned, not simulated.

All files are in `design/builds/overnight-2026-11-10/builds/`:
- `status-collector.sheet.md`
- `status-collector.md`
- `status-collector.fight.json`
- `status-collector.ket-dan.fight.json`
- `status-collector.staging.md`
- `status-collector.suggestions.md`
- `status-collector.ledger.md`

BUILD-RESULT: slug=status-collector status=DONE staged_new=22 staged_reused=4 suggestions=2 checks_fail=1 checks_na=2
