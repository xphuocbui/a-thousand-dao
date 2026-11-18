# Authoring a Đạo Đồ land

How to draw one land of the Đạo Đồ so it reads like PoE's tree. Written 2026-11-08 after the Metal
land pilot. The user's verdict on that pilot: "ok looks good now". Apply these steps to the four other element lands,
the blend zones, Wind and the Thunder island.

- **Evidence:** `design/research/passive-tree-study.md`, findings 1–29 and the cluster shape audit.
- **Pilot:** `tools/design/dao_do_rework/regions/metal.py`, published at
  https://claude.ai/artifact/FhJRJHc3CAVwcbn7xhTGCf
- **Shape audit page:** https://claude.ai/artifact/JY97qwAu8nJfPgPJZeTDZV

## The tools

| File | What it does |
|---|---|
| `tools/design/dao_do_rework/build_region.py` | Builds a land from its spec. It prices nodes from the Modifier System, runs every check, and writes `<land>.json` and a viewer page. Run `python -I tools/design/dao_do_rework/build_region.py <land> <out_dir> [--labels]`. |
| `tools/design/dao_do_rework/regions/pens.py` | The drawing pens, shared by every land. `pict` hangs a figure off a node, `dress` gives one road node several figures with hand-chosen fallbacks, and `place_in` draws a figure in an open space and joins it at its nearest node. It also holds `PICT` (the figure library) and `lolli`, `leaf`, `span` and the rest. |
| `tools/design/dao_do_rework/holes.py` | The empty-space map. Run `python -I tools/design/dao_do_rework/holes.py <out_dir>/<land>.json <out.html> 2.0`. |
| `tools/design/dao_do_rework/region_viewer.html` | The viewer template. Add `#big&box=x0,y0,x1,y1` to the page URL to zoom for a screenshot; build with `--labels` to show node ids. |
| `tools/design/dao_do_rework/regions/<land>.py` | One spec per land. It defines `build(T)` and `dressing(T)`, plus the land's themes and keystones. |
| `tools/design/dao_do_rework/kit.py` | (2026-11-09) The drawing kit shared by every region: `Tree`, the fit check, ports and edge ports, and `check()` for one region or the whole tree. |
| `tools/design/dao_do_rework/build_tree.py` | (2026-11-09) Builds every region into one tree, joins the ports and checks the whole tree. Since 2026-11-12 every run writes a **new** graph version to `design/dao-do/versions/` (`gen-<date>[-lean]`, suffixed when taken) and never overwrites one; `--name`, `--note` and `--no-version` adjust that. Run `python -I tools/design/dao_do_rework/build_tree.py [<out_dir>]`; an `<out_dir>` also gets the old scratch `tree.json` and `tree.html` (from `tree_viewer.html`). Set `KMD_LIGHT=1` for the lighter variant. |
| `tools/design/dao_do_rework/editor/serve.py` | (2026-11-12) The Đạo Đồ editor. Run `python -I tools/design/dao_do_rework/editor/serve.py`; it opens the editor in the browser on `127.0.0.1`. Move, rotate, scale, mirror, duplicate and copy nodes; swap two nodes' places (`X`, links stay) or positions (`Shift+X`, links follow); select links by click or box (`E`) and curve one by dragging it; add, link, split and delete; set kind, theme, cluster and region; add modifiers and effects from pickers that read `modifiers.md` and `effects.md` live, or free text (marked). Checks (unreachable, too close, crossings, links over nodes) re-run after every edit. **Save** overwrites only the open version (its previous copy goes to `versions/.prev/`); **Save as new** writes another. Unsaved edits survive a closed tab. Press `?` in the editor for every shortcut. |
| `tools/design/dao_do_rework/versions.py` | (2026-11-12) The version store shared by `build_tree.py` and the editor: a version file is the kit's `tree.json` plus a `meta` block (name, created, saved, source, parent, note). Node modifier lines carry `mod_refs` (a catalogue id, `null` for free text; absent means generator placeholders). |
| `tools/design/dao_do_rework/editor/publish_view.py`, `export_catalogue.py` | (2026-11-12) `publish_view.py <out.html> [<version>]` builds a read-only copy of the editor around one version, to share as an artifact. `export_catalogue.py [<out.json>]` shows what the pickers read from the two GDDs. |
| `tools/design/dao_do_rework/regions/common.py`, `landkit.py`, `figs.py` | (2026-11-09) Shared geometry, themes and talent roads; the land toolkit (start web, road skeleton, dressing and hole-fill rules, hidden band, quiet fields); 27 themed figures. |
| `tools/design/dao_do_rework/judge/judge.sh` | (2026-11-09) Blind comparison with PoE 1 and PoE 2: it renders all three trees in one neutral style and asks a fresh `claude -p` session to judge. Rotate the letters; a single Sonnet verdict is position-biased. |
| Region options (2026-11-09) | Set in a region spec: `ROAD_JITTER` (travel nodes shift along their roads; 0 keeps even steps), `ARC_TOUCH_OK` (a stem may touch its own road's arc), `HALO_EXTRA` and `HALO_AVOID` (small hidden clusters added in the band's widest gaps, kept off island bridges), `NAME_ROTATE` (each region starts each notable name bank at its own place). Metal sets all of them off, so the pilot builds as approved. The rules learned from the judges (caps, no twins, gold districts, keystone clearances) live in `landkit.py`; `design/research/dao-do-overnight.md` lists them with their reasons. |

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

