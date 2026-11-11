# 44 · Sát Đạo · *Tu La* (the Asura Way)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct`, `crit_damage_pct`, `pierce_pct`, `khi_huyet_pct`, `leech_health_pct`, `tam_ma_resist_pct`,
> `status_duration_pct` (fear).
> **Road:** `attack_pct` +1.2.

## Build directions

1. **The Executioner.** Cull: a foe below a health threshold dies outright (Đao Phủ). PoE's culling strike, the
   single best "finish the fight" tool, and a counter to sustain builds that hover low.
2. **The Streak.** Consecutive fights won give a Streak (kept between fights, lost on a loss): power that rewards a
   player who chooses fights well (Chiến Liên).
3. **Killing Intent.** An aura of fear built from the number of cultivators killed: the foe starts weaker (Sát Ý).
   A world-level reputation turned into a fight effect.
4. **Asura's Sea.** Damage up as **both** sides lose health: the mutual-ruin brawler (Huyết Hải Tu La).

## Facets

### 1. Sát Ý (Killing Intent)
- **Small:** `attack_pct` +1.2 · `status_duration_pct` fear +2
- **Stat notables:** Cold Eyes of a Killer (Mắt Sát Thủ): attack ×2 · Bloodstained Aura (Khí Nhuốm Máu): fear duration
  ×2 · Weight of Deaths (Sức Nặng Cái Chết): attack +1, crit damage +1 · Death's Shadow (Bóng Tử): pierce +2
- **Effects:**
  - **Major: Killing Intent (Sát Ý Lẫm Lẫm).** At fight start, the foe gains Thunder debuff stacks for the fight: 1 per 10 cultivators you have killed (cap 15). `Needs key` (kill count).
  - Minor: Glare of Death (Ánh Mắt Tử). The foe's first art each fight waits 0.5 s. *(starter)*
  - Minor: Killer's Name (Danh Sát Thủ). Foes two realms below you may flee before the fight (an event choice).

### 2. Chiến Liên (Battle Streak)
- **Small:** `attack_pct` +1.2 · `khi_huyet_pct` +0.5
- **Stat notables:** Unbeaten (Bất Bại): attack ×2 · War-Worn (Dày Dạn Trận): max health ×2 · Rolling Victory (Thắng
  Liền): attack +1, max health +1 · Hunger for Battle (Khát Chiến): crit damage +2
- **Effects:**
  - **Major: Battle Streak (Chiến Liên).** Each fight won in a row against a foe no more than one realm below you gives 1 Streak (cap 20, kept between fights): L1 +1 % damage each. A loss or flight resets it. `Needs key`.
  - Minor: Warm Blood (Máu Còn Nóng). A fight within the same month as your last win starts with 10 % extra linh lực.
    *(starter)*
  - Minor: Streak Guard (Giữ Chuỗi). Your first loss halves the Streak instead of resetting it.

### 3. Đao Phủ (the Executioner)
- **Small:** `crit_damage_pct` +1.5 · `attack_pct` +1
- **Stat notables:** Headsman (Đao Phủ Thủ): crit damage ×2 · Final Stroke (Nhát Cuối): attack ×2 · Swift End (Kết Nhanh):
  crit damage +1, attack +1 · Mercy Denied (Không Tha): pierce +2
- **Effects:**
  - **Major: Cull (Trảm).** Your hits put a foe at or below 8 % of its max health Down (refusals still apply; overkill counts as 0 for the double-knockout rule). Bosses and tribulations are immune. `Needs rule` (Combat Down step).
  - Minor: Smell Weakness (Ngửi Thấy Yếu). Your hits on a target below 30 % deal more (L5 +15). *(starter)*
  - Minor: Clean Kill (Giết Gọn). Your hits on a target below 15 % health restore 1 % of max linh lực.

### 4. Huyết Hải Tu La (the Asura's Sea of Blood)
- **Small:** `leech_health_pct` +0.3 · `attack_pct` +1
- **Stat notables:** Red Sea (Biển Đỏ): leech ×2 · Asura's Rage (Tu La Nộ): attack ×2 · Wading in Blood (Lội Máu): leech
  +0.5, attack +1 · Six Arms (Sáu Tay): crit damage +2
- **Effects:**
  - **Major: Mutual Ruin (Lưỡng Bại Câu Thương).** Your hits deal more by the health both sides have lost this fight, counting healed-back health (L5 +1 per 8 % of max health lost in total, cap +40).
  - Minor: Blood Haze (Sương Huyết). When both sides are below 50 %, your leech is doubled. *(starter)*
  - Minor: Asura's Stance (Thế Tu La). Below 50 % health, your art speed +15 %.

### 5. Lãnh Huyết (Cold Blood)
- **Small:** `tam_ma_resist_pct` +1 · `crit_chance_pct` +0.4
- **Stat notables:** Ice in the Heart (Băng Trong Tim): heart-demon resist ×2 · Calm Killer (Sát Thủ Lặng): crit chance ×2 ·
  Unmoved by Death (Không Động Trước Chết): heart-demon resist +1, crit chance +0.5 · Steady Blade (Lưỡi Vững):
  accuracy +2
- **Effects:**
  - **Major: Cold Blood (Lãnh Huyết).** Each cultivator you kill removes 2 heart demon.
  - Minor: No Nightmares (Không Ác Mộng). Heart demon from grim events is halved. *(starter)*
  - Minor: Calm in Carnage (Lặng Giữa Thảm Sát). Your crits on a target below 20 % health have +10 pp crit chance on your next hit.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **A Thousand Deaths Behind You (Thiên Tử Tại Hậu)** | keystone | Cull's threshold is 12 % | You cannot heal or leech at all | Đao Phủ |
| **Asura (Tu La)** | keystone | Mutual Ruin is L5 +1 per 5 % (cap +60) | Your max health is 20 % lower and your regeneration is dampened by 100 | Huyết Hải Tu La |
| **Hundred Battles Unbeaten (Bách Chiến Bất Bại)** | keystone | Battle Streak's cap is 50 | A loss costs 1 year of lifespan per 10 Streak lost | Chiến Liên |

## New pieces

- Cull (kill below a threshold): `Needs rule` (Combat Down step); a big tool, flagged.
- Kill count and Streak as character counters: `Needs key`.

## Kept apart from

Ám's Mark for Death (execution by crit; Sát culls outright), Huyết Đạo (blood economy), Hận (named enemies). Sát is
**the cull, the streak and mutual ruin**.
