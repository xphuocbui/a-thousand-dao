# UX Spec: Đạo Đồ View

> **Status**: In Review, lean round 2 NEEDS REVISION (2 blocking, 5 advisory: applied 2026-11-24); written
> 2026-11-24 night by Claude under the UI delegation (memory ui-design-delegated). **Look (user 2026-11-24: "don't we
> just use v5 ... do something similar to" the viewer artifact, then "like PoE's skill tree"):** the canvas draws v5 in
> a PoE style: dark ground, the viewer's palette and stat-family colours, a framed painted icon on every node (wired in
> 2026-11-24; polish of the icons waits for the release pass, user 2026-11-20). This spec describes the window as built
> on 2026-11-24 (`src/ui/dao_do/dao_do_screen.gd`, `dao_do_canvas.gd`); behaviour the review asked for that the code
> does not have yet is listed under Open Questions as "Not built yet".
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **GDDs read**: `design/gdd/dao-do.md` (rules 1–5 access and starts, 3 the Chaos gate and routes, 4 purity scaling, 16
> capability notables, 20), `design/ux/hud.md` (full screens; element 5 D; End turn's unspent-points pip),
> `interaction-patterns.md` (Tree view), memory dao-do-node-art (colour = group, frames by class)
> **Patterns used**: Full screen, Tree view, Searchable list (search pulses), Confirm in place, Reply strip.
> **Rework (user 2026-11-24: "It should be like PoE's skill tree. Please add with icon, and hovering over it gives the
> stat")**: the canvas draws every node's framed painted icon, PoE-style dark ground, dim unallocated and bright
> allocated nodes with gold paths. There is **no inspector panel any more**: the **node card** (D3) is a dark plate with
> a gold edge that follows the pointer, and also appears on a keyboard selection (Shift+arrows, P / Enter, search). It
> shows the node's painting at full size, its name in its class colour, class and land in words, stats one per line, the
> capability or Effect with its rule, and what reaching it costs. **A click on a mark plans its route; a click on a
> planned mark takes it and everything planned after it out of the plan.** There is no separate "select" step and no
> double-click: a click selects (white ring) and plans in one action.
> **Pattern**: the node card is a new pattern (a floating, mouse-transparent card that follows the pointer or the
> keyboard selection, flips left or clamps up near the edge). It is not in `interaction-patterns.md` yet: needs adding
> there (not edited from this spec).

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
|      ·  ·  ○──○──◎   (D2 canvas: the whole tree, zoomable)          |
|         ·  │       ★ ┌──────────────────────┐ D3 node card          |
|      ●──●──●  (open) │ [painting]           │ (floats by the pointer |
|           ╲ (planned)│ Sword Heart (Kiếm Tâm)│  or the keyboard       |
|                      │ Notable · the Kim land│  selection; flips left |
|                      │ +12 % sword damage    │  or clamps up at the   |
|                      │ Click to plan: 4 pts  │  edge)                 |
|                      │   Kim 34 → 36         │                        |
|                      └──────────────────────┘                        |
+--------------------------------------------------------------------+
| reply strip                                                        |
```

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| D1 | Counters | Text | Points unspent, marks open, the plan's length and whether the points cover it; **the next point source** ("Next: level 2 +1, … breakthrough +13", dao-do.md UI Requirements) | No |
| D1 | Search | LineEdit | Node names and stat words (two letters or more, diacritics folded); matches pulse on the canvas at every zoom; "n matches"; Enter cycles through them, centres each, selects it and shows its node card | Ctrl+F |
| D1 | Apply plan / Reset plan | Buttons | Apply opens the pending marks in order, **only when the points cover the whole plan** (rule 3: a route is all or nothing; disabled with "the plan costs 6 points; you have 5"); confirm in place: "Open 5 marks for 5 points? Permanent: the Đạo Đồ is never refunded."; a refused mark stops the plan there; Reset clears the plan | Yes |
| D1 | Zoom | Buttons | + / − / fit / centre on me | Yes |
| D2 | Canvas | Custom draw (PoE-style, the v5 viewer's palette) | Near-black ground; a framed painted icon per node, size by class; unallocated lines dark bronze, allocated marks and lines bright gold with a glow, reachable ones lit a little, the plan and the hovered route as pale blue lines, search matches pulsing; the selected node has a white ring; the node card always names the class and the land in words (the non-colour backup) | Wheel zooms about the pointer; + − zoom about the centre; drag / arrows pan; hover a node: the node card and the route preview; click: select and plan its route (a planned mark: take it and later marks out of the plan); P / Enter on the selection: the same as a click |
| D3 | Node card | Floating card (mouse-transparent) | The node's painting at full size, its name in its class colour (20 px notable / keystone / start, 17 px other), "class · land" in words (16 px), stats one per line in blue (16 px), "×0.80 from your root's purity in this land" when scaled, the capability (name, description) or Effect (name, rule), the price of a closing node, then one status line: "Allocated", "In the plan: click to take it out", "✗ <reason>" (gated, realm, no route; the engine's checks decide), or "Click to plan: N point(s)" with each road's purity grant as "Kim 34 → 36" | None (it never takes the mouse). Position: 22 px right and 18 px below the pointer, flipped to the left of the pointer when it would pass the right edge, moved up when it would pass the bottom edge. The GDD's "root lacks N base elements" condition is not in the engine's `can_allocate` yet: logged |
| Start chooser | Row in the header | Buttons | "Start (until your first mark):" and one button per start the root allows (`tree_starts`); the current one ticked; choosing arms a "Confirm: start at X" button; permanent after the first mark | Choose (confirm) |
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
| Gated node | The node card names the gate (the Chaos land) as its "✗" reason |
| Capability notable below its realm | The node card names the realm needed; not on routes (rule 16) |
| Event waiting | Look-only: Apply and Plan disabled with 🔒; looking and searching stay live |
| Applying | Buttons disabled while the jobs run, one node at a time; the canvas updates after each |

## Interaction Map

| Input | Action |
|---|---|
| D | Open / back |
| Wheel, + / − | Zoom about the pointer / the centre |
| Drag, arrow keys | Pan |
| 0 | Fit; Home: centre on the player's open nodes |
| Hover a node | The node card and the route preview (pale line) |
| Click a node | Select it and plan its route; on a planned node, take it and the marks after it out of the plan |
| P / Enter | The same as a click, on the selected node (the keyboard route to plan or unplan) |
| Shift+arrows | Move the selection to the neighbour that way, centre on it and show its node card (keyboard users get the card without a pointer) |
| Ctrl+F, Enter in search | Search; next match (selects it and shows its card) |
| Esc | Close a pending confirm, else clear the selection, else Back |
| Gamepad: left stick pan, triggers zoom, A select, X plan, B back | Intended (Partial); **not built yet**: the canvas handles keys and mouse only (Open Question 6) |

Every key is rebindable (hud.md Platform Adaptation).

## Data Requirements

The map is static data (`dao_do_map.json`, read once through `DaoDoTree.load_map`). The player's state is one read,
`GameQuery.dao_do(s)`: {has_start, starts [{key, name, node}], open [ids], points, gate_open, realm}. The node card and
route preview are `GameQuery.dao_do_node(s, id, pending)`: {name, kind, area, stats, scale, cap, cap_name, effect, closes,
route [ids] from the open set plus the pending plan (`DaoDoTree.path_to` on a copy), cost, gains, purity_now, open,
planned, ok, reason}; reads only. Apply emits one `tree_apply` with the whole ordered plan, which the session runs node
by node (each is adjacent by construction); the start chooser runs `tree_choose_start(key)`. **The plan is the screen's UI state for the session**: kept when the
player leaves with "Keep", not saved with the game. Routes follow `DaoDoTree.path_to`, rule 3's tie-break included
(highest total scaled value, then the lowest ids).

## Events Fired

`action_requested("tree_apply", [ids])` once per confirmed Apply (the whole plan); `("tree_choose_start", [key])`;
`leave_decided(go)` after the leave prompt; `back_requested`.

## Transitions & Animations

Search matches pulse (a 1 s alpha cycle; under reduced motion they are ringed without pulsing). Zoom and pan are
immediate (no momentum here).

## Input Method Completeness Checklist

- [x] Keyboard: pan, zoom, search (Enter through the matches), Shift+arrows to select, P / Enter to plan, Apply
- [x] Mouse: everything
- [ ] Gamepad: not built (Open Question 6)
- [x] No hover-only information: the node card also appears on a keyboard selection (Shift+arrows, search, P / Enter)
- [ ] Screen reader: the card is **not** a live region yet; it only sets the card's accessible name to the node's name
      (Open Question 5)

## Accessibility

Node class by size and frame, not colour; open / reachable / planned by fill, ring and line; the node card names class
and land in words. **Text sizes of the node card as built: every line is at least 16 px (class line, stats, notes, gain
lines and status line 16 px; 17–20 px title), so the card meets the 16 px floor in
`design/accessibility-requirements.md` (Open Question 3, closed 2026-11-24).** The search box, counters and buttons use the theme size. Reduced motion stops the search pulse
(they are ringed instead). Screen reader: the canvas has an accessible name ("hover a mark for its stats; search finds
marks by name or stat") and the Apply button names its disabled reason; the canvas itself is not navigable by screen
reader (a known limit, like the map). The card's contents are **not announced** yet (Open Question 5).

## Localization Considerations

Node names carry English and Hán-Việt as authored; modifier text follows the language. The card's labels are 280 px
wide minimum and wrap by word, so a 40 % longer line gets taller, not wider; there are no character limits yet (Open
Question 7).

## Acceptance Criteria

- [ ] `[GdUnit]` `GameQuery.dao_do` returns the open set, the points and the starts; reading it and `dao_do_node` leave
      `to_dict()` unchanged.
- [ ] `[GdUnit]` The route preview is `DaoDoTree.path_to`'s route; with a pending plan it starts from the plan's nodes.
- [ ] `[GdUnit]` Planning adds the route's nodes in order; a click on a planned mark removes it and the marks after
      it; Reset clears the plan; Apply emits one `tree_apply` with the plan in order, only after its confirm.
- [ ] `[GdUnit]` A gated node and a capability notable below its realm show their reason on the node card and cannot
      be planned.
- [ ] `[GdUnit]` Node card (`card_text()`): shows name, stats, cost and the purity gains for a plannable node, and the
      "✗ reason" for a refused one; it is hidden when the pointer leaves a node or drags.
- [ ] `[GdUnit]` Keyboard only: Shift+arrows moves the selection and shows the node card; P / Enter plans; Esc closes a
      confirm, then clears the selection, then goes back. No step needs the pointer.
- [ ] `[Screenshot]` 1280×720: a node near the right edge and one near the bottom edge: the card flips left / moves up
      and stays fully inside the canvas.
- [ ] `[GdUnit]` Search finds nodes by name (diacritics folded) and cycles through them.
- [ ] `[GdUnit]` The canvas draws only the nodes inside the view (culling) and redraws only on a change.
- [ ] `[Screenshot]` 1920×1080 and 1280×720: the tree around the start with a node selected and a plan; nothing clips.

## Revision: weak-point pass (2026-11-24)

Bar in groups (weak-point #11): **Points** (points unspent and the plan's cost; the next point source is in their
tooltip), **Search**, **Plan** (Apply, the gold primary, and Reset), **View** (−, +, Whole tree, My marks); groups wrap
whole. A **minimap** (`DaoDoMinimap`, ui_windows.json dao_do.minimap_px 220) sits in the canvas's bottom-right corner:
every mark a faint dot, your marks gold, the plan blue, the view a brass frame; click or drag to move the view (a mouse
aid; the keyboard has Whole tree and My marks). The bar's disabled buttons keep the wood look (the screen is on dark
wood).

## Open Questions

1. Node art: the painted framed icons are drawn (wired in 2026-11-24); only their polish waits for the release pass
   (memory dao-do-node-art).
2. Refunds: rule 3, the Đạo Đồ is never refunded; not offered.
3. (Closed 2026-11-24: every hover-card line is at least 16 px, `dao_do_screen.gd` `_card_label` calls; no smaller
   floor for the card.)
4. **Not built yet: contrast and colour-independence of the card and icon frames.** The card is a near-black plate
   (alpha 0.94) with coloured text (stats blue `#8f9cff`, notes `#a79f8f`); no contrast ratio is measured. Frames by
   class are a non-colour cue on the tree, but this has not been checked in a colour-blind view. Measure both.
5. **Not built yet: screen reader reads the card.** The card sets only its accessible name (the node's title); there is
   no live region announcing stats and route cost, and the canvas cannot be navigated by a screen reader. The review
   asks for an announcement on every keyboard selection (Standard tier plus panel support, committed 2026-11-22).
6. **Not built yet: gamepad.** The canvas takes keys and mouse only. Needs left stick pan, triggers zoom, A plan, B
   back, a d-pad / stick step of the selection (the Shift+arrows step), and a focus order: header (counters, search,
   Apply, Reset, zoom, start row) then canvas. Tab / d-pad order is not defined or tested today.
7. **Not built yet: localization limits** for the card's name and lines (a maximum character count, 40 % expansion
   test); the card wraps by word at a 280 px minimum width.
8. **Not built yet: a slow-open check.** There is no measured open-time criterion for the window (8,051 nodes with
   icons); measure it and set one.
9. The start chooser's "what lies within 9 points of each start" (dao-do.md UI Requirements) is not shown yet.
10. Land names drawn on the canvas at low zoom (a further non-colour backup) wait for the art pass.
11. (Decided 2026-11-24, UI owner; the user may overrule: a click plans, as in Path of Exile, kept. Round 1's
    "double-click" and "inspector" stay gone.)
