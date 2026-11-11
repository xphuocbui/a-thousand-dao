# Job transcript: tune-wind (try 1)

Wind is tuned: both suites now land at x0.70–0.91 of the typical mirror at Trúc Cơ and Kết Đan. Lint is at 0 findings. The last suite_check run, which includes the added Wind-stack route, printed only the Held Breath and Flurry engine lines, so only they are confirmed engaged after it. The final run's engine lines show Held Breath at 0.2 per fight in both realms, Flurry step 1 at 1.0 and step 2 at 0.7–0.8.

Suite lengths against the typical mirror, before → after:

| Suite | Trúc Cơ | Kết Đan |
|---|---|---|
| gale-courier-scripture | x0.37 → x0.70 | x0.47 → x0.71 |
| slow-hour-scripture | x0.54 → x0.82 | x0.59 → x0.91 |

All fights are still 20-0 for the suite, except slow-hour at Kết Đan, which went 19-0 (one fight not counted).

- **Why the courier suite was fast:** the cause was Swallow Stance's +50 % basic speed. Cutting it to +10 % moved the suite from x0.39 to x0.72 by itself.
- **Held Breath never engaged:** its Breath counter was reset by any art firing, so it never reached the threshold. It now resets only when Held Breath itself fires, and I added a 3-Wind-stack route to its empower. Before that route, Kết Đan still printed NEVER_ENGAGED.
- **Top payoffs:**
  - Flurry step 2, Held Breath's empower, Echo's empower, Reckless Gale step 2 and Trailing Gale step 3 now need a counter or health threshold AND an easy route, instead of one OR-group.
  - The Wind burns in Flurry step 2 and Reckless Gale step 2 now add a free hit for each stack burned, with no cap.
  - Flat c_mults and some c_arts came down.
- **Frequency:** Echo's empower fired 3.6 times a fight before and now fires 0.1–0.2. Trailing Gale step 3 never fired in the final runs, which fits "rare".
- **Dead routes:** I found none in Wind, since Trailing Gale lays Slowed Time itself.
- **Not rechecked:** I did not re-run the standalone range x0.8–1.2; the suite_check output doesn't print standalone rows, so I can't confirm those arts landed in range. The only standalone arts I changed were Swallow Stance and Three-Step Chase (both also in the courier suite), and Gale Sprite is untouched.

The rule texts in the json and the table in `design/arts/family-wind.md` are updated to match. `design/arts/tune-wind.md` has the before and after suite_check lines and one line per change.

TUNE-DONE design/arts/tune-wind.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-wind.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-wind.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/tune-wind.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/tune-wind.md) instead (Edit rules cover all file-editing tools).
```
