# 71 · Điếu Đạo · *Hàn Giang Độc Điếu* (Lone Angler on the Cold River)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `co_duyen_pct`, `tam_ma_resist_pct`, `attack_pct`, `crit_damage_pct`, `health_regen_pct`,
> `linh_luc_regen_pct`, `status_duration_pct`.
> **Road:** `crit_damage_pct` +1.5.

## Build directions

1. **The Patient Angler.** A Line is cast at fight start; every second it waits, the catch grows; when it bites (a
   guard you set), the reel-in is one enormous hit (Chờ, Câu Móc). The ultimate "set a guard and wait" build.
2. **The Lure.** Draw the foe in: the foe's arts are pulled to fire early (cheaper for you to answer), and in the
   world, events come to you (Mồi).
3. **Fortune of the Water.** Fishing as fortune: encounters and treasure from rivers (Phúc Thủy).
4. **The Calm Lake.** Heart demon calm and regeneration while waiting (Hồ Lặng).

## Facets

### 1. Chờ (Patience)
- **Small:** `crit_damage_pct` +1.5 · `health_regen_pct` +0.05
- **Stat notables:** Still Rod (Cần Yên): crit damage ×2 · Long Wait (Chờ Lâu): regen ×2 · Quiet Water (Nước Lặng): crit
  damage +1, regen +0.05 · Cold Morning (Sáng Lạnh): max health +2
- **Effects:**
  - **Major: Cast the Line (Thả Câu).** At fight start, cast a Line: it gains 1 Weight per second (cap 40). Your next hit
    after you set the hook (a guard you choose: time, foe health, foe linh lực) consumes the Weight: L5 +2 per Weight.
    `Needs key` (the Line).
  - Minor: Early Bite (Cắn Sớm). The Line starts with 5 Weight. *(starter)*
  - Minor: Recast (Thả Lại). After a reel-in, the Line is recast at once.

### 2. Mồi (the Lure)
- **Small:** `attack_pct` +1 · `co_duyen_pct` +1
- **Stat notables:** Bright Lure (Mồi Sáng): attack ×2 · Sweet Bait (Mồi Ngọt): fortune ×2 · Twitching Bait (Mồi Giật):
  attack +1, fortune +1 · Scent Trail (Vệt Mùi): status duration +2
- **Effects:**
  - **Major: Take the Bait (Cắn Câu).** The foe's arts fire 15 % sooner (their timers shortened), but their first firing
    each costs them 25 % more and deals 20 % less. A tempo trap: the foe overspends early.
  - Minor: Chum (Mồi Thả). The foe's first art each fight costs 50 % more. *(starter)*
  - Minor: Events Come to You (Sự Đến Tìm). Once a season, an event of your choice type comes to you (no travel).
    `Needs key`.

### 3. Phúc Thủy (Fortune of the Water)
- **Small:** `co_duyen_pct` +1 · `linh_luc_regen_pct` +0.075
- **Stat notables:** River Luck (May Sông): fortune ×2 · Water's Gift (Quà Nước): regen ×2 · Golden Carp (Cá Chép Vàng):
  fortune +1, regen +0.05 · River Pearl (Ngọc Trai Sông): sell price +2
- **Effects:**
  - **Major: The River Gives (Sông Cho).** Fishing (a world activity at rivers and lakes) yields spirit materials and a
    counted treasure every 10 catches. `Needs key` (fishing activity).
  - Minor: Lucky Cast (Lần Thả May). +5 % fortune near water. *(starter)*
  - Minor: Carp Leaps the Gate (Cá Chép Vượt Vũ Môn). Once a realm, a rare catch gives +2 pp breakthrough chance
    (q-extras).

### 4. Câu Móc (Line and Hook)
- **Small:** `attack_pct` +1.2 · `status_duration_pct` +2
- **Stat notables:** Barbed Hook (Lưỡi Câu Ngạnh): attack ×2 · Strong Line (Dây Bền): status duration ×2 · Set the Hook
  (Giật Câu): attack +1, crit damage +1 · Reel (Cuộn Dây): crit chance +2
- **Effects:**
  - **Major: Hooked (Mắc Câu).** The reel-in hit also applies Hooked (3 pulses): the foe cannot escape and its evade is 0.
  - Minor: Firm Grip (Cầm Chắc). Foes cannot escape from you while your Line has 20+ Weight. *(starter)*
  - Minor: Line Snaps Back (Dây Bật). If the foe cleanses Hooked, it takes a trigger hit of `c_trig` 0.5.

### 5. Hồ Lặng (the Calm Lake)
- **Small:** `tam_ma_resist_pct` +1 · `health_regen_pct` +0.05
- **Stat notables:** Mirror Lake (Hồ Gương): heart-demon resist ×2 · Lakeside Rest (Nghỉ Bờ Hồ): regen ×2 · Reed Hat (Nón
  Lá): heart-demon resist +1, regen +0.05 · Snow on the River (Tuyết Trên Sông): cold resist +2
- **Effects:**
  - **Major: Lone Angler (Độc Điếu).** While your Line has 10+ Weight, your regeneration of both pools is doubled and you
    take 10 % less damage.
  - Minor: Quiet Days (Ngày Lặng). A season spent fishing removes 15 heart demon. *(starter)*
  - Minor: Snow Hat (Nón Tuyết). Ice stacks on you are 25 % weaker.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Fish Comes to the Hook (Nguyện Giả Thượng Câu)** | keystone | Cast the Line's cap is 80 Weight, and the reel-in may exceed L5's cap by 50 (only this hit) | Your other hits deal 30 % less (L2 −30) | Chờ |
| **Cold River (Hàn Giang)** | keystone | Lone Angler applies at 5 Weight and also makes curses on you last 1 pulse less | Your art speed is −30 % | Hồ Lặng |
| **The Straight Hook (Trực Câu)** | keystone | Take the Bait also lowers the foe's ward strength by 15 % while its arts fire early | You cannot reel in before 15 s | Mồi |

## New pieces

- The Line (a waiting meter with a player-set guard); fishing as a world activity: `Needs key`.
- A single hit past the L5 cap: a cap shift, `Needs rule`, flagged.

## Kept apart from

Xạ's Full Draw (a bow art waiting at its guard; Điếu's Line is a separate meter for any hit), Nhẫn's Patience (time
as power for every hit), Kỳ (planning). Điếu is **one guard-timed reel-in, the lure that makes the foe overspend,
and fortune from the water**.
