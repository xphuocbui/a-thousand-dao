# 06 · Phong Nguyệt Đạo · *Phong Hoa Tuyết Nguyệt* (Wind, Flowers, Snow, Moon)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `art_speed_pct`, `evade_pct`, `healing_pct`, `attack_pct` (cold, light, physical), `crit_chance_pct`,
> `crit_damage_pct`, `tam_ma_resist_pct`.
> **Road:** `crit_chance_pct` +0.4.

## Build directions

The Way of the four beauties, built as a **set bonus**: each facet is one beauty, and holding several at once is
the point (Tứ Cảnh). Where Ngũ Hành rewards elements in order, Phong Nguyệt rewards collecting all four.

1. **The Four Beauties.** Go wide: take each facet's first notables, and the set bonus (Tứ Cảnh) does the rest.
2. **Beauty Is the Blade.** Crit as grace: crits come from Hoa and Nguyệt, crit damage from Tuyết; a crit caster
   with healing riders.
3. **The Wind Dancer.** Phong's speed and evade with Hoa's heals: a light, sustained skirmisher.
4. **Snow Calm.** Tuyết's calm: heart demon resistance and a slow, sure Cold build.

## Facets

### 1. Phong (Wind)
- **Small:** `art_speed_pct` +0.5 · `evade_pct` +0.4
- **Stat notables:** Breeze (Gió Nhẹ): art speed ×2 · Willow in Wind (Liễu Rủ): evade ×2 · Scent on the Wind (Hương
  Gió): art speed +1, healing +1 · Wind Song (Gió Hát): crit chance +1
- **Effects:**
  - **Major: Wind Carries Petals (Phong Tống Hoa).** Each art you fire gives your next heal +10 % (cap +50 %), and each
    heal gives your next art +5 % art speed (cap +25 %).
  - Minor: Light Breeze (Gió Thoảng). +5 % art speed while above 70 % health. *(starter)*
  - Minor: Wind Beauty (Phong Cảnh). +5 % art speed; counts as a Beauty for Tứ Cảnh.

### 2. Hoa (Flowers)
- **Small:** `healing_pct` +1.5 · `crit_chance_pct` +0.4
- **Stat notables:** Plum in Snow (Mai Tuyết): healing ×2 · Peony (Mẫu Đơn): crit chance ×2 · Orchid (Lan): healing +1,
  crit chance +0.5 · Chrysanthemum (Cúc): heart-demon resist +2
- **Effects:**
  - **Major: Flowers Bloom on the Crit (Hoa Khai Bạo Kích).** Your crits heal you for 1.5 % of max health (once per
    0.5 s).
  - Minor: Fragrance (Hương Thơm). Your heals over 3 % of max health give +2 pp crit chance for 3 s. *(starter)*
  - Minor: Flower Beauty (Hoa Cảnh). +8 % healing; counts as a Beauty for Tứ Cảnh.

### 3. Tuyết (Snow)
- **Small:** `attack_pct` cold +1 · `tam_ma_resist_pct` +1
- **Stat notables:** First Snow (Tuyết Đầu): cold ×2 · Snow Calm (Tuyết Lặng): heart-demon resist ×2 · Snowlight (Ánh
  Tuyết): cold +1, crit damage +1 · Drift (Tuyết Đọng): crit damage ×2
- **Effects:**
  - **Major: Snow Falls Silently (Tuyết Lạc Vô Thanh).** Your crits deal more by the number of Ice stacks on the target
    (crit damage +1 % per stack, cap +40 %, inside `crit_mult_cap`).
  - Minor: Cold Clarity (Lạnh Tỉnh). Heart demon gain from fights −20 %. *(starter)*
  - Minor: Snow Beauty (Tuyết Cảnh). Your Cold hits apply 1 Ice stack; counts as a Beauty for Tứ Cảnh.

### 4. Nguyệt (Moon)
- **Small:** `attack_pct` light +1 · `crit_chance_pct` +0.4
- **Stat notables:** Moon on Water (Trăng Nước): light ×2 · Moon Gaze (Ngắm Trăng): crit chance ×2 · Silver Night
  (Đêm Bạc): light +1, crit chance +0.5 · Moon Pavilion (Lầu Trăng): soul resist +2
- **Effects:**
  - **Major: Moon-Viewing Strike (Vọng Nguyệt Kích).** Your first crit every 5 s deals more (L5 +40).
  - Minor: Moon Watch (Trông Trăng). While you have not crit for 3 s, +5 pp crit chance. *(starter)*
  - Minor: Moon Beauty (Nguyệt Cảnh). +2 pp crit chance; counts as a Beauty for Tứ Cảnh.

### 5. Tứ Cảnh (the Four Beauties at Once)
- **Small:** `crit_damage_pct` +1.5 · `healing_pct` +1
- **Stat notables:** Scroll of Four (Tranh Tứ Bình): crit damage ×2 · Poet's Eye (Mắt Thi Nhân): crit chance +1,
  healing +1 · Four Seasons Garden (Vườn Bốn Mùa): regen +0.1 · Elegance (Phong Nhã): crit damage +1, art speed +0.5
- **Effects:**
  - **Major: The Four Beauties (Tứ Cảnh Hợp).** For each of the four "Beauty" minors you hold, your crits deal more
    (L5 +8 per Beauty; all four: L5 +32) and your crits restore 0.5 % of max linh lực per Beauty.
  - Minor: Two Beauties (Song Cảnh). With 2+ Beauties, +3 pp crit chance. *(starter)*
  - Minor: Four Together (Tứ Cảnh Tề). With all 4 Beauties, crit damage you take is dampened 20 % (rule 6a).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Beauty Is the Blade (Mỹ Tức Phong)** | keystone | Your crit multiplier cap is +0.3 higher (a cap shift, `Needs rule`; R14) while you hold all four Beauties | Your non-crit hits deal 25 % less (L2 −25) | Tứ Cảnh |
| **Wind, Flowers, Snow, Moon (Phong Hoa Tuyết Nguyệt)** | keystone | Each Beauty minor you own counts twice for The Four Beauties | Your heals are 25 % weaker and your crit damage −15 % | Tứ Cảnh |
| **Flowers on the Crit (Hoa Bạo)** | keystone | Flowers Bloom on the Crit heals 2.5 % (still once per 0.5 s) | Your max health is 25 % lower | Hoa |

## New pieces

- "Beauty" set counting: `Fits today` (an Effect reading which Effects you hold), needs a readable for held Effects.

## Kept apart from

Phong Đạo (Wind as speed and evade), Hoa Đạo (falling petals and decay), Thái Âm (moon phases). Phong Nguyệt is **a
set bonus for breadth, and crits that heal**.
