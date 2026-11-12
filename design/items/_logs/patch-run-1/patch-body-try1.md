# Job transcript: patch-body (try 1)

I appended four items to `design/items/catalogue-body.json`, and the lint reports 14 items checked, 0 findings. The first 10 records are untouched.

| Item | Slot, grade | What it gives | Answers |
|---|---|---|---|
| Iron-Gate Armour (Thiết Môn Giáp), `body-iron-gate-armour` | armour (Giáp), 3 | A standing drain ward, the Common Ward scaled by 1.5: all 513.8 points, drain 0.492. 36.6 W of the 38.3 W budget. | deity-warden, starter-wall, ninth-bell |
| Ring of the Answering Stone (Ứng Thạch Giới), `body-stone-answer-ring` | ring (Nhẫn), 3 | New Effect Stone Answers: a free Physical hit worth 25 % of the damage a shield or ward stops, capped at 6 % of maximum health per pulse. 34.6 W. | mirror-hide (Return-channel Effect) |
| Pledge Anchor (Thệ Cốt Mao), `body-pledge-anchor` | weapon (Mao), 3 | The art Pledge Drop (Thệ Cốt Trầm): it pays 6 % of health, writes 3 Debt with no hit needed, and counts as a canon art. At 4 Debt it hits 3 times as hard and spends the Debt. 36.2 W. | mirror-hide (health-payment art), unique-mountain-splitting-axe (Debt without hits), unique-vajra-hide-armour (a canon art that reads Debt) |
| Pendant of the First Stand (Tiên Lập Bội), `body-first-stand-pendant` | necklace (Ngọc Bội), 2 | New Effect First Stand: the body shield starts the fight at 30 % of maximum health. 24.0 W of the 25.6 W budget. | unique-mountain-splitting-axe (shield held at 30 % at fight start) |

- **Drain ward type:** the ward is typed "all", not Physical. The only starter drain wards are Common, Fire and Force, so I took the Common Ward.
- **`notes` field:** the item record spec doesn't list `notes` as a field. I added it to each item as you asked and put the "Answers: <build>: <ask>" lines there, and the lint accepts it.
- **New Effects:** Stone Answers and First Stand are both marked "proposed; not yet in effects.md".
- **Asks left unanswered:** art-thief (a palm-scoped treasure that adds Drink), bare-fist (a driver for the basic punch), and burial-shroud (a body-guard or pierce piece).

PATCH-DONE body
