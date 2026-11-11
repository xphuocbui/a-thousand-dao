# Job transcript: tune-body (try 1)

The body family now lands in range on every suite and standalone art, and the lint is at 0 findings. The top steps fire less than the target of one or two a fight: the Marrow Tithe x11 step went from 0.8 per fight to none at Trúc Cơ, and the other top steps did not fire before or after.

**Suite check after tuning** (Trúc Cơ / Kết Đan, against the typical mirror)

| Art or suite | Before | After |
|---|---|---|
| Unbroken Flesh Canon | x0.62 / x0.75 | x0.71 / x0.75 |
| Hundred Echo Palm Scripture | x0.56 (fast) / x0.72 | x0.73 / x0.83 |
| Mountain Root Stance | x1.56 / x1.55 (slow) | x0.99 / x1.00 |
| Bone-Turning Palm | x0.76 / x0.84 | x0.81 / x0.86 |

- **Engagement:** every engine art still fires at least one step in its own suite.
- **Gates:** the four top steps (Marrow Tithe x11, Last Breath x6, Answering Palm x5, Barrage Rain) now need a real requirement AND an easy route, instead of one OR-group. Bulwark Knuckle's top step already had that shape.
- **Fast suite:** I lowered flat `c_art` and `c_mult` on Answering Palm and Rolling Barrage Fist to bring Hundred Echo out of the fast range. I also lowered Bone-Turning Palm's `c_art` to 2.3.
- **Mountain Root Stance:** it was slow, so I softened its defences and slowdown and raised its own hit to 1.0. The strike-back hit is also now 1.0 (was 0.45).
- **Not done:** I added no `consume` with `then` and `per`, because Debt, Ram and Tempo pay flat amounts. I removed no routes. I kept the Slowed Time route on the assumption that Ice carries it, which I did not check.

The Bash tool refused the multi-line script I wrote for the edits, so I applied them one at a time with the Edit tool. The suite rows in `tune-body.md` come from the run before the Mountain Root change; the Mountain Root rows come from the final run. Only those two rows changed in that final run.

The table in `design/arts/family-body.md` is updated for the new gates and numbers.

TUNE-DONE design/arts/tune-body.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-body.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-body.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/tune-body.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/tune-body.md) instead (Edit rules cover all file-editing tools).
```
