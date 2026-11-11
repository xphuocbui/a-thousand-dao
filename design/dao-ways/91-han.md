# 91 · Hận Đạo · *Hận Hải Nan Điền* (A Sea of Hatred No One Can Fill)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct`, `crit_damage_pct`, `pierce_pct`, `khi_huyet_pct`, `tam_ma_resist_pct`, `leech_health_pct`.
> **Road:** `attack_pct` +1.2.

## Build directions

The World Database remembers who wronged you (Pillar 5). Hận is the Way that reads it.

1. **The Nemesis.** One named enemy from the World Database: against them (and their sect), a huge bonus; the
   whole build aims at one fight (Kẻ Thù). A story build with teeth.
2. **The Grudge List.** Every cultivator who defeated you or harmed your sect is marked; bonuses against all of them
   (Ghi Hận). The broader version.
3. **Vengeance in the Fight.** Damage taken from this foe in this fight becomes damage against it (Báo Thù),
   a retaliation that scales with the fight's grudge.
4. **Hatred as Qi.** Heart demon from hatred becomes linh lực regeneration (Hận Ý).

## Facets

### 1. Kẻ Thù (the Nemesis)
- **Small:** `attack_pct` +1.2 · `pierce_pct` +0.5
- **Stat notables:** Sworn Enemy (Kẻ Thù Truyền Kiếp): attack ×2 · Hunting Knife (Dao Săn Thù): pierce ×2 · Their Face
  (Mặt Hắn): attack +1, crit damage +1 · Long Memory (Nhớ Dai): max health +2
- **Effects:**
  - **Major: The Nemesis (Túc Địch).** Name one cultivator from your World Database grudges as your Nemesis. Against
    them, your hits deal more (L5 +40) and your pierce +20 pp. If they die by another's hand, you may name a new one
    after a year. (World Database grudges as a life readable, Character Stats rule 9a, R13.)
  - Minor: Know Their Ways (Biết Tay). Against your Nemesis, you see their slot order and guards. *(starter)*
  - Minor: Their Kin (Bà Con Hắn). Against your Nemesis's sect members, L5 +12.

### 2. Báo Thù (Vengeance)
- **Small:** `crit_damage_pct` +1.5 · `khi_huyet_pct` +0.5
- **Stat notables:** Repayment (Trả Nợ Máu): crit damage ×2 · Blood for Blood (Máu Trả Máu): max health ×2 · Vengeful
  (Báo Oán): crit damage +1, attack +1 · Cold Dish (Món Nguội): attack +2
- **Effects:**
  - **Major: Vengeance (Báo Thù).** Counts only damage from the grudge target's own hits: for each 5 % of your max
    health this foe has taken from you this fight (its own hits only; not its companion, ticks, reflected or ally
    damage; not net of healing), your hits on it deal more (L5 +5, cap +25). It does not read your health share.
  - Minor: First Blood Remembered (Nhớ Giọt Máu Đầu). The first hit each fight that lands on you gives L5 +15 for 5 s.
    *(starter)*
  - Minor: Spiteful Heal (Lành Vì Hận). Your leech is doubled against a foe that has crit you this fight.

### 3. Ghi Hận (Grudges)
- **Small:** `attack_pct` +1.2 · `tam_ma_resist_pct` +1
- **Stat notables:** Black Book (Sổ Đen): attack ×2 · Every Name (Từng Cái Tên): heart-demon resist ×2 · Ledger of Wrongs
  (Sổ Oán): attack +1, heart-demon resist +1 · Patient Grudge (Hận Kiên Nhẫn): crit damage +2
- **Effects:**
  - **Major: Grudge List (Danh Sách Thù).** Every cultivator who has defeated you, robbed you or killed a sect member
    is on your list. Against them, L5 +20. (World Database grudges, Character Stats rule 9a, R13.)
  - Minor: Old Wound (Vết Cũ). Against a listed foe, you start with 10 % more linh lực. *(starter)*
  - Minor: Settled Score (Rửa Hận). Defeating a listed foe removes 10 heart demon.

### 4. Huyết Thệ (Blood Oath)
- **Small:** `khi_huyet_pct` +1 · `attack_pct` +1
- **Stat notables:** Oath in Blood (Thề Máu): max health ×2 · Cut Palm (Rạch Tay): attack ×2 · Sworn (Đã Thề): max health
  +1, attack +1 · Unbreakable Vow (Lời Thề Sắt): status resist +2
- **Effects:**
  - **Major: Blood Oath (Huyết Thệ).** Swear an oath to defeat a World Database grudge within reach (same realm band or higher) within a year: +10 % to all damage until
    it is done. One oath at a time, with a one-year wait after it ends. If the year passes, lose 2 years of lifespan
    (more for a higher-realm target) and gain 30 heart demon. `Needs key` (oath with a deadline).
  - Minor: Oath-Bound (Bị Thề Ràng). While under oath, +5 % max health. *(starter)*
  - Minor: Oath Kept (Giữ Lời). Fulfilling an oath gives a permanent +1 % damage (cap +10 %).

### 5. Hận Ý (Hatred as Qi)
- **Small:** `linh_luc_regen_pct` +0.075 · `attack_pct` +1
- **Stat notables:** Burning Hate (Hận Cháy): linh lực regen ×2 · Cold Hate (Hận Lạnh): attack ×2 · Simmering (Âm Ỉ):
  regen +0.05, attack +1 · Black Heart (Tâm Đen): crit damage +2
- **Effects:**
  - **Major: Hatred Is Qi (Hận Hóa Khí).** Your linh lực regeneration is increased by 1 % per 2 heart demon (an in-fight readable, R13; cap +40 %).
  - Minor: Fuel (Nhiên Liệu). Heart demon gained from defeats is halved, but each defeat gives +1 % damage against the
    victor forever (World Database). *(starter)*
  - Minor: Glare (Trừng Mắt). The foe's accuracy is −5 pp while you are below 50 % health.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The World Remembers, and So Do You (Thế Nhớ, Ta Nhớ)** | keystone | The Nemesis bonus is L5 +80 | Against anyone but your Nemesis or listed foes, your hits deal 25 % less (L2 −25) | Kẻ Thù |
| **A Sea of Hatred (Hận Hải)** | keystone | Vengeance's cap rises to +50 (inside the L5 cap of 100) | You cannot heal at all, leech included | Báo Thù |
| **Never Forgive (Vĩnh Bất Tha Thứ)** | keystone | The Grudge List includes anyone who has ever beaten you (a Down or a flight) | Your heart demon cannot fall below 50 | Ghi Hận |

## New pieces

- World Database reads (grudges, Nemesis): Character Stats rule 9a life readables (R13); a strong Pillar 5 tie.
- Oaths with deadlines: `Needs key` (shared with Thệ Đạo).

## Kept apart from

Nhân Quả's Báo Ứng (retribution for any blow, per fight), Thệ Đạo (oaths as a way of life), Sát Đạo (killing intent
in general). Hận is **power against the named, from the World Database**.
