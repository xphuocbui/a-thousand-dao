# 29 · Nhân Quả Đạo · *Gieo Nhân Gặt Quả* (Cause and Effect; Sow the Cause, Reap the Fruit)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct`, `khi_huyet_pct`, `block_rating`, `status_resist_pct`, `co_duyen_pct`, `healing_pct`,
> `crit_damage_pct`.
> **Road:** `khi_huyet_pct` +1.

## Build directions

1. **Karma Bank.** Delayed damage: a share of every hit you deal is held as Karma on the foe and paid out later in
   one lump that ignores the defences the foe has raised since (Nghiệp). Burst without a burst art.
2. **Retribution.** Every point of damage the foe deals to you is owed back with interest (Báo Ứng); the tank
   whose damage is the foe's own.
3. **Debts.** Borrow power now, repay it later in the fight: a front-loaded build that must win before the bill
   comes, or survive the bill (Nợ).
4. **The Cutter.** Sever cause and effect: cleanse everything, refuse statuses, and break other builds' delayed
   mechanics. A counter-build.

## Facets

### 1. Nghiệp (Karma)
- **Small:** `attack_pct` +1.2 · `crit_damage_pct` +1.5
- **Stat notables:** Heavy Karma (Nghiệp Nặng): attack ×2 · Seed of Ruin (Mầm Họa): crit damage ×2 · Patient Cause
  (Nhân Chờ): attack +1, max health +1 · Ripened (Chín Muồi): attack +2
- **Effects:**
  - **Major: Karma (Nghiệp).** 20 % of the damage your hits deal is also recorded as Karma on the foe. Every 8 s,
    the Karma is dealt to the foe's health as one Chaos part that skips ward shields, and resets.
    `Needs key` (Karma counter) + `Needs rule` (bypass).
  - Minor: Ripening (Chín). Karma paid out after 20 s of fight is 30 % larger. *(starter)*
  - Minor: Compounding (Lãi Mẹ Đẻ Lãi Con). Each Karma payout grows by 10 % of the payout before it (the second
    is ×1.1, the third ×1.2, and so on).

### 2. Nợ (Debts)
- **Small:** `attack_pct` +1.2 · `healing_pct` +1.5
- **Stat notables:** Borrowed Strength (Lực Vay): attack ×2 · Grace Period (Hạn Trả): healing ×2 · Creditor (Chủ
  Nợ): attack +1, healing +1 · Interest (Lãi): crit damage +2
- **Effects:**
  - **Major: Borrowed Power (Mượn Lực).** For the first 15 s, your hits deal more (L5 +40). After 15 s you repay:
    your hits deal less (L2 −20) until you have dealt damage equal to what the loan added.
  - Minor: Debtor's Grace (Ân Hạn). The loan lasts 18 s. *(starter)*
  - Minor: Default (Quịt). If you win before repayment ends, gain 1 Fortune (khí vận) for the season.

### 3. Báo Ứng (Retribution)
- **Small:** `block_rating` +1 · `khi_huyet_pct` +1
- **Stat notables:** Eye for an Eye (Ăn Miếng Trả Miếng): max health ×2 · Hold the Grudge (Ghi Nhớ): block ×2 ·
  Measured Return (Trả Đúng): block +1, attack +1 · Iron Patience (Nhẫn Sắt): max health +1, block +1
- **Effects:**
  - **Major: Retribution (Báo Ứng).** Damage that reaches your health is recorded as Owed. Your next art hit deals
    more by Owed: L5 +1 per 1 % of your max health Owed (cap +50), then Owed resets.
  - Minor: Returned in Kind (Trả Lễ). When a curse is placed on you, the same curse is placed on the foe for 1 pulse.
    *(starter)*
  - Minor: Interest Owed (Nợ Lãi). Owed not spent within 5 s grows by 20 %.

### 4. Duyên (Affinity)
- **Small:** `co_duyen_pct` +1 · `healing_pct` +1
- **Stat notables:** Fated Meeting (Hội Ngộ): fortune encounters ×2 · Red Thread (Chỉ Hồng): healing ×2 · Kind
  Cause (Nhân Lành): fortune +1, status resist +1 · Old Bond (Duyên Cũ): companion damage +2
- **Effects:**
  - **Major: Good Cause, Good Fruit (Thiện Nhân Thiện Quả).** Events where you helped an NPC record a Cause; once per
    realm, a later event cashes it as a guaranteed fortunate encounter. `Needs key` (Event Engine, World Database).
  - Minor: Bound Fates (Đồng Mệnh). Your companion's power share +5 %. *(starter)*
  - Minor: Lucky Cause (Nhân May). Fortune shifts your status chances by 25 % more.

### 5. Đoạn Nhân Quả (Cutting Karma)
- **Small:** `status_resist_pct` +1 · `attack_pct` +1
- **Stat notables:** Clean Slate (Bảng Trắng): status resist ×2 · Severing (Cắt Đứt): attack ×2 · No Debt (Không
  Nợ): status resist +1, max health +1 · Free of Cause (Vô Nhân): soul resist +2
- **Effects:**
  - **Major: Sever (Đoạn).** Delayed effects on you (Karma, stored damage like Internal Injury, standing statuses)
    resolve at half; and your cleanses also remove one foe buff that reads time (a growing stack, a stored bonus).
  - Minor: Unbound (Vô Ràng Buộc). Curses on you last 1 pulse less. *(starter)*
  - Minor: Cut the Thread (Cắt Chỉ). The foe's companion deals 20 % less to you.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Every Blow Comes Home (Nhân Quả Tuần Hoàn)** | keystone | Karma records 40 % and pays out every 5 s | Your hits deal 30 % less directly (L2 −30) | Nghiệp |
| **Heaven Keeps Accounts (Thiên Ký Sổ)** | keystone | Retribution has no cap and Owed never resets until spent | You cannot block or evade (block 0, evade 0) | Báo Ứng |
| **Debt Never Paid (Nợ Bất Hoàn)** | keystone | Borrowed Power's repayment is halved | If you lose the fight, you lose 1 year of lifespan per 10 % of the loan unpaid | Nợ |
| **Outside Karma (Siêu Nhân Quả)** | keystone | You are immune to delayed and stored effects (they do not apply to you) | You cannot use Karma, Owed or any stored-damage Effect yourself | Đoạn Nhân Quả |

## New pieces

- Karma and Owed counters: `Needs key`.
- Damage skipping shields (Karma payout): `Needs rule` (shared with Thương, Chưởng).
- Causes cashed by later events: `Needs key` (Event Engine).

## Kept apart from

Luân Hồi (the wheel and rebirth); Hận Đạo (grudges against named NPCs in the world); Nhẫn Đạo (damage taken to
power over time). Nhân Quả is **delayed payout, loans and retribution**.
