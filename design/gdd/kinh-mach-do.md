# Meridian Map (Kinh Mạch Đồ)

> **Status**: In Review (2026-11-05: map density revision by user direction, rule 21: generic roads, smaller clusters, clusters in the border gaps, region capacity, the drawing rules; awaiting a fresh /design-review). Previously Approved (2026-11-04: lean re-review after the Spiritual Roots redesign added the hidden variant sectors, rule 20, Formulas H2–H4 and G9; 0 blockers, 9 recommended). Seven lean /design-review passes: the first five returned NEEDS REVISION and every blocker was fixed; the sixth and seventh found no blockers. Recommended revisions (variant-sector breakthrough side effects through toxicity and heart demon, the reserved id block, AC-KMD-34 lifespan figure, step 9 variety tie-breaks, symbol collisions, per-region link capacity) are settled during implementation or the next edit. Open Questions 4, 5, 9 and 14 stay open. See `reviews/kinh-mach-do-review-log.md`.
> **Creative Director Review (CD-GDD-ALIGN)**: skipped (Lean mode)
> **Author**: user + Claude
> **Last Updated**: 2026-11-05
> **Last Verified**: 2026-11-04
> **Implements Pillar**: Pillar 1 (Your Dao, Your Name), Pillar 3 (Power Is Built, Not Given); touches Pillar 2 (Every Number Is Bounded and Visible)

## Summary

The Meridian Map (Kinh Mạch Đồ) is the game's PoE-style passive tree.
- **The map.** One fixed map of about 1,300 acupoints (huyệt), growing from the dantian
  (Đan Điền) through inner, middle and outer bands. It is identical in every life and
  append-only at the rim.
- **Points.** Earned per level (1–300) and at every great and small breakthrough.
- **Value.** Every acupoint's value scales with the spiritual root's (linh căn) purity in
  its element.
- **Hidden clusters.** About 75, mostly at the rim, that points alone can't reach. An
  event, item or cultivation technique (công pháp) unseals a fully authored **sealed**
  cluster, which may carry one of 25 **capabilities** (rule changes such as dual-wielding
  magic treasures [pháp bảo] or a second cultivation technique). A story moment unseals an
  **open** cluster, which the LLM fills inside a validated budget.
- **Variant sectors.** Each of the eight variant roots (biến dị linh căn) has a hidden sector of
  30 acupoints, 240 in all and outside the 1,300, that stays locked and undrawn until the root
  owns that variant.
