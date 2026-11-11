# Job transcript: family-wood (try 1)

I wrote 8 Wood signature arts to `design/arts/family-wood.json`, one mechanic shape each. The lint reports `checked 8 arts in 1 files, 0 findings`. I did not run any art in a fight, so how the engine resolves a few of them is unchecked (listed below).

| Art | Shape |
|---|---|
| Harvest Bloom (Thu Hoạch Khai Hoa) | Cash-in: harvests up to 30 Poison from the foe, healing you and blooming as Chaos hits |
| Thornling Grove (Thích Linh Lâm) | Summon: a Chaos Thornling, with one more per 15 Poison on the foe |
| Rooted Form (Cắm Rễ Thế) | Stance: sturdier and healing more, 20 % slower, poisons the foe each pulse |
| Bloodroot Pact (Huyết Căn Khế) | Health cost: Chaos ticks heal you in proportion to the foe's Poison |
| Seed of Spring (Xuân Chủng) | Held payload: plants up to 3 Seeds, and your next art blooms them |
| Thorn Rain (Thích Vũ) | Split: 6 thorns, each laying Poison, crit thorns laying more |
| Blight Canker (Hủ Căn) | Curse pattern: Chaos ticks spread Stagnation, then Withering at 10 |
| Second Spring (Tái Xuân) | Echo: every 3rd healing-art heal re-fires your last art at 40 % |

`design/arts/family-wood.md` has the table, which library arts these replace, and the engine gaps.

Things the engine or lint couldn't express, or that I couldn't verify:
- **Held payload:** the engine's `held` spends on the same event it banks. Seed of Spring uses a counter instead, set after its own hit and spent by the next art hit.
- **Thorn Rain per-thorn crit:** I assumed each split sub-hit rolls crit and fires `hit_landed` on its own. I haven't confirmed that in the engine.
- **Stack pricing:** the lint only prices stacks on the `buff` and `debuff` fields, not stacks granted through Effects. I lowered Thorn Rain's `c_art` by hand to compensate.
- **Poison tick mods:** there is no modifier that makes Poison ticks deal more.
- **Stagnation lock:** Blight Canker has no cleanse lock on Stagnation, so a foe cleanse removes the pattern.

FAMILY-DONE design/arts/family-wood.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-wood.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-wood.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-wood.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-wood.md) instead (Edit rules cover all file-editing tools).
```
