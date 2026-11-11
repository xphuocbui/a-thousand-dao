# 30 · Bỉ Ngạn Đạo · *Bỉ Ngạn Hoa Khai* (The Other Shore; the Far-Shore Flower Blooms)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `attack_pct` (fire, chaos, soul), `escape_pct`, `status_duration_pct` (curse), `ngo_tinh` (comprehension),
> `soul_res_pct`, `tam_ma_resist_pct`, `khi_huyet_pct`.
> **Road:** `soul_res_pct` +1.

## Build directions

1. **Red Petals.** A burst bank that fills as health falls: each 10 % of health lost grows a petal; at the Down
   step every petal bursts (Hồng Hoa). A build that wants to be nearly beaten.
2. **Forgetting.** Curses that make the foe forget: Silence of its last-fired art, Sealed Meridian on its biggest
   layer, on a cycle (Vong Xuyên). The memory-wipe controller.
3. **The Crossing.** Survival and escape at the edge: the build that leaves every losing fight alive (Độ).
4. **Awakening.** Insight from near-death: comprehension and heart-demon clarity gained by surviving at low health
   (Giác Ngộ). A life-around-the-fight build.

## Facets

### 1. Bỉ Ngạn Hoa (the Spider Lily)
- **Small:** `attack_pct` fire +1 · `attack_pct` chaos +1
- **Stat notables:** Red Lily (Huyết Lan): fire +1, chaos +1 ×2 · Leafless Stem (Cọng Không Lá): crit damage +2 ·
  Riverbank Bloom (Hoa Bờ Sông): chaos ×2 · Funeral Red (Đỏ Tang): fire penetration +2
- **Effects:**
  - **Major: Flower without Leaves (Hoa Lá Bất Tương Kiến).** Your Fire and Chaos parts never meet the same
    defence twice: a hit that has both types converts its smaller part to whichever type the foe resists less.
    (`convert_to: least_resisted`, decided when the hit lands; a major, so allowed; it uses one of the 2 conversions: Combat Damage Types rule 6, R10.)
  - Minor: Lily Root (Rễ Lan). Your Chaos hits apply 2 Burn stacks for 6 pulses and your Fire hits apply 2 Poison stacks for 6 pulses.
    *(starter)*
  - Minor: Blooming in Autumn (Nở Mùa Thu). After 30 s of fight, your Fire and Chaos hits deal more (L5 +12).

### 2. Độ (Crossing)
- **Small:** `escape_pct` +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Ferry (Đò Ngang): escape ×2 · Far Bank (Bờ Xa): max health ×2 · Oarsman (Người Chèo): escape
  +1, evade +1 · Calm Water (Nước Lặng): regen +0.1
- **Effects:**
  - **Major: To the Other Shore (Đáo Bỉ Ngạn).** Your escape art fires automatically at 15 % health whatever its
    guard and slot, once per fight, with +30 % chance. It takes no art slot: it sits in a free escape slot (`free_slots[escape]`, Combat rule 13, R4).
  - Minor: Ferryman's Fee (Tiền Đò). A failed escape restores 10 % of max health. *(starter)*
  - Minor: Mist on the River (Sương Sông). Pursuers cannot lower your escape chance below 30 %.

### 3. Vong Xuyên (River of Forgetting)
- **Small:** `status_duration_pct` curse +2 · `attack_pct` soul +1
- **Stat notables:** Grey Water (Nước Xám): curse duration ×2 · Forgetful Cup (Chén Quên): soul attack ×2 · Blank
  Mind (Tâm Trống): curse duration +1, soul attack +1 · Drowned Memory (Ký Ức Chìm): thần thức +2
- **Effects:**
  - **Major: Forget (Lãng Quên).** Every 9 s, Silence the foe's form tag that has the most slotted arts, for 2 pulses (`Needs rule`: no reapply lockout on this Silence).
  - Minor: Lost Thread (Mất Mạch). Your soul hits delay the foe's next art by 0.3 s (`delay_timer`, Effects rule 6, R1: repeats within 3 s fall off by half; `timer_resist_pct` shortens it).
  - Minor: Meng's Soup (Canh Quên). The first curse each fight you place lasts 2 pulses longer. *(starter)*

### 4. Giác Ngộ (Enlightenment)
- **Small:** `ngo_tinh` (comprehension) +1 · `tam_ma_resist_pct` +1
- **Stat notables:** Clear Shore (Bờ Trong): comprehension ×2 · Still Mind (Tâm Tĩnh): heart-demon resist ×2 ·
  Lotus Thought (Niệm Sen): comprehension +1, soul resist +1 · Far-Seeing (Nhìn Xa): thần thức +2
- **Effects:**
  - **Major: Enlightened at the Edge (Lâm Tử Ngộ Đạo).** Each fight you win after falling below 15 % health grants
    comprehension progress equal to a week of study and removes 5 heart demon. `Needs key` (Character Stats
    progress).
  - Minor: Unafraid (Vô Úy). Below 30 % health, Afraid (Tình's proposed curse) and Silence on you last 1 pulse less. *(starter)*
  - Minor: See the Shore (Kiến Ngạn). Your breakthrough chance +1 pp after a fight won below 15 % (q-extras, counted
    under the ceiling).

### 5. Hồng Hoa (Red Petals)
- **Small:** `attack_pct` +1.2 · `khi_huyet_pct` +0.5
- **Stat notables:** Petal Fall (Cánh Rơi): attack ×2 · Crimson Field (Đồng Đỏ): crit damage ×2 · Thousand Petals
  (Ngàn Cánh): attack +1, max health +1 · Withered Red (Đỏ Úa): fire +1, chaos +1
- **Effects:**
  - **Major: Red Petals (Hồng Hoa Tán).** For each 10 % of max health you have lost (from full), grow 1 Petal (they
    do not shrink when healed). At the Down step's last act, each Petal deals 3 % of your max health as Fire to the
    foe (a trigger inside `trig_budget`, Effects rule 7, R18). Petals are a self-counter that only grows (tag `growing`, Effects rule 8, R7).
  - Minor: Petal Shield (Thuẫn Cánh). Each Petal gives a body shield of 2 % of max health. *(starter)*
  - Minor: Early Bloom (Nở Sớm). Once per fight, at 5 Petals, release 2 of them at once (they are spent).

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Death and Awakening, One Shore (Sinh Tử Nhất Ngạn)** | keystone | Red Petals may burst at a Down refusal you make instead of the last act (Petals reset when they burst) | Your health regeneration is dampened by 100 (halved) | Hồng Hoa |
| **The Far-Shore Flower Blooms (Bỉ Ngạn Hoa Khai)** | keystone | Petals grow per 5 % lost | Your max health is 30 % lower | Hồng Hoa |
| **River without Return (Bất Quy Xuyên)** | keystone | Forget fires every 6 s | You apply no curse other than Forget's Silence | Vong Xuyên |
| **The Other Shore (Bỉ Ngạn)** | keystone | To the Other Shore always succeeds | Fights you flee count as defeats for heart demon, doubled | Độ |

## New pieces

- Petals (a counter that only grows): a self-counter, tag `growing` (Effects rule 8, R7).
- `status_duration_pct` [curse]: the key exists (Modifiers Stat List); durations clamp to 1–5 pulses (R22).
- Progress gained from a fight (Enlightened at the Edge): `Needs key`.

## Kept apart from

Sinh Tử (the threshold refused), Luân Hồi (rebirth), Hoàng Tuyền (last words). Bỉ Ngạn is **petals that burst
at the edge, forgetting, and always reaching the far shore**.
