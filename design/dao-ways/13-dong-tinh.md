# 13 · Động Tĩnh Đạo · *Tĩnh Như Xử Nữ, Động Như Thoát Thố* (Motion and Stillness; Still as a Maiden, Swift as a Fleeing Hare)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `art_speed_pct`, `attack_pct`, `defense_pct`, `health_regen_pct`, `linh_luc_regen_pct`, `evade_pct`,
> `block_rating`.
> **Road:** `attack_pct` +0.6 and `defense_pct` +0.6.

## Build directions

1. **Two Stances.** Switch between Motion (offence, art speed) and Stillness (defence, regeneration) on your own
   rule: a guard you set before the fight decides when (Chuyển Thế). A build with two halves, tuned by one guard.
2. **The Coiled Spring.** Stillness stores power and Motion spends it in a burst (Tĩnh Cực Sinh Động): the
   charge-and-release build.
3. **The Unmoving.** Never switch: Stillness forever, with power from not acting; the anti-tempo tank.
4. **Pure Motion.** Motion forever: art speed and evade, the fast skirmisher that cannot regenerate.

## Facets

### 1. Động (Motion)
- **Small:** `art_speed_pct` +0.5 · `attack_pct` +1
- **Stat notables:** Hare's Speed (Tốc Thỏ): art speed ×2 · Strike First (Ra Tay Trước): attack ×2 · Never Still
  (Chẳng Ngừng): art speed +1, evade +1 · Rush (Lao Tới): attack +1, crit chance +0.5
- **Effects:**
  - **Major: Motion (Động Thế).** In Motion stance: +25 % art speed and your hits deal more (L5 +15); your
    regeneration of both pools is halved.
  - Minor: Quick Turn (Xoay Nhanh). Switching into Motion fires your next ready art at once. *(starter)*
  - Minor: Momentum (Đà Động). Each art fired in Motion gives +2 % art speed until you switch (cap +20 %).

### 2. Tĩnh (Stillness)
- **Small:** `defense_pct` +1.2 · `health_regen_pct` +0.05
- **Stat notables:** Maiden's Calm (Tĩnh Nữ): defense ×2 · Still Water (Nước Lặng): regen ×2 · Quiet Breath (Hơi
  Lặng): linh lực regen +0.15 · Rooted (Bám Rễ): block +1, defense +1
- **Effects:**
  - **Major: Stillness (Tĩnh Thế).** In Stillness stance: your arts do not fire, your regeneration of both pools is tripled and all damage you take is dampened 25 % (rule 6a). The basic attack still runs.
  - Minor: Settle (Lắng Xuống). Switching into Stillness cleanses 3 debuff stacks. *(starter)*
  - Minor: Calm Eye (Mắt Tĩnh). In Stillness, +10 pp evade.

### 3. Chuyển Thế (Switching Stances)
- **Small:** `art_speed_pct` +0.25 and `defense_pct` +0.6 · `evade_pct` +0.4
- **Stat notables:** Turning Point (Điểm Xoay): art speed +1, defense +1 ×2 · Fluid (Linh Hoạt): evade ×2 · Hinge
  (Bản Lề): regen +0.05, attack +1 · Pivot (Trục Xoay): block +2
- **Effects:**
  - **Major: Change of Stance (Chuyển Thế).** You start in a stance you choose and switch by a guard you set before the fight (own linh lực below or above a share, own health, or every N seconds), with a minimum of 4 s in each stance. Without this Effect, you switch every 8 s. `Needs key` (a stance guard).
  - Minor: Clean Switch (Chuyển Gọn). Switching gives 1 s of +20 pp evade. *(starter)*
  - Minor: Stance Memory (Nhớ Thế). Each switch gives L5 +5 for 4 s (cap +15).

### 4. Tĩnh Cực Sinh Động (Stillness Bursting into Motion)
- **Small:** `attack_pct` +1.2 · `crit_damage_pct` +1.5
- **Stat notables:** Coiled (Cuộn Mình): attack ×2 · Pounce (Vồ): crit damage ×2 · Held Arrow (Tên Giữ): attack +1,
  crit damage +1 · Spring Loaded (Lò Xo): art speed +2
- **Effects:**
  - **Major: The Hare Bolts (Thỏ Thoát).** Each second in Stillness stores L5 +6 (cap +60). Your first 3 **art** hits after switching into Motion share the store (each takes a third).
  - Minor: Ambush Stance (Thế Phục). Your first hit in Motion each time crits for certain. *(starter)*
  - Minor: Long Wait (Chờ Lâu). The store's cap is +80 after 10 s straight in Stillness.

### 5. Bất Động (Unmoving)
- **Small:** `defense_pct` +1.2 · `block_rating` +1
- **Stat notables:** Statue (Tượng Đá): defense ×2 · Anchor (Neo): block ×2 · Unmoved (Bất Di): defense +1, block +1 ·
  Patience (Kiên Nhẫn): regen +0.1
- **Effects:**
  - **Major: Unmoving (Bất Động Như Sơn).** In Stillness, your basic attack deals more by the time spent there (L5 +3
    per second, cap +45) and your block counts double.
  - Minor: Heavy Seat (Ngồi Nặng). `delay_timer` pushes on you (Effects rule 6, R1) do nothing in Stillness. *(starter)*
  - Minor: Patience Repaid (Nhẫn Được Đền). After 20 s in Stillness, your next switch into Motion refills 30 % linh lực.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Two Stances, One Master (Lưỡng Thế Nhất Chủ)** | keystone | Each stance keeps 40 % of the other stance's bonuses | Your minimum time in each stance is 8 s | Chuyển Thế |
| **Swift as a Fleeing Hare (Động Như Thoát Thố)** | keystone | You are always in Motion and Motion gives +40 % art speed | Motion's regeneration penalty stays, and all healing you receive is halved | Động |
| **Still as a Maiden (Tĩnh Như Xử Nữ)** | keystone | You are always in Stillness, and your arts may fire in it at half damage | You can never enter Motion | Tĩnh, Bất Động |
| **Stillness Gives Birth to Motion (Tĩnh Cực Sinh Động Đại)** | keystone | The Hare Bolts stores L5 +10 a second (cap +100) | Each Motion stint lasts at most 4 s | Tĩnh Cực Sinh Động |

## New pieces

- Stance (a two-state self-mode with a player-set guard): `Needs key` + Combat rule 13 guard vocabulary.
- Arts suppressed by a stance: Effects rule 16, R29 (a state may suppress named arts).
- The store (The Hare Bolts) and Momentum: self-counters with tag `growing` (Effects rule 8, R7), caps as written.

## Kept apart from

Hư Thực (feints and true strikes), Kỳ Đạo (planning and slot order), Vô Vi (power from not acting at all, no stance).
Động Tĩnh is **two stances, the coiled spring, and the guard that switches them**.