- **Bounds.** Every number is bounded and recorded. NPCs build on the same tree under
  the same rules.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Linh Căn, Character Stats, Cảnh Giới & Bình Cảnh`

## Overview

The Meridian Map (Kinh Mạch Đồ) is the player's Path-of-Exile-style passive tree: one
fixed map of acupoints (huyệt) growing out of the dantian (Đan Điền) in five element
sectors, explored by spending meridian points (Kinh Mạch points) earned at each
breakthrough stage. A point opens one acupoint next to an already-open one; small
acupoints carry modest bonuses, notables and keystones carry larger or trade-off bonuses,
and every bonus scales with the player's purity in the acupoint's element, so a
character's spiritual root (linh căn) decides which regions of the map are worth walking.
The map is identical in every life, so it can be learned and planned.

On top of that base map sit **hidden clusters**: themed groups of acupoints, mostly on the
outer ring and occasionally deeper inside, that cannot be reached with points alone. A
cluster starts hidden and opens only when its condition is met: an event, an item or a
cultivation technique (công pháp). **Sealed clusters** have authored content, identical in
every life, so a player who learns what unlocks which cluster can plan a whole build
around it. **Open clusters** have a fixed place and theme but no fixed content: when a
story moment unlocks one, the LLM writes its acupoints inside an engine-set budget
(clamped and recorded like every LLM number), with a template pool as the offline
fallback. Once unlocked, a cluster is part of that life's tree and its acupoints are
opened with points like any other.
What varies between lives is only what fills the open clusters; positions, themes and
conditions never change.

A rarer root opens a further layer. Each variant root (biến dị linh căn) has its own small sector,
not drawn at all until the root owns that variant, and where it sits tells how the variant arose:
innate ones near the dantian, a transmutation off its element, a convergence as a chord across the
wheel between its two elements.

The tree is where Pillar 1 (Your Dao, Your Name) and Pillar 3 (Power Is Built, Not
Given) meet: two cultivators with the same root diverge by the regions they walk and the
clusters their lives earned, and power from a hidden cluster is earned through play,
never picked off a list. It stays inside Pillar 2 (Every Number Is Bounded and Visible)
because every LLM-written value is budgeted and recorded.

## Player Fantasy

*Draft derived from the Overview and Pillars 1–3; edit freely.*

You read the map the way a cultivator reads their own body. Your spiritual root (linh căn) tells you which
regions of the tree are yours to walk, and every point is a small, permanent decision: no
refunds, no respec. The planning pleasure is in the long routes: you spot a notable twelve
steps away and count what it will cost.

Then, far out on the rim, a silhouette you have been eyeing opens because of something your
life did: a hard-won item, a cultivation technique (công pháp) you stayed with for years, a story moment you lived
through. The door should feel earned, never bought. Two cultivators with the same root end
up with different trees, because their lives opened different doors.

## Detailed Design

Rules 1–21 are **built** in the debug terminal (`src/gameplay/meridian/`, 2026-11-05), with
sealed cluster content as theme-pool filler (Open Question 6) and open-cluster fills from the
template pool only. Quantities in these rules are named parameters; their values and ranges
are in Formulas.

### Core Rules

**The base tree**

1. **The map.** Generated deterministically from `assets/data/meridian_tree.json` (fixed
   seed), so it is identical in every life. About `tree_size_target` acupoints (about
   1,300: 772 visible, about 525 in hidden clusters), laid out from the core outward
   in bands:
   - **Core:** the dantian (Đan Điền) at the center and five element gates in generating
     cycle (tương sinh) order, clockwise from the top (Wood → Fire → Earth → Metal →
     Water; Mộc → Hỏa → Thổ → Kim → Thủy). A center keystone, the Five Elements Cycle (Ngũ
     Hành Luân Chuyển), sits at d 1 next to the dantian (a 1-point take for a 5-element
     root) and needs all five base elements.
   - **Inner band:** meridian roads (kinh lộ) and small visible clusters, reachable in Qi
     Refining (Luyện Khí); rare inner hidden clusters.
   - **Middle band:** visible base clusters and bridge clusters between neighbouring
     element sectors.
   - **Outer band:** keystones and most hidden clusters.
   - **Expansion band:** reserved beyond the rim and empty at launch (rule 19).

   The map is built from eight kinds of piece:

   | Piece | Visible | Content |
   |---|---|---|
   | Meridian road (highway) | yes | Chains of small acupoints carrying generic stats (`road_stats`: mostly vitality, then spiritual power and divine sense; H0; never breakthrough_chance), the same in every sector and not scaled by the root (rule 21). Each sector has 3 radials, and 3 rings cross every sector. They connect regions; 430 at launch, gates included |
   | Junction acupoint (hội huyệt) | yes | A meridian road acupoint where meridian roads meet: a gate, a ring junction, or a fork or merge point. It has 3–4 links and is the only kind of acupoint that may have 4 (the dantian excepted). Same stats as meridian roads; 85 at launch, counted within the meridian roads |
   | Base cluster | yes | A shaped group of small acupoints around 1–3 notables, generated from its theme's pool (themes such as Sword Intent [Kiếm Ý], Body Guarding [Hộ Thể], Spiritual Power [Linh Lực], Vitality [Khí Huyết], Divine Sense [Thần Thức], Way of Alchemy [Đan Đạo], Artifact Refining [Luyện Khí], Way of Formations [Trận Đạo], Way of Talismans [Phù Đạo], Beast Taming [Ngự Thú], Spirit Fields [Linh Điền], Longevity [Thọ Nguyên], Heart State [Tâm Cảnh], Fortune [Khí Vận], Escape Arts [Độn Thuật]); 40 at launch |
   | Bridge cluster | yes | Mixes the two neighbouring sectors' elements; one in the middle band and one in the outer band of every border (10) |
   | Keystone | yes | One trade-off rule; two per sector at the rim plus the center (11) |
   | Sealed cluster | hidden | Fully authored (rule 12); may carry a capability (rule 16) |
   | Open cluster | hidden | Written by the LLM at its story moment, inside the budget (rules 10–11) |
| Variant sector | locked until owned | 30 acupoints themed on one variant root, outside the base totals (rule 20) |

   The prototype built today is a 9-ring, 202-acupoint version of the same layout: gates on
   ring 1, notables on rings 3, 5 and 7, keystones on ring 9, bridges on rings 3, 6 and 8.

   **Topology (how acupoints connect), decided 2026-11-03.** The aim is a flexible graph
   where routes still matter.
   - **Meridian roads (highways).** Chains of small acupoints with generic stats carry the
     player between clusters, like PoE's attribute paths.
     - Each sector has 3 **radial meridian roads** from its gate to the rim, named L
       (left), C (centre) and R (right). They fork and merge along the way.
     - At each band edge (inner/middle, middle/outer and the rim) a **ring meridian road**
       runs sideways. It links neighbouring clusters and continues across sector
       borders. The rings are named K1, K2 and K3, so a name starting with K is a ring
       and one starting with L, C or R is a radial.
   - **Junction acupoints.** Where meridian roads meet, roughly every 3–5 steps; these are
     the crossroads a route is planned around.
   - **Cluster entries.** Every cluster, visible or hidden, has 1–3 entries (about 2 on
     average). Its notables stay farthest from the entries (rule 6).
   - **Flexibility limits.** The generator enforces these and rejects or repairs a seed
     that breaks them:
     - Neighbouring clusters connect by at least 2 routes, and the second is at least 2
       steps longer than the first.
     - An acupoint has at most 4 links, and only junction acupoints have 4. The average is 2.3–2.6.
     - There is no band skipping: reaching depth d always costs at least d points,
       including through an unsealed hidden cluster.
   - **Bridges.** Each border between neighbouring element sectors has 5 crossings: the 3
     ring meridian roads, plus a bridge cluster in the middle band and one in the outer band.
   - **Shapes.** Clusters take a shape from a catalogue: ring, star, chain, fork, loop
     with a tail, double ring, crescent, cross. Each theme has a preferred shape (for
     example Sword Intent a chain, Way of Formations a ring), but any theme may use any shape, and
     authored data may override.
   - **Hidden clusters** are wired exactly like visible ones. One with 2 entries becomes
     a shortcut once unsealed.
   - **Size.** The meridian roads and bridges bring the visible tree to 772 acupoints and the
     map to about 1,300 (Formulas H). Clusters grow toward the rim: 3 inner, 5 middle, 8 outer
     (rule 21). The outer rings keep 3 ring acupoints per K2 and K3 segment.
2. **Points.** Cultivation runs on **levels 1–300**. Each realm is a band of levels, and at
   the top of the band the bottleneck (bình cảnh) holds the level until the realm breakthrough succeeds.
   Points come from:
   - **Birth:** 2.
   - **Levels:** 1 point per level gained. A level gives points only; stat rises come from
     breakthroughs.
   - **Great breakthroughs:** entering a new realm (its early stage, sơ kỳ). Each one has a
     bonus (`great_breakthrough_bonus`: Foundation Establishment [Trúc Cơ] 15, Core Formation [Kết
     Đan] 25, Nascent Soul [Nguyên Anh] 40, Deity Transformation [Hóa Thần] 60).
   - **Small breakthroughs:** inside each realm, the early, middle and late stages (sơ kỳ,
     trung kỳ, hậu kỳ) split the realm's levels into thirds, and great perfection (đại viên
     mãn) is the realm's last level.
     - Reaching the **middle stage** grants 15% of the next great breakthrough's bonus, and
       the **late stage** 25%. These are extra.
     - Reaching **great perfection** grants 35% of it as an **advance**, so the great
       breakthrough then pays the remaining 65%.
   - **Events:** an event may grant 1 (the Event Engine's budget file caps grants; Open
     Question 11).
   - Every great and small breakthrough also raises base stats.

   Totals at great perfection: Qi Refining 51, Foundation Establishment 120, Core Formation
   216, Nascent Soul 357, Deity Transformation 566 (with a placeholder for the realm after
   Deity Transformation). Formulas has the exact computation. Realms & Bottlenecks (Cảnh
   Giới & Bình Cảnh) owns the level bands, the stat rises and these values, and the Event
   Engine owns event grants; they are provisional here. The built
   prototype still uses the old ladder (stages, 1/3/4/5/6 points per stage, 86 at most).
3. **Opening an acupoint** costs 1 point. It must not already be open, must be adjacent to
   an open acupoint, and, for an acupoint that names a minimum element count, the player's
   spiritual root (linh căn) must have that many base elements. Opening a path to a target
   opens every acupoint on the shortest route, all or nothing: it fails without spending
   anything if the points do not
   cover the whole route. When several routes are equally short, the one with the highest
   total scaled value (rule 4) is taken, then the one whose acupoint ids sort lowest; the path
   tool previews that route. Points are never refunded and there is no respec.
4. **Bonuses.** Each open acupoint adds its stat modifiers to the character's stat sheet
   under the source "Kinh Mạch: <name> #<id>". A sector acupoint's values are multiplied by
   0.5 + purity/100 for the sector's element, or by 0.25 if the player lacks that element
   (gates and cluster acupoints; meridian roads are exact, rule 21);
   a bridge acupoint uses the average of its two sectors' multipliers; a variant sector's
   acupoint uses 0.5 + purity/100 for its variant (rule 20); keystones, meridian roads and the root are exact. So purity, not just element count, decides which regions pay off. The
   summed `breakthrough_chance` from all Meridian Map (Kinh Mạch Đồ) acupoints is clamped
   at `tree_breakthrough_cap` (Formulas F), and the stat sheet shows the clamp.
5. **NPCs** spend their points greedily under the same rules: every reachable acupoint is
   scored by its kind and boosted if it lies in a sector favoured by the NPC's archetype,
   with a small random term, until the points run out. The weights are
   `tree_kind_scores` and `tree_focus_weight` in `world_generation.json`.

**Hidden clusters (new)**

6. **A hidden cluster** is a fixed group of acupoints in the map data. It has:
   - an id and a name;
   - a **theme**, which is a system the game already has (Way of Alchemy, Artifact
     Refining, Way of Formations, Way of Talismans, Beast Taming, Divine Sense, Longevity,
     Heart State, and so on);
   - an element affinity;
   - a **location**: *outer*, in the outer band (the usual case), or *inner*,
     linking at depth 3–7 (rare; its interior may reach into the middle band);
   - 1–3 entries linking to existing acupoints (about 2 on average; rule 1, Topology);
   - a **kind**, *sealed* or *open*;
   - exactly one **seal condition**;
   - a **size** of 3 to 15 acupoints, drawn from a normal distribution
     (`cluster_size_mean`, `cluster_size_sd`) once with the tree seed and then fixed.

   A cluster has one notable per `huyet_per_notable` acupoints (1 to 3), the theme's payoff,
   placed farthest from the entry so the player pays for the small acupoints first. Each
   notable's route distance from the nearest entry is at least that of every small acupoint
   in the cluster. Its size
   sets its minimum realm (`size_realm_gates`); an inner cluster's gate is one realm
   lower, so the rare inner cluster can open in Qi Refining. The number of clusters, and each
   cluster's location and kind, are rolled once with the tree seed (`cluster_count`,
   `inner_share`, `sealed_share`). No type has a fixed count. The cluster list,
   positions, sizes, themes and conditions are the same in every life. The seed rolls only
   the count, each cluster's location and kind, and its size. Theme, element affinity,
   sector and the placement of capabilities are authored in the data after the seed is
   accepted. Entry links are generated by the topology generator (Formulas H, G7);
   authored data may override them, and the content build re-runs the G8 checks. The
   content build fails if the catalogue cannot be placed (AC-KMD-41).
7. **Seal conditions.** Each cluster has exactly one, fixed in data, with an optional
   minimum realm:
   - *event*: an Event Engine effect that unseals this cluster, carried only by the event
     template authored for that cluster (a sealed cluster can never be unsealed by an
     LLM-invented event);
   - *item*: a Meridian Seal (Mạch Ấn) key item bound to this cluster is used and consumed;
   - *cultivation technique* (công pháp): a cultivation technique that lists this cluster is
     the active cultivation technique (the main slot) for a number of seasons spent
     cultivating (`cong_phap_seasons`; idle seasons do not count, Cultivation Techniques
     rule 15). The seasons add up and need not be in a row: switching to another
     cultivation technique pauses the count, and it never resets.
   Open clusters are unsealed only by the *story moment* effect (rule 10).
8. **Hidden state.** While hidden, a cluster's acupoints cannot be opened, are not part of the
   frontier, and are never routed through by the path tool. Nothing refunds or bypasses
   this: points cannot buy a seal open.
9. **Unsealing.** When the condition is met and any realm minimum holds, the cluster
   becomes unsealed in that life, the world records an event of type "cluster unsealed"
   (player, cluster, source) in the World Database, and the cluster's entry acupoints join
   the frontier wherever they touch an open acupoint. Unsealing grants access only; every
   acupoint is still opened with points under rule 3.
10. **Open clusters and the fill.** An open cluster is unsealed by a *story moment*: an
    event whose effect asks to unseal an open cluster, within the per-realm allowance
    (`open_unseals_per_realm`).
    - **Eligible clusters** are hidden open clusters whose gate is at or below the
      player's realm.
    - **The choice is deterministic.** Among the eligible clusters, the engine takes those
      with the theme the event hints, if any have it. It then takes the lowest C_enter
      (Formulas B) from the player's open acupoints, then the lowest cluster id.
    - **The fill.** The chosen cluster then needs its acupoint names, descriptions and
      bonuses. The engine sends the LLM a fill request with:
      - the theme and element affinity;
      - the cluster's budget (Formulas F);
      - its slot list: each acupoint id with its role, small or notable (the reply is keyed
        by slot id);
      - the unlocking event's people, place and text.
    - **Validation.** The reply is repaired by the validator (rule 11).
    - **Fallback.** The fill comes from the theme's template pool if the LLM is off,
      fails, or returns a reply the validator cannot repair: invalid JSON, or an acupoint
      left with no stat after repair. So a fill always completes.
    The final fill is recorded in the World Database and the player's record; from then on
    it is canonical and is never rewritten, so planning stays possible.
11. **The fill budget (Pillar 2).** A fill may use only stat keys on an allowed list
    (`fill_stats`), values inside per-stat caps, at most the cluster budget in summed
    weighted value, and exactly the cluster's acupoint count and notable count. Budgets
    depend on the cluster's depth and size, not on the player's realm; only the lifespan
    weight uses the realm. Anything outside is repaired in the order Formulas F lists,
    each repair is recorded on the fill, and the adjustments are shown to the player. No fill may contain
    a trade-off keystone, a capability or any other rule change (for example "single
    artifact"), or a flag stat.
12. **Content of sealed clusters** is fully authored in data: every acupoint's name,
    description and modifiers is written by hand, not generated. The stats are held to the
    same budget formula as fills, so authored and LLM clusters at the same reach are
    comparable. A notable that carries a capability carries fewer stats
    (`capability_stat_share`). A cluster's modifiers scale with its affinity element
    exactly as rule 4.
13. **Visibility modes.** A per-life setting, chosen at character creation and changeable
    at any time during play:
    - **Silhouette**: a hidden cluster shows on the map by its location and theme only; its
      content stays hidden and its condition is revealed only after a *discovery*. A
      discovery happens when the player opens an acupoint adjacent to the cluster's entry, or
      when an event, an NPC conversation or an item grants the hint.
    - **Visible**: every cluster shows its location and theme from the start, with its
      condition and, for sealed clusters, its content; an open cluster shows "to be
      written by the story".
    The suggested default is Silhouette for Fated (Thiên Định) lives and Visible for
    Self-made (Tự Định) lives, but any life may pick either mode and switch freely. Switching changes only what is
    displayed:
    - Discoveries persist across switches.
    - A cluster whose condition the player saw in Visible mode counts as discovered after
      switching to Silhouette.
    - An open cluster's content stays hidden in both modes until its story moment.
14. **NPCs.** When a gifted NPC is generated, it may have sealed clusters unsealed, with a
    chance that rises with its realm and edge score (`npc_unseal_chance`, Progression
    Edges owns the edge score); never open clusters, which need the LLM. Unsealed
    clusters then take part in the NPC's allocation under rule 5. An NPC holding a
    capability gets its simplified `npc_effect`, within the caps in Formulas G.
15. **Per-life state** held by the character and saved with it: the unsealed clusters, the
    discovered hints, the recorded fills and the visibility mode.

**Capabilities (divine abilities, thần thông)**

16. **A capability** is a rule change, not a stat: it lets the character do something the
    rules otherwise forbid. Capabilities are an authored catalogue in data
    (`meridian_capabilities.json`). Each one sits on one notable of one outer sealed
    cluster of at least `cap_min_n` acupoints, and the authoring decides where; there is no
    roll. The size floor keeps every capability behind the Core Formation gate, so none can
    affect the first two breakthroughs. About a third of all hidden
    clusters carry one, so every catalogue entry appears somewhere in the tree. Open
    clusters never grant a capability. Opening the notable grants it for the rest of the
    life. Each capability's numbers are parameters in its catalogue entry.
17. **The launch catalogue** (25 entries, grouped by the theme of the cluster that holds
    them):

    | # | Capability | Rule | System touched |
    |---|---|---|---|
    | 1 | Twin Arms in Harmony (Song Khí Hợp Bích) | Two magic treasures (pháp bảo) of the same kind work as a pair: both at full power, +15% attack for the pair | Magic treasures, Combat |
    | 2 | Divided Divine Sense (Thần Thức Phân Hóa) | +1 magic treasure slot and +20% divine sense | Magic treasures, Character Stats |
    | 3 | Treasure Nurtured Within (Dưỡng Bảo Nội Thể) | One chosen magic treasure costs no divine sense and grows +1% per year carried, up to +50% | Magic treasures |
    | 4 | Blood Commands Spirit (Huyết Ngự Linh) | 20% of vitality counts as spiritual power; below 30% vitality, −20% in combat | Character Stats, Combat |
    | 5 | Soul Leaves the Body (Linh Hồn Xuất Khiếu) | Once per realm, survive a death in an event at 5% vitality, losing one stage | Event Engine, Realms |
    | 6 | Twin Technique Cultivation (Song Tu Công Pháp) | Cultivate a second cultivation technique at 50% speed with its full bonuses | Cultivation Techniques (Công Pháp) |
    | 7 | Embryonic Breath (Thai Tức Quy Nguyên) | Age at three-quarters speed during closed-door cultivation (bế quan) | Time & Turn (aging) |
    | 8 | Dao in Dreams (Mộng Trung Ngộ Đạo) | Seasons spent travelling also cultivate, at 50% rate | Cultivation, Travel |
    | 9 | Great Essence-Draining Art (Hấp Tinh Đại Pháp) | Defeating a cultivator gives cultivation base (tu vi) worth 5% of the current stage; heart demon (tâm ma) +2 each time | Realms, Character Stats (heart demon) |
    | 10 | Divided Furnace Flame (Đan Hỏa Phân Lô) | Brew two recipes in one season | Alchemy (Luyện Đan) |
    | 11 | Strange Pill Reborn (Dị Đan Hóa Sinh) | A failed brew has a 30% chance of a random mutated pill within budget instead of ash | Alchemy |
    | 12 | Hundred Herbs Kept Alive (Bách Thảo Tàng Linh) | Harvested herbs keep aging in the bag at half speed | Herbs |
    | 13 | Endless Talismans (Phù Lục Bất Tận) | 30% chance a used talisman is not consumed | Talismans (Phù Lục) |
    | 14 | Portable Cave Abode (Động Phủ Tùy Thân) | Formations and spirit fields work wherever the character is; the field can be tended anywhere | Formations (Trận Pháp), Spirit Fields |
    | 15 | Formation Within a Formation (Trận Trung Trận) | Formations may exceed their maximum by 2 levels; upkeep for those levels ×2 | Formations |
    | 16 | Ten Thousand Beasts, One Heart (Vạn Thú Đồng Tâm) | +2 spirit beasts (linh thú) kept; loyalty never drops below 30 | Spirit Beasts (Linh Thú) |
    | 17 | Beast Soul Union (Thú Hồn Hợp Thể) | The strongest spirit beast adds its full combat power (chiến lực) instead of half | Spirit Beasts, Combat |
    | 18 | Reading Heaven's Secrets (Thiên Cơ Diễn Toán) | See every choice's success and failure outcomes before choosing | Event Engine |
    | 19 | Child of Fortune (Khí Vận Chi Tử) | Once per realm, reroll a failed event check | Event Engine |
    | 20 | Concealed Breath (Liễm Tức Ẩn Thân) | Others see the character two stages lower; hostile events −30% frequency | Event Engine, NPCs |
    | 21 | Blink Mark (Thuấn Di Ấn) | Once a year, travel instantly to any visited place | Travel |
    | 22 | Last Radiance (Hồi Quang Phản Chiếu) | With under 5 years of lifespan left, the breakthrough chance of a pill attempt is up to ×2 (capped by Formulas E2) | Realms |
    | 23 | Burning Life to Break Through (Thiêu Thọ Phá Cảnh) | After a failed pill attempt, burn 10 years of lifespan (5% of the realm's lifespan if more; the years are added to age, Realms rule 18) to retry at once | Realms |
    | 24 | Mutation Awakening (Biến Dị Khai Mở) | Each completed realm breakthrough gives one more roll to every unowned, non-declined derived variant root (biến dị) whose requirement is met (Spiritual Roots rule 10; pricing open, see its Open Question 3) | Spiritual Root |
    | 25 | Heart Demon Turned to Strength (Tâm Ma Hóa Lực) | Heart demon above 50 adds attack (+heart demon ÷ 2 %); backlash chance ×2 | Heart Demon, Combat |

    #14 sits on a **hybrid-theme cluster** (Way of Formations and Spirit Fields), so its
    place on the map is between those two themes; it is still one notable of one cluster (Open
    Question 9).

    Capabilities 22 and 23 act on breakthrough odds. Each is usable once per realm, and at
    most one of them acts per realm step. #22's gain is capped, and #23 costs the greater
    of 10 years and 5% of the realm's lifespan (Formulas E2). They must be calibrated against
    the progression targets (about 3 in 10 baseline, about 7 in 10 with the player's
    edge) before they ship. NPCs can hold sealed clusters (rule 14), so this applies to NPCs
    too.
18. **Capabilities do not stack with themselves.** A capability is held or not. Two
    capabilities that touch the same number apply in catalogue order, and each
    catalogue entry names any capability it cannot be combined with.

**Growing the map**

19. **The map is append-only.** Every acupoint and cluster keeps its id and position
    forever. New content is added only in the expansion band beyond the rim, linked to
    existing outer acupoints, and never moves, renumbers or reshapes anything already there.
    Saves, recorded fills, World Database events and the Codex stay valid across content
    updates. The fixed seed applies to each content release separately, so adding a
    release never rerolls an earlier one. The variant sectors (rule 20) ship in the first release,
    so their host links are part of it; any later change to them follows this rule.

**Variant sectors (added 2026-11-04)**

20. **Variant sectors.** Each of the eight variant roots (biến dị linh căn; Spiritual Roots
    rule 9) has its own sector of `variant_sector_size` (30) acupoints, built from existing
    pieces: a meridian road chain, two clusters and an apex cluster (Formulas H2).
    - **Placement tells the origin.**

      | Origin | Variant | Where | Entry depth |
      |---|---|---|---|
      | Innate (Thiên Sinh) | Wind (Phong), Blood (Huyết), Void (Hư Không) | A spur off an inner radial, near the dantian | 3, 4, 5 |
      | Convergence (Hội Tụ) | Chaos (Hỗn Độn) | A spur off the K1 ring | 7 |
      | Transmutation (Chuyển Hóa) | Light (Quang), Ice (Băng) | A spur off the element's own sector (Fire, Water) | 8 |
      | Convergence (Hội Tụ) | Thunder (Lôi), Darkness (Ám) | A chord across the wheel joining the two elements' sectors (Fire–Metal, Earth–Water), with an entry on each side | 9–13 |

    - **Locked.** While the root does not own the variant, the sector is not drawn and not
      hinted in either visibility mode (rule 13). Its acupoints cannot be opened, are not
      part of the frontier, are never routed through by the path tool, and are not counted
      in the reported map size. No event, item or point opens it.
    - **Unlocked.** When the root gains the variant, at birth or later, the sector is
      visible at once and its entries join the frontier wherever they touch an open
      acupoint. It has no seal and no realm minimum, and every acupoint still costs 1 point
      under rule 3. Variants are never lost, so a sector never relocks. Nothing is refunded
      when a sector appears.
    - **Nothing new is saved.** Whether a sector is unlocked is read from the root; its open
      acupoints are saved like any other (rule 15).
    - **Value.** A sector's acupoints scale by 0.5 + purity/100 for its variant, recomputed
      when a derived variant's purity changes. There is no absent value, since a locked
      sector cannot be opened.
    - **Content.** Stats come from the variant's theme (`variant_stats`, Formulas H4), using
      weighted stats only. Clusters are generated like base clusters; each sector has one
      authored apex notable. Its roads are kind `variant_road`, not meridian roads, so they
      carry the theme's stats and rule 1's element-only limit does not apply. A sector holds no keystone, no capability, no
      `breakthrough_chance` and no stat under a character-wide ceiling. An LLM never fills
      one.
    - **Links.** A sector joins the map only at its hosts, and never links to another
      sector. A chord is a real route between its two element sectors, for its holder only.
    - **NPCs.** An NPC that owns a variant may spend in its sector under rule 5. Sector
      acupoints score by their kind (a road as a small acupoint, the apex as a notable) and
      get no sector focus boost.

**Map density and drawing (added 2026-11-05, user direction)**

21. **Density.** The map must read clearly: no packed clusters and no empty gaps.
    - **Generic roads.** Meridian roads and junctions carry `road_stats` at H0, the same in
      every sector, like PoE's attribute paths. Their value is exact, so a road pays the same
      on every root. The five gates keep their element's lead stat and scale by purity.
    - **Size grows outward.** Visible clusters are 3 acupoints in the inner band, 5 in the
      middle band and 8 in the outer band. Hidden clusters are smaller on average (Formulas
      C), and inner ones are at most `inner_cluster_size_max`.
    - **Border gaps are filled.** The gap between two sectors holds clusters as well as its
      bridges: one inner, one middle and one outer, so all three gaps of a sector read alike.
    - **Region capacity.** Each region holds at most `region_capacity` acupoints. A hidden
      cluster that does not fit moves to the rim, which has no limit. An inner hidden cluster
      cannot move, so it shrinks to the room left, down to `cluster_size_min`.
    - **Stronger, not poorer.** A shrunk cluster keeps its full value: the premium and the
      per-acupoint caps of Formulas F are multiplied by n_rolled ÷ n, so its acupoints may
      pass the normal E_small and E_notable (user decision 2026-11-05).
    - **Big clusters go to the rim.** A hidden cluster of `rim_cluster_size_min` or more takes
      a rim region first, with one link, so more of them fit outside.
    - **The map must be drawable.** All of a cluster's links lie on one region's boundary, and
      a later cluster stays on one side of an earlier one in that region. So the base map has
      a drawing with no crossing edges. Requirements are under UI Requirements.

**What the player cannot do:** refund or respec; open a hidden acupoint; see or open a locked
variant sector; unseal by paying
points; choose or edit what fills an open cluster; see an open cluster's content before its
story moment, even in Visible mode.

### States and Transitions

| Subject | State | Becomes | When | Guard |
|---|---|---|---|---|
| Cluster | Hidden | Unsealed | Its one condition fires | Sealed kind; realm minimum met; not already unsealed |
| Cluster | Hidden | Pending | Its one condition fires below the gate realm | Sealed kind; realm minimum not met; a Meridian Seal key, if used, is consumed |
| Cluster | Pending | Unsealed | The character reaches the gate realm | Automatic; no further input |
| Cluster | Hidden | Awaiting fill | A story moment unseals it | Open kind; per-realm allowance left; chosen by rule 10 |
| Cluster | Awaiting fill | Unsealed | The fill is recorded | Always completes (LLM or template pool) |
| Cluster | Unsealed | (stays) | Never goes back | Unsealing is permanent for the life |
| Acupoint | Closed | Open | The player spends 1 point | Rule 3; its cluster, if any, is Unsealed |
| Acupoint | Open | (stays) | Never closes | No refund, no respec |
| Capability | Not held | Held | Its notable is opened | Sealed cluster only; held for the rest of the life |
| Variant sector | Locked | Unlocked | The root gains the variant (Spiritual Roots) | Automatic; never goes back |

A hidden, pending or awaiting-fill cluster's acupoints, and a locked sector's, are Closed and cannot
be opened.

### Interactions with Other Systems

All interfaces are provisional where the other GDD does not exist yet.

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Spiritual Root | in | purity per element, base element count (rule 3, 4), owned variants with purities (variant sectors, rule 20) | Spiritual Root |
| Character Stats | out | modifiers {source, stat, value}; the character's capability set (held capability ids); the tree never computes a stat | Character Stats (stat keys and their meaning; storage of the capability set) |
| Realms & Bottlenecks | in | the highest level reached (points_total, Formulas A) and the ladder constants (bands, great breakthrough bonuses, shares); the realm (realm minimum, budgets). Its `level_gained`, `stage_reached` and `breakthrough_succeeded` events trigger the recompute | Realms |
| Event Engine | in | effects "unseal this cluster" and "story moment: unseal an open cluster", both gated by the budget file; the existing "grant a point" effect | Event Engine (gating); this GDD (what the effects do) |
| Item DB | in | Meridian Seal key items bound to a cluster | Item DB (item kind); this GDD (what the key does) |
| Cultivation Techniques | in | a cultivation technique's list of clusters it can unseal, and active-seasons tracking | Cultivation Techniques (record); this GDD (the rule) |
| LLM Game Master | out/in | fill request out; fill reply in; validated by this GDD's budget | this GDD (budget and schema); LLM Game Master (transport) |
| World Database | out | "cluster unsealed" events and recorded fills, searchable by player and cluster | World Database |
| NPC Builds | in/out | allocation and clusters unsealed at generation | NPC Builds (generation); this GDD (cluster rules) |
| Combat | none direct | only the stat modifiers above | — |
| Capability hosts (Magic treasures in Artifact Refining, Cultivation Techniques, Time & Turn, Alchemy, Spirit Herbs & Spirit Fields [Linh Thảo & Linh Điền], Talismans, Formations, Spirit Beasts, Travel & Map, Event Engine, Realms, Spiritual Root, Character Stats; the capability-to-host list is in Dependencies) | out | the character's capability set, which each host reads; each host implements the rule change behind its capabilities | this GDD (catalogue and when one is held); each host system (the behaviour) |
| Guidance Layer / Debug Terminal / Game UI | out | map with silhouettes and hints, visibility mode, "an unsealed cluster has unopened acupoints" goals | Guidance Layer |
| Save/Load | out | the per-life state of rule 15 and the fill records | Save/Load |

## Formulas

Values are in **W**, a common power unit: 1 W = the value of +1% attack. An acupoint's
(huyệt) power is the weighted sum of its modifiers (formula F1). All values marked "guess"
need a bot run (`tools/balance/autoplay.gd`, `tools/balance/npc_cohort.gd`) before
they are trusted. Rounding is half away from zero everywhere. **Point shares are
computed in integer arithmetic, never with float `round()`**: `0.35 * 90` is
31.499999999999996 in IEEE floats, so a float implementation would round the
Deity Transformation (Hóa Thần) advance to 31 instead of 32 and give 565 points at level
300 instead of 566.
The shares are stored as integer percents (`pct_trung` 15, `pct_hau` 25, `pct_dai` 35)
and `share(p, B) = floor((p·B + 50) / 100)`.

### A. Points

The points_total formula is defined as:

`points_total(L) = pts_birth + (L − 1) + Σ_i bonus_i(L) + pts_event`

where, for each realm i with levels [lo_i, hi_i], N_i = hi_i − lo_i + 1, its own bonus
B_i and the next realm's bonus B_next:

`bonus_i(L) = [L ≥ lo_i]·(B_i − share(p_d, B_i)) + [L ≥ t_i]·share(p_t, B_next) + [L ≥ h_i]·share(p_h, B_next) + [L ≥ hi_i]·share(p_d, B_next)`

with `t_i = lo_i + floor(N_i/3)` (first level of the middle stage [trung kỳ]) and
`h_i = lo_i + floor(2·N_i/3)` (first level of the late stage [hậu kỳ]). Qi Refining (Luyện
Khí) has no entry term.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| L | int | 1–300 | calculated | Highest level ever reached (a level lost later never takes points back) |
| pts_birth | int | 2 | data file | Points at birth |
| lo_i, hi_i | int | Qi Refining 1–39, Foundation Establishment (Trúc Cơ) 40–79, Core Formation (Kết Đan) 80–129, Nascent Soul (Nguyên Anh) 130–199, Deity Transformation 200–300 | data file | Realm level bands (provisional; Realms & Bottlenecks [Cảnh Giới & Bình Cảnh] owns them) |
| B_i | int | Foundation Establishment 15, Core Formation 25, Nascent Soul 40, Deity Transformation 60; after Deity Transformation 90 (placeholder) | data file | Great breakthrough bonus |
| p_t, p_h | int (percent) | 15, 25 | data file (`pct_trung`, `pct_hau`) | Middle-stage and late-stage shares of the next bonus (extra) |
| p_d | int (percent) | 35 | data file (`pct_dai`) | Great perfection (đại viên mãn) share of the next bonus (advance, deducted from the breakthrough) |
| share(p, B) | int | 0–B | calculated | `floor((p·B + 50) / 100)`: half rounds up, integer arithmetic only |
| t_i, h_i | int | e.g. Qi Refining 14 and 27, Foundation Establishment 53 and 66 | calculated | First level of the middle and late stages |
| pts_event | int | 0+ | calculated | Event grants, +1 each |
| points_total | int | 2–566 (+ events) | calculated | Points earned in the life |

**Output Range:** 2 at level 1 to 566 at level 300, plus events; never decreases.

| Point | Level | Total |
|---|---|---|
| Qi Refining great perfection | 39 | 51 |
| Foundation Establishment early stage (sơ kỳ) | 40 | 62 |
| Foundation Establishment great perfection | 79 | 120 |
| Core Formation early stage | 80 | 137 |
| Core Formation great perfection | 129 | 216 |
| Nascent Soul early stage | 130 | 243 |
| Nascent Soul great perfection | 199 | 357 |
| Deity Transformation early stage | 200 | 397 |
| Deity Transformation great perfection | 300 | 566 |

**Example:** Level 60 (Foundation Establishment middle stage):
- 2 at birth + 59 from levels.
- Qi Refining bonuses: 2 + 4 + 5.
- Foundation Establishment entry: 15 − 5 = 10.
- Foundation Establishment middle stage: share(15, 25) = floor(425/100) = 4.
- Total: **86**.

### A2. Acupoint value scale

Lives earn about 3.6× more points than the old stage ladder (51 vs 14 at Qi Refining's
end), so acupoint values are scaled down to keep a typical life's tree power unchanged.
The power target is set on the mix of acupoints a typical life opens, not on the map's own
mix. The map is 54% meridian roads (kinh lộ), but a life spends only about 25–40% of its
points on them.

The value_scale formula is defined as:

`k_pts = points_total(anchor) / points_old(anchor)` ; `w̄_target = w̄_old / k_pts` ; `w̄_route = h_r·H0 + (1 − h_r − ν_r)·S0 + ν_r·N0` ; `P_LK = points_total(anchor)·w̄_route` ; `w̄_map = (n_hw·H0 + n_sm·S0 + N_vis·N0) / (n_hw + n_sm + N_vis)`

S0, N0 and H0 are chosen as clean values. The launch values (S0 = H0 = 1.2, N0 = 8) are a
design choice, not an output.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| anchor | — | Qi Refining great perfection | constant | The most common life end |
| points_old, points_total | int | 14, 51 | calculated | Old and new points at the anchor |
| k_pts | float | 3.64 | calculated | Points multiplier |
| S0_old, N0_old | float | 5 W, 22 W | calculated (from `meridian_tree.json`) | Old small and notable values |
| w̄_target | float | 2.07 W | calculated | Target mean W per point: 7.55 / 3.64 |
| S0, N0 | float | 1.2 W, 8 W | data file | Base small and notable values |
| H0 | float | 1.2 W | data file (`huyet_value_highway`) | Value of a meridian road acupoint, junctions (hội huyệt) included. Kept as its own key so it can move without touching Formulas D and F |
| h_r | float | 0.25–0.40 (guess) | calculated (bot) | Meridian road share of a 51-point route |
| ν_r | float | 0.10–0.16 (guess) | calculated (bot) | Notable share of that route |
| n_hw, n_sm, N_vis | int | 430, 280, 80 | calculated (H) | Visible meridian road acupoints, small cluster acupoints and notables (no keystones, no dantian [Đan Điền]) |
| w̄_route | float | 1.87–2.27 W | calculated | Mean W per point on a route |
| w̄_map | float | 1.89 W | calculated | Mean over the visible map; a data lint (AC-KMD-06), not the power target |
| P_LK | float | 95–116 W | calculated | Tree power at Qi Refining's end |
| Keystone | float | ≥ 50 W | data file | Keystones keep full strength; not rescaled |

**Meridian road stat pool.** Meridian roads and junction acupoints carry generic stats
(`road_stats`, rule 21), border ring acupoints included. They never carry
`breakthrough_chance`, so the extra meridian roads do not touch the tree's breakthrough
ceiling. They no longer carry cultivation speed or resistances, so the power figures below,
measured with element stats, need a new bot run (AC-KMD-07).

**Output Range:**
- Tree power at Qi Refining's end is about 95–116 W, with a median of about 102–109 W
  (guess). The target is about 106 W; AC-KMD-07's bot window is 90–125 W.
- The lever is notables reached: each notable is ±6.8 W against a small acupoint. With
  H0 = S0, swapping a meridian road step for a small acupoint changes nothing.
- w̄_map = 1.89 W (it was 2.11 on the old map composition).
- At Deity Transformation great perfection tree power is about 1,100–1,300 W (guess), 1.7–2.0× the old
  ladder's 650 W: a deliberate tilt toward later realms.
- Without the rescale it would be about 4,270 W (6.6×): 566 × 7.55.
- **Keystones are outside this budget, by design.** A keystone's 50 W is its positive side;
  its drawback is authored with it and is part of its net value.
  - A sector keystone beeline costs 22 points for about 75 W (21 meridian road acupoints at 1.2 W plus the
    keystone's 50 W), about 3.4 W per point against the 2.07 target. The drawback must
    bring the net back toward the target when keystone content is authored (Open Question 4).
  - **Center keystone (intended).** The Five Elements Cycle (Ngũ Hành Luân Chuyển) costs 1
    point at d 1 and needs a 5-element (five elements [Ngũ Hành], Legendary) root, so it is
    a deliberate jump of about +47% of a Qi Refining tree for the rarest root. It is the one place the tree hands power over
    cheaply, an accepted tension with Pillar 3: the root itself is the price. AC-KMD-07
    leaves 5-element lives out of its median.

**Example:**
- **Efficient 51-point route:** 13 meridian road acupoints, 30 small acupoints and 8
  notables, so h_r = 0.255 and ν_r = 0.157. Power is 43 × 1.2 + 8 × 8 = **115.6 W**.
- **Greedy bot route:** 20 meridian road acupoints, 25 small and 6 notables. Power is
  45 × 1.2 + 48 = **102.0 W**.
- **Weak route:** 20 meridian road acupoints, 26 small and 5 notables. Power is 46 × 1.2 + 40 =
  **95.2 W**.
- **Map lint:** (710 × 1.2 + 80 × 8) / 790 = 1,492 / 790 = **1.889 W**.
- **What the values mean:** a typical small acupoint is +1.2% attack (or +0.5% cultivation
  speed); a notable is +8% attack.

### B. Band depth and reach cost

Depth d(x) is the route length from the dantian, computed once by BFS when the map is
generated.

| Band | Depth | Contents |
|---|---|---|
| Core | 0–1 | The dantian, 5 gates (junctions), and the center keystone next to the dantian |
| Inner | 2–6 | 3 radial meridian roads per sector, the K1 ring (junctions at d 5, ring acupoints at d 6) and 2 small clusters per sector; inner hidden clusters link at d 3–7 |
| Middle | 7–14 | Radials, 2 fork-and-merge connectors and 4 base clusters per sector, and the middle bridge clusters; K2 junctions at d 14 |
| Outer | 15–22 | Outer meridian roads: radials, the K2 ring (d 15–16), braids (d 17–18) and the rim ring K3 (junctions at d 20, ring acupoints at d 21–22). Also 2 base clusters per sector and the outer bridges. Outer hidden clusters link at d 15–22; keystones sit at d 22 |
| Expansion | beyond the launch map's deepest acupoint | Reserved, empty at launch |

Band depths are measured on visible acupoints and cluster link points. A hidden cluster's
interior extends outward from its link, so outer cluster acupoints can sit at up to d ≈ 37.

d(x) is computed once per content release and frozen. A later release may link only to
existing outer acupoints and must not shorten any existing acupoint's depth. The content build
rejects a release that would.

The reach_cost formula is defined as:

`C_reach(x | O) = min_{o ∈ O} dist(o, x)` ; `C_enter(K) = min_i C_reach(link_{K,i} | O) + 1` ; `C_clear(K) = C_enter(K) + n_K − 1`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| O | set | ≥ {Đan Điền} | calculated | The character's open acupoints |
| x | id | any acupoint | calculated | Target acupoint |
| dist(o, x) | int | 0–30 | calculated | Unopened acupoints on the shortest route from o to x, x included |
| link_{K,i} | id | visible acupoint | data file | The visible acupoint that entry i of cluster K attaches to (1–3 per cluster) |
| n_K | int | 3–15 | data file (C) | Cluster size |
| C_* | int | 1–37 | calculated | Points needed |

**Output Range:**
- From a fresh character, an outer cluster costs 16–23 points to enter and 18–37 to
  clear.
- An inner cluster costs 4–8 to enter and 6–22 to clear.
- Once an outer meridian road is open to the link, an outer cluster costs only n_K.

**Example:**

| Life | Points | Reach |
|---|---|---|
| Qi Refining great perfection | 51 | Its focus sector's inner band and 2–3 of its 4 middle clusters (d ≈ 10–13), about 6–8 notables. The rare inner hidden cluster (n ≤ 6: 6–13 points) fits. A keystone beeline (22 points) is possible but costs 43% of the life |
| Foundation Establishment great perfection | 120 | Every cluster and both keystones of one focus sector (about 98 points, guess; the whole sector is 27 + 62 + 52 = 141 acupoints, but most of its meridian roads need not be walked), and a second sector's inner band (about 12 points) |
| Core Formation early stage | 137 | The focus sector's outer meridian road is open to d 20, so a 9-acupoint outer cluster costs 9 of the 17 new points |
| Nascent Soul+ | 243–566 | Enough for many clusters; unsealing, not points, is the limit |

### C. Hidden cluster generation

All draws are made once, with the tree seed, when a content release is generated
(rule 19).

The cluster_generation formulas are defined as:

`n = clamp(round(N(μ_n, σ_n)), n_min, n_max)` ; `k = clamp(floor(n / huyet_per_notable), 1, 3)` ; `location = inner if U < share_inner, else outer` ; `kind = sealed if U' < share_sealed, else open` ; `gate = realm_by_size(n) − (1 if inner else 0)`

where realm_by_size is Foundation Establishment for n ≤ g1, Core Formation for n ≤ g2,
otherwise Nascent Soul. An inner cluster's gate is one realm lower, so it can reach Qi
Refining.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| N_clusters | int | 75 | data file | Hidden clusters in the launch release |
| μ_n, σ_n | float | 8, 2 | data file | Size distribution (rule 21; were 9, 2.5) |
| n_min, n_max | int | 3, 12 | data file | Size clamp (rule 21; n_max was 15). An inner cluster also stops at `inner_cluster_size_max` (5) and at its region's room |
| huyet_per_notable | int | 5 | data file | One notable per full 5 acupoints |
| share_inner | float | 0.15 | data file | Chance a cluster is inner |
| share_sealed | float | 0.667 | data file | Chance a cluster is sealed |
| g1, g2 | int | 6, 10 | data file | Size thresholds for the realm gate |
| cap_min_n | int | 7 | data file | Smallest cluster that may carry a capability (outer only) |
| U, U' | float | 0–1 | calculated (seeded) | Uniform draws |

