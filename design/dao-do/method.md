# Đạo Đồ: how the graph is made (method, as of 2026-11-19)

The Đạo Đồ (the passive tree; skill-tree rename of 2026-11-18) is a PoE 2-like graph: roads, cells between the roads,
and figures (pieces) of small, notable and keystone nodes hung from the roads. This is how it was built, so the next
stage, filling in the nodes, starts from a known state. The rules themselves are in `rules-2026-11-18.md` (3.1 how we
work, 3.2 hard rules, 3.10 cells); that file's section 7 (tools) is superseded by this one.

**What worked (user, 2026-11-19: "I think we did 2 things right"):**
1. **Divide by cell, then design cell by cell.** The roads split the tree into cells; each cell is designed on its
   own, in its own file section, judged on its own, before the next. Earlier whole-tree and whole-land passes kept
   converging on the same stamped tree (rules section 2).
2. **Let OpenAI generate the layout and the pictures.** For a place that needs a figure, the image model draws ideas
   over the real roads, the user picks, and the pick is traced. OpenAI also designed pieces directly (the rim pagoda).
   It gives variety and a look the user can choose from, which hand-placing alone did not.

Current state: 7,840 nodes, 856 pieces; 0 crossings, only the base map's 4 old spacing warnings, every piece passes
R0-R4, every node reachable from the start. Built by `sh tools/design/dao_do_rework/cells/integrate.sh <tag>` (from the
repo root) into `design/dao-do/cells/out/<tag>-map.json`; deterministic (two builds of the same files are identical).
Frozen snapshot for the content work: `cells/versions/v5-frozen-2026-11-19/` (earlier: v4-frozen, v3-islands, v2-night); official: `cells/official-2026-11-18/`.

## 1. The layers

1. **Roads (`cells/base-map.json`).** Travel nodes and road links: the five lands' road lattices, the hub's two rings,
   the islands' road circles, the rim, the border roads, the starts and their own figures, keystone spots. Roads are
   the user's; change one only when the user approves (rules 3.1.7). Changes so far are recorded where made (e.g.
   the hub's five spokes removed 2026-11-19, commit 18d72da).
2. **Cells.** The faces between road walls (`cells/cells.json`, `cells/inventory.json`). Every piece belongs to one
   cell and hangs from at most two road nodes of it.
3. **Pieces (the figures).** Python files that build `{piece name: (nodes, links)}` per cell:
   `nodes = {key: ((x, y), kind)}`, `links = [(a, b, arc centre or None)]`, road nodes given by their integer ids.
   `tools/design/dao_do_rework/cells/celllib.py` compiles them onto the base map; a node's name is
   `c<cell> <piece> <key>`.

## 2. How pieces are made

There are two ways, by place.

**Lands, borders, rim, cells 14 and 93: drawn by hand** (`cells/lands/<land>.py`, `borders.py`, `cell14.py`,
`cell93.py`), region by region. Claude places every piece and join; scripts only compile, check, render and report
(rules 3.1.1, memory "hand-author, no scripts"). The family sheet (`design/dao-do/families/`, 11 small families) gives
the small forms; medium and big clusters are drawn inline where they go and used once. Lessons the user gave: combos
first, fill after; each cell its own centre figure, place and family mix ("don't be repetitive"); lands visibly
symmetric (70-80% of road nodes mirrored); figures split across a wall road, mirrored each side; no stamped shapes;
no illustrated lands. The v2 night run's briefs (`cells/*-brief.md`) record the density, rim, consolidation, fill and
review passes the land files cite.

**Islands and the hub: traced from a picture the user picked** (the "Sun method", user: "the sun method is very good").
Used for the Sun (931), Moon (933), Thunder (932), the Shadow Shrine and its lotus (933), Chaos (79) and the five
lands' first cells (1-5).

1. *Layout.* Render the place's empty roads (`tools/design/dao_do_rework/cells/render_box.py`), with the figures to
   keep left in if the picture must weave round them.
2. *Pictures.* Ask OpenAI's image model to draw ideas over that layout, keeping every road where it is, in a
   traceable style: thin single lines, beads at even spacing, lines starting from roads or other lines, no crossings,
   clear air (`tools/design/dao_do_rework/underlay/img.py`, model `gpt-image-2.6-sunburst`, `/v1/images/edits`; key
   from `OPENAI_API_KEY`, never written down). Several ideas, two versions each; check each keeps the roads (road
   hits) before showing it.
