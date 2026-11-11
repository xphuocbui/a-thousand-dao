# The Slow Thunder (Trì Lôi)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses.
> **Seed**: "The opposite of art spam: long cooldown, low cost, huge coefficient arts give the most damage per linh lực. Two or three enormous arts on slow timers, and a plan for the seconds before they land. Drain wards hate it."
> **Direction**: The Slow Thunder (Trì Lôi): cheap slow arts keep the pool (and so the ward) full; the linh lực that full pool throws away gathers as a thunderhead that the longest art releases; single huge hits overdraw the enemy's drain ward.
> **Realm span**: Nguyên Anh (Nascent Soul), with the Kết Đan run-up described · **Power level**: top-end · **Use**: player
> **Fit**: 11 Fits today · 9 Needs key · 3 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 2 NOT ASSESSED: The fight, and the identity test inside Stack (no simulator this run, user decision 2026-11-11). Budgets has one sub-item not assessed (thần thức load, see Checks).

## Directions considered

Three readings of a specific seed (Phase 3, chosen by the session under the run's override).

- **Chosen: The Slow Thunder (Trì Lôi).** Channel: art hit. Enabler: none (a stack, plus one identity Effect). The lint pays cheap slow arts the most coefficient per linh lực; the build keeps that unspent linh lực as a full ward, and Thunderhead turns the overflow of a full pool into the longest art's coefficient. The single huge hit overdraws drain wards by Combat Defence & Healing Formulas C. Fit: Needs rule (one held payload).
- **Not picked: The Patient Blade (Ẩn Phong Đạo).** Arts held ready behind guards gain power for each second they waited (the deferred Sheathed Blade). It needs a readable for "time an art waited", and its guards turn damage off in fights where the condition never comes, the commonest failure in the combat model.
- **Not picked: The Dam-Breaker's Tithe (Phá Đê Thuế).** Big hits make the enemy's drain ward pay, and Water Table drinks 30 % of the bill. dry-well already owns Water Table and the bill game, and Water Table closes regeneration, the very resource this seed turns into damage.

## The Spine

- **The channel:** art hit (Lightning). Three slow, cheap arts (8, 10 and 12 s, cost 0.02 each) at the art lint's ceiling for their cost, plus one cheap herald. Uses L1 to L5 and crit. The caps that matter: L5 (100), `crit_mult_cap` 3.0, Thunderhead's own +3.0, and the enemy's pool, which caps what its drain ward can pay.
- **The enabler:** none. The build is a stack of designed pieces with one identity Effect (Thunderhead).
- **The loop:** the herald marks the target every 2.5 s (Thunder debuff stacks, Leaking Ward); the pool stays full because the peals cost 2 % each; each pulse's regeneration is thrown away by the full pool and gathers as the thunderhead; every 4.4 to 6.7 s a peal lands, and the 12 s Ice-Breaking Peal spends the thunderhead.
- **The engine:** linh lực is mana and ward in one pool (Combat rule 11). Spending almost none keeps the ward full and makes the pool overflow every pulse. Thunderhead and Still Water both read that overflow, so the same unspent breath heals the body and loads the strike, and ward strength, ward efficiency, regeneration and cost reduction all become damage.
- **The sacrifice:** damage per second in the first seconds. Nothing fires before 2.5 s and no peal before 4.4 s. It carries no quick arts, no talisman opener and no escape. It refuses to fix this with spam: an extra quick art spends the overflow that is the whole engine.
- **The arc:** at Kết Đan it is a patient caster with two slow arts and a full ward. At Nguyên Anh the third peal, the third ward slot and Thunderhead arrive and it becomes a thunder that breaks dams. As story, the cultivator learns to keep what they could spend, and the scripture's founder died because the thaw came before his breath was ready.

## The Legend

The ferry wardens of the Seven Floes crossing (bến Thất Lăng) on a northern river had one task: every spring the ice jammed below the bend, and if it broke on its own the towns downstream drowned. One warden learned to hold a single breath through the whole winter, spending nothing, and to let it go as one stroke of thunder that broke the jam where he chose. His notes became the Long Winter Thunder Scripture (Trường Đông Lôi Kinh). Its first line reads: "Spend nothing you can keep; keep nothing you cannot spend."

He died the winter the thaw came early. The ice broke before his breath was full and took the ferry with it. His students copy that page in red ink.

Walkers of this path are quiet in a fight. For three or four seconds they seem to do nothing but stand behind a full ward. The sects that build their defence on drain wards, keepers of the dyke-style "deep pool" methods, hate them, because a ward sized to pay for a stream of blows cannot pay for one blow that size all at once.

## How It Fights

The fight opens with the slow thunder's side doing almost nothing. Its ward is full and stays full, and the basic attack ticks along. At 2.5 s the Far Flash marks the enemy with Thunder stacks and Leaking Ward. Each pulse, linh lực that the full pool cannot hold gathers as the thunderhead and, through Still Water, heals the body. At about 4.4 s the Thaw Rumble lands, at about 5.6 s the Rolling Peal, and at about 6.7 s the Ice-Breaking Peal falls with the thunderhead behind it: coefficient 4.23 becomes up to 7.23. Against a drain ward that hit costs more linh lực than the enemy has, so most of what the ward would have stopped goes through. The enemy is left with an empty pool, Bare Vessel lights for the peals that follow, and Thunder Breaks the Dam pushes the enemy's next art back a second.

**Signature moment:** the Breakdown line "Thunderhead +3.00: Ice-Breaking Peal 4.23 → 7.23; Common Ward paid 12 % of its bill", with the enemy's linh lực bar empty from one hit. The other one players tell each other about: the build goes Down at 5 s, before its first great peal, and Final Clause fires the Ice-Breaking Peal free as a last act, carrying the full thunderhead.

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1. Base | Art lint at cost 0.02 | `c_art ≤ 1 · (1 + 24 · 0.02) + 0.25 · (cd − 1)`: 3.23 / 3.73 / 4.23 at 8 / 10 / 12 s | (rule) | art | none | ● | Arts | every slow art |
| 1. Base | **Thunderhead (Tích Lôi Vân)** | Overflow gathered; the longest-cooldown art's next landed hit adds +0.1 coefficient per 1 % of maximum linh lực gathered, cap +3.0 | Overflow (held) | art | none (`art_coef_add`) | ○ | Động Tĩnh Đạo, Tĩnh Cực Sinh Động major; scripture L9 | bare-fist's Stored Breath shape for arts; unkillable, any ward caster with one big art |
| 2. Rate | Art speed [slow] (`art_speed_pct`) | +30 scripture, +30 Ice-Jam Seal, +20 tree (all [slow] or universal): cd_eff 4.44 / 5.56 / 6.67 s | Increased | art | none | ● | Technique, item, tree | any slow-art build |
| 2. Rate | Opening Haste (Tiên Phát), `opening_haste_pct` | First timer ÷ (1 + X/100); +30 from Thunder-Gall Pill. Stop near +30: more makes the first peal land before the thunderhead is full | Timing | art | none | ○ staged | Pill, Herald's Banner | first-volley (its identity), soul openers |
| 3. L1 | Damage [lightning], damage [slow] (`attack_pct`) | Family notables +12 % each, plus tree W | Increased | art | L1 | ● | Tree | every Lightning or slow art build |
| 3. L2 | **Long Fuse (Trường Dẫn)** | `damage_more` +50 (technique) / +40 (Way notable), scope [slow, cheap] | More | art | L2 | ○ | Scripture L2; Tĩnh Cực Sinh Động notables ×2; Winter Breath region | any build whose damage arts are cheap and slow (sustain casters, sect guardians) |
| 3. L2 | **Heavy Sky (Thiên Trầm)** | `damage_more` +40 [lightning] (technique L6 and Lôi Đạo Thiên Lôi notables ×3) | More | art | L2 | ○ | Scripture L6; Lôi Đạo Thiên Lôi | first-volley, variant-thunder builds |
| 3. L3 | Artifact attack | Ice-Jam Seal (`an`, Cực phẩm) and one weapon piece | (gear) | art | L3 | ● | Items | every gear build |
| 3. L4 | Ringing Ground via Nine Rods Array (+80); Thunder-Gall Pill (+70 [lightning]) | L4 at its cap (150) in foreseen fights | More | art | L4 | ○ staged | Formation, pill | first-volley, dry-well, many others |
| 3. L5 | Steady Breath (Bình Tức), scope [slow] | L5 +12 while own linh lực ≥ 50 %: always true for this build | Conditional | art | L5 | ● (Effects GDD) | Ice-Jam Seal; Động Tĩnh Đạo Tĩnh | ward casters, cheap arts |
| 3. L5 | Undivided (Chuyên Nhất) | L5 +10 per empty art slot (2 empty → +20) | Per | art | L5 | ○ staged | Swept Floor region | one-art (its source) |
| 3. L5 | Bare Vessel (Lộ Đỉnh) | L5 +80 while the enemy has under 5 % linh lực: true after a peal overdraws a drain ward | Conditional | art | L5 | ○ (content ledger) | Way, tree | Burial Shroud, Ninth Bell, dry-well |
| 4. Crit | Crit chance [slow], crit damage [element loi] (`crit_chance_pct`, `crit_damage_pct`) | +12 pp and +40 pp notables; Far Flash's Thunder debuff stacks add +1.2 pp chance and +5 % crit damage taken each | Increased (+ stacks) | art | none (crit) | ● | Tree; Far Flash | every crit build |
| 5. Reach | Weighted Bucket (Trụy Dũng), `ward_bill_pct` | The enemy's drain wards bill +15 % for what they stop against your hits | Increased | art (via the enemy's ward) | none | ○ staged | Winter Breath region notable; tree | dry-well (its source), first-volley's Breaker |
| 5. Reach | Leaking Ward (Lậu Hộ) curse, from Far Flash | Drain wards bill +50 % for 3 pulses | (curse) | art | none | ● (Effects GDD) | Far Flash | dry-well, first-volley |
| 5. Reach | Lightning penetration (`resist_pen_pct` [lightning]) | +120 points notable: the answer to per-hit and resist wards | Increased | art | none | ● | Tree | every Lightning build |
| 6. Past the cap | Still Water (Tĩnh Thủy) | Overflow restores health at half the amount; it keeps working when the thunderhead is full | Overflow | sustain | none | ● (Effects GDD) | Động Tĩnh Đạo Tĩnh | ward casters, healers |
| 7. Fuel | Art cost [slow] (`art_cost_pct`) | −20 % scripture L8, −20 % Winter Breath notable: each peal costs 0.012 | Increased | linh lực | none | ● | Technique, tree | any slow caster |
| 7. Fuel | Linh lực regeneration (`linh_luc_regen_pct`) | +5 pp total (tree, seal +1.0, Tĩnh lines): 3.5 + 3.88 = 7.38 % of maximum per pulse | Flat | linh lực | none | ● | Tree, item, Way | every sustain build |
| 7. Fuel | Ward efficiency (`ward_efficiency_pct`) | +8 notables: own drain bills fall, so more of each pulse overflows | Increased | linh lực / ward | none | ● | Tree, Way | every ward caster |
| 8. Survival | Mountain Screen (shield ward, reserved 0.06), Soul-Guarding Lamp (reserved 0.20), Common Ward | The opening window's shield, the soul answer, the full drain ward | (wards) | defence | none | ● | Ward slots (3 at Nguyên Anh) | everyone |
| 8. Survival | Final Clause (Mạt Khoản) | Once a fight, going Down fires the longest-cooldown art free (with the thunderhead) | Trigger | art | none | ● (Effects GDD) | Scripture L12 | burst builds, dark paths |
| 9. Identity | Thunderhead (above) and **Thunder Breaks the Dam (Lôi Phá Đê)** | When the enemy's wards pay against your [slow] hit and are left at 0 linh lực, the enemy's art with the least time left is delayed 1 s | Trigger | control | none | ○ | Lôi Đạo Thiên Lôi minor | dry-well, first-volley's Breaker, any big-hit build |

