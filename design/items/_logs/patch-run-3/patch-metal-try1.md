# Job transcript: patch-metal (try 1)

I appended 5 items to `design/items/catalogue-metal.json`, and the lint now reports 0 findings. The first 10 records are untouched, and I edited only that file.

The only lint problem was on the needle. Its budget spend was too low and its art coefficient too high, so I raised the accuracy and cut the art's `c_art` to 0.85 (cost share 0.025).

| Item | Grade | Answers |
|---|---|---|
| Ironwall Plate (Thiết Bích Giáp) | 3 | armoury-mind, giant-killer, starter-blade, triple-convert, unique-heaven-purchasing-coin: a Metal armour with a standing drain ward. one-art: a plain Metal ward with no health spend. |
| Giantfall Ring (Đồ Cự Giới) | 2 | giant-killer: realm pierce, and more Metal stacks per hit. |
| Black-Nail Needle (Hắc Đinh Châm) | 2 | curse-engine: a curse-scoped weapon. status-collector: lays Sundered. |
| Clear-Mind Jade (Minh Tâm Ngọc Bội) | 1 | armoury-mind: a soul-defence necklace. |
| Armoury Banner (Binh Khí Kỳ) | 3 | armoury-mind: counts equipped weapon-base pieces. |

- **Ironwall ward:** it is a Common Ward scaled by 1.3 (all 445.3 points, drain 0.426, standing), and its `check_from` is the Common Ward. It is not typed to Metal, because the only typed starter drain ward is Fire.
- **Armoury Banner:** it carries one new Effect, Armoury Count (Binh Khí Kê), whose closing cost is that your wards are 15 % weaker. It is a strong-enabler item, so it spends about 70 % of its budget, with a note.
- **Budgets:** the other four items spend 80–100 % of their grade budget.
- **Not covered:** I left several asks unanswered:
  - the bow or spear weapon (there is no base for it);
  - the cleanse-on-a-clock bell;
  - the slow-time item;
  - the health-cost (Dear Blood) answer;
  - the Return-from-block armour;
  - the beat timer and Temper-count Effect;
  - the single-art coefficient ring;
  - the empty-slot scaling item.

PATCH-DONE metal
