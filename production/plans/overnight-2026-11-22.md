# Overnight 2026-11-22 → 23: places, map and UI

> **User brief (2026-11-22, going to sleep):** work on the map and UI until morning; about $40 of OpenAI image budget.
> For each special location write more history, imagine how it looks, and give it special art; make sure the assets fit
> the map. Arts for a location's levels (future, or now if a good idea). Think of a few great projects places can
> have, with art for each stage. UI decisions are Claude's except big ones. Place assets wait until the map is done.
> Study the world's history and each place's description before generating the map; if a place's history is thin,
> author lore and a description first, for every place, even ones without special locations.
> **Read first after a reset:** this file (checklist and log), then `production/plans/ui-greybox-build.md`.
> **Rules:** commit only own paths (`git commit -- <paths>`; a parallel session may share the repo); never edit
> `design/gdd/*` (the other session's); image calls through `tools/asset-pipeline/ui/img_edit.py` with the key from
> `OPENAI_API_KEY`; log every image call's cost below. Windowed demo runs are fine tonight (the user is asleep).

## Budget
About $40. Plan: map near layer ~$4, far layer ~$1, place miniatures ~$14, level variants ~$9, great-project stages
~$2, special place illustrations ~$5, retries ~$5. Prices: gpt-image-2 medium ≈ $0.053 / image, high ≈ $0.211
(unverified; icon pipeline's table). Spent so far tonight: see the log.

## Checklist
1. [ ] Study: world history (`assets/data/world_history.json`: 516 events, 30 sects, 86 cast, 14 famous sites, 19
       features, 28 hidden slots), places (`assets/data/world_continent.json`: 254 places, 20 regions), region names
       and images (`design/map/continent-11/region_names.json`), sect proposals.
2. [ ] Place catalogue: for all 254 places a look (what you see), lore (consistent with the recorded events) and an art
       brief; special places (famous sites, blessed lands, ruins, sect seats, cities, unique features) get a longer
       history. Output `design/world/place_catalogue.json` (proposal; the user reviews in the morning).
3. [ ] Great projects: a short design proposal (`design/world/great_projects_proposal.md`): a few project kinds by
       place kind, their stages, what each stage looks like. Not a GDD (the GDDs are the other session's).
4. [ ] UI: theme builder (`src/ui/theme/`), fight screen style slice, then person window, tooltips, HUD chrome; demo
       and screenshots after each.
5. [ ] Map test: one region two ways, (a) AI-painted tiles guided by a render of the grid, (b) engine-built from the
       grid with AI textures; pick by screenshot against `prototypes/ui-mood/out/map-near-m.png`; record why.
6. [ ] Map production: near layer (painted terrain, no buildings: the engine places the place art), far layer (paper
       campaign map style), both registered to the 540 × 360 grid; integrated in `src/ui/map/`; screenshots.
7. [ ] Place art: one miniature per place for the near map (fits the map's scale and light), illustrations for
       special places, level variants where it helps, great-project stage art; integrated; screenshots.
8. [ ] Morning report in this file: what was done, decisions taken, open questions, spend.

## Morning report (final, 2026-11-23)

**Spend:** 510 images (509 medium, 1 high) + earlier tests ≈ **$27.8 of $40** (unverified per-image prices:
medium $0.053, high $0.211). About $12 left for redoing places after your review.

**Tests:** full suite 860 cases, all pass. One known fault, **not from tonight**: `tests/unit/session/session_reads_test.gd`
passes every case, then Godot faults at shutdown ("Run dispose test resources"): exit 139 with `-d`, a hang
without it. Bisected: same with the lore file removed, and same on a clean checkout of HEAD (6b4899a2), so it predates
tonight's work. Not fixed; a candidate for a separate look (gdUnit dispose of the session suite).

**Where to look:** the gallery https://claude.ai/artifact/8fD5fkFY4TGP1npH5xJizP (section "Overnight") and the place
catalogue page (link in the log below once published).

**Done:**
1. **Place catalogue** (proposal for your review): all 254 places have a look, lore and art brief; 141 special places
   have a history; settlements and seats have two levels; plausible great projects listed. Checked: names, recorded
   years only, every special has a history. In the game: the place window shows the painting, look, lore and history.
2. **Great projects** proposal: 10 projects × 3 stages, as staged shared works (Travel & Map rule 31); 4 open
   questions at its end.
3. **Map painted**: far paper map (one painting) and near relief (35 crops stitched, 6480 × 4320), both registered to
   the grid; region names drawn by the engine on the paper map; diamond markers; names skip overlaps; region zoom 6×.
4. **Place art**: every place painted into its own patch of the near map from its catalogue brief; patches fitted to
   what was painted and capped by the distance to the next place; drawn on known places only; markers sit below the
   art.
5. **Stage art**: levels for cities, sect seats, towns and markets (2 each), and great-project stages at one place
   per project; for review (not yet shown in the game: places have no level in the game data yet).
6. **UI**: the Rosewood theme on every screen built so far (wood HUD, parchment windows and tooltips, the fight
   screen as the slice), lists and fields styled, End turn cinnabar, link colours per surface.

**Decisions I took** (see the list below): map method (a); far layer as one painting; place art in its own patch;
region zoom 4× → 6×; villages' level art left for a later pass (budget).

**Your calls:**
1. Review the place catalogue (and its art) and the great projects proposal (its 4 questions).
2. Commit: nothing from tonight is committed yet (your rule); the paths are listed below.
3. The HUD resource boxes (which resources get a box).
4. Provinces: still a drawing layer only; with the painted map, do you still want them?
5. Back up the masters (`design/map/continent-11/art/`, ~1.1 GB, not in git).
6. Approve the art bible drafts (Section 6 and 8.8, `design/art/drafts/section-6-and-8-map-places-draft.md`).

**Paths to commit (tonight's, own only):** `src/ui/theme/`, `src/ui/{fight,greybox,map,hud,tooltip,windows}/` (the
modified files), `src/gameplay/session/game_query.gd`, `tests/unit/ui/ui_rosewood_theme_test.gd(.uid)`,
`tests/unit/session/session_reads_test.gd`, `assets/data/ui_hud.json`, `assets/data/world_place_lore.json`,
`assets/map/`, `assets/ui/frames/frame_board*`, `assets/ui/kit.json`, `tools/asset-pipeline/map/`,
`tools/asset-pipeline/ui/cut_kit.py`, `tools/design/world/`, `design/world/`, `design/art/drafts/`,
`design/map/continent-11/art/` (gitignore + guide only), `prototypes/place-gallery/`, `prototypes/ui-mood/.gdignore`,
`production/plans/overnight-2026-11-22.md`, `production/plans/ui-greybox-build.md`, `production/qa/evidence/hud-greybox/`.
Not ours: the `tests/performance/world/*.uid` and `tests/unit/crafting/herb_rework_test.gd.uid` files.

## Decisions taken tonight (Claude, under the UI delegation)
- **Lore is attached per named place** (254, one tile each, keyed by place id), with regions (20 tile groups) as the
  backdrop and multi-tile sites (blessed lands, veins, the wasteland) on their site records; unnamed tiles get their
  look from the terrain painting only; hidden slots and tile secrets stay undescribed (user asked mid-night; answered).
- **Map method (a), AI-painted crops guided by a render of the grid**, chosen over (b) engine-built after the 2×2 test:
  the stitched test showed no visible seams at map scale, followed the terrain, and looked far richer than a shader
  build could tonight. Settlements are not painted into the terrain: each place gets its own patch (step 7).
- **Far layer as one painting** (the continent is 3:2, like a 1536 × 1024 image): no seams; checked by overlaying the
  true coastline (it sits on the painted one).
- **Place art is painted into its own patch of the near layer** (the model gets the painted terrain around the place
  and its catalogue brief; a soft-edged patch is cut out), so it fits the map's light, scale and land; the engine draws
  the patches on the place tiles, so levels and project stages can swap them; drawn only for known places.
- **Fight screen restyled** with the Rosewood theme as the style slice (board frames over wood, parchment slot inset,
  parchment log window, plaque buttons); slot rows now put the title beside the slots so the screen fits 1280 × 720.
- **Great projects** written as a proposal (`design/world/great_projects_proposal.md`, 10 projects × 3 stages), not a
  GDD.
- **Region zoom 4× → 6×** so place art reads; place markers and names sit below a place's art.
- **Place patches are fitted** to what the model changed around the centre, capped by the next place's distance, so a
  big port city keeps its harbour and two neighbours never cover each other's art.
- **Level art for villages left for later** (70 × 2 images): budget kept for redoing places after the user's review.
- **Masters kept out of git** (~1.1 GB): regenerable from the scripts, but costly; to back up outside the repo.
- **Art bible drafts, not edits:** Section 6 and 8.8 (map and place art) are drafted in
  `design/art/drafts/section-6-and-8-map-places-draft.md` for the user's approval.

## Log
- 22:59: plan written. Committed before: 362aed3f (pass 3), c5296a24 (mood rounds), 6b4899a2 (art bible, kit).
- 23:10: place packs built (`tools/design/world/place_packs.py`); 5 world-builder agents writing the catalogue.
- 23:30: theme builder `src/ui/theme/rosewood_theme.gd` (+ 3 tests); fight screen restyled; demo 60/60.
- 23:50: catalogue drafts in (254/254); checker (`tools/design/world/place_catalogue_check.py`) found ~220 invented
  years and ~25 under-marked specials; fix lists sent back to each writer (packs 01-04 fixed, 05 in progress).
- 00:00: guide render (`tools/asset-pipeline/map/guide.py`), near test 2×2 ($0.21), far layer ($0.21, high), near
  layer painting (31 crops, ~$1.65) in progress.
- Spend so far tonight: kit $0.16 (before the brief), near test $0.21, far $0.21, near ~$1.65 → about $2.2.
- 00:30: all packs fixed; checker: 254/254, 141 special, 0 observations; merged `design/world/place_catalogue.json`,
  exported `assets/data/world_place_lore.json`; `GameQuery.place_lore` + the place window shows look, lore, history.
- 00:40: near layer stitched (6480 × 4320), open sea calmed (`sea_fix.py`), installed VRAM-compressed (~19 MB);
  map view draws far/near layers; demo 60/60.
- 00:50: place art test (5 places, $0.27): excellent fit; full run of 254 started (4 workers, ~$13.5).
- 01:00: HUD restyle (wood/paper surfaces), lists and fields, region names on the paper map, place painting in the
  place window; stage tool `place_stages.py` (levels for cities, seats, towns, markets; 10 great projects × 3).
- 01:30: place patches fitted to what the model painted (`fitted_radius`), capped at 55 % of the distance to the next
  place; small places drawn first; region zoom 4× → 6×; markers below the art; demo 60/60 at 1280 and 1920.
- 02:15: all 254 places painted; the place review page published: https://claude.ai/artifact/937BB85Bw9TRLvt4qjw9qM
  (search, kind filters, regions as chapters); the 10 great projects × 3 stages done (canal and sanctuary sites picked
  from the land: no catalogue entry named them); levels painting (2 painters from both ends).
- Full suite (JOBS=4): 860 cases in 24 groups, all passed; `tests/unit/session` exited 139 (a segfault at shutdown
  after its 55 cases passed and reported; the same group exited 0 when run alone earlier); rerun alone to confirm.
- Masters (~1.1 GB) are local only (`design/map/continent-11/art/.gitignore`): back them up; the game assets (~32 MB)
  and every plan, prompt and meta file are tracked.
- Spend (from the meta files, unverified per-image prices): kit $0.16, near $1.85, far $0.21, places $13.46, stages
  $5.67 so far → $21.4; with the remaining levels about $27.5. The rest is left for redoing places after review.
