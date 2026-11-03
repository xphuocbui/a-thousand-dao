# Kinh Mạch Đồ (Skill Tree)

> **Status**: Designed (pending /design-review)
> **Creative Director Review (CD-GDD-ALIGN)**: skipped (Lean mode)
> **Author**: user + Claude
> **Last Updated**: 2026-11-03
> **Last Verified**: 2026-11-03
> **Implements Pillar**: Pillar 1 (Your Dao, Your Name), Pillar 3 (Power Is Built, Not Given); touches Pillar 2 (Every Number Is Bounded and Visible)

## Summary

Kinh Mạch Đồ is the game's PoE-style passive tree.
- **The map.** One fixed map of about 1,250 huyệt, growing from Đan Điền through inner,
  middle and outer bands. It is identical in every life and append-only at the rim.
- **Points.** Earned per level (1–300) and at every great and small breakthrough.
- **Value.** Every huyệt's value scales with the linh căn's purity in its element.
- **Hidden clusters.** About 75, mostly at the rim, that points alone can't reach. An
  event, item or công pháp unseals a fully authored **sealed** cluster, which may carry
  one of 25 **capabilities** (rule changes such as dual-wielding pháp bảo or a second
  công pháp). A story moment unseals an **open** cluster, which the LLM fills inside a
  validated budget.
