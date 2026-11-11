# 87 · Kiếp Đạo · *Độ Kiếp* (Crossing the Calamity)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `khi_huyet_pct`, `attack_pct`, `resist_pct` (lightning), `tam_ma_resist_pct`, `status_resist_pct`,
> `cultivation_speed_pct` (capped), `qi_deviation_pct` (lower).
> **Road:** `khi_huyet_pct` +1.

## Build directions

The life-around-the-fight Way. Kiếp turns **surviving bad things** into permanent growth.

1. **Courting Disaster.** Take on self-imposed trials before a fight (a Vow of handicap: fight at half linh lực,
   fight without wards) for big rewards if you win (Tự Chuốc). Risk management as a build.
2. **The Gambler's Breakthrough.** Riskier breakthroughs with bigger rewards (Hiểm Phá; rule 4's Effect
   exception).
3. **Ten Thousand Trials.** A life-long counter: every calamity survived (a fight won below 10 %, a tribulation,
   a qi deviation) adds a permanent stack (Vạn Kiếp).
4. **Calamity Qi.** In a fight, events you survive are fuel: a tribulation wave, a near-death, a Down refusal each
   give a Calamity stack that powers arts (Kiếp Khí).

## Facets

### 1. Tự Chuốc (Courting Disaster)
- **Small:** `attack_pct` +1.2 · `khi_huyet_pct` +0.5
- **Stat notables:** Reckless (Liều): attack ×2 · Iron Nerve (Thần Kinh Thép): max health ×2 · Bold Step (Bước Táo
  Bạo): attack +1, max health +1 · Dare (Thách): crit damage +2
- **Effects:**
  - **Major: Court Disaster (Tự Chuốc Họa).** Before a fight you may take up to 3 Trials (each: start at 50 % linh lực;
    no ward slots; start at 70 % health; the foe starts with 20 buff stacks). Win against a foe of your realm or higher, and each Trial taken gives 1
    Calamity Mark (permanent, cap 30; +0.3 % to all damage and max health each); one Mark-earning win per foe per
    season. Trials are preparation choices (Effects rule 8 / Combat rule 12, R8). `Needs key` (Marks).
  - Minor: Easy Trial (Thử Nhẹ). Your first Trial each fight is half as harsh. *(starter)*
  - Minor: Brave Heart (Tâm Dũng). Each Trial taken gives L5 +8 in that fight.

### 2. Hiểm Phá (Risky Breakthroughs)
- **Small:** `tam_ma_resist_pct` +1 · `qi_deviation_pct` −1
- **Stat notables:** Steel Mind (Tâm Thép): heart-demon resist ×2 · Clean Channels (Kinh Mạch Sạch): qi deviation −2 ×2 ·
  All In (Dốc Sức): heart-demon resist +1, max health +1 · Leap (Nhảy Vọt): comprehension +2
- **Effects:**
  - **Major: All or Nothing (Được Ăn Cả Ngã Về Không).** Before a breakthrough, you may Gamble: −10 pp success, and a
    success gives 3 free skill points. Bot fixture required (rule 4 exception, AC-DAO-29).
  - Minor: Fall Softly (Ngã Nhẹ). Failed breakthroughs cost 25 % less lifespan. *(starter)*
  - Minor: Try Again Sooner (Thử Lại Sớm). The wait after a failed breakthrough is 30 % shorter. `Needs key`.

### 3. Kiếp Hậu (After the Calamity)
- **Small:** `health_regen_pct` +0.05 · `status_resist_pct` +1
- **Stat notables:** Scar Tissue (Mô Sẹo): status resist ×2 · Recovered (Hồi Phục): regen ×2 · Survivor (Kẻ Sống Sót):
  max health +1, regen +0.05 · Hard-Won (Khó Khăn Mới Có): attack +2
