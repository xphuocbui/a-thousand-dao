# 22 · Băng Đạo · *Băng Tâm* (Ice Heart)

> Overnight draft 2026-11-11. Proposal. **Needs:** Ice (variant) ≥ 30.
> **Theme stats:** `attack_pct` (cold), `stack_effect_pct` (ice), `stack_duration_pct` (ice), `resist_pen_pct`
> (cold), `defense_pct`, `ward_efficiency_pct`, `body_shield_pct`, `resist_pct` (cold), `tam_ma_resist_pct`,
> `status_duration_pct` (curse).
> **Road:** `stack_effect_pct` ice +1.5.

## Build directions

1. **The Cost Lock.** Ice debuff stacks raise the foe's art costs with no cap; pile them and the foe stops casting,
   then its ward starves. The art-heavy foe's nightmare, useless against a bare-fist build.
2. **The Glacier.** Layered wards of ice: every ward you slot adds a shield and the shields refresh from your
   Ice stacks on the foe (Băng Xuyên). A ward tank that wins by cost attrition.
3. **Frozen Clock.** Timer control: Ice stacks past a threshold slow the foe's art timers (Đông Kết).
4. **Cold Shatter.** Pile, then consume stacks for burst (the Sword Way's Shatter has a cousin here that works on
   any Cold art).

## Facets

### 1. Sương Giá (Frost)
- **Small:** `attack_pct` cold +1.5 · `resist_pen_pct` cold +0.6
- **Stat notables:** Hoarfrost (Sương Muối): cold ×2 · Biting Cold (Rét Cắt): cold penetration ×2 · Frost Flower
  (Hoa Băng): cold +1, ice stack effect +1 · Black Ice (Băng Đen): cold crit damage +2
- **Effects:**
  - **Major: Shatter (Băng Toái).** (Consumes stacks: R19.) Every 6 s, your next Cold hit on a target bearing 25+ Ice stacks consumes 15
    and deals more (L5 +3 per stack consumed, +45).
  - Minor: Frostbite (Đống Thương). Your Cold hits apply 1 Ice stack per 2 % of the target's max health they deal for 6 pulses
    (cap 5). *(starter)*
  - Minor: Brittle (Giòn). A target bearing 15+ Ice stacks takes more Physical damage (L5 +10 to your Physical
    hits on it).

### 2. Băng Thể (Ice Body)
- **Small:** `body_shield_pct` +1 · `resist_pct` cold +1.5
- **Stat notables:** Ice Skin (Da Băng): body shield ×2 · Winter Blood (Huyết Đông): cold resistance ×2 · Glass
  Bones (Cốt Pha Lê): body shield +1, max health +1 · Numb (Tê): status resist +2
- **Effects:**
  - **Major: Ice Armour (Băng Giáp).** At each pulse, your body shield regains 0.1 % of your max health per Ice
    stack on the foe (cap 3 % a pulse).
  - Minor: Cold Retort (Hàn Phản). When a hit breaks your body shield, apply 6 Ice stacks to the attacker for 8
    pulses.
  - Minor: Chilled Blood (Huyết Lạnh). Burn on you is 25 % weaker. *(starter)*

### 3. Đông Kết (Freezing)
- **Small:** `stack_duration_pct` ice +2 · `stack_effect_pct` ice +1
- **Stat notables:** Deep Freeze (Đóng Băng Sâu): ice duration ×2 · Ice Lock (Khóa Băng): ice stack effect ×2 ·
  Slow Thaw (Tan Chậm): ice duration +1, cold +1 · Rime (Băng Sương): ice effect +1, defense +1
- **Effects:**
  - **Major: Frozen Clock (Đông Kết).** Each pulse a target bears 30+ Ice stacks, its next art timer is delayed 0.4 s
    (0.8 s at 60+). A bounded delay: repeats on the same target within 3 s move half the seconds of the one before, and its `timer_resist_pct` shortens each (`delay_timer`, Effects rule 6, R1). Slowed Time stays Thời's curse.
  - Minor: Lingering Chill (Hàn Lưu). Your Ice batches applied to a target already bearing 20+ last 2 pulses longer. *(starter)*
  - Minor: Frozen Breath (Tức Đông). Each pulse in which the foe's linh lực is below its cheapest ready art's cost, apply 5 Ice stacks for 8 pulses.

