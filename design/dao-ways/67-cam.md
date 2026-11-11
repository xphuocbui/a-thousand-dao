# 67 · Cầm Đạo · *Thiên Lại* (the Pipes of Heaven: Music)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. **Holds one art** (the Way's theme owns a song no technique
> carries as well; dao.md rule 10).
> **Theme stats:** `attack_pct` (force, soul), `art_speed_pct`, companion damage, `tam_ma_resist_pct`, `status_duration_pct`,
> `than_thuc_pct`.
> **Road:** `attack_pct` force +1.5.

## Build directions

1. **Resonance.** Each hit of the same tag in a row raises Resonance; the song swells (Cộng Hưởng). A hit-count build
   for one tag, the musical cousin of Si's obsession but per fight and reset by silence.
2. **The Zither of Souls.** Force and Soul from the strings: the Way's art, Song of Heaven's Pipes, is a two-part hit
   (Force + Soul) that the Way scales (Cầm).
3. **The War Drum.** Drums for your companion: the companion attacks on your beat and harder (Chiến Cổ).
4. **Silence.** Stop the foe's arts: Silence on tempo and a song that makes the foe's arts cost more (Vô Thanh).
5. **The Flute.** Calm: heart demon down, and the foe's growing self-stacks slowed (Tiêu).

## Art

**Song of Heaven's Pipes (Thiên Lại Khúc)** — Way art (the Cầm facet's notable). Two parts: a Force part (c_art
per the lint) and a Soul part (`x_soul` at 0.4 of a soul art of its cost). Cost 8 % of max
linh lực, cooldown 6 s. Rider (counts as a minor): +3 Resonance. `Needs rule` (a mixed Soul part; shared with Mị's
Fox Fire).

## Facets

### 1. Cầm (the Zither)
- **Small:** `attack_pct` force +1.5 · `than_thuc_pct` +0.5
- **Stat notables:** Seven Strings (Bảy Dây): force ×2 · Silk Strings (Dây Tơ): thần thức ×2 · Plucked Note (Nốt Gảy):
  force +1, soul +1 · Ancient Zither (Cổ Cầm): soul attack +2
- **Effects:**
  - **Art: Song of Heaven's Pipes** (above).
  - **Major: Strings of the Soul (Huyền Âm Nhiếp Hồn).** Your Force hits apply 1 Slackened Soul stack every 3rd hit, and
    your soul hits deal +1 % `x_soul` per 5 Resonance.
  - Minor: Tuning (Lên Dây). You start each fight with 5 Resonance. *(starter)*

### 2. Chiến Cổ (the War Drum)
- **Small:** companion damage +2 · `art_speed_pct` +0.5
- **Stat notables:** War Drum (Trống Trận): companion ×2 · Marching Beat (Nhịp Hành Quân): art speed ×2 · Thunder Drum
  (Trống Sấm): companion +1, art speed +1 · Drum Skin (Da Trống): max health +2
- **Effects:**
  - **Major: Beat the Drum (Lôi Cổ).** Your companion attacks on every second art you fire (an extra companion hit),
    once per 2 s.
  - Minor: Rally (Hiệu Triệu). Your companion's power share +5 %. *(starter)*
  - Minor: Drum Roll (Hồi Trống). After 3 companion hits in 4 s, your next art deals L5 +15.

### 3. Tiêu (the Flute)
- **Small:** `tam_ma_resist_pct` +1 · `status_duration_pct` +2
- **Stat notables:** Bamboo Flute (Sáo Trúc): heart-demon resist ×2 · Long Note (Nốt Dài): status duration ×2 · Lonely
  Tune (Khúc Cô Đơn): heart-demon resist +1, status duration +1 · Moon Flute (Tiêu Trăng): soul resist +2
- **Effects:**
  - **Major: Flute of Calm (Tiêu Tĩnh).** The foe's growing self-stacks (Fury, Hunger, Spin, Obsession and the like) lose
    1 a second while you have fired an art in the last 3 s.
  - Minor: Soothing Air (Khúc Êm). Heart demon gained from fights −20 %. *(starter)*
  - Minor: Lull (Ru). The foe's art speed −5 % while you hold 10+ Resonance.

### 4. Cộng Hưởng (Resonance)
- **Small:** `attack_pct` +1.2 · `art_speed_pct` +0.5
- **Stat notables:** Echoing Hall (Sảnh Vang): attack ×2 · Harmony (Hòa Âm): art speed ×2 · Sympathetic String (Dây Cộng
  Hưởng): attack +1, art speed +1 · Overtone (Bội Âm): crit damage +2
- **Effects:**
  - **Major: Resonance (Cộng Hưởng).** Each hit with the same form tag as your previous hit gives 1 Resonance (cap 20):
    L5 +2 each. A hit of a different form tag halves Resonance.
  - Minor: Sustain the Note (Giữ Nốt). Resonance does not fall while you have hit in the last 1 s. *(starter)*
  - Minor: Crescendo (Cao Trào). At 20 Resonance, your next hit crits for certain and Resonance falls to 10.

### 5. Vô Thanh (Silence)
- **Small:** `status_duration_pct` +2 · `attack_pct` soul +1
- **Stat notables:** Hush (Im Lặng): status duration ×2 · Soundless (Vô Âm): soul ×2 · Rest Note (Dấu Lặng): status
  duration +1, soul +1 · Still Air (Không Khí Tĩnh): soul resist +2
- **Effects:**
  - **Major: The Great Sound Is Silent (Đại Âm Hi Thanh).** Every 10 s, Silence the foe's most-slotted form tag for 2
    pulses; while the foe is Silenced by you, its arts cost 20 % more.
  - Minor: Rest (Nghỉ Nhịp). Your first Silence each fight lasts 1 pulse longer. *(starter)*
  - Minor: Ringing Silence (Lặng Ngân). While the foe is Silenced, your Resonance cannot fall.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Song Decides the Fight (Khúc Định Thắng Bại)** | keystone | Resonance's cap is 40 | A hit of a different form tag resets Resonance to 0 | Cộng Hưởng |
| **Pipes of Heaven (Thiên Lại)** | keystone | Song of Heaven's Pipes' cooldown is 4 s | You cannot slot any other damaging art | Cầm |
| **Ten-Thousand-Drum Charge (Vạn Cổ Tề Minh)** | keystone | Beat the Drum fires on every art (once per 1 s) | Your own hits deal 25 % less (L2 −25) | Chiến Cổ |

## New pieces

- A mixed Force + Soul art: `Needs rule` (Combat Damage Types: soul hits are all Soul).
- A tag for growing self-stacks: `Needs key` (shared with Liên's Calming Scent).

## Kept apart from

Vũ Đạo (rhythm as dance and the pulse beat), Si's Infatuation (one chosen tag for life), Trấn (silence as a prison).
Cầm is **resonance, the drum for the companion, and silence on tempo**.
