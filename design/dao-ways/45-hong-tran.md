# 45 · Hồng Trần Đạo · *Vạn Trượng Hồng Trần* (Red Dust; Ten Thousand Fathoms of Red Dust)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `sell_price_pct`, `buy_price_pct`, `mission_income_pct`, renown, `co_duyen_pct`, `comprehension`,
> `tam_ma_resist_pct`, `khi_huyet_pct`.
> **Road:** `co_duyen_pct` +1.

## Build directions

The Way of living among mortals. Almost all of it is life-around-the-fight; the fight pieces reward having lived.

1. **The Merchant-Cultivator.** Prices, income and standing in towns: a build that turns the economy into power (Thế
   Gian). Spirit stones are the stat.
2. **Tempered by the World.** Comprehension from mortal events and losses (Thất Khổ, Hồng Trần Luyện Tâm): insight
   for the player who plays the world, not only the fights.
3. **The Mortal Heart.** Heart demon kept low by mortal bonds (Phàm Tâm); a stable long life.
4. **Paid Power.** Spirit stones spent before a fight for power (a paid preparation): the rich cultivator's L4.

## Facets

### 1. Thế Gian (the Mortal World)
- **Small:** `sell_price_pct` +1 · `buy_price_pct` −1
- **Stat notables:** Market Sense (Mắt Chợ): sell price ×2 · Haggler (Trả Giá): buy price ×2 · Trade Roads (Đường Buôn):
  mission income ×2 · Known in Town (Quen Phố): renown +2
- **Effects:**
  - **Major: Coin Is Qi (Tiền Là Khí).** Before a fight, spend spirit stones: each 1 % of your realm's typical monthly
    income gives L4 +1 (cap +20). `Needs key` (stone spend at preparation).
  - Minor: Good Customer (Khách Quen). Shops in towns you have visited three times give −5 % prices. *(starter)*
  - Minor: Guild Friend (Bạn Phường Hội). Missions from mortal guilds pay 20 % more.

### 2. Duyên Phận (Bonds)
- **Small:** `co_duyen_pct` +1 · `tam_ma_resist_pct` +1
- **Stat notables:** Old Friends (Bạn Cũ): fortune ×2 · Kind Neighbours (Hàng Xóm Tốt): heart-demon resist ×2 · Many
  Bonds (Nhiều Mối): fortune +1, heart-demon resist +1 · Family Table (Mâm Cơm): max health +2
- **Effects:**
  - **Major: Bonds of the World (Duyên Trần).** Each mortal NPC bond you keep (friend, family, patron) gives +1 % max
    health and −1 heart demon gain per event (cap 10). `Needs key` (NPC bonds).
  - Minor: Letters Home (Thư Nhà). Visiting a bonded NPC once a year removes 10 heart demon. *(starter)*
  - Minor: Help from Friends (Bạn Giúp). Once a season, a bonded NPC gives an item or a rumour (event).

### 3. Thất Khổ (the Sorrows)
- **Small:** `comprehension` +1 · `tam_ma_resist_pct` +1
- **Stat notables:** Lessons of Loss (Bài Học Mất Mát): comprehension ×2 · Endured (Đã Chịu): heart-demon resist ×2 ·
  Wisdom of Grief (Khôn Từ Đau): comprehension +1, heart-demon resist +1 · Old Scars (Sẹo Cũ): max health +2
- **Effects:**
  - **Major: Insight from Loss (Khổ Trung Ngộ Đạo).** Each sorrowful event (a bond lost, a defeat, a failed
    breakthrough) gives comprehension progress as well as heart demon. `Needs key`.
  - Minor: Bear It (Chịu Đựng). Heart demon from sorrowful events −25 %. *(starter)*
  - Minor: Grief Remembered (Nhớ Thương). Each lost bond gives +0.5 % soul resistance for life (cap +10 %).

### 4. Phàm Tâm (a Mortal Heart)
- **Small:** `tam_ma_resist_pct` +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Simple Joys (Vui Giản Dị): heart-demon resist ×2 · Plain Food (Cơm Rau): max health ×2 · Human Warmth
  (Hơi Ấm Người): heart-demon resist +1, max health +1 · Rice Wine (Rượu Gạo): regen +0.1
- **Effects:**
  - **Major: Mortal Heart (Phàm Tâm).** Your heart demon decays 2 per month while you live in a mortal town, and your
    breakthrough heart-demon checks are +1 pp (q-extras) while it is below 20.
  - Minor: Home Cooking (Cơm Nhà). Eating in a town before a fight gives +5 % health for it. *(starter)*
  - Minor: Ordinary Clothes (Áo Thường Dân). Hostile cultivators find you 20 % less often in towns.

### 5. Hồng Trần Luyện Tâm (Tempered by the World)
- **Small:** `comprehension` +1 · `attack_pct` +1
- **Stat notables:** World-Wise (Từng Trải): comprehension ×2 · Street Fighter (Võ Phố): attack ×2 · Seen It All (Đã Thấy
  Hết): comprehension +1, attack +1 · Dust on the Robe (Bụi Trên Áo): status resist +2
- **Effects:**
  - **Major: Tempered by Red Dust (Hồng Trần Luyện Tâm).** For each 10 years lived among mortals (in towns), +1 % to all
    stat lines from every Dao you hold (cap +8 %). `Needs key`.
  - Minor: Common Sense (Lẽ Thường). Event choices that read "wisdom" are always available. *(starter)*
  - Minor: Dust Settles (Bụi Lắng). Heart demon above 50 decays twice as fast in towns.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Cultivated among Mortals (Đại Ẩn Ẩn Ư Thị)** | keystone | Living in a town counts as seclusion for cultivation speed (at 80 %) | You cannot live in a sect or a cave dwelling | Phàm Tâm, Hồng Trần Luyện Tâm |
| **Ten Thousand Fathoms (Vạn Trượng)** | keystone | Coin Is Qi's cap is L4 +40 | Your spirit stones lose 2 % a month (you live well) | Thế Gian |
| **Every Bond a Root (Mỗi Duyên Một Rễ)** | keystone | Bonds of the World has no cap | A lost bond gives double heart demon | Duyên Phận |

## New pieces

- NPC bonds, towns lived in, stone spend before a fight: `Needs key` (World Database, Travel & Map).

## Kept apart from

Tiêu Dao (wandering and freedom), Hiệp Đạo (heroism), Tâm Đạo (heart demons as a game). Hồng Trần is **the
economy, bonds and insight of a life among mortals**.
