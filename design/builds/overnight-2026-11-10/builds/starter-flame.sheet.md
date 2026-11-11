# The Hearth Keeper (Thủ Lô Hỏa Giả)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: A new player's first build: simple Fire art caster that is easy to understand, forgiving with linh lực, and grows into something strong by Kết Đan with pieces that are easy to find. Explain every choice.
> **Direction**: B, The Hearth Keeper (a Burn caster that refills itself from its own Burn). Chosen by the designer; see "Directions considered".
> **Realm span**: Luyện Khí (Qi Refining) to Kết Đan (Core Formation) · **Power level**: ordinary · **Use**: player
> **Fit**: 3 Fits today · 9 Needs key · 1 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: the technique's budget was not computed, arts are inside the lint; The fight: the identity piece Embers Feed the Hearth is unmodelled and was run as an approximation)

## Directions considered

Chosen: **B. The Hearth Keeper (Thủ Lô Hỏa Giả)**, a Burn caster whose ticks pay its linh lực back.

- **A. The Bonfire (Đại Hỏa Chưởng)**: stack Fire damage and big direct hits. Not picked: it teaches "more damage", runs dry in two volleys (the first thing that goes wrong), and is the opposite of forgiving.
- **C. The Furnace Master (Đan Lô Sư)**: pills and a formation do the work before the fight (L4 heavy). Not picked: a first build should not depend on alchemy and preparation, which a new player has not unlocked.
- **D. The Last Blaze (Tàn Hỏa Nhất Kích)**: one huge art that burns lifespan or health. Not picked: a trade build punishes mistakes, and a new player has no feel yet for when to pay.

Why B: the loop is one sentence (light them, the fire feeds you), the identity piece fixes the commonest failure (linh lực), the pieces are mostly existing ones, and the player can see the Burn stacks and the refill in a Breakdown.

## The Spine

- **The channel:** Burn ticks (element stacks, uncapped, no floor, skip evade and block) opened by cheap Fire art hits. Ticks use L1 to L4; direct hits also use L5, which Kindled Wound fills.
- **The enabler:** Embers Feed the Hearth. Opens: each Burn tick you deal returns 25 % of its damage as linh lực. Closes: your direct Fire hits deal 15 % less, so the build wants Burn, not a big hit.
- **The loop:** Spark Palm every 2 s keeps Burn stacks on the target, Kindling Seal and Flame Lance add bigger batches, the ticks refill the pool, the pool pays for the next casts.
- **The engine:** the Burn ticks pay for the arts that apply the Burn. The longer the fight, the more it is paid for.
- **The sacrifice:** crit (Burn never crits), reach (no pierce, so a fire-resistant enemy walls it), and a weak first volley.
- **The arc:** Luyện Khí it is three cheap arts and a thin Burn. Trúc Cơ adds the keystone and the pool stops being a worry. Kết Đan adds Flame Lance, the L4 and L5 layers and a spare slot for the player's own fix.

## The Legend

Every village with a kiln has a keeper who never lets the hearth go out. They bank the coals at night, feed them in the morning and know that a fire kept small lasts the winter. The Hearth Keepers took that into cultivation: they do not blaze, they keep a fire going on someone else.

The path comes from the Xích Diễm line of Fire manuals, which were written for sect kitchens and forges before anyone used them to fight. What it does to the person is patience: they cannot rush, because a flame that is rushed goes out. Who wants it gone: water cultivators who wash the fire off, and anyone with a heavy Fire resistance, who stand in the smoke and laugh.

## How It Fights

The cultivator opens with Spark Palm and Kindling Seal, which put Burn stacks on the target. The ticks do most of the damage, and each tick returns a little linh lực, so the pool stays full while the ward holds. Flame Lance lands a bigger batch every 6 s, and Warm the Hearth is cast once for a Fire buff. The fight shows the loop in plain numbers: the Burn count rises, the linh lực bar does not fall.

**Signature moment:** the player watches the linh lực bar sit near full through a 20-second fight while the enemy's own bar and ward fall.

## Enabler

