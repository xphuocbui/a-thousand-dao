# Job transcript: family-earth (try 1)

I wrote seven Earth signature arts, and the lint finds nothing: `python -I tools/design/arts/lint_arts.py design/arts/family-earth.json` reports 7 arts checked, 0 findings. That only proves the schema and numbers pass. I haven't run any of these arts in a fight, so none of the mechanics are tested.

| Art | Shape |
|---|---|
| Strata Hammer (Tầng Nham Chùy) | Counter build-up, then cash-in |
| Mountain Stance (Trấn Sơn Thế) | Stance |
| Quarry Offering (Thạch Tế) | Paid in health |
| Sinking Weight (Trầm Trọng Ấn) | Slowed Time |
| Stone Warden Call (Thạch Vệ Triệu) | Summon |
| Aftershock Slam (Dư Chấn Kích) | Echo |
| Bastion Reprisal (Bích Lũy Báo) | Shield as a weapon |

They replace the authored Earth arts Mountain-Press Seal, Stone Rebuke, Iron Mountain Shield, Stone-Skin Seal and Bedrock Breath. The five Earth common arts and Mending Breath are untouched.

The unresolved engine questions are listed in `family-earth.md`:
- **Counter spend:** I assumed negative counter adds work. The Strata and tremor counters spend that way, and the order of two Effects on one event is unverified.
- **`dampen_taken` units:** the value 10 in the stance is a guess.
- **Stance `suppress`:** it is empty.
- **Echo:** `fire_art` repeats the last art's damage only, so Aftershock Slam's echo carries none of that art's stacks or statuses.
- **Shield-break burst:** it fires on any body shield of yours breaking, not just Bastion Reprisal's own.
- **Effect-granted stacks:** they are unpriced, so the lint does not charge them.

FAMILY-DONE design/arts/family-earth.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-earth.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-earth.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-earth.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-earth.md) instead (Edit rules cover all file-editing tools).
```