Forms used: Increased, More, Flat, Conditional, Per, Overflow, Timing, Trigger (8).

**Identity piece:** Thunderhead. It makes the unspent breath the strike: without it, regeneration and ward efficiency are only defence and the build is a slow caster with a full ward. With it, every point the build does not spend comes back as up to +71 % on the Ice-Breaking Peal, and every point the enemy forces it to spend is taken off that peal. That is the build's decision and its counterplay in one rule.

**Empty rungs:** none. Rung 6 is shallow on purpose: past Thunderhead's cap the overflow only heals (Still Water). That is a sacrifice, not a gap, because a higher cap would let a fully unpressured fight grow one hit without bound.

| Layer | Points at Nguyên Anh (foreseen) | Multiplier | Sources |
|---|---|---|---|
| L1 | about 380 raw, 290 after the soft cap | ×3.90 | Tree W (top-end 45 % attack share), scripture `attack_pct` 15, Thunder root's `attack_pct`, [lightning] and [slow] notables |
| L2 | 290 of 300 | ×3.90 | Long Fuse 50 + 40 + 40, Heavy Sky 40 + 40 × 3 |
| L3 | target 250 (cap) | ×3.50 | Ice-Jam Seal and one weapon piece; not computed from item numbers this run |
| L4 | 150 (cap); blind 0 | ×2.50; blind ×1.00 | Nine Rods Array 80, Thunder-Gall Pill 70 |
| L5 | 32; 100 once the enemy is dry | ×1.32; ×2.00 | Steady Breath 12, Undivided 20; Bare Vessel 80 (clipped at 100) |

