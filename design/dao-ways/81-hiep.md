# 81 · Hiệp Đạo · *Hiệp Cốt* (Bones of a Hero)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct`, `khi_huyet_pct`, `pierce_pct`, renown, `crit_damage_pct`, `status_resist_pct`.
> **Road:** `attack_pct` +1.2.

## Build directions

1. **The Duelist.** Formal duels (foreseen, one-on-one challenges) give a big bonus; the build that wants every fight
   to be a challenge (Quyết Đấu).
2. **Protector of the Weak.** Fights in defence of mortals or weaker NPCs (events) give power and renown; against
   bullies (foes far above their victims), +damage (Phù Nhược).
3. **The Wandering Hero.** Quests as the progression: each hero's quest completed is a permanent stat (Du Hiệp).
4. **Fame.** Renown as power: the foe's nerve breaks before a famous hero (Danh Tiếng).

## Facets

### 1. Chính Nghĩa (Justice)
- **Small:** `attack_pct` +1.2 · `status_resist_pct` +1
- **Stat notables:** Just Blade (Lưỡi Công Lý): attack ×2 · Steady Heart (Lòng Vững): status resist ×2 · Honest Strike
  (Đòn Thẳng): attack +1, status resist +1 · Righteous Anger (Phẫn Nộ Chính Đáng): crit damage +2
- **Effects:**
  - **Major: Justice (Thế Thiên Hành Hiệp).** Against an NPC with a wicked trait or a record of killing the weak, your
    hits deal +25 % and pierce +10 pp. `Needs key` (NPC traits #42).
  - Minor: Stand Up (Đứng Ra). In event fights you join to defend someone, +10 % max health. *(starter)*
  - Minor: No Fear of the Strong (Không Sợ Kẻ Mạnh). Against a higher realm, heart demon from defeat is halved.

### 2. Phù Nhược (Protecting the Weak)
- **Small:** `khi_huyet_pct` +1 · renown +1
- **Stat notables:** Shield of the Weak (Khiên Kẻ Yếu): max health ×2 · Good Name (Tiếng Tốt): renown ×2 · Guardian
  (Người Bảo Vệ): max health +1, renown +1 · Iron Back (Lưng Sắt): block +2
- **Effects:**
  - **Major: Protect the Weak (Phù Nhược).** Fights in defence of mortals or weaker NPCs give double renown and +15 %
    damage; each one won gives +0.2 % max health for life (cap +10 %). `Needs key`.
  - Minor: Grateful Village (Làng Biết Ơn). Villages you have defended give you shelter and discounts. *(starter)*
  - Minor: Bully's Bane (Khắc Kẻ Ức Hiếp). Against a foe two realms above its victim, +20 %.

### 3. Du Hiệp (the Wandering Hero)
- **Small:** renown +1 · `travel_speed_pct` +2
- **Stat notables:** Road Hero (Hiệp Khách Giang Hồ): renown ×2 · Long Road (Đường Dài): travel ×2 · Hero's Pack (Hành Lý
  Hiệp Khách): renown +1, travel +1 · Wine and Sword (Rượu Và Kiếm): attack +2
- **Effects:**
  - **Major: Hero's Quests (Hiệp Nghĩa Nhiệm Vụ).** Each quest that helps others completed gives +0.5 % to one stat of
    your choice for life (cap +15 % total). `Needs key` (Quests).
  - Minor: Known on the Road (Có Tiếng Trên Đường). Quest givers offer you better rewards. *(starter)*
  - Minor: Hero's Welcome (Đón Như Anh Hùng). Inns are free in towns where you are famous.

### 4. Quyết Đấu (the Duel)
- **Small:** `attack_pct` +1.2 · `crit_damage_pct` +1.5
- **Stat notables:** Challenger (Kẻ Thách Đấu): attack ×2 · Duelist's Edge (Lưỡi Quyết Đấu): crit damage ×2 · Ten Paces
  (Mười Bước): attack +1, crit damage +1 · Honour Bound (Danh Dự Ràng Buộc): pierce +2
- **Effects:**
  - **Major: The Duel (Quyết Đấu).** In a foreseen challenge duel (either side challenged), your hits deal L5 +25 and the
    foe cannot use talismans or pills. `Needs key` (fight situation).
  - Minor: Accept Any Challenge (Nhận Mọi Lời Thách). Accepting a duel gives +5 % damage for it. *(starter)*
  - Minor: Duel Record (Chiến Tích). Each duel won gives +1 renown per realm of the foe.

### 5. Danh Tiếng (Reputation)
- **Small:** renown +1 · `attack_pct` +1
- **Stat notables:** Famous Name (Đại Danh): renown ×2 · Feared Sword (Kiếm Đáng Sợ): attack ×2 · Legend Grows (Truyền
  Thuyết Lớn): renown +1, attack +1 · Spotless (Trong Sạch): status resist +2
- **Effects:**
  - **Major: Name That Breaks Nerve (Nghe Danh Mất Vía).** Foes whose renown is below yours start the fight with −1 % art
    speed per 100 renown of difference (cap −15 %).
  - Minor: Fame Travels (Danh Đi Trước). Your renown decays half as fast. *(starter)*
  - Minor: Living Legend (Huyền Thoại Sống). At renown 1,000+, +5 % to all damage.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Righteousness Answers (Nghĩa Bất Dung Từ)** | keystone | Justice's bonus is +50 % | You must answer every call for help in events (you cannot refuse) | Chính Nghĩa |
| **Peerless Duelist (Thiên Hạ Đệ Nhất Kiếm Khách)** | keystone | The Duel's L5 is +50 | In ambush and blind fights, your hits deal 20 % less | Quyết Đấu |

## New pieces

- NPC traits (wicked, bully), fight situations, renown as a fight readable: `Needs key`.

## Kept apart from

Nho (righteousness as a meter and words), Thiên Đạo (rules), Hận (vengeance). Hiệp is **duels, protecting the weak,
and renown that breaks nerve**.