## Cluster rules (user, 2026-11-15)

Set while reviewing the 2026-11-12 lean tree. Measured on that tree in the symmetry page,
https://claude.ai/artifact/NhVpEF4ArVTssfs6mNCNtT (its wasted-node numbers use the strict, shortest-route measure);
the pilot that applies them is https://claude.ai/artifact/KytMXG91CpDnhJ5tGe24AQ (version `gen-2026-11-15-lean-rules-3`). `tools/design/dao_do_rework/cluster_rules.py` checks them on any
version, and the editor runs the same checks live.

1. **A cluster mirrors about the line through its entry, notables included.** Every node, minor or notable, has a
   twin of the same kind across that line, or sits on it. A cluster with several outside links may mirror about a
   line that maps those links onto each other. "Symmetric clusters including the symmetry with its notable node."
   - Exempt for now: the themed figures drawn lopsided on purpose (bolt, spiral, wave, antler and the other
     `ASYM` figures). The user has not yet said whether they stay.
2. **No dead-end minor nodes.** Every minor node lies on some route between the cluster's entry, its notables and
   its other outside links. So the far ends of a figure are notables or keystones, and nothing hangs off a figure
   that leads nowhere (the lifespan drum's triangles). "A far end node of a cluster, unless it is used to
   connect/shorten the path to another notable, should not be a far node of a cluster."
   - A longer route round a loop is allowed: it is an alternative path, and in the content pass it must carry
     different modifiers from the short way (user: in PoE a longer route "offers a different modifier to the shorter
     path (so basically an alternative), or is used as a connector to another notable node in the same cluster").
   - Measured over clusters that hold a notable: dead ends are 0.2 % of PoE 1's minor nodes and 1.6 % of PoE 2's (PoE
     2 has a few); the 11-12 tree had 18 %. Counting every node off the shortest routes instead gives 9 %, 6 % and 33 %.
3. **No notable at the door.** Follow the stem in to where the figure opens: the first notable sits at least two steps
   past that point (PoE 2: 97 % of figures at least three deep). A radial figure (pinwheel, star, fan, snowflake) is
   entered at its hub, and either the hub is its first notable or each arm ends in one. "Would be better if the first
   notable is the center of the blade, or the start connects to the center of the blade."
4. **Every cluster holds at least one notable.** The 11-12 tree had 82 clusters with none.
5. **Sister sets, rarely.** One figure carrying one notable per element, with matching wording, like PoE 2's
   Stormwalker, Frostwalker and Flamewalker (one mirrored figure) or PoE 1's three Walkers (three parallel lanes).
   About one per land, best in the blend zones and the hub.
6. **Mirrored pairs across a road, rarely: 5–10 % of facing pairs.** Where a road node carries one cluster on each
   side, the two usually stay a big one and a small one (Dos, below). In 5–10 % of those facing pairs, the two are the
   same figure mirrored across the road.

**Where the rules live in the tools (2026-11-15).**
- `cluster_rules.py <version.json> [--region r] [--list]` reports rules 1–4 and 6 for a version;
  `--templates` checks every figure in `pens.PICT` on its own; all 58 pass (the taiji, the centre start, is left as
  drawn and is exempt from rule 1 with the whirl, since both turn about their centre). The editor's Checks tab runs the same tests after every edit, rings dead-end minor nodes
  cyan, and shows the mirrored-pair rate; its counts match the script's.
- `pens.place_in` joins a figure at its entry and turns it to face the road node, so its mirror line runs through
  that node (`axial=True`); the entry must still be the figure's nearest node to the road (Don'ts, below).
- `landkit.thin_notables` no longer strips gold freely (the judges' "too much gold" rule, `THIN_NOTABLES = True` to
  restore). It keeps the fewest template notables that still pass rules 1–4 on the figure, never fewer than one, and
  leaves no plain loop more than `THIN_SLACK` (2) steps longer than the short way. Hand-drawn constellations keep all
  their notables, as before.
- `landkit.mirror_pair` gives a hashed `PAIR_SHARE` (0.06) of the land road nodes the same figure on both sides; the
  tree comes out at 5 of 61 facing pairs (8 %), three of them the islands' gateway pairs.
- `landkit.LIGHT_FILL_ROUNDS` (1): hole-fill passes in the lean variant. The cut dead-end nodes used to fill space:
  with one pass Earth has 34 square units open at clearance 2.0 (16 before the rules); two passes give 24 and grow
  the tree from 6,979 to about 7,400 nodes (7,115 before). Open for the user.
- Not reached by the templates: hand-drawn set pieces (the Metal pilot, start webs, keystone spurs, the big
  constellations) and road connectors. `cluster_rules.py --list` names them.

**Land sizes (user, 2026-11-15).** "Each land has roughly the same amount of nodes, including the chaos land. Adding
more is preferable to trimming." Then: 930 is too big for Chaos, "make it comparable and stronger"; the islands take
the same treatment. Version `gen-2026-11-15-lean-chaos-2`:

| Land | Nodes | How |
|---|---|---|
| Fire, Earth, Metal, Water, Wood | 903–962 | unchanged |
| Chaos (the centre) | 494 | `push.py` moves every land and island out by `common.LAND_PUSH` (9) after drawing; the hub (`hub.py`) fills the room: a Source ring road, five Source roads, three new keystones (proposals) off the land axes, every road node dressed, holes filled |
| Light, Darkness, Thunder | 544–588 | an outer band on each island's far side (`islands.band`, `band_fill`), joined to the crown by three spokes; Darkness's shadow road, bridge and the Shadow Shrine (kept separate, user) stay bare |
| Blend zones | 424–486 | unchanged |

- Chaos and the islands are smaller than a land and stronger per point: their figures keep all their notables
  (`cfg["rich"]`), about 1 notable per 4 nodes against about 1 per 6.6 in the lands.
- The push is rigid: roads move straight out, every cluster moves as one piece with the node it hangs from, an
  island's core moves whole, and `push.repair` re-places the few clusters the push brought too close to something.
  `build_tree.py --push D` overrides the amount, but the hub is drawn to `HUB_R` (9.9 + `LAND_PUSH`) either way, so
  change `LAND_PUSH` instead; a smaller push alone would put the hub over the lands. Versions record the push
  (`"push"`), and the editor and tree viewer shift their guide rings by it.
- The push opens the inner bands of the lands: sideways spacing grows about 1.5× at the start ring and 1.3× at ring 1,
  because the holes were filled before the push. Visible in Fire's start web; a fill pass after the push is open.
- The Đạo Đồ GDD's measured distances and map size describe the unpushed map; they are stale until the content
  pass re-measures them.

How to fix a failing figure, in order of preference: move its notable to the far point on its axis (a ring puts it
opposite the entry, so both halves are routes to it); give a radial figure its notables at the arm tips in mirrored
pairs, or make the hub the notable and enter there; cut an arm that leads nowhere, or join it to a neighbour as a
shortcut. Keep notable counts and cluster sizes close to the targets above while doing so.

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
> `design/research/dao-do-overnight.md`, which also holds the whole-tree build and the PoE comparison.

- **Budget:** the Metal land holds about 825 nodes against the 600 planned per element. Either the 5,000-node total
  grows, or the other lands are drawn a little lighter.
- **Summit bypass:** the summit has no road beside it on the centre road.
- **Start web:** 72 nodes within 9 points, against about 130 for PoE 2.
- **Attributes:** which attribute each element's roads give (Metal's +0.4 root bone, căn cốt, is a proposal).
- **Content:** Metal's own keystones (the three starter keystones are placeholders), cluster mastery (Tinh Thông),
  and notable names beyond the small per-theme banks.
- **Still to draw:** the other lands, the blend zones, Wind and the Thunder island, then joining them into one tree.