**Output Range:**
- E[n] = 8 before the inner limits. The launch seed's 75 clusters hold 524 acupoints.
- k: 1 notable with probability 0.58, 2 with 0.41, 3 with 0.014. That's about 108
  hidden notables (16% density).
- About 11 inner and 64 outer clusters. A seed is accepted only if the inner count is
  9–14 **and** at least 25 outer sealed clusters have n ≥ cap_min_n (one for each
  capability). Otherwise the next seed is tried. This avoids outlier maps without
  fixing a count.
- Outer gates: about 10 Foundation Establishment, 36 Core Formation and 18 Nascent Soul
  clusters. Inner gates: about 2 Qi Refining, 6 Foundation Establishment and 3 Core
  Formation.
- Capabilities: 25 of 75 clusters (a third of all, half of the sealed ones). They are
  placed on outer sealed clusters with n ≥ 7, about 36 of which qualify.

**Example:** A draw of 11.37 rounds to n = 11:
- k = floor(11/5) = 2.
- U = 0.62 makes it outer, so its gate is Nascent Soul.
- U' = 0.31 makes it sealed, so it may carry a capability.

### D. Cluster premium and node value

The cluster_premium formula is defined as:

`P = P_min + (P_max − P_min)·(w_d·t_d + w_n·t_n)` ; `t_d = (d_entry − d_lo)/(d_hi − d_lo)` ; `t_n = (n − n_min)/(n_max − n_min)` ; `E_small = S0·P` ; `E_notable = N0·P`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P_min, P_max | float | 1.25, 1.75 | data file | Premium bounds (cap of +75% by user decision) |
| w_d, w_n | float | 0.5, 0.5 | data file | Weight of reach vs size; w_d + w_n = 1 |
| d_entry | int | 4–23 | calculated (B) | Depth of the cluster's entry acupoint: min_i d(link_{K,i}) + 1, taken from the shallowest link when the cluster has 2–3 links. AC-KMD-12 speaks of the link's depth, AC-KMD-29 of d_entry |
| d_lo, d_hi | int | 4, 23 | data file | Entry depth bounds |
| S0, N0 | float | 1.2, 8 W | data file (A2) | Base small and notable values |
| E_small, E_notable | float | 1.5–2.1, 10–14 W | calculated | Target value per hidden acupoint |

**Output Range:**
- P runs from 1.25 to 1.75.
- After spiritual root (linh căn) scaling (rule 4, up to ×1.5), the strongest hidden notable is
  8 × 1.75 × 1.5 = 21 W, well below the weakest keystone (50 W).

**Example:** An outer cluster, entry at d 19, n = 9:
- t_d = 15/19 = 0.789 and t_n = 0.5.
- P = 1.25 + 0.5·0.645 = **1.5724**.
- E_small = 1.887 W and E_notable = 12.58 W.
- An inner cluster at d 5 with n = 5 gets P = 1.305.
- Tests use exact values with `assert_near`, not the rounded figures shown here.

### E. Capability notables

A capability's worth depends heavily on the build, so it is not priced in W. Each
catalogue entry has a **tier**, and the tier sets how much of the notable's stat value
stays alongside the capability.

The capability_notable formula is defined as:

`E_cap_notable = f_tier · E_notable`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| f_tier | float | T1 0.5, T2 0.25, T3 0 | data file | Stat share kept by a capability notable |
| tier | enum | T1, T2, T3 | data file (catalogue) | T1 narrow, T2 build-shaping, T3 survival or breakthrough |
| E_notable | float | 10–14 W | calculated (D) | The notable's normal value |
| E_cap_notable | float | 0–7 W | calculated | Stats on the capability notable |

Initial tiers (guess):
- **T1:** #10 Divided Furnace Flame (Đan Hỏa Phân Lô) and #19 Child of Fortune (Khí Vận
  Chi Tử).
- **T3:** #5 Soul Leaves the Body (Linh Hồn Xuất Khiếu), #22 Last Radiance (Hồi Quang Phản
  Chiếu) and #23 Burning Life to Break Through (Thiêu Thọ Phá Cảnh).
- **T2:** every other entry, until a bot measurement places it.

A measurement compares the metric with and without the capability: combat power (chiến lực) for combat
capabilities, the system's own output for the others (e.g. alchemy throughput). The
capability's attack equivalent then sets the tier: below half a notable is T1, up to one
notable is T2, and above that or unmeasurable is T3. The initial T2 entries above are
guesses made before any measurement.

**Output Range:** 0–7 W of stats; the capability itself is not scaled by the spiritual root.

**Example:** A T2 capability on the n = 9, P = 1.5724 cluster carries 0.25 × 12.58 =
**3.14 W** of stats, e.g. +3.1% attack.

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
- **At most one of #22 and #23 acts per realm step.** A character holding both chooses
  which to use for that realm.

The breakthrough_guard formula is defined as:

`q_desp = min(2q, q + Δ_desp, q_max − τ_a, q + δ_max·(1 − q − τ_a)/(1 − S))` ; attempt chance `= q_desp + τ_a` ; `ι_23 = 0 if I ≥ failure_insight_cap, else min(failure_insight_pp, failure_insight_cap − I)` ; `q_retry = min(q, (δ_max − ι_23)/(1 − S))` ; `S'_22 = 1 − (1 − S)·(1 − q_desp − τ_a)/(1 − q − τ_a)` ; `S'_23 = S + q_retry·(1 − S) + ι_23·(1 − q_retry)·F_0` ; `max(S'_22, S'_23) ≤ S + δ_max`

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
| S | float | 0 ≤ S < 1 (S_guard is capped at 0.95) | calculated (S_guard, Realms & Bottlenecks GDD, Formulas H) | Lower bound on success per realm before capabilities, from the pill attempts made and the pills held (targets ≈ 0.30 baseline / ≈ 0.70 player edge) |
| q | float | 0.01–0.95 (0.01–0.90 when τ_a = 0.05) | calculated (`CultivationRules`) | Chance per attempt, including failure insight, without τ_a |
| τ_a | float | 0 or τ = 0.05 | calculated (τ from Realms & Bottlenecks, Formulas, `crafting_talismans.json`) | The breakthrough talisman on the attempt #22 acts on: τ if the realm step's one talisman is used on that attempt, else 0. If the q_max clamp cuts the talisman short, τ_a is the part that applies, so q + τ_a ≤ q_max |
| q_desp | float | q to q_max − τ_a | calculated | #22's chance for the attempt without τ_a, clamped by the guard; the attempt succeeds with q_desp + τ_a |
| ι_23 | float | 0 or 0.02 (0 to `failure_insight_pp`) | calculated (`breakthrough.failure_insight_pp` 2 and `failure_insight_cap` 4 pp, Realms & Bottlenecks) | The insight #23's extra roll would add if it failed: 0 if the step's current insight I is at the cap, else min(failure_insight_pp, failure_insight_cap − I) |
| F_0 | float | 0–1 | calculated | Chance of failing every attempt in the step except the one after the extra roll; used only to state the carry exactly (the guard assumes F_0 = 1) |
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
  This is deliberate. Capabilities are earned, rare (one per outer sealed cluster) and bounded,
  and the player-facing text says "up to ×2, capped".
- **Baseline includes the tree.** The 0.30 / 0.70 targets are measured with the tree's own
  `breakthrough_chance` already counted (AC-KMD-50 runs the bot with it), so the tree as
  the bot allocates it (about 0.02 of the cap) sits inside the targets; a maxed tree is
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

### F. Fill budget

The F1 power formula is defined as:

`power(h) = Σ_stats w[stat]·value` (all values ≥ 0)

The cluster budget formula is defined as:

`B = P·[(n − k)·S0 + (k − c)·N0 + c·f_tier·N0]`

The per-acupoint cap formulas are defined as:

`power(small) ≤ tol·E_small` ; `power(notable) ≤ E_notable` ; `power(capability notable) ≤ f_tier·E_notable`

For a cluster shrunk by region capacity (rule 21), E_small and E_notable are multiplied by n_rolled ÷ n, so the cluster keeps its value in fewer, stronger acupoints (user decision 2026-11-05).

The compounding cap formula is defined as:

`Σ_cluster value_c ≤ cap9_c·(n/9)^γ`

The lifespan cap formula is defined as:

`Σ_cluster lifespan_years ≤ φ_r·L_r`

The tree-wide ceiling formula is defined as:

`Σ_tree breakthrough_chance ≤ tree_breakthrough_cap`

The final scale formula is defined as:

`scale_all = min(1, B / Σ power)`

Sealed clusters are authored to the same numbers. The validator checks them in tests, in
**sealed mode**, which differs from the normal mode in one way: the cluster's one
capability notable (c = 1) is allowed, and it is exempt from step 3's rule that every
acupoint has a stat and from the capability ban. Its stats are held to f_tier·E_notable, so
a T3 capability notable has none. Every other rule and step applies unchanged.
Open-cluster fills run in the normal mode (c = 0) and are clamped at runtime.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| w[stat] | float | 0.7–140 | data file (`meridian_fill.json`) | Weight per unit of each allowed stat (table below) |
| c | int | 0–1 | data file | Capability notables in the cluster (always 0 for open clusters) |
| tol | float | 1.2 | data file | Spread allowed on one small acupoint |
| cap9_c | float | table below | data file | Per-cluster cap on a compounding stat for n = 9 |
| γ | float | 0.5 | data file | Compounding caps grow sublinearly with size |
| φ_r | float | 0.10 (Qi Refining–Core Formation), 0.05 (Nascent Soul+) | data file | Ceiling on a cluster's summed lifespan_years, as a share of realm lifespan (a whole n = 15 budget would otherwise allow 22%) |
| tree_breakthrough_cap | float | 8 (guess) | data file | Ceiling, in percentage points, on the summed breakthrough_chance of every Meridian Map (Kinh Mạch Đồ) acupoint in a life; applies to NPCs too |
| L_r | int | 120–2000 | data file (`cultivation_realms.json`) | Realm lifespan: the player's realm at fill time; the gate realm for sealed clusters |
| B | float | 10.7–67 W | calculated | Cluster budget (10.7 W is the smallest capability cluster; 13 W the smallest without one) |

Stat weights (W per displayed unit). The base notables in `meridian_tree.json` are the
reference. All weights are guesses until checked by the bot.

| Stat | w | Stat | w |
|---|---|---|---|
| attack_pct, defense_pct, linh_luc_pct | 1.0 | alchemy_success | 2.7 |
| khi_huyet_pct | 1.2 | breakthrough_chance | 5 |
| than_thuc_pct, artifact_power_pct | 1.3 | khi_van, ngo_tinh | 5 |
| tam_ma_resist_pct, stealth | 1.5 | refining_success | 2.0 |
| dan_doc_resist_pct | 1.6 | formation_power_pct | 1.0 |
| cultivation_speed_pct | 2.2 | dan_doc_decay | 8 |
| herb_growth_pct | 0.9 | density_bonus | 140 |
| mission_income_pct | 0.7 | field_plots | 20 |
| lifespan_years | 300 / L_r per year | | |

**Precision.** Values are held as whole counts of their precision unit (+12.3% attack is
123 units of 0.1), so every floor is exact:
- 0.1: every `_pct` stat, `stealth`, `alchemy_success`, `refining_success`,
  `breakthrough_chance` and `lifespan_years` (in years).
- 0.01: `khi_van`, `ngo_tinh`, `dan_doc_decay` and `density_bonus`.
- 1: `field_plots` (Character Stats confirms the unit). One plot is 20 W, so it fits only
  a notable with E_notable ≥ 20 W, and only when the cluster's compounding cap allows at
  least 1 (n ≥ 9). At launch values E_notable is at most 14 W (Formulas D), so no
  acupoint can carry a plot: step 6 removes it wherever a fill puts it.

Compounding caps per cluster at n = 9 (the old values ÷ k_pts; guesses):
- cultivation_speed_pct 4
- breakthrough_chance 0.5
- ngo_tinh 1
- khi_van 1
- alchemy_success 3
- density_bonus 0.04
- dan_doc_decay 0.8
- field_plots 1

`lifespan_years` has its own per-cluster ceiling, φ_r·L_r, and `breakthrough_chance` also
has the tree-wide ceiling above, because its per-cluster cap alone lets many clusters add
up. The tree's `breakthrough_chance` is bounded by both `tree_breakthrough_cap` and Realms
& Bottlenecks' character-wide ceiling on the summed per-attempt extras (its Formulas C),
whichever binds first; Realms & Bottlenecks owns that q-extras ceiling and its value.

**Plot price (user decision 2026-11-04, cross-GDD review 04g F11).** `field_plots` is
priced at 20 W, not 10 W. At the root-free median one plot is worth about +0.06 S at a
breakthrough, which is about 3.8 pp of q (Realms & Bottlenecks Formulas D: fields are a
build). At `breakthrough_chance`'s 5 W per pp that is about 19 W, rounded to 20 W. At
10 W a plot bought odds at about twice the rate of `breakthrough_chance` and sat outside
`tree_breakthrough_cap`.
- **Effect on fills.** 20 W is over every acupoint's power cap at launch values
  (tol·E_small ≤ 2.52 W, E_notable ≤ 14 W, a capability notable ≤ 7 W), so step 6 removes
  any plot and fills the acupoint from the theme's pool. No cluster over-spends: B does
  not depend on w, and the replacement stat is held to the same caps. The tree therefore
  gives no plots unless N0·P reaches 20 W (N0 ≥ 11.43 at P_max), which is outside the N0
  safe range (7.0–9.1). The `field_plots` compounding cap of 1 stays as the guard for
  that case.
- **Bot calibration.** The bot's calibration runs (Realms & Bottlenecks AC-CG-30 and
  AC-CG-60, and this GDD's AC-KMD-50) take no `field_plots` acupoint. Fields are a build
  outside Realms & Bottlenecks' 0.30 / 0.70 targets.

The tree's `herb_growth_pct`, `alchemy_success` and `lifespan_years` also count toward
Character Stats' character-wide bonus ceilings (its rule 14 and Formulas I), which they
share with techniques, items and pills (user decision 2026-11-04, cross-GDD review G1).
A fill can therefore add value the sheet later clamps; the fill validator prices it at
full W, as for any other stat.

Excluded from fills (never allowed):
- rule flags (single_artifact, safe_failure, dan_doc_no_penalty);
- cultivation_speed_per_element_pct and lifespan_pct;
- travel_speed_pct, alchemy_yield and co_duyen_pct;
- pill_effect_pct, artifact_attack_pct and artifact_defense_pct;
- element_affinity_pct, than_thuc_cost_pct and mi_luc.

Forbidden shapes: a negative value, a capability, more than 2 stats on one acupoint, a
notable count other than k, and fewer than 3 distinct stats across the cluster.

Repair order (every repair is recorded on the fill and shown to the player). Values
are held to their stat's precision (table above) and are only ever rounded down, so
rounding can lower a fill's power but never raise it.
1. **Shape.** The fill is slot-indexed: the request lists the cluster's n slots by id,
   each with its role (small or notable) taken from the map, and the reply holds one
   entry per slot id.
   - Drop entries whose slot id is unknown or repeated; fill missing slots from the
     theme's pool.
   - A slot's role always comes from the map, never from the reply. A reply that marks a
     different set of notables is ignored on that field, and the mismatch is recorded.
     So notables stay on the slots farthest from the entry (rule 6).
   - Remove capability and rule text.
2. **Keys.** Replace a disallowed or flag key with a stat from the theme's pool.
3. **Signs and size.** Remove a negative, zero or sub-unit value (below one precision
   unit of its stat, such as +0.04% attack). If an acupoint is left with no stat, it gets
   one from the pool, in whole units, so a replacement passes steps 6–9 like any other
   value.
4. **Stat count.** On an acupoint with more than 2 stats, keep the 2 with the highest power.
5. **Variety.** While the cluster has fewer than 3 distinct stats, the lowest-power
   duplicate stat is replaced from the pool.
6. **Per-stat cap.** Clamp each value to cap_power / w, where cap_power is the acupoint's
   power cap (tol·E_small or E_notable), rounded down to the stat's precision. If that is
   below one unit (`field_plots` on any acupoint at launch values), the stat is removed and replaced
   from the pool as in step 3.
7. **Acupoint cap.** Scale any acupoint over its power cap down to the cap.
8. **Compounding caps.** Scale down each stat that breaks its compounding cap, across
   the cluster, and scale `lifespan_years` down to φ_r·L_r. A stat whose cluster cap,
   rounded down to its precision, is below one unit (`field_plots` when n < 9, if a plot
   passed step 6) is removed
   and replaced from the pool as in step 3.
