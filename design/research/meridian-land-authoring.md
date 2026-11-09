# Authoring a Kinh Mạch Đồ land

How to draw one land of the Meridian Map (Kinh Mạch Đồ) so it reads like PoE's tree. Written 2026-11-08 after the Metal
land pilot. The user's verdict on that pilot: "ok looks good now". Apply these steps to the four other element lands,
the blend zones, Wind and the Thunder island.

- **Evidence:** `design/research/passive-tree-study.md`, findings 1–29 and the cluster shape audit.
- **Pilot:** `tools/design/meridian_rework/regions/metal.py`, published at
  https://claude.ai/artifact/FhJRJHc3CAVwcbn7xhTGCf
- **Shape audit page:** https://claude.ai/artifact/JY97qwAu8nJfPgPJZeTDZV

## The tools

| File | What it does |
|---|---|
| `tools/design/meridian_rework/build_region.py` | Builds a land from its spec. It prices nodes from the Modifier System, runs every check, and writes `<land>.json` and a viewer page. Run `python -I tools/design/meridian_rework/build_region.py <land> <out_dir> [--labels]`. |
| `tools/design/meridian_rework/regions/pens.py` | The drawing pens, shared by every land. `pict` hangs a figure off a node, `dress` gives one road node several figures with hand-chosen fallbacks, and `place_in` draws a figure in an open space and joins it at its nearest node. It also holds `PICT` (the figure library) and `lolli`, `leaf`, `span` and the rest. |
| `tools/design/meridian_rework/holes.py` | The empty-space map. Run `python -I tools/design/meridian_rework/holes.py <out_dir>/<land>.json <out.html> 2.0`. |
| `tools/design/meridian_rework/region_viewer.html` | The viewer template. Add `#big&box=x0,y0,x1,y1` to the page URL to zoom for a screenshot; build with `--labels` to show node ids. |
| `tools/design/meridian_rework/regions/<land>.py` | One spec per land. It defines `build(T)` and `dressing(T)`, plus the land's themes and keystones. |
| `tools/design/meridian_rework/kit.py` | (2026-11-09) The drawing kit shared by every region: `Tree`, the fit check, ports and edge ports, and `check()` for one region or the whole tree. |
| `tools/design/meridian_rework/build_tree.py` | (2026-11-09) Builds every region into one tree, joins the ports and checks the whole tree. It writes `tree.json` and `tree.html` (from `tree_viewer.html`). Run `python -I tools/design/meridian_rework/build_tree.py <out_dir>`. Set `KMD_LIGHT=1` for the lighter variant. |
| `tools/design/meridian_rework/regions/common.py`, `landkit.py`, `figs.py` | (2026-11-09) Shared geometry, themes and talent roads; the land toolkit (start web, road skeleton, dressing and hole-fill rules, hidden band, quiet fields); 27 themed figures. |
| `tools/design/meridian_rework/judge/judge.sh` | (2026-11-09) Blind comparison with PoE 1 and PoE 2: it renders all three trees in one neutral style and asks a fresh `claude -p` session to judge. Rotate the letters; a single Sonnet verdict is position-biased. |
| Region options (2026-11-09) | Set in a region spec: `ROAD_JITTER` (travel nodes shift along their roads; 0 keeps even steps), `ARC_TOUCH_OK` (a stem may touch its own road's arc), `HALO_EXTRA` and `HALO_AVOID` (small hidden clusters added in the band's widest gaps, kept off island bridges), `NAME_ROTATE` (each region starts each notable name bank at its own place). Metal sets all of them off, so the pilot builds as approved. The rules learned from the judges (caps, no twins, gold districts, keystone clearances) live in `landkit.py`; `design/research/meridian-tree-overnight.md` lists them with their reasons. |

**Coordinates.**
- A land is drawn in (u, v): v runs outward along the land's axis and u runs across it.
- One unit is one ordinary link.
- `P(r, θ)` gives a point by radius and degrees off the axis.

The fit check in the builder (`Tree.fits`) refuses any figure that leaves the land, sits within 0.72 of a node, lies
on a link, or crosses one.

## The steps

1. **Frame.**
   - Set the land's axis, half-angle (23°) and rim.
   - The start sits at r 17.
   - Ring roads sit at about r 30.5, 44.5, 58.5 and 70, each band about 13 units deep; the rim is at 76.
   - Every ring ends in exits to the blend zones, and the ring through the start ends in exits to the neighbouring starts.
