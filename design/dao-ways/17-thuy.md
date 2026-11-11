# 17 · Thủy Đạo · *Nhược Thủy* (Like Water)

> Overnight draft 2026-11-11. Proposal. **Needs:** Water ≥ 30.
> **Theme stats:** `linh_luc_pct`, `linh_luc_regen_pct`, `linh_luc_regen_inc_pct`, `ward_efficiency_pct`,
> `art_cost_pct`, `art_speed_pct` (water), `stack_effect_pct` (water), `healing_pct`, `health_regen_pct`,
> `attack_pct` (water, cold), `travel_speed_pct`.
> **Road:** `linh_luc_pct` +1.2.

## Build directions

1. **The Deep Pool.** Damage that reads how full the pool is (Uyên's major), a huge ward from a huge pool; the
   build that never runs dry. Stack: max linh lực, regeneration, ward efficiency.
2. **The River Chain.** Each art that fires shortens the next slot's timer (Lưu Chuyển), so a slot order becomes
   a chain. Stack: art speed, cheap arts, cost reduction.
3. **The Tide.** Power swells and ebbs on a fixed 12 s wave; slot your big art to land on the crest (Triều Cường).
   Rewards cooldowns tuned to the wave: a timing min-max.
4. **The Monsoon.** Healing over time from rain batches that stack like Water stacks; sustain without heal arts.

## Facets

### 1. Lưu (Flow)
- **Small:** `art_speed_pct` water +1 · `art_cost_pct` −0.5
- **Stat notables:** Current (Dòng Chảy): water art speed ×2 · Smooth Stones (Đá Trơn): art cost −1.5, art speed
  +0.5 · Unbroken Stream (Suối Liền): art speed +1, water attack +1 · Downhill (Xuôi Dòng): art cost −3
- **Effects:**
  - **Major: Flow On (Lưu Chuyển).** When one of your arts fires, the art in the next slot has its timer cut by
    15 % of its effective cooldown (at most once per art per second).
  - Minor: Find the Gap (Tìm Khe). When your art is fully stopped by a ward, refund 50 % of its cost.
  - Minor: Water Takes the Shape (Tùy Hình). Your first art each fight fires at half its cooldown. *(starter)*
    *Shared minor* (with Phong, Thời).

### 2. Triều (Tides)
- **Small:** `stack_effect_pct` water +1.5 · `linh_luc_regen_pct` +0.075
- **Stat notables:** Spring Tide (Triều Cường): water stack effect ×2 · Ebb (Triều Rút): regeneration +0.2 ·
  Moon Pull (Trăng Kéo): water attack +1.5, regen +0.05 · Undertow (Sóng Ngầm): water stack effect +1, art cost −1
- **Effects:**
  - **Major: The Tide Turns (Triều Cường).** Your power runs on a 12 s wave from t = 0: for the first 6 s of each
    wave your hits deal more (L5 +30) and for the next 6 s you regenerate double linh lực.
  - Minor: High Water (Nước Lớn). While you hold 20+ Water buff stacks, your ward efficiency is +15 %.
  - Minor: Riptide (Xoáy Nước). When your crest begins, gain 6 Water buff stacks for 12 pulses.

### 3. Uyên (the Depths)
- **Small:** `linh_luc_pct` +1.2 · `ward_efficiency_pct` +1.2
- **Stat notables:** Abyss (Vực Thẳm): max linh lực ×2 · Still Deep (Lặng Sâu): ward efficiency ×2 · Hidden
  Spring (Mạch Ngầm): regen increased +4 · Cold Bottom (Đáy Lạnh): max linh lực +1, ward efficiency +1
- **Effects:**
  - **Major: The Deep Answers (Uyên Ứng).** Your hits deal more by how full your linh lực is (L5 +1 per 2 % of the
    share above 50 %, so +25 at full).
  - Minor: Overflow Shield (Tràn Thuẫn). Regeneration you lose at a full pool becomes a ward shield (up to 10 %
    of max linh lực). *(starter)*
  - Minor: Weight of Water (Trọng Thủy). Your drain ward bills 10 % less while your pool is above 70 %.

### 4. Vũ (Rain)
- **Small:** `health_regen_pct` +0.05 · `healing_pct` +1.5
- **Stat notables:** Long Rain (Mưa Dầm): regen ×2 · Soft Rain (Mưa Phùn): healing ×2 · Monsoon (Gió Mùa):
  regen +0.1, healing +1 · Rain on Leaves (Mưa Lá): regen increased +4
- **Effects:**
  - **Major: Monsoon (Mùa Mưa).** Each Water buff stack you hold also gives +0.05 pp health regeneration.
  - Minor: Rain Curtain (Màn Mưa). When you are hit for more than 10 % of max health, gain 8 Water buff stacks
    for 8 pulses. *(starter)*
  - Minor: After Rain (Sau Mưa). Your heals over 5 % of max health also cleanse 2 debuff stacks.

### 5. Giang Hà (Rivers)
- **Small:** `travel_speed_pct` +2 · `linh_luc_regen_pct` +0.075
- **Stat notables:** River Road (Đường Sông): travel ×2 · Ferryman (Lái Đò): travel +1, escape +1 · Delta (Châu
  Thổ): regen +0.1, max linh lực +1 · Ten Thousand Streams (Vạn Dòng): water attack ×2
- **Effects:**
  - **Major: All Rivers Reach the Sea (Bách Xuyên Quy Hải).** Each art you slot of a different element gives your
    Water arts +6 L2 (cap +30). The multi-element caster's Water core.
  - Minor: Downstream (Thuận Dòng). Escape art chance +15 % on water or river ground.
  - Minor: Wetland (Đầm Lầy). On water ground, your Water buff stacks are 50 % stronger.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Water Wears the Mountain (Thủy Tích Thạch Xuyên)** | keystone | Each hit you land on a ward makes that ward bill 3 % more for the fight (stacks per hit, no cap) | Your hits deal 25 % less damage (L2 −25) | Lưu |
| **Bottomless (Vô Đáy)** | keystone | Your art costs are paid from a pool 50 % larger than your maximum (an overdraw), and you start each fight at full overdraw | Your linh lực regeneration is halved | Uyên |
| **Like Water (Nhược Thủy)** | keystone | Your damage type adapts: each hit's largest part converts to the type the foe resists least (one conversion) | Your crits deal no extra damage | Triều |
| **The Sea Is Patient (Hải Nhẫn)** | keystone | After 30 s of fight, your Water buff stacks count double | Before 30 s, your arts cost 30 % more | Vũ |

## New pieces

- The Tide Turns: a fixed wave from t = 0, `Fits today` (time guard Effects).
- Like Water: conversion to the foe's least-resisted type, `Needs rule` (conversion is authored, not chosen).
- Bottomless: overdraw, `Needs rule` (Combat rule 11).

## Kept apart from

Vụ Đạo (mist, evasion, stealth); Băng Đạo (Ice); Thái Âm's Triều Tịch (the moon's tide reads moon phases, this
one is a flat wave). Thủy Đạo is **the pool, the chain and the wave**.
