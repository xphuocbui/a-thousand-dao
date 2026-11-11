# 82 · Hoàng Đạo · *Nhân Hoàng* (Emperor of Men)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. The ◇ Thần Dân (Followers) facet is archived; replaced here
> by **Quốc Khố (the Treasury)**.
> **Theme stats:** `defense_pct`, `status_resist_pct`, renown, `mission_income_pct`, `formation_power_pct`, `attack_pct`.
> **Road:** `status_resist_pct` +1.

## Build directions

1. **Authority.** An aura of rank: foes of lower realm or renown are weakened by your presence (Uy Nghiêm). The
   anti-swarm, anti-upstart duelist.
2. **Decrees.** Before a fight, issue a Decree (a buff to yourself that is also a Rule the foe must obey for its
   first 10 s) (Thánh Chỉ).
3. **Tribute.** Income from regions you rule or protect: the wealth build (Cống Phẩm, Quốc Khố).
4. **The Throne.** Home ground: your seat of power is a fortress (Long Ỷ).

## Facets

### 1. Uy Nghiêm (Authority)
- **Small:** `status_resist_pct` +1 · `defense_pct` +0.6
- **Stat notables:** Imperial Bearing (Long Uy): status resist ×2 · Dragon Robe (Long Bào): defense ×2 · Cold Gaze of Rule
  (Ánh Mắt Quân Vương): status resist +1, defense +1 · Mandate (Thiên Mệnh Đế): renown +2
- **Effects:**
  - **Major: Imperial Majesty (Đế Uy).** Foes of a lower realm deal you 20 % less and start with −10 % art speed; foes of
    your realm with less renown deal 10 % less.
  - Minor: Bow Before Me (Quỳ Xuống). The foe's first hit each fight is dampened 30 % (rule 6a). *(starter)*
  - Minor: Unbending Crown (Vương Miện Không Cúi). Fear and charm on you are refused.

### 2. Quốc Khố (the Treasury) — replaces ◇ Thần Dân
- **Small:** `mission_income_pct` +1 · `sell_price_pct` +1
- **Stat notables:** Full Coffers (Kho Đầy): income ×2 · Tax Roll (Sổ Thuế): sell price ×2 · Mint (Xưởng Đúc): income +1,
  sell +1 · Granary (Kho Lúa): max health +2
- **Effects:**
  - **Major: The Treasury (Quốc Khố).** A personal treasury collects 10 % of all spirit stones you earn and grows 5 % a
    year; you may draw on it for any purchase. `Needs key`.
  - Minor: Royal Credit (Tín Dụng Hoàng Gia). Shops sell to you on credit up to a season's income. *(starter)*
  - Minor: Spend to Rule (Chi Để Trị). Spending 1 % of the treasury before a fight gives L4 +5 (cap +20).

### 3. Thánh Chỉ (Decrees)
- **Small:** `status_duration_pct` curse +2 · `attack_pct` +1
- **Stat notables:** Edict (Chiếu Chỉ): curse duration ×2 · Imperial Seal (Ngọc Tỷ): attack ×2 · Heaven's Order (Lệnh
  Trời): curse duration +1, attack +1 · Herald (Sứ Giả): renown +2
- **Effects:**
  - **Major: Decree (Thánh Chỉ).** Before a foreseen fight, issue one Decree: *No Haste* (the foe's art speed −20 % for
    10 s), *No Mercy* (the foe cannot heal for 10 s), *No Retreat* (the foe cannot escape), *Kneel* (the foe's first art
    waits 2 s). `Needs key`.
  - Minor: Quick Decree (Chiếu Nhanh). Decrees work in ambush fights too. *(starter)*
  - Minor: Long Decree (Chiếu Dài). Decrees last 15 s.

### 4. Cống Phẩm (Tribute)
- **Small:** `mission_income_pct` +1 · `co_duyen_pct` +1
- **Stat notables:** Vassal Gifts (Lễ Vật Chư Hầu): income ×2 · Rare Tribute (Cống Phẩm Quý): fortune ×2 · Overlord (Bá
  Chủ): income +1, fortune +1 · Jade Tribute (Cống Ngọc): artifact power +2
- **Effects:**
  - **Major: Receive Tribute (Thu Cống).** Each region where you are the strongest cultivator (World Database) gives a
    tribute item each year. `Needs key`.
  - Minor: Lesser Tribute (Cống Nhỏ). Villages you protect give herbs each season. *(starter)*
  - Minor: Tribute of Arts (Cống Thuật). Once a realm, a tribute includes a technique.

### 5. Long Ỷ (the Throne)
- **Small:** `formation_power_pct` +1.2 · `defense_pct` +0.6
- **Stat notables:** Dragon Throne (Ngai Rồng): formation ×2 · Palace Walls (Tường Cung): defense ×2 · Throne Room (Điện
  Ngai): formation +1, defense +1 · Imperial Guard Array (Trận Ngự Lâm): resist all +1
- **Effects:**
  - **Major: The Seat of Power (Ngự Tọa).** Fights at your seat (cave dwelling or a hall you own) are foreseen for you,
    and damage you take is dampened 25 % (rule 6a) there.
  - Minor: Palace Array (Trận Cung). Your seat's formations need no upkeep. *(starter)*
  - Minor: Audience (Thiết Triều). NPCs come to your seat with offers (events).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **All under Heaven (Phổ Thiên Chi Hạ)** | keystone | Imperial Majesty applies to foes of your own realm as to lower ones | Foes of a higher realm deal you 15 % more (you do not bow) | Uy Nghiêm |
| **Son of Heaven (Thiên Tử)** | keystone | You may issue two Decrees | Each fight you lose costs 20 % of your treasury | Thánh Chỉ |

## New pieces

- Treasury, tribute, Decrees, the seat of power: `Needs key` (World Database, Travel & Map).

## Kept apart from

Thần Đạo (worship and shrines), Thiên Đạo (rules on both sides; Decrees bind only the foe for 10 s). Hoàng is
**majesty over the lesser, decrees, and the treasury**.
