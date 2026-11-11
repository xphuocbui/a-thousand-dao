# Job transcript: family-water (try 1)

I wrote both files and the lint passes: 8 Water signature arts, 0 findings. I did not run any of them on the fight engine, so the effects are schema-checked only.

Each art has its own mechanic shape:

| Art | Shape |
|---|---|
| Swelling Tide Palm (Doanh Triều Chưởng) | Build-up and cash-in with an uncapped Tide counter. At 5 or more Tide the palm breaks them all as free hits, one per Tide. |
| Marrow to Dew (Tủy Hóa Lộ) | Paid in health. 5 % health buys 20 % linh lực, and later heals return more. |
| Deep Lake Stance (Thâm Hồ Thế) | Stance. Faster regeneration, more healing and a Water stack every pulse, but 30 % less damage. |
| Gathering Wave (Tụ Ba) | Held payload. It banks up to 4 waves, and the next landed hit releases them. |
| Seep-Through Palm (Thấm Cốt Chưởng) | Conversion. Half Physical and half Water, plus a small speed-up to your other arts. |
| Backwash Seal (Hồi Lưu Ấn) | Echo. Every 3rd Water art repeats at half power and returns linh lực. |
| Drag of the Deep (Thâm Uyên Kéo) | Delay and Slowed Time curse. Linh lực returns in proportion to the foe's Slowed Time stacks. |
| Brimming Cup (Doanh Bôi) | Shield and overflow as a weapon. Overflowing linh lực and broken shields become free hits. |

Brimming Cup replaces Water Curtain, and Marrow to Dew and Deep Lake Stance together replace Ebb and Flow. Spring at the Well's Mouth, Drowning Palm and Ninth-Weight Lance are kept. I did not touch the common Water arts.

Points to check when the arts first run on the engine (also in `family-water.md`):
- **Counter reset:** Swelling Tide Palm relies on the counter's `set` not being multiplied by the `scale` factor.
- **Readables in `scale`:** the `foe.status.slowed_time` and `own.counter.tide` readables need to return stack counts inside `scale`.
- **Stance mod units:** I inferred the units of the stance's `mods` from the engine, because `content-formats.md` doesn't state them.

Missing engine pieces, also in the md:
- A tag-scoped `suppress`, so Deep Lake Stance suppresses nothing.
- A `split` that grows with a counter.
- A conversion into healing or linh lực.
- Companion heal targets for a Water summon, so this family has none.

FAMILY-DONE design/arts/family-water.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-water.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-water.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-water.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-water.md) instead (Edit rules cover all file-editing tools).
```
