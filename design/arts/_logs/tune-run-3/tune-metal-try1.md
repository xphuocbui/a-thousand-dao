# Job transcript: tune-metal (try 1)

The Metal family is mostly tuned. One target is still missed. The Hundred-Blades Canon at Trúc Cơ is x0.56, just under the 0.6 floor. I stopped there because slowing it further risked Sundering Wedge no longer engaging.

| Run | Before | After |
|---|---|---|
| Nine-Temper Scripture, Trúc Cơ / Kết Đan | x0.32 / x0.40 | x0.63 / x0.61 |
| Hundred-Blades Canon, Trúc Cơ / Kết Đan | x0.30 / x0.34 | x0.56 / x0.69 |
| Iron Hide Stance, Trúc Cơ / Kết Đan | x1.29 / x1.11 | x1.22 / x1.11 |

- **Engines:** Sundering Wedge, which never engaged before, now fires its first step in both realms. Every other engine art fires at least one step or empower. Their top payoffs fire about once per fight. The lint reports 0 findings.
- **Top payoffs:** Each now needs an AND-gate. Shatter-Edge Cleave and Flying Blade Retinue also consume up to 12 foe stacks (was 9 and 6), so a bigger stack means a bigger hit. Sundering Wedge's last step does the same.
- **Dead routes:** I removed the Temper routes from Sundering Wedge, because the Canon never builds Temper.
- **Iron Hide Stance:** Its W-L is still poor at 5-14 and 2-16. Both runs are inside the x0.8–1.2 band at Kết Đan, but Trúc Cơ at x1.22 sits just above it.
- **Cleanup:** My attempts to run helper scripts were blocked, so I made the edits by hand and deleted the temporary files afterward.

`design/arts/family-metal.md` has its table rows updated. `design/arts/tune-metal.md` has the before and after suite_check rows and one line per change.

TUNE-DONE design/arts/tune-metal.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-metal.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-metal.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/tune-metal.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/tune-metal.md) instead (Edit rules cover all file-editing tools).
```
