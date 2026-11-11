# 78 · Nho Đạo · *Hạo Nhiên* (Vast Righteousness)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct` (light, force), `ngo_tinh` (comprehension), `status_duration_pct` (curse), `defense_pct`, `soul_res_pct`,
> `tam_ma_resist_pct`.
> **Road:** `ngo_tinh` (comprehension) +1.

## Build directions

1. **Words of Power.** Spoken commands as curses: Silence, Sealed Meridian and a new curse, Commanded (the foe's
   next art fires on your timing) (Ngôn Linh). The scholar-controller.
2. **Righteous Qi.** A Righteousness meter that rises with "just" fights (against foes who attacked first, demons,
   bullies) and powers Light and Force (Chính Khí).
3. **Calligraphy.** Written arts: arts inscribed in advance hit harder the longer the inscription (Thư Pháp).
4. **Rites.** Order and buffs: a fight begun with the proper rite gives a fight-long bonus (Lễ).
5. **Learning.** Comprehension (Học).

## Facets

### 1. Chính Khí (Righteous Qi)
- **Small:** `attack_pct` light +1 · `attack_pct` force +1
- **Stat notables:** Upright Qi (Khí Ngay): light ×2 · Unbending (Không Cong): force ×2 · Great Qi (Hạo Khí): light +1, force
  +1 · Pure Conscience (Lương Tâm): soul resist +2
- **Effects:**
  - **Major: Vast Righteousness (Hạo Nhiên Chính Khí).** A Righteousness meter (0–100) rises by 5 for each just fight won
    (the foe struck first, is demonic, or attacked the weak: World Database). Your Light and Force hits deal more (L5
    +1 per 4 Righteousness). `Needs key`.
  - Minor: Just Cause (Chính Danh). In a fight where the foe struck first, +10 % damage. *(starter)*
  - Minor: Shame the Wicked (Làm Nhục Kẻ Ác). Demonic foes deal you 10 % less.

### 2. Thư Pháp (Calligraphy)
- **Small:** `attack_pct` +1 · `art_cost_pct` −0.5
- **Stat notables:** Iron Brush (Bút Sắt): attack ×2 · Flowing Script (Chữ Thảo): art cost ×2 · Bold Hand (Nét Đậm):
  attack +1, art cost −1 · Seal Script (Chữ Triện): defense +2
- **Effects:**
  - **Major: Written Art (Văn Chiêu).** Before a foreseen fight, inscribe one art: for each hour (game time) spent, +2 %
    damage to it for the fight (cap +30 %). `Needs key`.
  - Minor: Practised Character (Chữ Luyện). Your inscribed art's first firing comes 1 s sooner. *(starter)*
  - Minor: Ink on the Blade (Mực Trên Lưỡi). Your inscribed art applies Exposed on its first hit.

### 3. Lễ (Rites)
- **Small:** `defense_pct` +1.2 · `status_resist_pct` +1
- **Stat notables:** Proper Bow (Vái Đúng): defense ×2 · Order (Trật Tự): status resist ×2 · Ritual Robe (Lễ Phục): defense
  +1, status resist +1 · Temple Bell (Chuông Đền): soul resist +2
- **Effects:**
  - **Major: The Rite of Combat (Lễ Chiến).** In foreseen fights (challenges, duels), you perform the rite: +10 % to all
    damage and resistance for the fight. In ambush and blind fights, nothing. `Needs key` (fight situation readable).
  - Minor: Courtesy (Lễ Độ). Challenge duels offered to you by NPCs can be declined without renown loss. *(starter)*
  - Minor: Order in Chaos (Trật Tự Giữa Hỗn Loạn). In ambush fights, curses on you last 1 pulse less.

### 4. Học (Learning)
- **Small:** `ngo_tinh` (comprehension) +1 · `tam_ma_resist_pct` +1
- **Stat notables:** Ten Thousand Books (Vạn Quyển Sách): comprehension ×2 · Calm Study (Học Lặng): heart-demon resist ×2 ·
  Scholar's Lamp (Đèn Sách): comprehension +1, heart-demon resist +1 · Library (Thư Viện): thần thức +2
- **Effects:**
  - **Major: Learning Without End (Học Vô Bờ Bến).** Comprehension +5 % per Dao you hold (other than this one), cap +15 %.
  - Minor: Diligent (Cần Cù). Seclusion progress +3 %. *(starter)*
  - Minor: Read Widely (Đọc Rộng). You may learn techniques one tier above your sect's normal access with a quest.

### 5. Ngôn Linh (Words of Power)
- **Small:** `status_duration_pct` curse +2 · `attack_pct` force +1
- **Stat notables:** Commanding Voice (Giọng Lệnh): curse duration ×2 · Weighty Words (Lời Nặng): force ×2 · True Name
  (Chân Danh): curse duration +1, force +1 · Edict (Chiếu): soul resist +2
- **Effects:**
  - **Major: Command (Hiệu Lệnh).** Every 12 s, speak a Command: the foe's next art fires at a moment you set by guard
    (delayed up to 2 s, or forced now if it is ready and its cost is due). `Needs key` (Commanded) + `Needs rule`.
  - Minor: Halt (Dừng). Your first Command each fight comes at 3 s. *(starter)*
  - Minor: Silence the Unjust (Bịt Miệng Kẻ Bất Nghĩa). Your Silence lasts 1 pulse longer against a demonic foe.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Pen Cuts Deeper (Bút Sắc Hơn Kiếm)** | keystone | Written Art may inscribe 2 arts, cap +50 % | Your non-inscribed arts deal 20 % less (L2 −20) | Thư Pháp |
| **Vast Righteousness (Hạo Nhiên)** | keystone | Righteousness gives L5 +1 per 2 points | Each unjust fight (you strike first at a weaker non-demonic foe) costs 20 Righteousness | Chính Khí |
| **Words Bind Heaven (Ngôn Xuất Pháp Tùy)** | keystone | Command every 8 s | Your hits deal 25 % less (L2 −25) | Ngôn Linh |

## New pieces

- Righteousness meter, inscription, fight situation readable, Commanded: `Needs key` / `Needs rule`.

## Kept apart from

Hiệp (heroism and duels), Thiên Đạo (rules on both sides), Ấn (seal curses). Nho is **righteousness as a meter,
inscribed arts, and the command that moves the foe's timing**.
