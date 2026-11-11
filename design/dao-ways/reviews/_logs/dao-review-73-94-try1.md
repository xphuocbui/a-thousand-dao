# Job transcript: dao-review-73-94 (try 1)

I reviewed the 21 drafts and wrote `design/dao-ways/reviews/batch-73-94.md`. It has 40 findings (the cap), most severe first, and I dropped the lowest-value ones. The drafts were not edited. I did not check the table's row count after the final edit, but trimmed it from 52 to 40 and reviewed everything against the combat, effects, dao and modifier rules.

The most serious ones:
- **Cô's Lone Blade:** it feeds L3 from an Effect, but L3 comes from gear only.
- **Thủ's capstone:** it raises `ward_cap`, which was retired.
- **Damage cuts:** "Hits on you are reduced by N %" (Vô Vi, Hoàng, Phân Thân) is not a step in the defence path.
- **Si's One Thought:** the chosen tag is unrestricted, so choosing `hit` or `art` makes the penalty never apply.
- **Dominant pieces:** Thệ's oaths cost most builds nothing, and Kiếp's Marks can be farmed on weak foes. Hóa's Giant Form heal combined with fast form switching is a heal loop.
- **Dead Scales:** Long's Soul and Chaos Scales can never stop anything.
- **Vô Vi's Stillness:** it is ambiguous whether the basic attack counts as "an art firing", which decides whether the Way works at all.

I also flagged three overlaps: Nghịch, Hận and Kiếp all turn being hurt into L5; four Ways grant home ground or foreseen fights; and three Ways pick foe rules from a menu.

I did not verify `renown`, `ngo_tinh` as a percent, or the `c_trig` cap value for Thủ's 0.7 capstone, so none of those are in the findings.

REVIEW-DONE design/dao-ways/reviews/batch-73-94.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/dao-ways/reviews/batch-73-94.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/dao-ways/reviews/batch-73-94.md) instead (Edit rules cover all file-editing tools).
```
