# 56 · Chưởng Đạo · *Thiên Thủ* (a Thousand Hands: Palm)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct` (palm, force), `resist_pen_pct` (force), `art_speed_pct` (palm), `art_cost_pct`
> (palm), `crit_chance_pct` (palm), `attack_pct` (fire) on Hỏa Chưởng only, `khi_huyet_pct`, `block_rating`.
> **Road:** `attack_pct` palm +2.

## Build directions

1. **Inner Injury.** Palm hits store part of their damage as a new status, Internal Injury (Nội Thương), that
   bursts later past every shield. The anti-ward build for Force.
2. **A Thousand Palms.** Many cheap palm hits, each building Palm Wind stacks; feeds on-hit Effects and Ice
   cost-locks with the hit count.
3. **The Heavy Palm.** Force hits that ignore block and knock timers back; a control-and-weight build.
4. **The Burning Palm.** Palm and Fire: every palm hit adds Burn, and Burn on the foe speeds the palms.

## Facets

### 1. Trọng Chưởng (Heavy Palm)
- **Small:** `attack_pct` force +1.5 · `attack_pct` palm +1
- **Stat notables:** Mountain Palm (Chưởng Núi): force ×2 · Iron Palm (Thiết Chưởng): palm ×2 · Rooted Strike
  (Kích Vững): force +1, max health +1 · Collapse (Sập): force penetration +2
- **Effects:**
  - **Major: One Palm Fells a Mountain (Nhất Chưởng Đảo Sơn).** Your Force palm hits ignore block, and push the
    target's slowest art timer back 0.5 s (once per 3 s). (`delay_timer`, falls off within 3 s, foe's `timer_resist_pct` shortens it: Effects rule 6, R1).
  - Minor: Weighty (Nặng Nề). Your slow palm arts deal more (L5 +12). *(starter)*
  - Minor: Shockwave (Sóng Xung). When your palm hit breaks a ward shield, apply Qi Disruption (1 stack).

### 2. Chưởng Phong (Palm Wind)
- **Small:** `art_speed_pct` palm +1 · `stack_effect_pct` wind +1
- **Stat notables:** Palm Gust (Gió Chưởng): palm art speed ×2 · Air Blade (Phong Nhận Chưởng): palm +2 · Pushing
  Wind (Gió Đẩy): evade +1, palm +1 · Whirl (Xoáy): wind stack effect +2
- **Effects:**
  - **Major: Palm Wind (Chưởng Phong).** Each palm **art** hit grants 1 Wind buff stack for 4 pulses (at most 10 from this source); at 10+ Wind buff stacks your palm hits also apply 2 Wind debuff stacks for 4 pulses.
  - Minor: Wind Pressure (Phong Áp). Your palm hits ignore 2 pp of the foe's evade.
  - Minor: Light Palm (Chưởng Nhẹ). Your quick palm arts cost 20 % less while you hold 5+ Wind buff stacks. *(starter)*

### 3. Nội Kình (Inner Strike)
- **Small:** `attack_pct` force +1 · `resist_pen_pct` force +0.6
- **Stat notables:** Hidden Force (Lực Ẩn): force penetration ×2 · Through the Skin (Xuyên Da): palm +1, force +1 ·
  Vibration (Chấn Động): force ×2 · Meridian Strike (Kích Mạch): palm crit chance +1, force +1
- **Effects:**
  - **Major: Internal Injury (Nội Thương).** 30 % of the damage your palm hits deal to ward shields is stored as
    Internal Injury on the target; every 3 s it deals the stored amount as Force straight to health (no shield,
    no block). `Needs key` (status) and `Needs rule` (bypass).
  - Minor: Shaken Meridians (Chấn Mạch). When Internal Injury bursts, apply 5 Stagnation stacks.
  - Minor: Deep Palm (Chưởng Sâu). Your palm hits on a target bearing Internal Injury ignore 10 Force resistance points. *(starter)*

### 4. Hỏa Chưởng (Burning Palm)
- **Small:** `attack_pct` fire +1 · `attack_pct` palm +1
- **Stat notables:** Red Palm (Chưởng Đỏ): fire ×2 · Scorched Hand (Tay Cháy): palm +1, fire +1 · Smoke Palm
  (Chưởng Khói): fire stack effect +2 · Furnace Grip (Nắm Lò): fire penetration +2
- **Effects:**
  - **Major: Burning Palm (Liệt Hỏa Chưởng).** Your palm hits convert 30 % to Fire and apply 3 Burn stacks for 6 pulses; your
    palm art speed is +1 % per 5 Burn stacks on the target (cap +30 %).
  - Minor: Hot Hands (Tay Nóng). Your palm crits apply 5 extra Burn stacks for 6 pulses. *(starter)*
  - Minor: Branded (Dấu Lửa). A target bearing 30+ Burn stacks takes more from your palm hits (L5 +12).

### 5. Thiên Chưởng (a Thousand Palms)
- **Small:** `attack_pct` palm +1 · `art_cost_pct` palm −1
- **Stat notables:** Many Hands (Đa Thủ): palm ×2 · Endless Palms (Chưởng Vô Tận): palm cost ×2 · Blur (Mờ Tay):
  palm art speed +1, palm +1 · Rapid Strikes (Liên Kích): palm crit chance +2
- **Effects:**
  - **Major: A Thousand Hands (Thiên Thủ).** Every 5th palm hit you land (trigger hits do not count) strikes again as a trigger hit (`c_trig` 0.6) with the same tags.
  - Minor: Rhythm of Palms (Nhịp Chưởng). Each palm hit in the last 2 s gives L5 +2 to the next (cap +20).
  - Minor: Open Hand (Tay Mở). Your basic attack counts as a palm art hit. *(starter)*

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **One Palm, a Mountain Falls (Nhất Chưởng)** | keystone | Internal Injury stores 60 % and bursts every 2 s | Your palm hits deal 30 % less to health directly (L2 −30) | Nội Kình |
| **Thousand-Hand Body (Thiên Thủ Thân)** | keystone | You may slot 2 more quick palm arts of this Way's techniques beyond your slots | Your slow arts cannot be slotted, and your basic attack deals 50 % less | Thiên Chưởng |
| **Palm of the Furnace (Lô Chưởng)** | keystone | While you hit the target with a palm at least every 3 s, the timers of the Burn batches you applied with palms are frozen (cap 60 stacks from palms) | Your non-palm Fire hits deal 30 % less (L2 −30) | Hỏa Chưởng |
| **Empty Hand (Không Thủ Chưởng)** | keystone | Your palm hits deal more by unused art slots (L5 +15 per empty slot) | You cannot equip a weapon artifact | Trọng Chưởng |

## New pieces

- Internal Injury (stored damage released past shields): `Needs key` + `Needs rule`.
- Extra slots for one form only (Thousand-Hand Body): `Needs rule` (`slots_by_realm`).

## Kept apart from

Thương's Through the Ward (Physical pierce); Thể Đạo's Không Thủ (basic attack with bare hands, body stats);
Đại Đạo's empty-slot rule (Empty Hand is palm-only). Chưởng is **the injury inside, the thousand palms, the burning
hand**.