**Embers Feed the Hearth (Tàn Hỏa Dưỡng Lô).** A Meridian Map keystone in the Fire land (a Fire-land notable the player reaches by the second realm), already proposed in the missing-pieces catalogue. An Effect on the tick event with the action "restore linh lực". Needs rule: the Effects action list must allow it (effects.md rule 6).

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Burn batches on the arts | Spark Palm 1 stack 6 s, Kindling Seal 2 for 8 s, Flame Lance 3 for 8 s | Flat base | tick | none | ◐ | arts | any Fire stack build |
| 2 Rate | Art speed (`art_speed_pct`) | +10 % from small tree nodes | Increased | art | none | ◐ | tree | any art build |
| 2 Rate | First Move (Tiên Thủ) | The first art of the fight costs no linh lực | Timing | art | none | ○ | tree keystone | alpha-strike builds |
| 3 Multiplier | Fire damage nodes | +12 % notable, a few of them | Increased | art, tick | L1 | ○ | tree | any Fire build |
| 3 Multiplier | Fire arts "more" | Xích Diễm Địa Quyết layers, L2 40 in the sim | More | art, tick | L2 | ◐ | công pháp | any Fire main |
| 3 Multiplier | Artifact attack | Ember Rod weapon, L3 30 | Increased | art | L3 | ● | artifact | any caster |
| 3 Multiplier | Preparation | Pill and formation, L4 20 | More | art, tick | L4 | ○ | pill, formation | any preparer |
| 3 Multiplier | Kindled Wound (Trì Nhiệt) | Fire parts deal more to a target with your Burn, L5 +15 | Conditional | art | L5 | ● (effects.md Starter Effects) | Effect | any Burn build |
| 4 Crit | (none) | Burn does not crit | sacrifice | | | | | |
| 5 Reach | (none) | no pierce | sacrifice | | | | | |
| 6 Past cap | (none) | ticks have no cap | sacrifice | | | | | |
| 7 Fuel | Embers Feed the Hearth | 25 % of each tick returns as linh lực; direct Fire hits −15 % | Trigger plus Trade | tick | none | ○ | keystone | any Burn or poison build |
| 7 Fuel | Fire art cost | −6 % notable, a few | Increased | art | none | ○ | tree | any one-tag build |
| 7 Fuel | Linh lực regeneration | +1 % notable | Increased | any | none | ● | tree | everyone |
| 8 Survival | Common Ward, ward strength, health | The realm's Common Ward, +ward strength nodes | Increased | defence | W2-W4 | ● | ward, tree | everyone |
| 9 Identity | Embers Feed the Hearth | see above | Trigger | tick | none | ○ | keystone | Burn, poison |

**Identity piece:** Embers Feed the Hearth. It turns the build's damage into its fuel. Without its sim approximation the same loadout wins 4 of 20 instead of 20 of 20.
**Empty rungs:** crit, reach, past the cap, all sacrifices; a first build should have few decisions and these are the ones a newcomer least needs. The L5 layer is filled only by Kindled Wound.

| Layer | Points at Kết Đan | Multiplier | Sources |
|---|---|---|---|
| L1 | 50 | ×1.50 | Fire damage nodes and `attack_pct` |
| L2 | 40 (+15 on each art) | ×1.40 (×1.55 on arts) | Xích Diễm Địa Quyết and the root's affinity |
| L3 | 30 | ×1.30 | Ember Rod |
| L4 | 20 | ×1.20 | Hearth-Warming Pill, Gathering Flame Array |
| L5 | 15 | ×1.15 | Kindled Wound |

M is about 3.8 (4.2 on arts) against the typical 5.48 at Kết Đan. The Burn stacks are tick damage and sit outside the hit-art lint, which is where the rest of the damage comes from. See Scaling.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire, purity about 70 (middling) | Fire tags are cheap and Xích Diễm Địa Quyết names Fire; middling purity is what most players roll |
| Key talents | Comprehension, Willpower (for the heart demon resist) | Comprehension speeds the layers; no Physique needed |
| The Way (Đạo) | Hỏa Đạo, Phần Thiên: the Chân Hỏa (True Flame, Burn) branch | The Way's own Burn branch; it is in the dao.md Catalogue, its nodes are not in game data |

## Công Pháp

### Xích Diễm Địa Quyết (dia_hoa) — main, tier 2

Fire manual from the kitchens and forges. In game data today.

```json
{"id": "dia_hoa", "name": "Xích Diễm Địa Quyết", "tier": 2, "tech_kind": "main", "names": ["hoa"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 12}, {"stat": "tam_ma_resist_pct", "value": 8}],
 "abilities": [], "seal_clusters": [], "origin": "authored"}
```

