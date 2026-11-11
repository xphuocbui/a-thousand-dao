# 33 · Cốt Đạo · *Bạch Cốt* (White Bones)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `body_shield_pct`, `block_rating`, `attack_pct` (physical, bone), `health_regen_pct`, `khi_huyet_pct`,
> `soul_res_pct`, companion damage, `can_cot` (root bone).
> **Road:** `body_shield_pct` +1.

## Build directions

1. **Bone Armour.** Body shields that rebuild from bone: shield pieces (Bone Plates) that break one at a time and
   regrow on a timer. A body-shield tank that is weak to Chaos and answers it with plates.
2. **The Bone Spear.** Spend your own max health for Physical damage: each art takes a sliver of max health (it
   returns after the fight) for a big Physical part. A "sacrifice the vessel" min-max.
3. **Marrow.** Regeneration that scales with root bone (căn cốt), the talent stat: the build for high-căn-cốt rolls.
4. **Bone Servants.** A bone companion that soaks: your companion takes a share of hits aimed at you.

## Facets

### 1. Cốt Giáp (Bone Armour)
- **Small:** `body_shield_pct` +1 · `block_rating` +1
- **Stat notables:** Ribcage (Lồng Ngực): body shield ×2 · Bone Plate (Giáp Xương): block ×2 · Exoskeleton (Xương
  Ngoài): body shield +1, block +1 · Spur (Gai Xương): physical +2
- **Effects:**
  - **Major: Bone Plates (Cốt Phiến).** Your body shield is split into 5 Plates, each worth a fifth. A hit breaks at most one Plate (it loses up to its own damage from that Plate; the rest goes on to health). Ticks wear Plates but never break one below 1 point. A broken Plate regrows after 4 s. `Needs rule` (Combat Defence shields).
  - Minor: Calcify (Vôi Hóa). Your Chaos resistance is +10 per unbroken Plate. *(starter)*
  - Minor: Splintered Plate (Phiến Vỡ). When a Plate breaks, deal 1 % of your max health as Physical to the attacker.

### 2. Cốt Thương (Bone Spear)
- **Small:** `attack_pct` physical +1.5 · `khi_huyet_pct` +0.5
- **Stat notables:** Spine Lance (Thương Sống): physical ×2 · Femur Club (Chùy Xương): physical crit damage ×2 · Bone
  Splinter (Mảnh Xương): physical +1, penetration +1 · Marrow Tip (Mũi Tủy): physical penetration +2
- **Effects:**
  - **Major: Draw the Bone (Rút Cốt).** Each of your Physical arts takes 2 % of your max health for the fight when it fires (if your health allows) and deals more (L5 +25). Max health returns after the fight.
  - Minor: Bone Shard (Mảnh Cốt). Your Physical crits apply 1 Bleed stack. *(starter)*
  - Minor: Hollow Bones (Xương Rỗng). Each 10 % of max health given up to Draw the Bone gives +2 % art speed.

### 3. Tủy (Marrow)
- **Small:** `health_regen_pct` +0.05 · `can_cot` +0.5
- **Stat notables:** Red Marrow (Tủy Đỏ): regen ×2 · Root Bone (Căn Cốt): root bone +1 ×2 · Deep Marrow (Tủy Sâu):
  regen +0.05, max health +1 · Bone Broth (Nước Xương): regen increased +4
- **Effects:**
  - **Major: Marrow Spring (Tủy Tuyền).** Each broken Plate that regrows heals you 2 % of max health.
  - Minor: Knit (Liền Xương). Your body shield regains 1 % of max health each pulse while you are not hit.
    *(starter)*
  - Minor: Bone Deep (Thấu Xương). Bleed on you is 50 % weaker.

### 4. Cốt Nô (Bone Servants)
- **Small:** companion damage +2 · `block_rating` +1
- **Stat notables:** Skeleton Guard (Vệ Binh Xương): companion ×2 · Shield of Bones (Khiên Xương): block ×2 ·
  Rattling Host (Đoàn Lách Cách): companion +1, block +1 · Dry Bones (Xương Khô): chaos resistance +2
- **Effects:**
  - **Major: Bone Wall (Tường Cốt).** Your bone companion takes 20 % of each hit aimed at you (it cannot fall; its
    power share drops 1 % per 2 % of your max health it has taken, floor 50 %). `Needs rule` (companions in the
    defence path).
  - Minor: Reassemble (Ráp Lại). Your companion's power share recovers 1 % a second. *(starter)*
  - Minor: Bone Toss (Ném Xương). Your companion's hits apply 1 Metal debuff stack for 4 pulses.

### 5. Sọ Hộ (Skull Ward)
- **Small:** `soul_res_pct` +1 · `body_shield_pct` +1
- **Stat notables:** Thick Skull (Sọ Dày): soul resistance ×2 · Crown Bone (Xương Đỉnh): body shield ×2 · Skull Cup
  (Chén Sọ): soul resist +1, thần thức +1 · Death's Head (Đầu Lâu): soul resist +1, max health +1
- **Effects:**
  - **Major: Skull Ward (Sọ Hộ).** Your body shield also stops Soul hits at 50 % of its value. `Needs rule` (soul
    meets only soul resistance and soul wards).
  - Minor: Hard Head (Cứng Đầu). Slackened Soul on you is halved. *(starter)*
  - Minor: Grinning Skull (Sọ Cười). When a soul hit breaks your body shield, apply Slackened Soul to the attacker.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Strength from the Inside Out (Nội Cốt Ngoại Giáp)** | keystone | Bone Plates regrow after 2 s | Your ward strength is halved | Cốt Giáp |
| **White Bone Demon (Bạch Cốt Ma)** | keystone | Draw the Bone takes 4 % per art and gives L5 +40 | Your health regeneration is 0 | Cốt Thương |
| **Bones of the Ancients (Cổ Cốt)** | keystone | Plates regrow 1 s sooner per 20 căn cốt above 30 (floor 2 s) | Your art speed is −25 % | Tủy |
| **Bone Legion (Cốt Quân)** | keystone | Bone Wall takes 35 % and its floor is 70 % | You cannot slot a ward in an art slot | Cốt Nô |

## New pieces

- Plates (a body shield in pieces): `Needs rule`.
- Max health spent for the fight (Draw the Bone): `Needs key`.
- Companion in the defence path; body shield against Soul: `Needs rule`.

## Kept apart from

Thể Đạo (flesh, bronze skin, the giant), Kim's Thối Thể (block from gear), Quỷ Đạo (ghosts). Cốt is **plates
that regrow, the vessel spent as a spear, and căn cốt as regeneration**.