- **Bounds.** Every number is bounded and recorded. NPCs build on the same tree under
  the same rules.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Linh Căn, Character Stats, Cảnh Giới & Bình Cảnh`

## Overview

Kinh Mạch Đồ is the player's Path-of-Exile-style passive tree: one fixed map of huyệt
(acupoints) growing out of Đan Điền in five element sectors, explored by spending Kinh
Mạch points earned at each breakthrough stage. A point opens one huyệt next to an
already-open one; small huyệt carry modest bonuses, notables and keystones carry larger
or trade-off bonuses, and every bonus scales with the player's purity in the huyệt's
element, so a character's linh căn decides which regions of the map are worth walking.
The map is identical in every life, so it can be learned and planned.

On top of that base map sit **hidden clusters**: themed groups of huyệt, mostly on the
outer ring and occasionally deeper inside, that cannot be reached with points alone. A
cluster starts hidden and opens only when its condition is met: an event, an item or a
công pháp. **Sealed clusters** have authored content, identical in every life, so a
player who learns what unlocks which cluster can plan a whole build around it. **Open
clusters** have a fixed place and theme but no fixed content: when a story moment
unlocks one, the LLM writes its huyệt inside an engine-set budget (clamped and recorded
like every LLM number), with a template pool as the offline fallback. Once unlocked, a
cluster is part of that life's tree and its huyệt are opened with points like any other.
What varies between lives is only what fills the open clusters; positions, themes and
conditions never change.

The tree is where Pillar 1 (Your Dao, Your Name) and Pillar 3 (Power Is Built, Not
Given) meet: two cultivators with the same root diverge by the regions they walk and the
clusters their lives earned, and power from a hidden cluster is earned through play,
never picked off a list. It stays inside Pillar 2 (Every Number Is Bounded and Visible)
because every LLM-written value is budgeted and recorded.

## Detailed Design

Rules 2–5 are **built** (debug terminal, `src/gameplay/meridian/`) on a 202-huyệt
prototype map; rule 1 describes the **target map**, which replaces it at PoE scale (about
1,250 huyệt) and is not yet built. Rules 6–19 are the cluster design and are **not yet
implemented**. Quantities in these rules are named parameters; their values and ranges
are in Formulas.

### Core Rules

**The base tree**

1. **The map.** Generated deterministically from `assets/data/meridian_tree.json` (fixed
   seed), so it is identical in every life. About `tree_size_target` huyệt (about 1,250:
   about 600 visible, about 675 in hidden clusters), laid out from the core outward in
   bands:
   - **Core:** Đan Điền at the center and five element gates in tương sinh order,
     clockwise from the top (Mộc → Hỏa → Thổ → Kim → Thủy). A center keystone, Ngũ Hành
     Luân Chuyển, needs all five base elements.
   - **Inner band:** path huyệt and small visible clusters, reachable in Luyện Khí;
     rare inner hidden clusters.
   - **Middle band:** visible base clusters and bridge clusters between neighbouring
     element sectors.
   - **Outer band:** keystones and most hidden clusters.
   - **Expansion band:** reserved beyond the rim and empty at launch (rule 19).

   The map is built from six kinds of piece:

   | Piece | Visible | Content |
   |---|---|---|
   | Path huyệt | yes | Small stats of its sector's element; connects regions |
   | Base cluster | yes | A wheel of small huyệt around 1–3 notables, generated from its theme's pool (themes such as Kiếm Ý, Hộ Thể, Linh Lực, Khí Huyết, Thần Thức, Đan Đạo, Luyện Khí, Trận Đạo, Phù Đạo, Ngự Thú, Linh Điền, Thọ Nguyên, Tâm Cảnh, Khí Vận, Độn Thuật) |
   | Bridge cluster | yes | Mixes the two neighbouring sectors' elements |
   | Keystone | yes | One trade-off rule; two per sector at the rim plus the center (11) |
   | Sealed cluster | hidden | Fully authored (rule 12); may carry a capability (rule 16) |
   | Open cluster | hidden | Written by the LLM at its story moment, inside the budget (rules 10–11) |

   The prototype built today is a 9-ring, 202-huyệt version of the same layout: gates on
   ring 1, notables on rings 3, 5 and 7, keystones on ring 9, bridges on rings 3, 6 and 8.
2. **Points.** Cultivation runs on **levels 1–300**. Each realm is a band of levels, and at
   the top of the band the bình cảnh holds the level until the realm breakthrough succeeds.
   Points come from:
   - **Birth:** 2.
   - **Levels:** 1 point per level gained. A level gives points only; stat rises come from
     breakthroughs.
   - **Great breakthroughs:** entering a new realm (its sơ kỳ). Each one has a bonus
     (`breakthrough_bonus`: Trúc Cơ 15, Kết Đan 25, Nguyên Anh 40, Hóa Thần 60).
   - **Small breakthroughs:** inside each realm, sơ kỳ, trung kỳ and hậu kỳ split the
     realm's levels into thirds, and đại viên mãn is the realm's last level.
     - Reaching **trung kỳ** grants 15% of the next great breakthrough's bonus, and **hậu
       kỳ** 25%. These are extra.
     - Reaching **đại viên mãn** grants 35% of it as an **advance**, so the great
       breakthrough then pays the remaining 65%.
   - **Events:** an event may grant 1.
   - Every great and small breakthrough also raises base stats.

   Totals at đại viên mãn: Luyện Khí 51, Trúc Cơ 120, Kết Đan 216, Nguyên Anh 357, Hóa Thần
   566 (with a placeholder for the realm after Hóa Thần). Formulas has the exact
   computation. Cảnh Giới & Bình Cảnh owns the level bands, the stat rises and these
   values, and the Event Engine owns event grants; they are provisional here. The built
   prototype still uses the old ladder (stages, 1/3/4/5/6 points per stage, 86 at most).
3. **Opening a huyệt** costs 1 point. It must not already be open, must be adjacent to an
   open huyệt, and, for a huyệt that names a minimum element count, the player's linh căn
   must have that many base elements. Opening a path to a target opens every huyệt on the
   shortest route, all or nothing: it fails without spending anything if the points do not
   cover the whole route. Points are never refunded and there is no respec.
4. **Bonuses.** Each open huyệt adds its stat modifiers to the character's stat sheet under
   the source "Kinh Mạch: <name> #<id>". A sector huyệt's values are multiplied by
   0.5 + purity/100 for the sector's element, or by 0.25 if the player lacks that element;
   a bridge huyệt uses the average of its two sectors' multipliers; keystones and the root
   are exact. So purity, not just element count, decides which regions pay off.
5. **NPCs** spend their points greedily under the same rules: every reachable huyệt is
   scored by its kind and boosted if it lies in a sector favoured by the NPC's archetype,
   with a small random term, until the points run out. The weights are
   `tree_kind_scores` and `tree_focus_weight` in `world_generation.json`.

**Hidden clusters (new)**

6. **A hidden cluster** is a fixed group of huyệt in the map data. It has:
   - an id and a name;
   - a **theme**, which is a system the game already has (Đan Đạo, Luyện Khí, Trận Đạo,
     Phù Đạo, Ngự Thú, Thần Thức, Thọ Nguyên, Tâm Cảnh, and so on);
   - an element affinity;
   - a **location**: *outer*, in the outer band (the usual case), or *inner*, in the
     inner or middle band (rare);
   - one or two entry links to existing huyệt;
   - a **kind**, *sealed* or *open*;
   - exactly one **seal condition**;
   - a **size** of 3 to 15 huyệt, drawn from a normal distribution
     (`cluster_size_mean`, `cluster_size_sd`) once with the tree seed and then fixed.

   A cluster has one notable per `huyet_per_notable` huyệt (1 to 3), the theme's payoff,
   placed farthest from the entry so the player pays for the small huyệt first. Each
   notable's route distance from the nearest entry is at least that of every small huyệt
   in the cluster. Its size
   sets its minimum realm (`size_realm_gates`); an inner cluster's gate is one realm
   lower, so the rare inner cluster can open in Luyện Khí. The number of clusters, and each
   cluster's location and kind, are rolled once with the tree seed (`cluster_count`,
   `inner_share`, `sealed_share`). No type has a fixed count. The cluster list,
   positions, sizes, themes and conditions are the same in every life.
7. **Seal conditions.** Each cluster has exactly one, fixed in data, with an optional
   minimum realm:
   - *event*: an Event Engine effect that unseals this cluster, carried only by the event
     template authored for that cluster (a sealed cluster can never be unsealed by an
     LLM-invented event);
   - *item*: a Mạch Ấn key item bound to this cluster is used and consumed;
   - *công pháp*: a công pháp that lists this cluster is the active công pháp for a number
     of seasons (`cong_phap_seasons`). The seasons add up and need not be in a row:
     switching to another công pháp pauses the count, and it never resets.
   Open clusters are unsealed only by the *story moment* effect (rule 10).
8. **Hidden state.** While hidden, a cluster's huyệt cannot be opened, are not part of the
   frontier, and are never routed through by the path tool. Nothing refunds or bypasses
   this: points cannot buy a seal open.
9. **Unsealing.** When the condition is met and any realm minimum holds, the cluster
   becomes unsealed in that life, the world records an event of type "cluster unsealed"
   (player, cluster, source) in the World Database, and the cluster's entry huyệt join the
   frontier wherever they touch an open huyệt. Unsealing grants access only; every huyệt
   is still opened with points under rule 3.
10. **Open clusters and the fill.** An open cluster is unsealed by a *story moment*: an
    event whose effect asks to unseal an open cluster, within the per-realm allowance
    (`open_unseals_per_realm`).
    - **Eligible clusters** are hidden open clusters whose gate is at or below the
      player's realm.
    - **The choice is deterministic.** Among the eligible clusters, the engine takes those
      with the theme the event hints, if any have it. It then takes the nearest by route
      length from the player's open huyệt, then the lowest cluster id.
    - **The fill.** The chosen cluster then needs its huyệt names, descriptions and
      bonuses. The engine sends the LLM a fill request with:
      - the theme and element affinity;
      - the cluster's budget (Formulas F);
      - the unlocking event's people, place and text.
    - **Validation.** The reply is repaired by the validator (rule 11).
    - **Fallback.** The fill comes from the theme's template pool if the LLM is off,
      fails, or returns a reply the validator cannot repair: invalid JSON, or a huyệt
      left with no stat after repair. So a fill always completes.
    The final fill is recorded in the World Database and the player's record; from then on
    it is canonical and is never rewritten, so planning stays possible.
11. **The fill budget (Pillar 2).** A fill may use only stat keys on an allowed list
    (`fill_stats`), values inside per-stat caps, at most the cluster budget in summed
    weighted value, and exactly the cluster's huyệt count and notable count. Budgets
    depend on the cluster's depth and size, not on the player's realm; only the lifespan
    weight uses the realm. Anything outside is repaired in the order Formulas F lists,
    each repair is recorded on the fill, and the adjustments are shown to the player. No fill may contain
    a trade-off keystone, a capability or any other rule change (for example "single
    artifact"), or a flag stat.
12. **Content of sealed clusters** is fully authored in data: every huyệt's name,
    description and modifiers is written by hand, not generated. The stats are held to the
    same budget formula as fills, so authored and LLM clusters at the same reach are
    comparable. A notable that carries a capability carries fewer stats
    (`capability_stat_share`). A cluster's modifiers scale with its affinity element
    exactly as rule 4.
13. **Visibility modes** (a per-life setting fixed at character creation):
    - **Silhouette**: a hidden cluster shows on the map by its location and theme only; its
      content stays hidden and its condition is revealed only after a *discovery*. A
      discovery happens when the player opens a huyệt adjacent to the cluster's entry, or
      when an event, an NPC conversation or an item grants the hint.
    - **Visible**: every cluster shows its location and theme from the start, with its
      condition and, for sealed clusters, its content; an open cluster shows "to be
      written by the story".
    Default: Thiên Định lives use Silhouette, Tự Định lives use Visible.
14. **NPCs.** When a gifted NPC is generated, it may have sealed clusters unsealed, with a
    chance that rises with its realm and edge score (`npc_unseal_chance`, Progression
    Edges owns the edge score); never open clusters, which need the LLM. Unsealed
    clusters then take part in the NPC's allocation under rule 5. An NPC holding a
    capability gets its simplified `npc_effect`, within the caps in Formulas G.
15. **Per-life state** held by the character and saved with it: the unsealed clusters, the
    discovered hints, the recorded fills and the visibility mode.

**Capabilities (thần thông)**

16. **A capability** is a rule change, not a stat: it lets the character do something the
    rules otherwise forbid. Capabilities are an authored catalogue in data
    (`meridian_capabilities.json`). Each one sits on one notable of one outer sealed
    cluster of at least `cap_min_n` huyệt, and the authoring decides where; there is no
    roll. The size floor keeps every capability behind the Kết Đan gate, so none can
    affect the first two breakthroughs. About a third of all hidden
    clusters carry one, so every catalogue entry appears somewhere in the tree. Open
    clusters never grant a capability. Opening the notable grants it for the rest of the
    life. Each capability's numbers are parameters in its catalogue entry.
17. **The launch catalogue** (25 entries, grouped by the theme of the cluster that holds
    them):

    | # | Capability | Rule | System touched |
    |---|---|---|---|
    | 1 | Song Khí Hợp Bích | Two pháp bảo of the same kind work as a pair: both at full power, +15% attack for the pair | Pháp bảo, Combat |
    | 2 | Thần Thức Phân Hóa | +1 pháp bảo slot and +20% thần thức | Pháp bảo, Character Stats |
    | 3 | Dưỡng Bảo Nội Thể | One chosen pháp bảo costs no thần thức and grows +1% per year carried, up to +50% | Pháp bảo |
    | 4 | Huyết Ngự Linh | 20% of khí huyết counts as linh lực; below 30% khí huyết, −20% in combat | Character Stats, Combat |
    | 5 | Linh Hồn Xuất Khiếu | Once per realm, survive a death in an event at 5% khí huyết, losing one stage | Event Engine, Cảnh Giới |
    | 6 | Song Tu Công Pháp | Cultivate a second công pháp at 50% speed with its full bonuses | Công Pháp |
    | 7 | Thai Tức Quy Nguyên | Age at three-quarters speed during bế quan | Thọ Nguyên |
    | 8 | Mộng Trung Ngộ Đạo | Seasons spent travelling also cultivate, at 50% rate | Cultivation, Travel |
    | 9 | Hấp Tinh Đại Pháp | Defeating a cultivator gives tu vi worth 5% of the current stage; tâm ma +2 each time | Combat, Tâm Ma |
    | 10 | Đan Hỏa Phân Lô | Brew two recipes in one season | Luyện Đan |
    | 11 | Dị Đan Hóa Sinh | A failed brew has a 30% chance of a random mutated pill within budget instead of ash | Luyện Đan |
    | 12 | Bách Thảo Tàng Linh | Harvested herbs keep aging in the bag at half speed | Herbs |
    | 13 | Phù Lục Bất Tận | 30% chance a used talisman is not consumed | Phù Lục |
    | 14 | Động Phủ Tùy Thân | Formations and linh điền work wherever the character is; the field can be tended anywhere | Trận Pháp, Linh Điền |
    | 15 | Trận Trung Trận | Formations may exceed their maximum by 2 levels; upkeep for those levels ×2 | Trận Pháp |
    | 16 | Vạn Thú Đồng Tâm | +2 linh thú kept; loyalty never drops below 30 | Linh Thú |
    | 17 | Thú Hồn Hợp Thể | The strongest linh thú adds its full chiến lực instead of half | Linh Thú, Combat |
    | 18 | Thiên Cơ Diễn Toán | See every choice's success and failure outcomes before choosing | Event Engine |
    | 19 | Khí Vận Chi Tử | Once per realm, reroll a failed event check | Event Engine |
    | 20 | Liễm Tức Ẩn Thân | Others see the character two stages lower; hostile events −30% frequency | Event Engine, NPCs |
    | 21 | Thuấn Di Ấn | Once a year, travel instantly to any visited place | Travel |
    | 22 | Hồi Quang Phản Chiếu | With under 5 years of thọ nguyên left, breakthrough chance ×2 | Cảnh Giới |
    | 23 | Thiêu Thọ Phá Cảnh | After a failed breakthrough, burn 10 years of thọ nguyên to retry at once | Cảnh Giới, Thọ Nguyên |
    | 24 | Biến Dị Khai Mở | Each realm breakthrough rolls one extra chance at a new biến dị | Linh Căn |
    | 25 | Tâm Ma Hóa Lực | Tâm ma above 50 adds attack (+tâm ma ÷ 2 %); backlash chance ×2 | Tâm Ma, Combat |

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

19. **The map is append-only.** Every huyệt and cluster keeps its id and position
    forever. New content is added only in the expansion band beyond the rim, linked to
    existing outer huyệt, and never moves, renumbers or reshapes anything already there.
    Saves, recorded fills, World Database events and the Codex stay valid across content
    updates. The fixed seed applies to each content release separately, so adding a
    release never rerolls an earlier one.

**What the player cannot do:** refund or respec; open a hidden huyệt; unseal by paying
points; choose or edit what fills an open cluster; see an open cluster's content before its
story moment, even in Visible mode.

### States and Transitions

| Subject | State | Becomes | When | Guard |
|---|---|---|---|---|
| Cluster | Hidden | Unsealed | Its one condition fires | Sealed kind; realm minimum met; not already unsealed |
| Cluster | Hidden | Awaiting fill | A story moment unseals it | Open kind; per-realm allowance left; chosen by rule 10 |
| Cluster | Awaiting fill | Unsealed | The fill is recorded | Always completes (LLM or template pool) |
| Cluster | Unsealed | (stays) | Never goes back | Unsealing is permanent for the life |
| Huyệt | Closed | Open | The player spends 1 point | Rule 3; its cluster, if any, is Unsealed |
| Huyệt | Open | (stays) | Never closes | No refund, no respec |
| Capability | Not held | Held | Its notable is opened | Sealed cluster only; held for the rest of the life |

A hidden or awaiting-fill cluster's huyệt are Closed and cannot be opened.

### Interactions with Other Systems

All interfaces are provisional where the other GDD does not exist yet.

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Linh Căn | in | purity per element, base element count (rule 3, 4) | Linh Căn |
| Character Stats | out | modifiers {source, stat, value}; the tree never computes a stat | Character Stats (stat keys and their meaning) |
| Cảnh Giới & Bình Cảnh | in | points per stage and per breakthrough; the realm (realm minimum, budgets) | Cảnh Giới |
| Event Engine | in | effects "unseal this cluster" and "story moment: unseal an open cluster", both gated by the budget file; the existing "grant a point" effect | Event Engine (gating); this GDD (what the effects do) |
| Item DB | in | Mạch Ấn key items bound to a cluster | Item DB (item kind); this GDD (what the key does) |
| Công Pháp | in | a công pháp's list of clusters it can unseal, and active-seasons tracking | Công Pháp (record); this GDD (the rule) |
| LLM Game Master | out/in | fill request out; fill reply in; validated by this GDD's budget | this GDD (budget and schema); LLM Game Master (transport) |
| World Database | out | "cluster unsealed" events and recorded fills, searchable by player and cluster | World Database |
| NPC Builds | in/out | allocation and clusters unsealed at generation | NPC Builds (generation); this GDD (cluster rules) |
| Combat | none direct | only the stat modifiers above | — |
| Capability hosts (Pháp bảo, Công Pháp, Luyện Đan, Herbs, Phù Lục, Trận Pháp, Linh Điền, Linh Thú, Travel, Thọ Nguyên, Tâm Ma, Event Engine, Cảnh Giới, Linh Căn) | out | "character holds capability X" queries; each host system implements the rule change behind its capabilities | this GDD (catalogue and when one is held); each host system (the behaviour) |
| Guidance Layer / Debug Terminal / Game UI | out | map with silhouettes and hints, visibility mode, "an unsealed cluster has unopened huyệt" goals | Guidance Layer |
| Save/Load | out | the per-life state of rule 15 and the fill records | Save/Load |

## Formulas

Values are in **W**, a common power unit: 1 W = the value of +1% attack. A huyệt's
power is the weighted sum of its modifiers (formula F1). All values marked "guess"
need a bot run (`tools/balance/autoplay.gd`, `tools/balance/npc_cohort.gd`) before
they are trusted. Rounding is half away from zero (GDScript `round()`) everywhere.

### A. Points

The points_total formula is defined as:

`points_total(L) = pts_birth + (L − 1) + Σ_i bonus_i(L) + pts_event`

where, for each realm i with levels [lo_i, hi_i], N_i = hi_i − lo_i + 1, its own bonus
B_i and the next realm's bonus B_next:

`bonus_i(L) = [L ≥ lo_i]·(B_i − round(α_d·B_i)) + [L ≥ t_i]·round(α_t·B_next) + [L ≥ h_i]·round(α_h·B_next) + [L ≥ hi_i]·round(α_d·B_next)`

with `t_i = lo_i + floor(N_i/3)` (first level of trung kỳ) and
`h_i = lo_i + floor(2·N_i/3)` (first level of hậu kỳ). Luyện Khí has no entry term.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| L | int | 1–300 | calculated | Highest level ever reached (a level lost later never takes points back) |
| pts_birth | int | 2 | data file | Points at birth |
| lo_i, hi_i | int | Luyện Khí 1–39, Trúc Cơ 40–79, Kết Đan 80–129, Nguyên Anh 130–199, Hóa Thần 200–300 | data file | Realm level bands (provisional; Cảnh Giới owns them) |
| B_i | int | Trúc Cơ 15, Kết Đan 25, Nguyên Anh 40, Hóa Thần 60; after Hóa Thần 90 (placeholder) | data file | Great breakthrough bonus |
| α_t, α_h | float | 0.15, 0.25 | data file | Trung kỳ and hậu kỳ shares of the next bonus (extra) |
| α_d | float | 0.35 | data file | Đại viên mãn share of the next bonus (advance, deducted from the breakthrough) |
| t_i, h_i | int | e.g. Luyện Khí 14 and 27, Trúc Cơ 53 and 66 | calculated | First level of trung kỳ and hậu kỳ |
| pts_event | int | 0+ | calculated | Event grants, +1 each |
| points_total | int | 2–566 (+ events) | calculated | Points earned in the life |

**Output Range:** 2 at level 1 to 566 at level 300, plus events; never decreases.

| Point | Level | Total |
|---|---|---|
| Luyện Khí đại viên mãn | 39 | 51 |
| Trúc Cơ sơ kỳ | 40 | 62 |
| Trúc Cơ đại viên mãn | 79 | 120 |
| Kết Đan sơ kỳ | 80 | 137 |
| Kết Đan đại viên mãn | 129 | 216 |
| Nguyên Anh sơ kỳ | 130 | 243 |
| Nguyên Anh đại viên mãn | 199 | 357 |
| Hóa Thần sơ kỳ | 200 | 397 |
| Hóa Thần đại viên mãn | 300 | 566 |

**Example:** Level 60 (Trúc Cơ trung kỳ):
- 2 at birth + 59 from levels.
- Luyện Khí bonuses: 2 + 4 + 5.
- Trúc Cơ entry: 15 − 5 = 10.
- Trúc Cơ trung kỳ: round(0.15·25) = 4.
- Total: **86**.

### A2. Huyệt value scale

Lives earn about 3.6× more points than the old stage ladder (51 vs 14 at Luyện Khí's
end), so huyệt values are scaled down to keep a typical life's tree power unchanged.

The value_scale formula is defined as:

`k_pts = points_total(anchor) / points_old(anchor)` ; `S0 = S0_old / k_pts` (rounded to a clean value) ; `N0 = N0_old / k_pts` (re-split) ; `w̄ = (1 − ν)·S0 + ν·N0`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| anchor | — | Luyện Khí đại viên mãn | constant | The most common life end |
| points_old, points_total | int | 14, 51 | calculated | Old and new points at the anchor |
| k_pts | float | 3.64 | calculated | Points multiplier |
| S0_old, N0_old | float | 5 W, 22 W | calculated (from `meridian_tree.json`) | Old small and notable values |
| S0, N0 | float | 1.2 W, 8 W | data file | New base small and notable values |
| ν | float | 0.134 | calculated (H) | Share of notables among visible huyệt |
| w̄ | float | ≈ 2.1 W | calculated | Mean W per point |
| Keystone | float | ≥ 50 W | data file | Keystones keep full strength; not rescaled |

**Output Range:**
- Tree power at Luyện Khí's end stays about 106 W.
- At Hóa Thần đại viên mãn it is about 566 × 2.1 ≈ 1,190 W, about 1.8× the old ladder's
  650 W: a deliberate tilt toward later realms.
- Without the rescale it would be about 4,100 W (6.3×).

**Example:** The old mean is 7.55 W per point. Divided by 3.64 it is 2.07. The split is
S0 = 1.2 and N0 = 8, which keeps notables about 6.7× a small huyệt:
(1 − 0.134)·1.2 + 0.134·8 = 2.11 W per point. A typical small huyệt becomes +1.2%
attack (or +0.5% cultivation speed); a notable +8% attack.

### B. Band depth and reach cost

Depth d(x) is the route length from Đan Điền, computed once by BFS when the map is
generated.

| Band | Depth | Contents |
|---|---|---|
| Core | 0–1 | Đan Điền, 5 gates, center keystone |
| Inner | 2–6 | Paths, small visible clusters; inner hidden clusters link at d 3–7 |
| Middle | 7–14 | Base wheels, bridge clusters |
| Outer | 15–22 | Anchor routes; outer hidden clusters link at d 15–22; keystones at d 22 |
| Expansion | beyond the launch map's deepest huyệt | Reserved, empty at launch |

Band depths are measured on visible huyệt and cluster link points. A hidden cluster's
interior extends outward from its link, so outer cluster huyệt can sit at up to d ≈ 37.

d(x) is computed once per content release and frozen. A later release may link only to
existing outer huyệt and must not shorten any existing huyệt's depth. The content build
rejects a release that would.

The reach_cost formula is defined as:

`C_reach(x | O) = min_{o ∈ O} dist(o, x)` ; `C_enter(K) = C_reach(link_K | O) + 1` ; `C_clear(K) = C_enter(K) + n_K − 1`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| O | set | ≥ {Đan Điền} | calculated | The character's open huyệt |
| x | id | any huyệt | calculated | Target huyệt |
| dist(o, x) | int | 0–30 | calculated | Unopened huyệt on the shortest route from o to x, x included |
| link_K | id | base huyệt | data file | The huyệt a hidden cluster's entry attaches to |
| n_K | int | 3–15 | data file (C) | Cluster size |
| C_* | int | 1–37 | calculated | Points needed |

**Output Range:**
- From a fresh character, an outer cluster costs 16–23 points to enter and 18–37 to
  clear.
- An inner cluster costs 4–8 to enter and 6–22 to clear.
- Once the anchor route is open, an outer cluster costs only n_K.

**Example:**

| Life | Points | Reach |
|---|---|---|
| Luyện Khí đại viên mãn | 51 | Its focus sectors' inner band and the first half of the middle band (d ≈ 10). The rare inner hidden cluster (n ≤ 6: 5–12 points) fits. A keystone beeline (22 points) is possible but costs 43% of the life |
| Trúc Cơ đại viên mãn | 120 | Its focus sectors cleared out to d 22 |
| Kết Đan sơ kỳ | 137 | Anchors open, so a 9-huyệt outer cluster costs 9 of the 17 new points |
| Nguyên Anh+ | 243–566 | Enough for many clusters; unsealing, not points, is the limit |

### C. Hidden cluster generation

All draws are made once, with the tree seed, when a content release is generated
(rule 19).

The cluster_generation formulas are defined as:

`n = clamp(round(N(μ_n, σ_n)), n_min, n_max)` ; `k = clamp(floor(n / huyet_per_notable), 1, 3)` ; `location = inner if U < share_inner, else outer` ; `kind = sealed if U' < share_sealed, else open` ; `gate = realm_by_size(n) − (1 if inner else 0)`

