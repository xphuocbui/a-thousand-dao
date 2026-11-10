# 15 · Kim Đạo · *Bách Luyện* (Hundred Temperings: Metal)

> Overnight draft 2026-11-11. Proposal. **Needs:** Metal ≥ 30 purity.
> **Theme stats:** `attack_pct` (physical, metal), `crit_damage_pct` (physical), `resist_pen_pct` (physical),
> `artifact_attack_pct`, `artifact_power_pct`, `than_thuc_cost_pct`, `block_rating`, `body_shield_pct`,
> `stack_effect_pct` (metal), `stack_duration_pct` (metal).
> **Road:** `attack_pct` metal +2.

## Build directions

1. **The Shredder.** Pile the Metal debuff (+1.8 % Physical taken per stack) on the foe, then cash it in with one
   Physical blow (Kim Minh). Stack: Metal stack effect, stack duration, crit damage, penetration.
2. **The Armoury.** Carry as many artifacts as thần thức allows; long-cooldown artifact actives stop costing art
   slots (Bách Binh Ứng); L3 is the build's big layer. Stack: artifact attack, thần thức cost down, artifact power.
3. **The Anvil.** A Metal thể tu: block turns every blow taken into Metal buff stacks, so the build hits harder the
   longer it is beaten on. Stack: block rating, body shield, Metal stack duration.
4. **The Pure Edge.** Every part made Physical (Độc Phong), so a dual-root caster's Fire or Lightning arts ride
   the Metal stacks and the Physical penetration.

## Facets

### 1. Tinh Kim (Refined Metal)
- **Small:** `attack_pct` physical +1.2 · `resist_pen_pct` physical +0.6
- **Stat notables:** Refined Steel (Tinh Cương): physical +2 attack ×2 · Hairline Edge (Phong Như Phát): physical
  crit damage +2 · No Flaw (Vô Hà): physical penetration +1, physical attack +1 · Bright Grain (Văn Sáng): metal attack +2
- **Effects:**
  - **Major: Hundredfold Refined (Bách Luyện Tinh).** Each Metal buff stack you hold gives your Physical hits
    1 point of Physical resistance penetration (no cap of its own).
  - Minor: Purge the Dross (Khử Tạp). Hits whose parts are all Physical, with nothing converted, deal more
    (L5 +12). *(starter)*
  - Minor: Tempered Again (Tái Luyện). When a crit lands on you, gain 2 Metal buff stacks for 6 pulses.

### 2. Thối Thể (Tempered Body)
- **Small:** `block_rating` +1 · `body_shield_pct` +1
- **Stat notables:** Iron Hide (Thiết Bì): block ×2 · Plated Ribs (Giáp Cốt): body shield +1, block +1 · Hammered
  Flat (Chùy Bình): body shield ×2 · Cold-Forged (Lãnh Rèn): block +1.2, physical attack +0.8
- **Effects:**
  - **Major: Anvil Body (Châm Thể).** Each hit your block reduces grants you 1 Metal buff stack for 10 pulses.
  - Minor: Iron Shirt (Thiết Sam). While no ward shield of yours is up, your body shield is 25 % stronger.
    *(starter)*
  - Minor: Ring of the Hammer (Chùy Hưởng). When your body shield breaks, your next Physical hit deals more
    (L5 +25).

### 3. Lò Rèn (the Forge)
- **Small:** `artifact_power_pct` +0.9 · `artifact_attack_pct` +0.75
- **Stat notables:** Bellows (Bễ Lò): artifact power ×2 · Hot Iron (Sắt Nung): artifact attack +1.5, physical +0.5 ·
  Master's Mark (Ấn Thợ): artifact power +1, artifact attack +1 · Slag Out (Lọc Xỉ): artifact attack ×2
- **Effects:**
  - **Major: Living Forge (Hoạt Lô).** Each time your weapon artifact's active effect fires, that weapon gains
    +2 % artifact attack for the fight (cap +40 %). `Needs rule`: L3 moving mid-fight.
  - Minor: Quench (Tôi). The first artifact active you fire each fight costs no linh lực. *(starter)*
  - Minor: Spirit in the Steel (Khí Linh). +1 % artifact power for each 5 % of your thần thức left unused by
    artifacts (cap +15 %).

### 4. Binh Khố (the Armoury)
- **Small:** `than_thuc_cost_pct` −0.8 · `artifact_attack_pct` +0.75
- **Stat notables:** Wide Racks (Giá Rộng): thần thức cost −2 ×2 · Polished Rows (Hàng Bóng): artifact attack ×2 ·
  Quartermaster (Quản Khố): thần thức cost −1, artifact power +1 · Spare Blade (Kiếm Dự): artifact attack +1, block +1
- **Effects:**
  - **Major: Hundred Weapons Answer (Bách Binh Ứng).** Up to two of your artifact actives with an authored
    cooldown of 10 s or more take no art slot. `Needs rule`: Combat rule 13, the one slot pool.
  - Minor: Light Load (Khinh Trang). Your cheapest equipped artifact costs no thần thức.
  - Minor: Weapon Rack (Binh Giá). Your Physical hits deal more for each weapon-role artifact equipped (L5 +3
    each, cap +15). *Shared minor* (with Thương, Đao).

### 5. Kim Phong (Metal Edge)
- **Small:** `stack_effect_pct` metal +1.5 · `attack_pct` metal +1
- **Stat notables:** Ringing Edge (Phong Minh): metal stack effect ×2 · Long Temper (Lâu Tôi): metal stack duration
  +2 ×2 · Shearing (Cắt Kim): metal attack +1, physical crit damage +1 · Whetted (Mài Bén): metal stack effect +1,
  physical attack +1
- **Effects:**
  - **Major: Metal Rings True (Kim Minh).** When your Metal debuff on a target reaches 20 stacks, your next
    Physical hit consumes 10 of them and deals more (L5 +4 per stack consumed, so +40).
  - Minor: Edge Bites (Phong Phệ). Your Physical crits apply 2 Metal debuff stacks for 4 pulses.
  - Minor: Sharpened by Use (Việt Dụng Việt Lợi). Your Metal buff stacks last 2 pulses longer. *(starter)*

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Gear Is the Body (Khí Tức Thân)** | keystone | Your artifacts' defence ratings also count as block rating, and your armour's artifact power adds to body shield strength | You cannot slot a ward in a free ward slot (wards in art slots only) | Thối Thể, Lò Rèn |
| **Hundred Temperings (Bách Luyện Thành Cương)** | keystone | Your Metal buff stacks never expire during a fight | You gain at most 1 Metal buff stack per second | Kim Phong |
| **Sole Edge (Độc Phong)** | keystone | Every non-Soul part of your hits is converted to Physical (counts as one of the 2 conversions) | You cannot apply Burn or Poison | Tinh Kim |
| **Living Arsenal (Vạn Binh Thân)** | enabler | +1 artifact equipped beyond `equip.max_slots` | Your artifacts cost 30 % more thần thức | Binh Khố |
| **Unbreaking (Bất Chiết)** | keystone | Your Physical resistance may exceed the resistance cap by 10 points | You take 20 % more Chaos damage (rust) | Thối Thể |

## New pieces

- `stack_duration_pct` scoped by element: exists as a key; element scope `Needs key`.
- Living Forge, Bách Binh Ứng, Living Arsenal: `Needs rule` (L3 in-fight growth; actives outside the slot pool;
  a slot above `equip.max_slots`).

## Kept apart from

Thể Đạo and Cốt Đạo (body without gear); Kỹ Đạo's Luyện Khí (refining as a craft, not fighting with gear).
Kim Đạo is the Way of **Metal stacks and carried steel**.