**Fit:** Fits today · **Budget:** NOT ASSESSED, the pool_max values were not computed. Tier 2 `max_realm` is nguyen_anh, so it reaches Kết Đan.

### Khơi Hỏa Sơ Quyết (Kindling Breath Primer) — main, tier 0 (staged)

For Luyện Khí and Trúc Cơ, before Xích Diễm Địa Quyết. Tier 0 `max_realm` is truc_co. One bonus `linh_luc_regen_pct`. Fits today as a data row; no such Fire tier-0 row was found in the data, so it is staged.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Spark Palm (Hỏa Tinh Chưởng) | Primer or Xích Diễm, layer 1 | qi, fire, palm, burn | 1.3 | 0.02 | 2 s | none | Needs key |
| Kindling Seal (Dẫn Hỏa Ấn) | layer 3 | qi, fire, seal, burn | 2.0 | 0.04 | 4 s | none | Needs key |
| Flame Lance (Liệt Diễm Thương) | layer 6 | qi, fire, burn | 3.2 | 0.06 | 6 s | none | Needs key |
| Warm the Hearth (Noãn Lô Quyết) | layer 9 | qi, fire, buff | 0.5 | 0.02 | 10 s | none | Needs key |

- **Spark Palm. Effect:** hit, 1 Burn stack for 6 s. **Description:** a spark from the hearth, thrown.
- **Kindling Seal. Effect:** hit, 2 Burn stacks for 8 s.
- **Flame Lance. Effect:** hit, 3 Burn stacks for 8 s. **Description:** the poker, white-hot.
- **Warm the Hearth. Effect:** small hit, 3 Fire buff stacks for 15 s (Fire damage). The only art that waits: cast it first, then never again.

Art lint: c_art ≤ 1 + 24 × cost + 0.25 × (cooldown − 1). Spark 1.73, Seal 2.71, Lance 3.69, Warm 1.0+: all under. The loader printed no `lint_over` or `range`.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Luyện Khí | 3 | Spark Palm, Kindling Seal, Warm the Hearth | Common Ward | Embers not yet; keep casting cheap |
| Trúc Cơ | 4 | + Flame Lance | Common Ward | Embers Feed the Hearth arrives |
| Kết Đan | 5 | Warm, Spark, Seal, Lance + one free slot | Common Ward | the free slot is the player's answer to what they meet (see Matchups) |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Xích Lô Trượng (Ember Rod) | artifact, weapon | a staff base, any grade, Kết Đan tier; affixes Fire damage and Fire art cost | L3 and fuel | Needs key (Fire affixes) |
| Noãn Lô Đan (Hearth-Warming Pill) | pill | common | L4 before the fight; raises regen | Needs key |
| Tụ Hỏa Trận (Gathering Flame Array) | formation | beginner tier | L4 and Fire ground tag | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Embers Feed the Hearth | keystone | the engine | Needs rule |
| 2 | Linh lực regeneration | +1 % notable | forgiveness | Fits today |
| 3 | Fire damage | +12 % notable | L1 | Needs key |
| 4 | Fire art cost | −6 % notable | fuel | Needs key |
| 5 | Status duration | +12 % notable | longer Burn | Needs key |
| 6 | Ward strength | +8 % notable | survival | Fits today |
| 7 | First Move | keystone | free opener | Needs key |

### Hidden cluster idea: Kindled Meridians (Hỏa Mạch Thiêu)

Theme: Fire land, element affinity Fire, sealed, seal condition: a Fire technique (Xích Diễm Địa Quyết lists it in `seal_clusters`). Size 5 acupoints: three small Fire damage and Fire art cost points, one notable Status duration, one notable carrying Embers Feed the Hearth at the far end. No capability. An idea for the tree rework, not data.

## Đạo

