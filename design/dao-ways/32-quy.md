# 32 · Quỷ Đạo · *U Minh* (the Netherworld)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** companion damage, `attack_pct` (soul, chaos, ghost fire), `than_thuc_pct`, `soul_res_pct`,
> `status_duration_pct` (curse), `evade_pct`.
> **Road:** `attack_pct` soul +1.5.

## Build directions

1. **The Ghost Host.** A ghost companion whose hits are Soul, so it ignores the foe's wards entirely: a
   companion-carry build with a damage type nothing else gives a companion.
2. **Possession.** Soul hits Possess the foe: its next art also strikes itself. Stronger the bigger the foe's
   arts: a mirror that turns burst builds on their owners.
3. **The Haunting.** Curses that outlive their caster: if you go Down, your curses stay on the winner and tick,
   and if you die, a haunt follows your killer for a year (a world-level revenge).
4. **Ghost Fire.** Soul damage over time, a new tick type for soul builds (Quỷ Hỏa), bounded by the lockout's
   spirit.

## Facets

### 1. Quỷ Bộc (Ghost Servants)
- **Small:** companion damage +2 · `than_thuc_pct` +0.9
- **Stat notables:** Bound Ghost (Quỷ Trói): companion damage ×2 · Cold Hands (Tay Lạnh): companion +1, thần thức
  +1 · Night Retainer (Gia Nhân Đêm): companion +1, soul resist +1 · Grave Leash (Xích Mộ): thần thức ×2
- **Effects:**
  - **Major: Ghost Servant (Quỷ Bộc).** You may bind a ghost as your companion (acquired by defeating a ghost creature). Its hits are Soul hits by Formulas E2, at its power share, and meet only soul resistance and soul wards. `Needs key` (ghost companion kind).
  - Minor: Restless Servant (Bộc Bất An). Your companion's first hit each fight comes at 1 s. *(starter)*
  - Minor: Chill Touch (Hàn Thủ). Your companion's hits apply 1 Slackened Soul stack every 4th hit.

### 2. Nhập Xác (Possession)
- **Small:** `attack_pct` soul +1.5 · `status_duration_pct` +2
- **Stat notables:** Ride the Flesh (Cưỡi Xác): soul attack ×2 · Slip Inside (Lẻn Vào): status duration ×2 · Hollow
  Eyes (Mắt Rỗng): soul attack +1, thần thức +1 · Puppet Strings (Dây Rối): soul +1, curse duration +1
- **Effects:**
  - **Major: Possess (Nhập).** Your soul hits apply Possessed (until the foe's next art fires, at most 5 pulses; 8 s reapply lockout): that art also deals 30 % of its damage to the foe itself. `Needs key` + `Needs rule` (self-damage from a foe's art).
  - Minor: Lingering Presence (Ám Ảnh). Possessed lasts 2 pulses. *(starter)*
  - Minor: Puppet's Fumble (Rối Vụng). A Possessed foe's arts cost 20 % more.

### 3. Oán Hồn (Haunting)
- **Small:** `status_duration_pct` curse +2 · `attack_pct` chaos +1
- **Stat notables:** Grudge (Oán): curse duration ×2 · Wailing (Than Khóc): chaos ×2 · Unquiet Grave (Mồ Động):
  curse duration +1, chaos +1 · Black Grudge (Oán Đen): status resist +2
- **Effects:**
  - **Major: Haunt (Ám Hồn).** If you lose, a **haunt wound** runs on the winner, reported to the caller (Effects rules 10 and 11): −5 % to its fortune rolls for a year, and 1 % of max health lost at the start of each of its fights for a season. `Needs key` (a run-on wound).
  - Minor: Curse on the Killer (Rủa Kẻ Giết). The first curse you place each fight cannot be cleansed. *(starter)*
  - Minor: Ghostly Wail (Tiếng Than). When you fall below 30 % health, apply Withering to the foe.

### 4. Quỷ Hỏa (Ghost Fire)
- **Small:** `attack_pct` soul +1.5 · `soul_res_pct` +1
- **Stat notables:** Will-o'-Wisp (Ma Trơi): soul ×2 · Blue Flame (Lửa Xanh): soul +1, fire +1 · Cold Fire (Lửa
  Lạnh): soul resist ×2 · Lantern Ghost (Quỷ Đèn): soul +1, thần thức +1
- **Effects:**
  - **Major: Ghost Fire (Quỷ Hỏa).** Your soul hits apply Ghost Fire: a soul tick of 10 % of the hit, each pulse for
    3 pulses, meeting only soul resistance. Batches stack; a new batch cannot be applied during the soul lockout.
    `Needs key` (a soul tick; Combat Damage Types: "Soul never ticks").
  - Minor: Cold Glow (Ánh Lạnh). Ghost Fire on the foe gives you +10 % soul resistance. *(starter)*
  - Minor: Will-o'-Wisp Lure (Ma Trơi Dụ). A target bearing Ghost Fire has −5 pp evade.

### 5. Quỷ Môn (the Ghost Gate)
- **Small:** `evade_pct` +0.4 · companion damage +1
- **Stat notables:** Open Gate (Mở Cửa): companion ×2 · Gatekeeper (Giữ Cửa): evade ×2 · Hungry Ghosts (Ngạ Quỷ):
  companion +1, leech +0.3 · Seventh Month (Tháng Bảy): soul +2
- **Effects:**
  - **Major: Open the Ghost Gate (Khai Quỷ Môn).** Every 5 s, a wandering ghost strikes the foe: a soul trigger hit by Formulas E2 at 40 % of your weakest soul art, inside `trig_budget`, outside the soul lockout.
  - Minor: Ghost Month (Tháng Cô Hồn). In the seventh month of the year, your soul damage is +15 %. `Needs key`
    (calendar readable). *(starter)*
  - Minor: Shut the Gate (Đóng Cửa). Soul hits on you are 15 % weaker.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Dead Fight for You (Quỷ Binh)** | enabler | Your ghost companion's power share counts at 50 % against `c_comp_cap` and its hits apply Possessed | You cannot slot soul arts yourself | Quỷ Bộc |
| **Netherworld (U Minh)** | keystone | With a ghost companion, its hits and Ghost Gate strikes may apply Ghost Fire during the soul lockout | Your non-soul hits deal 30 % less (L2 −30) | Quỷ Hỏa |
| **Puppet of the Dead (Hồn Khôi)** | keystone | Possessed sends 60 % back | Possess's reapply lockout is 12 s | Nhập Xác |
| **Undying Grudge (Oán Bất Tán)** | keystone | The haunt wound is reported even when you flee or draw, and its health loss is 2 % | Your max health is 25 % lower | Oán Hồn |

## New pieces

- Ghost companion with Soul hits: `Needs key`.
- Possessed (foe's art hits itself): `Needs key` + `Needs rule`.
- A soul tick (Ghost Fire): `Needs rule` (Combat Damage Types rule 1).
- Calendar readable: `Needs key`.

## Kept apart from

Hồn Đạo (the soul as craft: divine sense, puppetry); Hoàng Tuyền (lanterns of souls); Cốt Đạo (bone servants).
Quỷ is **a soul companion, possession and the haunting curse**.
