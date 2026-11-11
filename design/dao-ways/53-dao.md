# 53 · Đao Đạo · *Cuồng Đao* (the Mad Saber)

> Overnight draft 2026-11-11. Proposal. **Needs:** none; needs a `saber` form tag (dao.md Open (roster)).
> **Theme stats:** `attack_pct` (saber, physical), `crit_damage_pct` (saber), `resist_pen_pct` (physical),
> `artifact_attack_pct` (weapon), `khi_huyet_pct`, `leech_health_pct`, `block_rating`, `art_cost_health_pct`.
> **Road:** `attack_pct` saber +2.

## Build directions

1. **The Momentum Saber.** A new self-stack, Fury (Cuồng Ý): each saber hit adds Fury, Fury adds damage, and
   missing or waiting bleeds it away. Sword is precision; Saber is momentum.
2. **The Ward Splitter.** Sweeping cuts strike every slotted ward's shield at once (Hoành Tảo): the answer to
   layered-ward tanks.
3. **The Blood Saber.** Pay arts in health, leech it back from Bleed; a high-risk sustain loop (watch the by-root
   note: health-paid costs are already strong, so this one carries a closing cost).
4. **The Return Stroke.** Counters: every hit taken queues a saber reply; a duelist who wants to be hit first.

## Facets

### 1. Trọng Đao (Heavy Saber)
- **Small:** `attack_pct` saber +2 · `crit_damage_pct` saber +1.5
- **Stat notables:** Broad Back (Sống Dày): saber ×2 · Cleaver (Dao Phay): saber crit damage ×2 · Iron Weight (Sắt
  Nặng): physical +1, saber +1 · Split Bone (Chẻ Xương): physical penetration +2
- **Effects:**
  - **Major: One Cut Splits the Sky (Nhất Đao Khai Thiên).** Your saber arts with a cooldown of 6 s or more deal
    more by their cooldown (L5 +4 per second of authored cooldown above 5, cap +40).
  - Minor: Heft (Nặng Tay). Your slow-tagged saber arts ignore 15 Physical resistance points against a foe above 50 % health. *(starter)*
  - Minor: Cleave Through (Chém Xuyên). A ward shield your saber hit breaks cannot recharge for 5 s.

### 2. Hoành Tảo (Sweeping Cut)
- **Small:** `attack_pct` saber +1 · `attack_pct` physical +1
- **Stat notables:** Wide Arc (Vòng Rộng): saber ×2 · Sweeping Wind (Gió Quét): physical +2 · Long Reach (Tầm Xa):
  saber +1, accuracy +1 · Spinning Edge (Lưỡi Xoáy): saber crit chance +1, saber +1
- **Effects:**
  - **Major: Sweep (Hoành Tảo).** Your saber hits deal 30 % of their damage to every ward shield the target has up,
    in addition to the normal defence path. `Needs rule` (Combat Defence: one path per hit).
  - Minor: Clear the Field (Dọn Trận). Your saber hits remove 1 buff stack of the target's highest-count element (`strip_buff`, Effects rule 6, R16; once per pulse).
  - Minor: Wide Stance (Thế Rộng). +5 block rating per slotted saber art. *(starter)*

### 3. Đao Ý (Saber Intent)
- **Small:** `attack_pct` saber +1.5 · `khi_huyet_pct` +0.5
- **Stat notables:** Rising Madness (Cuồng Dâng): saber ×2 · Battle Blood (Máu Chiến): max health +1, saber +1 ·
  Unrelenting (Không Ngớt): saber crit damage +2 · Wild Eyes (Mắt Dại): saber crit chance +1, accuracy +1
- **Effects:**
  - **Major: Fury (Cuồng Ý).** Each saber hit you land (basic attack included, once you hold a saber; trigger hits count) gives 1 Fury (cap 20): L5 +2 per Fury on saber hits. After 3 s without a saber hit, Fury falls by 1 a second. (a self-counter, tag `growing`: Effects rule 8, R7; cap 20, decay as written).
  - Minor: Roar (Hống). At 20 Fury, your next saber hit crits for certain and resets Fury to 10.
  - Minor: Hot Start (Khởi Nóng). You begin each fight with 5 Fury, and Fury never falls below 5. *(starter)*

### 4. Huyết Đao (Blood Saber)
- **Small:** `leech_health_pct` +0.3 · `attack_pct` bleed +1.5
- **Stat notables:** Red Edge (Lưỡi Đỏ): leech ×2 · Drip (Nhỏ Giọt): bleed ×2 · Blood Groove (Rãnh Máu): leech
  +0.5, saber +1 · Pay in Red (Trả Máu): leech +0.5, max health +1
- **Effects:**
  - **Major: Blood Saber (Huyết Đao).** Your saber arts may be paid in health (1 % health per 1 % linh lực of cost),
    and each Bleed tick you deal heals you for 30 % of its damage.
  - Minor: Opened Vein (Mở Mạch). Your saber crits apply 2 Bleed stacks. *(starter)*
  - Minor: Smell of Blood (Mùi Máu). Your saber hits deal more to a Bleeding target (L5 +10).

### 5. Hồi Đao (Return Stroke)
- **Small:** `block_rating` +1 · `attack_pct` saber +1
- **Stat notables:** Parry (Đỡ Gạt): block ×2 · Riposte (Phản Đòn): saber +2 · Ready Stance (Thế Chờ): block +1,
  saber crit chance +1 · Turned Blade (Lưỡi Ngược): saber crit damage ×2
- **Effects:**
  - **Major: Return Stroke (Hồi Đao).** When you are hit while your block rating is above 0 and the block reduced it, strike back: a saber trigger hit (`c_trig` 0.5). It counts as a saber hit for Fury and Bleed but not as an art fired. Once per 0.75 s.
  - Minor: Read the Blow (Đọc Chiêu). After you block, your next saber art fires 0.3 s sooner.
  - Minor: Stand Your Ground (Giữ Thế). +10 % block rating while you have Fury. *(starter)*

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Heaven-Splitting Edge (Khai Thiên Nhất Đao)** | keystone | Your one slotted slow saber art deals much more (L5 +60), cannot be evaded, and always crits | You may slot only one damaging art | Trọng Đao |
| **Mad Saber (Cuồng Đao)** | keystone | Fury has no cap and does not decay | Your ward strength is halved and your evade is 0 | Đao Ý |
| **Sea of Blood Saber (Huyết Hải Đao)** | keystone | Every Bleed stack on the target adds L5 +3 to your saber hits (to the L5 cap) | You cannot heal from any source but Bleed and leech | Huyết Đao |
| **Answer Every Blow (Hữu Kích Tất Ứng)** | keystone | Return Stroke has no per-time limit (bounded by `trig_cap`) and its `c_trig` is 0.7 | You cannot slot more than 2 arts | Hồi Đao |

## New pieces

- `saber` form tag: `Needs key` (Combat rule 6, Modifier System rule 9).
- Fury (self-counter, tag `growing`): Effects rule 8, R7; shared idea with Sát Đạo's Chiến Liên.
- Sweep (damage to all ward shields): `Needs rule`.

## Kept apart from

Kiếm Đạo (crit precision, flying swords). Sát Đạo (killing intent, executions). Huyết Đạo (blood as a currency).
Đao Đạo is **momentum, the sweep and the return stroke**.
