# 84 · Thủ Đạo · *Thủ Hộ* (the Keeper)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. The ◇ Hộ Vệ (Protector: allies) and ◇ Khiêu Khích (Taunt)
> facets are archived; replaced here by **Canh Cổng (the Gatekeeper)** and **Phản Thủ (Guarded Counter)**.
> **Theme stats:** `defense_pct`, `ward_efficiency_pct`, `block_rating`, `body_shield_pct`, `khi_huyet_pct`, `resist_pct`.
> **Road:** `defense_pct` +1.2.

## Build directions

1. **Nothing Passes.** Ward stacking: every ward slotted strengthens the others, and the shields refill on a vigil
   clock (Thuẫn Tường, Canh Giữ). The pure ward tank.
2. **The Gatekeeper.** Hold a place: fights at a place you guard (a cave, a gate, a sect door) are fortress fights
   (Canh Cổng).
3. **The Guarded Counter.** Every hit your ward fully stops queues a counter (Phản Thủ): defence that kills.
4. **Unbroken.** The last line: when the ward falls, the body rises (Bất Khuất).

## Facets

### 1. Thuẫn Tường (Shield Wall)
- **Small:** `defense_pct` +1.2 · `ward_efficiency_pct` +1.2
- **Stat notables:** Wall of Shields (Tường Khiên): defense ×2 · Locked Shields (Khiên Khóa): ward efficiency ×2 · Tower
  Shield (Khiên Tháp): defense +1, ward +1 · Iron Wall (Tường Sắt): resist all +1
- **Effects:**
  - **Major: Shield Wall (Thuẫn Tường).** Each ward you have slotted gives every other slotted ward +10 % strength.
  - Minor: Ready Shield (Khiên Sẵn). Your first ward each fight is cast at 0.5 s. *(starter)*
  - Minor: Overlap (Chồng Khiên). Ward shields stop 5 % more while 3+ wards are up.

### 2. Canh Cổng (the Gatekeeper) — replaces ◇ Hộ Vệ
- **Small:** `block_rating` +1 · `formation_power_pct` +1
- **Stat notables:** Gate Guard (Lính Gác Cổng): block ×2 · Gate Array (Trận Cổng): formation ×2 · Doorway Stance (Thế
  Cửa): block +1, formation +1 · Keys (Chìa Khóa): defense +2
- **Effects:**
  - **Major: Hold the Gate (Giữ Cổng).** At a place you have sworn to guard (your cave, your sect's gate: one at a time),
    fights are foreseen for you and your wards are +25 %. `Needs key`.
  - Minor: Watchman (Người Canh). Intruders at your guarded place are detected a turn early. *(starter)*
  - Minor: Gate Never Opens (Cổng Không Mở). At your guarded place, foes cannot escape.

### 3. Phản Thủ (Guarded Counter) — replaces ◇ Khiêu Khích
- **Small:** `block_rating` +1 · `attack_pct` +1
- **Stat notables:** Shield Bash (Đập Khiên): attack ×2 · Riposte Guard (Thủ Phản): block ×2 · Edge of the Shield (Mép
  Khiên): attack +1, block +1 · Bracing Blow (Đòn Chống): force +2
- **Effects:**
  - **Major: Guarded Counter (Phản Thủ).** Each hit your ward stops fully queues a counter: a Force trigger hit scaled by
    your ward strength (`c_trig` 0.4, inside `trig_budget`).
  - Minor: Shield Edge (Viền Khiên). Your counters apply 1 Earth debuff stack. *(starter)*
  - Minor: Punish the Reckless (Phạt Kẻ Liều). Counters against a slow-tagged art deal +30 %.

### 4. Canh Giữ (Vigil)
- **Small:** `ward_efficiency_pct` +1.2 · `health_regen_pct` +0.05
- **Stat notables:** Long Watch (Canh Dài): ward efficiency ×2 · Night Fire (Lửa Canh): regen ×2 · Patient Guard (Gác
  Kiên Nhẫn): ward +1, regen +0.05 · Unsleeping (Không Ngủ): status resist +2
- **Effects:**
  - **Major: Vigil (Canh Giữ).** After 20 s, your ward shields refill 5 % of their value each pulse.
  - Minor: First Watch (Canh Đầu). For the first 10 s, your ward shields are +15 %. *(starter)*
  - Minor: Dawn Relief (Đổi Canh). At 30 s, restore 15 % of max linh lực.

### 5. Bất Khuất (Unbroken)
- **Small:** `khi_huyet_pct` +1 · `body_shield_pct` +1
- **Stat notables:** Unbowed (Không Khuất): max health ×2 · Last Shield (Khiên Cuối): body shield ×2 · Stand Alone (Đứng
  Một Mình): max health +1, body shield +1 · Iron Spine (Xương Sống Sắt): block +2
- **Effects:**
  - **Major: The Wall Falls, the Keeper Stands (Tường Đổ Người Còn).** When your last ward shield breaks, gain a body
    shield equal to 30 % of the ward shields' total value (once per 15 s).
  - Minor: Grim Resolve (Quyết Tâm). Below 30 % health, +15 block. *(starter)*
  - Minor: Rebuild (Dựng Lại). After the body shield from the major breaks, your next ward cast costs nothing.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Nothing Passes You (Nhất Phu Đương Quan)** | keystone | Your `ward_cap` is 15 % higher | You cannot slot more than 2 damaging arts | Thuẫn Tường |
| **Eternal Vigil (Vĩnh Canh)** | keystone | Vigil starts at 10 s and refills 8 % | Your arts cost 25 % more | Canh Giữ |
| **Shield and Spear (Khiên Và Giáo)** | keystone | Guarded Counter is outside `trig_budget` | Your arts deal 30 % less (L2 −30) | Phản Thủ |

## New pieces

- A sworn guarded place: `Needs key`.
- `ward_cap` shift: a cap shift, `Needs rule`, flagged.

## Kept apart from

Kim's The Gear Is the Body (armour as block), Băng's Glacier (Ice-fed ward shields), Thổ (Earth stacks). Thủ is
**wards that strengthen each other, the vigil, and counters from a full stop**.
