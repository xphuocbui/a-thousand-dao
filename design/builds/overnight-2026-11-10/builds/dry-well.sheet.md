# The Dry Well (Khô Tỉnh)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses.
> **Merged 2026-11-11 (user decision):** Cold Toll below is now **Băng Đạo's capstone Absolute Zero (Tuyệt Đối Linh Độ)**,
> same rule and close; the build takes Băng Đạo as a second Way instead of Cold Toll in Vụ's Chìm facet. This sheet's
> body keeps the old name as a record.
> **Seed**: "Starve the enemy: burn their linh lực to zero so they have no ward and no arts, then win on hits that land nearly in full. A qi-burn build that wins by taking away the other side's game, and has to survive the opening where the enemy is still full."
> **Direction**: The Dry Well: Ice makes the enemy's arts dearer, heavy Cold hits make their drain ward bill their own pool, and Cold Toll makes the Ice tax the ward too, so the well is dry before their first volley comes off cooldown. Then guarded finishers fire into an empty ward.
> **Realm span**: Trúc Cơ (Foundation Establishment) to Nguyên Anh (Nascent Soul) · **Power level**: top-end · **Use**: player · **Kind**: min-max
> **Fit**: 5 Fits today · 12 Needs key · 4 Needs rule
> **Checks**: 6 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: no source gives the thần thức budget, and the technique passive is outside `bonus_pool`; Stack: the identity test cannot run in `fight_calc.py` because Cold Toll is unmodelled, and the paper model stands in; The fight: `fight_calc.py` reports CONSTANT_DRIFT on 31 of 60 constants and models the pre-#44 defence, and the engine is unmodelled)

## The seed meets the current rules

Rule 23 and Combat Defence & Healing rule 11 make the seed's win real: a side with no linh lực has no drain ward, no
per-hit ward and no default ward, and cannot pay for arts. Only what it built outside the pool stays: reserved wards,
resistance from items and the tree, block and body shields. Three facts of the #44 rules shape the build:

- **A drain ward bills the defender per point it prevents** (Formulas C). The bill falls as the defender's ward strength
  rises, so a top-end ward is cheap to run: at Nguyên Anh about 0.033 linh lực per point. Big hits still empty it,
  because a 20,000-point hit is 20,000 points. Leaking Ward (+50 %) is the only existing bill raise.
- **Ice is the only element whose debuff attacks the pool** (Effects rule 9a): +3.9 % art cost per stack, no cap,
  purity-scaled. It cannot touch a ward-slot payment (user decision 2026-11-10). The build's identity piece bends exactly
  that, for one keystone.
- **Fights at the top end last two or three seconds.** A top-end hit (M about 256 at Nguyên Anh) empties any pool in a
  few instants and kills on the first unwarded hit. So "survive the opening" means one precise thing: the enemy must be
  dry before its first volley comes off cooldown, or that volley must be unaffordable.

## Directions considered

- **Chosen: The Dry Well (Khô Tỉnh).** Make the enemy pay twice: Ice raises what their arts cost, and Cold Toll raises
  what their ward costs. Heavy, cheap Cold hits make their drain ward spend their pool; the opener arts stop by guard the
  moment the well is dry, and the finishers, guarded the other way, fire into an empty ward. It is the strongest min-max
  reading because the payoff is not "more damage" but a defence that vanishes: against a 1,500-point ward with 300
  points kept, every hit after the dry point deals four times as much.
- **Not chosen: The Grinding Mill (Ma Khí Đạo).** A pure Qi Disruption clock: Force ticks on linh lực, Stagnation, an
  overflow. It is weakest exactly where the seed needs it: Qi Disruption meets all + Force resistance, so a top-end ward
  cuts it to a sixteenth. It survives here as Drowning Palm, one piece of the opener.
- **Not chosen: The Thirsty Ground (Khát Địa).** The surprise: win before the fight with an array that makes foes start
  with less linh lực (the fight request's `start_qi_share`), plus a soul opener. Foreseen fights only, and it hands a
  player stat control over a fight-request field the Event Engine owns. Filed as a thought, not a piece.

## The Spine

- **The channel:** linh lực burn first, through the enemy's own drain ward (bills on prevented damage, raised by Leaking
  Ward, Weighted Bucket and Cold Toll), through Ice-taxed art costs and through Qi Disruption ticks. Then **art hits**
  (Cold, with a Force palm and a part-Physical finisher), L1 to L5, into a ward that is no longer there. L5 is a
  condition (Bare Vessel, Cracked Clay). No crit.
- **The enabler:** Water Table (an existing Effect) on the Well-Drawing Gourd: 30 % of what the enemy's drain wards pay
  against your hits comes back to you. It closes your linh lực regeneration.
- **The loop:** while the enemy's well has water (linh lực at or above 5 %), the bucket arts fire: Rime Needle (Ice),
  Leaking Seal (Leaking Ward), Drowning Palm (Qi Disruption). Every bucket you pull is a bill they pay and a sip you
  drink. When it is dry, the bucket arts stop by their guards and the blade arts start by theirs: Undertow and Dry
  Riverbed.
