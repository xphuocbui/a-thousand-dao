# Decisions 2026-11-26 (world-depth art)

- **Portrait style: xianxia v1** (user: "v1 is better"). It uses the XIANXIA_STYLE block (layered silk, embroidery,
  jade and silver, ethereal light, power where it suits) and per-sect xianxia dress sheets, with no automatic rank or
  realm lines. v2 added those lines and the rank uniforms; it made low realms plainer and was judged worse. Its
  code stays behind a flag (`rank_realm`), and its sheets are kept in `art/portraits/_unused-uniform-dress.json.bak`.
- Sect sameness and power still come through the dress sheet and the style block's "stronger for the stronger". The
  user's earlier ask (a sect's cast looks like one house; higher realms look more powerful) should be written into
  each sect's v1-style sheet and each prompt's clothing, without the separate lines.

# Decisions 2026-11-26 (implementation scope)

- **Everything goes into the game** (user: "please make sure to include everything, including the effects and items
  that are not in the game in the implementation"). It covers every proposal technique and its arts, every item, set
  bonus and Effect, the engine features they need (`builds/engine-wishes.md`, the duel readings), the beasts, and the
  new statuses, tags and modifier keys. Generated stand-in techniques are only a temporary step; they are not the end
  state. This answers the plan's old D2 question. Plan: `production/plans/world-depth-implementation.md` (Stages 4-6
  and the gap report's done condition).

# Decisions 2026-11-26 (implementation, Stages 0-1)

- **D3: promote records by sect**, Băng Tâm Các first (ADR-0009, accepted; saves refused on a `world_data_version`
  number, not the content hash).
- **The per-sect order:** each sect's pass designs its techniques, arts and Effects, runs the gap report for the
  engine words it needs, builds those in both fight engines with parity, then exports, loads and fights. Stage 5 up
  front builds only the features already known (`builds/engine-wishes.md`).
- **Review every sect:** the user reviews each sect's designed techniques, arts, Effects and items before it is
  exported.
- **Stand-ins:** each sect's Stage 6 pass picks its people's real techniques (the lineage method by rank where one
  fits, the method a note names, else a new technique for that sect).
- **Hidden events:** World Generation rule 5a wins. N-lang_dao-03, N-suong_tung-02, N-thai_chi-04 and N-van_hac-03 are
  the `hidden` kind (out of both tiers until uncovered), their page kind kept as `kind:` (the story kind).
  N-thoi_tinh-01 ("hidden in part") is split: a public quarrel line and a hidden N-thoi_tinh-01b (texts approved).
- **Ties:** `lover` is a soft friend tie started at a high strength; `former_master` / `former_disciple` are soft ties,
  friend by default, rival or enmity where the note says they parted badly (the pinned sư đồ is the current pair only).
- **Event Vietnamese text:** all 277 translated now, in batches on Sonnet; the user reviews at the end.
- **combat_library.json:** re-export now (the 2026-11-25 `song` tags on three bell arts), with the full test suite.

# Decisions 2026-11-26 (implementation, Stage 2: the seat moves)

- **Seat takes the province:** the province a new seat lies in becomes that sect's seat province: its seat place
  becomes the sect seat and its seat kind the great or minor seat; a wilderness province becomes a settlement province
  and gets the seat's starting buildings; the village or city stays a place inside it. A minor seat in a city's
  province (Yến Quang in Tang Ma Thành's `prov_p80`) is a vassal seat inside it: the city keeps the province, as Phần
  Vũ does under Phượng Minh.
- **Old seats become a new kind, `sect_hall`:** a sect's outer hall or court, held by the sect, settled like a town,
  its painting kept and retitled, a sect-hall map symbol.
- **The seat replaces the site:** a production site's good (vein, lair, forest) stays with the place as the seat's own
  site; ruins and peaks just become the seat.
- **Routes as data:** each page's routes are added as tracks (roads where the page says road) in the route data, not
  painted into `roads.png` or the map art yet.
- **Provinces runtime code:** done now in this work (the provinces session is not running), with tests, noted in
  `production/plans/provinces-runtime.md`.
- **GDD amendments first:** Travel & Map (the `sect_hall` kind) and Provinces (rule 2a for wilderness, village and city
  provinces) are drafted and shown before any building.
- **Băng Tâm's island seat:** place 214 lies on an island of the ice archipelago (every audit candidate does). Ruled:
  keep it, with a sea lane; the lane runs from Băng Khổng Thôn (1346), the nearest routed coastal place (Hàn Trạch
  Thôn, first named, is inland), plus a track to Hàn Giao Chử on the island. The export writes the lane's water tiles
  into the travel grid's lane layer so a player can sail it (the painted map and `roads.png` are not changed).
- **Founder's arrays re-sized** (Formula G on the seat kind): Hồng Đậu +0.10, Lê Hoa +0.20, Minh Loan 0 (a named
  record), Hàm Nguyệt +0.15, Lễ Tuyền +0.20, Bình Thủy +0.35; the Formula G table and the six pages updated.
- **AC-PV-01** amended to 472 settlement and 233 wilderness provinces.
- **The 12 unmoved minor seats** whose province's seat place is a village, town or nothing are fixed the same way (their
  province takes the minor seat as its seat place), in a separate commit with a census check.
