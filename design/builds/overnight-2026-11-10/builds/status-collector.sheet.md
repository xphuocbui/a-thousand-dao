# The Hundred-Ailment Ledger (Bách Bệnh Lục)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: Each distinct status on the target adds power. Apply as many different statuses as the rules allow, cheaply, then cash in with a hit that reads the count. A breadth build in a game of depth builds.
> **Direction**: A, The Ledger of Afflictions (chosen by the skill; see Directions considered).
> **Realm span**: Kết Đan to Hóa Thần · **Power level**: top-end · **Use**: player · **Spiritual root**: five-element (ngũ linh căn) with the Lôi and Băng variants
> **Fit**: 6 Fits today · 11 Needs key · 5 Needs rule
> **Checks**: 6 PASS · 1 FAIL (the fight: at Hóa Thần the arts never fire against a typical foe) · 2 NOT ASSESSED (Budgets: combat modifiers are not in `bonus_pool`; NPC use: not run against the generator). Parts not assessed inside PASS rows: aux harmony, and the identity test on Tally Ten (unmodelled).

## Directions considered

Chosen: **A, The Ledger of Afflictions (Bách Bệnh Lục).** Many cheap statuses from five elements plus an enabler, read by a count-scaling Effect and a count-scaling modifier, cashed in by one hit. It is the only reading that keeps the seed's breadth and still has a late-game ceiling.

- **B, The Brand Sage (Ấn Sư), curses only.** Three curse slots, Marked Prey capped at +12 (3 statuses), all the weight in deeper curses. Dropped: the cap of three curses makes the count ceiling too low to feel like breadth, and it is the Curse-engine's ground.
- **C, The Five-Rot Garden (Ngũ Hủ Viên), depth on stacks.** Pile one element's stacks high and let ticks do the work. Dropped: that is a depth build, the opposite of the seed, and ticks cannot read a count.
- **D, The Gu-Tender (Cổ Sư), a companion carries the statuses.** Pack Hunt reads statuses for a beast. Dropped: a companion is one source and it is not tested by the simulator.

## The Spine

- **The channel:** art hits, by one big physical art (Ledger Reckoning) that reads the count; the other six arts are applicators whose own damage is small on purpose. Uses L1 to L5. L5 is the count (Marked Prey, up to +48), L2 carries a Per on the count (Crowded Ledger, up to +36).
- **The enabler:** the Tally Gourd (Kết Sổ Hồ Lô). It opens extra statuses: each time an art of yours applies a status, the Gourd adds a one-stack batch of one status the target lacks (Qi Disruption, Bleed, Exposed). It closes 30 % of the direct damage of every status-applying art and takes a curse slot for Exposed.
- **The loop:** brand the target with five or six cheap arts at 3 s cooldowns, let the Gourd and Rolling Refresh fill and hold the count, fire Ledger Reckoning every 4 s.
- **The engine:** a count that is read twice, in L5 (Marked Prey, raised to 12 kinds by Tally Ten) and in L2 (Crowded Ledger). Twelve kinds are worth +48 L5 and +36 L2 on one hit.
- **The sacrifice:** the applicators barely hurt. The build has no damage until the count is up, and it dies to anything that wipes statuses (a cleanser) or ignores them (a status-resistant body).
- **The arc:** Kết Đan a four-element brand and a modest count; Nguyên Anh adds the Thunder and Ice brands and the Gourd; Hóa Thần fills the Gourd's three extras and the second and third curses.

## The Legend

The Hundred-Ailment Ledger was a registrar's book kept in a plague-hospice of the Verdant Valley sect (tông môn), where one fever came in forty forms and no healer could tell which patient had which. The registrar, Mạc Văn, wrote each affliction on its own line so the physicians could treat them in order. Cultivators who read the ledger found that it worked in reverse: lay each line on a living enemy and the enemy carried the whole book.

Its walkers are the sect's old triage hands and a few wanderers who bought a copy for a stone. It changes them: they stop seeing a fight and see a list, and they cannot rest while a line is blank. Mạc Văn is said to have died carrying all forty lines at once, which is why the Gourd takes its curse slot.

