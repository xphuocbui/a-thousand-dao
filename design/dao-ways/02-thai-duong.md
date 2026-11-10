# 02 · Thái Dương Đạo · *Kim Ô* (the Great Sun; the Golden Crow)

> Overnight draft 2026-11-11. Proposal. **Needs:** Fire ≥ 30.
> **Theme stats:** `attack_pct` (fire, light), `stack_effect_pct` (fire), `resist_pen_pct` (fire, light), `art_speed_pct`,
> `defense_pct`, `khi_huyet_pct`.
> **Road:** `attack_pct` fire +1 and light +1.

## Build directions

1. **The Day Arc.** The fight is a day: Sunrise (opening burst), Noon (peak at 15–25 s), Sunset (a last blaze when
   you are losing). Each phase is a facet; a build picks the hours it wants to own.
2. **Fire on Light.** Every Fire hit Exposes, every Light hit Burns: a two-type caster where each type sets up the
   other (Liệt Nhật).
3. **The Corona.** An aura of heat: a standing Fire tick on the foe paid for by your Fire buff stacks, with no slot
   (Nhật Miện). The aura build the PoE player wants.
4. **The Last Blaze.** Sunset: below 30 % health the sun burns brightest; a comeback with a hard edge.

## Facets

### 1. Bình Minh (Sunrise)
- **Small:** `art_speed_pct` +0.5 · `attack_pct` fire +1
- **Stat notables:** First Rays (Tia Đầu): art speed ×2 · Red Dawn (Rạng Đông Đỏ): fire ×2 · Morning Heat (Nắng
  Sớm): fire +1, art speed +0.5 · Cockcrow (Gà Gáy): fire crit chance +1
- **Effects:**
  - **Major: Sunrise (Nhật Xuất).** For the first 8 s, your Fire hits deal more (L5 +35) and each applies 3 extra Burn
    stacks.
  - Minor: Crow Takes Wing (Ô Cất Cánh). Your first Fire art fires at half its cooldown. *(starter)*
  - Minor: Early Warmth (Ấm Sớm). You start each fight with 10 Fire buff stacks for 8 pulses.

### 2. Chính Ngọ (Noon)
- **Small:** `attack_pct` fire +1 · `crit_damage_pct` +1.5
- **Stat notables:** Overhead Sun (Nắng Đỉnh): fire ×2 · Shadowless (Không Bóng): crit damage ×2 · Midday Glare
  (Chói Trưa): light +1, fire +1 · White Heat (Nóng Trắng): fire penetration +2
- **Effects:**
  - **Major: High Noon (Chính Ngọ).** From 15 s to 25 s, your hits deal more (L5 +50) and cannot be evaded.
  - Minor: Long Noon (Trưa Dài). High Noon lasts until 28 s. *(starter)*
  - Minor: Sunstroke (Say Nắng). During High Noon, your hits apply Exposed on a crit.

### 3. Liệt Nhật (Scorching Sun: Fire on Light)
- **Small:** `attack_pct` light +1 · `attack_pct` fire +1
- **Stat notables:** Burning Light (Quang Cháy): fire +1, light +1 ×2 · Searing (Thiêu Đốt Sáng): light penetration ×2 ·
  Blaze Ray (Tia Rực): fire penetration +2 · Heat Shimmer (Hơi Nóng): accuracy +3
- **Effects:**
  - **Major: Scorching Sun (Liệt Nhật).** Your Fire hits apply Exposed for 1 pulse; your Light hits apply Burn stacks
    equal to 2 per 1 % of the target's max health they deal.
  - Minor: Sun-Bleached (Phai Nắng). Exposed you apply also lowers Fire resistance by 20 more. *(starter)*
  - Minor: Light Feeds Fire (Quang Dưỡng Hỏa). Each Light hit gives 1 Fire buff stack for 6 pulses.

### 4. Nhật Miện (Corona)
- **Small:** `stack_effect_pct` fire +1.5 · `defense_pct` +0.6
- **Stat notables:** Ring of Fire (Vòng Lửa): fire stack effect ×2 · Halo of Heat (Quầng Nóng): defense ×2 · Solar
  Wind (Gió Mặt Trời): fire stack duration +2, fire +1 · Corona Shield (Thuẫn Quầng): fire resist +2
- **Effects:**
  - **Major: Corona (Nhật Miện).** While you hold 20+ Fire buff stacks, the foe takes a standing Burn: 1 Burn stack per
    10 of your Fire buff stacks is applied each pulse (no slot, no cost).
  - Minor: Heat Haze (Sóng Nhiệt). While you hold 20+ Fire buff stacks, the foe's accuracy is −5 pp. *(starter)*
  - Minor: Radiant Body (Thân Phát Sáng). Fire buff stacks you hold also give +0.5 Fire resistance each.

### 5. Hoàng Hôn (Sunset)
- **Small:** `khi_huyet_pct` +0.5 · `attack_pct` fire +1
- **Stat notables:** Red Sky (Trời Đỏ): fire ×2 · Long Shadows (Bóng Dài): max health ×2 · Last Light (Ánh Cuối):
  fire +1, max health +1 · Ember Sky (Trời Than): fire crit damage +2
- **Effects:**
  - **Major: Last Blaze (Hồi Quang Phản Chiếu).** Below 30 % health, your Fire and Light hits deal more (L5 +45) and
    your Fire buff stacks count double.
  - Minor: Setting Sun (Mặt Trời Lặn). When you fall below 30 % health, gain 20 Fire buff stacks for 10 pulses
    (once per fight). *(starter)*
  - Minor: Afterglow (Ráng Chiều). After Last Blaze has been active 5 s, heal 10 % of max health (once per fight).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **A Sun That Never Sets (Bất Lạc Nhật)** | keystone | High Noon lasts from 10 s to the end of the fight | Sunrise and Sunset Effects do nothing | Chính Ngọ |
| **Golden Crow (Kim Ô)** | enabler | Corona needs only 10 Fire buff stacks and applies 1 Burn stack per 5 | You cannot slot a Water or Ice art | Nhật Miện |
| **Ten Suns (Thập Nhật)** | keystone | Scorching Sun's Exposed lasts 2 pulses and its Burn is doubled | Your max health is 20 % lower | Liệt Nhật |
| **Twilight Sovereign (Hoàng Hôn Đế)** | keystone | Last Blaze starts at 50 % health | You cannot heal above 60 % health | Hoàng Hôn |

## New pieces

- Standing Burn from buff stacks (Corona): `Fits today` as an Effect on the pulse event.

## Kept apart from

Hỏa Đạo (Burn as the clock; Thái Dương is time-of-day and Fire on Light); Quang Đạo (its First Light opens with
Exposed, Thái Dương's Sunrise opens with Fire burst); Âm Dương's Dương. Thái Dương is **the hours of the day, Fire
on Light, and the corona**.
