# Job transcript: patch-general (try 1)

I appended two items to `design/items/catalogue-general.json`. The lint reports 0 findings on all 12 items, and I didn't touch the first 10.

- **Long-Road Robe (Trường Lộ Bào)**: a grade 3 Đạo Bào, 6 thần thức, spending 35.4 W of 38.3 W. It has a `than_thuc_pct` modifier and a standing drain ward, the Common Ward scaled by 1.15 (394 points, drain 0.377, `check_from` the Common Ward). It answers bare-fist (a `than_thuc_pct` treasure), cooldown-floor (a cheap extra at 6 TT) and curse-engine (a ward armour that costs no art speed).
- **Lantern of Waking (Tỉnh Mộng Đăng)**: a grade 2 Đăng, spending 23.7 W of 25.6 W. It carries the existing Effect Cold Feet and a reserve art, Waking Light (12 % reserved, 11.8 W of its 12.0 W allowance). It answers soul-lance's ask for a cleanse or escape treasure, as an escape plus status-resistance piece. It has no actual cleanse, and I didn't add any new Effects.

I did not cover two of the six asks. Evade-dancer wanted a thần thức pendant to lift the extra limit, and loaded-dice wanted a payout piece that spends the crit meter on demand.

My first attempt, a Python script that appended both records, was denied by the sandbox. I made the same edit with the Edit tool instead.

PATCH-DONE general
