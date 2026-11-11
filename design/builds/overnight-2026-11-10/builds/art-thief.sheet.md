# The Hollow Thief (Hư Thủ Thâu Pháp)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: Copy or steal the enemy's arts mid-fight and fire them back. Empty slots that fill with what the enemy brought. Strong against art-heavy builds, helpless against a bare-fist build.
> **Direction**: The Borrowed Hand (Tá Thủ): empty art slots become loan slots (tá vị) that record the foe's arts as they are cast. Chosen by the author, see Directions considered.
> **Realm span**: Kết Đan (Core Formation) to Nguyên Anh (Nascent Soul) · **Power level**: top-end · **Use**: player
> **Fit**: 3 Fits today · 17 Needs key · 6 Needs rule
> **Checks**: 6 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: technique and thần thức budgets cannot be checked; Stack: the identity test ran only on an approximation, the theft engine is unmodelled; The fight: the engine is unmodelled, so the fight is the nearest approximation)

## Directions considered

**Chosen: The Borrowed Hand (Tá Thủ).** Channel: art hit, with the foe's own coefficients run through the player's layers. It is the only reading where the seed's three promises (steal, fire back, slots that fill) are one rule, and it has the clearest signature moment (a loan slot fills with the foe's best art and it goes straight back).

Not picked:
- **The Open Book (Khai Quyển), reflect and return.** Hits and arts thrown at you come back as damage. It overlaps the existing reflect builds, takes nothing and gives the player no new loadout moment.
- **The Silenced Hall (Phong Pháp), denial.** Delay and seal the foe's arts with timer moves. It wins by taking, so the player never fires anything the foe brought, and the "fire them back" half of the seed is lost.
- **The Scribe Who Keeps (Lục Pháp), learning.** A stolen art is kept for life as a new art. It is a progression system, out of the fight, and would need save-state rules before it did any fighting.

## The Spine

- **The channel:** art hit. A copy is an art in a loan slot: it fires on the player's cooldown timer, spends the player's linh lực and takes all five layers of the player's multiplier, not the foe's. L2 and L5 are the layers the build tunes for copies.
- **The enabler:** Borrowed Hand (Tá Thủ), the first divine ability of the Hollow Hall Sutra (layer 4). It opens loan slots (every empty art slot at fight start). It closes the slots themselves (a slot with an own art holds no copy), copies of soul, ward and escape arts, and anything at all against a foe with no art.
- **The loop:** the foe casts, a copy of it is recorded, half a cooldown later it fires back at the foe, then again on its cooldown. A new foe art takes the next loan slot; when all are full the oldest copy is spent.
- **The engine:** Borrowed Weight, a Per modifier: each distinct copy in hand makes every copy hit harder, and Full Hand pays more when every loan slot is full. The foe's own arts are the build's fuel. The more arts it throws, the harder they return.
- **The sacrifice:** two own arts only, with the weak Hollow Palm for damage. Against a bare-fist foe there is nothing to copy and the player has little of its own to fall back on. The build refuses to fix this (no big own art, no talismans, which would eat loan slots).
- **The arc:** Kết Đan, five slots, three loans, learning to read which foes bring arts. Nguyên Anh, six slots, four loans, Pre-Read and Spent Hand: the player opens a fight already holding the foe's best art and turns its overflow into free hits.

## The Legend

The Hollow Hall Sutra (Hư Đường Kinh) was written by a failed sect librarian, a copyist who could never finish a technique of her own. The sutra says the vessel that holds nothing can hold anything, and its first rule is that a cultivator must leave the halls of the mind empty. Her sect hanged her for stealing from the sword sect's archive. They never found the manuscripts, because she had read them once and kept them in her head.

Those who walk it now are called hollow hands (hư thủ). They carry two arts, and everyone assumes the rest of the slots are idle. Then the foe casts its best art and the hollow hand answers with it. The path does a quiet harm: a hollow hand stops being able to value a technique that is merely theirs. Every sect whose arts are its pride wants them gone, and the martial sects of the bare fist smile at them, because the fist can't be copied.

## How It Fights

