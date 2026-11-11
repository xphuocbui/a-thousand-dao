# 74 · Long Đạo · *Chân Long* (the True Dragon)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `khi_huyet_pct`, `body_shield_pct`, `attack_pct` (cold, lightning, physical), `artifact_power_pct`,
> `status_duration_pct` (fear), `resist_pct`.
> **Road:** `khi_huyet_pct` +1.

## Build directions

1. **Dragon Blood.** Vitality and Blood Purity: max health that feeds damage (Long Huyết). With Huyết Đạo's Blood
   Purity, the bloodline build.
2. **Scales.** Shields in layers: Dragon Scales are body-shield pieces, each stopping one element (Long Lân).
3. **The Roar.** Fear and Silence on a long cooldown: the opening roar that wins the tempo (Long Ngâm).
4. **The Hoard.** Treasures: more artifacts and spirit stones as power (Long Tàng). The dragon sitting on gold.
5. **Rain-Calling.** Water and Lightning together: storm arts (Hô Vũ).

## Facets

### 1. Long Huyết (Dragon Blood)
- **Small:** `khi_huyet_pct` +1 · `attack_pct` physical +1
- **Stat notables:** Dragon Heart (Long Tâm): max health ×2 · Dragon Might (Long Lực): physical ×2 · Hot Blood of Dragons
  (Long Huyết Nóng): max health +1, physical +1 · Ancient Line (Dòng Cổ): regen +0.1
- **Effects:**
  - **Major: Dragon Blood (Long Huyết Thức Tỉnh).** Your hits gain flat damage equal to 0.6 % of your max health; with
    Blood Purity (Huyết Đạo), +0.01 % more per point.
  - Minor: Dragon's Girth (Long Thể). +8 % max health. *(starter)*
  - Minor: Dragon's Vigour (Long Sinh Lực). Your health regeneration +1 % per 10 % of max health above your realm base.

### 2. Long Lân (Scales)
- **Small:** `body_shield_pct` +1 · `resist_pct` +1
- **Stat notables:** Hard Scales (Vảy Cứng): body shield ×2 · Shining Scales (Vảy Sáng): resist all ×2 · Overlapping
  (Vảy Chồng): body shield +1, resist +1 · Reverse Scale (Nghịch Lân): crit damage +2
- **Effects:**
  - **Major: Dragon Scales (Long Lân).** Your body shield is split into 4 Scales, one per element group (Physical/Force,
    Fire/Cold/Lightning/Light, Chaos, Soul): each stops only its group, at 40 % of the whole shield's value each.
    `Needs rule` (Combat Defence shields; shared idea with Cốt's Plates).
  - Minor: Polished Scale (Vảy Bóng). +10 % body shield. *(starter)*
  - Minor: The Reverse Scale (Nghịch Lân). When a crit hits you, your next hit deals L5 +30 (the dragon's anger).

### 3. Long Ngâm (the Roar)
- **Small:** `status_duration_pct` fear +2 · `attack_pct` +1
- **Stat notables:** Thunder Roar (Hống Sấm): fear duration ×2 · Deep Voice (Giọng Trầm): attack ×2 · Echoing Roar (Hống
  Vang): fear duration +1, attack +1 · Terror of Heaven (Uy Trời): status resist +2
- **Effects:**
  - **Major: Dragon's Roar (Long Ngâm).** At 2 s and every 20 s after, roar: the foe is Silenced on its most-slotted tag
    for 1 pulse and Afraid (Tình's key) for 2 pulses.
  - Minor: Opening Roar (Hống Mở Màn). The first roar comes at 1 s. *(starter)*
  - Minor: Roar of Kings (Hống Vương). Foes two realms below cannot act for 1 s after a roar.

### 4. Long Tàng (the Hoard)
- **Small:** `artifact_power_pct` +0.9 · spirit stone yield +1
- **Stat notables:** Golden Bed (Giường Vàng): artifact power ×2 · Treasure Eye (Mắt Bảo): stone yield ×2 · Gem Scales (Vảy
  Ngọc): artifact power +1, stone yield +1 · Jealous Guard (Giữ Của): body shield +2
- **Effects:**
  - **Major: The Hoard (Long Tàng).** Your artifact power is +1 % per 10 % of your realm's typical stone wealth you carry
    (cap +25 %). `Needs key` (wealth readable).
  - Minor: Hoarder (Kẻ Tích Trữ). Spirit stones you carry cannot be stolen. *(starter)*
  - Minor: Dragon's Greed (Long Tham). Fights against a richer foe deal +10 %.

### 5. Hô Vũ (Rain-Calling)
- **Small:** `attack_pct` cold +1 · `attack_pct` lightning +1
- **Stat notables:** Storm Dragon (Bão Long): cold +1, lightning +1 ×2 · Rain Pearl (Ngọc Mưa): water stack effect +2 · Cloud
  Rider (Cưỡi Mây Long): art speed +2 · Thunder Claw (Vuốt Sấm): lightning crit damage +2
- **Effects:**
  - **Major: Call the Rain (Hô Phong Hoán Vũ).** Your Cold hits grant 1 Water buff stack and your Lightning hits apply 1
    Thunder debuff stack; while you hold 15+ Water buff stacks, your Lightning hits deal L5 +15.
  - Minor: Rain Cloud (Mây Mưa). You start each fight with 10 Water buff stacks. *(starter)*
  - Minor: Wet Target (Mục Tiêu Ướt). A foe bearing Ice stacks takes +10 % from your Lightning.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Dragon Wakes (Long Tỉnh)** | keystone | Dragon Blood uses 1.2 % | Your art speed is −20 % | Long Huyết |
| **Ninefold Scales (Cửu Lân)** | keystone | Each Scale stops its group at 60 % | Your ward strength is halved | Long Lân |
| **Lord of the Four Seas (Tứ Hải Long Vương)** | keystone | Call the Rain's bonus is L5 +35 and starts at 10 stacks | You cannot apply Burn | Hô Vũ |

## New pieces

- Scales by element group: `Needs rule`.
- Carried wealth as a readable: `Needs key`.

## Kept apart from

Thú Đạo (companions), Hóa Đạo (beast forms), Huyết's Bloodline. Long is **health as damage, scales by element, and
the roar**.
