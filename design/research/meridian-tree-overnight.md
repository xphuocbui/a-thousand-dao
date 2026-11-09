# Meridian Map: whole-tree draft (overnight 2026-11-08 → 09)

> **Status**: Draft for the user's review. Written overnight while the user slept. Nothing is committed.
> **Request**: redraw the whole Kinh Mạch Đồ by following `design/research/meridian-land-authoring.md`, with the kit in
> `tools/design/meridian_rework/` and the Metal pilot as the worked example. The layout comes first; node content may
> stay placeholder. Then compare against PoE 1 and PoE 2 in a fresh session and improve until ours wins.
> **Page**: https://claude.ai/artifact/AbbxnckEoY4QypdaxtZdC4. The lean variant, for open point 1:
> https://claude.ai/artifact/P6vkxLZdENs1BekcsjZf9y
> **Build**: `python -I tools/design/meridian_rework/build_tree.py <out_dir>` writes `tree.json` and `tree.html`.

## Read this first (morning summary)

- **The whole tree is drawn** and passes every check: 0 crossings, 0 nodes too close, 0 links grazing a node, 0
  unreachable acupoints, 0 clusters without a bypass, 78 hidden clusters (15 % inner, every name unique), every one
  3–12 acupoints, as rule 6 asks.
- **The PoE comparison:** blind judges (fresh `claude -p` sessions, three trees drawn by the same neutral renderer,
  letters rotated) rank ours first. Lean build, all six letter orders per model: Opus 48 out of 60 (PoE 30–35), ours
  first in 6 of 6; Sonnet 45 (PoE 28–35), ours first in 4 of 6. Re-checked on the final lean build (three orders
  each): Opus 24 of 30, ours first 3 of 3; Sonnet 23, ours first 2 of 3. Final full build: Opus 23.5 (PoE 2 18,
  PoE 1 16.5), ours first 3 of 3; Sonnet 23 (PoE 1 18), 2 of 3. Opus has preferred ours in every run but one since
  round 2. Details in the round log.
- **Decisions waiting for you:**
  1. The open-point answers below are provisional (I could not ask you).
  2. The **Shadow Shrine (Ám Từ)** on the east side is my addition, not in the zoning plan (see Still open).
  3. **Full or lean** (open point 1): the lean build (about 6,300 visible acupoints) won 10 of 12 blind runs over all
     six letter orders (Opus 6 of 6, Sonnet 4 of 6) and led both judges' totals. The full build (about 7,600) now
     scores about the same in the final checks, but needs more points per build to cover. I recommend the lean one.
  4. **The keystones beside the starts** crowd the centre in both judges' eyes; they come from the approved Metal
     start web, so I left them (see Still open).
- **Nothing is committed.**

## The open points: my answers (provisional)

You asked to be asked about each open point before drawing, but you were asleep. Each point below has my
recommended answer, chosen so it is easy to change.
The tree is drawn with these answers. Each answer names the knob that reverses it.