Healers' guilds (the cleanse trade) and the body-tempering schools want it gone: cleansing is the answer, and so are bodies that shrug off afflictions.

## How It Fights

A five-element root throws a cheap brand at the target every three seconds: Fire, Earth, Metal, Wood, Thunder, Ice, each a separate kind of affliction. The Tally Gourd quietly adds Qi Disruption, Bleed and Exposed. Every kind is one more entry in the ledger, and Marked Prey and Crowded Ledger pay for each. Then Ledger Reckoning lands as a physical hit that meets Metal's armour-breaking stacks and the whole count.

**Signature moment:** the target's status bar fills until it scrolls, twelve icons deep, and the next Reckoning shows two bonus lines in the Breakdown: "+48 for twelve kinds" and "+36 more for twelve kinds".

## Enabler

**Tally Gourd (Kết Sổ Hồ Lô)**, a named artifact on the `ho_lo` base, grade `cuc`. Found as the registrar's burial-goods in the hospice's sealed ledger-room (event reward). Opens: a one-stack batch of Qi Disruption, then Bleed, then Exposed (first the target lacks), applied after an art of yours applies a status, 3 pulses long. Closes: −30 % direct damage on arts that apply a status, a curse slot for Exposed, 25 thần thức. Not usable before Nguyên Anh (artifact tier).

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Ledger Reckoning coefficient | c_art 3.1 inside the art lint | Flat base | art | none | ○ | công pháp | any slow-hitter |
| 2 Rate | Art speed | +40 % | Increased | art | none | ● | tree, technique | any art build |
| 3 L1 | Attack and element nodes | 400 points (counts 300 past +200) | Increased | art, basic | L1 | ● | tree, Way W | any |
| 3 L2 | Brand technique more | +90 on status-apply arts, +30 aux, +40 Way, +40 cluster, +50 tags | More | art | L2 | ○ | công pháp, Đạo | any status build |
| 3 L2 live | Crowded Ledger (Chúng Bệnh) | +3 more per distinct own status on the target, cap +36 | Per | art | L2 | ○ | hidden cluster | Curse-engine |
| 3 L3 | Artifacts | Gourd, Registrar's Needle, Hospice Ward Robe at 250 | Increased | art | L3 | ● | artifacts | any |
| 3 L4 | Preparation | Nine Rods Array, Hundred-Herb Pill at 150 | More | art | L4 | ○ | formation, pill | any prepared build |
| 3 L5 | Marked Prey | +4 per distinct own status, cap +16 | Per | art, basic | L5 | ◐ | Effect | Curse-engine |
| 4 Crit | Thunder brand, crit 0.3 x2.2 | Thunder stacks raise crit taken | Conditional | art | none | ● | art | any thunder |
| 5 Reach | Exposed and Sundered curses | All-resistance −100, type −150 per stack | Conditional | any | none | ● | Gourd, art | Curse-engine |
| 6 Past the cap | Tally Ten (Thập Kết) | Marked Prey counts 12 kinds: cap +16 to +48 | Cap shift | art | L5 | ○ | Đạo (Ôn Dịch) | any Marked Prey build |
| 6 Past the cap | Extra Curse Slot (Thêm Chú Vị) | +1 `curse_slots` | Cap shift | any | none | ○ | hidden cluster | Curse-engine |
| 7 Fuel | Thrifty Brand (Tiết Ấn) | −8 % cost on status-applying arts | Increased | art | none | ○ | tree | any status build |
| 7 Fuel | Rolling Refresh (Lan Bệnh) | Applying a status refreshes one other of yours by 1 pulse, 2 per firing | Trigger | any | none | ○ | Đạo (Ôn Dịch) | starter-venom |
| 8 Survival | Hospice Ward Robe | Drain ward, W2–W5 at 300/250/150/100 | Increased | defence | W2–W5 | ● | artifact, tree | any ward build |
| 9 Identity | Tally Ten | the ceiling on a count-reader | Cap shift | art | L5 | ○ | Đạo | signature |

**Identity piece:** Tally Ten with Crowded Ledger. Without the cap shift the count stops paying at four kinds and the other eight statuses are worth nothing.
**Empty rungs:** none. Rung 4 is thin on purpose: crit comes only from the Thunder stacks.

