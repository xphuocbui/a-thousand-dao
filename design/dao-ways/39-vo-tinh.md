# 39 · Vô Tình Đạo · *Thái Thượng Vong Tình* (the Heartless Way; the Highest Forget Feeling)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `tam_ma_resist_pct`, `status_resist_pct`, `attack_pct`, `crit_chance_pct`, `ngo_tinh` (comprehension),
> `defense_pct`, `soul_res_pct`.
> **Road:** `tam_ma_resist_pct` +1.

## Build directions

1. **The Steady Hand.** Power that never moves: Vô Tình cuts every conditional bonus (yours and the foe's against
   you) and pays it back as a flat L5 that is always on (Lạnh Lùng). The anti-swing build: as good at 1 s as at 50 s.
2. **Immune.** Heart demon immunity, mood immunity, fear immunity, charm immunity (Đoạn Tình, Như Đá): the build
   that ignores every mind game.
3. **Above Feeling.** Comprehension and insight from detachment: the cultivation-speed life (Thái Thượng).
4. **Alone.** No companion: its power goes to you (Cô Độc).

## Facets

### 1. Đoạn Tình (Cutting Ties)
- **Small:** `tam_ma_resist_pct` +1 · `status_resist_pct` +1
- **Stat notables:** Severed (Đã Cắt): heart-demon resist ×2 · Unbound (Không Ràng): status resist ×2 · Clear Break (Dứt
  Khoát): heart-demon resist +1, status resist +1 · Empty Room (Phòng Không): soul resist +2
- **Effects:**
  - **Major: Cut All Ties (Trảm Tình).** You gain no heart demon in fights, and Effects that read your heart demon,
    moods or fear do nothing to you.
  - Minor: No Regrets (Không Hối). Heart demon from events decays twice as fast. *(starter)*
  - Minor: Unmoved by Pleas (Không Động Lòng). Charm-type Effects on you are refused.

### 2. Lạnh Lùng (Cold Heart: steady power)
- **Small:** `attack_pct` +1.2 · `defense_pct` +0.6
- **Stat notables:** Even Pulse (Mạch Đều): attack ×2 · Steady (Vững): defense ×2 · Flat Calm (Lặng Phẳng): attack +1,
  defense +1 · Exact (Chính Xác): accuracy +2
- **Effects:**
  - **Major: Steady Power (Bình Ổn Chi Lực).** Your conditional L5 Effects (while, after, below, above) do nothing; you
    gain a flat L5 +35 that always applies instead.
  - Minor: Measured (Đo Lường). Your crit chance is a counter (Mệnh's Counted Fate) for your first 10 s. *(starter)*
  - Minor: No Peaks (Không Đỉnh). The foe's conditional bonuses against you (execute, low-health, after-crit) are halved.

### 3. Thái Thượng (Above Feeling)
- **Small:** `ngo_tinh` (comprehension) +1 · `cultivation_speed_pct` +0.4 (capped)
- **Stat notables:** High Seat (Ngôi Cao): comprehension ×2 · Detached Mind (Tâm Xa): cultivation speed +1 · Clear View
  (Nhìn Thấu): comprehension +1, soul resist +1 · Cold Insight (Ngộ Lạnh): thần thức +2
- **Effects:**
  - **Major: Forget Feeling, Find the Way (Vong Tình Đắc Đạo).** Your comprehension is +1 % per 10 heart demon below 50
    (cap +5 %, so a calm heart learns faster).
  - Minor: Distant (Xa Xôi). Seclusion cultivation interrupted by events loses half the time. *(starter)*
  - Minor: Above It All (Trên Hết). Your breakthrough heart-demon checks have +1 pp (q-extras).

### 4. Cô Độc (Alone)
- **Small:** `attack_pct` +1.2 · `khi_huyet_pct` +0.5
- **Stat notables:** Solitude (Cô Tịch): attack ×2 · Self Only (Chỉ Mình): max health ×2 · Single Path (Lối Riêng):
  attack +1, max health +1 · No Ties (Không Vướng Bận): crit chance +1
- **Effects:**
  - **Major: Heartless Strength (Vô Tình Lực).** With no companion, its whole power share is added to your own hits as
    L5 (+1 per 1 % of the share you would have had, cap +25).
  - Minor: Travel Light (Đi Nhẹ). With no companion, +10 % travel speed. *(starter)*
  - Minor: No One to Lose (Không Ai Để Mất). With no companion, heart demon from loss events is 0.

### 5. Như Đá (Like Stone)
- **Small:** `status_resist_pct` +1 · `defense_pct` +0.6
- **Stat notables:** Stone Face (Mặt Đá): status resist ×2 · Granite Will (Ý Đá): defense ×2 · Weathered Stone (Đá
  Mòn): status resist +1, defense +1 · Cold Stone (Đá Lạnh): resist all +1
- **Effects:**
  - **Major: Heart of Stone (Tâm Như Thạch).** Curses on you last half as long, and you are immune to Silence.
  - Minor: Unblinking (Không Chớp). Exposed on you is halved in strength. *(starter)*
  - Minor: Unshaken (Không Lay). Timer pushback on you is halved.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Heaven Has No Heart (Thiên Đạo Vô Tình)** | keystone | Steady Power's flat L5 is +55 | Your crit damage is fixed at the base multiplier (no crit damage bonuses) | Lạnh Lùng |
| **The Highest Forget Feeling (Thái Thượng Vong Tình)** | keystone | You are immune to curses for the first 10 s of every fight | You cannot form bonds (Dao partners, sworn siblings, disciples, companions) | Đoạn Tình |
| **Stone Heart, Iron Hand (Thạch Tâm Thiết Thủ)** | keystone | Heart of Stone makes you immune to all curses that change rules (not damage) | Your heals are halved | Như Đá |

## New pieces

- A switch that turns off conditional L5 (Steady Power): `Needs rule` (Effects read conditions per record).
- Bonds (Dao partner, sworn siblings) as readables: `Needs key`.

## Kept apart from

Tình Đạo (moods), Cô Đạo (solitude as a life; Vô Tình's Cô Độc is the absent companion only), Thiền (stillness of
mind). Vô Tình is **steady power, immunity to mind games, and the absent bond**.
