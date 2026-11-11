# 34 · Hồn Đạo · *Nguyên Thần* (the Primordial Spirit: Soul)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. Holds the seed Soul (†).
> **Theme stats:** `than_thuc_pct`, `x_soul` (soul attack), `soul_res_pct`, `than_thuc_cost_pct`, `artifact_power_pct`,
> companion damage (spirit), `tam_ma_resist_pct`.
> **Road:** `than_thuc_pct` +0.9.

## Build directions

1. **The Soul Sniper.** The purest soul build: thần thức squared, the lockout as the only limit, so the Way's best
   pieces shorten or bend the lockout. Ignores every layer, ward and evade (Combat rule 24).
2. **The Soul Fortress.** Soul resistance and soul wards so high that soul builds bounce, with a reflect. The
   game needs a real answer to soul snipers; this is it.
3. **The Puppeteer.** Artifacts that act on their own (puppets) paid by thần thức: L3 and artifact actives as the
   main damage, with thần thức as both budget and power.
4. **Spirit Servant.** A spirit companion that scales with your thần thức instead of its own power share.

## Facets

### 1. Thần Thức (Divine Sense)
- **Small:** `than_thuc_pct` +0.9 · `than_thuc_cost_pct` −0.8
- **Stat notables:** Vast Sense (Thần Thức Rộng): thần thức ×2 · Light Grip (Nắm Nhẹ): thần thức cost ×2 · Inner Eye
  (Mắt Trong): thần thức +1, soul resist +1 · Sea of Mind (Thức Hải): thần thức +1, max linh lực +1
- **Effects:**
  - **Major: Overwhelming Sense (Thần Áp).** While your thần thức is at least 1.5× the foe's, your soul hits apply Pressed Mind (a curse: −15 % art speed, 3 pulses, refresh; `Needs key`).
  - Minor: Read the Foe (Dò Xét). At fight start you see the foe's slot order and guards (UI; the NPC AI also reads it), and your first soul art fires 0.5 s sooner. *(starter)*
  - Minor: Spare Sense (Thức Dư). +1 % `x_soul` per 5 % of your thần thức not used by artifacts (cap +12 %).

### 2. Hồn Kích (Soul Strike)
- **Small:** `x_soul` +1.5 · `than_thuc_pct` +0.5
- **Stat notables:** Soul Needle (Kim Hồn): soul attack ×2 · Mind Spear (Thương Tâm): soul +1, thần thức +1 · Shatter
  Thought (Phá Niệm): soul attack +2 · Piercing Will (Ý Xuyên): soul +1, thần thức +1
- **Effects:**
  - **Major: Twin Soul Strike (Song Hồn Kích).** Your soul lockout is 25 % shorter, and a soul art that fires the
    instant the lockout ends deals +10 % `x_soul`.
  - Minor: Soul Shock (Hồn Chấn). Your soul hits apply Slackened Soul (1 stack). *(starter)*
  - Minor: Mind Crack (Nứt Thần). Your soul hits on a target with negative soul resistance delay its next art by
    0.3 s (`delay_timer`, Effects rule 6, R1: repeats within 3 s fall off by half; `timer_resist_pct` shortens it).

### 3. Hồn Hộ (Soul Ward)
- **Small:** `soul_res_pct` +1 · `tam_ma_resist_pct` +1
- **Stat notables:** Iron Soul (Hồn Sắt): soul resistance ×2 · Clear Heart (Tâm Trong): heart-demon resist ×2 · Soul
  Bastion (Lũy Hồn): soul resist +1, thần thức +1 · Anchor (Neo Hồn): soul resist +1, max health +1
- **Effects:**
  - **Major: Mirror Soul (Hồn Kính).** 25 % of each soul hit that your soul resistance stops is dealt back to the
    attacker as Soul (it meets the attacker's soul resistance; not a soul art, so no lockout).
  - Minor: Steady Spirit (Hồn Vững). Slackened Soul cannot take your soul resistance below 0. *(starter)*
  - Minor: Ward of Mind (Hộ Thần). Your soul wards cost 20 % less.

### 4. Linh Bộc (Spirit Servants)
- **Small:** companion damage +2 · `than_thuc_pct` +0.5
- **Stat notables:** Bound Spirit (Linh Trói): companion ×2 · Spirit Tether (Dây Linh): companion +1, thần thức +1 ·
  Mind-Linked (Tâm Liên): thần thức ×2 · Faithful Spirit (Linh Trung): companion +1, soul resist +1
- **Effects:**
  - **Major: Spirit Servant (Linh Bộc).** Your companion's power share is replaced by your thần thức ratio over the
    foe's × 20 % (cap `c_comp_cap`). Its hits are Force. (Effects rule 16, R31: replaces the companion's power-share source)
  - Minor: Quick Spirit (Linh Nhanh). Your companion attacks 10 % faster. *(starter)*
  - Minor: Shared Sense (Cộng Thức). Your companion's hits on a foe give you +1 % thần thức for the fight (cap +10 %).

### 5. Khôi Lỗi (Puppetry)
- **Small:** `artifact_power_pct` +0.9 · `than_thuc_cost_pct` −0.8
- **Stat notables:** Puppet Master (Khôi Chủ): artifact power ×2 · Fine Strings (Dây Mảnh): thần thức cost ×2 ·
  Wooden Soldier (Lính Gỗ): artifact attack +2 · Jointed Limbs (Khớp Linh Hoạt): artifact power +1, artifact attack +1
- **Effects:**
  - **Major: Puppet Theatre (Khôi Lỗi Hí).** Up to 2 puppet artifacts you equip act on their own: each hits every
    `basic_cooldown` × 1.5 with Physical damage scaled by its artifact attack (an artifact-companion that takes no
    art slot; it counts against `equip.max_slots`; companions are one per source, Effects rule 16, R31).
  - Minor: Strings of Mind (Tơ Thần). Your puppets' damage is +1 % per 2 % of your thần thức above the foe's (cap
    +20 %). *(starter)*
  - Minor: Spare Parts (Phụ Tùng). Your puppets' first hits each fight come at 1 s.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **The Body Is a Vessel (Thân Vi Khí)** | keystone | Your soul arts share no lockout with each other: each has its own lockout | Your max health is 30 % lower and you cannot slot a ward in an art slot | Hồn Kích |
| **Primordial Spirit (Nguyên Thần Xuất Khiếu)** | keystone | Your thần thức counts 25 % higher for soul damage (inside the squared ratio) | Your non-soul hits deal 40 % less (L2 −40) | Thần Thức |
| **Unshakable Soul (Hồn Bất Động)** | keystone | While your linh lực is above 50 %, your soul resistance is +40 pp | Your ward strength is −30 % | Hồn Hộ |
| **Thousand Puppets (Thiên Khôi)** | keystone | Puppet Theatre runs 4 puppets | Your arts cost 30 % more | Khôi Lỗi |

## New pieces

- Puppets as artifact companions: Effects rule 16, R31 (one companion per source).
- Per-art soul lockouts (The Body Is a Vessel): Effects rule 16, R32 (capstone; this Way's cap shift, Dao rule 4).
- Showing the foe's slot order: UI, `Fits today`.

## Kept apart from

Quỷ Đạo (ghost companions and possession); Kỹ Đạo's Khôi Lỗi Thuật (making puppets as a craft); Phân Thân (clones).
Hồn is **the soul sniper, the soul fortress and the puppets of the mind**.