2. **Start web** (PoE 2's twin hubs).
   - **Hubs:** two hub notables, one per identity (sword and forge in Metal), each on a leg of four nodes from the start.
   - **Lanes:** a dome joins the hubs with the element's notable on top. A low lane under it holds a universal notable.
   - **Under the start:** a cradle, with the near keystone at its tip 6–10 points out (Called Blow is 7).
3. **Roads.**
   - The ring road runs through the start.
   - One road leaves each hub, through a short junction, heading away from the dome. One road leaves the dome's top.
   - Ring roads are arcs. Spokes run along both edges at about ±21°, and avenues run through the constellations.
   - Space travel nodes 4.5–5 units apart on rings and spokes. Few road nodes, each carrying several clusters, is what PoE does.
4. **Constellations.**
   - Give each band three: the left identity, the element in the centre, and the right identity.
   - Draw each as one composed group, not as separate clusters.
   - Join each to its nearest road node (`nearest`).
   - Neighbouring constellations reach each other through a node or two.
   - Metal's set:

     | Band | Left identity | Centre (element) | Right identity |
     |---|---|---|---|
     | 1 | three-lane bridge | great wheel | gourd |
     | 2 | crown (Iron Body ring above it) | four-leaf lattice | shared zigzag with a ring (trident above it) |
     | 3 | sword tomb | summit | anvil |
     | Between rings 3 and 4 | blade pinwheel | | furnace square |
     | Beyond ring 4 | sword peak | Metal apex | furnace peak |

5. **Dress every road node** with two or three figures in `dressing(T)`, choosing shape, theme and direction by hand.
   - Inner road nodes carry two small figures. Outer ones carry a big figure (7–12 nodes) and a small companion.
   - Universal themes are scattered across the land. Identity themes stay on their side.
   - Give each figure a fallback list (`[first choice, second, kite]`) so a tight spot still gets something.
6. **Fill the holes.**
   - Build, then run `holes.py` at 2.0, then at 1.6.
   - Fill every hole with a symmetric figure using `place_in`, aimed at the hole's peak. It joins by its nearest node to the nearest road node, or failing that to another cluster's nearest node.
   - Leave the centres of the great rings and the start dome open: that's where a cluster mastery (Tinh Thông) would sit.
7. **Bypass check.** If a road passes through a cluster, there must be a road around it. Hubs on roads are fine;
   whole clusters a player cannot skip are not. In Metal, the forge anvil needed a Water-edge highway. The summit on
   the centre road still has none.
8. **Variety check.**
   - Read `metrics.shapes` in the build output.
   - No figure should be more than about 12 % of clusters: no runs of kites, hearts or hexagons.
   - Swap repeats for other shapes from the catalogue.
9. **Look at it.**
   - Take a full screenshot and labelled zooms of each band, and fix what reads badly.
   - Publish the page and show the user before moving on.

## Targets

| Measure | PoE | Metal pilot |
|---|---|---|
| Roads join a cluster at its nearest node | 79 % (PoE 2), the rest are hubs | 100 % |
| Road nodes carrying a cluster | 88 % | 93 % |
| Road nodes carrying 2+ clusters | 75 % | 65 % |
| Small cluster sharing a road node with a 6+ cluster | 58 % (PoE 2) | 76 % |
| Median cluster size, inner / middle / outer third | 4 / 5 / 5, 34 % of outer with 7+ | 6 / 6 / 7, 74 % of outer with 7+ |
| Small nodes before a notable | mostly 2–3; 0 only for hubs | mostly 2–3 |
| Clusters with 2+ notables | 29 % | about a third |
| Arcs and rings among clusters | 31 % (PoE 2) | rings only where they mean something |
| First notable · nearest keystone | 5 · 6–13 points | 4 · 7 |
| Crossings, nodes closer than 0.6, links grazing a node | 0 | 0 |
| Open space with clearance > 2 units (outside mastery spots) | none | about 5 square units |

## Dos

- Draw by hand. The pens only nudge a figure (a turn of up to 60°, or a shrink to 85 %) to clear its neighbours.
- Compose in groups: a band is a set of constellations that reach each other, not a scatter of pockets.
- Join a cluster at its nearest node, from both sides when two clusters meet.
- Give every road node two or three clusters, one of them big, and make clusters bigger toward the rim.
- Use PoE 2's figures, and pick ones that mean something for the theme: a heart for Tâm Cảnh, an hourglass for
  lifespan, an eye for thần thức, swords and crosses for the sword side, a coin for Metal.
- Prefer symmetric figures: kite, diamond, bowtie, theta, snowflake, concentric rings, lens, window, spoked ring,
  hexagon, wheel and lollipop.
- Put several notables in a cluster, with small nodes before each.
- Keep the old map's spokes and rings, the layout the user prefers.
- Measure before you judge: run `holes.py` and the checks, and read the screenshot.

## Don'ts

| Don't | Why (the user, 2026-11-08) |
|---|---|
| A square or lattice highway | "The square design looks really bad. PoE and PoE2 does not use square attribute highways" |
| Filling space from a shape library around a grid | "This feels nothing like it, too generated" (v4) |
| Join a cluster at a far node while a nearer one faces the road | "Autumn Killing Qi … why doesn't it connect to the closest one" |
| Crescent 3–4 node arcs as the default pocket | "I am really disappointed by the amount of crescent shape node clusters" |
| Straight two- or three-node sticks | v1 review: "really badly designed, unlike poe at all" |
| One cluster per road node everywhere | "sometimes a highway node could have multiple cluster attached" |
| Small outer clusters standing alone | outer clusters "tend to be bigger … almost always have a bigger cluster starting from the same highway node" |
| A road that runs through a cluster with no way around | "the purpose of the highway is so user could skip a cluster" |
| Many copies of one figure | "there is an abundant of some shapes, like the heart and diamond" |
| Loose bands and big gaps | "it still feels loose, especially the last ring" |
| Figures shrunk until they read as blobs | the dense figures have minimum sizes in `pens.DENSE` |

## Open for the whole tree

> **Provisional answers (2026-11-09, overnight):** each point below is answered, provisionally, in
> `design/research/meridian-tree-overnight.md`, which also holds the whole-tree build and the PoE comparison.

- **Budget:** the Metal land holds about 825 nodes against the 600 planned per element. Either the 5,000-node total
  grows, or the other lands are drawn a little lighter.
- **Summit bypass:** the summit has no road beside it on the centre road.
- **Start web:** 72 nodes within 9 points, against about 130 for PoE 2.
- **Attributes:** which attribute each element's roads give (Metal's +0.4 root bone, căn cốt, is a proposal).
- **Content:** Metal's own keystones (the three starter keystones are placeholders), cluster mastery (Tinh Thông),
  and notable names beyond the small per-theme banks.
- **Still to draw:** the other lands, the blend zones, Wind and the Thunder island, then joining them into one tree.