where realm_by_size is Trúc Cơ for n ≤ g1, Kết Đan for n ≤ g2, otherwise Nguyên Anh.
An inner cluster's gate is one realm lower, so it can reach Luyện Khí.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| N_clusters | int | 75 | data file | Hidden clusters in the launch release |
| μ_n, σ_n | float | 9, 2.5 | data file | Size distribution |
| n_min, n_max | int | 3, 15 | data file | Size clamp |
| huyet_per_notable | int | 5 | data file | One notable per full 5 huyệt |
| share_inner | float | 0.15 | data file | Chance a cluster is inner |
| share_sealed | float | 0.667 | data file | Chance a cluster is sealed |
| g1, g2 | int | 6, 10 | data file | Size thresholds for the realm gate |
| cap_min_n | int | 7 | data file | Smallest cluster that may carry a capability (outer only) |
| U, U' | float | 0–1 | calculated (seeded) | Uniform draws |

**Output Range:**
- E[n] = 9, so 75 clusters hold about 675 huyệt. Each tail clamp has a 0.5% chance.
- k: 1 notable with probability 0.58, 2 with 0.41, 3 with 0.014. That's about 108
  hidden notables (16% density).
- About 11 inner and 64 outer clusters. A seed is accepted only if the inner count is
  9–14 **and** at least 25 outer sealed clusters have n ≥ cap_min_n (one for each
  capability). Otherwise the next seed is tried. This avoids outlier maps without
  fixing a count.
