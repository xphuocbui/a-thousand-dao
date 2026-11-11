# 54 · Thương Đạo · *Phá Quân* (the Army-Breaker: Spear)

> Overnight draft 2026-11-11. Proposal. **Needs:** none; needs a `spear` form tag.
> **Theme stats:** `attack_pct` (spear, physical), `resist_pen_pct` (physical), `pierce_pct`, `accuracy_pct`,
> `art_speed_pct` (spear), `crit_chance_pct` (spear), `block_rating`, `artifact_attack_pct` (weapon).
> **Road:** `resist_pen_pct` physical +0.6.

## Build directions

1. **The Point Goes Through.** A share of each spear hit skips ward shields entirely (Xuyên Thấu): the anti-ward
   build that does not care how big the ward is. Stack: penetration, spear damage.
2. **Reach.** The spear's first strike: every art's first firing comes much sooner, and the opening seconds are the
   build's whole plan. Tempo, not burst.
3. **The Combo Spear.** Slot order as a combo string: firing arts in slot order builds Dragon stacks (Long
   Thương), and the last art in the string cashes them.
4. **The Spear Wall.** Counter the foe's quick hits: every quick-tagged hit you take sets off a thrust.

## Facets

### 1. Xuyên Thấu (Piercing)
- **Small:** `resist_pen_pct` physical +0.6 · `attack_pct` spear +1
- **Stat notables:** Needle Tip (Mũi Kim): physical penetration ×2 · Armour Bane (Khắc Giáp): spear ×2 · Through
  and Through (Xuyên Suốt): penetration +1, spear +1 · Thin Point (Mũi Nhọn): spear crit damage +2
- **Effects:**
  - **Major: Through the Ward (Xuyên Hộ).** 25 % of each spear hit's damage skips ward shields (it still meets
    resistance, block and the body shield). `Needs rule` (Combat Defence path).
  - Minor: Find the Seam (Tìm Kẽ). Your spear crits apply Sundered. *(starter)*
  - Minor: Bore In (Khoan). Each spear hit on the same target in a row ignores 3 more resistance points (cap 15),
    reset when another art hits.

### 2. Trường Thương (Reach)
- **Small:** `art_speed_pct` spear +1 · `accuracy_pct` +0.5
- **Stat notables:** Long Shaft (Cán Dài): spear art speed ×2 · First Touch (Chạm Trước): accuracy ×2 · Keep Away
  (Giữ Xa): evade +1, spear art speed +1 · Long Arm (Tay Dài): spear +2
- **Effects:**
  - **Major: First Strike (Tiên Phát).** Your spear arts' first firing comes after 40 % of their cooldown, not the
    full cooldown.
  - Minor: Keep Them Out (Ngăn Xa). Until the foe's first art fires, your hits deal more (L5 +20). *(starter)*
  - Minor: Measured Distance (Đo Tầm). Your spear arts cannot be evaded in the first 5 s.

### 3. Xung Phong (Charge)
- **Small:** `attack_pct` spear +1.5 · `khi_huyet_pct` +0.5
- **Stat notables:** Charge (Xông Lên): spear ×2 · War Horse Heart (Tâm Chiến Mã): max health +1, spear +1 ·
  Break the Line (Phá Tuyến): physical penetration +1, spear +1 · Battle Cry (Hét Trận): spear crit chance +1
- **Effects:**
  - **Major: Break the Army (Phá Quân).** Your first spear hit each fight deals more by the foe's ward strength: L5
    +1 per 2 % of its total ward shields as a share of its max health (cap +50).
  - Minor: Run-Up (Lấy Đà). Each spear hit in the first 10 s gives the next one L5 +5 (cap +25). *(starter)*
  - Minor: Trample (Giẫm Đạp). Your spear hits in the first 10 s apply 3 Earth debuff stacks for 6 pulses.

### 4. Thương Trận (Spear Wall)
- **Small:** `block_rating` +1 · `attack_pct` spear +1
- **Stat notables:** Hedge of Points (Rừng Giáo): block ×2 · Set the Butt (Chống Cán): block +1, spear +1 · Brace
  (Thủ Thế): physical resistance +2 · Ready Point (Mũi Chờ): spear crit damage +2
- **Effects:**
  - **Major: Spear Wall (Thương Trận).** When a quick-tagged hit lands on you, thrust back: a spear trigger hit
    (`c_trig` 0.45), once per 0.5 s.
  - Minor: Set Against the Charge (Chống Xung). The foe's first hit each fight is reduced by your block rating
    twice. *(starter)*
  - Minor: Pin (Ghim). Your counter-thrusts apply Silence on the `quick` tag for 1 pulse (once per 6 s).

### 5. Long Thương (Dragon Spear)
- **Small:** `crit_chance_pct` spear +0.8 · `attack_pct` spear +1
- **Stat notables:** Coiling (Cuộn): spear crit chance ×2 · Dragon Tail (Đuôi Rồng): spear +2 · Scale Point (Mũi
  Vảy): spear +1, crit damage +1 · Seven Turns (Thất Chuyển): spear art speed +1, spear +1
- **Effects:**
  - **Major: Dragon Combo (Long Liên).** Each time your arts fire in slot order (slot n then slot n+1 within 3 s),
    gain 1 Dragon stack (cap 6); your last-slot art consumes them for L5 +8 each.
  - Minor: Dragon Turns (Long Hồi). A broken combo keeps half its Dragon stacks. *(starter)*
  - Minor: Dragon Breath (Long Tức). At 6 Dragon stacks, your next art costs nothing.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Point Goes Through (Thương Xuyên)** | keystone | Through the Ward skips 50 % | Your spear hits cannot crit | Xuyên Thấu |
| **Army-Breaker (Phá Quân Thương)** | keystone | Break the Army applies to every spear hit while the foe's ward shields are above 20 % of its max health | Your hits on a foe with no ward shield deal 30 % less (L2 −30) | Xung Phong |
| **Nine Dragons (Cửu Long)** | keystone | Dragon Combo's cap is 12 | You must slot at least 4 arts or Dragon stacks are never gained | Long Thương |
| **Unbroken Line (Tuyến Bất Phá)** | keystone | Spear Wall triggers on every hit that lands, not only quick ones | Your arts' cooldowns are 25 % longer | Thương Trận |

## New pieces

- `spear` form tag: `Needs key`.
- Damage skipping ward shields: `Needs rule` (shared with Chưởng, Nhân Quả, Hỗn Độn: one bypass rule).
- First firing after a share of cooldown (First Strike): `Needs rule` (Combat rule 13).

## Kept apart from

Kiếm (crit), Đao (momentum), Chưởng's Nội Kình (palm force through wards as Force; the spear's pierce is
Physical and partial). Thương is **through the ward, first to strike, combos in slot order**.