9. **Budget and quantize.** One loop, so the total never exceeds B:
   - Let B_rest = B, with every acupoint unfixed.
   - Scale the unfixed acupoints by min(1, B_rest / their summed power), taken from their
     step-8 values on every pass, then round every value down to its precision. A value
     that rounds to 0 is dropped.
   - An acupoint left with no stat is **fixed**: it gets one precision unit of an uncapped
     stat, meaning one with no compounding cap and no lifespan ceiling (for example
     `attack_pct`). The choice, in order:
     - the acupoint's own highest-power uncapped stat, if the cluster does not have it yet;
     - else the pool's first uncapped stat the cluster does not have yet;
     - else its own highest-power uncapped stat, or the pool's first if it had none.

     That is within every cap: one unit of an uncapped stat passes the per-acupoint cap
     (steps 3 and 6), and it has no cluster cap to break. Subtract the fixed acupoint's
     power from B_rest and repeat on the unfixed acupoints.
   - **Variety after the loop.** If the cluster now has fewer than 3 distinct stats
     (because a dropped stat was the only copy), add one precision unit of an uncapped stat
     the cluster lacks (highest power first, then the pool's order). Repeat until there are
     3 distinct stats. A unit goes on an acupoint only when all of these hold:
     - the acupoint has exactly one stat;
     - its power plus the unit stays within its power cap (steps 6–7): a small at 2.2 W
       against a 2.264 W cap cannot take a 0.1 W unit;
     - the cluster's **actual** total power plus the unit stays at or below B. Use the
       cluster's real total, not B_rest: B_rest ignores the unfixed acupoints, which were
       already scaled to fit it.

     If no acupoint qualifies, the pool fill is used. So AC-KMD-35's "at least 3 distinct
     stats" holds for every result without breaking B or an acupoint cap.
   - Each pass fixes at least one acupoint, so the loop ends within n passes. If B_rest
     drops below 0, the reply is unrepairable and the pool fill is used.
10. **Record.** Record a repair only when a value changed.

Scaling and rounding down only lower power. The two places a value is raised, the fixed
acupoint and the variety unit of step 9, each add one unit of an uncapped stat. The fixed
acupoint cannot break a cap (it has no other stat). The variety unit is added only where
the acupoint cap and B still hold. So every cap from steps 6–8 and B still hold, with no
tolerance. A reply that needs no scaling is changed only by its own rounding,
because step 3 already removed sub-unit values.

A reply the validator cannot repair (invalid JSON, or no usable acupoint at all) is
replaced entirely by a pool fill.

**Output Range:** 13 W (n 3, inner, P 1.25) to 67 W (n 15, k 3, P 1.75) for a cluster
without a capability. The lowest B of a capability cluster is about 10.7 W (n 7, outer at
d_entry 16, T3). A clamped fill never exceeds B and has no negatives. Per notable,
lifespan_years is at most about 4.7% of L_r (14 W ÷ 300), because the per-acupoint cap binds first; per
cluster it is held to φ_r·L_r (12 years at L_r = 120 in Qi Refining through Core Formation), where a
whole n = 15 budget would otherwise allow 22%.

**Example:** n = 9, k = 1, c = 0, P = 1.5724, so B = 1.5724·(8·1.2 + 8) = **27.67 W**.
A valid fill:

| Acupoint | Content | Power each | Power total |
|---|---|---|---|
| 4 small | +2% attack | 2.0 W | 8.0 W |
| 2 small | +1.5% vitality (khí huyết) | 1.8 W | 3.6 W |
| 2 small | +0.8% cultivation speed | 1.76 W | 3.5 W |
| 1 notable | +8% attack, +4% defense | 12 W | 12 W |

- Total 27.12 W, within B.
- Every small is ≤ 2.264 W (tol·E_small) and the notable is ≤ 12.58 W.
- No repair is needed.
- Cultivation speed sums to 1.6, under its cap of 4.

### G. NPC unseal chance

The npc_unseal_chance formula is defined as:

`a(r, e) = a_max[r] · (base_step + min(e, 1)·(max_step − base_step)) / max_step` ; `p(r, e) = 1 − (1 − a)^(1/M_r)` per eligible sealed cluster, and p = 0 when M_r = 0

An NPC rolls p once per eligible sealed cluster when it is generated, in an order
shuffled with the NPC's own seed so that no cluster id is favoured. A cluster is eligible
if the NPC has its element and its gate is at or below the NPC's realm. Only
element-matching clusters roll, so the real holder share sits below a; a is a ceiling. An NPC
holds at most 1 cluster below Nascent Soul, and at most 2 from Nascent Soul.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| a_max[r] | float | 0.02, 0.10, 0.18, 0.22, 0.22 | data file | Share of NPCs at realm r holding any cluster, at edge 1 (guess) |
| base_step, max_step | float | 0.30, 0.70 | data file (`character_edges.json`) | The edge curve shared with Progression Edges |
| e | float | 0–1+ | calculated (Progression Edges) | NPC edge score |
| M_r | int | ≈ 1, 12, 38, 50, 50 | calculated from the map | Sealed clusters with gate ≤ realm r |
| a | float | 0–0.22 | calculated | Chance the NPC holds at least one cluster |
| p | float | 0–0.02 | calculated | Chance per eligible cluster |

**Output Range:**
- With a mean NPC edge of about 0.25 (guess), about 1% / 6% / 10% / 13% / 13% of NPCs
  per realm hold a cluster, all under the 15% target.
- Among holders, the combat power gain is about 2% at the A2 scale, against a target under
  15%.

**Example:** A Core Formation NPC at e = 1: a = 0.18, so p = 1 − 0.82^(1/38) = **0.0052** per
cluster. Holders mostly hold one.

**Capabilities on NPCs.** An NPC holding a capability notable gets that capability's
`npc_effect` from a closed set:
- `chien_luc_mult` up to ×1.10;
- `p_step_add` up to +0.05, with the NPC's p_step still clamped to max_step 0.70;
- `survive_once`;
- `none`: the capability shows in the World Database and story context only.

### H. Visible tree sizing

The visible_tree formula is defined as:

`V = core + 5·(inner_s + middle_s + outer_s) + 5·bridge_pair` ; `inner_s = R·5 + 2·m1 + Σn_inner` ; `middle_s = R·8 + 2 + Σn_middle` ; `outer_s = R·(a3 − a2) + 2·m2 + 2 + 2·m3 + Σn_outer + ks` ; `bridge_pair = m1 + m2 + m3 + n_bm + n_bo` ; `k_vis(n) = clamp(floor(n / huyet_per_notable_visible), 1, 3)` ; `ν = N_vis / V`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| core | int | 7 | data file | The dantian, 5 gates (each a junction of degree 4) and the center keystone, which sits next to the dantian at d 1 |
| R | int | 3 | data file (`radials_per_sector`) | Radial meridian roads per sector, from the gate to the rim |
| a1, a2, a3 | int | 5, 14, 20 | data file (`ring_anchor_depths`) | Depth of the K1, K2 and K3 ring junctions on every radial |
| m1, m2, m3 | int | 2, 3, 3 | data file (`ring_interior`) | Ring acupoints between two junctions, at depths anchor + min(i, m + 1 − i): K1 at 6, 6; K2 at 15, 16, 15; K3 at 21, 22, 21 |
| Σn_inner, Σn_middle, Σn_outer | int | 2×3, 4×5, 2×8 | data file (`base_cluster_slots`) | Visible base clusters per sector, in the L–C and C–R gaps |
| n_gi, n_gm, n_go | int | 3, 5, 6 | data file (`base_cluster_slots`) | Visible clusters in each border gap, beside its bridges (rule 21) |
| ks | int | 2 | data file | Sector keystones, at d 22 |
| n_bm, n_bo | int | 5, 5 | data file (`base_cluster_slots`) | Middle and outer bridge cluster per border (4 small + 1 notable each) |
| inner_s, middle_s, outer_s | int | 27, 62, 52 | calculated | Visible acupoints per sector per band |
| bridge_pair | int | 18 | calculated | Visible acupoints per border |
| k_vis(n) | int | 1–3 | calculated | Notables in a visible cluster (`huyet_per_notable_visible` = 4) |
| R·5, R·8 | int | 15, 24 | calculated | Radial acupoints in the inner (d 2–6) and middle (d 7–14) bands. Fixed by the band edges, not by a1 and a2; changing a ring anchor moves ring acupoints only |
| N_vis | int | 80 | calculated | Visible notables |
| ν | float | 0.100 | calculated | Share of notables among visible acupoints |
| V | int | 772 | calculated | Visible acupoints |

Per sector (junctions are meridian road acupoints and are counted in that column):

| Band | Meridian roads | Junctions | Base clusters (count × size, notables) | Keystones | Total |
|---|---|---|---|---|---|
| Inner d 2–6 | 19: radials 3 × 5; K1 2 segments × 2 at d 6 | 3: K1 junctions at d 5 | 2 × 4 (3 + 1) → 2 | 0 | **27** |
| Middle d 7–14 | 26: radials 3 × 8; 2 connectors × 1 (d 9, d 10) | 7: 4 connector ends (d 8–11), 3 K2 junctions at d 14 | 4 × 9 (7 + 2) → 8 | 0 | **62** |
| Outer d 15–22 | 32: radials 3 × 6; K2 2 × 3 (d 15, 16, 15); 2 braids × 1 (d 18); K3 2 × 3 (d 21, 22, 21) | 6: 3 braid junctions at d 17, 3 K3 junctions at d 20 | 2 × 9 (7 + 2) → 4 | 2 at d 22 | **52** |
| Sector | 77 | 16 | 8 clusters, 62 acupoints, 14 notables | 2 | **141** |

Per border: 8 meridian road acupoints (the K1, K2 and K3 border segments of 2, 3 and 3
acupoints), a middle bridge cluster of 5 and an outer bridge cluster of 5, so **18**
acupoints and 2 notables. That makes 5 crossings per border.

**Revised 2026-11-05 (rule 21).** The per-sector table above and the edge counts below still
show the 2026-11-03 split; these totals replace them.

**Output Range:**
- V = 442 + 5·56 + 50 = **772**:
  - 430 meridian road acupoints including the 5 gates, 85 of them junctions;
  - 65 visible clusters holding 330 acupoints (**75 notables**): per sector 56 in base and gap
    clusters, and 10 bridges of 5;
  - 11 keystones and the dantian.
- ν = 75 / 772 = **0.097**.
- Hidden clusters hold 524 acupoints on the launch seed, so the map holds **1,296** (this
  document rounds it to about 1,300).
- Mean degree on the launch seed is about 2.30, the bottom of `degree_avg_window`, because rim
  clusters take one link.
- Edges:
  - The skeleton has 506 edges: meridian roads, core and keystones.
  - Visible clusters add about 340 internal edges and about 100 entry links, for a total
    of about 946. The mean degree is about **2.36** (guess).
  - The full map, with every cluster unsealed, also comes to about 2.36 (guess).

**Example:**
- **One sector, band by band:**
  - Inner: 15 + 4 + 8 = 27.
  - Middle: 24 + 2 + 36 = 62.
  - Outer: 18 + 6 + 2 + 6 + 18 + 2 = 52.
  - Total: 141.
- **One border:** 2 + 3 + 3 + 5 + 5 = 18.
- **Late lives:** a Deity Transformation great perfection life (566 points) could open 71%
  of the visible tree, so late lives are defined by the hidden clusters they unsealed.
- **Clearing one sector:** every cluster and both keystones of a sector cost about 98
  points (guess): about 34 meridian road acupoints, 62 cluster acupoints and 2 keystones.
  That is far less than the sector's 141, because most of its meridian roads never need
  walking.

### H2. Variant sector sizing

Each of the eight variants owns one sector of 30 acupoints, built only from existing pieces:
a chain of meridian road acupoints, cluster A of 4, cluster B of 9, and the apex cluster X of
9 with its authored apex notable. Notable counts follow `k_vis`, so A has 1, B has 2 and X
has 2 (one of them the apex). Layout is fixed: A is a Chain, B and X are Rings. Entry counts
are set by this layout, not drawn from `entry_count_weights`.

The variant_sector formulas are defined as:

`n_sector = n_road + n_A + n_B + n_X` ; `k_sector = k_vis(n_A) + k_vis(n_B) + k_vis(n_X)` ; `d(y) = min_i ( d(L_i) + 1 + dist(e_i, y) )` ; `C_enter = e` ; `C_clear = e + n_sector − 1`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_road | int | 8 | data file (`variant_road_count`) | Road acupoints: R1–R8 in a spur; F1–F4 and M1–M4 in a chord |
| n_A, n_B, n_X | int | 4, 9, 9 | data file (`variant_cluster_slots`) | Cluster sizes. X is the apex cluster |
| k_vis(n) | int | 1, 2, 2 | calculated (H) | floor(n / 4) notables per cluster |
| n_sector | int | 30 | calculated | 8 + 4 + 9 + 9 |
| k_sector | int | 5 | calculated | Notables per sector: 4 ordinary and 1 apex |
| e | int | 3–13 | data file (`variant_entry_depth`) | Depth of the sector's first acupoint. The host sits at e − 1 |
| d(L_i) | int | 2–12 | calculated | Depth of host i, a visible acupoint, so its depth is frozen |
| dist(e_i, y) | int | 0–12 | calculated | Steps inside the sector from entry acupoint i to y |
| C_enter, C_clear | int | 3–42 | calculated | Points from a fresh character (Formulas B) |

**Layout (fixed for every variant):**

| Origin | Roads | A (4, Chain) | B (9, Ring) | X (9, Ring) |
|---|---|---|---|---|
| Spur (6 variants, 1 host link) | Chain R1–R8. R1 is the entry acupoint | 1 entry at R3 | 2 entries at R5 and R6 | 1 entry at R8. Apex and the 2nd notable on its two farthest nodes |
| Chord (Thunder, Darkness; 2 host links) | Spine F1–F2–F3–F4–M4–M3–M2–M1. F1 and M1 are the entries | 1 entry at F2 | 2 entries at M2 and M3 | 2 entries at F4 and M4. Apex on the farthest node |

Cluster entries are internal links onto road acupoints, which become degree 3 (non-junction,
allowed). No sector acupoint has degree 4. Edges per sector: a spur has 7 + 1 + (3 + 1) +
(9 + 2) + (9 + 1) = **33**, and a chord has 7 + 2 + (3 + 1) + (9 + 2) + (9 + 2) = **35**.

**Depth span of each class (e = entry depth):**

| Class | Spur | Chord (both entries at e) |
|---|---|---|
| Road acupoints | e … e+7 | e … e+3 |
| Cluster A | e+3 … e+6 (notable at e+6) | e+2 … e+5 (notable e+5) |
| Cluster B | e+5 … e+9 (both notables at e+9) | e+2 … e+6 (notables e+6) |
| Cluster X | e+8 … e+12 (apex and 2nd notable at e+12) | e+4 … e+8 (apex e+8, 2nd notable e+7) |

| Variant | e | Roads | A | B | X (apex) | C_enter | C_clear |
|---|---|---|---|---|---|---|---|
| Wind (Phong) | 3 | 3–10 | 6–9 | 8–12 | 11–15 (15) | 3 | 32 |
| Blood (Huyết) | 4 | 4–11 | 7–10 | 9–13 | 12–16 (16) | 4 | 33 |
| Void (Hư Không) | 5 | 5–12 | 8–11 | 10–14 | 13–17 (17) | 5 | 34 |
| Chaos (Hỗn Độn) | 7 | 7–14 | 10–13 | 12–16 | 15–19 (19) | 7 | 36 |
| Light (Quang), Ice (Băng) | 8 | 8–15 | 11–14 | 13–17 | 16–20 (20) | 8 | 37 |
| Thunder (Lôi), Darkness (Ám) | 9–13, one value per chord | 9–16 | 11–18 | 11–19 | 13–21 (17–21) | 9–13 | 38–42 |

No sector acupoint is deeper than 21, so nothing reaches the expansion band.

**Entry links per origin:**

| Variant | Links | Host (existing acupoint) | Host pool per sector |
|---|---|---|---|
| Wind, Blood, Void | 1 each, in a sector drawn from `rng("variant:"+id)`, distinct hosts | Radial acupoint at d 2, 3 and 4 respectively | 3 per depth |
| Chaos | 1, in a sector drawn from `rng("variant:hon_don")` | K1 ring acupoint at d 6, non-junction | 4 |
| Light, Ice | 1, in Fire and Water | Radial at d 7 (L7, C7, R7). Fallback d 8 (then e = 9), non-junction | 3 (+2) |
| Thunder | 2, one in Fire and one in Metal, both at depth e − 1 | Non-junction road acupoint of the middle band, d 8–12 | 13: L 4, C 3, R 4, plus the two connector acupoints |
| Darkness | 2, one in Earth and one in Water | Same | 13 |

- **Totals:** 10 host links, all on non-junction road acupoints that go to degree 3. No
  junction or keystone gains a link, so the degree rules hold.
- **Link capacity (estimate, not simulated):** the middle band has 19 non-junction road
  acupoints per sector (d 7–13) against about 10 of base demand. With variant demand added,
  the ratios are Fire and Water 1.58, Earth and Metal 1.73 and Wood 1.90, all above
  `link_capacity_margin` 1.25. The inner band has 45 radial hosts at d 2–4 against about 31 of
  demand, about 1.45.

**No band skipping.** Sector depth is BFS depth with every sector unlocked, and it equals the
depth with only that sector unlocked:
- a single-entry spur cannot shorten anything;
- a chord's route from host to host is 9 edges and its hosts are at equal depth, so
  |d(L_F) − d(L_M)| = 0 ≤ s + 2 = 9 holds;
- B's links (R5, R6; M2, M3 differ by 1) and X's links (F4, M4 differ by 0) also satisfy
  |Δd| ≤ s + 2.

Reaching a sector acupoint at depth d therefore costs at least d points, with all sectors
open or none. If a host shortage forces different chord entries, |e_F − e_M| ≤ 2
(`variant_chord_depth_gap`). A chord is a modest route: because the dantian is always open, it
never beats the base route at e = 9, ties at e = 10 and saves at most 3 points at e = 13.

**Totals:**

| Quantity | Value |
|---|---|
| Acupoints | 8 × 30 = **240**: 64 roads, 136 cluster smalls, 40 notables (8 of them apex) |
| Edges | 6 × 33 + 2 × 35 = **268** (258 internal, 10 host links) |
| Mean degree of a sector's own nodes | spur 2.17, chord 2.27 |
| Full map, every sector unlocked | 772 + 524 + 240 = **1,536** acupoints; mean degree about **2.3** |
| Notables in the full map | 75 + about 90 + 40 = about 205 (guess) |
| Visible map | V = 772, unchanged by sectors. Sectors are reported separately; `tree_size_target` still means the base map |

**Output Range:** n_sector is always 30. e runs 3–13, d(y) runs 3–21 and C_clear runs 32–42. A
fresh Qi Refining life (51 points) can clear any sector and keeps 9–19 points. A Foundation
Establishment life (120 points) keeps 78–88.

**Example:**
- **Wind:** host Earth radial C2 (d 2), so e = 3. Roads sit at d 3–10, A at 6–9, B at 8–12 and
  X at 11–15, with the apex at d 15. C_clear = 3 + 29 = 32.
- **Thunder, e = 11:** Fire and Metal hosts at d 10. Roads at d 11–14, A at 13–16, B at 13–17
  and X at 15–19, with the apex at d 19. C_clear = 40.

### H3. Variant sector value

Variant clusters are priced at the lowest hidden premium, `variant_premium` = P_min = 1.25,
with the base values S0, N0 and H0. Formula D gives every hidden cluster P ≥ 1.25, so E_small,
E_notable and the budget of clusters A and B hold at any entry depth by construction. X, with
its apex, passes because n = 9 gives P ≥ 1.375. Roads are priced like smalls. The apex is 1.1 × an ordinary notable.

The variant_value formulas are defined as:

`W_road = H0·P_v` ; `W_small = S0·P_v` ; `W_notable = N0·P_v` ; `W_apex = a_apex·N0·P_v` ; `W_sector = n_road·W_road + n_small·W_small + (k_sector − 1)·W_notable + W_apex` ; `W_scaled(p) = W_sector·(0.5 + p/100)` ; `G(p) = W_scaled(p) − w̄_target·n_sector` ; `g_QR = G / P_LK` ; `g_FE = G / (w̄_target·120)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P_v | float | 1.25 | data file (`variant_premium`) | Equal to P_min |
| H0, S0, N0 | float | 1.2, 1.2, 8 W | data file (A2) | Base values |
| a_apex | float | 1.1 | data file (`variant_apex_ratio`) | Apex notable over an ordinary notable |
| n_small | int | 17 | calculated | Cluster smalls: 3 + 7 + 7 |
| p | int | derived 8–80, innate 10–100 | calculated (Spiritual Roots D2) | Variant purity |
| w̄_target | float | 2.07 W | calculated (A2) | Main-map W per point |
| P_LK | float | 106 W | calculated (A2) | Qi Refining tree power target at 51 points |
| W_sector | float | 88.5 W | calculated | Unscaled sector value |
| G(p) | float | −10.8 to +70.65 W | calculated | Gain over spending the same 30 points on the main map |

| Class | Count | Unscaled W | p 43 (×0.93) | p 50 (×1.0) | p 80 (×1.3) | p 100 (×1.5) |
|---|---|---|---|---|---|---|
| Road | 8 | 1.5 | 1.40 | 1.50 | 1.95 | 2.25 |
| Small | 17 | 1.5 | 1.40 | 1.50 | 1.95 | 2.25 |
| Notable | 4 | 10.0 | 9.30 | 10.0 | 13.0 | 15.0 |
| Apex | 1 | 11.0 | 10.23 | 11.0 | 14.3 | 16.5 |
| Sector | 30 | 88.5 | 82.3 | 88.5 | 115.05 | 132.75 |

Unscaled, A = 14.5 W, B = 30.5 W, X = 31.5 W and the roads 12 W. 88.5 / 30 = **2.95 W per
point**, against 2.56–2.9 for visible clusters, about 3.07 for a hidden n = 9 cluster and 2.07
for the main-map average.

**Checks:**

| Check | Limit | Value | Result |
|---|---|---|---|
| Small ≤ tol·E_small | 1.8 (strictest, at P_min) | 1.5 | pass |
| Notable ≤ E_notable | 10.0 at P_min | 10.0 | pass, no slack |
| Apex ≤ E_notable at the shallowest apex (Wind, X entry d 11, P = 1.467) | 11.74 | 11.0 | pass; a 12 W apex would fail |
| Cluster budget B = P·[(n−k)·S0 + k·N0] | A 14.5, B 30.5, X ≥ 35.8 | 14.5, 30.5, 31.5 | pass |
| Compounding caps | H4 | at the cap | pass |
| Ceiling keys | none allowed | none used | pass |
| Scaled value | below the 50 W keystone floor | 16.5 W at most | pass |

**Output Range:**
- W_scaled runs 51.3 W (derived p 8) to 132.75 W (innate p 100).
- At purity 20 or below a sector pays less than the main map (break-even is 20.17). That follows
  the existing rule that purity decides which regions pay.
- These are prices before rounding. Flooring each authored value to its precision takes
  0.4–1.6 W off a sector, and the sheet's single floor (Character Stats Formulas I) takes another
  1.6–4.2 W off a fully open one, as it does for any acupoint.

**Gain over the same 30 points on the main map (62.1 W):**

| Purity | W_scaled | G | g_QR | g_FE |
|---|---|---|---|---|
| 8 | 51.3 | −10.8 | −10.2 % | −4.3 % |
| 43 (derived mean) | 82.3 | +20.2 | +19.1 % | +8.1 % |
| 50 (innate mean) | 88.5 | +26.4 | +24.9 % | +10.6 % |
| 70 | 106.2 | +44.1 | +41.6 % | +17.8 % |
| 80 (derived maximum) | 115.05 | +52.95 | +50.0 % | +21.3 % |
| 100 | 132.75 | +70.65 | +66.7 % | +28.4 % |

- **Origin changes only cost.** Clearing a sector in Qi Refining leaves 17–19 of 51 points for
  innate lives, 15 for Chaos, 14 for Light and Ice and 9–13 for Thunder and Darkness. The road
  to a host is treated as shared with the main map.
- **Qi Refining power is accepted (user decision 2026-11-04).** About 4.3 % of lives hold an
  innate variant and reach about +25 % tree power at mean purity, and +41.6 % at purity 70. The
  rare root is the price, as with the center keystone. Depth cannot change this, since the same
  30 points earn the same value anywhere. No sector carries `breakthrough_chance`, so the macro
  targets are untouched. AC-KMD-07 leaves these lives out of its median.
- The variant's role bonus (Spiritual Roots Formulas E, about 14–15 W at purity 47–50) comes on
  top.

**Example:** Thunder at purity 47 scales by 0.97: W_scaled = 88.5 × 0.97 = 85.8 W, a gain of 85.8
− 62.1 = +23.7 W, or +22.4 % of a Qi Refining tree, plus 14.1 W from its role line.

### H4. Variant stat themes

Every stat below has a Meridian weight (Formulas F). Excluded: `travel_speed_pct`,
`co_duyen_pct`, `breakthrough_chance`, the keys under character-wide ceilings
(`herb_growth_pct`, `alchemy_success`, `lifespan_years`) and `ngo_tinh`, which feeds the
q-extras ceiling. Every cluster holds at least 3 distinct stats and every acupoint at most 2.

| Variant | Lead | Stat 2 | Stat 3 | W per stat (of 88.5) | Units at purity factor 1.0 | Apex notable (≤ 11.0 W) |
|---|---|---|---|---|---|---|
| Thunder | attack_pct | artifact_power_pct | linh_luc_pct | 42.0 / 29.0 / 17.5 | +42.0 % / +22.3 % / +17.5 % | attack_pct +11.0 |
| Darkness | stealth | than_thuc_pct | defense_pct | 30.5 / 39.0 / 19.0 | +20.3 / +30.0 % / +19.0 % | stealth +7.3 |
| Chaos | cultivation_speed_pct (capped) | linh_luc_pct | khi_huyet_pct | 23.3 / 48.7 / 16.5 | +10.6 % / +48.7 % / +13.7 % | cultivation_speed_pct +2.0, linh_luc_pct +6.6 |
| Light | tam_ma_resist_pct | formation_power_pct | than_thuc_pct | 42.0 / 29.0 / 17.5 | +28.0 % / +29.0 % / +13.5 % | tam_ma_resist_pct +7.3 |
| Ice | dan_doc_resist_pct | dan_doc_decay (capped) | defense_pct | 55.2 / 16.8 / 16.5 | +34.5 % / +2.1 / +16.5 % | dan_doc_decay +0.4, dan_doc_resist_pct +4.8 |
| Wind | defense_pct | mission_income_pct | stealth | 42.0 / 29.0 / 17.5 | +42.0 % / +41.4 % / +11.7 | defense_pct +11.0 |
| Blood | khi_huyet_pct | attack_pct | defense_pct | 42.0 / 29.0 / 17.5 | +35.0 % / +29.0 % / +17.5 % | khi_huyet_pct +9.1 |
| Void | khi_van (capped) | mission_income_pct | than_thuc_pct | 13.3 / 30.0 / 45.2 | +2.66 / +42.9 % / +34.8 % | khi_van +0.50, than_thuc_pct +6.5 |

The Units column is before flooring; the Apex column is floored. The eight lead stats are
distinct. Wind carries Escape Arts (Độn Thuật) type stats and Void
carries Fortune (Khí Vận) type stats; their travel speed and fortune roles live in Spiritual
Roots Formulas E. Chaos and Void lead by theme, not by share, because compounding caps bind; Darkness's stealth is
held below its Stat 2 on purpose.

**Which piece carries which** (standard map for Thunder, Light, Wind and Blood; S1, S2 and S3 are
the table's three stats):

| Piece | Carries |
|---|---|
| Roads (8) | S1 |
| A (4) | smalls S1, S2, S3; notable S2 |
| B (9) | smalls S1×3, S2×2, S3×2; notables S1 and S3 |
| X (9) | smalls S1×2, S2×3, S3×2; notable S2; apex S1 |

**Overrides:**
- **Darkness (stealth held to 30.5 W):** roads and the apex carry stealth. A: smalls stealth,
  than_thuc, defense; notable than_thuc. B: smalls than_thuc×3, defense×2, stealth×2; notables
  than_thuc and defense. X: smalls defense×3, than_thuc×2, stealth×2; notable than_thuc.
- **Chaos (cultivation speed at its cap, 10.6 % in all):** roads carry linh_luc. A: smalls
  khi_huyet×3; notable cultivation speed 2.6 plus linh_luc 4.28 W. B: smalls khi_huyet×4, linh_luc×3;
  each notable cultivation speed 2.0 plus linh_luc 5.6 W. X: smalls khi_huyet×4, linh_luc×3;
  notable cultivation speed 2.0 plus linh_luc 5.6 W; apex cultivation speed 2.0 plus linh_luc
  6.6 W.
- **Ice:** roads carry dan_doc_resist. A: smalls defense×3; notable decay 0.5 plus resist 6.0 W.
  B: smalls defense×4, resist×3; each notable decay 0.4 plus resist 6.8 W. X: smalls defense×4,
  resist×3; notable decay 0.4 plus resist 6.8 W; apex decay 0.4 plus resist 7.8 W.
- **Void (khi_van at its cap, 2.66 in all):** roads carry than_thuc. A: smalls mission×2,
  than_thuc; notable khi_van 0.66 plus than_thuc 6.7 W. B: smalls mission×4, than_thuc×3;
  notables (khi_van 0.5 plus mission 7.5 W) and (khi_van 0.5 plus than_thuc 7.5 W). X: smalls
  mission×4, than_thuc×3; notable khi_van 0.5 plus mission 7.5 W; apex khi_van 0.5 plus
  than_thuc 8.5 W.

**Compounding-cap check (unscaled; caps are cap9·(n/9)^0.5):**

| Stat | Variant | A (n = 4) | B | X | Cap per cluster |
|---|---|---|---|---|---|
| cultivation_speed_pct | Chaos | 2.6 | 4.0 | 4.0 | 2.66 / 4 / 4 |
| khi_van | Void | 0.66 | 1.00 | 1.00 | 0.66 / 1 / 1 |
| dan_doc_decay | Ice | 0.5 | 0.8 | 0.8 | 0.53 / 0.8 / 0.8 |

No other stat in a sector has a compounding cap.

**Example:** Thunder's A cluster at purity factor 1.0 holds smalls of +1.5 % attack, +1.1 %
artifact power and +1.5 % spiritual power, and a notable of +7.6 % artifact power (9.88 W at
1.3 W per point, floored to precision under the 10.0 W cap).

#### Topology generator

Every draw comes from a sub-stream `rng(tag)`, seeded with `hash64(tree_seed, tag)`. Use
FNV-1a in GDScript, not the engine's `hash()`, which is not promised stable across
versions.
- Tags are `"sector:s"`, `"border:b"` and `"cluster:id"`.
- Formulas C keeps its own stream.

**G1. Core.**
- The dantian (d 0) links the 5 gates and the center keystone, all at d 1.
- Each gate links L2, C2 and R2 of its sector, so it is a junction of degree 4.
- The dantian has degree 6 and is the one exemption from the degree limit.

**G2. Radials, forks and merges.**
- Each sector has radials L, C and R, each a chain from d 2 to d 20.
- The seed draws a chirality bit χ_s:
  - χ = 0: connectors C8 → x (d 9) → L10 and R9 → y (d 10) → C11.
  - χ = 1 is the mirror: C8 → R10 and L9 → C11.
- A connector is a fork, because it leaves one radial, and a merge, because it joins the
  next radial deeper down. Its acupoint takes the depth between its ends, so it never
  shortens a radial.
- Braids L17 – b (d 18) – C17 and C17 – b′ (d 18) – R17 are always present.
- Junctions per radial for χ = 0 (mirrored for χ = 1):
  - C: 1, 5, 8, 11, 14, 17, 20;
  - L: 1, 5, 10, 14, 17, 20;
  - R: 1, 5, 9, 14, 17, 20.
- Spacing along radials and rings is 3–5 steps. Connectors and braids are 2 steps, by
  design.

**G3. Ring meridian roads.**
- Ring junctions sit at d 5, 14 and 20 on every radial.
- A segment's i-th interior acupoint sits at anchor + min(i, m + 1 − i):
  - K1 (m 2): 6, 6;
  - K2 (m 3): 15, 16, 15;
  - K3 (m 3): 21, 22, 21.
- Segments run L–C and C–R inside a sector, and from R of sector s to L of sector s + 1
  across each border.
- K3 acupoints stay at d 22 or less for m3 ≤ 4.
- Junction degrees:
  - K1 and K2 junctions: 4;
  - K3 junctions: 3;
  - C17: 4;
  - connector ends, L17 and R17: 3.

**G4. Keystones.**
- On each in-sector K3 segment, the seed picks one of its two d 21 acupoints as host. The
  keystone attaches there at d 22, with degree 1.
- The d 22 ring acupoint never hosts a keystone, which would sit at d 23. It never hosts a
  visible cluster link either, because the entry would sit at d 23.

**G5. Regions, tags and neighbours.**
- **Sector regions:** each gap (L–C and C–R) has five regions:
  - inner: gate to K1;
  - middle-low: K1 to the connector;
  - middle-high: connector to K2;
  - outer-low: K2 to the braid;
  - outer-high: braid to K3.

  Beyond K3, the rim region holds hidden clusters only.
- **Border regions:** each border has middle, outer and rim regions, between R of sector s
  and L of sector s + 1.
- **Tags:**
  - Sector s: its radials, in-sector ring segments, connectors, braids and in-sector
    clusters.
  - Border b: its border ring segments and its bridge clusters.
- **Neighbours:** two clusters are neighbours if they share a region, or if their regions
  share a boundary meridian road segment.

**G6. Visible clusters.** Clusters are filled in sector order, inner band to outer, L–C gap
before C–R, then the borders.
- **Slots:**
  - each gap gets 1 inner cluster (n 3);
  - each gap gets 1 middle-low and 1 middle-high cluster (n 5);
  - each gap gets 1 outer cluster (n 8), in outer-low or outer-high as the seed picks;
  - each border gets a middle bridge and an outer bridge (n 5), placed first;
  - each border gets 1 inner (n 3), 1 middle (n 5) and 1 outer (n 6) cluster (rule 21).
- **Border inner region (added 2026-11-05):** each border also has an inner region, between
  R of sector s and L of sector s + 1, from the gates to K1.
- **Non-crossing wiring (added 2026-11-05):** a region keeps its open faces. A cluster takes
  its links from one face, which splits at those links, so a later cluster stays on one side.
- **Entries:** a double ring's entries stay on its outer ring; n ≤ 5 takes at most 2 entries.
- **Shape:**
  - A shape **supports** a cluster only when both hold. The test is made on the cluster
    itself: its n, its E, its role (a bridge uses the bridge-pair slots, any other cluster
    the E slots) and its k (`floor(n/4)` for a visible cluster, `floor(n/5)` for a hidden
    one). The same (shape, n, E) can therefore support a hidden cluster and not a visible
    one.
    - its entry slots exist for E (shape table);
    - for n ≥ 5, at least k non-entry nodes lie at least `notable_min_entry_dist` steps from
      every entry. Ring at n = 5 with E = 2 as a bridge pair (v0, v2) and with E = 3,
      Star at n = 5 with E = 3, and Crescent at n = 5 with E = 3, fail this, so they are
      not supported.
  - **Some shape always supports.** Chain supports every non-bridge cluster (with entries
    at v0–v2, the nodes v4 onward are at least 2 steps away: n − 4 ≥ k), and Crescent
    supports every bridge (n 5, E 2: v2 only, k = 1). So the fallback below never runs
    out. AC-KMD-66 checks it.
  - The theme's preferred shape is used with chance `shape_preferred_share` (0.6), if it
    supports n and E.
  - Otherwise the shape is drawn uniformly from the other shapes that support them.
  - Fallback order: Ring, then Crescent, then Chain, each only if it supports n and E.
    So a Ring bridge (n 5) falls back to Crescent.
- **Entries:**
  - E is drawn from `entry_count_weights` (1: 0.20, 2: 0.60, 3: 0.20), then set to
    E ← min(E, max(1, n − k − 1)).
  - Bridges have E = 2, one link on each side's radial. A bridge never links to a border
    ring acupoint, so the 5 crossings stay independent.
- **Link hosts:** a host must
  - lie on the region's boundary meridian road;
  - not be a junction;
  - have degree ≤ 2;
  - not already host a link;
  - not host a keystone.

  When E ≥ 2, the links go on two different boundary meridian roads where possible.
- **Notables:** take the k non-entry nodes farthest from their nearest entry, breaking ties
  by lower slot index. This meets AC-KMD-21 by construction. In addition, for n ≥ 5 every
  notable must be at least `notable_min_entry_dist` (2, guess) steps from its nearest
  entry, so the player pays for small acupoints first. The shape's "supports" test (above)
  guarantees this is satisfiable before a shape is chosen.
- **Local checks:**
  - **Depth fit:** every acupoint y, with `d(y) = min_i (d(L_i) + 1 + dist(e_i, y))`, lies in
    its band. Inner clusters sit at d 3–6, middle clusters and middle bridges at 7–14, and
    outer clusters and outer bridges at 16–22, because outer links start at d 15. For
    example, a 9-acupoint Chain with one entry spans 9 depths and fits neither band.
  - **Shortcut rule** (below).
  - **Distinct hosts.**
- **Failure:** re-draw up to `cluster_retry` (8) times; if every try fails, reject the
  seed.

**G7. Hidden clusters.**
- Size, k, location and kind come from Formulas C, then region capacity may shrink an inner
  cluster (rule 21).
- The authored catalogue supplies theme and sector. Each cluster is then wired as in G6:
  - inner clusters go to their sector's inner regions or its border inner region, with links
    at d 3–7;
  - outer clusters go to their sector's outer-low, outer-high or rim regions, or the
    matching border regions, with links at d 15–22;
  - regions are filled fewest-placed first, then by the seed, among regions with room;
  - a cluster of `rim_cluster_size_min` or more tries rim regions first, and a rim cluster
    takes one link.
- **Extra hosts allowed for hidden clusters only:**
  - small non-entry, non-notable acupoints of a visible cluster with internal degree ≤ 2;
  - degree-3 junctions (L17, R17 and the K3 junctions), which then reach degree 4.
- All links of one hidden cluster share one tag, so unsealing never adds a border
  crossing.
- **Outer link capacity (guess):**
  - Supply is about 200 slots: about 150 on meridian roads and about 50 on visible cluster
    acupoints.
    - Meridian roads: 26 non-junction outer acupoints per sector (12 radial, 6 K2 ring, 2 braid, 6 K3 ring)
      × 5 = 130, plus 6 per border × 5 = 30, minus the 10 keystone hosts = 150.
    - Visible cluster hosts are usable by hidden clusters only. Visible outer clusters
      cannot use hosts at d 19 or deeper, since their entry would leave no room below d 22.
    - The degree-3 junctions that hidden clusters may also use (L17, R17 and the K3 junctions:
      5 per sector, 25 in all) are extra headroom and are not counted in the 150.
  - Demand is about 158: about 30 visible entries and about 128 hidden ones.
  - The ratio is about 1.27, against `link_capacity_margin` 1.25: the margin is thin, so
    AC-KMD-67 reports it per seed.
  - This is checked before G7. Below 1.0 the seed is rejected; below the margin it is
    reported.
  - The same check runs per band for the inner and middle bands (hosts and demand counted
    the same way); it is reported only, since the inner and middle bands hold few hidden
    entries.
  - **Expansion capacity.** Rule 19 links new content to existing outer acupoints. The
    launch map leaves about 40–70 free outer slots (about 20–35 clusters at E = 2). A
    release that needs more may link new clusters to the previous release's outer
    clusters, which is allowed by rule 19 because those are existing acupoints, or must
    add its own meridian roads in the expansion band.

**Shortcut rule.** For every cluster with 2–3 entries, visible or hidden, and every pair of
its links:

`|d(L_i) − d(L_j)| ≤ s_ij + 2`

- s_ij is the route length in edges between entries e_i and e_j inside the cluster.
- The route from one link through the cluster to the other has s_ij + 2 edges. When that
  is never shorter than the depth gap it spans, frozen d is still a valid potential. BFS
  with any set of clusters unsealed then returns the same d for every visible acupoint.
- An unsealed 2-entry cluster is therefore a sideways loop, never an inward-to-outward
  tunnel.
- **Example:** links at d 15 and d 21 need s ≥ 4.

**G8. Global validation, repair and rejection.**
1. **Depths:**
   - Every meridian road acupoint's BFS d on the visible graph equals its template depth.
   - Every visible cluster lies in its band.
   - BFS with every hidden cluster unsealed gives the same d for every visible acupoint.
2. **Degree:**
   - every acupoint has degree ≤ 4, the dantian excepted;
   - only junctions reach 4.
3. **Average degree:**
   - Both the visible graph and the full graph must fall in `degree_avg_window`
     (2.30–2.60).
   - **Repair below the floor:** turn tree-shaped clusters into a Ring (one more edge
     each) in fill order, then Rings into a Double ring, until the floor is met. Above the
     ceiling, apply the reverse.
   - A converted shape must still be one that supports the cluster (G6). Each entry stays
     on its host and moves to the new shape's slot of the same index (shape table order);
     the conversion is skipped if that slot does not exist or already has internal degree 3.
     The local checks (depth fit, notables, shortcut rule with the new s_ij, distinct
     hosts) are re-run after each conversion, and a conversion that fails any of them is
     skipped.
   - With every shape a tree and a mean E of 1.7, the visible graph would reach about
     2.25, so the repair can matter.
4. **Two routes:**
   - For every neighbour pair, route 1 is the rule-3 route between the entry sets, with
     interior length ℓ1. It may not cross either cluster's interior.
   - Route 2 avoids route 1's interior, except the link of a 1-entry cluster. It must
     exist with ℓ2 ≥ ℓ1 + `route2_min_extra` (2).
   - Routes run on the visible graph. Hidden clusters take part only as endpoints.
   - **Repair:** re-draw the later cluster's links up to `cluster_retry` times.
5. **Crossings:**
   - Each border has exactly 5 border-tagged components, each touching both neighbouring
     sectors.
   - No edge joins two different sector tags.
6. **Seed loop:**
   - Any remaining failure moves to the next seed (seed + 1), up to `seed_max_attempts`
     (64).
   - A seed is accepted only when both the Formulas C checks and these checks pass.
   - If no seed passes, the content build fails.

**G9. Variant sectors.** Runs after G8 accepts a seed, and uses only the sub-streams
`rng("variant:"+id)`. No accept or reject test reads it, so the base seed, counts and
accepted-seed ranges never change. A failure here stops the content build and never moves the
seed loop.
1. **Order:** catalogue order, Wind, Blood, Void, Thunder, Darkness, Chaos, Light, Ice.
2. **Hosts:** per Formulas H2. Every host is a distinct road acupoint, not a junction, a keystone
   or a cluster entry, with degree 2 before the link. If a pool is empty, the fallbacks run in
   this order, and when they are used up the content build fails:
   - a drawn sector (Wind, Blood, Void, Chaos): the next sector in cycle order;
   - Light and Ice: a d 8 host, so e = 9;
   - a chord: the next value of e in 9–13, then a depth gap up to `variant_chord_depth_gap`.
3. **Ids and tags:** variant acupoints have the integer id 100000 + 100·slot + n (slot 0–7 in
   catalogue order; n 0–29: roads, then A, B and X), so ids still sort, and the tag
   `variant:<id>`, and no sector tag. So G8's crossing check does not read them: a chord is not a border crossing, and
   the 5 crossings per border stand. They are not regions, neighbours or link slots for G5–G7.
4. **Checks:**
   - every acupoint has degree ≤ 4, the dantian excepted, and only junctions reach 4;
   - BFS with every sector unlocked gives the same d for every base acupoint;
   - each sector's depths match Formulas H2, with that sector alone unlocked and with all
     unlocked;
   - no edge joins two variant tags;
   - the full graph's mean degree is reported against `degree_avg_window`; outside it is a
     warning. The sector layout is fixed, so there is no repair.
5. **Hash:** variant data, with the 10 host links, has its own golden hash, so the base map hash
   of AC-KMD-08 is unaffected.

**Shape templates.**
- Internal degree is at most 3.
- Entry slots are taken in the order listed. A slot is skipped if it doesn't exist at this
  n or has internal degree 3.
- Notables follow G6.

| Shape | Graph on n nodes | Min n | Internal edges | Entry slots (E = 1 / 2 / 3) | Bridge pair |
|---|---|---|---|---|---|
| Ring | Cycle v0…v(n−1) | 4 | n | v0 / +v1 / +v(n−1) | v0, v⌊n/2⌋ |
| Star | Hub (degree 3) and 3 arms; n − 1 split as evenly as possible, a1 ≥ a2 ≥ a3 | 4 | n − 1 | tip of arm 3 / +tip of arm 2 / +node 1 of arm 1 | tips of arms 3 and 2 |
| Chain | Path v0…v(n−1) | 3 | n − 1 | v0 / +v1 / +v2 | use Crescent |
| Crescent | Path v0…v(n−1) | 3 | n − 1 | v0 / v0 and v(n−1) / +v1 | v0, v(n−1) |
| Fork | Stem of s = max(1, ⌊(n−1)/3⌋) nodes, a fork node, and 2 branches splitting the rest | 5 | n − 1 | v0 / +v1 / +node 1 of branch 2 | v0, tip of branch 2 |
| Loop-with-tail | Tail of t = max(1, ⌊n/3⌋) nodes on a cycle of n − t nodes, meeting at junction j | 5 | n | tail tip / +a cycle neighbour of j / +the tail node after the tip | as E = 2 |
| Double ring | Junctions u and w (degree 3) joined by 3 paths with interiors p1 ≥ p2 ≥ p3, where p3 = 0 at n = 6 and 1 otherwise | 6 | n + 1 | path-1 node next to u / +path-2 node next to u / +the path-3 node | path-1 node next to u, path-2 node next to w |
| Cross (H form) | Centres c1–c2 (degree 3) with 2 arms each; c1 takes the shorter arms. A 4-arm cross would need a degree-4 acupoint that isn't a junction | 6 | n − 1 | tip of a c1 arm / +the other c1 tip / +tip of c2's shorter arm | a c1 tip and a c2 tip |

Preferred shapes per theme (placeholder; game-designer confirms with Open Question 4):

| Shape | Themes |
|---|---|
| Ring | Way of Formations (Trận Đạo), Heart State (Tâm Cảnh) |
| Double ring | Body Guarding (Hộ Thể), Spiritual Power (Linh Lực) |
| Star | Divine Sense (Thần Thức) |
| Chain | Sword Intent (Kiếm Ý), Escape Arts (Độn Thuật) |
| Crescent | Longevity (Thọ Nguyên), Fortune (Khí Vận) |
| Fork | Artifact Refining (Luyện Khí), Beast Taming (Ngự Thú) |
| Loop-with-tail | Vitality (Khí Huyết), Way of Alchemy (Đan Đạo) |
| Cross | Way of Talismans (Phù Đạo), Spirit Fields (Linh Điền) |

### Parameter keys

There is one data key per parameter, used in both the rules and the formulas.

| Symbol | Data key | Value |
|---|---|---|
| — | `tree_size_target` | ≈ 1,300 (772 visible + about 525 hidden) |
| — | `road_stats` | khi_huyet_pct, linh_luc_pct, khi_huyet_pct, than_thuc_pct, in rotation |
| — | `region_capacity` | inner 6, border_inner 6, middle_low 7, middle_high 9, outer_low 12, outer_high 12, border_middle 14, border_outer 18; the rim has no limit |
| — | `inner_cluster_size_max` | 5 |
| — | `rim_cluster_size_min` | 7 |
| H0 | `huyet_value_highway` | 1.2 W |
| R | `radials_per_sector` | 3 |
| a1, a2, a3 | `ring_anchor_depths` | 5, 14, 20 |
| m1, m2, m3 | `ring_interior` | 2, 3, 3 |
| — | `base_cluster_slots` | per sector: inner 2×3, middle 4×5, outer 2×8; per border: inner 3, middle 5, outer 6, middle bridge 5, outer bridge 5 |
| — | `huyet_per_notable_visible` | 4 |
| — | `entry_count_weights` | E = 1 / 2 / 3: 0.20, 0.60, 0.20 |
| — | `shape_preferred_share` | 0.6 |
| — | `route2_min_extra` | 2 |
| — | `degree_avg_window` | 2.30–2.60 |
| — | `link_capacity_margin` | 1.25 |
| — | `cluster_retry` | 8 |
| — | `seed_max_attempts` | 64 |
| — | `notable_min_entry_dist` | 2 (guess) |
| N_clusters | `cluster_count` | 75 |
| μ_n, σ_n | `cluster_size_mean`, `cluster_size_sd` | 8, 2 |
| n_min, n_max | `cluster_size_min`, `cluster_size_max` | 3, 12 |
| — | `huyet_per_notable` | 5 |
| share_inner | `inner_share` | 0.15 |
| share_sealed | `sealed_share` | 0.667 |
| g1, g2 | `size_realm_gates` | 6, 10 |
| cap_min_n | `cap_min_n` | 7 |
| f_tier | `capability_stat_share` | T1 0.5, T2 0.25, T3 0 |
| B | `fill_total_power` (computed per cluster) | Formulas F |
| — | `fill_stats` | the weight table in F |
| — | `cong_phap_seasons` | 24 for a Yellow or Profound cultivation technique (công pháp), 48 for Earth or Heaven (fixed by the Cultivation Techniques GDD, key `seal_seasons`); cultivating seasons in the main slot add up (rule 7) |
| — | `open_unseals_per_realm` | Qi Refining 1, Foundation Establishment 1, Core Formation 1, Nascent Soul 2, Deity Transformation 2 |
| tree_breakthrough_cap | `tree_breakthrough_cap` | 8 percentage points (guess) |
| a_max[r] | `npc_unseal_share` | 0.02, 0.10, 0.18, 0.22, 0.22 |
| — | NPC allocation weights | `tree_kind_scores` and `tree_focus_weight` in `world_generation.json` (rule 5) |
| n_sector | `variant_sector_size` | 30 |
| n_road | `variant_road_count` | 8 |
| n_A, n_B, n_X | `variant_cluster_slots` | clusters [4, 9], apex cluster 9 |
| P_v | `variant_premium` | 1.25 (= P_min) |
| a_apex | `variant_apex_ratio` | 1.1 |
| e | `variant_entry_depth` | phong 3, huyet 4, hu_khong 5, hon_don 7, quang 8, bang 8; loi and am a value 9–13 drawn once per chord from `rng("variant:"+id)` |
| — | `variant_hosts` | phong, huyet, hu_khong [inner radial, sector drawn]; hon_don [K1 ring, sector drawn]; quang [hoa]; bang [thuy]; loi [hoa, kim]; am [tho, thuy] |
| — | `variant_stats` | per variant: the sector and apex names, the three stats and W split, and the per-piece assignment (H4); caps use the existing `fill_stats` caps |
| — | `variant_chord_depth_gap` | 0 (fallback up to 2) |

### Computational budget

The NPC allocator must target notables and clusters several steps away and stay fast
with up to 566 points:
- keep the open set and the frontier as Dictionary sets, updated per point;
- choose targets with one BFS from all open acupoints (O(N + E) ≈ 3,200 steps), redone
  only when a target is reached;
- cache plans per (archetype, focus element).

Budget: **≤ 50 ms per Deity Transformation NPC** (guess). The current one-step allocator
is estimated at 1–5 s at 566 points and must be replaced before NPCs above Core Formation
are generated.

## Edge Cases

**Points and allocation**

- **If points arrive with nothing to open** (every reachable acupoint [huyệt] open, the
  rest sealed): the points stay unspent and are shown as unspent; they never expire.
- **If the character loses a level** (a failed breakthrough or an event costs a stage):
  no points are taken back and no acupoint closes. points_total tracks the highest level
  reached, so regaining the level pays nothing twice.
- **If the only route to a target passes through hidden acupoints:** the path tool
  reports the target as unreachable and spends nothing (rule 8).
- **If a path is cheaper through an inner hidden cluster once it is unsealed:** routes
  may pass through unsealed clusters like any other acupoint.
- **If the spiritual root (linh căn) changes mid-life** (a Linh Căn Quả or Tẩy Tủy Đan adds or
  raises an element): every open acupoint's multiplier is recomputed immediately under
  rule 4. An acupoint whose element count requirement is no longer met stays open and
  keeps contributing, since there is no respec.

**Unsealing**

- **If a seal condition is met below the cluster's gate realm:** the unseal is recorded
  as pending and completes automatically when the character reaches the gate realm.
  - A Meridian Seal (Mạch Ấn) key is consumed at use and the pending unseal is shown with
    its realm.
  - A cultivation technique's (công pháp) season count stops once it reaches
    `cong_phap_seasons`.
- **If a condition fires for a cluster already unsealed:** nothing happens. A Meridian
  Seal key for an unsealed cluster cannot be used and is not consumed.
- **If a story moment fires with no eligible open cluster** (all unsealed, none within
  reach rules, or the realm allowance spent): the effect is dropped and logged. Nothing
  is given in its place, so no free power appears.
- **If two conditions fire on the same turn:** they resolve in cluster id order; each is
  independent.
- **If an NPC's rolls would exceed its cluster cap:** rolling stops at the cap (Formulas
  G).

**LLM fills**

- **If the LLM is off, times out or returns invalid JSON:** the fill comes from the
  theme's template pool. If the theme has no pool, the generic pool is used. A fill
  always completes in the same turn.
- **If the reply has unknown or repeated slot ids, missing slots, or marks the wrong
  notables:** bad entries are dropped, missing slots are filled from the pool, and roles
  come from the map's slots. The adjustment is recorded on the fill like any
  clamp.
- **If a name is empty, duplicates an existing acupoint name or fails the text filter:** it
  is replaced with "<cluster name> · huyệt <n>". The stats are kept.
- **If the game closes between the unseal and the fill being recorded:** on load the
  cluster is still Awaiting fill, and the fill is requested again with the same inputs.

**Capabilities**

- **If a capability has nothing to act on** (e.g. +1 magic treasure [pháp bảo] slot with
  no magic treasure): it is held and listed, with no effect until it can act.
- **If two held capabilities are marked incompatible in the catalogue:** the notable
  that grants the second can still be opened for its stats. Its capability is shown as
  suppressed while the first is held.
- **If #5 Soul Leaves the Body (Linh Hồn Xuất Khiếu) would trigger on death by old age:**
  it does not; it covers deaths in events and fights only.
- **If #23 Burning Life to Break Through's (Thiêu Thọ Phá Cảnh) burn cost is equal to or
  greater than the remaining lifespan:** the retry is not offered. It is offered only
  when remaining lifespan > burn_cost.
- **If the character holds both #22 Last Radiance (Hồi Quang Phản Chiếu) and #23:** only
  one acts per realm step, and the player chooses which (Formulas E2).
- **If an NPC holds a capability whose effect is `none`:** the capability appears in
  the World Database and story context only.

**Content and saves**

- **If a new content release adds clusters mid-life:** they appear hidden at the rim and
  can be unsealed in the current life. Nothing already on the map changes (rule 19).
- **If a save references an acupoint or cluster id that the data no longer has** (only
  possible with corrupted or modded data): the acupoint is skipped, its point is returned
  as unspent, and the problem is logged. This is the one case where a point is
  refunded.
- **If the seed's inner cluster count falls outside 9–14:** the next seed is tried at
  generation time (Formulas C). Players never see a rejected seed.

**Variant sectors**

- **If a variant forms mid-life (Mutation Awakening, a Linh Căn Quả):** its sector appears at
  once, and its entries join the frontier only where they touch an open acupoint. If the host
  is closed, the player walks to it first. Points already spent stay spent.
- **If an innate variant's host sits in a sector of an element the root lacks:** the road to it
  pays the ×0.25 absent multiplier (rule 4). The host's sector is drawn once with the map, so
  this is fixed and can be learned.
- **If a variant's purity is 20 or below:** the sector pays less than the main map (Formulas H3).
  It is not blocked; the value shown before spending tells the player (AC-KMD-57).
- **If a derived variant's purity rises (Tẩy Tủy Đan):** its open sector acupoints are recomputed
  immediately under rule 4, like any open acupoint.
- **If a chord is shorter than the existing route between its two sectors:** the path tool may
  use it, for its holder only. A locked sector is never routed through.
- **If a root owns two or more variants:** each sector unlocks on its own; they never link to
  each other, and points are spent in each separately.
- **If a sector's hosts cannot be placed:** the content build fails (G9). The seed never moves.
- **If a save holds an open variant acupoint on a root that lacks the variant** (an edited save):
  it is treated as an unknown id: the acupoint is skipped, its point returns as unspent and one
  line is logged (AC-KMD-53).

**Display**

- **If a cluster has 2 or 3 entry links:** discovery in Silhouette mode triggers from any
  of them.
- **If a cluster's element is absent from the spiritual root:** it can still be unsealed
  and opened. Its acupoints are worth 0.25× (rule 4), which the map shows before the point is
  spent.

## Dependencies

None of the systems below has a GDD yet; every interface is provisional. When each GDD
is written, it must list the Meridian Map (Kinh Mạch Đồ) in its own Dependencies section,
as the bidirectional-dependency rule requires.

**Upstream: this system cannot work without them (hard)**

| # | System | What the Meridian Map needs from it |
|---|---|---|
| 1 | Data-Driven Config | `meridian_tree.json`, `meridian_fill.json`, `meridian_capabilities.json`, and the cluster and point parameters |
| 2 | Deterministic Simulation Core | The seeded RNG for map generation (fixed seed per content release) and NPC allocation; Breakdown for explainable values |
| 6 | Spiritual Root (Linh Căn) | Purity per element and base element count (rules 3 and 4); owned variants with purities, for the hidden variant sectors (rule 20) |
| 7 | Character Stats | Accepts modifiers {source, stat, value}; owns stat keys, units and meaning, and the stat weights' reference values; stores the character's capability set (held capability ids), which the Meridian Map writes and every capability host reads |
| 8 | Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) | Level, realm and stage; level bands, great breakthrough bonuses and the `pct_trung` / `pct_hau` / `pct_dai` shares (Formulas A); realm lifespan L_r; pill attempts for #22 and #23; the breakthrough talisman (one per realm step, τ 0.05, rule 8), which enters Formulas E2 as τ_a; failure insight (`breakthrough.failure_insight_pp` 2, `failure_insight_cap` 4), which enters E2 through q (insight included) and ι_23 |

**Upstream: the cluster layer needs them; the base tree works without them (soft)**

| # | System | What the Meridian Map needs from it | Without it |
|---|---|---|---|
| 3 | World Database | Stores "cluster unsealed" events and recorded fills | Fills are kept on the character only, and NPCs can't refer to them |
| 5 | Save/Load | Saves per-life state (rule 15) | Per-life state is lost on reload |
| 9 | Cultivation Techniques (Công Pháp) | A cultivation technique's list of clusters, and active-season tracking | Cultivation technique seals can't be met |
| 13 | Item Database & Generation | The Meridian Seal (Mạch Ấn) key item kind | Item seals can't be met |
| 23 | Event Engine | The "unseal this cluster" and "story moment" effects, gated by budget; event point grants | Event seals and open clusters can't be unsealed |
| 29 | LLM Game Master | Fill request transport | The template pool fills every open cluster |
| 11 | Progression Edges | The NPC edge score for `npc_unseal_chance` | NPCs never unseal clusters |

**Downstream: systems that depend on the Meridian Map**

| # | System | What it takes |
|---|---|---|
| 21 | Combat | Only the stat modifiers, through Character Stats. No capability behaviour is hosted by Combat; each is owned by exactly one host below (for #9, Combat only reports the defeat to Realms & Bottlenecks) |
| 24 | NPC Build Generation | The allocation rules (rule 5) and the allocator budget (Formulas, Computational budget); NPC unseals and `npc_effect` |
| 27 | World Generation & History | Generates NPCs through NPC Build Generation, so it is bound by the allocator budget |
| 33 | Balance Simulation Harness | Reruns calibration with the new point ladder and rescaled values (A, A2) |
| 35 | Guidance Layer | Map, silhouettes, hints, unspent points, "an unsealed cluster has unopened acupoints" goals |
| 36 | Debug Terminal | The text map and the open commands |
| 37 | Game UI | The visual map (later) |
| 12 | Codex & Karmic Carryover | Records discovered clusters, conditions and capabilities across lives (Silhouette mode benefits most) |

**Capability hosts.** Each implements the behaviour behind its capabilities. Hosts do
**not** call the Meridian Map:
- The Meridian Map writes held capability ids into a capability set on the character.
- Hosts read that set, the same way they read stat modifiers.
- This breaks what would otherwise be cycles with the upstream hosts (Realms & Bottlenecks,
  Spiritual Root, Character Stats, Event Engine, Cultivation Techniques).

The hosts, each capability owned by exactly one (all 25 appear once):
- Magic treasures [pháp bảo] (inside Artifact Refining [Luyện Khí] #16): #1 Twin Arms in
  Harmony, #2 Divided Divine Sense, #3 Treasure Nurtured Within
- Cultivation Techniques #9: #6 Twin Technique Cultivation
- Time & Turn #4: #7 Embryonic Breath, #8 Dao in Dreams
- Alchemy (Luyện Đan) #15: #10 Divided Furnace Flame, #11 Strange Pill Reborn
- Spirit Herbs & Spirit Fields (Linh Thảo & Linh Điền) #14: #12 Hundred Herbs Kept Alive
- Talismans (Phù Lục) #18: #13 Endless Talismans
- Formations (Trận Pháp) #17: #14 Portable Cave Abode (it publishes a
  location-independent flag that Spirit Herbs & Spirit Fields reads), #15 Formation
  Within a Formation
- Spirit Beasts (Linh Thú) #19: #16 Ten Thousand Beasts, One Heart, #17 Beast Soul Union
- Event Engine #23: #5 Soul Leaves the Body, #18 Reading Heaven's Secrets, #19 Child of
  Fortune, #20 Concealed Breath
- Travel & Map #25: #21 Blink Mark
- Realms & Bottlenecks #8: #9 Great Essence-Draining Art (cultivation base [tu vi] from a
  defeat; Combat reports the defeat, and the heart demon [tâm ma] change goes through
  Character Stats), #22 Last Radiance, #23 Burning Life to Break Through
- Spiritual Root #6: #24 Mutation Awakening
- Character Stats #7: #4 Blood Commands Spirit, #25 Heart Demon Turned to Strength (and
  the heart demon part of #9)

**Systems index.**
- Row 10's Depends On already reads Linh Căn, Character Stats, Cảnh Giới, Config, Sim
  Core, and soft: Event Engine, Item DB, Công Pháp, LLM GM, World DB, Edges.
- Its status follows this GDD's review. When the GDD is approved it becomes "Designed
  (partially implemented)": the base tree is built at prototype scale; clusters, levels
  and capabilities are not built.
- No new cycle: Event Engine, Item DB, Cultivation Techniques and LLM GM don't depend on
  the Meridian Map, and capability hosts depend on the character's capability set, not
  on this system. NPC Builds already depends on it in one direction only.

## Tuning Knobs

Every knob is a data key (see Parameter keys). Ranges marked *derived* follow from other
numbers in this GDD; ranges marked *guess* wait for a bot run.

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `cluster_count` | 75 | 60–90, derived: below about 55 the seed rule (25 capability-eligible clusters) cannot be met. The inner window of 9–14 is fixed, so at either end about half of all seeds are rejected; move the window with the count | Hidden share of the map; about 9 acupoints (huyệt) per cluster |
| `size_realm_gates` (g1, g2) / `cap_min_n` | 6, 10 / 7 | g1 5–6 and always below `cap_min_n` (at g1 = 7 an outer n = 7 cluster would gate at Foundation Establishment [Trúc Cơ]), g2 9–11; cap_min_n 7 (it must keep every capability at Core Formation [Kết Đan] or later) | Which realm each cluster size opens in; how many clusters can carry a capability |
| Δ_desp / `q_max` / burn share | 0.15 / 0.95 / 5% | Δ_desp 0.05–0.15, q_max ≤ 0.95, burn share 3–10%, guess | Strength of #22 Last Radiance (Hồi Quang Phản Chiếu) and cost of #23 Burning Life to Break Through (Thiêu Thọ Phá Cảnh) (Formulas E2) |
| `pts_birth`, `great_breakthrough_bonus`, `pct_trung` / `pct_hau` / `pct_dai` | 2, 15/25/40/60, 15/25/35 | provisional; Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) owns them. Keep `pct_trung` + `pct_hau` + `pct_dai` ≤ 100 | Points per life (Formulas A) |
| `cluster_size_mean` / `_sd` | 8 / 2 | mean 8–11, derived: at mean 7 only about 25 clusters have n ≥ 7, which is the seed rule's floor | Cluster size, entry cost, gate realm, budget |
| `inner_share` | 0.15 | 0.12–0.18, derived from the seed window of 9–14 inner clusters | How many clusters can open in Qi Refining (Luyện Khí) |
| `sealed_share` | 0.667 | 0.55–0.75 | Sealed against open split; the authoring load (about 9 acupoints per sealed cluster) |
| `huyet_per_notable` | 5 | 4–6 | Notable density in clusters (about 16%) |
| S0 / N0 | 1.2 / 8 | S0 1.1–1.4 at N0 = 8; N0 7.0–9.1 at S0 = 1.2. Derived from AC-KMD-07's 90–125 W on the A2 routes, which are guesses. Hard ceiling N0 < 19, so the strongest hidden notable (N0·1.75·1.5) stays under the 50 W keystone floor | Tree power per point |
| `huyet_value_highway` (H0) | 1.2 | 1.0–1.2. Derived: at 0.9 the weak route of A2 falls to about 89 W, under AC-KMD-07's 90 W floor; at most S0, so clusters stay the destinations | Cost of walking meridian roads (kinh lộ) |
| `radials_per_sector` | 3 | 3, fixed by user decision; any change rewrites Formulas H | Meridian road density |
| `ring_anchor_depths` | 5 / 14 / 20 | Fixed at 5 / 14 / 20 (user decision 2026-11-03). The junction (hội huyệt) lists of G2 and AC-KMD-61, the connectors and the braids are built around these depths: K1 at 4 or 6, or K2 at 13 or 15, breaks the 3–5 junction spacing, and a keystone at d 22 hangs off a d 21 ring acupoint. A different anchor means rewriting G2 first | Where the rings sit |
| `ring_interior` | 2 / 3 / 3 | 2–4 each. Derived: the 3–5 step junction spacing, and m3 ≤ 4 keeps K3 at d 22 or less. Each +1 on a ring adds 15 acupoints (2 per sector, 1 per border) and 15 link slots | Ring length; link capacity |
| `base_cluster_slots` | inner 2×3, middle 4×5, outer 2×8, border gaps 3/5/6, bridges 5/5 | keep sizes rising toward the rim; a slot must fit its `region_capacity` | Visible content vs map size and readability |
| `region_capacity` | see Parameter keys | a value is safe while the drawing rules pass (UI Requirements); raise only with a clean layout | How much a region holds; how many clusters move to the rim |
| `road_stats` | vitality-led rotation | generic stats only; never `breakthrough_chance` or a ceiling key | What walking a road gives every build |
| `huyet_per_notable_visible` | 4 | 4–5. Derived: at 3, a 6-acupoint cluster pays about 3.5 W per point, above the weakest hidden cluster (about 3.0) | Visible ν |
| `entry_count_weights` | 0.20 / 0.60 / 0.20 | mean 1.8–2.15. The low end is the user's "about 2". Derived: with about 200 outer link slots and 79 outer-linked clusters, a mean above about 2.03 takes the outer ratio under the 1.25 margin (1.18 at 2.15), which is reported, not rejected | Entries, average degree, shortcuts |
| `shape_preferred_share` | 0.6 | 0.4–0.8 (guess) | How readable a theme's shape is vs variety |
| `route2_min_extra` | 2 | fixed by user decision | Two-route rule |
| `degree_avg_window` | 2.30–2.60 | fixed by user decision. The launch map is expected near 2.36; the G8 repair holds the floor | Flexibility |
| `link_capacity_margin` | 1.25 | 1.1–1.5 (guess). Report only: a seed whose outer ratio is below the margin is listed in AC-KMD-67's report, not rejected; a ratio below 1.0 rejects the seed (G7). The launch ratio is about 1.27 | How often the capacity report flags a seed |
| `cluster_retry` / `seed_max_attempts` | 8 / 64 | 4–16 / 32–256 (guess) | Build time vs rejection |
| `notable_min_entry_dist` | 2 | 1–3 (guess); applies only at n ≥ 5. Higher values make fewer (shape, n, E) combinations supported (G6), so bridges and small clusters lose shapes | Small acupoints are paid for before a notable |
| `w_d`, `w_n` / `d_lo`, `d_hi` | 0.5, 0.5 / 4, 23 | w_d + w_n = 1; d_lo and d_hi follow the shallowest and deepest possible entry (derived from the link depths 3–22) | How much a hidden cluster's reach and size raise its premium |
| P_min / P_max | 1.25 / 1.75 | P_max ≤ 1.75 (user cap); P_min ≥ 1.0 | How much more a hidden acupoint pays than a visible one |
| `tol` | 1.2 | 1.0–1.5 | Spread allowed on one small acupoint |
| γ | 0.5 | 0.3–1.0 (1.0 is linear) | How fast compounding caps grow with cluster size |
| `capability_stat_share` | T1 0.5, T2 0.25, T3 0 | each ≤ 0.5, with T1 ≥ T2 ≥ T3 | Stats kept beside a capability |
| φ_r | 0.10 / 0.05 | 0.05–0.15 | Most lifespan one cluster may give |
| `tree_breakthrough_cap` | 8 pp | 4–12, guess | Most breakthrough chance the tree may give |
| δ_max | 0.10 | 0.05–0.10, derived: above 0.10 an edge life exceeds 0.80 | Breakthrough lift from capabilities #22 Last Radiance and #23 Burning Life to Break Through |
| `open_unseals_per_realm` | 1 / 1 / 1 / 2 / 2 | 0–3 per realm | How often a story moment can open the tree |
| `npc_unseal_share` | 0.02–0.22 | up to 0.22, derived: the holder share must stay under 15% (AC-KMD-49) | How many NPCs hold a cluster |
| `cong_phap_seasons` | 24 / 48 | fixed by the Cultivation Techniques (Công Pháp) GDD (rule 15, `seal_seasons` 24 / 24 / 48 / 48 by tier); 12–60 safe | Length of a cultivation technique seal |
| `variant_premium` | 1.25 | 1.0–1.25. Above about 1.29 Wind's A cluster exceeds Formulas D's notable cap, so a raise needs a per-cluster check | Sector power per point (2.95 W at 1.25) |
| `variant_apex_ratio` | 1.1 | 1.0–1.17. Hard cap: N0·P_v·a_apex ≤ E_notable at the shallowest apex (11.74 W) | How much the apex outweighs the other notables |
| `variant_entry_depth` | 3, 4, 5 innate; 7 Chaos; 8 transmutation; 9–13 chords | innate 3–5; Chaos 7 (the K1 ring); chords only while the middle band has hosts | Cost to reach and clear a sector. Does not change its gain |
| Stealth share (Darkness) | 30.5 W (+20.3) | 20–42 W | Evasion strength, a guess: 1 stealth is about 1 pp of check chance |
| Chaos cultivation speed | +10.6 % | at most the compounding cap, 10.6 % | The only place sectors add cultivation speed |

**Target outcome (guess).** A typical life unseals 3–6 clusters by Nascent Soul (Nguyên Anh). The
autoplay bot reports it; AC-KMD-49 bounds NPCs only.

## Visual/Audio Requirements

Deferred to the Game UI GDD (system 37). The tree's look (ink-wash map, element
colours, silhouettes for hidden clusters) is decided there.

## Game Feel

Not specified at this tier. Intent for later work:
- Opening a notable should feel like a decision paid off.
- Unsealing a cluster should feel like a door opening in the map, not a menu unlock.

## UI Requirements

These apply to the Debug Terminal now and to the Game UI later.

- **Point budget.** Spent and unspent points are always visible, along with the next
  point source (next level, next small breakthrough, next great breakthrough, with its
  advance shown separately).
- **Before spending.**
  - Every acupoint (huyệt) shows its scaled value (after rule 4) before a point is spent.
  - The path tool shows the full route cost and the total gain before committing.
- **Hidden clusters.**
  - In Silhouette mode, the location and theme show; the condition shows once
    discovered.
  - In Visible mode, the condition and (sealed) content show.
  - An open cluster shows "to be written by the story".
  - A pending unseal shows the realm it waits for.
- **Fills.** Every clamp on an LLM fill is listed on the cluster, in the same style as
  event clamps.
- **Variant sectors.** A locked sector is not drawn and not hinted, in either visibility mode. An
  unlocked one shows its name, its variant's purity and its scale. When a variant forms mid-life,
  the screen shows where its sector appeared and which host opens it.
- **Capabilities.** Held capabilities are listed with their rule text and, when one
  can't act or is suppressed, the reason.
- **Drawing the map (added 2026-11-05, user direction).** Any drawing of the map keeps these
  rules. The viewer in `tools/meridian-map/` reports them on every build.
  - No two edges cross unless they share an acupoint.
  - An acupoint stays at least `map_clearance` (15 units) from any edge it is not on.
  - Connected acupoints sit one standard step apart (46 units; road acupoints exactly one step
    along a radial). Ring edges are longer, because the ring is wider than its acupoints.
  - Edges may curve. A curve must pass the same two checks, or the edge stays straight.
  - Variant sectors are drawn outside the rim, and each host link is a pair of entry marks, not
    a line. That is the one exception to drawing every edge, because the Fire–Metal and
    Earth–Water chords cannot be drawn without crossing (Open Question 16).

## Cross-References

| Document | Relationship |
|---|---|
| `design/gdd/game-concept.md` | Pillars 1–3. The concept has no Meridian Map (Kinh Mạch Đồ) section, so no concept update is outstanding |
| `design/gdd/systems-index.md` | System 10; dependency and status changes proposed under Dependencies |
| `design/quick-specs/progression-and-edges.md` | Breakthrough targets (3 in 10 baseline, 7 in 10 with the player's edge); NPC edge curve used in Formulas G; the calibration must be rerun for Formulas A and A2 |
| `design/quick-specs/luyen-khi-and-tran-phap.md` | Magic treasure (pháp bảo) slots and formations, touched by capabilities #1–3, #14, #15 |
| `design/quick-specs/phu-luc-linh-thu-thanh-tuu.md` | Talismans (phù lục) and spirit beasts (linh thú), touched by capabilities #13, #16, #17 |
| `assets/data/meridian_tree.json` | The built prototype map; to be regenerated at the target scale |
| `assets/data/cultivation_realms.json` | Holds the old stage ladder; must move to level bands (Realms & Bottlenecks [Cảnh Giới & Bình Cảnh] GDD) |
| `docs/debug-terminal.md` | Terminal commands for the tree |
| `design/gdd/linh-can.md` | The variant roots, their purities and the sector contract (its rule 12), which rule 20 fulfils |

## Acceptance Criteria

Drafted with qa-lead.

**Gate levels and tests.**
- `project.yaml` sets no `testing.strict`, so Logic, Integration and UI are BLOCKING and
  Config/Data is ADVISORY.
- Unit suites live in `tests/unit/meridian/`, extend `DaoTestSuite` and use an injected
  seeded RNG. LLM tests inject `LlmService` disabled or faked, and never write the LLM
  config or achievements.
- Evidence for the debug terminal is a captured transcript in `production/qa/evidence/`,
  not a screen capture. The exception is AC-KMD-87, which needs retained screenshots.
- **[Bot]** items are judged on the printed output of `tools/balance/autoplay.gd` or
  `tools/balance/npc_cohort.gd`. `npc_cohort.gd` needs three new outputs: generation at
  realm r, the share of NPCs holding a cluster, and combat power (chiến lực) with and
  without the NPC's clusters.
- The existing `meridian_tree_test.gd` asserts the 202-acupoint (huyệt) prototype; those asserts
  are replaced when the target map lands (AC-KMD-10).

**Points (rule 2, Formulas A)**

- **AC-KMD-01** [Logic] With the integer `share()` of Formulas A, points_total(L) returns:

  | L | Total | L | Total | L | Total |
  |---|---|---|---|---|---|
  | 1 | 2 | 39 | 51 | 129 | 216 |
  | 13 | 14 | 40 | 62 | 130 | 243 |
  | 14 | 17 | 53 | 79 | 199 | 357 |
  | 26 | 29 | 60 | 86 | 200 | 397 |
  | 27 | 34 | 79 | 120 | 300 | 566 |
  | 38 | 45 | 80 | 137 | | |

  The first levels of the middle stage (trung kỳ) and late stage (hậu kỳ) are:

  | Realm | Middle stage | Late stage |
  |---|---|---|
  | Qi Refining (Luyện Khí) | 14 | 27 |
  | Foundation Establishment (Trúc Cơ) | 53 | 66 |
  | Core Formation (Kết Đan) | 96 | 113 |
  | Nascent Soul (Nguyên Anh) | 153 | 176 |
  | Deity Transformation (Hóa Thần) | 233 | 267 |
- **AC-KMD-02** [Logic] points_total(266) = 477, points_total(267) = 501 and
  points_total(300) = 566. A banker's-rounding implementation (500 at 267, 565 at 300)
  fails this test, and so does a float implementation (`round(0.35 * 90)` = 31 gives 565
  at 300). `share(35, 90)` = 32 and `share(25, 90)` = 23 are asserted directly.
- **AC-KMD-03** [Logic] Each great perfection (đại viên mãn) advance plus the next entry term equals that
  bonus: 5+10 = 15, 9+16 = 25, 14+26 = 40, 21+39 = 60.
- **AC-KMD-04** [Logic] points_total never decreases over 1..300.
  - At L = 60 (86 points), dropping to level 52 and climbing back keeps the total at 86
    at every step, and no acupoint closes.
- **AC-KMD-05** [Logic] Event grants and unspent points.
  - Each event grant adds exactly 1: L = 39 with 2 grants gives 53.
  - With every reachable acupoint open, new points stay unspent, and the count is
    unchanged after 20 turns.

**Value scale (Formulas A2)**

- **AC-KMD-06** [Config/Data, data-lint test]
  - The data has S0 = 1.2, N0 = 8 and `huyet_value_highway` (H0) = 1.2.
  - Every keystone has power ≥ 50 W under the F weights.
  - k_pts = 3.643 (±0.001).
  - On the target map, the mean power of visible acupoints other than keystones and the
    dantian (Đan Điền) is 1.80–1.98 W (expected 1.889). The mean over visible cluster
    acupoints only is 2.60–2.85 W (expected 2.711).
  - Every meridian road (kinh lộ) acupoint, junctions (hội huyệt) included, carries only
    `road_stats`, never `breakthrough_chance`, and pays the same on every root.
  - The visible tree's summed breakthrough_chance is at most 4 pp (half of
    `tree_breakthrough_cap`), which leaves room for hidden clusters.
- **AC-KMD-07** [Integration, Bot: `autoplay.gd`, ≥ 60 lives = 20 seeds × 3 origins]
  The median tree power at Qi Refining great perfection is 90–125 W. Lives with a 5-element root
  (the center keystone, Formulas A2) or an owned variant sector (Formulas H3) are left out of the
  median and reported separately.

**Map and reach (rules 1, 3, 4, 5, 8; Formulas B and H)**

- **AC-KMD-08** [Logic] Determinism. Two generations from the same data, and two lives
  with different character seeds, give identical ids, positions, edges, kinds, modifiers
  and d(x). A map hash equals a golden constant.
- **AC-KMD-09** [Logic] The core.
  - The dantian is at d = 0.
  - There are exactly 5 gates at d = 1, clockwise from the top: Wood, Fire, Earth, Metal,
    Water (Mộc, Hỏa, Thổ, Kim, Thủy).
  - The center keystone is refused with 4 base elements and allowed with 5.
  - The center keystone is at d 1, adjacent to the dantian, which has exactly 6 links.
- **AC-KMD-10** [Logic] Formula H.
  - The map has 772 visible acupoints:
    - 430 meridian road acupoints, including the 5 gates, of which 85 are junctions;
    - 65 visible clusters holding 330 acupoints, 75 of them notables;
    - 11 keystones;
    - the dantian.
  - Per sector: meridian road acupoints 19 / 26 / 32, clusters 2 × 3, 4 × 5, 2 × 8, 2 keystones.
  - Per border: 8 meridian road acupoints, two bridge clusters of 5, and clusters of 3, 5 and 6.
  - Every visible cluster has clamp(floor(n/4), 1, 3) notables.
  - The total, 772 plus the cluster sizes, matches a golden value in 1,250–1,410.
- **AC-KMD-11** [Logic] Bands.
  - Every visible acupoint has d ≤ 22, and the sector keystones sit at exactly d = 22.
  - Every meridian road acupoint's d equals its template depth:
    - gates: 1;
    - ring junctions: 5, 14 and 20;
    - ring acupoints: 6 (K1), 15–16 (K2) and 21–22 (K3);
    - connector acupoints: 9 and 10;
    - braid acupoints: 18.
  - Visible clusters by band:
    - inner clusters lie in d 3–6;
    - middle clusters and middle bridges in 7–14;
    - outer clusters and outer bridges in 16–22.
  - Inner hidden clusters link at d 3–7 and outer hidden clusters at d 15–22.
  - Cluster interiors may go deeper; d is frozen per release.
- **AC-KMD-12** [Logic] Reach on a fixture graph.

  | Cluster | Link open? | C_enter | C_clear |
  |---|---|---|---|
  | Outer, linked at d 19, n 9 | no | 20 | 28 |
  | Same | yes | 1 | 9 |
  | Inner, linked at d 4, n 5 | no | 5 | 9 |
  | Outer, two links at d 17 and d 19, n 9 | neither | 18 | 26 |
  | Same | only the d 19 link | 1 | 9 |
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
  - Purity 60 gives ×1.10, purity 100 gives ×1.50, and an absent element gives ×0.25.
  - A bridge between Wood 60 and an absent Fire gives ×0.675.
  - The root and keystones are ×1.0.
  - The modifier source is exactly `Kinh Mạch: <name> #<id>`.
- **AC-KMD-16** [Logic] A spiritual root (linh căn) change mid-life.
  - Purity 60 → 80 changes that element's open acupoints from ×1.10 to ×1.30 on the same
    call.
  - An acupoint whose element requirement is no longer met stays open and keeps
    contributing.
- **AC-KMD-17** [Logic] Rule 8.
  - Hidden acupoints fail `can_allocate` with a reason and are absent from `frontier()`.
  - `path_to` through them reports unreachable and spends 0.
  - No API turns points into an unseal.
  - Once unsealed, the cluster can be routed through.
- **AC-KMD-18** [Logic] Rule 5, with a fixed seed.
  - NPC allocation is identical on repeat runs and every open is legal.
  - Points spent = min(points, reachable acupoints).
  - A Fire-archetype NPC opens more Fire acupoints than acupoints of any other sector.

**Clusters and unsealing (rules 6, 7, 9, 10, 13; Formulas C)**

- **AC-KMD-19** [Logic] The launch release.
  - It has 75 clusters, every n in 3–15, and an inner count of 9–14.
  - At least 25 outer sealed clusters have n ≥ 7.
  - Every cluster has all the fields of rule 6 and exactly one condition.
  - Notables: k(3) = 1, k(9) = 1, k(10) = 2, k(14) = 2, k(15) = 3.
  - Gates:

    | n | Location | Gate |
    |---|---|---|
    | 6 | outer | Foundation Establishment |
    | 7 | outer | Core Formation |
    | 11 | outer | Nascent Soul |
    | 5 | inner | Qi Refining |
    | 11 | inner | Core Formation |
- **AC-KMD-20** [Logic] Seed rejection. A seed giving 8 or 15 inner clusters, or fewer
  than 25 capability-eligible clusters (outer, sealed, n ≥ 7), is rejected. The accepted seed is the same on every run.
- **AC-KMD-21** [Logic] In every cluster, each notable's route distance from the
  nearest entry is ≥ that of every small acupoint.
- **AC-KMD-22** [Logic] Event condition. The authored template's unseal effect moves
  cluster K from Hidden to Unsealed. The same effect on an LLM-made event is rejected and
  logged, and K stays Hidden.
- **AC-KMD-23** [Logic] Item condition. Using K's Meridian Seal (Mạch Ấn) consumes it and
  unseals K. A key for an unsealed cluster can't be used, and the item count is unchanged.
- **AC-KMD-24** [Logic] Cultivation technique (công pháp) condition.
  - K stays Hidden after 23 active seasons and unseals at 24 (48 for a high-tier
    cultivation technique).
  - Switching cultivation technique for 5 seasons pauses the count without resetting it.
- **AC-KMD-25** [Logic] Pending unseal.
  - A Foundation Establishment character meets a Core Formation-gated condition: the
    cluster becomes pending with "Kết Đan" recorded, and the key is consumed.
  - It becomes Unsealed on entering Core Formation with no further input.
- **AC-KMD-26** [Logic] Unsealing.
  - Exactly one World Database event {type "cluster unsealed", player, cluster, source}
    is written.
  - The entry acupoints that touch an open acupoint join the frontier.
  - The open set and the points are unchanged, and the cluster never returns to Hidden.
  - Two conditions on one turn resolve in ascending cluster id.
- **AC-KMD-27** [Logic] Rule 10 selection, with eligible open clusters A (id 4, route 6,
  Way of Alchemy [Đan Đạo]), B (id 2, route 3, Way of Formations [Trận Đạo]) and C (id 7,
  route 3, Way of Formations).
  - No hint: B is chosen.
  - Hint Way of Alchemy: A is chosen.
  - Once the realm allowance is used, the next story moment is dropped and logged and
    grants nothing. The same happens when no cluster is eligible.
- **AC-KMD-28** [Logic] Visibility.
  - Fated (Thiên Định) suggests Silhouette and Self-made (Tự Định) suggests Visible.
  - Either life can choose either mode at creation and switch at any time.
  - After a switch from Visible to Silhouette, every condition shown in Visible counts
    as discovered. Discoveries are never lost on a switch.
  - In Silhouette, the condition stays hidden until a discovery. Discovery comes from
    any entry of a cluster with 2–3 links, or from an event, NPC or item hint.
  - In either mode, an open cluster's content is empty before its fill is recorded.

**Fills and validator (rules 10, 11, 12; Formulas D, E, F)**

- **AC-KMD-29** [Logic] Premium.
  - d_entry 19 (link at d 18), n 9 gives P = 1.5724 (±0.0005), E_small = 1.887 and
    E_notable = 12.58.
  - d_entry 5, n 5 gives 1.305; d_entry 4, n 3 gives 1.25; d_entry 23, n 15 gives 1.75.
  - The strongest scaled notable is 21 W, below 50.
- **AC-KMD-30** [Logic] Budget B.

  | n | k | c | P | B |
  |---|---|---|---|---|
  | 9 | 1 | 0 | 1.5724 | 27.67 (±0.01) |
  | 3 | 1 | 0 | 1.25 | 13.0 |
  | 15 | 3 | 0 | 1.75 | 67.2 |
  | 9 | 1 | 1 (T2) | 1.5724 | 18.24 |
  | 9 | 1 | 1 (T3) | 1.5724 | 15.10 |
- **AC-KMD-31** [Logic] The GDD's example fill passes with zero repairs and scale_all = 1:
  power 27.12 W, small cap 2.264 W, notable cap 12.58 W, cultivation speed 1.6 of 4.
- **AC-KMD-32** [Logic] Keys. `single_artifact: true` and `lifespan_pct` are replaced
  from the pool, a capability or rule-text field is removed, and each repair is
  recorded.
- **AC-KMD-33** [Logic] Shape repairs (Formulas F steps 1–5). Each repair is recorded.

  | Input | After repair |
  |---|---|
  | 12 acupoints for n 9 | 9 (extras dropped) |
  | 6 acupoints for n 9 | 9 (3 added from the pool) |
  | Reply marks 2 notables for k 1 | Roles come from the slot map: 1 notable; the extra mark is ignored and recorded |
  | An unknown or repeated slot id | Entry dropped; a missing slot is filled from the pool |
  | +0.04% attack (below one unit of 0.1) | Removed; a pool stat is added if the acupoint is left empty |
  | `field_plots` on a small acupoint or a notable | Removed (one plot is 20 W, over the small cap and over E_notable ≤ 14 W); replaced from the pool |
  | −5% defense | stat removed (replaced from the pool if the acupoint is left empty) |
  | An acupoint with 3 stats | the 2 highest-power stats kept |
  | 2 distinct stats | 3 or more |
- **AC-KMD-34** [Logic] Value repairs, in order.
  - +30% attack on a small is cut to +2.2%: the cap is 2.264 W, rounded down to the 0.1
    precision, so the acupoint has 2.2 W.
  - Cultivation speed summing to 9 at n = 9 is scaled down to a sum of at most 4 (rounding
    down can leave it a little under). The cap is 2.667 at n = 4 and 5.164 at n = 15.
  - A notable whose only stat is `field_plots` loses it at step 6 (20 W is over its
    E_notable, at most 14 W at launch values) and gets a pool stat.
  - With a fixture data file whose N0 lifts that notable's E_notable to at least 20 W, the
    same notable in an n = 7 cluster passes step 6 but loses the plot at step 8 (the
    cluster cap, 0.88, is below one unit) and gets a pool stat.
  - Three smalls in an n = 3 cluster, each with only 0.1 `breakthrough_chance` (cap 0.289):
    all three are dropped at step 9, and each is fixed with one unit of an uncapped pool
    stat. The cluster's `breakthrough_chance` sums to 0.
  - A fill of 34.6 W against B = 27.67 is scaled by 0.7997, then every value is rounded
    down to its precision (step 9), so the result is ≤ 27.67 and never above it.
  - Fixture where scale_all < 1 and one acupoint's only stat is a single unit: after step
    9 that acupoint keeps one unit, the others are rescaled on the remaining budget, and
    the total is ≤ B with no tolerance. If the fixed acupoints alone exceed B, the pool
    fill is used.
  - A notable's lifespan_years at L_r = 120 is at most 5.03 years, and a cluster's summed
    lifespan_years is cut to 12 years (φ_r·L_r).
  - +0.4% breakthrough_chance on a small is allowed: 2.0 W ≤ 2.264 W.
  - Variety fixtures, a cluster left with 2 distinct stats after step 9:
    - the only single-stat acupoint is a small at 2.2 W (cap 2.264 W): a 0.1 W unit would
      reach 2.3 W, so no unit is added and the pool fill is used;
    - the cluster's real total is within 0.05 W of B: the pool fill is used;
    - a single-stat acupoint with room under its cap and the cluster under B gains one unit
      of an uncapped stat the cluster lacked, and the cluster has 3 distinct stats.
- **AC-KMD-35** [Logic] Property test over 500 seeded hostile fills. After the
  validator, every fill:
  - has power ≤ B (exactly, no tolerance) and no negative values;
  - has every acupoint within its own power cap (`tol·E_small` for a small, `E_notable` for a
    notable), exactly, no tolerance;
  - has summed lifespan_years ≤ φ_r·L_r;
  - has every stat's cluster sum within its compounding cap, `cap9_c·(n/9)^γ` rounded down
    to the stat's precision;
  - uses only `fill_stats` keys, with at most 2 stats per acupoint;
  - has n acupoints and k notables on the map's notable slots, with at least 3 distinct stats;
  - has every value an exact multiple of its precision;
  - has no capability or flag;
  - records every repair.
- **AC-KMD-36** [Logic] LLM off.
  - With the LLM disabled, timing out or returning invalid JSON, a story moment
    completes its fill from the theme's pool in the same turn, and the fill passes
    AC-KMD-35.
  - A theme with no pool falls back to the generic pool.
  - The same seed gives the same fill.
- **AC-KMD-37** [Logic] Fill requests and names.
  - The fake LLM receives theme, affinity, B, and the event's people, place and text.
  - An empty, duplicate or filtered name becomes `<cluster name> · huyệt <n>`, with its
    stats kept. The filter is the Event Engine's LLM text filter.
- **AC-KMD-38** [Logic] Recorded fills.
  - A recorded fill is byte-identical after reload and after a later story moment.
  - A save taken between unseal and record loads as Awaiting fill and re-requests with
    identical inputs.
- **AC-KMD-39** [Logic, data-driven] Every authored sealed cluster passes the validator in
  sealed mode (Formulas F) with zero repairs. A T3 capability notable with no stats
  passes; the same notable in normal mode is repaired.
- **AC-KMD-40** [Logic] Formula E with E_notable = 12.58.
  - T1 gives 6.29 W, T2 3.145 W and T3 0 W.
  - A capability notable's authored power is ≤ f_tier·E_notable.

**Capabilities (rules 16–18; Formula E2)**

- **AC-KMD-41** [Config/Data] The catalogue.
  - 25 entries with unique ids. Every tier is T1, T2 or T3. The launch assignment (#10 and
    #19 T1; #5, #22 and #23 T3; the rest T2) is provisional (Open Question 5): the test
    compares it with a golden list that changes in the same commit as any re-tiering.
  - Each `npc_effect` is from the closed set and within its caps, and incompatibility
    lists are symmetric.
  - Each capability sits on exactly one notable of a distinct outer sealed cluster with
    n ≥ 7. No open cluster carries one.
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
    0.01–min(S − τ_a, 0.95 − τ_a) (a pair with an empty q range is skipped), the lift of #22 and of #23 is ≤ 0.10 + 1e-9, q ≤ q_desp,
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

**NPCs (rule 14; Formula G)**

- **AC-KMD-47** [Logic] Formula G.
  - Core Formation at e = 1: a = 0.18, p = 0.005209 (±1e-5).
  - Core Formation at e = 0: a = 0.07714.
  - e = 1.5 gives the same as e = 1.
  - Qi Refining at e = 1 with M = 1: p = 0.02.
  - M = 0 gives p = 0.
  - Only clusters of the NPC's elements at or below its realm are rolled.
- **AC-KMD-48** [Logic] With every roll forced to succeed:
  - a Foundation Establishment NPC holds 1 cluster, and Nascent Soul and Deity
    Transformation NPCs hold 2;
  - rolls go in the NPC's seeded shuffled order (identical on a repeat run, and not
    ascending id), and open clusters are never held.
  - `npc_effect`:
    - `chien_luc_mult` is capped at ×1.10;
    - `p_step_add` 0.05 on 0.68 gives 0.70;
    - `survive_once` fires once;
    - `none` changes no number.
- **AC-KMD-49** [Integration, Bot: extended `npc_cohort.gd`, ≥ 1,000 NPCs per realm,
  3 seeds]
  - Cluster holders are under 15% at every realm.
  - The median combat power uplift among holders is under 15%.
- **AC-KMD-50** [Integration, Bot] Breakthrough rates on the level ladder with rescaled
  values.
  - `npc_cohort.gd` at 1,000 per cohort: per-realm success is 0.30 ± 0.05 with no edge
    and 0.70 ± 0.05 with all edges.
  - `autoplay.gd` over ≥ 60 lives: 0.70 ± 0.10 with edge on and 0.30 ± 0.10 with edge
    off.
  - In both runs the bot takes no `field_plots` acupoint (Formulas F, plot price): fields
    are a build outside these targets.

**Persistence and content releases (rules 15, 19)**

- **AC-KMD-51** [Logic] A save/load round trip keeps open acupoints, unsealed and pending
  clusters, hints, fills with their repair records, visibility mode and capability set
  identical. Serialising twice gives identical output.
- **AC-KMD-52** [Logic] Append-only, with release 1 plus a fixture release 2.
  - Every release-1 acupoint keeps its id, position, kind, modifiers and d(x).
  - Every release-1 cluster keeps its fields.
  - New ids are above the largest release-1 id, and new acupoints link only to release-1
    outer acupoints.
  - Release 1 generated alone equals release 1 inside "1+2".
  - A fixture release that would shorten any depth is rejected by the content build.
- **AC-KMD-53** [Logic] A release-1 save loads under release-2 data.
  - The new clusters are Hidden, and fills and World Database events still resolve.
  - A save with an unknown id skips that acupoint, returns its point as unspent and logs
    one line.

**Performance**

- **AC-KMD-54** [Integration; BLOCKING before NPCs above Kết Đan are generated] A
  headless perf script, `tests/performance/meridian/allocator_perf.gd` (not a gdUnit
  test).
  - Setup: 200 seeded Deity Transformation NPCs at 566 points on the target map, plan cache cold.
  - Measurement: `Time.get_ticks_usec()` around the allocate call only.
  - Pass: p95 ≤ 50 ms and max ≤ 100 ms on the reference machine, the owner's development
    PC (AMD RX 9070 XT, 61 GB RAM; record its CPU model on the first run). A run on other
    hardware is informational.
  - Record median, p95, max and the CPU model in `production/qa/evidence/`; the first
    passing run on a machine is its baseline, and a later run on the same machine may
    not exceed it by more than 20%.
- **AC-KMD-55** [Logic] With a counter injected into the allocator: BFS passes ≤ targets
  reached + 1, and there is no full frontier rescan per point.

**Topology (rule 1, Formulas H)**

- **AC-KMD-60** [Logic] Degree.
  - In the full graph (every cluster unsealed), every acupoint has degree ≤ 4 except Đan
    Điền, which has exactly 6 (5 gates and the center keystone).
  - Every degree-4 acupoint is a junction acupoint (hội huyệt).
  - In the visible graph the 85 hội have degree 3–4:
    - 40 have degree 4: 5 gates, 15 K1 junctions, 15 K2 junctions and 5 C17 braid
      junctions;
    - 45 have degree 3: 15 K3 junctions, 20 connector ends and 10 side braid junctions.
  - The average degree is 2.30–2.60 on the visible graph and on the full graph (expected
    about 2.36 on each, guess).
- **AC-KMD-61** [Logic] Hội spacing.
  - Along every radial, consecutive hội are 3–5 steps apart. For χ = 0:
    - C: d 1, 5, 8, 11, 14, 17, 20;
    - L: d 1, 5, 10, 14, 17, 20;
    - R: d 1, 5, 9, 14, 17, 20.

    χ = 1 mirrors L and R.
  - K1 segments are 3 steps, and K2 and K3 segments 4 steps.
  - Every connector and braid is 2 steps.
- **AC-KMD-62** [Logic] Two routes.
  - Every neighbour pair on the launch map passes this test:
    - route 1 is the rule-3 route, with interior length ℓ1;
    - a route 2 exists that avoids route 1's interior (a 1-entry cluster's link
      excepted);
    - ℓ2 ≥ ℓ1 + 2.
  - A fixture pair whose best second route is ℓ1 + 1 fails validation: the generator
    re-draws, then rejects the seed.
