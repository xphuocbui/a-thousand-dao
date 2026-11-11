# 27 · Sinh Tử Đạo · *Sinh Diệt* (Arising and Passing)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. Holds the seeds Life and Death (†).
> **Theme stats:** `healing_pct`, `health_regen_pct`, `khi_huyet_pct`, `attack_pct` (chaos, over_time),
> `status_duration_pct` (curse), `lifespan_pct`, `leech_health_pct`, `healing_taken_pct`.
> **Road:** `healing_pct` +1.5.

## Build directions

1. **The Anti-Healer.** In a sustain-is-king game, the Way that turns healing against its owner: Withering past
   its floor makes the foe's heals hurt it (capstone). The sustain meta's hard counter.
2. **Overflow Life.** Healing past full health becomes damage (Sinh): a healer that kills by healing.
3. **The Threshold Walker.** Live at the Down step: refuse it, act from it, and get stronger each time you cross
   it (Ranh Giới).
4. **Corpse Qi.** Corpse Rot as a standing engine with drain riders (Thi Khí): one permanent tick paid in linh
   lực, made the build's core.
5. **Longevity.** Lifespan as the resource of a life-long build: more years, more seasons, more breakthroughs.

## Facets

### 1. Sinh (Life) †
- **Small:** `healing_pct` +1.5 · `health_regen_pct` +0.05
- **Stat notables:** Spring of Life (Suối Sống): healing ×2 · Green Pulse (Mạch Xanh): regen ×2 · Full Vessel
  (Bình Đầy): max health +1, healing +1 · Quickening (Hồi Xuân): regen increased +4
- **Effects:**
  - **Major: Life Overflowing (Sinh Sinh Bất Tức).** Healing you receive past full health is dealt to the foe as
    Light damage (a trigger, inside `trig_budget`), at 60 % of the overflow.
  - Minor: Living Water (Nước Sống). Your heals over 5 % of max health also restore 2 % of max linh lực. *(starter)*
  - Minor: Vigour (Sinh Lực). +10 % healing while above 80 % health.

### 2. Diệt (Death) †
- **Small:** `status_duration_pct` curse +2 · `attack_pct` chaos +1
- **Stat notables:** Grave Cold (Lạnh Mộ): curse duration ×2 · Death Touch (Chạm Chết): chaos ×2 · Mourning (Tang):
  curse duration +1, chaos +1 · Dust to Dust (Cát Bụi): chaos penetration +2
- **Effects:**
  - **Major: Withering Hand (Khô Thủ).** Your Chaos hits apply Withering. Each pulse, a Withered foe that healed this pulse gains 3 Poison stacks for 6 pulses (`Needs rule` R20: "a heal lands" as an event).
  - Minor: Death's Patience (Tử Nhẫn). Withering you apply lasts 2 pulses longer. *(starter)*
  - Minor: Last Breath (Tàn Hơi). A Withered foe below 30 % health has its regeneration dampened by 100 (halved; Modifier System rule 6a).

### 3. Ranh Giới (the Threshold)
- **Small:** `khi_huyet_pct` +1 · `healing_taken_pct` +1
- **Stat notables:** Edge of Life (Bờ Sinh): max health ×2 · Second Chance (Cơ Hội Hai): healing taken ×2 · Thin
  Line (Lằn Ranh): max health +1, regen +0.05 · Death's Door (Cửa Tử): crit damage +2
- **Effects:**
  - **Major: Walk the Threshold (Hành Ranh).** Once per fight, at the Down step's refusal, refuse it (health 1, Effects rule 11) and drop every hit that lands on you for 1 s (`Needs rule` R6; ticks still land). Each threshold crossed is reported to the caller as a life result: +1 % max health for life, cap +10 % (applied outside the fight, `Needs key`).
  - Minor: Last Act (Tối Hậu Chiêu). At the Down step's last act, your next ready art fires at once and deals more
    (L5 +40). *(starter)*
  - Minor: Near Death (Cận Tử). While below 20 % health, healing you receive is 50 % stronger.

### 4. Thi Khí (Corpse Qi)
- **Small:** `attack_pct` over_time +1.5 · `leech_health_pct` +0.3
- **Stat notables:** Grave Mist (Sương Mộ): over-time ×2 · Rot Drinker (Uống Thối): leech ×2 · Corpse Candle (Đèn
  Xác): chaos +1, over-time +1 · Cold Meat (Thịt Lạnh): max linh lực +2
- **Effects:**
  - **Major: Corpse Qi (Thi Khí).** You can apply Corpse Rot: your Chaos crits apply it (its standing fee is 1 %, not 2 %). At each pulse, heal 50 % of the health Corpse Rot removed that pulse.
  - Minor: Rot Spreads (Thối Lan). While your Corpse Rot is on the foe, your Chaos hits apply 2 Poison stacks for 4 pulses. *(starter)*
  - Minor: Grave Wind (Gió Mộ). Corpse Rot you apply also applies Stagnation (5 stacks) every 3 pulses.

### 5. Trường Sinh (Longevity)
- **Small:** `lifespan_pct` +1 · `health_regen_pct` +0.05
- **Stat notables:** Long Years (Năm Dài): lifespan ×2 · Crane's Age (Tuổi Hạc): lifespan +1, regen +0.05 · Old
  Pine (Thông Già): max health +2 · Slow Heart (Tim Chậm): regen ×2
- **Effects:**
  - **Major: Undying Spring (Trường Xuân).** Your health regeneration is increased by 2 % for every 10 years of lifespan you have left (cap +30 %).
  - Minor: Bank the Years (Gửi Năm). Lifespan costs from Effects (Burning Lifespan and others) are 30 % lower.
    *(starter)*
  - Minor: Ageless (Bất Lão). Your stats do not fall in old age until the last 10 % of your lifespan. `Needs key`
    (Character Stats ageing).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Crossing the Line Both Ways (Sinh Tử Lưỡng Giới)** | keystone | While the foe is Withered by you, healing it receives is dealt to it as Chaos damage instead | You cannot be healed by any source but regeneration | Diệt |
| **The Living Wound (Sinh Thương)** | keystone | Life Overflowing deals 100 % of the overflow (still a trigger inside `trig_budget`) | Your direct hits deal 40 % less (L2 −40) | Sinh |
| **Thrice-Crossed (Tam Quá Quỷ Môn)** | keystone | Walk the Threshold may refuse twice per fight (`Needs rule` R5) | Your max health is 35 % lower | Ranh Giới |
| **Corpse Lord (Thi Vương)** | enabler | You may hold 2 Corpse Rots on a target, each with its own fee (`Needs rule`: Corpse Rot has no stacking) | You cannot apply Poison by hits | Thi Khí |
| **Ten Thousand Years (Vạn Thọ)** | keystone | Undying Spring counts every 5 years (cap +50 %) | Every breakthrough you attempt costs 2 % more lifespan, success or not | Trường Sinh |

## New pieces

- Healing turned to damage (Crossing the Line): `Needs rule` (Combat Defence healing).
- Untouchable for 1 s: `Needs rule` (shared with Ám's Step into Shadow).
- A life-long "thresholds crossed" counter: `Needs key`.

## Kept apart from

Luân Hồi (rebirth after a Down: forms and past lives), Hoàng Tuyền (last acts and the dead), Bỉ Ngạn (bursts on a
Down), Quỷ Đạo (ghost servants). Sinh Tử is **healing as a weapon both ways, and the Down step as a door**.
