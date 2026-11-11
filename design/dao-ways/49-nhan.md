# 49 · Nhẫn Đạo · *Nhẫn Nhất Thời, Phong Bình Lãng Tĩnh* (Forbearance; Endure a Moment, and Wind and Waves Fall Still)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `khi_huyet_pct`, `health_regen_pct`, `block_rating`, `body_shield_pct`, `status_resist_pct`, `attack_pct`,
> `tam_ma_resist_pct`.
> **Road:** `khi_huyet_pct` +1.

## Build directions

1. **Bear It.** Damage taken becomes stored power (Chịu Đựng): every point you absorb adds to a store that your
   arts spend. Sustain is king, and Nhẫn turns being hit into the win condition.
2. **Patience.** Stronger the longer the fight lasts, with no early power at all (Kiên Nhẫn); the 60 s fight
   specialist that must reach fatigue alive.
3. **The Last Stand.** At low health, refuse to fall and hit back (Tử Thủ), without the Down-refusal of other
   Ways: Nhẫn's last stand is a damage floor plus a store dump.
4. **Slow Burn.** Regeneration that grows each pulse you stay in the fight (Âm Ỉ).

## Facets

### 1. Kiên Nhẫn (Patience)
- **Small:** `attack_pct` +1.2 · `health_regen_pct` +0.05
- **Stat notables:** Wait (Chờ Đợi): attack ×2 · Long Breath (Hơi Dài): regen ×2 · Slow Hand (Tay Chậm): attack +1, regen
  +0.05 · Time Is Mine (Thời Gian Là Của Ta): status resist +2
- **Effects:**
  - **Major: Patience (Kiên Nhẫn).** Your hits deal more by fight time past 15 s (L5 +2 per second, cap +60); before
    15 s, they deal 15 % less.
  - Minor: Patient Start (Khởi Chậm). For the first 15 s, you take 15 % less damage. *(starter)*
  - Minor: Outlast (Bền Hơn). Fatigue affects you 50 % less.

### 2. Chịu Đựng (Bear It)
- **Small:** `khi_huyet_pct` +1 · `block_rating` +1
- **Stat notables:** Take the Blow (Chịu Đòn): max health ×2 · Brace (Gồng): block ×2 · Thick Skin (Da Dày Lì): max
  health +1, block +1 · Swallow Pain (Nuốt Đau): regen +0.1
- **Effects:**
  - **Major: Endured Strength (Nhẫn Lực).** 20 % of the damage that reaches your health is stored (cap 50 % of max
    health). Each art you fire spends up to 5 % of max health from the store for L5 +1 per 0.2 % spent (so up to +25).
    `Needs key` (the store).
  - Minor: Bite the Lip (Cắn Môi). The first 3 hits each fight are reduced by 15 %. *(starter)*
  - Minor: Overflow of Pain (Tràn Đau). When the store is full, your basic attack spends from it too.

### 3. Ý Chí (Iron Will)
- **Small:** `status_resist_pct` +1 · `tam_ma_resist_pct` +1
- **Stat notables:** Will of Iron (Ý Sắt Đá): status resist ×2 · Unbent Mind (Tâm Không Cong): heart-demon resist ×2 ·
  Firm (Kiên Cường): status resist +1, max health +1 · Clenched Teeth (Nghiến Răng): soul resist +2
- **Effects:**
  - **Major: Iron Will (Ý Chí Sắt).** Each curse placed on you gives 3 % of max health to the store (with Endured
    Strength) or heals 2 % (without).
  - Minor: Shrug (Nhún Vai). Curses on you last 1 pulse less. *(starter)*
  - Minor: Will Holds (Ý Vững). Fear and charm Effects on you are refused.

### 4. Tử Thủ (Last Stand)
- **Small:** `body_shield_pct` +1 · `attack_pct` +1
- **Stat notables:** Hold the Line (Giữ Tuyến): body shield ×2 · Back to the Gate (Tựa Cổng): attack ×2 · Final Wall
  (Bức Tường Cuối): body shield +1, attack +1 · Dying Fury (Cơn Giận Cuối): crit damage +2
- **Effects:**
  - **Major: Last Stand (Tử Thủ).** Once per fight, when you fall below 20 % health, release the whole store at once as
    a Force hit (a trigger; `Needs rule` R18: a once-per-fight exemption from `trig_budget`) and gain a body shield equal to half of it.
  - Minor: Dig In (Bám Trụ). Below 30 % health, block +20. *(starter)*
  - Minor: Stand Until Dawn (Đứng Đến Sáng). After Last Stand, your regeneration is doubled for 6 s.

### 5. Âm Ỉ (Slow Burn)
- **Small:** `health_regen_pct` +0.05 · `khi_huyet_pct` +0.5
- **Stat notables:** Embers Within (Than Trong): regen ×2 · Steady Flame (Lửa Đều): max health ×2 · Long Night Fire (Lửa
  Đêm Dài): regen +0.05, max health +1 · Smoulder (Âm Ỉ Cháy): regen increased +4
- **Effects:**
  - **Major: Slow Burn (Âm Ỉ).** Your health regeneration rises by 2 % each pulse of the fight (cap +80 %).
  - Minor: Warm Coals (Than Ấm). You start each fight with +20 % regeneration from Slow Burn. *(starter)*
  - Minor: Never Out (Không Tắt). Stagnation on you cannot reduce regeneration gained from Slow Burn.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Whoever Lasts, Wins (Nhẫn Giả Thắng)** | keystone | Patience has no cap and starts at 10 s | Before 10 s, your hits deal 40 % less | Kiên Nhẫn |
| **Endure a Moment (Nhẫn Nhất Thời)** | keystone | Endured Strength stores 40 % and its cap is 100 % of max health | Your ward strength is halved | Chịu Đựng |
| **Wind and Waves Fall Still (Phong Bình Lãng Tĩnh)** | keystone | Slow Burn has no cap | Your hits deal 20 % less (L2 −20) | Âm Ỉ |

## New pieces

- The damage store (Endured Strength): `Needs key`.

## Kept apart from

Nhân Quả's Báo Ứng (owed damage paid once; Nhẫn stores and spends over time), Nghịch (power from being behind),
Vô Vi (not acting). Nhẫn is **damage taken as stored power, and patience with no ceiling**.