### 4. Băng Xuyên (Glacier)
- **Small:** `defense_pct` +1.2 · `ward_efficiency_pct` +1.2
- **Stat notables:** Ice Shelf (Thềm Băng): ward efficiency ×2 · Layered Ice (Băng Tầng): defense ×2 · Crevasse
  (Khe Băng): defense +1, cold resist +1 · Ancient Ice (Băng Cổ): ward efficiency +1, ice effect +1
- **Effects:**
  - **Major: Glacier (Băng Xuyên).** Each ward you have slotted gains a shield equal to 2 % of max linh lực,
    restored every 6 s; while the foe has 20+ Ice stacks, it restores every 3 s.
  - Minor: Cold Bill (Hàn Phí). When a foe's hit deals no damage to your health (all stopped by your wards), apply 2 Ice stacks to it for 6 pulses (event: a hit fully stopped by wards, Effects rule 5, R20).
  - Minor: Slow Melt (Tan Chậm Rãi). Your cast wards last 25 % longer.

### 5. Tuyết Rơi (Snowfall)
- **Small:** `tam_ma_resist_pct` +1 · `escape_pct` +1
- **Stat notables:** Quiet Snow (Tuyết Lặng): heart-demon resist ×2 · White-Out (Trắng Xóa): escape ×2 · Calm
  Heart (Tâm Lặng): heart-demon resist +1, status resist +1 · Snow Cover (Tuyết Phủ): evade +1, escape +1
- **Effects:**
  - **Major: Ice Heart (Băng Tâm).** You are immune to Silence and Sealed Meridian, and heart demon gained from fights is halved. Your Cold hits on a foe who has hit you crit with +10 pp chance.
  - Minor: White Silence (Tuyết Câm). Your first hit each fight applies 10 Ice stacks for 8 pulses. *(starter)*
  - Minor: Footprints Filled (Dấu Chân Lấp). Your escape art cannot be pursued: the pursuer's tags do not lower its
    chance.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The World Stops (Thiên Địa Đóng Băng)** | keystone | At 80+ Ice stacks on a target, all its art timers are delayed 2 s (once per 15 s, so no falloff applies; its `timer_resist_pct` shortens it; `delay_timer`, Effects rule 6, R1) | Your arts deal 30 % less hit damage (L2 −30) | Đông Kết |
| **Heart of Ice (Hàn Tâm)** | keystone | Your Ice batches never expire while the target is below 50 % linh lực | You gain no Water buff stacks | Sương Giá |
| **Eternal Glacier (Vĩnh Băng)** | keystone | Your ward shields do not break: past 0 they keep stopping 25 % of what they stopped, until the ward is replaced | Your linh lực regeneration is 0 | Băng Xuyên |
| **Absolute Zero (Tuyệt Đối Linh Độ)** | enabler | Your Ice stacks on a foe also raise the drain bills its wards pay against your hits and ticks, by the same share they add to its art costs (3.9 % per stack × your Ice stack power × stack effect); a bill never passes the foe's live pool. The slow clock (dearer arts) becomes a fast one (a dearer ward). Merged with the build *dry-well*'s Cold Toll (user decision 2026-11-11) | Your Ice stacks' art-cost raise on that foe is halved | Đông Kết, Băng Xuyên |

## New pieces

- Frozen Clock, The World Stops: `delay_timer` with falloff and `timer_resist_pct` (Effects rule 6, R1).
- Absolute Zero: drain bills only, the named exception to "Ice never touches ward payments" (Combat Defence & Healing Edge Cases; Effects rule 9a Ice row; user decision 2026-11-11). Reserved and per-hit wards are its counter.
- Eternal Glacier: `Needs rule` (Combat Defence shields).

## Kept apart from

Vụ (Mist's cold debuff is accuracy-flavoured); Thái Âm (moonlight: Cold on Light); Thủy (Water's buff side). Băng
Đạo is **the cost lock, the frozen clock and the glacier ward**.
