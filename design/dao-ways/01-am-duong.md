# 01 · Âm Dương Đạo · *Lưỡng Nghi* (Yin and Yang; the Two Forms)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. Holds the seeds Yin, Yang and Taiji (†).
> **Theme stats:** `attack_pct` (cold, fire, light, chaos), `stack_effect_pct` (fire, ice), `resist_pct` (cold, fire),
> `defense_pct`, `health_regen_pct`, `linh_luc_regen_pct`.
> **Road:** `attack_pct` cold +1 and fire +1 alternating (Yin road nodes and Yang road nodes).

## Build directions

1. **The Balanced Pair.** Deal Yin (Cold, Chaos) and Yang (Fire, Light) damage in equal measure; the closer to
   50/50 over the last 5 s, the more both deal (Thái Cực). A min-max of slot order and art mix.
2. **The Swap.** Your pools swap roles on demand: health and linh lực trade places once a fight (Thái Cực's
   swap), the panic button and the burst enabler in one.
3. **Day and Night.** Alternating 10 s phases: Yang phase for offence, Yin phase for regeneration; timing your
   long arts to the phases is the skill.
4. **Union.** Paired stacks: every Fire stack on the foe is worth more while an Ice stack sits beside it (Giao
   Hòa). A two-element debuff build.

## Facets

### 1. Âm (Yin) †
- **Small:** `attack_pct` cold +1 · `attack_pct` chaos +1
- **Stat notables:** Deep Yin (Thái Âm Khí): cold ×2 · Shade Water (Âm Thủy Khí): chaos ×2 · Cold Moon Qi (Nguyệt
  Hàn): ice stack effect +2 · Night Root (Gốc Đêm): cold resist +1, regen +0.05
- **Effects:**
  - **Major: Yin Gathers (Âm Tụ).** Each Yin hit (Cold or Chaos) you land gives 1 Yin (cap 20). At 20, your next Yang
    hit consumes all Yin and deals more (L5 +3 per Yin).
  - Minor: Yin Shelter (Âm Ẩn). While you hold 10+ Yin, Fire damage you take is dampened 15 % (Modifier System rule 6a). *(starter)*
  - Minor: Cold Night (Đêm Lạnh). Your Cold hits apply 1 Ice stack for 6 pulses.

### 2. Dương (Yang) †
- **Small:** `attack_pct` fire +1 · `attack_pct` light +1
- **Stat notables:** Pure Yang (Thuần Dương): fire ×2 · Bright Yang (Dương Minh): light ×2 · Sun Qi (Nhật Khí): fire
  stack effect +2 · Warm Root (Gốc Ấm): fire resist +1, regen +0.05
- **Effects:**
  - **Major: Yang Rises (Dương Thăng).** Each Yang hit (Fire or Light) gives 1 Yang (cap 20). At 20, your next Yin hit
    consumes all Yang and deals more (L5 +3 per Yang).
  - Minor: Yang Fire (Dương Hỏa). While you hold 10+ Yang, Cold damage you take is dampened 15 % (rule 6a). *(starter)*
  - Minor: Noon Qi (Ngọ Khí). Your Fire hits apply 1 extra Burn stack for 6 pulses.

### 3. Thái Cực (Taiji) †
- **Small:** `attack_pct` cold +0.75 and fire +0.75 · `defense_pct` +0.6
- **Stat notables:** Turning Fish (Cá Xoay): cold +1, fire +1 ×2 · Still Centre (Tâm Tĩnh): defense ×2 · Seed in
  Each (Hạt Trong Nhau): chaos +1, light +1 · Circle (Vòng Tròn): resist cold +1, fire +1
- **Effects:**
  - **Major: Taiji (Thái Cực).** Your hits deal more by how balanced your Yin and Yang damage was over the last 5 s:
    L5 +40 × (1 − |share_yin − share_yang|).
  - Minor: The Fish Turn (Cá Quay Đầu). Once per fight, when your health falls below 25 % while your linh lực share is higher, swap the two shares (health never set below 1; it counts as healing, so `no_heal` blocks it). *(starter)*
  - Minor: Opposites Hold (Đối Lập Tương Trì). While both Yin and Yang are 5+, your resistances to Cold and Fire are
    +20.

### 4. Ngày Đêm (Day and Night)
- **Small:** `health_regen_pct` +0.05 · `attack_pct` +1
- **Stat notables:** Long Day (Ngày Dài): attack ×2 · Long Night (Đêm Dài): regen ×2 · Dawn and Dusk (Bình Minh
  Hoàng Hôn): attack +1, regen +0.05 · Twilight (Chạng Vạng): linh lực regen +0.15
- **Effects:**
  - **Major: Day and Night (Nhật Dạ Luân).** The fight alternates 10 s Day and 10 s Night from t = 0 (you choose which
    comes first). Day: your hits deal more (L5 +25). Night: your regeneration of both pools is doubled.
  - Minor: Dusk Strike (Kích Hoàng Hôn). The first hit after a Day ends deals more (L5 +30). *(starter)*
  - Minor: Dawn Breath (Hơi Rạng Đông). When Night ends, restore 5 % of max linh lực.

### 5. Giao Hòa (Union)
- **Small:** `stack_effect_pct` fire +1 · `stack_effect_pct` ice +1
- **Stat notables:** Fire and Ice (Băng Hỏa): fire stack effect +1, ice stack effect +1 ×2 · Steam (Hơi Nước): fire
  stack duration +2 · Frost Smoke (Khói Băng): ice stack duration +2 · Wedding of Opposites (Hôn Phối): cold +1, fire +1
- **Effects:**
  - **Major: Union (Âm Dương Giao Hòa).** Pairs = the smaller of your Burn pile and your Ice pile on the foe. Each pair adds +1 % to your Burn ticks and +1 pp to the art-cost raise of your Ice stacks.
  - Minor: Shared Fire (Cộng Hỏa). Your Cold hits apply 1 Burn stack for 6 pulses. *(starter)*
  - Minor: Shared Frost (Cộng Băng). Your Fire hits apply 1 Ice stack for 6 pulses.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Two Fish Turn (Lưỡng Ngư Chuyển)** | keystone | Your Cold and Fire parts convert 30 % into each other, and your Chaos and Light parts likewise (one conversion; both tag families kept; Soul never converts). Your basic attack converts 100 %: half Cold, half Fire | You cannot slot arts that deal Physical, Force or Lightning damage | Thái Cực |
| **Perfect Balance (Âm Dương Cân Bằng)** | keystone | Taiji's bonus is L5 +70 | If either side's share falls below 30 %, your hits deal 30 % less (L2 −30) | Thái Cực |
| **Eternal Day (Vĩnh Nhật)** | keystone | Day lasts 15 s and Night 5 s | During Night your hits deal 50 % less (L2 −50) | Ngày Đêm |
| **Yin and Yang Unite (Âm Dương Hợp Nhất)** | keystone | Union's pairs are the larger pile, not the smaller | Your Burn and Ice batches last half as long (fight-long batches end at 20 s) | Giao Hòa |

## New pieces

- Yin and Yang counters; damage-share readables over a window: `Needs key`.
- Pool swap (The Fish Turn): `Needs rule` (Combat rule 11).

## Kept apart from

Thái Dương (the sun alone), Thái Âm (the moon alone), Ngũ Hành (five, not two), Quang Đạo, Ám Đạo. Âm Dương is
**balance between two, the swap, and day and night**.
