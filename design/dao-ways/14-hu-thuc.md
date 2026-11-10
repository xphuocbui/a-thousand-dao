# 14 · Hư Thực Đạo · *Hư Hư Thực Thực* (Empty and Full; Empty and Full, Full and Empty)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `art_speed_pct`, `art_cost_pct`, `attack_pct`, `crit_damage_pct`, `evade_pct`, `accuracy_pct`.
> **Road:** `crit_damage_pct` +1.5.

## Build directions

1. **Feint and Strike.** A new art kind, the Feint (Hư Chiêu): nearly free, deals almost nothing, but counts as a
   hit for the foe's per-hit ward, its "being hit" triggers and its counters. Feints drain per-hit wards and bait
   counter-builds; the true strike that follows hits harder. Anti-counter, anti-per-hit-ward.
2. **The Hidden Blade.** Your displayed power is low (the NPC AI and the foe's "read" Effects see less), and your
   first true strike reveals the rest (Ẩn Thực). The world-level ambush build.
3. **False Images.** Evade from afterimages that grow with each feint (Hư Ảnh).
4. **Empty Becomes Full.** Every third feint becomes a true strike without warning: the counted surprise.

## Facets

### 1. Hư Chiêu (Feints)
- **Small:** `art_cost_pct` −0.5 · `art_speed_pct` +0.5
- **Stat notables:** Empty Hand (Tay Không): art cost ×2 · Quick Bluff (Lừa Nhanh): art speed ×2 · Hollow Move
  (Chiêu Rỗng): art cost −1, art speed +1 · Misdirection (Đánh Lạc): evade +2
- **Effects:**
  - **Major: Feint (Hư Chiêu).** Unlocks Feint arts: a feint costs 1 % of max linh lực, has a 1 s cooldown, deals
    `c_art` 0.1, and counts as a hit for the foe's per-hit ward payments, its "being hit" triggers and its counters.
    `Needs key` (an art kind with the `feint` tag).
  - Minor: Bait (Mồi). The foe's counter Effects (Return Stroke, Spear Wall, retaliation) fire on your feints and are
    then on their cooldown. *(starter)*
  - Minor: Empty Threat (Dọa Suông). Each feint that lands applies 1 Wind debuff stack.

### 2. Thực Kích (True Strikes)
- **Small:** `attack_pct` +1.2 · `crit_damage_pct` +1.5
- **Stat notables:** Real Blow (Đòn Thật): attack ×2 · Full Weight (Toàn Lực): crit damage ×2 · Heavy Truth (Thật
  Nặng): attack +1, crit damage +1 · True Line (Đường Thật): accuracy +2
- **Effects:**
  - **Major: The Real One (Thực Chiêu).** Each feint that lands adds L5 +6 to your next non-feint hit (cap +48).
  - Minor: Unguarded (Sơ Hở). Your first non-feint hit after 2+ feints cannot be evaded. *(starter)*
  - Minor: Through the Gap (Qua Kẽ Hở). Your non-feint hits after a feint ignore 15 resistance points.

### 3. Hư Ảnh (False Images)
- **Small:** `evade_pct` +0.4 · `art_speed_pct` +0.5
- **Stat notables:** Mirage Step (Bước Ảo): evade ×2 · Double (Bóng Đôi): evade +1, art speed +1 · Blur (Nhòe): evade
  +1, crit chance +0.5 · Smoke (Khói): escape +2
- **Effects:**
  - **Major: Afterimages (Tàn Ảnh).** Each feint you fire leaves an Image (cap 5, 4 s each): +3 pp evade per Image
    (inside `evade_cap`); an evaded hit pops one.
  - Minor: Shadow Double (Ảnh Kép). You start each fight with 2 Images. *(starter)*
  - Minor: Image Strike (Ảnh Kích). When an Image pops, your next feint's cooldown resets.

### 4. Ẩn Thực (Hidden Strength)
- **Small:** `attack_pct` +1.2 · `defense_pct` +0.6
- **Stat notables:** Plain Robe (Áo Thường): attack ×2 · Humble Face (Mặt Hiền): defense ×2 · Hidden Depth (Sâu Kín):
  attack +1, defense +1 · Quiet Power (Lực Lặng): crit damage +2
- **Effects:**
  - **Major: Hide Your Strength (Tàng Phong).** Your displayed power (`display_power`, the rating others read) is 40 %
    lower. NPCs that choose fights by power pick you more, and Effects that read your power read the lower number.
    Your first hit each fight deals more (L5 +40). `Needs key` (a displayed-power modifier).
  - Minor: Underestimated (Bị Coi Thường). Against a foe one realm or less above you, +10 % damage. *(starter)*
  - Minor: Reveal (Lộ Diện). After your first true strike, +5 % to all stats for the fight.

### 5. Hư Thực Tương Sinh (the Empty Becomes Full)
- **Small:** `attack_pct` +1 · `art_cost_pct` −0.5
- **Stat notables:** Turn (Chuyển Hóa): attack ×2 · Fill (Lấp Đầy): art cost ×2 · Two Faces (Hai Mặt): attack +1, evade
  +1 · Surprise (Bất Ngờ): crit chance +1
- **Effects:**
  - **Major: Empty Becomes Full (Hư Hóa Thực).** Every 3rd feint you fire becomes a true strike: it deals as your
    strongest slotted art (its coefficient and tags) at 60 %.
  - Minor: Full Becomes Empty (Thực Hóa Hư). Once every 10 s, an art the foe would evade becomes a feint instead (it
    still triggers The Real One). *(starter)*
  - Minor: Which Was Real (Thật Giả Khó Phân). The foe's counter Effects fire on your feints only (not on true strikes)
    while you hold 3+ Images.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Which Blow Was Real? (Hư Thực Mạc Trắc)** | keystone | Feints take no art slot (up to 3) | Your non-feint arts cost 30 % more | Hư Chiêu |
| **All Empty (Toàn Hư)** | keystone | The Real One has no cap | You may slot at most 1 non-feint art | Thực Kích |
| **Ten Thousand Images (Vạn Ảnh)** | keystone | Afterimages cap at 10 and may exceed `evade_cap` by 5 pp | Your max health is 25 % lower | Hư Ảnh |
| **The Hidden Dragon (Tàng Long)** | keystone | Hide Your Strength lowers displayed power by 80 % and its first-hit bonus is L5 +80 | Your stat lines from all Daos count at 85 % | Ẩn Thực |

## New pieces

- Feint art kind (`feint` tag): `Needs key`.
- A displayed-power modifier: `Needs key` (Combat Formulas K).
- An art kind outside the slot pool (feints): `Needs rule`.

## Kept apart from

Động Tĩnh (stances), Huyễn Đạo (illusion: false targets and mirrors; Hư Thực is feints), Kỳ Đạo (planning). Hư Thực
is **the feint that drains per-hit wards and baits counters, and the strength you hide**.
