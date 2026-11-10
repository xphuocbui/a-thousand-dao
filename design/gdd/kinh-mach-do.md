# Meridian Map (Kinh Mạch Đồ)

> **Status**: Major revision in progress (design-review 2026-11-10: MAJOR REVISION NEEDED; the user's answers are in
> `reviews/kinh-mach-do-review-2026-11-10.md`, and the rewrite goes section by section with the user). The map is now
> the hand-drawn tree, lean build (`design/research/meridian-tree-overnight.md`, drawn with
> `tools/design/meridian_rework/`); hidden clusters are scrapped (user decision 2026-11-09: cultivation-technique
> and item trees move to a separate tab); capability rule text lives in `effects.md`. Sections not yet rewritten
> still describe the old generated map and say so. Earlier history: `reviews/kinh-mach-do-review-log.md`.
> **The map is a shape placeholder** (user, 2026-11-10): the drawn tree's layout, regions, sizes and distances stand in
> for the real map and will change further, as will its content. The rules here (points, opening, purity scaling,
> roads granting purity, capabilities, starts, the drawing checks) are the design; the measured numbers (7,115
> acupoints, region sizes, distances in Formulas B and H) describe today's placeholder and are re-measured whenever the
> map changes.
> **Creative Director Review (CD-GDD-ALIGN)**: skipped (Lean mode)
> **Author**: user + Claude
> **Last Updated**: 2026-11-10
> **Last Verified**: 2026-11-10
> **Implements Pillar**: Pillar 1 (Your Dao, Your Name), Pillar 3 (Power Is Built, Not Given); touches Pillar 2 (Every
> Number Is Bounded and Visible)

## Summary

The Meridian Map (Kinh Mạch Đồ) is the game's PoE-style passive tree.

- **The map.** One hand-drawn map of about 7,100 visible acupoints (huyệt): five element lands (Metal, Wood, Water,
  Fire, Earth) with five blend zones between them, the Taiji hub at the centre, Wind's land and the Ice start inside
  the rim, and the Light, Darkness and Thunder islands and the Shadow Shrine outside it, all joined by roads. It is
  identical in every life and append-only from a fresh id baseline (user decision 2026-11-10).
- **Starts.** 11 starts. The player starts at any start whose element or variant the root holds; an NPC takes its
  strongest element's (user decision 2026-11-10).
- **Points.** Earned per level (1–110) and, mostly, at great and small breakthroughs. One point opens one acupoint
  next to an open one.
- **Value.** Every acupoint's value scales with the root's purity in its element. An element land's roads also grant
  that element's purity (about 0.5 per node); blend roads half of each neighbour's; hub roads give general stats.
- **Capabilities.** The map places 25 rule changes (capabilities) in its clusters; their rules live in `effects.md`.
- **The map is a placeholder.** Both the shape (layout, regions, sizes) and the content (names, modifiers,
  keystones) are placeholders and will change (user, 2026-11-10); a later content pass also gives every element land
  a keystone that generates linh lực.
- **Not here.** Cultivation techniques and items get their own small trees in a separate tab.
- **Bounds.** Every number is bounded and recorded. NPCs build on the same tree under the same rules.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps:
`Linh Căn, Character Stats, Cảnh Giới & Bình Cảnh, Modifier System, Effects System`

## Overview

The Meridian Map (Kinh Mạch Đồ) is a fixed, hand-drawn map of acupoints (huyệt) that a character explores with
meridian points (Kinh Mạch points) earned at each breakthrough. A point opens one acupoint next to an already-open
one. Small acupoints carry modest bonuses, notables larger ones, and keystones a strong rule paid for by what it
closes.

The map follows Path of Exile's grammar: roads of travel nodes with clusters hung on them, a cluster joined to its
road at its nearest node, notables after two or three small nodes, bigger clusters toward the rim, and a way around
every cluster a road passes. Each element has a land, each pair of neighbours a blend zone between them, the Taiji
hub sits at the centre, and the variant roots have their own starts and lands.

The spiritual root (linh căn) decides where a character starts and which lands are worth walking, because bonuses
scale with purity. Walking an element's roads also deepens that element's purity, slowly. The map is identical in
every life, so it can be learned and planned across realms.

The tree is where Pillar 1 (Your Dao, Your Name) and Pillar 3 (Power Is Built, Not Given) meet: two cultivators with
the same root diverge by the lands they walk and the keystones they take. It stays inside Pillar 2 because every
value is priced by the Modifier System and every rule is an Effect with its own bounds.

## Player Fantasy

You read the map the way a cultivator reads their own body. Your spiritual root (linh căn) tells you where you may
begin and which lands are yours to walk, and every point is a small, permanent decision: no refunds, no respec. The
planning pleasure is in the long routes: you spot a keystone at the edge of the Fire land twelve steps away and count
what it will cost.

Walking an element's roads changes you as well as your build: each step deepens your purity in that element, so the
land you choose becomes more truly yours. Far out past the rim lie the islands of Light, Darkness and Thunder,
reached by long bridges, and a build that wants them pays for the journey.

## Detailed Design

The built game still runs the old generated map (`src/gameplay/meridian/`, 2026-11-05: about 1,300 acupoints with
hidden clusters and variant sectors). The drawn tree replaces it at implementation, from a fresh id baseline (rule
19); until then the difference is listed under **Known gaps in the build** (Open Questions). Quantities in these rules
are named parameters; their values and ranges are in Formulas.

### Core Rules

**The map**

1. **The map is drawn by hand.** It is the lean build of the Meridian kit (`tools/design/meridian_rework/`,
   `build_tree.py` with `KMD_LIGHT=1`), drawn by the rules in `design/research/meridian-land-authoring.md`; its
   output, `tree.json`, is the map data. It is identical in every life.
   - **Regions** (14; visible acupoints in the lean build of 2026-11-10):

     | Region | What it is | Acupoints |
     |---|---|---|
     | Five element lands | Metal, Wood, Water, Fire, Earth, each with its own ring roads, spokes, identity districts and a second element theme | 811–980 each (4,379) |
     | Five blend zones | Between each pair of neighbouring lands; their rings carry one land's radius to the other's | 348–401 each (1,906) |
     | The Taiji hub | The centre, holding the Primordial Chaos start; five dantian roads run out to the blend zones | 101 |
     | Wind's land and the Ice start | Wind has its own land between Water and Wood near the rim; Ice starts inside Water's land | counted in their lands |
     | Islands | Light, Darkness and Thunder outside the rim, joined by bridges (Thunder only to Wind); the Shadow Shrine (Ám Từ), a satellite on the shadow road (kept, user decision 2026-11-10) | 217–282 each (729) |

   - **Pieces:** 11 starts, 616 road (travel) nodes, 5,364 small acupoints, 1,084 notables and 40 keystones, in
     811 clusters: 7,115 visible acupoints.
   - **Grammar** (the authoring guide's rules): roads of travel nodes carry the clusters; a cluster joins a road at
     its nearest node; a notable comes after two or three small acupoints (none only for hubs); a road node carries
     two or three clusters, one of them big toward the rim; every road that passes a cluster leaves a way around it;
     no figure stands beside its twin; clusters grow toward the rim.
   - **Drawing checks** (run on every build, AC-KMD-60): no crossing links, no two acupoints closer than 0.6, no
     link grazing an acupoint, every acupoint reachable from every start, no cluster without a bypass, at most 6
     links on one acupoint.
   - **Distances:** neighbouring element starts are 12 points apart, opposite ones about 24; the Chaos start is
     15–16 from every element start; the far rim is about 50 points out, the islands farther.
   - **Shape and content are placeholders.** The drawn layout is a shape placeholder that will change further (user,
     2026-11-10), and its names, modifiers, keystones and capability placements are filled in one content pass (user
     decision 2026-11-09), which also gives every element land a keystone that generates linh lực. The counts and
     distances above are measured on today's placeholder.
   - **Not on this map:** sealed and open hidden clusters are retired (rules 6–15). Cultivation-technique and item
     trees are separate small trees in their own tab, spending the same points
     (`design/research/side-trees-thoughts.md`).
2. **Points.** Cultivation runs on **levels 1–110**. Each realm is a band of levels, and at
   the top of the band the bottleneck (bình cảnh) holds the level until the realm breakthrough succeeds.
   Points come from:
    - **Birth:** 2.
    - **Levels:** 1 point per level gained. A level gives points only; stat rises come from
      breakthroughs.
    - **Great breakthroughs:** entering a new realm (its early stage, sơ kỳ). Each one has a
      bonus (`great_breakthrough_bonus`: Foundation Establishment [Trúc Cơ] 30, Core Formation [Kết
      Đan] 40, Nascent Soul [Nguyên Anh] 61, Deity Transformation [Hóa Thần] 100), paid in
      full on success.
    - **Small breakthroughs:** inside each realm, the early, middle and late stages (sơ kỳ,
      trung kỳ, hậu kỳ) split the realm's levels into thirds, and great perfection (đại viên
      mãn) is the realm's last level.
        - Reaching the **middle stage**, the **late stage** and **great perfection** each pays
          that realm's `small_breakthrough_bonus`: Qi Refining 13 / 13 / 14, Foundation
          Establishment 3 / 3 / 3, Core Formation 5 / 5 / 6, Nascent Soul 20 / 20 / 20, Deity
          Transformation 33 / 33 / 33.
    - **Events:** an event may grant 1 (the Event Engine's budget file caps grants; Open
      Question 11).
    - Every great and small breakthrough also raises base stats.

   **Shared with the Way (Đạo).** The same points also buy Dao nodes (`design/gdd/dao.md`
   rule 7), at the same 1 point a node. This system owns the total. The Way keeps its own count
   of points spent, and a character's unspent points are the total minus the acupoints opened
   minus the Way's count. A point spent on a Dao node is never returned to the map. For an
   NPC, the Way deducts its Dao points from the points the allocator receives (dao.md Formulas D3).

   Totals at great perfection: Qi Refining 51, Foundation Establishment 120, Core Formation
   216, Nascent Soul 357, Deity Transformation 566. Formulas has the exact computation. Realms & Bottlenecks (Cảnh
   Giới & Bình Cảnh) owns the level bands, the stat rises and these values, and the Event
   Engine owns event grants. Realms' values are registered; event grants are provisional.
