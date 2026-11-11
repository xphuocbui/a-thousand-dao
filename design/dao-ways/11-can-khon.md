# 11 · Càn Khôn Đạo · *Tụ Lý Càn Khôn* (Heaven and Earth in a Sleeve: Space; a World in a Sleeve)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. Holds the seed Space (†).
> **Theme stats:** `evade_pct`, `escape_pct`, `travel_speed_pct`, `attack_pct` (force), `resist_pen_pct` (force),
> inventory capacity (Needs key), `than_thuc_pct`.
> **Road:** `evade_pct` +0.4.

## Build directions

1. **The Blink.** Step through space: evades that become counters, and a short untouchable step on a cooldown
   (Thuấn Bộ). A defensive duelist who punishes misses.
2. **The Rift.** Force damage that tears space: each rift hit leaves a Rift on the foe that makes its wards leak
   (Liệt Không). The ward-breaker for Force.
3. **The Sleeve.** Carry more: an extra artifact, more talisman stock, pills kept fresh. The inventory min-max
   that feeds preparation builds (Tụ Lý).
4. **The Sealed Place.** Close space around the fight: no escape for either, and a fight that must end (Phong Tỏa).

## Facets

### 1. Thuấn Bộ (Step)
- **Small:** `evade_pct` +0.4 · `escape_pct` +1
- **Stat notables:** Blink (Thuấn Di): evade ×2 · Fold Step (Bước Gấp): escape ×2 · Between Places (Giữa Chốn): evade
  +1, escape +1 · Afterimage (Dư Ảnh): crit chance +1
- **Effects:**
  - **Major: Step Through Space (Thuấn Bộ).** When you evade, your next hit deals more (L5 +25) and ignores the foe's block (`Needs key`: a block-ignore flag).
  - Minor: Folded Distance (Rút Ngắn). The foe's first art each fight is delayed by 0.5 s (it must find you).
    *(starter)*
  - Minor: Slip the Grip (Thoát Kẹp). Your escape chance is +15 % while you have evaded in the last 2 s.

### 2. Tụ Lý (the Sleeve)
- **Small:** inventory slots +1 · `than_thuc_pct` +0.5
- **Stat notables:** Deep Sleeve (Tay Áo Sâu): inventory ×2 · Pocket World (Thế Giới Túi): thần thức ×2 · Fresh Keep
  (Giữ Tươi): pill effect +2 · Hidden Pocket (Túi Ẩn): talisman power +2
- **Effects:**
  - **Major: World in a Sleeve (Tụ Lý Càn Khôn).** +1 artifact equipped beyond `equip.max_slots`, and each slotted
    talisman has +1 stock.
  - Minor: Time-Stopped Pouch (Túi Ngừng Thời). Pills and herbs you carry do not lose potency over time. `Needs key`.
    *(starter)*
  - Minor: Quick Draw from the Sleeve (Rút Nhanh). Your talismans fire 0.5 s sooner.

### 3. Liệt Không (Rift)
- **Small:** `attack_pct` force +1.5 · `resist_pen_pct` force +0.6
- **Stat notables:** Tear (Xé): force ×2 · Space Cut (Chém Không): force penetration ×2 · Void Edge (Lưỡi Không): force
  +1, crit damage +1 · Fracture (Rạn): force +2
- **Effects:**
  - **Major: Rift (Liệt Không).** Your Force hits leave a Rift (stacks to 5, 3 pulses): each Rift makes the target's ward
    shields stop 6 % less of each hit.
  - Minor: Torn Ward (Hộ Rách). Your Force crits make the foe's drain ward bill +20 % for 2 pulses. *(starter)*
  - Minor: Space Shear (Cắt Không Gian). Your Force hits ignore 10 % of the target's block (`Needs key`, the same block-ignore flag).

### 4. Súc Địa (Folding the Earth)
- **Small:** `travel_speed_pct` +2 · `escape_pct` +1
- **Stat notables:** Shrink the Land (Thu Đất): travel ×2 · Long Stride (Sải Dài): travel +1, escape +1 · Map Fold
  (Gấp Bản Đồ): travel +1, evade +1 · Far Gate (Cổng Xa): escape ×2
- **Effects:**
  - **Major: Fold the Earth (Súc Địa Thành Thốn).** Travel takes 40 % less time; once a season, choose where a fight
    happens when an encounter starts (pick the ground). `Needs key` (Travel, Event Engine).
  - Minor: Short Road (Đường Tắt). Travel encounters are 20 % rarer. *(starter)*
  - Minor: Home Fold (Gấp Về Nhà). Once a season, return home instantly.

### 5. Phong Tỏa (Sealed Place)
- **Small:** `defense_pct` +1.2 · `attack_pct` force +1
- **Stat notables:** Sealed Space (Không Gian Phong): defense ×2 · Closed World (Thế Giới Đóng): force ×2 · Space Lock
  (Khóa Không): defense +1, force +1 · No Exit (Không Lối Ra): status resist +2
- **Effects:**
  - **Major: Seal the Space (Phong Tỏa Không Gian).** Neither side's escape art can fire (a closing rule on both sides). If you slot no escape art, your hits deal more (L5 +15).
  - Minor: Closed Door (Cửa Đóng). Foes cannot escape from you below 30 % health. *(starter)*
  - Minor: Pressed Space (Ép Không Gian). In a sealed fight, every 10 s apply Pressed to the foe (a curse: −3 pp evade per stack, stacks to 5, lasts until the fight ends or is cleansed).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Here and There at Once (Thử Bỉ Đồng Tại)** | keystone | Step Through Space triggers on every evade and on every hit you block fully | Your max health is 20 % lower | Thuấn Bộ |
| **Heaven and Earth in a Sleeve (Tụ Lý Càn Khôn Đại Pháp)** | enabler | +2 artifacts beyond the slot cap | Your artifacts' thần thức cost +40 % | Tụ Lý |
| **Shattered Space (Không Gian Toái)** | keystone | Rifts stack to 10 | Your non-Force hits deal 30 % less (L2 −30) | Liệt Không |
| **A World Apart (Biệt Giới)** | keystone | Fights you seal cannot be interfered with by events (no third parties) and your hits deal +10 % | Your max health is 15 % lower | Phong Tỏa |

## New pieces

- Rift and Pressed (statuses): `Needs key`; a block-ignore flag: `Needs key`.
- Inventory capacity key: `Needs key`.
- Choosing the ground of an encounter: `Needs key`.

## Kept apart from

Tiêu Dao (travel as freedom), Phong's Lãng Du (travel and escape), Kim's Living Arsenal (+1 artifact from Metal;
Càn Khôn's is storage). Càn Khôn is **the blink, the rift, the sleeve and the sealed place**.