Hỏa Đạo (Phần Thiên) exists in the dao.md Catalogue; this build takes its Chân Hỏa (True Flame, Burn) branch and nothing new.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Luyện Khí | three cheap casts; slow but safe | Spark Palm, Kindling Seal | the first fire the player keeps lit |
| Trúc Cơ | the pool stops mattering | Embers Feed the Hearth, Flame Lance | learning that the fire feeds back |
| Kết Đan | all five layers, a free slot | Ember Rod, pill, array, Kindled Wound | the keeper starts to choose where to burn |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical, same realm | wins (sim 20-0, 21.8 s) | Burn stacks and the refill outlast it |
| Fire-resistant enemy (150+ points against Fire, Combat rule 18) | loses or stalls | every tick is cut by 60 %, and the ticks fuel the build |
| Healer | even | heals undo Burn damage; the build has no burst |
| Cleanser | loses stacks | cleansing removes stacks, and with them the refill |
| Drainer (Qi Disruption) | even | Burn returns what it takes, the ward is the target |
| One realm above | loses (sim 0-20) | ordinary, as for any typical build |
| Top-end | loses | one volley (sim 1.6 s) |

**Counter:** a Fire-resistant or Water body enemy, and a cleanser. Adapt with the free slot: a Water or Metal art for the resistant, a Sword or Seal hit that is not Fire for the wall; refill the stacks fast for the cleanser.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts inside the lint (no `lint_over`); slots 4 of 5; one artifact. The technique's budget was not computed |
| Validity | PASS | fire element, ket_dan realm, dia_hoa tier 2 reaches Kết Đan, no aux technique to check harmony |
| Stack | PASS | six forms (Increased, More, Conditional, Trigger, Trade, Timing); identity piece present; all layers filled; the identity test changed the fight (wins 20 → 4) |
| Scaling | PASS | M about 3.8 against typical 5.48, but the build wins 20-0 from Burn ticks, which sit outside M. INFO: its direct damage is below typical |
| The fight | NOT ASSESSED | Embers (the engine) is unmodelled and was run as `regen_bonus_pp` 3 and `gain_on_hit_pct` 0.6; Kindled Wound is a guard and was run always on |
| Reuse | PASS | six pieces reused, no signature modifier |
| NPC use | PASS | every modifier is a key or a tag, no input; an NPC Burn caster can carry the same stack |
| Counterplay | PASS | Fire-resistant enemy, cleanser |
| Originality | PASS | names are generic Fire words; no novel or game names |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/starter-flame.fight.json`. Observations from `fight.py`, 20 fixed seeds, not the game.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical | 0 | 20 / 0 / 0 | 21.8 s | never | none | none |
| typical | +1 realm | 0 / 20 / 0 | 7.4 s | 5.6 s | Warm the Hearth | none |
| typical | +2 realms | 0 / 20 / 0 | 3.5 s | 2.7 s | Flame Lance, Warm the Hearth | none |
| top_end | 0 | 0 / 20 / 0 | 1.6 s | 1.0 s | Kindling Seal, Flame Lance, Warm the Hearth | none |
| top_end | +1, +2 | 0 / 20 / 0 | 1.0 s | 1.0 s | all | none |

The same-realm fight (21.8 s) is under the 30 to 60 s band. A slightly strong starter is accepted. Health left 55 %.

**Identity test** (`--without regen_bonus_pp`, the approximation of Embers; the Embers id itself is not a key the file can remove, and `gain_on_hit_pct` alone showed NO_CHANGE): typical+0 changed (mean 21.8 to 26.6 s, wins 20 to 4, the build runs dry at 15.8 s), typical+1 changed (7.4 to 6.9 s), the rest NO_CHANGE.

**Unmodelled:** Embers Feed the Hearth's real tick trigger and its −15 % direct Fire closing cost; Kindled Wound's condition; First Move and Fire art cost (folded into `art_cost_pct` 15); the technique's bonuses and root purity beyond `purity.fire`. Simulator `model_note`: soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield and escape are not modelled.

## New Concepts

None.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Embers Feed the Hearth | Needs rule | an Effect action "restore linh lực" on the tick event (effects.md rule 6, action list) |
| Fire damage, Fire art cost, Status duration, First Move | Needs key | tagged keys, as in the tree catalogue |
| Spark Palm, Kindling Seal, Flame Lance, Warm the Hearth | Needs key | art records |
| Khơi Hỏa Sơ Quyết | Fits today | one data row |
| Xích Lô Trượng, Noãn Lô Đan, Tụ Hỏa Trận | Needs key | a Fire weapon affix, a pill, a formation |
| Kindled Meridians | cluster idea | for the tree rework |
