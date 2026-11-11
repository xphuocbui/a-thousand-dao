# Review session transcript: dao-review-38-51-try1

> The final message of one headless `claude -p` session, saved by the overnight driver.

I've written the findings file with 40 rows, after trimming five low-severity rows to meet the cap. I didn't edit any drafts. I haven't re-read the final file since that trim.

The most serious problems:
- **Nhẫn fatigue cut:** Outlast (the minor that cuts fatigue by 50 %) breaks Combat rule 10, which says no Effect changes fatigue.
- **Counted chance outside keystones:** Vô Tình's Measured is a minor, and Tình's Fear (the 1-in-4 hesitation on the foe's arts) counts a foe's chance. Effects rule 12 allows counted chance only on a keystone, and only on the owner's own chances.
- **Effects that do nothing as written:**
  - Sát's capstone lifting Mutual Ruin's cap, since the sum of health lost tops out at +50 anyway.
  - Sát's post-cull riders, since a cull ends the fight.
  - Tình's Cold Fury, because Anger has no decay rule.
  - Vô Tình's Heartless Strength, because with no companion the share is 0.
- **Looks dominant:** Vô Tình's Steady Power, Thiền's Vows, Sát's Cull, Huyễn's Decoys, Mộng's Dream and Tình's Anger.
- **Batch-wide:** Notables in all 14 drafts use stat keys outside their declared theme stats. Curse-duration cuts and extensions across Ways need one shared floor and cap.

Rows are rated high, medium or low, most severe first.

REVIEW-DONE design/dao-ways/reviews/batch-38-51.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/dao-ways/reviews/batch-38-51.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/dao-ways/reviews/batch-38-51.md) instead (Edit rules cover all file-editing tools).
```
