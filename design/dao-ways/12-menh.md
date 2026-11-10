# 12 · Mệnh Đạo · *Thiên Cơ* (Heaven's Secret: Fortune)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. Holds the seed Stars (†, as Star Signs).
> **Theme stats:** `co_duyen_pct`, fortune (khí vận), `crit_chance_pct`, `evade_pct`, `escape_pct`, `status_resist_pct`,
> `status_chance_pct` (Needs key).
> **Road:** fortune +1.

Rule 15 wants chance to be a flavour, never the base. So Mệnh's builds are about **controlling** chance: counting it,
loading it and knowing it, never about rolling more.

## Build directions

1. **Counted Chance.** Turn your rolls into counters (Định Mệnh): a crit every Nth hit, an evade every Nth hit.
   Deterministic power for the player who hates variance.
2. **Fortune Stacker.** Khí vận as the stat: it shifts every roll that is not 0 or 100 %, in your favour; and an
   Ill Star that shifts the foe's against them (Hung Tinh).
3. **The Diviner.** See events before they come: the life-around-the-fight Mệnh (Bói Toán), choosing your fights.
4. **Star Signs.** Your birth sign gives a fixed bonus, and a capstone lets you live under a different star.

## Facets

### 1. Tinh Tượng (Star Signs) †
- **Small:** fortune +1 · `crit_chance_pct` +0.4
- **Stat notables:** Born Under a Good Star (Sinh Sao Tốt): fortune ×2 · Star Mark (Dấu Sao): crit chance ×2 · Birth
  Chart (Lá Số): fortune +1, status resist +1 · Ascendant (Cung Mệnh): max health +2
- **Effects:**
  - **Major: Your Star (Bản Mệnh Tinh).** At character creation (or the glimpse), you receive a Star Sign: one of 12
    fixed bonuses (a +8 % stat line chosen by sign). `Needs key` (Star Sign table).
  - Minor: Lucky Hour (Giờ Hoàng Đạo). Breakthroughs attempted in your sign's month have +1 pp (q-extras). *(starter)*
  - Minor: Star's Shelter (Sao Che). The first crit against you each fight is not a crit.

### 2. Khí Vận (Fortune)
- **Small:** fortune +1 · `co_duyen_pct` +1
- **Stat notables:** Heaven's Favour (Thiên Sủng): fortune ×2 · Chance Meeting (Kỳ Ngộ): encounter fortune ×2 · Lucky
  Bones (Cốt May): fortune +1, evade +1 · Golden Thread (Chỉ Vàng): fortune +1, crit chance +0.5
- **Effects:**
  - **Major: Favoured by Heaven (Thiên Mệnh Sở Quy).** Fortune's shift on your rolls is doubled.
  - Minor: Lucky Escape (Thoát Hiểm May). Fortune also shifts your escape chance. *(starter)*
  - Minor: Windfall (Lộc Trời). Fights you win give 10 % more spirit stones and materials.

### 3. Bói Toán (Divination)
- **Small:** `co_duyen_pct` +1 · `than_thuc_pct` +0.5
- **Stat notables:** Yarrow Stalks (Cỏ Thi): fortune ×2 · Tortoise Shell (Mai Rùa): thần thức ×2 · Hexagram (Quẻ):
  fortune +1, thần thức +1 · Omen Reader (Đọc Điềm): status resist +2
- **Effects:**
  - **Major: Read the Omens (Xem Quẻ).** Once a season, see the next event this season will bring you and decide to
    meet or avoid it. `Needs key` (Event Engine).
  - Minor: Foreknowledge (Biết Trước). At fight start you see the foe's guards and slot order. *(starter)*
    *Shared minor* (with Hồn's Read the Foe).
  - Minor: Ill Omen Avoided (Tránh Hung). The first event each year that would cost you lifespan costs half.

### 4. Định Mệnh (Destiny)
- **Small:** `crit_chance_pct` +0.4 · `evade_pct` +0.4
- **Stat notables:** Fated Strike (Kích Định): crit chance ×2 · Fated Dodge (Né Định): evade ×2 · Written Path (Đường
  Đã Viết): crit chance +1, evade +1 · Destiny's Hand (Tay Số Mệnh): crit damage +2
- **Effects:**
  - **Major: Counted Fate (Số Định).** Your crit chance becomes a counter: you crit on every hit that brings the running
    total of your crit chance to a whole number (a 25 % chance crits exactly every 4th hit). Uses no draw; fortune does
    not shift it (Combat rule 15, Effects rule 12).
  - Minor: Counted Dodge (Né Theo Số). Your evade becomes a counter in the same way. *(starter)*
  - Minor: Fate's Margin (Lề Số Mệnh). Counters start half full each fight.

### 5. Hung Tinh (Ill Star)
- **Small:** fortune +1 · `status_chance_pct` +1
- **Stat notables:** Ill Star (Sao Xấu): status chance ×2 · Black Omen (Điềm Đen): fortune ×2 · Crossed Stars (Sao
  Chéo): status chance +1, fortune +1 · Unlucky Day (Ngày Xui): crit damage +2
- **Effects:**
  - **Major: Ill Star (Hung Tinh Chiếu).** Your fortune also counts against the foe: its rolls (crit, evade, status,
    escape) are shifted against it by half your fortune.
  - Minor: Jinx (Xui Xẻo). The foe's first crit each fight is not a crit. *(starter)*
  - Minor: Bad Luck Spreads (Vận Xui Lan). Your curses have +10 pp status chance against a foe with lower fortune.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Heavens Bend (Thiên Tùy Nhân Nguyện)** | keystone | All your chances become counters (crit, evade, status, trigger, escape) | Fortune does nothing for you | Định Mệnh |
| **Heaven's Secret (Thiên Cơ)** | keystone | Read the Omens works once a month | You cannot gain fortune from any source but this Dao | Bói Toán |
| **Child of Fortune (Thiên Mệnh Chi Tử)** | keystone | Fortune's shift on your rolls is tripled | Fortune's shift on the foe's rolls against you is doubled too (heaven watches both) | Khí Vận |
| **Change Your Star (Cải Tinh)** | keystone | Choose a second Star Sign | Your fortune is halved | Tinh Tượng |

## New pieces

- Star Sign table: `Needs key`.
- `status_chance_pct`: `Needs key` (catalogue lists "Status chance" as ○).
- Counters for every chance (The Heavens Bend): `Fits today` (Effects rule 12 counted chance), broadened.

## Kept apart from

Tinh Đạo (stars as arrays and meteors), Nhân Quả (karma), Kiếm's Called Blow (counted crit for swords only; Mệnh's
is every art, and both cannot stack: they are the same rule). Mệnh is **counted fate, loaded fortune, foreknowledge**.
