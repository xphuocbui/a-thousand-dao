# World depth in the running game: plan (2026-11-25, rewritten 2026-11-26)

**Status:** PLAN. The content review and its fixes are done. The art is painted (portraits in the xianxia style,
places in the grand style). Stage 0 is next.

**Asked:**
- the user, 2026-11-25: "before the implementation work, could you please first mark down the plan, then before the
  plan execution, do a full review of the casts, events, builds that we did tonight, content-wise".
- the user, 2026-11-26: "please make sure to include everything, including the effects and items that are not in the
  game in the implementation".

**The 2026-11-26 ruling, which shapes this plan.** Everything the world-depth content names goes into the game:
- every proposal technique and its arts;
- every item, set bonus and Effect;
- every engine feature those Effects need (`builds/engine-wishes.md`, the duel readings);
- the beasts, the new statuses, tags and modifier keys.

Stand-in techniques (`<hoang|huyen|dia|thien>_<element>`) are allowed only as a temporary step while stages land. They
are not an end state: the plan is done only when the gap report (Stage 1) shows zero stand-ins and zero unwired
records. This answers the old D2 question. Recorded in `design/world/depth/DECISIONS-2026-11-26.md`.

**Design:** the GDDs were amended on 2026-11-25 from the user's rulings in `design/world/depth/DECISIONS-2026-11-25.md`,
groups 1-12:
- Linh Căn rule 2, Formulas A2 and D4;
- Provinces rules 2a and 3a;
- Sects rules 3a, 19b, 20b-20d and F20-F22;
- World Generation rules 3a, 5, 5a, 6, 6a, 8a, 16, 16a and Formulas E, F and G;
- NPC Traits (v2) and its catalogue;
- Item Database rules 20f, 20g and 22, and Formulas J;
- Combat rules 25 and 26, and Formulas L;
- Effects rules 17-19.

The content is in `design/world/depth/` (`SUMMARY-2026-11-25.md`).

## Start here (for a new session)

1. **Read, in order:**
   - this plan;
   - `design/world/depth/README.md` and `SUMMARY-2026-11-25.md` (what the content is);
   - `design/world/depth/DECISIONS-2026-11-25.md` groups 1-14, and `DECISIONS-2026-11-26.md` (every user ruling);
   - `design/world/depth/schema.md` (record fields);
   - `design/world/depth/builds/README.md`, `engine-wishes.md`, `duel-readings.md` and `authored/WIRED.md` (what
     the builds need from the engine, and what is still open);
   - `design/world/depth/art/README.md` (the art method), only for Stage 3.
2. **Checkers to keep green:**
   - `python -I tools/design/world/depth_check.py` (content: roots, admission, bands, opposite traits, routes, ties);
   - `python -I tools/design/world/art_prompt_check.py`, for the `x-*` batches only.
     - The `p*` batches are superseded by the xianxia rewrite (`x-*`). Their flags, such as p07, are not yours.
     - The 14 flags left on `x-*/demo.json` are the user-approved demo prompts, so leave them.
   - the game suites: `tools/run-tests-parallel.sh` (memory: the parallel runner, with integration and parity) and the
     smoke check;
   - the exporters' `--check` modes: `export_named.py`, `export_techniques.py` and `export_combat_library.py`.
3. **Commits so far (all on main, not pushed):**
   - 7a5d139f: the content and GDD amendments;
   - 4f89c796: the Phất Y rename and the builds folder;
   - 5ababc91: story pass B;
   - 4f5305a2: depth and tone;
   - 251d240e: the art prompts;
   - e2ce0d41 and 65d2f3fa: the prompt fixes and this plan's first version;
   - the xianxia art pass: see `production/session-state/active.md` (the content session commits it).
