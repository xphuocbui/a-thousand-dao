# 04 · Ngũ Hành Đạo · *Ngũ Hành Luân Chuyển* (the Five Phases; the Five Turning)

> Overnight draft 2026-11-11. Proposal. **Needs:** three or more base elements at ≥ 30 purity.
> **Theme stats:** `element_affinity_pct`, `stack_effect_pct` (each base element), `stack_duration_pct`,
> `attack_pct` (fire, physical, chaos, cold), `cultivation_speed_per_element_pct`.
> **Road:** `element_affinity_pct` +1.5.

## Build directions

1. **The Generating Cycle.** Wood feeds Fire feeds Earth feeds Metal feeds Water feeds Wood: an art of one element
   strengthens the next element's art fired after it. Slot order as the cycle (Tương Sinh).
2. **The Overcoming Cycle.** Water beats Fire, Fire beats Metal, Metal beats Wood, Wood beats Earth, Earth beats
   Water: your element stacks wipe the foe's matching buff stacks and convert them. The anti-element duelist.
3. **Balance.** Hold buff stacks of all five at once; the smallest pile sets a bonus (Quân Bình), so breadth beats
   depth.
4. **Rotation.** A five-element rotation where each art's element changes each time it fires (Luân Chuyển):
   one art, five elements.

## Facets

### 1. Tương Sinh (the Generating Cycle)
- **Small:** `element_affinity_pct` +1.5 · `stack_effect_pct` (any base) +0.75
- **Stat notables:** Mother and Child (Mẹ Con): affinity ×2 · Feeding Flow (Dòng Nuôi): stack duration ×2 · Endless
  Birth (Sinh Sinh): affinity +1, stack effect +1 · Root of Five (Gốc Ngũ): max health +1, max linh lực +1
- **Effects:**
  - **Major: Mother Feeds Child (Mẫu Dưỡng Tử).** When your art fires and the art fired before it was of its
    generating element (Wood before Fire, and so on), it deals more (L5 +25) and costs 25 % less.
  - Minor: The Cycle Turns (Luân Hồi Ngũ Khí). Each art you fire grants 2 buff stacks of the next element in the
    generating cycle for 6 pulses. *(starter)*
  - Minor: Child Returns (Tử Phản Mẫu). When three arts fire in generating order (each the child of the one before, within 4 s), restore 6 % of max linh lực; a chain counts once, then starts again from the next art.

### 2. Tương Khắc (the Overcoming Cycle)
- **Small:** `attack_pct` +1.2 · `resist_pen_pct` +0.6
- **Stat notables:** Water Quenches (Thủy Diệt Hỏa): cold +2 · Fire Melts (Hỏa Khắc Kim): fire +2 · Metal Cuts
  (Kim Khắc Mộc): physical +2 · Wood Breaks (Mộc Khắc Thổ): chaos +2 · Earth Dams (Thổ Khắc Thủy): force +2
- **Effects:**
  - **Major: Overcome (Khắc Chế).** Your hits of an element remove 2 of the foe's buff stacks of the element it overcomes (`strip_buff`, Effects rule 6, R16: oldest batch first, at most once per pulse), and deal more by the stacks removed in the last 3 s (L5 +3 per stack, cap +30).
  - Minor: Know the Enemy (Tri Khắc). At fight start, your art of the element that overcomes the foe's root element
    fires at half cooldown. *(starter)*
  - Minor: Turned Against (Phản Khắc). Damage you take from arts whose element overcomes your root's highest-purity element is dampened 10 % (rule 6a).

### 3. Quân Bình (Balance)
- **Small:** `stack_duration_pct` +2 · `khi_huyet_pct` +0.5
- **Stat notables:** Five Pillars (Ngũ Trụ): stack duration ×2 · Even Hand (Tay Đều): affinity +1, max health +1 ·
  Steady Centre (Trung Tâm): defense +2 · Harmony of Five (Ngũ Hòa): regen +0.1
- **Effects:**
  - **Major: Balance (Quân Bình).** Your hits deal more by the smallest of your five base-element buff piles (L5 +8 per stack in the smallest pile, cap +40).
  - Minor: Even Breath (Hơi Đều). While you hold buff stacks of all five base elements, your regeneration of both
    pools is 25 % higher. *(starter)*
  - Minor: Fill the Gap (Lấp Chỗ Trống). Each pulse, grant 1 buff stack of your smallest base element, for the fight.

### 4. Luân Chuyển (Rotation)
- **Small:** `art_speed_pct` +0.5 · `element_affinity_pct` +1
- **Stat notables:** Wheel of Five (Bánh Ngũ): art speed ×2 · Turning Colour (Sắc Xoay): affinity ×2 · Rotation Step
  (Bước Xoay): art speed +1, affinity +1 · Spinning Root (Rễ Xoay): stack effect +2
- **Effects:**
  - **Major: Five Turning (Ngũ Hành Luân Chuyển).** One art you choose changes element each time it fires, in the
    generating order, and its damage type follows (Wood: Chaos, Fire: Fire, Earth: Force, Metal: Physical, Water:
    Cold). `Needs rule` (an art's element changing in a fight).
  - Minor: Colour Change (Đổi Sắc). Each time a rotating art changes element, it grants 3 buff stacks of its new
    element. *(starter)*
  - Minor: Full Turn (Trọn Vòng). Every 5th firing of a rotating art deals more (L5 +40).

### 5. Hòa Hợp (Harmony: pair bonus)
- **Small:** `stack_effect_pct` (any base) +1 · `attack_pct` +1
- **Stat notables:** Paired Roots (Rễ Đôi): stack effect ×2 · Water and Wood (Thủy Mộc): regen +0.1 · Fire and Earth
  (Hỏa Thổ): fire +1, force +1 · Metal and Water (Kim Thủy): physical +1, cold +1
- **Effects:**
  - **Major: Harmony (Hòa Hợp).** Your element buff stacks of a generating pair (Water and Wood, Wood and Fire, and so
    on) each count 25 % stronger while both are held.
  - Minor: Two as One (Song Hợp). Arts with two element tags grant stacks of both. *(starter)*
  - Minor: Harmonious Root (Linh Căn Hòa). Your lowest-purity element counts +10 purity for stack effects.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **All Five Turn as One (Ngũ Hành Hợp Nhất)** | keystone | Every art you fire grants 1 buff stack (6 pulses) of the element it generates, and the cycle never breaks: the next art always counts as its child | Your stacks of any single element cannot exceed 12 | Quân Bình |
| **The Wheel Without End (Luân Bất Tận)** | keystone | Mother Feeds Child fires when the last art fired **of the generating element** fired within 4 s, whatever was fired between | Your arts of the same element as the art before cost 50 % more | Tương Sinh |
| **Overcoming Heaven (Khắc Thiên)** | keystone | Overcome removes 5 stacks of the overcome element and grants you 5 buff stacks of your overcoming element (`strip_buff` with the `steal` variant, Effects rule 6, R16: still once per pulse, oldest batch first) | Your arts cannot apply debuff stacks | Tương Khắc |
| **Five Phases Body (Ngũ Hành Thể)** | keystone | Rotation applies to every art you slot | You may slot at most 3 arts | Luân Chuyển |

## New pieces

- An art whose element changes mid-fight: `Needs rule` (Combat rule 6: element tags never convert).
- The foe's root element as a readable: `Needs key`.

## Kept apart from

Hỗn Độn (Chaos: all elements merged), Tứ Thời (seasons as phases in time), Luân Hồi (Eternal Return borrows the
cycle order only). Ngũ Hành is **order between elements: generating, overcoming, balance**.
