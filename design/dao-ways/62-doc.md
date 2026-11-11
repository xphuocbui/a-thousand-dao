# 62 · Độc Đạo · *Vạn Độc* (Ten Thousand Poisons)

> Overnight draft 2026-11-11. Proposal. **Needs:** Wood ≥ 30. Holds the seeds Poison (†) and Plague.
> **Theme stats:** `attack_pct` (poison, chaos, over_time), `stack_effect_pct` (wood), `resist_pen_pct` (chaos),
> `status_duration_pct`, `dan_doc_resist_pct`, `status_resist_pct`, companion damage (gu), `alchemy_success`.
> **Road:** `attack_pct` poison +2.5.

## Build directions

1. **The Venom Clock.** Poison batches (Chaos, passes every shield) at volume; the cleanest tick build. Độc's
   edge over Mộc: penetration and Poison that resists cleansing.
2. **The Many Poisons.** Several poison statuses at once (Poison, Corpse Rot, Bleed, a new Paralytic): each
   distinct poison multiplies the others (Vạn Độc). A breadth build.
3. **The Gu Master.** A Gu companion that is a poison applier: the companion carries the Poison, the cultivator
   protects it and buffs it.
4. **The Plague.** Statuses that spread to the foe's companion and come back when cleansed; anti-cleanse.

## Facets

### 1. Nọc (Venom) †
- **Small:** `attack_pct` poison +2.5 · `stack_effect_pct` wood +1
- **Stat notables:** Viper Fang (Nanh Rắn): poison ×2 · Black Venom (Nọc Đen): chaos penetration ×2 · Scorpion Tail
  (Đuôi Bọ Cạp): poison +1.5, chaos +1 · Concentrate (Cô Đặc): wood stack effect ×2
- **Effects:**
  - **Major: Lingering Venom (Độc Lưu).** Cleansing removes at most half of a Poison batch of yours (rounded down),
    and cleansing wards remove your Poison at half their share.
  - Minor: Fang Strike (Cắn). Your hits apply 2 Poison stacks for 6 pulses. *(starter)*
  - Minor: Venom Rush (Độc Xông). Your first Poison batch each fight is 3× its size.

### 2. Đan Độc (Pill Toxin)
- **Small:** `dan_doc_resist_pct` +1.5 · `alchemy_success` +1
- **Stat notables:** Poison Pill (Độc Đan): alchemy ×2 · Inured (Nhờn Độc): toxicity resist ×2 · Toxic Brew (Nấu
  Độc): alchemy +1, poison +1 · Bitter Draught (Thuốc Đắng): status resist +2
- **Effects:**
  - **Major: Poison Pills (Độc Đan Thuật).** You can brew poison pills: taken before a foreseen fight, each puts 20 Poison stacks on the foe at t = 0 for 8 pulses and costs you 5 % toxicity (a pill `fight_payload`, Combat rule 12; one preparation pick, Effects rule 8, R8). `Needs key` (Alchemy recipe class).
  - Minor: Immune Blood (Huyết Kháng Độc). Poison and Corpse Rot on you are 30 % weaker. *(starter)*
  - Minor: Coat the Blade (Tẩm Độc). Coatings you apply in preparation last the whole fight (a preparation pick, Effects rule 8, R8).

### 3. Cổ (Gu)
- **Small:** companion damage +2 · `attack_pct` poison +1
- **Stat notables:** Gu Mother (Cổ Mẫu): companion damage ×2 · Hive (Tổ Cổ): companion +1, poison +1 · Fed on
  Blood (Nuôi Máu): max health +2 · Golden Silkworm (Kim Tằm): chaos penetration +2
- **Effects:**
  - **Major: Gu Swarm (Cổ Trùng).** Your companion's hits apply Poison stacks equal to 1 per 10 % of its power share
    (cap 6 per hit), using your Poison values.
  - Minor: Gu in the Blood (Cổ Trong Máu). When you take a hit, your companion's next hit applies double Poison.
  - Minor: Hatch (Nở). A gu companion starts each fight with its first hit ready. *(starter)*

### 4. Ôn Dịch (Plague)
- **Small:** `status_duration_pct` +2 · `attack_pct` over_time +1.5
- **Stat notables:** Pestilence (Dịch Bệnh): status duration ×2 · Fever (Sốt): over-time damage ×2 · Spreading Sick
  (Lây Lan): status duration +1, poison +1 · Bad Air (Khí Độc): over-time +1, chaos +1
- **Effects:**
  - **Major: Plague (Ôn Dịch).** Each pulse, half the Poison stacks of yours cleansed from the foe in the last pulse return 2 pulses later as a new batch of 4 pulses (reads the "your stacks were cleansed" count: Effects rule 5). Returned batches never return again.
  - Minor: Contagion (Truyền Nhiễm). When the foe holds 30+ of your Poison stacks, apply 5 Stagnation stacks (once per 3 s).
  - Minor: Incubation (Ủ Bệnh). Your Poison batches deal half for their first 2 pulses, then 40 % more. *(starter)*

### 5. Giải Độc (Antidote)
- **Small:** `status_resist_pct` +1 · `healing_pct` +1.5
- **Stat notables:** Antidote (Thuốc Giải): status resist ×2 · Purge Blood (Thanh Huyết): healing ×2 · Known Poisons
  (Biết Độc): status resist +1, poison +1 · Herb Lore (Thảo Dược): alchemy +2
- **Effects:**
  - **Major: Poison Fights Poison (Dĩ Độc Công Độc).** Each pulse, up to 5 Poison stacks on you are removed and applied to the foe as your Poison (4 pulses). Corpse Rot is not moved.
  - Minor: Clean Veins (Mạch Sạch Độc). Your cleanses remove poison tags first and remove 2 more. *(starter)*
  - Minor: Know Your Venom (Biết Mình). While you bear Poison, your Chaos resistance is +15.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Your Blood Is Poison (Huyết Tức Độc)** | keystone | Any hit that lands on you applies Poison to the attacker for 4 pulses: 1 stack per 1 % of your max health it took | You cannot be healed by others' arts or pills (your own healing works) | Nọc, Giải Độc |
| **Ten Thousand Poisons (Vạn Độc Quy Tông)** | keystone | Each different poison-tagged status on the target (Poison, Bleed via a poison coating, Paralytic; your Poison batches also apply 1 Paralytic) gives your over-time damage L4 +10 | Your hit parts deal 50 % of their normal damage | Ôn Dịch |
| **Gu King (Cổ Vương)** | enabler | Requires a gu companion: its power share cap (`c_comp_cap`) is 50 % higher | You cannot slot more than 3 arts | Cổ |
| **Plague Bearer (Dịch Chủ)** | keystone | Plague returns all the cleansed stacks (still once per batch) | Returned batches last 1 pulse less, and your Poison deals 20 % less | Ôn Dịch |

## New pieces

- Paralytic (a poison-tagged curse: art speed −10 %, 3 pulses): `Needs key`, for Ten Thousand Poisons' breadth.
- Poison pill recipe class: `Needs key` (Alchemy).
- Cleanse resistance on a status (Lingering Venom): `Needs rule` (Effects 9a cleansing).

## Kept apart from

Mộc Đạo (Poison as growth, regeneration); Phệ's Nuốt Đan (toxicity as power for you); Đan Đạo. Độc is
**Poison that will not be cleansed, many poisons at once, the Gu**.
