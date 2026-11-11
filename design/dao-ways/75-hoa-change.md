# 75 · Hóa Đạo · *Vạn Hóa* (Ten Thousand Changes)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `khi_huyet_pct`, `attack_pct` (physical, beast), `evade_pct`, `element_affinity_pct`, `art_speed_pct`,
> `block_rating`.
> **Road:** `khi_huyet_pct` +0.5 and `evade_pct` +0.2.

## Build directions

A **Form** is a self-state that rewrites your stat profile: you hold one at a time and change by a guard you set.

1. **The Shapeshifter.** Change form mid-fight to answer the foe: Giant when it bursts, Small when it is accurate,
   Elemental when it resists your element (Biến Hóa). The adaptive build.
2. **The Giant.** One form, always: huge health, slow, unstoppable (Cự Hình).
3. **The Small.** Evade and stealth as a mouse or a sparrow: the hardest target in the game (Tiểu Hình).
4. **The Beast.** Beast Form: claws on the basic attack and a beast's instincts (Thú Hình).
5. **The Elemental.** Become your element: your damage converts and your resistance to it soars (Nguyên Tố Hình).

## Facets

### 1. Thú Hình (Beast Forms)
- **Small:** `attack_pct` beast +2 · `khi_huyet_pct` +0.5
- **Stat notables:** Tiger Form (Hình Hổ): beast ×2 · Bear Hide (Da Gấu): max health ×2 · Wolf's Speed (Tốc Sói): beast +1,
  art speed +1 · Eagle Eye (Mắt Ưng Hóa): accuracy +2
- **Effects:**
  - **Major: Beast Form (Thú Hình).** In Beast Form: your basic attack cooldown −30 %, it gains the `beast` tag and
    +40 % damage; you cannot fire arts tagged `seal` or `formation`. `Needs key` (Forms).
  - Minor: Feral (Hoang Dã). In Beast Form, +5 % leech on basic attacks. *(starter)*
  - Minor: Pounce (Vồ Mồi). Entering Beast Form makes your next basic attack crit.

### 2. Cự Hình (Giant Form)
- **Small:** `khi_huyet_pct` +1 · `block_rating` +1
- **Stat notables:** Towering Form (Hình Khổng Lồ): max health ×2 · Stone Hands (Tay Đá): block ×2 · Heavy Tread (Bước
  Nặng): max health +1, block +1 · Big Swing (Vung Lớn): physical +2
- **Effects:**
  - **Major: Giant Form (Cự Hình).** In Giant Form: max health +40 %, block +40, your hits +15 %; art speed −30 % and
    evade 0.
  - Minor: Grow (Lớn Lên). Entering Giant Form heals the health gained. *(starter)*
  - Minor: Stomp (Dậm). Entering Giant Form pushes the foe's timers back 0.5 s. `Needs rule` (timer pushback).

### 3. Tiểu Hình (Small Form)
- **Small:** `evade_pct` +0.4 · `escape_pct` +1
- **Stat notables:** Sparrow (Chim Sẻ): evade ×2 · Mouse Hole (Hang Chuột): escape ×2 · Quick and Small (Nhỏ Nhanh): evade
  +1, art speed +1 · Hidden in Grass (Ẩn Trong Cỏ): crit chance +2
- **Effects:**
  - **Major: Small Form (Tiểu Hình).** In Small Form: evade +20 pp (may exceed `evade_cap` by 5), max health −30 %, your
    hits −20 %.
  - Minor: Slip Through (Lách Qua). Entering Small Form cleanses Bound and Hooked-type effects. *(starter)*
  - Minor: Tiny Bite (Cắn Nhẹ). In Small Form, your crits apply 1 Bleed stack.

### 4. Nguyên Tố Hình (Elemental Form)
- **Small:** `element_affinity_pct` +1.5 · `attack_pct` +1
- **Stat notables:** Living Flame (Lửa Sống): affinity ×2 · Body of Water (Thân Nước): attack ×2 · Stone Flesh (Thịt Đá):
  affinity +1, attack +1 · Storm Shape (Hình Bão): resist all +1
- **Effects:**
  - **Major: Elemental Form (Nguyên Tố Hình).** In Elemental Form (of your highest-purity element): your hits convert 50 %
    to that element's damage type, you gain +60 resistance to it, and your buff stacks of it count double.
  - Minor: Element Skin (Da Nguyên Tố). Entering Elemental Form gives 10 buff stacks of its element. *(starter)*
  - Minor: Shifting Element (Nguyên Tố Đổi). You may choose your second-highest element instead.

### 5. Biến Hóa (Switching Forms)
- **Small:** `art_speed_pct` +0.5 · `khi_huyet_pct` +0.5
- **Stat notables:** Quick Change (Biến Nhanh): art speed ×2 · Fluid Body (Thân Linh Hoạt): max health ×2 · Many Faces
  (Nhiều Hình): art speed +1, max health +1 · True Shape (Chân Hình): status resist +2
- **Effects:**
  - **Major: Ten Thousand Changes (Vạn Hóa).** Set up to 3 Forms and a guard for each; you switch when its guard is met
    (once per 4 s). Each switch cleanses 3 debuff stacks and gives L5 +15 for 3 s. `Needs key` (Form guards).
  - Minor: Smooth Change (Biến Mượt). Switching keeps 50 % of your health share instead of rescaling. *(starter)*
  - Minor: Memory of Form (Nhớ Hình). Each Form you have used this fight gives +3 % to all damage.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Any Shape, Any Answer (Tùy Cơ Biến Hóa)** | keystone | Ten Thousand Changes holds 5 Forms and switches every 2 s | Your max health is 20 % lower in every Form | Biến Hóa |
| **True Giant (Pháp Thiên Tượng Địa)** | keystone | Giant Form gives +80 % max health and its art speed penalty is −15 % | You are always in Giant Form | Cự Hình |
| **Become the Element (Hóa Thân Nguyên Tố)** | keystone | Elemental Form converts 100 % and its resistance is +100 | Damage of the element that overcomes yours deals you 50 % more | Nguyên Tố Hình |

## New pieces

- Forms (a self-state rewriting the stat profile) and Form guards: `Needs key` + `Needs rule`.

## Kept apart from

Thú Đạo (a companion), Long Đạo (dragon traits), Phân Thân (clones), Động Tĩnh (two stances: offence and defence;
Hóa's Forms rewrite the profile). Hóa is **forms you switch into by guard**.
