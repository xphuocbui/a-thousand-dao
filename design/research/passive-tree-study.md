# Passive Tree Study: what makes the PoE trees work

> **Status**: Reference study for the Meridian Map (Kinh Mạch Đồ) rework, 2026-11-08. Requested by the user:
> study the PoE 1 and PoE 2 passive trees (connections, pathing, shape) and write down their characteristics
> before the rework starts. The user prefers the old Kinh Mạch Đồ layout because "it looks more PoE like" and
> wants it as good as PoE (memory: skill-tree-rework-later).
> **Viewer**: the "Passive Tree Survey" artifact (https://claude.ai/artifact/BzNDez5fo2xRxKqNrdDJ16) redraws all
> three trees from data, with shortest paths and point costs on hover.
> **Rule for the rework**: we take *principles* from PoE, never its layout, node names or numbers.
>
> **User decisions for the rework (2026-11-08)**, carried over from the overnight shape brief, which was removed
> once this study replaced it. Its three new shapes (Body Map, Weave, Star Field) were not adopted, and neither
> was the 2026-11-07 wheel.
> 1. Keep the old layout and make it better. The user liked all of it: small clusters, long roads planned across
>    realms, the organic look, hidden rim clusters. *"I actually prefer the old one overall layout more. It looks
>    more PoE like, the only thing i do not like, is that it is not as good as PoE."*
> 2. The spiritual root picks the start (PoE-style starts; touches Spiritual Roots and NPC Builds).
> 3. Capabilities are a mix: slot raises become keystones with a real closing cost, and closeless ones become
>    major Effects.
> 4. No cap on tree keystones or Effects per build ("We will balance this out later").
> 5. **Tree size: about 5,000 nodes** (user decision 2026-11-08). The tree is sized against the late realms, not
>    Qi Refining (a starter realm, about PoE's first 10 levels). With today's point curve, a build covers about 1 %
>    at the end of Qi Refining (51 points), 7 % at the end of Nascent Soul (357) and 11 % at the end of Deity
>    Transformation (566), close to PoE's 3–6 % at the top.
> 6. **Starts** (user decision 2026-11-08; provisional until the user sees it drawn: "There will likely be
>    changes"). Five element starts on a ring at about a third of the radius, PoE 1-style, in generating order
>    (Wood, Fire, Earth, Metal, Water); a multi-element root picks any of its elements' starts. Variants:
>    - **Light** starts outside the circle beyond Fire, on a graph of its own that later joins Fire (user's idea).
>    - **Darkness** starts outside on the opposite side, joining Water and reaching Earth along the rim (user's idea).
>    - **Ice** starts on Water's road, out from Water's start (user: "in or in the direction of water").
>    - **Wind** starts inside the circle between Water and Wood, pushed out near the rim, with its own land in the
>      Wood–Water blend zone (user decision 2026-11-08: Wind relates to Thủy and Mộc). This replaced the
>      earlier "any point on the ring road" proposal.
>    - **Thunder** has an island outside the circle beyond Wind, directly opposite Earth, joined to Wind and to
>      Fire and Metal, its parents (user decision 2026-11-08: "phong and lôi are somewhat together"). Draft 3
>      proposes two lightning roads (long highways of few nodes, about 12–15 points each) just inside the rim to
>      Fire's and Metal's outer land. Thunder starts **only on its island** (user decision 2026-11-08); the lightning
>      roads are 12–15 points each for now (user: "i'm not so sure").
>    - **Chaos** starts at any element start, or the centre.
>    - **Void and Blood: a future plan** (user decision 2026-11-08: "let's leave void and blood out for now").
>      They are not budgeted or drawn. Proposals kept for later: Void on an island next to Darkness, joined to it
>      by a road and linked straight to hidden rim clusters (secret realms); Blood starting in the centre hub.
> 7. **Counterpart nodes** (user decision 2026-11-08, from the user's Thunder idea). A derived variant's holder
>    may take a parent element's node as the variant's counterpart version: Thunder on Fire and Metal nodes,
>    Darkness on Earth and Water, Chaos on any element, Light on Fire, Ice on Water. Innate variants (Wind,
>    Blood, Void) have no parent, so they rely on their own start and district.
> 8. **Neighbouring regions blend** (user decision 2026-11-08). The land between two starts mixes both
>    elements' themes. In generating order, overcoming pairs sit across the ring from each other.
> 8a. **Zoning plan approved** (now draft 4, without Void and Blood; Wind and Thunder per decision 6) (user, 2026-11-08: "Otherwise everything looks good"), draft 2 at
>     https://claude.ai/artifact/2piSKgDExSfkL9UJmUbHKE: centre hub 350 nodes, ring road 150, five element lands of
>     600, five blend zones of 150, rim and hidden clusters 400, Light and Darkness islands 120 each, Wind land 100, Thunder island 120 (about 5,110).
>     Targets: neighbouring starts 12–15 points apart, a keystone within about 10 points of every start, the rim
>     40–45 points out.
> 9. **Hand-authored** (user decision 2026-11-08), not generated: the tree is drawn region by region.
> 10. **Theme split** (user decision 2026-11-08). *Universal* themes, scattered unevenly and near every start:
>     health (Khí Huyết), linh lực, thần thức, ward (Hộ Thể), a new crit-like offence theme, lifespan (Thọ Nguyên),
>     heart (Tâm Cảnh) and comprehension (Ngộ Đạo). *Identity* themes, in districts: Metal has sword intent
>     (Kiếm Ý) and refining (Luyện Khí); Fire has alchemy (Đan Đạo); Earth has formations (Trận Đạo); Wood has
>     fields (Linh Điền) and beasts (Ngự Thú); Water has talismans (Phù Đạo). Cluster mastery (Tinh Thông) is a
>     future concept.

## How this was measured

- **PoE 1**: Grinding Gear Games' public tree export (`grindinggear/skilltree-export`, `data.json`, 3.x).
- **PoE 2**: the 0.5 tree from the Path of Building community (`PathOfBuilding-PoE2`, `src/TreeData/0_5/tree.json`).
- **Ours**: today's generator output (seed 20261102), exported with `tools/balance/export_tree.gd` and laid out by
  `tools/meridian-map/build.js`.
- Ascendancies, cluster jewels, Bloodline and other side nodes are left out. PoE 1 masteries are counted
  separately, not as path nodes. "Points" means nodes on the shortest path, ignoring level and quest rules.
- Our sealed clusters connect through gates that the drawn graph does not include, so about 30 of our notables
  show as unreachable by plain links. That affects only our reach figures.
- The script is `tools/design/meridian_rework/poe_study/analyse.py`. Run it again on each rework iteration to
  measure it against these numbers.

## Measured side by side

| Measure | PoE 1 | PoE 2 | Kinh Mạch Đồ today |
|---|---|---|---|
| Allocatable nodes | 2,006 | 4,115 | 1,536 |
| Notables / keystones / jewel sockets | 454 / 48 / 21 | 984 / 33 / 18 | 193 / 19 / 0 |
| Travel nodes (attribute or road) | 202 (+10 to one attribute) | 326 (+5 to an attribute you pick) | 534 roads |
| Starts | 7 (6 on a ring + Scion in the centre) | 6 (each shared by two classes) | 1 (Đan Điền) |
| Start ring radius (share of the tree's radius) | 0.34 | 0.09–0.13 | centre |
| Start distance, neighbour / opposite (points) | 12 / 26 | 12 / 30 | — |
| Nearest keystone from a start | 6–8 | 9–13 | 22 (the centre keystone at 1 left out) |
| Notables within 10 points of a start | 34–61 | 20–28 | 37 |
| Share of notables within 20 points | about 60 % | about 40 % | 41 % |
| Farthest node from a start | 30–33 | 38–42 | 32 |
| Nodes with exactly 2 links (roads) | 65 % | 60 % | 50 % |
| Most links on one node | 9 | 9 | 4 (centre 6) |
| Dead-end tips | 77 | 559 | 202 |
| Independent loops per 100 nodes | 16 | 16 | 15 |
| Notable clusters with one way in | 79 % | 64 % | 83 % |
| Small nodes per notable cluster | 2.7 | 3.4 | 5.8 |
| Notable to nearest notable (steps) | mostly 4–6 (pairs at 2) | peaks at 2–3 and 6–7 | 85 of 193 are 8 or more |
| Keystones that are dead ends | 48 of 48 | 33 of 33 | 13 of 19 |
| Keystone distance from centre (share of radius) | 0.68 | 0.69 | 0.65 (one in the centre, ten at 0.4, eight at the rim) |
| Nodes in the inner 40 % of the radius | 10 % | 17 % | 53 % |
| Plate filled (40 × 40 grid) | 63 % | 71 % | 27 % |
| Links drawn as orbit arcs | 61 % | 29 % | 0 % (the builder curves 63 % of links, but not on orbits) |
| Match after a 60° turn / left-right mirror | 35 % / 51 % | 37 % / 38 % | 20 % / 48 % |
| Cluster forms with 4+ nodes: wheels / lines / stars | 137 / 75 / 6 | 271 / 175 / 52 | 28 / 12 / 21 |
| Points a finished build spends | about 120 (about 6 % of the tree) | about 120 (about 3 %) | 51 by the end of Qi Refining |

## Characteristics

### Shape

1. **A ring of starts around a hub.** PoE 1 sets six starts on a ring at a third of the radius, 60° apart,
   with the Scion in the centre. PoE 2 pulls its six starts in to a tight inner ring. Each start owns a region
   with its own themes and colour (strength, dexterity, intelligence and their blends).
2. **Overlap between neighbours.** About 61–67 % of all nodes are within 3 points of being closer to a second
   start. The land between two starts is a hybrid zone both can use, so regions blend instead of walling off.
3. **Full, round, richer toward the rim.** Both trees are as wide as they are tall and fill 63–71 % of the
   plate, with no empty bands. Density grows outward: the outer half holds most notables and keystones.
4. **Clusters are geometric forms on orbits.** Each node sits on one of a few concentric orbits around its
   cluster's centre, so clusters come in a small, recognisable set of shapes: wheels you pass through,
   half-rings, short spokes. PoE 1 draws 61 % of its links as arcs along those orbits, which gives the round,
   organic look. PoE 2 uses more straight spokes and stars.
5. **Hand-shaped, not symmetric.** A 60° turn lines up only 35–39 % of nodes. Every region was drawn for its
   themes, so each side reads differently, even though density is even around the circle.

### Connection

6. **Highways and pockets.** 60–65 % of nodes are plain links in a line, forming long travel roads. Notables
   sit in pockets off those roads. Most pockets have one way in (79 % in PoE 1), and a pocket costs only 2.7–3.4
   small nodes.
7. **Crossroads are travel nodes.** Where roads meet, the crossroad (5 to 9 links) is almost always an
   attribute travel node itself: 102 of 116 crossroads in PoE 1, 179 of 213 in PoE 2. Junctions are cheap stat
   nodes, so a fork costs nothing extra to stand on.
8. **Keystones are always a deliberate trip.** Every keystone is a dead-end tip with one link. You never walk
   through one, so taking it is always a choice.
9. **Loops give alternate routes.** About 16 independent loops per 100 nodes, mostly wheels entered at one point
   and left at another. A path collects a cluster's value on its way through instead of backtracking.
10. **Travel is never worthless.** PoE 1's travel nodes give +10 to one attribute, and PoE 2's let you pick +5 to
    any attribute. Roads pay for attribute requirements, so a long trip is softened, never dead.

### Pathing and payoff

11. **Small diameter, huge breadth.** The farthest node is only 30–42 points from any start, yet a finished
    build spends about 120 points, 3–6 % of the tree. Anything is reachable. The choice is which few percent to
    take and which roads to share between goals.
12. **Payoff arrives early and keeps coming.** The nearest keystone is 6–8 points away in PoE 1 (9–13 in PoE 2),
    and 20–61 notables sit within 10 points. Inside a cluster, notables are 2–3 steps apart, and clusters are
    4–7 steps apart, so a planned path hits a payoff every few points.
13. **Neighbours are close, the far side is a commitment.** Adjacent starts are 12 points apart and opposite
    ones 26–30. Borrowing a neighbour's region is cheap. Crossing the map is a build-defining spend.

### What PoE 2 changed

- Each of the six starts is shared by two classes, set much closer to the centre.
- The tree is twice as big (4,115 nodes, 984 notables), with fewer keystones (33) set further out.
- Notables come in tight groups of 2–3, then a longer gap.
- There are many more dead-end pockets: 559 tips against PoE 1's 77.
- Travel nodes are mostly the pick-an-attribute kind.

## Clusters: what they hold, where they sit, how they join

Added at the user's request (2026-11-08): "they scatter a lot of things everywhere, take crit for example, it
is all over the tree. same as health". A cluster here is a group that holds a notable or keystone. PoE 1's
themes come from its mastery names (315 of 422 clusters have one). PoE 2's come from the stat text, so they
are approximate. The script is `tools/design/meridian_rework/poe_study/themes.py`. The viewer's "Where a theme
sits" mode shows each theme on the map.

### Two kinds of theme

| Theme | PoE 1 clusters | Spread | Directions (of 12) | Points from the closest / farthest start | PoE 2 clusters | Spread | Directions | Points |
|---|---|---|---|---|---|---|---|---|
| life | 32 | 0.95 | 12 | 4 / 7 | 44 | 0.94 | 10 | 2 / 8 |
| crit | 12 | 1.10 | 9 | 5 / 11 | 48 | 0.99 | 12 | 5 / 10 |
| mana | 18 | 0.86 | 9 | 5 / 9 | 27 | 0.87 | 9 | 1 / 16 |
| attributes | 15 | 1.04 | 12 | 8 / 12 | 11 | 0.90 | 7 | 8 / 14 |
| aura / reservation | 17 | 1.01 | 10 | 6 / 9 | 7 | 1.04 | 4 | 12 / 16 |
| energy shield | 15 | 0.84 | 7 | 4 / 17 | 33 | 0.74 | 6 | 5 / 17 |
| armour | 15 | 0.69 | 5 | 5 / 15 | 42 | 0.76 | 8 | 2 / 18 |
| evasion | 16 | 0.62 | 6 | 4 / 17 | 18 | 0.60 | 5 | 2 / 20 |
| minion | 17 | 0.58 | 5 | 2 / 18 | 28 | 0.61 | 5 | 5 / 19 |
| trap / mine | 10 | 0.41 | 2 | 5 / 18 | — | | | |
| warcry | 7 | 0.53 | 3 | 6 / 22 | 7 | 0.51 | 3 | 10 / 28 |
| lightning | 6 | 0.53 | 4 | 7 / 20 | 30 | 1.02 | 12 | 6 / 12 |

Spread 1.0 means a theme's clusters sit as far apart as clusters in general; lower means grouped.

14. **Universal themes are scattered on purpose.** Life, crit, mana, auras and attributes cover 9–12 of 12
    directions, and the nearest one is 4–11 points from *every* start. Every build needs them, so every start
    gets them nearby. They are spread unevenly: some areas have two, some none.
15. **Identity themes are concentrated.** Minions, traps and mines, warcries, flasks, evasion and armour sit in
    2–6 directions, owned by 2–5 starts, and can be 17–22 points from the others. They make a start feel like
    itself, and taking one far from home is a real detour. (The elements differ by game: PoE 1 groups
    lightning, while PoE 2 spreads every element widely.)
16. **Scattered themes rarely sit next to themselves; concentrated ones form districts.** A crit cluster's
    nearest neighbour is another crit cluster only 17 % of the time in PoE 1. The same holds for spell (13 %),
    curse (18 %) and elemental (0 %). Evasion (81 %), weapons (70 %) and minions (65 %) run in districts of 2–3
    clusters. The commonest neighbour pairs put offence next to defence (PoE 2: crit next to life 49 times,
    crit next to energy shield 31), so any route can stay balanced.

### Shape and flow

17. **Every crossroads is a small menu.** In PoE 1, 397 of 422 notable pockets hang directly off a crossroads
    (PoE 2: 564 of 731). A crossroads typically holds 3–5 pockets of different themes (89–94 % mixed). You stand
    on a cheap travel node and choose a door.
18. **Mostly one notable at the end of a short spoke.** 86 % of PoE 1's clusters hold one notable (PoE 2: 72 %
    one, 19 % two, 8 % three). About two-thirds are straight spokes and one-third are wheels; stars are rare.
    79 % have one way in. Half the notables sit at the very tip.
19. **The walk builds toward the payoff.** The small nodes inside a cluster carry its theme 66–71 % of the time.
20. **Packed tight.** A cluster's nearest neighbour is almost always 2 points away (375 of 422 in PoE 1), so
    leaving one pocket puts you two steps from the next. The tree reads as one fabric, not as islands.
21. **Pass-through clusters are the exception.** Only 54 of PoE 1's clusters have two ways in and 36 have
    three or more. These are mostly wheels and lines laid along a road, which you collect on the way.

### Masteries (PoE 1)

22. **A mastery turns repeated themes into choices.** 315 of 422 notable clusters have a mastery at their centre,
    named for the theme (Life ×14, Mana ×12, Attack ×10, Critical ×7). It opens once you hold a notable in that
    cluster, and you pick one of its effects (277 offer six, the rest four or five). Each effect can be taken
    only once, so a second Life cluster offers a different Life choice. That is what makes repeating a theme
    around the tree worth taking.

### Applying it to Kinh Mạch Đồ (for discussion)

- **Our scatter is mechanical.** Each of our 14 themes appears about once per element sector (5 copies, 5
  directions, spread 0.9–1.3), whatever the theme. Universal and identity themes are spread the same way, and no
  theme forms a district (same-theme neighbours 9 %). Our pockets sit 2–3 steps from a hub, and most hubs hold
  0–2 pockets.
- **Split the themes in two.**
  - *Universal*, to scatter widely and unevenly: health (Khí Huyết), linh lực, thần thức, ward (Hộ Thể), and a
    crit-like offence theme.
  - *Identity*, given districts of 2–3 clusters near the root that fits: sword intent (Kiếm Ý), beasts (Ngự
    Thú), formations (Trận Đạo), talismans (Phù Đạo), alchemy (Đan Đạo), refining (Luyện Khí), fields (Linh Điền).
  - *Life and cultivation* (Thọ Nguyên, Tâm Cảnh, Ngộ Đạo) need a call: universal, since every cultivator lives
    and breaks through, or a district for the hermit build?
- **Menus at crossroads.** Hang 3–5 short pockets of different themes on each road junction, about 2 points
  apart, so every fork is a choice.
- **Pair offence with defence.** Put a defensive pocket next to most offensive ones.
- **Cluster shapes.** Mostly short spokes with one notable at the tip, about a third wheels, and a few
  pass-through wheels laid along the roads. Small nodes carry the cluster's theme.
- **Cluster mastery (Tinh Thông), a future concept** (the user's idea). One mastery per themed cluster, opened by a
  notable in it, offering a few choices that can each be taken once per character. The choices would be minor
  Effects or plain modifiers (Effects System rule 4; Modifier System). It makes repeated universal themes worth
  taking.

### Third pass (2026-11-08): start webs, entries, notables per cluster

Measured after the user's review of Metal pilot v4 ("too generated"; `tools/design/meridian_rework/poe_study/study3.py`,
`crop2.py`).

23. **Roads join a cluster at its nearest node.** PoE 2: 79 % of links into a cluster land on the cluster's nearest
    node to the linking node, and 93 % on one of the nearest two. PoE 1: 95 % land within 15 % of the nearest
    distance. The exceptions are hubs: notables that roads pass through (Blur, Raw Power).
24. **Several notables per cluster, with small nodes before each.** PoE 2 clusters hold 1 / 2 / 3 / 4+ notables
    492 / 139 / 55 / 12 times. Counting nodes taken inside the cluster before a notable gives 0: 141, 1: 113,
    2: 355, 3: 290, 4+: 69, so 2–3 is the norm and 0 means a hub. Between two notables of one cluster there are
    usually 1–3 small nodes.
25. **Every start opens into a twin-hub web.** In PoE 2 the start's two short legs reach two hub notables
    (Raw Power and Pure Energy, Battle-hardened and Remorseless, Honed Instincts and Blur). The hubs are joined
    by a shared diamond or lens with a notable on it (Practiced Signs, Open Mind, Feel no Pain), and each hub
    fans out to 3–6 pockets: leaves, rings and forks. Long travel roads frame the web, and the first travel
    nodes are 2–3 points from the start. Within 9 points: about 130 nodes, 13–20 notables and about 19 loops.
    The first notables sit at 5 points.
26. **Think in constellations.** Beyond the start, PoE composes groups of clusters as one shape: twin hubs with
    mirrored leaf pairs (Feel no Pain), a hub on a ring (Brutal), a three-lane bridge between two hubs (PoE 1
    Witch: Arcanist's Dominion and Deep Wisdom), and a trident of three notables. Neighbouring clusters reach each
    other through a node or two, so a district reads as one fabric.

Metal pilot v5 (`tools/design/meridian_rework/`) is drawn by hand to these rules, on the original map's layout of
spokes and rings, which the user preferred over v4's square lattice.

### Cluster shape audit (2026-11-08)

Every PoE group holding a notable or keystone was sorted by its inner links and their geometry (`tools/design/
meridian_rework/poe_study/audit.py`, which writes the gallery `audit/gallery.html`). Counts are PoE 2 (621 clusters), with PoE 1 (387) after the
slash.

| Shape | PoE 2 | PoE 1 | Median nodes | What it looks like (examples) |
|---|---|---|---|---|
| Arc (crescent) | 18 % | 45 % | 4 / 3 | nodes on one orbit, notable at the end (Battle Trance, Overflowing Power) |
| Ring / wheel | 13 % | 33 % | 6 / 5 | closed orbit, notables on it (Growing Swarm, Blood of Rage) |
| Bent line | 13 % | 0.5 % | 4 | straight links that turn: L, V, U-bracket, hook (Heatproof, Lucky Rabbit Foot, Natural Immunity) |
| Lollipop | 11 % | 1 % | 5 | ring on a stem, or a ring with a notable on a spoke at its centre (Pinpoint Shot, Bloodthirsty) |
| Split | 6 % | 3 % | 6 | two mirrored halves joined only from outside: brackets ( ), concentric rings (Heart of Oak, Explosive Impact) |
| Polygon (5–6, straight) | 6 % | – | 6 | hexagon, kite, heart, cup (Mystical Rage, Adverse Growth, Smoke Inhalation) |
| Lens / theta | 4 % | 3 % | 6 | two hubs joined by three lanes; a circle with a diameter (Sanguine Tolerance, Mending Deflection) |
| Lattice (3+ loops) | 4 % | 1 % | 8 | snowflake, triangle in a triangle, concentric rings with spokes, an arrowhead (Endless Blizzard, Echoing Frost, Piercing Shot) |
| Zigzag / meander | 4 % | 0.3 % | 5 | S-curve, square wave (Whirling Onslaught, Invigorating Archon, Electrocuting Exposure) |
| Fork (Y) and trident | 3 % | 0.3 % | 6 | a stem splitting into two or three tines; a spear with a forked head (Elemental Force, Shockwaves, Focused Thrust) |
| Diamond / kite (4) | 2 % | – | 4 | four nodes, notable at the far corner (Mental Toughness, Stormwalker) |
| Ring with spokes | 2 % | – | 8 | a ring with arms out of it: a figure, an hourglass with handles (Right Hand of Darkness, Lasting Toxins) |
| Tri-star (Y, equal arms) | 2 % | 0.3 % | 4 | three equal arms from one hub, a T or anchor (Spiked Whip, Arcane Remnants, Blade Catcher) |
| Star / cross (4+ arms) | 2 % | – | 6 | X cross, + cross, asterisk (Blade Flurry, Lust for Sacrifice, Expendable Army) |
| Figure-8, ladder, chained diamonds | 2 % | 0.3 % | 9 | two loops sharing a node or a side; a totem pole (Made to Last, Supportive Ancestors) |
| Straight spoke, pair | 3 % | – | 2–3 | the rare plain stick |

27. **PoE 2 turned crescents into pictograms.** PoE 1 is mostly arcs and rings (78 %). PoE 2 keeps them to 31 %
    and draws the rest as recognisable figures that often match the theme: crosses for crossed-blade notables, a
    spear for Focused Thrust, a heart shape for Mystical Rage, a snowflake for Endless Blizzard.
28. **Several clusters per travel node.** Of travel nodes that carry clusters, 75 % (PoE 1) and 76 % (PoE 2) carry
    two or more, and about a quarter carry four.
29. **Outer clusters are bigger, and small ones lean on a big one.** PoE 2 cluster size grows outward: median 4 in
    the inner third, 5 in the middle, 5 in the outer third, with 13 %, 23 % and 34 % of clusters holding 7+ nodes.
    A small cluster (up to 4 nodes) shares its travel node with a cluster of 6+ nodes 58 % of the time (PoE 1:
    38 %).

## Where today's Kinh Mạch Đồ differs

| Ours today | PoE | Likely fix in the rework |
|---|---|---|
| One start at the centre | A ring of starts | Root-chosen starts on a ring (user decision 2026-11-08) |
| Empty middle band: about 2 % of nodes between half and nine-tenths of the radius; 27 % of the plate filled | No empty bands; 63–71 % filled | Fill the middle with road networks and pockets; the rim stays rich |
| 5.8 small nodes per notable pocket; 85 notables 8+ steps from the next | 2.7–3.4 per pocket; notables 2–6 apart | Shorter pockets, notables in pairs or triples |
| Largest junction has 4 links | Crossroads of 5–9 links, on travel nodes | Real crossroads on road nodes |
| Nearest keystone 22 points from the start (besides the centre one) | 6–13 | A keystone within about 10 points of every start |
| 6 of 19 keystones have two links | Every keystone is a dead end | Keystones only at tips |
| Clusters grown as blobs; curves are smoothing | Clusters are orbit forms (wheels, arcs, spokes) | A small library of orbit cluster templates |
| Roads carry stats (road_stats), already like PoE's travel | Travel pays attributes | Keep; consider a pick-one road node |

Already PoE-like: about 15 loops per 100 nodes, most pockets with one way in (83 %), and a round outline.

## Questions to settle before the rework

1. ~~Tree size and budget~~: settled, about 5,000 nodes (decision 5 at the top).
2. ~~The start ring~~: settled provisionally (decisions 6 and 7 at the top).
3. ~~Hybrid zones~~: settled, neighbours blend (decision 8).
4. ~~Hand-drawn or generated~~: settled, hand-authored (decision 9).
5. ~~Theme split~~: settled (decision 10).
6. **Cluster mastery (Tinh Thông).** Now or later, and does it host minor Effects, plain modifiers or both?