| Layer | Points at Hóa Thần | Multiplier | Sources |
|---|---|---|---|
| L1 | 400 (counts 300) | ×4.0 | tree notables, Way W, element affinity |
| L2 | 250 static, 300 on Reckoning | ×3.5, ×4.0 | Canon, Pamphlet, Đạo art nodes, cluster, Crowded Ledger |
| L3 | 250 | ×3.5 | three artifacts, artifact power nodes |
| L4 | 150 | ×2.5 | Nine Rods Array, Hundred-Herb Pill, coating |
| L5 | 52 static, 100 on Reckoning | ×1.52, ×2.0 | Kindled Wound, Steady Breath, Marked Prey with Tally Ten |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Five-element root, with Lôi (Hỏa+Kim) and Băng (Thủy) reached | Fire, Earth, Metal, Wood debuffs from the five; Thunder and Ice from the variants. Low purity is the price |
| Key talents | Comprehension, Thần thức | Comprehension for three techniques; thần thức for the Gourd and Needle |
| The Way (Đạo) | Độc Đạo (Vạn Độc), Ôn Dịch facet (Plague: statuses spread) | The facet's idea is exactly "statuses spread"; holds Tally Ten and Rolling Refresh |

## Công Pháp

### Hundred-Ailment Register Canon (Bách Bệnh Chân Kinh), main, tier 3 (Thiên)

The registrar's book as a method: five brands in five elements, one slow reckoning.

```json
{"id": "bach_benh_chan_kinh", "name": "Bách Bệnh Chân Kinh", "tier": 3, "tech_kind": "main",
 "names": ["kim", "moc", "thuy", "hoa", "tho"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_regen_pct", "value": 8}, {"stat": "than_thuc_pct", "value": 6}],
 "abilities": [{"ability_id": "ember-brand", "unlock_layer": 2}, {"ability_id": "cracked-earth-brand", "unlock_layer": 4},
               {"ability_id": "cold-iron-brand", "unlock_layer": 6}, {"ability_id": "bitter-sap-brand", "unlock_layer": 8},
               {"ability_id": "ledger-reckoning", "unlock_layer": 12}],
 "seal_clusters": ["quan_thu"], "origin": "authored"}
```

**Fit:** Needs key (a five-element main; combat passives). **Budget:** NOT ASSESSED (combat modifiers are not in `bonus_pool`); the two bonuses use keys in the pool, small.

### Two Variants Pamphlet (Nhị Biến Tiểu Sách), secret, tier 2

Two pages the registrar kept for the odd cases. Holds Thread-Lightning and Rime brands, unlocked at layers 4 and 8, `names` ["hoa", "kim", "thuy"]. **Fit:** Needs key. Aux harmony with the main: NOT ASSESSED.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Ember Brand (Hỏa Ấn) | Canon 2 | elem, fire, status | 0.7 | 0.02 | 3 s | none | Needs key |
| Cracked-Earth Brand (Thổ Ấn) | Canon 4 | elem, earth, status | 0.7 | 0.02 | 3 s | none | Needs key |
| Cold-Iron Brand (Kim Ấn) | Canon 6 | elem, metal, status | 0.7 | 0.02 | 3 s | none | Needs key |
| Bitter-Sap Brand (Mộc Ấn) | Canon 8 | elem, wood, status | 0.7 | 0.02 | 3 s | none | Needs key |
| Thread-Lightning Brand (Lôi Ấn) | Pamphlet 4 | elem, thunder, status | 0.7 | 0.02 | 3 s | none | Needs key |
| Rime Brand (Băng Ấn) | Pamphlet 8 | elem, ice, status | 0.7 | 0.02 | 3 s | none | Needs key |
| Ledger Reckoning (Tính Sổ) | Canon 12 | phys, metal | 3.1 | 0.06 | 4 s | none | Needs key |

**Effect:** each Brand is a hit plus a 5-stack, 10 s batch of its element's debuff (Fire burn, Earth accuracy down, Metal physical taken up, Wood poison, Thunder crit taken up, Ice art cost up). **Description:** a stamp pressed into a page that does not exist yet. **Reckoning:** a hit whose L2 and L5 read the count (+3 and +4 per kind), meeting Metal's physical-taken stacks.

