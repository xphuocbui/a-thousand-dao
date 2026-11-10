# 03 · Thái Âm Đạo · *Quảng Hàn* (the Great Moon; the Moon Palace)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct` (cold, light), `stack_effect_pct` (ice, water), `evade_pct`, `linh_luc_regen_pct`,
> `health_regen_pct`, `soul_res_pct`, `crit_damage_pct`.
> **Road:** `attack_pct` cold +1 and light +1.

## Build directions

1. **The Phases.** A 24 s lunar cycle of four phases (New, Waxing, Full, Waning), each a different bonus; a build
   tunes its arts to fire at Full. Unlike Thủy's flat tide, each phase does something else.
2. **Borrowed Light.** Take a share of the foe's buff stacks as your own (the moon shines with the sun's light):
   the counter-build to stack builds that also feeds on them.
3. **Moonlight.** Cold on Light: Ice stacks and Exposed from the same hits; a cost-lock that also opens defences.
4. **Night Bloom.** Stronger in long fights and at night (world time): late-fight power for sustain builds.

## Facets

### 1. Nguyệt Tướng (Phases)
- **Small:** `attack_pct` +1.2 · `evade_pct` +0.4
- **Stat notables:** Crescent (Trăng Khuyết): attack ×2 · Half Moon (Bán Nguyệt): evade ×2 · Gibbous (Trăng Khuyết
  Dần): attack +1, evade +1 · Moon Face (Mặt Trăng): crit damage +2
- **Effects:**
  - **Major: Phases of the Moon (Nguyệt Tướng).** The fight runs a 24 s cycle from t = 0: New (0–6 s: +15 pp evade),
    Waxing (6–12 s: +1 Ice stack on the foe per hit), Full (12–18 s: L5 +40 on all hits), Waning (18–24 s: leech 4 %).
  - Minor: Moon Calendar (Âm Lịch). You choose the phase the fight begins in. *(starter)*
  - Minor: Full Moon Longer (Rằm Dài). Full lasts 8 s; New lasts 4 s.

### 2. Nguyệt Quang (Moonlight)
- **Small:** `attack_pct` cold +1 · `attack_pct` light +1
- **Stat notables:** Silver Light (Ánh Bạc): cold +1, light +1 ×2 · Cold Glow (Sáng Lạnh): ice stack effect ×2 · Moon
  Beam (Tia Trăng): light penetration +2 · Frost Silver (Bạc Sương): cold penetration +2
- **Effects:**
  - **Major: Moonlight (Nguyệt Quang).** Your Cold hits apply Exposed for 1 pulse on a crit; your Light hits apply
    2 Ice stacks per hit.
  - Minor: Pale Light (Ánh Nhạt). Your Light hits convert 25 % to Cold. *(starter)*
  - Minor: Moon Frost (Sương Trăng). A target bearing 20+ Ice stacks takes more from Light (L5 +12).

### 3. Triều Tịch (Tides, with Water)
- **Small:** `stack_effect_pct` water +1.5 · `linh_luc_regen_pct` +0.075
- **Stat notables:** Moon Tide (Triều Trăng): water stack effect ×2 · Pull (Lực Hút): linh lực regen ×2 · High Tide
  (Triều Lên): water effect +1, regen +0.05 · Neap (Triều Kém): max linh lực +2
- **Effects:**
  - **Major: Moon Pulls the Sea (Nguyệt Dẫn Triều).** During Full, your Water buff stacks count triple; during New,
    your linh lực regeneration is doubled.
  - Minor: Ebb Gift (Quà Triều Rút). When Waning ends, gain 10 Water buff stacks for 12 pulses. *(starter)*
  - Minor: Spring Tide (Triều Cường Rằm). With a Water root ≥ 30, Full lasts 2 s longer.

### 4. Dạ Hoa (Night Bloom)
- **Small:** `health_regen_pct` +0.05 · `attack_pct` +1
- **Stat notables:** Night-Blooming Cereus (Quỳnh Hoa): regen ×2 · Midnight Petal (Cánh Nửa Đêm): attack ×2 · Dew at
  Night (Sương Đêm): regen +0.05, soul resist +1 · Pale Bloom (Hoa Nhạt): crit damage +2
- **Effects:**
  - **Major: Bloom at Night (Dạ Hoa Khai).** For each full lunar cycle completed in the fight, your hits deal more (L5
    +15, cap +45) and your regeneration +10 %.
  - Minor: Night Fight (Dạ Chiến). Fights at night (world time) start in Full. `Needs key` (world time readable).
    *(starter)*
  - Minor: Brief Beauty (Phù Dung Sớm Nở). Bloom at Night's bonus is doubled for the first 6 s after each cycle.

### 5. Kính Nguyệt (Borrowed Light)
- **Small:** `soul_res_pct` +1 · `evade_pct` +0.4
- **Stat notables:** Mirror Moon (Trăng Gương): soul resist ×2 · Reflected Light (Ánh Phản): evade ×2 · Still Pool
  (Hồ Lặng): soul resist +1, regen +0.05 · Silver Mirror (Gương Bạc): light +2
- **Effects:**
  - **Major: Borrowed Light (Tá Quang).** Every 3 s, copy 25 % of the foe's largest element buff pile as your own
    buff stacks of that element (a batch for 6 pulses).
  - Minor: Moon Reflects (Trăng Soi). The foe's Exposed and Sundered on you last 1 pulse less. *(starter)*
  - Minor: Waxing on Their Light (Mượn Ánh Mà Tròn). While you hold borrowed stacks, your hits deal more (L5 +10).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Full Moon Every Night (Dạ Dạ Mãn Nguyệt)** | keystone | The cycle is Full for 12 s and New for 12 s (Waxing and Waning skipped) | During New, your hits deal 30 % less (L2 −30) | Nguyệt Tướng |
| **Moon Palace (Quảng Hàn Cung)** | keystone | Moonlight's Exposed applies on every Cold hit, not only crits | You cannot apply Burn and Fire hits deal you 25 % more | Nguyệt Quang |
| **The Moon Has No Light of Its Own (Nguyệt Vô Tự Quang)** | keystone | Borrowed Light copies 60 % and also removes what it copies from the foe | You cannot gain buff stacks except by borrowing | Kính Nguyệt |
| **Endless Night (Trường Dạ)** | keystone | Bloom at Night has no cap | The cycle runs 36 s | Dạ Hoa |

## New pieces

- World time readable in fights: `Needs key` (shared with Quỷ's Ghost Month).
- Copying the foe's buff stacks: `Fits today` as an Effect (reads a sheet value and grants stacks).

## Kept apart from

Thủy Đạo's Triều (a flat wave; the moon has four different phases), Băng, Âm Dương's Âm, Mộng. Thái Âm is **the
four phases, Cold on Light, and light borrowed from the foe**.
