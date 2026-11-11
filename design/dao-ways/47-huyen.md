# 47 · Huyễn Đạo · *Kính Hoa Thủy Nguyệt* (Flowers in a Mirror, Moon in Water: Illusion)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. Holds the seed Illusion (†) and the proposed Dust Đạo (as
> a facet).
> **Theme stats:** `evade_pct`, `soul_res_pct`, `attack_pct` (soul), `than_thuc_pct`, `accuracy_pct` (foe −, via Effects),
> `status_duration_pct`.
> **Road:** `evade_pct` +0.4.

## Build directions

1. **False Targets.** Illusory doubles take hits for you: each Decoy absorbs one hit fully (Thủy Nguyệt). Decoys
   are rebuilt by thần thức. The anti-burst build: a big hit lands on a decoy.
2. **The Mirror.** Reflect a share of arts back (Gương): strongest against art-heavy foes, nothing against basic
   attacks and ticks.
3. **Heart Demons Both Ways.** Raise the foe's heart demon in a fight and punish it (Tâm Ma Ảo): the mind-war build.
4. **Dust.** Blind with dust: accuracy debuffs that pair with evade (Bụi Trần).

## Facets

### 1. Ảo Ảnh (Mirage)
- **Small:** `evade_pct` +0.4 · `than_thuc_pct` +0.5
- **Stat notables:** Heat Shimmer (Hơi Nóng Ảo): evade ×2 · Mind's Eye Trick (Lừa Thần Thức): thần thức ×2 · Phantom
  (Bóng Ảo): evade +1, thần thức +1 · Fata Morgana (Ảo Cảnh): soul resist +2
- **Effects:**
  - **Major: Mirage (Ảo Ảnh).** Your evade is +1 pp per 5 % of your thần thức above the foe's (cap +15 pp, inside
    `evade_cap`); the foe's accuracy does not reduce it.
  - Minor: Blurred Shape (Hình Mờ). +4 pp evade for the first 10 s. *(starter)*
  - Minor: Mirage Strike (Kích Ảo). After you evade, your next soul hit +5 % `x_soul`.

### 2. Gương (the Mirror)
- **Small:** `soul_res_pct` +1 · `defense_pct` +0.6
- **Stat notables:** Bronze Mirror (Gương Đồng): soul resist ×2 · Polished Face (Mặt Bóng): defense ×2 · Two Faces (Hai
  Mặt): soul resist +1, defense +1 · Bright Glass (Kính Sáng): light resist +2
- **Effects:**
  - **Major: The Mirror Returns (Kính Phản).** 20 % of each art hit's damage stopped by your wards is reflected to the
    attacker as the same damage type (a trigger, inside `trig_budget`). Basic attacks and ticks are not reflected.
  - Minor: Mirror Ward (Hộ Gương). Your first ward each fight is 20 % stronger. *(starter)*
  - Minor: Cracked Mirror (Gương Nứt). When your ward shield breaks, reflect 50 % of the breaking hit.

### 3. Tâm Ma Ảo (Heart Demons Both Ways)
- **Small:** `attack_pct` soul +1.5 · `tam_ma_resist_pct` +1
- **Stat notables:** Whispered Doubt (Lời Gieo Ngờ): soul attack ×2 · Mirror Heart (Tâm Gương): heart-demon resist ×2 ·
  Nightmare Seed (Mầm Ác Mộng): soul +1, heart-demon resist +1 · False Memory (Ký Ức Giả): thần thức +2
- **Effects:**
  - **Major: Sow Demons (Gieo Tâm Ma).** Your soul hits add 2 heart demon to the foe for the fight (a fight value, not
    kept); each 10 fight heart demon gives the foe −3 % art speed and your soul hits +2 % `x_soul` against it.
    `Needs key` (in-fight heart demon on profiles).
  - Minor: Shared Nightmare (Ác Mộng Chung). Afraid (Tình's proposed curse) you apply lasts 1 pulse longer. *(starter)*
  - Minor: Reflected Demon (Ma Phản). Heart-demon Effects the foe uses against you are reflected.

### 4. Bụi Trần (Dust)
- **Small:** `status_duration_pct` +2 · `evade_pct` +0.4
- **Stat notables:** Dust Cloud (Mây Bụi): status duration ×2 · Grit in Eyes (Cát Vào Mắt): evade ×2 · Choking Dust (Bụi
  Nghẹt): status duration +1, evade +1 · Dust Devil (Lốc Bụi): earth +2
- **Effects:**
  - **Major: Dust in the Eyes (Bụi Mờ Mắt).** Your hits apply Dusted (stacks with no cap, 3 pulses): −0.8 pp accuracy
    per stack on the foe. `Needs key` (shared shape with Vụ's Fogged; one key may serve both).
  - Minor: Dusty Veil (Màn Bụi). +5 pp evade while the foe has 10+ Dusted. *(starter)*
  - Minor: Dust Settles (Bụi Đọng). Dusted batches last 1 pulse longer.

### 5. Thủy Nguyệt (the Moon in Water)
- **Small:** `than_thuc_pct` +0.9 · `evade_pct` +0.4
- **Stat notables:** Reflection (Ảnh Phản Chiếu): thần thức ×2 · Ripple (Gợn Sóng): evade ×2 · Moon on the Pond (Trăng
  Đáy Ao): thần thức +1, evade +1 · Empty Catch (Bắt Hụt): soul resist +2
- **Effects:**
  - **Major: Moon in Water (Thủy Trung Nguyệt).** You hold Decoys (cap 3, start with 2). A hit that would deal 10 %+ of
    your max health hits a Decoy instead (fully absorbed). A Decoy rebuilds every 8 s.
    `Needs rule` (a hit absorbed outside the defence path).
  - Minor: Ripple Step (Bước Gợn). When a Decoy breaks, +10 pp evade for 1 pulse. *(starter)*
  - Minor: More Moons (Thêm Trăng). Decoys rebuild every 6 s while your thần thức exceeds the foe's.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Enemy Fights a Dream (Địch Chiến Ảo Mộng)** | keystone | Decoys cap at 5 and absorb hits of 5 %+ | Your max health is 25 % lower | Thủy Nguyệt |
| **Flowers in a Mirror (Kính Hoa)** | keystone | The Mirror Returns reflects 40 % and also basic attacks | Your own arts deal 25 % less (L2 −25) | Gương |
| **A World of Dust (Trần Thế)** | keystone | Dusted also lowers the foe's crit chance by 0.3 pp per stack | You cannot crit | Bụi Trần |

## New pieces

- Decoys (whole-hit absorption): `Needs rule`.
- In-fight heart demon on profiles: `Needs key`.
- Dusted (accuracy-down stacks; one key with Fogged): `Needs key`.

## Kept apart from

Hư Thực (feints), Phân Thân (clones that fight), Vụ (veil and fog), Mộng (the dream window). Huyễn is **decoys that
eat big hits, the mirror, and dust in the eyes**.