The hollow hand opens with two modest arts and empty slots. The foe's first art lands, and a copy of it forms in a loan slot at half its cooldown. Soon the foe's own fire or blade returns to it, on the player's multiplier. By Nguyên Anh the player holds up to four of the foe's arts, the oldest ones spend themselves as free hits when a fifth arrives, and the pool is kept alive by the half-price copies and the Water root's regeneration.

**Signature moment:** a sword-sect elder throws his ninth-layer sword rain, and four seconds later it comes back down on him, faster than he cast it, with his own name on it in the fight log. The log reads "Copy of Rain of Nine Swords, 2.6 coefficient, loan slot 1".

## Enabler

**Borrowed Hand (Tá Thủ)** lives on the Hollow Hall Sutra, unlocked at layer 4 of 12. A player finds the sutra as a Địa giai (tier 2) copy in a ruined sect library, or a hall of a fallen scribe sect.

Opens: at the start of the fight every art slot with no art, talisman, ward or escape art becomes a loan slot (see the staged concept empty-art-slot). When the foe casts a body or qi art, the oldest empty loan slot records a copy. The copy keeps the foe's tags plus `stolen`, a fidelity share of its coefficient (70 % base), costs half its cost share, and starts at half its cooldown. It fires on the player's cooldown timers with the player's art speed and layers. The same art id twice refreshes its copy instead of taking a second slot. When all loan slots are full the oldest copy is lost (Spent Hand turns that into a free hit).

Closes: a loan slot holds nothing until the foe casts, so the build has no opening volley of its own. Soul arts, wards and escape arts cannot be copied. A talisman or an own art in a slot removes a loan slot. Copies vanish when the fight ends.

## The Stack

