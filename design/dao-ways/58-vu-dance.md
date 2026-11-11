# 58 · Vũ Đạo · *Nghê Thường* (the Rainbow Robe: Dance)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. The ◇ Hội (Festival: allies' power) facet is archived
> (no allies in combat); replaced here by **Biến Tấu (Variation)**.
> **Theme stats:** `art_speed_pct`, `evade_pct`, `attack_pct` (sword, palm when danced), `art_cost_pct`, `crit_chance_pct`,
> `health_regen_pct`, `escape_pct`.
> **Road:** `evade_pct` +0.4.

## Build directions

1. **The Beat.** Arts timed to a fixed rhythm: hits that land on the beat (the pulse) deal more (Tiết Tấu). A
   timing min-max: tune cooldowns so they divide the pulse.
2. **The Spinner.** Each art fired in a different form or element than the last builds Spin, so a mixed loadout
   is rewarded. The variety build.
3. **The Untouchable Dancer.** Evade that grows with each art fired; graceful defence for a caster.
4. **The Sword Dance.** Sword arts and evade: each evade advances the next sword art.

## Facets

### 1. Tiết Tấu (Rhythm)
- **Small:** `art_speed_pct` +0.5 · `crit_chance_pct` +0.4
- **Stat notables:** Steady Beat (Nhịp Đều): art speed ×2 · Drum in the Heart (Trống Lòng): crit chance ×2 ·
  Measure (Khuông): art speed +1, crit chance +0.5 · Downbeat (Phách Mạnh): crit damage +2
- **Effects:**
  - **Major: On the Beat (Hợp Tiết).** Your **art** hits that land in the same millisecond as a pulse deal more (L5 +60). The basic attack and companion are excluded. (The Ninth Bell pilot's identity piece, given a home.)
  - Minor: Keep Time (Giữ Nhịp). Your arts' effective cooldowns round to the nearest multiple of the pulse when
    within 5 % of it. *(starter)* (Effects rule 16, R37)
  - Minor: Syncopation (Nghịch Phách). Hits off the beat apply 1 Wind debuff stack for 4 pulses.

### 2. Xoay (Spin)
- **Small:** `attack_pct` +1 · `art_speed_pct` +0.5
- **Stat notables:** Whirling Sleeves (Tay Áo Xoay): attack ×2 · Turn on a Coin (Xoay Đồng Xu): art speed +1,
  evade +1 · Rainbow Hem (Vạt Cầu Vồng): element affinity +2 · Centre Held (Trục Vững): max health +1, attack +1
- **Effects:**
  - **Major: Spin (Toàn).** Each art you fire whose form or element differs from the art fired just before gives
    1 Spin (cap 10, decays 1 a second): L5 +3 per Spin on all hits.
  - Minor: Turn Away (Xoay Né). Each Spin gives +0.5 pp evade. *(starter)*
  - Minor: Seven Colours (Thất Sắc). With arts of 4+ different elements slotted, your element stacks last 1 pulse
    longer.

### 3. Uyển Chuyển (Grace)
- **Small:** `evade_pct` +0.4 · `health_regen_pct` +0.05
- **Stat notables:** Willow Waist (Eo Liễu): evade ×2 · Flowing Robe (Áo Lượn): evade +1, regen +0.05 · Light Foot
  (Chân Nhẹ): escape +1, evade +1 · Soft Landing (Đáp Êm): max health +2
- **Effects:**
  - **Major: Grace (Uyển Chuyển).** Each art you fire gives +1 pp evade for 3 s (cap +10, inside `evade_cap`); each
    hit you evade refunds 10 % of your last art's cost.
  - Minor: Bow and Turn (Cúi Xoay). The first crit against you each fight is evaded. *(starter)*
  - Minor: Trailing Silk (Lụa Bay). While you have evaded in the last 2 s, your regeneration is 50 % higher.

### 4. Kiếm Vũ (Sword Dance)
- **Small:** `attack_pct` sword +1.5 · `evade_pct` +0.4
- **Stat notables:** Dancing Blade (Kiếm Múa): sword ×2 · Silk and Steel (Lụa Thép): sword +1, evade +1 · Twirl
  Cut (Chém Xoay): sword crit chance +1 · Fan of Blades (Quạt Kiếm): sword art speed +2
- **Effects:**
  - **Major: Sword Dance (Kiếm Vũ).** When you evade, your next sword art's timer ends 0.5 s sooner and its hit
    deals more (L5 +15).
  - Minor: Flourish (Múa Hoa). Your sword crits give 2 Spin. *(starter)*
  - Minor: Ribbon Edge (Lưỡi Lụa). Your sword hits apply 1 Wind debuff stack for 4 pulses.

### 5. Biến Tấu (Variation) — replaces ◇ Hội
- **Small:** `art_cost_pct` −0.5 · `attack_pct` +1
- **Stat notables:** Improvise (Ứng Tác): art cost ×2 · Theme and Variation (Chủ Đề): attack ×2 · Fresh Step (Bước
  Mới): art speed +1, art cost −1 · Encore (Diễn Lại): crit damage +2
- **Effects:**
  - **Major: Never the Same Dance (Bất Trùng).** Your arts deal more for each different art fired in the last 8 s
    (L5 +5 per art, cap +30).
  - Minor: Encore (Tái Diễn). After all your slotted arts have fired once, your next art costs nothing (once per
    fight). *(starter)*
  - Minor: Variation (Biến Khúc). An art that fires twice in a row (nothing between) costs 25 % more.
    (A drawback minor that pays the build back through Never the Same Dance.)

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Fight Is a Dance (Chiến Như Vũ)** | keystone | On the Beat triggers on art hits within 50 ms of a pulse | Your off-beat art hits deal 20 % less (L2 −20) | Tiết Tấu |
| **Rainbow Robe (Nghê Thường)** | keystone | Spin's cap is 20 and it does not decay while you keep alternating | Two arts of the same form and element cannot both be slotted | Xoay |
| **Feather Dance (Vũ Lông)** | keystone | Grace's evade bonus may exceed `evade_cap` by 5 pp (this Way's one cap-shift capstone: Dao rule 4, R14; the −25 % max health is the felt close) | Your max health is 25 % lower | Uyển Chuyển |

## New pieces

- Cooldown snapping to the pulse (Keep Time): Effects rule 16, R37.
- Spin (self-counter, tag `growing`): Effects rule 8, R7; same machinery as Đao's Fury.

## Kept apart from

Phong Đạo (speed and evade as wind); Cầm Đạo (rhythm as music, Resonance). Vũ Đạo is **the beat, variety and grace**.
