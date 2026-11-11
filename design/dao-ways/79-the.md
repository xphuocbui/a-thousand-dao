# 79 · Thệ Đạo · *Thiên Thệ* (Oath to Heaven)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct`, `khi_huyet_pct`, `status_resist_pct`, `tam_ma_resist_pct`, renown, `co_duyen_pct`.
> **Road:** `status_resist_pct` +1.

## Build directions

Oaths are **life-long** restrictions (Thiền's Vows are per fight, Kiếp's Trials per fight). A broken oath is a
disaster; a kept oath is permanent power.

1. **Self-Oaths.** Swear to never do something for life (never use a sword, never flee, never kill the surrendered):
   each kept oath gives a large permanent bonus (Tự Thệ). The deepest min-max decision in the game.
2. **Contracts.** Binding deals with NPCs: services for power, enforced by heaven (Khế Ước).
3. **Sworn Siblings.** Sworn bonds with NPCs who come to your aid in the world (Kết Nghĩa).
4. **Heaven as Witness.** Oath-breakers you fight take more damage (Thiên Chứng).

## Facets

### 1. Tự Thệ (Self-Oaths)
- **Small:** `attack_pct` +1.2 · `status_resist_pct` +1
- **Stat notables:** Iron Word (Lời Sắt): attack ×2 · Kept Promise (Giữ Lời): status resist ×2 · Bound by Word (Lời Ràng):
  attack +1, status resist +1 · Sworn Body (Thân Đã Thề): max health +2
- **Effects:**
  - **Major: Oath to Heaven (Thiên Thệ).** Swear up to 3 life oaths from a list (never slot a ward in a ward slot; never
    flee; never use pills in fights; never hold a companion; never use artifacts beyond one; never kill a surrendered
    foe). Each gives +6 % to all damage and +4 % max health for life. Breaking one (only by choice, in an event) loses
    all oath bonuses and adds 50 heart demon. `Needs key`.
  - Minor: Witnessed Oath (Thề Có Chứng). Your first oath gives +50 % of its bonus. *(starter)*
  - Minor: Oath Strength (Sức Lời Thề). +5 % status resistance per oath held.

### 2. Khế Ước (Contracts)
- **Small:** renown +1 · `co_duyen_pct` +1
- **Stat notables:** Fair Terms (Điều Khoản Công Bằng): renown ×2 · Sealed Deal (Thỏa Thuận Có Ấn): fortune ×2 · Contract
  Seal (Ấn Khế): renown +1, fortune +1 · Binding Ink (Mực Ràng Buộc): status resist +2
- **Effects:**
  - **Major: Heaven-Bound Contract (Thiên Khế).** Contracts you make with NPCs (an event) are enforced: an NPC who breaks
    one takes a curse for a year, and you gain a fortunate encounter. `Needs key` (Event Engine).
  - Minor: Good Terms (Điều Kiện Tốt). Mission rewards from contracts +15 %. *(starter)*
  - Minor: Read the Fine Print (Đọc Kỹ). You see hidden costs in event offers.

### 3. Thiên Chứng (Heaven as Witness)
- **Small:** `attack_pct` +1.2 · `tam_ma_resist_pct` +1
- **Stat notables:** Heaven Watches (Trời Chứng): attack ×2 · Clean Conscience (Lương Tâm Sạch): heart-demon resist ×2 ·
  Witness Stone (Đá Chứng): attack +1, heart-demon resist +1 · Thunder of Witness (Sấm Chứng): lightning +2
- **Effects:**
  - **Major: Heaven Witnesses (Thiên Địa Chứng Giám).** Your hits deal +20 % to a foe who has broken an oath or contract
    (World Database).
  - Minor: Clear Record (Hồ Sơ Sạch). While you have broken no oath, heart demon gain −15 %. *(starter)*
  - Minor: Perjurer's Bane (Khắc Kẻ Bội Thề). Curses you apply to an oath-breaker cannot be cleansed for 2 pulses.

### 4. Kết Nghĩa (Sworn Bonds)
- **Small:** renown +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Peach Garden (Vườn Đào): renown ×2 · Brother's Blood (Máu Anh Em): max health ×2 · Shared Cup (Cùng
  Chén): renown +1, max health +1 · Loyal Friend (Bạn Trung Thành): fortune +2
- **Effects:**
  - **Major: Sworn Siblings (Kết Nghĩa Kim Lan).** Swear brotherhood with up to 3 NPCs: they may appear in events to help
    you (a fight they fight beside you is a mass-battle future feature; for now: items, rumours, rescue from capture).
    `Needs key`.
  - Minor: Sibling's Gift (Quà Anh Em). Once a year, each sworn sibling gives a gift. *(starter)*
  - Minor: Avenge (Báo Thù Cho Anh Em). Against a sworn sibling's killer, +25 % damage.

### 5. Nợ Ân (Debts)
- **Small:** `attack_pct` +1 · `co_duyen_pct` +1
- **Stat notables:** Owed (Được Nợ): attack ×2 · Called In (Đòi Nợ): fortune ×2 · Ledger (Sổ Nợ): attack +1, fortune +1 ·
  Patient Creditor (Chủ Nợ Kiên Nhẫn): heart-demon resist +2
- **Effects:**
  - **Major: Call In a Debt (Đòi Ân).** NPCs who owe you (you saved, helped or spared them) can be called on once each
    for an item, a technique copy or a safe house. `Needs key`.
  - Minor: Spared Foe (Kẻ Được Tha). Sparing a beaten NPC makes them owe you. *(starter)*
  - Minor: Interest (Tiền Lãi). Debts older than 5 years give double.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **A Word Is Law (Nhất Ngôn Cửu Đỉnh)** | keystone | You may swear 5 oaths, each +8 % damage | Breaking an oath also costs 10 years of lifespan | Tự Thệ |
| **Heaven Is My Witness (Thiên Chứng Ngã Tâm)** | keystone | Heaven Witnesses' bonus is +40 % | You can never make a contract you might break (no deceit choices in events) | Thiên Chứng |

## New pieces

- Life oaths, contracts, sworn siblings, debts owed: `Needs key` (World Database, Event Engine).

## Kept apart from

Thiền's Vows (per fight), Kiếp's Trials (per fight), Hận's Blood Oath (one target with a deadline), Hiếu's
Báo Ân (kindness received). Thệ is **oaths for life, enforced contracts, and debts you can call**.
