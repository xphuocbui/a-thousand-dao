# 89 · Vô Vi Đạo · *Vô Vi Nhi Trị* (Rule by Not Acting)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `defense_pct`, `ward_efficiency_pct`, `health_regen_pct`, `linh_luc_regen_pct`, `attack_pct`
> (over_time), `block_rating`, `body_shield_pct`.
> **Road:** `ward_efficiency_pct` +1.2.

## Build directions

1. **The Idle Master.** Power while no art of yours fires: a build with few, slow arts whose idle time is the
   resource (Bất Động Thủ). Pairs with long cooldowns and ticks.
2. **Let It Happen.** Wards, ticks and counters do the work: everything that is not an art you cast gets stronger
   (Tự Nhiên). The passive build: formations, wards, statuses, the companion.
3. **Yielding.** Counters: each hit you take, softened, returns as a push (Thuận); water-like defence.
4. **Keeping Soft.** Damage taken is softened by a share, more the softer you are (low ward, low block): a
   counter-intuitive tank (Thủ Nhu).

## Facets

### 1. Bất Động Thủ (Not Striking)
- **Small:** `defense_pct` +1.2 · `linh_luc_regen_pct` +0.075
- **Stat notables:** Folded Hands (Khoanh Tay): defense ×2 · Empty Moment (Lúc Rảnh): linh lực regen ×2 · Still Hand
  (Tay Yên): defense +1, regen +0.05 · Waiting Power (Lực Chờ): attack +2
- **Effects:**
  - **Major: Not Striking (Bất Xuất Thủ).** For each second in which none of your arts fires, gain 1 Stillness (cap 20):
    your wards are +2 % stronger per Stillness, and your next art consumes them for L5 +3 each.
  - Minor: Idle Breath (Hơi Rảnh). While no art has fired for 2 s, your linh lực regeneration is doubled. *(starter)*
  - Minor: Patient Hand (Tay Nhẫn). Your arts with a cooldown of 10 s or more cost 25 % less.

### 2. Tự Nhiên (Let It Happen)
- **Small:** `attack_pct` over_time +1.5 · `ward_efficiency_pct` +1.2
- **Stat notables:** Nature's Course (Lẽ Tự Nhiên): over-time ×2 · Self-Running (Tự Vận): ward efficiency ×2 · Flow of
  Things (Dòng Vật): over-time +1, ward +1 · Unforced (Không Ép): formation power +2
- **Effects:**
  - **Major: Things Happen of Themselves (Vạn Vật Tự Hóa).** Damage from sources that are not your arts or basic attack
    (ticks, triggers, your companion, formations, ward retaliation) is increased by 30 % (L4 +30 for ticks and
    formations; L5 +30 for triggers).
  - Minor: Self-Mending (Tự Lành). Your wards heal you for 0.5 % of max health each time they stop a hit fully.
    *(starter)*
  - Minor: Natural Order (Trật Tự Tự Nhiên). Your ticks' batches last 1 pulse longer.

### 3. Thuận (Yielding)
- **Small:** `block_rating` +1 · `evade_pct` +0.4
- **Stat notables:** Bend (Uốn): block ×2 · Give Way (Nhường): evade ×2 · Reed in Wind (Lau Trước Gió): block +1, evade
  +1 · Return Push (Đẩy Lại): force +2
- **Effects:**
  - **Major: Yield and Return (Thuận Thế Hoàn Lực).** 15 % of the damage each hit deals to you (after defence) is
    returned as Force (a trigger, inside `trig_budget`), and the hit is reduced by the same amount.
  - Minor: Soft Catch (Đỡ Mềm). The first hit that lands on you each fight is dampened 30 % (rule 6a). *(starter)*
  - Minor: Turn the Force (Chuyển Lực). Returned Force applies 1 Qi Disruption stack.

### 4. Thủ Nhu (Keeping Soft)
- **Small:** `health_regen_pct` +0.05 · `body_shield_pct` +1
- **Stat notables:** Soft Water (Nước Mềm): regen ×2 · Supple (Mềm Dẻo): body shield ×2 · Soft Overcomes Hard (Nhu Khắc
  Cương): regen +0.05, body shield +1 · Gentle (Hiền): status resist +2
- **Effects:**
  - **Major: The Soft Overcomes the Hard (Nhu Năng Khắc Cương).** Hits on you are reduced by 20 %, and by a further
    10 % while you hold no ward shield.
  - Minor: Water Takes the Blow (Nước Nhận Đòn). Crits against you deal 20 % less extra damage. *(starter)*
  - Minor: Bend, Don't Break (Cong Không Gãy). Your body shield regenerates 1 % a pulse while you hold no ward shield.

### 5. Vô Vi Tâm (the Non-Acting Heart)
- **Small:** `tam_ma_resist_pct` +1 · `defense_pct` +0.6
- **Stat notables:** Empty Heart (Tâm Không): heart-demon resist ×2 · No Desire (Vô Dục): defense ×2 · Uncontending
  (Bất Tranh): heart-demon resist +1, defense +1 · Simple Heart (Tâm Đơn): regen +0.1
- **Effects:**
  - **Major: Not Contending (Bất Tranh).** You cannot be the target of the foe's "on hit" triggers (its triggers on
    hitting you do not fire), and its counters do not fire on your ticks.
  - Minor: No Struggle (Không Tranh Giành). Heart demon from fights you lose is halved. *(starter)*
  - Minor: Contentment (Tri Túc). +5 % to all regeneration while above 50 % health.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **It Wins without Moving (Bất Động Nhi Thắng)** | keystone | Things Happen of Themselves gives +60 % | Your arts and basic attack deal 50 % less (L2 −50) | Tự Nhiên |
| **Rule by Not Acting (Vô Vi Nhi Trị)** | keystone | Not Striking's cap is 40 and Stillness also gives +1 % regeneration each | You may slot at most 2 arts | Bất Động Thủ |
| **The Highest Good (Thượng Thiện)** | keystone | Yield and Return returns 30 % | Your max health is 20 % lower | Thuận |

## New pieces

- Damage-source split (arts vs everything else) as a scope: `Needs key` (a `non_art` source tag).
- Immunity to the foe's on-hit triggers: `Needs rule`.

## Kept apart from

Thiền Đạo (stillness of mind and vows), Động Tĩnh's Tĩnh (a stance that suppresses arts), Nhẫn Đạo (damage taken
as power). Vô Vi is **power from not casting, and from everything that is not an art**.
