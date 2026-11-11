# Two Clocks (Song Thời)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses.
> **Seed**: "Tick builds are a clock capped by dot_pulse_cap. Run two separate tick families (Burn and Poison, or a Burn plus a Corpse Rot) so each hits its own cap, then spend what the caps clip. The min-max question: what is the fastest legal kill clock, and how does the build live until it rings?"
> **Direction**: The Two Clocks: a fast Burn clock that empties the enemy's linh lực through what their resistance stops, and a slow Poison clock that takes their health once the first one rings.
> **Realm span**: Kết Đan (Core Formation) to Hóa Thần (Deity Transformation) · **Power level**: top-end · **Use**: player · **Kind**: min-max
> **Fit**: 8 Fits today · 4 Needs key · 7 Needs rule
> **Checks**: 5 PASS · 0 FAIL · 4 NOT ASSESSED (Budgets: artifact thần thức has no budget source; Stack: the identity test cannot run in `fight_calc.py`; Scaling: Combat Formulas B's top-end anchors are "re-derive" after #44; The fight: `fight_calc.py` reports CONSTANT_DRIFT on 31 of 60 constants and still models the retired tick caps)

## The seed meets the current rules

The seed's premise has been retired. Combat economy revision #44 (2026-11-09) removed `dot_pulse_cap` and `dot_pool_cap`
(combat.md rule 7, Formulas F: "Ticks have no cap … resistance and cleansing answer them"). Burn and Poison are now
**element stack batches** with no stack cap, at `c_tick` 0.019 per stack, priced through the art lint's charge (effects.md
rule 9a, Formulas D). So this build answers the seed's question in today's terms:

- **What clips a tick now?** The target's resistance, in points (combat-defence.md rule 3), and a cleansing ward that
  removes 25 % of every batch each pulse (rule 6). Nothing else does.
- **Spend what the caps clip** becomes **spend what the resistance stops**. A drain ward already bills the defender's
  linh lực for every point it stops, ticks included (combat-defence.md rule 8). Add an Overflow on the stopped part
  (Ash Ledger) and one on the landed part (the existing Spillover), and the enemy's linh lực drains at roughly the same
  rate whatever their resistance. That is the first clock.
- **The fastest legal kill clock** is bounded only by the charge cap: one firing pays for at most 40 debuff
  stack-seconds (0.6 ÷ 0.015). Read literally, effects.md AC-EF-69 lets an art grant more and still pay 0.6. That gap,
  and the equal price of a 1 s batch and a 10 s batch, are two findings for the suggestions file. The build is
  designed inside the bound the fix would make real.

## Directions considered

- **Chosen: The Two Clocks (Song Thời).** The two families are given two different shapes of time. Burn arrives in
  fat, short batches (20 stacks for 2 s): fast, cleanse-resistant, resisted hard by common Fire wards. So most of it is
  *stopped*, and Ash Ledger turns what is stopped into linh lực burn. Poison arrives in thin, long batches (4 stacks for
  10 s), stretched by stack duration. It ramps, passes every shield, and meets rare Chaos resistance, so it is the
  health clock. When the first clock rings (enemy linh lực at 0), their arts stop, their drain ward falls, and through
  the enabler Bare Vessel lifts both families by +80 L5. It is the strongest min-max reading because each
  family covers the defence the other is weak against.
- **Not chosen: The Cleanse Debt (Tẫn Trái Đạo).** A surprise reading that builds around the enemy's cleansing ward,
  so that every stack it removes pays you. It only works when the foe brings a cleanse, and most foes do not. Its one
  good piece survives here as Cinder Debt, an answer rather than an engine.
- **Not chosen: The One-Pulse Bonfire (Nhất Tức Liệu Nguyên).** The literal fastest clock: 40 stacks for 1 s every
  second, no ramp, ticking before any cleanse. It rests on two pricing gaps the game should close, so a player
  guide built on it would be patched away. It is filed as suggestions instead.

## The Spine

