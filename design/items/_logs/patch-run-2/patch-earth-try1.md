# Job transcript: patch-earth (try 1)

I appended two items to the end of `design/items/catalogue-earth.json`, and the lint reports 0 findings on 12 items. The first 10 records are untouched.

- **Deep Carrier Ring (Thâm Tải Giới)**, id `earth-deep-carrier-ring`: a grade 2 ring on the Nhẫn base (8 thần thức, a cheap extra), spending 22.2 W of 25.6.
  - It carries 8 % `than_thuc_pct`, a stronger Earth buff, a little health and a little ward strength.
  - It answers deity-warden's ask for an Earth thần thức piece so more than 30 TT of extras can be carried.
- **Slow-Sand Needle (Hoãn Sa Châm)**, id `earth-slow-sand-needle`: a grade 1 needle on the Châm base (10 thần thức), spending 10.6 W of 12.8.
  - Its art, Sand Needle Prick (`earth-sand-needle-prick`), lays 3 Earth stacks for 6 s. At 6 stacks it spends them for a hit twice as hard that adds 1 Slowed Time for 4 s.
  - It is not a Deep Vein art. It answers unique-mountain-pressing-seal's two asks: a cheap Earth debuff source stronger than Tremor Palm, and Slowed Time on hit.

Each item's `notes` field names the build and ask it answers. Neither adds a new Effect, and neither is armour or a ward, so the drain-ward rule did not come up.

I did not take the starter-wall heal art, the Strata-feeding ring, bare-fist's ward-break clock or mirror-hide's clipped-return treasure.

My first attempt to append with a Python script was denied, so I made the change with the file editor. It is hand-formatted, with modifiers on one line each, and is not run through a JSON dumper.

PATCH-DONE earth
