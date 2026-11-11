# Review session transcript: dao-review-01-14-try1

> The final message of one headless `claude -p` session, saved by the overnight driver.

I reviewed all 14 drafts and wrote the findings to `design/dao-ways/reviews/batch-01-14.md`. It has a one-paragraph summary and a 36-row table, most severe first. The drafts themselves are untouched.

The main findings:
- **Contradicts a rule without a `Needs rule` label:**
  - Seal the Space in `11-can-khon.md` Silences the foe's escape art, which the Silence entry forbids.
  - `12-menh.md` grants counted chance from a major, a minor and a capstone that counts every chance at once, against Effects rule 12 (keystone only, one chance each).
  - Falling Stars in `09-tinh.md` sits outside `trig_budget`, against Effects rule 7.
  - Five drafts remove or shorten the foe's buff stacks, which is not on Effects rule 6's closed action list.
- **Dominant pieces:**
  - Empty Becomes Full (`14-hu-thuc.md`) and Before Taiji (`08-vo-cuc.md`) are dominant outright.
  - Several capstones close something the build never uses, so they cost nothing.
- **Effects the timeline cannot reach:**
  - Bloom at Night and Endless Night (`03-thai-am.md`) need more lunar cycles than a 30–60 s fight contains.
  - Great Void gains at most 5 points over the cap it removes.
  - "First hit" bonuses in `13-dong-tinh.md` and `14-hu-thuc.md` land on the basic attack.
- **Duplicates across Ways:** the Ngũ Hành and Hỗn Độn "all five elements" capstones are the same rule, and so are the Thái Âm and Ngũ Hành capstones that steal the foe's buff stacks.
- **Stat keys:** keys appear in notables outside their Way's `theme_stats`, plus a few keys that exist nowhere. I checked key existence against Character Stats and the modifiers GDD; I did not read the full Character Stats list.

REVIEW-DONE design/dao-ways/reviews/batch-01-14.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/dao-ways/reviews/batch-01-14.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/dao-ways/reviews/batch-01-14.md) instead (Edit rules cover all file-editing tools).
```
