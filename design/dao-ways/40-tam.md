# 40 · Tâm Đạo · *Vấn Tâm* (Questioning the Heart)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `tam_ma_resist_pct`, `comprehension`, `soul_res_pct`, `than_thuc_pct`, `status_resist_pct`,
> `cultivation_speed_pct` (capped), `qi_deviation_pct` (lower).
> **Road:** `tam_ma_resist_pct` +1.

## Build directions

The breakthrough Way. Tâm turns the **heart demon system** from a tax into a game.

1. **Face the Demon.** Heart demon trials become fights you can win (Tâm Ma): each one won turns a demon into a
   permanent bonus. A build for players who want to engage with tâm ma instead of minimising it.
2. **The Dao Heart.** A stat that grows with resolve (Đạo Tâm), giving breakthrough safety and soul defence.
3. **Clarity.** Insight bursts: sudden comprehension after hard fights (Minh Ngộ).
4. **Resolve in Fights.** Status resistance and immunity to fear and charm while your Dao Heart holds (Kiên Định).

## Facets

### 1. Tâm Ma (Heart Demons)
- **Small:** `tam_ma_resist_pct` +1 · `soul_res_pct` +1
- **Stat notables:** Face the Shadow (Đối Diện Bóng): heart-demon resist ×2 · Know Thyself (Tự Biết): soul resist ×2 ·
  Inner Mirror (Gương Trong): heart-demon resist +1, soul resist +1 · Demon Tamer (Kẻ Thuần Ma): thần thức +2
- **Effects:**
  - **Major: Turn the Demon (Chuyển Ma).** When your heart demon would cause a trial (a breakthrough check or event),
    you may fight it instead (a fight against your mirror at 70 % power). Win: remove 30 heart demon and gain a Turned
    Demon (+1 % to one stat, permanent, cap 10). `Needs key` (heart-demon fights; Event Engine).
  - Minor: Know Your Demon (Biết Ma Mình). You see your heart demon's exact number and its next threshold. *(starter)*
  - Minor: Demon's Lesson (Ma Dạy). Each Turned Demon gives +2 % comprehension.

### 2. Đạo Tâm (the Dao Heart)
- **Small:** `status_resist_pct` +1 · `tam_ma_resist_pct` +1
- **Stat notables:** Firm Heart (Tâm Vững): status resist ×2 · True Heart (Tâm Thật): heart-demon resist ×2 · Heart of
  the Way (Tâm Đạo): status resist +1, heart-demon resist +1 · Unshakable (Bất Động Tâm): soul resist +2
- **Effects:**
  - **Major: Dao Heart (Đạo Tâm Kiên Cố).** A new stat, Dao Heart (0–100): +1 for each breakthrough, each Turned Demon,
    each oath kept; each point gives +0.1 pp to breakthrough heart-demon checks (q-extras) and +0.5 soul resistance.
    `Needs key`.
  - Minor: Steady Heart (Tâm Ổn). Your heart demon cannot rise more than 10 from any one event. *(starter)*
  - Minor: Heart Ward (Hộ Tâm). In fights, while your Dao Heart is 50+, fear and charm Effects on you are refused.

### 3. Tự Vấn (Self-Questioning)
- **Small:** `comprehension` +1 · `than_thuc_pct` +0.5
- **Stat notables:** Ask Again (Hỏi Lại): comprehension ×2 · Look Within (Nhìn Vào): thần thức ×2 · Doubt and Answer
  (Nghi Và Đáp): comprehension +1, thần thức +1 · Honest Mirror (Gương Thật): soul resist +2
- **Effects:**
  - **Major: Question the Heart (Vấn Tâm).** Once per season in seclusion, answer a Question (an event with three
    answers about your past choices); each answer gives a different one-season bonus (comprehension, cultivation
    speed or a breakthrough q-extra). `Needs key` (Event Engine).
  - Minor: Clear Doubts (Giải Nghi). Comprehension +5 % while heart demon is below 20. *(starter)*
  - Minor: Right Question (Câu Hỏi Đúng). The Question event offers a fourth answer.

### 4. Kiên Định (Resolve)
- **Small:** `status_resist_pct` +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Iron Resolve (Ý Sắt): status resist ×2 · Stand Firm (Đứng Vững): max health ×2 · Resolute (Quyết
  Tâm): status resist +1, max health +1 · Will to Live (Ý Sống): regen +0.1
- **Effects:**
  - **Major: Resolve (Kiên Định).** While above 50 % health, curses on you last 1 pulse less; below 50 %, your status
    resistance is +20 pp.
  - Minor: Unwavering (Không Nao Núng). The first curse on you each fight is refused. *(starter)*
  - Minor: Resolve Rewarded (Kiên Định Được Thưởng). Fights won while under 3+ curses give +1 Dao Heart.

### 5. Minh Ngộ (Clarity)
- **Small:** `comprehension` +1 · `cultivation_speed_pct` +0.4
- **Stat notables:** Clear Light (Ánh Trong): comprehension ×2 · Awakened Mind (Tâm Thức Tỉnh): cultivation speed +1 ·
  Lucid (Minh Mẫn): comprehension +1, soul resist +1 · Insight's Edge (Lưỡi Ngộ): thần thức +2
- **Effects:**
  - **Major: Sudden Clarity (Đốn Minh).** After a fight you win against a higher realm or below 20 % health, gain
    a Clarity: the next technique mastery step or Dao node is free. `Needs key`.
  - Minor: Clear Morning (Sáng Trong Lành). Seclusion progress +5 % in the season after a Clarity. *(starter)*
  - Minor: Clear in Battle (Tỉnh Táo Khi Chiến). Your accuracy +5 pp while heart demon is below 20.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **No Demon Left Inside (Tâm Vô Ma)** | keystone | Turn the Demon works on every trial and Turned Demons cap at 20 | You can never gain power from heart demon (Ma, Si and similar Effects do nothing) | Tâm Ma |
| **Heart Like a Mirror (Tâm Như Minh Kính)** | keystone | Dao Heart counts double for breakthroughs (still a separate Effect source, bot fixture) | Your heart demon gain from defeats is doubled | Đạo Tâm |
| **Ask and Be Answered (Vấn Tất Đáp)** | keystone | Question the Heart works once a month | Your seclusion time per season is −20 % | Tự Vấn |

## New pieces

- Dao Heart stat; heart-demon trial fights; seclusion Question events: `Needs key`.

## Kept apart from

Thiền (stillness, vows), Vô Tình (cutting feeling), Si and Ma (heart demon as fuel; Tâm turns it into permanent
gains instead). Tâm is **the heart demon as a game you can win**.
