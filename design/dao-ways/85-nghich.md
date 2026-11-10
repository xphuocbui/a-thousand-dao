# 85 · Nghịch Đạo · *Nghịch Thiên Cải Mệnh* (Defy Heaven, Change Fate)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `pierce_pct`, `attack_pct`, `khi_huyet_pct`, `resist_pct` (lightning), `tam_ma_resist_pct`,
> `crit_damage_pct`, `status_resist_pct`.
> **Road:** `pierce_pct` +0.5.

## Build directions

1. **Behind on Points.** Power that reads the **gap** between you and the foe (health share, realm, power), not
   your own state: when you are losing, you hit harder; when you are winning, you hit normally. A comparative
   build: strongest exactly when the fight is going wrong.
2. **The Giant Killer.** Fight upward: pierce past its cap by Effect, suppression turned into fuel (Vượt Cấp). The
   build for the player who wants to beat the realm above.
3. **Unbreakable.** No single hit can take more than a set share of your health (Bất Phục): the anti-one-shot
   build in a game where top builds end fights in a volley.
4. **Rewrite Fate.** Reroll breakthrough failures and tribulation odds (Cải Mệnh; Effects may pass the q-extras
   ceiling, dao.md rule 4).

## Facets

### 1. Nghịch Cảnh (Against the Odds)
- **Small:** `attack_pct` +1.2 · `khi_huyet_pct` +0.5
- **Stat notables:** Underdog (Kẻ Yếu): attack ×2 · Hard Times (Thời Khó): max health ×2 · Grit (Gan Lì): attack +1,
  max health +1 · Back to the Wall (Lưng Tựa Tường): crit damage +2
- **Effects:**
  - **Major: Against the Current (Nghịch Lưu).** Your hits deal more by how far your health share is below the foe's
    (L5 +1 per 1 % of the gap, cap +50).
  - Minor: Turnaround (Lật Ngược). When your health share falls below the foe's for the first time, cleanse every
    curse on you. *(starter)*
  - Minor: Spite (Hờn). While behind, your crits deal +15 % more.

### 2. Vượt Cấp (Fighting Upward)
- **Small:** `pierce_pct` +0.5 · `attack_pct` +1
- **Stat notables:** Climb (Leo): pierce ×2 · Reach Above (Với Cao): attack ×2 · Rising Star (Sao Mới): pierce +1,
  attack +1 · Sharper Than Rank (Bén Hơn Cấp): crit damage +2
- **Effects:**
  - **Major: Leap the Realm (Vượt Cảnh).** Against a foe of a higher realm, your pierce may exceed `pierce_cap` by 10
    pp and each 1 pp of suppression you still suffer gives L5 +1 (cap +30).
  - Minor: Measure the Giant (Đo Khổng Lồ). Against a higher realm, your first art fires at half cooldown. *(starter)*
  - Minor: Earned Respect (Được Kính Nể). A cultivator of a higher realm you defeat grants double World Database
    renown. `Needs key`.

### 3. Nghịch Kiếp (Defying Tribulation)
- **Small:** `resist_pct` lightning +1.5 · `tam_ma_resist_pct` +1
- **Stat notables:** Heaven Defier (Kẻ Nghịch Thiên): lightning resistance ×2 · Iron Heart (Tâm Sắt): heart-demon
  resist ×2 · Storm Body (Thân Bão): lightning resist +1, max health +1 · Defiant Will (Ý Nghịch): status resist +2
- **Effects:**
  - **Major: Defy the Tribulation (Nghịch Kiếp).** In a heavenly tribulation fight, your hits deal more by the
    tribulation's wave number (L5 +8 per wave survived) and its first bolt is halved.
  - Minor: Tribulation-Hardened (Kiếp Rèn). After each tribulation survived, +2 % lightning resistance for life (cap
    +20 %). *(starter)*
  - Minor: Shout at Heaven (Quát Trời). Heart demon from a failed tribulation wave is halved.

### 4. Bất Phục (Unyielding)
- **Small:** `khi_huyet_pct` +1 · `status_resist_pct` +1
- **Stat notables:** Never Kneel (Không Quỳ): max health ×2 · Unbowed (Không Cúi): status resist ×2 · Standing Still
  (Vẫn Đứng): max health +1, block +1 · Last Breath Fight (Đánh Đến Hơi Cuối): regen +0.1
- **Effects:**
  - **Major: Unyielding (Bất Khuất Bất Phục).** No single hit can take more than 25 % of your max health (the rest is
    stopped). Ticks are not hits.
  - Minor: Stand Back Up (Đứng Dậy). After a hit that took 15 %+ of your max health, regenerate 5 % over 2 s.
    *(starter)*
  - Minor: Will over Wound (Ý Thắng Thương). While below 50 % health, curses on you last 1 pulse less.

### 5. Cải Mệnh (Rewriting Fate)
- **Small:** fortune +1 · `crit_damage_pct` +1
- **Stat notables:** Torn Page (Trang Rách): fortune ×2 · Own Hand (Tay Mình): crit damage ×2 · Rewrite (Viết Lại):
  fortune +1, crit damage +1 · Changed Star (Sao Đổi): status resist +2
- **Effects:**
  - **Major: Change Fate (Cải Mệnh).** Once per realm, a failed breakthrough may be rerolled. Each reroll adds 10 heart
    demon. (Rule 4 exception: an Effect on breakthrough odds; bot fixture required, AC-DAO-29.)
  - Minor: Fate's Debt (Nợ Mệnh). After a failed breakthrough, your next attempt has +2 pp (q-extras, inside the
    ceiling). *(starter)*
  - Minor: Defy the Roll (Nghịch Số). The first crit against you each fight is rerolled.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Weaker You Are, the Harder You Strike (Nhược Giả Cường Kích)** | keystone | Against the Current counts the gap twice (L5 +2 per 1 %, cap +80) | While your health share is above the foe's, your hits deal 25 % less (L2 −25) | Nghịch Cảnh |
| **Defy Heaven (Nghịch Thiên)** | keystone | Leap the Realm also works against equals: suppression you do not suffer still counts as 10 pp | Against lower realms, your hits deal 30 % less | Vượt Cấp |
| **Unbreakable Will (Ý Chí Bất Diệt)** | keystone | Unyielding's limit is 15 % | Your max health is 20 % lower | Bất Phục |
| **Change Fate (Nghịch Thiên Cải Mệnh)** | keystone | Change Fate works twice per realm | Every breakthrough you attempt, success or not, adds 10 heart demon | Cải Mệnh |

## New pieces

- Per-hit damage limit (Unyielding): `Needs rule` (Combat Defence path), and a strong counter to burst: flag for
  balance.
- Pierce past its cap: a cap shift, `Needs rule`.

## Kept apart from

Nhẫn Đạo (power from damage taken over time; Nghịch reads the gap now), Kiếp Đạo (tribulation as fuel for life),
Sinh Tử (the Down refused). Nghịch is **power from being behind, fighting upward, and a cap on any single blow**.
