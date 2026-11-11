# Raising the Tiger (Dưỡng Hổ)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses.
> **Seed**: "The companion is the main damage: power share up to c_comp_cap, the cultivator's arts exist only to buff, heal or protect the beast. The PoE minion player's build in a one-companion game."
> **Direction**: Raising the Tiger: the beast does all the killing, the keeper feeds it fire, heals it and stands behind it; the bond makes the beast mortal, so protecting it is the game.
> **Realm span**: Trúc Cơ (Foundation) – Hóa Thần (Deity Transformation) · **Power level**: top-end · **Use**: player
> **Fit**: 5 Fits today · 9 Needs key · 10 Needs rule (pieces this build adds or stages; reused pieces keep their own labels)
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (The fight, and the identity test inside Stack: no simulator this run, user decision 2026-11-11). Budgets passes with its thần thức part not assessed (no reference thần thức per realm, Combat Defence & Healing Open Question 12).

## Directions considered

The seed is specific, so three readings were weighed and the strongest for a min-max build was chosen (run override 1).

**Chosen: Raising the Tiger (Dưỡng Hổ).** The companion channel made the whole damage: the keeper's basic attack is lent to the beast, art speed flows into the beast's timers, the keeper's arts pour Fire buff stacks into the side and heal and shield the beast, and the bond brings the beast into the open with its own health bar. It is the only reading where "heal or protect the beast" means something under the rules, and it turns the build's weakness (kill the beast and the keeper is harmless) into the thing a player plays around.

**Not picked: The Ridden Beast (Kỵ Hồn).** The keeper's soul rides inside the beast and every art is fired through it, carrying the [companion] tag.
It reads as a minion build but plays as an art caster with a beast skin: the arts deal the damage, which breaks the seed.

**Not picked: The Hundred-Bite Pack (Bách Phệ).** The beast bites as often as the rules allow and each bite lays Poison; the keeper's arts lengthen and deepen the stacks.
The damage then lives in the Poison clock, not in the beast, so it repeats the Two Clocks build of this run with a different applier.

## The Spine

- **The channel:** companion hit (Combat rule 19, Formulas J). `c_comp = min(c_comp_cap 1.0, share / (B_p · stage))`, one strike per `basic_cooldown` (1 s), no linh lực, no crit, full layers M(companion tags), meets evade, wards and block. So the levers are: reach the cap, then **more strikes** (two timers, each floored at `cooldown_min` 0.5 s), **every layer** L1–L5 on [companion], and **a factor outside M** (Fire buff stacks on the side).
- **The enabler:** the **Shared-Heart Contract (Đồng Tâm Khế)**. Opens: your basic attack becomes a second companion strike (Lent Hand), and your companion fights **in the open**, with a health bar of half yours that takes 30 % of the damage reaching you, and that your heals and shields can reach. Closes: you may slot no art or talisman that hits, ticks or curses the enemy. Every point of the side's damage is the beast's.
- **The loop:** the tiger strikes every 0.5 s on two timers and its bite lays Poison; the keeper pours spare linh lực into Feed the Fire (Fire buff stacks), keeps Roused up with Whistle In, and spends the rest of the pool on wards, heals and Bark Mantle for whichever of the two is hurt.
- **The engine:** the keeper's whole economy becomes the beast's damage. Art speed (useless to buff arts) drives the beast's timers through Bonded Spirit; spare linh lực regeneration becomes Fire stacks (every 1 % of maximum linh lực a second spent on Feed the Fire holds 30 Fire stacks, +36 % damage dealt before purity); the beast's surplus power share past the cap becomes L5 through **Straining Leash**. Nothing the keeper owns is wasted.
- **The sacrifice:** the keeper has no hand of its own. If the tiger is Down, the side deals nothing until it rises, and the 30 % it was taking for the keeper lands on the keeper. The build refuses to fix this with a damaging art: it answers with Bark Mantle, heals and Rouse.
- **The arc:** a Trúc Cơ herb-warden with a tiger cub who still fights beside it, to a Kết Đan keeper who signs the Contract and puts down its own hands, to a Nguyên Anh master whose tiger strikes four times a second, to a Hóa Thần elder walking behind a beast the sects rank above most of their elders.

## The Legend

On the Cedar-Ridge (Bách Sam Lĩnh) the forest wardens never learned to kill. They grew herbs, kept the paths and raised what the hunters left orphaned. The Contract was written by a warden who found a tigress with a spear in her side and no strength left to heal her. She opened her own chest and gave the animal half the beat of her heart. The tigress lived. From that day the warden's hands would not close into a fist, and every blow she meant to strike was struck by the tiger instead.

The wardens copied her scripture as a way to keep a beast alive, not as a fighting art. It was a sect war that taught them otherwise: a warden with a full-grown tiger held a pass against three Kết Đan elders, doing nothing but singing fire into her beast and binding its wounds. She died anyway, a year later, the day the tiger fell to a poisoned spear. She could not lift a hand to save herself.

