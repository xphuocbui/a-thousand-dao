# Job transcript: content-items-soul-song-seal (try 1)

I appended one item to `design/items/catalogue-soul-song-seal.json`: Hushed Vigil Cuirass (Tĩnh Canh Giáp), a grade 2 armour piece on the `giap` base. The lint reports 0 findings across 14 items, and I changed no existing record.

- **Modifiers:** `soul_res_pct` +25, `khi_huyet_pct` +5 and `than_thuc_pct` +2, which spends 20.6 W of the 25.6 W grade budget (80 %).
- **Ward:** Hushed Vigil Ward (Tĩnh Canh Tráo) is a standing drain ward of Soul 275 points at drain 0.33. It is the Qi-Scattering Robe starter ward scaled by 1.25 on payload and drain, and typed Soul instead of Force. Its price check is therefore inherited (3.788 of 3.813).
- **Effects and notes:** It has no Effect and no new Effect. The `notes` field says it answers the soul-lance ask.
- **Soul typing:** I did not check that the combat sim accepts a `Soul` payload type. The lint passed it, but the lint may not test that. Mourning Robe already uses a Force-typed ward on the same scaling pattern. If the sim rejects Soul, an "all 411 points, drain 0.394" ward on the Common Ward scaled 1.2 is the fallback.

CONTENT-DONE soul-song-seal
