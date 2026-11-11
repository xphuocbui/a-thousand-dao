# 64 · Đan Đạo · *Cửu Chuyển* (the Nine Turnings: Pill)

> Overnight draft 2026-11-11. Proposal. **Needs:** Wood or Fire ≥ 30. Holds the seeds Spirit Farming (†), Cold Pill,
> and the folded Cuisine (Linh Thiện).
> **Theme stats:** `alchemy_success`, `pill_effect_pct`, `dan_doc_resist_pct`, `herb_growth_pct`, `healing_pct`,
> `cultivation_speed_pct` (capped), `attack_pct` (cold) on Hàn Đan only.
> Also used below, listed here (dao.md rule 12): `khi_huyet_pct` and max health, `health_regen_pct`, field slots
> (`Needs key`).
> **Road:** `alchemy_success` +1.

## Build directions

1. **The Pill Fighter.** Pills in fights: more pill uses, stronger pills, pills that fire at guards like talismans
   (Đan Lô). The alchemist who brings the shop to the fight.
2. **The Field Lord.** Spirit fields that feed everything: herbs, income, ingredients (Linh Điền). The farmer build,
   now with a fight payoff (fresh herbs as preparation).
3. **The Cold Pill.** Pills that work in reverse: cold pills cool the foe (a thrown cold pill applies Ice stacks) (Hàn Đan).
4. **The Cook.** Spirit food as long buffs: a meal before a fight lasts a week (Linh Thiện).
5. **The Healer.** Medicine: healing over time, cleanse, sickness (Y Đạo).

## Facets

### 1. Đan Lô (the Furnace)
- **Small:** `alchemy_success` +1 · `pill_effect_pct` +1
- **Stat notables:** Steady Fire (Lửa Đều): alchemy ×2 · Potent Pill (Đan Mạnh): pill effect ×2 · Nine Turns (Cửu Chuyển):
  alchemy +1, pill effect +1 · Pill Cloud (Mây Đan): dan độc resist +2
- **Effects:**
  - **Major: Pill Belt (Đai Đan).** In any fight situation, you may carry 3 combat pills that fire at a guard you set
    (like talismans) and take no art slot (key: `free_slots[pill]`, R4; the pills carry a `fight_payload`, build-run suggestion 1; no total cap, the Way's own cost is the limit).
  - Minor: Furnace Hand (Tay Lò). Pills you brew have +1 quality step chance one time in 5 (ordinary seeded life chance; counted chance is keystone-only, Effects rule 12). *(starter)*
  - Minor: Double Batch (Mẻ Đôi). Brewing yields +1 pill one time in 3 (ordinary seeded life chance). Rival of the capstone Every Pill Is Perfect.

### 2. Linh Điền (Spirit Fields) †
- **Small:** `herb_growth_pct` +2 · `alchemy_success` +0.5
- **Stat notables:** Green Thumb (Tay Xanh): herb growth ×2 · Rich Soil (Đất Màu): herb growth +1, alchemy +1 · Spirit
  Spring (Suối Linh): herb growth +2 · Many Plots (Nhiều Luống): field slots +1
- **Effects:**
  - **Major: Spirit Fields (Linh Điền).** Your fields have `herb_growth_pct` +30 (a stat line, Effects rule 3), and a plot can grow 2 herbs at once.
    `Needs key` (fields).
  - Minor: Fresh Picked (Mới Hái). Herbs used within a month of harvest give +10 % pill effect. *(starter)*
  - Minor: Field Income (Lợi Ruộng). Your fields sell surplus for spirit stones each season.

### 3. Hàn Đan (Cold Pill)
- **Small:** `attack_pct` cold +1 · `pill_effect_pct` +1
- **Stat notables:** Frost Pill (Đan Sương): cold ×2 · Cooling Draught (Thuốc Mát): pill effect ×2 · Ice Furnace (Lò
  Băng): cold +1, alchemy +1 · Calm Blood (Máu Mát): dan độc resist +2
- **Effects:**
  - **Major: Thrown Pill (Ném Đan).** Pills may be thrown at the foe in a fight as an art that takes a `pill` slot (`free_slots[pill]`, R4) and uses up one pill from the belt or stock per throw (cooldown 8 s, no linh lực cost): a cold
    pill applies 6 Ice stacks for 6 pulses; a toxic pill applies 6 Poison stacks for 6 pulses; a fire pill applies 6 Burn stacks for 6 pulses (element stacks, Effects rule 9a; the count scales with the pill's potency). `Needs key` (thrown pill art).
  - Minor: Cool Head (Đầu Mát). Toxicity from cold pills is 50 % lower. *(starter)*
  - Minor: Frost-Kept (Giữ Lạnh). Pills do not lose potency over time.

### 4. Linh Thiện (Spirit Food)
- **Small:** `healing_pct` +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Hearty Meal (Bữa No): max health ×2 · Fine Cooking (Nấu Khéo): healing ×2 · Spice Rack (Kệ Gia Vị):
  max health +1, healing +1 · Banquet (Yến Tiệc): regen +0.1
- **Effects:**
  - **Major: Spirit Feast (Linh Thiện).** You can cook spirit food: a meal gives a buff for 7 days (a +5 % stat line of
    the dish), and you may hold 2 meal buffs. `Needs key` (cooking, food items).
  - Minor: Taste Test (Nếm Thử). Spirit food gives 25 % more. *(starter)*
  - Minor: Well Fed (No Đủ). With a meal buff active, heart demon decays 1 a week.

### 5. Y Đạo (Medicine)
- **Small:** `healing_pct` +1.5 · `status_resist_pct` +1
- **Stat notables:** Healer's Hands (Tay Lương Y): healing ×2 · Antidote Lore (Biết Thuốc Giải): status resist ×2 · Pulse
  Reading (Bắt Mạch): healing +1, status resist +1 · Needle Craft (Châm Cứu): regen +0.1
- **Effects:**
  - **Major: Physician (Thầy Thuốc).** Your heals also cleanse debuff stacks, oldest first, 1 per 2 % of max health healed (cap 5 per heal),
    and grave wounds after fights heal in half the time. `Needs key` (wounds).
  - Minor: Bandage (Băng Bó). After a fight, restore 10 % health. *(starter)*
  - Minor: Cure the Sick (Chữa Bệnh). Sickness events can be cured for renown and merit.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Every Pill Is Perfect (Đan Vô Phế)** | keystone | Your brewing never fails (it may still roll low quality) | Your pill yield is always 1 (rival: Double Batch) | Đan Lô |
| **Nine Turnings (Cửu Chuyển Hoàn Đan)** | keystone | Pill Belt holds 6 pills | Your arts cost 25 % more | Đan Lô |
| **The Pill Thrower (Ném Đan Thủ)** | keystone | Thrown Pill's cooldown is 4 s and it applies 10 stacks | Pill Belt's slots hold only thrown pills: you cannot drink pills in fights | Hàn Đan |

## New pieces

- Pill Belt: pointed at `free_slots[pill]` (R4) and pill `fight_payload` (build-run 1). Thrown pill art: `Needs key`.
- Fields, cooking, wounds: `Needs key` (systems not designed yet).

## Kept apart from

Hỏa's Đan Hỏa (pill fire for Fire builds), Phệ's Nuốt Đan (toxicity as power), Độc's Đan Độc (poison pills). Đan is
**pills in the fight, fields, food and medicine**.