4. **Rules that bind this work** (from the user's memory rules):
   - **Commit only your own paths** (`git commit -- <paths>`). Another session owns the "Formation teaching" bullet in
     `design/gdd/sects.md`, so never stage that hunk. The formations session owns `formations.md`, and the provinces
     session owns the provinces runtime code.
   - **Both engines.** Every fight feature and every Effect lands in GDScript (`src/gameplay/combat/fight/`) and in
     `tools/design/combat_sim/fight.py`, with the parity tests green.
   - **Effects are hand-designed and unpriced.** No W price and no price check until the game is finished.
   - **Bulk authoring.** About 50 records per batch, the checker handed over up front, all rules in one list, an early
     content read, and "rewrite", never "expand". Batch subagents use model `sonnet`.
   - **No environment conditions** in fight rules (terrain, biome, weather, place). **Scale without caps:** a cost or
     a decay bounds a piece, not a cap.
   - **Run and observe:** every player-visible change is launched and kept as a screenshot in `production/qa/evidence/`.
     Warn the user before a batch of Godot windows, use `--shots` and the cached test world, and keep ratings off in
     test runs.
   - **Missing art** shows PlaceholderArt (magenta stripes), never a stand-in that looks finished.
   - **GDD edits go to the user** section by section; the user approves each one.

## Where things stand (updated 2026-11-26)

- **Content:**
  - 1,891 people (1,748 living) in 50 sects and 6 outside groups;
  - 490 items in 166 sets;
  - 180 proposal techniques with 331 new arts;
  - 21 named beasts;
  - about 264 new dated events;
  - 435 hand-picked Đạo Đồ routes.

  `depth_check.py` reports no findings.
- **Keys renamed during the fixes**, so the export must use the new keys:
  - `thach_tang_danh` became `thang_vo_ta`, already changed in `assets/data` too;
  - the founder `quach_vo_tich` became `quach_linh_thu`;
  - `ta_bat_luu` became `cat_da_binh`;
  - Thải Chi's five Nghiêm herb names became `nghiem_kim_ngan`, `nghiem_bac_ha`, `nghiem_ha_kho`, `nghiem_hoi_huong`
    and `nghiem_ngu_vi`.
- **People:**
  - **new:** `ha_tinh_can` (Cốc Vũ, tier B) and `mac_thang_kieu` (Tùng Đào, tier C, held in Lô Niệm Ca's cellar);
  - **removed:** none;
  - **kept from `world_history.json`, not in the depth content:** 18 dead founders and last heads of fallen sects:

    | Sect | People |
    |---|---|
    | khong_son | bui_loc_trai, thoi_bat_kien |
    | xich_thanh | chu_liet_nhat, ton_ha_khoi |
    | cuu_thieu | co_phuong_nghi, lac_thieu_am |
    | lac_anh | dao_tan_phan, diep_phi_hong, khuong_vong_nguyet |
    | co_pham | giang_bich_khong, ma_vien_anh |
    | pha_quan | ha_lang_tinh |
    | khai_loi | hau_xuan_loi, ly_thien_co |
    | ho_thien | khuc_ho_gia |
    | han_giang | lieu_co_chu, lieu_thoa_lap |
    | thon_hai | o_kinh_hai |

    The merge must keep them.
- **Chronicle data already changed in `assets/data/world_history.json`** (user approved):
  - A225's text: the Phất Y founding, with no poem;
  - C023: Lôi Vô Danh dies of the miasma.
- **Game data otherwise unchanged.** `world_history.json` still holds the old 106 people and 54 authored builds. Only
  `world_cultivators_min` (5000) and the two chronicle texts have changed.
- **Art** (DECISIONS group 14; style in DECISIONS-2026-11-26):
  - **Portraits:** one per authored person, in the xianxia style, painted at low quality.
    - Prompts: `design/world/depth/art/portraits/x-<group>/*.json` (1,909 people: the 1,891 authored, plus the 18
      fallen-sect people in `x-fallen`). The five authored people added late (`ha_tinh_can`, `mac_thang_kieu`,
      `thang_vo_ta`, `cao_sa_lang`, `nhan_du_ti`) are in `x-late`.
    - Images: `tools/asset-pipeline/portraits/out/authored/x-<group>/<key>.png`, outside git. All 1,909 were painted
      and verified on 2026-11-26. One prompt (`quan_anh_ho`) was softened after a safety refusal; her story stays in
      her record.
  - **Places:** 311 story-site pictures in `design/world/depth/art/places/out/<batch>/`, outside git, painted before
    the xianxia change. The user keeps them as they are for now (2026-11-26).
  - **Beasts:** the 21 beasts have no picture and show PlaceholderArt until the user asks for them.
  - **Gallery:** https://claude.ai/artifact/H45zDrK7quF8PusDZGKAPE (version 5: all 1,909 xianxia portraits and the
    311 places). Its build script sits in the content session's scratchpad. The install in Stage 3 reads the pngs,
    not the gallery.

## The gap: what the content names that the game does not have (measured 2026-11-26)

Stage 1's gap report (`depth_gap.py`) replaces these counts with exact lists. **Since 2026-11-26 the live numbers
are `python -I tools/design/world/depth_gap.py`** (Stage 1 progress has the first run). The table below is the
earlier hand count, kept for where each kind lives.

| What | Count | Where it is | State |
|---|---|---|---|
| Proposal techniques | 180 (49 Yellow, 80 Profound, 44 Earth, 7 Heaven; 98 main, 79 secret, 3 body) | `**/*.techniques.json` | Prose `concept`. 4 carry catalogue-form `abilities` or `effects`. None are in `items_cong_phap.json`. |
| New arts | 331 | the techniques' `arts` dicts | 11 point to a DSL record in `builds/authored/auth-tech.json`, and 24 to an Effect in `auth-eff-*.json`. The rest (about 296) are a name and a concept only. |
| Existing art references | 83 (50 distinct) | the techniques' `arts` strings | All 50 are in `combat_library.json`. |
| Items | 490 (432 artifacts, 58 treasures) | `**/*.items.json` | Not in `items_named.json` or `combat_library.json`. 2 items have no `base`. |
| Item Effects | about 170 on 163 items | `items[].effects` | Rule text (`{id, name, rule}`), no engine records. |
| Sets | 166 | `items.json` `sets` | Not in the game. 2-piece and 3-piece Modifiers are plain lines; 165 full-set Effects are rule text. |
| Authored wishes | 94 entries | `builds/authored/auth-mod/eff-1/eff-2/tech.json` | Have DSL records or modifier lines, wired into the depth files (`WIRED.md`). Not in `combat_effects.json`. 2 were refused and 2 not authored. |
| Engine features | about 30 | `builds/engine-wishes.md` sections 1-5 | Fight-state actions, readables and events, statuses, tags, Art DSL words and checks. Several may already exist (see Stage 5). |
| Duel readings | 5 kept (rewritten 2026-11-26: no spatial fight) | Combat rule 25, Formulas L | Composed, Pressing, the foe pressed, Broken, Wounded, plus the Bound curse. At range, Displace, Rooted, Pinned, field Pieces, spreads removed; allies and Alone postponed. Not in code. |
| Statuses | Charmed, Drunk, Sleep | `engine-wishes.md` section 3 | Not in the Effects GDD Status Catalogue or the engine's `STATUS`. |
| Elements and parts | Light dtype, `soul_part` 30 % on a Light hit | `dawn-call` | The engine's `ELEM_TYPE` has no `light`. |
| Tags | `song`, `bow`, `fan`, `mist`, `crane`, `bird`, `talisman` (source tag) | depth arts, items and beasts | `song` and `bow` need the `modifiers.md` rule 9 amendment. The rest need engine support. |
| Modifier keys, candidates | about 12 non-fight or new keys | items, sets and passives | Candidates: `dan_doc_resist_pct`, `curse_effect_pct`, `pill_effect_pct`, `dao_tam`, `can_cot`, `khi_van`, `cultivation_speed_pct`, `breakthrough_chance`, `herb_growth_pct`, `element_affinity_pct`, `artifact_attack_pct`, and `companion_power_pct` / `companion_speed_pct` (refused, b13). Whether the game reads each one is unconfirmed; the gap report decides. |
| Beasts | 21 | `**/*.beasts.json` | Named beasts in the game's Character form (`is_beast`, `owner_id`, `loyalty`, `tags`, `combat`, `bond`). Not in the game. |
| Ties | 25 kinds | cast `ties` | Map to the game's kinds (Stage 1). 18 people are over the 16 cap. |
| Đạo Đồ routes | 435, plus a `lineage.tree_route` per sect | cast `build.tree` | Hand-picked notables. They must reach the game's allocation. |
| Events | about 264 `N-` events | `sects/*.md` prose | Not structured (Stage 1). |

## Stages

### Stage 0: decisions and one ADR
- **D1:** DONE. Checkpoints committed.
- **ADR-0009: the world-depth export.** ACCEPTED 2026-11-26 (user): `docs/architecture/adr-0009-world-depth-export.md`.
  It covers:
  - the two routes: world content through `export_world.py`; records promoted into the design catalogues
    (`catalogue-sect-<key>.json`, `part-sect-<key>.json`, `sets-<key>.json`) and the existing exporters, with Effects
    written into `combat_effects.json` as today. There is no second exporter for records.
  - the merge: the depth record wins on every field it carries; the 18 fallen-sect people come from the old cast;
    the depth builds already hold all 54 old builds' targets (18 the same, 36 changed in the depth pass).
  - the save check: a `world_data_version` **integer** (user 2026-11-26), raised only on a break; `load_dict`
    refuses a save with another value. Today `data_version` is recorded but never compared.
  - the stand-in rule: explicit `wants` beside a stand-in, counted by the gap report; `_learn` warns.
- **D2:** ANSWERED by the 2026-11-26 ruling: no stand-ins at the end.
- **D3:** ANSWERED (user 2026-11-26): **by sect**. Băng Tâm Các first.
- **Sources first (found 2026-11-26).** DONE 2026-11-26. A fresh `export_world.py` run differed from the committed
  `world_history.json` in A225 and C023: the approved texts (story pass B, 5ababc91) were edited in `assets/data` only.
  Both are now in their sources (A225 in `annals_proposal.json`, C023 in `chronicle_proposal.json`), and a fresh
  export equals the file apart from `data_version`. From now on, never edit `world_history.json` by hand.

### Stage 1: structure the export, and the gap report (tools only)

**Progress 2026-11-26:**
- DONE: `tools/design/world/depth_gap.py`. It gives each record a state (rule text, engine form, structured,
  catalogue, game, runs, clash); only "runs" closes (techniques, items, sets and beasts at "game", since their lines
  and Effects are their own rows, read from the game record once promoted). Fight verdicts come from fight.py's own
  compilers; a scope tag no library art carries stays open. It lists by owner and cross-owner references (`--sect`,
  `--list`, `--json`). First run: 180 techniques, 331 new arts (11 engine form), 490 items, 166 sets, 381 open
  Effects (1 clash: Still Water), 4 Effect names shared by several records, 75 open modifier lines of 2,394, 21 beasts,
  276 events (structured, not yet in the game), 184 stand-ins (none names its wanted technique in a field), 39
  cross-owner references, 16 people over the 16-tie cap (distinct partners), 47 engine words, 4 open wishes, 0
  unknown ids. Băng Tâm Các's slice: 4 techniques, 9 new arts, 23 items, 9 sets, 11 Effects, 2 beasts, 5 events, 6
  stand-ins, 104 lines that all run.
- DONE: the seat table, `tools/design/world/depth_seats.py` → `design/world/depth/seats.json`. 50 sects read, 13 seats
  move, 11 no-lean, all pass Formula F (Wind exempt). `depth_check.py` runs it and reports a stale file or a failing
  seat.
- DONE 2026-11-26: the events, `tools/design/world/depth_events.py` → `design/world/depth/events/
  <owner>.events.json`. 277 events in 56 owners (landmark 39, annals 233, hidden kind 5; secret 34, from the header
  flag, a "(hidden" after the text, or a timeline row marking its bold id). People, sects and place are matched by name
  as proposals, then confirmed and corrected by the translation pass, which wrote `text_vi` for all 277 in six Sonnet
  batches (`design/world/depth/_brief-event-translation.md`; `text_vi_of` catches a later rewrite). Coined names and
  judgement calls for the user's end review: `design/world/depth/review/event-translation-names.md`.
- DONE in the gap report (`TIE_MAP`, user rulings 2026-11-26): the tie mapping; no kind is unmapped. Every authored
  person is notable in the game (cap 16); partners are counted once; a feud is pinned.
- RULED 2026-11-26 (`DECISIONS-2026-11-26.md`, Stages 0-1): the four `hidden`-kind events follow rule 5a (pages
  now `hidden`, kind kept); N-thoi_tinh-01 split into a public line and hidden N-thoi_tinh-01b (277 events); `lover`
  is a high-strength soft friend tie; former masters are soft ties; stand-ins are picked per sect in Stage 6; all 277
  events are translated now on Sonnet; `combat_library.json` is re-exported now.
- OPEN: the trait trim (rule 2a's order is fully stated; it lands in the export, Stage 7), the export fields, the
  Đạo Đồ route rule.

- **The gap report,** `tools/design/world/depth_gap.py` (observations only). For every build, person, item, set,
  technique, art and beast it lists:
  - stand-in techniques;
  - technique, art, item, Effect and beast ids the game does not have;
  - modifier keys that nothing in the game consumes (stat sheet, fight compiler, cultivation, crafting);
  - Effects with rule text but no engine record;
  - engine words (events, actions, statuses, tags) that the records use and the engine lacks.

  **Done condition for the whole plan:** every list is empty.
- **The 264 `N-` events** become structured JSON (id, year, kind, tier, people, place, text). This also feeds the
  review's timeline check.
- **Seats:** a machine-readable table of the final seat and leans per sect (World Generation OQ 12). Add Formula F on
  the final seats, with the Wind exemption, to `depth_check.py`.
- **Tie kinds:** a mapping table from the 25 kinds to the game's kinds.
  - kin covers parent, child, sibling, cousin, grandparent, grandchild, aunt_uncle, niece_nephew, in_law, ancestor and
    descendant;
  - su_do covers master, disciple and the former pair;
  - ket_nghia covers sworn_sibling;
  - dao_lu covers dao_partner and spouse;
  - lover is soft.

  Overflow is checked against rule 5's authored exception.
- **The trait trim** for over-band people (NPC Traits rule 2a). The first count was 30 people and 36 traits; pass C
  added about 21 tier B and 20 tier C people one trait over their band.
- **Fields the export carries:**
  - `appearance` for every tier;
  - `wants` and `secret` for tier B;
  - talent flaws, with `thien_phu` to match;
  - `beasts` on tamers, with the records from `**/*.beasts.json`.

  `changed` notes are design-only and are not exported.
- **Đạo Đồ routes:** how a route's notables (and the sect's `lineage.tree_route`) become the game's allocation. Use
  the BuildGenerator path where it fits, with the authored notables pinned.

### Stage 2: the map (seats move)
- **`world_continent.json`:**
  - each moved seat place becomes `great_seat` / `minor_seat` with the sect's key;
  - the old seat becomes the kind its page names;
  - routes to the new seats, and `seat_array_density` on them;
  - province seat records (Provinces rule 2a);
  - place lore lines.
- **Code effects named by the provinces session:** `ProvinceBuildings.payer` and `place_start`'s seat-province test
  (Provinces OQ 11). Re-run the starting-level census.
- **Art:** moved seats show PlaceholderArt until painted (low quality by default).

**Progress 2026-11-26** (rulings in `design/world/depth/DECISIONS-2026-11-26.md`, Stage 2):
- GDD amendments written (user-approved): Travel & Map rule 6 "Sect halls" and its kind tables; Provinces rule 2a
  extended to wilderness, village and city provinces, same-province and lake moves, and the old seat's province.
- `design/map/continent-11/seat_moves.json` (user-approved names): the 13 moves, years, old-seat names, founder's arrays
  (Formula G), page routes and `events_at_old`. `export_continent.py` applies it (new seat = great/minor seat under the
  seat's names, `former_name` and `site_kind` kept; old seat = `sect_hall`), measures the routes on the land (lakes
  crossable; a sea lane on the water) and links any seat still off the network; sect records carry `seat_moved`,
  `seat_array_density`, `seat_array`. Pipeline: export, `land_qi.py --no-bin`, export, `province_stats_v2.py`,
  `export_world.py`.
- **Băng Tâm's 214 is an island** of the ice archipelago (every audit candidate is): ruled to keep it with a sea lane
  from Băng Khổng Thôn (1346), the nearest routed coastal place, and a track to Hàn Giao Chử; page §2 updated.
- Chronicle: an event naming a moved seat resolves to the old seat before the move year, and to it always when the
  page keeps it there (`events_at_old`: A013, A015, A109, A110, A278, A279); only C175 and A125 move to Băng Tâm's new
  seat. Living cast homes follow the seat; three the pages put at the old hall (Quan Vũ Thanh, Vu Ngô Đồng, Lệ Tiêu
  Hồn) wait for Stage 7's depth homes.
- Code: `sect_hall` in every kind table (data and `continent_data`, `map_view`, `province_window`); the founder's array
  as a permanent layer-2 work in `MapWorks.density` (`qi.seat_array`, 0 when broken); a seat keeps its production site
  (`site_kind`); `ProvinceBuildings.payer` takes a great seat at the seat place. Tests: `tests/unit/world/
  seat_moves_test.gd` (8, AC-WG-52 included).
- `map_version` hashes only the grid and qi bins, so it does not change; old saves keep their own places until Stage
  7's `world_data_version` refuses them.
- Checked 2026-11-26: full suite green (1,105); census flat over three seeds (year 200 mean Kết Đan 248 → 249,
  Nguyên Anh 42 → 44, Hóa Thần 5 → 4); every seat compared old against new (`place_start` now seats a great and a minor
  sect in one province, so Phượng Minh keeps its seat halls; a lane's water tiles join the travel grid so the island
  seat can be left; six minor arrays re-sized by Formula G on the seat kind). Lạc Hà's old seat drew a hidden blessed
  land (+0.8) in seed 4242: a per-game roll that stays with the hall, outside Formula G. Screenshots:
  `production/qa/evidence/world-depth-stage2/`.
- DONE 2026-11-26: the sect-hall map symbol (user pick, option 1 of `tools/asset-pipeline/map/symbols/sheet-sect-hall.png`,
  gpt-image-2 low; cut by `cut_symbols.py` into `assets/map/symbols/sect_hall.png`).
- DONE 2026-11-26: the 26 moved places' look and lore and 23 provinces' lore (user-approved table:
  `design/world/depth/review/moved-text-2026-11-26.md`), written into the catalogue packs
  (`design/world/place_catalogue/pack_*.json`, merged by `place_catalogue_check.py`) and the provinces-v2 lore files.
  The catalogue check now counts a sect hall's sect record; its year notes on 12 entries (move years, page history)
  clear when Stage 7 exports the depth events.
- Open: new seats' banners until Stage 3; Băng Tâm's new seat (214) has fewer than 2 catalogue levels (it kept the
  ruin's); the three cast homes the pages put at the old hall (Stage 7);
  re-leans with Stage 9 (ruled). The 12 unmoved minor seats whose province was seated at a village, town or nothing
  are fixed in their own commit (ruled 2026-11-26).

### Stage 3: install the authored art
- **Portraits.**
  - Copy each `tools/asset-pipeline/portraits/out/authored/x-<group>/<key>.png` to `assets/portraits/cast/<key>.webp`
    at 400x600, as `gen_portraits.install` does.
  - The `x-*` batches are the only source. The old `p*` and `pilot` batches are superseded.
  - This replaces the old cast portraits, including the 18 fallen-sect people once they are repainted.
  - Rebuild `assets/portraits/portraits.json`; its `cast` list must hold every authored key.
  - A key without a picture keeps PlaceholderArt.
- **Places.**
  - Copy each `places/out/<batch>/paint_<id>.png` to `assets/art/places/<id>.webp`, the window banner, at 1536x864
    for seats and 960x540 for the rest (as `tools/asset-pipeline/places/install_place_paintings.py` does).
  - Replace the old 254 banners. If the user orders a xianxia place repaint, install that instead.
  - The map's miniatures (`assets/map/places/`) are NOT changed.
- **Check:** open the character window and a sect window, and keep screenshots in `production/qa/evidence/`. Measure
  the import size; about 1,900 webp portraits come to about 60 MB.

**Progress 2026-11-26** (rulings in `DECISIONS-2026-11-26.md`, Stage 3):
- Portraits: `tools/asset-pipeline/portraits/install_authored.py` installs the 1,909 `x-*` portraits (the four
  `x-pilot` ones included) at the painted 1024x1536, WebP 90, 404 MB; `portraits.json` cast lists all 1,909.
- Places: `tools/asset-pipeline/places/install_place_paintings.py` now installs the world-depth paintings (batches l1-l3,
  311 places, all 254 earlier banners replaced) at 1536x864, WebP 90, 134 MB. The map miniatures are unchanged.
- Both folders in Git LFS; imported as lossy WebP 0.9 with mipmaps (845 MB import cache).
- Evidence: `production/qa/evidence/world-depth-stage3/01-bang-tam-sect-window-*.png` (1600x900 and 2560x1440).

### Stage 4: the GDD amendments (each one to the user, section by section)
The features in Stage 5 need these rules first. Another session edits `design/gdd/`, so stage only your own hunks.
- **Effects GDD:**
  - Status Catalogue rows Charmed, Drunk and Sleep (d34, d39, d40). Drunk has no stack cap; each stack runs its own 3
    pulses. Charmed and Sleep hold the caster.
  - The engine features of `engine-wishes.md` sections 1-3 that change a rule: held damage, delay immunity, tick to
    heal, stopping a side's clock, the caster-holding status, the diagram in an ambush, the overflow amount, upkeep per
    Piece, the lost-in-N-s readable, pill burn, the drained, healed and leech events, batch expiry, ward-absorbed, the
    Piece's laid hour, and failed escape.
- **Combat GDD:** Formulas C, the extended last act after Down and the double-knockout draw (`pine-wave-fifteenth-layer`).
- **Damage Types:** the Light element and dtype, and the R11 `soul_part` exception (`dawn-call`).
- **Modifier System:** rule 9 vocabulary for the `song` and `bow` form tags, plus `fan`, `mist`, the companion tags
  `crane` and `bird`, and the talisman source tag. Also every new modifier key the gap report finds unconsumed:
  `companion_power_pct` and `companion_speed_pct` (b13) unless they already exist, and the non-fight keys.
- **Formations:** rule 9's `diagram_always` carve-out. This is the formations session's file, so ask that session.
- **Art DSL** (the arts README or GDD): the `new_vocab` words of `engine-wishes.md` section 4.

**Progress 2026-11-26: DONE** (user approved each amendment; 4-9 approved together, "i approve all now go"):
1. Effects Status Catalogue: Charmed, Drunk, Sleep, and "Statuses that hold their caster" (`holds_caster`).
2. Effects rule 6: Hold damage, Delay immunity (`delay_immune`), Turn a tick into healing, Stop a side's clock,
   Upkeep on a self-counter.
3. Effects rules 5 and 6: the world-depth events and readables (`pill_burned`, `qi_drained`, `healed` and the heal
   event's `overflow`, `batch_expired`, `ward_absorbed`, `escape_failed`, lost in the last N s, a batch's laid hour);
   R20 amended so a batch expiring is an event; Burn a pill. Effects Open Question 14 answered.
4. Effects rule 9b: a stack or mark remembers its source (talisman cleanse skip); companions carry tags.
5. Effects rule 11 and Combat rule 10: the extended last act (`last_act_window`) and its double-knockout draw.
6. Damage Types rule 1: how an added Soul part is scoped (Light and R11 were already in).
7. Modifier System rule 9: `fan`, the companion-kind family (`crane`, `bird`), the three new status tags; every
   depth modifier key was already a Stat List row.
8. `tools/design/combat_sim/FIGHT-INPUT.md`: the world-depth DSL words (to build in Stage 5); Effects rule 12 and the
   Status Catalogue note the two exceptions (a meter kept between fights, a curse that takes no slot).
9. Formations rule 9: `diagram_always` (written by this work; the formations session was not running).

### Stage 5: the engine features (both engines, parity green)
- **2026-11-26, combat redesign** (`design/world/depth/DECISIONS-2026-11-26.md`): before slice 2, one rewrite pass
  moves the depth records off the removed and postponed readings (`tools/design/world/spatial_words_check.py`, 239
  records). Slice 1 is committed (4f9fc9a4). Remaining slices (rulings 2026-11-26): 2a statuses Bound, Off Guard,
  Charmed, Drunk, Sleep and the caster hold; 2b tick to heal and upkeep; 2c the extended last act (`last_act_window`,
  its own slice: it changes the defeat check); E escape (fleeing, Combat rule 10, Formulas I; neither engine has it);
  3 events and readables; 4 tags and Light; 5 the five kept readings (smaller than planned); 6 item sets; 7 the abode
  and vein removal; 8 the DSL words and the kept meter. Held damage is parked with A File of One. Estimate for the
  rest of Stage 5: about 20-26 h.
- **Order (user 2026-11-26):** this stage builds only the features already known (`engine-wishes.md`, the duel
  readings, sets, tags). Each sect's Stage 6 pass then builds the engine words its own designs need, in both engines
  with parity, before that sect is exported.
- **Verify first, then build only the gap.** The engine already lists `delay_immune` (MOD_KEYS), `last_act`,
  `store_damage`, `heal_restored`, `batch_ended`, `overflow` and others (`assets/data/combat_engine.json`). For each
  row of `engine-wishes.md`, record whether it exists, partly exists or is missing before writing code.
- **Build:**
  - `engine-wishes.md` sections 1-4, the actions, events, readables, statuses, tags and DSL words;
  - section 5's checks: the Bleed tags, the summon coefficient's `companion_power_pct`, and decay by a share;
  - the duel readings (Combat rule 25, Formulas L; **rewritten 2026-11-26**, no spatial fight, one side against one
    side): Composed and `composed_time`, Pressing, the foe pressed, Broken and Wounded, the Bound curse, and the
    companion share of strike payloads; self-counter charges with their own timers and blows;
  - removing the `own_abode` and `vein` fight bonuses (rule 26, AC-CB-104);
  - item sets: the set bonus counted on worn pieces (Item Database rule 22), in the stat sheet and the fight compiler;
  - companion tags and companion hit events carrying them (crane, bird);
  - the source tag on stacks and marks (talisman), and cleanse skipping it;
  - the pill slot read in a fight (`burn_pill`, `pill_burned`);
  - the counted-chance meter kept between fights (`playing-past-the-break`, an exception to Formulas A).
- **Every feature** gets a GdUnit test and a `fight.py` test, plus a parity case.

### Stage 6: the records (author, then promote through the existing exporters)
All in batches of about 50, the checker up front, **by sect** (D3), Băng Tâm Các first. Nothing here is priced.
- **Each sect's pass (user 2026-11-26):** design its techniques, arts, Effects, items, sets and beasts; pick its
  stand-ins' real techniques; run `depth_gap.py --sect <key>` for the engine words it needs; build those (Stage 5's
  rules); **show the user the sect's designs for review** (every sect, user 2026-11-26); then export, load and fight.
- **Techniques (180).** Promote each proposal into `design/techniques/catalogue-*.json` in the catalogue form:
  `bonuses`, `passives` (the fight lines), `abilities` with `unlock_layer`, and layers. Lint with
  `tools/design/arts/lint_techniques.py`. Then `export_techniques.py` writes them into `items_cong_phap.json`.
- **Arts (331 new).** Write a full art record for each concept-only art (about 296) in `design/arts/` form: DSL fields,
  tags and unlock layer. Take the 11 `auth-tech.json` records and the 24 Effect-backed passive arts as written. Lint
  with `lint_arts.py` and `suite_check.py`. Give ids to the lineage arts that have none (`where-the-drop-falls`,
  `line-through-the-ice`, `a-bite-on-the-line`).
- **Effects.** Write an engine record (as in `combat_effects.json`: `rule`, `records` with `on`, `filter` and `do`,
  plus `lines`) for:
  - about 170 item Effects;
  - 165 full-set Effects;
  - the technique and passive-art Effects.

  Bring the 94 authored wish records into `combat_effects.json`.
- **Items (490) and sets (166).** Promote into `design/items/catalogue-*.json`, with a new sets file for the sets.
  Give the 2 items with no `base` a base. Lint with `lint_items.py`; repair it first, since it imports the removed Đạo
  Đồ editor. Then `export_named.py` writes `items_named.json`, `export_combat_library.py` writes `combat_library.json`,
  and a new `items_sets.json` is exported.
- **Beasts (21).** The game's beast records, with owner, loyalty, tags, power share and bond (`creatures_linh_thu.json`
  rules), and each owner's `beasts` field.