3. **Opening an acupoint** costs 1 point. It must not already be open, must be adjacent to an open acupoint, and, for
   an acupoint that names a minimum element count, the player's spiritual root (linh căn) must have that many base
   elements. Opening a path to a target opens every acupoint on the shortest route, all or nothing: it fails without
   spending anything if the points do not cover the whole route. When several routes are equally short, the one with
   the highest total scaled value (rule 4) is taken, then the one whose acupoint ids sort lowest; the path tool
   previews that route. Points are never refunded and there is no respec.
   - **The start** (user decision 2026-11-10). At birth the player picks any start whose element or variant the root
     holds: an element start for an owned base element, the Chaos start for the Primordial Chaos root, and the Light,
     Darkness, Thunder, Ice or Wind start for that variant. A single-element root without variants has one choice.
     The start is owned at once and costs nothing. An NPC takes the start of its highest-purity element, ties broken
     in generating-cycle order (Wood, Fire, Earth, Metal, Water).
4. **Bonuses.** Each open acupoint adds its modifiers to the character's stat sheet under the source "Kinh Mạch:
   <name> #<id>". Values are priced by the Modifier System (Formulas F reads `modifier_prices`).
   - **Land acupoints** (small, notable, cluster) are multiplied by 0.5 + purity/100 for their land's element, or by
     0.25 at purity 0 (purity a road granted counts, even in an element the root does not own; Spiritual Roots rule 8a); a blend-zone acupoint uses the average of its two lands' multipliers; a variant land's
     (rule 20) uses that variant's purity the same way. Keystones and the hub are exact.
   - **Roads.** An element land's road nodes grant only that element's purity, about `road_purity` (0.5) each, exact
     (Spiritual Roots rule 8a: purity is proficiency and has no cap); a blend zone's grant half of each neighbour's;
     a variant land's roads (Wind's land, the islands) grant that variant's purity the same way (user decision
     2026-11-10, Spiritual Roots review D4); the hub's dantian roads give general stats. The amount
     is bot-tuned so purity above 100 stays rare (user decisions 2026-11-10).
   - **Keys.** Any key in the Modifier System's Stat List may appear except `leech_health_pct` and
     `bonus_ward_slots`, the rare sustain exception (user decision 2026-11-10); rare modifiers only on keystones.
   - **Breakthrough.** The summed `breakthrough_chance` from all Meridian Map acupoints follows a diminishing-return
     curve, `k · ln(1 + Σ / k)` with `k` = `tree_breakthrough_k` (Formulas F), not a clamp (user decision 2026-11-10);
     the sheet shows the curve line. It remains a q-extras source under Realms' ceiling.
5. **NPCs** spend their points greedily under the same rules: every reachable acupoint is
   scored by its kind and boosted if it lies in a sector favoured by the NPC's archetype,
   with a small random term, until the points run out. The weights are
   `tree_kind_scores` and `tree_focus_weight` in `world_generation.json`. An NPC may open a capability notable
   under rule 16's realm minimum. The allocator's budget on a map of 7,000+ acupoints is in Formulas
   (Computational budget).