M foreseen ≈ 3.90 × 3.90 × 3.50 × 2.50 × 1.32 = **176** before the enemy is dry and **266** after (top-end anchor at Nascent Soul: 256). Blind: 70 and 107.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire and Metal, Fire high (80+), Metal 50+, with the **Thunder (Lôi)** variant by convergence (linh-can.md: Thunder needs {Fire, Metal}; purity round(0.8 × √(Fire × Metal)), e.g. Fire 86 and Metal 40 give 47) | Thunder's role is Offense (`attack_pct`). Thunder purity powers the herald's debuff stacks (× (1 + 0.002 × P)). Fire and Metal purities matter less, since the scripture names only Thunder |
| Key talents | Comprehension (ngộ tính) for layers and mastery; soul strength (thần hồn) for thần thức (a fourth ward slot at 1.75 × the reference, Combat Defence & Healing Formulas D, and soul defence) | Layers unlock the peals; thần thức answers the soul drainers that starve the overflow |
| The Way (Đạo) | **Động Tĩnh Đạo** (Motion and Stillness): facets Tĩnh (Stillness: defence, regeneration) and Tĩnh Cực Sinh Động (stillness bursting into motion). **Lôi Đạo**, facet Thiên Lôi (Heavenly Thunder) | Stillness is the full pool; the burst is the peal. Thiên Lôi carries Lightning's L2 and the dam-breaking trigger |