- **Non-fight modifier keys.** Each key the gap report finds unconsumed gets a reader: cultivation speed and
  breakthrough chance, herb growth, pill effect, curse effect, the talent and dao_tam lines, and the Đan Độc and Tâm Ma
  resists. Each gets a unit test.
- **The open items from `WIRED.md`**, each decided by the user or applied:
  - unapplied wires:
    - **b2:** `string-cut` music to song, the `cam` base tag, and `x_soul 3 [song]` on `hollow-bell-canon`;
    - **b9:** `palm` on `rolling-barrage-fist` and `twin-shadow-fist`, and `art_speed_pct 8 [palm]` on
      `hundred-echo-palm-scripture`; with it, the held `ta-goose-bone-beads` rescope;
    - **b10:** the bow scopes;
    - **d11:** the Debt Stone on `mountain-heart-canon`, with the held `lh-nails-of-dao-sa` 2-piece;
    - **d12:** Written in the Ledger on `ruin-ledger-scripture`;
    - **b13:** the war-flag companion lines;
    - the dropped `herb_growth_pct` and `curse_effect_pct` lines, which return once their keys are read;
  - choices for the user:
    - the Way-Out Knot gear for phong_bach_ke, hua_thanh_diem and nham_do_han;
    - the two aux choices: sai_thanh_phong with `evening-song-of-the-boats`, and pham_thu_dien with `haze-walk`;
    - e9 `cung_mac_suong`'s black-ice-method, held until her story turns;
  - text conflicts:
    - the Eighth Movement's two readings (`nine-shao-advent` against `pm-tieu-thieu-quan / eight-of-nine`);
    - the two stale `build_use` lines (`tx-miasma-root-charm`, `ls-snare-wire-coins`);
  - the 2 refused and 2 not-authored entries in `auth-eff-2.json` and `auth-tech.json`: re-author or drop, with the
    user.

