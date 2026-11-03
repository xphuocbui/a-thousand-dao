# Quick spec: Artifact refining (Luyện Khí, making magic treasures) and formations (Trận Pháp, at the cave abode)

*Status: implemented in the debug terminal build, 2026-11-03, pending design review.
Source: game-concept.md § Core Mechanics 3 ("luyện chế pháp bảo … trận pháp … crafting
affinity comes from linh căn") and § Pillar 3 (Power Is Built, Not Given). The concept's
MVP list defers both; they were built at the user's request after the overnight build.*

## Why now

The balance probe (tools/balance/autoplay.gd) showed spirit stones (linh thạch) piling up with nothing
worth buying: sect lives end Foundation Establishment (Trúc Cơ) with 2–9k LT and Core Formation (Kết Đan) lives with 30–70k. Materials
(items_materials.json) had no use except selling. Both crafts turn money and materials
into lasting power, and both give Metal (Kim) and Earth (Thổ) roots a crafting identity like Fire
(Hỏa, alchemy) and Wood (Mộc, herbs) already have.

## Artifact refining (Luyện Khí)

**Rules.** At any place, `refine <base> [tier]` spends one season, spirit stone (linh thạch) fuel and
materials to make one magic treasure (pháp bảo) of the chosen base (Phi Kiếm, Ấn, Chuông, …).

- *Tier* is the artifact tier (0 Pháp khí, 1 Pháp bảo, 2 Linh bảo …). Default and
  maximum: the refiner's realm index. Each tier needs artifact refining level ≥ `min_level[tier]`.
- *Materials*: `materials[tier]` units, each with rarity ≥ `min_rarity[tier]`. The
  session picks the cheapest qualifying materials the player owns. The artifact takes
  the element most common among them (none if they are elementless).
- *Fuel*: `base.base_value × tier.value_scale × fuel_mult` spirit stones, paid up front.
- Fuel and materials are spent whether or not it succeeds.

**Formulas** (values in crafting_refining.json):

    success % = clamp(100 − difficulty[tier] + level × success_per_level
                      + Metal purity × kim_success_per_purity + comprehension × ngo_tinh_per_point,
                      min_success, max_success)
    grade cap = clamp(floor(level / levels_per_grade) + avg material rarity − 1, 0, 4)
    grade     = weighted roll over items_artifacts.json grades with rank ≤ grade cap
    xp        = xp[tier] on success, × fail_xp_fraction on failure

Example: a Foundation Establishment (Trúc Cơ) refiner, artifact refining level 3, Metal (Kim) 60,
comprehension (ngộ tính) 50, tier 1 Phi Kiếm:
success = 100 − 60 + 3×6 + 60×0.25 + 50×0.1 = 78%; fuel = 20 × 8 × 2 = 320 LT;
3 materials of rarity ≥ 2 (e.g. Xích Đồng, Hàn Ngọc); grade cap = floor(3/2) + 2 − 1 = 2.

**Edge cases.** Unknown base → error, nothing spent. Tier above realm → refused. Not
enough materials or fuel → refused, nothing spent. Skill below min level → refused.
Refining is an action that passes a season, so it is blocked while an event waits.

## Formations (Trận Pháp)

**Rules.** At the cave abode (động phủ, home), `formation build <id>` raises a formation one level,
paying spirit stones (linh thạch) and materials, in one season. Each level adds `per_level` to its stat.
Every year each formation costs upkeep; if the player cannot pay, it drops one level.

| Formation | Stat | Applies |
|---|---|---|
| Tụ Linh Trận | density_bonus (spiritual qi [linh khí] at home) | only while at home |
| Thanh Mộc Trận | herb_growth_pct | always (the field is at home) |
| Hộ Sơn Trận | defense_pct | only while at home |

**Formulas** (crafting_formations.json):

    build cost (level L, 1-based)  = cost_lt × cost_growth^(L−1) spirit stones
                                     + materials_per_level × L units of rarity ≥ material_rarity
    max level                      = min(max_level, formation skill level + 1)
    upkeep per year                = Σ levels × upkeep_lt_per_level × (1 − Earth purity × tho_upkeep_cut_per_purity)
    xp per build                   = xp_per_level_built × L

Example: Tụ Linh Trận level 2 costs 150 × 2.5 = 375 LT + 2 Huyền Hoàng Thạch-class
materials; at level 2 home density +0.30; upkeep 2 × 10 = 20 LT/year, 14 LT with Earth (Thổ) 75.

**Edge cases.** Not at home → refused. Already at max level → refused with the reason
(skill or cap). Upkeep is charged on the yearly tick after the sect stipend, so a
stipend can pay it. Formations are kept in the player record and saved.

## Tuning knobs

| Knob | File | Safe range | Effect |
|---|---|---|---|
| fuel_mult | crafting_refining.json | 1–4 | how much refining drains spirit stones (linh thạch) |
| difficulty[tier] | crafting_refining.json | 30–80 | early refining success |
| materials[tier], min_rarity[tier] | crafting_refining.json | 2–6, 1–4 | material demand per tier |
| levels_per_grade | crafting_refining.json | 1–3 | how fast skill unlocks better grades |
| per_level (each formation) | crafting_formations.json | see file | strength of a formation level |
| cost_lt, cost_growth | crafting_formations.json | 50–500, 1.5–3 | build cost curve |
| upkeep_lt_per_level | crafting_formations.json | 5–50 | the lasting sink |
| kim_success_per_purity, tho_upkeep_cut_per_purity | both | 0–0.5, 0–0.008 | spiritual root (linh căn) identity |

## Acceptance criteria

1. With enough materials and fuel, `refine` spends exactly the stated fuel and materials
   and passes one season; on success a magic treasure (pháp bảo) of the chosen base and tier is owned.
2. Refining is refused, with nothing spent, when fuel, materials, skill or realm fall short.
3. Higher Metal (Kim) purity gives a higher refining success chance (shown by `explain refine`).
4. Building a formation at home spends its cost, raises its level by one, and the stat
   appears in `explain` with the formation as its source.
5. Tụ Linh Trận raises the cultivation rate only while the player is at home.
6. Unpaid upkeep lowers a formation one level on the yearly tick and is reported.
7. Formations survive save/load.
