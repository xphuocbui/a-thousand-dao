# 28 · Luân Hồi Đạo · *Lục Đạo Luân Hồi* (the Wheel of Rebirth; the Six Paths)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. Holds the seed Reincarnation (†).
> **Theme stats:** `attack_pct`, `khi_huyet_pct`, `ngo_tinh` (comprehension), `soul_res_pct`, `than_thuc_pct`, `stack_duration_pct`,
> `healing_pct`.
> **Road:** `soul_res_pct` +1.

## Build directions

1. **The Wheel.** A rotating buff: every 6 s the Wheel turns to the next of six Paths, each a different bonus
   (damage, defence, speed, sustain, soul, crit). A loadout tuned to the Paths' order is a min-max puzzle.
2. **Rebirth.** Survive a Down by being reborn with a different loadout (the second half of the fight is a new
   build). The comeback build.
3. **Past Lives.** Life-around-the-fight: carry insight and a sliver of power from previous characters (a meta
   progression across lives, if the game allows it) or from previous realms.
4. **Cycling Stacks.** Element stacks that cycle: when a batch expires, it returns as the next element in the
   generating cycle (with Ngũ Hành).

## Facets

### 1. Bánh Xe (the Wheel)
- **Small:** `attack_pct` +1.2 · `stack_duration_pct` +2
- **Stat notables:** Turning (Quay): attack ×2 · Spoke and Rim (Nan Vành): stack duration ×2 · Axle (Trục): attack
  +1, max health +1 · Momentum of Ages (Đà Kiếp): crit damage +2
- **Effects:**
  - **Major: The Wheel Turns (Luân Chuyển).** Every 6 s the Wheel moves to the next Path, in order: Heaven (L5 +20),
    Asura (crit chance +10 pp), Human (art speed +20 %), Beast (block +40), Hungry Ghost (leech +3 %), Hell (all
    resistance +40). You may choose the starting Path before the fight.
  - Minor: Wheel Spins Faster (Quay Nhanh). The Wheel turns every 5 s. *(starter)*
  - Minor: Hold the Path (Giữ Đạo). Once per fight, when you crit, the current Path holds for one extra turn.

### 2. Tiền Kiếp (Past Lives)
- **Small:** `ngo_tinh` (comprehension) +1 · `than_thuc_pct` +0.9
- **Stat notables:** Old Memory (Ký Ức Xưa): comprehension ×2 · Many Faces (Nhiều Mặt): thần thức ×2 · Remembered
  Art (Chiêu Nhớ): comprehension +1, thần thức +1 · Deja Vu (Quen Thuộc): soul resist +2
- **Effects:**
  - **Major: Memory of Lives (Túc Tuệ).** At a glimpse, you may be offered one Dao your previous character held (if
    any) as a fourth choice. `Needs rule` (meta progression across lives; Save/Load).
  - Minor: Familiar Art (Chiêu Quen). Techniques of a kind you have mastered before in this life learn 20 % faster.
    *(starter)*
  - Minor: Old Enemy (Cừu Cũ). Your hits deal more to a cultivator who has defeated you before (L5 +15).

### 3. Tái Sinh (Rebirth)
- **Small:** `khi_huyet_pct` +1 · `healing_pct` +1.5
- **Stat notables:** New Flesh (Thịt Mới): max health ×2 · Reborn Blood (Huyết Tái): healing ×2 · Seedling Body
  (Thân Mầm): max health +1, regen +0.05 · Second Dawn (Bình Minh Hai): healing +1, max health +1
- **Effects:**
  - **Major: Rebirth (Tái Sinh).** Once per fight, at the Down step's refusal, refuse it (health 1) and switch to your second loadout (a saved art set and slot order prepared before the fight): its arts start on full cooldown and reservations are retaken. Then heal 50 % of max health (a heal; `no_heal` blocks it). `Needs rule` (a second loadout).
  - Minor: Shed the Old (Lột Xác). When reborn, every debuff and curse on you is removed. *(starter)*
  - Minor: Infant Strength (Lực Hài Nhi). For 5 s after a rebirth, your hits deal more (L5 +30).

### 4. Vãng Sinh (Passage)
- **Small:** `soul_res_pct` +1 · `attack_pct` soul +1.5
- **Stat notables:** Ferry of Souls (Đò Hồn): soul resistance ×2 · Passing Bell (Chuông Tiễn): soul attack ×2 ·
  Guiding Lamp (Đèn Dẫn): thần thức +1, soul resist +1 · Mantra of Passage (Chú Vãng Sinh): soul attack +1, thần
  thức +1
- **Effects:**
  - **Major: Send On (Tiễn Đưa).** Your soul hits gain +1 % `x_soul` per 2 pp of the foe's health below 50 % (cap +25 %). Soul ignores layers, so this is the soul build's execute.
  - Minor: Calm Passage (Tĩnh Độ). Your soul lockout is 0.2 s shorter. *(starter)*
  - Minor: Released (Siêu Thoát). Ghost and undead creatures take 20 % more from you. `Needs key` (undead tag).

### 5. Lục Đạo (the Six Paths)
- **Small:** `attack_pct` +1.2 · `khi_huyet_pct` +0.5
- **Stat notables:** Six Gates (Lục Môn): attack ×2 · Path Walker (Hành Giả): attack +1, max health +1 · Between
  Worlds (Giữa Cõi): soul resist +1, attack +1 · Karma Wheel (Pháp Luân): crit chance +2
- **Effects:**
  - **Major: Walk All Six (Lục Đạo Hành).** Each Path you have been on this fight leaves 30 % of its bonus behind
    for the rest of the fight (so by 36 s you hold 30 % of all six, plus the current one).
  - Minor: Asura's Path (Đạo Tu La). While on the Asura Path, your crits apply 2 Bleed stacks. *(starter)*
  - Minor: Hell's Path (Đạo Địa Ngục). While on the Hell Path, curses on you last 1 pulse less.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Death Is a Door (Tử Tức Môn)** | keystone | Rebirth may refuse twice (`Needs rule` R5); the second switch returns to your first loadout | Your max health is 30 % lower | Tái Sinh |
| **Turn the Wheel by Hand (Thủ Chuyển Luân)** | keystone | You choose the Wheel's order before the fight and may skip one Path | The Wheel turns every 8 s whatever else says (Wheel Spins Faster does nothing) | Bánh Xe |
| **Six Paths as One (Lục Đạo Quy Nhất)** | keystone | Walk All Six's residue is 50 % (not 30 %) | The Wheel turns every 9 s | Lục Đạo |
| **Eternal Return (Vĩnh Hồi)** | keystone | At each pulse, each of your element buff batches that expired that pulse returns once as the next element in the generating cycle (Wood → Fire → Earth → Metal → Water), at half size, for its original duration. A returned batch never returns again | Your batches last 30 % shorter | Bánh Xe |

## New pieces

- A second loadout used after a rebirth: `Needs rule` (Combat rule 13, loadout).
- Meta progression across lives (Memory of Lives): `Needs rule`; big design question for the user.
- `undead` foe tag: `Needs key`.

## Kept apart from

Sinh Tử (healing both ways, the threshold); Nhân Quả (karma debts); Ngũ Hành (the cycles as elements; Eternal
Return only borrows the order). Luân Hồi is **the turning wheel and the second life within the fight**.