### Stage 7: one sect end to end (Băng Tâm Các)
- `tools/design/world/export_world.py` reads `design/world/depth/` for one sect: people, merged builds, lineage, items,
  sets, beasts, events and ties (mapped). It writes `world_history.json`; the records come through Stage 6's exporters.
- The gap report for this sect shows zero.
- Load the world, open the sect window and the person cards, and fight one authored build. Keep screenshots in
  `production/qa/evidence/`.
- Measure world build time with this sect.

### Stage 8: everyone
- Export the other 49 sects and the 6 groups. Measure world build time with all 1,747 authored builds; budget and
  optimise if needed.
- The census: realm counts against the targets (5,000 world), sect sizes, the admission pass rates.
- The gap report shows zero across the world.

### Stage 9: roots and admission in code
- **Re-leans first** (user 2026-11-26): write each sect's final leans from `design/world/depth/seats.json` into the
  game's sect records (`world_continent.json` great/minor sects), with the admission code.
- **Linh Căn:** the weighted Fisher-Yates, the purity shift and the variant boost (Formulas A2, D4). The map export
  writes province `land_qi`, `variant_max` and `land_element_means` (Provinces rule 3a).
- **World Generation rule 8a:** birthplace, the land roll, Sects admission (F20), intake (F21), and no-lean sects.
- **Living World Tick:** births read the mother's home province.
- **Golden tests:** even land equals the old roll (AC-LC-59). The world-totals AC is AC-LC-66.

