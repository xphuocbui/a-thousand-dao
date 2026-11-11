# 36 · Thể Đạo · *Bất Diệt Thể* (the Undying Body)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `block_rating`, `body_shield_pct`, `khi_huyet_pct`, `health_regen_pct`, `can_cot`, `resist_pct`
> (physical, force), `attack_pct` (basic, physical).
> **Road:** `khi_huyet_pct` +1.

## Build directions

1. **Flesh Beats Treasure.** No artifacts, all body: L3 is empty, so the Way pays it back in body power (Không
   Thủ, capstone). The thể tu min-max: what is a build worth with no gear?
2. **The Bare-Fist Body.** The basic attack as the main channel, scaled by căn cốt and max health. Never casts.
3. **Bronze and Iron.** Block and body shield stacked so high that Physical and elemental hits stop mattering;
   the weak point is Chaos, and Ngọc Tủy's regeneration is the answer.
4. **The Giant.** Max health as everything: damage and regeneration read max health (Cự Nhân).

## Facets

### 1. Đồng Bì (Bronze Skin)
- **Small:** `block_rating` +1 · `resist_pct` physical +1.5
- **Stat notables:** Bronze Hide (Da Đồng): block ×2 · Weathered (Dạn Dày): physical resistance ×2 · Callus (Chai):
  block +1, physical resist +1 · Ringing Skin (Da Vang): force resistance +2
- **Effects:**
  - **Major: Bronze Body (Đồng Thân).** Hits that your block reduces by more than half are reduced by your block a
    second time (block applies twice to small hits). (Effects rule 16, R24)
  - Minor: Thick-Skinned (Da Dày). +15 block rating while above 70 % health. *(starter)*
  - Minor: Shrug Off (Nhún Vai). Your block reduces Burn ticks by 2 % each. (Effects rule 16, R24)

### 2. Thiết Cốt (Iron Bones)
- **Small:** `body_shield_pct` +1 · `can_cot` +0.5
- **Stat notables:** Iron Frame (Khung Sắt): body shield ×2 · Dense Bone (Xương Đặc): root bone +1 ×2 · Rebar (Cốt
  Thép): body shield +1, max health +1 · Unbending (Không Cong): force resistance +2
- **Effects:**
  - **Major: Iron Bones (Thiết Cốt).** Your body shield is increased by 1 % per point of căn cốt above 30 (cap +40 %), and it regains 2 % of its value each pulse.
  - Minor: Hard Frame (Khung Cứng). +50 `timer_resist_pct` (key: `timer_resist_pct`, R1): delays and Slowed Time on you are halved. Weighed on you is halved. *(starter)*
  - Minor: Bone Song (Cốt Ca). When your body shield is full, your basic attack deals more (L5 +15).

### 3. Ngọc Tủy (Jade Marrow)
- **Small:** `health_regen_pct` +0.05 · `resist_pct` chaos +1.5
- **Stat notables:** Jade Marrow (Tủy Ngọc): regen ×2 · Clean Blood (Máu Sạch): chaos resistance ×2 · Inner Spring
  (Suối Trong): regen +0.05, chaos resist +1 · Purified Body (Thân Tịnh): status resist +2
- **Effects:**
  - **Major: Marrow Cleanses (Tủy Tịnh).** Each pulse in which your health regeneration healed you, remove 1 Poison or Corpse Rot stack from you (2 if your regeneration is 0.3 pp or more).
  - Minor: Clear Marrow (Tủy Trong). Your Chaos resistance +15 while your body shield is up. *(starter)*
  - Minor: Endless Spring (Xuân Bất Tận). Your health regeneration is not dampened by Stagnation below 30 stacks.

### 4. Cự Nhân (the Giant)
- **Small:** `khi_huyet_pct` +1 · `attack_pct` physical +1
- **Stat notables:** Towering (Cao Lớn): max health ×2 · Heavy Fist (Nắm Đấm Nặng): physical ×2 · Broad Shoulders
  (Vai Rộng): max health +1, physical +1 · Titan's Blood (Huyết Khổng Lồ): regen +0.1
- **Effects:**
  - **Major: Giant's Strength (Cự Lực).** Your Physical hits gain flat damage equal to 1 % of your maximum health
    (before layers).
  - Minor: Big Frame (Thân To). Your max health is +1 % per point of căn cốt above 40 (cap +10 %). *(starter)*
  - Minor: Stride (Sải Bước). Your basic attack's cooldown is 0.1 s shorter per 20 % of max health above your
    realm's base (cap −0.3 s).

### 5. Không Thủ (Bare Hands)
- **Small:** `attack_pct` basic +2 · `block_rating` +1
- **Stat notables:** Iron Fist (Quyền Sắt): basic ×2 · Knuckle (Đốt Tay): basic +1, physical crit damage +1 · Guard
  Hand (Tay Che): block ×2 · Palm and Elbow (Chưởng Khuỷu): basic +1, block +1
- **Effects:**
  - **Major: Flesh Beats Treasure (Nhục Thân Thắng Bảo).** For each artifact slot you leave empty, your basic attack deals more (L5 +12 per slot, cap +48) and your block +10. (Does not stack with the capstone of the same name: the capstone replaces it.)
  - Minor: Fist Rhythm (Nhịp Quyền). Each basic attack hit gives the next L5 +3 (cap +15, lost if 2 s pass).
    *(starter)*
  - Minor: Grapple (Vật). Your basic attack applies 1 Earth debuff stack for 4 pulses.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Undying Body (Bất Diệt Thể)** | keystone | Your health regeneration lines count +50 % | You cannot be healed by arts or pills | Ngọc Tủy |
| **Flesh Beats Treasure (Nhục Thân Thành Thánh)** | keystone | Your body counts as a weapon and an armour artifact of your realm for L3 (a top-quality piece's attack and defence); the major's empty-slot bonus no longer applies | You cannot equip any artifact | Không Thủ |
| **Bronze Mountain (Đồng Sơn)** | keystone | Bronze Body triggers on any hit your block reduces | Your art speed is −30 % | Đồng Bì |
| **Titan (Khổng Lồ)** | keystone | Giant's Strength uses 2 % | Your health regeneration is dampened by 100 (halved) | Cự Nhân |

## New pieces

- Block twice / block on ticks: Effects rule 16, R24.
- Body counting as artifacts for L3: Effects rule 16, R37 (body cultivation counts as gear for L3).

## Kept apart from

Cốt (plates and bone spears), Thổ's Sơn Thể (Earth stacks), Kim's Thối Thể (Metal and gear), Huyết (blood economy).
Thể is **no gear, the bare fist, and the body that will not die**.
