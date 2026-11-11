# Wood (Mộc) signature arts

8 authored arts, one mechanic shape each. `python -I tools/design/arts/lint_arts.py design/arts/family-wood.json`: 0 findings.
Commons (rot-seed, slow-rot, vine-lash, spring-sap, weeping-sap, venom-tithe) are unchanged and not repeated.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Harvest Bloom (Thu Hoạch Khai Hoa) | Build-up then cash-in (consume) | poison stacks, healing, free hits, chaos damage | Harvests up to 30 Poison from the foe; every 2 heal you and bloom as a Chaos hit. |
| Thornling Grove (Thích Linh Lâm) | Summon | summons, companion speed, poison stacks | Raises a Chaos Thornling (plus one per 15 Poison on the foe); each strike seeds Poison. |
| Rooted Form (Cắm Rễ Thế) | Stance / form | health regeneration, healing, wood buff stacks | Toggle: sturdier and healing more but 20 % slower; each pulse poisons the foe, more per 10 Wood stacks. |
| Bloodroot Pact (Huyết Căn Khế) | Paying with health | health cost, poison stacks, healing, leech | Costs 6 % health; Chaos ticks heal you in proportion to the Poison on the foe. |
| Seed of Spring (Xuân Chủng) | Held payload ("your next art") | wood buff stacks, healing, art speed | Plants up to 3 Seeds; the next art you land blooms them all into stacks and a heal. |
| Thorn Rain (Thích Vũ) | Split hits | crit, split, accuracy, art speed | 6 thorns, each lays 1 Poison and a crit thorn lays another. |
| Blight Canker (Hủ Căn) | Curse pattern | poison ticks, stagnation, curse duration | Chaos ticks on a stagnated foe add Stagnation; at 10 they add Withering. |
| Second Spring (Tái Xuân) | Echo / repeat, healing as a weapon | healing, heal arts, last art damage | Every 3rd heal from a healing art re-fires your last art at 40 %. |

## Library arts replaced
- `venom-drinking-root` -> Bloodroot Pact (same heal-from-Poison idea, now paid in health and scaling with stacks).
- `withering-touch` -> Blight Canker (a flat Withering hit became a curse that spreads itself).
- `banyan-shade` -> Second Spring (the refund heal became the echo engine; the 95 % guard is kept).
- `heartwood-spear` -> Harvest Bloom and Thorn Rain (the Poison-per-10 free hit split into a cash-in and a split hit).
- Kept as they are: `shedding-bark`, `bark-mantle`, `green-poultice` (not touched; Rooted Form covers the sturdy-healer gap).

## What the engine could not express
- **A true "next art" hold.** `held` banks and spends on the same event, so Seed of Spring uses a counter that is set
  after its own hit and spent by the next art hit (`filter kind art`). Missing: a `held` that skips the banking art, or a
  "not this art" filter. A basic attack never spends the Seeds only because the filter says `kind: art`.
- **Per-thorn crit.** Thorn Rain assumes each split sub-hit rolls crit and fires `hit_landed` itself; unverified in the engine.
- **Poison granted by Effects is not charged by the lint** (only `buff`/`debuff` fields are). Thorn Rain, Thornling Grove and
  Rooted Form grant stacks through Effects; their c_art was lowered by hand (Thorn Rain) to account for it. A lint that
  prices `stacks` actions is the missing piece.
- **Summons that scale with a readable.** `summon` takes a fixed `c`; Thornling Grove adds a second summon via `scale` instead of a
  stronger one, so many Thornlings accumulate (no summon cap).
- **Mods tagged `poison`.** No way to say "Poison ticks deal more" as a mod on tick damage (`tags` on `mod` only reach hits).
- **Cleanse-resistance / lock on Stagnation** (rule 16, R27) is not wired for Blight Canker; a foe cleanse removes the pattern.
