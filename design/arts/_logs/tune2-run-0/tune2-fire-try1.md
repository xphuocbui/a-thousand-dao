# Job transcript: tune2-fire (try 1)

Scorch Fist is stronger but still not at about even. Trúc Cơ went from 6-14 to 8-12 and Kết Đan from 5-15 to 5-14. The lint caps how much power the art can carry, so I stopped there. Lint is at 0 findings.

I changed only `scorch-fist`:
- **`c_art`:** 1.8 → 1.88, the most the lint allows with 2 Burn stacks for 5 s.
- **Conversion:** the Fire share went from 0.5 to 0.75. This made no difference in the fights.
- **Empower gate:** the full-Fire hit now needs 8 Burn stacks instead of 20.

Giving it 3 Burn stacks and `c_art` 2.3 reached 15-4, but the lint rejected it. A third stack or a longer Burn duration lowers the lint's `c_art` cap, so I reverted to 2 stacks for 5 s. I didn't chase the last few wins.

The fight lengths stayed in the standalone band (x1.14 at Trúc Cơ, x1.05 at Kết Đan). The Scorch Fist row in `design/arts/family-fire.md` is updated, and the before and after `suite_check` rows are in `design/arts/tune2-fire.md`.

TUNE-DONE design/arts/tune2-fire.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-fire.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-fire.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/tune2-fire.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/tune2-fire.md) instead (Edit rules cover all file-editing tools).
```
