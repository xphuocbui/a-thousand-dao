# 68 · Kỳ Đạo · *Nhất Cục Thiên Hạ* (the Way of Go; the World in One Game)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `art_speed_pct`, `art_cost_pct`, `attack_pct`, `defense_pct`, `than_thuc_pct`, `comprehension`.
> **Road:** `than_thuc_pct` +0.9.

## Build directions

The planner's Way. The only player choices in a fight are made before it (slot order, guards); Kỳ makes those choices
more powerful and more numerous.

1. **The Opening Book.** Slot order matters more: the first N arts in slot order are stronger, and a set "opening"
   fires in sequence with no gaps (Bố Cục). A build that writes the first 10 s precisely.
2. **Foresight.** See the foe's guards and slot order and set a counter-guard: one art per fight that fires the
   instant the foe's named art fires (Tiên Tri). The reactive build, in a game with no reactions.
3. **Sacrifice.** Give up a piece for position: an art you sacrifice (unslot at a guard) refunds its cost and
   strengthens the others (Khí Tử).
4. **The Endgame.** Late-fight power that reads how many arts each side still has affordable (Tàn Cục).

## Facets

### 1. Tiên Tri (Foresight)
- **Small:** `than_thuc_pct` +0.5 · `defense_pct` +0.6
- **Stat notables:** Read the Board (Đọc Bàn Cờ): thần thức ×2 · Two Moves Ahead (Trước Hai Nước): defense ×2 · Deep
  Reading (Đọc Sâu): thần thức +1, defense +1 · Calm Player (Kỳ Thủ Bình Tĩnh): heart-demon resist +2
- **Effects:**
  - **Major: Answer Move (Ứng Thủ).** Name one foe art before the fight (you see its loadout); one art of yours is set to
    fire the instant that art fires (ignoring its own timer, once per its cooldown). `Needs key` (a reactive guard).
  - Minor: See the Board (Nhìn Cờ). You see the foe's slot order and guards before the fight. *(starter)*
    *Shared minor* (with Hồn, Mệnh).
  - Minor: Forced Move (Nước Ép). The foe's first art waits 0.5 s.

### 2. Bố Cục (the Opening)
- **Small:** `art_speed_pct` +0.5 · `attack_pct` +1
- **Stat notables:** Opening Book (Sách Khai Cuộc): art speed ×2 · Strong Start (Khai Cuộc Mạnh): attack ×2 · Joseki
  (Định Thức): art speed +1, attack +1 · Corner First (Chiếm Góc): art cost −2
- **Effects:**
  - **Major: The Opening (Bố Cục).** Your first 3 arts in slot order fire in sequence from 1 s, 0.4 s apart, once per
    fight (their first firing ignores their cooldown).
  - Minor: First Stone (Quân Đầu). Your first art in slot order costs nothing on its first firing. *(starter)*
  - Minor: Shape (Thế Cờ). Arts in slots 1 to 3 deal +8 %.

### 3. Hư Chiêu Kỳ (Feints in Play)
- **Small:** `art_cost_pct` −0.5 · `attack_pct` +1
- **Stat notables:** Probe (Thăm Dò): art cost ×2 · Ladder (Thang): attack ×2 · Ko Threat (Đe Dọa Cướp): art cost −1, attack
  +1 · Tesuji (Diệu Thủ): crit damage +2
- **Effects:**
  - **Major: Probe and Punish (Thăm Rồi Phạt).** When the foe's counter Effect fires on one of your hits, your next art
    within 2 s deals L5 +30 and cannot be countered.
  - Minor: Test Move (Nước Thử). Your cheapest art costs 50 % less. *(starter)*
  - Minor: Ko Fight (Tranh Cướp). When the foe reapplies a curse you just cleansed, you are immune to it for 2 s.

### 4. Khí Tử (Sacrifice)
- **Small:** `art_cost_pct` −0.5 · `khi_huyet_pct` +0.5
- **Stat notables:** Give a Stone (Bỏ Quân): art cost ×2 · Thick Shape (Thế Dày): max health ×2 · Sacrifice for Tempo (Thí
  Quân Giành Nhịp): art speed +1, art cost −1 · Strong Group (Nhóm Mạnh): defense +2
- **Effects:**
  - **Major: Sacrifice (Khí Tử Tranh Tiên).** Set one art as the sacrifice with a guard: when the guard is met, it is
    removed for the rest of the fight, refunding 30 % of max linh lực, and your other arts deal +12 % and cost 10 % less.
    `Needs rule` (unslotting mid-fight).
  - Minor: Small Loss (Mất Ít). A sacrificed art's slot fires your basic attack an extra time once. *(starter)*
  - Minor: Living Group (Nhóm Sống). After a sacrifice, curses on you last 1 pulse less.

### 5. Tàn Cục (Endgame)
- **Small:** `attack_pct` +1.2 · `defense_pct` +0.6
- **Stat notables:** Endgame Precision (Tàn Cục Chính Xác): attack ×2 · Count the Score (Đếm Điểm): defense ×2 · Yose
  (Thu Quan): attack +1, defense +1 · Last Stone (Quân Cuối): crit damage +2
- **Effects:**
  - **Major: Counting (Đếm Mục).** After 20 s, your hits deal more by how many more arts you can afford than the foe
    (L5 +10 per art, cap +40).
  - Minor: Patient Endgame (Tàn Cục Kiên Nhẫn). After 20 s, your art costs −10 %. *(starter)*
  - Minor: Resign (Đầu Hàng). Once per fight, if the foe's health share is 3× yours after 20 s, you may flee with a
    certain escape.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Every Move Was Planned (Mỗi Nước Đều Tính)** | keystone | You may set two guards per art (both must be true), and Answer Move names 2 foe arts | Your art speed bonuses count at half | Tiên Tri |
| **The World in One Game (Nhất Cục Thiên Hạ)** | keystone | The Opening fires 5 arts | After the opening, your arts cost 20 % more | Bố Cục |
| **Sacrifice the Dragon (Thí Long)** | keystone | Sacrifice may be used twice | You must slot a sacrifice art in every fight | Khí Tử |

## New pieces

- A reactive guard (fire when the foe's named art fires): `Needs key` (Combat rule 13 guard vocabulary).
- Two guards per art; unslotting mid-fight: `Needs rule`.

## Kept apart from

Hư Thực (feints that drain wards), Động Tĩnh (stances), Kiếm's Called Blow. Kỳ is **the opening, the answer move,
and sacrifice for tempo**.
