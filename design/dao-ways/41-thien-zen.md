# 41 · Thiền Đạo · *Minh Tâm* (the Bright Heart: Zen)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `cultivation_speed_pct` (capped), `tam_ma_resist_pct`, `status_resist_pct`, `body_shield_pct`,
> `resist_pct` (all), `defense_pct`, `ngo_tinh` (comprehension).
> **Road:** `status_resist_pct` +1.

## Build directions

1. **Vows.** Power from self-restriction, chosen before a fight from a list (no Fire arts, no healing, no more than
   2 arts, no escape): each Vow kept gives a big bonus (Thệ Nguyện). The PoE "challenge league" build: the
   min-maxer picks the Vows that cost their build nothing.
2. **The Diamond Body.** Body shield and resistance to all, with immunity to being moved (Kim Cương).
3. **Emptiness.** Resistance and calm: the foe's statuses slide off (Không).
4. **Seclusion.** The cultivation-speed Way: sitting still pays (Tĩnh Tọa).

## Facets

### 1. Tĩnh Tọa (Stillness)
- **Small:** `cultivation_speed_pct` +0.4 · `tam_ma_resist_pct` +1
- **Stat notables:** Lotus Seat (Kiết Già): cultivation speed +1 · Long Sitting (Ngồi Lâu): heart-demon resist ×2 · Quiet
  Room (Tịnh Thất): cultivation speed +0.5, heart-demon resist +1 · Breath Count (Đếm Hơi): linh lực regen +0.15
- **Effects:**
  - **Major: Sit Still (Tĩnh Tọa).** Seclusion of a full season gives a Stillness charge (cap 3); each charge spent
    before a fight gives +15 % linh lực regeneration for it. `Needs key`.
  - Minor: Calm Breath (Hơi Lặng). Seclusion interrupted by events loses no progress. *(starter)*
  - Minor: Sitting Fight (Thiền Chiến). In fights, while you have not been hit for 3 s, your regen +30 %.

### 2. Không (Emptiness)
- **Small:** `status_resist_pct` +1 · `resist_pct` +1
- **Stat notables:** Empty Mind (Tâm Không): status resist ×2 · Nothing to Hit (Không Chỗ Đánh): resist all ×2 · Void
  Calm (Lặng Không): status resist +1, resist +1 · Formless Peace (Bình An Vô Tướng): soul resist +2
- **Effects:**
  - **Major: Form Is Emptiness (Sắc Tức Thị Không).** The first curse each foe art would place on you each fight fails (a fixed fail, no roll), and debuff stacks placed on you are 20 % fewer (rounded down).
  - Minor: Let It Pass (Để Qua). Debuff batches on you are 1 pulse shorter. *(starter)*
  - Minor: Empty Hand Calm (Tay Không Lặng). With no damaging art slotted, +20 % resist all.

### 3. Thệ Nguyện (Vows)
- **Small:** `attack_pct` +1.2 · `defense_pct` +0.6
- **Stat notables:** Vow Kept (Giữ Nguyện): attack ×2 · Discipline (Giới): defense ×2 · Strict (Nghiêm): attack +1,
  defense +1 · Pure Conduct (Hạnh Thanh): status resist +2
- **Effects:**
  - **Major: Vows (Thệ Nguyện).** Before a fight, take up to 3 Vows from a list: *No Fire arts*, *No Healing*, *At Most Two Arts*, *No Escape*, *No Talismans*, *No Pills*, *No Artifacts Beyond One*. A Vow counts only if it forbids something your loadout actually holds (you unslot it). Each counted Vow gives L5 +10 and +4 % resistance to all. `Needs key`.
  - Minor: Easy Vow (Nguyện Dễ). Your first Vow gives +50 % of its bonus. *(starter)*
  - Minor: Vow of Silence (Nguyện Câm). An extra Vow: *No Curses* (counts only if you hold a curse-applying art); while kept, Silence on you lasts 1 pulse less.

### 4. Kim Cương (the Diamond Body)
- **Small:** `body_shield_pct` +1 · `resist_pct` +1
- **Stat notables:** Diamond Skin (Da Kim Cương): body shield ×2 · Vajra (Kim Cang): resist all ×2 · Unbreakable Seat
  (Tòa Không Vỡ): body shield +1, resist +1 · Golden Bones (Cốt Vàng): max health +2
- **Effects:**
  - **Major: Diamond Body (Kim Cương Bất Hoại).** Your body shield is not worn down by Burn, and Chaos passes it at half
    (Chaos usually passes body shields fully). `Needs rule`.
  - Minor: Immovable Seat (Tòa Bất Động). Timer pushback on you does nothing. *(starter)*
  - Minor: Diamond Mind (Tâm Kim Cương). While your body shield is up, curses on you last 1 pulse less.

### 5. Đốn Ngộ (Sudden Insight)
- **Small:** `ngo_tinh` (comprehension) +1 · `than_thuc_pct` +0.5
- **Stat notables:** Flash of Truth (Chớp Chân Lý): comprehension ×2 · Open Eye (Mắt Mở): thần thức ×2 · Koan (Công Án):
  comprehension +1, thần thức +1 · Awakening (Giác): soul resist +2
- **Effects:**
  - **Major: Sudden Insight (Đốn Ngộ).** Every 8th season of seclusion (counted) brings an Insight: a technique layer gained free (never a Dao node). `Needs key`.
  - Minor: Ready Mind (Tâm Sẵn). Your Insight counter starts at 4. *(starter)*
  - Minor: Insight in Battle (Ngộ Trong Chiến). A fight won while holding 3 Vows adds 1 to the Insight counter.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Mind Does Not Move (Tâm Bất Động)** | keystone | Vows give L5 +14 each and you may take 4 | Each fight you break a Vow (by event) costs 20 heart demon | Thệ Nguyện |
| **Diamond Never Breaks (Kim Cương Bất Hoại Thân)** | keystone | Diamond Body stops Chaos fully | Your art speed is −25 % | Kim Cương |
| **Bright Heart (Minh Tâm Kiến Tính)** | keystone | Above 80 % health, each curse placed on you has its duration halved (floor 1 pulse) | Your max health is 15 % lower | Không |

## New pieces

- Vows (pre-fight restrictions with rewards): `Needs key`; shared machinery with Kiếp's Trials and Thệ Đạo.
- Burn and Chaos against body shields: `Needs rule`.

## Kept apart from

Vô Vi (power from not acting), Tâm Đạo (heart demons), Thệ Đạo (oaths in the world; Thiền's Vows are per fight),
Bồ Đề (merit). Thiền is **vows per fight, the diamond body, and emptiness that statuses slide off**.