3. *Pick.* Show them in the viewer artifact; the user picks (and often combines: "Fusang 2 inside, Corona 1's rays
   outside"; "Add beside 1's elements, Replace 1's swirl"). Mirror the picture if its elements face the wrong lands
   (Chaos: across the Earth axis).
4. *Trace.* Trace the picked picture, dot for dot, not "in its spirit" (memory "trace a picked underlay"):
   - by hand: read each line's waypoints off gridded close-ups and let `trace_lib.even_chain` follow the drawn
     line between them, nodes evenly along it (Sun's tree, Moon, Thunder, Shrine, lotus); circles laid exactly round
     measured centres; symmetric figures traced on one half and mirrored (`trace_fine.mirror`);
   - by its line network, for big dense drawings: `underlay/skel2.py` thins the ink to centre lines and splits it
     into strokes between ends and junctions (loops kept); junctions become forks, free ends notables (the five
     element motifs). Inner lines that only touch an outline (leaf veins, blade notches) are dropped first;
   - regularised, where the drawn lines cannot meet the rules (the hub swirl: a piece holds at most two roads, so the
     picture's arms became ten log-spiral arms ring to ring and ten tributaries, turning as the picture's do).
   Say which changes the rules forced, and join loose parts where the picture floats them (a stem to a road, a band
   to the web).
5. *Settle.* Make it meet the spacing rules (3.2): `trace_fine.thin_at` and `settle` drop a node on a line before a
   dead-end stroke and a dead-end stroke before a loop edge, never a door's first node; place nodes a little over
   the minima (0.95 / 0.65) so settling and the audit agree. Where the picture is finer than the rules and the user
   approves, the place gets the Sun's looser spacing (3.2 exception: Sun, Shrine, lotus).
6. *Check, look, ask.* Overlay the trace on its picture (`underlay/overlay.py`) and look at full-resolution crops;
   rebuild the whole tree and audit; show the user in the viewer. Iterate on what the user flags (they judge by eye:
   "too dense", "a flare is missing", "not connected").

The pictures, prompts and measured data are in `design/dao-do/underlays/<place>/` (README there); the scripts in
`tools/design/dao_do_rework/underlay/` (README there).

### Where the prompts and pictures are kept (for future reference)

| What | Where |
|---|---|
| The picked pictures, their prompts (`prompt-*.md`), the empty layouts they were drawn over (`layout*.png`) and the model's replies (`*-meta.json`) | `design/dao-do/underlays/<place>/`: `sun/` (Fusang 2 + Corona 1 combined as `inout-3.png`), `moon/` (Moon 2), `thunder/` (Thunder 3), `shrine/` (Eclipse 2, Lotus 1), `chaos/` (Replace 1, Add beside 1), `pagoda/` (OpenAI's code design, round 2) |
| Every idea of the 2026-11-19 round for the Shrine, Thunder and Chaos (4 ideas x 2 versions each), their 12 prompts, layouts and contact sheets | `design/dao-do/underlays/ideas-2026-11-19/` (Thunder's drums, dragon, leiwen and lightning tree are unused, ready for its redesign) |
| The first round of island ideas (sketch 3 style) | `design/dao-do/underlays/first-ideas-*` |
| Earlier ideas removed in the cleanups (Sun ideas Fusang 1, Crow, Fusburst, Fusflame, Fusrays, Corona 2; Moon 1-4, Thunder 1-3, Chaos 1-3; OpenAI's code designs of all four islands, rounds 1-2) | git history: `git show 6a97947^:design/dao-do/cells/openai/<path>` (removed in 6a97947) and `git show 064c229^:design/dao-do/cells/openai/<path>` (removed in 064c229) |
| Every picture shown to the user, as JPGs, in the galleries below the tree | the viewer artifact https://claude.ai/artifact/RJmdZHYeMaMAVobqfZNYkn |

The prompt core that made the pictures traceable (reuse it; put the place's description and the art direction
before it):

```text
Image 1 is the exact road layout of <the place: its roads, rings, starts>. Turn it into an artistic underlay sketch
showing <the idea>.
KEEP image 1 EXACTLY: same framing and scale; every gold road, ring and node, the white start and any red keystone
stay at exactly the same pixel positions. Only ADD the artwork, <where>.
HOW IT MUST BE DRAWN (it will be traced into nodes): thin clean single lines with small round beads along them at even
spacing, a larger bead at each line's end; lines start from a road node or from another line; lines never cross each
other or the roads; leave clear air between lines; no fills, no shading, no text.
PALETTE: <colours>.
FINISH: near-black background; roads stay gold; flat 2D, no glow, no gradients, no frame, no starfield.
```

When figures already in a cell must stay, add: "those cells already hold small gold node figures: keep every one
exactly as it is, and weave the lines round them through the empty space, never touching them" (Add beside 1).

## 3. Rules every piece meets (checked at each build)

- Cluster rules (`tools/design/dao_do_rework/cluster_rules.py`): R0 joined; R2 no dead-end minor node (a loop hung at
  one point needs a notable on it); R3 the first notable two steps past where the figure opens (measured from the
  first fork past the door); R4 at least one notable.
- Spacing per node (`tools/design/dao_do_rework/authoring/audit.py`): other pieces and roads 0.9 to nodes, 0.6 to
  links; own piece 0.7 and 0.45; no crossings; the Sun exception where approved. A road node links to a piece; a piece
  hangs from at most two road nodes; pieces never touch each other or a start figure.
- Keystones: alone on one link to a road node (`keystones_islands.py`, the lands' rim pairs).
- Every node reachable from the start (the audit reports it).
- Node density on traced lines: the user wanted them sparse (spacing along the lines: swirl 1.8, element motifs 1.7,
  eclipse 1.45, lotus 1.55).

## 4. Build, view, save

- **Build:** `sh tools/design/dao_do_rework/cells/integrate.sh <tag>`: compiles cells 14 and 93, the five lands, the
  borders, the Sun, Moon, Shrine, Thunder, the Chaos swirl and elements, the pagoda and the island keystones; audits;
  checks the cluster rules; colours the links (`colour_links.py`, from the pictures); renders the whole tree and each
  land. Output in `cells/out/` (scratch, ignored).
- **View:** `tools/design/dao_do_rework/cells/viewer_svg.py <map> tree-col.svg` draws the zoomable vector tree (links in
  their picture colours) for the viewer artifact https://claude.ai/artifact/RJmdZHYeMaMAVobqfZNYkn, where the user
  gives verdicts.
- **Save:** on the user's word, freeze a snapshot in `cells/versions/<name>/` (map, base map copy, `source/` of the
  files compiled, renders, `tree.svg`, README of what changed, SHA256SUMS), checked to rebuild byte for byte. Never
  promote a version to official without the user's word. Commit only your own paths (`git commit -- <paths>`).

## 5. Before filling in the nodes

- **Frozen again as v5: `cells/versions/v5-frozen-2026-11-19/`** (user, 2026-11-19: "freeze it then we go to the next
  session"; built at 82ef4e1; 8,038 nodes, 867 pieces). The content work keys to v5. Between v4 and v5 the map was
  unfrozen for Thunder's bolts (`thunder_bolts.py`, OpenAI's inside bolts `oai_thunder.py`) and Water's rim (three
  snowflakes, `water_rim.py` and `oai_water.py`); see v5's README.
- **The freeze before: `cells/versions/v4-frozen-2026-11-19/`** (user, 2026-11-19; commit 337f464; 7,840 nodes,
  856 pieces). Node names of traced pieces (`n_123`, `v45`) are produced by the tracing and change if a piece is
  re-traced, so key content on v4's map (or on piece + role, e.g. a piece's notables), not on keys that a re-trace
  regenerates. If the graph must change once content exists, change it deliberately and carry the content across.
- **What exists for content:** `design/gdd/dao-do.md` (the GDD: the 25 capabilities, the node kinds),
  `big-clusters-draft-2026-11-18.md` (80 big clusters with picture and idea, all 25 capabilities placed; approved),
  `design/gdd/effects.md`, and the land themes in `tools/design/dao_do_rework/regions/common.py`. Rules decision 6.5:
  content first for big clusters; small and medium clusters drawn without content, their passives assigned later.
- **Still open on the graph:** the GDD's file table still names tools removed in the 2026-11-19 cleanups (Thunder was
  redone before v5; the user: "the thunderland works").