- **AC-KMD-63** [Logic] No band skipping.
  - BFS with all 75 hidden clusters unsealed gives the same d for all 772 visible acupoints as
    the visible graph does.
  - Every cluster with 2–3 entries satisfies |d(L_i) − d(L_j)| ≤ s_ij + 2 for every pair.
  - Fixture: a hidden cluster linked at d 15 and d 21.
    - With s = 3 it is rejected.
    - With s = 4 it is accepted.
    - After unsealing it, the d 21 link still has d 21, and C_reach to it from Đan Điền
      is still 21.
- **AC-KMD-64** [Logic] Crossings.
  - Each of the 5 borders has exactly 5 border-tagged components, each touching both
    neighbouring sectors:
    - the K1, K2 and K3 border segments, of 2, 3 and 3 acupoints;
    - two bridge clusters of 5.
  - No edge joins acupoints of two different sector tags.
  - Bridge links sit on side radials, never on border ring acupoints.
  - Every hidden cluster's links share one tag.
- **AC-KMD-65** [Logic] Entries.
  - Every one of the 125 clusters has 1–3 entries, each linked to a distinct visible
    acupoint. No acupoint hosts two links.
  - Every bridge has exactly 2 entries, one on each side.
  - Every cluster has E ≤ max(1, n − k − 1).
  - The mean over all clusters is 1.85–2.15 (expected about 1.97, guess).
  - Visible links never sit on a hội; hidden links may use a degree-3 hội.
