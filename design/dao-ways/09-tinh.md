# 09 · Tinh Đạo · *Tinh Hà* (River of Stars)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `formation_power_pct`, `attack_pct` (light, formation), `crit_chance_pct`, `accuracy_pct`,
> `travel_speed_pct`, `co_duyen_pct`, `than_thuc_pct`.
> **Road:** `attack_pct` light +1.5.

## Build directions

1. **The Sky Is Your Array.** Formations that need no ground: a star array laid in preparation follows you into
   every fight, ambush included (Tinh Trận). The L4 build that does not collapse in a blind fight.
2. **Falling Stars.** A counter that fills with each hit and drops a meteor at 7 (the Dipper's seven stars): a
   rhythm burst build (Lưu Tinh).
3. **Starlight Precision.** Accuracy and crit from Light; the foe's evade becomes your crit.
4. **The Navigator.** Travel and fortune: the stars guide you to good encounters (Bắc Đẩu).

## Facets

### 1. Tinh Trận (Star Arrays)
- **Small:** `formation_power_pct` +1.2 · `attack_pct` formation +1
- **Stat notables:** Seven Star Array (Thất Tinh Trận): formation power ×2 · Constellation (Chòm Sao): formation +1,
  light +1 · Star Map (Tinh Đồ): thần thức +2 · Pole Star Anchor (Neo Bắc Cực): defense +2
- **Effects:**
  - **Major: Array in the Sky (Thiên Trận).** One formation you have laid this season comes with you into ambush and
    blind fights at 60 % power. `Needs rule` (Combat rule 12, preparation by situation).
  - Minor: Starlit Ground (Đất Sao). Your formations' L4 is +5 at night. `Needs key` (world time). *(starter)*
  - Minor: Shifting Stars (Sao Dời). Your formations cost 20 % less upkeep.

### 2. Tinh Quang (Starlight)
- **Small:** `attack_pct` light +1.5 · `accuracy_pct` +0.5
- **Stat notables:** Starfire (Lửa Sao): light ×2 · Clear Night (Đêm Trong): accuracy ×2 · Twinkle (Lấp Lánh): light
  +1, crit chance +0.5 · Cold Starlight (Ánh Sao Lạnh): cold +1, light +1
- **Effects:**
  - **Major: Starlight Sees All (Tinh Quang Chiếu).** Each 1 pp of the foe's evade gives you +1 pp accuracy and +0.5 pp
    crit chance against it (the brighter it dodges, the clearer it shows).
  - Minor: Star Glint (Sao Lóe). Your Light crits apply Exposed for 1 pulse. *(starter)*
  - Minor: Distant Light (Ánh Xa). Your Light hits ignore 10 resistance points against a foe that has evaded you this fight.

### 3. Thiên Lý (Distance)
- **Small:** `travel_speed_pct` +2 · `art_speed_pct` +0.5
- **Stat notables:** Thousand Li (Ngàn Dặm): travel ×2 · Long Reach (Tầm Xa): art speed ×2 · Star Road (Đường Sao):
  travel +1, escape +1 · Far Sight (Nhìn Xa): accuracy +2
- **Effects:**
  - **Major: A Thousand Li in a Step (Thiên Lý Nhất Bộ).** Travel between known places takes half the time; in
    fights, your first art fires at 50 % of its cooldown.
  - Minor: Night Travel (Đi Đêm). Travel at night is 25 % faster. `Needs key`. *(starter)*
  - Minor: Star Gate (Cổng Sao). Once a year, travel to any place you have visited in a day. `Needs key` (Travel).

### 4. Bắc Đẩu (the Dipper)
- **Small:** `co_duyen_pct` +1 · `crit_chance_pct` +0.4
- **Stat notables:** Seven Stars (Bảy Sao): fortune ×2 · Pointer Stars (Sao Chỉ): crit chance ×2 · Guiding Light (Ánh
  Dẫn): fortune +1, crit chance +0.5 · North Star (Sao Bắc Cực): status resist +2
- **Effects:**
  - **Major: The Dipper Guides (Bắc Đẩu Chỉ Lộ).** Once per season, when an event offers choices, you see which choice
    leads to a fortunate encounter. `Needs key` (Event Engine).
  - Minor: Lucky Star (Sao May). Fortune (khí vận) shifts your crit rolls by 50 % more. *(starter)*
  - Minor: Star-Crossed (Lỡ Sao). A foe with lower fortune than yours has −5 pp crit chance against you.

### 5. Lưu Tinh (Falling Stars)
- **Small:** `attack_pct` light +1 · `crit_damage_pct` +1.5
- **Stat notables:** Meteor (Sao Băng): light ×2 · Shooting Star (Sao Đổi Ngôi): crit damage ×2 · Star Shower (Mưa
  Sao): light +1, crit damage +1 · Crater (Hố Va): force +2
- **Effects:**
  - **Major: Falling Stars (Lưu Tinh Trụy).** Each art hit you land adds 1 Star (cap 7; trigger hits and meteors add none). At 7, a meteor falls: a trigger hit, half Light and half Force, `c_trig` 1.2 of your strongest art's coefficient, inside `trig_budget`; Stars reset.
  - Minor: Wish on a Star (Ước Sao). Each meteor restores 4 % of max linh lực. *(starter)*
  - Minor: Starfall Crater (Hố Sao). A meteor applies Sundered (Force).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Sky Is Your Array (Thiên Vi Trận)** | keystone | Array in the Sky runs at 100 % and carries 2 formations | You cannot lay a formation on ground in a foreseen fight (only the sky arrays) | Tinh Trận |
| **River of Stars (Tinh Hà)** | keystone | Falling Stars drops a meteor at 5 Stars | Your non-meteor hits deal 25 % less (L2 −25) | Lưu Tinh |
| **Seven Stars Aligned (Thất Tinh Liên Châu)** | keystone | Your crit chance is +1 pp per Star held (cap +7) and crits add 2 Stars | Your max health is 20 % lower | Lưu Tinh, Bắc Đẩu |
| **Starlit Eye (Tinh Nhãn)** | keystone | Starlight Sees All gives +1 pp crit per 1 pp of the foe's evade | Your accuracy can never exceed what the foe's evade needs (no spare accuracy), and your crit damage −20 % | Tinh Quang |

## New pieces

- Formations carried into ambush and blind fights: `Needs rule` (Combat rule 12).
- Event choice preview (Dipper): `Needs key`.

## Kept apart from

Trận Đạo (formations as a craft on the ground), Mệnh Đạo's Tinh Tượng (star signs as fate), Quang Đạo (Exposed
uptime). Tinh is **the array you carry, the meteor every seven hits, and the guiding star**.