Art lint (`c_art ≤ 1 × (1 + 24 × cost) + 0.25 × (cooldown − 1)`): Brand 0.7 ≤ 1.98; Reckoning 3.1 ≤ 3.19. No `lint_over`.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Kết Đan | 5 | Ember, Earth, Iron, Sap, Reckoning | Common drain ward | four kinds, count +16 L5 |
| Nguyên Anh | 6 | + Thread-Lightning | Hospice Ward Robe | five kinds, Gourd arrives (+3 echoes) |
| Hóa Thần | 7 | + Rime | Robe, layers at the caps | six brands, nine kinds in hand, twelve at the limit |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Tally Gourd (Kết Sổ Hồ Lô) | artifact, utility, enabler | `ho_lo`, cực, Nguyên Anh+ | the enabler | Needs rule |
| Registrar's Needle (Chủ Bộ Châm) | artifact, weapon | `cham`, thượng, Hóa Thần | L3 attack; affixes Liệt and element | Fits today |
| Hospice Ward Robe (Dưỡng Đường Y) | artifact, ward | `giap`, thượng, Hóa Thần | W3 gear for the drain ward | Fits today |
| Nine Rods Array (Cửu Can Trận) | formation | existing staged | L4 | Needs key |
| Hundred-Herb Pill (Bách Thảo Đan) | pill | preparation | +status duration in the fight, L4 | Needs key |

The Needle is a registrar's pen: it records one line per hit, which the Breakdown shows as the count.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Status chance | +6 % notable | Brands must land | Needs key |
| 2 | Status duration | +12 % notable | 10 s batches last | Needs key |
| 3 | Art cost, status-applying arts (Thrifty Brand) | −8 % notable | Fuel | Needs key |
| 4 | Art speed | +3 % notable | Rate | Fits today |
| 5 | Status stack cap | +1 rare | Deeper batches | Needs key |
| 6 | Many Hands cluster | see below | Crowded Ledger, Extra Curse Slot | Needs key |

### Hidden cluster idea: Many Hands (Quần Thủ)

Theme: statuses (Effects System). Element affinity: Wood. Kind: sealed, seal condition: the Register Canon (`seal_clusters`). Size 8 acupoints: small status chance, status duration, Thrifty Brand, art speed; a notable at the middle (status duration +12 %); the far notable holds Crowded Ledger, and the last holds Extra Curse Slot. No capability.

## Đạo

Existing: **Độc Đạo (Vạn Độc)**, Ôn Dịch facet (Plague: statuses spread). Wanted nodes: the facet's stat lines, Nọc for the Wood stacks, and two new Effect nodes staged here: **Tally Ten** (capstone) and **Rolling Refresh** (middle). New: nothing else.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Kết Đan | four brands, one Reckoning; 20-0 on a same-realm foe, 8-12 against Nguyên Anh+1 | Canon, five-element root | the ledger is mostly blank |
| Nguyên Anh | five kinds, then the Gourd | Pamphlet, Gourd, Many Hands | the first line writes itself |
| Hóa Thần | six brands, nine kinds in hand | Tally Ten, Robe | the registrar's fate shows |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| typical | wins | brands and basic attack end it before the cooldowns (1.6 s at Hóa Thần) |
| top_end | wins narrowly (14-5-1) | engine runs: brands 4 casts each, Reckoning 2.9 |
| top_end_the_tu | likely loses | body layers and status resist shrug off the count; NOT run |
| cleanser | loses | cleanse removes the stacks; Tally Ten reads fewer kinds |