- **AC-KMD-66** [Logic] Shape templates. For each of the 8 shapes, every n from its
  minimum to 15, and every E of 1–3 that has slots:
  - the graph is connected and has the internal edge count in the table;
  - internal degree is ≤ 3, and every entry slot has internal degree ≤ 2;
  - the notable rule passes AC-KMD-21.

  For every combination the shape *supports* (G6), also:
  - for n ≥ 5, every notable is at least 2 steps from its nearest entry (guess).

  A combination without enough slots, or one that fails the distance test, is not
  supported: it falls back (Ring, then Crescent, then Chain) and is never emitted. The
  test runs per cluster role and k: once with k = `floor(n/4)` (visible) and once with
  k = `floor(n/5)` (hidden), and once more for the bridge pair at n 5, E 2.
  - Fixtures that must be unsupported: Ring n 5 with E 3, Ring n 5 as a bridge pair
    (v0, v2), Star n 5 with E 3 and Crescent n 5 with E 3.
  - Fixtures that must be supported: Crescent n 5 as a bridge pair, Chain n 5 with E 3 and
    Ring n 6 with E 3.
  - **Coverage property:** for every n from 3 to 15, every E allowed by
    E ≤ max(1, n − k − 1), and both k values, at least one shape supports the cluster
    (Chain for a non-bridge, Crescent for a bridge). A failure means the fallback can run
    out.

  The same seed gives every cluster the same shape, entries and
  notables. The same seed gives every cluster the same shape, entries and
  notables. The accepted seed and its attempt count are golden values (AC-KMD-08).
