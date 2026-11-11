# 10 · Thời Đạo · *Quang Âm* (Passing Light: Time)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. Holds the seed Time (†).
> **Theme stats:** `art_speed_pct`, `herb_growth_pct`, `lifespan_pct`, `healing_pct`, `status_duration_pct`,
> `stack_duration_pct`, `cooldown` effects (via Effects only), `cultivation_speed_pct` (capped).
> **Road:** `art_speed_pct` +0.5.

## Build directions

1. **Haste.** Art speed as the core, with time-specific tricks: speed that lands as earlier first firings and a
   lower `cooldown_min` (a cap shift, small and costly). The tempo build.
2. **Stillness.** Slow the foe's timers (the shared timer-pushback rule, done fully here): the control build.
3. **Rewind.** Once a fight, return your health and pool to what they were 5 s ago (Hồi Quang); a defensive
   reset that makes burst builds whiff.
4. **Years.** Lifespan and herb ageing: the life-around-the-fight Time (Lão Hóa, Năm Tháng).

## Facets

### 1. Lão Hóa (Ageing) †
- **Small:** `herb_growth_pct` +2 · `lifespan_pct` +1
- **Stat notables:** Old Root (Rễ Già): herb growth ×2 · Aged Wine (Rượu Lâu Năm): pill effect +2 · Weathered (Phong
  Trần): lifespan ×2 · Patina (Lớp Gỉ Thời Gian): herb growth +1, lifespan +1
- **Effects:**
  - **Major: Hasten the Years (Thúc Niên).** Once a season, age one herb plot or pill batch by 10 years at once.
    `Needs key` (herb age; the seed's old effect). Life-around power for alchemists.
  - Minor: Wither the Foe (Lão Hóa Địch). Once per pulse, your hit shortens the foe's newest buff batch by 1 pulse (shared rule R16). *(starter)*
  - Minor: Old Wood (Gỗ Già). Wood and Earth buff stacks you hold last 2 pulses longer.

### 2. Tốc (Haste)
- **Small:** `art_speed_pct` +0.5 · `stack_duration_pct` +1
- **Stat notables:** Quickened (Tăng Tốc): art speed ×2 · Fleeting (Thoáng Qua): art speed +1, evade +1 · Swift Hand
  (Tay Nhanh): art speed +1, art cost −1 · Moment (Khoảnh Khắc): crit chance +1
- **Effects:**
  - **Major: Haste (Gia Tốc).** Your art speed also shortens your arts' first firing (the cooldown before the first
    firing is divided by art speed twice, floor 0.5 s).
  - Minor: Quick Start (Khởi Nhanh). +20 % art speed for the first 5 s. *(starter)*
  - Minor: Time Skip (Nhảy Thời). When an art fires at `cooldown_min`, the next art in slot order has 0.2 s cut from its
    timer.

### 3. Ngưng (Stillness)
- **Small:** `status_duration_pct` +2 · `defense_pct` +0.6
- **Stat notables:** Frozen Moment (Khoảnh Đông): status duration ×2 · Still Clock (Đồng Hồ Dừng): defense ×2 · Held
  Breath (Nín Thở): status duration +1, defense +1 · Stopped Sand (Cát Ngừng): soul resist +2
- **Effects:**
  - **Major: Time Stands Still (Thời Gian Ngưng).** Your hits apply Slowed Time: the target's art timers run 4 %
    slower per stack (stacks to 5, 3 pulses). `Needs key` (curse) + `Needs rule` (timers; shared).
  - Minor: Delay (Hoãn). Your first hit each fight pushes all the foe's timers back 0.5 s. *(starter)*
  - Minor: Long Moment (Khoảnh Dài). Your curses last 1 pulse longer.

### 4. Năm Tháng (Years)
- **Small:** `lifespan_pct` +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Many Winters (Nhiều Mùa Đông): lifespan ×2 · Long Life (Thọ): max health ×2 · Year Rings (Vòng
  Tuổi): lifespan +1, max health +1 · Time-Worn (Mòn Thời Gian): resist all +1
- **Effects:**
  - **Major: Years Are Power (Niên Lực).** Your hits deal more by your age in decades (L5 +2 per decade, cap +30);
    an old cultivator hits hardest.
  - Minor: Slow Ageing (Lão Chậm). Ageing penalties start 10 % later in life. *(starter)* `Needs key`.
  - Minor: Spend a Year (Tiêu Một Năm). Once per fight, spend 1 year of lifespan to refill 25 % of linh lực.

### 5. Hồi Quang (Rewind)
- **Small:** `healing_pct` +1.5 · `art_speed_pct` +0.5
- **Stat notables:** Turn Back (Quay Lại): healing ×2 · Echo of Self (Bóng Cũ): healing +1, max health +1 · Second Look
  (Nhìn Lại): art speed ×2 · Undo (Hoàn Tác): status resist +2
- **Effects:**
  - **Major: Rewind (Hồi Quang).** Once per fight, at the Down step's refusal, refuse it: your health and linh lực become the higher of now and their values 5 s earlier (clipped at t = 0). Statuses stay. It counts as healing (`no_heal` blocks it).
  - Minor: Recall (Hồi Tưởng). After a Rewind, your art timers are set to what they were 5 s earlier too. *(starter)*
  - Minor: Replay (Phát Lại). After a Rewind, your next art deals more (L5 +30).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Fight Runs on Your Clock (Thời Tại Ngã)** | keystone | Your `cooldown_min` is 25 % lower (a cap shift, `Needs rule`; R14) | Your art costs are 40 % higher | Tốc |
| **Stopped Heaven (Ngưng Thiên)** | keystone | Slowed Time stacks to 10 | Your arts cost 30 % more | Ngưng |
| **Endless Rewind (Vô Tận Hồi Quang)** | keystone | Rewind fires twice; the second reads 10 s back | Your max health is 30 % lower | Hồi Quang |
| **The Old Master (Lão Tổ)** | keystone | Years Are Power has no cap | Your art speed is −20 % | Năm Tháng |

## New pieces

- Slowed Time curse, timers slowed: `Needs key` + `Needs rule` (the shared timer rule).
- A state snapshot to rewind to: `Needs rule` (Combat rule 21 keeps the engine pure; a snapshot is fine).
- Herb age as an item field: `Needs key`.

## Kept apart from

Phong Đạo (speed as wind), Tứ Thời (the calendar), Băng's Frozen Clock (Ice-gated timer slow; Thời is the time
curse itself). Thời is **haste, stopped time, and the rewind**.