- **The channel:** ticks (over-time statuses: Burn is Fire, Poison is Chaos), layers L1–L4, plus L5 through the
  enabler. They skip evade, block and ward shields, and meet resistance in points. Poison also passes body shields;
  Burn wears them down. They have no cap and no floor. Answered by resistance, status resistance and cleansing.
  Second channel: linh lực burn (Ash Ledger, Spillover, the enemy's own drain bill), which meets nothing.
- **The enabler:** the Twin-Wick Incense Clock. It opens L5 for your ticks and closes all hit damage.
- **The loop:** every second Ember Rain and Rot Seed lay a batch; every two seconds the Censers lay another.
  Burn's stopped damage bills the enemy's pool, Burn's landed damage refills yours (Embers Feed the Hearth), and Poison
  stacks pile up.
- **The engine:** Ash Ledger and Spillover together make the first clock almost blind to resistance. When it rings,
  three things happen at once. The enemy stops casting, a drain ward falls, and Bare Vessel turns on. So the
  second clock runs about ×3 faster from that pulse on.
- **The sacrifice:** no hit damage at all, so no fallback. A foe with status resistance past 100 % (application at
  the 5 % floor) or a strong cleanser leaves it with nothing, and it refuses to fix that: no hit arts and no
  crit. Foreseen fights only for full power (L4 is preparation).
- **The arc:** at Kết Đan a ward-drowner with two arts per family; at Nguyên Anh the Incense Clock makes it a killer;
  at Hóa Thần the full Thiên giai canon, a seventh slot and +1 Poison per grant.

## The Legend

The Twin-Wick Incense Clock was made for a mountain temple that kept two vigils, one for the living and one
for the dead. The green coil burned rot-wood gathered from coffins; the red coil burned cassia. When each coil
reached its thread, a bronze ball fell onto the bell beneath. Monks timed their meditations by it, and the abbot
timed something else: the red bell meant a guest's qi was spent, the green bell meant the guest was dying.

The temple was burned out two centuries ago by a sect that found its own elders among the "guests". The clock
survived because the fire could not hurt it. Whoever carries it now learns its price quickly. Their hands stop
hurting anyone; all their harm moves into the smoke. Cultivators who walk this path speak little and wait a
great deal. They count under their breath, because they know to the second when the enemy will run dry.

The Green Flame Scripture is the temple's own manual, copied by a novice who survived the burning. It teaches that
wood is patience and fire is spending, and that the art is in making the enemy spend first.

## How It Fights

You never strike. From the first second, red embers and green spores settle on the enemy, a heavy burst of Burn
every second and a thin layer of rot that keeps piling. Their ward fights the fire bravely, and every point it stops
is paid from their linh lực. By the third second against a strong foe their pool is gone. Their arts go silent,
their ward goes out, and the rot that was crawling starts to race. You spend the fight behind a shield and a
regrowing body, waiting for the second bell.

**Signature moment:** the Breakdown line "linh lực 0", then the next pulse's ticks jumping from about 40 to about 260
raw per family as Bare Vessel lights: the first bell, then the second.

## Enabler

**Twin-Wick Incense Clock (Song Tâm Hương Chung)**: a named artifact on the bell base (Chuông), utility role.

- **Opens:** your L5 payloads (Effects' `damage_more` on L5) also apply to your over-time ticks. Combat Formulas F
  limits ticks to L1–L4, so this is a `Needs rule` bend.
- **Closes:** your hits (arts, basic attack, trigger hits) deal no damage. They still roll evade and still apply
  their statuses and curses.
- **Found:** in the ruins of a burned mountain temple, or on a Nguyên Anh cultivator of this path (an NPC can carry it).
  A rare item; the stack under it is ordinary.

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Burn, Poison (element debuffs) | `c_tick` 0.019 per stack, no stack cap | — | tick | — | ● | Effects rule 9a | every Fire or Wood build |
| 1 Base | Stack effect [hoa, debuff], [moc, debuff] | +36 % each (one notable +24 and three smalls) | Increased | tick | none (on the stack) | ◐ | Tree, Hỏa Đạo, Độc Đạo | any stack build |
| 1 Base | Root purity | ×(1 + 0.002 P) per stack, P 80 → ×1.16 | Per | tick | none | ◐ | Spiritual root | every stack build |
| 2 Rate | Stack duration [moc, debuff] | +60 % (Poison 10 s → 16 s) | Increased | tick | none | ◐ | Độc Đạo Nọc, tree | Wood stack builds |
| 2 Rate | Stacks per grant [moc] | +1 Poison per grant (Hóa Thần) | Flat | tick | none | ◐ (rare) | Độc Đạo capstone stem | starter-venom at its top |
| 3 L1 | Damage over time, poison, fire | +300 points across [over_time], [poison], [fire] lines | Increased | tick | L1 | ◐ | Tree, Đạo | any tick build |
| 3 L2 | Green Flame passive | +40 [over_time] | More | tick | L2 | ○ | Green Flame Scripture | any tick build |
| 3 L2 | Rot Deepens (Thi Độc Thâm) | +40 [poison] | More | tick | L2 | ○ reused | Độc Đạo notable | Burial Shroud |
| 3 L2 | **Banked Coals (Than Ủ)** | +40 [burn] | More | tick | L2 | ○ new | Hỏa Đạo Chân Hỏa notable | any Burn build |
| 3 L3 | Gear | Fan (Phiến) and Gourd (Hồ Lô) attack, about +200 at Nguyên Anh | — | tick | L3 | ● | Artifacts | everyone |
| 3 L4 | Corpse-Wax Coating (Thi Lạp) | +60 prepared tick damage; plus a +40 pill | More | tick | L4 | ○ reused | Preparation | Burial Shroud |
| 3 L5 | Bare Vessel (Lộ Đỉnh) | +80 while the enemy has under 5 % linh lực | Conditional | tick (via enabler) | L5 | ○ reused | Sealed cluster | Burial Shroud, Ninth Bell |
| 3 L5 | Fuel for the Fire (Tân Hỏa) | Burn +3 per 5 Poison stacks | Per | tick [burn] (via enabler) | L5 | ○ reused | Mộc Đạo notable | Wildfire (by-root) |
| 3 L5 | Kindled Wound, Marked Prey | +15 [fire] vs a burning target; +4 per distinct status (+8) | Conditional, Per | tick (via enabler) | L5 | ◐ | Hỏa Đạo; Item | Fire, curse builds |
| 4 Certainty | — | Ticks never crit; status chance 100 % is the certainty, cut by status resistance | — | — | — | — | — | **sacrifice** (no crit) |
| 5 Reach | Penetration [fire], [chaos] | +120 points each | Flat | tick | none | ◐ | Hỏa Đạo Tro Tàn, Độc Đạo Nọc | any element build |
| 6 Past the cap | **Ash Ledger (Tro Trướng)** | 20 % of tick damage stopped by resistance burns the target's linh lực | Overflow | tick → linh lực | none | ○ new | Hỏa Đạo Tro Tàn | dry-well |
| 6 Past the cap | Spillover (Dật Độc) | 25 % of tick damage dealt burns linh lực | Overflow | tick → linh lực | none | ◐ | Độc Đạo Nọc | any poison build |
| 6 Past the cap | **Cinder Debt (Tẫn Trái)** | each of your stacks a cleanse removes burns 0.5 % of the cleanser's max linh lực | Overflow | cleanse → linh lực | none | ○ new | Hỏa Đạo Tro Tàn | starter-venom |
| 7 Fuel | Embers Feed the Hearth (Tàn Hỏa Dưỡng Lô) | Burn ticks restore 25 % of their damage as your linh lực | Trigger (keystone) | tick → own linh lực | none | ○ reused | Meridian Map, Fire land | single-fire |
| 7 Fuel | Linh lực regeneration | +1 pp | Flat | — | none | ◐ | Tree | everyone |
| 8 Survival | Spring Sap's Wood buff | 30 stacks steady → +3.5 % health a pulse | — | — | none | ● (stacks), ○ (art) | Green Flame Scripture | Wood sustain |
| 8 Survival | Wards | Common Ward, Mountain Screen; Clear Heart Ward from Nguyên Anh | — | — | — | ● | Ward slots | everyone |
| 9 Identity | Ash Ledger | see rung 6 | Overflow | | | | | |

**Forms used:** Increased, More, Flat, Per, Conditional, Overflow, Trigger, plus the Scaling-bridge enabler (8).

**Identity piece:** Ash Ledger. It makes the first clock indifferent to resistance. The harder the enemy resists,
the more is stopped, and the more their own pool pays. Without it, a strong ward stalls the first clock
until the second has to do the work alone (Fight Results: own health 58 % → about 25 %).

**Empty rungs:** crit (rung 4) is a sacrifice: ticks cannot crit. Hit damage is a sacrifice, the enabler's close.

| Layer (ticks) | Points at Nguyên Anh | Multiplier | Sources |
|---|---|---|---|
| L1 | 300 (soft cap: 250 effective) | ×3.50 | Tree and Đạo tick-scoped Increased lines, technique `attack_pct` 10 |
| L2 | 150 per family | ×2.50 | Green Flame passive 40, Rot Deepens or Banked Coals 40, Đạo notable 30, aux technique 40 |
| L3 | 200 | ×3.00 | Fan and Gourd artifact attack against the realm base |
| L4 | 100 (foreseen) / 0 (blind) | ×2.00 / ×1.00 | Corpse-Wax Coating 60, a Kindling pill 40 |
| L5 | before the first bell: Poison 8, Burn 23 + 0.6 per Poison stack; after: Poison 88, Burn 100 (cap) | ×1.08–2.00 | Marked Prey, Kindled Wound, Fuel for the Fire, Bare Vessel, via the Incense Clock |
| Stack effect, purity | +36 %, P 80 | ×1.36 × 1.16 | Not layers: multiply the stack itself |

L1–L4 product 52.5 (foreseen). With stack effect and purity, each stack ticks for 1.574 U a pulse before
resistance and L5 (U = the realm's fight unit, 100 at Nguyên Anh). Against the Formulas B anchors: the typical
L1–L4 product at Nguyên Anh is about 6.7, the top-end one about 128. The build sits below top-end per layer
and makes it up through the uncapped stack count and the ×2 of L5.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Wood and Fire, both at purity 70+ (80 assumed) | Each purity powers its own family (×1.16 at 80). Wood generates Fire, so the main technique gains harmony (`main_generates` 1.15) |
| Key talents | Comprehension (layers and Đạo glimpses); Căn cốt second (health, since the build must stand still for 8 s) | The build is Đạo-heavy and wants its technique at full layers |
| The Way (Đạo) | **Hỏa Đạo** (Tro Tàn facet: Ash Ledger, Cinder Debt, Fire penetration; Chân Hỏa: Banked Coals, Burn stack effect). **Độc Đạo** (Nọc facet: Spillover, Poison stack duration and effect, Chaos penetration, Rot Deepens) | Hỏa holds the identity; Độc holds the slow clock. Both need their element at purity 30+ |

## Công Pháp

### Green Flame Scripture (Thanh Diễm Quyết) — main, Địa giai, then Thiên giai (Thanh Diễm Thiên Kinh)

The temple novice's copy. Its margins say "make them spend first".

```json
{"id": "thien_moc_hoa_thanh_diem", "name": "Thanh Diễm Thiên Kinh", "tier": 3, "tech_kind": "main",
 "names": ["moc", "hoa"], "layers": 15,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20}, {"stat": "khi_huyet_pct", "value": 15},
             {"stat": "defense_pct", "value": 12}, {"stat": "attack_pct", "value": 10}],
 "abilities": [{"ability_id": "ember_rain", "unlock_layer": 3}, {"ability_id": "rot_seed", "unlock_layer": 3},
               {"ability_id": "spring_sap", "unlock_layer": 5}, {"ability_id": "red_censer", "unlock_layer": 7},
               {"ability_id": "green_censer", "unlock_layer": 7}],
 "seal_clusters": [], "origin": "authored"}
```

Combat passive (no field yet): `damage_more` +40 [over_time] on L2.

**Fit:** Needs key (the passive and the abilities have no catalogue yet) · **Budget:** 20/20 + 15/15 + 12/15 + 10/15 = **3.47 of 4** (Thiên), each line ≤ 1.5. The Địa giai copy (tier 2, to Nguyên Anh) drops `attack_pct`: **2.80 of 3**. The passive's budget is NOT ASSESSED: it is not in `bonus_pool`.

## Arts

Art lint: `c_art ≤ 1 + 24 · cost + 0.25 · (cooldown − 1)`, × (1 − charge); debuff charge 0.015 and buff charge
0.010 per stack-second (combat.md Formulas C, effects.md Formulas D). Every stack art sits at charge 0.6.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Ember Rain (Tàn Hỏa Vũ) | Green Flame, 3 | Fire hit; hoa, fire, art, quick, cheap | 0.59 | 0.02 | 1 s | — | Fits today |
| Rot Seed (Hủ Chủng) | Green Flame, 3 | Chaos hit; moc, chaos, poison, art, quick, cheap | 0.59 | 0.02 | 1 s | — | Fits today |
| Spring Sap (Xuân Dịch) | Green Flame, 5 | Wood hit; moc, art, cheap | 0.69 | 0.02 | 2 s | — | Fits today |
| Red Censer (Xích Lô Hương) | Green Flame, 7 | Fire hit; hoa, fire, art, cheap | 0.69 | 0.02 | 2 s | — | Fits today |
| Green Censer (Thanh Lô Hương) | Green Flame, 7 | Chaos hit; moc, chaos, poison, art, cheap | 0.69 | 0.02 | 2 s | — | Fits today |

- **Ember Rain.** **Effect:** a hit that applies 20 Burn stacks for 2 s (40 stack-seconds). **Description:** a
  shower of embers that burn out before anyone can sweep them away.
- **Rot Seed.** **Effect:** a hit that applies 4 Poison stacks for 10 s (16 s with the build's stack duration).
  **Description:** spores that wait in the meridians.
- **Spring Sap.** **Effect:** a hit that grants its owner 6 Wood buff stacks for 10 s (+0.1 pp health regeneration
  each). **Description:** the green coil's smoke, breathed in.
- **Red Censer, Green Censer.** **Effect:** as Ember Rain and Rot Seed on a 2 s cooldown. **Description:** the clock's
  two coils, lit.

Under the Incense Clock every hit deals 0, so the coefficients matter only to a cultivator without it (an NPC using
the scripture alone).

## Loadout by Realm

| Realm | Slots | Slot order | Ward slots | Note |
|---|---|---|---|---|
| Kết Đan | 5 | Ember Rain, Rot Seed, Spring Sap, Red Censer, Green Censer | Common Ward, Mountain Screen | No enabler yet: ticks on L1–L4 only, hits still deal their 40 % |
| Nguyên Anh | 6 | as Kết Đan, then Golden Light Shield (cast ward in an art slot) | Common Ward, Mountain Screen, Clear Heart Ward | The Incense Clock: L5 reaches the ticks |
| Hóa Thần | 7 | as Nguyên Anh, then a third Rot Seed copy (aux technique) or an escape talisman | + Thousand-Layer Cloud | Thiên giai canon, +1 Poison per grant |

Slot order puts Ember Rain first, because with little linh lực the earlier slot pays. The Burn clock is the one that
must never wait.

Linh lực bill: 0.02 + 0.02 + 0.01 + 0.01 + 0.01 = **0.07 of the pool per second** at Kết Đan, against regeneration
0.035 + 0.009 (+1 pp, log curve) = 0.044. Embers covers the rest while Burn lands (about +6 % of the pool a
second against a strong foe, far more against a typical one).

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Twin-Wick Incense Clock (Song Tâm Hương Chung) | Artifact, utility | Chuông (bell), named | The enabler | Needs rule |
| Ember Fan | Artifact, weapon | Phiến, high grade, realm tier | L3 attack; a `resist_pen_pct` [fire] affix if rolled | Fits today |
| Spore Gourd | Artifact, weapon | Hồ Lô, high grade, realm tier | L3 attack; a `stack_duration_pct` [moc] affix if rolled | Fits today |
| Temple robe | Artifact, ward gear | Giáp | Ward strength for the Common Ward | Fits today |
| Corpse-Wax Coating (Thi Lạp) | Preparation | coating | +60 L4 on ticks, foreseen fights | Needs key (reused) |
| Kindling pill | Pill | Alchemy | +40 L4, foreseen fights; a Wood-Fire root brews its own | Needs key |

The clock's history is above. The fan and the gourd are the two coils' tools: one to drive the fire, one to carry
the rot.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Embers Feed the Hearth (Fire land keystone) | 25 % of Burn dealt → linh lực | Pays the 0.07/s bill; its close costs nothing under the Incense Clock | Needs rule |
| 2 | Damage over time notables | +12 % each | L1 for both families | Fits today (designed) |
| 3 | Stack effect [hoa, debuff], [moc, debuff] | +24 notable, +3.6 small | Multiplies every stack | Fits today (designed) |
| 4 | Penetration [fire], [chaos] | +120 / +18 | Reach, and past 0 it amplifies | Fits today (designed) |
| 5 | Linh lực regeneration | +0.35 pp notable | Fuel | Fits today (designed) |
| 6 | Sick Meridians (Bệnh Mạch), sealed cluster (content ledger) | Bare Vessel at its end | The second bell | Needs key (reused) |

## Đạo

No new Way. Two placements in existing catalogue Ways (dao.md § Catalogue), for whoever draws their graphs:
- **Hỏa Đạo, Tro Tàn (Ash: after the Burn):** Ash Ledger as a `major` Effect notable, Cinder Debt as a `minor`,
  Fire penetration and Burn stack effect lines on the way in. The facet's theme is what the fire leaves, and
  Ash Ledger spends exactly that.
- **Độc Đạo, Nọc (Venom: Poison stacks):** Spillover (existing) as a notable, Poison stack duration and effect, Chaos
  penetration, Rot Deepens.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Kết Đan | A ward-drowner: the enemy's pool is gone by about 3–4 s, then the ticks finish | Green Flame Scripture (Địa), Ember Rain, Rot Seed, Ash Ledger, Embers | Finds the novice's manual; learns that the fire is for their linh lực |
| Nguyên Anh | A clock-maker: the first bell lights Bare Vessel and the second rings within about 5 s | Twin-Wick Incense Clock; Clear Heart Ward; Golden Light Shield | Takes the clock from the temple ash, and stops hurting anyone with their hands |
| Hóa Thần | The same, faster and deeper: +1 Poison per grant, a seventh slot, fourth ward | Thiên giai canon, Thousand-Layer Cloud | Learns who burned the temple, and that the abbot's guests were not all innocent |

## Matchups

Paper model, Nguyên Anh, same realm, foreseen. "Strong" is a first-guess stand-in for a top-end foe, because Combat
Formulas B's top-end ehp is "re-derive": 1,650 resistance points (700 on a drain ward, 950 kept), health n 2.0,
linh lực n 1.5, hit M 30.

| Enemy | Result | Why |
|---|---|---|
| Typical (Common Ward 448, drain) | Wins, about 4 s | First bell at about 3 s; then resistance is −120 after penetration, which amplifies, and Bare Vessel lights |
| Strong (above) | Wins, about 8 s, own health about 58 % | First bell at about 3 s stops its arts; the second at about 8 s |
| Typical + Fire-Shunning Veil, Chaos 150 kept (Combat rule 18's high-resistance foe) | Wins, about 5 s | Resisting Fire makes more of Burn stopped, so Ash Ledger rings the first bell sooner |
| Strong + Clear Heart Ward (cleanse 0.25, status +37.5 pp) | Narrow win, about 13 s | Poison holds about 15 stacks, Burn about 33; Cinder Debt and the 25 % reservation still ring the first bell at about 5 s |
| A healer with status resistance past 100 % (Combat rule 18's healer, built to resist) | **Loses** | Every batch lands at the 5 % floor and the build has no hits |
| Top-end burst (the first-volley shape, Formulas B top-end M) | Loses, NOT ASSESSED in detail | It kills in a volley or two, before the first bell; top-end ehp is "re-derive" |
| A reserved-ward foe (Still Lake Aura) | Wins, slower | Its resistance never falls, but the first bell still silences its arts |

**Counter:** a cultivator who resists statuses rather than damage. Clear Heart Ward, status resistance against
over_time (+30 pp notable) and against poison (+40 pp) take application to the 5 % floor, and the build has nothing
else. The second counter is speed: a burst build that ends the fight before the third second.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 3.47 / 4 (Thiên) and 2.80 / 3 (Địa), every line ≤ 1.5: pass. Arts at their lint (0.59, 0.69) with charge 0.6: pass. Slots 5 / 6 / 7 used of 5 / 6 / 7: pass. Artifact thần thức (Chuông 25, Phiến 25, Hồ Lô 25, Giáp 5 = 80) against the realm's budget and `equip.max_slots`: no source read gives the budget for these named pieces, so this part could not be checked |
| Validity | PASS | Elements `moc`, `hoa`; tier 3 `max_realm` `hoa_than` covers the span, tier 2 reaches `nguyen_anh`; bases Chuông, Phiến, Hồ Lô, Giáp exist in `items_artifacts.json`; wards from combat-defence.md Formulas H; Wood generates Fire (harmony 1.15) |
| Stack | NOT ASSESSED | Every rung filled or named a sacrifice (crit, hits); 8 forms; no modifier targets a layer its channel lacks except the L5 pieces, which the enabler makes live; layer totals above. **Identity test:** `fight_calc.py --without` cannot remove Ash Ledger because the script cannot express it, so per the skill this part is NOT ASSESSED. The paper model says removing it changes the fight (strong foe: first bell 3 s → 6 s, kill 8 s → 9 s, own health 58 % → about 25 %) |
| Scaling | NOT ASSESSED | `fight_calc` prints m_static 3.30 (only untagged sources, by its format) against anchors 7.37 / 256; meaningless here. Tick L1–L4 product 52.5 sits between the typical (≈ 6.7) and top-end (≈ 128) products; with L5 at cap and stack effect it reaches ≈ 166. Top-end ehp anchors are "re-derive" (Formulas B), so "top-end" cannot be checked against them. INFO: the paper model's kill times are top-end-fast |
| The fight | NOT ASSESSED | `fight_calc.py --selftest` passed its fixtures but printed CONSTANT_DRIFT for 31 of 60 constants (health_units, resistance, regen, the retired tick caps, the anchors). On this build it reports a loss to the typical foe at 3 s, with `dot_pool_cap_clipped` ×4 and `dot_pulse_cap_clipped` ×2. Those caps no longer exist, and its health is a quarter of today's. The engine (drain billing of ticks, Ash Ledger, Spillover's #44 form, Embers, batches, L5 on ticks) is all UNMODELLED. Paper results are in Fight Results |
| Reuse | PASS | Reused by name: Bare Vessel, Rot Deepens, Corpse-Wax Coating (content ledger); Fuel for the Fire, Embers Feed the Hearth, Green Flame Scripture (by-root); Spillover, Kindled Wound, Marked Prey and the wards (GDDs). New pieces each name a second home; one signature-leaning piece (the Incense Clock) |
| NPC use | PASS | Every piece is passive, unguarded or an all-or-nothing enabler the generator can pick. Each is one Breakdown line: "Ash Ledger: 12.4 linh lực burned (20 % of 62 stopped)" |
| Counterplay | PASS | Loses to a status-resisting healer (rule 18's healer kind) and to top-end burst; slowed by a cleanser |
| Originality | PASS | Names are new; the incense clock is a real historical object, not a borrowed IP; no novel or game names used |

## Fight Results

Input: `two-clocks.fight.json`. `fight_calc.py` observations are recorded but are of the pre-#44 model. The table below is
the hand-worked paper model on today's GDD formulas (combat.md Formulas A, E, F; combat-defence.md rules 3, 8;
effects.md rule 9a, Formulas D). The drain bill rate is 0.19 linh lực per stopped point at the Common Ward (combat.md
Formulas C's worked example), scaled down in proportion for stronger drain wards. Expected values, no chance. A
reproducible simulator built on the canonical #44 `sim.py` is `two-clocks.sim.py` (not yet run; see its header).

| Enemy | Realm | Result | Time | First bell (enemy linh lực 0) | Own dry at | Cap hits |
|---|---|---|---|---|---|---|
| typical | Nguyên Anh | win | ≈ 4 s | ≈ 3 s | never | none (no caps exist) |
| strong | Nguyên Anh | win | ≈ 8 s | ≈ 3 s | never (Embers) | none |
| strong, **without Ash Ledger** | Nguyên Anh | win | ≈ 9 s | ≈ 6 s | never | none; own health ≈ 25 % |
| strong, **without the Incense Clock** | Nguyên Anh | win | ≈ 11 s | ≈ 3 s | never | none |
| strong + Clear Heart Ward | Nguyên Anh | narrow win | ≈ 13 s | ≈ 5 s | ≈ 20 s | none |
| typical | Kết Đan (no enabler) | win | ≈ 4 s | ≈ 3 s | never | none |
| strong (1,400 points, 600 drain) | Kết Đan (no enabler) | win | ≈ 14 s | ≈ 4 s | ≈ 25 s | none; own health ≈ 45 % |
| strong, without Ash Ledger | Kết Đan | coin flip | ≈ 15 s | ≈ 8 s | — | own health ≈ 0–6 % |
| `fight_calc` typical (old model) | Nguyên Anh | loss | 3.0 s | — | 2.0 s | `dot_pool_cap_clipped` 4, `dot_pulse_cap_clipped` 2 (retired caps) |

**Worked pulse, Nguyên Anh vs strong.** One stack ticks 0.019 × 52.5 × 1.36 × 1.16 = 1.574 U raw. At pulse 3 the
target holds 60 Burn and 12 Poison. Raw = 1.574 × (12 × 1.08 + 60 × 1.302) = 143 U. Resistance 1,530 after
penetration lets 6.1 % through (8.8 U) and stops 134 U. Their own drain bill takes 7.5 U of linh lực, Ash Ledger 26.9 U,
Spillover 2.2 U. With pulse 2's burn, their 39 U pool is gone. From pulse 4 the drain part of their ward is down
(950 − 120 = 830 points, 10.75 % through), and L5 rises to 1.88 (Poison) and 2.00 (Burn). The ticks are 236 U raw and 25 U
dealt, and climb by about 2 U a pulse.

**The kill clock, in one line.** For thin batches the dealt damage grows like `q · g · k² / 2` (q per-stack dealt, g
stacks a second, k pulses), so the kill comes at about `k ≈ 1 + √(2H / (q·g))`. For fat batches it grows like `q · S · k`, so
`k ≈ 2 + H / (q·S)`. Front-loading wins every fight shorter than about twice a thin batch's duration, and #44's fights
are all that short. Hence the fast clock is Burn in fat batches.

**Unmodelled (in `fight_calc.py`):** element stack batches; drain billing of ticks; Ash Ledger; Spillover (#44 form);
Embers Feed the Hearth; Cinder Debt; the Incense Clock's L5 on ticks and its zero-hit close; Spring Sap's Wood buff;
resistance in points; the ward slots. These are all of the engine, which is why The fight is NOT ASSESSED.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Twin-Wick Incense Clock | Needs rule | combat.md Formulas F: an Effect may extend its owner's L5 payloads to its ticks (suggestions.md) |
| Ash Ledger | Needs rule | effects.md rule 5: a tick's prevented points as a readable |
| Cinder Debt | Needs rule | effects.md rule 5, combat.md rule 9: "your stacks removed by a cleanse" event |
| Fuel for the Fire (reused) | Needs rule | Works only with the Incense Clock, or rewritten as L2 |
| Embers Feed the Hearth (reused) | Needs rule | Tick event → restore linh lực |
| Tro Tàn notable (Hỏa Đạo) | Needs rule | Via Ash Ledger |
| Green Flame Scripture | Needs key | A combat passive and ability list on technique records |
| Bare Vessel, Rot Deepens, Corpse-Wax Coating (reused) | Needs key | As in the content ledger |
| Banked Coals; the five arts; Nọc placement; wards | Fits today | Content records only |
| Stack grant bound at the charge cap | Needs rule | effects.md Formulas D, AC-EF-69 (suggestion) |
| Front-loaded batch floor or price | Needs rule | effects.md rule 9a, Formulas D (suggestion) |