- **The engine:** Cold Toll. Ice stacks pile up twice a second, and each one now raises both their art costs and the
  bill their ward pays against you. The bills compound with the stacks, so the pool falls faster every half second, and
  the volley they were saving for costs more than they have left.
- **The sacrifice:** no linh lực regeneration, no crit, and nothing against a foe that never needed linh lực: a
  reserved-ward caster keeps its kept resistance, a body cultivator (thể tu) keeps its shields. It refuses to fix this.
  It also cannot answer a foe that strikes before 1.5 s.
- **The arc:** at Trúc Cơ a patient Ice needler whose foes spend themselves into silence; at Kết Đan the Way of Mist
  turns the Ice into a toll; at Nguyên Anh it drinks from the enemy's ward and kills in the second instant after their
  well runs out.

## The Legend

In the drought country west of the salt flats there was once one deep well for a whole province, and a sect grew up
around it whose only art was keeping it. They did not fight raiders. They let the raiders drink, and the water was so
cold it cracked teeth and so heavy it sat in the belly like stone, and a man who had drunk from it could not lift his
sword for an hour. Then the keepers came out.

The Dry Well Scripture is what the keepers wrote down when the well finally failed. It teaches that every cultivator
carries a well, that a ward is only a bucket lowered into it, and that the art is to make the other side pull the rope
until there is nothing at the bottom. Its last page says the sect's founder drank the last of the well herself, so no
one else could; the scripture closes regeneration to anyone who carries her gourd, as if the body remembered that the
spring is gone.

Sects that live on deep reserves of linh lực, the ward-masters and the sustain schools, hate this path. They call its
walkers "well-thieves" and refuse them hospitality, because a guest of this kind leaves every host thirsty.

## How It Fights

Half a second in, a needle of rime finds the enemy, and their ward catches it and pays. A second in, a seal follows and
their ward pays more, and more again, because the frost is in their channels now and every point their ward stops costs
them dear. By the time their own arts come off cooldown, the pool that should have paid for them is gone; their arts
sit ready and silent. Your bucket arts stop on their own. The Undertow, which has been waiting since 1.5 s, fires into a
cultivator with no ward at all.

**Signature moment:** the Breakdown at 2.000 s: "enemy linh lực 0 · 6 arts ready, unpaid · Undertow: 15,950 (no ward)".

## Enabler

**Water Table (Thủy Mạch)**, an existing enabler in the Effects GDD's Starter catalogue, carried by a new named artifact:
the **Well-Drawing Gourd (Cấp Tỉnh Hồ Lô)**, base `ho_lo`, utility role, Cực phẩm, Nguyên Anh tier.

- **Opens:** you gain 30 % of the linh lực the enemy's drain wards pay against your hits. In the opening, when the enemy
  is full and paying, that is about 500–600 linh lực a second, more than the bucket arts cost.
- **Closes:** your linh lực never regenerates in fights. After the well is dry you live on what you drank, and on Owed
  Water's repayments.
