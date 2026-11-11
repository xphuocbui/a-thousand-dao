# 18 · Hỏa Đạo · *Phần Thiên* (Burning Heaven: Fire)

> Overnight draft 2026-11-11. Proposal. **Needs:** Fire ≥ 30. Holds the seeds Lava and Pill Fire (†).
> **Theme stats:** `attack_pct` (fire, burn, over_time), `stack_effect_pct` (fire), `stack_duration_pct` (fire),
> `resist_pen_pct` (fire), `pill_effect_pct`, `dan_doc_resist_pct`, `alchemy_success`, `attack_pct` (physical) on
> Lava only, `khi_huyet_pct` on Niết Bàn only.
> **Road:** `attack_pct` fire +2.

## Build directions

1. **The Pyre.** Burn batches by the hundred; Burn has no cap, so the build is a clock that speeds up. Stack:
   Fire stack effect, over-time damage, Fire penetration (read when applied).
2. **The Stoked Furnace.** Your own Fire buff stacks (+1.2 % damage each) as the main multiplier for direct hits;
   Lò Nóng keeps them from expiring while you keep casting.
3. **The Lava Flow.** Fire and Physical in one hit (Dung Nham), half rides Burn, half rides Metal or Earth stacks;
   Burn that also cracks block.
4. **The Ash Harvest.** Consume Burn for bursts (Tro Tàn): the build lets the clock run, then cashes it.
5. **The Phoenix.** Survive the Down step once by burning, and come back stronger (Niết Bàn).

## Facets

### 1. Chân Hỏa (True Flame)
- **Small:** `stack_effect_pct` fire +1.5 · `attack_pct` over_time +1.5
- **Stat notables:** White Flame (Bạch Diễm): fire stack effect ×2 · Long Burn (Cháy Lâu): fire stack duration
  +2 ×2 · Hungry Fire (Lửa Đói): over-time damage ×2 · Cutting Heat (Nhiệt Xuyên): fire penetration +1, fire +1
- **Effects:**
  - **Major: Wildfire (Liệu Nguyên).** At each pulse, each of your Burn batches that expired that pulse on a target is reapplied at half its stacks for its original duration. A reapplied batch never reapplies again.
  - Minor: Catch (Bén Lửa). Your Fire hits apply 1 extra Burn stack per 10 stacks already on the target (cap +5; batches of 6 pulses).
  - Minor: Kindling (Mồi Lửa). Your first Fire art each fight applies double Burn. *(starter)*

### 2. Dung Nham (Lava) †
- **Small:** `attack_pct` fire +1 · `attack_pct` physical +1
- **Stat notables:** Molten Rock (Đá Chảy): fire +1, physical +1 ×2 · Magma Core (Lõi Dung Nham): physical ×2 ·
  Basalt Skin (Da Bazan): block +1, fire +1 · Pyroclast (Hỏa Thạch): physical crit damage +2
- **Effects:**
  - **Major: Molten Strike (Dung Kích).** Your Physical hits convert 40 % to Fire and apply Burn equal to 1 stack
    per 2 % of the hit's damage as a share of the target's max health. `Fits today` (conversion + apply).
  - Minor: Slag (Xỉ Nóng). Your hits on a target bearing 20+ of your Burn stacks ignore 15 of its block per 10 stacks.
  - Minor: Earth Heat (Địa Nhiệt). With an Earth root ≥ 30, your Earth buff stacks also grant +0.6 % Fire damage
    each.

### 3. Đan Hỏa (Pill Fire) †
- **Small:** `pill_effect_pct` +1 · `alchemy_success` (theme curve) +1
- **Stat notables:** Furnace Hand (Tay Lò): alchemy ×2 · True Fire Pill (Chân Hỏa Đan): pill effect ×2 · Heat
  Tolerance (Chịu Nhiệt): dan độc resist ×2 · Banked Coals (Than Ủ): pill effect +1, fire +1
