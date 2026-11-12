# Job transcript: patch-soul-song-seal (try 1)

I appended 3 items to `design/items/catalogue-soul-song-seal.json`. The lint reports 0 findings on 13 items, and I did not touch the first 10 records. Each item has an "Answers:" line in its `notes`.

- **Toll-Counting Needle (Điểm Chung Châm)**, grade 2, Châm base. Its soul art adds a Toll on each soul hit. At 3 Tolls it fires an extra strike and spends them, with no Chord counter. It answers soul-lance's ask for a soul weapon on the Toll rhythm, and spends 22.0 of 25.6 W.
- **Seal-Bearer's Ring (Chấp Ấn Giới)**, grade 2, Nhẫn base. It gives +5 % thần thức and seal-scoped attack and art speed. It answers meta-hunter's seal-scoped ring and soul-lance's thần thức ring, and spends 20.9 of 25.6 W.
- **Clear-Mind Robe (Thanh Minh Bào)**, grade 2, Đạo Bào base. Its ward is Clear Heart Ward at 1.2 times payload, cleanse and reservation, with `check_from` pointing at the starter ward. It answers the cleanse asks from curse-engine and meta-hunter, and spends 22.0 of 25.6 W.

No new Effects were needed. The robe's cleanse is a ward feature, not an Effect that lays Sealed Meridian on the foe, so curse-engine's actual ask is only partly met. Three asks remain open: deity-warden's soul art for a Warden, the lost Lamp-Oil Siphon (linh lực back on a soul hit), and two-clocks' Twin-Wick Incense Clock.

PATCH-DONE soul-song-seal
