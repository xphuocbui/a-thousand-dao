# 38 · Tình Đạo · *Thất Tình* (the Seven Feelings)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct`, `healing_pct`, `status_duration_pct` (curse), companion damage, `tam_ma_resist_pct`,
> `crit_damage_pct`, `art_speed_pct`.
> **Road:** `tam_ma_resist_pct` +1.

## Build directions

Feelings are **moods**: a self-state the build enters on a trigger, one at a time, each with its own bonus. A
build chooses which feelings it can enter and how it moves between them.

1. **Anger.** Damage when hurt: being hit pushes you into Anger (Nộ), and Anger stacks with each hit taken.
   A berserker built on mood.
2. **Joy and Sorrow.** Joy on crits and heals (art speed), Sorrow when the foe heals or you lose health (curses
   last longer): a caster that swings.
3. **Love.** Bonds: your companion's power share grows with your Love; the companion build's mood (Ái).
4. **Fear.** The foe loses nerve: Fear curses that make it hesitate (art timers waver). A control build.
5. **All Seven.** A capstone where every mood is held at once at a third of its value: breadth.

## Facets

### 1. Hỷ (Joy)
- **Small:** `art_speed_pct` +0.5 · `healing_pct` +1
- **Stat notables:** Laughter (Tiếng Cười): art speed ×2 · Glad Heart (Lòng Vui): healing ×2 · Light Step (Bước Nhẹ):
  art speed +1, evade +1 · Bright Mood (Tâm Trạng Tươi): crit chance +1
- **Effects:**
  - **Major: Joy (Hỷ).** Each crit, and each pulse in which you healed 3 %+ of max health, puts you in Joy for 4 s: +20 % art speed and your
    heals +15 %. Joy is a mood (only one at a time).
  - Minor: Good Spirits (Phấn Chấn). You start each fight in Joy. *(starter)*
  - Minor: Shared Joy (Chia Vui). While in Joy, your companion attacks 15 % faster.

### 2. Nộ (Anger)
- **Small:** `attack_pct` +1.2 · `khi_huyet_pct` +0.5
- **Stat notables:** Rage (Thịnh Nộ): attack ×2 · Hot Blood (Máu Nóng): max health ×2 · Clenched Fist (Nắm Chặt): attack
  +1, max health +1 · Red Mist (Sương Đỏ): crit damage +2
- **Effects:**
  - **Major: Anger (Nộ).** Each hit that lands on you for 3 %+ of max health gives 1 Anger (cap 15) and puts you in the Anger mood: L5 +3 per Anger. Anger is a self-counter (tag `growing`; Effects rule 8, R7) that loses 1 a second while you are in another mood. Mood priority, when two moods trigger in one instant: Anger, then Sorrow, then Joy, then Love.
  - Minor: Quick Temper (Nóng Tính). Your first hit taken each fight gives 3 Anger. *(starter)*
  - Minor: Cold Fury (Giận Lạnh). While you hold 10+ Anger, it does not decay in other moods.

### 3. Ai (Sorrow)
- **Small:** `status_duration_pct` curse +2 · `attack_pct` cold +1
- **Stat notables:** Grief (Đau Buồn): curse duration ×2 · Tears (Nước Mắt): cold ×2 · Mourning Song (Khúc Tang): curse
  duration +1, cold +1 · Heavy Heart (Lòng Nặng): soul resist +2
- **Effects:**
  - **Major: Sorrow (Ai).** When a hit of 10 %+ of your max health lands on you, enter Sorrow for 6 s: your next curse applied lasts 1 pulse longer (curse durations clamp to 1–5 pulses, R22), and on entering Sorrow you apply Withering once.
  - Minor: Weep (Khóc). Entering Sorrow cleanses 3 debuff stacks. *(starter)*
  - Minor: Shared Grief (Sầu Chung). In Sorrow, your Cold hits apply 2 Ice stacks for 6 pulses.

### 4. Ái (Love)
- **Small:** companion damage +2 · `healing_pct` +1
- **Stat notables:** Devotion (Tận Tình): companion ×2 · Tender (Dịu Dàng): healing ×2 · Bound Hearts (Hai Tim): companion
  +1, healing +1 · Faithful (Chung Thủy): max health +2
- **Effects:**
  - **Major: Love (Ái).** Your companion's hits deal more by your missing health (+1 % per 5 % missing, cap +20 %). In the Love mood (entered when your companion hits), each companion hit heals you 0.5 % of max health (at most 3 % a pulse).
  - Minor: Together (Cùng Nhau). Your companion's first hit each fight comes at 1 s. *(starter)*
  - Minor: Protective (Che Chở). While in Love, hits on you are reduced by 8 %.

### 5. Cụ (Fear)
- **Small:** `status_duration_pct` +2 · `attack_pct` +1
- **Stat notables:** Dread (Khiếp Sợ): status duration ×2 · Looming (Đe Dọa): attack ×2 · Cold Sweat (Mồ Hôi Lạnh):
  status duration +1, attack +1 · Terror (Kinh Hoàng): crit damage +2
- **Effects:**
  - **Major: Fear (Cụ).** Your crits apply Afraid (a curse, 2 pulses): the foe's next art after each of your crits waits 0.5 s before firing (`delay_timer`, Effects rule 6, R1: repeats on one target within 3 s halve the delay seconds).
  - Minor: Nervous Foe (Địch Run). The foe's first art each fight waits 0.5 s (`delay_timer`, R1). *(starter)*
  - Minor: Smell of Fear (Mùi Sợ). Your hits on an Afraid foe deal more (L5 +12).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Every Feeling, Mastered (Thất Tình Tự Tại)** | keystone | You hold every mood you have unlocked at once, each at 40 % of its value | No mood is ever at full value | any two facets |
| **Burning Anger (Nộ Hỏa Thiêu Thân)** | keystone | Anger's cap is 25 and it never decays | You can never enter Joy or Love; your heals are halved | Nộ |
| **Love Unto Death (Ái Đến Chết)** | keystone | Love's companion bonus is +1 % per 2 % missing (cap +40 %) | You cannot heal yourself from arts | Ái |

## New pieces

- Moods (a one-at-a-time self-state): `Needs key`.
- Afraid (a curse; its hesitation is `delay_timer`, R1): `Needs key`.

## Kept apart from

Vô Tình (the absence of feeling), Tâm Đạo (heart demons), Đao's Fury (momentum from hitting; Anger comes from being
hit). Tình is **moods that swing, and the feelings that drive them**.
