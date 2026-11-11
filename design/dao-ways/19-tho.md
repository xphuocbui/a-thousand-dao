# 19 · Thổ Đạo · *Bất Động Sơn* (Unmoving Mountain: Earth)

> Overnight draft 2026-11-11. Proposal. **Needs:** Earth ≥ 30. Holds the seed Gravity (†).
> **Theme stats:** `block_rating`, `body_shield_pct`, `khi_huyet_pct`, `resist_pct` (physical), `stack_effect_pct`
> (earth), `stack_duration_pct` (earth), `attack_pct` (force, earth, physical), `defense_pct`, `evade_pct` (negative
> on gravity nodes only), `health_regen_pct`.
> **Road:** `block_rating` +1.

## Build directions

1. **The Mountain.** Earth buff stacks dampen Physical taken without a cap; pile them and Physical builds stop
   mattering. Pair with a Chaos or Soul answer, since Earth does nothing there. The anti-sword build.
2. **The Weight.** Gravity: your Force hits scale with your max health (Thiên Quân), so a tank's health is its
   damage. The thể tu who hits with its mass.
3. **The Quake.** Delay the foe's timers with each heavy hit (Địa Chấn): a control build that wins by making the
   enemy act less.
4. **The Rooted.** Stronger every second you have not been moved: Deep Roots rewards a build with no escape and no
   evade, and punishes a foe that wins by tempo.

## Facets

### 1. Trọng Lực (Gravity) †
- **Small:** `attack_pct` force +1.5 · `khi_huyet_pct` +0.5
- **Stat notables:** Heavy Hand (Thủ Trọng): force ×2 · Dense Body (Thân Đặc): max health ×2 · Pull of the Earth
  (Địa Dẫn): force +1, max health +1 · Leaden (Chì): force +2, evade −1 (a price on a stat node)
- **Effects:**
  - **Major: A Thousand Catties (Thiên Quân).** Your Force hits gain flat damage equal to 1.5 % of your maximum
    health (before layers).
  - Minor: Heavy Air (Khí Nặng). Your Force hits apply Weighed (Gravity Well's curse) at 1 stack for 2 pulses.
  - Minor: Falling Weight (Trọng Rơi). Your slow-tagged arts deal more (L5 +12). *Shared minor* (with Chưởng, Ấn).

### 2. Sơn Thể (Mountain Body)
- **Small:** `block_rating` +1 · `body_shield_pct` +1
- **Stat notables:** Cliff Face (Vách Đá): block ×2 · Granite (Đá Hoa Cương): body shield ×2 · Bedrock (Đá Gốc):
  physical resistance +2, block +1 · Ridge Back (Lưng Núi): max health +1, block +1
- **Effects:**
  - **Major: Unmoving Mountain (Sơn Bất Động).** Your block also applies to ticks (Bleed, Burn) at half its value.
    `Needs rule` (ticks never meet block, Combat rule 7).
  - Minor: Stone Skin (Thạch Bì). Each Earth buff stack also gives +0.5 block rating (cap +40). *(starter)*
  - Minor: Landslide Guard (Hộ Sạt). When your body shield breaks, gain 10 Earth buff stacks for 6 pulses.

### 3. Địa Chấn (Earthquake)
- **Small:** `attack_pct` earth +2 · `attack_pct` force +1
- **Stat notables:** Fault Line (Đứt Gãy): earth ×2 · Aftershock (Dư Chấn): force +1, earth +1 · Tremor (Rung):
  earth stack effect +2 · Split Ground (Nứt Đất): earth penetration +2
- **Effects:**
  - **Major: Earthquake (Địa Chấn).** When your hit deals more than 8 % of the target's max health, every art
    timer of the target is pushed back 0.6 s (once per 2 s).
  - Minor: Shaken (Lảo Đảo). Your hits on a target bearing 15+ of your Earth debuff stacks cannot be evaded.
  - Minor: Tremor Step (Bước Chấn). Your basic attack applies 2 Earth debuff stacks for 6 pulses. *(starter)*

### 4. Trần Bích (Dust Wall)
- **Small:** `stack_effect_pct` earth +1.5 · `stack_duration_pct` earth +2
- **Stat notables:** Thick Dust (Bụi Dày): earth stack effect ×2 · Long Wall (Tường Dài): earth duration ×2 ·
  Choking Cloud (Mây Bụi): earth effect +1, physical resistance +1 · Packed Earth (Đất Nện): defense +2
- **Effects:**
  - **Major: The Wall Remembers (Tường Nhớ).** When a Physical hit lands on you, gain Earth buff stacks equal to
    1 per 2 % of your max health it took (cap 8 per hit).
  - Minor: Grit (Sạn). While the foe has 20+ of your Earth debuff stacks, crit damage you take is dampened 25 % (rule 6a).
  - Minor: Settled (Lắng). Earth buff batches granted while you hold 20+ last 2 pulses longer. *(starter)*

### 5. Bàn Căn (Deep Roots)
- **Small:** `health_regen_pct` +0.05 · `defense_pct` +1.2
- **Stat notables:** Deep Footing (Chân Vững): defense ×2 · Old Stone (Đá Cổ): regen ×2 · Root in Rock (Rễ
  Đá): block +1, regen +0.05 · Patience of Hills (Đồi Nhẫn): max health +1, defense +1
- **Effects:**
  - **Major: Deep Roots (Bàn Căn).** A streak: for each full 5 s since you last escaped or evaded (resets to 0 on either), your hits deal more (L5 +5, cap +40).
  - Minor: Stand Fast (Đứng Vững). Effects that would push back your timers do half. *(starter)*
  - Minor: Grounded (Tiếp Địa). Your Lightning resistance +20 points while you hold 10+ Earth buff stacks.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Immovable (Bất Động)** | keystone | Your Earth buff stacks never expire during a fight; Earth's dampening of Physical damage you take is capped at 60 % | You cannot slot a ward in a free ward slot | Bàn Căn |
| **Mountain Falls (Sơn Băng)** | keystone | Once every 15 s, your next art hit converts all Physical to Force (one conversion) and deals more by your Earth buff stacks (L5 +1 each, cap +60), consuming them (R19) | Your art speed is −30 % | Trọng Lực |
| **The Earth Bears All (Hậu Đức Tải Vật)** | keystone | 20 % of the damage your block stops is dealt back to the attacker as Force (a trigger hit, inside `trig_budget`) | Your hits deal 20 % less (L2 −20) | Sơn Thể |
| **Gravity Well (Trọng Trường)** | enabler | Your Force hits apply a new curse, Weighed (Áp Trọng): −15 % art speed, 3 pulses, refresh | Your block rating is halved | Trọng Lực |

## New pieces

- Block applying to ticks: `Needs rule` (Combat rule 7).
- Weighed (Áp Trọng), an art-speed curse: `Needs key` (new curse in the Status Catalogue).
- Timer pushback from a hit (Earthquake): `Needs rule` (no Effect action pushes foe timers today; shared with
  Thời Đạo's Ngưng and Băng's Đông Kết).

## Kept apart from

Thể Đạo (the body as flesh), Cốt Đạo (bone), Kim's Thối Thể (block from gear and Metal). Thổ Đạo is **Earth stacks,
weight and time held still**.
