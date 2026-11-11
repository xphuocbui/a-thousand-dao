# 61 · Trấn Đạo · *Trấn Thiên* (Suppressing Heaven: Sealing)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `status_duration_pct` (curse), `attack_pct` (seal, force), `formation_power_pct`, `than_thuc_pct`,
> creature damage, `defense_pct`, `status_resist_pct`.
> **Road:** `status_duration_pct` curse +2.

## Build directions

1. **The Jailer.** Silence the foe's main tag and keep it silenced: Silence's 2-pulse lockout is the build's
   enemy, so Trấn plays with that rule (Phong Thuật). A pure control build.
2. **Qi Lock.** Lock the foe's regeneration and art payments together: Stagnation and a new curse, Sealed Qi,
   that caps how much linh lực the foe can spend per pulse. The anti-burst build.
3. **The Beast Tamer-Jailer.** Suppress creatures: big bonuses against beasts and the means to bind a beaten one
   (companion acquisition). A creature-hunting direction.
4. **Self-Seal.** Seal your own power at fight start and release it later, bigger: a delayed-power build with a
   visible charge bar.

## Facets

### 1. Phong Thuật (Seal Arts)
- **Small:** `status_duration_pct` curse +2 · `attack_pct` seal +1
- **Stat notables:** Iron Lock (Khóa Sắt): curse duration ×2 · Gag (Bịt Miệng): seal ×2 · Sealing Script (Phù Phong):
  curse duration +1, seal +1 · Heavy Lock (Khóa Nặng): status resist +2
- **Effects:**
  - **Major: Keep Them Silent (Vĩnh Cấm).** Silence you apply has no reapply lockout when it is reapplied by a
    different art than the one that applied it.
  - Minor: Name the Silence (Định Cấm). Silence you apply names the foe's tag with the most slotted arts. *(starter)*
  - Minor: Muffled (Bóp Nghẹt). A Silenced foe's basic attack deals 15 % less.

### 2. Khóa Khí (Seal Qi)
- **Small:** `attack_pct` force +1.5 · `status_duration_pct` +2
- **Stat notables:** Choke the Flow (Tắc Dòng): force ×2 · Closed Gate (Cổng Đóng): status duration ×2 · Pressure
  Point (Huyệt Đạo): force +1, curse duration +1 · Stilled Sea (Biển Lặng): force penetration +2
- **Effects:**
  - **Major: Sealed Qi (Phong Khí).** Your Force hits apply Sealed Qi: the target can spend at most 8 % of its max
    linh lực per pulse on arts (3 pulses, refresh). `Needs key` (new curse).
  - Minor: Close the Points (Điểm Huyệt). Your Force crits apply 3 Stagnation stacks. *(starter)*
  - Minor: Backed Up (Ứ). Arts the target cannot afford under Sealed Qi still start their cooldown (they are wasted).
    `Needs rule`.

### 3. Trấn Thú (Seal Beasts)
- **Small:** creature damage +2 · `defense_pct` +1.2
- **Stat notables:** Beast Chain (Xích Thú): creature damage ×2 · Iron Collar (Vòng Sắt): defense ×2 · Tamer's Eye
  (Mắt Thuần Thú): creature damage +1, thần thức +1 · Cage (Lồng): formation power +2
- **Effects:**
  - **Major: Bind the Beast (Thu Phục).** A creature you defeat while it bears a curse of yours can be bound as a
    companion without a taming roll (once per season). `Needs key` (Spirit Beasts, Event Engine).
  - Minor: Beast Fears the Seal (Thú Sợ Ấn). Creatures deal 10 % less to you. *(starter)*
  - Minor: Muzzled Companion (Rọ Mõm). The foe's companion deals 30 % less while its owner bears a curse of yours.

### 4. Lao Ngục (Prison)
- **Small:** `formation_power_pct` +1.2 · `escape_pct` (foe −, via Effects only)
- **Stat notables:** Prison Array (Trận Ngục): formation power ×2 · Locked Door (Cửa Khóa): curse duration +2 ·
  Warden (Cai Ngục): defense +1, formation +1 · Bars of Qi (Song Khí): force +2
- **Effects:**
  - **Major: No Escape (Bất Thoát).** Foes cannot escape from you, and their escape art's slot is Silenced for the
    fight.
  - Minor: Walls Close In (Tường Ép). Every 10 s of fight, apply Cornered to the foe (a curse: −2 pp evade per stack, stacks to 5, 5 pulses, refreshed by each new stack; `Needs key`). *(starter)*
  - Minor: Solitary (Biệt Giam). A foe with no companion takes more from your Force hits (L5 +10).

### 5. Tự Phong (Self-Seal)
- **Small:** `defense_pct` +1.2 · `attack_pct` +1
- **Stat notables:** Locked Strength (Lực Khóa): attack ×2 · Sealed Body (Thân Phong): defense ×2 · Coiled Spring
  (Lò Xo Nén): attack +1, crit damage +1 · Patience Seal (Ấn Nhẫn): max health +2
- **Effects:**
  - **Major: Break the Seal (Phá Phong).** At fight start your arts are sealed for 6 s (they do not fire); each
    second sealed stores L5 +8 (cap +48), released on your first 3 hits after the seal breaks.
  - Minor: Sealed Defence (Phòng Phong). While your arts are sealed, you take 25 % less damage. *(starter)*
  - Minor: Controlled Release (Thả Dần). The stored bonus spreads over 5 hits instead of 3, at 80 % each.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Nothing Moves without Leave (Vô Lệnh Bất Động)** | keystone | Your curses' reapply lockouts are 0 | You can hold at most 2 curses on a target | Phong Thuật |
| **Suppressing Heaven (Trấn Thiên)** | keystone | Sealed Qi's limit is 5 % and it also caps the foe's ward payments | Your own arts cost 25 % more | Khóa Khí |
| **Heaven Prison (Thiên Lao)** | keystone | Foes cannot escape, use talismans or take pills in fights against you | You cannot either | Lao Ngục |
| **Thousand-Year Seal (Thiên Niên Phong)** | keystone | Break the Seal may be held up to 20 s (cap +160, still bounded by L5's cap per hit) | Your basic attack is sealed too while your arts are | Tự Phong |

## New pieces

- Sealed Qi (spend cap per pulse): `Needs key`.
- Binding a beaten creature: `Needs key` (Spirit Beasts).
- Silence without lockout (Keep Them Silent, Nothing Moves): `Needs rule` (Status Catalogue reapply lockout).

## Kept apart from

Ấn Đạo (seal marks and detonation; Trấn is suppression and prisons); Thời Đạo's Ngưng (time-freeze). Trấn is
**silence held, qi locked, beasts bound, power stored**.
