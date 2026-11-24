# UX Spec: Combat tab, the formation editor (trận đồ)

> **Status**: Built 2026-11-24 to the user's pick of mock-up A (`prototypes/ui-mood/out/r5-tab-a-l.png`); evidence
> `production/qa/evidence/ui-windows/review-2026-11-24/17-*.png`, `17b-*.png`, `720-17-combat-tab.png`
> **Author**: user + Claude
> **Implements**: `design/gdd/formations.md` Part I (rules 1-12; UI Requirements: Diagram collection, Preparation)
> **Plan**: `production/plans/combat-formations.md`
> **Platform Target**: PC; keyboard and mouse primary, gamepad partial (`design/ux/hud.md` Platform Adaptation)

## Purpose & Player Need

The player arranges their arts into a combat formation: which formation, which art in which node, and whether to lay
it. The arrangement is the build (Pillar 3), and every price is shown at once (Pillar 2): lay fuel, linh lực
reserved, the strength by situation. A loss should point at a node choice the player can change.

## Player Context on Arrival

From the character sheet (C, then the Combat tab, or Ctrl+Tab), from the fight screen's "Back to the map" after a
fight, or from a person's sheet (look only: someone else's formation, no editing). Usually between seasons, with time.

## Navigation Position

The character sheet's second tab, "Combat" (`CharacterWindow.TABS`). A side-panel window (Window sizes pattern: 62 %).

## Layout Specification

```
+----------------------------------------------------------------+
| Character   Vô Danh · Age 16/120              tabs        [x]  |
|----------+---------------------------------------+-------------|
| FORMA-   |   [ Five Phases · Ngũ Hành Trận ]     | YOUR ARTS   |
| TIONS    |                                       |  [ic] name  |
| (o) Plain|        the formation board            |  [ic] name  |
| (o) Serp.|     (figure, nodes with art icons,    |  [ic] name  |
| (*) Five |      feeds, + / - / ? badges,         |  ...        |
| (o) ...  |      closed nodes dashed "L3")        |             |
|          |   o o o o o  Level 2 · next: ...      |             |
|----------+---------------------------------------+-------------|
| [Lay fuel 14/30] [Reserved 8 %] [100/70/50 %] [Lay: On]       |
| [Ward 244] [Block 3.91] [Evade 0 %] [Crit 15 %] (more: hover)   |
+----------------------------------------------------------------+
```

| Zone | Holds |
|---|---|
| C1 Collection (left, ~22 %) | The Plain Row, then every known formation as a round medallion with a small gold drawing of its shape and its name; the Set one with a glowing gold ring and a "SET" seal; one that cannot be set now (too many nodes for the art slots, reservation over the cap) dimmed with its reason in the tooltip. Click or Enter: set it (it keeps its level; arts are placed by fit). |
| C2 Board (centre, ~52 %) | The Set formation drawn as on the fight screen: its figure, curved links (feeds as arrows with their seconds, adjacency as plain strokes), nodes as bronze rings with the art's painted icon inside and a + / − / ? badge; a closed node is a dim dashed ring marked "L<n>"; a closed link dashed. Under it a level track: one pip per level up to its max, lit to the current level, and "Level 2 · next level: opens node 4" (or "more strength", or "one level"). The name plaque on top. The Plain Row shows the arts as a plain row of slots. |
| C3 Arts (right, ~26 %) | The player's arts in slot order as framed cards (icon, name, "in node 2" or "plain slot"). |
| C4 Price strip (bottom) | Four tiles: lay fuel against the stones held; linh lực reserved against the cap; strength by situation (laid 100 %, ambush 70 %, blind 50 %); "Lay when foreseen" On / Off (a toggle). |
| C5 Numbers (bottom) | The fighter's key numbers (ward points, block, evade, crit); the full groups in their tooltips. |

## Interaction Map

| Input | Result |
|---|---|
| Click a node, then an art (drag and drop: not built yet) | The art goes to that node (`place_diagram_art`); if it was in another node, that node empties. The node's rule applies to it at once (the board and numbers re-read). |
| Click a node, then "Empty node N" in the arts column | The node empties; the art returns to the plain slots. |
| Click a closed node | Its tooltip: "Opens at level 3"; nothing is placed. |
| Hover a node | Tooltip: the node's rule in words (scaled by the current strength), its polarity in words (benefit, drawback, condition), the art in it and what it changes. |
| Hover a feed | "When node 1's art fires, node 2's wait drops 1.2 s (never below the shortest cooldown)." |
| Click a collection medallion | Set that formation (`set_diagram`); the Plain Row sets the default line. |
| Lay toggle | `set_diagram_lay` |
| Keyboard | Tab: collection, board nodes (in node order), arts, price strip. Enter on a node selects it; Enter on an art places it in the selected node; Delete empties the selected node. Esc: clears the selection, then closes the window. |
| Gamepad | D-pad moves between nodes; A selects; LB / RB cycle arts; A places. |

## States & Variants

| State | Behaviour |
|---|---|
| Event waiting | Look only: medallions, nodes and the toggle are disabled with "locked while an event waits". |
| Someone else's sheet | Look only: their Set formation on the board, no collection, no editing. |
| Plain Row set | The board shows a plain row of slots; the price strip reads no fuel, no reservation. |
| A node is selected | Its ring glows; the arts' cards show "place here". |
| Fuel short | The lay fuel tile reads "short: carried at 70 %" in amber. |

## Data Requirements

`GameQuery.formations(s)`: `known` [{id, name, name_vi, set, can, reason, view}], `current` (a `diagram_view`: nodes
{n, polarity, words, pos, open, unlock, art, art_name, icon, slot}, links {kind, a, b, seconds, bend, open, unlock},
figure, level, level_eff, max_level, strength, open_nodes), `pool` [{id, name, icon, tags, node}], `slots`, `lay`,
`fuel`, `stones`, `reserved`, `reserve_cap`, `shares`, `event_waiting`. Actions: `set_diagram(id)`,
`place_diagram_art(node, art_id)`, `set_diagram_lay(on)` (GameSession; refused while an event waits).

## Accessibility

Polarity is a shape mark (+, −, ?) as well as colour; the closed state is a dashed ring and a level label; every node,
link and medallion has an accessible name ("Node 2, benefit, +10 % art speed, holds Thunder Seal"); text at the 16 px
floor; the board's art is decorative beside the words in tooltips and names.

## Localization Considerations

Formation names in English with their Hán-Việt name; rule words built from short phrases (Diagrams.rule_words).

## Acceptance Criteria

- [ ] `[GdUnit]` The collection lists the Plain Row and each known formation; the Set one is marked; one that cannot be set says why.
- [ ] `[GdUnit]` Clicking a node and then an art requests `place_diagram_art(node, art)`; a closed node requests nothing.
- [ ] `[GdUnit]` Look-only (event waiting, another person) disables every action.
- [ ] `[Screenshot]` 1920x1080 and 1280x720: the board, the collection and the arts fit without overlap; the largest formation (9 nodes) fits the board.

## Open Questions

| # | Question |
|---|---|
| 1 | Raising a formation's level (F3, at the abode): from this tab or from the Abode screen? (Proposal: a "Raise…" button under the level track, enabled at home.) |
| 2 | A per-node contribution tally after a fight (GDD Open Question 9). |
