# 31 · Hoàng Tuyền Đạo · *Hoàng Tuyền Lộ* (the Yellow Springs; the Road to the Yellow Springs)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct` (cold, chaos, soul), `stack_effect_pct` (ice), `than_thuc_pct`, `soul_res_pct`,
> `khi_huyet_pct` (negative on Cửu Tuyền only), `healing_pct`, `status_duration_pct`.
> **Road:** `attack_pct` chaos +1.5.

## Build directions

1. **One Foot Below.** Start every fight with part of your health already given to the Springs (a lower cap on
   max health) for a power tier: nine depths, each worse and stronger (Cửu Tuyền). The voluntary-drawback build:
   the min-maxer picks the depth their sustain can carry.
2. **Last Words.** Arts that keep firing when you cannot pay: they speak once more in health (Di Ngôn). A build
   that runs its pool to zero on purpose.
3. **The Lantern Bearer.** Carry the souls of the defeated as charges between fights, spent for soul power (Dẫn
   Hồn). A soul build with a resource that lives outside the fight.
4. **Dark Water.** Cold and Chaos together: Ice stacks and Poison from one hit, the cost-lock plus the clock.

## Facets

### 1. Cửu Tuyền (the Nine Springs)
- **Small:** `attack_pct` +1.2 · `khi_huyet_pct` −0.5 (a price on a stat node)
- **Stat notables:** Deeper Spring (Suối Sâu): attack ×2 · Yellow Water (Nước Vàng): chaos ×2 · Cold Spring (Suối
  Lạnh): cold ×2 · Underworld Rock (Đá Âm): max health +2 (the one plain survival node)
- **Effects:**
  - **Major: Descend (Hạ Tuyền).** Before a fight, choose a depth 0–9. Each depth: −5 % max health, and L5 +6 on all
    hits (depth 9: −45 % max health, L5 +54).
  - Minor: Used to the Dark (Quen Âm). Each depth also gives +3 Chaos and Cold resistance. *(starter)*
  - Minor: Spring Water (Nước Suối). Each depth gives +2 % healing.

### 2. Di Ngôn (Last Words)
- **Small:** `attack_pct` +1 · `healing_pct` +1
- **Stat notables:** Final Breath (Hơi Cuối): attack ×2 · Spoken Twice (Nói Hai Lần): crit damage +2 · Testament
  (Di Chúc): max health +1, attack +1 · Unfinished (Dở Dang): art cost −3
- **Effects:**
  - **Major: Last Words (Di Ngôn).** When an art of yours waits because you cannot pay its linh lực, it fires anyway,
    paid in health at 1.5× (once per art per 6 s).
  - Minor: Dying Wish (Nguyện Cuối). At the Down step's last act, every ready art fires. *(starter)*
  - Minor: Words Remain (Lời Còn). Arts fired with Last Words deal more (L5 +15).

### 3. Dẫn Hồn (Leading Souls)
- **Small:** `than_thuc_pct` +0.9 · `attack_pct` soul +1.5
- **Stat notables:** Soul Lantern (Đèn Hồn): thần thức ×2 · Guide's Bell (Chuông Dẫn): soul attack ×2 · Lantern
  Oil (Dầu Đèn): soul resist +1, thần thức +1 · Beckoning (Vẫy Gọi): soul attack +1, thần thức +1
- **Effects:**
  - **Major: Lantern of Souls (Dẫn Hồn Đăng).** Each cultivator you defeat gives 1 Soul charge (cap 9, kept between
    fights). Before a fight you may spend charges: each gives +4 % `x_soul` for that fight. `Needs key` (a
    character resource).
  - Minor: Lead Gently (Dẫn Nhẹ). Your soul lockout is 0.2 s shorter while you hold 5+ Soul charges. *(starter)*
  - Minor: Restless Souls (Hồn Không Yên). Creatures you defeat give a Soul charge one time in four.

### 4. Hoàn Dương (Return to the Living)
- **Small:** `healing_pct` +1.5 · `khi_huyet_pct` +0.5
- **Stat notables:** Warm Again (Ấm Lại): healing ×2 · Breath Returns (Hơi Về): regen ×2 · Sun on the Face (Nắng
  Mặt): max health +1, healing +1 · Living Colour (Hồng Hào): fire resistance +2
- **Effects:**
  - **Major: Return to the Living (Hoàn Dương).** Each time your health rises back above 50 % after being below 25 %,
    your hits deal more for 6 s (L5 +30) and you cleanse 5 debuff stacks.
  - Minor: Climb Out (Leo Lên). Healing you receive while below 25 % health is 40 % stronger. *(starter)*
  - Minor: Shed the Grave (Rũ Đất). Returning above 50 % (as above) also removes one curse.

### 5. Âm Thủy (Dark Water)
- **Small:** `attack_pct` cold +1 · `attack_pct` chaos +1
- **Stat notables:** Black Spring (Suối Đen): cold +1, chaos +1 ×2 · Grave Chill (Lạnh Mồ): ice stack effect ×2 ·
  Silt (Bùn Đáy): chaos penetration +2 · Still Dark (Tối Lặng): cold penetration +2
- **Effects:**
  - **Major: Dark Water (Âm Thủy).** Your hits with both Cold and Chaos parts apply Ice stacks and Poison stacks
    equal to the larger of the two they would apply alone.
  - Minor: Underflow (Dòng Ngầm). Your Cold hits convert 25 % to Chaos. *(starter)*
  - Minor: Drink of the Springs (Uống Suối Vàng). A foe bearing 20+ Ice and 20+ Poison stacks regenerates no linh lực.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **One Foot Already Below (Nhất Cước Đạp Âm)** | keystone | Descend's depths give L5 +8 each | You must descend at least to depth 4 | Cửu Tuyền |
| **The Road to the Springs (Hoàng Tuyền Lộ)** | keystone | Last Words has no per-art limit and costs 1× in health | Your linh lực regeneration is halved | Di Ngôn |
| **Ninefold Lantern (Cửu Đăng)** | keystone | Soul charges cap at 18 and each gives +5 % `x_soul` | Your non-soul hits deal 30 % less (L2 −30) | Dẫn Hồn |
| **The Springs Run Both Ways (Lưỡng Tuyền)** | keystone | Return to the Living fires each time you cross 50 % upward, with no lower threshold | Your max health is 20 % lower | Hoàn Dương |

## New pieces

- Pre-fight depth choice lowering max health: `Fits today` (preparation Effect), but needs UI.
- Soul charges kept between fights: `Needs key`.

## Kept apart from

Sinh Tử (the Down refused), Bỉ Ngạn (petals and escape), Quỷ Đạo (ghost servants), Hồn Đạo (soul craft). Hoàng
Tuyền is **voluntary depth, last words in health, and lanterns of souls**.
