# 77 · Hiếu Đạo · *Ẩm Thủy Tư Nguyên* (Filial Piety; Drinking Water, Remember the Source)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. The ◇ Gia Tộc (Family) facet is archived; replaced here by
> **Gia Phong (House Rules)**. The capstone is a lineage blessing, not a lineage that fights (dao.md).
> **Theme stats:** `khi_huyet_pct`, `comprehension`, `tam_ma_resist_pct`, renown, `co_duyen_pct`, `status_resist_pct`.
> **Road:** `tam_ma_resist_pct` +1.

## Build directions

1. **The Inheritor.** Power from what came before: techniques learned from a master or a sect start further along,
   and inheritances (truyền thừa) found in the world give more (Truyền Thừa).
2. **The Loyal Disciple.** Sect loyalty as power: contribution, standing and protection from your sect (Trung Môn).
3. **Repay Every Kindness.** A debt ledger of kindnesses received; repaying them gives permanent power (Báo Ân).
4. **Ancestors' Blessing.** Rites at ancestral shrines give a seasonal blessing (Tổ Tiên).

## Facets

### 1. Tổ Tiên (Ancestors)
- **Small:** `tam_ma_resist_pct` +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Ancestral Shrine (Từ Đường): heart-demon resist ×2 · Old Blood (Máu Tổ): max health ×2 · Incense for
  the Dead (Hương Tổ): heart-demon resist +1, max health +1 · Family Name (Họ): renown +2
- **Effects:**
  - **Major: Ancestors' Blessing (Tổ Ấm).** Once a season, a rite at your ancestral shrine gives a blessing for the
    season: +5 % to one stat line of your choice. `Needs key` (shrine, rites).
  - Minor: Remember the Source (Nhớ Nguồn). Heart demon from events about family −30 %. *(starter)*
  - Minor: Ancestral Guard (Tổ Phù Hộ). The first time each year you would die, you are left at 1 health instead
    (outside fights: events). `Needs key`.

### 2. Gia Phong (House Rules) — replaces ◇ Gia Tộc
- **Small:** `status_resist_pct` +1 · `comprehension` +1
- **Stat notables:** Family Teaching (Gia Giáo): comprehension ×2 · Upright House (Nhà Nề Nếp): status resist ×2 · Good
  Upbringing (Có Giáo Dục): comprehension +1, status resist +1 · Family Craft (Nghề Nhà): crafting success +2
- **Effects:**
  - **Major: House Rules (Gia Phong).** Choose one family rule at the glimpse (diligence: +5 % seclusion progress; thrift:
    −10 % prices; martial: +5 % damage; scholarship: +5 % comprehension). `Needs key`.
  - Minor: Family Recipe (Công Thức Nhà). Your first craft each season gets a quality step chance. *(starter)*
  - Minor: Honour the Name (Giữ Tiếng). Renown losses are halved.

### 3. Trung Môn (Sect Loyalty)
- **Small:** renown +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Loyal Disciple (Đệ Tử Trung Thành): renown ×2 · Sect Robe (Áo Môn Phái): max health ×2 · Sect Pride
  (Tự Hào Môn): renown +1, max health +1 · Sect Arts (Võ Học Môn Phái): attack +2
- **Effects:**
  - **Major: For the Sect (Vì Tông Môn).** Sect contribution earned +30 %; in fights against your sect's enemies, +10 %
    damage. `Needs key` (sects, contribution).
  - Minor: Elder's Favour (Ơn Trưởng Lão). Sect market prices −10 %. *(starter)*
  - Minor: Sect Shelter (Môn Che Chở). Hostile NPCs who know your sect attack you 20 % less often.

### 4. Truyền Thừa (Inheritance)
- **Small:** `comprehension` +1 · `co_duyen_pct` +1
- **Stat notables:** Master's Legacy (Di Sản Thầy): comprehension ×2 · Inheritance Luck (Duyên Truyền Thừa): fortune ×2 ·
  Old Manual (Bí Kíp Cũ): comprehension +1, fortune +1 · Handed Down (Được Truyền): technique mastery +2
- **Effects:**
  - **Major: Inherit (Kế Thừa).** Techniques learned from a master (NPC) or an inheritance start at their second layer;
    inheritances found in the world give one more reward. `Needs key`.
  - Minor: Master's Notes (Ghi Chép Thầy). Technique mastery +10 %. *(starter)*
  - Minor: Successor (Truyền Nhân). A master NPC's death leaves you an item.

### 5. Báo Ân (Repaying Kindness)
- **Small:** renown +1 · `attack_pct` +1
- **Stat notables:** Debt of Gratitude (Nợ Ân): renown ×2 · Returned Favour (Đáp Lễ): attack ×2 · Grateful Heart (Lòng
  Biết Ơn): renown +1, attack +1 · Remembered Kindness (Nhớ Ơn): heart-demon resist +2
- **Effects:**
  - **Major: Repay Kindness (Báo Ân).** Each kindness received (an NPC helps you: World Database) is recorded; repaying it
    (an event) gives +1 % to all damage permanently (cap +10 %). `Needs key`.
  - Minor: Thank You (Cảm Tạ). Repaying a kindness removes 5 heart demon. *(starter)*
  - Minor: Ungrateful Foe (Kẻ Vô Ơn). Your hits on an NPC who betrayed a kindness deal +20 %.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Lineage Blessing (Phúc Ấm Tổ Tông)** | keystone | Ancestors' Blessing works once a month and gives +8 % | You cannot change your sect, and leaving it costs the blessing for good | Tổ Tiên, Trung Môn |
| **Remember the Source (Ẩm Thủy Tư Nguyên)** | keystone | Repay Kindness's cap is +20 % | Unrepaid kindnesses older than 10 years add heart demon each year | Báo Ân |

## New pieces

- Ancestral shrines, house rules, kindness ledger, inheritances: `Needs key` (World Database, Event Engine, Sects).

## Kept apart from

Sư Đạo (teaching others), Thệ Đạo (oaths), Hiệp Đạo (heroism). Hiếu is **blessings from the source: ancestors,
sect, masters and kindness repaid**.
