# Job transcript: patch-thunder (try 1)

I appended three items to `design/items/catalogue-thunder.json`, and the lint reports 0 findings (13 items checked). I left the first 10 records alone. I couldn't run a script to write the JSON, so I added the three records by hand-editing the end of the list.

- **Winnings Band (Lôi Thắng Giới)** is a grade 3 ring on Nhẫn. It gives linh lực on crit plus Lightning crit chance, crit damage, art speed and damage. It uses 34.1 W of 38.3 W. It answers first-volley's ring ask, loaded-dice's Winnings and second-ring asks, and the Ninth Tribulation Seal's grade 3 Lightning ring ask.
- **Stormveil Robe (Lôi Mạc Bào)** is a grade 2 robe on Đạo Bào. Its ward is a standing drain ward, the Common Ward scaled by 1.3 to all 445.25 points and drain 0.4264, with `check_from` pointing at the Common Ward. It uses 24.5 W of 25.6 W and answers first-volley's ward armour ask.
- **Lightning Step Charm (Lôi Bộ Bội)** is a grade 2 necklace on Ngọc Bội. It carries the existing Cold Feet Effect, escape art speed, Lightning art speed and crit chance, evade, and linh lực regeneration. It uses 24.1 W of 25.6 W and answers first-volley's Lightning Step ask.

I added no new Effects and no unique items.

I did not cover these asks:
- First-volley's request for an item carrying the lost L2 Lightning more and L4 preparation.
- Loaded-dice's pre-filled crit and evade meter treasure.
- Loaded-dice's necklace that turns crits taken into stacks (Thunder Debt).

PATCH-DONE thunder