- Outer gates: about 10 Trúc Cơ, 36 Kết Đan and 18 Nguyên Anh clusters. Inner gates:
  about 2 Luyện Khí, 6 Trúc Cơ and 3 Kết Đan.
- Capabilities: 25 of 75 clusters (a third of all, half of the sealed ones). They are
  placed on outer sealed clusters with n ≥ 7, about 36 of which qualify.

**Example:** A draw of 11.37 rounds to n = 11:
- k = floor(11/5) = 2.
- U = 0.62 makes it outer, so its gate is Nguyên Anh.
- U' = 0.31 makes it sealed, so it may carry a capability.

### D. Cluster premium and node value

The cluster_premium formula is defined as:

`P = P_min + (P_max − P_min)·(w_d·t_d + w_n·t_n)` ; `t_d = (d_entry − d_lo)/(d_hi − d_lo)` ; `t_n = (n − n_min)/(n_max − n_min)` ; `E_small = S0·P` ; `E_notable = N0·P`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P_min, P_max | float | 1.25, 1.75 | data file | Premium bounds (cap of +75% by user decision) |
| w_d, w_n | float | 0.5, 0.5 | data file | Weight of reach vs size; w_d + w_n = 1 |
| d_entry | int | 4–23 | calculated (B) | Depth of the cluster's entry huyệt |
| d_lo, d_hi | int | 4, 23 | data file | Entry depth bounds |
| S0, N0 | float | 1.2, 8 W | data file (A2) | Base small and notable values |
| E_small, E_notable | float | 1.5–2.1, 10–14 W | calculated | Target value per hidden huyệt |

**Output Range:**
- P runs from 1.25 to 1.75.
- After linh căn scaling (rule 4, up to ×1.5), the strongest hidden notable is
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
- **T1:** #10 Đan Hỏa Phân Lô and #19 Khí Vận Chi Tử.
- **T3:** #5 Linh Hồn Xuất Khiếu, #22 Hồi Quang Phản Chiếu and #23 Thiêu Thọ Phá Cảnh.
- **T2:** every other entry, until a bot measurement places it.

A measurement compares the metric with and without the capability: chiến lực for combat
capabilities, the system's own output for the others (e.g. alchemy throughput). The
capability's attack equivalent then sets the tier: below half a notable is T1, up to one
notable is T2, and above that or unmeasurable is T3.

**Output Range:** 0–7 W of stats; the capability itself is not scaled by linh căn.

**Example:** A T2 capability on the n = 9, P = 1.5724 cluster carries 0.25 × 12.58 =
**3.14 W** of stats, e.g. +3.1% attack.

### E2. Breakthrough guard

Capabilities #22 and #23 must not move a realm's breakthrough success by more than
δ_max.

**Attempt model.** A realm step is a series of attempts, each succeeding with chance q,
until one succeeds or the life ends. S is the resulting chance of crossing the realm.
- **#22 (desperation)** replaces one attempt's chance q with q_desp.
- **#23 (retry)** adds one extra attempt with chance q right after a failure, without
  waiting.
- **At most one of #22 and #23 acts per realm step.** A character holding both chooses
  which to use for that realm.

The breakthrough_guard formula is defined as:

`q_desp = min(2q, q + Δ_desp, q_max)` ; `S'_22 = 1 − (1 − S)·(1 − q_desp)/(1 − q)` ; `S'_23 = S + q·(1 − S)` ; `max(S'_22, S'_23) ≤ S + δ_max`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| S | float | ≈ 0.30 / ≈ 0.70 | data file (progression targets) | Success per realm before capabilities, baseline / player edge |
| q | float | 0.01–0.95 | calculated (`CultivationRules`) | Chance per attempt |
| q_max | float | 0.95 | data file | Ceiling on any attempt's chance |
| Δ_desp | float | 0.15 | data file | Cap on #22's gain over q |
| δ_max | float | 0.10 | data file | Allowed lift per realm |
| burn_cost | int | max(10, 0.05·L_r) years | data file | #23's lifespan cost, L_r being the realm's lifespan |

**Output Range:**
- The analytic lift is at most about 0.075 at S = 0.70 and q = 0.25.
- With large q, #23's analytic lift q·(1 − S) can exceed 0.10; the bot measurement
  (Acceptance Criteria) is binding.
- If it fails, lower #23 to a retry at q/2.

**Example:** S = 0.70, q = 0.25:
- #23 alone: 0.70 + 0.25·0.30 = **0.775**.
- #22 alone: q_desp = 0.40, so 1 − 0.30·0.60/0.75 = **0.76**.
- They can't both act in one realm step, so the lift is at most +0.075.

### F. Fill budget

The F1 power formula is defined as:

`power(h) = Σ_stats w[stat]·value` (all values ≥ 0)

The cluster budget formula is defined as:

`B = P·[(n − k)·S0 + (k − c)·N0 + c·f_tier·N0]`

The per-huyệt cap formulas are defined as:

`power(small) ≤ tol·E_small` ; `power(notable) ≤ E_notable`

The compounding cap formula is defined as:

`Σ_cluster value_c ≤ cap9_c·(n/9)^γ`

