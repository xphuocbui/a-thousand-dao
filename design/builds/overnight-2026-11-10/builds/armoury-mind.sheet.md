# The Armoury Mind (Tàng Binh Thức)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses.
> **Seed**: "L3 gear and artifact count, limited by thần thức and equip.max_slots. A build whose divine sense exists to carry more artifacts, each one acting or adding power. Max out L3 and find what the thần thức budget forces out."
> **Direction**: The Garrison Mind: L3 reaches its cap with two or three heavy pieces; every piece past that earns its peg. Weapon pieces strike at each pulse and lay Metal stacks, ward pieces become walls and linh lực, and the count itself is a layer. What L3 throws away becomes penetration. The price: the mind spread over the rack guards the soul worse.
> **Realm span**: Nascent Soul (Nguyên Anh) – Deity Transformation (Hóa Thần), defined at Nascent Soul · **Power level**: top-end · **Use**: player
> **Fit**: 3 Fits today · 10 Needs key · 7 Needs rule (equipped pieces as a readable; a layer's total before its cap; the Thinned Mind close on soul defence)
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (The fight and the identity test: no simulator this run, user decision 2026-11-11). Inside Budgets, the technique's combat passives (no `bonus_pool` row) are NOT ASSESSED.

## Directions considered

Three readings of a specific seed (Phase 3, chosen without the user by the session's override).

- **Chosen: The Garrison Mind (Thủ Khố Tâm).** A wide rack: L3 capped early, every further piece acts (a pulse strike laying Metal stacks) or adds (ward strength, ward efficiency, linh lực, body shield), the count is an L5 Per, and L3's clipped points become Physical penetration. Channel: art hit (Physical, Metal) plus trigger strikes as a status engine. Strongest for a min-max player: every slot and every unit of thần thức is a decision with a number on it, and the build stays whole in blind fights because gear is loadout, not preparation.
- **Not chosen: The Treasure Breaker (Bộc Bảo Giả).** Pieces the mind lets go burst one by one as huge hits (self-detonation), L3 falling as it goes; the cracked pieces are reported as a life cost.
  An all-in burst build, which the project wants rare (sustain is king), and it burns the player's shopping list every fight.
- **Not chosen: The Hollow Rack (Không Giá Thức).** The surprise: carry one piece, keep thần thức free, and live on Open Sky and the single-artifact multiplier (`equip.single_artifact_keystone_mult` 2.5).
  It answers "what does the budget force out" by forcing out everything, the opposite of the seed's "more artifacts", and its keystone already exists.

## The Spine

- **The channel:** art hit (Physical, Metal-tagged) and the basic attack, through all five layers; L3 is held at its cap (250 points, ×3.5). Trigger strikes from the rack are not damage (the trigger budget keeps them under half of direct damage); they are a status engine that lays Metal debuff stacks (+1.8 % Physical damage taken each, uncapped, before resistance).
- **The enabler:** Garrison Mind (Thủ Khố Tâm). Opens: at each pulse, every weapon-role piece you control strikes and lays a Metal stack, with no art slot. Closes (Thinned Mind, Thức Bạc): against soul hits, only your free thần thức and half of what your pieces bind defend you.
- **The loop:** each pulse, four to six pegs strike and renew the Metal stacks; the arts fire on cooldown into a target whose Physical damage taken keeps rising; ward pieces hum linh lực back and keep the ward fed; Physical arts renew the body shield.
- **The engine:** count and sum are different numbers. L3 reads the **sum** of attack and stops at 250, so a heavy piece wastes most of itself; the Garrison Mind, Full Rack and Humming Shields read the **count**, which only slots and thần thức limit. Past the cap, the thrown-away sum becomes penetration (Edge Past the Rack). So every piece past the second is chosen for what it does, not for its attack.
- **The sacrifice:** soul defence (the close), every trigger Effect (the strikes fill `trig_cap`), Open Sky (no free thần thức), and artifact active arts (they would take art slots the build needs).
- **The arc:** at Nascent Soul the mind is the limit: thần thức decides how many pegs hang, and cheap pieces (Needle, Armour, Shield) crowd out the heavy ones. At Deity Transformation the rack is the limit: thần thức grows past what the slots can take, and the old Nascent Soul needles, now nearly weightless, go back on the rack as strikers.

## The Legend

The Cold Pass (Hàn Ải) garrison kept the armoury for a thousand spears and never had more than forty soldiers. Its last quartermaster, Lư, could not cultivate a single great art, so he trained his mind to hold the store instead: forty blades hung on thought, each falling in its turn. The scripture he left is less a technique than an inventory.

He held the pass alone for a season. He died on the last night of it, not to a sword but to a hired soul needle a novice could have turned aside, because every part of his mind was out on the racks. His students kept the scripture and added the first line every copy now opens with: "Hang the blades, but keep one hand on the door."

Rack-keepers are prized by sects and caravans: one of them is a garrison. Soul cultivators hunt them for the same reason the assassin did. A mind that holds forty blades holds itself loosely.

## How It Fights

Before the fight, nothing: the rack is part of the loadout, so a blind ambush finds it as ready as a duel. From the first pulse, every weapon on the rack strikes the enemy once a second, small blows that mainly lay Metal stacks, and within six seconds the enemy takes about half again as much Physical damage. Called Blade and Hook and Chain keep the enemy cut open (Sundered); Peg-Line Cut stacks Metal buffs on you; Rack-Wide Volley lands every six seconds through a ward that two shields and the rack's whole weight have made thick. The ward pieces hum linh lực back each pulse, and each Physical art renews the iron of the body shield.

**The signature moment:** the first Rack-Wide Volley at six seconds. The Breakdown shows L3 clipped at 250 with 150 points spent as penetration, Full Rack at +40 for seven pieces, and 24 Metal stacks on a target that takes half again its Physical damage. Seven treasures on one mind; six of them are not why it hit.

## Enabler

**Garrison Mind (Thủ Khố Tâm)**, tier `enabler`.

- **Where a player finds it:** the Pass-Garrison Armoury Scripture at layer 11 (the Địa giai copy at layer 9), or the Kim Đạo (Bách Luyện) capstone at the far end of the Binh Khố (Armoury) facet.
- **Rule:** at each pulse, each weapon-role piece you control makes one strike: a free hit, `c_trig` 0.3, Physical, tags `kim`, `artifact`, `trigger` and the piece's own; when it lands it lays 1 Metal debuff stack for 6 s (purity-powered as any stack, effects.md rule 9a). Each strike is one trigger firing: `trig_cap` (6 a side between pulses) and `trig_budget` apply; a strike whose damage the budget clips to 0 still lands and lays its stack. Evade applies. "Control" is Item DB rule 11's: pieces the thần thức cannot hold do nothing.
- **Opens:** a status engine that scales with the number of weapon pieces, takes no art slot and costs no linh lực.
- **Closes, Thinned Mind (Thức Bạc):** against soul hits, your defending thần thức is your free thần thức plus half of what your pieces bind (Combat Formulas E2 `divine_sense_def`). This overrides, for the holder only, Combat rule 3's "the thần thức that equipped artifacts occupy does not lower the thần thức a side fights with".
- **Size of the close:** binding 83 % of the budget leaves 0.17 + 0.83 / 2 = 0.58 of it to defend, so `rho` against you rises ×1.71 and a soul hit's share ×2.94 (`soul_beta` 2). A same-sense soul art of `soul_pct` 0.05 takes 14.7 % instead of 5 %, before soul resistance and soul shields.
- **Fit:** Needs rule (effects.md rule 5: equipped pieces and their roles as a compile readable, concept `equipped-pieces-readable`; combat.md rule 3 and Formulas E2 for the close, concept `thinned-mind`). The actions (pulse event, free hit, grant element stacks) are on effects.md rule 6's list.

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Art coefficients | Rack-Wide Volley 4.65, Called Blade and Hook and Chain 1.97, Peg-Line Cut 1.62 (lint) | Flat base | art | none | ○ | Technique arts | — |
| 2 Rate | Art speed (`art_speed_pct`) | +30 to +40 from tree and Way | Increased | art | none | ◐ | Tree | every art build |
| 3 L1 | Damage, Metal damage (`attack_pct`, scoped [kim]) | top-end W share 45 % of the tree | Increased | art, basic | L1 | ● / ○ | Tree, Way | every Metal build |
| 3 L2 | Cold Iron Order (Hàn Thiết Lệnh) | `damage_more` [kim]: +60 technique (Thiên; +50 Địa), +40 per Way notable | More | art hit | L2 | ○ | Technique passive; Kim Đạo Binh Khố notables (×2) | curse-engine (Metal arts), single-metal Thousand Cuts |
| 3 L2 | Ore Weight (Khoáng Trọng) | `damage_more` [physical]: +45 technique, +25 Way node | More | art hit | L2 | ○ (staged) | Kim Đạo Lò Rèn nodes (×2) | triple-convert (its maker) |
| 3 L3 | Artifact power (`artifact_power_pct`), weapon attack (`artifact_attack_pct`, Liệt), Twin Arms (#1) | Fill L3 to its cap with two or three pieces | Increased | all hits | L3 | ● | Tree, affixes, capability #1 | every gear build |
| 3 L3 | Kindred Vessels affix (Đồng Khí) | rolled affix `artifact_power_pct` +4 to +10, any base | Increased | all hits, ward | L3 | ○ | Generated artifacts | every gear build, ward casters |
| 3 L4 | Ringing Ground (Nine Rods Array) and Iron-Sand Hand Bath | +80 and +50 L4, foreseen fights | More | art hit | L4 | ○ (staged) | Formation, coating | first-volley, bare-fist and four more |
| 3 L5 | Full Rack (Mãn Giá) | L5 +10 for each piece you control past the third, cap +50 | Per | art, basic | L5 | ○ | Technique passive (layer 12); Binh Khố `major`; Pass-Garrison Rack | soul-lance (heavy bells), NPC sect armourers, flying-sword builds |
| 3 L5 | Opened Seams (Khai Phùng) | Physical parts deal L5 +15 to a target bearing your Metal stacks | Conditional | art, basic | L5 | ○ | Technique passive (layer 13) | curse-engine, every Metal stack build |
| 3 L5 | Steady Breath (Bình Tức) | L5 +12 [kim] while linh lực ≥ 50 % | Conditional | art | L5 | ● | Named rack's line | sword, ward casters |
| 4 Crit | Crit chance and damage | tree, 25 to 50 % | Increased | art, basic | none | ● | Tree | every hit build |
| 5 Reach | Garrison Mind's Metal stacks | +1.8 % Physical damage taken a stack, × (1 + 0.002 × Metal purity) | Trigger | art, basic | none (damage taken) | ○ | Enabler | — |
| 5 Reach | Sundered (Phá Giáp), from Hook and Chain | −150 Physical resistance a stack | (curse) | art, basic | none | ● | Art | — |
| 6 Past the cap | Edge Past the Rack (Giá Ngoại Phong) | L3 points your gear brings past the cap become Physical penetration, 1 for 1, cap +200. Read at compile | Overflow | art, basic | none | ○ | Binh Khố `major`; technique passive (Thiên layer 14) | bare-fist (one heavy fist piece), any Physical gear build |
| 6 Past the cap | Artifact slots (`artifact_slots`) | +1 capability #2, +1 Binh Khố keystone, +2 Pass-Garrison Rack | Cap shift | none | none | ◐ | Capability #2, Way, named item | every gear build |
| 7 Fuel | Humming Shields (Thuẫn Minh) | at each pulse, restore 0.3 % of maximum linh lực for each ward_gear piece you control, cap 1.5 % | Per | sustain | none | ○ | Technique passive (layer 7) | home-fortress, unkillable, bare-fist (feeds Stored Breath's overflow) |
| 7 Fuel | Ward efficiency from ward gear (`a_w`) | `we` +30 per unit of a_w, no ceiling: cheaper drain and per-hit bills | Increased | sustain | none | ● | Shields, bells | every ward caster |
| 8 Survival | Ward strength from ward gear | `ws` +30 per unit of a_w, no ceiling; also scales the Soul-Guarding Lamp's soul shield bar | Increased | defence | none | ● | Shields, bells | every ward caster |
| 8 Survival | Iron Skin Renewed (Thiết Bì Phục) | a Physical art's firing restores 2 % of max health as body shield, once a pulse | Trigger | defence | none | ● | Technique passive (layer 4) | thể tu, Physical swords |
| 8 Survival | Soul resistance (Hồn Hộ lines) | +15 to +30 pp | Increased | soul defence | none | ● (staged facet) | Hồn Đạo Hồn Hộ | soul-lance |
| — Budget | Thần thức (`than_thuc_pct`) | +22.5 technique, +20 capability #2, +6 tree notables, Hồn Đạo Thần Thức lines | Increased | budget | none | ● | Technique, tree, Way | soul-lance, formation masters |
| — Budget | Weapon efficiency (Khinh Binh) | weapon-role pieces cost −6 % thần thức (notable), −15 % on the named rack | Increased | budget | none | ○ (catalogue row) | Tree, Pass-Garrison Rack | flying-sword builds, by-root Gold Rain (coins) |
| 9 Identity | Garrison Mind (Thủ Khố Tâm) | each weapon piece strikes each pulse and lays a Metal stack; Thinned Mind | Trigger + Trade | trigger, status | none | ○ | Technique, Kim Đạo capstone | — (enabler) |

**Identity piece:** Garrison Mind. Remove it and the rack's count does nothing to the enemy: no strikes, no Metal stacks, and Opened Seams never lights. Layer arithmetic only (no simulator): effective multiplier at Nascent Soul falls from about ×271 to about ×180, a third.
**Empty rungs:** none fully. L4 is empty in blind fights (a sacrifice shared by every build; the rack itself is loadout, so the rest stays). Fuel is the weakest rung: six arts overspend like most builds, and Humming Shields, ward efficiency and Re-Temper's refunds carry it.

| Layer | Points at Nascent Soul (Volley) | Multiplier | Sources |
|---|---|---|---|
| L1 | x1 ≈ 333 raw, 266 effective | ×3.66 | Top-end tree share (45 % of 739 W), soft-capped past 200 |
| L2 | 265 (other arts 235) | ×3.65 | Cold Iron Order 60 + Way 80, Ore Weight 45 + Way 50, the Volley's own +30. Under the 300 cap |
| L3 | 400 raw → 250 | ×3.5 (cap) | Nurtured Seal, Flying Sword, two Needles; 150 clipped → +150 Physical penetration |
| L4 | 130 (foreseen) / 0 (blind) | ×2.3 / ×1.0 | Ringing Ground 80, Iron-Sand Hand Bath 50 |
| L5 | 67 | ×1.67 | Full Rack 40 (seven pieces), Opened Seams 15, Steady Breath 12 |
| Outside M | 24 Metal stacks | ×1.51 damage taken | Four strikers × 6 s; Metal purity 95 |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Single Metal (Kim), purity 90 or more | Metal stacks are multiplied by (1 + 0.002 × purity): 95 gives ×1.19. Metal is the Way's requirement and the arts' element |
| Key talents | Thần hồn (soul strength) first, as high as events allow; then comprehension | Thần thức = thần hồn × realm multiplier × stage × (1 + `than_thuc_pct`). Every point is 1.5 units of rack at +50 %. Events raise thần hồn (in the game) |
| The Way (Đạo) | Kim Đạo · Bách Luyện: Binh Khố facet (artifact slots, Full Rack, Edge Past the Rack, Cold Iron Order notables, the capstone Garrison Mind); Lò Rèn for Ore Weight and artifact power lines. Second Way: Hồn Đạo, Thần Thức lines (`than_thuc_pct`) and Hồn Hộ (soul resistance) for the close | Binh Khố is the facet dao.md § Catalogue already names "the Armoury: artifact slots" |
| Meridian Map capabilities | #2 Divided Divine Sense (+1 slot, +20 % thần thức), #3 Treasure Nurtured Within (first piece costs no thần thức, +1 % a year to +50 %), #1 Twin Arms in Harmony (a pair of one kind, +15 % attack) | All in the game. #3 makes the heaviest piece free, so it goes first in equip order |

## Công Pháp

### Pass-Garrison Armoury Scripture (Quan Khố Chân Kinh) — main, Thiên giai (tier 3, to Hóa Thần)

An inventory written as a breathing method: "a blade you can name is a blade you can hold". Địa giai copy (Quan Khố Quyết, tier 2, 12 layers, to Nascent Soul) for the climb: the same without `defense_pct` (2.5 of 3).

```json
{"id": "quan_kho_chan_kinh", "name": "Quan Khố Chân Kinh", "tier": 3, "tech_kind": "main",
 "names": ["kim"], "layers": 15,
 "bonuses": [{"stat": "than_thuc_pct", "value": 22.5},
             {"stat": "linh_luc_pct", "value": 20},
             {"stat": "defense_pct", "value": 15}],
 "abilities": [{"ability_id": "called_blade", "unlock_layer": 1},
               {"ability_id": "hook_and_chain", "unlock_layer": 3},
               {"ability_id": "peg_line_cut", "unlock_layer": 5},
               {"ability_id": "re_temper", "unlock_layer": 6},
               {"ability_id": "rack_wide_volley", "unlock_layer": 8},
               {"ability_id": "shut_the_armoury_door", "unlock_layer": 10}],
 "seal_clusters": ["peg_wall"], "origin": "authored"}
```

Passives (no field yet): L2 Cold Iron Order (+60 [kim] L2), L4 Iron Skin Renewed (existing Effect), L7 Humming Shields, L11 Garrison Mind (enabler), L12 Full Rack, L13 Opened Seams, L14 Edge Past the Rack.

**Fit:** Needs key (combat passives, Effects and art records have no field in `items_cong_phap.json` yet) · **Budget:** `than_thuc_pct` 22.5 / 15 = 1.5, `linh_luc_pct` 20 / 20 = 1.0, `defense_pct` 15 / 15 = 1.0: **3.5 of 4.0**, each line ≤ `bonus_single_cap` 1.5. PASS. The passives have no `bonus_pool` row: NOT ASSESSED for budget.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Called Blade (Hô Kiếm) | Scripture, 1 | body; kim, physical, sword, art, cheap | 1.97 | 0.03 | 2 s | — | Needs key |
| Hook and Chain (Câu Liên) | Scripture, 3 | body; kim, physical, curse, art, cheap | 1.97 | 0.03 | 2 s | — | Needs key |
| Peg-Line Cut (Đinh Tuyến Trảm) | Scripture, 5 | body; kim, physical, sword, art | 1.62 | 0.05 | 3 s | — | Needs key |
| Re-Temper (Hồi Tôi) | Scripture, 6 | heal; kim, heal, art | c_heal 4.13 | 0.05 | 4 s | own health ≤ 70 % | Needs key |
| Rack-Wide Volley (Toàn Giá Tề Phát) | Scripture, 8 | body; kim, physical, art, costly, slow | 4.65 | 0.10 | 6 s | — | Needs key |
| Shut the Armoury Door (Bế Khố Môn) | Scripture, 10 | cleanse; soul, cleanse, art | — | 0.03 | 3 s | own status Slackened Soul or Silence | Needs key |

- **Called Blade.** Effect: a Physical hit. Lint 1 + 24 × 0.03 + 0.25 × 1 = 1.97. Description: the nearest blade answers before it is named.
- **Hook and Chain.** Effect: a Physical hit; applies Sundered (1 stack). Curses carry no lint charge today, so c sits at the plain lint (first guess). Description: one hook takes the shield, the chain takes the arm.
- **Peg-Line Cut.** Effect: a Physical hit; grants its owner 4 Metal buff stacks for 10 s (+1.2 % Physical damage dealt each). Lint 2.70 × (1 − 0.40 buff charge) = 1.62. Description: a line of pegs, each blade taking its own turn.
- **Re-Temper.** Effect: heal (combat-defence.md Formulas E), U × 4.13 × 4, refunding its cost when it heals (rule 16). Heal lint 1.4 × 2.95. Description: quenching the self as one quenches a blade.
- **Rack-Wide Volley.** Effect: a Physical hit; carries `damage_more` +30 L2 for itself. Slot 1. Lint 1 + 2.4 + 1.25 = 4.65. Description: every blade on the rack falls on one point.
- **Shut the Armoury Door.** Effect: cleanse curses with the `soul` or `seal` cleanse tag from its owner (the Bell of Waking's shape, its own record). The close's own answer. Description: "keep one hand on the door".

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Nascent Soul | 6 | Rack-Wide Volley, Peg-Line Cut, Hook and Chain, Called Blade, Re-Temper, Shut the Armoury Door | Free ward slots (3): Common Ward (drain), Golden Bell (per hit), Soul-Guarding Lamp (reserved 0.20) | Seven pieces (6 + capability #2) |
| Deity Transformation | 7 | as above, then a talisman or a drain ward in the art slot | as above | Ten pieces (6 + #2 + Binh Khố keystone + the rack's +2) |

## Items

**The rack at Nascent Soul** (Cực phẩm, Nascent Soul tier; numbers at stage 1.00; thần thức in units of base cost, since the realm multiplier cancels for pieces of your own realm's tier).

| # | Item | Type, role | What it gives | Thần thức | Fit |
|---|---|---|---|---|---|
| 1 | Nurtured Seal (any Ấn, Liệt +30) | artifact, weapon | x3 156, rising to 234 over 50 years (#3); striker | 0 (capability #3) | Fits today |
| 2 | Flying Sword (Phi Kiếm, Liệt +25) | artifact, weapon | x3 112.5; striker | 20 | Fits today |
| 3, 4 | Two Needles (Châm) | artifact, weapon | x3 66 each; strikers | 10 each | Fits today |
| 5 | Shield (Thuẫn, Kiên +30) | artifact, ward_gear | a_w 1.365: ws and we +41 | 15 | Fits today |
| 6 | Shield (Thuẫn, Kiên +20) | artifact, ward_gear | a_w 1.26: ws and we +37.8 | 15 | Fits today |
| 7 | Armour (Giáp) | artifact, body_gear | a_b 0.9: σ_b 0.54, block 10.8 | 5 | Fits today |
| | **Total** | | **x3 400 → 250 (cap); 150 → penetration. a_w 2.78 → ws, we +83. 4 strikers. 7 pieces** | **75 of 90** | |

The budget here: thần hồn 60, `than_thuc_pct` +50 (technique 22.5, #2 20, one tree notable 6, a Hồn Đạo line) → 60 × 1.0 × 1.5 = 90 units.

**What the budget forces out at Nascent Soul.** With 15 units left, a second Seal (30) does not fit, nor a Bell (25), nor a third Shield and a Needle at once. The cheap bases win the count: per unit of thần thức a Needle gives 6.6 points of L3 and a strike, a Seal 4.0; per slot the Seal gives 120 and the Needle 66. Short of thần thức, the rack fills with Needles, Shields and Armour; short of slots, with Seals and Bells. Also forced out: Open Sky (nothing left free), any trigger Effect (the strikes fill `trig_cap`), and artifact active arts (art slots).

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| The Pass-Garrison Rack (Quan Ải Binh Giá) | named artifact, utility | new base `gia` (rack: attack 0, defence 10, thần thức 15), Cực phẩm, Nascent Soul or Deity Transformation tier | `artifact_slots` +2 (rare, named only), `artifact_power_pct` +15, Weapon efficiency −15 % (weapon-role pieces), Steady Breath [kim]; carries Full Rack as a second host. Net +1 piece and the count's Effect | Needs key |
| Kindred Vessels affix (Đồng Khí) | affix row | any base | `artifact_power_pct` +4 to +10; every piece's affix lifts every piece | Fits today |
| Nine Rods Array (Cửu Can Trận) | formation | foreseen only | Ringing Ground +80 L4 on art hits | Needs key (staged) |
| Iron-Sand Hand Bath (Thiết Sa Dục Thủ) | coating | foreseen and ambush | +50 L4 on body hits | Needs key (staged) |

The rack's history: forty pegs of black oak from the Cold Pass armoury, the iron hooks worn bright where Lư's thought rested on them. Whoever holds it can hang two more blades than their mind should bear.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Capability #2 Divided Divine Sense | +1 slot, +20 % thần thức | Both limits at once | Fits today |
| 2 | Capability #3 Treasure Nurtured Within | first piece free, +50 % over 50 years | The heaviest piece costs nothing | Fits today |
| 3 | Thần thức (`than_thuc_pct`) | +0.9 / +6 | The budget | Fits today |
| 4 | Artifact thần thức cost (`than_thuc_cost_pct`) | −1.5 / −10 | The budget, other side | Fits today |
| 5 | Weapon efficiency | −1 / −6 (weapon pieces) | Cheaper strikers | Needs key |
| 6 | Artifact power (`artifact_power_pct`) | +0.9 / +6 | L3 reaches the cap with fewer pieces; ward gear grows | Fits today |
| 7 | Damage, Metal damage, crit | catalogue | L1 and crit | Fits today / Needs key |
| 8 | Capability #1 Twin Arms in Harmony | +15 % attack for a pair | Only past the cap as penetration; take late | Fits today |

### Hidden cluster idea: Peg Wall (Đinh Bích)

Theme: the armoury (artifacts carried and controlled), wider than this build: any gear-heavy cultivator, flying-sword users, sect quartermasters. Metal affinity. Sealed, 8 acupoints; seal: the Pass-Garrison Armoury Scripture lists it in `seal_clusters`. Smalls: `than_thuc_pct` +0.9 (×2), `than_thuc_cost_pct` −1.5 (×2), `artifact_power_pct` +0.9, Weapon efficiency −1; notables `than_thuc_pct` +6 and, farthest, Humming Shields. No capability. An idea for the tree rework, not data. Note: Item DB rule 3 records the Meridian Map's hidden clusters as retired (2026-11-10); this is offered as a region idea for the rework.

## Đạo

Kim Đạo · Bách Luyện, **Binh Khố facet (the Armoury)**, requirement Metal. Nodes that matter: `artifact_slots` +1 as a rare notable (Item DB rule 11 names Binh Khố as a source); Cold Iron Order notables (+40 [kim] L2, ×2); Full Rack as the facet's `major`; Edge Past the Rack as a second `major` at Nascent Soul; stat lines `than_thuc_cost_pct`, `artifact_power_pct` and `artifact_attack_pct`; the capstone holding Garrison Mind. From **Lò Rèn**: Ore Weight nodes (+25 [physical] L2, ×2). The graph is not drawn, and this session did not read `design/dao-ways/`.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Core Formation (before the span) | A sword cultivator with three pieces and a Địa giai copy of the scripture | Capability #3 on the first good Seal; Called Blade, Hook and Chain | Finds the scripture in a garrison's ledger chest |
| Nascent Soul | Seven pieces, thần thức the limit; L3 at the cap from the first stage, penetration from the surplus | Garrison Mind, Full Rack, Edge Past the Rack, capability #2, Soul-Guarding Lamp | The first soul needle that gets through; learns to shut the door |
| Late Nascent Soul (stage 1.45) | Every piece's attack and defence ÷ 1.45: L3 400 → 276, the surplus nearly gone; thần thức ×1.45 frees room for heavier pieces | Refine or replace the Needles with a second Seal | Pieces fall behind the body; the quartermaster's work is never done |
| Deity Transformation | Ten pieces; slots the limit. Old Nascent Soul Needles cost 3 units (10 × 30 / 100) and still strike; new pieces carry L3 | Thiên giai scripture to layer 14, the Pass-Garrison Rack, Binh Khố keystone | The old blades go back on the rack; nothing is thrown away |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical peer (Nascent Soul) | wins | ×271 effective against the typical ×7.37; the Volley alone ends it early |
| Top-end peer, Physical arts | even to wins | Matches the top-end ×256; ward gear thinner than the anchor's a_w 5 (2.78), so it wins on stacks and penetration, not walls |
| Physical-resistant (150+ points, rule 18) | wins | Penetration 150 + Sundered −150 a stack + Metal stacks before resistance |
| Earth body (Earth buff: Physical taken dampened) | even | Earth stacks offset Metal stacks; L3 and penetration stay |
| Soul-piercer (rule 18 soul dealer) | loses unless prepared | Thinned Mind: ×2.94 soul share. The Lamp's soul shield (bar 0.10 × (1 + ws/100) of linh lực, about 0.26 at ws 160) and Hồn Hộ lines turn it to even |
| Evader | even | Strikes and hits can be evaded; fewer stacks |
| Cleansing ward (Clear Heart) | wins, slower | A quarter of each Metal batch a pulse; the strikes renew every pulse |
| Drainer (Qi Disruption) | even | Six arts overspend; ward efficiency +83 and Humming Shields carry it |

**Counter:** a soul-piercer. The rack spreads the mind, so a soul art that would be a nuisance to a peer takes three times as much. Adapt with the Soul-Guarding Lamp in a ward slot, Hồn Hộ soul resistance, Shut the Armoury Door in the loadout, and before a foreseen fight against a soul sect, take a piece or two off the rack: each unit unbound defends at full.

## Checks

Each result is PASS, FAIL or NOT ASSESSED, with the reason.

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Technique 3.5 of 4.0, each line ≤ 1.5; arts inside the lint (1.97, 1.97, 1.62 with buff charge, 4.65; heal 4.13); 6 art slots of 6 at Nascent Soul, 7 of 7 at Deity Transformation; 7 pieces of `equip.max_slots` 6 + `artifact_slots` 1; thần thức 75 of 90 units. **NOT ASSESSED inside it:** the passives (no `bonus_pool` row) |
| Validity | PASS | Bases `an`, `phi_kiem`, `cham`, `thuan`, `giap`, `chuong` from `items_artifacts.json`; grade `cuc` (rank 4) is inside the Nascent Soul and Deity Transformation artifact grade cap 4; tier 3 (Thiên) `max_realm` hoa_than covers the span; element kim; single main, no auxiliary harmony to check. New base `gia` labelled Needs key |
| Stack | PASS | Every rung filled (L4 empty in blind fights, stated); forms: Flat base, Increased, More, Per, Conditional, Trigger, Overflow, Cap shift, Trade (9); L5 pieces aim at hits, strikes aim at stacks only; layer totals stated above |
| Identity test | NOT ASSESSED | No simulator this run (user decision 2026-11-11). Layer arithmetic only: without Garrison Mind, effective ×271 → ×180 at Nascent Soul |
| Scaling | PASS | Nascent Soul: layers ×180, ×271 with stacks, against the top-end anchor ×256. Deity Transformation: ×241, ×396 with 30 stacks, against ×325: INFO, above the anchor, not pulled back |
| The fight | NOT ASSESSED | No simulator this run (user decision 2026-11-11). Not hand-simulated |
| Reuse | PASS | Reused: Ore Weight, Nine Rods Array, Iron-Sand Hand Bath, `layer-total-readable`, Hồn Đạo Thần Thức and Hồn Hộ facets, `preparation-fight-payload`, Thousand-Weight Thought (optional). Every new piece names a second home; one signature piece (the named rack, a carrier of shared pieces) |
| NPC use | PASS | Every Effect reads compile values or pulses, needs no input; a generator equips by role and count. Breakdown lines: "Full Rack: 7 pieces, +40", "Edge Past the Rack: L3 400 → 250, +150 Physical penetration", "Garrison Mind: 4 strikes, 4 Metal stacks", "Thinned Mind: soul defence 0.58 of thần thức" |
| Counterplay | PASS | Soul-piercer (rule 18 soul dealer); also evaders and Earth bodies blunt the stacks |
| Originality | PASS | Names checked against no known novel or game term; "flying sword" and "treasure" are genre nouns. The single-artifact keystone already in data is the opposite pole, not a copy |

## Fight Results

No fight input and no simulation this run (user decision 2026-11-11). The engine is stated above from the formulas: Item DB Formulas D (attack, defence, thần thức cost), Combat Formulas B (L3, caps), Combat Defence & Healing Formulas A0 (a_w, a_b), Character Stats Formulas C (divine sense), Combat Formulas E2 (soul share), G (free hits, `trig_cap` 6), Effects rule 9a (Metal stacks).

**Unmodelled:** everything; in particular the trigger budget's clip on strike damage, Metal stack decay under cleansing, linh lực over the fight, and the soul close against a real soul kit.

## New Concepts

**Equipped pieces as a readable** (`equipped-pieces-readable`). Effects rule 5 lists free thần thức but not the pieces themselves. Rule: at compile, an Effect may read the pieces its owner controls (Item DB rule 11: equipped, within thần thức, in equip order), their count, and each piece's role tags and base. Bounds: compile only; uncontrolled pieces never count. Breakdown: "Controlled pieces: 7 (weapon 4, ward_gear 2, body_gear 1)". Serves: this build, soul-lance (heavy treasures), any flying-sword or sect-armourer build, NPC gear archetypes. Question for the user: add to effects.md rule 5?

**Thinned Mind** (`thinned-mind`). A close that lets bound thần thức count only in part toward soul defence. Rule: an enabler's close may set, for its holder, `divine_sense_def = free + k × bound` (k = 0.5 here) in Combat Formulas E2. Combat rule 3's line stays true for everyone else. Bounds: k between 0 and 1; only an enabler or keystone may carry it. Breakdown: "Thinned Mind: 0.58 of thần thức defends". Serves: this build; a future treasure-hoard keystone; NPC armourers (the soul cultivator's natural prey). Question for the user: allow this closing rule?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Garrison Mind | Needs rule | effects.md rule 5 (`equipped-pieces-readable`); combat.md rule 3 and Formulas E2 (`thinned-mind`) |
| Full Rack | Needs rule | `equipped-pieces-readable` |
| Humming Shields | Needs rule | `equipped-pieces-readable` |
| Edge Past the Rack | Needs rule | `layer-total-readable` (staged by home-fortress), effects.md rule 5 |
| Binh Khố facet pieces | Needs rule | via the Effects above; `artifact_slots` in the Way's `theme_stats` |
| Cold Iron Order | Fits today | a content row: `damage_more` [kim] L2 |
| Kindred Vessels affix | Fits today | an `affixes` row on `artifact_power_pct` |
| Opened Seams | Fits today | an Effect record (Metal twin of Kindled Wound) |
| Weapon efficiency | Needs key | `than_thuc_cost_pct` scoped by role [weapon] (Modifier System role scope) |
| The Pass-Garrison Rack | Needs key | new base `gia`; Weapon efficiency |
| Pass-Garrison Armoury Scripture | Needs key | combat passives and art records on technique templates |
| Six arts | Needs key | art records |
| Peg Wall | Needs key | a cluster idea for the tree rework (clusters retired; region idea) |
| `artifact_slots` | Needs key (designed) | Character Stats key exists in the GDD, not in code (Item DB Build Gaps rule 11) |
