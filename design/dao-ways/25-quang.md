# 25 · Quang Đạo · *Quang Minh* (Radiance)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct` (light), `resist_pen_pct` (light), `crit_chance_pct` (light), `accuracy_pct`,
> `defense_pct`, `ward_efficiency_pct`, `status_duration_pct` (exposed), `soul_res_pct`, `healing_pct`.
> **Road:** `attack_pct` light +2.

## Build directions

1. **Exposure.** Keep the foe Exposed (−100 all resistance) as close to always as the rules allow, then hit it
   with anything; Light builds become the enablers of high-resistance kills. Stack: Exposed uptime, Light hits.
2. **The Dispeller.** Strip the foe's buff stacks (Tịnh): the counter to stack builds (Fire, Wind, Earth buffs),
   with damage that reads what was stripped.
3. **The Halo.** Light wards that answer Chaos and Soul and grow brighter each time they stop a hit.
4. **The Judge.** Punish demons, curses and anyone who cursed you: a duelist's Way with a moral edge (Phán Xét).

## Facets

### 1. Quang (Radiance)
- **Small:** `attack_pct` light +1.5 · `resist_pen_pct` light +0.6
- **Stat notables:** Blinding (Chói Lòa): light ×2 · Clear Ray (Tia Trong): light penetration ×2 · Glare (Lóa
  Mắt): light +1, accuracy +1 · Pure Beam (Tia Thuần): light crit damage +2
- **Effects:**
  - **Major: Laid Bare (Hiển Lộ).** Your Light hits apply Exposed; if the target is already Exposed by you, extend
    it by 1 pulse instead (to at most 6 pulses).
  - Minor: Lingering Light (Dư Quang). Exposed you apply to a target that is already Exposed lasts 1 pulse longer. *(starter)*
  - Minor: Sunlit (Tắm Nắng). Your non-Light hits deal more to an Exposed target (L5 +10).

### 2. Tịnh (Purity)
- **Small:** `status_resist_pct` +1 · `attack_pct` light +1
- **Stat notables:** White Fire (Bạch Hỏa): light +2 · Clear Eyes (Mắt Trong): status resist ×2 · Holy Water (Nước
  Thánh): status resist +1, healing +1 · Purge Light (Quang Tẩy): light penetration +1, status resist +1
- **Effects:**
  - **Major: Dispel (Tịnh Trừ).** Each of your Light hits removes 3 of the target's buff stacks (oldest first; shared rule R16, once per pulse); for
    each stack removed this way in the last 3 s, your Light hits deal more (L5 +1, cap +30).
  - Minor: Clean Light (Quang Sạch). Each Light hit you land cleanses 1 debuff stack from you. *(starter)*
  - Minor: Unshadowed (Không Bóng). Darkness effects on you (blind, accuracy down) are halved.

### 3. Thự Quang (First Light)
- **Small:** `accuracy_pct` +0.5 · `crit_chance_pct` light +0.8
- **Stat notables:** Dawn Strike (Kích Rạng Đông): light crit chance ×2 · First Ray (Tia Đầu): accuracy ×2 ·
  Morning Star (Sao Mai): light +1, crit chance +0.5 · Clear Morning (Sáng Trong): light penetration +1, accuracy +1
- **Effects:**
  - **Major: First Light (Thự Quang).** For the first 6 s of a fight, every hit you land applies Exposed, and the
    foe cannot evade.
  - Minor: Lit Path (Đường Sáng). Your first Light art each fight fires 1 s sooner. *(starter)*
  - Minor: Day Breaks (Bình Minh Lên). Your crits in the first 10 s apply Exposed for 1 pulse.

### 4. Hào Quang (Halo)
- **Small:** `defense_pct` +1.2 · `soul_res_pct` +1
- **Stat notables:** Ring of Light (Vòng Sáng): defense ×2 · Halo Ward (Hộ Quang): ward efficiency ×2 · Holy Glow
  (Thánh Quang): soul resistance ×2 · Bright Shield (Thuẫn Sáng): defense +1, chaos resistance +1
- **Effects:**
  - **Major: Halo (Hào Quang).** Your wards' shields also stop Chaos damage at 40 % and Soul damage at 20 % of their value, and each
    hit they fully stop grants +1 % ward strength for the fight (cap +30 %). (Shield `stops` list, under the caps of 50 % Chaos / 30 % Soul: Combat Defence rule 9, R3; event: a hit fully stopped by wards, Effects rule 5, R20.)
  - Minor: Radiant Guard (Quang Hộ). When your ward stops a Chaos hit, apply Exposed to the attacker for 1 pulse.
  - Minor: Warm Light (Ánh Ấm). Your wards heal you for 1 % of max health when they are cast. *(starter)*

### 5. Phán Xét (Judgement)
- **Small:** `attack_pct` light +1 · `status_duration_pct` exposed +2
- **Stat notables:** Verdict (Phán Quyết): light ×2 · Long Sentence (Án Dài): Exposed duration ×2 · Witness
  (Chứng Nhân): soul resistance +1, light +1 · Gavel (Búa Phán): light crit damage +2
- **Effects:**
  - **Major: Judgement (Phán Xét).** Your hits deal more for each curse you have cleansed from yourself this fight (L5 +6 each, cap +30), and L5 +25 more against a foe that has placed a curse on you.
  - Minor: Sin Revealed (Tội Hiện). Your Light hits deal more to a foe carrying Corpse Rot, Chaos statuses or a
    demonic tag (L5 +15). *Shared minor* (with Lôi's Smite the Unclean, Bồ Đề).
  - Minor: No Hiding (Không Trốn). Foes cannot escape from you while Exposed. *(starter)*

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Nothing Hides (Vô Sở Độn Hình)** | keystone | Exposed from you has no refresh limit: it can be re-applied while running, its duration adding up to 10 pulses | Your hits deal no damage to a target that is not Exposed for the first 3 s (you need to light it first) | Quang |
| **Radiance (Quang Minh)** | keystone | Your Light hits cannot be evaded, and `bypass_share` 10 % on every part of your hits: that share skips ward shields only (Combat Defence rule 9, R2; cap 50 % per part) | Your arts cannot be Light and another element at once (no Light conversion) | Quang, Thự Quang |
| **The Sun Within (Nội Nhật)** | keystone | Your Halo stops Chaos at 50 % and Soul at 30 %, the caps (Combat Defence rule 9, R3) | Your hits deal 25 % less (L2 −25) | Hào Quang |
| **Heaven's Mirror (Thiên Kính)** | keystone | Each curse a foe places on you is also placed on it | You cannot place curses other than Exposed | Phán Xét |

## New pieces

- Exposed stacking duration: Effects rule 16, R27 (refresh to stack).
- Chaos and Soul against ward shields: shield `stops` list, caps 50 % / 30 % (Combat Defence rule 9, R3).

## Kept apart from

Thái Dương (fire and sun cycles; its Bình Minh is an opening Fire burst, Quang's First Light is an opening
Exposed); Bồ Đề (merit and healing others); Âm Dương's Dương. Quang is **Exposed uptime, dispelling and the halo**.
