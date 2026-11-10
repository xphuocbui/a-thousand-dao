# The Way (Đạo)

> **Status**: In Review (design-review 2026-11-10: NEEDS REVISION, 1 blocking; findings and user answers applied the same day, see `reviews/dao-review-2026-11-10.md`; re-review pending)
> **Author**: user + Claude
> **Last Updated**: 2026-11-10 (graph Ways, Effects and arts, consolidated catalogue: revision in progress, needs a fresh /design-review)
> **Last Verified**: 2026-11-10
> **Implements Pillar**: Pillar 1 (Your Dao, Your Name), Pillar 3 (Power Is Built, Not Given), Pillar 4 (Every Season Counts); touches Pillar 5 (A World That Remembers)

## Summary

The Way (Đạo) is the system of Daos: Sword, Space, Time, Yin and Yang, and many more. A
character glimpses a Dao through an event, picks it from three offered, and builds its graph
of about 150 nodes, drawn in clusters like a Meridian Map land, with the same skill points that buy acupoints,
at a flat 1 point a node. A node is worth about twice the same node on the map, so a
Dao feels special. A Dao defines builds with stat lines, Effects and several capstones (an art is rare), and
NPCs from Core Formation hold Daos too. It exists because Pillar 1 wants distinct builds, and
a Dao is the strongest way to tell two lives apart.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha (provisional)` · Key deps: `Spiritual Roots (Linh Căn), Meridian Map (Kinh Mạch Đồ), Character Stats, Modifier System, Effects System, Event Engine`; soft: `Cultivation Techniques, Realms & Bottlenecks, Combat (arts)`

## Overview

The Way (Đạo) is the system of comprehended Daos (ngộ đạo): Sword, Space, Time, Yin and
Yang, and many more. A Dao is not rolled into the root. An event gives a character a glimpse
of one, and the character then builds it up by spending skill points on its graph: stat
lines, Effects (rules) and capstones (keystones) that define the build; arts come from cultivation techniques, and a Dao holds one only rarely. A Dao is a
specialisation the character pays for, and its premium is deliberate. Every node costs 1 of the same points that buy acupoints
on the Meridian Map (Kinh Mạch Đồ); a stat node is worth about twice the same node on the map, and the
Effects come on top, so a point spent on a Dao is the best point a life spends. The root and the cultivation technique (công pháp)
are prerequisites, never the source. One glimpse a realm caps a life at four Daos, and the
points cap how deep each one goes. From Core Formation (Kết Đan), an NPC may hold one Dao,
rolled abstractly like its breakthrough fate, so a Sword master or a Space god can exist in
the world.

The system exists because Pillar 1 asks for more distinct builds, and the Way is where the
strongest distinction lives: two lives with the same root and technique can diverge by Dao,
and two lives with the same Dao can diverge by facet. It serves Pillar 3, since a Dao is
built by choosing nodes, and Pillar 4, since the points come from levels and breakthroughs,
which cost seasons. It also gives the 22 mutations moved out of the root (Spiritual Roots rule 16) a
home, consolidated into broad Ways with new Daos beside them, each hosting several builds.

## Player Fantasy

A Way is not given. One season, in a waterfall's noise or a dying master's last words, the character glimpses
something larger than a technique: the turning of the four seasons, the loneliness of a sword, the patience of an
old man fishing a cold river. Three Ways show themselves and one is taken. From then on the player owns a map of
that idea, a constellation of small truths with a few great ones at its edges, and every point spent there feels
like understanding, not bookkeeping: a node is worth twice its weight on the Meridian Map because it means more.

Two lives with the same root and the same technique stop being the same person once their Ways differ, and two
lives on the same Way part again at its capstones. The name a build earns (One Sword, Winter Never Ends, the Lone
Angler) is the name the world remembers: a Sword master is a fact the World Database keeps, and NPCs who walked a Way
before you are waiting in it.

## Detailed Design

### Core Rules

**What a Dao is**

1. **A Dao is a small graph, drawn to its theme** (user decision 2026-11-10, replacing the 20-node tree).
   Each Dao (data: `dao.json`) has an id, a name with its Hán-Việt form, a requirement (rule 5), its
   theme stats (rule 12) and 110–170 nodes (default 150), each with a position and its edges (user decision
   2026-11-10: ×2–3 the earlier 45-node graph; the Sword pilot holds 158):
   - the **start**: one node, given free at the glimpse;
   - **roads**: a few travel nodes from the start into each facet, stat lines with the Way's road modifier;
   - **five facets**: named sectors of the graph, each one face of the theme (rule 12), each holding several
     **clusters** (figures of small nodes and notables, as on the Meridian Map) hung on its road nodes and
     chained beyond them;
   - the **capstones**: the Dao's keystones, 2–6 nodes (`dao_keystone_count`, default 5), usually one on a
     short stem beyond each facet's outer cluster (user decision 2026-11-10: "why not all 3, if not more?").

   It is a graph drawn by hand with the Meridian Map kit and its authoring rules
   (`design/research/meridian-land-authoring.md`): roads carry clusters, a cluster joins at its nearest node,
   notables come after two or three small nodes, figures are chosen for the theme. The Sword pilot fans five
   facets upward from a start at the bottom (user: "actually looks pretty good"); other Daos may take other
   outlines. A silhouette of the Dao (a sword shape) was tried and dropped (user: "bad"). The data lint
   requires that the graph is connected, that every node is reachable from the start, and that no two edges
   cross. A node has
   a kind (rule 3) and its content. Adding a Dao is a data change, never a rule change.
2. **The catalogue holds broad Ways** (user decisions 2026-11-07 and 2026-11-10). It starts from the 22
   mutations moved out of the root (Spiritual Roots rule 16: Lava, Gravity, Life, Poison, Mist, Sword,
   Heavenly Thunder, Destruction, Death, Pill Fire, Spirit Farming, Refined Metal, Array, Soul,
   Illusion, Stars, Space, Yin, Yang, Reincarnation, Taiji and Time), consolidated: a seed broad enough
   to host several builds stays a Dao, and a narrow seed lives on as a facet of a broader one (Yin, Yang
   and Taiji in one Yin and Yang Dao, for example). New broad Daos sit beside them. The Catalogue
   section maps every seed to its Dao or facet, so none is lost. A seed's old effect (Pill Fire's
   `alchemy_success`, Time's herb ageing) becomes nodes in the graph that holds it, under rule 4.
3. **Four node kinds** (user decision 2026-11-10, consistency N4 and N11).
   - **Stat line:** catalogue modifiers (Modifier System) on the stat sheet, with the Dao and node as
     their source (Character Stats' provider interface), priced in W (Formulas D1). Small and road
     nodes are always stat lines; a notable is a stat line, an Effect or (rarely) an art.
   - **Effect:** one Effect record (Effects System rule 1) of tier `minor` or `major`, whose `hosts`
     lists the Way. It is unpriced, like every Effect, and the facet slot table (rule 10) bounds how many
     a Dao holds. Capstones and `major` Effects belong to one Dao; a `minor` Effect may come from a shared pool
     that several Ways host (user decision 2026-11-10, review D-04). The Effect record names the Daos that host it
     (`host_dao`, a list; Effects System rule 1). This replaces the earlier passive ability with its own W credit and `npc_effect`.
   - **Art (rare):** an art in Combat's format (Combat rule 13), its damage parts typed (Combat Damage Types
     rule 1) and its `more` sized in layer points (Modifier System rule 12). The hold on arts is lifted
     now that Combat is designed, but **arts come from cultivation techniques (công pháp), not from the Way**
     (user decision 2026-11-10): most Daos hold no art, a few hold one, and a Dao with two is an exception
     the Catalogue names (rule 10 and Formulas D1 part 4). An art is bounded by Combat's art rules (its strength follows its
     linh lực cost) and by the art slot it takes in a fight. An art's rider, if it has one, is an Effect
     and counts as one `minor` in the slot table.
   - **Capstone:** exactly one Effect of tier `keystone` or `enabler`, one of the Dao's signatures (rule 12),
     paid for by what it closes (Effects System rule 14). It may also carry one rare modifier (Modifier
     System rule 13: a Way capstone is a listed host) and stat lines. A character may hold several
     capstones of one Dao. Two whose rules contradict are marked rival in the data (Effects System rule 13),
     and only one of a rival pair can be bought.
4. **No cap raises and no root factors.** A Dao may not raise a cap that Character Stats still keeps (the q-extras
   ceiling, the crit caps) or multiply the whole cultivation rate, lifespan or breakthrough chance. Lifespan, herb
   growth and alchemy now follow diminishing-return curves with no clamp (Character Stats rule 14, revised
   2026-11-10), so a Dao's lines on them add through the curve like any other source. A stat line is an
   additive modifier and is not a multiplier, but cultivation speed has no ceiling, so one Dao's
   `cultivation_speed_pct` lines are held to `dao_rate_cap_pct` (10 %) by the lint (Formulas D1
   part 5; user decision 2026-11-06). The cap is per Dao, so four Daos may give +40 %; AC-DAO-10 checks the gates
   with the most Daos a life can hold (review D-11). Realms & Bottlenecks'
   gate odds are calibrated without them, and re-running that calibration is the price of
   adding one. Any breakthrough chance a stat line gives counts under the q-extras ceiling
   (`q_extras_ceiling_pp`, 10 pp) and nowhere else: it is a separate q-extras source, not the
   Meridian Map tree's contribution, so the tree's 8 pp cap (`tree_breakthrough_cap`) neither
   limits it nor is raised by it (user decision 2026-11-06). Realms & Bottlenecks lists the Way
   among the q extras. **Effects** that change breakthrough or heart-demon odds (a riskier breakthrough for a
   reward, rerolled odds, heart demon gain or decay) may go beyond that ceiling (user decision 2026-11-10, review
   D-05): each such Effect carries a bot fixture (AC-DAO-29), and the Realms calibration is re-run with them
   (Realms & Bottlenecks' recalibration open question).
5. **Requirement.** A Dao names what it needs from the root and technique: elements at a
   minimum purity of `dao_req_purity_min` (30; user decision 2026-11-10, review D-12), a variant, or a technique
   kind. The old mutation's parents are the natural
   start (Lava: Fire and Earth). The requirement is checked at the glimpse (rule 6), not again.

**Gaining a Dao**

6. **A glimpse opens a Dao.** An event effect `dao_glimpse` presents an offer of up to `dao_offer_size` (3) Daos
   the character qualifies for and has not glimpsed (Formulas D2). The player's pick is made
   inside the effect, before it resolves, and the effect opens exactly that one Dao (Event
   Engine, provisional contract). A glimpse
   gives only the graph to look at: no points and no stats. At most `dao_glimpses_per_realm`
   are given per realm, so a Dao stays an event in a life. Points already spent on acupoints are
   gone, so the Guidance Layer's Advisor tells the player, from the first realm that allows a
   glimpse, that this realm's glimpse is still unused and that Dao nodes need unspent points (UI
   Requirements; user decision 2026-11-06). The Way reserves nothing.
7. **Points buy nodes.** A node is bought with the same skill points that buy Meridian Map
   acupoints (Kinh Mạch points, paid by Realms & Bottlenecks' levels and breakthroughs). Every
   node costs a flat `dao_node_cost`, 1 point, whatever it gives (user decision 2026-11-10, replacing 3 when the
   graph grew to about 150 nodes).
   There is no separate currency and no study time (user decision 2026-11-05). A character buys a node only in a Dao it has glimpsed.
8. **Order within a graph.** A node can be bought if it shares an edge with a
   node already bought, as on the Meridian Map. Each capstone is placed so that every route to it is
   long: the shortest path from the start to any capstone costs at least `dao_capstone_depth` (10) points,
   and the outer band has no roads, so it runs through clusters (the data lint checks the depth; 2026-11-10,
   replacing "one whole branch and one node in each other branch"). A bought node is never refunded (as on the Meridian Map).
9. **Glimpses cap the count, points cap the depth.** One glimpse a realm from Foundation
   Establishment (rule 6) means at most one new Dao per realm: four in a life on the current ladder, Foundation
   Establishment to Deity Transformation. How deep each goes is what the
   character's points allow, and each point spent here is not spent on an acupoint (user
   decision 2026-11-05). No other rule limits the count or the depth.
10. **A Dao node beats the acupoints it replaces, and a facet's rules are bounded by slots.**
    - **Stat nodes carry the premium.** A small or road node is worth twice a map small node (2.4 W against
      1.2) and a stat notable twice a map notable (16 W against 8) (user decisions 2026-11-06 and 2026-11-10),
      so a Dao feels special and is extra power by design. Formulas D1 lints every
      stat-line node, not only the average, so the premium holds for the nodes a player actually buys.
    - **Effects and arts are bounded by the facet slot table** (user decision 2026-11-10, "Balanced";
      Effects System rule 4 asks each host for one):

      | Where | `major` Effects | `minor` Effects | Arts | Stat lines |
      |---|---|---|---|---|
      | Each facet (its notables) | at most 1 | at most 2 | at most 1, and only as the Dao's art | the other notables and every small node |
      | Start and roads | none | none | none | all |
      | Each capstone (2–6) | — | — | — | one `keystone` or `enabler` Effect, plus optional stat lines and one rare modifier |
      | Whole Dao | at most 5 | at most 10 | **0 as a rule; 1 rarely; 2 only as a named exception** | everything else |

      **Arts are rare** (user decision 2026-11-10: "very rarely a Dao has an art, and even rarer more than
      one; arts usually come from công pháp"). Across the catalogue, at most `dao_art_share_max` (20 %) of
      Daos hold any art, and at most `dao_two_art_max` (2) Daos hold two. A Dao holds an art only when the
      art is its theme's own (a Sound Dao's song, say) and no technique could carry it as well.
      A facet's `major` Effect usually sits at its far end, so the facet pays off for going deep. An
      art's rider counts as a `minor`.
    - The extra should stop at the gates: rule 4 still holds and the gate odds read no power stat,
      but a stat line that speeds cultivation or brewing could still shift them, so AC-DAO-10 tests it.
      How strong the unpriced Effects and arts make a Dao is measured by the balance harness (Open
      Question 4), not by a price.

**NPCs**

11. **NPCs hold Daos from Core Formation** by an abstract roll, like their breakthrough fate
    (user decision 2026-11-05). An NPC holds **at most one Dao**: it keeps its first
    successful roll and later rolls are ignored (review decision 2026-11-05). The Dao points
    `P_npc` (Formulas D3) are deducted from the points the Meridian Map allocator gives the
    NPC, and those points are worth `dao_premium` times what they buy on the map, the same
    premium the player gets (rule 10; user decision 2026-11-06). The Dao's effect is a power
    multiplier, not the graph, and it emits no per-season simulation. The Dao's id is stored in
    the NPC's record and written to the World Database as a fact when it is rolled, so the
    world can name a Sword master (Pillar 5; AC-DAO-25).

**Theme**

12. **A graph belongs to its Dao.** Every node comes from its Dao's theme (user decision
    2026-11-06): with the name hidden, a player can tell the Dao from its nodes. Sword's graph is
    blades and cutting, a craft Dao's is the furnace and the field, Time's is years and ageing.
    - **Stat lines** use only the Dao's `theme_stats`, a list in its data. There is no filler:
      a line any Dao could hold belongs on the Meridian Map instead.
    - **Capstones and `major` Effects** belong to one Dao: no such id appears in two Daos' graphs. `minor`
      Effects may be shared from a common pool (rule 3).
    - **Each facet** is a named face of the theme, and should open its own build direction (the
      library rule: a Dao hosts many builds, never one). The **capstones** are the Dao's signatures,
      each an effect a build is named for, usually each closer to a different facet.
    - **The shape** reads as the Dao too (rule 1).
    - **Theme comes before combat value.** A craft Dao needs no attack line. Its craft keys
      (`alchemy_success`, `herb_growth_pct`, lifespan) add through Character Stats' curves, so most of a craft
      Dao's strength is Effects, and its stat lines use its uncapped theme keys.

**What the player cannot do:** buy a node in a Dao it has not glimpsed; buy a node not joined to one
already bought (or to the start); refund a node; make a node raise a cap or multiply a whole rate.

### States and Transitions

Each Dao is in one of four states for a character. Nothing is ever lost.

| State | Becomes | When | Guard |
|---|---|---|---|
| Unknown | Glimpsed | A `dao_glimpse` event effect resolves on this Dao | The requirement is met, the Dao is not already glimpsed, and this realm's glimpses are under `dao_glimpses_per_realm` |
| Glimpsed | Glimpsed (node bought) | The player buys a node | The node shares an edge with a bought node (the start is owned from the glimpse), and the character has `dao_node_cost` unspent points |
| Glimpsed | Keystoned | A first capstone is bought while other nodes remain | The capstone shares an edge with a bought node (the layout makes that at least `dao_capstone_depth` nodes in) and no rival of it is held |
| Glimpsed or Keystoned | Mastered | The last remaining buyable node is bought | Every node of the graph is bought except the rivals of capstones held (a full graph costs about `dao_full_points`, less 1 point per rival given up) |
| Mastered | — | Terminal | A Dao is never lost and never refunded. The one exception is a data change that adds nodes: states are derived, so the Dao reads as Keystoned until the new nodes are bought (Edge Cases) |

Keystoned and Mastered are derived from the nodes bought, not stored. A capstone can be the
last node bought (rule 8 does not ask for every node), and then the Dao goes from
Glimpsed straight to Mastered. **A World Database event is written when a capstone is
bought, whatever else is bought**, so that purchase writes exactly one event whether it leaves
nodes or completes the graph (AC-DAO-14). Reaching Mastered by any other node writes none.

"Fully built" in this GDD means Mastered. Keystoned is reachable far earlier: the shortest route to
a capstone is at least 10 points of a default graph's 149. "Keystone" and "capstone" name
the same nodes; the state keeps its name. **Each capstone bought writes its own World Database event**
(revised 2026-11-10 with several capstones). An NPC goes Unknown → Glimpsed by
its roll (rule 11) and has no per-node state.

### Interactions with Other Systems

Spiritual Roots, Character Stats, Cultivation Techniques, Realms & Bottlenecks, the Meridian Map, the Item
Database, Combat (with Combat Damage Types and Combat Defence & Healing), the Modifier System, the Effects System,
Heavenly Tribulation and Quests have GDDs. Every other interface is provisional.

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Meridian Map (Kinh Mạch Đồ) | in / out | in: the character's points (its Formulas A) and its W-per-point target. Out: the points spent on Dao nodes, which are not available for acupoints. One shared pool | Meridian Map (the points); this GDD (Dao costs) |
| Spiritual Roots (Linh Căn) | in | the root as a read-only requirement: elements, purities, variants | Spiritual Roots |
| Cultivation Techniques (Công Pháp) | in | a technique's kind and tier, as a requirement | Cultivation Techniques |
| Character Stats | out | the Dao's stat lines as modifiers, with the Dao and node as their source; Effect and capstone nodes as Effect records (Effects System) | Character Stats (provider interface); this GDD (the lines) |
| Realms & Bottlenecks | in | the realm, for the glimpse limit; the gate calibration this GDD must not break (rule 4) | Realms & Bottlenecks |
| Event Engine | in | the `dao_glimpse` effect, which grants access to a Dao | Event Engine (provisional; no GDD) |
| Combat (and Damage Types, Defence & Healing) | out | art nodes in Combat rule 13's format; Effects that act in fights | Combat (art format); this GDD (which arts a Dao holds) |
| Modifier System, Effects System | in | the stat-line catalogue and W prices; the Effect record, tiers and host rules | Modifier System; Effects System |
| NPC Builds, Living World Tick | out / in | an NPC's Dao roll at Core Formation, and its simplified `npc_effect` | NPC Builds |
| World Database | out | a glimpse and a Keystoned Dao are recorded as events; an NPC's Dao is recorded as a fact on its record (Pillar 5) | World Database |
| Save/Load | out | per character: the Daos glimpsed and the nodes bought; per NPC: its Dao id | Save/Load |
| Guidance Layer, Debug Terminal, Game UI | out | the Dao list, each graph with costs, what is buyable and what is unaffordable, the glimpse notice, and the unused-glimpse heads-up | Guidance Layer |

### Catalogue (provisional)

> **Status: roster draft, 2026-11-10.** User decisions: consolidate the seeds into broad Ways; double the list;
> then a romantic pass ("the Đạo should be a bit more romantic … like Thái Dương, Thái Âm, Ngũ Hành, Tứ Thời"):
> poetic names drawn from classical images, a Way's player-facing name is **Hán-Việt first** with the English as
> its gloss, and four mundane Ways folded into others. Then a short-name pass ("something sounds cool alone on its
> own, like Đao Đạo and Xạ Đạo"): every Way is named by a short **X Đạo**, and the poetic phrase is kept as its
> title (hiệu), shown under the name, e.g. **Điếu Đạo** · *Hàn Giang Độc Điếu*. Each Way is a facet list and a capstone idea, not yet a
> graph. Graphs are drawn one Way at a time as Meridian kit regions,
> `tools/design/meridian_rework/regions/dao_<slug>.py`; the first is Kiếm Đạo (the pilot, approved 2026-11-10).
> Requirements are first guesses and use the root's element purity (Spiritual Roots), at least `dao_req_purity_min` (30); "—" means none,
> and those Ways count toward `dao_open_min`. A † marks a Way or facet that holds a seed moved out of the root.

**Heaven and Earth** (the great patterns)

| # | Way | Needs | Five facets | Capstone idea |
|---|---|---|---|---|
| 1 | **Âm Dương Đạo** · *Lưỡng Nghi* (Yin and Yang; the Two Forms) † | — | Âm (Yin: Cold, darkness)† · Dương (Yang: Fire, Light)† · Thái Cực (Taiji: balance, swapping)† · Ngày Đêm (Day and Night: alternating) · Giao Hòa (Union: paired stacks) | The two fish turn |
| 2 | **Thái Dương Đạo** · *Kim Ô* (the Great Sun; the Golden Crow) | Fire | Bình Minh (Sunrise: opening burst) · Chính Ngọ (Noon: peak mid-fight) · Liệt Nhật (Scorching Sun: Fire on Light) · Nhật Miện (Corona: aura) · Hoàng Hôn (Sunset: a last blaze) | A sun that never sets |
| 3 | **Thái Âm Đạo** · *Quảng Hàn* (the Great Moon; the Moon Palace) | — | Nguyệt Tướng (Phases: power that cycles) · Nguyệt Quang (Moonlight: Cold on Light) · Triều Tịch (Tides, with Water) · Dạ Hoa (Night Bloom) · Kính Nguyệt (Borrowed Light) | The full moon every night |
| 4 | **Ngũ Hành Đạo** · *Ngũ Hành Luân Chuyển* (the Five Phases; the Five Turning) | three or more base elements | Tương Sinh (the generating cycle) · Tương Khắc (the overcoming cycle) · Quân Bình (Balance) · Luân Chuyển (Rotation) · Hòa Hợp (Harmony: pair bonus) | All five turn as one |
| 5 | **Tứ Thời Đạo** · *Xuân Hạ Thu Đông* (the Four Seasons; Spring, Summer, Autumn, Winter) | — | Xuân (Spring: growth, healing) · Hạ (Summer: fire, burst) · Thu (Autumn: killing qi, harvest) · Đông (Winter: cold, rest) · Luân Niên (the Turning Year) | Always the right season |
| 6 | **Phong Nguyệt Đạo** · *Phong Hoa Tuyết Nguyệt* (Wind, Flowers, Snow, Moon) | — | Phong (Wind: speed) · Hoa (Flowers: grace, healing) · Tuyết (Snow: Cold, calm) · Nguyệt (Moon: Light) · Tứ Cảnh (the four beauties at once) | Beauty is the blade |
| 7 | **Hỗn Độn Đạo** · *Hồng Mông* (Primordial Chaos; the Primal Haze) | the Primordial Chaos root | Hỗn Độn (Chaos damage) · Vô Hình (Unformed: any element) · Xâm Thực (Erosion: resistance down) · Tiên Thiên (Before Heaven: insight) · Hỗn Hợp (Mixing: element stacks combined) | All five, none of them |
| 8 | **Vô Cực Đạo** · *Vô Cực Sinh Thái Cực* (the Limitless; the Limitless Gives Birth to Taiji) | — | Vô Tướng (Formless) · Vô Hạn (Unbounded growth) · Quy Nhất (Return to One) · Hư Vô (Emptiness) · Sơ Thủy (the First Breath) | Before Taiji, beyond limit |
| 9 | **Tinh Đạo** · *Tinh Hà* (River of Stars) | — | Tinh Trận (Star Arrays) · Tinh Quang (Starlight: Light) · Thiên Lý (Distance: travel, range) · Bắc Đẩu (the Dipper: guidance, fate) · Lưu Tinh (Falling Stars: bursts) | The sky is your array |
| 10 | **Thời Đạo** · *Quang Âm* (Passing Light: Time) † | — | Lão Hóa (Ageing: herbs)† · Tốc (Haste: art speed) · Ngưng (Stillness: enemy timers) · Năm Tháng (Years: lifespan) · Hồi Quang (Rewind: restore) | The fight runs on your clock |
| 11 | **Càn Khôn Đạo** · *Tụ Lý Càn Khôn* (Heaven and Earth in a Sleeve: Space; a World in a Sleeve) † | — | Thuấn Bộ (Step: escape, evade) · Tụ Lý (the Sleeve: inventory) · Liệt Không (Rift: Force damage) · Súc Địa (Folding the Earth: travel) · Phong Tỏa (Sealed Place: stops escape) | Here and there at once |
| 12 | **Mệnh Đạo** · *Thiên Cơ* (Heaven's Secret: Fortune) † | — | Tinh Tượng (Star Signs)† · Khí Vận (Fortune, cơ duyên) · Bói Toán (Divination: see events) · Định Mệnh (Destiny: counted chance) · Hung Tinh (Ill Star: curse luck) | The heavens bend |
| 13 | **Động Tĩnh Đạo** · *Tĩnh Như Xử Nữ, Động Như Thoát Thố* (Motion and Stillness; Still as a Maiden, Swift as a Fleeing Hare) | — | Động (Motion: speed, attack) · Tĩnh (Stillness: defence, regeneration) · Chuyển Thế (Switching stances) · Tĩnh Cực Sinh Động (stillness bursting into motion) · Bất Động (Unmoving) | Two stances, one master |
| 14 | **Hư Thực Đạo** · *Hư Hư Thực Thực* (Empty and Full; Empty and Full, Full and Empty) | — | Hư Chiêu (Feints) · Thực Kích (True Strikes) · Hư Ảnh (False images: evade) · Ẩn Thực (Hidden strength) · Hư Thực Tương Sinh (the empty becomes full) | Which blow was real? |

**Elements and nature**

| # | Way | Needs | Five facets | Capstone idea |
|---|---|---|---|---|
| 15 | **Kim Đạo** · *Bách Luyện* (Hundred Temperings: Metal) † | Metal | Tinh Kim (Refined Metal)† · Thối Thể (Tempered Body: block, body shield) · Lò Rèn (the Forge: artifact power) · Binh Khố (the Armoury: artifact slots) · Kim Phong (Metal Edge: Metal stacks) | The gear is the body |
| 16 | **Mộc Đạo** · *Khô Vinh* (Wither and Bloom: Wood) | Wood | Sinh Trưởng (Growth: stacks that grow) · Gai (Thorns: retaliation) · Rừng (the Forest: ground, companions) · Rễ (Roots: drain) · Khai Hoa (Blossom: bursts after growth) | The forest outlives everything |
| 17 | **Thủy Đạo** · *Nhược Thủy* (Like Water) | Water | Lưu (Flow: art chains) · Triều (Tides: rising and falling) · Uyên (the Depths: linh lực) · Vũ (Rain: healing over time) · Giang Hà (Rivers: travel) | Water wears down the mountain |
| 18 | **Hỏa Đạo** · *Phần Thiên* (Burning Heaven: Fire) † | Fire | Chân Hỏa (True Flame: Burn) · Dung Nham (Lava, with Earth)† · Đan Hỏa (Pill Fire: furnace heat)† · Tro Tàn (Ash: after the Burn) · Niết Bàn (the Phoenix Rises) | The furnace never cools |
| 19 | **Thổ Đạo** · *Bất Động Sơn* (Unmoving Mountain: Earth) † | Earth | Trọng Lực (Gravity)† · Sơn Thể (Mountain Body: block) · Địa Chấn (Earthquake: stagger) · Trần Bích (Dust Wall: Earth stacks) · Bàn Căn (Deep Roots: standing still) | Immovable |
| 20 | **Lôi Đạo** · *Cửu Thiên Lôi* (Thunder of the Nine Heavens) † | Thunder | Thiên Lôi (Heavenly Thunder: tribulation)† · Thiểm Điện (Lightning: crit, speed) · Lôi Thể (Thunder Body) · Phong Bạo (Storm, with Wind) · Tịnh Hóa (Purging: cleanse, demon-slaying) | Carry your own tribulation |
| 21 | **Phong Đạo** · *Thanh Phong* (Clear Breeze: Wind) | Wind | Cuồng Phong (Gale: art speed) · Phiêu (Drift: evade, Wind stacks) · Phong Nhận (Wind Blades: Physical cuts) · Bão Táp (Tempest, with Thunder) · Lãng Du (Wanderer: travel) | Never in one place |
| 22 | **Băng Đạo** · *Băng Tâm* (Ice Heart) | Ice | Sương Giá (Frost: Cold damage) · Băng Thể (Ice Body: shields) · Đông Kết (Freezing: slowed timers) · Băng Xuyên (Glacier: layered wards) · Tuyết Rơi (Snowfall: stealth, calm) | The world stops |
| 23 | **Vụ Đạo** · *Yên Vũ* (Misty Rain) † | Water | Màn Sương (Veil: evade, stealth)† · Hàn Vụ (Cold Mist: Ice debuff) · Mây (Clouds: travel, escape) · Sương Mai (Dew: regeneration) · Chìm (Drowning: linh lực burn) | Unseen until too late |
| 24 | **Ngọc Đạo** · *Ngọc Thanh* (Jade Purity) | Earth | Ngọc Thể (Jade Body: body shield) · Thuần Khiết (Purity: status resistance) · Khúc Xạ (Refraction: split hits) · Ngọc Giản (Jade Slips: insight) · Điêu Khắc (Carving: artifacts) | Flawless |
| 25 | **Quang Đạo** · *Quang Minh* (Radiance) | — | Quang (Radiance: Light damage) · Tịnh (Purity: cleanse) · Thự Quang (First Light: opening burst) · Hào Quang (Halo: wards) · Phán Xét (Judgement: against demons and curses) | Nothing hides |
| 26 | **Ám Đạo** · *Dạ Hành* (Night Walker) | — | Bóng Tối (Darkness: blind, accuracy down) · Ẩn (Hiding: stealth, ambush) · Thích Khách (the Assassin: first strike, crit) · Đêm Sâu (Deep Night: stronger later) · Ảnh Bộ (Shade Step: escape) | Strike from nowhere |

**Life, death and the soul**

| # | Way | Needs | Five facets | Capstone idea |
|---|---|---|---|---|
| 27 | **Sinh Tử Đạo** · *Sinh Diệt* (Arising and Passing) † | — | Sinh (Life: regeneration, healing)† · Diệt (Death: curses, withering)† · Ranh Giới (the Threshold: the Down step) · Thi Khí (Corpse Qi: drain, Corpse Rot) · Trường Sinh (Longevity) | Crossing the line both ways |
| 28 | **Luân Hồi Đạo** · *Lục Đạo Luân Hồi* (the Wheel of Rebirth; the Six Paths) † | — | Bánh Xe (the Wheel: cycling stacks) · Tiền Kiếp (Past Lives: insight) · Tái Sinh (Rebirth: survive a Down) · Vãng Sinh (Passage: soul) · Lục Đạo (the Six Paths: shifting forms) | Death is a door |
| 29 | **Nhân Quả Đạo** · *Gieo Nhân Gặt Quả* (Cause and Effect; Sow the Cause, Reap the Fruit) | — | Nghiệp (Karma: delayed payback) · Nợ (Debts: owed and called) · Báo Ứng (Retribution: retaliation) · Duyên (Affinity: bonds) · Đoạn Nhân Quả (Cutting karma: cleanse) | Every blow comes home |
| 30 | **Bỉ Ngạn Đạo** · *Bỉ Ngạn Hoa Khai* (The Other Shore; the Far-Shore Flower Blooms) | — | Bỉ Ngạn Hoa (the Spider Lily) · Độ (Crossing: escape, survival) · Vong Xuyên (River of Forgetting: curses) · Giác Ngộ (Enlightenment) · Hồng Hoa (Red Petals: bursts on a Down) | Death and awakening, one shore |
| 31 | **Hoàng Tuyền Đạo** · *Hoàng Tuyền Lộ* (the Yellow Springs; the Road to the Yellow Springs) | — | Cửu Tuyền (the Nine Springs: depth) · Di Ngôn (Last Words: last acts) · Dẫn Hồn (Leading Souls) · Hoàn Dương (Return to the Living) · Âm Thủy (Dark Water: Cold, Chaos) | One foot already below |
| 32 | **Quỷ Đạo** · *U Minh* (the Netherworld) | — | Quỷ Bộc (Ghost Servants) · Nhập Xác (Possession) · Oán Hồn (Haunting: curses after death) · Quỷ Hỏa (Ghost Fire: Soul damage) · Quỷ Môn (the Ghost Gate) | The dead fight for you |
| 33 | **Cốt Đạo** · *Bạch Cốt* (White Bones) | — | Cốt Giáp (Bone Armour) · Cốt Thương (Bone Spear: Physical) · Tủy (Marrow: regeneration) · Cốt Nô (Bone Servants) · Sọ Hộ (Skull Ward: soul) | Strength from the inside out |
| 34 | **Hồn Đạo** · *Nguyên Thần* (the Primordial Spirit: Soul) † | — | Thần Thức (Divine Sense) · Hồn Kích (Soul Strike) · Hồn Hộ (Soul Ward) · Linh Bộc (Spirit Servants) · Khôi Lỗi (Puppetry) | The body is a vessel |
| 35 | **Huyết Đạo** · *Huyết Hải* (Sea of Blood) | — | Huyết Giá (Blood Price: health-paid costs) · Xuất Huyết (Bleeding) · Huyết Thuẫn (Blood Shield) · Sinh Lực (Vitality) · Huyết Mạch (Bloodline) | Life is the only currency |
| 36 | **Thể Đạo** · *Bất Diệt Thể* (the Undying Body) | — | Đồng Bì (Bronze Skin: block) · Thiết Cốt (Iron Bones: body shield) · Ngọc Tủy (Jade Marrow: regeneration) · Cự Nhân (the Giant: vitality, căn cốt) · Không Thủ (Bare Hands: basic attack) | Flesh beats treasure |
| 37 | **Liên Đạo** · *Thanh Liên* (Blue Lotus) | — | Xuất Bùn (Out of the Mud: rise after a fall) · Tịnh Thủy (Pure Water: cleanse) · Liên Đài (the Lotus Throne: wards) · Liên Tử (Lotus Seeds: regeneration) · Hương Liên (Lotus Scent: calm) | Untouched by the mud |

**The heart**

| # | Way | Needs | Five facets | Capstone idea |
|---|---|---|---|---|
| 38 | **Tình Đạo** · *Thất Tình* (the Seven Feelings) | — | Hỷ (Joy) · Nộ (Anger: damage when hurt) · Ai (Sorrow: curses) · Ái (Love: bonds, companions) · Cụ (Fear: the enemy loses nerve) | Every feeling, mastered |
| 39 | **Vô Tình Đạo** · *Thái Thượng Vong Tình* (the Heartless Way; the Highest Forget Feeling) | — | Đoạn Tình (Cutting Ties: heart demon immunity) · Lạnh Lùng (Cold Heart: steady power) · Thái Thượng (Above Feeling: insight) · Cô Độc (Alone: no companions, more power) · Như Đá (Like Stone: statuses) | Heaven has no heart |
| 40 | **Tâm Đạo** · *Vấn Tâm* (Questioning the Heart) | — | Tâm Ma (Heart Demons: faced and turned) · Đạo Tâm (the Dao Heart) · Tự Vấn (Self-Questioning: insight) · Kiên Định (Resolve) · Minh Ngộ (Clarity) | No demon left inside |
| 41 | **Thiền Đạo** · *Minh Tâm* (the Bright Heart: Zen) | — | Tĩnh Tọa (Stillness: seclusion cultivation) · Không (Emptiness: resistance, calm) · Thệ Nguyện (Vows: power from self-restriction) · Kim Cương (Diamond Body) · Đốn Ngộ (Sudden Insight) | The mind does not move |
| 42 | **Bồ Đề Đạo** · *Bồ Đề Bản Vô Thụ* (Bodhi: Merit; Bodhi Was Never a Tree) | — | Từ Bi (Compassion: healing others) · Nghiệp Thuẫn (Karma Shield: wards) · Thiện Hạnh (Good Deeds: quests, standing) · Trừ Ma (Exorcism) · Kim Thân (the Golden Body) | Merit outweighs heaven |
| 43 | **Ma Đạo** · *Thiên Ma* (the Heavenly Demon) | — | Ma Lực (Heart Demon Power) · Huyết Tế (Blood Sacrifice) · Ma Hóa (Corruption: Chaos) · Cấm Thuật (Forbidden Arts) · Ma Thân (Demon Body) | Embrace the demon |
| 44 | **Sát Đạo** · *Tu La* (the Asura Way) | — | Sát Ý (Killing Intent: fear, damage) · Chiến Liên (Battle Streak) · Đao Phủ (the Executioner: low-health enemies) · Huyết Hải Tu La (with the Sea of Blood) · Lãnh Huyết (Cold Blood: heart demon control) | A thousand deaths behind you |
| 45 | **Hồng Trần Đạo** · *Vạn Trượng Hồng Trần* (Red Dust; Ten Thousand Fathoms of Red Dust) | — | Thế Gian (the Mortal World: standing, prices) · Duyên Phận (Bonds) · Thất Khổ (the Sorrows: insight from loss) · Phàm Tâm (a Mortal Heart: heart demon) · Hồng Trần Luyện Tâm (tempered by the world) | Cultivated among mortals |
| 46 | **Mộng Đạo** · *Hồ Điệp Mộng* (the Butterfly Dream) | — | Mộng (Dream: rest, insight) · Hồ Điệp (the Butterfly: evade) · Thực Mộng (Dream into Real: swap) · Mộng Cảnh (Dreamscape: ground) · Tỉnh (Waking: cleanse) | Which one is dreaming? |
| 47 | **Huyễn Đạo** · *Kính Hoa Thủy Nguyệt* (Flowers in a Mirror, Moon in Water: Illusion) † | — | Ảo Ảnh (Mirage: evade) · Gương (the Mirror: reflect) · Tâm Ma Ảo (Heart Demons both ways) · Bụi Trần (Dust: the proposed Dust Đạo) · Thủy Nguyệt (the Moon in Water: false targets) | The enemy fights a dream |
| 48 | **Mị Đạo** · *Khuynh Thành* (City-Toppling Beauty: Charm) | — | Mị Lực (Allure) · Thuyết Phục (Persuasion: prices, standing) · Mê Hoặc (Enthral: the enemy hesitates) · Hồ Hỏa (Fox Fire) · ◇ Ngưỡng Mộ (Admirers: followers) | No one will strike you |
| 49 | **Nhẫn Đạo** · *Nhẫn Nhất Thời, Phong Bình Lãng Tĩnh* (Forbearance; Endure a Moment, and Wind and Waves Fall Still) | — | Kiên Nhẫn (Patience: stronger the longer the fight) · Chịu Đựng (Bear It: damage taken to power) · Ý Chí (Iron Will) · Tử Thủ (Last Stand) · Âm Ỉ (Slow Burn: regeneration) | Whoever lasts, wins |
| 50 | **Tiêu Dao Đạo** · *Tiêu Dao Du* (Free Wandering; Free and Easy Wandering) | — | Vô Môn (No Sect) · Vân Hạc (Clouds and Cranes: travel) · Kỳ Ngộ (Chance Meetings) · Tự Tại (a Carefree Heart) · Thoát (Escape) | Bound by nothing |
| 51 | **Hoa Đạo** · *Lạc Hoa* (Falling Petals) | — | Hữu Ý (Petals with intent: grace) · Lưu Thủy Vô Tình (Water without intent: indifference) · Hoa Vũ (Petal Rain: many hits) · Tàn Hoa (Fading: decaying bursts) · Hương Tàn (Lingering Scent: after-effects) | Beautiful because it falls |

**Arms**

| # | Way | Needs | Five facets | Capstone idea |
|---|---|---|---|---|
| 52 | **Kiếm Đạo** · *Kiếm Tâm Thông Minh* (the Sword; a Sword Heart, Clear and Bright) † | — | Kiếm Ý (Sword Intent: crit, pierce) · Phi Kiếm (Flying Swords) · Kiếm Thể (Edge Body: Physical thể tu) · Hàn Phong (Cold Edge) · Kiếm Tâm (Sword Heart: thần thức) | Drawn: Nhất Kiếm, Vạn Kiếm Quy Tông, Báo Chiêu, Đông Bất Tận, Tâm Bất Động, Thân Tức Kiếm |
| 53 | **Đao Đạo** · *Cuồng Đao* (the Mad Saber) | — (needs a `saber` form tag) | Trọng Đao (Heavy Saber) · Hoành Tảo (Sweeping Cut) · Đao Ý (Saber Intent) · Huyết Đao (Blood Saber) · Hồi Đao (Return Stroke: counters) | One cut splits the sky |
| 54 | **Thương Đạo** · *Phá Quân* (the Army-Breaker: Spear) | — (needs a `spear` form tag) | Xuyên Thấu (Piercing) · Trường Thương (Reach: first strike) · Xung Phong (Charge) · Thương Trận (Spear Wall: counters) · Long Thương (Dragon Spear: combos) | The point goes through |
| 55 | **Xạ Đạo** · *Xạ Nhật* (Shooting the Suns: Bow) | — (needs a `bow` form tag) | Viễn Xạ (Long Shot) · Tiễn Vũ (Rain of Arrows) · Ưng Nhãn (Hawk's Eye: crit, accuracy) · Linh Tiễn (Spirit Arrows) · Truy Tung (Tracking: hunts, creatures; from Hunting) | Never a miss |
| 56 | **Chưởng Đạo** · *Thiên Thủ* (a Thousand Hands: Palm) | — | Trọng Chưởng (Heavy Palm: Force) · Chưởng Phong (Palm Wind) · Nội Kình (Inner Strike: through wards) · Hỏa Chưởng (Burning Palm) · Thiên Chưởng (a Thousand Palms: many hits) | One palm, a mountain falls |
| 57 | **Ấn Đạo** · *Pháp Ấn* (Dharma Seals) | — | Ấn Liên (Seal Chains: combos) · Phược Ấn (Binding Seals) · Thiên Ấn (Heaven Seals: big slow arts) · Khoái Ấn (Quick Seals) · Hộ Ấn (Seal Wards) | A seal for every answer |
| 58 | **Vũ Đạo** · *Nghê Thường* (the Rainbow Robe: Dance) | — | Tiết Tấu (Rhythm: art timing) · Xoay (Spin: several targets) · Uyển Chuyển (Grace: evade) · Kiếm Vũ (Sword Dance) · ◇ Hội (Festival: allies' power) | The fight is a dance |
| 59 | **Diệt Đạo** · *Tịch Diệt* (Silent Extinction: Destruction) † | — | Hủy Hoại (Ruin: more damage)† · Phá Giáp (Shatter: resistance shred) · Diệt Tuyệt (Annihilation: Chaos) · Sụp Đổ (Collapse: overkill) · Tai Kiếp (Calamity: self-cost) | Nothing is left standing |
| 60 | **Phệ Đạo** · *Thôn Thiên* (Swallowing Heaven) | — | Thôn (Swallow: drain linh lực) · Hóa (Digest: gains from kills) · Đói (Hunger: stacking need) · Nuốt Đan (Consume Pills: toxicity into power) · Hắc Khẩu (the Maw: soul drain) | Everything is food |
| 61 | **Trấn Đạo** · *Trấn Thiên* (Suppressing Heaven: Sealing) | — | Phong Thuật (Seal Arts: silence) · Khóa Khí (Seal Qi) · Trấn Thú (Seal Beasts) · Lao Ngục (Prison: stop escape) · Tự Phong (Self-Seal: stored power) | Nothing moves without leave |
| 62 | **Độc Đạo** · *Vạn Độc* (Ten Thousand Poisons) † | Wood | Nọc (Venom: Poison stacks)† · Đan Độc (Pill Toxin) · Cổ (Gu: poison beasts) · Ôn Dịch (Plague: statuses spread; from Plague) · Giải Độc (Antidote: cleanse) | Your blood is poison |

**Arts and crafts**

| # | Way | Needs | Five facets | Capstone idea |
|---|---|---|---|---|
| 63 | **Kỹ Đạo** · *Thiên Công* (Heaven's Craftsmanship) | — | Luyện Khí (Refining: artifacts) · Họa Phù (the Talisman Brush) · Khôi Lỗi Thuật (Puppets) · Chế Trận (Formation Making) · Giám Bảo (Appraisal: quality; spirit stones as payment, from Wealth) | Everything carried is self-made |
| 64 | **Đan Đạo** · *Cửu Chuyển* (the Nine Turnings: Pill) † | Wood or Fire | Đan Lô (the Furnace) · Linh Điền (Spirit Fields)† · Hàn Đan (Cold Pill) · Linh Thiện (Spirit Food: buffs; from Cuisine) · Y Đạo (Medicine: healing) | Every pill is perfect |
| 65 | **Trận Đạo** · *Phong Thủy* (Wind and Water: Geomancy) † | — | Trận Pháp (Arrays)† · Linh Mạch (Spirit Veins) · Phù Lục (Talismans) · Hộ Trận (Ward Arrays) · Động Phủ (the Cave Dwelling: home ground) | A formation within the body |
| 66 | **Họa Đạo** · *Thi Họa* (Poetry and Painting) | — | Mặc Thú (Ink Beasts: summons) · Sơn Thủy (Landscape: ground) · Chân Dung (Portrait: copies) · Bút Pháp (Brushstroke: combos) · Thi Quyển (the Living Scroll: stored arts) | What is drawn becomes real |
| 67 | **Cầm Đạo** · *Thiên Lại* (the Pipes of Heaven: Music) | — | Cầm (the Zither: Force, soul) · Chiến Cổ (the War Drum: companions) · Tiêu (the Flute: calm) · Cộng Hưởng (Resonance: stacking hits) · Vô Thanh (Silence: stops enemy arts) | The song decides the fight |
| 68 | **Kỳ Đạo** · *Nhất Cục Thiên Hạ* (the Way of Go; the World in One Game) | — | Tiên Tri (Foresight: guards, slot order) · Bố Cục (the Opening: art order) · Hư Chiêu Kỳ (Feints, counters) · Khí Tử (Sacrifice: give up to gain) · Tàn Cục (Endgame: late-fight power) | Every move was planned |
| 69 | **Tửu Đạo** · *Túy Tiên* (the Drunken Immortal) | — | Túy Quyền (Drunken Fist: erratic evade) · Ủ Rượu (Brewing: spirit wine) · Hỏa Tửu (Fire Wine) · Cuồng Hoan (Revelry: heart demon down) · Say Mèm (Hangover: cost for power) | Drunk is enlightened |
| 70 | **Ti Đạo** · *Hồng Tuyến* (the Red Thread) | — | Sợi Duyên (Fate Threads) · Trói (Binding: slowing) · Mạng Nhện (the Web: traps) · Dây Rối (Puppet Strings) · Thiên Y (Silk Armour) | Every thread leads to you |
| 71 | **Điếu Đạo** · *Hàn Giang Độc Điếu* (Lone Angler on the Cold River) | — | Chờ (Patience: waiting gains) · Mồi (the Lure: draw enemies, events) · Phúc Thủy (Fortune of the Water) · Câu Móc (Line and Hook: pull, stop escape) · Hồ Lặng (the Calm Lake: heart demon) | The fish comes to the hook |
| 72 | **Thâu Đạo** · *Diệu Thủ* (the Wondrous Hand) | — | Trộm Bảo (Steal Treasures) · Trộm Khí (Steal Qi) · Trộm Thuật (Steal Arts) · Khoái Thủ (Quick Hands) · Biến Mất (Vanish) | Whatever they have is yours |

**Beasts and changes**

| # | Way | Needs | Five facets | Capstone idea |
|---|---|---|---|---|
| 73 | **Thú Đạo** · *Bách Thú* (a Hundred Beasts) | — | Linh Khế (Spirit Bond: loyalty, companion share) · Bầy (the Pack) · Thú Thể (Beast Body: borrowed traits) · ◇ Tọa Kỵ (Mounts) · Săn (the Hunt: creatures, materials; from Hunting) | One heart in many bodies |
| 74 | **Long Đạo** · *Chân Long* (the True Dragon) | — | Long Huyết (Dragon Blood: vitality) · Long Lân (Scales: shields) · Long Ngâm (the Roar: fear, silence) · Long Tàng (the Hoard: treasures) · Hô Vũ (Rain-Calling: Water, Lightning) | The dragon wakes |
| 75 | **Hóa Đạo** · *Vạn Hóa* (Ten Thousand Changes) | — | Thú Hình (Beast Forms) · Cự Hình (Giant Form) · Tiểu Hình (Small Form: evade, stealth) · Nguyên Tố Hình (Elemental Form) · Biến Hóa (switching forms mid-fight) | Any shape, any answer |
| 76 | **Phân Thân Đạo** · *Nhất Khí Hóa Tam* (One Breath, Three Bodies) | — | Phân Thân (Split Self: a clone fights) · Kính Ảnh (Mirror Images: evade) · Hóa Thân (an Avatar Body) · Đồng Tâm (Shared Mind: thần thức) · Thiên Thủ Phân Thân (Many Hands: art slots, rare) | There are three of you |

**People and the world**

| # | Way | Needs | Five facets | Capstone idea |
|---|---|---|---|---|
| 77 | **Hiếu Đạo** · *Ẩm Thủy Tư Nguyên* (Filial Piety; Drinking Water, Remember the Source) | — | Tổ Tiên (Ancestors) · ◇ Gia Tộc (Family) · Trung Môn (Sect Loyalty) · Truyền Thừa (Inheritance) · Báo Ân (Repaying Kindness) | ◇ The lineage fights beside you (archived; a lineage-blessing capstone instead) |
| 78 | **Nho Đạo** · *Hạo Nhiên* (Vast Righteousness) | — | Chính Khí (Righteous Qi) · Thư Pháp (Calligraphy: written arts) · Lễ (Rites: order, buffs) · Học (Learning: comprehension) · Ngôn Linh (Words of Power: silence, command) | The pen cuts deeper |
| 79 | **Thệ Đạo** · *Thiên Thệ* (Oath to Heaven) | — | Tự Thệ (Self-Oaths: closed options for power) · Khế Ước (Contracts) · Thiên Chứng (Heaven as Witness) · Kết Nghĩa (Sworn Bonds) · Nợ Ân (Debts) | A word is law |
| 80 | **Sư Đạo** · *Truyền Đăng* (Passing the Lamp) | — | ◇ Đệ Tử (Disciples who fight) · Giảng Đạo (Teaching: insight) · Đạo Thống (the Lineage of Arts) · Chỉ Điểm (Guidance: others' breakthroughs) · Di Sản (Legacy) | The student surpasses you |
| 81 | **Hiệp Đạo** · *Hiệp Cốt* (Bones of a Hero) | — | Chính Nghĩa (Justice) · Phù Nhược (Protecting the Weak) · Du Hiệp (Wandering Hero: quests) · Quyết Đấu (the Duel) · Danh Tiếng (Reputation) | Righteousness answers |
| 82 | **Hoàng Đạo** · *Nhân Hoàng* (Emperor of Men) | — | Uy Nghiêm (Authority: aura, fear) · ◇ Thần Dân (Followers) · Thánh Chỉ (Decrees) · Cống Phẩm (Tribute) · Long Ỷ (the Throne: home ground) | All under heaven |
| 83 | ◇ **Binh Đạo** (archived whole: mass battle) · *Thiên Quân Vạn Mã* (a Thousand Troops, Ten Thousand Horses) | — | Binh Sĩ (Troops: mass battle) · Chiến Trận (Battle Formations) · Thống Soái (Generalship) · Công Thành (Siege) · Lương Thảo (Supply) | The army is one body |
| 84 | **Thủ Đạo** · *Thủ Hộ* (the Keeper) | — | Thuẫn Tường (Shield Wall) · ◇ Hộ Vệ (Protector: allies) · ◇ Khiêu Khích (Taunt) · Canh Giữ (Vigil: late-fight defence) · Bất Khuất (Unbroken) | Nothing passes you |

**Ways that change the rules** (user request 2026-11-10: "any other cool đạo concepts"; the rule-changers chosen)

| # | Way | Needs | Five facets | Capstone idea |
|---|---|---|---|---|
| 85 | **Nghịch Đạo** · *Nghịch Thiên Cải Mệnh* (Defy Heaven, Change Fate) | — | Nghịch Cảnh (Against the Odds: stronger when behind on health) · Vượt Cấp (Fighting Upward: against higher realms) · Nghịch Kiếp (Defying Tribulation) · Bất Phục (Unyielding: survive a Down) · Cải Mệnh (Rewriting Fate: rerolled odds) | The weaker you are, the harder you strike |
| 86 | **Thiên Đạo** · *Thiên Đạo Vô Thân* (Heaven Has No Favourites) | — | Thiên Quy (Heaven's Rules: limits on the enemy) · Công Bằng (Impartial: both sides capped alike) · Thiên Phạt (Heaven's Punishment: against rule-breakers, demons) · Pháp Tắc (Laws: rule-change Effects) · Thay Trời (Acting for Heaven) | You are the law in this fight |
| 87 | **Kiếp Đạo** · *Độ Kiếp* (Crossing the Calamity) | — | Tự Chuốc (Courting Disaster: self-imposed trials) · Hiểm Phá (Risky Breakthroughs) · Kiếp Hậu (After the Calamity: gains from surviving) · Kiếp Khí (Calamity Qi: tribulation as fuel) · Vạn Kiếp (Ten Thousand Trials: stacks per survival) | Every calamity makes you stronger |
| 88 | **Đại Đạo** · *Đại Đạo Chí Giản* (The Great Way Is Simple) | — | Giản (Simplicity: power per empty slot) · Nhất (The One: one art, one ward) · Bỏ (Letting Go: fewer pieces, stronger ones) · Quy Chân (Return to the True) · Vô Chiêu (No Forms: the basic attack grows) | Less is everything |
| 89 | **Vô Vi Đạo** · *Vô Vi Nhi Trị* (Rule by Not Acting) | — | Bất Động Thủ (Not Striking: power while idle) · Tự Nhiên (Let It Happen: wards and ticks do the work) · Thuận (Yielding: counters) · Thủ Nhu (Keeping Soft: damage taken softened) · Vô Vi Tâm (the Non-Acting Heart) | It wins without moving |
| 90 | **Si Đạo** · *Si* (Obsession) | — | Nhất Niệm (One Thought: one tag, very deep) · Si Mê (Infatuation: stacking focus) · Quên Mình (Self-Forgetting: other stats ignored) · Điên (Madness: heart demon as fuel) · Tuyệt Kỹ (the Peerless Art) | Master of one thing, nothing else |
| 91 | **Hận Đạo** · *Hận Hải Nan Điền* (A Sea of Hatred No One Can Fill) | — | Kẻ Thù (the Nemesis: a sworn enemy from the World Database) · Báo Thù (Vengeance: power against those who wronged you) · Ghi Hận (Grudges: marked foes) · Huyết Thệ (Blood Oath) · Hận Ý (Hatred as qi) | The world remembers, and so do you |
| 92 | **Cô Đạo** · *Thiên Sát Cô Tinh* (the Lone Star of Calamity) | — | Độc Hành (Walking Alone: no companions) · Vô Môn Phái (No Sect) · Cô Tinh (the Lone Star: more power per missing ally) · ◇ Khắc Thân (Bringing Misfortune: allies weaken, you rise) · Lạnh (Coldness: heart demon) | Alone under heaven |
| 93 | **Vực Đạo** · *Lĩnh Vực* (Domain) | — | Triển Vực (Unfolding: a domain opens mid-fight) · Vực Quy (Domain Rules: rewrites fight rules inside it) · Vực Áp (Domain Pressure: enemy slowed) · Vực Hộ (Domain Ward) · Vực Thần (Domain Lord: your own ground everywhere) | Within my domain, I decide |
| 94 | **Thần Đạo** · *Hương Hỏa Thành Thần* (A God Made of Incense Smoke) | — | ◇ Tín Đồ (Followers: faith from the world) · Hương Hỏa (Incense: faith as power) · Miếu (Shrines: home ground) · Thần Uy (Divine Majesty: fear, aura) · Hiển Linh (Manifestation: answering prayers, events) | Worshipped, therefore mighty |

**Seed mapping.** Lava, Pill Fire → Hỏa Đạo; Gravity → Thổ Đạo; Life, Death → Sinh Tử Đạo; Poison → Độc Đạo;
Mist → Vụ Đạo; Sword → Kiếm Đạo; Heavenly Thunder → Lôi Đạo; Destruction → Diệt Đạo; Spirit Farming → Đan Đạo;
Refined Metal → Kim Đạo; Array → Trận Đạo; Soul → Hồn Đạo; Illusion → Huyễn Đạo; Stars → Mệnh Đạo;
Space → Càn Khôn; Yin, Yang, Taiji → Âm Dương; Reincarnation → Luân Hồi; Time → Thời Đạo. The proposed Dust,
Talisman and Cold Pill Daos from the root build catalogue are facets (Huyễn Đạo, Trận Đạo, Đan Đạo).

**Folded in the romantic pass:** Wealth (spirit stones as payment → Kỹ Đạo's Giám Bảo), Plague (→ Độc Đạo's
Ôn Dịch), Hunting (→ Thú Đạo's Săn and Xạ Đạo's Truy Tung), Cuisine (→ Đan Đạo's Linh Thiện). Emotion split into
Tình Đạo and Vô Tình.

**Archived for future extensions (◇; user decision 2026-11-10, review D-03).** Combat is one fighter plus attached
companions; it has no allies, party, mounts, disciples, troops, taunt or world followers, and Effects System rule 5
has nothing to read them. The facets marked ◇ wait for that extension and are recorded in Combat's future plans
(combat.md Open Question 27). A Way with a ◇ facet is drawn with a replacement facet chosen when it is drawn; Binh
Đạo (#83) is archived whole, since four of its five facets are mass battle. Thần Đạo's Hương Hỏa also leans on
followers and should be reshaped onto shrines and ground when drawn.

**Open (roster):**
- Đao Đạo, Thương Đạo and Xạ Đạo need new form tags beside sword, palm, seal, beast and formation (Combat rule 6,
  Modifier System rule 9).
- Overlaps to keep apart while drawing: Huyết Đạo, Sát Đạo and Diệt Đạo; Thể Đạo, Cốt Đạo, Thổ Đạo and
  Kim Đạo's Thối Thể; Quang Đạo, Bồ Đề, Thái Dương and Âm Dương's Dương; Vụ Đạo, Băng Đạo, Thái Âm and Âm
  Dương's Âm; Sinh Tử Đạo, Hoàng Tuyền, Bỉ Ngạn, Quỷ Đạo and Luân Hồi; Tâm Đạo, Thiền Đạo and Tình Đạo; Nhân Quả and
  Luân Hồi; Động Tĩnh and Hư Thực with Kỳ Đạo; Nghịch Đạo with Nhẫn Đạo; Vô Vi Đạo with Thiền Đạo; Cô Đạo with Vô Tình (its Cô Độc facet); Đại Đạo with Kiếm Đạo's One Sword; Vực Đạo with Trận Đạo's Động Phủ; Kiếp Đạo with Lôi Đạo's tribulation facet; Long Đạo with Thú Đạo and Hóa Đạo; Phân Thân Đạo with Huyễn Đạo; Ti Đạo with Kỹ Đạo's puppets; Vũ Đạo with Phong Đạo; Thái Âm's Triều Tịch with Thủy Đạo's Triều; Thái Dương's Bình Minh with Quang Đạo's Thự Quang (both opening bursts); Hỏa Đạo's Đan Hỏa with Đan Đạo's Đan Lô (review D-15). Each graph keeps its facets
  distinct from its neighbours' (rule 12).

## Formulas

Values marked *guess* need a bot run and a content pass before they are trusted. Stat lines
are priced with the Meridian Map's weights (its Formulas F1, in W: 1 W is the value of +1 %
attack).

### D1. A Dao's cost and value

The dao_node_value formula is defined as:

`cost(n) = c` ; `W_small = m · c · s` ; `W_notable = m · c · b` ; `C_dao = c · (N − 1)`

and a data lint on every Dao, five parts (revised 2026-11-10, Sword pilot v2: 1 point a node, small and notable
nodes as on the Meridian Map, Effects and arts bounded by slots, consistency N4):
1. **size and shape:** `110 ≤ N ≤ 170`; the graph is connected and every node is reachable from the start; no two
   edges cross and no node sits closer than 0.6 to another or on a link (the Meridian Map kit's checks); each
   facet's clusters lie in its own sector; every capstone's shortest route from the start holds at least
   `dao_capstone_depth` points; the Dao holds 2–6 capstones;
2. **each stat node:** a small or road node is `(1 ± t) · W_small` and a stat notable is `(1 ± t) · W_notable`, with
   `t` = `dao_node_tol` 0.2, so no node is a trap or a jackpot. Capstones' stat lines, if any, are not held to a band;
3. **the mean:** the W per point over the Dao's priced nodes is at least `0.9 · m · w̄` (3.73 W), so the premium
   holds for the graph as a whole;
4. **the slot table** (rule 10): Effects and arts sit only on notables; per facet at most 1 `major` Effect and
   2 `minor` Effects (an art's rider counts as one); per Dao at most 1 art, or 2 if the Catalogue names the Dao as
   an exception; across the catalogue at most `dao_art_share_max` of Daos hold an art and at most
   `dao_two_art_max` hold two; road nodes are stat lines only; each capstone is exactly one Effect of tier
   `keystone` or `enabler` and at most one rare modifier, and rival pairs are marked both ways; across the whole
   catalogue, two capstones whose `closes` contradicts the other's payload are marked rival even in different
   Daos (review D-09); capstones and `major` Effects are unique to one Dao, `minor` Effects may be shared;
5. **the rate cap.** One Dao's `cultivation_speed_pct` lines sum to at most `dao_rate_cap_pct` (10 %), worth
   10 × 2.2 = 22 W (rule 4). This is the only per-key limit. The 2026-11-06 key-headroom lint (a ceiling times the
   key's price on `alchemy_success`, `herb_growth_pct` and lifespan) is dropped (user decision 2026-11-10, review
   D-01): Character Stats rule 14 turned those ceilings into diminishing-return curves with no clamp, so the curves
   keep stacking in check and AC-DAO-10 guards the gates.

The cost is flat, so strong and weak nodes cost the same, as on the Meridian Map. Stat nodes carry the premium
node by node; Effects and the rare art carry no W (Effects System rule 4) and are held by the slot table. The
curves are character-wide, so several Daos on one key share their diminishing return; the Advisor shows the
marginal gain before a buy (Edge Cases).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c | int | 1 | data file (`dao_node_cost`) | Points per node, flat (user decision 2026-11-10, replacing 3) |
| m | float | 2 | data file (`dao_premium`) | How much a Dao node beats the same node on the map (user decision 2026-11-06) |
| s, b | float | 1.2, 8 | Modifier System (`grade_small`, `grade_notable`) | The map's small and notable budgets in W |
| w̄ | float | 2.07 | Meridian Map Formulas A2 (`w̄_target`) | Mean W per point on the map |
| `dao_rate_cap_pct` | float | 10 | data file, *guess* | Most `cultivation_speed_pct` one Dao may give, in percent (user decision 2026-11-06) |
| N | int | 110–170 | data file (`dao_node_count` 150) | Nodes in a Dao, the start included (user decision 2026-11-10: ×2–3 the 45-node graph; the Sword pilot holds 158) |
| K | int | 2–6 | data file (`dao_keystone_count` 5) | Capstones in a Dao |
| t | float | 0.2 | data file (`dao_node_tol`), *guess* | How far one stat node may sit from its budget |
| `dao_capstone_depth` | int | 10 | data file, *guess* | Fewest points on any route from the start to any capstone (the Sword pilot: 11–12) |
| W(n) | float | small 1.9–2.9, notable 12.8–19.2 | calculated | A stat node's value: its modifiers priced by the Modifier System (Formulas C) |
| C_dao | int | 109–169 | calculated (`dao_full_points` 149) | Points a fully built (Mastered) Dao costs; the start is free |

**Output Range:** at the defaults (c 1, m 2), small and road nodes are 2.4 W ± 20 % and stat notables 16 W ± 20 %;
the bands move with the knobs. A default Mastered Dao costs about 149 points, a little over a quarter of a life's
566. With the Sword pilot's mix (121 small or road nodes, 15 stat notables) its stat lines are worth about
121 × 2.4 + 15 × 16 = 530 W against the 325 W its 157 points buy on the map, plus its 15 Effects and its capstones.
Over all of its points the pilot's stat lines are 530 ÷ 157 = 3.38 W per point,
1.63 × the map: its 15 Effect notables and 6 capstones (21 points) carry no W, and they are the unpriced rest of the
×2 premium (review D-02). Four Mastered Daos would need about 600 points, more than a life holds, so a life masters one or two and goes
part-way into the rest. Open Question 4 measures the whole with the balance harness.

**Example:** the Sword pilot (`tools/design/meridian_rework/regions/dao_sword.py`, approved 2026-11-10):
158 nodes, the start free, so 157 points to master. A facet holds a big constellation at the end of its road,
one figure chained beyond it and one or two figures on its road nodes; Sword Intent's notables are 2 `minor`
Effects, 1 `major` (Flowing Water) and stat notables at 16 W, which the slot table allows. Its capstones sit 11–12
points from the start, so `dao_capstone_depth` 10 holds. A small node of +1.8 pp sword crit chance and +1.8 %
sword damage is 1.8 × 1.0 ÷ 1.5 + 1.8 × 1.0 ÷ 1.5 = 2.4 W, inside 1.9–2.9.

### D2. The glimpse offer

The dao_offer formula is defined as:

`E = {d : requirement(d) met, d not yet glimpsed}` ; `offer = the first min(dao_offer_size, |E|) entries of a uniform shuffle of E`

A character is given `dao_glimpses_per_realm` glimpses in each realm from `dao_glimpse_realm_min`
(Foundation Establishment); the glimpse happens when an event resolves it (the Event Engine
owns the rate). The shuffle is a Fisher–Yates over E in stable `dao.json` id order (never the display number, so inserting or renumbering a Way changes no seeded offer; review D-16), one uniform draw per
swap, so the offer is reproducible from the seed. Exactly: with k = min(`dao_offer_size`, |E|), for i = 0 … k−1
take j = i + randint(|E| − i) and swap entries i and j; the offer is entries 0 … k−1. That is k
draws (two for |E| = 2, even though the last has one outcome), from the seeded stream named
`dao_offer`, so no other stream shifts.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `dao_glimpses_per_realm` | int | 1 | data file | Glimpses a realm allows (user decision 2026-11-05) |
| `dao_glimpse_realm_min` | int | 1 | data file | First realm that allows one: Foundation Establishment (user decision 2026-11-05) |
| `dao_offer_size` | int | 3 | data file | Daos shown per glimpse; the player picks one (user decision 2026-11-05) |
| `dao_open_min` | int | 6 | data file lint | Daos with no root or technique requirement. Invariant, linted on the data: `dao_open_min ≥ dao_offer_size + 4·dao_glimpses_per_realm − 1`, so E always holds a full offer after every earlier glimpse (4 realms allow a glimpse). At the defaults 3 + 4 − 1 = 6 |
| \|E\| | int | 6+ | calculated | Daos on offer |

**Output Range:** an offer of 3 whenever the catalogue holds six open Daos. A life gets up to four
glimpses (Foundation Establishment to Deity Transformation).

**Example:** a character qualifies for 9 Daos and has already glimpsed 2 of them, so |E| = 7.
Three draws pick the offer from those 7. The player takes one, and the other two return to E.

### D3. An NPC's Dao

The npc_dao formula is defined as:

`P_npc = min(C_dao, ⌊npc_dao_share · points_total(level)⌋)` ; `map_points = points_total − P_npc` ;
`power_mult = (map_points + dao_premium · P_npc) ÷ map_points`

An NPC rolls once per realm entered from Core Formation, with chance `npc_dao_chance`, until
its first success (rule 11: at most one Dao). On success it takes one Dao uniformly from those
it qualifies for. The Meridian Map allocator gets `map_points`, and `power_mult` multiplies the
resulting combat power, as a capability's `npc_effect` does. `power_mult` restores the W the
deducted points would have bought on the map and adds the premium, so an NPC with a Dao is
stronger than one without, as a player's is (user decision 2026-11-06, on the deduction from
review decision 2026-11-05). It assumes map power is close to linear in points, which a bot run
must confirm (Open Question 5).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `npc_dao_chance` | float | 0.5 | data file, *guess* | Chance of a Dao per realm from Core Formation, until the first success |
| `npc_dao_share` | float | 0.25 | data file, *guess* | Share of an NPC's points it has put into its Dao |
| `dao_premium` | float | 2 | data file (Formulas D1) | What a Dao point is worth against a map point, the player's value |
| points_total(level) | int | 161–566 | Meridian Map Formulas A | The NPC's points: an NPC's level is the first level of its stage |
| P_npc | int | 40–141 | calculated | Points put into the Dao, deducted from the map |
| map_points | int | 121–425 | calculated | Points the Meridian Map allocator gets |

**Output Range:** `power_mult` 1.00 (no Dao) to about 1.67. Below the cap it is a plateau
of 1.660–1.667 at the Meridian Map's stage totals (161 points, Core Formation early: 1.661; 216, Core Formation
great perfection: 1.667; 278, Nascent Soul early: 1.660; 458, Deity Transformation early: 1.663; 566: 1.664). With a 149-point Dao
(revised 2026-11-10) the cap would bind only from 596 points, past a life's 566, so it never binds.
The ratio `P_npc ÷ points_total` never exceeds `npc_dao_share`, so `power_mult` never exceeds
1 + 2 × 0.25 ÷ 0.75 = 1.667.
`power_mult` acts on the smaller map allocation, so the gain over an NPC of the same level with
no Dao is `(points_total + (dao_premium − 1) · P_npc) ÷ points_total`: about +25 % at every level,
+24.9 % at 566 points. `npc_dao_power_max` is retired. The NPC model prices only the points; a Dao's
unpriced Effects (and rare art) are not in it, so the harness check (Open Question 5) covers them too. The NPC's
full 2.0 × assumes the Effects and capstones make up the 0.37 × that the stat lines leave (D1 Output Range; user
decision 2026-11-10, review D-02).

**Example:** a Core Formation NPC at level 41 has 161 points, so P_npc = min(149, ⌊40.25⌋) = 40,
map_points = 121 and power_mult = (121 + 80) ÷ 121 = **1.661**, about +25 % over a Dao-less NPC
of that level. A Nascent Soul NPC at its first level has 278 points, so P_npc = ⌊69.5⌋ = 69, map_points = 209 and
power_mult = (209 + 138) ÷ 209 = **1.660**, +24.8 %.

## Edge Cases

**Glimpses**

- **If fewer Daos qualify than `dao_offer_size`:** the offer shows what exists. The catalogue lint
  keeps `dao_open_min` Daos open, so an empty offer cannot happen in shipped data. If E were empty, the glimpse
  is skipped and the realm's allowance is kept.
- **If a glimpse event arrives after the realm's allowance is used:** the Event Engine's
  validator refuses the effect, and the event plays without it.
- **If the character skips a realm's glimpse:** the allowance is lost with the realm. It does not
  carry forward.
- **If the player declines every offered Dao:** nothing is granted and the allowance is used.
  Self-made lives glimpse like any other life, and no life has a Dao at birth.

**Buying**

- **If a node costs more than the character's unspent points:** the buy is refused and the
  shortfall is shown. A glimpsed Dao is always visible, with every cost.
- **If a node's stat line is on a curve key** (lifespan, herb growth, alchemy; Character Stats rule 14): it adds
  through the curve like every other source, and before the buy the Advisor shows its marginal gain. On a key that
  still clamps (the q-extras ceiling, crit caps) it is clamped and the sheet shows the clamp line.
- **If a Dao's Effect does the same thing as a Meridian Map keystone or another host's Effect:** both
  apply and stack, unless the Effect's own `limits` say otherwise (Effects System). A Dao's Effects have
  their own ids (rule 12).
- **If a node is not joined to anything bought:** the buy is refused and the screen shows the nearest
  bought node it could be reached from.
- **If the character has points but no glimpsed Dao:** the points go to the Meridian Map as
  before. The Way never forces a spend.
- **There is no respec.** A bought node stays, and a point spent here is never returned to the map.

**Requirements and changes**

- **If the root or technique changes after a glimpse:** the Dao stays. The requirement was
  checked once, at the glimpse (rule 5). A root never loses anything (Spiritual Roots rule 14).
- **If a Dao's data changes between versions:** a node bought under the old data keeps its points,
  and a save refers to nodes by id. A removed node is refunded as unspent points, the one case a
  refund happens. A node that needed the removed one keeps its purchase: the prerequisite is
  checked only at buy time, so nothing already bought is lost or locked.
- **If a data change adds nodes to a Dao the character has Mastered:** nothing is taken away.
  The Dao reads as Keystoned again (states are derived; the keystone stays bought), the new nodes are buyable,
  and the keystone's World Database event is not written a second time.
- **If a glimpsed Dao is deleted from the catalogue:** its bought nodes are refunded as unspent
  points (the same single refund case), and it leaves the Dao list. A save that refers to it
  loads without error. The catalogue lint still has to hold `dao_open_min` after the deletion.
- **If a glimpsed Dao's requirement changes in the data:** the Dao stays (the requirement was
  checked once, at the glimpse). Only Daos not yet glimpsed are offered under the new requirement.

**Arts and Effects**

- **If a character owns more Way arts than art slots:** the extra arts are owned but not slotted; the
  slot order decides which fight (Combat rule 13). Buying an art never forces a slot.
- **If a capstone is rival to one the character already holds (in this Dao or another host):** the buy is refused and the
  screen names the rival (Effects System rule 13). The points are not spent.

**NPCs**

- **If an NPC is generated at Core Formation or higher:** it rolls once for its current realm, not
  for earlier ones.
- **If an NPC's roll succeeds but it qualifies for no Dao:** it holds none, and the roll counts as
  failed, so it rolls again in its next realm. The `dao_open_min` lint keeps Daos with no
  requirement in the catalogue, so this cannot happen in shipped data.
- **If an NPC dies:** its Dao stays in its record. The World Database keeps it as history.
- **If a world is small:** a 3,000-cultivator world has about 1.7 Deity Transformation NPCs, so a
  Dao held only by Deity Transformation NPCs may not exist in that world. That is allowed.

## Dependencies

Spiritual Roots, Character Stats, Cultivation Techniques, Realms & Bottlenecks, the Meridian Map, the Item
Database, Combat (with its Damage Types and Defence & Healing sub-systems), the Modifier System, the Effects System,
Heavenly Tribulation and Quests have GDDs. Every other interface is provisional. When each remaining GDD is written,
it must list the Way in its own Dependencies section.

**Upstream: this system cannot work without them (hard)**

| # | System | What the Way needs from it |
|---|---|---|
| 1 | Data-Driven Config | `dao.json`: the catalogue, trees, requirements and the keys in Formulas |
| 2 | Deterministic Simulation Core | The seeded shuffle for the offer, the NPC roll, and Breakdown for every cost and line |
| 6 | Spiritual Roots (Linh Căn) | The root as a read-only requirement: elements, purities and variants |
| 7 | Character Stats | The stat sheet that takes a Dao's lines as modifiers, with their source |
| 40 | Modifier System | The stat-line catalogue and its W prices (Formulas D1) |
| 41 | Effects System | The Effect record, tiers and host rules for Effect and capstone nodes |
| 10 | Meridian Map (Kinh Mạch Đồ) | The points a character has (its Formulas A) and the W-per-point target node values are set against |
| 23 | Event Engine | The `dao_glimpse` effect: without it no character can gain a Dao |

**Upstream: needed for a part of the system (soft)**

| # | System | What it supplies | Without it |
|---|---|---|---|
| 9 | Cultivation Techniques | A technique's kind and tier, as a requirement | A Dao can only require roots |
| 8 | Realms & Bottlenecks | The realm, for the glimpse allowance; the gate odds Daos must not break | No glimpse allowance by realm |
| 21 | Combat | The art format (rule 13) and the fight art nodes act in | No art nodes ship |
| 22 | Heavenly Tribulation (Thiên Kiếp) | The tribulation that Lôi, Kiếp and Nghịch Đạo act on | Those facets have nothing to act on |
| 31 | Quests | Quests and standing for Hiệp Đạo's Du Hiệp and Bồ Đề Đạo's Thiện Hạnh | Those facets read nothing |
| 13 | Item Database | Artifact slots and refining for Kim Đạo and Kỹ Đạo | Those facets fall back to stat lines |
| 24 / 28 | NPC Build Generation, Living World Tick | The NPC roll at Core Formation | Only the player holds Daos |
| 11 Progression Edges (design order #10) | A birth or sect edge that grants an early glimpse (Open Question 6) | The glimpse allowance stays at `dao_glimpses_per_realm` |

**Downstream: systems that depend on the Way**

| # | System | What it takes |
|---|---|---|
| 10 | Meridian Map | The points spent on Dao nodes, which its unspent figure subtracts |
| 6 | Spiritual Roots | Open Question 9 is answered here: the relocated mutations are Daos |
| 9 | Cultivation Techniques | Open Question 11 closes: no shipped template names a relocated id |
| 23 | Event Engine | A new effect, `dao_glimpse`, with a per-realm limit |
| 21 | Combat | Way arts and fight Effects |
| 35 / 36 / 37 | Guidance Layer, Debug Terminal, Game UI | The Dao list, trees with costs and the glimpse offer |
| 5 | Save/Load | The Daos glimpsed and the nodes bought |

**Cycle and how it is broken:** the Way and the Meridian Map share one pool of points. The
Meridian Map owns the total (its Formulas A); the Way keeps its own count of points spent, and
the map's unspent figure is the total minus both counts. Neither system calls the other each turn.

**Combat sub-systems (back-references added by the Combat revision #43, 2026-11-08).** This system and the four
systems split out of Combat depend on each other as follows.

- **Modifier System (#40):** Way nodes carry catalogue modifiers at its W prices, including `more` on L2.
- **Effects System (#41):** Way nodes and capstones host Effects (conditions, triggers, keystones).
- **Combat Damage Types (#21b):** a Way art node declares its damage parts and types.
- **Combat Defence & Healing (#21a):** ward spells and heal arts may be Way content.

## Tuning Knobs

All live in `dao.json` (Formulas D1–D3). Safe ranges are guesses until the bot run (Open
Question 4, 5).

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `dao_node_cost` | 1 | 1–2 | Points per node, flat. Moves a Dao's total cost and the stat-node budgets (Formulas D1) with it |
| `dao_premium` | 2 | 1.5–3 | How much a stat node beats the acupoints it replaces, for the player and for NPCs. 3 lets Daos outshine the map |
| `dao_node_count`, `dao_full_points` | 150, 149 | 110–170, 109–169 at cost 1 | How much of a life's points a Dao takes (4 Mastered Daos ≈ 600 of 566, so a life masters one or two), and the authoring load |
| `dao_capstone_depth` | 10 | 8–16 | How deep the signatures sit: points before a Dao names the build |
| `dao_keystone_count` | 5 | 2–6 | How many signatures a Dao offers, and so how many builds it names |
| `dao_rate_cap_pct` | 10 | 5–15 | Most cultivation speed one Dao may give (Formulas D1 part 5). Higher lets a Dao speed the climb and could shift the gate calibration |
| `dao_node_tol` | 0.2 | 0.1–0.3 | How far one stat node may sit from W_small or W_notable. Wider lets a node be a jackpot or a trap (replaces `dao_branch_tol`, `dao_route_floor` and `dao_ability_credit`, retired 2026-11-10) |
| `dao_req_purity_min` | 30 | 20–50 | Least purity of a required element at the glimpse (rule 5; review D-12) |
| Data size | 94 Ways × about 150 nodes ≈ 14,000 nodes in `dao.json` | load once at start; a save stores bought node ids per Dao | Load time and save size (review D-17) |
| Facet slot table | 1 major, 2 minor per facet | ±1 per kind, by the harness | How rule-heavy a Dao is against its stat lines (rule 10) |
| `dao_art_share_max`, `dao_two_art_max` | 0.2, 2 | 0–0.3; 0–3 | How often a Dao carries an art instead of leaving arts to techniques (user decision 2026-11-10: rare) |
| `dao_glimpses_per_realm` | 1 | 1 (2 only if `dao_open_min` ≥ offer + 7, so at offer 3 and not at offer 4, which needs 11 against a ceiling of 10) | Daos per life (4 at 1) |
| `dao_glimpse_realm_min` | 1 (Foundation Establishment) | 1–2 | When the first Dao can come |
| `dao_offer_size` | 3 | 2–4 | Choice at a glimpse; the invariant in Formulas D2 must hold (at 4 it needs `dao_open_min` ≥ 7) |
| `dao_open_min` | 6 | 6–10, and never below `dao_offer_size + 4·dao_glimpses_per_realm − 1` | How many Daos anyone can be offered |
| `npc_dao_chance` | 0.5 | 0.2–0.8 | How common Dao-holding NPCs are |
| `npc_dao_share` | 0.25 | 0.1–0.30 | NPC points in the Dao; `power_mult` caps at 1 + `dao_premium` × share ÷ (1 − share), so 0.30 gives 1.86 |

## Visual/Audio Requirements

Deferred. Each Dao will want an identity (colour, sigil and sound) when the Game UI and Audio
are designed.

## Game Feel

Not specified at this tier. Intent for later work:
- **A glimpse** is a moment: `dao_offer_size` Daos offered, one chosen, and a graph to look at whose shape is the Dao.
- **A node** feels like a real purchase: clearly better than the same node on the map.
- **A facet's far end** pays off: its `major` Effect changes how the build plays.
- **A capstone** is the payoff that names the build; a Dao offers several, so two lives in one Dao can be named differently.
- **A graph** reads as its Dao: every node sounds like Sword, or Time, and like nothing else.

## UI Requirements

Specified for the Debug Terminal now and the Game UI later.
- **The Dao list** shows each Dao as unknown (not shown), glimpsed, keystoned or mastered.
- **A graph** shows every node in its authored layout with its kind (stat, Effect with its tier, art,
  capstone) and what it gives, which nodes are buyable now (joined to a bought node), the flat cost,
  and the shortfall when the character cannot afford one. Facets are named on the drawing.
- **The offer** lists `dao_offer_size` Daos (three at the default) with their requirements and a one-line description.
- **The Advisor** shows a stat line's marginal gain before a buy on a curve key, and warns when it would sit above a
  cap.
- **Drawing a graph:** the Debug Terminal lists nodes by facet; the Game UI draws the authored layout (about 150
  nodes, as the Meridian Map viewer does) and must stay responsive at that size (review D-17).
- **The unused-glimpse heads-up:** from Foundation Establishment, while the realm's glimpse is
  unused, the Advisor says so, shows the character's unspent points, and notes that a Dao graph
  is 110–170 points and its first capstone at least 10. It is information only and never forces or blocks a spend.
- **The shared pool:** the unspent count is the same figure the Meridian Map shows.

## Cross-References

| Document | What it must say or do |
|---|---|
| `design/gdd/linh-can.md` | Open Question 9 is answered by this GDD, and rule 16 points here |
| `design/gdd/cong-phap.md` | Open Question 11 closes: no shipped template names a relocated mutation |
| `design/gdd/kinh-mach-do.md` | List the Way in Dependencies: its unspent points subtract the Way's spent count |
| `design/gdd/character-stats.md` | A Dao is a new modifier source on the stat sheet |
| `design/gdd/canh-gioi.md` | The gate calibration holds because Daos add no cap raise (rule 4); a Dao stat line's breakthrough chance is a q-extras source under the 10 pp ceiling, while Effects on breakthrough and heart-demon odds may exceed it and need the recalibration (2026-11-10, review D-05) (added 2026-11-06) |
| `design/gdd/systems-index.md` | Row 39 and the design order |
| `design/registry/entities.yaml` | The keys and formulas above |

## Acceptance Criteria

Evidence: Logic and Integration tests under `tests/unit/dao/`, Config/Data checks of `dao.json`,
and UI transcripts under `production/qa/evidence/debug-terminal/`.

**Costs and data**

- **AC-DAO-01** [Config/Data] Every Dao in `dao.json` has 110–170 nodes; at the defaults (cost 1, premium 2)
  every small and road node is 1.92–2.88 W and every stat notable 12.8–19.2 W, and the W per point over priced
  nodes is at least 3.73 (Formulas D1 parts 2–3). A fixture small node at 1.8 W or 3.0 W fails, and so does a
  notable at 12 W or 20 W. With `dao_premium` 3 the bands scale to 2.88–4.32 and 19.2–28.8 W.
- **AC-DAO-27** [Config/Data] Graph lint (Formulas D1 part 1). A fixture Dao fails if: a node is
  unreachable from the start; two edges cross; two nodes sit closer than 0.6; a capstone is 9 points from the
  start; or the Dao holds 1 or 7 capstones. The Sword pilot passes (capstones at 11–12).
  The Formulas D1 example Dao passes.
- **AC-DAO-28** [Config/Data] Slot table (rule 10, Formulas D1 part 4). A fixture facet with 2 `major`
  Effects, or 3 `minor` (an art's rider counting as one) fails; a Dao with 2 arts not named as an exception, or
  any Dao with 3, fails; a catalogue where more than 20 % of Daos hold an art, or 3 Daos hold two, fails; a small or road node
  holding an Effect fails; a capstone with no Effect, two Effects, an Effect of tier `major`, or two rare
  modifiers fails; a rival mark on one capstone of a pair but not the other fails; a fixture pair in two different
  Daos whose `closes` and payload contradict (One Sword's single sword art against a capstone that needs several)
  fails until both are marked rival. Every Effect a Dao holds lists the Way in its `hosts` (Effects System rule 13).
- **AC-DAO-26** [Config/Data] Rate cap (Formulas D1 part 5). A fixture Dao with 12 `alchemy_success` lines passes
  (the key-headroom check was dropped 2026-11-10); a fixture Dao whose
  `cultivation_speed_pct` lines sum to 11 % fails at the default `dao_rate_cap_pct` 10 and passes
  at exactly 10 %. A fixture Dao with the same lines on an uncapped key passes.
- **AC-DAO-21** [Config/Data] At least `dao_open_min` Daos have no root or technique
  requirement, and `dao_open_min ≥ dao_offer_size + 4·dao_glimpses_per_realm − 1` holds. The
  lint also fails when a deletion drops the open count below the invariant.
- **AC-DAO-22** [Config/Data] No node carries a ceiling raise or a root factor, and none multiplies a
  whole cultivation rate, lifespan or breakthrough chance (rule 4). Every art node passes Combat's art
  record validation (Combat rule 13) and its damage parts are typed.
- **AC-DAO-23** [Config/Data] Every stat line uses only its Dao's `theme_stats`. No capstone or `major` Effect id
  appears in two Daos; a `minor` Effect may, and lists every hosting Dao in `host_dao` (a fixture `minor` shared by
  two Daos passes; a shared `major` fails).
- **AC-DAO-02** [Logic] Formulas D1: every node costs 1 point, whether a small node, a notable, an Effect, an
  art or a capstone; the start is free; W_small is 2.4 W and W_notable 16 W.
- **AC-DAO-03** [Logic] The Formulas D1 example (the Sword pilot) has 158 nodes and costs 157 points to master
  (the start free); it holds 121 small or road nodes, 15 stat notables, 15 Effect notables (1 `major` and 2 `minor`
  per facet), no art and 6 capstones, each 11–12 points from the start; it passes the lint.

**Glimpses**

- **AC-DAO-04** [Logic] With |E| = 7 the offer holds three distinct Daos and draws one value per
  entry offered. With |E| = 2 it holds two. The same seed gives the same offer.
- **AC-DAO-05** [Logic] A Qi Refining character is given no glimpse. From Foundation
  Establishment, each realm allows one; a second `dao_glimpse` in the same realm is refused, and
  an unused allowance does not carry into the next realm.
- **AC-DAO-06** [Logic] A Dao whose requirement the root does not meet is never offered; a Fire Way is offered at Fire purity 30 and not at 29 (`dao_req_purity_min`). A
  glimpsed Dao stays after a technique change.

**Buying**

- **AC-DAO-07** [Logic] A node in an unglimpsed Dao is refused. The start is owned at the glimpse;
  any other node is refused until a node sharing an edge with it is bought. A capstone is refused until
  a neighbour of it is bought, and while its rival is held. A buy below cost is refused and names the shortfall. No node is ever
  refunded.
- **AC-DAO-08** [Integration] A character with 200 points who masters a 149-point Dao has 51
  left, and the Meridian Map allocation sees 51. The map refuses a 52nd acupoint.
- **AC-DAO-09** [Logic] A Dao's breakthrough-chance line above the q-extras ceiling is clamped and the sheet shows
  the clamp line. A Dao's herb-growth line adds through Character Stats' curve (no clamp line).
- **AC-DAO-10** [Integration, Bot: `autoplay.gd`] `autoplay.gd --edge on --perk dao_cot --dao <id>` (the Đạo Cốt perk is
  AC-CG-31's fixture, not a Dao). The `--dao` flag is a test hook: it grants the glimpse of
  `<id>` on entering Foundation Establishment, bypassing the Event Engine, and buys nodes of that graph in
  node-id order (each joined to one already bought) as the points allow; the graph is Mastered only from Core
  Formation on. The three stat-line-only test Daos are fixtures in the test data: one whose lines are all
  cultivation speed (held to the rate cap), one all alchemy and brewing success, and one all Dao heart and
  comprehension, each at the top of the bands (121 small nodes at 2.88 W and 36 stat notables at 19.2 W, about
  6.6 W per point) so they are the worst case for rule 10. They check the gate calibration beyond what shipped
  data can reach. At each gate (Foundation Establishment to Core Formation, Core Formation to Nascent Soul, Nascent
  Soul to Deity Transformation) the Realms gate runs stay inside AC-CG-31's windows. The run is repeated with four
  such Daos (a glimpse in every realm from Foundation Establishment), so the per-Dao rate cap summed over Daos has
  not moved the gate calibration either (review D-11, D-13).
- **AC-DAO-29** [Integration, Bot: `autoplay.gd`] Each Effect that changes breakthrough or heart-demon odds (rule 4)
  has a bot fixture; the Realms gate runs with it are recorded for the Realms recalibration, and the Effect may push
  the odds past the q-extras ceiling (user decision 2026-11-10, review D-05).

**NPCs**

- **AC-DAO-11** [Logic] Formulas D3 at `dao_full_points` 149, on the Meridian Map's stage totals: 161 points
  (Core Formation early) gives P_npc 40, map_points 121, power_mult 1.661; 216 (Core Formation great perfection)
  P_npc 54, 162, 1.667; 278 (Nascent Soul early) P_npc 69, 209, 1.660; 458 (Deity Transformation early) P_npc 114,
  344, 1.663; 566 P_npc 141, 425, 1.664 (each ±0.001; the cap never binds). An NPC with no Dao has power_mult 1.000.
- **AC-DAO-12** [Logic] Over 16,000 NPC rolls at `npc_dao_chance` 0.5, 50 % ± 1.6 pp succeed. An
  NPC generated at Core Formation rolls once, for its current realm only. An NPC that has a Dao
  makes no further roll in later realms and still holds exactly that one Dao. With test data
  where an NPC qualifies for no Dao, a successful roll leaves it with none and it rolls again in
  its next realm.

**Persistence and the world**

- **AC-DAO-13** [Integration] A save round trip keeps every Dao glimpsed and node bought. A node
  removed from the data comes back as unspent points.
- **AC-DAO-14** [Integration] A glimpse and each capstone purchase write one World Database
  event each. Buying a capstone as the last node (Glimpsed straight to Mastered) writes exactly one
  event. Buying the last non-capstone node of a Keystoned Dao writes none.

**UI**

- **AC-DAO-15** [UI] A retained screenshot or transcript shows, each as its own item: the Dao
  list with unknown / glimpsed / keystoned / mastered states, a graph with every cost and the
  unaffordable nodes marked with their shortfall and the buyable nodes marked, the offer of `dao_offer_size` Daos with their requirements and
  one-line descriptions, the Advisor's marginal-gain note before a buy, and the unused-glimpse
  heads-up with the unspent count (at Foundation Establishment with the glimpse unused, and
  absent once it is used).

**Added by the 2026-11-05 and 2026-11-06 reviews**

- **AC-DAO-16** [Integration] An NPC with a Dao (Formulas D3): the Meridian Map allocator is
  called with `map_points`, not `points_total`, and the resulting combat power is multiplied by
  `power_mult`. An NPC with no Dao is called with `points_total` and a multiplier of 1.000.
- **AC-DAO-17** [Logic] With E empty the glimpse is skipped and the realm's allowance is kept; a
  declined offer uses the allowance and leaves every offered Dao in E.
- **AC-DAO-18** [Integration] A Dao Effect and a Meridian Map keystone that give the same
  breakthrough chance both apply. The Dao's share counts only under the 10 pp q-extras ceiling:
  with the tree at its 8 pp cap and a Dao line of 4 pp, the extras clamp at 10 pp and the sheet
  shows the clamp line. With the Dao line at 4 pp and the tree at 12 pp offered, the tree
  counts 8 pp and the Dao 4 pp (12 pp, clamped to 10 pp).
- **AC-DAO-19** [Logic] A node removed by a data change is refunded, and a node that needed it
  stays bought.
- **AC-DAO-20** [Config/Data, human sign-off] A content review of the shipped catalogue: for each Dao, shown its
  nodes and shape with the name hidden, at least 2 of 3 reviewers name it, and each of its five facets
  is a named face of the theme that opens its own build direction (rule 12). A Dao that fails goes back to the content pass.
- **AC-DAO-24** [Logic] Edge Cases: a data change that adds a node to a Mastered Dao leaves it
  Keystoned and writes no second keystone event. A deleted glimpsed Dao refunds its
  bought nodes and the save loads. A changed requirement leaves a glimpsed Dao in place.
- **AC-DAO-25** [Integration] An NPC that rolls a Dao has its id in its record and one World
  Database fact for it, and the id survives a save round trip. An NPC with no Dao has neither.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | The `dao_glimpse` contract: which events grant it, how often (the rate), and what the validator checks. The Event Engine is already implemented, so read its code before settling the contract. The rate also decides how often the unused-glimpse heads-up fires | Event Engine | Any Dao in play |
| 2 | The catalogue (in progress 2026-11-10): the consolidated roster, then a graph of about 150 nodes for each Way (Sword pilot v2 approved 2026-11-10), each from its theme (rule 12), with each Way's requirement and `theme_stats`. Pilot: Sword. Graphs live in `tools/design/meridian_rework/regions/dao_<slug>.py` | game-designer, user | Content pass |
| 3 | **Closed 2026-11-10:** Combat is designed; arts follow Combat rule 13 and are bounded by its art rules and the slot table, so they need no W credit | — | — |
| 4 | The slot table, `dao_node_tol` 0.2, `dao_capstone_depth` 10 and `dao_keystone_count` 5 are guesses (several capstones in one life may stack strongly: the harness checks a Dao with all its non-rival capstones), and Effects and arts are unpriced. `dao_premium` 2 already puts a Mastered Dao's stat lines above what its points buy on the map (the Sword pilot: about 530 W against the 325 W its points buy on the map, Formulas D1), and the Effects, capstones and rare art come on top. Measure a life with one, two and four Daos against combat and NPC power with the balance harness once the pilot and a few Ways exist | systems-designer | A content pass and a bot run |
| 5 | `npc_dao_chance` and `npc_dao_share` are guesses, and so is the assumption behind `power_mult` (map power close to linear in points). A bot run must confirm that a Dao-holding NPC ends up about 11–25 % above a Dao-less NPC of its level, check the combined NPC uplift with cluster holders (Meridian Map AC-KMD-49), and re-run the world census, since stronger NPCs may change who dies | NPC Builds, bot run | AC-DAO-11, 12 |
| 6 | May a perk or a sect grant an early glimpse (a birth edge)? It would touch Progression Edges | game-designer | The edge |
| 7 | Do Dao trees sit on the Meridian Map screen or on their own? | ux-designer | The UI |
| 8 | **Closed 2026-11-10:** Combat is designed, so the Way ships with arts and Effects; its tier in the index stays Alpha (provisional) | — | — |
