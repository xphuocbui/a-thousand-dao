# 05 · Tứ Thời Đạo · *Xuân Hạ Thu Đông* (the Four Seasons; Spring, Summer, Autumn, Winter)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `healing_pct`, `health_regen_pct`, `attack_pct` (fire, physical, cold), `crit_damage_pct`,
> `herb_growth_pct`, `cultivation_speed_pct` (capped by `dao_rate_cap_pct`), `defense_pct`, `linh_luc_regen_pct`.
> **Road:** `herb_growth_pct` +2.

## Build directions

The other cycle Ways (Âm Dương's day and night, Thái Âm's phases, Thủy's tide) turn inside a fight. Tứ Thời turns
with the **world's calendar** (Pillar 4: every season counts). A build reads the real season outside.

1. **The Seasonal Specialist.** One facet deep, so one season of the year is very strong and the player plans the
   year around it: hunts in Summer, breakthroughs in Winter.
2. **The Year-Round.** All four facets shallow, and the Turning Year rewards each season lived through: a steady
   build that grows with time (Luân Niên).
3. **The Harvester.** Autumn's killing qi: execute and loot, plus herb-growth for the farmer-alchemist.
4. **Winter Rest.** Seclusion cultivation in Winter, and defence in fights; the build for the cautious long life.

## Facets

### 1. Xuân (Spring)
- **Small:** `healing_pct` +1.5 · `herb_growth_pct` +2
- **Stat notables:** New Shoots (Chồi Non): healing ×2 · Spring Rain (Mưa Xuân): regen ×2 · Planting (Gieo Trồng):
  herb growth ×2 · Green Return (Xanh Trở Lại): healing +1, regen +0.05
- **Effects:**
  - **Major: Spring Awakening (Xuân Sinh).** In Spring, your health regeneration is doubled in fights and your herb
    fields grow 25 % faster. Out of Spring, your heals are +10 %.
  - Minor: First Green (Xanh Đầu Mùa). In Spring, you start each fight with 10 Wood buff stacks for 10 pulses. *(starter)*
  - Minor: Thaw (Tan Băng). In Spring, Ice stacks on you expire twice as fast.

### 2. Hạ (Summer)
- **Small:** `attack_pct` fire +1.5 · `crit_damage_pct` +1
- **Stat notables:** Blazing Day (Ngày Rực): fire ×2 · Thunderstorm Season (Mùa Giông): crit damage ×2 · Long Light
  (Nắng Dài): fire +1, art speed +0.5 · Cicada Song (Ve Kêu): attack +2
- **Effects:**
  - **Major: Summer Fury (Hạ Nộ).** In Summer, your hits deal more (L5 +30). Out of Summer, your first art each fight
    deals more (L5 +20).
  - Minor: Heat Wave (Nắng Nóng). In Summer, your Burn batches last 1 pulse longer. *(starter)*
  - Minor: Short Nights (Đêm Ngắn). In Summer, your art speed is +10 %.

### 3. Thu (Autumn)
- **Small:** `attack_pct` physical +1.5 · `crit_damage_pct` +1
- **Stat notables:** Killing Frost (Sương Sát): physical ×2 · Falling Leaves (Lá Rụng): crit damage ×2 · Harvest Moon
  (Trăng Mùa Gặt): material yield +2 · Metal Wind (Gió Kim): physical +1, penetration +1
- **Effects:**
  - **Major: Autumn's Killing Qi (Thu Sát).** In Autumn, your hits on a target below 35 % health deal more (L5 +40);
    defeated creatures yield one more material roll. Out of Autumn, the execute is L5 +15.
  - Minor: Reaping (Gặt). Herbs you harvest in Autumn have +1 quality step chance. `Needs key`. *(starter)*
  - Minor: Bare Branches (Cành Trơ). In Autumn, your hits remove 1 of the foe's buff stacks (shared rule R16, once per pulse).

### 4. Đông (Winter)
- **Small:** `defense_pct` +1.2 · `attack_pct` cold +1
- **Stat notables:** Deep Snow (Tuyết Dày): defense ×2 · Long Winter (Đông Dài): cold ×2 · Hearth (Bếp Lửa): max health
  +1, regen +0.05 · Hibernation (Ngủ Đông): linh lực regen +0.15
- **Effects:**
  - **Major: Winter Stillness (Đông Tàng).** In Winter, seclusion cultivation progress is +10 % (within `dao_rate_cap_pct`), and in fights all damage you take is dampened 15 % (rule 6a). Out of Winter, dampened 5 %.
  - Minor: Frozen Ground (Đất Đóng Băng). In Winter, your Cold hits apply 1 extra Ice stack for 6 pulses. *(starter)*
  - Minor: Store for Winter (Tích Trữ). Pills you brewed in Autumn are 10 % stronger in Winter. `Needs key`.

### 5. Luân Niên (the Turning Year)
- **Small:** `attack_pct` +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Turning Year (Năm Xoay): attack ×2 · Annual Ring (Vòng Năm): max health ×2 · Almanac (Lịch Pháp):
  attack +1, max health +1 · Four Corners (Tứ Phương): defense +1, attack +1
- **Effects:**
  - **Major: Every Season Counts (Tứ Thời Tích Lũy).** For each season you have lived through holding this Dao, +0.1 %
    attack and max health (cap +8 %, which is 20 years). `Needs key` (a counter).
  - Minor: Season's Turn (Chuyển Mùa). In the first month of each season, your fights start with 10 buff stacks of
    that season's element (Spring Wood, Summer Fire, Autumn Metal, Winter Water). *(starter)*
  - Minor: Weather-Wise (Thạo Thời Tiết). Weather events give you an extra choice. `Needs key`.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Always the Right Season (Tứ Thời Như Ý)** | keystone | Choose one season: its facet's in-season Effects apply all year, at half strength out of season | The other three facets' Effects, in and out of season, never apply (their consolation lines included) | any |
| **Endless Summer (Trường Hạ)** | keystone | Summer Fury's in-season bonus applies in Spring and Autumn too | Out of those seasons, Summer Fury gives nothing, and your regeneration is −25 % all year | Hạ |
| **The Long Winter (Trường Đông)** | keystone | Winter Stillness's in-season Effects apply in Autumn and Winter, and its dampening is 25 % | Your regeneration is −25 % in every season | Đông |
| **Wheel of the Year (Niên Luân)** | keystone | Every Season Counts has no cap and counts double in seclusion | Each failed breakthrough loses 4 seasons of its count | Luân Niên |

## New pieces

- The world season readable in fights and crafts: `Needs key` (a world-time readable, shared with Thái Âm and Quỷ).
- A seasons-lived counter: `Needs key`.

## Kept apart from

Âm Dương's Day and Night, Thái Âm's phases, Thủy's tide: in-fight cycles. Thời Đạo (time as speed and ageing). Tứ
Thời is **the real calendar outside, and power that grows with the years**.
