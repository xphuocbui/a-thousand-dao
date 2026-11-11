# 35 · Huyết Đạo · *Huyết Hải* (Sea of Blood)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `khi_huyet_pct`, `art_cost_health_pct`, `leech_health_pct`, `health_regen_pct`, `attack_pct`
> (bleed, physical), `body_shield_pct`, `healing_pct`.
> **Road:** `khi_huyet_pct` +1.
> **Balance flag:** the by-root notes found health-paid costs at 50 % beat a typical build in every seed. This Way
> leans on them, so every health-cost piece here carries a cost of its own, and none lowers the 1:1 rate further.

## Build directions

1. **Blood Price.** Pay arts in health, keep the linh lực pool whole as ward. The economy build: health is the
   cheap pool, linh lực the expensive one. The Way's job is to make the trade *interesting*, not free.
2. **The Bleeder.** Bleed stacks past their cap (to 8, 10) and Bleed that heals you: a Physical tick build.
3. **Blood Shield.** Health spent becomes a shield: paying for arts raises a Blood Shield, so the health you spend
   protects the health you keep.
4. **Bloodline.** Life-around-the-fight: Blood Purity, a progression stat that grows with fights won at the edge.

## Facets

### 1. Huyết Giá (Blood Price)
- **Small:** `leech_health_pct` +0.3 · `khi_huyet_pct` +0.5
- **Stat notables:** Red Coin (Đồng Đỏ): leech ×2 · Deep Veins (Mạch Sâu): max health ×2 · Paid in Full
  (Trả Đủ): max health +1, leech +0.3 · Blood Ink (Mực Máu): attack +2
- **Effects:**
  - **Major: Blood Price (Huyết Giá).** Your arts are paid in health when your linh lực is below 50 %: 1 % of max health per 1 % of max linh lực they cost. Health-paid arts deal more (L5 +10); while any art was health-paid in the last 5 s, your health regeneration is dampened by 25.
  - Minor: Clot (Đông Máu). Health you pay is taken over 1 pulse, not at once (a cushion against burst). *(starter)*
  - Minor: Blood for Blood (Máu Đổi Máu). When you pay health for an art, your next hit leeches 3 % more.

### 2. Xuất Huyết (Bleeding)
- **Small:** `attack_pct` bleed +2 · `attack_pct` physical +1
- **Stat notables:** Open Wounds (Vết Hở): bleed ×2 · Long Bleed (Chảy Dài): bleed duration +2 ×2 · Gash (Vết
  Toác): physical +1, bleed +1 · Serrated (Răng Cưa): physical crit damage +2
- **Effects:**
  - **Major: Haemorrhage (Băng Huyết).** Bleed you apply stacks to 10 (not 5). At each pulse, heal 20 % of the health your Bleed removed that pulse.
  - Minor: Nick (Cứa). Your Physical crits apply 2 Bleed stacks. *(starter)*
  - Minor: Thin Blood (Máu Loãng). A target bearing 5+ Bleed stacks regenerates 25 % less health.

### 3. Huyết Thuẫn (Blood Shield)
- **Small:** `body_shield_pct` +1 · `healing_pct` +1
- **Stat notables:** Scab (Vảy Máu): body shield ×2 · Clotted Ward (Hộ Đông): body shield +1, max health +1 · Iron
  Blood (Huyết Sắt): healing ×2 · Red Mantle (Áo Đỏ): max health +2
- **Effects:**
  - **Major: Blood Shield (Huyết Thuẫn).** Health you pay for arts becomes a Blood Shield (a body shield) at 30 % of the amount, lasting 6 s, up to 15 % of max health.
  - Minor: Thick Blood (Huyết Đặc). Bleed on you is 40 % weaker. *(starter)*
  - Minor: Shield of Life (Thuẫn Sinh). Your heals over 5 % of max health add 25 % of themselves as Blood Shield.

### 4. Sinh Lực (Vitality)
- **Small:** `health_regen_pct` +0.05 · `khi_huyet_pct` +0.5
- **Stat notables:** Strong Heart (Tim Khỏe): regen ×2 · Full Blood (Đủ Máu): max health ×2 · Red Spring (Suối Đỏ):
  regen +0.05, healing +1 · Vigorous (Cường Tráng): max health +1, regen +0.05
- **Effects:**
  - **Major: Heart Like a Drum (Tâm Như Cổ).** Your health regeneration is increased by 1 % for each 1 % of max
    health you have paid for arts in the last 10 s (cap +50 %).
  - Minor: Second Heart (Tim Thứ Hai). Your vitality fraction counts 20 % higher for starting health. *(starter)*
  - Minor: Red Breath (Hơi Đỏ). While above 90 % health, your hits deal more (L5 +10).

### 5. Huyết Mạch (Bloodline)
- **Small:** `khi_huyet_pct` +0.5 · `attack_pct` +1
- **Stat notables:** Old Blood (Máu Xưa): max health ×2 · Awakened Line (Mạch Thức): attack ×2 · Noble Vein (Mạch
  Quý): attack +1, max health +1 · Beast Blood (Máu Thú): physical +2
- **Effects:**
  - **Major: Awaken the Bloodline (Huyết Mạch Thức Tỉnh).** Your Blood Purity (a new character stat, 0–100) rises by
    1 for each fight won below 30 % health; each point gives +0.3 % max health and +0.2 % attack (cap 100).
    `Needs key` (a progression stat).
  - Minor: Blood Remembers (Máu Nhớ). Each fight won below 30 % health gives 1 extra Blood Purity while your heart demon is below 20. *(starter)*
  - Minor: Dragon Blood Trace (Vết Long Huyết). With Long Đạo held, Blood Purity rises twice as fast.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Life Is the Only Currency (Huyết Tức Tiền)** | keystone | All your arts are paid in health (Blood Price's rate) and a reserved ward of yours may reserve up to its cap without costing casts. Rival of Crimson Aegis | Your max health is 20 % lower and Blood Price's L5 does not apply | Huyết Giá |
| **Sea of Blood (Huyết Hải)** | keystone | Haemorrhage has no Bleed cap | Your non-Bleed damage deals 30 % less (L2 −30) | Xuất Huyết |
| **Crimson Aegis (Huyết Khải)** | keystone | Blood Shield converts at 50 % and its cap is 25 %. Rival of Life Is the Only Currency | You cannot slot wards in ward slots | Huyết Thuẫn |
| **Bloodline Sovereign (Huyết Mạch Chí Tôn)** | keystone | Blood Purity also adds to your highest element's stack purity (1 for 1, cap +60) | Your heart demon gain is +25 % | Huyết Mạch |

## New pieces

- Blood Purity (progression stat): `Needs key`.
- Health paid over a pulse (Clot): `Needs rule` (Combat Formulas E).

## Kept apart from

Đao's Huyết Đao (blood as a saber's fuel), Sát Đạo (killing intent), Diệt's Tai Kiếp (self-ruin for damage), Thể
Đạo (the body as armour). Huyết is **the blood economy, Bleed past its cap, and the shield of spent blood**.
