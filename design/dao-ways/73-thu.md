# 73 · Thú Đạo · *Bách Thú* (a Hundred Beasts)

> Overnight draft 2026-11-11. Proposal. **Needs:** none. The ◇ Tọa Kỵ (Mounts) facet is archived; replaced here by
> **Thú Hồn (Beast Souls: the companion's growth)**. Holds the folded Hunting seed (Săn).
> **Theme stats:** companion damage, companion attack speed, `khi_huyet_pct`, `attack_pct` (beast), creature damage,
> `travel_speed_pct`.
> **Road:** companion damage +2.

## Build directions

1. **The Beast Carry.** The companion is the main damage: power share to `c_comp_cap`, and the Way's capstones
   bend that cap. The minion player's Way.
2. **The Pack.** One companion fights, but the Pack gives it borrowed strength from beasts you have tamed and keep at
   home (Bầy): breadth at home becomes depth in the fight.
3. **Beast Body.** Borrow traits from your companion: its element, its toughness, its claws on your basic attack
   (Thú Thể). The druid fantasy.
4. **The Hunter.** Creatures, materials and taming (Săn).

## Facets

### 1. Linh Khế (Spirit Bond)
- **Small:** companion damage +2 · `khi_huyet_pct` +0.5
- **Stat notables:** Blood Pact (Khế Huyết): companion ×2 · Shared Breath (Cùng Hơi): max health ×2 · Loyal Heart (Lòng
  Trung): companion +1, max health +1 · Bond Mark (Dấu Khế): companion attack speed +2
- **Effects:**
  - **Major: One Heart in Two Bodies (Nhất Tâm Song Thể).** Your companion's power share cap (`c_comp_cap`) is +20 %
    of itself, and 10 % of damage you take is moved to the companion (it lowers its share for the fight instead of
    health). `Needs rule` (companion as a damage sink; shared with Cốt's Bone Wall).
  - Minor: Loyal (Trung Thành). Your companion's loyalty never falls below its floor. *(starter)* `Needs key`.
  - Minor: Called by Name (Gọi Tên). Your companion's first hit each fight comes at 0.5 s.

### 2. Bầy (the Pack)
- **Small:** companion damage +1.5 · creature damage +1
- **Stat notables:** Pack Leader (Đầu Đàn): companion ×2 · Many Paws (Nhiều Chân): companion attack speed ×2 · Howl
  (Tru): companion +1, attack speed +1 · Den (Hang): max health +2
- **Effects:**
  - **Major: The Pack (Bầy Đàn).** For each tamed beast you keep at your home (cap 5), your fighting companion's power
    share is +2 % (inside the cap) and its hits deal +5 %. `Needs key` (beasts kept at home).
  - Minor: Pack Howl (Tru Bầy). Your companion's hits apply 1 Earth debuff stack for 4 pulses. *(starter)*
  - Minor: Rotation (Thay Phiên). Between fights, swap your companion for a kept beast at no cost.

### 3. Thú Thể (Beast Body)
- **Small:** `attack_pct` beast +2 · `khi_huyet_pct` +0.5
- **Stat notables:** Claws (Vuốt): beast ×2 · Thick Hide (Da Dày Thú): max health ×2 · Fangs (Nanh): beast +1, crit damage
  +1 · Beast Blood (Máu Thú): regen +0.1
- **Effects:**
  - **Major: Borrow the Beast (Mượn Thú).** Your basic attack gains your companion's damage type and `beast` tag, and
    20 % of its power share as L5 (+1 per 1 %).
  - Minor: Beast Sense (Thú Cảm). +3 pp evade while your companion is alive in the fight. *(starter)*
  - Minor: Shared Hide (Chung Da). Your companion's element gives you its element's buff stacks (5, for the fight).

### 4. Thú Hồn (Beast Souls) — replaces ◇ Tọa Kỵ
- **Small:** companion damage +2 · `than_thuc_pct` +0.5
- **Stat notables:** Soul Bond (Hồn Khế): companion ×2 · Wise Beast (Thú Khôn): thần thức ×2 · Old Companion (Bạn Cũ):
  companion +1, thần thức +1 · Spirit Food (Thức Ăn Linh): companion attack speed +2
- **Effects:**
  - **Major: Grow Together (Cùng Lớn).** Your companion gains +1 % power share (inside the cap) per year it has been
    with you (cap +15 %). `Needs key`.
  - Minor: Beast Core Feast (Tiệc Nội Đan). Beast cores fed to your companion give double. *(starter)*
  - Minor: Last Gift (Quà Cuối). If your companion dies, you gain +3 % of its share as permanent attack.

### 5. Săn (the Hunt)
- **Small:** creature damage +2 · `travel_speed_pct` +1
- **Stat notables:** Tracker (Thợ Lần): creature damage ×2 · Hunter's Road (Đường Săn): travel ×2 · Skinner (Lột Da):
  material yield +2 · Snare (Bẫy Thú): creature +1, travel +1
- **Effects:**
  - **Major: Tame the Beaten (Thuần Thú).** Beaten creatures can be tamed without a roll once per season, and your
    taming rolls are +25 % at other times. `Needs key` (Spirit Beasts).
  - Minor: Good Hunt (Săn Được). Creatures yield one more material roll one time in 3 (counted). *(starter)*
  - Minor: Beast Lore (Biết Thú). You see a creature's element and weakness before the fight.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **One Heart in Many Bodies (Nhất Tâm Vạn Thể)** | keystone | Your companion's power share cap is +50 % of itself | Your own hits deal 40 % less (L2 −40) | Linh Khế |
| **King of Beasts (Bách Thú Chi Vương)** | keystone | The Pack counts up to 10 beasts | You cannot slot more than 3 arts | Bầy |
| **Wild Shape (Dã Hình)** | keystone | Borrow the Beast gives 50 % of the share as L5 | Your companion deals 50 % less | Thú Thể |

## New pieces

- Beasts kept at home, companion years, loyalty floors: `Needs key` (Spirit Beasts).
- Companion as a damage sink: `Needs rule`.

## Kept apart from

Long Đạo (the dragon as your own bloodline and roar), Hóa Đạo (becoming beasts), Quỷ's ghost servant, Cốt's bone
servant (other companion kinds). Thú is **the companion as the carry, and the pack at home**.
