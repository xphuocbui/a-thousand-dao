# Job transcript: patch-force-chaos (try 1)

I appended 4 items to `design/items/catalogue-force-chaos.json`, and the lint now reports 0 findings over 14 items. The first 10 records are unchanged.

| Item | Grade | Answers |
|---|---|---|
| Null Plate (Hư Giáp), a Giáp armour | 3 | art-thief: a heavier armour whose ward beats a Common Ward at ws 62.5. Its standing drain ward is the Common Ward at ×1.3 (445.25 points, drain 0.426). |
| Draining Signet (Hấp Khí Giới), a Nhẫn ring | 2 | art-thief: a Force-scoped ring with `attack_pct`. burial-shroud: a ring that raises Qi Disruption strength or the foe's linh lực drain. It carries the Spillover Effect and spends 92 % of the budget. |
| Ash-to-Void Pendant (Hôi Hư Bội), a Ngọc Bội necklace | 3 | triple-convert: a Fire-to-Chaos conversion piece (+40 % convert), and Chaos penetration on a necklace. |
| Seal of Foreclosure (Tịch Biên Ấn), an Ấn seal | 4, unique, with a `holder` | burial-shroud: a grade 4 Ruin Ledger weapon. The locket's ask for a grade 4 family weapon with health pay. Its art is Foreclose, a Ruin Ledger Scripture art. |

- **Foreclosure Seal health pay:** I wrote it as the `art_cost_health_pct` modifier, because the catalogues have no example of a health-pay art. The lint passes it, but check that this is how health pay should be expressed.
- **Sundered curse:** I did not cover the triple-convert ask for a Sundered-curse piece that strips Chaos resistance as a separate item. The Foreclosure Seal's art lays 1 Sundered, but nothing in this patch strips Chaos resistance beyond that.
- **No new Effects:** none were added.

PATCH-DONE force-chaos