- **Effects:**
  - **Major: What Does Not Kill (Đại Nạn Bất Tử).** Each fight you win below 10 % health against a foe of your realm or higher gives 1
    Calamity Mark (shared with Court Disaster; cap 30; one per foe per season).
  - Minor: Aftermath Calm (Sau Bão). After surviving a tribulation, 1 season of +10 % cultivation speed (inside the
    per-Dao cap). *(starter)*
  - Minor: Lessons (Bài Học). After a defeat you survive, your next fight against the same foe deals +15 %.

### 4. Kiếp Khí (Calamity Qi)
- **Small:** `resist_pct` lightning +1.5 · `attack_pct` +1
- **Stat notables:** Storm-Fed (Ăn Bão): lightning resistance ×2 · Disaster Qi (Khí Tai Ương): attack ×2 · Thunder
  Scars (Sẹo Sét): lightning resist +1, attack +1 · Ill Wind (Gió Độc): crit damage +2
- **Effects:**
  - **Major: Calamity Qi (Kiếp Khí).** Each event you survive gives 1 Calamity stack: a tribulation wave or bolt
    survived, a near-death (your health first falls below 25 %, once per fight, and again each time you recover above
    50 % and fall back), a Down refusal used. Health lost does not count by itself. Each stack: your arts cost 4 % less (total cost cut capped at 25 %) and deal L5 +5 per stack (cap 9 stacks).
    Calamity stacks are a self-counter (tag `growing`, Effects rule 8, R7).
  - Minor: Lightning Drinker (Uống Sét). In a tribulation, each bolt you survive refills 5 % linh lực. *(starter)*
  - Minor: Disaster Ward (Hộ Tai). At 5+ Calamity stacks, curses on you last 1 pulse less.

### 5. Vạn Kiếp (Ten Thousand Trials)
- **Small:** `khi_huyet_pct` +1 · `attack_pct` +1
- **Stat notables:** Weathered Soul (Hồn Dày Dạn): max health ×2 · Tempered by Trials (Rèn Bởi Kiếp): attack ×2 · Many
  Scars (Nhiều Sẹo): max health +1, attack +1 · Unbroken (Chưa Gãy): resist all +1
- **Effects:**
  - **Major: Ten Thousand Trials (Vạn Kiếp Bất Ma).** Calamity Marks cap at 60, and at 30+ Marks each one also gives
    +0.2 % resistance to all.
  - Minor: Mark of Survival (Dấu Sống Sót). Tribulations survived each give 2 Calamity Marks. *(starter)*
  - Minor: Trial Memory (Nhớ Kiếp). Calamity Marks are not lost when a breakthrough fails.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Every Calamity Makes You Stronger (Kiếp Kiếp Tăng Cường)** | keystone | Calamity Marks give +0.5 % each | You lose 6 Marks for each fight you lose | Vạn Kiếp |
| **Walk Into the Storm (Nhập Kiếp)** | keystone | You may take up to 5 Trials (adds: no pills; the foe is one realm higher in suppression) | You must take at least 1 Trial in every foreseen fight | Tự Chuốc |
| **Heaven's Gambler (Thiên Đổ)** | keystone | All or Nothing gives 5 skill points | A failed Gamble costs 10 % of your Calamity Marks | Hiểm Phá |
| **Calamity Incarnate (Kiếp Thân)** | keystone | Each Calamity Qi event gives 2 stacks (cap 18 stacks) | Your max health is 25 % lower | Kiếp Khí |

## New pieces

- Calamity Marks (a permanent counter): `Needs key`; a balance flag (power from risk taken, uncapped by points).
- Pre-fight Trials: preparation choices (Effects rule 8 / Combat rule 12, R8); the handicap list is this Way's own.

## Kept apart from

Nghịch's Against the Current (the gap to the foe) and Hận's Vengeance (the foe's own hits): Kiếp counts events survived, never health lost. Lôi's Thiên Lôi (carry a bolt in fights), Nghịch's Nghịch Kiếp (tribulation fights), Thệ Đạo (oaths that close
options for power). Kiếp is **trials taken on purpose and the marks they leave**.