Tiger-bone traders hunt the keepers for their beasts, and the sects that farm beasts for pills call the Contract theft. Lone cultivators of Cô Đạo spit at it: a cultivator who cannot strike is no cultivator. The keepers answer that they have never needed to.

## How It Fights

The keeper never strikes. At 0.5 s the tiger lands its first bite and every 0.5 s after, on two timers (its own and the keeper's lent hand). Each bite is Physical with a quarter turned to Chaos by Rot Seeps In, and lays a Poison stack, which wakes Pack Hunt. Feed the Fire fires whenever the keeper's linh lực is at 40 % or more, so the pool hovers near 40 % and every point of regeneration above it becomes Fire stacks; Whistle In keeps the tiger Roused; Old-Tree Sap heals whichever of the two is lower; Bark Mantle lays bark over the tiger whenever its shield is gone. If the tiger goes Down, Rouse stands it up at 40 % in the same instant its guard opens.

**Signature moment:** the enemy's big art crashes into the keeper's ward, 30 % of what gets through tears into the tiger instead, the bark splits, the tiger bleeds down to a sliver, and the keeper, who has not raised a hand all fight, sings it whole again while it keeps biting four times a second.

## Enabler

**Shared-Heart Contract (Đồng Tâm Khế)**, Effect tier `enabler`.

- **Where:** the main technique's divine ability (Shared-Heart Tiger-Rearing Scripture, Địa giai layer 9, Thiên giai layer 12), and as the capstone of Thú Đạo (its capstone idea is "One heart in many bodies"). One host is enough.
- **Opens:**
  1. **Lent Hand (Tá Thủ).** Your basic attack becomes a second companion strike: on its timer your companion strikes instead, with its own tags, `c_comp` and the companion's modifiers. Your own basic attack no longer exists. (Redirect.)
  2. **Beast in the open (Thú Hiện Thân).** Your companion has a health bar of `beast_health_share` 0.50 × your maximum health (× `companion_health_pct`), and **30 % of the damage that reaches your health from hits** lands on it instead (after your whole defence path; ticks, soul hits and fatigue are not shared). Your heals, health restores and body-shield casts may target it (Rain on Both). At 0 it is **Down**: no strikes, no sharing, until it rises by itself after 8 s at 25 % of its bar, or a Rouse stands it up.
- **Closes:** you may slot no art or talisman that deals a hit, applies a tick or lays a curse on the enemy (enforce a closing rule at compile: forbid a slot kind). Buff, heal, shield, cleanse, escape and command arts stay legal. While your companion is Down your side deals no damage at all.
- **Fit:** Needs rule (combat.md rule 19 "cannot be targeted", Formulas J; combat-defence.md rule 16, heal and shield targets; effects.md rule 6, a new action "redirect the basic attack to the companion"). Staged as `shared-heart-contract` and the concept `beast-in-the-open`.

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses. Channel is companion hit unless stated.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Companion power share | +pp to `c_comp` (+1 pp = +0.01), up to `c_comp_cap` | Flat base | companion | none | ◐ (Modifier System, Pending) | Tree, Thú Đạo Linh Khế lines, Beast-Bond affix | Salamander Keeper, Living Sword (by-root) |
| 1 Base | Beast Soul Union (Thú Hồn Hợp Thể) | Strongest companion's share ×2; −1 art slot | Trade | companion | none | ● (Effects keystone, capability #17) | Meridian Map keystone | any companion build |
| 1 Base | Element-tagged companion (Moss-Fang Bite) | The tiger's bite carries [moc] and lays 1 Poison stack for 6 s | Rule swap | companion, tick | none | ○ (by-root missing-pieces) | Creature record | Salamander Keeper, Living Sword, Artisan General |
| 2 Rate | Lent Hand (Tá Thủ), in the Contract | Your basic attack timer becomes a second companion strike | Redirect | companion | none | ○ | Enabler | Guide Hound-type keepers who cast nothing |
| 2 Rate | Bonded Spirit (Linh Khế) | Your companion's timers carry your art speed, stopping at `cooldown_min` | Redirect | companion | none | ○ (tree catalogue keystone) | Thú Đạo Linh Khế notable | any beast keeper with art speed |
| 2 Rate | Companion attack speed (`companion_speed_pct`) | +X % to the companion's timers only, adds to Bonded Spirit's sum | Increased (timing) | companion | none | ○ (tree catalogue row) | Tree, Shepherd's Path cluster, Tiger-Tally Seal | Herd builds, Salamander Keeper |
| 2 Rate | Art speed (`art_speed_pct`) | Feeds both the beast (through Bonded Spirit) and the buff arts | Increased | companion, buff arts | none | ◐ | Tree, Đạo lines | every caster |
| 3 L1 | Damage (`attack_pct`), and `attack_pct` [companion] | Increased damage; the technique's `attack_pct` 15 | Increased | companion | L1 | ● / ◐ | Technique bonuses, tree, Thú Đạo lines | any companion build |
| 3 L2 | Fang and Claw (Nha Trảo) | `damage_more` +40 [companion] (technique passive +60 Địa, +80 Thiên) | More | companion | L2 | ○ | Technique passive, Thú Đạo and Mộc Đạo Rừng notables | every companion build |
| 3 L3 | Artifact attack (`artifact_attack_pct`, weapon role) | The keeper's weapons feed L3 for the beast's hits | Increased | any hit | L3 | ● | Tiger-Tally Seal, generated `an` seals | every build |
| 3 L4 | Blood-Meal Pill (Huyết Thực Đan) | L4 `damage_more` +70 [companion] for one fight (fed to the beast) | More | companion | L4 | ○ | Pill | any companion build |
| 3 L4 | Full Trough (Mãn Tào) | +20 per doubling of the year's feed above what is due, to +40; blind fights keep it | Per | companion | L4 | ○ (reused, 2026-11-07 ledger) | Thú Đạo Linh Khế line | Guide Hound, Herd-Child (2026-11-07) |
| 3 L5 | Pack Hunt (Quần Liệp) | L5 +15 [companion] while the target bears any of your statuses | Conditional | companion | L5 | ● (Effects starter) | Thú Đạo Bầy minor | poison, curse builds |
| 3 L5 | Marked Prey (Tiêu Ký) | L5 +4 per distinct status of yours on the target, cap +16 | Per | any hit | L5 | ● (Effects starter) | Thú Đạo Bầy minor | curse-engine, poison |
| 3 L5 | Roused (Hưng Phấn), from Whistle In | L5 +20 [companion] for 3 s | Conditional | companion | L5 | ○ | Art (Whistle In) | herd builds with song arts |
| 4 Certainty | Sure Bite (Ngoạm Chắc) | Your companion's hits are never evaded (the evade roll is skipped) | Rule swap | companion | none | ○ | Shepherd's Path cluster (far notable), Tiger-Tally Seal | any companion build vs evaders |
| 4 Certainty | Fire buff stacks (Feed the Fire, Hearth Song) | +1.2 % damage dealt per stack × (1 + 0.002 × Fire purity); every 1 % of max linh lực a second spent on Feed holds 30 stacks | Per | all the side's hits | outside M (assumed; see suggestion) | ● (Effects rule 9a) | Arts | any Fire caster |
| 5 Reach | Rot Seeps In (`convert_pct` 25 % Physical → Chaos, [moc]) | A quarter of each bite passes body shields | Conversion | companion | rule 6 | ◐ (Effects note, catalogue grade) | Mộc Đạo Rừng notable | Wood poison builds |
| 5 Reach | Realm pierce (`pierce_pct`) | For the tiger's climb a realm up | Increased | any hit | none | ● | Tree | every build |
| 6 Past the cap | **Straining Leash (Căng Xích)** | Your companion's hits deal more for every 0.1 of uncapped `c_comp` above `c_comp_cap`: L5 +5 each, cap +50 | Overflow | companion | L5 | ○ | Technique passive (layer 11), Thú Đạo Linh Khế `major` | Salamander Keeper, Living Sword, any keeper of a beast stronger than itself |
| 7 Fuel | Art cost (`art_cost_pct`) and regeneration (`linh_luc_regen_pct`) | Every point saved or regained is more Fire stacks | Increased | buff arts | none | ● | Tree, technique, Water-free lines | every caster |
| 7 Fuel | Fire stack strength (`stack_effect_pct` [hoa, buff], `stack_grant` [hoa]) | ×(1 + X/100) on Fire buff; +1 stack a grant | Increased / Flat | Fire buff | none | ◐ (Modifier System) | Tree, Hỏa lines | any Fire buffer |
| 8 Survival | Beast in the open (Contract) + Rain on Both | 30 % of damage to you lands on the beast; your heals heal both | Rule swap | defence | none | ○ | Enabler; technique | Turtle and Snake (by-root), Guardian companion |
| 8 Survival | Thick Hide (Hậu Bì), `companion_health_pct` | +X % to the beast's health bar (small +3 %, notable +20 %) | Increased | defence | none | ○ | Thú Đạo Thú Thể lines, cluster | any beast in the open |
| 9 Identity | **Straining Leash** (above) | The beast you tamed above your station pays off past the cap | Overflow | companion | L5 | ○ | | |

**Identity piece:** **Straining Leash (Căng Xích).** Every companion build hits `c_comp_cap` early, because a beast of one's own realm already gives 0.5 and any stronger beast gives far more; the surplus is wasted by today's rules. Straining Leash spends it: a tiger tamed above your station (or doubled by Beast Soul Union) turns its clipped share into L5, up to +50, half of L5's cap. It is the reason a keeper hunts a beast stronger than itself, and the reason Beast Soul Union stops being worth an art slot once the beast is twice the cap.

**Empty rungs:** none fully empty. L4 is short in blind fights (Full Trough +40 alone, ×1.40, against the anchor's ×2.50): a sacrifice of the companion channel, which has no formation of its own. Crit is empty by rule (companions cannot crit); certainty (Sure Bite) and the Fire buff fill rung 4 instead.

| Layer | Points at Nguyên Anh, top-end, foreseen fight | Multiplier | Sources |
|---|---|---|---|
| L1 | ~266 effective (about 333 raw, soft cap at 200) | ×3.66 | Tree W at the top-end attack share (Formulas B), technique `attack_pct` 15, `attack_pct` [companion] lines |
| L2 | 300 (cap) | ×4.00 | Fang and Claw: technique passive +60, Thú Đạo notables +40 × 3, Mộc Đạo Rừng +40 × 2 (360, clipped to 300) |
| L3 | ~250 | ×3.50 | Tiger-Tally Seal and two generated weapon seals (`an`), as any top-end build carries |
| L4 | 110 (blind: 40) | ×2.10 (blind ×1.40) | Blood-Meal Pill +70, Full Trough +40 |
| L5 | 89 | ×1.89 | Straining Leash +50, Roused +20, Pack Hunt +15, Marked Prey +4 |
| **M** | | **≈ 203 foreseen (≈ 136 blind)** | Top-end anchor at Nguyên Anh: 256 (Formulas B) |
| Outside M | ~100–150 Fire stacks | ×2.4 to ×3.1 | Feed the Fire and Hearth Song at Fire purity 80 (×1.16 per stack) |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Dual **Wood (Mộc) and Fire (Hỏa)**; Fire purity 80 or more, Wood 60 or more | Fire purity powers every Fire buff stack the keeper holds (×(1 + 0.002 × P), Effects rule 9a). Wood is the tiger's element and the Way of the Forest; Wood generates Fire, so the main technique is in harmony |
| Key talents | **Soul strength (thần hồn)** high, **Physique (căn cốt)** good, Comprehension fair | Thần hồn sets the tame chance and how many beasts can be kept (Spirit Beasts quick spec), and taming a beast above your realm is the build's chase. Physique raises your health, and the beast's bar is half of it |
| Craft | **Beast Taming (Ngự thú)** levels | +0.05 tame chance per level, and growth per level (`growth_per_skill_level` 0.1) |
| The Way (Đạo) | **Thú Đạo** (#73), facets **Linh Khế** (Spirit Bond), **Bầy** (the Pack), **Thú Thể** (Beast Body); capstone the Shared-Heart Contract. Second Way: **Mộc Đạo** (#16) facet **Rừng** (the Forest: ground, companions) | The Way the catalogue already names for companion share; the Forest facet is Wood's companion facet |

## Công Pháp

### Shared-Heart Tiger-Rearing Scripture (Đồng Tâm Dưỡng Hổ Kinh) — main, Địa giai (tier 2, to Nguyên Anh); Thiên giai copy Đồng Tâm Dưỡng Hổ Thiên Kinh (tier 3, to Hóa Thần)

"Feed it from your own fire. Bind its wounds before your own. When it bites, that is your hand."

```json
{"id": "dong_tam_duong_ho", "name": "Đồng Tâm Dưỡng Hổ Kinh", "tier": 2, "tech_kind": "main",
 "names": ["moc", "hoa"], "layers": 12,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 20},
             {"stat": "attack_pct", "value": 15}],
 "abilities": [{"ability_id": "whistle_in", "unlock_layer": 1},
               {"ability_id": "feed_the_fire", "unlock_layer": 3},
               {"ability_id": "bark_mantle", "unlock_layer": 5},
               {"ability_id": "old_tree_sap", "unlock_layer": 7},
               {"ability_id": "shared_heart_contract", "unlock_layer": 9},
               {"ability_id": "rouse", "unlock_layer": 10},
               {"ability_id": "hearth_song", "unlock_layer": 12}],
 "passives_proposed": [{"layer": 2, "id": "fang_and_claw", "damage_more_l2": 60, "scope": ["companion"]},
                       {"layer": 7, "id": "rain_on_both"},
                       {"layer": 11, "id": "straining_leash"}],
 "seal_clusters": ["shepherds_path"], "origin": "authored"}
```

Thiên giai copy: 15 layers; bonuses `khi_huyet_pct` 15, `linh_luc_pct` 20, `attack_pct` 15, `defense_pct` 15; Fang and Claw +80; the Contract moves to layer 12, Hearth Song to layer 14, and layer 15 adds the **Old Cedar Song (Lão Sam Ca)** passive: Roused also gives +15 % `companion_speed_pct` while it lasts.

**Fit:** Needs key (abilities, passives and art records have no field in `items_cong_phap.json` yet) · **Budget:** Địa: 15/15 + 20/20 + 15/15 = 3.0 of 3, each 1.0 ≤ 1.5. Thiên: + 15/15 = 4.0 of 4. **Max realm:** Địa `nguyen_anh`, Thiên `hoa_than`: the span is reached with the Thiên copy.

No auxiliary technique is required. A body technique (luyện thể) for health is the natural second slot, since the beast's bar is half the keeper's health.

## Arts

The keeper's arts. None of them hits, ticks or curses the enemy (the Contract forbids it). The tiger's bite is the companion's fixed art.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Whistle In (Hô Hổ) | Scripture L1 | command; moc, song, companion, art | — | 0.02 | 2 s | none | Needs rule |
| Feed the Fire (Đầu Hỏa) | Scripture L3 | buff; hoa, buff, art, cheap | — | 0.02 | 1 s | own linh lực at or above 40 % | Fits today |
| Bark Mantle (Bì Giáp) | Scripture L5 | shield; moc, shield, companion, art | — | 0.05 | 4 s | own companion's shield empty | Needs rule |
| Old-Tree Sap (Lão Mộc Dịch) | Scripture L7 | heal; moc, heal, art | c_heal 3.78 | 0.05 | 3 s | the lower of your and your companion's health shares at or below 80 % | Needs rule |
| Rouse (Hoán Tỉnh) | Scripture L10 | heal; moc, heal, companion, art | — | 0.06 | 6 s | own companion Down | Needs rule |
| Hearth Song (Lô Ca) | Scripture L12 (Địa) / L14 (Thiên) | buff; hoa, buff, song, art | — | 0.03 | 2 s | own linh lực at or above 40 % | Fits today |
| Moss-Fang Bite (Đài Nha Phệ) | The tiger's fixed art | companion hit; beast, companion, moc, physical, hit | c_comp | — | `basic_cooldown` | — | Needs key |

- **Whistle In.** **Effect:** your companion's two timers are each shortened by 0.5 s (never sooner than `cooldown_min` after its last strike), and it is Roused: its hits deal L5 +20 for 3 s. Once art speed floors the timers, only Roused still does anything. **Description:** two notes through the fingers, the sound the wardens use to call a tiger off the ridge.
- **Feed the Fire.** **Effect:** grants you 12 Fire buff stacks for 5 s (60 stack-seconds: charge 0.010 × 60 = 0.6, the cap; the art has no hit, so the charge costs it nothing it had). **Description:** the keeper breathes into its cupped hands and the tiger's stripes smoulder.
- **Bark Mantle.** **Effect:** your companion gains a body shield of 0.19 × your maximum linh lực (σ ≤ `shield_per_cost` 3.81 × κ 0.05), not scaled by ward strength; it does not recharge. **Description:** moss and cedar bark grow over the beast's flanks and split when struck.
- **Old-Tree Sap.** **Effect:** heals U × 3.78 × 4 (1,512 at Nguyên Anh before `healing_pct`) to whichever of you and your companion has the lower health share; with Rain on Both it heals both. Refunds its cost when it restores health (combat-defence.md rule 16). Heal lint at cost 0.05, cooldown 3 s: 1.4 × (1 + 24 × 0.05 + 0.25 × 2) = 3.78. **Description:** amber sap from a cut in the keeper's own palm.
- **Rouse.** **Effect:** your Down companion rises at once at 40 % of its bar. **Description:** the keeper presses its forehead to the beast's and gives it a beat of its own heart.
- **Hearth Song.** **Effect:** grants you 6 Fire buff stacks for 10 s (60 stack-seconds, charge 0.6). Longer batches than Feed the Fire, so the fire holds through a Silence or a drained pool. **Description:** a low herding song that keeps a fire banked overnight.
- **Moss-Fang Bite.** **Effect:** a Physical companion hit at `c_comp`, carrying [moc]; lays 1 Poison stack for 6 s on the target (Effects rule 9a, beast stack purity 0). Its charge (0.015 × 6 = 0.09) costs the bite 9 % of its coefficient under the art lint's rule; the sheet assumes companion fixed arts pay charges the same way. **Description:** green-black fangs that leave the wound smelling of wet earth.

**Charges on buff arts.** Run override: the staging suggestion "Bound an art's stack grant at the charge cap" (two-clocks) is respected: each buff art grants exactly 60 buff stack-seconds per firing, the most that suggestion allows.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Trúc Cơ | 4 | Feed the Fire, Whistle In, Old-Tree Sap, (free: a ward) | Common Ward | No Contract yet: the keeper's basic attack still lands as its own, the cub hits at about c_comp 0.5 |
| Kết Đan | 5 | Feed the Fire, Whistle In, Bark Mantle, Old-Tree Sap, Rouse | Common Ward | Contract at layer 9: Lent Hand doubles the strikes, the tiger is in the open |
| Nguyên Anh | 6 (5 with Beast Soul Union) | Feed the Fire, Hearth Song, Whistle In, Bark Mantle, Old-Tree Sap, Rouse | Common Ward, Mountain Screen, a third ward slot | Art speed +100 floors both beast timers (4 strikes a second). Drop Whistle In first if Beast Soul Union takes a slot |
| Hóa Thần | 7 | as Nguyên Anh, plus a cleanse art (Clear Heart Ward in a ward slot, or a cleanse art against curse builds) | four ward slots | The Thiên copy; Old Cedar Song; the tiger a realm above its keeper |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Tiger-Tally Seal (Hổ Phù Ấn) | Named artifact, weapon role | `an` (attack 40, defence 5, thần thức 30), Cực phẩm, Nguyên Anh or Hóa Thần tier | Authored lines: companion power share +15 pp, `companion_speed_pct` +20, `attack_pct` [companion] +20; carries Sure Bite. Its attack feeds L3 for every bite | Needs key |
| Beast-Bond affix (Thú Khế) | Affix row on any artifact | `affixes` table, weight 6 | Companion power share +5 to +15 pp: what a generated item rolls for a keeper | Needs key |
| Two generated weapon seals | Artifact, weapon role | `an` or `phien`, Cực phẩm | L3 for the tiger (the keeper never swings them) | Fits today |
| Ward gear | Artifact, ward role | `chuong`, `thuan` | Ward strength: the pool is the keeper's whole defence | Fits today |
| Blood-Meal Pill (Huyết Thực Đan) | Pill, preparation (foreseen and ambush) | Alchemy | Fed to the beast: L4 `damage_more` +70 [companion] for one fight; toxicity as its recipe sets, paid by the keeper (the beast eats from its keeper's hand) | Needs key |
| Full Trough (Mãn Tào) | Feeding, life (reused) | Spirit stones | Feed twice what is due all year: L4 +20 per doubling, to +40, kept in blind fights | Needs key |

**Tiger-Tally Seal, history.** A bronze tally cast in two halves, one for the keeper's belt and one hung at the tiger's throat, so that a beast and its keeper always know where the other is. The wardens made it after the first keeper died alone.

## Companion

**Moss-Striped Tiger (Đài Văn Hổ)**, a Wood spirit beast (linh thú) of the Cedar-Ridge, whose stripes are living moss. Element-tagged companion (by-root missing-pieces): its hits carry [moc] and lay Poison. Fixed art: Moss-Fang Bite. Tame it young at Trúc Cơ, or, better, tame a grown one a realm above you with high thần hồn and Beast Taming: that is the share that Straining Leash pays for. Feed it every year (`feed_lt_by_realm` 5 / 40 / 300 / 2,000 / 15,000 spirit stones), and twice that for Full Trough. **Fit:** Needs key (a creature species record and its element field).

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Bonded Spirit (keystone) | art speed → companion timers | Turns the keeper's art speed into strikes | Needs rule |
| 2 | Art speed notables until +100 % total | +13.3 % per notable | Floors both timers at 0.5 s; past +100 % only the buff arts gain | Fits today |
| 3 | Beast Soul Union (keystone) | share × 2, −1 art slot | Only until uncapped `c_comp` reaches 2.0 | Fits today (designed) |
| 4 | `attack_pct` [companion], `attack_pct` | +12 % notable | L1, to the soft cap at 200 | Fits today (designed) |
| 5 | Linh lực regeneration, art cost | +1 % / −3 % notables | Fire stacks | Fits today |
| 6 | Companion power share | +20 pp notable | Only while `c_comp` is below the cap | Needs key |
| 7 | Health, Thick Hide | +6.5 % / +20 % | The beast's bar | Needs key (Thick Hide) |
| 8 | Shepherd's Path cluster | sealed | Below | Needs key |

### Hidden cluster idea: Shepherd's Path (Mục Lộ)

Theme: keeping animals, the herder's craft (Spirit Beasts), wider than this build: any keeper, herder or beast-rider. Element affinity Wood. Kind: sealed, plannable. Seal: the Shared-Heart Tiger-Rearing Scripture lists it in `seal_clusters`. Size 8: smalls companion power share +3 pp (×2), `companion_speed_pct` +1.5 % (×2), `attack_pct` [companion] +2 %, `companion_health_pct` +3 %; notables `companion_speed_pct` +10 % and, farthest, Sure Bite. No capability. An idea for the tree rework, not data.

## Đạo

The build uses **Thú Đạo** (#73) and **Mộc Đạo** (#16) from dao.md § Catalogue; this session did not read `design/dao-ways/` (run override 3), so these are wants for the graphs, staged as Đạo pieces.

- **Thú Đạo, Linh Khế (Spirit Bond).** Stat lines: companion power share, `attack_pct` [companion]; notables Fang and Claw +40 [companion] L2 (×3), Bonded Spirit; `major` Straining Leash; Full Trough as a line. Capstone: the Shared-Heart Contract.
- **Thú Đạo, Bầy (the Pack).** `companion_speed_pct` lines; Pack Hunt and Marked Prey as `minor`s (both list Way hosts).
- **Thú Đạo, Thú Thể (Beast Body).** `companion_health_pct` (Thick Hide) lines.
- **Mộc Đạo, Rừng (the Forest).** `convert_pct` 25 % Physical → Chaos [moc] (Rot Seeps In's catalogue grade), Fang and Claw +40 [companion] (×2).

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Trúc Cơ | A healer with a cub: the keeper still strikes, the cub bites at c 0.5 | Scripture L1–L7, Feed the Fire, Whistle In, Old-Tree Sap; first tame | The cub follows the keeper home from a hunter's trap |
| Kết Đan | The beast is the fighter; the keeper only sings, heals and shields | The Contract (L9): Lent Hand, the beast in the open; Rouse; Thú Đạo; Blood-Meal Pill | The keeper's hands stop closing. A sparring partner laughs and stops laughing |
| Nguyên Anh | Four bites a second, Fire stacks in the hundreds, L5 near its cap | Bonded Spirit and art speed +100 %, Straining Leash, Beast Soul Union if needed, Tiger-Tally Seal | The keeper trades its first tiger's grave for a grown tigress a realm above it |
| Hóa Thần | The same loop at Thiên giai; the tiger outranks most elders | Thiên copy, Old Cedar Song, Hearth Song, a cleanse | Tiger-bone traders come in numbers. The keeper never lifts a hand, and does not need to |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Drainer (Qi Disruption, soul art) | wins | The beast's damage costs nothing: a dry keeper loses its ward and Fire stacks, not its damage |
| Alpha-strike art caster | wins | Full pool as ward, 30 % of what lands goes to a second bar, heals refund; the caster runs dry first |
| High evade | wins with Sure Bite, even without | Sure Bite skips the evade roll for every bite |
| Poison or Burn ticker | even | Ticks on the keeper skip the beast's sharing, so the keeper's bar takes all of it; the bite's own Poison wakes Pack Hunt anyway |
| Soul lance | even | Soul hits skip the beast; the keeper needs a soul ward in a ward slot |
| Curse kit with Silence or Sealed Meridian on L2 | loses without a cleanse | A Silence naming [buff] or [hoa] stops the Fire stacks; Hearth Song's 10 s batches hold through one. Carry a cleanse at Hóa Thần |
| High Physical resistance healer (rule 18) | loses | The bite is three-quarters Physical; a ≥ 150-point Physical wall with a heal outlasts it. Only Rot Seeps In's quarter of Chaos gets through cleanly |
| Beast-breaker (slow, huge hits) | even to loses | One big hit puts 30 % of a large number into the beast's half-size bar; if Bark Mantle is down and Rouse is on cooldown, the side deals nothing for up to 8 s |

**Counter:** a Physical-resistant enemy that heals (Combat rule 18 requires one per realm tier) beats the bite on damage; a slow heavy hitter beats it on tempo by knocking the tiger Down twice inside Rouse's 6 s cooldown. Both are real, ordinary enemy types.

## Checks

Each result is PASS, FAIL or NOT ASSESSED, with the reason.

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS (thần thức part NOT ASSESSED) | Technique Địa 3.0 of 3, Thiên 4.0 of 4, each line 1.0 ≤ 1.5. Heal lint: c_heal 3.78 at cost 0.05 / 3 s = 1.4 × 2.70. Bark Mantle σ 0.19 ≤ 3.81 × 0.05. Buff arts at charge 0.6 (60 stack-seconds), inside the cap and the two-clocks bound. Slots: Nguyên Anh 6 of 6 (5 of 5 with Beast Soul Union). Artifacts: 5 of `equip.max_slots` 6. Thần thức per realm: not assessed, no reference table (Combat Defence & Healing Open Question 12; staged `soul-reference-table`) |
| Validity | PASS | Elements `moc`, `hoa` exist; tiers `dia` (max `nguyen_anh`) and `thien` (max `hoa_than`) reach the span; base `an` exists; no auxiliary technique, so no harmony check is needed; Wood generates Fire inside the main technique |
| Stack | PASS (identity test NOT ASSESSED) | All 9 rungs filled; 11 forms (Flat base, Trade, Rule swap, Redirect, Increased, More, Per, Conditional, Conversion, Overflow, Timing). No L5 on ticks (the Poison is a switch for Pack Hunt, not damage). Layers: L1 ×3.66, L2 ×4.00, L3 ×3.50, L4 ×2.10 (blind ×1.40), L5 ×1.89. Identity test: no simulator this run (user decision 2026-11-11); read from the rules, Straining Leash is L5 +50 when the beast's uncapped `c_comp` is 2.0, so removing it moves L5 from ×1.89 to ×1.39, about −26 % to every bite |
| Scaling | PASS, INFO | M ≈ 203 foreseen against the top-end anchor's 256 (−21 %, all in L4 and L5), ≈ 136 blind. Two factors sit outside M: the Fire buff (×2.4 to ×3.1 at 100–150 stacks, Fire purity 80) and the rate (4 strikes a second at `c_comp` 1.0, costing nothing). By the rules the build meets top-end. If Fire buff's "damage dealt" is ruled into L1 (Effects rule 9a does not name its layer), the factor shrinks to about ×1.1 and the build sits on M and rate alone; see suggestions |
| The fight | NOT ASSESSED | No simulator this run (user decision 2026-11-11). Read from the rules: nothing is gated behind a late art (the beast strikes at 0.5 s, Feed the Fire at 0.5 s); the keeper's spend is throttled by Feed the Fire's 40 % guard, so the pool cannot run dry on buffs; heals refund. Unmodelled: every Needs-rule piece (Lent Hand, Bonded Spirit, the beast in the open, Rouse, Whistle's timer shave) |
| Reuse | PASS | Reused by name: Beast Soul Union, Pack Hunt, Marked Prey (Effects); Bonded Spirit, Companion attack speed, Companion damage (tree catalogue); Element-tagged companions, Rain on Both (by-root missing-pieces); Full Trough (2026-11-07 ledger); Rot Seeps In (Effects note). New pieces each have a second home (Stack table); signatures: the Tiger-Tally Seal only |
| NPC use | PASS | Every new piece reads compile values (share, slots, purity) or live events the engine lists; a sect of beast keepers can be generated as Contract holders. Breakdown lines: "Straining Leash: share 1.80 over cap 1.0, +40 L5"; "Lent Hand: basic attack → Moss-Fang Bite"; "Moss-Striped Tiger took 412 of 1,373 (Shared Heart)" |
| Counterplay | PASS | Physical-resistant healer and slow heavy hitter (above) |
| Originality | PASS | Names checked as original: Cedar-Ridge, Shared-Heart Contract, Moss-Striped Tiger, Tiger-Tally Seal (a tiger tally is a generic historical object), Straining Leash. The structure (a minion build) is borrowed from Path of Exile; no names are |

## Fight Results

No fight input was written and no simulation was run (user decision 2026-11-11). Key numbers from the GDD formulas, at Nguyên Anh (U = 100), top-end, foreseen fight:

- One bite: 100 × 1.0 × M 203 = **20,300** before Fire stacks, suppression and the defence path; × 2.4 with 100 Fire stacks at purity 80 = about **48,700**. Four bites a second.
- Heal: Old-Tree Sap restores 100 × 3.78 × 4 = **1,512** (before `healing_pct`), refunding its 0.05 when it heals.
- Beast bar: 0.5 × the keeper's health (64 × 100 × n_body = 6,400 × n_body), so **3,200 × n_body** before Thick Hide.
- Fire economy: Feed the Fire buys 60 stack-seconds for 2 % of the pool. Spare regeneration of 4 % a second holds about 120 stacks (+144 %, ×1.16 at Fire purity 80).

**Unmodelled:** everything; the list of Needs-rule pieces is under New Content Needed.

## New Concepts

**Beast in the open (Thú Hiện Thân).** A companion that takes part of its keeper's damage on its own health bar, can be healed and shielded by its keeper, goes Down at 0 and rises later. Rule needed: combat.md rule 19 (today: "cannot be targeted … cannot be removed except by its owner's defeat") and Formulas J; combat-defence.md rule 16 (heal and shield targets). Bounds: bar `beast_health_share` 0.5 of the owner's health; share of damage 0.30; ticks, soul and fatigue never shared; rise after 8 s at 25 %. Breakdown line: "Moss-Striped Tiger took 412 of 1,373 (Shared Heart)". Other builds it serves: the Turtle and the Snake (by-root dual-water-wood, guardian companion), the Herd-Child (2026-11-07). Opt-in only, through the Contract, so every other companion keeps rule 19 as it is. Question for the user: is a companion bar worth a second health bar in the fight log?

**The companion's timer as a timer.** Art speed (Bonded Spirit), `companion_speed_pct` and "move a timer" (Whistle In) acting on the companion's `basic_cooldown`. Rule: combat.md Formulas A2 (`basic_cooldown` fixed; art speed applies to arts only), effects.md rule 6. Serves: the Herd-Child and Guide Hound (2026-11-07), any herd song build.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Shared-Heart Contract | Needs rule | effects.md rule 6, a new action "redirect the basic attack to the companion"; combat.md rule 19 and Formulas J for the beast in the open; a closing rule (forbid a slot kind) |
| Beast in the open | Needs rule | combat.md rule 19, Formulas J; combat-defence.md rule 16 (heal and shield targets); a Down state for companions |
| Bonded Spirit | Needs rule | combat.md Formulas A2: art speed applies to the companion's timer |
| `companion_speed_pct` | Needs key + rule | modifiers.md Stat List; combat.md Formulas A2 |
| Whistle In, Bark Mantle, Old-Tree Sap, Rouse | Needs rule | effects.md rule 6 (move the companion's timer; restore or shield the companion; stand it up) |
| Rain on Both | Needs rule | heal target companion (by-root missing-pieces) |
| Straining Leash | Fits today | Reads the strongest companion's share at compile (effects.md rule 5) |
| Sure Bite | Fits today | "Skip a roll" (effects.md rule 6) |
| Fang and Claw, Pack Hunt, Marked Prey | Fits today | `damage_more` L2 by tag; starter Effects |
| Feed the Fire, Hearth Song | Fits today | Stack-granting arts with no hit |
| Companion power share, Beast-Bond affix | Needs key | modifiers.md Pending row given a key; an `affixes` row |
| Thick Hide (`companion_health_pct`) | Needs key (and the beast in the open) | modifiers.md Stat List |
| Blood-Meal Pill, Full Trough | Needs key | a pill's fight payload; a feeding readable |
| Moss-Striped Tiger, Moss-Fang Bite | Needs key | creature species record with an element tag (by-root "Element-tagged companions") |
| Tiger-Tally Seal | Needs key | `companion_speed_pct`, companion power share |
| Shared-Heart Tiger-Rearing Scripture | Needs key | abilities, passives and art records have no field yet |
| Fire buff on companion hits | Needs rule (clarification) | effects.md rule 9a: name the layer of "damage dealt" and that companion hits count |
