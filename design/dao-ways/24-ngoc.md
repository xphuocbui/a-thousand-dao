# 24 · Ngọc Đạo · *Ngọc Thanh* (Jade Purity)

> Overnight draft 2026-11-11. Proposal. **Needs:** Earth ≥ 30.
> **Theme stats:** `body_shield_pct`, `status_resist_pct`, `soul_res_pct`, `element_affinity_pct`, `artifact_power_pct`,
> `than_thuc_cost_pct`, `attack_pct` (light, earth), `ngo_tinh` (comprehension) (cultivation curve), `cultivation_speed_pct`
> (capped by `dao_rate_cap_pct`).
> **Road:** `status_resist_pct` +1.

## Build directions

1. **Flawless.** Power that reads root purity: the single-root, high-purity player gets a payoff no mixed root
   matches (Vô Hà). The build for the "pure root" fantasy, as numbers.
2. **The Prism.** Refraction splits a big hit into several smaller ones: the answer to per-hit wards and a way
   to multiply "on hit" Effects.
3. **The Jade Wall.** Status immunity in tiers and a body shield that cannot be pierced by Chaos for a while: the
   counter to curse and poison builds.
4. **The Carver.** Jade artifacts with extra power and lower thần thức cost; an artifact-support direction.

## Facets

### 1. Ngọc Thể (Jade Body)
- **Small:** `body_shield_pct` +1 · `soul_res_pct` +1
- **Stat notables:** Jade Skin (Da Ngọc): body shield ×2 · Translucent (Trong Suốt): soul resistance ×2 · Jade
  Marrow Shell (Vỏ Ngọc): body shield +1, status resist +1 · Cool Stone (Đá Mát): fire resistance +2
- **Effects:**
  - **Major: Unflawed Shell (Ngọc Bất Tỳ).** Your body shield stops Chaos damage too (at half its value) while it
    is above 50 %. (The shield's `stops` list adds Chaos at a 50 % share, the cap: Combat Defence rule 9, R3.)
  - Minor: Polished (Đánh Bóng). Your body shield is 20 % stronger while you have no debuff on you. *(starter)*
  - Minor: Jade Resonance (Ngọc Cộng Minh). When your body shield breaks, it rings: the attacker is Exposed for 1
    pulse.

### 2. Thuần Khiết (Purity)
- **Small:** `status_resist_pct` +1 · `element_affinity_pct` +1.5
- **Stat notables:** Clear Water Jade (Ngọc Nước): status resist ×2 · Single Grain (Đơn Văn): element affinity ×2 ·
  Untouched (Vô Nhiễm): status resist +1, soul resist +1 · True Colour (Chân Sắc): affinity +1, status resist +1
- **Effects:**
  - **Major: Flawless (Vô Hà).** Your hits deal more by your highest element purity above 60 (L5 +1 per 2 purity,
    cap +20), and your element stacks' purity factor counts 50 % more.
  - Minor: Reject the Impure (Bài Tạp). The first 5 debuff stacks of each element placed on you each pulse are
    refused. *(starter)*
  - Minor: Clean Channels (Mạch Sạch). Your cleanse effects remove 1 more stack.

### 3. Khúc Xạ (Refraction)
- **Small:** `attack_pct` light +1.5 · `accuracy_pct` +0.5
- **Stat notables:** Prism (Lăng Kính): light ×2 · Split Beam (Tách Tia): accuracy +1, light +1 · Facet Cut (Mài
  Mặt): light crit damage +2 · Rainbow Edge (Viền Cầu Vồng): element affinity +1, light +1
- **Effects:**
  - **Major: Refract (Khúc Xạ).** Your hits above 5 % of the target's max health split into 3 hits of 36 % each
    (108 % total); each counts as a hit for Effects and ward payments.
  - Minor: Scatter Light (Tán Quang). Your Light hits apply Exposed for 1 pulse on a crit.
  - Minor: Through Jade (Xuyên Ngọc). Your split hits ignore 10 resistance points. *(starter)*

### 4. Ngọc Giản (Jade Slips)
- **Small:** `ngo_tinh` (comprehension) +1 · `soul_res_pct` +1
- **Stat notables:** Library of Slips (Kho Giản): comprehension ×2 · Copied Insight (Chép Ngộ): comprehension +1,
  cultivation speed +1 · Engraved Memory (Khắc Nhớ): soul resistance ×2 · Seal of Record (Ấn Ghi): thần thức +2
- **Effects:**
  - **Major: Record the Way (Ghi Đạo).** When you buy a capstone in any Dao, you gain 2 free skill points
    (once per Dao). `Needs rule` (points economy, Meridian Map Formulas A).
  - Minor: Read Twice (Đọc Hai Lần). Technique mastery from study is 15 % faster while your heart demon is below 20.
  - Minor: Slip for the Road (Giản Đi Đường). A jade slip you carry can store one art seen in a fight this
    season, usable once as a talisman. `Needs rule`.

### 5. Điêu Khắc (Carving)
- **Small:** `artifact_power_pct` +0.9 · `than_thuc_cost_pct` −0.8
- **Stat notables:** Fine Chisel (Đục Tinh): artifact power ×2 · Light Jade (Ngọc Nhẹ): thần thức cost ×2 · Carved
  Ward (Ngọc Bội Hộ): artifact defence +2 · Jade Seal (Ngọc Ấn): artifact power +1, seal attack +1
- **Effects:**
  - **Major: Jade Vessel (Ngọc Khí).** Jade-material artifacts you equip give +1 element purity each to their
    element for stack effects (cap +15). `Needs key` (artifact material tag).
  - Minor: Smooth Grain (Thớ Mịn). Jade-material artifacts' actives cost 20 % less linh lực.
  - Minor: Talisman of Jade (Ngọc Phù). Talismans you drew on jade slips have +1 stock. *(starter)*

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Flawless (Hoàn Mỹ)** | keystone | You are immune to curses while above 70 % health | Your max health is 15 % lower | Thuần Khiết |
| **Jade Purity (Ngọc Thanh)** | keystone | Your element stacks of your second-highest element use your highest purity | You may hold buff stacks of two elements only | Thuần Khiết |
| **The Thousand-Facet Gem (Thiên Diện Ngọc)** | keystone | Refract splits into 5 hits of 22 % each | Your crits deal 30 % less extra damage | Khúc Xạ |
| **Better Broken Jade (Ninh Vi Ngọc Toái)** | keystone | Once a fight, at the Down step's refusal, refuse it (health 1; the fight's one Down refusal, R5) and shatter: deal 20 % of your max health as Light to the foe (a trigger) | You cannot escape | Ngọc Thể |

## New pieces

- Chaos against body shields (Unflawed Shell): `stops` list at 50 % (Combat Defence rule 9, R3).
- Artifact material tag (`jade`): `Needs key`.
- Hit splitting (Refract): `Needs rule` (Combat rule 10, one hit per firing).

## Kept apart from

Thể Đạo's Ngọc Tủy (jade marrow as regeneration); Quang Đạo (Light damage itself); Kỹ Đạo (crafting). Ngọc Đạo
is **purity as power, the prism and the unflawed shell**.
