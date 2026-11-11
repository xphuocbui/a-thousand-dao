# 59 · Diệt Đạo · *Tịch Diệt* (Silent Extinction: Destruction)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. Holds the seed Destruction (†).
> **Theme stats:** `attack_pct` (all, chaos), `resist_pen_pct`, `crit_damage_pct`, `attack_pct` (overkill),
> `art_cost_health_pct`, `khi_huyet_pct` (negative on Tai Kiếp only).
> **Road:** `attack_pct` +1.2.

## Build directions

1. **Shatter.** Resistance shred: Sundered on every hit type, stacking (Phá Giáp), so high-resistance enemies
   (Combat rule 18's 150-point walls) melt. The enabler for every other build in a party of one.
2. **Annihilation.** Chaos damage with self-cost: the strongest raw multiplier in the game, paid in health and
   ward. Glass-cannon min-max.
3. **Collapse.** Damage past a broken ward shield carries into the next one at full strength, and overkill is
   stored for the next fight's opening. The ward-chain breaker.
4. **Calamity.** Self-destruction as a resource: each % of your own max health lost adds damage (Tai Kiếp).

## Facets

### 1. Hủy Hoại (Ruin) †
- **Small:** `attack_pct` +1.2 · `crit_damage_pct` +1.5
- **Stat notables:** Ruin (Hoang Tàn): attack ×2 · Crushing (Nghiền): crit damage ×2 · Wreckage (Đổ Nát): attack +1,
  penetration +1 · Rubble (Gạch Vụn): attack +2
- **Effects:**
  - **Major: Ruin (Hủy Diệt).** Your hits deal more for each damage type your hits and ticks have dealt to the target this fight (L5 +8 per type, cap +32; a converted part counts once, by its final type).
  - Minor: Crack (Nứt). Your crits apply Sundered. *(starter)*
  - Minor: Broken Things (Vật Vỡ). Your hits deal more to a target whose ward shields are all broken (L5 +12).

### 2. Phá Giáp (Shatter)
- **Small:** `resist_pen_pct` +0.6 · `attack_pct` +1
- **Stat notables:** Armour Breaker (Phá Giáp Thủ): penetration ×2 · Brittle Plate (Giáp Giòn): penetration +1, crit
  damage +1 · Shear Line (Đường Cắt): attack +1, penetration +1 · Rending (Xé): attack +2
- **Effects:**
  - **Major: Shatter Every Guard (Phá Vạn Giáp).** Sundered you apply holds one batch per damage type at once (each counts as one curse against `curse_slots`). (Effects rule 16, R27)
  - Minor: Weak Point (Điểm Yếu). Your first hit each fight applies Sundered for its largest type. *(starter)*
  - Minor: Brittle Body (Thân Giòn). A Sundered target's block is halved against your hits.

### 3. Diệt Tuyệt (Annihilation)
- **Small:** `attack_pct` chaos +1.5 · `resist_pen_pct` chaos +0.6
- **Stat notables:** Void Edge (Lưỡi Hư): chaos ×2 · Unmaking (Phân Giải): chaos penetration ×2 · End of Things (Tận
  Diệt): chaos +1, crit damage +1 · Black Sun (Hắc Nhật): chaos +2
- **Effects:**
  - **Major: Annihilate (Diệt Tuyệt).** Your Chaos hits deal more by the health you have lost (L5 +1 per 2 % of max
    health missing, cap +40).
  - Minor: Unravel (Tháo Gỡ). Your Chaos hits remove 1 of the foe's buff stacks (`strip_buff`, Effects rule 6, R16; once per pulse).
  - Minor: Extinction Touch (Chạm Diệt). Your basic attack converts 30 % to Chaos. *(starter)*

### 4. Sụp Đổ (Collapse)
- **Small:** `attack_pct` +1.2 · `crit_damage_pct` +1.5
- **Stat notables:** Avalanche (Lở): attack ×2 · Domino (Đổ Dây): crit damage +1, attack +1 · Cave-In (Sập Hầm):
  penetration +2 · Fault (Đứt): crit damage ×2
- **Effects:**
  - **Major: Collapse (Sụp Đổ).** When one hit of yours breaks 2 ward shields, your next hit deals more (L5 +30) and the foe's next ward cast costs 50 % more.
  - Minor: Momentum of Ruin (Đà Hủy). When your hit breaks a shield, your next hit deals more (L5 +15).
  - Minor: Aftermath (Hậu Quả). Excess damage from a killing blow (past 0 health) is recorded; at the start of your
    next fight this season, your first hit deals more (L5 +1 per 1 % of overkill, cap +20). *(starter)* `Needs key`.

### 5. Tai Kiếp (Calamity)
- **Small:** `attack_pct` +1.2 · `art_cost_health_pct` −1 (cheaper in health)
- **Stat notables:** Calamity (Tai Ương): attack ×2 · Burning Bridges (Đốt Cầu): attack +1, health cost −1 · Last Day
  (Ngày Tận): crit damage +2 · Self-Ruin (Tự Hủy): attack +2, max health −1 (a price on a stat node)
- **Effects:**
  - **Major: Calamity Fuel (Tai Kiếp Lực).** Health you pay for arts adds to your next hit: L5 +2 per 1 % of max
    health paid (cap +40), consumed by that hit.
  - Minor: Nothing Spared (Bất Lưu). While below 50 % health, your crits apply Sundered. *(starter)*
  - Minor: Ruined Vessel (Hủy Thể). While below 50 % health, your hits ignore 15 resistance points.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Nothing Is Left Standing (Vạn Vật Quy Hư)** | keystone | Your hits ignore 30 % of the target's resistance | You take 30 % more damage of every type (your own guard breaks too) | Phá Giáp |
| **Silent Extinction (Tịch Diệt)** | keystone | Your Chaos parts have `bypass_share` 50 % (the cap per part, skips ward shields only: Combat Defence rule 9, R2) | You cannot regenerate linh lực | Diệt Tuyệt |
| **The World Ends (Tận Thế)** | keystone | Calamity Fuel's cap is the L5 cap | Your max health is 40 % lower | Tai Kiếp |
| **Ruin Upon Ruin (Họa Vô Đơn Chí)** | keystone | Ruin counts every damage type twice (cap +72) | You must deal at least 3 damage types or your hits deal 30 % less (L2 −30) | Hủy Hoại |

## New pieces

- Sundered stacking by type: Effects rule 16, R27.
- Overkill carried into the next fight (Aftermath): `Needs key` (a season-scoped character stat).
- Collapse was reworked after review (the overflow it asked for is already Combat Defence rule 9).

## Kept apart from

Huyết Đạo (blood as currency, health costs as a lifestyle); Sát Đạo (killing intent, executions). Diệt is
**resistance shred, Chaos at a price, and the collapse of every guard**.
