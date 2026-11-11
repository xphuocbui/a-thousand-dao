# Job transcript: tune-thunder (try 1)

Both Thunder suites now land at x0.61 to x0.70 of the typical mirror at both realms, and every engine art fires at least one step or empower. The lint is at 0 findings. The top steps of the Palm, Seal and Bind never fired in these typical-build runs, and the target of about once or twice a fight is not shown for them. Chain Arc's top step fires 0.9 per fight, and Peal's empower fires 2.1 to 2.9 per fight, above that target.

| Suite | Realm | Before | After | W-L after |
|---|---|---|---|---|
| Thousand-Bolt Scripture | Trúc Cơ | x0.39 | x0.61 | 18-2 |
| Thousand-Bolt Scripture | Kết Đan | x0.47 | x0.70 | 18-2 |
| Heavenly Tribulation Scripture | Trúc Cơ | x0.31 | x0.62 | 20-0 |
| Heavenly Tribulation Scripture | Kết Đan | x0.40 | x0.61 | 20-0 |

- **Heavenly engines:** before, Tribulation Seal and Thunderclap Bind never engaged. Their step 1 now opens, and their step 2 gates are two conditions each (one stack requirement AND an OR-group). Thunderclap Bind's old step-2 route needed 3 Slowed Time, which it can never lay (it lays 2); that route is gone.
- **Fixes to the Heavenly suite:** Stormcloud Familiar's summon strike and Storm Bank's damage ramp were what made that suite too fast, so I cut them hard (0.55 to 0.08 and 25 % to 2 %). The Seal's debuff stays at [4, 8].
- **Top payoffs:** Palm, Chain Arc, Peal, Seal and Bind top steps are now AND-gated and keep at least two feeding routes each. Flat multiples came down. I did not use `consume` with `then`/`per`.
- **Standalones:** Overload Form, Stormcloud Familiar and Storm Bank print no separate suite_check row, so I could not check them against x0.8 to x1.2. They are only checked inside the suite runs.
- **Docs:** the rule texts in the JSON and the table in `design/arts/family-thunder.md` match the new values. `design/arts/tune-thunder.md` has the before and after suite_check rows and one line per change.

TUNE-DONE design/arts/tune-thunder.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-thunder.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-thunder.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/tune-thunder.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/tune-thunder.md) instead (Edit rules cover all file-editing tools).
```