The final scale formula is defined as:

`scale_all = min(1, B / Σ power)`

Sealed clusters are authored to the same numbers. The validator checks them in tests.
Open-cluster fills are clamped at runtime.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| w[stat] | float | 0.7–140 | data file (`meridian_fill.json`) | Weight per unit of each allowed stat (table below) |
| c | int | 0–1 | data file | Capability notables in the cluster (always 0 for open clusters) |
| tol | float | 1.2 | data file | Spread allowed on one small huyệt |
| cap9_c | float | table below | data file | Per-cluster cap on a compounding stat for n = 9 |
| γ | float | 0.5 | data file | Compounding caps grow sublinearly with size |
| φ_r | float | 0.10 (Luyện Khí–Kết Đan), 0.05 (Nguyên Anh+) | data file | Hard ceiling on lifespan_years per notable, as a share of realm lifespan |
| L_r | int | 120–2000 | data file (`cultivation_realms.json`) | Realm lifespan: the player's realm at fill time; the gate realm for sealed clusters |
| B | float | 13–67 W | calculated | Cluster budget |

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
| mission_income_pct | 0.7 | field_plots | 10 |
| lifespan_years | 300 / L_r per year | | |

Compounding caps per cluster at n = 9 (the old values ÷ k_pts; guesses):
- cultivation_speed_pct 4
- breakthrough_chance 0.5
- ngo_tinh 1
- khi_van 1
- alchemy_success 3
- density_bonus 0.04
- dan_doc_decay 0.8
- field_plots 1

Excluded from fills (never allowed):
- rule flags (single_artifact, safe_failure, dan_doc_no_penalty);
- cultivation_speed_per_element_pct and lifespan_pct;
- travel_speed_pct, alchemy_yield and co_duyen_pct;
- pill_effect_pct, artifact_attack_pct and artifact_defense_pct;
- element_affinity_pct, than_thuc_cost_pct and mi_luc.

Forbidden shapes: a negative value, a capability, more than 2 stats on one huyệt, a
notable count other than k, and fewer than 3 distinct stats across the cluster.

Repair order (every repair is recorded on the fill and shown to the player). Values
are kept to 0.1 display precision for percentages and 0.01 for small flat stats.
1. **Shape.**
   - Drop extra huyệt beyond n; add missing ones from the theme's pool.
   - The k highest-power huyệt become the notables; any others are demoted to small
     huyệt.
   - Remove capability and rule text.
2. **Keys.** Replace a disallowed or flag key with a stat from the theme's pool.
3. **Signs.** Remove a negative or zero value. If a huyệt is left with no stat, it gets
   one from the pool.
4. **Stat count.** On a huyệt with more than 2 stats, keep the 2 with the highest power.
5. **Variety.** While the cluster has fewer than 3 distinct stats, the lowest-power
   duplicate stat is replaced from the pool.
6. **Per-stat cap.** Clamp each value to cap_power / w, where cap_power is the huyệt's
   power cap (tol·E_small or E_notable). There is no flooring, so a stat with a large w
   still fits as a fraction.
7. **Huyệt cap.** Scale any huyệt over its power cap down to the cap.
8. **Compounding caps.** Scale down each stat that breaks its compounding cap, across
   the cluster.
9. **Budget.** Apply scale_all.

A reply the validator cannot repair (invalid JSON, or no usable huyệt at all) is
replaced entirely by a pool fill.

**Output Range:** 13 W (n 3, inner, P 1.25) to 67 W (n 15, k 3, P 1.75). A clamped fill
never exceeds B and has no negatives. Because the per-huyệt power cap binds first,
lifespan_years on a notable is at most about 4% of L_r, below the φ_r ceiling.

**Example:** n = 9, k = 1, c = 0, P = 1.5724, so B = 1.5724·(8·1.2 + 8) = **27.67 W**.
A valid fill:

| Huyệt | Content | Power each | Power total |
|---|---|---|---|
| 4 small | +2% attack | 2.0 W | 8.0 W |
| 2 small | +1.5% khí huyết | 1.8 W | 3.6 W |
| 2 small | +0.8% cultivation speed | 1.76 W | 3.5 W |
| 1 notable | +8% attack, +4% defense | 12 W | 12 W |

- Total 27.12 W, within B.
- Every small is ≤ 2.264 W (tol·E_small) and the notable is ≤ 12.58 W.
- No repair is needed.
- Cultivation speed sums to 1.6, under its cap of 4.

### G. NPC unseal chance

The npc_unseal_chance formula is defined as:

`a(r, e) = a_max[r] · (base_step + min(e, 1)·(max_step − base_step)) / max_step` ; `p(r, e) = 1 − (1 − a)^(1/M_r)` per eligible sealed cluster, and p = 0 when M_r = 0

An NPC rolls p once per eligible sealed cluster when it is generated. A cluster is
eligible if the NPC has its element and its gate is at or below the NPC's realm. An NPC
holds at most 1 cluster below Nguyên Anh, and at most 2 from Nguyên Anh.

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
- Among holders, the chiến lực gain is about 2% at the A2 scale, against a target under
  15%.

**Example:** A Kết Đan NPC at e = 1: a = 0.18, so p = 1 − 0.82^(1/38) = **0.0052** per
cluster. Holders mostly hold one.

**Capabilities on NPCs.** An NPC holding a capability notable gets that capability's
`npc_effect` from a closed set:
- `chien_luc_mult` up to ×1.10;
- `p_step_add` up to +0.05, with the NPC's p_step still clamped to max_step 0.70;
- `survive_once`;
- `none`: the capability shows in the World Database and story context only.

### H. Visible tree sizing

The visible_tree formula is defined as:

`V = core + 5·(inner_s + middle_s + outer_s) + 5·bridge_pair`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| core | int | 7 | data file | Đan Điền, 5 gates, center keystone |
| inner_s | int | 18 | data file | Per sector, d 2–6: 2 routes × 5 + 2 small clusters × 4 (3 + 1 notable) |
| middle_s | int | 52 | data file | Per sector, d 7–14: 2 routes × 8 + 4 wheels × 9 (7 + 2 notables) |
| outer_s | int | 34 | data file | Per sector, d 15–22: 2 anchor routes × 7 + 2 wheels × 9 + 2 keystones at d 22 |
| bridge_pair | int | 14 | data file | Per neighbouring pair: inner route 3 + middle bridge cluster 8 (6 + 2) + outer route 3 |
| V | int | ≈ 600 | calculated | Visible huyệt |

**Output Range:**
- V = 7 + 5·104 + 5·14 = **597**: 80 notables (ν = 13.4%) and 11 keystones (2 per
  sector plus the center).
- With 675 hidden huyệt, the map holds about 1,272.

**Example:** A Hóa Thần đại viên mãn life (566 points) could open 95% of the visible
tree, so late lives are defined by the hidden clusters they unsealed.

### Parameter keys

There is one data key per parameter, used in both the rules and the formulas.

| Symbol | Data key | Value |
|---|---|---|
| — | `tree_size_target` | ≈ 1,250 |
| N_clusters | `cluster_count` | 75 |
| μ_n, σ_n | `cluster_size_mean`, `cluster_size_sd` | 9, 2.5 |
| n_min, n_max | `cluster_size_min`, `cluster_size_max` | 3, 15 |
| — | `huyet_per_notable` | 5 |
| share_inner | `inner_share` | 0.15 |
| share_sealed | `sealed_share` | 0.667 |
| g1, g2 | `size_realm_gates` | 6, 10 |
| cap_min_n | `cap_min_n` | 7 |
| f_tier | `capability_stat_share` | T1 0.5, T2 0.25, T3 0 |
| B | `fill_total_power` (computed per cluster) | Formulas F |
| — | `fill_stats` | the weight table in F |
| — | `cong_phap_seasons` | 24 for an ordinary công pháp, 48 for a high-tier one; seasons add up (rule 7) |
| — | `open_unseals_per_realm` | Luyện Khí 1, Trúc Cơ 1, Kết Đan 1, Nguyên Anh 2, Hóa Thần 2 |
| a_max[r] | `npc_unseal_share` | 0.02, 0.10, 0.18, 0.22, 0.22 |
| — | NPC allocation weights | `tree_kind_scores` and `tree_focus_weight` in `world_generation.json` (rule 5) |

### Computational budget

The NPC allocator must target notables and clusters several steps away and stay fast
with up to 566 points:
- keep the open set and the frontier as Dictionary sets, updated per point;
- choose targets with one BFS from all open huyệt (O(N + E) ≈ 3,000 steps), redone only
  when a target is reached;
- cache plans per (archetype, focus element).

Budget: **≤ 50 ms per Hóa Thần NPC** (guess). The current one-step allocator is
estimated at 1–5 s at 566 points and must be replaced before NPCs above Kết Đan are
generated.

## Edge Cases

**Points and allocation**

- **If points arrive with nothing to open** (every reachable huyệt open, the rest
  sealed): the points stay unspent and are shown as unspent; they never expire.
- **If the character loses a level** (a failed breakthrough or an event costs a stage):
  no points are taken back and no huyệt closes. points_total tracks the highest level
  reached, so regaining the level pays nothing twice.
