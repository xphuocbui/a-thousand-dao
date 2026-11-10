# 60 · Phệ Đạo · *Thôn Thiên* (Swallowing Heaven)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `leech_linh_luc_pct`, `leech_health_pct`, `linh_luc_on_kill_pct`, `attack_pct` (force, soul),
> `pill_effect_pct`, `dan_doc_resist_pct`, `than_thuc_pct`, `linh_luc_pct`.
> **Road:** `leech_linh_luc_pct` +0.2.

## Build directions

1. **The Swallower.** Leech linh lực from every hit and starve the foe at the same time: your pool rises as theirs
   falls, so both wards move the wrong way for them. The drain duelist.
2. **Hunger.** A self-stack that grows each second you have not leeched and pays out big when you finally do: a
   rhythm of starve-and-gorge (Đói).
3. **The Pill Eater.** Pill toxicity into power: overdose before a foreseen fight and turn đan độc into stats.
4. **The Maw.** Drain thần thức with soul arts and grow your own: the soul build's sustain.
5. **Digest.** Permanent gains from defeated cultivators (a capped, life-long stat growth): the "devour to grow"
   fantasy as a world-level build.

## Facets

### 1. Thôn (Swallow)
- **Small:** `leech_linh_luc_pct` +0.2 · `attack_pct` force +1
- **Stat notables:** Open Throat (Họng Mở): linh lực leech ×2 · Gulp (Nuốt Ực): force ×2 · Bottomless Belly
  (Bụng Không Đáy): max linh lực +1, leech +0.2 · Inhale (Hít Vào): force penetration +2
- **Effects:**
  - **Major: Swallow Heaven (Thôn Thiên).** Linh lực you leech is also burned from the foe a second time (it loses
    twice what you gain).
  - Minor: Sip (Nhấp). Your hits on a target above 80 % linh lực leech double. *(starter)*
  - Minor: Waterlogged (Sũng Nước). A target with 0 linh lực takes more from your hits (L5 +15). *Shared minor*
    (with Vụ, Thâu).

### 2. Hóa (Digest)
- **Small:** `linh_luc_on_kill_pct` +1 · `khi_huyet_pct` +0.5
- **Stat notables:** Iron Stomach (Dạ Sắt): on-kill linh lực ×2 · Slow Digest (Tiêu Chậm): max health ×2 · Fattened
  (Béo Tốt): max health +1, max linh lực +1 · Bone Meal (Bột Xương): on-kill +1, regen +0.05
- **Effects:**
  - **Major: Digest (Tiêu Hóa).** Each cultivator you defeat in a fight permanently gives +0.1 % to one of your
    stat sheet's attack, max health or max linh lực (its largest), cap +10 % per realm. `Needs key` (a growing
    character stat; Character Stats provider).
  - Minor: Aftertaste (Dư Vị). After a fight you win, your next fight starts with 10 % extra linh lực (over max,
    decaying). *(starter)*
  - Minor: Eat the Core (Ăn Nội Đan). Beast cores you consume give 25 % more.

### 3. Đói (Hunger)
- **Small:** `attack_pct` +1.2 · `leech_health_pct` +0.3
- **Stat notables:** Gnawing (Gặm): attack ×2 · Ravenous (Thèm Khát): health leech ×2 · Empty Gut (Ruột Rỗng):
  attack +1, leech +0.3 · Craving (Cơn Thèm): crit damage +2
- **Effects:**
  - **Major: Hunger (Cơn Đói).** Each second you have not leeched, gain 1 Hunger (cap 15). Your next hit that leeches
    consumes it: L5 +4 and leech ×(1 + 0.1) per Hunger.
  - Minor: Starved (Đói Lả). While your linh lực is below 30 %, your leech is doubled. *(starter)*
  - Minor: Feeding Frenzy (Ăn Cuồng). After a hit consumes 10+ Hunger, your next 3 hits deal more (L5 +15).

### 4. Nuốt Đan (Consume Pills)
- **Small:** `pill_effect_pct` +1 · `dan_doc_resist_pct` +1.5
- **Stat notables:** Pill Glutton (Tham Đan): pill effect ×2 · Lead Belly (Bụng Chì): toxicity resist ×2 · Second
  Helping (Thêm Phần): pill effect +1, toxicity resist +1 · Bitter Root (Rễ Đắng): max health +2
- **Effects:**
  - **Major: Poison Is Food (Độc Là Thực).** At fight start, gain L5 +1 per 2 % of your pill toxicity as a share of
    its limit (cap +40). The toxicity stays. `Needs key` (toxicity readable).
  - Minor: Overdose Tolerance (Quen Liều). The toxicity threshold where penalties begin is 15 % higher. *(starter)*
  - Minor: Chew the Dregs (Nhai Bã). Failed pills you brew can be eaten for half effect. `Needs key` (Alchemy).

### 5. Hắc Khẩu (the Maw)
- **Small:** `than_thuc_pct` +0.9 · `attack_pct` soul +1.5
- **Stat notables:** Black Mouth (Miệng Đen): thần thức ×2 · Soul Teeth (Răng Hồn): soul attack ×2 · Ghost Gullet
  (Họng Ma): thần thức +1, soul resist +1 · Mind Hunger (Đói Thần): soul attack +1, thần thức +1
- **Effects:**
  - **Major: Devour Soul (Phệ Hồn).** Your soul hits steal thần thức: the target loses 1 % of its thần thức per hit and
    you gain it for the fight (cap +30 %). `Needs rule` (thần thức changes mid-fight).
  - Minor: Soul Belch (Ợ Hồn). Your soul lockout is 0.2 s shorter while you have stolen 10 %+ thần thức.
  - Minor: Taste of Fear (Vị Sợ). Every 3rd soul hit you land applies Slackened Soul. *(starter)*

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Everything Is Food (Vạn Vật Giai Thực)** | keystone | All your leech is doubled and works on ticks | You cannot heal or regenerate health except by leech | Thôn, Đói |
| **Swallowing Heaven (Thôn Thiên Đại Pháp)** | keystone | When the foe's linh lực hits 0, swallow its ward: its free ward slots' wards end and cannot be recast this fight | Your own wards bill 30 % more | Thôn |
| **Bottomless Hunger (Cơ Bất Tận)** | keystone | Hunger has no cap | You lose 0.5 % max health a second while Hunger is above 10 | Đói |
| **The Poison Saint's Gut (Độc Thánh Tạng)** | keystone | Pill toxicity no longer harms you; Poison Is Food has no cap | You cannot take any pill that removes toxicity | Nuốt Đan |

## New pieces

- Permanent growth from kills (Digest): `Needs key`, and a balance flag (power from the world, not points).
- Thần thức theft mid-fight: `Needs rule`.
- Toxicity readable in fights: `Needs key` (shared with Hỏa's Fever Pill).

## Kept apart from

Huyết Đạo (blood as a currency); Đan Đạo (pills as a craft); Hồn Đạo (soul as a craft). Phệ is **drain twice,
starve and gorge, poison as food**.
