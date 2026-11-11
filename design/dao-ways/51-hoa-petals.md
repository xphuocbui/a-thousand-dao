# 51 · Hoa Đạo · *Lạc Hoa* (Falling Petals)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct`, `art_speed_pct`, `crit_chance_pct`, `stack_duration_pct`, `status_duration_pct`,
> `healing_pct`, `evade_pct`.
> **Road:** `art_speed_pct` +0.5.

## Build directions

1. **Petal Rain.** Many tiny hits: each art scatters Petals (extra hits at a fraction), so per-hit Effects and
   per-hit wards are the battlefield (Hoa Vũ). The hit-count build.
2. **Fading Bloom.** Buffs that decay instead of expiring: your buff stacks lose 10 % a pulse but never drop
   suddenly, and decaying stacks pay out (Tàn Hoa). A smooth-power build.
3. **Lingering Scent.** After-effects: every status you apply leaves a Scent when it ends that keeps a share of its
   effect (Hương Tàn). The duration build.
4. **Intent and Indifference.** Two stances of grace: Hữu Ý (with intent: crit) and Vô Tình (indifference: evade),
   chosen by fight time.

## Facets

### 1. Hữu Ý (Petals with Intent)
- **Small:** `crit_chance_pct` +0.4 · `attack_pct` +1
- **Stat notables:** Aimed Petal (Cánh Nhắm): crit chance ×2 · Graceful Cut (Nhát Duyên): attack ×2 · Meant to Fall (Rơi
  Có Ý): crit chance +1, attack +1 · Blossom Edge (Viền Hoa): crit damage +2
- **Effects:**
  - **Major: Falling with Intent (Lạc Hoa Hữu Ý).** For the first 20 s, your crits scatter 3 Petals (each a trigger hit
    of `c_trig` 0.15 with the crit's tags).
  - Minor: First Petal (Cánh Đầu). Your first art each fight crits for certain. *(starter)*
  - Minor: Intent Shown (Ý Lộ). Each crit gives +1 % crit damage for the fight (cap +20 %).

### 2. Lưu Thủy Vô Tình (Water without Intent)
- **Small:** `evade_pct` +0.4 · `healing_pct` +1
- **Stat notables:** Indifferent Stream (Dòng Hờ Hững): evade ×2 · Cool Water (Nước Mát): healing ×2 · Passing By (Trôi
  Qua): evade +1, healing +1 · Unattached (Không Vương): status resist +2
- **Effects:**
  - **Major: Water Flows On (Lưu Thủy Vô Tình).** After 20 s, your evade is +10 pp and each evade heals 1 % of max health.
  - Minor: Let It Go (Thả Trôi). After 20 s, curses on you last 1 pulse less. *(starter)*
  - Minor: Two Halves (Hai Nửa). With both this facet's major and Falling with Intent, the switch time is yours to set
    (5 to 40 s).

### 3. Hoa Vũ (Petal Rain)
- **Small:** `art_speed_pct` +0.5 · `attack_pct` +1
- **Stat notables:** Storm of Petals (Bão Cánh): art speed ×2 · Thousand Petals (Ngàn Cánh Hoa): attack ×2 · Swirl (Xoáy
  Cánh): art speed +1, attack +1 · Petal Edge (Lưỡi Cánh): crit chance +2
- **Effects:**
  - **Major: Petal Rain (Hoa Vũ).** Each art that hits scatters Petals equal to 1 per 2 s of its authored cooldown (cap
    5): each a trigger hit of `c_trig` 0.12 with the art's tags (inside `trig_budget`).
  - Minor: Wind-Borne (Gió Mang). Your Petals apply 1 Wind debuff stack for 4 pulses each. *(starter)*
  - Minor: Thorned Petals (Cánh Có Gai). Your Petals apply 1 Bleed stack every 3rd hit.

### 4. Tàn Hoa (Fading)
- **Small:** `stack_duration_pct` +2 · `attack_pct` +1
- **Stat notables:** Slow Wilt (Héo Chậm): stack duration ×2 · Last Colour (Màu Cuối): attack ×2 · Pressed Flower (Hoa
  Ép): stack duration +1, attack +1 · Dry Bloom (Hoa Khô): max health +2
- **Effects:**
  - **Major: Fading Bloom (Tàn Hoa).** Your buff stack batches do not expire: they lose 15 % of their stacks each pulse
    instead (rounded down, at least 1). Each stack lost this way gives L5 +0.5 to your next hit (cap +30).
    `Needs rule` (Effects 9a batches).
  - Minor: Lingering Colour (Sắc Lưu). Your first buff batch each fight does not fade for 5 pulses. *(starter)*
  - Minor: Petals Fall Softly (Cánh Rơi Nhẹ). Faded stacks heal 0.1 % of max health each.

### 5. Hương Tàn (Lingering Scent)
- **Small:** `status_duration_pct` +2 · `healing_pct` +1
- **Stat notables:** Long Fragrance (Hương Lâu): status duration ×2 · Sweet Air (Khí Ngọt): healing ×2 · Scented Robe (Áo
  Thơm): status duration +1, healing +1 · After-Scent (Dư Hương): soul resist +2
- **Effects:**
  - **Major: Lingering Scent (Dư Hương).** When a curse or debuff batch you applied ends (not cleansed), it leaves a Scent
    for 2 pulses at 40 % of its effect.
  - Minor: Faint Trace (Vết Hương). Your curses last 1 pulse longer. *(starter)*
  - Minor: Scent of Spring (Hương Xuân). When your heal over-heals, the excess lingers as regeneration for 2 pulses.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Beautiful Because It Falls (Hoa Lạc Tri Mỹ)** | keystone | Petal Rain scatters up to 8 Petals and they are outside `trig_budget` (`Needs rule` R18: Petals become their own channel) | Your arts' own hits deal 40 % less (L2 −40) | Hoa Vũ |
| **Never Quite Gone (Hương Bất Tán)** | keystone | Lingering Scent keeps 70 % for 4 pulses | Your curses' first application is at 70 % strength | Hương Tàn |
| **The Last Bloom (Tàn Hoa Tối Hậu)** | keystone | Fading Bloom's L5 has no cap | Your buff batches start at 70 % of their size | Tàn Hoa |

## New pieces

- Decaying batches (Fading Bloom): `Needs rule`.
- Scents (after-effects of ended statuses): `Needs key`.

## Kept apart from

Phong Nguyệt's Hoa (flowers as healing on crits), Mộc (Wood stacks and Blossom), Ngọc's Refract (one hit split;
Hoa adds extra petal hits). Hoa is **petal hits, buffs that fade instead of ending, and lingering statuses**.
