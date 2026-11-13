# Job transcript: content-items-metal (try 1)

I added two items to `design/items/catalogue-metal.json`, and the lint reports 0 findings. No existing record was changed, and no new Effects were needed.

1. **Ninth-Bell Ring (Cửu Chung Giới)** (`metal-ninth-bell-ring`) answers ninth-bell. It is a grade 2 ring on the Nhẫn base with +24 % `art_speed_pct` [kim], +10 % `khi_huyet_pct` and +6 % `linh_luc_pct`. It spends 21.6 W of 25.6 W (84 %).
2. **Earthbind Anchor (Phược Địa Mao)** (`metal-earthbind-anchor`) answers deity-warden. It is a grade 3 weapon on the Mao (anchor) base.
   - Its art, Earthbind Drop (Phược Địa Trầm), is a Metal Physical hit that lays 2 Earth debuff stacks for 8 s.
   - The modifiers are +16 % physical attack, +30 % stack duration and +20 % stack effect on Earth debuffs, plus +10 % `khi_huyet_pct` and +10 block. It spends 33.8 W of 38.3 W (88 %).

The anchor is a weapon rather than a ring, necklace or utility piece. The request allowed any Metal piece, and an art is the way an item lays stacks. Its Earth stacks come from a `hit_landed` effect on the art, the same pattern as the Hundred-Edge Flying Sword, since the art's own `debuff` field would lay Metal stacks. The lint's art checks accepted it.

CONTENT-DONE metal
