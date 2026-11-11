# Job transcript: family-wood (try 1)

I wrote 8 Wood (Mộc) signature arts to `design/arts/family-wood.json`, and `python -I tools/design/arts/lint_arts.py design/arts/family-wood.json` prints 0 findings (8 arts checked; 5 engine, 3 standalone). I did not run any of these arts in a fight, so the new effects are only schema-checked.

- **Standalone (3):**
  - Rooted Form (Cắm Rễ Thế) is a stance.
  - Thorn Rain (Thích Vũ) splits into 6 thorns.
  - Bloodroot Pact (Huyết Căn Khế) is paid in health and repays itself against a heavily poisoned foe.
- **Engine (5):**
  - Seed of Spring (Xuân Chủng) holds a payload for your next art.
  - Harvest Bloom (Thu Hoạch Khai Hoa) cashes in Poison or Seeds.
  - Second Spring (Tái Xuân) is a stepped echo/heal.
  - Thornling Grove (Thích Linh Lâm) is a stepped summon.
  - Blight Canker (Hủ Căn) is a curse pattern.
- **Payoff:** every fully fed step or empower reports 3.0–3.5x the lint.
- **Feeding routes:** each engine art has at least two routes, through exclusive empower entries or OR-guards.
- **Suites:** `verdant-cycle-scripture` shares a Seed counter, and `rotting-canopy-canon` shares Poison and Stagnation pressure. Thornling Grove and Blight Canker also unlock when three canopy arts fire in one pulse.

`design/arts/family-wood.md` has the table with the Engine column, a short section per suite, the library arts replaced (`venom-drinking-root`, `withering-touch`, `banyan-shade`, `heartwood-spear`) and the engine gaps. The main ones:
- Every empower whose condition holds applies, so I made alternative routes exclusive by hand.
- It is unverified whether the `held` payload on Seed of Spring can be spent by the same art that banked it.
- The lint does not price stacks granted by effects, summons or free hits.
- There is no way to say "Poison ticks deal more", so I dropped Bloodroot Pact's low-health bonus.

FAMILY-DONE design/arts/family-wood.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-wood.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-wood.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-wood.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-wood.md) instead (Edit rules cover all file-editing tools).
```