## Công Pháp

### Long Winter Thunder Scripture (Trường Đông Lôi Kinh) — main, Địa giai (tier 2)

"Spend nothing you can keep; keep nothing you cannot spend."

```json
{"id": "truong_dong_loi_kinh", "name": "Trường Đông Lôi Kinh", "tier": 2, "tech_kind": "main",
 "names": ["loi"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20},
             {"stat": "defense_pct", "value": 15},
             {"stat": "attack_pct", "value": 15}],
 "abilities": [{"ability_id": "far_flash", "unlock_layer": 1},
               {"ability_id": "thaw_rumble", "unlock_layer": 3},
               {"ability_id": "rolling_peal", "unlock_layer": 5},
               {"ability_id": "ice_breaking_peal", "unlock_layer": 7}],
 "seal_clusters": [], "origin": "authored"}
```

Passives (no field in `items_cong_phap.json` yet): L2 Long Fuse +50 [slow, cheap] (L2); L4 `art_speed_pct` +30 [slow]; L6 Heavy Sky +40 [lightning] (L2); L8 `art_cost_pct` −20 [slow]; L9 Thunderhead (second host after the Way); L12 Final Clause (existing Effect, Tech host). No Thiên giai copy: it stops at Nguyên Anh (tier 2 `max_realm` nguyen_anh). `seal_clusters` stays empty (retired, cong-phap.md rule 15); its side region is Winter Breath.

