# 16 · Mộc Đạo · *Khô Vinh* (Wither and Bloom: Wood)

> Overnight draft 2026-11-11. Proposal. **Needs:** Wood ≥ 30.
> **Theme stats:** `health_regen_pct`, `health_regen_inc_pct`, `healing_pct`, `khi_huyet_pct`, `stack_effect_pct`
> (wood), `stack_duration_pct` (wood), `attack_pct` (poison, over_time), `leech_health_pct`, `block_rating`,
> `companion` damage (beast), `herb_growth_pct`.
> **Road:** `stack_effect_pct` wood +1.5.

## Build directions

1. **The Evergreen.** Wood buff stacks (+0.1 pp health regeneration each) piled until regeneration outpaces any
   foe's damage. The sustain-is-king tank. Stack: wood stack duration, regeneration increased, max health.
2. **The Spreading Rot.** Poison batches that grow by themselves each pulse (Lan Độc), so the clock speeds up the
   longer it runs. Stack: Wood stack effect, over-time damage, purity.
3. **The Bramble.** Thorns: every hit that lands on you returns a Poisoned thorn; the more you are hit the more
   Poison the foe carries. Stack: block, max health, retaliation.
4. **The Bloom.** Grow your own Wood buff stacks, then spend them all at once (Khai Hoa) for a heal or a burst.

## Facets

### 1. Sinh Trưởng (Growth)
- **Small:** `stack_duration_pct` wood +2 · `health_regen_pct` +0.05
- **Stat notables:** Spring Sap (Nhựa Xuân): wood duration ×2 · Deep Green (Xanh Thẳm): wood stack effect ×2 ·
  New Rings (Vòng Mới): health regen +0.1, max health +1 · Rain-Fed (Mưa Nuôi): regeneration increased ×2
- **Effects:**
  - **Major: Spreading Growth (Lan Độc).** At each pulse, each of your Poison batches on a target with 5+
    stacks grows by 1 stack (at most once per batch every 2 pulses).
  - Minor: Late Leaf (Lá Muộn). Your Wood buff batches granted after 20 s of fight last twice as long.
  - Minor: Sprout (Nảy Mầm). At the start of a fight you hold 10 Wood buff stacks for 10 pulses. *(starter)*

### 2. Gai (Thorns)
- **Small:** `block_rating` +1 · `khi_huyet_pct` +1
- **Stat notables:** Hooked Bark (Vỏ Móc): block ×2 · Briar Skin (Da Gai): max health +1, block +1 · Thicket
  (Bụi Rậm): max health ×2 · Sap-Bitter (Nhựa Đắng): poison attack +1.5, block +0.5
- **Effects:**
  - **Major: Bramble Coat (Áo Gai).** When a hit lands on your health, apply Poison to the attacker equal to
    1 stack per 1 % of your maximum health it took (at most 10 per hit).
  - Minor: Splinter (Dằm). When your block reduces a hit, apply 2 Poison stacks to the attacker. *(starter)*
  - Minor: Grown Over (Liền Sẹo). When your body shield breaks, gain Wood buff stacks equal to 5 for 6 pulses.

### 3. Rừng (the Forest)
- **Small:** companion damage +2 · `formation_power_pct` +1.2 (ground: forest)
- **Stat notables:** Old Grove (Rừng Già): companion damage ×2 · Canopy (Tán Rừng): formation power ×2 · Wild
  Pack (Bầy Rừng): companion damage +1, max health +1 · Mossbed (Đệm Rêu): health regen +0.1, formation power +1
- **Effects:**
  - **Major: The Forest Fights (Rừng Chiến).** Your companion's hits apply 2 Poison stacks and grant you 1 Wood
    buff stack.
  - Minor: Home Grove (Rừng Nhà). On forest ground your Wood buff stacks are 50 % stronger.
  - Minor: Shared Root (Cộng Căn). Your companion heals for 20 % of your health regeneration each pulse.
    `Needs rule` (companions have no health today; it lowers its own damage taken instead: L4 −).

### 4. Rễ (Roots)
- **Small:** `leech_health_pct` +0.3 · `attack_pct` poison +1.5
- **Stat notables:** Taproot (Rễ Cái): leech ×2 · Drinking Roots (Rễ Hút): leech +0.5, poison +1 · Deep Draw
  (Hút Sâu): poison attack ×2 · Root Web (Lưới Rễ): poison +1, regeneration increased +1
- **Effects:**
  - **Major: Root Drinks the Rot (Căn Ẩm Hủ).** Each Poison tick you deal heals you for 15 % of its damage.
    (Reuses the by-root keystone name; here it heals health, the linh lực version stays a map keystone.)
  - Minor: Strangle (Siết). A target bearing 15+ of your Poison stacks regenerates 30 % less (a Stagnation-like
    dampen, not a curse slot).
  - Minor: Sink In (Ăn Sâu). Your Poison batches last 1 pulse longer. *(starter)*

### 5. Khai Hoa (Blossom)
- **Small:** `healing_pct` +1.5 · `stack_effect_pct` wood +1
- **Stat notables:** Full Bloom (Mãn Khai): healing ×2 · Petal Count (Đếm Cánh): wood stack effect ×2 · Heavy
  Flower (Hoa Nặng): healing +1, max health +1 · Pollen (Phấn Hoa): poison +1, healing +1
- **Effects:**
  - **Major: Blossom (Khai Hoa).** Once every 12 s, when you hold 30+ Wood buff stacks, consume them all: heal
    1 % of maximum health per stack and apply that many Poison stacks to the foe.
  - Minor: Seed Fall (Hạt Rơi). When a Blossom (or any heal of yours above 10 % of max health) resolves, gain 5
    Wood buff stacks for the fight.
  - Minor: Wither Before Bloom (Khô Trước Vinh). While below 40 % health, your Wood buff stacks are 100 % stronger.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Forest Outlives Everything (Rừng Trường Tồn)** | keystone | Your Wood buff stacks never expire during a fight | You can never hold more than 60 Wood buff stacks | Sinh Trưởng |
| **Wither and Bloom (Khô Vinh Luân)** | keystone | Every 10 s your Wood stacks switch side: your Wood buff count is applied to the foe as Poison, and the Poison on the foe returns as your buff stacks | Your arts deal 30 % less hit damage (L2 −30) | Khai Hoa |
| **Ironbark (Thiết Mộc)** | keystone | Your health regeneration also restores your body shield at the same rate | Your ward strength is halved | Gai |
| **Green Blood (Lục Huyết)** | enabler | Your arts may be paid in health at 1.5× their cost, and health regeneration counts as linh lực regeneration for Ice-stack cost raises | You cannot use pills in a fight | Rễ |

## New pieces

- Spreading Growth: a stack that grows by itself, `Needs rule` (Effects 9a: batches never change size).
- Bramble Coat: retaliation scaled by damage taken, `Fits today` as an Effect on "being hit".
- Wither and Bloom: transfers stacks between sides, `Needs rule`.

## Kept apart from

Độc Đạo (Poison as craft, Gu and plague; Mộc is Poison as growth). Sinh Tử's Sinh (healing as life and death).
Mộc Đạo is **regeneration you grow, and Poison that grows**.
