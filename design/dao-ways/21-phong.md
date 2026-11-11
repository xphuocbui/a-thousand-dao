# 21 · Phong Đạo · *Thanh Phong* (Clear Breeze: Wind)

> Overnight draft 2026-11-11. Proposal. **Needs:** Wind (variant) ≥ 30.
> **Theme stats:** `art_speed_pct`, `evade_pct`, `stack_effect_pct` (wind), `stack_duration_pct` (wind),
> `attack_pct` (physical, wind), `art_cost_pct`, `escape_pct`, `travel_speed_pct`, `crit_chance_pct` (wind).
> **Road:** `art_speed_pct` +0.5.

## Build directions

1. **Past the Floor.** Wind buff stacks push arts to `cooldown_min` fast; the clipped speed is the waste every
   speed build has. Over the Limit turns it into damage. Stack: Wind stacks, art speed, cheap arts.
2. **The Drifting Leaf.** Evade to the cap and make every evade pay (Phiêu): Wind buff stacks and linh lực from
   misses. Ticks and soul are its enemy.
3. **A Thousand Cuts.** Many cheap Physical wind blades, each applying Wind debuff (−evade) and Bleed; a per-hit
   build that feeds on hit count.
4. **The Tempest.** Wind and Thunder together: art speed into crits (with Lôi Đạo or a Thunder root).
5. **The Wanderer.** Travel, escape and fights won by not being there: an NPC survival archetype.

## Facets

### 1. Cuồng Phong (Gale)
- **Small:** `art_speed_pct` +0.5 · `stack_effect_pct` wind +1
- **Stat notables:** Howling (Gào Thét): art speed ×2 · Tailwind (Gió Xuôi): wind stack effect ×2 · Gust (Cơn
  Gió): art speed +1, art cost −1 · Whirlwind (Lốc): wind duration +2, art speed +0.5
- **Effects:**
  - **Major: Over the Limit (Quá Hạn).** Art speed your arts lose to `cooldown_min` becomes damage: L5 +1 per 10 %
    of art speed clipped (cap +40), on that art's hits.
  - Minor: Quickening (Tăng Tốc). Each art you fire grants 1 Wind buff stack for 4 pulses. *(starter)*
  - Minor: Second Wind (Hồi Phong). When your linh lực falls below 25 %, lose half your Wind buff stacks and
    restore 0.5 % of max linh lực per stack lost.

### 2. Phiêu (Drift)
- **Small:** `evade_pct` +0.4 · `stack_duration_pct` wind +2
- **Stat notables:** Thistledown (Bông Lau): evade ×2 · Feather Step (Bước Lông): evade +1, escape +1 · Updraft
  (Gió Nâng): evade +1, art speed +0.5 · Cloud Walk (Bước Mây): wind duration ×2
- **Effects:**
  - **Major: Leaf in the Wind (Diệp Tùy Phong).** Each hit you evade grants 2 Wind buff stacks for 6 pulses and
    restores 0.4 % of max linh lực.
  - Minor: Slip (Trượt). After you evade, your next hit cannot be evaded. *Shared minor* (with Huyễn, Hư Thực).
  - Minor: Light Body (Thân Nhẹ). +1 pp evade per 10 Wind buff stacks (cap +6, inside `evade_cap`). *(starter)*

### 3. Phong Nhận (Wind Blades)
- **Small:** `attack_pct` physical +1 · `attack_pct` wind +1
- **Stat notables:** Thin Blade (Lưỡi Mỏng): physical ×2 · Razor Wind (Gió Cắt): wind ×2 · Thousand Edges (Thiên
  Nhận): wind +1, crit chance (wind) +0.5 · Keening (Rít): physical crit damage +2
- **Effects:**
  - **Major: A Thousand Cuts (Thiên Đao Vạn Quả).** Your quick-tagged Wind arts apply 1 Bleed stack and 1 Wind
    debuff stack for 4 pulses per hit; Bleed from them may stack to 8 instead of 5.
  - Minor: Wind Shear (Phong Tiễn). Your Physical hits deal more to a foe that has evaded you this fight (L5 +12).
  - Minor: Cutting Air (Không Khí Cắt). Your basic attack applies 1 Wind debuff stack for 4 pulses. *(starter)*

### 4. Bão Táp (Tempest, with Thunder)
- **Small:** `crit_chance_pct` wind +0.8 · `art_speed_pct` +0.5
- **Stat notables:** Squall (Giông): crit chance (wind) ×2 · Black Wind (Hắc Phong): art speed +1, crit damage +1 ·
  Pressure Drop (Hạ Áp): wind stack effect +2 · Storm Wall (Tường Bão): evade +1, crit chance +1
- **Effects:**
  - **Major: Speed Is Lightning (Tốc Tức Lôi).** Each Wind buff stack you hold also counts as 0.5 Thunder buff
    stacks (crit chance and accuracy).
  - Minor: Downburst (Gió Giật Xuống). When your art crits, gain 2 Wind buff stacks for 4 pulses.
  - Minor: Eye of Calm (Mắt Lặng). While you hold 30+ Wind buff stacks, 15 % of your evade also applies to ticks.
    `Needs rule` (ticks never meet evade).

### 5. Lãng Du (the Wanderer)
- **Small:** `travel_speed_pct` +2 · `escape_pct` +1
- **Stat notables:** Long Road (Đường Xa): travel ×2 · Gone with the Wind (Cuốn Theo Gió): escape ×2 · Footloose
  (Chân Rảnh): escape +1, evade +1 · Road Dust (Bụi Đường): travel +1, art speed +0.5
- **Effects:**
  - **Major: Never in One Place (Vô Định Xứ).** Your escape art has no channel time and fires at its guard
    instantly; if it fails, its cooldown is halved.
  - Minor: Wind at the Back (Gió Sau Lưng). Fights you start by fleeing do not count as defeats for heart demon.
  - Minor: Weather Sense (Biết Trời). Travel events with storms give you an extra choice. `Needs key` (Event
    Engine).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Never in One Place (Lưu Phong)** | keystone | Your evade cap is 10 pp higher (a cap shift, `Needs rule`; R14) | Your max health is 30 % lower | Phiêu |
| **The Wind Has No Floor (Phong Vô Để)** | keystone | Your `cooldown_min` is 20 % lower (a cap shift, `Needs rule`; R14). Rival of Over the Limit: the two cannot both be held | Your arts cost 40 % more | Cuồng Phong |
| **Ten Thousand Blades (Vạn Nhận)** | keystone | Your quick arts hit twice at 50 % each (one firing for lockouts and trigger limits; `Needs rule`: hit splitting) | Your slow arts cannot be slotted | Phong Nhận |
| **Clear Breeze (Thanh Phong)** | keystone | Your Wind buff stacks never expire while you have evaded in the last 4 s | You cannot slot a ward with a block payload | Phiêu, Bão Táp |

## New pieces

- Clipped art speed as a readable (Over the Limit): the clip is already a trigger event (Combat rule 9); `Needs
  key` for the amount.
- Evade against ticks: `Needs rule`.
- Escape with no channel: `Needs rule` (escape_channel).

## Kept apart from

Lôi's Phong Bạo (debuffs from both stacks; here Wind feeds crit). Vũ Đạo (Dance: rhythm). Tiêu Dao (travel as a
life). Phong Đạo is **speed past the floor and the evade that pays**.