- **AC-KMD-67** [Integration, offline generator run] Generator acceptance. Over 200
  consecutive tree seeds, the generator reports how many are accepted (Formulas C and G8).
  - At least 10% are accepted, so 64 attempts fail with probability under 0.2%
    (`0.9^64`). A lower rate fails the test: loosen the checks before raising
    `seed_max_attempts`.
  - The report lists the rejection reason per seed (inner count, capability floor, depth
    fit, shortcut rule, two routes, crossings, degree, link capacity below 1.0). A seed
    whose outer ratio is between 1.0 and `link_capacity_margin` is accepted and listed as
    a warning with its ratio.

**UI (debug terminal; a captured transcript is the evidence)**

- **AC-KMD-56** [UI] At level 38 the terminal shows spent and unspent points and the next
  sources: level 39 +1, the great perfection (đại viên mãn) advance +5 (shown separately) and the Foundation Establishment (Trúc Cơ)
  breakthrough +10.
- **AC-KMD-57** [UI] Before spending, each acupoint shows its value after rule 4 (including
  ×0.25 for an absent element). The path tool shows the route cost and total gain
  before committing.
- **AC-KMD-58** [UI] The captured transcript shows each of these lines:
  - Silhouette: a hidden cluster line has its location and theme and no condition text;
    after the player opens an acupoint next to its entry, the condition line appears.
  - Visible: every cluster line carries its condition; a sealed cluster lists its acupoint
    names and values; an open cluster reads exactly "to be written by the story".
  - A pending unseal line names the realm it waits for.
  - Each fill's repairs are listed one per line, in repair order.
  - Each held capability line has its name and rule text; an idle or suppressed one adds
    its reason ("no pháp bảo", "suppressed by <name>").

