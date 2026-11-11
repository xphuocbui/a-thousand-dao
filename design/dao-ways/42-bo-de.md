# 42 · Bồ Đề Đạo · *Bồ Đề Bản Vô Thụ* (Bodhi: Merit; Bodhi Was Never a Tree)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `healing_pct`, `defense_pct`, `ward_efficiency_pct`, `attack_pct` (light), `soul_res_pct`, `body_shield_pct`,
> renown.
> **Road:** `healing_pct` +1.5.

## Build directions

Merit (công đức) is a new character resource: gained by good deeds in the world (quests, mercy, healing NPCs), spent
for power or protection.

1. **The Merciful Victor.** Sparing beaten foes (the caller's mercy choice) earns Merit; Merit becomes wards in the
   next fights (Nghiệp Thuẫn). A build whose world choices are its gear.
2. **The Exorcist.** Strong against demonic, ghost and undead foes; the specialist Way for one enemy family (Trừ Ma).
3. **The Golden Body.** Merit spent on a golden body: body shield and resistance that scale with Merit (Kim Thân).
4. **Compassion.** Healing that over-heals into a shield (no allies to heal in a duel, so the heal turns outward
   into protection).

## Facets

### 1. Từ Bi (Compassion)
- **Small:** `healing_pct` +1.5 · `body_shield_pct` +1
- **Stat notables:** Kind Hand (Tay Hiền): healing ×2 · Gentle Shield (Thuẫn Hiền): body shield ×2 · Mercy (Lòng Từ):
  healing +1, body shield +1 · Patience of Saints (Nhẫn Thánh): regen +0.1
- **Effects:**
  - **Major: Compassion (Từ Bi).** Healing you do past full health becomes a body shield (up to 20 % of max health).
  - Minor: Spare Them (Tha). When you win, choosing mercy gives 10 Merit. `Needs key` (Merit). *(starter)*
  - Minor: Kind Heal (Trị Hiền). Each pulse in which you healed 5 %+ of max health, cleanse 1 curse.

### 2. Nghiệp Thuẫn (Karma Shield)
- **Small:** `defense_pct` +1.2 · `ward_efficiency_pct` +1.2
- **Stat notables:** Merit Wall (Tường Công Đức): defense ×2 · Good Karma (Nghiệp Lành): ward efficiency ×2 · Blessed
  Guard (Hộ Phúc): defense +1, ward +1 · Lotus Aegis (Khiên Sen): soul resist +2
- **Effects:**
  - **Major: Karma Shield (Nghiệp Thuẫn).** Before a fight, spend Merit: each 10 Merit gives a ward shield of 2 % of max
    linh lực that does not drain your pool (cap 20 %).
  - Minor: Protected (Được Che). The first hit each fight that would take 20 %+ of your health is dampened 50 % (rule 6a). *(starter)*
  - Minor: Merit Lingers (Phúc Lưu). Merit decays 50 % slower.

### 3. Thiện Hạnh (Good Deeds)
- **Small:** renown +1 · `co_duyen_pct` +1
- **Stat notables:** Good Name (Danh Thơm): renown ×2 · Kind Fortune (Phúc Duyên): fortune ×2 · Helping Hand (Giúp Người):
  renown +1, fortune +1 · Charity (Bố Thí): sell price +2
- **Effects:**
  - **Major: Good Deeds (Thiện Hạnh).** Quests that help mortals or weaker cultivators give double Merit and a counted
    fortunate encounter after every 5. `Needs key` (Quests, Event Engine).
  - Minor: Alms (Bố Thí Nhỏ). Giving spirit stones in events gives Merit at a good rate. *(starter)*
  - Minor: Reputation for Good (Tiếng Lành). Righteous sects offer better prices.

### 4. Trừ Ma (Exorcism)
- **Small:** `attack_pct` light +1.5 · `soul_res_pct` +1
- **Stat notables:** Exorcist's Light (Quang Trừ Tà): light ×2 · Holy Ward (Hộ Thánh): soul resist ×2 · Sutra Chant
  (Tụng Kinh): light +1, soul resist +1 · Demon Bane (Khắc Ma): crit damage +2
- **Effects:**
  - **Major: Exorcise (Trừ Ma Vệ Đạo).** Your hits deal more to demonic, ghost and undead foes (L5 +35), and their
    Chaos and Soul hits on you are reduced by 20 %. `Needs key` (foe tags).
  - Minor: Sin Revealed (Tội Hiện). *Shared minor* (with Quang, Lôi): L5 +15 to Light hits on demonic foes or Corpse
    Rot carriers. *(starter)*
  - Minor: Purifying Word (Lời Tịnh). Your Light hits remove 1 Corpse Rot or Chaos-status stack from you.

### 5. Kim Thân (the Golden Body)
- **Small:** `body_shield_pct` +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Gilded Skin (Da Vàng): body shield ×2 · Golden Bones (Xương Vàng): max health ×2 · Buddha's Calm
  (Phật Tĩnh): body shield +1, max health +1 · Radiant Body (Thân Sáng): resist all +1
- **Effects:**
  - **Major: Golden Body (Kim Thân).** Your body shield and max health are +0.5 % per 100 Merit held (cap +20 %).
  - Minor: Gold Leaf (Lá Vàng). Spending Merit on a shrine gives +1 % body shield for a year (cap +10 %). *(starter)*
  - Minor: Unharmed Saint (Thánh Vô Thương). Bleed and Burn on you are 30 % weaker.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Merit Outweighs Heaven (Công Đức Vô Lượng)** | keystone | Merit spent is not lost: Karma Shield and Golden Body read Merit earned in life, not held | You cannot kill a beaten cultivator (mercy is forced) | Nghiệp Thuẫn, Kim Thân |
| **Bodhi Was Never a Tree (Bồ Đề Vô Thụ)** | keystone | Compassion's shield cap is 40 % and it does not decay | Your hits deal 30 % less (L2 −30) | Từ Bi |
| **Demon-Subduing Vajra (Hàng Ma Kim Cang)** | keystone | Exorcise's bonus is L5 +70 | Against foes who are not demonic, ghost or undead, your hits deal 20 % less | Trừ Ma |

## New pieces

- Merit (công đức) as a character resource; mercy choices feeding it: `Needs key`.
- Foe tags `demonic`, `ghost`, `undead`: `Needs key` (shared with Lôi, Quang, Luân Hồi).

## Kept apart from

Quang (Light damage, Exposed), Liên (cleanse and seeds), Thần Đạo (shrines and incense; Bồ Đề is merit from deeds).
Bồ Đề is **merit earned in the world, spent as shields**.
