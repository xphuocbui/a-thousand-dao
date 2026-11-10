# 94 · Thần Đạo · *Hương Hỏa Thành Thần* (A God Made of Incense Smoke)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. The ◇ Tín Đồ (Followers) facet is archived; replaced here by
> **Thần Vị (the Divine Tablet)**. Hương Hỏa is reshaped onto shrines (dao.md: "reshaped onto shrines and ground").
> **Theme stats:** `defense_pct`, `soul_res_pct`, `attack_pct` (light, soul), `formation_power_pct`, renown, `co_duyen_pct`,
> `status_resist_pct`.
> **Road:** `soul_res_pct` +1.

## Build directions

A Thần Đạo cultivator builds **shrines** in the world. Incense is a resource the shrines produce each season; it is
spent for power, and the world (NPCs, events) feeds it.

1. **The Shrine Network.** More shrines, more incense, more power: a world-building build (Miếu, Hương Hỏa).
2. **Divine Majesty.** Fear and aura: the foe's crit and accuracy fall in your presence (Thần Uy), a defensive god.
3. **Manifestation.** Answer prayers in events for renown and incense; a quest-driven build (Hiển Linh).
4. **The Tablet.** A divine tablet carried into fights: spend incense before a fight for a big one-fight bonus.

## Facets

### 1. Thần Vị (the Divine Tablet) — replaces ◇ Tín Đồ
- **Small:** `soul_res_pct` +1 · `defense_pct` +0.6
- **Stat notables:** Spirit Tablet (Bài Vị): soul resist ×2 · Altar (Bàn Thờ): defense ×2 · Gilded Name (Tên Thếp Vàng):
  soul resist +1, defense +1 · Carved Seal (Ấn Khắc): status resist +2
- **Effects:**
  - **Major: Burn Incense Before the Tablet (Thắp Hương).** Before a foreseen fight, spend Incense: each 10 Incense
    gives L5 +5 for that fight (cap +40). `Needs key` (Incense, a character resource).
  - Minor: Small Offering (Lễ Mọn). You start each fight with a ward shield of 3 % of max linh lực per shrine you own
    (cap 15 %). *(starter)*
  - Minor: Name Remembered (Danh Được Nhớ). Your renown decays half as fast.

### 2. Hương Hỏa (Incense, onto shrines)
- **Small:** renown +1 · `co_duyen_pct` +1
- **Stat notables:** Thick Smoke (Khói Dày): renown ×2 · Many Altars (Nhiều Bàn Thờ): fortune encounters ×2 · Smoke
  Rising (Khói Bay): renown +1, fortune +1 · Fragrant Hall (Điện Thơm): soul resist +2
- **Effects:**
  - **Major: Incense from Shrines (Hương Hỏa Miếu).** Each shrine you own produces Incense each season by its region's
    population (and twice in festival months). `Needs key` (shrines in Travel & Map, population).
  - Minor: Temple Fair (Hội Chùa). Festival months double Incense. *(starter)*
  - Minor: Offerings (Cúng Phẩm). Incense may be spent as spirit stones at a poor rate.

### 3. Miếu (Shrines)
- **Small:** `formation_power_pct` +1.2 · `defense_pct` +0.6
- **Stat notables:** Roadside Shrine (Miếu Bên Đường): formation power ×2 · Stone Temple (Đền Đá): defense ×2 · Sacred
  Ground (Đất Thiêng): formation +1, defense +1 · Gate Guardian (Thần Giữ Cổng): soul resist +2
- **Effects:**
  - **Major: Holy Ground (Thánh Địa).** Fights within a region where you own a shrine count as your home ground: your
    ground-scoped L4 applies, and your wards are +15 %.
  - Minor: Build a Shrine (Lập Miếu). You may build a shrine in a region you have done a quest in. `Needs key`.
    *(starter)*
  - Minor: Shrine Ward (Hộ Miếu). Your shrines cannot be desecrated by NPC events below your realm.

### 4. Thần Uy (Divine Majesty)
- **Small:** `status_resist_pct` +1 · `soul_res_pct` +1
- **Stat notables:** Awe (Kính Sợ): status resist ×2 · Holy Presence (Thánh Uy): soul resist ×2 · Tall Shadow (Bóng
  Cao): status resist +1, defense +1 · Crowned (Đội Mũ Thần): max health +2
- **Effects:**
  - **Major: Divine Majesty (Thần Uy).** The foe's crit chance −5 pp and accuracy −5 pp; per 1,000 renown you have, a
    further −1 pp each (cap −10 pp).
  - Minor: Kneel (Quỳ). Foes two realms below you cannot attack for the first 2 s. *(starter)*
  - Minor: Terrible Face (Mặt Thần Dữ). The foe's Fury-type self-stacks grow 25 % slower.

### 5. Hiển Linh (Manifestation)
- **Small:** renown +1 · `attack_pct` light +1
- **Stat notables:** Answered Prayer (Lời Cầu Được Đáp): renown ×2 · Miracle (Phép Lạ): light ×2 · Visible God (Thần
  Hiện): renown +1, light +1 · Blessing (Ban Phúc): fortune +2
- **Effects:**
  - **Major: Answer Prayers (Hiển Linh).** Events where a mortal asks for help may be answered: each answer gives
    Incense and renown; ignoring them loses Incense. `Needs key` (Event Engine).
  - Minor: Small Miracle (Phép Nhỏ). Once a season, heal a mortal NPC's sickness (an event), +20 Incense. *(starter)*
  - Minor: Divine Light (Thần Quang). Your Light hits deal +10 % on holy ground.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Worshipped, Therefore Mighty (Hương Hỏa Thần Lực)** | keystone | Burn Incense has no cap and also gives max health (+1 % per 10 Incense) | Without Incense spent, your hits deal 25 % less (L2 −25) | Thần Vị |
| **A God of This Land (Thổ Thần)** | keystone | Holy Ground applies in neighbouring regions too | Outside regions with shrines, your wards are −20 % | Miếu |
| **The Faith Never Fades (Tín Bất Diệt)** | keystone | Incense never decays and shrines produce 50 % more | You cannot leave the regions with your shrines for more than a year at a time | Hương Hỏa |

## New pieces

- Incense (a character resource), shrines (world objects), mortal-prayer events: `Needs key` (Travel & Map, Event
  Engine, World Database). A Way that needs world systems first; flag it as late content.

## Kept apart from

Bồ Đề (merit from good deeds), Hoàng Đạo (rule over people), Vực Đạo (ground you carry; Thần's ground is fixed
shrines). Thần Đạo is **shrines, incense and majesty**.