- **Re-leans** (`seats.json`) go into the game's sect records with Stage 9 (admission and land-driven roots).
- **Sect-hall map symbol:** option 1 (a wide hall with a double roof behind a gate arch), style G, painted at low
  quality; the other symbols are unchanged.
- **Place and province text** for the 26 moved places and their provinces: rewritten now from the pages, shown as one
  table first. **Cast homes** of the three old-cast people the pages put at old halls wait for Stage 7.

# Decisions 2026-11-26 (implementation, Stage 3: the art)

- **Full resolution:** portraits are installed at the painted 1024x1536 and every place banner at the painted
  1536x864 (WebP quality 90), not 400x600 and 960x540 (user: "by high quality i mean high resolution").
- **Git LFS** for `assets/portraits/**/*.webp` and `assets/art/places/*.webp` (about 0.5 GB).
- **Godot import:** those two folders import as lossy WebP 0.9 with mipmaps (same resolution; the import cache and an
  exported build carry about 0.85 GB instead of 3.2 GB lossless). Easy to revert per file if lossless is wanted.

# Decisions 2026-11-26 (implementation, Stage 4: the GDD amendments)

- Amendments 1-3 approved one by one; 4-9 approved together ("i approve all now go"). The list is in the plan's Stage 4.
- The Formations rule 9 carve-out (`diagram_always`) is written by this work, since the formations session was not
  running.

# Decisions 2026-11-26 (combat redesign: no space, one side against one side)

- **No spatial fight** (user: "I don't want spatial fight"). Position readings are removed: range (At range), places
  ("inside / under your field"), knock-back (Displace, Displaced, Planted), Rooted and Pinned, field Pieces, spreads
  to "a nearby foe". The action readings stay under non-spatial names (user picked the names): **Composed** (Định Tâm; was Still:
  a composed stance, or 2 s with no damaging or movement art or evade), **Pressing** (Áp Công; was Moving: a pressing
  stance, or within 1 s of an evade or movement art) and **the foe pressed** (was "the foe moved": it fired a damaging
  or movement art, or evaded, in the last second). Broken and Wounded (health thresholds) stay. A Field stays as a
  plain timed self-state; a laid object becomes a self-counter charge with its own timer.
- **One side against one side** ("multiple ally or multiple enemies fight should be postponed for now"): allies
  counted, Alone, "every foe", several fighters or foes and spreads are postponed. **Companions and summons stay** as
  part of a fighter's side, as today.
- **Approach:** the GDDs are amended now (shown section by section), then a rewrite pass over the ~240 affected depth
  records before Stage 5 goes on.
- **Rewrite rulings** (user, 2026-11-26): records that only name allies or "alone" in passing are reworded to "you",
  "your companions" or "with no companion"; records **built on counting allies** are **parked** (kept unchanged,
  marked postponed, not exported). "Cannot flee" **stays** as a non-spatial curse, **Bound** (Phược Thân): the foe's
  escape fails while it holds; it replaces Pinned's escape failure and does not touch evade. **Spread** clauses are
  **cut**; a record left with no point gets a small payoff on the one foe. Checker:
  `tools/design/world/spatial_words_check.py` (239 records with a hit in a rule field on 2026-11-26).
