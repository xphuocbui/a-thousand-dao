# Job transcript: dao-fix-38-51 (try 1)

I revised all 14 drafts (38–51) and wrote `design/dao-ways/reviews/fix-38-51.md`. I couldn't run a final `git status`, so I haven't checked that nothing outside these 14 files and the triage file changed. I didn't re-read the edited files either.

The review rows for this batch were already fixed in the earlier triage. So this pass was mostly pointing labels at the accepted rules (R1 `delay_timer`, R3, R5, R6, R7, R8, R9, R11, R13, R16, R18, R20, R22). The Mộng Dream and swap pieces are marked `(deferred, R15e)`. Labels no decision covers are left as they were.

Eight pieces changed substance to fit a rule:
- **Sát:** Cull moved from the Đao Phủ major to the capstone (R15c), with the refusal, overkill and boss/tribulation rules written in. The major is now Death Sentence, a +25 % crit damage finisher with no cull.
- **Thiền:** Diamond Body stops Chaos at 30 % and Diamond Never Breaks at 50 %, since R3 caps it at 50 %.
- **Mộng:** Drowsy Air now puts 2 Slowed Time stacks on the foe instead of cutting its art speed directly (R21). Shake It Off is a `strip_buff` (R16).
- **Huyễn:** Sow Demons now gives 1 Slowed Time stack per 10 fight heart demon (R21). Mirror Returns reflects hits fully stopped by wards (the R20 event), which is narrower than "damage stopped".
- **Nhẫn:** Last Stand no longer claims a trigger-budget exemption (R18).

Hoa's capstone keeps its `Needs rule` as R18's one exception. Băng's Absolute Zero and Cold Toll were not in these files and are untouched, and no GDD, index or decisions file was edited.

FIX-DONE design/dao-ways/reviews/fix-38-51.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/dao-ways/reviews/fix-38-51.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/dao-ways/reviews/fix-38-51.md) instead (Edit rules cover all file-editing tools).
```