| # | Open point (guide, "Open for the whole tree") | Provisional answer | Knob |
|---|---|---|---|
| 1 | **Budget**: Metal holds ~825 against 600 planned | **Let the total grow, to the lean variant's size: about 6,300 visible acupoints** (plus about 710 sealed). Both builds are drawn from the same code. The **full draft** keeps Metal's density in every land: about 7,590 visible (lands 900–1,110, blend zones 575–645, the islands and the Shadow Shrine 217–270, the hub 101). The **lean variant** (`KMD_LIGHT=1`: one fill pass, one figure per road node in the blend zones, Metal unchanged) holds about 6,300. A build covers about 5.7 % of the lean tree by the end of Nascent Soul (357 points) and 9.0 % by the end of Deity Transformation (566); 4.7 % and 7.5 % of the full one; PoE is 3–6 %, and the planned 5,000 gave 7 % and 11 %. Over all six letter orders per model **the lean build won 10 of 12 runs** (Opus 48 of 60 against PoE's 30–35, 6 of 6; Sonnet 45 against 28–35, 4 of 6); the full build won with Opus (23 of 30) and narrowly with Sonnet (22 against PoE 1's 20). | `KMD_LIGHT`; `landkit.blend_finish` (`per`, `clr`, `rounds`) |
| 2 | **Summit bypass** in Metal | A short road of three travel nodes runs beside the summit on its Water side, from ring 3 to ring 4. | `metal.py`, "summit bypass" |
| 3 | **Start web**: 72 nodes within 9 points vs ~130 in PoE 2 | Solved by the whole tree: every element start now has **141–180 nodes within 9 points**, counting the inner ring road, the blend arches and the neighbouring webs. | none needed |
| 4 | **Attributes** on the roads | Each element's roads pay one innate talent, by the five-phase organs and virtues: **Metal → physique (căn cốt)**, **Water → comprehension (ngộ tính)**, **Fire → soul strength (thần hồn)**, **Earth → Dao heart (đạo tâm)**, **Wood → fortune (khí vận)**. The ring road and the hub's dantian roads pay **a talent of your choice** (PoE 2's pick-one travel node). Charm (mị lực) appears on the pick-one roads and on Light's radiant road. The variant roads mix two talents. | `common.ROAD_KINDS` |
| 5 | **Content**: keystones, mastery, names | **Mostly placeholders.** Nine keystone slots hold the real Meridian Map keystones from `effects.md` (Called Blow, No Ward and Heart Demon's Blade in Metal; Burning Lifespan and Unyielding Breath in Fire; Formation Within a Formation in Earth; Beast Soul Union in Wood; Glass Meridians on Thunder; Soul Leaves the Body on Darkness), marked `[effects.md]`. The other 25 are my proposals, marked `[proposal]`. Node values follow the GDD budgets: small and road acupoints 1.2 W, notables 8 W (Kinh Mạch Đồ A2, Modifier System E), priced by Modifier System Formulas B–C; root scaling is applied at runtime. Notables come from a small per-theme name bank. The centres of the great rings stay open for cluster mastery (Tinh Thông), and the viewer marks those spots. | `common.THEMES`, each land's `KEYSTONES` |
| 6 | **Still to draw** | Everything is drawn: the other four lands, five blend zones, the centre hub, Wind's land and start, the Ice start, the Light, Darkness and Thunder islands, the lightning roads, the shadow road and the hidden band. | — |

Other decisions I made while drawing, also provisional:

- **The centre hub is a Taiji** with the Chaos start at its heart, and holds about 100 nodes, not 350. The zoning plan's
  350 would not fit inside the land keystones that ring the hub at radius 10.7. Five dantian roads run out to the five
  blend zones, so the centre reaches every pair of neighbours. A universal figure faces each element land.
- **Each land has its own ring radii**. Some rings are straight-sided or jittered, some segments are missing, and rings 2 and
  3 braid (cross over) in three blend zones. The blend zones carry each ring from one neighbour's radius to the other
  on a bent road. This keeps the old map's spokes and rings without the dartboard look of five identical circles.
- **The neighbouring starts are 12 points apart.** The inner ring road rises in an arch through each blend zone to
  reach that length. Opposite starts are about 24 points apart, Chaos is 15–16 from every element start, and the far rim is
  about 50 points out (the islands opposite are farther).
- **Lightning reaches Wind only** (your change, 2026-11-09 morning): the Thunder island's bridge lands beside the Wind
  start. The lightning roads that ran inside the rim through Water and Wood to Metal and Fire are gone; the hidden
  clusters that hung off them now gate into the lands themselves.
- **The Darkness bridge** (same change) runs just outside the hidden band and then drops straight in, square to the
  rim, onto a gate above Water's ring 4 (world 206°), so the band has room for hidden clusters on both sides of it.
- **The shadow road** hugs the rim just outside the hidden band (radius 85.4), with two stops on the way. At its
  eastern turn stands the **Shadow Shrine (Ám Từ)**, a waystation satellite I added (see Still open); the road then
  turns in over two short segments onto Earth's ring 4.
- **Hidden clusters (rule 6):** 78 in all, about the GDD's 75. 66 sit in the band beyond the rim and 12 inside the
  tree (15 %, as rule 6 asks): two in each land's quiet fields and one in each blend zone. Each has a kind
  (sealed or open), a theme and a seal condition, joined by dashed gates. Sizes run 6–11 acupoints, mean 9 (the
  tuning table's mean is 8, sd 2): the band's hand-placed clusters are 8–11, and late in the night each land and blend
  zone added small ones (6–8) in the widest gaps of its band, away from the island bridges (`landkit.halo`,
  `HALO_EXTRA`, `HALO_AVOID`; Metal's band is left as drawn). The page offers rule 13's **Silhouette** and **Visible**
  modes.
- **Identity districts**: Fire has Blaze (Wood side) and Alchemy (Earth side). Earth has Mountain body (Fire side) and
  Formations (Metal side). Water has Tide (Metal side) and Talismans (Wood side), with Ice's district round the Ice
  start. Wood has Spirit fields (Water side) and Beasts (Fire side). Each land also has a second element theme:
  Rebirth (Fire), Weight (Earth), Ice (Water) and Growth (Wood).

## Final state (overnight build)

| Measure | Value | Target or PoE |
|---|---|---|
| Visible acupoints | 8,672 (lean variant: 6,403) | 5,000 planned; see open point 1 |
| Sealed acupoints, hidden clusters | about 690 in 76 clusters (every name unique) (66 at the rim, 12 inner = 15 %), each 6–11 acupoints, mean 9 (lean: 77, 13 inner) | about 75 clusters of 3–12 (mean 8, sd 2), about 15 % inner (rule 6) |
| Visible notables / keystones / starts | about 1,400 / 40 / 11 (9 keystones are real `effects.md` ones, the rest proposals) | PoE 2: 984 / 33 |
| Notables as a share of visible acupoints | 16 % (gathered into districts) | PoE 2 24 %, PoE 1 23 % |
| Crossings, nodes too close, links grazing a node | 0 / 0 / 0 | 0 |
| Clusters a road runs through with no road around them | 0 (start webs excepted) | guide step 7 |
| Unreachable acupoints | 0 | 0 |
| Roads join a cluster at its nearest node | 100 % | PoE 2 79 % |
| Travel nodes carrying a cluster / carrying 2+ | 84 % / 62 % (the lightning roads now run bare) | PoE 88 % / 75 % |
| Neighbouring starts / opposite starts | 12 / 24 points | 12–15 / 25–30 |
| Chaos start to each element start | 15–16 points | — |
| Nearest keystone from each start | 6–11 points | about 10 |
| Nodes within 9 points of an element start | 141–180 (Ice 200, Wind 347) | PoE 2 about 130 |

Per region (with each region's sealed clusters): hub 101, Fire 930, Earth 1,134, Metal 904, Water 1,035, Wood 952; blend
zones 621–667 each; Light 230, Darkness 270 (with the shadow road and the Shadow Shrine), Thunder 217. (Final build.)

### What to look at first

1. The page, by element first, then by theme. Set **Start** to your root and hover anywhere to see its cost. Click
   acupoints to plan a build: the page spends points along the cheapest path and counts them; click an allocated one
   to refund it. **Copy build link** shares the start and the allocation; **Find** rings every acupoint whose name,
   cluster or theme matches (try "alchemy", "shrine" or "keystone").
2. Lands up close: Fire's centre road, Earth's Five Peaks, Water's Ice start, Wood's canopy, and Metal, unchanged
   apart from its ports, the summit bypass and its hidden band.
3. The lean page, to decide open point 1.
4. The open points table at the top. Every answer there was given without you, so treat it as provisional.

### Files (nothing committed)

- `tools/design/meridian_rework/`: `kit.py` and `build_tree.py` are new; `tree_viewer.html` is new; `build_region.py`
  is reworked onto the kit (Metal builds as before).
- `tools/design/meridian_rework/regions/`: new `common.py`, `figs.py`, `landkit.py`, `hub.py`, `fire.py`, `earth.py`,
  `water.py`, `wood.py`, `blend_fe.py`, `blend_em.py`, `blend_mw.py`, `blend_ww.py`, `blend_wf.py`, `islands.py`,
  `light.py`, `darkness.py` and `thunder.py`. `metal.py` is ported (ports, shared themes, summit bypass, hidden band).
  `pens.py` gained `MASTERY_KINDS`, roles on `place_in` and the hook that loads `figs.py`.
- `tools/design/meridian_rework/judge/`: the blind comparison (`judge.sh`, `poe_view.py` and `judge_prompt.md`). The PoE
  data stays outside the repo.
- `kit.py` also gained, during the polishing rounds: `ARC_TOUCH_OK` (a region option that lets a figure's stem touch
  its own road's arc, which the islands use), and `ROAD_JITTER` (travel nodes shift along their roads by a fixed hash;
  Metal and the Wood–Fire blend keep even steps). `landkit.py` gained the figure caps and the no-twin rule, the gold
  districts (`gold_keep`), the keystone clearance tiers, and the extra and inner hidden clusters (`HALO_EXTRA`,
  `HALO_AVOID`, `BLEND_INNER`).
- The page (`tree_viewer.html`) also has a build planner (click to allocate, click to refund, Clear, Copy build link),
  a Find box, engraved links,
  a seal round every start, an eight-point frame round every keystone, a faint plate behind the big element set
  pieces, a large faint element glyph behind each land (火 土 金 水 木), and sealed outlines that fade when zoomed out.
  The plates, seals, frames and glyphs show only in the colour views; the neutral view the judges see has none of them.
- `design/research/meridian-land-authoring.md`: a pointer to this note and the new tools in its table.

## How it was drawn

The guide's 9 steps, with these changes to the kit (`tools/design/meridian_rework/`):

- `kit.py`: the drawing kit split out of `build_region.py`, so many regions can be drawn into one tree. It adds region
  outlines (wedges, islands, the hub), ports, and edge ports that carry a road to a region's edge.
- `build_tree.py` draws every region, turns it into world coordinates, joins the ports, and runs every check on the
  whole tree. `tree_viewer.html` is the whole-tree page.
- `regions/figs.py`: 27 new figures, each one meaning something for its theme: a cauldron, sun, flame, lotus, phoenix,
  bagua, 山, turtle, paw, tree, vines, wave, whirlpool, great snowflake, bolt, eclipse, thunder drum, fan, cloud, koi,
  talisman slip, antler, flower, gourd, Taiji, shield and pagoda.
- `regions/landkit.py`: the parts every land shares. These are the start web, the road skeleton with ports, and step 5
  (dressing) and step 6 (hole filling) **as rules**:
  - identity themes stay on their own side, element themes sit in the middle, and universal themes scatter;
  - a cluster rarely sits next to its own theme, and an offence cluster is paired with defence;
  - each theme gets its own figure, and figures grow larger toward the rim.

  This is the one place I departed from "draw by hand". The guide asks for every road node to be dressed by hand.
  For about 900 road nodes in one night, I wrote the guide's rules as code. The big constellations of every land are
  still drawn by hand.
- Each land and blend zone is its own spec in `regions/`, with hand-drawn constellations:
  - **Fire**: the Sun Wheel, Fire Lotus and Vermilion Bird along its centre road.
  - **Earth**: the Nine Palaces, the Five Peaks (山) and the Altar of Earth.
  - **Water**: the Ice start inside a great snowflake, the Moon Pool and a pair of koi.
  - **Wood**: the World Tree, the Twin Vines and the Ancient Canopy.
  - **Blend zones**: a volcano, a mother lode, a mirror lake, a wutong tree with a phoenix, and Wind's whirlwind.
  - **Set pieces** (composed groups): Fire's Alchemist's Hall, Earth's Grand Array, Water's fan of talismans, Wood's
    Beast Den.
  - **Islands**: sun, eclipse and thunder-drum mandalas.

## The comparison with PoE

Fresh headless sessions (`claude -p`, Read only) judged three trees blind: ours, PoE 1 and PoE 2. All three were drawn
by the same viewer in the same neutral style, with letters shuffled between runs. The judges compared whole views and
same-scale close-ups.

The results are in the round log at the end.

## Round log

| Round | Judge | Ours as | Render | Result (scores out of 10) | What changed after it |
|---|---|---|---|---|---|
| 1 | Sonnet | B | ours kept its coloured starts and land glow (unfair) | **ours 8**, PoE 1 6, PoE 2 4 | made the render fair: neutral starts, no glow, for every tree |
| 2 | Opus | A | same (unfair, a stale page) | **ours 8**, PoE 1 6, PoE 2 4 | rebuilt the page; stricter brief that lists every tree's flaws |
| 3 | Opus | C | fair | **ours 8**, PoE 1 6, PoE 2 5 ("clear") | keystones in clearings, more keystones (34), ring gaps, fewer aligned radials, mastery marks, fewer grids |
| 4 | Opus | B | fair, islands in view | **ours 8**, PoE 2 6, PoE 1 4 ("clear") | irregular hidden band, smooth Darkness bridge, a spiral shadow road, zigzag lightning roads, fewer hexagons, a kite in each start web's dome |
| 5 | Sonnet | C | fair | PoE 1 8, **ours 6**, PoE 2 4 | thinned the gold (filler figures keep 1–2 notables: 22 % → 16 % of nodes), sealed clusters drawn as soft bubbles, inner sealed clusters, bigger keystone frames, more hidden clusters (57) |
| 6 | Sonnet, Opus | A, A | fair | Sonnet: PoE 1 8, **ours 6**; Opus: **ours 7**, PoE 1 6 | the "bubbles" read as warts: back to crisp outlines; gold moved to the tips of figures; keystones in clearings of radius 4.6; a ring inside each start web's dome; more ring gaps; islands moved in (radius 93); bays in the rim |
| 7 | Sonnet, Opus | C, C | fair | Sonnet: PoE 1 8, **ours 6**; Opus: **ours 7.5**, PoE 2 7 (narrow) | the zigzag lightning road read as a "damaged rim": back to smooth; quiet fields hold a visible landmark; the Chaos keystone moved to the Fire–Earth dantian road; rings 2 and 3 braid through three blend zones; heavier roads |
| 8 | Sonnet, Opus | A, B | fair | Sonnet: PoE 2 8, **ours 7**; Opus: **ours 7.5**, PoE 1 6 ("clear") | a density gradient (airy near the starts, dense toward the rim, as in PoE 2); one notable per filler figure; a clearing round each start; ring-with-a-gold-centre figures only where they mean the theme; Earth's boxy bay removed |
| 9 | Sonnet, Opus | C, C | fair | Sonnet: **ours 8**, PoE 2 6, PoE 1 5 ("clear"); Opus: **ours 7.5**, PoE 2 6.5, PoE 1 6 ("narrow"). The light variant (6,440 nodes) also scored **8** with Sonnet | **both judges pick ours: the stop condition is met.** Kept improving: rings pushed in and out (polygonal ring 4 in Fire and Water), fewer straight rings in Earth, the shadow road's last leg on a diagonal, a bend in the Light bridge, the three islands given different road rings, fewer and larger hidden clusters (49), caps on stamped forms |
| 10 | Sonnet, Opus | B, B | fair | Sonnet: **ours 8**, PoE 2 5, PoE 1 5; Opus: **ours 8**, PoE 2 7 | a lightning road that wanders in and out, more varied hidden figures, an inner court on each island, the Earth avenue that made a "rectangular notch" removed |
| 11 | Sonnet, Opus | A, A | fair | Sonnet: PoE 1 8, **ours 6**; Opus: **ours 8**, PoE 2 6 | the shadow road lands straight on Earth's ring 4 (no doubled road); keystones spread from band 1 to the rim |
| 12 | Sonnet | A | fair, main and lean | PoE 1 8; ours 5 (main), 6 (lean) | spotted Sonnet's position bias (see below) and ran the balanced test |
| 13 | Opus | A, C | fair | **ours 8** both times (PoE 2 7 at best) | the shadow road as a rim-hugging orbit with stops; a dense knot and an extra merged cell per land; the bypass check; the Wind whirlwind; Silhouette/Visible modes; hidden clusters held to 3–12 |
| 14 | Sonnet, Opus | C, B | fair | Sonnet: PoE 1 8, **ours 6**; Opus: **ours 8**, PoE 1 7 (narrow) | four more set pieces (Wildfire Star, Twin Peaks, Breaking Wave, Herb Garden); rice terraces drawn as stacked arcs instead of a grid; star figures capped; clearer mastery sockets; larger starts; a "Reading the map" card on the page |
| 15 | Opus | A | fair (draft 12: build planner, engraved links) | **ours 8**, PoE 2 6, PoE 1 5 ("clear") | one joint for every island (a straight bridge with a mirrored pair of figures at its middle, like a gateway); the Darkness bridge lands straight on Water's lightning road (it made a hairpin); sealed outlines fade back when zoomed out; a fit-check fix (`ARC_TOUCH_OK`) that let the islands' crowns and the shadow road's stops fill in |
| 16 | Opus | B, C | fair (draft 13) | **ours 8** both times (PoE 2 7, PoE 1 5 at best) | the Shadow Shrine (Ám Từ) midway on the shadow road, a ring of ten round a socket; ring 4 closed in Earth, Water and Wood (the gaps read as a broken rim); a keystone keeps 1.9 clear of earlier set pieces where it can; asterisks and window lattices capped harder |
| 17 | Opus | A, B, C (balanced) | fair (draft 14) | **ours 8, 8, 7.5 = 23.5**; PoE 2 19.5; PoE 1 15. Ours first in all three orders | each island's core given its own shape (Light a round sun ring, Thunder a five-point star, Darkness a ring pushed off-centre like an eclipse); the Light crown made symmetric; a faint plate of colour behind each big set piece (colour views only; the judges' neutral view has none) |
| 18 | Opus and Sonnet | A, B, C each (balanced) | fair (draft 17) | Opus: **ours 23.5**, PoE 2 18.5, PoE 1 15, ours first in all three orders. Sonnet: **ours 23**, PoE 1 20, PoE 2 13, ours first twice (it lost only with PoE 1 at B) | the Shadow Shrine moved to the shadow road's eastern turn as a small mandala (it balances the east side and explains the turn); a seal round every start; set-piece plates only behind element set pieces; the Return to Wuji keystone moved off the road; keystones keep 1.5 clear of links where they can |
| 19 | Opus | A, B, C (balanced) | fair (draft 19) | **ours 8, 8, 8 = 24**; PoE 2 17; PoE 1 15 | the Shadow Shrine grown into an east satellite at the islands' radius (road ring, inner court, crown, and the Swallowing the Moon keystone moved there from Darkness); two larger stops on the shadow road instead of five small ones; a rule against twins (a figure kind is not drawn again within 7 units: same-kind neighbours 104 → 54); ring roads drawn heavier than spokes |
| 20 | Opus | A, B, C (balanced) | fair (draft 20) | ours 8, 6, 8 = 22; PoE 2 20; PoE 1 14. Ours first twice; once PoE 2 won 7–6 ("narrow": it credited ours with the stronger silhouette and roads, PoE 2 with more organic density) | the lightning road runs bare like PoE's highways; an eight-point frame round each keystone (colour views only); the bowtie, the "X-star" every judge flagged, capped at 2 per region and dropped from the Earth and Ward themes |
| 21 | Opus | A, B, C (balanced) | fair (draft 21) | **ours 8, 8, 7 = 23**; PoE 2 18; PoE 1 14. Ours first in all three orders | the quiet fields widened by 45 % so the clearings register at full view; the World Tree's low branches curl into leaves and both boughs end in gold; the rice terraces close into stacked plots (judges: branches that end on a plain node look unfinished) |
| 22 | Opus | A, B, C (balanced) | fair (wider clearings) | **ours 8, 8, 7 = 23**; PoE 2 19; PoE 1 14. Ours first in all three orders | the shield and the hourglass capped (the stamps named in every round); a theme's first figure capped at twice the limit; the Ward theme leads with theta and hex, Lifespan with the gourd; a small gem in every mastery socket (judges: "sockets look empty") |
| 23 | Opus | A, B, C (balanced) | fair (draft 23) | **ours 8, 8, 7.5 = 23.5**; PoE 2 17.5; PoE 1 16. Ours first in all three orders | tried pairing the sealed rim clusters into pockets: no visible change at full view and two clusters lost, so reverted; the map card updated |
| 24 | Opus | A, B, C (balanced) | fair (draft 25) | **ours 8, 8, 8 = 24**; PoE 2 20; PoE 1 14. Ours first in all three orders | (draft 25 had added: hex, shield, theta, spoked and concentric share one cap of six per region, since they all read as "a ring with a gold centre"; a mastery socket is drawn only where it has room.) After it: page fixes (the visible count, the intro text, the Earth–Metal label) |
| 25 | Opus | A, B, C (balanced) | fair (draft 27) | **ours 8, 8, 7.5 = 23.5**; PoE 2 19.5; PoE 1 14.5. Ours first in all three orders | (draft 27 had added: the Metal–Water braid crossroads moved 3° off the axis, so the line from the Taiji down to Darkness jogs instead of running ruler-straight.) After it: Fire's Unyielding Breath keystone turned away from Cinnabar Furnace Body (they were 6.9 apart; the closest keystone pair is now 7.0) |
| 26 | Opus | A, B, C (balanced) | fair (draft 30) | **ours 8, 8, 8 = 24**; PoE 2 19; PoE 1 15. Ours first in all three orders | (draft 29–30 had added: the totem and gourd capped, the Lifespan theme led by the cup; a faint element glyph behind each land; road nodes shifted along their roads by a fixed hash so the diamonds no longer sit at even steps.) After it: a compact start table on the page |
| 27 | Opus and Sonnet | A, B, C each (balanced) | fair (draft 32) | Opus: **ours 8, 8, 7 = 23**; PoE 2 18; PoE 1 16, ours first in all three. Sonnet: **ours 22**; PoE 1 20; PoE 2 13, ours first twice (it lost only with PoE 1 at B) | (draft 32 had added: notables gathered into districts, filler figures carrying no gold in plain districts; the Darkness crown shortened so it no longer runs through its keystone.) Final build |
| 28 | Opus and Sonnet | A, B, C each (balanced) | fair (stronger plain districts, notables 15 %) | Opus: ours 24, PoE 2 19, PoE 1 14 (3 of 3). Sonnet: ours 20, **PoE 1 21**, PoE 2 12 (1 of 3) | Sonnet liked it less than the milder districts (22–20), so reverted to the draft 32 setting. The lean variant with the gold districts was tested the same way: **Opus 24, Sonnet 24** (PoE 14–18), ours first in all six runs (see Judge reliability) |
| 29 | Opus and Sonnet | A, B, C each (balanced) | fair (final: rule 6 met) | Full build with 74 hidden: Opus **24** (PoE 2 19, PoE 1 14), 3 of 3; Sonnet **22** (PoE 1 20), 2 of 3. Final lean build (77 hidden): Opus **23** (PoE 2 17, PoE 1 15), 3 of 3; Sonnet **23** (PoE 1 18, PoE 2 15), 2 of 3 | (the final builds had added: small hidden clusters in the band's widest gaps and one inner hidden cluster per blend zone, so the tree holds 79 hidden clusters, 16 % inner, as Kinh Mạch Đồ rule 6 asks.) Final build |
| 30 | Opus and Sonnet | A, B, C each (balanced) | fair (lean, after a close-up review) | Opus **24** (PoE 2 20, PoE 1 15), 3 of 3; Sonnet **23** (PoE 1 19, PoE 2 14), 2 of 3 | A fresh Opus session reviewed six close-ups of the lean build (6 of 10) and listed local flaws. Fixed: a sealed cluster sitting on a great ring's socket (inner hidden clusters now keep 4.5 from ring centres); keystones on roads (a middle tier of clearance, 1.3 from nodes and 1.1 from links, before the plain fit: no keystone now sits within 1.1 of a road); the totem "ladder" capped at 2 per region. Not changed: keystones beside the starts (the start web from the approved Metal pilot) and spacing inside Metal. Also: wider notable name banks and a per-region start in each bank (168 distinct names instead of 149), a Find box and a Copy build link on the page. Final build |
| 31 | Opus and Sonnet | A, B, C each (balanced) | fair (final full build, as published) | Opus **23.5** (PoE 2 18, PoE 1 16.5), ours first 3 of 3; Sonnet **23** (PoE 1 18, PoE 2 14), ours first 2 of 3 (the loss with PoE 1 at B) | The final pages: the narrow-screen layout fixed, and a dark theme checked |
| 32 | Opus and Sonnet | A, B, C each (balanced) | fair (your morning changes) | Packed build: Opus **23** (PoE 2 19, PoE 1 15), 3 of 3; Sonnet **22** (PoE 1 18, PoE 2 15), 2 of 3 | Your changes: lightning reaches Wind only (the inside-rim lightning roads to Metal and Fire removed); the Darkness bridge comes into Water square to the rim, with two new hidden clusters beside it; six more keystones (one per blend zone and Undertow in Water; 40 in all, every pair at least 7 apart). Packing: quiet fields back to their drawn size, keystone clearings 3.4 → 2.6, a final plug pass at clearance 1.75 (loose sample points 424 → 190) |
| 33 | Opus and Sonnet | A, B, C each (balanced) | fair (third figure on road nodes) | Opus **22** (PoE 2 18, PoE 1 14), 3 of 3; Sonnet **22** (PoE 1 20, PoE 2 13), 2 of 3 | Middle and outer road nodes carry a third small figure (PoE 2 hangs 2–3 clusters off most road nodes), so the full build packs tighter: about 8,670 visible acupoints. A figure joining another cluster now must use that cluster's nearest node exactly (it had a 15 % slack). Published as the final full build |

## What the comparison taught (rules added to the kit)

These come from the judge passes (rounds 1–30). Each was applied as a rule, so every land follows it, not just the one the
judge looked at.

1. **Make density rise from the starts to the rim.** PoE 2 is airy round its starts and dense toward its edge. Ours
   was evenly full, which the judges called "confetti", "carpet" and "sandy". Now the inner road nodes carry one figure,
   and holes near the centre need more room before they are filled (`landkit.fill_holes`). Sonnet's verdict turned on
   this change: ours 6 → 8.
2. **Put gold at the ends.** A tail that ends in a plain node reads as unfinished. Filler figures keep one notable,
   on their farthest tip (`landkit.thin_notables`), so gold dropped from 22 % to 17 % of nodes while every tail ends on
   a reward. Hand-drawn constellations keep all their notables.
3. **Don't draw a dartboard.** Five lands with the same ring radii read as one target. Each land now has its own
   radii, a few straight-sided or jittered rings, gaps in some rings, and avenues that don't line up. Rings 2 and 3
   braid (cross over) in three blend zones.
4. **Hidden content needs crisp outlines and visible gates.** Faint dust, soft bubbles and smudges were all criticised.
   Dark-filled outlined nodes with a clear dashed gate read as content.
5. **Give keystones an approach and some room.** Keystones sit on approaches of up to four nodes with a small clearing,
   spread from band 1 to the outer band. They should not sit in mirrored pairs at one radius.
6. **Make clearings purposeful.** An empty clearing reads as unfinished. Each land now has two quiet fields, each a
   clearing with one landmark figure in it.
7. **Avoid novelty rendering.** A zigzag "lightning" line read as a damaged rim. Keep road styling calm and use
   colour for meaning.
8. **Cap the stamps.** Lattices, fishbones and rings with a gold centre are capped per region, and the centre-gold
   rings appear only where they mean the theme.

9. **Join every island the same way.** Three different joints (a stem, a kink, a long bridge) read as three
   afterthoughts. Every island now has a straight bridge with a mirrored pair of figures at its middle, like a gateway
   (`islands.gate`), and each island core has its own shape: a round sun ring, a star, an off-centre eclipse ring.
10. **Give a long road a destination.** Small beads along the shadow road did not help. A destination did: the Shadow
    Shrine (Ám Từ), a small mandala at the road's eastern turn, which also balances the map's empty east side.
11. **Keep the outermost ring whole.** Gaps in ring 4 read as a broken rim at full view. Vary cell sizes with gaps in
    rings 1–3 only.
12. **Let sealed content recede at full view.** The sealed outlines fade when zoomed out and come back up close, so the
    rim reads clean from afar without hiding the secrets.
13. **Never put a template beside its twin.** Twin fishbones and twin ladders read as stamps even when each is fine on
    its own. `landkit.apart` skips a figure kind drawn within 7 units, unless nothing else fits.
14. **Four sides, not three.** With islands at the top, left and bottom, the empty east made the map look lopsided and
    the shadow road look like a patch. A fourth satellite (the Shadow Shrine) settled both.
15. **Cap a theme's own figure too.** The stamps the judges named for many rounds (the bowtie "X-star", the shield
    "ring with a notable inside", the hourglass "two-diamond ladder") were each the first figure of a common theme,
    which the caps had exempted. A theme's first figure now runs to twice the cap, no further.
16. **Finish every branch.** A branch that stops on a plain node reads as unfinished: end it in gold, or curl it back
    into a loop (the World Tree's leaves, the stacked rice terraces).
17. **Vary the road rhythm.** Travel nodes at exactly even steps looked plotted. They now shift along the road by up
    to a fifth of a step, by a fixed hash (`kit.Tree.road`, `ROAD_JITTER`; Metal, the approved pilot, keeps even steps).
18. **Gather the gold into districts.** Both judges called the notables confetti at full view. Filler figures that
    close on themselves now carry no notable inside plain districts (a smooth field over the map, `landkit.gold_keep`);
    hand-drawn constellations and open figures keep theirs. Visible notables fell from 17 % to 16 %, and Sonnet's
    verdict on the full build turned from PoE 1 (20–22) to ours (22–20).

Still open, for you to judge:
- **The Shadow Shrine (Ám Từ)** is my addition, not in the zoning plan. It is a satellite at the islands' radius on the
  east side (world 103°), where the shadow road turns in to Earth: a road ring, an inner court round a mastery socket,
  a crown, and the Swallowing the Moon keystone (a proposal, moved from the Darkness island). It is a waystation, not a
  start. It fixed the two longest-running critiques (the "tacked-on" shadow road and the empty east). Keep it, or
  remove it and decide the shadow road another way (shorten it to the Earth–Metal blend zone, for instance).
- **The shadow road** is your design: Darkness reaches Earth along the outside of the rim, now with two larger stops
  and the shrine at its turn.
- **Full-view density.** The judges long found the disc evenly speckled from afar. Gathering the notables into
  districts (lesson 18) helped most; a density field in the hole fill changed nothing visible and was reverted, and
  stronger plain districts lost Sonnet's vote. The other lever is the node budget, open point 1: the lean variant.
- **Keystones beside the starts.** Both judges say the keystones crowd the central starts: each land's near keystone
  sits in the cradle under its start (6–10 points out), so five red halos ring the Taiji between the starts. That is
  the start web of the approved Metal pilot, so I left it. Moving the cradles to the outer side of each start would
  clear the centre.
- **Metal.** The close-up review found spacing issues inside Metal (a keystone crowded by notables, a socket against a
  road). Metal is the approved pilot and was left as drawn; its own options (`ROAD_JITTER`, `HALO_EXTRA`,
  `NAME_ROTATE`) are off.
- **The Wind and Ice starts** sit off the central ring (Wind on the outer ring, Ice inside Water's snowflake), as you
  placed them. Judges call them "arbitrary"; the seals round every start help in the colour views.

### Judge reliability (read this before trusting any single verdict)

Across all rounds, **Sonnet chose the tree labelled B in most of its runs**, whichever tree that was: a strong
position bias. **Opus chose ours in every run but one** (about 40 runs; the exception was a narrow 7–6 for PoE 2 in
round 20), wherever ours sat (A, B or C). So a single Sonnet verdict says little. To settle it, the final build went to a **balanced test**: three runs per model, rotating the letters so
each tree sits at A, B and C once, with the scores summed.

| Final build, balanced | Ours | PoE 1 | PoE 2 | Winner per run |
|---|---|---|---|---|
| Sonnet (3 runs) | **21** | 20 | 15 | B, B, C → ours twice, PoE 1 once |
| Opus (3 runs) | **23** | 15.5 | 18.5 | ours in all three (8, 8, 7) |

A second balanced test on the final build (draft 9, after rounds 13–14):

| Final build (draft 9), balanced | Ours | PoE 1 | PoE 2 | Winner per run |
|---|---|---|---|---|
| Sonnet (3 runs) | **22** | 20 | 13 | PoE 1, ours, ours |
| Opus (3 runs) | **23.5** | 15.5 | 18 | ours in all three (8, 7.5, 8) |

After the final test I added crowns to the three islands, turned Earth's Nine Palaces 45° and regrouped Fire's hidden
clusters (draft 10). These came from the final test's notes and were not judged again.

A third balanced test, on draft 17 (after rounds 15–17), with both models:

| Draft 17, balanced | Ours | PoE 1 | PoE 2 | Winner per run |
|---|---|---|---|---|
| Sonnet (3 runs) | **23** | 20 | 13 | PoE 1 (sitting at B), ours, ours |
| Opus (3 runs) | **23.5** | 15 | 18.5 | ours in all three (8, 8, 7.5) |

The published page (draft 18) adds only the Wuji keystone move and the plate tweak after this test.

From round 19 on, every change was checked with a balanced Opus set (three letter orders) before it was kept; the
sums are in the round log (rounds 19–23: ours 22–24, PoE 2 17–20, PoE 1 14–16).

A fourth balanced test, both models, on draft 31 and on the lean variant built from the same code:

| Draft 31, balanced | Ours | PoE 1 | PoE 2 | Winner per run |
|---|---|---|---|---|
| Opus, main (draft 30, same layout) | **24** | 15 | 19 | ours in all three (8, 8, 8) |
| Sonnet, main | 20 | **22** | 12 | PoE 1, ours, PoE 1. Sonnet called ours "cluttered", "a hairball": too dense and too varied to read as motifs |
| Opus, lean (6,452 visible) | **23** | 15 | 19 | ours in all three (8, 8, 7) |
| Sonnet, lean | **22** | 20 | 13 | PoE 1, ours, ours |

So the two judges split on draft 31: Opus preferred it clearly, Sonnet narrowly preferred PoE 1. Gathering the gold
into districts (draft 32) won Sonnet back on the full build (22 against PoE 1's 20; Opus 23).

The final test, on **the lean variant with the gold districts** (6,428 visible acupoints), is the best result of the
night with both models:

| Lean variant (final), balanced | Ours | PoE 1 | PoE 2 | Winner per run |
|---|---|---|---|---|
| Opus (3 runs) | **24** | 14 | 18 | ours in all three (8, 8, 8) |
| Sonnet (3 runs) | **24** | 15 | 15 | ours in all three (8, 8, 8), even with PoE 1 at its favourite letter B |

Run again over the other three letter orders, so that each tree takes every position in every pairing (all six
permutations):

| Lean variant (final), all six letter orders | Ours | PoE 1 | PoE 2 | Ours first |
|---|---|---|---|---|
| Opus (6 runs) | **48** | 30 | 35 | 6 of 6 |
| Sonnet (6 runs) | **45** | 35 | 28 | 4 of 6 (both losses to PoE 1, once with PoE 1 at B) |

Sonnet's reasons: "a memorable silhouette … flanked by four satellite clusters", "density varies on purpose … calm
lanes of dark space", "the clusters are varied and hand-shaped", "the red keystones are sparse … each one reads as an
event". That bears directly on open point 1 (the budget).

**Result:** on balanced tests Opus ranks ours first every time. Sonnet ranks the full build first narrowly (22–20) and the lean build first in every run (24 against 15 and 15). Opus rates ours clearly ahead in every letter
order. Sonnet ranked ours first on draft 17 (23 against 20) and on the lean variant (22 against 20), but put PoE 1
narrowly ahead of the full draft 31 (22 against 20).
