# 93 · Vực Đạo · *Lĩnh Vực* (Domain)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `formation_power_pct`, `defense_pct`, `attack_pct`, `than_thuc_pct`, `linh_luc_pct`,
> `status_duration_pct`, `art_speed_pct`.
> **Road:** `than_thuc_pct` +0.9.

## Build directions

A **Domain** is a new fight object: unfolded mid-fight by an art-like action, it lasts a set time and, while up,
applies its Rules to both sides inside it, with you as its lord. It is L4 (ground) that you bring yourself.

1. **The Domain Lord.** Ground everywhere: a Domain counts as home ground of your choosing, so L4 ground tags
   follow you into ambushes and blind fights (Vực Thần). The answer to "L4 is gone in a blind fight".
2. **Domain Rules.** Pick the Rules your Domain imposes (no evade, cooldowns +20 %, stacks double for the lord):
   a mid-fight rule-change (Vực Quy) that differs from Thiên Đạo's whole-fight Rule.
3. **The Pressing Domain.** A Domain that slows and weakens the foe each second it stands inside (Vực Áp).
4. **The Sanctuary.** A Domain that is a ward: inside it, you take less and regenerate more (Vực Hộ).

## Facets

### 1. Triển Vực (Unfolding)
- **Small:** `than_thuc_pct` +0.9 · `linh_luc_pct` +1.2
- **Stat notables:** Open the Realm (Mở Cõi): thần thức ×2 · Deep Reserve (Dự Trữ Sâu): max linh lực ×2 · Wide Sense
  (Thức Rộng): thần thức +1, max linh lực +1 · Swift Unfolding (Triển Nhanh): art speed +2
- **Effects:**
  - **Major: Unfold the Domain (Triển Khai Lĩnh Vực).** Unlocks your Domain: it unfolds at a time or guard you set
    (default 10 s), costs 20 % of max linh lực, and lasts 12 s; once per fight (twice with capstones). While up, your
    L4 is +20 and your Domain's Rules apply. (The Domain is the one carried ground that unfolds mid-fight: Combat rule 12, R9.)
  - Minor: Quick Unfolding (Triển Tốc). Your Domain unfolds 3 s sooner. *(starter)*
  - Minor: Lingering Domain (Vực Lưu). Your Domain lasts 3 s longer.

### 2. Vực Quy (Domain Rules)
- **Small:** `status_duration_pct` +2 · `attack_pct` +1
- **Stat notables:** Law of the Land (Luật Đất): status duration ×2 · Lord's Word (Lời Chủ): attack ×2 · Bound Ground
  (Đất Trói): status duration +1, attack +1 · Edict (Chiếu Lệnh): defense +2
- **Effects:**
  - **Major: Domain Rules (Vực Quy).** Choose 2 Rules for your Domain from: *No Evade* (evade is 0 inside), *Heavy Air*
    (each foe art that fires inside is delayed 0.5 s: `delay_timer`, Effects rule 6, R1), *Lord's Stacks* (your stacks granted inside are doubled), *Silent Ground* (the
    foe's quick arts cannot fire), *Bright Ground* (Exposed on the foe while inside).
  - Minor: Third Rule (Quy Thứ Ba). Your Domain holds 3 Rules.
  - Minor: Rule Echo (Quy Vọng). A Rule lingers 2 s after the Domain folds.

### 3. Vực Áp (Domain Pressure)
- **Small:** `attack_pct` +1 · `art_speed_pct` +0.5
- **Stat notables:** Crushing Air (Khí Đè): attack ×2 · Weight of the Realm (Sức Nặng Cõi): art speed ×2 · Pressing Down
  (Đè Xuống): attack +1, art speed +1 · Heavy Sky (Trời Nặng): force +2
- **Effects:**
  - **Major: Domain Pressure (Vực Áp).** Each second the foe spends inside your Domain, it gains 1 stack of Slowed Time
    (6 % per stack, cap 5: Effects Status Catalogue, R1) and 1 stack of Sundered (named curses, durations clamped 1–5
    pulses, R17, R22).
  - Minor: Pressure Point (Điểm Áp). The first second of your Domain applies Sealed Meridian on L4 to the foe.
    *(starter)*
  - Minor: No Room to Breathe (Ngột Ngạt). The foe regenerates 25 % less linh lực inside your Domain.

### 4. Vực Hộ (Domain Ward)
- **Small:** `defense_pct` +1.2 · `health_regen_pct` +0.05
- **Stat notables:** Sanctuary (Thánh Địa): defense ×2 · Safe Ground (Đất Lành): regen ×2 · Walled Realm (Cõi Có Tường):
  defense +1, regen +0.05 · Lord's Shelter (Chủ Che): soul resist +2
- **Effects:**
  - **Major: Sanctuary (Vực Hộ).** Inside your Domain damage you take is dampened 20 % (rule 6a) and your regeneration of both pools is
    doubled.
  - Minor: Safe Unfolding (Triển An). Unfolding the Domain cleanses 5 debuff stacks. *(starter)*
  - Minor: Domain Shield (Thuẫn Vực). When your Domain folds, restore a body shield of 4 % of max health.

### 5. Vực Thần (Domain Lord)
- **Small:** `formation_power_pct` +1.2 · `than_thuc_pct` +0.5
- **Stat notables:** Lord of the Ground (Chủ Đất): formation power ×2 · Rooted Realm (Cõi Bám Rễ): thần thức ×2 · Home
  Everywhere (Đâu Cũng Nhà): formation +1, thần thức +1 · Throne of Earth (Ngai Đất): defense +2
- **Effects:**
  - **Major: Domain Lord (Vực Chủ).** Your Domain counts as a ground of your choosing (your best ground tags), so
    ground-scoped L4 modifiers apply inside it in any fight situation, blind included.
  - Minor: Carry the Ground (Mang Đất). In a blind fight, your Domain unfolds at 6 s. *(starter)*
  - Minor: Ground Memory (Đất Nhớ). Formations you laid this season add 50 % of their power inside your Domain.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Within My Domain, I Decide (Vực Trung Ngã Chủ)** | keystone | Your Domain unfolds twice per fight and holds 3 Rules | Outside your Domain, your hits deal 25 % less (L2 −25) | Vực Quy |
| **Endless Domain (Vô Biên Lĩnh Vực)** | keystone | Your Domain, once unfolded, never folds | It costs 40 % of max linh lực and unfolds no sooner than 15 s | Triển Vực |
| **Domain of Crushing Heaven (Thiên Áp Vực)** | keystone | Domain Pressure applies 2 stacks of each curse per second (Slowed Time keeps its cap of 5) | You cannot evade or escape inside your Domain | Vực Áp |

## New pieces

- The Domain object (a timed, self-carried ground with Rules): carried ground, Combat rule 12 (R9); the Way's whole
  engine. Its Rules list is this Way's own.

## Kept apart from

Thiên Đạo (a whole-fight Rule chosen before), Trận Đạo's Động Phủ (home ground as a cave), Tinh's Array in the Sky
(a formation carried). Vực is **ground you unfold, rules for a while, and pressure inside it**.