**Fit:** Needs key (combat passives, Effects and art records have no field in `items_cong_phap.json`) · **Budget:** 20/20 + 15/15 + 15/15 = **3.0 of 3** (tier 2), each 1.0 ≤ `bonus_single_cap` 1.5. PASS.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Far Flash (Viễn Thiểm) | Scripture L1 | Lightning hit; loi, lightning, hit, art, cheap | 1.44 (lint 1.98 × (1 − 0.27)) | 0.02 | 3 s | none | Needs key |
| Thaw Rumble (Giải Đông Lôi) | Scripture L3 | Lightning hit; loi, lightning, hit, art, slow, cheap | 3.23 (lint max) | 0.02 | 8 s | none | Needs key |
| Rolling Peal (Cổn Lôi) | Scripture L5 | Lightning hit; loi, lightning, hit, art, slow, cheap | 3.73 (lint max) | 0.02 | 10 s | none | Needs key |
| Ice-Breaking Peal (Phá Lăng Lôi) | Scripture L7 | Lightning hit; loi, lightning, hit, art, slow, cheap | 4.23 (lint max); + Thunderhead up to +3.0 | 0.02 | 12 s | none | Needs key |

- **Far Flash. Effect:** hit; lays 3 Thunder debuff stacks for 6 s (charge 0.015 × 18 = 0.27, Effects Formulas D); applies Leaking Ward (3 pulses). Curses carry no lint charge today (dry-well's suggestion would add one). **Description:** the flash seen on the far bank, long before the sound.
- **Thaw Rumble. Effect:** hit. **Description:** the low sound under the ice in the last week of winter.
- **Rolling Peal. Effect:** hit. **Description:** thunder that goes on along the valley after the stroke.
- **Ice-Breaking Peal. Effect:** hit; the build's longest authored cooldown, so Thunderhead and Final Clause pick it. **Description:** the one stroke the warden kept all winter.

Lint check (Combat Formulas C, `basic_coef` 1.0, `art_coef_per_cost` 24, `art_coef_per_cooldown` 0.25): 1.48 + 0.25 × (cd − 1) gives 1.98, 3.23, 3.73 and 4.23. All four are [cheap] (cost ≤ 2.5 %); the three peals are [slow] (≥ 6 s). No guards: a guard such as "enemy linh lực below 5 %" would silence the peals against per-hit and reserved wards, where the enemy never runs dry.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Kết Đan | 5 | Far Flash, Thaw Rumble, Rolling Peal; 2 empty | Common Ward, Soul-Guarding Lamp (2 ward slots) | No Thunderhead yet (scripture L9, Way not reached); a patient caster with a full ward |
| Nguyên Anh, early | 6 | Ice-Breaking Peal, Rolling Peal, Thaw Rumble, Far Flash; 2 empty | Common Ward, Soul-Guarding Lamp, Mountain Screen (3 ward slots) | Thunderhead arrives; the great peal goes in slot 1 so it hits first in a shared instant and overdraws the ward for the rest |
| Nguyên Anh, peak | 6 (+0) | as above | as above, plus a fourth ward slot from thần thức if reached (Clear Heart Ward against cleanse-and-silence foes) | Final Clause (L12), full Winter Breath region, the seal at Cực phẩm |

Slot order matters: when two peals share an instant, the earlier slot hits first (Combat rule 13), so the bigger hit overdraws the drain ward and the smaller one lands behind it.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Ice-Jam Seal (Phá Lăng Ấn) | Named artifact, weapon | `an` (attack 40, defence 5, thần thức 30), Cực phẩm, Nguyên Anh | `artifact_attack_pct` +30 (L3), `art_speed_pct` +30 [slow], `linh_luc_regen_pct` +1.0, carries Steady Breath [slow]. Rate, fuel and L5 on one piece | Fits today (named item on designed and live keys; Steady Breath lists Item) |
| Second weapon | Generated, weapon | `phi_kiem` or `an`, Thượng or Cực phẩm, Liệt affix | Fills L3 to its cap with the seal | Fits today |
| Ward piece | Generated, ward | `thuan`, Kiên affix | Ward strength: smaller own bills, more overflow | Fits today |
| Body piece | Generated, armour | `giap` (binds 5) | Health for the opening window | Fits today |
| Nine Rods Array (Cửu Can Trận) | Formation, foreseen only | staged | Ringing Ground L4 +80 | Needs key |
| Thunder-Gall Pill (Lôi Đởm Đan) | Pill, foreseen and ambush | staged | L4 +70 [lightning], `opening_haste_pct` +30 | Needs key |

The Ice-Jam Seal is the ferry's anchor-seal: the warden pressed it into the ice each autumn to mark where the jam would form, and it came up each spring scorched black.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Linh lực regeneration notables | +1 pp each, to about +4 pp from the tree | Overflow is regeneration minus spending: the thunderhead's fuel | Fits today |
| 2 | Art cost [slow] | −20 % notable | Each point not spent overflows | Fits today |
| 3 | Damage [lightning], damage [slow] | +12 % notables | L1 | Fits today |
| 4 | Crit chance [slow], crit damage [loi] | +12 pp, +40 pp | Crit on few huge hits | Fits today |
| 5 | Ward efficiency, ward strength | +8 % notables | Smaller own bills under pressure: more overflow kept | Fits today |
| 6 | Art speed [slow] | +20 % notable | Rate | Fits today |
| 7 | Lightning penetration | +120 points notable | Per-hit wards and Lightning-resistant foes | Fits today |
| 8 | Swept Floor region far notable (Undivided) | L5 +10 per empty slot | Two empty slots | Fits today (staged) |

### Tree region idea: Winter Breath (Đông Tức)

Theme: the breath you keep (linh lực not spent), wider than one build: ward casters, healers and any slow caster read it. Water affinity. A side-tree region for the rework (hidden clusters and `seal_clusters` are retired, cong-phap.md rule 15). 8 acupoints. Smalls: `linh_luc_regen_pct` +0.15 (×2), `art_cost_pct` [slow] −3 (×2), `ward_efficiency_pct` +1.2, `art_speed_pct` [slow] +3. Notables: `art_cost_pct` [slow] −20, and farthest, Long Fuse (+40 [slow, cheap] L2). One Weighted Bucket notable (`ward_bill_pct` +15) on a side branch. No capability. An idea, not data.

## Đạo

No new Way. Two named Ways from dao.md § Catalogue, with the nodes this build wants (graphs not drawn):

- **Động Tĩnh Đạo**, facet **Tĩnh** (Stillness: defence, regeneration): Still Water (existing Effect, Way host) and Steady Breath (existing, Way host) as `minor`s; stat lines `linh_luc_regen_pct`, `ward_efficiency_pct`, `defense_pct`. Facet **Tĩnh Cực Sinh Động** (stillness bursting into motion): **Thunderhead** as the facet's `major`; Long Fuse notables (+40 [slow, cheap] L2, ×2); stat lines `art_speed_pct` [slow], `art_cost_pct` [slow]. With the name hidden, a player reads "keep still, then strike once".
- **Lôi Đạo**, facet **Thiên Lôi** (Heavenly Thunder: tribulation): Heavy Sky notables (+40 [lightning] L2, ×3); **Thunder Breaks the Dam** as a `minor`; stat lines `crit_damage_pct` [loi], `resist_pen_pct` [lightning]. The tribulation's own image: thunder that gathers before it falls.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Kết Đan | A patient caster: two peals and a herald behind a full ward | Scripture to L5, Long Fuse, Still Water | Copies the scripture's red page and does not yet understand it |
| Nguyên Anh, early | The thunder: the 12 s peal with the thunderhead | Ice-Breaking Peal (L7), Thunderhead (L9 or Way), third ward slot | First drain-ward master broken in one blow; a dyke-keeping sect marks the name |
| Nguyên Anh, peak | The thunder with a last word | Final Clause (L12), Ice-Jam Seal at Cực phẩm, L4 at cap in foreseen fights | Learns the founder's lesson: a fight that comes too early is the one that kills you |

## Matchups

| Enemy (Combat rule 18 types) | Result | Why |
|---|---|---|
| Drain-ward caster (Common Ward, Fire-Shunning Veil) | Wins | A peal overdraws the pool: the unpaid share of what the ward stops rejoins the hit (Combat Defence & Healing Formulas C). Then Bare Vessel and Thunder Breaks the Dam |
| Art spammer (1–2 s arts) | Wins long, even short | It runs dry by about 16 s (Combat Formulas B note, typical mirror); this build never does. It must survive the first 5 s: Mountain Screen and the full ward |
| Thể tu with block | Wins | Flat block takes a fixed bite per hit (Formulas A2); four big hits lose almost nothing to it |
| Per-hit ward (Golden Bell, Surging Tide) | Even to loses | One flat fee stops the whole huge hit at the ward's share; the overdraw never happens. Take Lightning penetration |
| Linh lực drainer (Qi Disruption, soul arts that take linh lực) | Loses unless adapted | Its burns make the pool non-full, so nothing overflows: the thunderhead stays empty and Still Water heals nothing |
| Fast burster (first-volley style) | Even | It strikes before 4.4 s. The full Common Ward and Mountain Screen must hold, or Final Clause answers |
| Evader | Even | One evade costs a whole 5–7 s cycle (Thunderhead keeps its charge until a hit lands) |
| Silencer (Silence naming [slow] or `lightning`) | Loses unless cleansed | All three peals stop. Clear Heart Ward in a fourth ward slot |

**Counter:** a linh lực drainer with a per-hit ward. Its Qi Disruption ticks keep the pool below full, so Thunderhead and Still Water get nothing, and its Golden Bell pays one fee per peal, so the overdraw never happens. The build is left as a slow caster at 176 M with no thunderhead against a ward it cannot break.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Scripture 3.0 of 3, each line 1.0 ≤ 1.5. Arts at or under the lint (1.44 ≤ 1.98 × 0.73 = 1.445; 3.23, 3.73, 4.23 at the lint). 4 arts in 6 slots; 3 wards in 3 ward slots at Nguyên Anh (Formulas D). 4 artifacts ≤ `equip.max_slots` 6. Sub-item NOT ASSESSED: the thần thức load of the four pieces (bases bind 30 + 20 + 15 + 5) was not checked against a Nguyên Anh thần thức figure this run |
| Validity | PASS | Element `loi` is a real variant (Thunder from Fire and Metal, linh-can.md); damage type `lightning` (Combat rule 6); base `an`, `phi_kiem`, `thuan`, `giap` and grade `cuc` exist in `items_artifacts.json`; tier 2 `max_realm` is `nguyen_anh`, which covers the span. No auxiliary technique, so no harmony check is needed |
| Stack | PASS | All nine rungs filled; 8 forms; no modifier targets a channel the build does not use (L5 only on hits; no tick pieces); layer totals stated above. Identity test **NOT ASSESSED**: no simulator this run (user decision 2026-11-11) |
| Scaling | PASS | M 176 before the enemy is dry and 266 after, against the top-end anchor 256 at Nascent Soul (Formulas B). The Ice-Breaking Peal's coefficient (up to 7.23) is above any lint art. INFO: above the anchor once Bare Vessel lights, not pulled back |
| The fight | NOT ASSESSED | No simulator this run (user decision 2026-11-11). The engine is explained from the formulas in the guide |
| Reuse | PASS | Reused: Opening Haste, Weighted Bucket, Undivided, Nine Rods Array, Thunder-Gall Pill, Herald's Banner, `art_coef_add`, held payload, Swept Floor region, empty-art-slot meaning (staging); Bare Vessel (content ledger); Still Water, Steady Breath, Final Clause, Leaking Ward, Measured Stroke (Effects GDD). Every new piece names a second home except Thunderhead's host facet; one signature item (Ice-Jam Seal) |
| NPC use | PASS | Thunderhead, Thunder Breaks the Dam, Long Fuse and Heavy Sky read nothing an NPC lacks and need no input. Breakdown lines: "Thunderhead +2.40: Ice-Breaking Peal 4.23 → 6.63"; "Thunder Breaks the Dam: enemy's Flame Palm delayed 1 s" |
| Counterplay | PASS | A linh lực drainer (rule 18's "drains linh lực hard" profile) with a per-hit ward beats it, as above |
| Originality | PASS | Names checked: Seven Floes, Long Winter Thunder Scripture, the four arts, Thunderhead, Ice-Jam Seal and the Ways' facets are invented or from dao.md; no novel or game names |

## Fight Results

No fight input was written and no simulation was run (user decision 2026-11-11: no combat simulator this run). The guide gives the engine in words with numbers read straight from the formulas.

**Unmodelled:** everything. Pieces the fight would have needed to test: Thunderhead (held payload), Still Water and Thunderhead sharing one overflow, the overdraw against a drain ward at Nguyên Anh numbers, Thunder Breaks the Dam's delay, Opening Haste, Final Clause.

## New Concepts

None new beyond one clarification (Overflow is read whole) and the reused held payload and `art_coef_add` key. See New Content Needed.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Thunderhead (Tích Lôi Vân) | Needs rule; Needs key | A held payload (effects.md rule 8, bare-fist's suggestion) and `art_coef_add` from a second Effect (combat.md Formulas C; modifiers.md Stat List; one-art's suggestion) |
| Overflow is read whole | Needs rule | effects.md rule 5: every Effect reading the overflow event reads the whole amount (Still Water and Thunderhead) |
| Opening Haste | Needs rule | combat.md rule 13 and Formulas A2 (first-volley's suggestion) |
| Long Winter Thunder Scripture; Far Flash, Thaw Rumble, Rolling Peal, Ice-Breaking Peal | Needs key | Ability and passive fields in `items_cong_phap.json`; art records |
| Nine Rods Array, Thunder-Gall Pill | Needs key | A combat formation; a pill's fight payload (concept `preparation-fight-payload`) |
| Weighted Bucket | Needs key | `ward_bill_pct` (dry-well's suggestion) |
| Bare Vessel | Needs key | Its Effect record (content ledger proposal) |
| Measured Stroke (optional, against evaders) | Needs rule | Threshold 20 s → 10 s (one-art's suggestion) |
