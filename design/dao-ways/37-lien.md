# 37 · Liên Đạo · *Thanh Liên* (Blue Lotus)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `healing_pct`, `health_regen_pct`, `status_resist_pct`, `defense_pct`, `ward_efficiency_pct`,
> `tam_ma_resist_pct`, `cast_ward_duration_pct`, `attack_pct` (water, light).
> **Road:** `status_resist_pct` +1.

## Build directions

1. **The Seed Bank.** Lotus Seeds grow on a timer and are eaten automatically at low health: stored heals that
   cost no slot and no linh lực. A sustain build that is strong exactly when the burst build thinks it has won.
2. **Out of the Mud.** Each debuff or curse cleansed from you becomes power: the more the foe dirties you, the
   brighter you bloom. Counter-build against curse and poison players.
3. **The Lotus Throne.** A ward that grows a petal each pulse you are not hit, and each petal is a layer of
   shield; a slow, patient ward tank.
4. **The Calm.** Lotus scent: heart-demon immunity in fights and a foe that slows down. Control by calm.

## Facets

### 1. Xuất Bùn (Out of the Mud)
- **Small:** `status_resist_pct` +1 · `attack_pct` +1
- **Stat notables:** Clean Stem (Thân Sạch): status resist ×2 · Rise Up (Vươn Lên): attack ×2 · Mud Below (Bùn
  Dưới): status resist +1, max health +1 · Unstained (Không Vấy): chaos resistance +2
- **Effects:**
  - **Major: Out of the Mud (Xuất Ứ Nê Nhi Bất Nhiễm).** Each debuff stack or curse **cleansed** from you gives L5 +2 for 10 s (cap +40).
  - Minor: Untouched (Bất Nhiễm). Your cleanses remove 1 more stack. *(starter)*
  - Minor: Bloom in Dirt (Nở Trong Bùn). While you carry 3+ different debuffs, your regeneration is 50 % higher.

### 2. Tịnh Thủy (Pure Water)
- **Small:** `healing_pct` +1.5 · `status_resist_pct` +1
- **Stat notables:** Pure Spring (Suối Tịnh): healing ×2 · Clear Pond (Ao Trong): status resist ×2 · Holy Dew (Sương
  Thánh): healing +1, status resist +1 · Wash Clean (Rửa Sạch): regen +0.1
- **Effects:**
  - **Major: Pure Water (Tịnh Thủy).** Every 8 s, cleanse up to 15 debuff stacks of the element with the most stacks on you.
  - Minor: Purifying Heal (Trị Tịnh). Your heals over 5 % of max health cleanse 2 stacks. *(starter)*
  - Minor: Clean Breath (Hơi Sạch). Stagnation on you lasts 1 pulse less.

### 3. Liên Đài (the Lotus Throne)
- **Small:** `defense_pct` +1.2 · `ward_efficiency_pct` +1.2
- **Stat notables:** Thousand-Petal Seat (Đài Ngàn Cánh): defense ×2 · Lotus Ward (Hộ Sen): ward efficiency ×2 ·
  Floating Throne (Đài Nổi): defense +1, cast ward duration +1 · Stillness Seat (Tòa Tĩnh): soul resist +2
- **Effects:**
  - **Major: Lotus Throne (Liên Đài).** Each pulse you are not hit, grow 1 Petal (cap 9): each Petal is a ward shield of 2 % of max linh lực (scaled by ward strength), refilled each pulse; a hit that lands on health loses 2 Petals.
  - Minor: Opening Petals (Cánh Nở). You start each fight with 3 Petals. *(starter)*
  - Minor: Closed Bud (Nụ Khép). While you hold 9 Petals, curses on you last 1 pulse less.

### 4. Liên Tử (Lotus Seeds)
- **Small:** `health_regen_pct` +0.05 · `healing_pct` +1
- **Stat notables:** Seed Pod (Gương Sen): healing ×2 · Lotus Heart (Tim Sen): regen ×2 · Green Seed (Hạt Xanh):
  healing +1, max health +1 · Old Seed (Hạt Già): regen +0.05, healing +1
- **Effects:**
  - **Major: Lotus Seeds (Liên Tử).** Every 6 s, grow a Seed (cap 5). Each time your health crosses below 35 %, eat one: heal 12 % of max health. At most 3 Seeds a fight.
  - Minor: Seed Ready (Hạt Sẵn). You start each fight with 1 Seed. *(starter)*
  - Minor: Bitter Heart (Tâm Đắng). Eating a Seed also cleanses 3 debuff stacks.

### 5. Hương Liên (Lotus Scent)
- **Small:** `tam_ma_resist_pct` +1 · `status_resist_pct` +1
- **Stat notables:** Faint Scent (Hương Thoảng): heart-demon resist ×2 · Calm Water (Nước Lặng): status resist ×2 ·
  Incense of Lotus (Nhang Sen): heart-demon resist +1, soul resist +1 · Still Pond (Ao Tĩnh): regen +0.1
- **Effects:**
  - **Major: Calming Scent (Hương Định Tâm).** Every 3 s, apply 1 Calmed stack to the foe (a curse: −1 % art speed per stack, stacks to 15, 5 pulses, refreshed by each new stack; `Needs key` and `Needs rule`: art speed is not yet a curse rule), and its growing self-counters (shared rule R7) gain 30 % slower.
  - Minor: Clear Mind in Battle (Chiến Tâm Thanh). Heart demon gained from fights is 30 % lower. *(starter)*
  - Minor: Soothing (Xoa Dịu). Afraid (Tình's proposed curse) cannot be placed on you.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Untouched by the Mud (Xuất Nê Bất Nhiễm)** | keystone | You are immune to the first 3 debuff stacks of each element each pulse, and Out of the Mud counts each refused stack | Your hits deal 25 % less (L2 −25) | Xuất Bùn |
| **Blue Lotus Throne (Thanh Liên Bảo Tọa)** | keystone | Lotus Throne grows 2 Petals a pulse, cap 15 | Your arts cost 20 % more | Liên Đài |
| **Seed of Rebirth (Liên Tử Tái Sinh)** | keystone | At the Down step's refusal, eat every Seed at once instead of going Down (if they heal you above 0) | Seeds grow every 9 s | Liên Tử |
| **Heart of the Lotus (Liên Tâm)** | keystone | You cannot gain heart demon in fights, and the status-resistance clamp floor is 0 % for you (a certain resist is possible) | Your hits deal 15 % less (L2 −15) | Hương Liên |

## New pieces

- A tag for growing self-stacks (Fury, Hunger, Spin, Dragon stacks): `Needs key` (lets counters read them).

## Kept apart from

Thủy (Water), Bồ Đề (merit and healing others), Thiền Đạo (stillness and vows), Mộc's Blossom (Wood stack bursts).
Liên is **seeds eaten at the edge, the throne of petals, and power from being cleansed**.