- **If the only route to a target passes through hidden huyệt:** the path tool reports
  the target as unreachable and spends nothing (rule 8).
- **If a path is cheaper through an inner hidden cluster once it is unsealed:** routes
  may pass through unsealed clusters like any other huyệt.
- **If the linh căn changes mid-life** (a biến dị adds or changes an element): every
  open huyệt's multiplier is recomputed immediately under rule 4. A huyệt whose element
  count requirement is no longer met stays open and keeps contributing, since there is
  no respec.

**Unsealing**

- **If a seal condition is met below the cluster's gate realm:** the unseal is recorded
  as pending and completes automatically when the character reaches the gate realm.
  - A Mạch Ấn key is consumed at use and the pending unseal is shown with its realm.
  - A công pháp's season count stops once it reaches `cong_phap_seasons`.
- **If a condition fires for a cluster already unsealed:** nothing happens. A Mạch Ấn
  key for an unsealed cluster cannot be used and is not consumed.
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
- **If the reply has the wrong huyệt or notable count:** extra huyệt are dropped and
  missing ones are filled from the pool. The adjustment is recorded on the fill like any
  clamp.
- **If a name is empty, duplicates an existing huyệt name or fails the text filter:** it
  is replaced with "<cluster name> · huyệt <n>". The stats are kept.
- **If the game closes between the unseal and the fill being recorded:** on load the
  cluster is still Awaiting fill, and the fill is requested again with the same inputs.

**Capabilities**

- **If a capability has nothing to act on** (e.g. +1 pháp bảo slot with no pháp bảo):
  it is held and listed, with no effect until it can act.
- **If two held capabilities are marked incompatible in the catalogue:** the notable
  that grants the second can still be opened for its stats. Its capability is shown as
  suppressed while the first is held.
- **If #5 Linh Hồn Xuất Khiếu would trigger on death by old age:** it does not; it
  covers deaths in events and fights only.
- **If #23's burn cost is equal to or greater than the remaining lifespan:** the retry
  is not offered. It is offered only when remaining lifespan > burn_cost.
- **If the character holds both #22 and #23:** only one acts per realm step, and the
  player chooses which (Formulas E2).
- **If an NPC holds a capability whose effect is `none`:** the capability appears in
  the World Database and story context only.

**Content and saves**

- **If a new content release adds clusters mid-life:** they appear hidden at the rim and
  can be unsealed in the current life. Nothing already on the map changes (rule 19).
- **If a save references a huyệt or cluster id that the data no longer has** (only
  possible with corrupted or modded data): the huyệt is skipped, its point is returned
  as unspent, and the problem is logged. This is the one case where a point is
  refunded.
- **If the seed's inner cluster count falls outside 9–14:** the next seed is tried at
  generation time (Formulas C). Players never see a rejected seed.

**Display**

- **If a cluster has two entry links:** discovery in Silhouette mode triggers from
  either.
- **If a cluster's element is absent from the linh căn:** it can still be unsealed and
  opened. Its huyệt are worth 0.25× (rule 4), which the map shows before the point is
  spent.

## Dependencies

None of the systems below has a GDD yet; every interface is provisional. When each GDD
is written, it must list Kinh Mạch Đồ in its own Dependencies section, as the
bidirectional-dependency rule requires.

**Upstream: this system cannot work without them (hard)**

| # | System | What Kinh Mạch Đồ needs from it |
|---|---|---|
| 1 | Data-Driven Config | `meridian_tree.json`, `meridian_fill.json`, `meridian_capabilities.json`, and the cluster and point parameters |
| 2 | Deterministic Simulation Core | The seeded RNG for map generation (fixed seed per content release) and NPC allocation; Breakdown for explainable values |
| 6 | Linh Căn | Purity per element and base element count (rules 3 and 4) |
| 7 | Character Stats | Accepts modifiers {source, stat, value}; owns stat keys, units and meaning, and the stat weights' reference values |
| 8 | Cảnh Giới & Bình Cảnh | Level, realm and stage; level bands, breakthrough bonuses and α shares (Formulas A); realm lifespan L_r; breakthrough attempts for #22 and #23 |

**Upstream: the cluster layer needs them; the base tree works without them (soft)**

| # | System | What Kinh Mạch Đồ needs from it | Without it |
|---|---|---|---|
| 3 | World Database | Stores "cluster unsealed" events and recorded fills | Fills are kept on the character only, and NPCs can't refer to them |
| 5 | Save/Load | Saves per-life state (rule 15) | Per-life state is lost on reload |
| 9 | Công Pháp | A công pháp's list of clusters, and active-season tracking | Công pháp seals can't be met |
| 13 | Item Database & Generation | The Mạch Ấn key item kind | Item seals can't be met |
| 23 | Event Engine | The "unseal this cluster" and "story moment" effects, gated by budget; event point grants | Event seals and open clusters can't be unsealed |
| 29 | LLM Game Master | Fill request transport | The template pool fills every open cluster |
| 11 | Progression Edges | The NPC edge score for `npc_unseal_chance` | NPCs never unseal clusters |

**Downstream: systems that depend on Kinh Mạch Đồ**

