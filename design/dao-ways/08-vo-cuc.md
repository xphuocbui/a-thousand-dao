# 08 · Vô Cực Đạo · *Vô Cực Sinh Thái Cực* (the Limitless; the Limitless Gives Birth to Taiji)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct`, `khi_huyet_pct`, `linh_luc_pct`, `stack_duration_pct`, `defense_pct`, `art_cost_pct`,
> `comprehension`.
> **Road:** `attack_pct` +1.2.

## Build directions

1. **Unbounded Growth.** A self-stack with no cap that grows every second of the fight (Vô Hạn), slow at first
   and enormous at 60 s. The sustain build's win condition: if the fight goes long, Vô Cực wins.
2. **Return to One.** Every bonus you hold collapses into one number: your highest layer copies itself onto the
   lowest (Quy Nhất), so a lopsided build becomes a balanced one. The anti-"empty layer" fix.
3. **Emptiness.** Empty slots, empty pool, empty layers become power (Hư Vô): a minimalist with a twist (Đại
   Đạo's empty slots are kept apart: here it is an empty pool).
4. **The First Breath.** Everything at the start: the first breath of the fight is the strongest; a hard opener.

## Facets

### 1. Vô Tướng (Formless)
- **Small:** `defense_pct` +1.2 · `evade_pct` +0.4
- **Stat notables:** No Face (Vô Diện): defense ×2 · Shapeless Guard (Hộ Vô Hình): evade ×2 · Unformed Body (Thân Vô
  Hình): defense +1, evade +1 · No Mark (Vô Dấu): status resist +2
- **Effects:**
  - **Major: Formless (Vô Tướng).** Effects that read your tags (the foe's tag-scoped bonuses against you, Silence on
    your tags) treat you as having no form or element tags.
  - Minor: No Target (Vô Đích). The foe's first art each fight misses (evaded for certain). *(starter)*
  - Minor: Empty Shape (Hình Trống). Exposed and Sundered on you last 1 pulse less.

### 2. Vô Hạn (Unbounded)
- **Small:** `attack_pct` +1.2 · `stack_duration_pct` +2
- **Stat notables:** Without End (Vô Tận): attack ×2 · Ever Rising (Mãi Lên): stack duration ×2 · No Ceiling (Không
  Trần): attack +1, max health +1 · Endless Sky (Trời Vô Biên): crit damage +2
- **Effects:**
  - **Major: Unbounded (Vô Hạn).** Each second of fight gives 1 Boundless stack (no cap, never lost): L5 +1 per stack
    (inside L5's cap of 100).
  - Minor: Early Seed (Hạt Sớm). You start each fight with 8 Boundless stacks. *(starter)*
  - Minor: Past the Limit (Vượt Hạn). Once your L5 from all sources reaches its cap, each further Boundless stack gives
    +0.5 % crit damage instead.

### 3. Quy Nhất (Return to One)
- **Small:** `attack_pct` +1.2 · `khi_huyet_pct` +0.5
- **Stat notables:** One Root (Nhất Căn): attack ×2 · One Breath (Nhất Khí): max health ×2 · Gathered (Tụ Hội): attack
  +1, max health +1 · Centre (Trung): defense +2
- **Effects:**
  - **Major: Return to One (Vạn Pháp Quy Nhất).** Your lowest damage layer (L2 to L5) is raised to 50 % of the way
    toward your highest layer's total.
  - Minor: Single Breath (Nhất Tức). Your arts with the same element as your root's highest-purity element cost 15 %
    less. *(starter)*
  - Minor: One Path (Nhất Lộ). If you hold only this Dao, +10 % to all stat lines in it. `Needs key`.

### 4. Hư Vô (Emptiness)
- **Small:** `linh_luc_pct` +1.2 · `art_cost_pct` −0.5
- **Stat notables:** Void Sea (Biển Hư): max linh lực ×2 · Empty Bowl (Bát Rỗng): art cost ×2 · Nothing Held (Không
  Giữ): max linh lực +1, art cost −1 · Hollow (Trống Rỗng): evade +2
- **Effects:**
  - **Major: Emptiness Is Form (Không Tức Thị Sắc).** Your hits deal more by your missing linh lực (L5 +1 per 2 % of
    max linh lực missing, cap +45).
  - Minor: Empty Vessel (Bình Trống). While below 20 % linh lực, your art costs are halved. *(starter)*
  - Minor: Void Ward (Hộ Hư). Your ward shields are 20 % stronger while below 30 % linh lực.

### 5. Sơ Thủy (the First Breath)
- **Small:** `attack_pct` +1.2 · `crit_chance_pct` +0.4
- **Stat notables:** Origin (Khởi Nguyên): attack ×2 · First Light of Heaven (Ánh Đầu Trời): crit chance ×2 · Birth
  Cry (Tiếng Khóc Chào Đời): attack +1, crit damage +1 · Seed Moment (Khoảnh Khắc Đầu): art speed +2
- **Effects:**
  - **Major: The First Breath (Sơ Tức).** Your first firing of each art deals more (L5 +40).
  - Minor: Beginning (Khởi Đầu). Your first art each fight fires at 1 s. *(starter)*
  - Minor: Before Taiji (Tiền Thái Cực). Your first hit each fight ignores ward shields.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Beyond Limit (Vô Cực)** | keystone | Unbounded gives 2 stacks a second after 20 s | Your hits deal 30 % less for the first 15 s (L2 −30) | Vô Hạn |
| **Before Taiji (Vô Cực Sinh Thái Cực)** | keystone | Return to One raises every layer to your highest (all layers equal) | Your highest layer is capped at 1.8× | Quy Nhất |
| **The Great Void (Đại Hư)** | keystone | Emptiness Is Form has no cap | Your linh lực regeneration is 0 | Hư Vô |
| **The Formless Form (Vô Tướng Chi Tướng)** | keystone | You are immune to curses that name a tag | Your own tag-scoped modifiers count at half | Vô Tướng |

## New pieces

- Layer totals as readables and an Effect that raises a layer (Return to One): `Needs rule` (Combat rule 5; flag as a
  big one).
- Formless (no tags for the foe's Effects): `Needs rule`.

## Kept apart from

Đại Đạo (empty slots and simplicity), Hư Thực (feints), Hỗn Độn, Thiền Đạo (emptiness of mind). Vô Cực is
**growth without a ceiling, layers made one, and the empty pool as power**.