- **Found:** in the dry well itself, in the drought country (a rare event site from Kết Đan on), or on a Nguyên Anh
  well-thief NPC. The gourd also carries `ward_bill_pct` +15 and `linh_luc_pct` +10.

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base (burn) | Ice stacks (Ice's debuff) | +3.9 % enemy art cost per stack, × stack power 1.234 (Ice P 117) | — | Ice debuff | none | ● | Effects rule 9a, via Rime Needle | every Ice build |
| 1 Base (burn) | Stack effect [bang, debuff] | +50 % (notables in Hàn Vụ and Well-Rope) | Increased | Ice debuff | none | ◐ | Vụ Đạo Hàn Vụ, Well-Rope cluster | any stack build |
| 1 Base (burn) | Qi Disruption | 0.30 per stack × 3, a Force tick on linh lực | — | qi burn | L1–L4 | ● | Drowning Palm | any Force build |
| 2 Rate | Art speed [bang] | +100 % (needle 0.5 s, seal 1.0 s) | Increased | art hit | none | ◐ | Hàn Vụ, Well-Rope, tree | every art build |
| 2 Rate | Stack duration [bang, debuff]; stacks per grant [bang] | +40 % (5 s → 7 s); +1 per grant (rare) | Increased; Flat | Ice debuff | none | ◐ | Hàn Vụ, Well-Rope | variant-ice builds |
| 3 L1 | `attack_pct`; `attack_pct` [cold] | 160 + 140 = 300 points (250 effective) | Increased | art hit | L1 | ●/◐ | Tree, Way W, technique | any Cold build |
| 3 L2 | Dry Well passive; **Cold Depths (Hàn Uyên)** ×4 | +60 [bang]; +40 [cold] each, total 220 | More | art hit | L2 | ○ new | Technique; Hàn Vụ ×3, Băng Đạo Sương Giá ×1 | any Cold build |
| 3 L3 | Gear | 250 points: needle (Châm), the gourd, armour | — | art hit | L3 | ● | Artifacts | everyone |
| 3 L4 | Cold-Marrow Pill; Ringing Ground via Nine Rods Array | +70 [cold]; +80 (art from a formation) | More | art hit | L4 | ○ new; ○ reused | Preparation | Cold builds; first-volley, Ninth Bell |
| 3 L5 | **Cracked Clay (Nẻ Đất)** | +4 per 10 of your Ice stacks on the target, cap +20 | Per | art hit [cold] | L5 | ○ new | Hàn Vụ minor | variant-ice builds |
| 3 L5 | Bare Vessel (Lộ Đỉnh) | +80 while the enemy has under 5 % linh lực | Conditional | art hit, basic | L5 | ○ reused | Vụ Đạo Chìm notable | two-clocks, Burial Shroud, Ninth Bell |
| 4 Certainty | — | No crit; the guards make the finishers certain to land on an empty ward | — | — | — | — | — | **sacrifice** (no crit) |
| 5 Reach | Leaking Ward (curse) | Drain wards bill +50 %, 3 pulses | — | burn via ward | none | ● | Leaking Seal | first-volley |
| 5 Reach | **Weighted Bucket (Trụy Dũng)**, `ward_bill_pct` | +30 % (gourd 15, Well-Rope 15) to bills against your hits and ticks | Increased | burn via ward | none | ○ new key | Gourd, Well-Rope, Chìm lines | Water Table builds |
| 5 Reach | `resist_pen_pct` [force] | +300 points | Flat | qi burn tick | none | ◐ | Chìm lines | any Force build |
| 6 Past the cap | **Owed Water (Thủy Trái)** | Burn and bills an empty pool cannot pay become their debt (cap 40 %); they repay it before refilling, half to you | Overflow | burn past 0 | none | ○ new | Vụ Đạo Chìm major | two-clocks, soul-lance |
| 7 Fuel | Water Table (enabler) | 30 % of bills paid against your hits → your linh lực | Trade | own linh lực | none | ● | Well-Drawing Gourd | Force anti-ward |
| 7 Fuel | Frost Tithe (Sương Thuế) | 9 % of the extra cost your Ice adds → your linh lực | Trigger | own linh lực | none | ○ reused (by-root) | Meridian Map keystone, Ice reach | every Ice build |
| 7 Fuel | Still Water | Linh lực lost to a full pool heals at half | Overflow | own health | none | ● | Vụ Đạo or tree | ward casters |
| 8 Survival | Mountain Screen, Thousand-Layer Cloud | Reserved shields, about 6,110 points at ws 150, up from t = 0 | — | — | — | ● | Ward slots | everyone |
| 8 Survival | Spring at the Well's Mouth | Heal 1,640 every 2 s below 70 % health, refunded | — | — | — | ○ new art | Dry Well Scripture | Water builds |
| 9 Identity | **Cold Toll (Hàn Thuế)** | Your Ice stacks also raise the drain bills the foe's wards pay against your hits and ticks, by the share they add to its art costs. Closes: Ice's art-cost raise is halved | Redirect | burn via ward | none | ○ new | Vụ Đạo Chìm keystone | variant-ice builds |

**Forms used:** Increased, More, Flat, Per, Conditional, Overflow, Trigger, Trade (the enabler), Redirect (9).

**Identity piece:** Cold Toll. Ice alone is a slow clock: it makes the foe's next art dearer, but the foe can still pay
from a full pool. Cold Toll makes every stack a tax on the ward, which pays every half second. Paper model at Nguyên Anh
against a top-end foe whose arts first fire at 2.0 s: with it, the foe is dry at 2.0 s and fires nothing, and the build
wins at 2.0 s with 81 % health. Without it, the foe keeps about 2,070 linh lực, affords two arts at 2.0 s and kills the
build in that instant.

**Empty rungs:** crit (rung 4) is a sacrifice. Rung 6's Owed Water is filled but changes little in fights shorter than
about 4 s (Fight Results); it is there for long fights and to pay Water Table's close.

| Layer (Cold arts, Nguyên Anh, foreseen) | Points | Multiplier | Sources |
|---|---|---|---|
| L1 | 300 (250 effective after the soft start) | ×3.50 | `attack_pct` 160 (tree, Way W, technique), [cold] 140 |
| L2 | 220 | ×3.20 | Dry Well passive 60 [bang], Cold Depths ×4 (160) |
| L3 | 250 (cap) | ×3.50 | Gear against the realm base |
| L4 | 150 (cap) / 0 blind | ×2.50 / ×1.00 | Cold-Marrow Pill 70, Ringing Ground 80 |
| L5 | before the dry point 0–20; after it 100 (cap) | ×1.00–1.20 / ×2.00 | Cracked Clay; Bare Vessel |

M before the dry point ≈ 98 to 118; after it ≈ 196. Against Combat Formulas B at Nguyên Anh: typical M 7.37, top-end M
256 (L1–L4 product 128). The build's L1–L4 product is 98, a little under top-end, because it spends its L5 on a
condition and leaves L2 short of its cap. **The paper model below uses L2 260 points (×3.6, M 110 / 220)**, the planned
value once a fifth Cold L2 source is found (a Cold secret art; none is authored), so the numbers in Fight Results are
about 10 % optimistic on hits. The conclusions hold at 220 (checked: the dry point moves by no instant).

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water at 90 with the Ice variant (Ice purity 72 = 0.8 × 90). Ice's stack purity P = 72 + ½ × 90 = 117, power ×1.234 | Ice is a transmutation of Water (about 1.5–3 % of births with Water; a Linh Căn Quả can add Water to a root that lacks it, and the derived roll follows). The Dry Well Scripture names Ice, so only an Ice root may use it. A pure Water root without Ice can play the Trúc Cơ half with Huyền Thủy techniques, but has no Ice stacks |
| Key talents | Comprehension (layers, Way glimpses), Căn cốt second (health, because the opening is taken on shields and health) | The build lives in its technique and its Way |
| The Way (Đạo) | **Vụ Đạo** · *Yên Vũ* (Misty Rain): Chìm (Drowning: linh lực burn) for Cold Toll, Owed Water, Bare Vessel, Weighted Bucket lines; Hàn Vụ (Cold Mist: Ice debuff) for Ice stack lines, Cold Depths and Cracked Clay. A glimpse of **Băng Đạo** (Sương Giá) for one more Cold Depths | The catalogue already names both facets for exactly this; Vụ requires Water |

## Công Pháp

### Dry Well Scripture (Khô Tỉnh Quyết) — main, Huyền giai; Địa giai copy: Khô Tỉnh Kinh

The keepers' manual. Its margin note: "Let them drink."

```json
{"id": "dia_thuy_bang_kho_tinh", "name": "Khô Tỉnh Kinh", "tier": 2, "tech_kind": "main",
 "names": ["thuy", "bang"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20}, {"stat": "defense_pct", "value": 15},
             {"stat": "khi_huyet_pct", "value": 10}],
 "abilities": [{"ability_id": "rime_needle", "unlock_layer": 1}, {"ability_id": "leaking_seal", "unlock_layer": 3},
               {"ability_id": "drowning_palm", "unlock_layer": 5}, {"ability_id": "undertow", "unlock_layer": 7},
               {"ability_id": "well_mouth_spring", "unlock_layer": 9}, {"ability_id": "dry_riverbed", "unlock_layer": 12}],
 "seal_clusters": ["well_rope"], "origin": "authored"}
```

The Huyền giai copy (`huyen_thuy_bang_kho_tinh`, "Khô Tỉnh Quyết", tier 1, 9 layers) has `linh_luc_pct` 20 and
`defense_pct` 10 and the first five abilities. Combat passive (no field yet): `damage_more` +60 [bang] on L2 (Huyền
+40).

**Fit:** Needs key (passive and ability records have no field yet) · **Budget:** Địa 20/20 + 15/15 + 10/15 = **2.67 of 3**;
Huyền 20/20 + 10/15 = **1.67 of 2**; every line ≤ 1.5. Tier `max_realm`: Huyền `ket_dan`, Địa `nguyen_anh`, so the span
is covered. The passive's budget is NOT ASSESSED (not in `bonus_pool`).

## Arts

Lint today: `c_art ≤ 1 + 24 · cost + 0.25 · (cooldown − 1)`, × (1 − charge) for stack grants (combat.md Formulas C;
effects.md Formulas D). `fight_calc.py` still uses 12 per cost and reports four of these as OVER; that is its drift.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Rime Needle (Sương Châm) | Scripture, 1 | Cold hit; bang, cold, needle, art, quick, cheap | 0.68 (lint 1.72 × 0.4) | 0.03 | 1 s | enemy linh lực ≥ 5 % | Needs key |
| Leaking Seal (Lậu Ấn) | Scripture, 3 | Cold hit; bang, cold, seal, art, cheap | 1.9 (lint 1.97) | 0.03 | 2 s | enemy linh lực ≥ 5 % | Needs key |
| Drowning Palm (Nịch Thủy Chưởng) | Scripture, 5 | Force hit; thuy, force, palm, art | 2.2 (lint 2.70) | 0.05 | 3 s | enemy linh lực ≥ 5 % | Needs key |
| Undertow (Ám Lưu) | Scripture, 7 | Cold hit; bang, cold, art | 2.9 (lint 2.94) | 0.06 | 3 s | enemy linh lực ≤ 5 % | Needs key |
| Spring at the Well's Mouth (Tỉnh Khẩu Tuyền) | Scripture, 9 | Heal; thuy, heal, art | c_heal 4.1 (heal lint 4.13) | 0.05 | 4 s | own health ≤ 70 % | Needs key |
| Dry Riverbed (Khô Hà) | Scripture (Địa), 12 | Hit, 60 % Cold, 40 % Physical; bang, cold, physical, art, costly, slow | 4.6 (lint 4.65) | 0.10 | 6 s | enemy linh lực ≤ 5 % | Needs key |

- **Rime Needle.** **Effect:** a hit that applies 8 Ice stacks for 5 s (charge 0.015 × 40 = 0.6). **Description:** a
  sliver of well-ice that melts in the meridians.
- **Leaking Seal.** **Effect:** a hit that applies Leaking Ward (the target's drain wards bill +50 %, 3 pulses).
  **Description:** a seal pressed into the bottom of the bucket.
- **Drowning Palm.** **Effect:** a Force hit that applies Qi Disruption, 3 stacks, 3 pulses (status lint 0.9 ≤ 1.2 ×
  2.2). **Description:** the weight of a full well, pressed into the chest.
- **Undertow.** **Effect:** a hit. Its guard is false while the enemy has water, so it waits ready, and fires in the
  follow-up instant of the millisecond their pool reaches 0 (combat.md rule 10). **Description:** the pull at the
  bottom of a drained well.
- **Spring at the Well's Mouth.** **Effect:** heals U × 4.1 × 4 (1,640 at Nguyên Anh), refunding its cost when it heals.
  **Description:** the last cupful, kept for yourself.
- **Dry Riverbed.** **Effect:** a hit in two parts by the art's own record (Combat Damage Types rule 1). The Physical
  part lands on a Cold-warded foe. **Description:** stones where the river was.

The guards are the build's one decision: **buckets fire while the enemy has water, blades fire when it has none.** The
basic attack always runs.

## Loadout by Realm

| Realm | Slots | Slot order | Wards | Note |
|---|---|---|---|---|
| Trúc Cơ | 4 | Rime Needle, Leaking Seal, Drowning Palm, Undertow | Common Ward | Huyền giai; regeneration on; no Cold Toll, no Bare Vessel yet |
| Kết Đan | 5 | as Trúc Cơ, then Spring at the Well's Mouth | Common Ward, Mountain Screen | Vụ Đạo: Cold Toll, Owed Water, Bare Vessel, Cracked Clay |
| Nguyên Anh | 6 | Rime Needle, Leaking Seal, Drowning Palm, Undertow, Dry Riverbed, Spring | Common Ward, Mountain Screen, Thousand-Layer Cloud | Địa giai; the Well-Drawing Gourd (no regeneration from here) |

Slot order puts the needle first, so with a short pool the Ice still goes out; Leaking Seal second, so the curse is on
before Palm's bill. Undertow comes before Dry Riverbed, so in a shared follow-up instant the cheaper blade pays first.

Linh lực bill at Nguyên Anh while the enemy has water: needle 0.06 + seal 0.03 + palm 0.033 = **0.123 of the pool a
second** (about 640). Water Table returns 500–600 a second against a top-end ward in the opening, Frost Tithe a little
more. After the dry point the bucket arts stop; the blades cost about 0.07 a second.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Well-Drawing Gourd (Cấp Tỉnh Hồ Lô) | Artifact, utility | `ho_lo`, Cực phẩm, Nguyên Anh | Water Table (enabler); `ward_bill_pct` +15; `linh_luc_pct` +10 | Fits today (Water Table); Needs key (`ward_bill_pct`) |
| Rime needle | Artifact, weapon | `cham`, high grade, realm tier | L3 attack; a `stack_effect_pct` or Cold affinity affix if rolled | Fits today |
| Keeper's robe | Artifact, ward gear | `giap` | Ward strength and efficiency for the drain ward and the shields | Fits today |
| Cold-Marrow Pill (Hàn Tủy Đan) | Pill | Alchemy | L4 +70 [cold] for one fight; an Ice root shrugs off its toxicity | Needs key |
| Nine Rods Array (Cửu Can Trận) | Formation | Formations | Ringing Ground +80 (L4) in foreseen fights; reused from first-volley | Needs key |

The gourd: a village well-keeper's, lowered into the province's well on the day it ran dry and drawn up full. Nobody
knows what it drew. Whoever carries it stops refilling on their own, as if they had drunk enough for a lifetime.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Frost Tithe (Meridian Map keystone, Water land's Ice reach; by-root) | 9 % of the extra cost your Ice adds → linh lực | Fuel in the opening | Needs rule |
| 2 | Well-Rope (Tỉnh Thằng), sealed cluster | below | Weighted Bucket, Ice duration and effect, art speed | Needs key |
| 3 | `attack_pct` [cold] notables | +12 % each | L1 | Fits today (designed) |
| 4 | Art speed [bang] notables | +6 % each | The needle's rate | Fits today (designed) |
| 5 | Ward strength and efficiency | +8 % notables | The opening is taken on the drain ward and two shields | Fits today |

### Hidden cluster idea: Well-Rope (Tỉnh Thằng)

Theme: making the other side pay for its defence (wider than this build: any anti-ward build). Water or Ice affinity.
Sealed, 8 acupoints; seal: the Dry Well Scripture lists it in `seal_clusters`. Smalls: `ward_bill_pct` +2.5,
`stack_duration_pct` [bang, debuff] +4, `art_speed_pct` [bang] +2. Notables: `ward_bill_pct` +15, and farthest,
`stack_effect_pct` [bang, debuff] +24. No capability. An idea for the tree rework, not data.

## Đạo

No new Way. Two placements in **Vụ Đạo** (dao.md § Catalogue, #23), for whoever draws its graph:
- **Chìm (Drowning: linh lực burn):** Cold Toll as the facet's keystone at the far end; Owed Water as its `major`; Bare
  Vessel as a notable; stat lines `ward_bill_pct` and `resist_pen_pct` [force] on the way in.
- **Hàn Vụ (Cold Mist: Ice debuff):** stat lines `stack_effect_pct`, `stack_duration_pct` and `art_speed_pct` [bang];
  three Cold Depths notables (L2 +40 [cold]); one rare `stack_grant` [bang] +1; Cracked Clay as a `minor`.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Trúc Cơ | A patient needler: Ice makes the foe's arts dear, so a strong foe spends itself silent by about 5 s, then Undertow lands on an empty ward | Dry Well Scripture (Huyền), Rime Needle, Leaking Seal, Drowning Palm, Undertow; Frost Tithe | Finds the keepers' manual in a ruined well-house |
| Kết Đan | The toll-keeper: Cold Toll puts the Ice into the ward's bill; Owed Water keeps the dry foe dry | Vụ Đạo (Chìm, Hàn Vụ), Bare Vessel, Cracked Clay, Spring, Mountain Screen | Learns why the keepers were hated: they let their guests drink first |
| Nguyên Anh | The well-thief: drinks from the enemy's ward in the opening, kills two instants after the dry point | Well-Drawing Gourd (no regeneration), Dry Riverbed, Địa giai, Thousand-Layer Cloud | Takes the founder's gourd and finds that, like her, they no longer refill |

## Matchups

Paper model, Nguyên Anh, foreseen, same realm (Fight Results for the assumptions).

| Enemy | Result | Why |
|---|---|---|
| Typical (Common Ward 557 points, drain) | Wins, 1.0 s | The second needle's bill with Cold Toll empties the pool; Leaking Seal lands in the same instant on no ward |
| Warded master (1,500 points, 1,200 on drain wards, M 60) | Wins, 2.0 s, health 100 % | Dry at 2.0 s; its six arts never fire; its basic attacks only touch the shields |
| Top-end foe, arts first at 2.0 s (M 256) | Wins, 2.0 s, health ≈ 81 %, own linh lực ≈ 4 % | The identity matchup: dry at 2.0 s, volley unaffordable; its two basic attacks bill the build's ward to near empty |
| Same, **without Cold Toll** | **Loses**, 2.0 s | It keeps ≈ 2,070 linh lực and affords two Ice-taxed arts |
| Boss (the warded master at `boss_pool_mult` 4) | Wins, ≈ 3.0 s, health ≈ 96 % | It fires one volley at 2.0 s (Ice-taxed, three arts), which empties it; the blades fire at 3.0 s. INFO: rule 18 wants ≥ 4 s for a top-end build |
| Reserved-ward healer (1,500 points, 900 kept) | Wins, ≈ 3–4 s | Dry by about 2 s, but 900 points stay, so the blades deal a tenth, not a quarter |
| First-volley alpha (arts at 0.5 s) | **Loses**, 0.5 s | It strikes before the first needle lands |
| Fast top-end (arts at 1 s; `fight_calc`'s old fixture) | **Loses**, 1.0 s | Its volley at 1.0 s meets a pool that is still 90 % full |
| Thể tu (body shields, block, Physical resistance) | Even | Starving does nothing to its defence. Its default ward empties fast, so Bare Vessel lights; the fight is a plain top-end hit race on Cold against body shields |
| Drainer with a reserved ward (Qi Disruption or soul arts) | **Loses** or trades | It does not need its pool, and it drains yours while Water Table has closed your regeneration |

**Counter:** a cultivator who does not keep its defence in its pool (reserved wards, a thể tu) and strikes early. The
cleanest counter is a **reserved-ward drainer**: Still Lake Aura or Iron Shirt for defence, Qi Disruption for offence.
Starving it changes nothing, and it starves you. The build adapts by trading the gourd back for regeneration and putting
Mountain Screen and a reserved resistance ward in its slots.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique Địa 2.67 / 3 and Huyền 1.67 / 2, every line ≤ 1.5: pass. Arts at or under today's lint (0.68, 1.9, 2.2, 2.9, 4.6; heal 4.1 ≤ 4.13): pass (`fight_calc.py` uses the retired 12-per-cost lint and says OVER). Slots 4 / 5 / 6 of 4 / 5 / 6: pass. Ward slots 1 / 2 / 3 of 1 / 2 / 3: pass. Artifacts 3 of `equip.max_slots` 6: pass. Thần thức (Hồ Lô 25, Châm 10, Giáp 5 base units) against the character's budget: no source read gives the budget, so this part could not be checked. The passive is outside `bonus_pool` |
| Validity | PASS | Elements `thuy`, `bang` (`character_elements.json`; Ice is a transmutation of Water); tiers `huyen` (`max_realm` `ket_dan`) and `dia` (`nguyen_anh`) cover Trúc Cơ to Nguyên Anh; a technique naming a variant is authored (cong-phap.md rule 2); bases `ho_lo`, `cham`, `giap` exist; wards from combat-defence.md Formulas H; Qi Disruption and Leaking Ward in the Effects catalogue; guards use rule 13's vocabulary; the main technique names Water, and every art is Water or Ice, so no aux harmony question |
| Stack | NOT ASSESSED | Every rung filled or named a sacrifice (crit); 9 forms; no modifier on a layer its channel lacks (L5 only on hits); layer totals above. **Identity test:** `fight_calc.py --without cold_toll` prints WITHOUT_NOT_FOUND, because the script cannot express Cold Toll, so per the skill this part is NOT ASSESSED. The paper model says removing it turns the top-end matchup from a win at 2.0 s into a loss at 2.0 s |
| Scaling | PASS | Read from combat.md Formulas B this run: top-end M 256 at Nguyên Anh. The build's Cold M is ≈ 98–118 before the dry point and ≈ 196 after it, about 0.4–0.8 of the anchor, and after the dry point each hit meets 300 points instead of 1,500 (×4). It meets top-end on effective damage; L2 sits 80 points under its cap (a fifth Cold L2 source is missing). `fight_calc.py`'s m_static 9.10 counts only untagged layers and is not meaningful here. Defence anchors (top-end ehp) are "re-derive" and were not checked. INFO: the boss dies in ≈ 3.0 s, under rule 18's 4 s |
| The fight | NOT ASSESSED | `fight_calc.py --selftest` matched its fixtures but printed CONSTANT_DRIFT on 31 of 60 constants (old ward pass, body guard, the 12-per-cost lint, the anchors). It reports a win at 1.0 s against typical and a double knockout lost on overkill at 1.0 s against its old top-end fixture (a 1 s art). The engine (Cold Toll, Ice, Owed Water, Water Table, #44 resistance in points) is UNMODELLED. Paper results are in Fight Results |
| Reuse | PASS | Reused by name: Water Table, Still Water, Leaking Ward, Qi Disruption, the wards (GDDs); Bare Vessel (content ledger); Ringing Ground and Nine Rods Array (catalogue, staging); Frost Tithe (by-root). New pieces each name a second home; no signature pieces |
| NPC use | PASS | Every piece is passive, guarded with rule 13's vocabulary, or an all-or-nothing keystone or enabler. Each is one Breakdown line: "Cold Toll: bill ×2.30 (18 Ice)", "Owed Water: 364 owed" |
| Counterplay | PASS | Loses to rule 18 types: the drainer (Qi Disruption) when it carries a reserved ward, and to top-end burst that fires before 1.5 s. Even against a thể tu |
| Originality | PASS | Names are new and drawn from wells and water; no novel or game names; the dry-well image is ordinary language |

## Fight Results

Input: `dry-well.fight.json` (Nguyên Anh) and `dry-well.truc-co.fight.json` (Trúc Cơ). `fight_calc.py` observations
are recorded first; they are of the pre-#44 model. The table after them is a hand-worked paper model on today's GDD
formulas (combat.md Formulas A, A2, C, E, F; combat-defence.md Formulas A, C), with expected values and no chance.

**`fight_calc.py` (old model):**

| Enemy | Realm | Result | Time | Own dry at | Notes |
|---|---|---|---|---|---|
| typical | Nguyên Anh | win | 1.000 s | never | One needle at 0.5 s; enemy linh lực 0 by 0.5 s |
| typical, gap 1 and 2 | Hóa Thần | win | 1.000 s | never | Leaking Seal deals 80 % |
| top_end | Nguyên Anh | loss (double knockout, overkill) | 1.000 s | 1.000 s | The old fixture fires a 1 s art at cost 0.15 |
| top_end, gap 1 and 2 | Hóa Thần | loss | 1.000 s | 1.000 s | |
| typical | Trúc Cơ | win | 2.307 s | never | Without Rime Needle: win 2.308 s, own health 59 % instead of 72 % |
| typical, gap 1 / 2; top_end | Trúc Cơ | loss | 1.0–2.0 s | 1.0–2.0 s | |
| typical, `--without leaking_seal --without bare_vessel` | Nguyên Anh | win | 1.000 s | never | No change: the old typical dies to the first needle |

No `cap_hit` lines were printed in any run.

**Paper model.** Build at Nguyên Anh: usable linh lực 4,840 (n_qi 2.0, 6.9 % reserved), health 9,600, Common Ward 856
points (ws 150, we 100, rate 0.0656), shields 6,110, Cold M 110 / 220 (see the layer note), art speed +100 %, Ice 7.22 %
per stack. Foes are first guesses built from the Formulas B shares: **top-end** pool 4,030, regeneration 10 % a pulse,
health 14,270, 1,500 points (1,200 on drain wards at rate 0.0332, 300 kept), six arts at cost 0.06 first firing at 2.0 s,
hit M 256 with crit worth ×1.5; the **warded master** is the same with hit M 60.

| Enemy | Realm | Result | Time | Enemy dry at | Own dry at | Own health |
|---|---|---|---|---|---|---|
| typical | Nguyên Anh | win | 1.0 s | 1.0 s | never | 100 % |
| warded master | Nguyên Anh | win | 2.0 s | 2.0 s | never (≈ 72 % left) | 100 % |
| top-end, arts at 2.0 s | Nguyên Anh | win | 2.0 s | 2.0 s | ≈ 2.0 s (4 % left) | 81 % |
| top-end, **without Cold Toll** | Nguyên Anh | **loss** | 2.0 s | — | — | Down |
| top-end, without Owed Water | Nguyên Anh | win | 2.0 s | 2.0 s | ≈ 2.0 s | 81 % (no change) |
| boss (warded master, `boss_pool_mult` 4) | Nguyên Anh | win | ≈ 3.0 s | ≈ 3.0 s | never (≈ 50 %) | ≈ 96 % |
| typical | Trúc Cơ | win | ≈ 3.1 s | ≈ 3.0 s | never | ≈ 80 % |
| strong (1,000 points, 800 drain; M 15) | Trúc Cơ | narrow win | ≈ 11 s | ≈ 5 s | never | ≈ 40 % |
| strong, **without Rime Needle's Ice** | Trúc Cơ | loss | ≈ 10 s | never | — | Down |

**Worked instants, top-end foe, Nguyên Anh.** Bill factor against its ward: 0.9375 stopped × 0.8 on drain wards ×
0.0332 × 1.3 (Weighted Bucket) = 0.0324 per point of hit, ×1.5 with Leaking Ward.
- 0.5 s: Rime Needle, D 7,480, bill 242. Enemy 3,788. Ice 9.
- 1.0 s: pulse, enemy back to 4,030. Cold Toll ×1.65. Needle 414, Leaking Seal (D 21,650) 1,157, basic 117: enemy 2,342.
  Its basic attack (D 38,400) puts 4,017 into the shields and bills 2,256 from the build's pool; Water Table returns 506.
- 1.5 s: Cold Toll ×2.30 with Leaking Ward. Needle 896, Drowning Palm 1,107: enemy 339. Ice 27.
- 2.0 s: pulse, +403 → 742; Qi Disruption's tick (291 landed, 534 billed) → 0, 83 short (Owed Water debt). Its six arts are
  ready at 478 each (Ice +97 %, halved by Cold Toll's close): none fire. The bucket arts' guards are false. Undertow
  fires into 300 kept points: 63,800 → 15,950, against 10,753 health left. Down at 2.0 s.
- Without Cold Toll: bills are 1,023 at 1.0 s and 871 at 1.5 s; at 2.0 s the enemy holds 2,067 after its tick, pays
  two arts at 713 (Ice +195 %), and two hits of 76,800 put 16,080 past the build's ward into 2,093 of shield and 9,600 of
  health. The build is Down in that instant; Undertow would only have fired in the follow-up.

**Owed Water** changes no result in this table: every fight ends within an instant or two of the dry point. Its debt
matters when the dry state must last (longer boss fights than these, sustain mirrors at Kết Đan), and its repayment is
the build's only income after the dry point under Water Table. That claim is not shown by any run here.

**Unmodelled (in `fight_calc.py`):** Cold Toll, Ice stacks (approximated by a +50 % cost curse), Owed Water, Water Table's
gain, Frost Tithe, Still Water, Weighted Bucket, Cracked Clay, the heal art, the ward shields, #44 resistance in points
and kept resistance, Dry Riverbed's Physical part, Force penetration. These are the engine, which is why The fight is
NOT ASSESSED.

## New Concepts

**Linh lực debt.** A side may owe linh lực, up to a cap set by the Effect that made the debt (Owed Water: 40 % of
maximum). While it owes, its regeneration and gains pay the debt first, and it counts as having no linh lực. Rule:
combat.md rule 11 and Formulas E; combat-defence.md rule 8. Bounds: one debt per side, filled only by Effects from the
shortfall of burns and bills. Breakdown line: "Owed Water: 364 owed, 140 repaid (70 to you)". Other builds it serves:
two-clocks (Ash Ledger and Spillover burn past 0), soul-lance (soul hits take linh lực), any Qi Disruption build.
Question for the user: is a sticky "dry" state wanted, given that sustain is king?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Cold Toll | Needs rule | combat-defence.md Edge Cases and Formulas C, effects.md rule 9a: one keystone may carry Ice's raise onto drain bills (suggestions.md) |
| Owed Water | Needs rule | The linh lực debt concept; effects.md rule 5 readable `pool-shortfall`, rule 6 action "add debt" |
| Frost Tithe (reused, by-root) | Needs rule | effects.md rule 5 readable `ice-extra-cost` |
| Vụ Đạo Chìm placement | Needs rule | Via Cold Toll and Owed Water; `ward_bill_pct` in the Way's `theme_stats` |
| Weighted Bucket, `ward_bill_pct` | Needs key | modifiers.md Stat List; combat-defence.md Formulas C |
| Dry Well Scripture | Needs key | A combat passive and an ability list on technique records |
| The six arts | Needs key | Art records |
| Bare Vessel (reused) | Needs key | As in the content ledger |
| Cold-Marrow Pill; Nine Rods Array (reused) | Needs key | A pill's fight payload; a combat formation |
| Well-Rope cluster | Needs key | `ward_bill_pct` |
| Cold Depths, Cracked Clay, the gourd (Water Table), Hàn Vụ placement, the wards | Fits today | Content records only |
| A lint charge for curses | Needs rule (observed) | combat.md Formulas C; effects.md Formulas D (suggestion; the build does not need it) |