### Stage 10: traits v2 in code
- `traits.json` gets the new kinds.
- NpcTraits:
  - roll, and inherit with talent drift;
  - likes and dislikes in opinion (F3);
  - the doubled personality rows;
  - the 15 choice-weighted v2 traits;
  - the talent grade display (the character sheet's C3).
- Dialogue verbs (#30) are the first `opens` consumer, in a separate plan.

### Stage 11: balance and the one review
- Fight-test the authored builds against Power Rankings' bands. Re-check Realms' calibration with the land roll
  (Linh Căn OQ 16).
- Builds a little overpowered are fine; do not chase outliers or loop rebalances (memory: balance depth).
- The one design review over everything, per the user's rule of one pass at the end.
- **Later (user, 2026-11-26): precompute the cast's ranking.** With the large fixed cast (1,889 authored people), run
  the full Power Rankings panels for the cast offline, ship the result as the game's initial ranking, and at world
  generation only insert the newly generated characters at their right place, instead of rating everyone at start
  (today: provisional ratings by Formulas G, then background panels; Power Rankings rules 16 and the Provisional and
  Stale states). Needs a Power Rankings GDD amendment and a re-run whenever the cast or the fight data changes. Not
  scheduled; do it when the cast and its builds settle.

## Before Stage 0: the content review (DONE 2026-11-25)

Review: `design/world/depth/review/RANKED.md`. The user chose to fix all groups but the voice pass. Commits:
- 7a5d139f: the checkpoint and sweep A;
- 4f89c796: the Phất Y rename and the builds folder;
- 5ababc91: story pass B;
- 4f5305a2: depth and tone passes C and C2.

The checker is clean. Content after the fixes: 1,891 people; 41 % carry a dark trait, each with a deed; tier B has
wants and secrets; tier C has looks.

## Risks

- **Size.** Stage 6 is the bulk: about 296 art records and about 340 Effect records to author by hand, plus 180
  techniques and 490 items to promote. Plan it as many batches of about 50, by sect.
- **Engine scope.** About 30 engine features in two engines with parity. Stage 5's verify-first step keeps it to the
  real gap.
- **Load time** with 1,747 authored builds (Stage 7 measures one sect, Stage 8 all of them).
- **Silent technique drops:** `CastBuilds._learn` drops unknown ids with no error. The gap report catches them; make
  the loader warn as well.
- **Ties over the caps** for 18 people. The authored overflow rule covers pinned ties; soft ties beyond the cap are
  trimmed by weight.
- **Saves:** the data-version bump refuses old saves (pre-release, development saves only).
- **Other sessions:**
  - the formations session owns `formations.md` and the uncommitted `sects.md` bullet;
  - the provinces session owns the provinces runtime code;
  - GDD files are shared, so stage hunks.