**Counter:** a cleanser (cleanse every pulse) or a high `status_resist_pct` body. Answer: Rolling Refresh keeps six kinds alive, Qi Disruption and Exposed are curses with their own cleanse tags; hold the Reckoning until the count refills.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | the technique's combat modifiers are not in `bonus_pool`; arts inside the lint; slots 5 and 7 within `slots_by_realm`; 3 artifacts, thần thức by the Gourd 25, Needle ~10, Robe 5 |
| Validity | PASS | element ids real; tier 3 `max_realm` hoa_than covers the span; aux harmony NOT ASSESSED |
| Stack | PASS | forms: Increased, More, Per, Conditional, Cap shift, Trade, Trigger; layers all filled; identity test NOT ASSESSED on Tally Ten (unmodelled), but removing Ledger Reckoning changed the fight |
| Scaling | PASS (INFO) | static layers give M ≈ 186 (4.0×3.5×3.5×2.5×1.52) against top-end 325; on Reckoning the layers reach L2 300 and L5 100: M = 4.0×4.0×3.5×2.5×2.0 = 280, 86 % of top-end |
| The fight | FAIL | at Hóa Thần the typical fight ends in 1.6 s and every art shows NEVER_FIRED (the basic attack at L1 400 ends it); the loop is real only at Kết Đan (all arts fire) and vs top_end. Rule 18 allows a top-end volley win, but the engine is untested there |
| Reuse | PASS | four reused, signature pieces: the Gourd only |
| NPC use | NOT ASSESSED | not checked against the generator; each piece is a stat, tag or an Effect a Way could hold |
| Counterplay | PASS | cleanser and status-resistant bodies |
| Originality | PASS | no name or technique from a novel or game; Mạc Văn and the hospice are original |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/status-collector.fight.json` (Hóa Thần) and `status-collector.ket-dan.fight.json` (Kết Đan). Observations from `fight.py` on the combat simulator, 20 fixed seeds.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Hóa Thần file | 0 | 20 / 0 / 0 | 1.6 s | never | all seven arts | none |
| top_end, Hóa Thần file | 0 | 14 / 5 / 1 | 9.5 s | 8.4 s | none | none |
| typical, Kết Đan file | 0 | 20 / 0 / 0 | 5.8 s | never | none | none |
| typical, Kết Đan file | +1 | 8 / 12 / 0 | 13.6 s | 9.0 s | none | none |
| typical, Kết Đan file | +2 | 0 / 20 / 0 | 4.3 s | 4.0 s | none | none |
| top_end, Kết Đan file | 0 | 0 / 20 / 0 | 2.0 s | 1.6 s | all five arts | none |

The first Hóa Thần run had pools and health at n 1.2 and lost 0-20 to top_end; n 2.0 (a top-end pool and body, an assumption this sheet states) and ward strength 84.1 changed it to 14-5-1.

**Identity test** (`--without ledger-reckoning`, not the true identity piece): Kết Đan typical+0 changed (5.8 → 7.4 s), typical+1 changed (13.6 → 15.3 s, wins 8 → 3), typical+2 NO_CHANGE; Hóa Thần typical NO_CHANGE, top_end changed (9.5 → 12.6 s, wins 14 → 16, because the 6 % cost no longer dries the pool).

**Unmodelled:** the count (Marked Prey, Tally Ten, Crowded Ledger) as a live condition (set flat on Reckoning's x, none on the basic attack); the Gourd's echo statuses and curse slots; Qi Disruption, Bleed, Exposed, Sundered; Rolling Refresh; guards and conditions; the 30 % enabler cut (modelled as c_art 0.7); triggers. `model_note`: enemies are exact at Qi Refining and fitted at hoa_than; the simulator does not model soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield, or escape.

## New Concepts

**Distinct-status roster (the twelve).** Rule: Effects System's "distinct statuses of the side's own on the target" needs a table of what counts as one kind: six element debuff families, Bleed, Qi Disruption, Corpse Rot, and the curses (Sundered, Exposed, Sealed Meridian, Silence, Stagnation, Heavy Breath, Leaking Ward, Withering, Slackened Soul), at most three curses at once. Serves: this build, Curse-engine, starter-venom. Breakdown line: "Statuses of yours on the target: 9". Question for the user: do two Burn batches count as one kind (this sheet: yes).

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Crowded Ledger | Needs rule | a live-count Per in L2 (combat.md Formulas B reads L2 at compile) |
| Tally Ten | Needs rule | effects.md Marked Prey Limits: a second Effect may raise its cap |
| Tally Gourd, Rolling Refresh | Needs rule | effects.md Trigger records: a status applied as an event |
| Extra Curse Slot, Thrifty Brand, status chance and duration | Needs key | stat keys |
| Canon, Pamphlet, seven arts | Needs key | records |
