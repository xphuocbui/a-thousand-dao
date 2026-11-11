# Job transcript: dao-review-63-72 (try 1)

The review is written to `design/dao-ways/reviews/batch-63-72.md`, 40 rows, most severe first. I didn't edit any drafts. I could only spot-check stat-key coverage.

- **Rule problems.** Several pieces use actions outside the closed list, or break a rule that isn't labelled `Needs rule`:
  - Điếu's Take the Bait shortens the foe's timers. The rules only allow delaying them, and as written it speeds the foe up.
  - Tửu's capstone exceeds `evade_cap`.
  - Trận's Ward Array is a ward with no payment.
  - Kỹ, Đan, Tửu and Điếu use counted chance on minors and majors. Only a keystone may do that.
- **Effects that can't work on the timeline.**
  - Cầm's Resonance breaks every second, because the basic attack has no form tag.
  - Họa's Write the Character can never complete if any slot holds a ward or an escape art.
  - Kỹ's Quick Release does nothing.
  - Họa's Fresh Ink does nothing, because the companion already acts at 1 s.
  - Tửu's Burning Gourd cap of 50 % is unreachable.
- **Dominant pieces.** Tửu's wines, Đan's Thrown Pill, Họa's Living Scroll, Thâu's Steal the Art and Điếu's Lone Angler have no real cost.
- **Batch overlaps.**
  - Kỹ, Trận and Họa each give prepared ground to an unprepared fight.
  - Kỹ and Trận both build talisman-first Ways.
  - Kỳ's Answer Move and Ti's Strings Attached do the same thing.
- **Stat keys.** All ten drafts use stat lines outside their Theme stats. Several keys are also undeclared, such as formation upkeep, appraisal, loot and travel. These are in the last rows.

REVIEW-DONE design/dao-ways/reviews/batch-63-72.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/dao-ways/reviews/batch-63-72.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/dao-ways/reviews/batch-63-72.md) instead (Edit rules cover all file-editing tools).
```