Sizes on new modifiers are first guesses. The stack climbs the ladder for the art-hit channel.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Faithful Copy (Chân Bản) | Copies start at 70 % of the foe's coefficient, +6 points for each notable, cap 100 % | Flat base | art (copy) | none | ○ | Hollow Hall cluster | any build that copies, clones or summons a likeness of an art |
| 2 Rate | Warm Hand (Nhiệt Thủ) | A fresh copy starts at 25 % of its cooldown, not 50 % | Timing | art (copy) | none | ○ | Hollow Hall cluster, a Hư Thực notable | any opening-speed build |
| 2 Rate | Stolen art speed (the catalogue's art speed with one tag) | +6 % art speed on `stolen` arts, notable | Increased | art | none | ● row, tag ○ | tree | any tag-scoped speed build |
| 3 Multiplier L1 | Damage (`attack_pct`) | about +400 raw, counts as +300 past the soft knee | Increased | all | L1 | ● | tree, Way W | every build |
| 3 Multiplier L2 | Pilfered Craft (Thâu Công) | +30 % more damage on `stolen` arts | More | art (copy) | L2 | ○ | Hư Thực Đạo notable | any collector, mimic or companion-art build |
| 3 Multiplier L2 | Borrowed Weight (Mượn Trọng) | +12 % more for each distinct copy held, cap 4 (+48) | Per | art (copy) | L2 | ○ | Hollow Hall Sutra layer bonus | signature |
| 3 Multiplier L3 | Gear | Thousand-Hands Gauntlet and armour, about +240 | none | all | L3 | ○ | artifact | any weapon build |
| 3 Multiplier L4 | Mirror-Study Array, Still-Mind Pill, Home Ground | about +150 prepared | none | all | L4 | ○ / ● | formation, pill, keystone | any preparation build |
| 3 Multiplier L5 | Full Hand (Mãn Thủ) | +60 % more hit damage while every loan slot holds a copy | Conditional | art (copy) | L5 | ○ | Hư Thực Đạo notable | any full-loadout build |
| 4 Crit | Crit chance with one tag (the catalogue's "crit chance with swords") | +5 % crit chance on `stolen` arts | Increased | art | none | ○ | tree | any tag-scoped crit build |
| 5 Reach | Own Medicine (Dĩ Độc Công Độc) | The foe's resistance to a copy's tags counts at half | More | art (copy) | none | ○ | Hollow Hall cluster | any build facing a resistant foe |
| 6 Past the cap | Spent Hand (Tàn Thủ) | When a copy would be lost because the loan slots are full, it is released at once as a free hit at 50 % of its coefficient | Overflow | trigger | none | ○ Effect | Hư Thực Đạo keystone | any slot-limited trigger build |
| 7 Fuel | Stolen Breath (Tá Tức) | A copy's hit restores 1.5 % of maximum linh lực | Trigger | art (copy) | none | ○ | Hollow Hall cluster | any leech build |
| 7 Fuel | Art cost and regeneration (`art_cost_pct`, `linh_luc_regen_pct`) | −35 % art cost, +5 percentage points a pulse regeneration | Increased | any | none | ● | tree, root | every sustain build |
| 8 Survival | Hollow Guard (Hư Hộ) | +8 % more ward strength for each loan slot still empty | Conditional | ward | W2 | ○ | Bare-Scroll Robe | any build that wants empty slots (Clear Path, Quiet Channels) |
| 9 Identity | Borrowed Weight + the enabler | see below | Per | art (copy) | L2 | ○ | | |
| – Cap shift | Wide Sleeve (Khoan Tụ) | +1 loan slot, and own arts cost +20 % linh lực | Cap shift and Trade | none | none | ○ | Hollow Hall cluster keystone | any slot-bender |

**Identity piece:** Borrowed Hand with Borrowed Weight on it. Without the copies the build is two modest arts, and the `--without` run shows the foe's fight lasting longer (see Fight Results). Forms used: Increased, More, Flat base, Per, Conditional, Timing, Overflow, Trigger, Cap shift and Trade (ten).
**Empty rungs:** none. Rung 5 is thin by design: Own Medicine is the only reach. Rung 4 is a gap against the top-end crit cap: the build is at +20 % crit chance, not the 50 % cap, and spends its points elsewhere.

| Layer | Points at Nguyên Anh | Multiplier | Sources |
|---|---|---|---|
| L1 | 400 raw, 300 counted | ×4.0 | tree and Way W attack nodes |
| L2 | 200 on every art, +100 on copies (at the cap of 300) | ×3.0 own, ×4.0 copy | sutra layers 80, Hư Thực notables 70, tree art-more 50; copies add Pilfered Craft 30, Borrowed Weight 48, Hư Thực 22 |
| L3 | 240 (cap 250) | ×3.4 | Gauntlet 90, armour and artifact power rolls |
| L4 | 150 | ×2.5 | Mirror-Study Array 70, Home Ground 50, pill 30 |
| L5 | 0 on own arts, +60 on copies | ×1 own, ×1.6 copy | Full Hand; own arts hold no L5 condition |

Static M at Nguyên Anh: own arts about 102, copies about 218, against the top-end anchor of 256 and the typical 7.37. The build sits just under the top-end on copies and at 40 % of it on own arts (INFO).

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water and Metal, two elements, Water at 60 purity or more, Metal at 50 | Water is the vessel that takes any shape, and its stacks feed linh lực and regeneration, the sustain the half-price copies still need. Metal is the mirror: the crit and physical tags that copies of blade arts want. Hư Thực Đạo needs no element, so the root is free. |
| Key talents | Comprehension (ngộ tính) and thần thức | Comprehension raises technique strength and the sutra's layers come faster. Thần thức carries the Gauntlet, the robe and more, and a high soul keeps soul-art foes from ending the fight before the first copy. |
| The Way (Đạo) | Hư Thực Đạo (Empty and Full), facets Ẩn Thực (Hidden Strength) and Thực Kích (True Strikes), and the capstone Hư Thực Tương Sinh | Its catalogue capstone, "which blow was real?", is already about the empty becoming the full. |

## Công Pháp

### Hollow Hall Sutra (Hư Đường Kinh): main, Địa giai (tier 2)

A copyist's unfinished sutra, which gets stronger the less of it is written down.

```json
{"id": "hu_duong_kinh", "name": "Hư Đường Kinh", "tier": 2, "tech_kind": "main",
 "names": ["thuy"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 12},
             {"stat": "linh_luc_regen_pct", "value": 0.4}],
 "abilities": [{"ability_id": "borrowed_hand", "unlock_layer": 4}],
 "seal_clusters": ["hollow_hall"], "origin": "authored"}
```

**Fit:** Needs rule (the ability) · **Budget:** `linh_luc_pct` 12 is the same value as the shipped `dia_thuy` at the same tier. The regeneration bonus and the Borrowed Weight layer bonus are not in `bonus_pool` and cannot be checked: NOT ASSESSED. Tier 2's `max_realm` is `nguyen_anh`, so it reaches the whole span.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Hollow Palm (Hư Chưởng) | Sutra, layer 1 | qi, Water, Palm, strike | 2.6 | 0.04 | 4 s | none | Needs key (Palm and strike tags unchecked) |
| Still Pool Mending (Tĩnh Trì Hồi Khí) | Sutra, layer 2 | qi, Water, heal | heal 1.2 | 0.04 | 6 s | none | Fits today |
| Loan copy (Tá Chiêu), generated | Borrowed Hand | the foe's tags plus `stolen` | 70 to 100 % of the foe's | half the foe's | the foe's, first firing at 50 % | none | Needs rule |

**Hollow Palm effect:** a plain hit; art lint 2.71, so inside. **Description:** an open hand that takes nothing and leaves no mark.
**Still Pool Mending effect:** heals 1.2 coefficient; heal lint 4.49, so inside. **Description:** the stillness after a copied storm.

Two own arts only, by design. Hollow Palm is the only own damage, which is why the build is "helpless against a bare-fist build": Hollow Palm alone does not carry a Nguyên Anh fight.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Kết Đan | 5 | Hollow Palm, Still Pool Mending, then 3 loan slots | Drain ward, typical ws 47.9 plus layers | Three live copies is about what a typical foe's arts give. |
| Nguyên Anh | 6 | the same two, then 4 loan slots (5 with Wide Sleeve) | Drain ward, layers at the caps | Pre-Read fills loan slot 1 at t = 0 if the foe is known. |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Thousand-Hands Gauntlet (Thiên Thủ Thủ Sáo) | artifact, weapon | glove base if there is one, otherwise a weapon base; high grade, Nguyên Anh | L3 weapon attack, and the affix Warm Hand. Its history: a thief-saint's glove, said never to have been cleaned | Needs key |
| Bare-Scroll Robe (Bạch Quyển Y) | artifact, ward role (armour) | `giap`, high grade, Nguyên Anh | Ward strength, and Hollow Guard, so empty slots are worth something while they wait | Fits today |
| Mirror-Study Array (Duyệt Kính Trận) | formation, L4 | a small standing array | L4 prepared more, and Pre-Read: the foe's most costly known art is in loan slot 1 at t = 0. Only if the foe is known (Standing Array keystone lets it work in a blind fight) | Needs rule |
| Still-Mind Pill (Tĩnh Tâm Đan) | pill, preparation | an existing alchemy tier | Modest `than_thuc_pct` and `pill_effect` for the fight, so the robe and the Gauntlet both fit | Fits today |

Talismans are left out on purpose: each takes an art slot, and an art slot is a loan slot.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Damage (`attack_pct`) nodes | to +200 raw | L1 | ● |
| 2 | Art speed with the `stolen` tag | +6 % notable | rate | Needs key |
| 3 | Art cost, regeneration, max linh lực | −3 % / +1 % / +8 % notables | fuel, the build must stay alive on half-price copies | ● |
| 4 | Hollow Hall cluster | see below | fidelity, warm hand, reach, breath | Needs key |
| 5 | Home Ground keystone (Địa Lợi) | ground tags always count | L4 | Needs rule (already in the catalogue) |
| 6 | Crit chance on `stolen` | +5 % notable | rung 4 | Needs key |

### Hidden cluster idea: Hollow Hall (Hư Đường)

Theme: the Way of Copying and Emptiness, wider than this build (any mimic, student or NPC scribe). Element affinity: Water. Kind: sealed. Seal condition: a technique, the Hollow Hall Sutra lists it in `seal_clusters`. Size: 8 acupoints, 2 notables. The small acupoints are +1.2 % maximum linh lực, +0.15 % regeneration, +0.5 % art speed on stolen arts, and −0.5 % art cost. The notables are Faithful Copy (+6 fidelity points) and Own Medicine. The payoff farthest from the entry is a keystone-style notable: Wide Sleeve (+1 loan slot, own arts cost 20 % more). It carries no capability. An idea for the tree rework, not data.

## Đạo

Existing Way: Hư Thực Đạo (Empty and Full), catalogue number 14. The nodes that matter are: Ẩn Thực notable, Pilfered Craft; Thực Kích notable, Full Hand; and the capstone, Hư Thực Tương Sinh, the keystone that carries Spent Hand. Every other node is a stat line on its `theme_stats`. No new Way is proposed. The Way holds the L2 and L5 payoff so that the sutra can stay general.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Kết Đan | Two arts and three loans, reading what a foe brings; fights end in 3 to 4 s against a typical foe in the fight check | Borrowed Hand at sutra layer 4, Hollow Hall cluster entry | The first time the foe's own art is used on it, the player stops being able to enjoy their own techniques |
| Nguyên Anh | Four or five loans; Pre-Read opens fights already armed; Spent Hand makes a full hand a weapon | Mirror-Study Array, Hư Thực keystone, Wide Sleeve | A player who has copied a hundred arts realises they have none that is theirs |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical art caster (three or four arts) | wins | every art it casts comes back, fight about 3 s at Nguyên Anh (matrix) |
| Healer (arts and heals) | wins | the copy of a heal art heals the thief, and the foe's own arts come back |
| Sect elder with a big signature art | wins | one copy at full fidelity carries the fight |
| One-art hermit | even | one copy only, no Borrowed Weight beyond one, and Hollow Guard but a lazy fight |
| Soul-art cultivator | loses | soul arts cannot be copied and soul skips the ward |
| Top-end alpha striker | loses | the matrix: 0 wins in 20, about 9 s at Nguyên Anh; the foe kills before the copies ramp |
| Bare-fist body cultivator (thể tu) | loses | nothing to copy: the build is Hollow Palm and a heal |

**Counter:** the bare-fist body cultivator, with basic attacks only, and the soul-art cultivator. Adapt by bringing more own arts (leaving fewer loan slots), a Hollow Guard robe and a soul ward, and by accepting that this is the matchup to lose.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts inside the lint (no `lint_over`); slots 5 and 6 respected; artifacts within thần thức were not checked. The technique's second bonus and the new keys are outside `bonus_pool`. |
| Validity | PASS | Realms `ket_dan` and `nguyen_anh`; tier `dia` (`max_realm` `nguyen_anh`); elements water, metal, fire and thunder are real. No auxiliary technique, so no harmony check applies. |
| Stack | NOT ASSESSED | Ten forms, an identity piece, every rung filled or named. The identity test ran on the approximation only: the theft engine itself is unmodelled. |
| Scaling | PASS | Copies about 218 against the 256 top-end anchor, own arts about 102. INFO: L2 on copies is at its 300 cap. |
| The fight | NOT ASSESSED | The engine (theft and loan slots) is unmodelled. Nearest approximation: see Fight Results. |
| Reuse | PASS | 7 pieces reused (see staging). Signature pieces: Borrowed Weight and the Borrowed Hand rule. Every other new piece has a second home. |
| NPC use | PASS | An NPC with the sutra needs no input from a player; the Breakdown line is "Loan slots 3: Copy of Rain of Nine Swords, Copy of Searing Palm". |
| Counterplay | PASS | A bare-fist body cultivator, a soul-art cultivator and a top-end alpha striker each beat it. |
| Originality | PASS | No names or techniques taken from a novel or a game. The sutra, copyist and Hư Thực Đạo are this project's. |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/art-thief.fight.json` (Nguyên Anh) and `art-thief.ket-dan.fight.json` (Kết Đan). Observations from `fight.py` on the combat simulator (20 fixed seeds), not the game. The copies are three ordinary arts with a 4 to 6 s first firing, with the stolen L2 and L5 points in their `x`.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Nguyên Anh file | 0 | 20 / 0 / 0 | 3.0 s | never | still-pool-mending, loan-slot-2, loan-slot-3 | none |
| typical, Nguyên Anh file | +1 | 20 / 0 / 0 | 3.2 s | never | n/a | none |
| top_end, Nguyên Anh file | 0 | 0 / 20 / 0 | 9.3 s | 8.8 s | none | none |
| top_end, Nguyên Anh file | +1 | 0 / 20 / 0 | 4.1 s | 3.8 s | n/a | none |
| typical, Kết Đan file | 0 | 20 / 0 / 0 | 3.3 s | never | still-pool-mending, loan-slot-2, loan-slot-3 | none |
| typical, Kết Đan file | +1 | 20 / 0 / 0 | 4.5 s | never | n/a | none |
| typical, Kết Đan file | +2 | 20 / 0 / 0 | 12.5 s | never | n/a | none |
| top_end, Kết Đan file | 0 | 0 / 20 / 0 | 4.0 s | 4.0 s | still-pool-mending, loan-slot-3 | none |

A top-end build ends a typical same-realm fight in a volley or two (rule 18), and these do (3.0 and 3.3 s). The fights against a full-cap top-end foe are lost, since the build holds no L5 on own arts and its copies arrive 4 s in. The matrix also shows the build still winning a typical foe two realms up.

**Identity test** (`--without loan-slot-1-copy`): Nguyên Anh: typical+1 changed (3.2 to 4.0 s), top_end+0 changed (9.3 to 10.0 s), the others NO_CHANGE. Kết Đan: typical+1 changed (4.5 to 5.4 s), typical+2 changed (12.5 to 17.0 s). It proves only that the approximating arts matter, not the theft rule.

**Unmodelled** (the script's `model_note` and `UNMODELLED` lines): theft itself, and copies as whatever the foe fires, FIFO replacement; loan slots and the `stolen` tag (the `x` points stand in); the half-cost and half-start rules; a bare-fist foe, which the matrix never runs; Reading and Pre-Read preparation; Stolen Breath and Hollow Guard (approximated by `leech_qi_pct` and the typical ward layers); and the simulator's own `model_note`: enemies are fitted, not exact, at Nguyên Anh, and it does not model soul attacks, companions, triggers, conversion, most curses, guards and conditions, shields beyond the body shield, or escape. Spent Hand is a trigger and is not modelled.

## New Concepts

**Loan slot (Tá Vị).** Rule needed: Combat rule 13 (arts, cooldown timers and slot order), with rule 10 (the instant order, for an enemy cast event) and rule 9 (Spent Hand's trigger budget). Bounds: one copy per foe art id, at most the number of empty slots plus Wide Sleeve; soul, ward and escape arts cannot be copied; copies end with the fight; one tier of fidelity at most 100 %. Breakdown line: "Loan slots 4: 2 hold copies (Rain of Nine Swords at 70 %, Searing Palm at 70 %)". It serves any caster that counters the foe's arts, and any NPC duellist sect. Question for the user: should a loan slot be a real slot type or the compile-time reading of "empty"?

**Enemy art cast readable.** An Effect can read the id and record of an art the foe has just cast. Combat rule 10. Serves any reactive build and the staged Pre-Read. Question: is the foe's art list public in a fight?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Borrowed Hand, loan slot | Needs rule | Combat rule 13 and rule 10: the copy record, the slot reading |
| Stolen tag, fidelity key, copy keys | Needs key | `stolen` in the tag list (Combat rule 6), `copy_fidelity_pct`, `copy_start_share`, `stolen_res_pen_pct`, `loan_slots_bonus` |
| Spent Hand, Hollow Guard, Pre-Read | Needs rule | effects.md rule 8 (when an Effect applies), Combat rules 9 and 10 |
| The other modifiers, items and the cluster | Needs key | see the staging file |