**Stat ceilings (Formulas F)**

- **AC-KMD-59** [Logic] With open acupoints carrying 11 pp of breakthrough_chance in total,
  the stat sheet's Kinh Mạch contribution is 8 and the breakdown shows the clamp. At 7 pp
  nothing is clamped. The ceiling applies to an NPC's sheet the same way.

**Variant sectors (rule 20; Formulas H2–H4, G9)**

The base-map criteria (AC-KMD-06, -10, -11, -60, -63, -64, -65) count base acupoints only: anything with a `variant:` tag is outside their totals, including the 24 variant clusters, which are not among the 125. Fixtures set `variant_entry_depth` directly where a chord's e matters. AC-LC-33 and AC-LC-34 cover the root's side; these cover the map's side. A **variant id** is an id in the reserved block of G9.

- **AC-KMD-68** [Logic] Rule 20, locked. Root {Fire 86, Metal 40}, no variant owned, Thunder's Fire host open.
  - All 240 variant acupoints fail `can_allocate` with a reason, spend 0 and are absent from `frontier()`.
  - `path_to` to any of them reports unreachable and spends 0.
  - The host's neighbour list holds no variant id, and its degree reads 2.
  - A Meridian Seal (Mạch Ấn), an event unseal effect and a point spend aimed at a sector each change nothing: points, open set and stat sheet stay identical.
  - The stat sheet has no modifier from a variant acupoint.
- **AC-KMD-69** [Logic] Rule 20, not hinted and not counted, in Silhouette and in Visible.
  - For a life owning no variant, the map listing has 0 entries with a variant id, a `variant:` tag or a sector name. This also holds after switching mode both ways.
  - Opening a host produces no discovery, hint or condition line.
  - Reported size is 772 visible, and the total equals AC-KMD-10's golden value.
  - With Wind owned, those two figures are unchanged and a separate sector line reads 30. With Wind and Blood owned, it reads 60.
- **AC-KMD-70** [Logic] Rule 20, unlocked at birth. Root with Wind, e = 3, host at d 2, no realm reached.
  - `path_to` R1 opens 3 acupoints with 3 points. With 2 points it fails and spends 0.
  - `path_to` the apex (d 15) opens 15 with 15 points. With 14 it fails and spends 0.
  - Opening all 30 from a fresh character spends exactly 32: the 2 base acupoints plus 30, 1 point each.
  - No sector acupoint carries a seal or a realm minimum.
- **AC-KMD-71** [Logic] Rule 20, unlocked mid-life. Root {Fire 86, Metal 40}, Thunder e = 11, 51 points (40 spent, 11 unspent), Fire host open, Metal host closed.
  - When Thunder forms, F1 is in `frontier()` on the same call and M1 is not.
  - Spent stays 40, unspent stays 11 and the open set is unchanged: nothing is refunded.
  - With both hosts closed, no variant id is in `frontier()`, and `can_allocate` on F1 refuses as not connected.
  - After the player opens a host, its entry joins `frontier()`.
  - After a later root change and a save/load, every open sector acupoint stays open and the frontier is unchanged: the sector never relocks.
- **AC-KMD-72** [Logic] Rule 20, nothing new is saved.
  - A save with Wind and 5 sector acupoints open has the same key set as a save of the same life with no variant.
  - The 5 Wind ids sit in the ordinary open list, and no key records an unlocked state.
  - The round trip meets AC-KMD-51: serialising twice gives identical output.
- **AC-KMD-73** [Logic] Rule 20, scale. A sector acupoint's scale is 0.5 + purity/100 for its variant.

  | Purity | Scale | Road 1.5 W | Notable 10 W | Apex 11 W |
  |---|---|---|---|---|
  | 8 | 0.58 | 0.87 | 5.80 | 6.38 |
  | 43 | 0.93 | 1.395 | 9.30 | 10.23 |
  | 50 | 1.00 | 1.50 | 10.0 | 11.0 |
  | 80 | 1.30 | 1.95 | 13.0 | 14.3 |
  | 100 | 1.50 | 2.25 | 15.0 | 16.5 |

  - With Fire 86, Metal 40 and Thunder 47, a Thunder road reads ×0.97, never ×1.36, ×0.9 or a bridge average.
  - An open Thunder road of +1.5 attack gives 1.455, stored as +1.4 on the sheet (floored once, Character Stats Formulas I). A Tẩy Tủy Đan lifting Metal 40 → 48 makes it 1.515, stored as +1.5, on the same call (AC-LC-34 asserts the scale, this the sheet).
  - An open Wind road at purity 62 stays 1.68, stored as +1.6, through that pill.
  - The modifier source is `Kinh Mạch: <name> #<id>` with the variant id.
- **AC-KMD-74** [Logic, data-driven] Rule 20 and H4, content limits, over all 240 acupoints.
  - There are 0 keystones and 0 capabilities.
  - No acupoint carries `breakthrough_chance`, `travel_speed_pct`, `co_duyen_pct`, `ngo_tinh`, `herb_growth_pct`, `alchemy_success` or `lifespan_years`.
  - Every acupoint has 1–2 stats, each positive and each with a weight in `fill_stats`.
  - Each of the 24 clusters has at least 3 distinct stats.
  - The 8 leads are distinct and exactly: `attack_pct`, `stealth`, `cultivation_speed_pct`, `tam_ma_resist_pct`, `dan_doc_resist_pct`, `defense_pct`, `khi_huyet_pct`, `khi_van`.
  - An injected `LlmService` counter reads 0 calls across generation and unlocking.
  - The lint fails on fixtures with `breakthrough_chance` in a sector, 3 stats on one acupoint, and a cluster of 2 distinct stats.
- **AC-KMD-75** [Logic] H2 sizing.
  - Every sector has 30 acupoints: 8 roads and clusters of 4, 9 and 9, in Chain, Ring and Ring shapes.
  - Notables per cluster are 1, 2 and 2: 5 in all, one of them the apex.
  - No draw is made from `entry_count_weights`.
  - A spur has 33 edges (1 host link) and a chord 35 (2 host links).
  - No sector acupoint has degree 4.
  - Mean degree of a sector's own nodes is 65/30 for a spur and 68/30 for a chord.
  - Totals: 240 acupoints (64 roads, 136 smalls, 40 notables, 8 of them apex) and 268 edges (258 internal, 10 host links).
- **AC-KMD-76** [Logic] H2 depths, on the sector's own BFS.

  | Variant | e | Roads | A | B | X | Apex | C_enter | C_clear |
  |---|---|---|---|---|---|---|---|---|
  | Wind | 3 | 3–10 | 6–9 | 8–12 | 11–15 | 15 | 3 | 32 |
  | Blood | 4 | 4–11 | 7–10 | 9–13 | 12–16 | 16 | 4 | 33 |
  | Void | 5 | 5–12 | 8–11 | 10–14 | 13–17 | 17 | 5 | 34 |
  | Chaos | 7 | 7–14 | 10–13 | 12–16 | 15–19 | 19 | 7 | 36 |
  | Light, Ice | 8 | 8–15 | 11–14 | 13–17 | 16–20 | 20 | 8 | 37 |
  | Light or Ice, d 8 host fallback | 9 | 9–16 | 12–15 | 14–18 | 17–21 | 21 | 9 | 38 |
  | Chord fixture | 9 | 9–12 | 11–14 | 11–15 | 13–17 | 17 | 9 | 38 |
  | Chord fixture | 11 | 11–14 | 13–16 | 13–17 | 15–19 | 19 | 11 | 40 |
  | Chord fixture | 13 | 13–16 | 15–18 | 15–19 | 17–21 | 21 | 13 | 42 |

  - Spur notables sit at e+6 (A), e+9 (both of B) and e+12 (apex and second notable of X).
  - Chord notables sit at e+5 (A), e+6 (both of B), e+8 (apex) and e+7 (second notable of X).
  - No sector acupoint is deeper than 21 or shallower than 3.
- **AC-KMD-77** [Logic] H2, no band skipping.
  - These states give the same d for all 772 visible acupoints and every hidden-cluster acupoint: no sector unlocked, each sector alone (8 runs), all 8 unlocked, and each of those with all 75 hidden clusters sealed and unsealed.
  - Each sector's depths are identical alone and with all unlocked.
  - For all 240 acupoints, the route cost from Đan Điền alone equals d.
  - Shortcut pairs: chord hosts Δ0 ≤ 9 (s 7), R5/R6 and M2/M3 Δ1 ≤ 3 (s 1), F4/M4 Δ0 ≤ 3 (s 1).
  - Fixture: chord hosts at d 10 and d 12 are accepted, base depths are unchanged, and the sector's deepest acupoint is d 19. Hosts at d 10 and d 13 are rejected (`variant_chord_depth_gap`).
- **AC-KMD-78** [Logic, data-driven] H3 unit values and checks.
  - Road 1.5, small 1.5, notable 10.0 and apex 11.0 W.
  - Roads 12.0, A 14.5, B 30.5, X 31.5.
  - W_sector 88.5 and 88.5/30 = 2.95 W per point.
  - Small 1.5 ≤ 1.8 and notable 10.0 ≤ 10.0.
  - Wind's X: d_entry 11, n 9 gives P = 1.4671 (±0.0005) and E_notable = 11.74. An 11.0 W apex passes. A 12 W apex fails.
  - `variant_apex_ratio` 1.17 passes and 1.18 fails.
  - Budgets: A 14.5 ≤ 14.5, B 30.5 ≤ 30.5, X 31.5 ≤ 35.80 (Wind, the lowest).
  - The largest scaled acupoint is 16.5 W, below 50.
- **AC-KMD-79** [Logic, data-driven] H3 gain, with fixture constants w̄_target = 2.07 and P_LK = 106, using `assert_near`.

  | Purity | W_scaled | G | g_QR | g_FE |
  |---|---|---|---|---|
  | 8 | 51.33 | −10.77 | −10.16 % | −4.34 % |
  | 20 | 61.95 | −0.15 | −0.14 % | −0.06 % |
  | 21 | 62.835 | +0.735 | +0.69 % | +0.30 % |
  | 43 | 82.305 | +20.205 | +19.06 % | +8.13 % |
  | 50 | 88.5 | +26.4 | +24.91 % | +10.63 % |
  | 70 | 106.2 | +44.1 | +41.60 % | +17.75 % |
  | 80 | 115.05 | +52.95 | +49.95 % | +21.32 % |
  | 100 | 132.75 | +70.65 | +66.65 % | +28.44 % |
- **AC-KMD-80** [Logic, data-driven] H4 themes.
  - The W split per variant sums to 88.5 (±0.02):

    | Variant | Lead | Stat 2 | Stat 3 | Sector power after flooring (±0.01, provisional) |
    |---|---|---|---|---|
    | Thunder | 42.0 | 29.0 | 17.5 | 87.84 |
    | Darkness | 30.5 | 39.0 | 19.0 | 87.67 |
    | Chaos | 23.32 | 48.68 | 16.5 | 87.76 |
    | Light | 42.0 | 29.0 | 17.5 | 87.88 |
    | Ice | 55.2 | 16.8 | 16.5 | 87.22 |
    | Wind | 42.0 | 29.0 | 17.5 | 88.10 |
    | Blood | 42.0 | 29.0 | 17.5 | 87.54 |
    | Void | 13.3 | 30.0 | 45.2 | 86.92 |

  - Every value is a whole count of its Formulas F precision, floored, and no sector exceeds 88.5 W.
  - Each piece carries the stats of H4's standard map or the variant's override.
  - Apex notables:
    - Thunder and Wind: 11.0.
    - Darkness and Light: 7.3.
    - Blood: 9.1.
    - Chaos: speed 2.0, `linh_luc_pct` 6.6.
    - Ice: decay 0.40, resist 4.8.
    - Void: `khi_van` 0.50, `than_thuc_pct` 6.5.

    Each is at most 11.0 W.
  - Compounding caps (A / B / X):
    - Chaos `cultivation_speed_pct` 2.6 / 4.0 / 4.0 against 2.667 / 4 / 4.
    - Void `khi_van` 0.66 / 1.00 / 1.00 against 0.667 / 1 / 1.
    - Ice `dan_doc_decay` 0.5 / 0.8 / 0.8 against 0.533 / 0.8 / 0.8.
  - No other sector stat has a compounding cap.
  - The validator fails fixtures with Chaos X at 4.1, Void A at 0.67 and Ice A at 0.54.
- **AC-KMD-81** [Logic] G9, determinism and isolation.
  - Two generations and two lives with different character seeds give identical variant ids, tags, edges, host links, kinds, modifiers and d. Positions join this check when the Game UI sets them (Open Question 16).
  - With G9 on and off, the AC-KMD-08 base hash, accepted seed, attempt count and all base counts are identical. The base hash excludes variant acupoints and the 10 host links, which belong to the variant hash.
  - Variant data matches its own golden hash.
  - Changing one `variant_stats` value changes the variant hash and leaves the base hash unchanged.
  - An injected counter shows G9 draws only from `rng("variant:"+id)`, in the order `phong`, `huyet`, `hu_khong`, `loi`, `am`, `hon_don`, `quang`, `bang`.
  - Every acupoint has the integer id 100000 + 100·slot + n (slot 0–7 in catalogue order, n 0–29: roads, then A, B and X), the tag `variant:<id>` and no sector tag.
  - G5–G7's regions, neighbours and link slots, and G8's crossing result, are identical with and without G9.
- **AC-KMD-82** [Logic] G9, hosts and graph checks.
  - The 10 hosts are distinct. Each is a road acupoint that is not a junction, keystone or cluster entry, has degree 2 before its link and 3 after, and has d = e − 1.
  - Wind, Blood and Void: a radial at d 2, 3 and 4. Chaos: a K1 ring acupoint at d 6 with a sector tag.
  - Light in Fire and Ice in Water: a radial at d 7.
  - Thunder in Fire and Metal, and Darkness in Earth and Water: both hosts at one depth in d 8–12.
  - On an empty fixture, for χ = 0 and χ = 1, the pools per sector are:
    - 3 at each of d 2, 3 and 4;
    - 4 for Chaos;
    - 3 at d 7, plus 2 at d 8;
    - 13 for chords (L 4, C 3, R 4, 2 connectors).
  - Fixture: with L7, C7 and R7 occupied, Light takes L8 or R8 with e = 9 (depths in AC-KMD-76).
  - Fixture: with the drawn sector's d 2 pool occupied, Wind takes the next sector in cycle order.
  - No edge joins two variant tags.
  - Every acupoint has degree ≤ 4 except Đan Điền (6), and only junctions reach 4.
  - With all sectors in the graph, AC-KMD-60, -63, -64 and -65 still pass, and each border still has exactly 5 crossings.
  - Full-graph mean degree is reported; a value outside `degree_avg_window` is a warning (expected about 2.34, provisional).
- **AC-KMD-83** [Logic] G9, failure. Fixture: every fallback in Thunder's order is empty.
  - The content build fails and the error names `loi`.
  - The seed does not move, the attempt count is unchanged, and G1–G8 do not re-run.
  - The base hash is unchanged and no partial variant data is emitted.
  - The launch seed passes G9.
- **AC-KMD-84** [Logic] Chords. Root {Fire 86, Metal 40}, Thunder 47, base roads 1.2 W, open set = Đan Điền plus the route to the Fire host.
  - Each chord has exactly 2 entries, F1 and M1, each joining `frontier()` when its host is open.
  - e = 11 (hosts at d 10): for the holder, `path_to` the Metal host is the chord, 9 acupoints. For a life without Thunder it is the base route, 10 acupoints, with no variant id.
  - e = 10 (hosts at d 9): both routes cost 9. The holder takes the chord at 12.72 W rather than the base 9.72 W (rule 3).
  - e = 9 (hosts at d 8): the holder takes the base route, 8 acupoints.
  - After the holder opens the chord, the Metal host's d is still 10, and a fresh character's route cost to it is still 10.
- **AC-KMD-85** [Logic] NPCs, fixed seed, random term injected as 0, `tree_kind_scores` small 1 and notable 4, `tree_focus_weight` 2.
  - An NPC owning Thunder may open Thunder acupoints, and every open is legal. An NPC owning no variant opens none of the 240.
  - Points spent = min(points, reachable), and reachable includes owned sectors only.
  - A Fire-archetype NPC scores a Thunder road 1 and a Thunder notable or apex 4, the same at `tree_focus_weight` 0 and 2.
  - Repeat runs are identical.
- **AC-KMD-86** [Logic] Edge cases. A closed host is covered by AC-KMD-71.
  - Absent element: root {Water 60} + Wind 50, host in Earth. `path_to` R1 costs 3 and previews 0.30 + 0.30 + 1.50 = 2.10 W.
  - Low purity: Light at purity 8 (Fire 10). `can_allocate` passes, and a road previews 0.87 W. Nothing blocks a sector for low purity.
  - Two variants: {Fire 86, Metal 40} + Thunder 47 + Light 69.
    - Each sector unlocks on its own, at ×0.97 and ×1.19.
    - A point in one changes nothing in the other.
    - No route between them stays inside variant tags.
    - After Metal 40 → 48, Thunder reads ×1.01 and Light ×1.19.
  - Edited save: an open variant id on a root that lacks the variant is skipped, its point returns as unspent, and one line is logged, as for an unknown id (AC-KMD-53).
- **AC-KMD-87** [UI] Variant sectors on screen. Evidence is a retained screenshot of each state in `production/qa/evidence/`, from a windowed run per `.claude/docs/run-and-observe.md`, not a transcript alone.
  - Locked: a life owning no variant, one shot in Silhouette and one in Visible, showing no sector, name, hint or host marker.
  - Unlocked: Thunder shows its name, purity 47 and scale ×0.97.
  - Mid-life: on forming, the screen shows where the sector appeared and which host opens it.
  - Before spending: a Light road at purity 8 shows 0.87 W (AC-KMD-57).
- **AC-KMD-88** [Integration, offline generator run] G9 over every seed accepted in AC-KMD-67's 200-seed run, in report mode.
  - The report lists G9 pass or fail per seed, with the variant and reason for each failure.
  - It also gives hosts left per pool, full-graph mean degree, and middle and inner link ratios with variant demand added.
  - Pass: at least 90 % of accepted seeds pass G9 (provisional).
  - Ratios are expected at about 1.58 Fire and Water, 1.73 Earth and Metal, 1.90 Wood and 1.45 inner (provisional). A ratio below `link_capacity_margin` is listed as a warning, as in G7.
- **AC-KMD-89** [Integration, Bot: `autoplay.gd`, ≥ 60 lives per arm = 20 seeds × 3 origins] Lives holding a sector. Arms are Wind at purity 50, Thunder 47 and Chaos 44, each told to clear its sector in Qi Refining and paired with the same seeds with sector spending off.
  - The printed output gives each arm's median tree power at Qi Refining great perfection, separately from AC-KMD-07's median.
  - The Wind arm's gain is +15 to +35 W (expected +26.4, provisional).
  - Breakthrough success in every arm stays inside AC-KMD-50's `autoplay.gd` windows, 0.70 ± 0.10 with edge on and 0.30 ± 0.10 with edge off.

**Still provisional:**
- AC-KMD-01 and AC-KMD-02 at L ≥ 267 depend on Open Question 2 (the realm after Hóa
  Thần).
- Capability behaviours are tested in each host system's GDD; here only presence, data
  and the guard are covered.

**Map density (added 2026-11-05)**

- **AC-KMD-90** [Logic] Rule 21, roads. Every road and junction carries only `road_stats` and has scale 1.0 on any root. Every gate still scales by purity.
- **AC-KMD-91** [Logic] Rule 21, gaps. Every border inner, middle and outer region holds at least one cluster.
- **AC-KMD-92** [Logic] Rule 21, capacity. No region's load exceeds `region_capacity`, and every inner hidden cluster has n ≤ `inner_cluster_size_max`.
- **AC-KMD-93** [Logic] Rule 21, strength. A cluster shrunk from n_rolled to n has premium × n_rolled ÷ n.
- **AC-KMD-94** [Logic] G5–G7, wiring. All of a cluster's links lie on its region's boundary, and no two clusters in a region have interleaved links.
- **AC-KMD-95** [Integration] UI Requirements, drawing. `tools/meridian-map/build.js` reports 0 crossings and 0 acupoints under `map_clearance` on the launch seed.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | ~~May a Thiên Định life choose Visible mode?~~ **Resolved 2026-11-03:** any life chooses either mode at creation and can switch during play (rule 13) | user | — |
| 2 | What comes after Deity Transformation (Hóa Thần) (an end, more realms, or ascension)? **Deferred by the user 2026-11-03.** The placeholder next bonus of 90 stands, so the level-300 advance is 32 points | user + Cảnh Giới GDD | Nothing for now |
| 3 | Level bands, tu vi per level and the size of the stat rise at each great and small breakthrough | Cảnh Giới GDD | Formulas A; implementation |
| 4 | The fixed list of cluster themes, and whether each theme gets a stat whitelist (so a Đan Đạo cluster can't be all attack) | game-designer | Fill validator; sealed authoring |
| 5 | Capability tiers by measurement (only 5 of 25 have a provisional tier) and the list of incompatible pairs | systems-designer + bot | Formulas E; rule 18 |
| 6 | Content plan for about 50 fully authored sealed clusters (about 450 huyệt) and the sector keystones (2 per sector, 10 in all) | user + writer | Content release 1 |
| 7 | ~~Is φ_r a dead parameter?~~ **Resolved 2026-11-03:** φ_r is now the per-cluster ceiling on summed lifespan_years (Formulas F) | systems-designer | — |
| 9 | #14 Động Phủ Tùy Thân: the user suggested it may need notables from two clusters (Trận Đạo and Linh Điền). This revision keeps rule 16 (one notable, one cluster) and places it on a hybrid-theme cluster. Does the capability instead require both clusters? That would need a new rule and a changed seed check | user | Rule 16; AC-KMD-41 |
| 8 | Recalibrate breakthrough targets and NPC cohorts on the level ladder with rescaled values (Formulas A, A2) before any of it ships | Balance harness | Implementation sign-off |
| 10 | ~~Is the center keystone Ngũ Hành Luân Chuyển adjacent to Đan Điền or behind the gates?~~ **Resolved 2026-11-03:** adjacent to Đan Điền at d 1 (a 1-point take for a 5-element root). Đan Điền is exempt from the 4-link limit (degree 6) | user | — |
| 11 | Cap on event point grants per realm (the Event Engine's budget file should set it) | Event Engine GDD | Rule 2 |
| 12 | ~~The map generator's topology~~ **Design decided 2026-11-03** (rule 1, Topology: kinh lộ highways, hội huyệt, 1–3 entries, flexibility limits, 5 crossings per border, a shape catalogue). The generator spec and sizing are in Formulas H. AC-KMD-08's golden hash is set when the generator is built | technical-director (generator spec) | — |
| 13 | Where Meridian Seal (Mạch Ấn) keys come from (loot, shop, event reward), and the intended number of clusters a typical life unseals | Item DB + Event Engine GDDs | Item seals; Tuning Knobs target |
| 14 | Should `lifespan_years` get a tree-wide ceiling like `breakthrough_chance`? Today only each cluster is held to φ_r·L_r, so 5 unsealed clusters could add up to 50% of a realm's lifespan | user + systems-designer | Formulas F; balance sign-off |
| 15 | ~~Hidden variant sectors~~ **Answered 2026-11-04** by rule 20, Formulas H2–H4 and G9. Weights for `travel_speed_pct` and `co_duyen_pct` stay open under Spiritual Roots Open Question 2 | — | — |
| 16 | Where variant sectors are drawn. G9 fixes the graph, not positions, and on the wheel the Fire–Metal and Earth–Water chords must cross with no edge between them. **Viewer answer 2026-11-05:** sectors sit outside the rim with paired entry marks. The Game UI confirms or replaces it; the variant hash then includes the positions | Game UI | AC-KMD-81 |
| 17 | Building and content for variant sectors: `path_to` must read the character's owned variants, and the 8 sector names and apex notables need writing. The H3 and H4 values are guesses until AC-KMD-88 and AC-KMD-89 run | content, implementation story | Rule 20 |