| # | System | What it takes |
|---|---|---|
| 21 | Combat | Only the stat modifiers, through Character Stats; capability effects owned by Combat (#1, #4, #9, #17, #25) |
| 24 | NPC Build Generation | The allocation rules (rule 5) and the allocator budget (Formulas, Computational budget); NPC unseals and `npc_effect` |
| 27 | World Generation & History | Generates NPCs through NPC Build Generation, so it is bound by the allocator budget |
| 33 | Balance Simulation Harness | Reruns calibration with the new point ladder and rescaled values (A, A2) |
| 35 | Guidance Layer | Map, silhouettes, hints, unspent points, "an unsealed cluster has unopened huyệt" goals |
| 36 | Debug Terminal | The text map and the open commands |
| 37 | Game UI | The visual map (later) |
| 12 | Codex & Karmic Carryover | Records discovered clusters, conditions and capabilities across lives (Silhouette mode benefits most) |

**Capability hosts.** Each implements the behaviour behind its capabilities. Hosts do
**not** call Kinh Mạch Đồ:
- Kinh Mạch Đồ writes held capability ids into a capability set on the character.
- Hosts read that set, the same way they read stat modifiers.
- This breaks what would otherwise be cycles with the upstream hosts (Cảnh Giới, Linh
  Căn, Character Stats, Event Engine, Công Pháp).

The hosts:
- Pháp bảo (inside Luyện Khí #16): #1, #2, #3
- Công Pháp #9: #6
- Time & Turn #4: #7, #8
- Luyện Đan #15: #10, #11
- Linh Thảo & Linh Điền #14: #12, #14
- Phù Lục #18: #13
- Trận Pháp #17: #14, #15
- Linh Thú #19: #16, #17
- Event Engine #23: #5, #18, #19, #20
- Travel & Map #25: #21
- Cảnh Giới #8: #22, #23
- Linh Căn #6: #24
- Character Stats #7: #4, #25

**Systems index change (proposed for Phase 5).**
- Row 10's Depends On becomes Linh Căn, Character Stats, Cảnh Giới, Config, Sim Core,
  and soft: Event Engine, Item DB, Công Pháp, LLM GM, World DB, Edges.
- Status becomes "Designed (partially implemented)": the base tree is built at
  prototype scale; clusters, levels and capabilities are not built.
- No new cycle: Event Engine, Item DB, Công Pháp and LLM GM don't depend on Kinh Mạch
  Đồ, and capability hosts depend on the character's capability set, not on this
  system. NPC Builds already depends on it in one direction only.

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
  - Every huyệt shows its scaled value (after rule 4) before a point is spent.
  - The path tool shows the full route cost and the total gain before committing.
- **Hidden clusters.**
  - In Silhouette mode, the location and theme show; the condition shows once
    discovered.
  - In Visible mode, the condition and (sealed) content show.
  - An open cluster shows "to be written by the story".
  - A pending unseal shows the realm it waits for.
- **Fills.** Every clamp on an LLM fill is listed on the cluster, in the same style as
  event clamps.
- **Capabilities.** Held capabilities are listed with their rule text and, when one
  can't act or is suppressed, the reason.

## Cross-References

| Document | Relationship |
|---|---|
| `design/gdd/game-concept.md` | Pillars 1–3. The concept's Kinh Mạch section must be updated for levels, scale and capabilities (system 10 was flagged for a concept update in the systems index) |
| `design/gdd/systems-index.md` | System 10; dependency and status changes proposed under Dependencies |
| `design/quick-specs/progression-and-edges.md` | Breakthrough targets (3 in 10 baseline, 7 in 10 with the player's edge); NPC edge curve used in Formulas G; the calibration must be rerun for Formulas A and A2 |
| `design/quick-specs/luyen-khi-and-tran-phap.md` | Pháp bảo slots and formations, touched by capabilities #1–3, #14, #15 |
| `design/quick-specs/phu-luc-linh-thu-thanh-tuu.md` | Phù lục and linh thú, touched by capabilities #13, #16, #17 |
| `assets/data/meridian_tree.json` | The built prototype map; to be regenerated at the target scale |
| `assets/data/cultivation_realms.json` | Holds the old stage ladder; must move to level bands (Cảnh Giới GDD) |
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
- **[Bot]** items are judged on the printed output of `tools/balance/autoplay.gd` or
  `tools/balance/npc_cohort.gd`. `npc_cohort.gd` needs three new outputs: generation at
  realm r, the share of NPCs holding a cluster, and chiến lực with and without the NPC's
  clusters.
- The existing `meridian_tree_test.gd` asserts the 202-huyệt prototype; those asserts
  are replaced when the target map lands (AC-KMD-10).

**Points (rule 2, Formulas A)**

- **AC-KMD-01** [Logic] With half-away-from-zero rounding, points_total(L) returns:

  | L | Total | L | Total | L | Total |
  |---|---|---|---|---|---|
  | 1 | 2 | 39 | 51 | 129 | 216 |
  | 13 | 14 | 40 | 62 | 130 | 243 |
  | 14 | 17 | 53 | 79 | 199 | 357 |
  | 26 | 29 | 60 | 86 | 200 | 397 |
  | 27 | 34 | 79 | 120 | 300 | 566 |
  | 38 | 45 | 80 | 137 | | |

  The first levels of trung kỳ and hậu kỳ are:

  | Realm | Trung kỳ | Hậu kỳ |
  |---|---|---|
  | Luyện Khí | 14 | 27 |
  | Trúc Cơ | 53 | 66 |
  | Kết Đan | 96 | 113 |
  | Nguyên Anh | 153 | 176 |
  | Hóa Thần | 233 | 267 |
- **AC-KMD-02** [Logic] points_total(266) = 477 and points_total(267) = 501. A
  banker's-rounding implementation (500 at 267, 565 at 300) fails this test.
- **AC-KMD-03** [Logic] Each đại viên mãn advance plus the next entry term equals that
  bonus: 5+10 = 15, 9+16 = 25, 14+26 = 40, 21+39 = 60.
- **AC-KMD-04** [Logic] points_total never decreases over 1..300.
  - At L = 60 (86 points), dropping to level 52 and climbing back keeps the total at 86
    at every step, and no huyệt closes.
- **AC-KMD-05** [Logic] Event grants and unspent points.
  - Each event grant adds exactly 1: L = 39 with 2 grants gives 53.
  - With every reachable huyệt open, new points stay unspent, and the count is
    unchanged after 20 turns.

**Value scale (Formulas A2)**

- **AC-KMD-06** [Config/Data, data-lint test]
  - The data has S0 = 1.2 and N0 = 8.
  - Every keystone has power ≥ 50 W under the F weights.
  - k_pts = 3.643 (±0.001).
  - The mean power of visible non-keystone huyệt on the target map is 2.0–2.2 W.
- **AC-KMD-07** [Integration, Bot: `autoplay.gd`, ≥ 60 lives = 20 seeds × 3 origins]
  The median tree power at Luyện Khí đại viên mãn is 90–125 W.

**Map and reach (rules 1, 3, 4, 5, 8; Formulas B and H)**

- **AC-KMD-08** [Logic] Determinism. Two generations from the same data, and two lives
  with different character seeds, give identical ids, positions, edges, kinds, modifiers
  and d(x). A map hash equals a golden constant.
- **AC-KMD-09** [Logic] The core.
  - Đan Điền is at d = 0.
  - There are exactly 5 gates at d = 1, clockwise from the top: Mộc, Hỏa, Thổ, Kim,
    Thủy.
  - The center keystone is refused with 4 base elements and allowed with 5.
- **AC-KMD-10** [Logic] Formula H.
  - The map has 597 visible huyệt, 80 of them notables and 11 keystones.
  - Per sector: inner 18, middle 52, outer 34. Per bridge pair: 14.
  - The total, 597 plus the cluster sizes, matches a golden value in 1,200–1,350.
- **AC-KMD-11** [Logic] Bands.
  - Every visible huyệt has d ≤ 22, and the sector keystones sit at exactly d = 22.
  - Inner clusters link at d 3–7 and outer clusters at d 15–22.
  - Cluster interiors may go deeper; d is frozen per release.
- **AC-KMD-12** [Logic] Reach on a fixture graph.

  | Cluster | Link open? | C_enter | C_clear |
  |---|---|---|---|
  | Outer, linked at d 19, n 9 | no | 20 | 28 |
  | Same | yes | 1 | 9 |
  | Inner, linked at d 4, n 5 | no | 5 | 9 |
- **AC-KMD-13** [Logic] Opening a huyệt costs exactly 1 point. It is refused with 0 spent
  when the huyệt is already open, not adjacent, or short of elements.
- **AC-KMD-14** [Logic] Paths are all or nothing.
  - A 5-huyệt route with 4 points fails and leaves everything unchanged.
  - With 5 points, all 5 open.
  - After any sequence of opens, level losses and loads, the new open set contains the
    old one.
- **AC-KMD-15** [Logic] Rule 4.
  - Purity 60 gives ×1.10, purity 100 gives ×1.50, and an absent element gives ×0.25.
  - A bridge between Mộc 60 and an absent Hỏa gives ×0.675.
  - The root and keystones are ×1.0.
  - The modifier source is exactly `Kinh Mạch: <name> #<id>`.
- **AC-KMD-16** [Logic] A linh căn change mid-life.
  - Purity 60 → 80 changes that element's open huyệt from ×1.10 to ×1.30 on the same
    call.
  - A huyệt whose element requirement is no longer met stays open and keeps
    contributing.
- **AC-KMD-17** [Logic] Rule 8.
  - Hidden huyệt fail `can_allocate` with a reason and are absent from `frontier()`.
  - `path_to` through them reports unreachable and spends 0.
  - No API turns points into an unseal.
  - Once unsealed, the cluster can be routed through.
- **AC-KMD-18** [Logic] Rule 5, with a fixed seed.
  - NPC allocation is identical on repeat runs and every open is legal.
  - Points spent = min(points, reachable huyệt).
  - A Hỏa-archetype NPC opens more Hỏa huyệt than huyệt of any other sector.

**Clusters and unsealing (rules 6, 7, 9, 10, 13; Formulas C)**

- **AC-KMD-19** [Logic] The launch release.
  - It has 75 clusters, every n in 3–15, and an inner count of 9–14.
  - At least 25 outer sealed clusters have n ≥ 7.
  - Every cluster has all the fields of rule 6 and exactly one condition.
  - Notables: k(3) = 1, k(9) = 1, k(10) = 2, k(14) = 2, k(15) = 3.
  - Gates:

    | n | Location | Gate |
    |---|---|---|
    | 6 | outer | Trúc Cơ |
    | 7 | outer | Kết Đan |
    | 11 | outer | Nguyên Anh |
    | 5 | inner | Luyện Khí |
    | 11 | inner | Kết Đan |
- **AC-KMD-20** [Logic] Seed rejection. A seed giving 8 or 15 inner clusters, or fewer
  than 25 capability hosts, is rejected. The accepted seed is the same on every run.
- **AC-KMD-21** [Logic] In every cluster, each notable's route distance from the
  nearest entry is ≥ that of every small huyệt.
- **AC-KMD-22** [Logic] Event condition. The authored template's unseal effect moves
  cluster K from Hidden to Unsealed. The same effect on an LLM-made event is rejected and
  logged, and K stays Hidden.
- **AC-KMD-23** [Logic] Item condition. Using K's Mạch Ấn consumes it and unseals K. A
  key for an unsealed cluster can't be used, and the item count is unchanged.
- **AC-KMD-24** [Logic] Công pháp condition.
  - K stays Hidden after 23 active seasons and unseals at 24 (48 for a high-tier
    công pháp).
  - Switching công pháp for 5 seasons pauses the count without resetting it.
- **AC-KMD-25** [Logic] Pending unseal.
  - A Trúc Cơ character meets a Kết Đan-gated condition: the cluster becomes pending
    with "Kết Đan" recorded, and the key is consumed.
  - It becomes Unsealed on entering Kết Đan with no further input.
- **AC-KMD-26** [Logic] Unsealing.
  - Exactly one World Database event {type "cluster unsealed", player, cluster, source}
    is written.
  - The entry huyệt that touch an open huyệt join the frontier.
  - The open set and the points are unchanged, and the cluster never returns to Hidden.
  - Two conditions on one turn resolve in ascending cluster id.
- **AC-KMD-27** [Logic] Rule 10 selection, with eligible open clusters A (id 4, route 6,
  Đan Đạo), B (id 2, route 3, Trận Đạo) and C (id 7, route 3, Trận Đạo).
  - No hint: B is chosen.
  - Hint Đan Đạo: A is chosen.
  - Once the realm allowance is used, the next story moment is dropped and logged and
    grants nothing. The same happens when no cluster is eligible.
- **AC-KMD-28** [Logic] Visibility.
  - Thiên Định defaults to Silhouette and Tự Định to Visible.
  - In Silhouette, the condition stays hidden until a discovery. Discovery comes from
    either entry of a two-link cluster, or from an event, NPC or item hint.
  - In either mode, an open cluster's content is empty before its fill is recorded.

**Fills and validator (rules 10, 11, 12; Formulas D, E, F)**

- **AC-KMD-29** [Logic] Premium.
  - d 19, n 9 gives P = 1.5724 (±0.0005), E_small = 1.887 and E_notable = 12.58.
  - d 5, n 5 gives 1.305; d 4, n 3 gives 1.25; d 23, n 15 gives 1.75.
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
  | 12 huyệt for n 9 | 9 (extras dropped) |
  | 6 huyệt for n 9 | 9 (3 added from the pool) |
  | 2 notables for k 1 | 1 notable (the highest-power one), the other demoted |
  | −5% defense | stat removed (replaced from the pool if the huyệt is left empty) |
  | A huyệt with 3 stats | the 2 highest-power stats kept |
  | 2 distinct stats | 3 or more |
- **AC-KMD-34** [Logic] Value repairs, in order.
  - +30% attack on a small is cut to 2.264 W.
  - Cultivation speed summing to 9 at n = 9 is cut to 4. The cap is 2.667 at n = 4 and
    5.164 at n = 15.
  - A fill of 34.6 W against B = 27.67 is scaled by 0.7997.
  - A notable's lifespan_years at L_r = 120 is at most 5.03 years.
  - +0.4% breakthrough_chance on a small is allowed: 2.0 W ≤ 2.264 W.
- **AC-KMD-35** [Logic] Property test over 500 seeded hostile fills. After the
  validator, every fill:
  - has power ≤ B and no negative values;
  - uses only `fill_stats` keys, with at most 2 stats per huyệt;
  - has n huyệt and k notables, with at least 3 distinct stats;
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
- **AC-KMD-39** [Logic, data-driven] Every authored sealed cluster passes the validator
  with zero repairs.
- **AC-KMD-40** [Logic] Formula E with E_notable = 12.58.
  - T1 gives 6.29 W, T2 3.145 W and T3 0 W.
  - A capability notable's authored power is ≤ f_tier·E_notable.

**Capabilities (rules 16–18; Formula E2)**

- **AC-KMD-41** [Config/Data] The catalogue.
  - 25 entries with unique ids. Tiers: #10 and #19 are T1; #5, #22 and #23 are T3; the
    rest are T2.
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
  notable applies Y's stats and lists Y as suppressed with a reason. #2 held with no
  pháp bảo is listed with no effect.
- **AC-KMD-44** [Logic] E2 values.
  - burn_cost(L_r): 120 gives 10, 500 gives 25, 2000 gives 100.
  - q_desp: 0.25 gives 0.40, 0.10 gives 0.20, 0.90 gives 0.95.
  - With remaining lifespan = burn_cost, the retry is not offered; with burn_cost + 1,
    it is offered.
- **AC-KMD-45** [Integration, needs the Cảnh Giới host]
  - #22 and #23 are each usable once per realm, and at most one acts per realm step.
  - #22 needs under 5 years of thọ nguyên left.
  - #5 does not trigger on death by old age.
- **AC-KMD-46** [Integration, Bot: extended `npc_cohort.gd`, ≥ 2,000 NPCs per arm on
  paired seeds] Arms: neither, #22 only, #23 only.
  - Pass: every arm's per-realm success lift over "neither" is ≤ +0.10.
  - Rerun at 4,000 per arm if any estimate is 0.08–0.10.

**NPCs (rule 14; Formula G)**

- **AC-KMD-47** [Logic] Formula G.
  - Kết Đan at e = 1: a = 0.18, p = 0.005209 (±1e-5).
  - Kết Đan at e = 0: a = 0.07714.
  - e = 1.5 gives the same as e = 1.
  - Luyện Khí at e = 1 with M = 1: p = 0.02.
  - M = 0 gives p = 0.
  - Only clusters of the NPC's elements at or below its realm are rolled.
- **AC-KMD-48** [Logic] With every roll forced to succeed:
  - a Trúc Cơ NPC holds 1 cluster, and Nguyên Anh and Hóa Thần NPCs hold 2;
  - rolls go in ascending id, and open clusters are never held.
  - `npc_effect`:
    - `chien_luc_mult` is capped at ×1.10;
    - `p_step_add` 0.05 on 0.68 gives 0.70;
    - `survive_once` fires once;
    - `none` changes no number.
- **AC-KMD-49** [Integration, Bot: extended `npc_cohort.gd`, ≥ 1,000 NPCs per realm,
  3 seeds]
  - Cluster holders are under 15% at every realm.
  - The median chiến lực uplift among holders is under 15%.
- **AC-KMD-50** [Integration, Bot] Breakthrough rates on the level ladder with rescaled
  values.
  - `npc_cohort.gd` at 1,000 per cohort: per-realm success is 0.30 ± 0.05 with no edge
    and 0.70 ± 0.05 with all edges.
  - `autoplay.gd` over ≥ 60 lives: 0.70 ± 0.10 with edge on and 0.30 ± 0.10 with edge
    off.

**Persistence and content releases (rules 15, 19)**

- **AC-KMD-51** [Logic] A save/load round trip keeps open huyệt, unsealed and pending
  clusters, hints, fills with their repair records, visibility mode and capability set
  identical. Serialising twice gives identical output.
- **AC-KMD-52** [Logic] Append-only, with release 1 plus a fixture release 2.
  - Every release-1 huyệt keeps its id, position, kind, modifiers and d(x).
  - Every release-1 cluster keeps its fields.
  - New ids are above the largest release-1 id, and new huyệt link only to release-1
    outer huyệt.
  - Release 1 generated alone equals release 1 inside "1+2".
  - A fixture release that would shorten any depth is rejected by the content build.
- **AC-KMD-53** [Logic] A release-1 save loads under release-2 data.
  - The new clusters are Hidden, and fills and World Database events still resolve.
  - A save with an unknown id skips that huyệt, returns its point as unspent and logs
    one line.

**Performance**

- **AC-KMD-54** [Integration; BLOCKING before NPCs above Kết Đan are generated] A
  headless perf script, `tests/performance/meridian/allocator_perf.gd` (not a gdUnit
  test).
  - Setup: 200 seeded Hóa Thần NPCs at 566 points on the target map, plan cache cold.
  - Measurement: `Time.get_ticks_usec()` around the allocate call only.
  - Pass: p95 ≤ 50 ms and max ≤ 100 ms.
  - Record median, p95, max and the CPU in `production/qa/evidence/`.
- **AC-KMD-55** [Logic] With a counter injected into the allocator: BFS passes ≤ targets
  reached + 1, and there is no full frontier rescan per point.

**UI (debug terminal; a captured transcript is the evidence)**

- **AC-KMD-56** [UI] At level 38 the terminal shows spent and unspent points and the next
  sources: level 39 +1, the đại viên mãn advance +5 (shown separately) and the Trúc Cơ
  breakthrough +10.
- **AC-KMD-57** [UI] Before spending, each huyệt shows its value after rule 4 (including
  ×0.25 for an absent element). The path tool shows the route cost and total gain
  before committing.
- **AC-KMD-58** [UI] The terminal shows:
  - Silhouette and Visible content as rule 13 describes;
  - "to be written by the story" for open clusters;
  - the waiting realm for pending unseals;
  - each fill's repairs;
  - held capabilities with their rule text, and a reason when one is suppressed or idle.

**Still provisional:**
- AC-KMD-01 and AC-KMD-02 at L ≥ 267 depend on Open Question 2 (the realm after Hóa
  Thần).
- AC-KMD-28's defaults depend on Open Question 1.
- Capability behaviours are tested in each host system's GDD; here only presence, data
  and the guard are covered.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | May a Thiên Định life choose Visible mode, or is Silhouette fixed for it (achievement fairness)? | user | UI, Thành Tựu |
| 2 | What realm follows Hóa Thần? Its bonus (placeholder 90) sets the Hóa Thần đại viên mãn advance (32 points) | user + Cảnh Giới GDD | Formulas A at level 300 |
| 3 | Level bands, tu vi per level and the size of the stat rise at each great and small breakthrough | Cảnh Giới GDD | Formulas A; implementation |
| 4 | The fixed list of cluster themes, and whether each theme gets a stat whitelist (so a Đan Đạo cluster can't be all attack) | game-designer | Fill validator; sealed authoring |
| 5 | Capability tiers by measurement (only 5 of 25 have a provisional tier) and the list of incompatible pairs | systems-designer + bot | Formulas E; rule 18 |
| 6 | Content plan for about 50 fully authored sealed clusters (about 450 huyệt) and 10 more sector keystones (2 per sector instead of 1) | user + writer | Content release 1 |
| 7 | The lifespan ceiling φ_r never binds, because the per-huyệt power cap binds first. Keep it as a safety net or drop it? | systems-designer | none |
| 8 | Recalibrate breakthrough targets and NPC cohorts on the level ladder with rescaled values (Formulas A, A2) before any of it ships | Balance harness | Implementation sign-off |
