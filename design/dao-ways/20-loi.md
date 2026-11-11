# 20 · Lôi Đạo · *Cửu Thiên Lôi* (Thunder of the Nine Heavens)

> Overnight draft 2026-11-11. Proposal. **Needs:** Thunder (variant) ≥ 30. Holds the seed Heavenly Thunder (†).
> **Theme stats:** `attack_pct` (lightning), `crit_chance_pct` (lightning), `crit_damage_pct`, `accuracy_pct`,
> `art_speed_pct` (lightning), `stack_effect_pct` (thunder), `resist_pct` (lightning), `status_resist_pct`,
> `linh_luc_on_crit_pct`.
> **Road:** `attack_pct` lightning +2.

## Build directions

1. **The Crit Storm.** Thunder buff (+crit chance) on you and Thunder debuff (+crit chance and crit damage taken)
   on the foe: the cleanest crit-cap build in the game. Storm Battery-style refunds pay for it.
2. **The Tribulation Bearer.** Carry a heavenly tribulation's strike as an art fuel: you take Lightning damage on
   purpose and convert it (Thiên Lôi). A risky self-damage engine with a big payoff.
3. **The Living Bolt.** Thunder Body: your basic attack and art speed tied to crits, a fast-hit build.
4. **The Purger.** Cleanse every pulse and punish debuffs and demonic foes (Tịnh Hóa): the counter-build to curse
   and poison builds.

## Facets

### 1. Thiên Lôi (Heavenly Thunder) †
- **Small:** `resist_pct` lightning +1.5 · `attack_pct` lightning +1
- **Stat notables:** Lightning Rod (Cột Thu Lôi): lightning resistance ×2 · Ninth Bolt (Đạo Lôi Thứ Chín):
  lightning ×2 · Scarred by Heaven (Sẹo Trời): max health +1, lightning resistance +1 · Heaven's Anger (Thiên Nộ):
  lightning crit damage +2
- **Effects:**
  - **Major: Carry the Tribulation (Thân Mang Kiếp).** Every 10 s, a bolt strikes you for 4 % of max health as Lightning (it meets your resistance; `Needs rule`: a self-hit action). Your next Lightning art deals more by what it took after resistance (L5 +10 per 1 % of max health, cap +40). High resistance makes it cheaper and weaker: pick your spot.
  - Minor: Tribulation Scar (Kiếp Ấn). After surviving a heavenly tribulation, +1 % lightning damage per
    tribulation survived this life (cap +10 %). Life-around-the-fight.
  - Minor: Ground the Bolt (Tiếp Địa Lôi). Lightning damage that reaches you grants 2 Thunder buff stacks for 6
    pulses. *(starter)*

### 2. Thiểm Điện (Lightning)
- **Small:** `crit_chance_pct` lightning +0.8 · `art_speed_pct` lightning +1
- **Stat notables:** Forked Light (Chớp Nhánh): lightning crit chance ×2 · Flash (Lóe): lightning art speed ×2 ·
  Arc (Hồ Quang): crit chance +1, crit damage +1 · Static (Tĩnh Điện): accuracy +3
- **Effects:**
  - **Major: Chain Lightning (Liên Hoàn Lôi).** When your Lightning art crits, its next firing comes 25 % of its
    cooldown sooner.
  - Minor: Storm Battery (Lôi Trì). While you hold 10+ Thunder buff stacks, each crit restores 0.6 % of max linh lực. *(starter)*
  - Minor: Overcharge (Quá Tải). Crits past the crit chance cap: each 1 pp of crit chance above the cap gives L5
    +1 to Lightning hits (cap +20).

### 3. Lôi Thể (Thunder Body)
- **Small:** `stack_effect_pct` thunder +1.5 · `khi_huyet_pct` +0.5
- **Stat notables:** Charged Blood (Huyết Điện): thunder stack effect ×2 · Thunder Muscle (Cơ Sấm): physical +1,
  lightning +1 · Live Wire (Dây Sống): accuracy +1, crit chance +1 · Spark Skin (Da Lửa Điện): lightning resist +2
