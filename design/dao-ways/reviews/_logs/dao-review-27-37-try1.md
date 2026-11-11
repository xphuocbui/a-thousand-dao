# Review session transcript: dao-review-27-37-try1

> The final message of one headless `claude -p` session, saved by the overnight driver.

I reviewed all eleven drafts (27–37) and wrote the findings to `design/dao-ways/reviews/batch-27-37.md`: a one-paragraph summary and a 37-row table, most severe first.

I did not check the 20 or so stat keys outside `modifiers.md`, and I did not run anything against the data. The drafts are unedited.

Main findings:
- **Pieces that do nothing:** The Undying Body raises a `regen_cap` that was removed. Heart of the Lotus and Unshakable Soul raise caps that no longer exist. Calcify reduces Chaos on a body shield, which Chaos never meets. Several minors target Fear or Stagger effects, which don't exist.
- **Rule contradictions without a `Needs rule` label:**
  - Haunt makes curses deal damage and outlive the fight.
  - Withering Hand fires on "a heal received", which is not an event.
  - Last Breath and Drink of the Springs fully block regeneration, which the 2026-11-10 dampening decision replaced.
  - Calming Scent runs 6 pulses, over the 5-pulse curse cap.
- **Unflagged key:** `status_duration_pct` (curse scope) is used by about nine nodes across 27, 30, 31 and 32, and it is not in the catalogue.
- **Dominant or no-cost pieces:** Eternal Return gives permanent buffs. The Huyết health-to-shield loop makes arts nearly free. Thể's capstone counts as top gear while every slot stays empty. White Bone Demon's close is already the rule, so it costs nothing.
- **Overlaps:** 27, 28 and 30 each have a Down-refusal major. 27, 30 and 35 each give permanent progress for winning at low health. 27, 33, 35 and 36 each scale a regen or shield by a sheet number.

REVIEW-DONE design/dao-ways/reviews/batch-27-37.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/dao-ways/reviews/batch-27-37.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/dao-ways/reviews/batch-27-37.md) instead (Edit rules cover all file-editing tools).
```
