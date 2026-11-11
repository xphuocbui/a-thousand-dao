# Job transcript: family-ice (try 1)

I wrote seven Ice arts to `design/arts/family-ice.json` and the table to `design/arts/family-ice.md`. The lint prints `checked 7 arts in 1 files, 0 findings`.

I ran no fight with any of them. The lint only validates schema and numbers, so how they behave in play is untested. Three engine behaviours I took from the schema text still need a real fight to confirm: `own.state.<id>` as a readable, `consume` followed by `free_hit`, and `shield_broken` firing for the body shield. The c values are first guesses.

| Art | Shape |
|---|---|
| Cold Toll Seal (Hàn Toán Ấn) | Cost lock: each full 10 Ice stacks on the foe adds one Heavy Breath curse |
| Shatter Palm (Toái Băng Chưởng) | Cash-in: consumes the foe's Ice stacks for a cold hit per stack |
| Stilled Instant (Đình Thời Ấn) | Delays and Slowed Time: stacks add freeze time to the foe's art timers |
| Shattering Mantle (Toái Băng Giáp) | Shield as a weapon: bursts and lays Ice stacks when broken |
| Deep Winter Form (Thâm Đông Thế) | Stance: slower casting, more resistance, every hit lays Ice stacks |
| Sleet Volley (Tuyết Vũ Tiễn) | Charges and split hits |
| Black Ice Glaze (Huyền Băng Ấn) | Held payload: your next art also lays Exposed and Ice stacks |

It replaces the library's `frostbound-toll`, `leaking-seal`, `undertow` and `rime-mantle`; the four common Ice arts are untouched. The `.md` also lists which ideas from the replaced arts were dropped.

Engine pieces that could not be expressed:
- **Held payload:** it spends at the end of the firing that banks it, so it cannot target "your next art". Black Ice Glaze uses a one-slot counter instead; a `held` option that skips the current firing would fix it.
- **Heavy Breath cap:** the status stops at 2, so Cold Toll Seal gains nothing from Ice stacks past 20 except the stacks' own cost rise.
- **Stance suppression:** `suppress` takes art ids, not tags, so Deep Winter Form trades speed for resistance rather than suppressing non-Ice arts.

FAMILY-DONE design/arts/family-ice.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-ice.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-ice.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-ice.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-ice.md) instead (Edit rules cover all file-editing tools).
```
