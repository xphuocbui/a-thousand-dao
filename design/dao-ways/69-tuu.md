# 69 · Tửu Đạo · *Túy Tiên* (the Drunken Immortal)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `evade_pct`, `attack_pct` (fire, physical), `tam_ma_resist_pct`, `pill_effect_pct`, `health_regen_pct`,
> `crit_damage_pct`.
> Also used below, listed here (dao.md rule 12): `stack_effect_pct` (fire), max linh lực, fire resist, `khi_huyet_pct`,
> unscoped `attack_pct`, brewing success (`Needs key`).
> **Road:** `evade_pct` +0.4.

## Build directions

Drink is a **fight meter**: Tipsiness (Say) rises as you drink spirit wine before and during the fight, and every
facet reads it. Too much, and you lose control (a fumble). Tipsiness is a self-counter (Effects rule 8, R7, tag `growing`): it is added
by drinking and sipping, caps at 30, never decays, and is read live by the facets (before the fight it is a life readable,
Character Stats rule 9a).

1. **Drunken Fist.** Evade and counters that rise with Tipsiness; erratic but counted (Túy Quyền).
2. **The Brewer.** Spirit wine as a craft: wines are long buffs and fight fuel (Ủ Rượu).
3. **Fire Wine.** Breathe fire: wine converts to Fire damage and Burn (Hỏa Tửu).
4. **Revelry.** Heart demon down, joy up; the carefree drinker's life-around (Cuồng Hoan).
5. **The Hangover.** Power now, a price after the fight (Say Mèm).

## Facets

### 1. Túy Quyền (Drunken Fist)
- **Small:** `evade_pct` +0.4 · `attack_pct` physical +1
- **Stat notables:** Stagger Step (Bước Loạng Choạng): evade ×2 · Lazy Fist (Quyền Lười): physical ×2 · Tipsy Sway (Lắc
  Lư): evade +1, physical +1 · Spilled Cup (Chén Đổ): crit damage +2
- **Effects:**
  - **Major: Drunken Fist (Túy Quyền).** Each point of Tipsiness gives +1 pp evade (cap +15, inside `evade_cap`); each
    evade gives a counter hit (basic attack, once per 1 s).
  - Minor: Wobble (Lảo Đảo). +5 pp evade while Tipsiness is 5+. *(starter)*
  - Minor: Fall and Rise (Ngã Rồi Dậy). Every 10th Tipsiness point gained in the fight fumbles your next art (it waits 1 s) and gives L5
    +20 to the one after. Tipsiness you start the fight with does not fumble.

### 2. Ủ Rượu (Brewing)
- **Small:** `pill_effect_pct` +1 · brewing success +1
- **Stat notables:** Old Jar (Vò Cũ): pill effect ×2 · Spirit Grain (Hạt Linh): brewing ×2 · Cellar (Hầm Rượu): pill effect
  +1, brewing +1 · Wine Gourd (Hồ Lô Rượu): max linh lực +2
- **Effects:**
  - **Major: Spirit Wine (Linh Tửu).** You can brew spirit wine. Before a fight, drink up to 3 (Drink Deep raises it to 6): each gives 5 Tipsiness
    and its own buff (+8 % of one stat, each wine a different stat) for the fight. `Needs key` (wine items).
  - Minor: Good Year (Năm Rượu Ngon). Wines aged a year give +50 %. *(starter)*
  - Minor: Gourd at the Hip (Hồ Lô Bên Hông). In a fight, you sip: +1 Tipsiness every 5 s.

### 3. Hỏa Tửu (Fire Wine)
- **Small:** `attack_pct` fire +1 · `stack_effect_pct` fire +1
- **Stat notables:** Burning Liquor (Rượu Cháy): fire ×2 · Firebreath (Thở Lửa): fire stack effect ×2 · Strong Spirit
  (Rượu Mạnh): fire +1, crit damage +1 · Warm Belly (Bụng Ấm): fire resist +2
- **Effects:**
  - **Major: Breathe Fire (Phun Lửa).** Each Tipsiness converts 1 % of your hits to Fire (cap 25 %; a conversion, Combat Damage Types rule 6, one of the 2 per hit) and
    your Fire hits apply 1 Burn per 5 Tipsiness (4 pulses).
  - Minor: Flaming Cup (Chén Lửa). Your first Fire art each fight applies 10 Burn. *(starter)*
  - Minor: Alcohol Burns (Cồn Cháy). Burn you apply lasts 1 pulse longer while Tipsiness is 10+.

### 4. Cuồng Hoan (Revelry)
- **Small:** `tam_ma_resist_pct` +1 · `health_regen_pct` +0.05
- **Stat notables:** Merry Heart (Lòng Vui Say): heart-demon resist ×2 · Feast (Tiệc): regen ×2 · Toast (Nâng Chén):
  heart-demon resist +1, regen +0.05 · Song and Wine (Ca Và Rượu): max health +2
- **Effects:**
  - **Major: Drunk Is Enlightened (Say Là Ngộ).** Heart demon decays 2 per week while you drink (any wine), and once a
    season a drunken night gives a comprehension insight (seeded chance, not counted: counted chance is keystone-only, Effects rule 12). `Needs key`.
  - Minor: Good Company (Bạn Nhậu). Taverns give an extra rumour. *(starter)*
  - Minor: Liquid Courage (Can Đảm Nhờ Rượu). Fear Effects do nothing to you while Tipsiness is 5+.

### 5. Say Mèm (Hangover)
- **Small:** `attack_pct` +1.2 · `khi_huyet_pct` +0.5
- **Stat notables:** Last Round (Chén Cuối): attack ×2 · Iron Liver (Gan Sắt): max health ×2 · One More (Thêm Chén):
  attack +1, max health +1 · Bleary Eyes (Mắt Lờ Đờ): crit damage +2
- **Effects:**
  - **Major: Drink Deep (Say Khướt).** You may drink up to 6 wines before a fight (up to 30 Tipsiness): each point above 15 gives L5 +3; after
    the fight, a hangover gives −10 % to all stats for 3 days.
  - Minor: Hair of the Dog (Giải Rượu Bằng Rượu). A hangover is cured by drinking again (and costs a wine). *(starter)*
  - Minor: Blackout (Say Bất Tỉnh). At 30 Tipsiness, the foe's first crit against you each fight misses.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Drunken Immortal (Túy Tiên)** | keystone | Drunken Fist's evade cap is +25 (still inside `evade_cap`) | Your arts fumble every 5th Tipsiness point instead of the 10th | Túy Quyền |
| **A Thousand Cups Never Drunk (Thiên Bôi Bất Túy)** | keystone | Tipsiness never fumbles | Tipsiness caps at 20 (rival: Drink Deep, Blackout) | Ủ Rượu |
| **The Burning Gourd (Hỏa Hồ Lô)** | keystone | Breathe Fire converts 2 % per Tipsiness, cap 50 % | Your heals are halved (the liver is busy) | Hỏa Tửu |

## New pieces

- Tipsiness: pointed at a self-counter (R7) and a life readable (R13). Wine items, brewing success: `Needs key`.

## Kept apart from

Đan Đạo (pills), Tiêu Dao (carefree), Phong (evade as wind). Tửu is **a drink meter that feeds evade, fire and
power, with a fumble and a hangover**.