- **Effects:**
  - **Major: Swallow the Furnace (Nuốt Lò).** Pills you take before a fight also grant Fire buff stacks for the
    fight: 10 per pill (at most 3 pills).
  - Minor: Clean Burn (Đốt Sạch). Your pill toxicity gained from fight pills is 30 % lower. *(starter)*
  - Minor: Fever Pill (Đan Sốt). While your pill toxicity is above half its limit, your Fire hits deal more
    (L5 +15). `Needs key`: toxicity readable in the fight.

### 4. Tro Tàn (Ash)
- **Small:** `attack_pct` burn +1.5 · `attack_pct` fire +1
- **Stat notables:** Grey Ash (Tro Xám): burn damage ×2 · Cinder Drift (Tàn Bay): fire +2 · Banked Ember (Than
  Hồng): fire stack duration +2, burn +1 · Ash Field (Đồng Tro): fire penetration ×2
- **Effects:**
  - **Major: Harvest the Ash (Thu Tro).** Every 8 s your next Fire hit consumes up to 40 Burn stacks on the
    target and deals more (L5 +1.5 per stack consumed, so up to +60).
  - Minor: Smouldering (Âm Ỉ). Burn stacks consumed by your Effects leave 25 % of themselves behind.
  - Minor: Choking Smoke (Khói Ngạt). A target bearing 30+ Burn stacks has −1.2 pp accuracy per 10 stacks.

### 5. Niết Bàn (the Phoenix Rises)
- **Small:** `khi_huyet_pct` +1 · `stack_effect_pct` fire +1
- **Stat notables:** Phoenix Feather (Lông Phượng): max health ×2 · Red Down (Lông Đỏ): fire +1, max health +1 ·
  Warm Blood (Máu Ấm): health regen +0.1 · Rising Heat (Nhiệt Dâng): fire stack effect +1, fire +1
- **Effects:**
  - **Major: Rise from the Ashes (Dục Hỏa Trùng Sinh).** Once a fight, at the Down step's refusal, refuse it (health 1, Effects rule 11); then heal 30 % of max health (a heal; `no_heal` blocks it) and gain Fire buff stacks for the fight equal to the Burn on the foe (cap 50).
  - Minor: Burn Bright (Cháy Rực). While below 35 % health, your Fire buff stacks are 100 % stronger.
  - Minor: Embers in the Chest (Than Trong Ngực). When you fall below 50 % health, gain 15 Fire buff stacks for
    10 pulses (once per fight). *(starter)*

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Furnace Never Cools (Lò Bất Lãnh)** | keystone | Your Fire buff batches do not expire while you have fired a Fire art in the last 3 s | Your Fire arts cost 25 % more | Chân Hỏa |
| **Burning Heaven (Phần Thiên)** | keystone | Burn ticks you deal also count as Fire hits for "on hit" Effects (at most 1 per pulse per target) | Your direct Fire hits deal 30 % less (L2 −30) | Tro Tàn |
| **Lava Body (Dung Thân)** | enabler | Your basic attack becomes a Fire-and-Physical hit that applies 3 Burn stacks for 6 pulses | You cannot slot a Water or Ice art or a ward with a Cold payload | Dung Nham |
| **Nine Furnaces (Cửu Lô)** | keystone | Up to 3 combat pills may be carried into any fight and fire at a guard you set, taking no art slot (`Needs rule`: R4, pills in fights) | Fight pills give 50 % more toxicity | Đan Hỏa |
| **Nirvana (Niết Bàn)** | keystone | Rise from the Ashes may fire twice per fight, the second healing 15 % (`Needs rule`: R5, a second refusal) | Your max health is 20 % lower | Niết Bàn |

## New pieces

- Burn ticks counting as hits for "on hit" (Burning Heaven): `Needs rule` (Combat rule 9 events).
- Fight-time readable for pill toxicity: `Needs key`.

## Kept apart from

Thái Dương (the sun: Fire on Light, timing); Đan Đạo (pills as a craft). Hỏa Đạo is **Burn and the Fire buff**.
