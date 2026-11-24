# UX Spec: Đạo Đồ View

> **Status**: In Review, lean round 1 NEEDS REVISION (5 blocking, 8 advisory: applied 2026-11-24, see below); written
> 2026-11-24 night by Claude under the UI delegation (memory ui-design-delegated). **Look (user 2026-11-24: "don't we
> just use v5 ... do something similar to" the viewer artifact):** the canvas draws v5 the way the v5 viewer artifact
> draws it (claude.ai/artifact/RJmdZHYeMaMAVobqfZNYkn): its palette, dots by class, roads and links, and its Stats
> colouring by stat family; the painted framed icons it shows when zoomed in wait for the release pass (user 2026-11-20).
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **GDDs read**: `design/gdd/dao-do.md` (rules 1–5 access and starts, 3 the Chaos gate and routes, 4 purity scaling, 16
> capability notables, 20), `design/ux/hud.md` (full screens; element 5 D; End turn's unspent-points pip),
> `interaction-patterns.md` (Tree view), memory dao-do-node-art (colour = group, frames by class)
> **Patterns used**: Full screen, Tree view, Searchable list (search pulses), Confirm in place, Reply strip.
> **Rework (user 2026-11-24: "It should be like PoE's skill tree. Please add with icon, and hovering over it gives the
> stat")**: the canvas draws every node's framed painted icon (the viewer's icons, now wired in), PoE-style dark ground,
> dim unallocated and bright allocated nodes with gold paths; the D3 inspector is replaced by a hover card beside the
> pointer (name, stats one per line, capability / Effect, the cost to reach it); a click plans or unplans. The rows below
> that mention the inspector now describe the hover card.

---

## Purpose & Player Need

"Where can my points take me, and what do I get on the way?" The whole Đạo Đồ (8,051 nodes: roads, small marks,
notables, keystones, the eleven starts) on one zoomable canvas: what is open, what is reachable now, the shortest
route to any node with its point cost and what the route gives, a plan of several routes held as pending until Apply,
and search. With no start yet, the start chooser.

## Player Context on Arrival

From the Đạo Đồ button (Z2) or D, the character sheet's Đạo Đồ link, or End turn's reminder pip (unspent points).
Usually after a level or a breakthrough gave points, or while planning a build.

## Navigation Position

A **full screen** (hud.md Layout Zones): it replaces the map and the zones but Z1; ← Back to map; Esc backs out. It has
uncommitted edits (a pending plan), so leaving with a plan asks: keep (the plan stays for next time), discard, or
cancel (hud.md: "A full screen with uncommitted edits ... asks before leaving").

## Entry & Exit Points

| Entry | Opens at |
|---|---|
| Đạo Đồ button, D, the character sheet | Centred on the player's open nodes at a mid zoom |
| No start yet | The start chooser over the canvas |

Exits: Back to map (asks when a plan is pending), Esc (first clears a selection, then as Back).

## Layout Specification

### ASCII Wireframe (full width under Z1)

```
+--------------------------------------------------------------------+
| [← Back to map]  Đạo Đồ  · 3 points unspent · 41 open · plan: 5 (−5)|  D1 header
| [search…        ] [Apply plan (5)] [Reset plan]   [+][−][fit][me]   |
|--------------------------------------------------------------------|
|                                              | Node              |  D2 canvas | D3 inspector
|      ·  ·  ○──○──◎   (the tree, zoomable)    | Sword Heart (Kiếm Tâm)|
|         ·  │       ★                         | notable · Kim land |
|      ●──●──●  (open)                         | +12 % sword damage |
|           ╲ (planned, dashed)                | Route: 4 points    |
|                                              | gives: +2 Kim purity, …
|                                              | [Plan this route]  |
+--------------------------------------------------------------------+
| reply strip                                                        |
```

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| D1 | Counters | Text | Points unspent, marks open, the plan's length and whether the points cover it; **the next point source** ("Next: level 2 +1, … breakthrough +13", dao-do.md UI Requirements) | No |
| D1 | Search | LineEdit | Node names and stat words; matches pulse on the canvas at every zoom; "n matches"; Enter cycles through them and centres each | Ctrl+F |
| D1 | Apply plan / Reset plan | Buttons | Apply opens the pending marks in order, **only when the points cover the whole plan** (rule 3: a route is all or nothing; disabled with "the plan costs 6 points; you have 5"); confirm in place: "Open 5 marks for 5 points? Permanent: the Đạo Đồ is never refunded."; a refused mark stops the plan there; Reset clears the plan | Yes |
| D1 | Zoom | Buttons | + / − / fit / centre on me | Yes |
| D2 | Canvas | Custom draw (the v5 viewer's look) | Near-black ground; roads bronze, links muted, a cluster's links and small marks in its stat family's colour (offence, defence, sustain, cultivation, craft); notables gold (pale in Stats), keystones red, starts white, size by class; the Chaos land purple while locked; open marks and their lines bright, reachable ones ringed, the plan and the hovered route as bright lines, search matches pulsing; the inspector always names the class and the land in words (the non-colour backup) | Wheel / + − zoom; drag / arrows pan; hover a node: the inspector and the route preview; click: select; double-click or Enter: add its route to the plan |
| D3 | Inspector | Panel | The node's name, class and land in words, its lines (the game's modifier text at the player's purity), capability; the Chaos gate with its condition and the player's current purities; the route from the open set (or the plan's end): its point cost, each road's purity grant as "Kim 34 → 36", and every route mark's lines (the route's whole gain) | Plan this route; the refusal reason when not allowed (gated, realm, no route); the engine's checks decide (the GDD's "root lacks N base elements" condition is not in the engine's `can_allocate` yet: logged) |
| Start chooser | Overlay | Rows | The starts the root allows (`tree_starts`), each with its land; choosing is permanent | Choose (confirm) |
| D4 | Reply strip | Text | The results of Apply | Dismiss |

### Information Hierarchy

1. Where the player is (open nodes, the frontier) and the points to spend.
2. The node under the pointer and its route cost.
3. The plan.

## States & Variants

| State | What changes |
|---|---|
| No start | The start chooser; the canvas shows the starts the root allows |
| No points | Apply disabled ("no points"); planning still allowed (a plan longer than the points shows its excess in the counters) |
| Plan pending | Planned nodes dashed; Back asks keep / discard / cancel |
| Gated node | Hatched; the inspector names the gate (the Chaos land) |
| Capability notable below its realm | The inspector names the realm needed; not on routes (rule 16) |
| Event waiting | Look-only: Apply and Plan disabled with 🔒; looking and searching stay live |
| Applying | Buttons disabled while the jobs run, one node at a time; the canvas updates after each |

## Interaction Map

| Input | Action |
|---|---|
| D | Open / back |
| Wheel, + / − | Zoom about the pointer / the centre |
| Drag, arrow keys | Pan |
| 0 | Fit; Home: centre on the player's open nodes |
| Click / Enter on a node | Select (the inspector) |
| Double-click / P / Enter | Add the selected node's route to the plan |
| Shift+arrows | Move the selection to the neighbour that way (keyboard selection without a mouse) |
| Ctrl+F, Enter in search | Search; next match |
| Esc | Clear the selection, then Back |
| Gamepad: left stick pan, triggers zoom, A select, X plan, B back | (Partial) |

Every key is rebindable (hud.md Platform Adaptation).

## Data Requirements

The map is static data (`dao_do_map.json`, read once through `DaoDoTree.load_map`). The player's state is one read,
`GameQuery.dao_do(s)`: {has_start, starts [{key, name, node}], open [ids], points, gate_open, realm}. The inspector and
route preview are `GameQuery.dao_do_node(s, id, pending)`: {node fields, lines (describe_mods at the player's root),
route [ids] from the open set plus the pending plan (`DaoDoTree.path_to` on a copy), cost, gains, ok, reason}; reads only.
Apply runs `tree_allocate(node, false)` for each pending node in order as jobs (each is adjacent by construction);
the start chooser runs `tree_choose_start(key)`. **The plan is the screen's UI state for the session**: kept when the
player leaves with "Keep", not saved with the game. Routes follow `DaoDoTree.path_to`, rule 3's tie-break included
(highest total scaled value, then the lowest ids).

## Events Fired

`action_requested("tree_allocate", [id, false])` per node; `("tree_choose_start", [key])`; `back_requested`.

## Transitions & Animations

Search matches pulse (a 1 s alpha cycle; under reduced motion they are ringed without pulsing). Zoom and pan are
immediate (no momentum here).

## Input Method Completeness Checklist

- [x] Keyboard: pan, zoom, search, select (Tab through search matches), plan, Apply
- [x] Mouse: everything
- [x] Gamepad: pan, zoom, select, plan, back (Partial)
- [x] No hover-only information: selection shows the same inspector

## Accessibility

Node class by size and frame, not colour; open / reachable / planned / gated by fill, ring, dash and hatch, not colour
alone; text at the 16 px floor in the header and inspector; reduced motion stops the pulse. Screen reader: the
inspector is a live region reading the node's name, class and route cost; the canvas itself is not navigable by
screen reader (a known limit, like the map), but search and the inspector are.

## Localization Considerations

Node names carry English and Hán-Việt as authored; modifier text follows the language; the inspector wraps.

## Acceptance Criteria

- [ ] `[GdUnit]` `GameQuery.dao_do` returns the open set, the points and the starts; reading it and `dao_do_node` leave
      `to_dict()` unchanged.
- [ ] `[GdUnit]` The route preview is `DaoDoTree.path_to`'s route; with a pending plan it starts from the plan's nodes.
- [ ] `[GdUnit]` Planning adds the route's nodes in order; Reset clears it; Apply emits one `tree_allocate` per node,
      in order, after its confirm.
- [ ] `[GdUnit]` A gated node and a capability notable below its realm show their reason and cannot be planned.
- [ ] `[GdUnit]` Search finds nodes by name (diacritics folded) and cycles through them.
- [ ] `[GdUnit]` The canvas draws only the nodes inside the view (culling) and redraws only on a change.
- [ ] `[Screenshot]` 1920×1080 and 1280×720: the tree around the start with a node selected and a plan; nothing clips.

## Open Questions

- Node art (the painted icons, memory dao-do-node-art) is not drawn yet: nodes are shapes by class and colour by
  group; the icons come with the polish pass.
- Refunds: rule 3, the Đạo Đồ is never refunded; not offered.
- The start chooser's "what lies within 9 points of each start" (dao-do.md UI Requirements) is not shown yet.
- Land names drawn on the canvas at low zoom (a further non-colour backup) wait for the art pass.
