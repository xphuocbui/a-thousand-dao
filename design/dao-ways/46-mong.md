# 46 · Mộng Đạo · *Hồ Điệp Mộng* (the Butterfly Dream)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `evade_pct`, `comprehension`, `tam_ma_resist_pct`, `status_resist_pct`, `formation_power_pct`, `soul_res_pct`,
> `health_regen_pct`.
> **Road:** `soul_res_pct` +1.

## Build directions

The fight begins as a **Dream**: a stretch of time (default 6 s) at the start in which damage you take is undone
when you wake, and damage you deal is kept at half. The Way builds around that window.

1. **The Dreamer's Opening.** Open with your most expensive, riskiest arts while dreaming (nothing you lose is
   real), then wake to a fight where the foe has spent its burst on a dream. The counter to first-volley builds.
2. **The Butterfly.** Evade that grows while dreaming and stays after (Hồ Điệp).
3. **Dream into Real.** Once per fight, choose which is the dream: swap the last 6 s of both sides' health
   changes (Thực Mộng). The comeback trick.
4. **The Sleeper.** Insight from sleep between fights (Mộng): life-around comprehension.

## Facets

### 1. Mộng (Dream)
- **Small:** `comprehension` +1 · `tam_ma_resist_pct` +1
- **Stat notables:** Deep Sleep (Ngủ Say): comprehension ×2 · Sweet Dreams (Giấc Êm): heart-demon resist ×2 · Lucid (Mộng
  Tỉnh): comprehension +1, heart-demon resist +1 · Pillow Stone (Gối Đá): regen +0.1
- **Effects:**
  - **Major: The Dream (Nhập Mộng).** Each fight begins with a 6 s Dream: health you lose in it is restored when it ends;
    damage you deal in it counts at 50 %. Both sides' arts fire normally. `Needs key` (the Dream window) +
    `Needs rule` (undo on waking).
  - Minor: Dreamless Rest (Ngủ Không Mộng). A night's sleep after a fight removes 3 heart demon. *(starter)*
  - Minor: Dream Lesson (Bài Học Trong Mơ). Seclusion progress +5 % in seasons with no fights.

### 2. Hồ Điệp (the Butterfly)
- **Small:** `evade_pct` +0.4 · `soul_res_pct` +1
- **Stat notables:** Wing Dust (Phấn Cánh): evade ×2 · Flutter (Chập Chờn Bay): evade +1, soul resist +1 · Paper Wings
  (Cánh Giấy): evade +1, art speed +0.5 · Painted Wings (Cánh Vẽ): crit chance +1
- **Effects:**
  - **Major: Butterfly Wings (Hồ Điệp Dực).** During the Dream, your evade is +20 pp (inside `evade_cap`); each hit you
    evade in it gives +1 pp evade for the rest of the fight (cap +8).
  - Minor: Light as a Wing (Nhẹ Như Cánh). Your evade counts double against the foe's first art each fight. *(starter)*
  - Minor: Wing Beat (Vỗ Cánh). After you evade, your next art's cost −15 %.

### 3. Thực Mộng (Dream into Real)
- **Small:** `status_resist_pct` +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Which Is Real (Thật Hay Mơ): status resist ×2 · Wake Strong (Tỉnh Mạnh): max health ×2 · Between
  (Giữa Mơ Thực): status resist +1, max health +1 · Dream Logic (Lý Mộng): soul resist +2
- **Effects:**
  - **Major: Which One Is Dreaming (Trang Chu Mộng Điệp).** Once per fight, at a guard you set, swap the last 6 s of
    health changes between you and the foe (what you lost, it lost; what it lost, you lost). `Needs rule`.
  - Minor: Half-Awake (Nửa Tỉnh). The Dream lasts 2 s longer. *(starter)*
  - Minor: Dream Wound (Vết Thương Mơ). Damage you deal during the Dream counts at 70 %.

### 4. Mộng Cảnh (Dreamscape)
- **Small:** `formation_power_pct` +1.2 · `evade_pct` +0.4
- **Stat notables:** Dream Garden (Vườn Mơ): formation power ×2 · Shifting Halls (Sảnh Đổi): evade ×2 · Dream Ground
  (Đất Mơ): formation +1, evade +1 · Endless Stair (Bậc Vô Tận): soul resist +2
- **Effects:**
  - **Major: Dreamscape (Mộng Cảnh).** During the Dream, the fight's ground is your Dreamscape: your ground-scoped L4
    applies (any situation, blind included) and the foe's ground bonuses do not.
  - Minor: Drowsy Air (Khí Buồn Ngủ). During the Dream, the foe's art speed −15 %. *(starter)*
  - Minor: Dream Door (Cửa Mơ). Your escape chance is +25 % during the Dream.

### 5. Tỉnh (Waking)
- **Small:** `status_resist_pct` +1 · `health_regen_pct` +0.05
- **Stat notables:** Morning Bell (Chuông Sớm): status resist ×2 · Fresh Start (Khởi Đầu Mới): regen ×2 · Clear Eyes
  (Mắt Tỉnh): status resist +1, regen +0.05 · Wake Up Swinging (Tỉnh Dậy Ra Đòn): attack +2
- **Effects:**
  - **Major: Waking (Tỉnh Mộng).** When the Dream ends, cleanse every debuff and curse on you, and your next 3 hits deal
    more (L5 +25).
  - Minor: Rise Early (Dậy Sớm). When the Dream ends, restore 10 % of max linh lực. *(starter)*
  - Minor: Shake It Off (Rũ Bỏ). When the Dream ends, the foe's buff batches applied during it end too.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Long Dream (Trường Mộng)** | keystone | The Dream lasts 12 s | Damage you deal during the Dream counts at 25 % | Mộng |
| **The Butterfly Dream (Hồ Điệp Mộng)** | keystone | Which One Is Dreaming works twice per fight | Your max health is 25 % lower | Thực Mộng |
| **Never Wake (Bất Tỉnh)** | keystone | The Dream never ends: health you lose is restored every 6 s (at 50 %) | Damage you deal counts at 60 % all fight | Mộng, Tỉnh |

## New pieces

- The Dream window (undo on waking), the health-change swap: `Needs rule` (Combat rule 21: a snapshot is fine; the
  log must show it).

## Kept apart from

Huyễn Đạo (illusion: false targets, mirrors), Thời's Rewind (restore yourself to 5 s ago; Mộng undoes only the
Dream window, and swaps with the foe). Mộng is **the opening dream, the swap, and waking clean**.
