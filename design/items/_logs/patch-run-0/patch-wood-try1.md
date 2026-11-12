# Job transcript: patch-wood (try 1)

I appended 4 items to `design/items/catalogue-wood.json`. The lint reports 0 findings on all 14 items. The first 10 records are untouched, since I added the new ones with an edit at the end of the list.

| Item | Grade | Answers |
|---|---|---|
| Venom-Drinker's Pendant (Ẩm Độc Bội), `wood-venom-drinker-pendant` | 3, Ngọc Bội | **two-clocks:** necklace with Poison duration and effect. **starter-venom:** Poison ticks leech health and linh lực, and a grade 3 piece at 10 thần thức. |
| Moss-Ledger Robe (Đài Tịch Bào), `wood-moss-ledger-robe` | 2, Đạo Bào | **starter-venom:** light armour with a cleanse-immunity window, via the new Effect Moss Ledger. |
| Packmate Collar (Bạn Thú Khuyên), `wood-packmate-collar` | 2, Nhẫn | **beast-carry:** companion damage, companion speed and the Pack Hunt hit filter. |
| Thorn-Seeding Ring (Chủng Cức Giới), `wood-thorn-seeding-ring` | 3, Nhẫn | **starter-venom:** a Wood ring that adds one Poison stack per art laid. |

- **Budgets:** the modifiers spend 22.2 to 34.2 W, which is 87 to 95 % of the grade budget, except the ring. It spends 32.0 W, about 84 %.
- **Ward:** the Moss-Ledger Robe's ward is a standing drain ward, the Common Ward at factor 0.8 (274 points, drain 0.2624). It is Common Ward-based and not typed to Wood.
- **New Effect:** Moss Ledger (Đài Sổ) is the only new one, within the limit of 2. It makes Poison stacks you lay uncleansable for their first 4 s.
- **Leech scope:** the pendant's leech modifiers are scoped to `over_time`, as the closest scope the lint accepts to "Poison ticks".

Asks left unanswered:
- a beast ward
- the Bonded Spirit timer feed
- Poison plus Stagnation in one item
- Surplus Life
- the Shedding Bark cleanser
- the low-health item

PATCH-DONE wood