- **Effects:**
  - **Major: Thunder Body (Lôi Thể).** Your basic attack converts 50 % to Lightning, gains the `lightning` tag, and
    each basic crit grants 3 Thunder buff stacks for 6 pulses.
  - Minor: Jolt (Giật). When you are crit, apply 3 Thunder debuff stacks to the attacker for 6 pulses.
  - Minor: Twitch (Co Giật). While you hold 20+ Thunder buff stacks, your basic attack cooldown is 10 % shorter.

### 4. Phong Bạo (Storm, with Wind)
- **Small:** `art_speed_pct` +0.5 · `attack_pct` lightning +1
- **Stat notables:** Eye of the Storm (Mắt Bão): art speed ×2 · Squall Line (Tuyến Giông): lightning +1, art
  speed +1 · Thunderhead (Mây Giông): thunder stack effect +2 · Gale Bolt (Lôi Phong): lightning +2
- **Effects:**
  - **Major: The Storm Breaks (Bão Tố).** While you hold both 10+ Thunder and 10+ Wind buff stacks, each of your
    hits applies 1 Thunder debuff stack and 1 Wind debuff stack for 4 pulses.
  - Minor: Wind Before Rain (Gió Trước Mưa). Your Wind buff stacks also give +0.2 pp crit chance each (Lightning
    arts only).
  - Minor: Rolling Thunder (Sấm Rền). Each Lightning art fired in the last 3 s gives L5 +4 to your next one (cap
    +16).

### 5. Tịnh Hóa (Purging)
- **Small:** `status_resist_pct` +1 · `attack_pct` lightning +1
- **Stat notables:** Clean Strike (Kích Sạch): status resistance ×2 · Thunder Rite (Lôi Lễ): lightning +1,
  status resist +1 · Exorcist's Bolt (Lôi Trừ Tà): lightning crit damage +2 · Bright Nerve (Thần Kinh Sáng):
  soul resistance +2
- **Effects:**
  - **Major: Heaven Purges (Thiên Tịnh).** Each pulse, remove 1 debuff stack or curse from yourself; each one
    removed gives your next Lightning hit L5 +6 (cap +30).
  - Minor: Smite the Unclean (Trảm Tà). Your Lightning hits deal more to a target bearing Chaos-damage statuses or
    Corpse Rot, and to demonic cultivators (L5 +15). (foe tag `demonic`: Effects rule 5 readable, Combat rule 18 profile tag, R13.)
  - Minor: Clear Sky (Trời Quang). The first curse placed on you each fight is refused. *(starter)*

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **Carry Your Own Tribulation (Tự Độ Kiếp)** | keystone | The bolt strikes every 5 s for 6 % | You cannot gain Lightning resistance from wards | Thiên Lôi |
| **Nine Heavens (Cửu Thiên)** | keystone | Crit chance above the cap converts to crit damage (1 pp to +3 %) | Your non-crit hits deal 20 % less (L2 −20) | Thiểm Điện |
| **Thunder God's Body (Lôi Thần Thể)** | enabler | Your basic attack gains `basic_speed_pct` equal to your lightning `art_speed_pct` (floor `cooldown_min`; Combat Formulas A2, key: `basic_speed_pct`) | You can slot at most 2 arts | Lôi Thể |
| **Heaven's Verdict (Thiên Phán)** | keystone | Heaven Purges removes 3 a pulse, and each removal deals 1 % of the target's max health as Lightning to the foe that applied it (a trigger) | You cannot apply any curse | Tịnh Hóa |

## New pieces

- Basic attack under art speed (Thunder God's Body): reads as `basic_speed_pct` (Combat Formulas A2, build-run suggestion 6); art speed stays arts only.
- Crit chance over the cap as a readable (Overcharge): `Needs key`.
- `demonic` foe tag: Effects rule 5 readable (Character Stats rule 9a, R13).

## Kept apart from

Kiếp Đạo (tribulation as a life of trials); Phong Đạo; Quang Đạo's Phán Xét. Lôi Đạo is **the crit storm and the
bolt you carry**.
