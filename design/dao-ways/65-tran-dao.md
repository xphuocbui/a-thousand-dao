# 65 · Trận Đạo · *Phong Thủy* (Wind and Water: Geomancy)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. Holds the seed Array (†) and the proposed Talisman Đạo
> (Phù Lục facet).
> **Theme stats:** `formation_power_pct`, formation upkeep, `talisman_ink_pct`, talisman power, `defense_pct`,
> `linh_luc_regen_pct`, `cultivation_speed_pct` (capped).
> **Road:** `formation_power_pct` +1.2.

## Build directions

1. **The Fortress.** Formations at L4's cap on home ground: monstrous in a foreseen fight, weak in a blind one; the
   build wants to choose its fights (Trận Pháp, Động Phủ).
2. **Spirit Veins.** Geomancy: find and tap spirit veins for cultivation speed and in-fight regeneration on that
   ground (Linh Mạch).
3. **The Talisman Master.** Talismans as the main damage: strong single-use arts with stock (Phù Lục).
4. **The Ward Array.** Formations that act as wards: shields that do not drain your pool (Hộ Trận).

## Facets

### 1. Trận Pháp (Arrays) †
- **Small:** `formation_power_pct` +1.2 · formation upkeep −1
- **Stat notables:** Eight Gates (Bát Môn): formation power ×2 · Cheap Flags (Cờ Rẻ): upkeep ×2 · Interlocked (Trận Liên
  Hoàn): formation +1, upkeep −1 · Killing Array (Sát Trận): attack +2
- **Effects:**
  - **Major: Linked Arrays (Liên Trận).** You may lay 2 formations on one ground; their L4 adds (cap still holds).
  - Minor: Quick Setup (Bày Nhanh). Laying a formation takes half the time. *(starter)*
  - Minor: Array Eye (Mắt Trận). Your formations' L4 is +5 while you stand on their ground.

### 2. Linh Mạch (Spirit Veins)
- **Small:** `linh_luc_regen_pct` +0.075 · `cultivation_speed_pct` +0.4
- **Stat notables:** Dowsing (Dò Mạch): linh lực regen ×2 · Vein Tap (Chích Mạch): cultivation speed +1 · Dragon Vein
  (Long Mạch): regen +0.05, cultivation +0.5 · Earth's Pulse (Mạch Đất): max linh lực +2
- **Effects:**
  - **Major: Tap the Vein (Dẫn Linh Mạch).** On ground with a spirit vein, your linh lực regeneration in fights is
    doubled, and seclusion there is +10 % (inside the per-Dao cap). `Needs key` (veins on the map).
  - Minor: Find the Vein (Tìm Mạch). You see spirit veins on the map. *(starter)*
  - Minor: Vein Ward (Hộ Mạch). Formations on a vein need no upkeep.

### 3. Phù Lục (Talismans)
- **Small:** talisman power +2 · `talisman_ink_pct` +1
- **Stat notables:** Thunder Talisman (Phù Lôi): talisman power ×2 · Ink Saver (Tiết Kiệm Mực): ink ×2 · Talisman Stack
  (Chồng Phù): talisman power +1, ink +1 · Sealed Paper (Giấy Phong): defense +2
- **Effects:**
  - **Major: Talisman Barrage (Phù Trận).** Each talisman you fire gives your next talisman L4 +8 (cap +40); talismans
    you slot have +1 stock.
  - Minor: Ready Talisman (Phù Sẵn). Your first talisman each fight fires at 1 s. *(starter)*
  - Minor: Twin Talisman (Phù Đôi). A talisman fired with another in the same instant deals +15 %.

### 4. Hộ Trận (Ward Arrays)
- **Small:** `defense_pct` +1.2 · `formation_power_pct` +1
- **Stat notables:** Protective Ring (Vòng Hộ): defense ×2 · Ward Flags (Cờ Hộ): formation power ×2 · Steady Ward (Hộ
  Vững): defense +1, formation +1 · Mountain-Guard Array (Hộ Sơn Trận): resist all +1
- **Effects:**
  - **Major: Ward Array (Hộ Trận).** A ward formation you lay gives a ward shield of 10 % of your max linh lực that
    refreshes every 10 s and does not drain your pool.
  - Minor: Array Shelter (Trận Che). On your formation ground, curses on you last 1 pulse less. *(starter)*
  - Minor: Reinforce (Gia Cố). Ward Array refreshes every 8 s.

### 5. Động Phủ (the Cave Dwelling)
- **Small:** `formation_power_pct` +1.2 · `health_regen_pct` +0.05
- **Stat notables:** Home Cave (Động Nhà): formation ×2 · Quiet Chamber (Thất Tĩnh): regen ×2 · Stone Gate (Cửa Đá):
  defense +1, formation +1 · Spirit Garden (Vườn Linh): herb growth +2
- **Effects:**
  - **Major: Home Ground (Động Phủ).** Fights at your cave dwelling are always foreseen for you, and your formations
    there run at +25 %.
  - Minor: Guarded Door (Cửa Có Canh). Intruders at your cave are fought with your formations already laid.
    *(starter)*
  - Minor: Restful Cave (Động Yên). Seclusion at your cave recovers heart demon 20 % faster.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **A Formation within the Body (Thân Trung Hữu Trận)** | keystone | One formation is carried in your body: it applies in every fight at 50 % power, any situation | You cannot lay ground formations | Trận Pháp |
| **Wind and Water (Phong Thủy)** | keystone | Tap the Vein works on any ground you have laid a formation on | Your formations cost double upkeep | Linh Mạch |
| **Ten Thousand Talismans (Vạn Phù)** | keystone | Talisman Barrage's cap is +80 | Your non-talisman arts deal 30 % less (L2 −30) | Phù Lục |

## New pieces

- Spirit veins on the map; formations carried in the body: `Needs key` / `Needs rule`.

## Kept apart from

Tinh's Array in the Sky (one formation carried in the sky; Trận's capstone carries one in the body: these are rival
answers to the same problem, keep both but never both on one character via `dao` rival marking), Kỹ's Chế Trận
(formation crafting), Vực (a domain). Trận is **arrays on the ground, veins, talismans and home**.