**Retired rules (kept as numbers so other documents' references stay valid)**

6. **Retired 2026-11-09: hidden clusters.** The sealed and open clusters are scrapped (user decision). Content a life
   unlocks (cultivation-technique and item trees, LLM story-moment content) goes in side trees in their own tab.
7. **Retired:** seal conditions (were rule 6's clusters).
8. **Retired:** hidden state.
9. **Retired:** unsealing.
10. **Retired:** open clusters and the LLM fill.
11. **Retired:** the fill budget.
12. **Retired:** sealed-cluster content.
13. **Retired:** visibility modes (Silhouette and Visible) for hidden content; the whole map is always visible.
14. **Retired:** NPC unsealing.
15. **Retired:** per-life cluster state. A character's map state is its start and the open acupoints.

**Capabilities**

16. **A capability** is a rule change, not a stat: it lets the character do something the rules otherwise forbid.
    Its rule text, numbers and closing cost live in `effects.md` (the Keystones and Life tables re-express all 25;
    user decision 2026-11-10). This GDD owns the placement: which notable or keystone holds which capability, in
    `meridian_capabilities.json`, and the capability-set contract (Character Stats stores the set). A capability
    notable carries a realm minimum of Core Formation (`cap_realm_min`), so none can affect the first two
    breakthroughs; this replaces the old sealed-cluster size gate. Opening it grants the capability for the rest of
    the life. Placements are part of the content pass.
17. **The launch catalogue** (25 entries; each row's rule and closing cost is its `effects.md` record, and #1, #4,
    #17 and #25 follow `effects.md` where the two texts differed):

    | # | Capability | System touched | Rule and closing cost |
    |---|---|---|---|
    | 1 | Twin Arms in Harmony (Song Khí Hợp Bích) | Magic treasures, Combat | effects.md record |
    | 2 | Divided Divine Sense (Thần Thức Phân Hóa) | Magic treasures, Character Stats | effects.md record |
    | 3 | Treasure Nurtured Within (Dưỡng Bảo Nội Thể) | Magic treasures | effects.md record |
    | 4 | Blood Commands Spirit (Huyết Ngự Linh) | Character Stats, Combat | effects.md record |
    | 5 | Soul Leaves the Body (Linh Hồn Xuất Khiếu) | Event Engine, Realms | effects.md record |
    | 6 | Twin Technique Cultivation (Song Tu Công Pháp) | Cultivation Techniques (Công Pháp) | effects.md record |
    | 7 | Embryonic Breath (Thai Tức Quy Nguyên) | Time & Turn (aging) | effects.md record |
    | 8 | Dao in Dreams (Mộng Trung Ngộ Đạo) | Cultivation, Travel | effects.md record |
    | 9 | Great Essence-Draining Art (Hấp Tinh Đại Pháp) | Realms, Character Stats (heart demon) | effects.md record |
    | 10 | Divided Furnace Flame (Đan Hỏa Phân Lô) | Alchemy (Luyện Đan) | effects.md record |
    | 11 | Strange Pill Reborn (Dị Đan Hóa Sinh) | Alchemy | effects.md record |
    | 12 | Hundred Herbs Kept Alive (Bách Thảo Tàng Linh) | Herbs | effects.md record |
    | 13 | Endless Talismans (Phù Lục Bất Tận) | Talismans (Phù Lục) | effects.md record |
    | 14 | Portable Cave Abode (Động Phủ Tùy Thân) | Formations (Trận Pháp), Spirit Fields | effects.md record |
    | 15 | Formation Within a Formation (Trận Trung Trận) | Formations | effects.md record |
    | 16 | Ten Thousand Beasts, One Heart (Vạn Thú Đồng Tâm) | Spirit Beasts (Linh Thú) | effects.md record |
    | 17 | Beast Soul Union (Thú Hồn Hợp Thể) | Spirit Beasts, Combat | effects.md record |
    | 18 | Reading Heaven's Secrets (Thiên Cơ Diễn Toán) | Event Engine | effects.md record |
    | 19 | Child of Fortune (Khí Vận Chi Tử) | Event Engine | effects.md record |
    | 20 | Concealed Breath (Liễm Tức Ẩn Thân) | Event Engine, NPCs | effects.md record |
    | 21 | Blink Mark (Thuấn Di Ấn) | Travel | effects.md record |
    | 22 | Last Radiance (Hồi Quang Phản Chiếu) | Realms | effects.md record |
    | 23 | Burning Life to Break Through (Thiêu Thọ Phá Cảnh) | Realms | effects.md record |
    | 24 | Mutation Awakening (Biến Dị Khai Mở) | Spiritual Root | effects.md record |
    | 25 | Heart Demon Turned to Strength (Tâm Ma Hóa Lực) | Heart Demon, Combat | effects.md record |

    #14 sits between the Formations and Spirit Fields districts (Earth and Wood), where it reads as both.

    Capabilities 22 and 23 act on breakthrough odds. Each is usable once per realm, and at most one of them acts per
    realm step. #22's gain is capped, and #23 costs the greater of 10 years and 5% of the realm's lifespan
    (Formulas E2). They must be calibrated against the progression targets (Realms & Bottlenecks Formulas E: the
    player's edge is 0.70 / 0.70 / 0.30 / 0.20) before they ship. NPCs can open capability notables (rule 5), so this
    applies to NPCs too.
18. **Capabilities do not stack with themselves.** A capability is held or not. Two
    capabilities that touch the same number apply in catalogue order, and each
    catalogue entry names any capability it cannot be combined with.

**Growing the map**

19. **The map is append-only from a fresh baseline.** The drawn tree starts a new id baseline when it replaces the
    generated map (user decision 2026-11-10). From then on every acupoint and cluster keeps its id and position
    forever; new content is added beyond the rim or in the islands' outer edges, linked to existing acupoints, and
    never moves, renumbers or reshapes anything already there. Saves, World Database events and the Codex stay valid
    across content updates. A save made on the old generated map is migrated once: its opened acupoints are refunded
    as unspent points and the character picks a start under rule 3.

**Variant lands**

20. **Variant roots have their own starts and lands** (user decision 2026-11-10, replacing the variant sectors of
    2026-11-04). Wind has its land, Ice its start inside Water's land, Light, Darkness and Thunder their islands, and
    Primordial Chaos the hub. They are open to everyone, like the element lands; a variant land's acupoints scale by
    0.5 + purity/100 for that variant, or 0.25 at purity 0. A variant start can be picked only by a root
    holding the variant (rule 3). Blood and Void, archived as roots (Spiritual Roots, 2026-11-09), have no land; their
    old sector data stays locked and is not counted in the map size or the calibration.

**Drawing rules**

21. **The map is drawn to the authoring guide** (whatever shape it takes next). `design/research/meridian-land-authoring.md` (targets, dos and
    don'ts) and the kit's rules in `regions/landkit.py` (caps on repeated figures, no twins, gold at the ends of
    branches, districts, quiet fields, keystone clearings) are the drawing rules. Every build reports the guide's
    measures (cluster joins, clusters per road node, cluster sizes by band, notables, keystone distances, open space)
    and runs rule 1's drawing checks.

**What the player cannot do:** refund or respec; start at a start its root does not hold; open a capability notable
below Core Formation.

### States and Transitions

| Subject | State | Becomes | When | Guard |
|---|---|---|---|---|
| Start | Unchosen | Owned | The character is born (or an old save is migrated, rule 19) | A start the root holds (rule 3); free |
| Acupoint | Closed | Open | The player spends 1 point | Rule 3; a capability notable needs `cap_realm_min` (rule 16) |
| Acupoint | Open | (stays) | Never closes | No refund, no respec |
| Capability | Not held | Held | Its notable or keystone is opened | Held for the rest of the life |

Hidden clusters, their states (Hidden, Pending, Awaiting fill, Unsealed) and locked variant sectors are retired
(rules 6–15, 20).

### Interactions with Other Systems

All interfaces are provisional where the other GDD does not exist yet.

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Spiritual Root | in / out | in: purity per element and variant, base element count (rules 3, 4, 20), which starts the root may pick; out: purity granted by element-land and blend-zone roads (rule 4; Spiritual Roots rule 8a) | Spiritual Root (purity); this GDD (how much the roads grant) |
| Character Stats | out | modifiers {source, stat, value}; the character's capability set (held capability ids); the tree's breakthrough curve line; the tree never computes a stat | Character Stats (stat keys and their meaning; storage of the capability set) |
| Realms & Bottlenecks | in | the highest level reached (points_total, Formulas A) and the ladder constants (bands, great and small breakthrough bonuses); the realm (`cap_realm_min`). Its `level_gained`, `stage_reached` and `breakthrough_succeeded` events trigger the recompute | Realms |
| Modifier System | in | the Stat List, `modifier_prices` and breadth tiers that price every acupoint (Formulas F) | Modifier System |
| Effects System | in | the rule text and closing cost of every capability and keystone (rule 16) | Effects System (rules); this GDD (placement) |
| Combat, Combat Defence & Healing, Combat Damage Types | none direct | only the stat modifiers above, including the #44 defence and sustain keys (rule 4) | — |
| The Way (Đạo) | in / out | one shared pool of points: the Way's spent count is subtracted from this system's total | this GDD (the total); the Way (its costs) |
| Event Engine | in | the "grant a point" effect | Event Engine |
| NPC Builds | in / out | the NPC's start (rule 3) and its allocation | NPC Builds (generation); this GDD (the rules) |
| Capability hosts (Magic treasures in Artifact Refining, Cultivation Techniques, Time & Turn, Alchemy, Spirit Herbs & Spirit Fields, Talismans, Formations, Spirit Beasts, Travel & Map, Event Engine, Realms, Spiritual Root, Character Stats; the list is in Dependencies) | out | the character's capability set, which each host reads; each host implements the rule change | `effects.md` (the rule); each host (the behaviour); this GDD (where it sits) |
| Guidance Layer / Debug Terminal / Game UI | out | the drawn map (regions, starts, clusters), the start choice at birth, route previews, purity gained from roads | Guidance Layer |
| Save/Load | out | the start, the open acupoints, and the one-time migration flag (rule 19) | Save/Load |

## Formulas

Values are in **W**, a common power unit: 1 W = the value of +1% attack. An acupoint's (huyệt) power is its modifiers
priced by the Modifier System (formula F1). Values marked "guess" need a bot run (`tools/balance/autoplay.gd`,
`tools/balance/npc_cohort.gd`) before they are trusted. Rounding is half away from zero everywhere. Points are whole
numbers read from data, so Formulas A needs no rounding. Rewritten 2026-11-10 for the drawn map (major revision).

### A. Points

The points_total formula is defined as:

`points_total(L) = pts_birth + (L − 1) + Σ_i bonus_i(L) + pts_event`

where, for each realm i with levels [lo_i, hi_i], N_i = hi_i − lo_i + 1, its great bonus
B_i and its small bonuses s_i,1 to s_i,3:

`bonus_i(L) = [L ≥ lo_i]·B_i + [L ≥ t_i]·s_i,1 + [L ≥ h_i]·s_i,2 + [L ≥ hi_i]·s_i,3`

with `t_i = lo_i + floor(N_i/3)` (first level of the middle stage [trung kỳ]) and
`h_i = lo_i + floor(2·N_i/3)` (first level of the late stage [hậu kỳ]). Qi Refining (Luyện
Khí) has no entry term.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| L | int | 1–110 | calculated | Highest level ever reached (a level lost later never takes points back) |
| pts_birth | int | 2 | data file | Points at birth |
| lo_i, hi_i | int | Qi Refining 1–10, Foundation Establishment (Trúc Cơ) 11–40, Core Formation (Kết Đan) 41–80, Nascent
Soul (Nguyên Anh) 81–100, Deity Transformation 101–110 | data file | Realm level bands (registered; Realms &
Bottlenecks [Cảnh Giới & Bình Cảnh] owns them) |
| B_i | int | Foundation Establishment 30, Core Formation 40, Nascent Soul 61, Deity Transformation 100 | data file (
`great_breakthrough_bonus`) | Great breakthrough bonus, paid in full on success |
| s_i,1, s_i,2, s_i,3 | int | Qi Refining 13, 13, 14; Foundation Establishment 3, 3, 3; Core Formation 5, 5, 6; Nascent
Soul 20, 20, 20; Deity Transformation 33, 33, 33 | data file (`small_breakthrough_bonus`) | Points at the realm's middle
stage, late stage and great perfection (đại viên mãn) |
| t_i, h_i | int | e.g. Qi Refining 4 and 7, Foundation Establishment 21 and 31 | calculated | First level of the middle
and late stages |
| pts_event | int | 0+ | calculated | Event grants, +1 each |
| points_total | int | 2–566 (+ events) | calculated | Points earned in the life |

**Output Range:** 2 at level 1 to 566 at level 110, plus events; never decreases.

| Point                                        | Level | Total |
|----------------------------------------------|-------|-------|
| Qi Refining great perfection                 | 10    | 51    |
| Foundation Establishment early stage (sơ kỳ) | 11    | 82    |
| Foundation Establishment great perfection    | 40    | 120   |
| Core Formation early stage                   | 41    | 161   |
| Core Formation great perfection              | 80    | 216   |
| Nascent Soul early stage                     | 81    | 278   |
| Nascent Soul great perfection                | 100   | 357   |
| Deity Transformation early stage             | 101   | 458   |
| Deity Transformation great perfection        | 110   | 566   |

**Example:** Level 26 (Foundation Establishment middle stage):

- 2 at birth + 25 from levels.
- Qi Refining small breakthroughs: 13 + 13 + 14 = 40.
- Foundation Establishment entry: 30.
- Foundation Establishment middle stage: 3.
- Total: **100**.

### A2. Acupoint value scale

The small and notable values stay as on the generated map; the drawn map's mix of pieces sets its mean.

The value_scale formula is defined as:

`w̄_map = (n_road·R0 + n_sm·S0 + n_not·N0) / (n_road + n_sm + n_not)` ; `R0 = road_purity · purity_price`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| S0, N0 | float | 1.2 W, 8 W | data file (Modifier System `grade_small`, `grade_notable`) | Base small and notable values, before the purity multiplier (rule 4) |
| `road_purity` | float | 0.5 (guess) | data file | Purity an element-land road node grants (rule 4); a blend road grants half of each neighbour's |
| `purity_price` | float | 0.3 W per purity point (guess) | data file | What one point of purity is worth, through the acupoint multiplier and element stacks (Spiritual Roots rule 8a) |
| R0 | float | 0.15 W | calculated | Value of an element-land road node |
| n_road, n_sm, n_not | int | 616, 5,364, 1,084 | measured (lean build, 2026-11-10) | Road nodes, small acupoints and notables (no starts, no keystones) |
| w̄_map | float | 2.15 W | calculated | Mean W per acupoint over the visible map; a data lint (AC-KMD-06), not a power target |
| Keystone | float | ≥ 50 W | data file | A keystone's positive side; its rule and closing cost are its `effects.md` record |

**Output Range:** w̄_map is 2.15 W at the defaults (2.07 W was the generated map's per-point target). A life's tree
power is set by the route it walks, not the map's mix: the route share of road nodes, small acupoints and notables
is re-measured by the bot on the drawn map (AC-KMD-07; the generated map's figure was 95–116 W at Qi Refining's
end). Hub roads give general stats at S0.

**Example:** (616 × 0.15 + 5,364 × 1.2 + 1,084 × 8) / 7,064 = (92 + 6,437 + 8,672) / 7,064 = **2.152 W**. A typical
small acupoint is +1.2% attack (or +0.5% cultivation speed); a notable +8% attack; a Fire road node +0.5 Fire purity.

### B. Distances from the starts

The drawn map replaces the generated map's bands (K1–K3, depths 5/14/20). What a start reaches is measured on every
build (lean build, 2026-11-10):

| Start | First notable | Nearest keystone | Keystones within 20 | Acupoints within 9 | Farthest |
|---|---|---|---|---|---|
| Metal, Wood, Fire, Earth, Water | 4 | 7 | 7–10 | 143–180 | 54–61 |
| Primordial Chaos (hub) | 3 | 11 | 5 | 151 | 55 |
| Ice | 3 | 6 | 6 | 194 | 63 |
| Wind | 3 | 9 | 11 | 303 | 60 |
| Light, Darkness, Thunder (islands) | 1–3 | 6–8 | 1–7 | 94–261 | 64–68 |

**Targets** (`start_targets`, the authoring guide): first notable within 5 points; nearest keystone 6–13 points
(PoE's range); every start within 70 points of the farthest acupoint. Neighbouring element starts are 12 points
apart and the Chaos start 15–16 from each (rule 1).

### C, D. Retired: hidden cluster generation and cluster premium

Retired with the hidden clusters (rules 6–15). The cluster premium P(d, n) and the per-cluster values E_small and
E_notable it set are gone: every small acupoint is S0 and every notable N0, before the purity multiplier.

### E. Capability notables

A capability's worth depends heavily on the build, so it is not priced in W. Each catalogue entry has a **tier**,
and the tier sets how much of a notable's stat value stays beside the capability.

The capability_notable formula is defined as:

`E_cap_notable = f_tier · N0`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| f_tier | float | T1 0.5, T2 0.25, T3 0 | data file | Stat share kept by a capability notable |
| tier | enum | T1, T2, T3 | data file (catalogue) | T1 narrow, T2 build-shaping, T3 survival or breakthrough |
| N0 | float | 8 W | data file | A notable's base value (A2) |
| `cap_realm_min` | enum | Core Formation | data file | Realm a capability notable needs to be opened (rule 16) |

Initial tiers (guess): **T1** #10 Divided Furnace Flame and #19 Child of Fortune; **T3** #5 Soul Leaves the Body,
#22 Last Radiance and #23 Burning Life to Break Through; **T2** every other entry, until a bot measurement places it.
A measurement compares the metric with and without the capability (combat power for combat capabilities, the
system's own output for the others); below half a notable is T1, up to one notable T2, above that or unmeasurable T3.

**Output Range:** 0–4 W of stats before the purity multiplier; the capability itself is not scaled.

**Example:** a T2 capability notable carries 0.25 × 8 = **2 W** of stats, e.g. +2% attack, times its land's purity
multiplier.

### E2. Breakthrough guard

Capabilities #22 Last Radiance and #23 Burning Life to Break Through must not move a
realm's breakthrough success by more than δ_max.

**Attempt model.** A realm step is a series of pill attempts (bare attempts, defined
by Realms & Bottlenecks, are not part of it), each succeeding with chance q,
until one succeeds or the life ends. S is the resulting chance of crossing the realm.

- **#22 (desperation)** replaces one attempt's chance q with q_desp. If that attempt
  also carries the realm step's breakthrough talisman (Realms & Bottlenecks rule 8: at
  most one per realm step, τ = 0.05, on a held pill attempt), τ_a is the talisman's
  part of the attempt's chance and q is the chance without it; the attempt then
  succeeds with q_desp + τ_a. On any other attempt τ_a = 0.
- **#23 (retry)** adds one extra attempt with chance q_retry (at most q) right after a
  failed pill attempt, without waiting. The extra roll never carries a talisman (Realms
  & Bottlenecks rule 8), so it has no τ_a term.
- **Failure insight (Realms & Bottlenecks).** Each failed pill attempt in a realm step
  adds ι = `breakthrough.failure_insight_pp` (0.02) to the chance of later attempts in
  that step, up to `failure_insight_cap` (0.04). **In E2, q is the attempt's chance
  including insight and excluding τ_a.** #23's extra roll is a pill attempt: if it
  fails, it adds ι_23 to the next attempt. #22 is unaffected and stays exact: the #22
  attempt is still one attempt, and its failure adds the same insight with or without
  #22, so every later attempt is the same in both cases.
- **Heavenly suppression (Realms & Bottlenecks Formulas C and H).** At the last two gates
  every value here is after `gate_factor` f: q and S use suppressed chances, τ_a = f · τ and
  ι_23 scales by f.
- **At most one of #22 and #23 acts per realm step.** A character holding both chooses
  which to use for that realm.

The breakthrough_guard formula is defined as:

`q_desp = min(2q, q + Δ_desp, q_max − τ_a, q + δ_max·(1 − q − τ_a)/(1 − S))` ; attempt chance `= q_desp + τ_a` ;
`ι_23 = 0 if I ≥ failure_insight_cap, else f · min(failure_insight_pp, failure_insight_cap − I)` ;
`q_retry = min(q, (δ_max − ι_23)/(1 − S))` ; `S'_22 = 1 − (1 − S)·(1 − q_desp − τ_a)/(1 − q − τ_a)` ;
`S'_23 = S + q_retry·(1 − S) + ι_23·(1 − q_retry)·F_0` ; `max(S'_22, S'_23) ≤ S + δ_max`

The last terms of q_desp and q_retry are the guard's construction: each is the largest
value of the attempt chance that keeps its own lift at or below δ_max for any S (solve
`(1−S)·(q_desp − q)/(1 − q − τ_a) ≤ δ_max` and `q_retry·(1−S) ≤ δ_max − ι_23`). The bound
therefore holds by construction, with or without the talisman and the insight, and is
tested analytically; the bot run only confirms it.

**#23's insight carry.** If the extra roll fails, the next pill attempt's chance rises
from p_next to p_next + ι_23. The lift is then exactly q_retry·(1 − S) + ι_23·(1 −
q_retry)·F_0, where F_0 = (1 − S)/(1 − p_next) is the chance of failing every attempt in
the step except that next one (F_0 = 0 if there is no next attempt). Because (1 −
q_retry)·F_0 ≤ 1, the carry is at most ι_23 and the lift at most (δ_max − ι_23) + ι_23
= δ_max; the guard is conservative (it reserves the full ι_23). The carry reaches only
the next attempt: the attempt that triggered the extra roll has already added insight
(I ≥ failure_insight_pp), so once the next attempt also fails, both paths sit at the
cap. **This needs `failure_insight_cap` ≤ 2 × `failure_insight_pp`** (4 ≤ 2 × 2 today).
Above that, a failed extra roll lifts several later attempts, and ι_23 in q_retry must
become their summed carry. The `q_max − τ_a` term keeps the attempt
chance q_desp + τ_a at or below q_max. **With τ_a = 0 every #22 formula reduces exactly
to its form before the talisman** (`min(2q, q + Δ_desp, q_max, q + δ_max·(1 − q)/(1 − S))`
and `1 − (1 − S)·(1 − q_desp)/(1 − q)`). q_retry has no τ_a term, because #23's extra
roll never carries a talisman; **with ι_23 = 0 it reduces exactly to its old form**
`min(q, δ_max/(1 − S))`. The doubling (2q) and Δ_desp caps apply to q, not to the
talisman: #22 never doubles τ_a. The formulas assume S < 1: at S = 1 there is nothing
to lift, and neither capability acts (the implementation must test this before
dividing by 1 − S). The #22 lift's denominator 1 − q − τ_a is positive, because the
attempt chance q + τ_a is clamped to q_max = 0.95 (Realms & Bottlenecks Formulas).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| S | float | 0 ≤ S < 1 (S_guard is capped at 0.95) | calculated (S_guard, Realms & Bottlenecks GDD, Formulas H) | Lower
bound on success per realm before capabilities, from the pill attempts made and the pills held (player edge targets ≈
0.70 / 0.70 / 0.30 / 0.20) |
| q | float | 0.01–0.95 (0.01–0.90 when τ_a = 0.05) | calculated (`CultivationRules`) | Chance per attempt, including
failure insight, without τ_a |
| τ_a | float | 0 or f · τ (0.05; 0.016 at CF→NS, 0.01 at NS→DT) | calculated (τ from Realms & Bottlenecks, Formulas,
`crafting_talismans.json`) | The breakthrough talisman on the attempt #22 acts on: τ if the realm step's one talisman is
used on that attempt, else 0. If the q_max clamp cuts the talisman short, τ_a is the part that applies, so q + τ_a ≤
q_max |
| q_desp | float | q to q_max − τ_a | calculated | #22's chance for the attempt without τ_a, clamped by the guard; the
attempt succeeds with q_desp + τ_a |
| ι_23 | float | 0 or f × 0.02 (0 to f × `failure_insight_pp`) | calculated (`breakthrough.failure_insight_pp` 2 and
`failure_insight_cap` 4 pp, Realms & Bottlenecks) | The insight #23's extra roll would add if it failed: 0 if the step's
current insight I is at the cap, else min(failure_insight_pp, failure_insight_cap − I) |
| F_0 | float | 0–1 | calculated | Chance of failing every attempt in the step except the one after the extra roll; used
only to state the carry exactly (the guard assumes F_0 = 1) |
| q_retry | float | 0.01–0.95 | calculated | Chance of #23's extra attempt, clamped by the guard |
| q_max | float | 0.95 | data file | Ceiling on any attempt's chance |
| Δ_desp | float | 0.15 | data file | Cap on #22's gain over q |
| δ_max | float | 0.10 | data file | Allowed lift per realm |
| burn_cost | int | max(10, 0.05·L_r) years | data file | #23's lifespan cost, L_r being the realm's lifespan |

**Output Range:**

- For every S with 0 ≤ S < 1 (S_guard is capped at 0.95), q in 0.01–0.95 and τ_a in {0, 0.05} with q + τ_a ≤ q_max, the
  lift of each capability is ≤ δ_max = 0.10. Before τ_a was added, a talisman on the #22
  attempt allowed up to δ_max·(1 − q)/(1 − q − τ) = 0.106 at q = 0.1225 (0.006 over).
  This holds for ι_23 in {0, 0.02} too. Before ι_23 was added, #23's insight carry
  allowed 0.1115 (q 0.30 after one failed attempt at 0.28, S 0.5104) and 0.1009 at the
  CF→NS baseline (attempts 0.0825 and 0.1025); the new guard gives 0.0920 and 0.0966.
- At S = 0.70 and q = 0.25 the clamps do not bind and the lift is 0.075 (#23) and 0.060
  (#22). The clamps bind where S is low or q is large.
- Without the clamps the guard fails at the baseline: at S = 0.30, q = 0.30 (one roll) #22
  would lift by +0.150 and #23 by +0.210.
- The clamps only bound the lift. The bot measurement (Acceptance Criteria) still checks
  the whole attempt model once Realms & Bottlenecks defines it.
- **Intent.** A capability adds at most δ_max (0.10) to whatever S the life has built.
  This is deliberate. Capabilities are earned, rare (one notable each, from Core Formation) and bounded,
  and the player-facing text says "up to ×2, capped".
- **Baseline includes the tree.** The 0.30 / 0.70 targets are measured with the tree's own
  `breakthrough_chance` already counted (AC-KMD-50 runs the bot with it), so the tree as
  the bot allocates it sits inside the targets; a maxed tree is
  Realms & Bottlenecks Open Question 13. The capabilities add at most 0.10 on top.
  Realms & Bottlenecks must treat the tree's share as part of the calibration, not an extra.
  The bot takes no `field_plots` acupoint (Formulas F, plot price).

**Example:** S = 0.70, q = 0.25, ι_23 = 0 (clamps do not bind):

- #23 alone: q_retry = min(0.25, 0.10/0.30) = 0.25, so 0.70 + 0.25·0.30 = **0.775**.
- #22 alone: q_desp = min(0.50, 0.40, 0.95, 0.25 + 0.10·0.75/0.30 = 0.50) = 0.40, so
  1 − 0.30·0.60/0.75 = **0.76**.
- They can't both act in one realm step, so the lift is at most +0.075.

**Example (clamps bind):** S = 0.30, q = 0.30, ι_23 = 0:

- #23: q_retry = min(0.30, 0.10/0.70) = 0.1429, so the lift is 0.1429·0.70 = **0.100**.
- #22: q_desp = min(0.60, 0.45, 0.95, 0.30 + 0.10·0.70/0.70 = 0.40) = 0.40, so the lift is
  0.70·0.10/0.70 = **0.100**.
- Both use τ_a = 0 (no talisman on the attempt), where the formulas are the old ones.

**Example (talisman on the #22 attempt):** S = 0.1725 (= q + τ_a, the lowest S this
attempt allows, since S ≥ the attempt's chance), q = 0.1225, τ_a = 0.05:

- q_desp = min(0.245, 0.2725, 0.95 − 0.05 = 0.90, 0.1225 + 0.10·0.8275/0.8275 =
  0.2225) = **0.2225** (the δ_max term binds).
- The attempt's chance is q_desp + τ_a = **0.2725**, against 0.1725 with the talisman
  alone.
- The lift is (1 − S)·(q_desp − q)/(1 − q − τ_a) = 0.8275·0.10/0.8275 = **0.100**.
- Under the old guard (no τ_a), q_desp would be min(0.245, 0.2725, 0.95, 0.1225 +
  0.10·0.8775/0.8275 = 0.2285) = 0.2285 and the lift 0.8275·0.1060/0.8275 = 0.106, over
  δ_max.

**Example (#23 with failure insight, CF→NS baseline):** two pill attempts at 0.0825 and
0.1025 (0.0825 + ι after the first fails), so S = 1 − 0.9175·0.8975 = 0.17654 (1 − S =
0.82346). #23 acts after the first failure: insight I = 0.02, so the extra roll has
q = 0.1025 and ι_23 = min(0.02, 0.04 − 0.02) = 0.02.

- q_retry = min(0.1025, 0.08/0.82346) = **0.09715** (the δ_max − ι_23 term binds).
- Direct lift: 0.09715·0.82346 = **0.0800**.
- Carry: if the extra roll fails, the second attempt is 0.1225 instead of 0.1025.
  F_0 = 0.9175 (fail the first attempt; nothing follows the second), so the carry is
  0.02·(1 − 0.09715)·0.9175 = **0.0166**.
- Lift: 0.0800 + 0.0166 = **0.0966** ≤ δ_max. Check from the sequence: failing all is
  0.9175·0.90285·0.8775 = 0.72689 against 0.82346, a lift of 0.0966.
- Under the old guard, q_retry = 0.1025 and the lift is 0.1025·0.82346 + 0.02·0.8975·0.9175
  = 0.0844 + 0.0165 = 0.1009, over δ_max.

### F. Acupoint power and the breakthrough curve

The F1 power formula is defined as:

`power(h) = Σ_lines price[key, op] · value / breadth_mult(scope)` (Modifier System Formulas C)

The breakthrough curve formula is defined as:

`bt_tree = k · ln(1 + Σ_tree breakthrough_chance / k)` , with `k` = `tree_breakthrough_k`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| price[key, op] | float | per the Stat List | Modifier System (`modifier_prices`) | W per unit of each key and operation; this GDD keeps no weight table of its own (the old `stat_weights` table moved there on 2026-11-07) |
| breadth_mult | float | 1.0–2.5 | Modifier System Formulas B | Narrower scopes are worth more per W |
| Σ_tree breakthrough_chance | float | 0+ pp | calculated | The tree's summed `breakthrough_chance`, after the purity multiplier |
| `tree_breakthrough_k` | float | 8 pp (guess) | data file | Curve scale; replaces the 8 pp `tree_breakthrough_cap` clamp (user decision 2026-11-10) |
| bt_tree | float | 0+ pp | calculated | The tree's contribution to the q extras (Realms & Bottlenecks Formulas C) |

**Allowed keys.** Every Stat List key may appear on an acupoint at its price, including the #44 defence and sustain
keys (resistance in points, block, body shield, regeneration, evade), except `leech_health_pct` and
`bonus_ward_slots` (user decision 2026-11-10); rare modifiers only on keystones (Modifier System rule 13); rule flags
never. Lifespan, herb growth and alchemy follow Character Stats' curves (rule 14), shared with every other source.

**Precision.** Values follow Character Stats' `stat_precision_grid`.

**Output Range:** a small acupoint is about 1.2 W and a notable about 8 W before the purity multiplier (0.25 to
0.5 + purity/100). bt_tree rises without limit but slowly: 8 pp of summed lines give 5.5 pp, 16 pp give 8.8 pp,
32 pp give 12.9 pp. It still counts under Realms' q-extras ceiling (10 pp).

**Example:** a notable of +8% sword damage and +4 pp sword crit chance (both family scope, 1.5) is
8 × 1.0 / 1.5 + 4 × 1.0 / 1.5 = 5.33 + 2.67 = **8.0 W**. With ten breakthrough acupoints of 1.6 pp each,
bt_tree = 8 · ln(1 + 16 / 8) = **8.8 pp**.

### G. Retired: NPC unseal chance

Retired with the hidden clusters (rule 14).

### H. Map size

The map's size is what the kit draws; the lean build is the shipped map (user decision 2026-11-10).

| Region | Visible acupoints (lean build, 2026-11-10) |
|---|---|
| Earth, Water, Wood, Metal, Fire | 980, 902, 848, 838, 811 |
| Blend zones (Earth–Metal, Wood–Water, Fire–Earth, Water–Fire, Metal–Water) | 401, 398, 382, 377, 348 |
| Darkness, Light, Thunder islands (with the Shadow Shrine) | 282, 230, 217 |
| Taiji hub | 101 |
| **All** | **7,115** (11 starts, 616 road nodes, 5,364 small, 1,084 notables, 40 keystones; 811 clusters) |

**Output Range:** 7,115 at launch; the expansion only appends (rule 19). The lean build is the target; the full
build (about 8,700) is not shipped.

### H2–H4, topology generator. Retired

The variant sectors (rule 20) and the deterministic topology generator are retired: the map is drawn with the kit
(rule 21), and its checks replace the generator's (AC-KMD-60).

### Parameter keys

`meridian_tree.json` (the kit's `tree.json`, from the lean build): regions, acupoints with ids, positions, kinds,
regions and modifiers, links, starts, clusters. Data keys: `road_purity`, `purity_price`, `tree_breakthrough_k`,
`cap_realm_min`, `start_targets`, `tree_kind_scores`, `tree_focus_weight` (in `world_generation.json`), the capability
mapping `meridian_capabilities.json` (capability id to acupoint id). Retired keys: `tree_size_target`, `road_stats`,
`huyet_value_highway` (replaced by `road_purity` and `purity_price`), `tree_breakthrough_cap`, the hidden-cluster and
fill keys, `variant_sector_size` and the H2–H4 keys.

### Computational budget

- **Player:** opening an acupoint and recomputing the sheet is a few hundred modifier lines; the path tool is one
  breadth-first search over 7,115 acupoints, well under a frame.
- **NPCs (user decision 2026-11-10: live greedy, optimized).** The allocator keeps a frontier of reachable acupoints
  with cached scores (rule 5's kind score × focus × purity multiplier, plus its small random term drawn once per
  acupoint); opening an acupoint adds only its new neighbours to the frontier, so each point is one pop from a heap.
  Budget: at most 50 ms per NPC at 566 points and 5 ms at 120, and world generation of 5,000 NPCs (most below Core
  Formation) in at most 30 s (AC-KMD-54).

## Edge Cases

**Points and allocation**

- **If points arrive with nothing to open** (every reachable acupoint [huyệt] already open): the points stay unspent
  and are shown as unspent; they never expire.
- **If the character loses a level** (a failed breakthrough or an event costs a stage): no points are taken back and
  no acupoint closes. points_total tracks the highest level reached, so regaining the level pays nothing twice.
- **If the spiritual root (linh căn) changes mid-life** (a Linh Căn Quả or Tẩy Tủy Đan adds or raises an element):
  every open acupoint's multiplier is recomputed immediately under rule 4. An acupoint whose element-count
  requirement is no longer met stays open and keeps contributing, since there is no respec.
- **If road purity takes an element past 100:** nothing stops it (Spiritual Roots rule 8a: no cap); the purity
  multiplier keeps rising (0.5 + purity/100), and so does the element's stack power. `road_purity` is tuned so
  this stays rare (rule 4).
- **If a character walks the roads of an element its root lacks:** the roads still grant that element's purity, which
  powers its stacks only; it adds no base element (Spiritual Roots rule 8a).

**Starts**

- **If a root holds several elements or variants:** the player picks one start at birth (rule 3); the others are
  reachable over the map like any acupoint. The start is never changed later.
- **If the root gains a variant after birth:** its start does not become a second start; the variant's land is
  already open to everyone (rule 20), and its acupoints now scale by the variant's purity.
- **If an NPC's highest purity is tied:** generating-cycle order breaks the tie (rule 3). An NPC whose strongest
  element is a variant takes that variant's start.
- **If a save from the generated map is loaded:** it is migrated once (rule 19): every opened acupoint is refunded as
  unspent points, the character picks a start, and a one-line note says so. Capabilities held through the old map
  are kept only if the new map's capability notable is reachable, which is checked when it is opened again.

**Breakthrough and capabilities**

- **If the tree's breakthrough lines grow very large:** bt_tree keeps rising on its curve (Formulas F) and still
  counts under Realms' 10 pp q-extras ceiling, which clamps the total.
- **If a capability notable is reached below Core Formation:** it can be routed through but not opened; the path tool
  stops before it and shows the realm it needs (rule 16).
- **If a capability has nothing to act on** (e.g. +1 magic treasure [pháp bảo] slot with no magic treasure): it is
  held and listed, with no effect until it can act.
- **If two held capabilities are marked incompatible:** the notable that grants the second can still be opened for
  its stats; its capability is shown as suppressed while the first is held.
- **If #5 Soul Leaves the Body would trigger on death by old age:** it does not; it covers deaths in events and
  fights only.
- **If #23 Burning Life to Break Through's burn cost is equal to or greater than the remaining lifespan:** the retry is
  not offered. It is offered only when remaining lifespan > burn_cost.
- **If the character holds both #22 Last Radiance and #23:** only one acts per realm step, and the player chooses
  which (Formulas E2).
- **If an NPC holds a capability whose effect is `none`:** the capability appears in the World Database and story
  context only.

**NPCs**

- **If an NPC's allocation would pass its time budget** (Computational budget): the allocator stops, keeps what it
  opened, and leaves the rest as unspent points; a debug counter records it. The world never waits on one NPC.

**Content and saves**

- **If a content release adds acupoints:** they are appended beyond the rim or on the islands' outer edges; nothing
  already on the map changes (rule 19).
- **If a save references an acupoint id that the data no longer has** (only possible with corrupted or modded data):
  the acupoint is skipped, its point is returned as unspent, and the problem is logged. This and the one-time
  migration are the only refunds.
- **If the content pass is not done yet:** placeholder names, modifiers and keystones are live data and work as
  written; a placeholder keystone without an `effects.md` record has no rule and acts as a notable of N0.

## Dependencies

Spiritual Roots, Character Stats, Realms & Bottlenecks, Cultivation Techniques, the Way, the Modifier System, the
Effects System, Combat (with Damage Types and Defence & Healing), the Item Database, Quests and Heavenly Tribulation
have GDDs. Every other system below has none yet, so its interface is provisional; when its GDD is written, it must
list the Meridian Map (Kinh Mạch Đồ) in its own Dependencies section.

**Upstream: this system cannot work without them (hard)**

| # | System | What the Meridian Map needs from it |
|---|---|---|
| 1 | Data-Driven Config | `meridian_tree.json` (the kit's lean `tree.json`), `meridian_capabilities.json`, the data keys of Parameter keys, and the ladder in `cultivation_realms.json` |
| 2 | Deterministic Simulation Core | The seeded RNG for NPC allocation's random term; Breakdown for explainable values |
| 6 | Spiritual Root (Linh Căn) | Purity per element and variant and the base element count (rules 3, 4, 20); which starts a root may pick; it takes the purity the roads grant (rule 4; its rule 8a) |
| 7 | Character Stats | Accepts modifiers {source, stat, value}; owns stat keys, units and meaning, the bonus curves and the precision grid; stores the capability set, which the Meridian Map writes and every host reads |
| 8 | Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) | Level, realm and stage; level bands, `great_breakthrough_bonus` and `small_breakthrough_bonus` (Formulas A); realm lifespan; pill attempts for #22 and #23; the breakthrough talisman τ_a (Formulas E2); the q-extras ceiling that bt_tree counts under; `cap_realm_min` |
| 40 | Modifier System | The Stat List, `modifier_prices` and breadth tiers that price every acupoint (Formulas F) |
| 41 | Effects System | The rule text, numbers and closing cost of every capability and keystone (rule 16) |

**Upstream: needed for part of the system (soft)**

| # | System | What the Meridian Map needs from it | Without it |
|---|---|---|---|
| 5 | Save/Load | Saves the start, the open acupoints and the migration flag (rule 19) | The map state is lost on reload |
| 23 | Event Engine | The "grant a point" effect | No event point grants |
| 39 | The Way (Đạo) | The count of points spent on Dao nodes (dao.md rule 7), which the unspent figure subtracts; an NPC's `P_npc`, deducted from the allocator's points | Unspent points are the total minus acupoints only |

**Downstream: systems that depend on the Meridian Map**

| # | System | What it takes |
|---|---|---|
| 21 | Combat (and #21a, #21b) | Only the stat modifiers, through Character Stats, including the #44 defence and sustain keys |
| 24 | NPC Build Generation | The start rule (rule 3), the allocation rules (rule 5) and the allocator budget (Computational budget) |
| 27 | World Generation & History | Generates NPCs through NPC Build Generation, so it is bound by the allocator budget |
| 33 | Balance Simulation Harness | Re-measures route power (A2) and the calibration runs on the drawn map |
| 35 / 36 / 37 | Guidance Layer, Debug Terminal, Game UI | The drawn map, the start choice, route previews, purity gained from roads |
| 12 | Codex & Karmic Carryover | Records capabilities found across lives |
| 31 | Quests | `stat_power_weights` (via the Modifier System) and `w̄_target` to price a lasting gain; tree points paid by a major quest (`quests.md` Formulas D) |
| 39 | The Way (Đạo) | The shared point pool (two-way) |

**Capability hosts.** Each implements the behaviour behind its capabilities, from the `effects.md` record. Hosts do
**not** call the Meridian Map: it writes held capability ids into the character's capability set, and hosts read that
set, the same way they read stat modifiers; this breaks what would otherwise be cycles with the upstream hosts. Each
capability is owned by exactly one host (all 25 appear once):

- Magic treasures (inside Artifact Refining #16): #1, #2, #3
- Cultivation Techniques #9: #6
- Time & Turn #4: #7, #8
- Alchemy #15: #10, #11
- Spirit Herbs & Spirit Fields #14: #12
- Talismans #18: #13
- Formations #17: #14 (publishes a location-independent flag that Spirit Fields reads), #15
- Spirit Beasts #19: #16, #17
- Event Engine #23: #5, #18, #19, #20
- Travel & Map #25: #21
- Realms & Bottlenecks #8: #9 (Combat reports the knockout; the heart demon change goes through Character Stats),
  #22, #23
- Spiritual Root #6: #24
- Character Stats #7: #4, #25 (and the heart demon part of #9)

**Systems index.** Row 10 depends on Linh Căn, Character Stats, Cảnh Giới, Config, Sim Core, the Modifier System and
the Effects System; soft: Save/Load, Event Engine, the Way. Its status follows this GDD's review. No new cycle: hosts
depend on the capability set, not on this system; NPC Builds depends on it in one direction only. Retired soft
dependencies (with the hidden clusters): World Database (unseal events), Item DB (Meridian Seal keys), Cultivation
Techniques (seal lists), LLM Game Master (fills), Progression Edges (NPC unseals).

## Tuning Knobs

Every knob is a data key (see Parameter keys). Ranges marked *derived* follow from other numbers in this GDD; ranges
marked *guess* wait for a bot run.

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `pts_birth`, `great_breakthrough_bonus`, `small_breakthrough_bonus` | 2, 30/40/61/100, and per realm 13/13/14, 3/3/3, 5/5/6, 20/20/20, 33/33/33 | Realms & Bottlenecks owns them, and they are registered. Keep the great perfection totals at 51/120/216/357/566, or re-measure A2 | Points per life (Formulas A) |
| S0 / N0 | 1.2 / 8 | S0 1.1–1.4, N0 7.0–9.1 (guess until AC-KMD-07 re-runs on the drawn map); N0 stays under the 50 W keystone floor | Tree power per point |
| `road_purity` | 0.5 | 0.3–1.0, guess; bot-tuned so purity above 100 stays rare | How fast walking a land deepens its element |
| `purity_price` | 0.3 W per purity point | 0.2–0.5, guess | The value a road node counts as (A2) |
| `tree_breakthrough_k` | 8 pp | 4–12, guess | How fast the tree's breakthrough share flattens (Formulas F) |
| `cap_realm_min` | Core Formation | Foundation Establishment to Nascent Soul | The earliest realm a capability can be held (rule 16) |
| `start_targets` | first notable ≤ 5 points; nearest keystone 6–13 | PoE's ranges | Drawing targets per start (Formulas B) |
| Δ_desp / `q_max` / burn share | 0.15 / 0.95 / 5% | Δ_desp 0.05–0.15, q_max ≤ 0.95, burn share 3–10%, guess | Strength of #22 and cost of #23 (Formulas E2) |
| δ_max | 0.10 | 0.05–0.10 | Breakthrough lift from #22 and #23 (Formulas E2) |
| `capability_stat_share` | T1 0.5, T2 0.25, T3 0 | each ≤ 0.5, with T1 ≥ T2 ≥ T3 | Stats kept beside a capability (Formulas E) |
| `tree_kind_scores`, `tree_focus_weight` | in `world_generation.json` | guess | How NPCs spend (rule 5) |
| NPC allocator budget | 50 ms at 566 points, 5 ms at 120; 30 s for 5,000 NPCs | hard limits (AC-KMD-54) | World generation time |

Retired knobs (with the generated map and the hidden clusters): `cluster_count`, `size_realm_gates`, `cap_min_n`,
`cluster_size_mean`/`_sd`, `inner_share`, `sealed_share`, `huyet_per_notable`, `huyet_value_highway`,
`radials_per_sector`, `ring_anchor_depths`, `ring_interior`, `base_cluster_slots`, `region_capacity`, `road_stats`,
`huyet_per_notable_visible`, `entry_count_weights`, `shape_preferred_share`, `route2_min_extra`, `degree_avg_window`,
`link_capacity_margin`, `cluster_retry`/`seed_max_attempts`, `notable_min_entry_dist`, `w_d`/`w_n`/`d_lo`/`d_hi`,
P_min/P_max, `tol`, γ, φ_r, `tree_breakthrough_cap`, `open_unseals_per_realm`, `npc_unseal_share`,
`cong_phap_seasons` (here; Cultivation Techniques keeps its own), the `variant_*` keys, the sector stealth and
cultivation-speed shares.

## Visual/Audio Requirements

Deferred to the Game UI GDD (system 37). The kit's viewer (`tools/design/meridian_rework/tree_viewer.html`) is the
reference look: element colours per land, gold notables, keystone frames, islands joined by bridges.

## Game Feel

Not specified at this tier. Intent for later work:

- Opening a notable should feel like a decision paid off.
- Choosing a start at birth should feel like choosing a homeland.
- Reaching an island should feel like a journey: the bridge is long and the land beyond is strange.

## UI Requirements

These apply to the Debug Terminal now and to the Game UI later.

- **Point budget.** Spent and unspent points are always visible, along with the next point source (next level, next
  small breakthrough, next great breakthrough).
- **The start.** At birth the screen lists the starts the root may pick (rule 3), each with its land and what lies
  within 9 points.
- **Before spending.**
  - Every acupoint (huyệt) shows its scaled value (after rule 4) before a point is spent; a road node shows the purity
    it grants and the element's purity after it.
  - The path tool shows the full route cost and the total gain before committing; it stops before a capability
    notable the character's realm cannot open and names the realm (rule 16).
- **The breakthrough curve.** The sheet shows the tree's summed `breakthrough_chance` and bt_tree after the curve.
- **Capabilities.** Held capabilities are listed with their `effects.md` rule text and, when one can't act or is
  suppressed, the reason.
- **The migration** (rule 19) shows a one-line note with the points refunded.
- **Drawing the map.** The map is drawn from the kit's data, at its positions, with every link (rule 1's drawing
  checks hold for any drawing). The Debug Terminal lists acupoints by region and cluster.

## Cross-References

| Document | Relationship |
|---|---|
| `design/gdd/game-concept.md` | Pillars 1–3 |
| `design/gdd/systems-index.md` | System 10; dependency and status changes proposed under Dependencies |
| `design/research/meridian-land-authoring.md` | The drawing rules (rule 21) |
| `design/research/meridian-tree-overnight.md` | The drawn tree, its open points and the PoE comparison |
| `design/research/side-trees-thoughts.md` | Cultivation-technique and item trees in their own tab (rules 1, 6) |
| `design/research/linh-can-proficiency-direction.md` | Purity as proficiency; roads grant purity (rule 4) |
| `tools/design/meridian_rework/` | The kit, `build_tree.py` (lean build: `KMD_LIGHT=1`), its checks and the viewer |
| `design/gdd/linh-can.md` | Purities, variants and the purity roads grant (its rule 8a) |
| `design/gdd/modifiers.md`, `design/gdd/effects.md` | Prices of every acupoint; capability and keystone rules |
| `design/gdd/dao.md` | The shared point pool |
| `design/quick-specs/progression-and-edges.md` | Breakthrough targets; the calibration must be rerun on the drawn map |
| `assets/data/cultivation_realms.json` | The 110-level ladder, owned by Realms & Bottlenecks |
| `docs/debug-terminal.md` | Terminal commands for the tree |

## Acceptance Criteria

Drafted with qa-lead.

**Gate levels and tests.**

- `project.yaml` sets no `testing.strict`, so Logic, Integration and UI are BLOCKING and
  Config/Data is ADVISORY.
- Unit suites live in `tests/unit/meridian/`, extend `DaoTestSuite` and use an injected
  seeded RNG. LLM tests inject `LlmService` disabled or faked, and never write the LLM
  config or achievements.
- Evidence for the debug terminal is a captured transcript in `production/qa/evidence/`,
  not a screen capture.
- **[Bot]** items are judged on the printed output of `tools/balance/autoplay.gd` or `tools/balance/npc_cohort.gd`.
  AC-KMD-07, -50 and -89's successors are pending until the bot runs on the drawn map.
- Rewritten 2026-11-10 for the drawn map (major revision). Retired ids are listed at the end and never reused.

**Points (rule 2, Formulas A)**

- **AC-KMD-01** [Logic] points_total(L) returns:

  | L | Total | L | Total | L | Total |
    |---|---|---|---|---|---|
  | 1 | 2 | 20 | 91 | 80 | 216 |
  | 3 | 4 | 21 | 95 | 81 | 278 |
  | 4 | 18 | 26 | 100 | 100 | 357 |
  | 7 | 34 | 31 | 108 | 101 | 458 |
  | 9 | 36 | 40 | 120 | 110 | 566 |
  | 10 | 51 | 41 | 161 | | |
  | 11 | 82 | 54 | 179 | | |

  The first levels of the middle stage (trung kỳ) and late stage (hậu kỳ) are:

  | Realm | Middle stage | Late stage |
    |---|---|---|
  | Qi Refining (Luyện Khí) | 4 | 7 |
  | Foundation Establishment (Trúc Cơ) | 21 | 31 |
  | Core Formation (Kết Đan) | 54 | 67 |
  | Nascent Soul (Nguyên Anh) | 87 | 94 |
  | Deity Transformation (Hóa Thần) | 104 | 107 |
- **AC-KMD-02** [Logic] points_total(106) = 496, points_total(107) = 530 and
  points_total(110) = 566. Every value is a whole number from data, with no rounding.
- **AC-KMD-03** [Logic] A great breakthrough pays its whole bonus at once: from great
  perfection to the next realm's first level the total rises by 31, 41, 62 and 101 (the
  bonus plus the level's own point), and nothing was paid in advance.
- **AC-KMD-04** [Logic] points_total never decreases over 1..110.
    - At L = 26 (100 points), dropping to level 20 and climbing back keeps the total at 100
      at every step, and no acupoint closes.
- **AC-KMD-05** [Logic] Event grants and unspent points.
    - Each event grant adds exactly 1: L = 10 with 2 grants gives 53.
    - With every reachable acupoint open, new points stay unspent, and the count is
      unchanged after 20 turns.
- **AC-KMD-06** [Config/Data, data-lint test]
    - The data has S0 = 1.2, N0 = 8, `road_purity` 0.5 and `purity_price` 0.3.
    - Every keystone's positive side has power ≥ 50 W at `modifier_prices`, or it is a **rule keystone** whose
      positive side has no price (its `effects.md` record), on the test's golden list.
    - On the lean map, w̄_map over road nodes, small acupoints and notables is 2.10–2.20 W (2.152 at the defaults).
    - Every element-land road node grants only its land's purity; every blend road node half of each neighbour's;
      no road node carries `breakthrough_chance`.
    - No acupoint carries `leech_health_pct` or `bonus_ward_slots`; rare modifiers appear only on keystones.
- **AC-KMD-07** [Integration, Bot: `autoplay.gd`, ≥ 60 lives = 20 seeds × 3 origins]
  The median tree power at Qi Refining great perfection is 90–125 W (pending: re-run on the drawn map; the window
  is re-set from its first run). Lives with a 5-element root are reported separately.

**Map, starts and reach (rules 1, 3, 4, 5; Formulas B, H)**

- **AC-KMD-13** [Logic] Opening an acupoint costs exactly 1 point. It is refused with 0
  spent when the acupoint is already open, not adjacent, or short of elements.
- **AC-KMD-14** [Logic] Paths are all or nothing.
    - A 5-acupoint route with 4 points fails and leaves everything unchanged.
    - With 5 points, all 5 open.
    - After any sequence of opens, level losses and loads, the new open set contains the
      old one.
    - Two equally short routes: the one with the higher total scaled value opens; on equal
      value, the one with the lower ids. The preview shows the same route.
- **AC-KMD-15** [Logic] Rule 4.
    - Purity 60 gives ×1.10, purity 100 gives ×1.50, purity 140 gives ×1.90, and an absent element gives ×0.25.
    - A blend-zone acupoint between Wood 60 and an absent Fire gives ×0.675.
    - A Wind-land acupoint for a root with Wind 50 gives ×1.00; without Wind, ×0.25.
    - Keystones and the hub are ×1.0. The modifier source is exactly `Kinh Mạch: <name> #<id>`.
- **AC-KMD-16** [Logic] A spiritual root (linh căn) change mid-life.
    - Purity 60 → 80 changes that element's open acupoints from ×1.10 to ×1.30 on the same
      call.
    - An acupoint whose element requirement is no longer met stays open and keeps
      contributing.
- **AC-KMD-18** [Logic] Rule 5, with a fixed seed.
    - NPC allocation is identical on repeat runs and every open is legal.
    - Points spent = min(points, reachable acupoints).
    - A Fire-archetype NPC opens more Fire acupoints than acupoints of any other sector.
- **AC-KMD-96** [Logic] The start (rule 3).
    - Root {Fire 70, Water 40}: the offered starts are Fire and Water; picking Fire owns the Fire start at no cost.
    - Root {Water 60} with Ice 50: Water and Ice are offered; Light is not.
    - A Primordial Chaos root is offered the Chaos start.
    - An NPC {Wood 55, Fire 55} takes the Wood start (generating-cycle tie-break); an NPC with Thunder 80 and Metal
      60 takes the Thunder start.
- **AC-KMD-97** [Logic] Road purity (rule 4).
    - Opening 4 Fire-land road nodes raises Fire purity by 2.0 (4 × 0.5); a Fire–Earth blend road node raises Fire
      and Earth by 0.25 each; a hub road node raises no purity.
    - A root without Metal that opens 2 Metal road nodes gains Metal purity 1.0 for its stacks, and no base element.
    - Fire purity 99.5 plus one Fire road node is 100.0, and one more is 100.5 (no cap).
- **AC-KMD-99** [Config/Data] Map size and distances (Formulas B, H). The shipped map has 7,115 visible acupoints
  (±2% after the content pass), 11 starts and 40 keystones, and no hidden cluster. From every start the first
  notable is within 5 points and the nearest keystone within 6–13 points (`start_targets`); a start outside a target
  is reported.
- **AC-KMD-60** [Logic, data-driven] Drawing checks (rule 1) on the shipped `tree.json`: 0 crossing links, 0 pairs
  of acupoints closer than 0.6, 0 links grazing an acupoint, 0 acupoints unreachable from any start, 0 clusters
  without a bypass, and no acupoint with more than 6 links. The kit's `check()` prints these and the test asserts
  them.

**Capabilities (rules 16–18; Formulas E, E2)**

- **AC-KMD-40** [Logic] Formula E with N0 = 8: T1 gives 4.0 W, T2 2.0 W and T3 0 W before the purity multiplier;
  a capability notable's authored power is ≤ f_tier·N0.
- **AC-KMD-41** [Config/Data] The catalogue.
    - 25 entries with unique ids, each with an `effects.md` record; every tier is T1, T2 or T3 (the launch
      assignment is provisional, compared with a golden list changed in the same commit as any re-tiering).
    - Each capability sits on exactly one notable or keystone in `meridian_capabilities.json`, and that acupoint
      carries `cap_realm_min`. Incompatibility lists are symmetric.
- **AC-KMD-42** [Logic] Holding capabilities.
    - Opening the notable adds the id to the character's capability set, and it survives
      level loss and save/load.
    - A second grant changes nothing.
    - The set lists in catalogue order.
- **AC-KMD-43** [Logic] With X and Y marked incompatible, holding X and opening Y's
  notable applies Y's stats and lists Y as suppressed with a reason. #2 Divided Divine
  Sense (Thần Thức Phân Hóa) held with no magic treasure (pháp bảo) is listed with no
  effect.
- **AC-KMD-44** [Logic] E2 values.
    - burn_cost(L_r): 120 gives 10, 500 gives 25, 2000 gives 100.
    - q_desp at S = 0.70: q = 0.25 gives 0.40, q = 0.10 gives 0.20, and q = 0.70 gives 0.80
      (the δ_max term, 0.70 + 0.10·0.30/0.30, binds, and the lift is exactly 0.100).
    - q_desp at S = 0.95, q = 0.90 is 0.95 (q_max binds; the lift is 0.025).
    - S below the attempt's chance cannot occur (S ≥ q + τ_a); the property test skips
      those pairs.
    - Guard clamps: at S = 0.30, q = 0.30, ι_23 = 0, q_retry = 0.1429 and q_desp = 0.40;
      both lifts are 0.100 (±0.001).
    - #23 with failure insight: pill attempts at 0.0825 and 0.1025 give S = 1 −
      0.9175·0.8975 = 0.17654375. #23 after the first failure has q 0.1025 and ι_23 0.02,
      so q_retry = min(0.1025, 0.08/0.82345625) = 0.09715 (± 1e-5). The lift computed from
      the attempt sequence, 0.82345625 − 0.9175·(1 − q_retry)·0.8775, is 0.0966 (± 1e-4;
      0.0800 direct plus 0.0166 carry), ≤ 0.10. With the old guard (q_retry 0.1025) the same
      sequence lifts 0.1009. ι_23 is 0.02 at insight 0.02 and 0 at insight 0.04 (the cap).
    - Guard clamps with the talisman: with τ_a 0.05 at S 0.1725 (= q + τ_a) and q 0.1225,
      q_desp = min(0.245, 0.2725, 0.90, 0.1225 + 0.10·0.8275/0.8275) = 0.2225 (± 1e-9;
      the δ_max term binds), the attempt's chance is 0.2725, and the #22 lift is
      (1 − 0.1725)·(0.2225 − 0.1225)/0.8275 = 0.100 (± 1e-9). With τ_a 0 the #22 values
      equal the old formulas'.
    - Property test: for S in 0.05–0.95 (step 0.05), τ_a in {0, 0.05} and q in
      0.01–min(S − τ_a, 0.95 − τ_a) (a pair with an empty q range is skipped), the lift of #22 and of #23 is ≤ 0.10 +
      1e-9, q ≤ q_desp,
      q_desp + τ_a ≤ 0.95 and q_retry ≤ q. For #23 the test also runs ι_23 in {0, 0.02}
      and takes the lift at its worst case, q_retry·(1 − S) + ι_23·(1 − q_retry) (F_0 = 1).
    - With remaining lifespan = burn_cost, the retry is not offered; with burn_cost + 1,
      it is offered.
- **AC-KMD-45** [Integration, needs the Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) host]
    - #22 Last Radiance (Hồi Quang Phản Chiếu) and #23 Burning Life to Break Through (Thiêu
      Thọ Phá Cảnh) are each usable once per realm, and at most one acts per realm step.
    - #22 needs under 5 years of lifespan (thọ nguyên) left.
    - #5 Soul Leaves the Body (Linh Hồn Xuất Khiếu) does not trigger on death by old age.
- **AC-KMD-46** [Integration, Bot: extended `npc_cohort.gd`, ≥ 2,000 NPCs per arm on
  paired seeds] Arms: neither, #22 only, #23 only.
    - Pass: every arm's per-realm success lift over "neither" is ≤ +0.10.
    - Rerun at 4,000 per arm if any estimate is 0.08–0.10.
- **AC-KMD-100** [Logic] Capability realm gate (rule 16). A Foundation Establishment character adjacent to a
  capability notable cannot open it (refused, 0 spent, the reason names Core Formation); the path tool stops before
  it. At Core Formation the same open succeeds and the capability is held.

**Breakthrough and calibration (Formulas F)**

- **AC-KMD-59** [Logic] The breakthrough curve (Formulas F). With open acupoints carrying 8, 16 and 32 pp of
  `breakthrough_chance`, the sheet's Kinh Mạch contribution is 5.55, 8.79 and 12.88 pp (±0.01), and the breakdown
  shows the curve line. With 0 pp it is 0. The curve applies to an NPC's sheet the same way, and the total still
  counts under Realms' q-extras ceiling.
- **AC-KMD-50** [Integration, Bot] Breakthrough rates on the level ladder with rescaled
  values.
    - `npc_cohort.gd`: as Realms & Bottlenecks AC-CG-54.
    - `autoplay.gd`: as Realms & Bottlenecks AC-CG-30 and AC-CG-31.
    - In both runs the bot takes no `field_plots` acupoint (Formulas F, plot price): fields
      are a build outside these targets.
- **AC-KMD-101** [Integration, Bot: `autoplay.gd`, ≥ 60 lives = 20 seeds × 3 origins] Road purity balance. The
  share of lives with any element above 100 purity at Deity Transformation great perfection is reported; above
  10 % (guess) `road_purity` is lowered.

**Persistence and content releases (rule 19)**

- **AC-KMD-51** [Logic] A save/load round trip keeps the start, the open acupoints, the capability set and the
  migration flag identical. Serialising twice gives identical output.
- **AC-KMD-52** [Logic] Append-only from the fresh baseline, with the launch data plus a fixture release 2.
    - Every launch acupoint keeps its id, position, kind, region and modifiers.
    - New ids are above the largest launch id, and new acupoints lie beyond the rim or on the islands' outer edges.
    - A fixture release that would move, renumber or shorten any route to an existing acupoint is rejected by the
      content build.
- **AC-KMD-98** [Logic] Migration (rule 19). A fixture save from the generated map with 120 points total and 85
  opened acupoints loads as: 0 open acupoints, 120 unspent points, a start chosen by the player (or the strongest
  element for an NPC), the migration flag set, and one note line. Loading it again changes nothing.

**NPC allocator (rule 5; Computational budget)**

- **AC-KMD-54** [Integration; BLOCKING before NPCs above Core Formation are generated] A headless perf script,
  `tests/performance/meridian/allocator_perf.gd` (not a gdUnit test), on the lean map (7,115 acupoints).
    - 200 seeded Deity Transformation NPCs at 566 points: p95 ≤ 50 ms, max ≤ 100 ms per NPC; 200 Foundation
      Establishment NPCs at 120 points: p95 ≤ 5 ms.
    - World generation of 5,000 NPCs with the census's realm mix: ≤ 30 s in total.
    - Measured with `Time.get_ticks_usec()` around the allocate call only, on the reference machine (the owner's
      development PC; record its CPU model on the first run). Median, p95, max and the CPU model are kept in
      `production/qa/evidence/`; a later run may not exceed the first passing run by more than 20%.
- **AC-KMD-55** [Logic] With a counter injected into the allocator: BFS passes ≤ targets
  reached + 1, and there is no full frontier rescan per point.

**UI**

- **AC-KMD-56** [UI] At level 9 the terminal shows spent and unspent points and the next
  sources: level 10 +1, great perfection (đại viên mãn) +14 and the Foundation Establishment (Trúc Cơ)
  breakthrough +31.
- **AC-KMD-57** [UI] Before spending, each acupoint shows its value after rule 4 (including
  ×0.25 for an absent element). The path tool shows the route cost and total gain
  before committing.

**Retired 2026-11-10** (generated map, hidden clusters, fills, variant sectors, topology generator; never reused): AC-KMD-08, AC-KMD-09, AC-KMD-10, AC-KMD-11, AC-KMD-12, AC-KMD-17, AC-KMD-19, AC-KMD-20, AC-KMD-21, AC-KMD-22, AC-KMD-23, AC-KMD-24, AC-KMD-25, AC-KMD-26, AC-KMD-27, AC-KMD-28, AC-KMD-29, AC-KMD-30, AC-KMD-31, AC-KMD-32, AC-KMD-33, AC-KMD-34, AC-KMD-35, AC-KMD-36, AC-KMD-37, AC-KMD-38, AC-KMD-39, AC-KMD-47, AC-KMD-48, AC-KMD-49, AC-KMD-53, AC-KMD-58, AC-KMD-61, AC-KMD-62, AC-KMD-63, AC-KMD-64, AC-KMD-65, AC-KMD-66, AC-KMD-67, AC-KMD-68, AC-KMD-69, AC-KMD-70, AC-KMD-71, AC-KMD-72, AC-KMD-73, AC-KMD-74, AC-KMD-75, AC-KMD-76, AC-KMD-77, AC-KMD-78, AC-KMD-79, AC-KMD-80, AC-KMD-81, AC-KMD-82, AC-KMD-83, AC-KMD-84, AC-KMD-85, AC-KMD-86, AC-KMD-87, AC-KMD-88, AC-KMD-89, AC-KMD-90, AC-KMD-91, AC-KMD-92, AC-KMD-93, AC-KMD-94, AC-KMD-95.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | ~~May a Thiên Định life choose Visible mode?~~ **Retired 2026-11-10** with the visibility modes (rule 13) | — | — |
| 2 | What comes after Deity Transformation (Hóa Thần) (an end, more realms, or ascension)? **Deferred by the user 2026-11-03.** Points no longer depend on it | user + Cảnh Giới GDD | Nothing for launch |
| 3 | ~~Level bands and stat rises~~ **Resolved 2026-11-05:** Realms & Bottlenecks holds them | — | — |
| 4 | ~~Cluster themes and stat whitelists~~ **Retired 2026-11-10:** the drawn map's themes are placeholders filled in the content pass (Open Question 20) | — | — |
| 5 | Capability tiers by measurement (only 5 of 25 have a provisional tier) and the list of incompatible pairs | systems-designer + bot | Formulas E; rule 18 |
| 6 | ~~Content plan for sealed clusters~~ **Retired 2026-11-10** with the hidden clusters; the keystones' content moves to Open Question 20 | — | — |
| 7 | ~~Is φ_r a dead parameter?~~ **Retired 2026-11-10** with the fill budget | — | — |
| 8 | Recalibrate breakthrough targets and NPC cohorts on the drawn map (Formulas A, A2; AC-KMD-07, -50), together with Realms & Bottlenecks' recalibration after the bonus curves and the Way's breakthrough Effects | Balance harness | Implementation sign-off |
| 9 | ~~#14 placement across two clusters~~ **Resolved 2026-11-10:** it sits between the Formations and Spirit Fields districts (rule 17) | — | — |
| 10 | ~~The centre keystone's place~~ **Retired 2026-11-10:** the hub is the Taiji with the Chaos start (rule 1) | — | — |
| 11 | Cap on event point grants per realm (the Event Engine's budget file should set it) | Event Engine GDD | Rule 2 |
| 12 | ~~The generator's topology~~ **Retired 2026-11-10:** the map is drawn (rules 1, 21) | — | — |
| 13 | ~~Meridian Seal keys~~ **Retired 2026-11-10** with the hidden clusters | — | — |
| 14 | ~~A tree-wide lifespan ceiling~~ **Resolved 2026-11-10:** lifespan follows Character Stats' curve, shared by every source | — | — |
| 15–19 | ~~Variant sectors, their drawing and build; the generator's G5–G9; the unseal flow~~ **Retired 2026-11-10** (rules 6–15, 20) | — | — |
| 20 | **The map's final shape and the content pass** (the current drawing is a shape placeholder, user 2026-11-10): the redrawn shape; names, modifiers and keystones for the whole map; every element land's linh-lực keystone; the 25 capability placements; the start-cradle keystones that crowd the centre (overnight notes, Still open) | user + game-designer | Content release 1 |
| 21 | `road_purity`, `purity_price` and `tree_breakthrough_k` are guesses; AC-KMD-101 tunes `road_purity` | systems-designer + bot | Rule 4; Formulas A2, F |
| 22 | ~~Should island roads grant their variant's purity?~~ **Resolved 2026-11-10:** yes, a variant land's roads grant its variant's purity like an element land's (rule 4; Spiritual Roots review D4) | — | — |

### Known gaps in the build

The spec above is the target. The built game (`src/gameplay/meridian/`, 2026-11-05) still runs the old generated map:
about 1,300 acupoints with hidden clusters, variant sectors, generic roads and the 8 pp clamp. Replacing it means:
loading the kit's lean `tree.json` (with its hidden band removed from the build), the start choice, road purity, the
breakthrough curve, `cap_realm_min`, the save migration (rule 19), the optimized allocator (AC-KMD-54) and the
retirement of the unseal, fill and sector code. Until then every Known-gap row of the generated map (G5–G9, shape
templates, the unseal flow, variant sectors) is moot.

