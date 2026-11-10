# 07 · Hỗn Độn Đạo · *Hồng Mông* (Primordial Chaos; the Primal Haze)

> Overnight draft 2026-11-11. Proposal. **Needs:** the Primordial Chaos root.
> **Theme stats:** `attack_pct` (chaos), `resist_pen_pct` (chaos, all), `element_affinity_pct`, `stack_effect_pct` (all),
> `comprehension`, `cultivation_speed_pct` (capped), `resist_pct` (chaos).
> **Road:** `attack_pct` chaos +2.

## Build directions

1. **Chaos Engine.** Chaos passes body shields and few resist it; Hỗn Độn makes it pass more (ward shields, at a
   share) and erode resistance further. The anti-tank Way for a rare root.
2. **Unformed.** Your arts have no fixed element: each counts as every base element for stacks and modifiers (Vô
   Hình), so every element-scoped bonus applies. A min-maxer's dream with a heavy closing cost.
3. **Mixing.** Your buff stacks of different elements merge into Chaos stacks, a single pile that counts as all of
   them (Hỗn Hợp). Simplifies the stack economy and multiplies it.
4. **Before Heaven.** Comprehension and insight: the rare root's life-around-the-fight edge (Tiên Thiên).

## Facets

### 1. Hỗn Độn (Chaos Damage)
- **Small:** `attack_pct` chaos +2 · `resist_pen_pct` chaos +0.6
- **Stat notables:** Primal Murk (Mù Mịt): chaos ×2 · Formless Edge (Lưỡi Vô Hình): chaos penetration ×2 · Grey Fire
  (Lửa Xám): chaos +1, crit damage +1 · Void Grip (Nắm Hư): chaos +2
- **Effects:**
  - **Major: Before the Forms (Tiên Hình).** 20 % of your Chaos damage ignores ward shields (it meets resistance and
    health only). `Needs rule` (shared bypass rule).
  - Minor: Chaos Taint (Nhiễm Hỗn). Your Chaos hits apply 2 Poison stacks. *(starter)*
  - Minor: Churning (Cuộn Xoáy). Your Chaos crits remove 2 buff stacks from the target.

### 2. Vô Hình (Unformed)
- **Small:** `element_affinity_pct` +1.5 · `attack_pct` +1
- **Stat notables:** Shapeless (Vô Dạng): affinity ×2 · All Colours (Mọi Sắc): attack ×2 · Primal Clay (Đất Sét Sơ
  Khai): affinity +1, attack +1 · Every Root (Vạn Căn): stack effect +2
- **Effects:**
  - **Major: Unformed (Vô Hình).** Your arts count as every base element for modifiers and Effects that read element
    tags (not for stacks granted).
  - Minor: Any Shape (Tùy Hình). Your arts grant buff stacks of your highest-purity element. *(starter)*
  - Minor: Shifting Grain (Vân Đổi). Each pulse, your basic attack's element tag changes in the generating order.

### 3. Xâm Thực (Erosion)
- **Small:** `resist_pen_pct` +0.6 · `attack_pct` chaos +1
- **Stat notables:** Corrode (Ăn Mòn): penetration ×2 · Slow Rot (Mục Dần): chaos +1, penetration +1 · Eat Away (Gặm
  Mòn): chaos ×2 · Unmake (Tan Rã): chaos crit damage +2
- **Effects:**
  - **Major: Erosion (Xâm Thực).** Each Chaos hit lowers all of the target's resistances by 3 points for the fight
    (cap −60). Stacks with Sundered and Exposed.
  - Minor: Wear (Mòn). Your Chaos hits lower the target's block by 2 for the fight (cap −30). *(starter)*
  - Minor: Crumbling Ward (Hộ Vỡ Vụn). A target eroded by 30+ points has its ward efficiency −10 %.

### 4. Tiên Thiên (Before Heaven)
- **Small:** `comprehension` +1 · `cultivation_speed_pct` +0.4 (counts toward the 10 % per-Dao cap)
- **Stat notables:** Primal Insight (Ngộ Sơ): comprehension ×2 · Unborn Mind (Tâm Chưa Sinh): thần thức +2 · Seed of
  Heaven (Mầm Trời): comprehension +1, cultivation speed +0.5 · Prenatal Qi (Tiên Thiên Khí): max linh lực +2
- **Effects:**
  - **Major: Innate Understanding (Tiên Thiên Ngộ).** Your glimpses offer 4 Daos instead of 3, and your first node in
    each Dao is free. `Needs rule` (dao_offer_size).
  - Minor: Primordial Breath (Hỗn Nguyên Khí). +0.1 pp linh lực regeneration per element whose buff stacks you hold.
    *(starter; the by-root keystone, Way form)*
  - Minor: Unwritten (Chưa Viết). Technique mastery +15 %.

### 5. Hỗn Hợp (Mixing)
- **Small:** `stack_effect_pct` (all) +0.75 · `stack_duration_pct` +2
- **Stat notables:** Blend (Hòa Trộn): stack effect ×2 · Long Mix (Trộn Lâu): stack duration ×2 · Cauldron (Vạc):
  stack effect +1, duration +1 · Murky Pool (Ao Đục): regen +0.1
- **Effects:**
  - **Major: Primal Mixing (Hồng Mông Hợp).** Every 5 s, your buff stacks of all elements merge into Chaos stacks (one
    per stack merged); each Chaos stack gives every element buff at 30 % of its value. `Needs key` (Chaos stacks).
  - Minor: Muddy (Đục). Merged Chaos stacks last 2 pulses longer. *(starter)*
  - Minor: All in One (Vạn Hợp). Your hits deal more by the number of different elements merged in the last batch
    (L5 +5 each).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **All Five, None of Them (Ngũ Hành Giai Vô)** | keystone | Unformed also applies to stacks: each art grants stacks of every base element at 30 % size | Your arts cannot deal non-Chaos damage (all converted) | Vô Hình |
| **Primal Haze (Hồng Mông)** | keystone | Erosion has no cap | Your max health is 25 % lower | Xâm Thực |
| **Chaos Unbound (Hỗn Độn Vô Câu)** | keystone | Before the Forms bypasses 45 % | Your Chaos resistance is −40 (you are part of it) | Hỗn Độn |
| **Mother of Elements (Vạn Tố Chi Mẫu)** | keystone | Primal Mixing's Chaos stacks count at 60 % | Stacks merge every 3 s (less time to use them raw) | Hỗn Hợp |

## New pieces

- Chaos stacks (a merged buff): `Needs key` (Effects 9a: Chaos has no stacks).
- Glimpse offer of 4: `Needs rule` (dao.md rule 6).

## Kept apart from

Ngũ Hành (order among elements), Diệt Đạo (Chaos at a price), Vô Cực (emptiness and growth). Hỗn Độn is **every
element as one, erosion, and Chaos past shields**.
