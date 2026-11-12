# Job transcript: patch-fire (try 1)

I appended 3 items to `design/items/catalogue-fire.json`, and the lint reports 0 findings on all 13 items. The first 10 records are untouched.

| Item | Grade and base | Answers |
|---|---|---|
| Cindersteel Mail (Tẫn Thiết Giáp), `fire-cinder-steel-mail` | 3, Giáp, 32.8 W of 38.3 | sect-ladder: a Fire armour with a standing drain ward. Its Cinder Veil is the Fire-Shunning Veil at 1.2 times payload and drain (Fire 360, drain 0.264). |
| Ring of the Fed Hearth (Dưỡng Lô Giới), `fire-hearth-ember-ring` | 2, Nhẫn, 24.7 W of 25.6 | sect-ladder: a grade 2–3 Fire ring that doesn't pay in health. starter-flame and two-clocks: Embers Feed the Hearth as an item Effect. |
| Long-Ember Censer (Trường Tàn Hương Lô), `fire-long-ember-censer` | 2, Hương Lô (10 thần thức), 21.3 W of 25.6 | beast-carry: a Fire-stack utility for the extra slots (+1 Fire buff stack per cast). sect-ladder: a treasure under 20 thần thức that makes Burn last longer. two-clocks: a second cheap extra. |

- **New Effect:** one, Embers Feed the Hearth, on the ring. Each Burn tick you deal returns 0.4 % of your maximum linh lực, at most 2 ticks a pulse. The brief didn't list it, so I wrote it inline as `"new": true`. Its status field says "proposed; not yet in effects.md".
- **Asks left open:** the Heat-keeping item for Furnace Heart, the cheap Burn weapon art, and the Physical-to-Fire conversion piece. Only 3 slots, so I took the asks most builds share.

I added the records with the Edit tool because a Python helper script I tried first was denied.

PATCH-DONE fire
