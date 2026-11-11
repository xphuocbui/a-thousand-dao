# 66 · Họa Đạo · *Thi Họa* (Poetry and Painting)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** companion damage (ink), `formation_power_pct`, `attack_pct` (ink: chaos/cold), `art_speed_pct`,
> `than_thuc_pct`, `art_cost_pct`, `ngo_tinh` (comprehension).
> **Road:** `than_thuc_pct` +0.9.

## Build directions

1. **The Living Scroll.** Store arts in a scroll before a fight; release them in the fight without their cooldown
   (Thi Quyển). A preparation build: a burst bank prepared in peace.
2. **Ink Beasts.** Paint a companion: an ink beast whose power reads your thần thức and that you can repaint each
   fight in a different form (Mặc Thú). The companion build with flexibility.
3. **Brushstroke Combos.** Arts in slot order as strokes of one character: completing a "character" (3 or 5 strokes)
   triggers a finishing stroke (Bút Pháp).
4. **Landscape.** Paint the ground: a landscape scroll unrolled as ground (L4) in any fight (Sơn Thủy).
5. **Portrait.** Paint the foe: a portrait copies a share of its strongest stat for you (Chân Dung).

## Facets

### 1. Mặc Thú (Ink Beasts)
- **Small:** companion damage +2 · `than_thuc_pct` +0.5
- **Stat notables:** Ink Tiger (Hổ Mực): companion ×2 · Wet Brush (Bút Ướt): thần thức ×2 · Living Ink (Mực Sống):
  companion +1, thần thức +1 · Ink Dragon (Rồng Mực): chaos +2
- **Effects:**
  - **Major: Ink Beast (Mặc Thú).** You may paint a companion before a fight instead of bringing one: its power share is
    your thần thức ratio over the foe's × 15 % (cap `c_comp_cap`), and you choose its damage type (Chaos, Cold or
    Physical). `Needs key`.
  - Minor: Fresh Ink (Mực Mới). Your ink beast's first hit comes at 1 s. *(starter)*
  - Minor: Ink Splash (Mực Bắn). Your ink beast's hits apply 1 Dusted stack (Huyễn's accuracy-down key).

### 2. Sơn Thủy (Landscape)
- **Small:** `formation_power_pct` +1.2 · `defense_pct` +0.6
- **Stat notables:** Mountain and River (Núi Sông): formation ×2 · Mist Scroll (Tranh Sương): defense ×2 · Wide Vista (Cảnh
  Rộng): formation +1, defense +1 · Ink Wash (Thủy Mặc): soul resist +2
- **Effects:**
  - **Major: Unroll the Landscape (Trải Tranh).** One painted landscape (a ground of your choosing) unrolls at 3 s in any
    fight situation: its ground tags apply, and your formations painted into it at 60 %. `Needs rule` (ground in blind
    fights; shared with Vực, Tinh).
  - Minor: Quick Sketch (Phác Nhanh). The landscape unrolls at 1 s. *(starter)*
  - Minor: Painted Mist (Sương Vẽ). In your landscape, +5 pp evade.

### 3. Chân Dung (Portrait)
- **Small:** `than_thuc_pct` +0.5 · `attack_pct` +1
- **Stat notables:** True Likeness (Giống Thật): thần thức ×2 · Painter's Eye (Mắt Họa Sĩ): attack ×2 · Captured Spirit
  (Thần Thái): thần thức +1, attack +1 · Fine Line (Nét Mảnh): crit chance +2
- **Effects:**
  - **Major: Paint Their Portrait (Vẽ Chân Dung).** At 5 s into a fight, copy 15 % of the foe's highest layer total (L1 to
    L5) into the same layer of yours for the fight. `Needs rule` (layer readables).
  - Minor: Study the Face (Nhìn Mặt). You see the foe's layer totals at fight start. *(starter)*
  - Minor: Second Sitting (Vẽ Lần Hai). The portrait updates at 20 s.

### 4. Bút Pháp (Brushstroke)
- **Small:** `art_speed_pct` +0.5 · `art_cost_pct` −0.5
- **Stat notables:** Swift Brush (Bút Nhanh): art speed ×2 · Economy of Stroke (Nét Tiết Kiệm): art cost ×2 · Flying
  White (Phi Bạch): art speed +1, art cost −1 · Wild Cursive (Cuồng Thảo): crit damage +2
- **Effects:**
  - **Major: Write the Character (Viết Chữ).** When your arts fire in slot order through all your slotted arts (a full character), a finishing stroke follows: a trigger hit with `c_trig` = 0.3 × the number of strokes, inside `trig_budget`, with the last art's tags.
  - Minor: Practised Hand (Tay Quen). A broken character keeps its count for 2 s. *(starter)*
  - Minor: Signature (Chữ Ký). The finishing stroke applies Sundered.

### 5. Thi Quyển (the Living Scroll)
- **Small:** `ngo_tinh` (comprehension) +1 · `than_thuc_pct` +0.5
- **Stat notables:** Long Scroll (Cuộn Dài): comprehension ×2 · Poem in Ink (Thơ Mực): thần thức ×2 · Rhyme (Vần):
  comprehension +1, thần thức +1 · Verse Seal (Ấn Thơ): art cost −2
- **Effects:**
  - **Major: The Living Scroll (Thi Quyển Sống).** Before a foreseen fight, store up to 2 of your arts in the scroll
    (paying their cost then). In the fight, each fires once at its guard with no cooldown and no cost. `Needs rule`.
  - Minor: Ink Dries Slowly (Mực Khô Chậm). Stored arts keep for a week. *(starter)*
  - Minor: Poet's Breath (Hơi Thi Nhân). Stored arts deal +15 %.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **What Is Drawn Becomes Real (Họa Long Điểm Tinh)** | keystone | Your ink beast's power share uses × 25 %, and you may paint 2 that alternate every 10 s | Your own arts deal 25 % less (L2 −25) | Mặc Thú |
| **The Painted World (Thế Giới Trong Tranh)** | keystone | Your landscape unrolls at 0 s and holds 2 grounds | You cannot lay real formations | Sơn Thủy |
| **The Scroll of Ten Thousand Verses (Vạn Thi Quyển)** | keystone | The Living Scroll stores 4 arts | Your slotted arts cost 25 % more | Thi Quyển |

## New pieces

- Painted companions, stored arts, layer copying: `Needs key` / `Needs rule`.

## Kept apart from

Kỹ's Họa Phù (talismans), Nho's Thư Pháp (calligraphy as words of power), Thú Đạo (real beasts). Họa is **arts
stored in a scroll, companions painted to order, and the landscape unrolled**.
