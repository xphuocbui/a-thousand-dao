# The Long Carry (Trường Đảm Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "A doctrine for a thousand disciples: a sect's standard path." No enabler, zero or nearly zero rule asks, mid-power, defined at Foundation Establishment, honestly loses one realm up, fun for an ordinary player to find. One new Conditional and one Redirect, arts paid in linh lực, ward on. Propose a technique tier ladder.
> **Direction**: A breath race. Every piece is ordinary. The surprise is which ordinary stat matters: ward efficiency, not ward strength.
> **Realm span**: Qi Refining – Deity Transformation, run at Foundation Establishment and Core Formation · **Power level**: ordinary · **Use**: a sect's standard path, for players and NPCs
> **Fit**: 4 Fits today · 13 Needs key · 0 Needs rule
> **Checks**: 9 PASS · 0 FAIL · 0 NOT ASSESSED. `t_b` has no set values yet (Combat Open Question 17), so its sizes here are guesses inside a passed check.

## The Spine

- **The channel:** art hits and the basic attack, using L1 to L5. Nothing is capped or escaped.
- **The enabler:** none.
- **The loop:** walk, shift the pole, set the load down. Spend a little, take small blows on the body, and stay ahead on breath.
- **The engine:** whoever holds more of their linh lực hits half as hard again. So every stat that saves your pool, or burns theirs, is now a damage stat.
- **The sacrifice:** reach. No pierce, no art speed, no secret art until the last realm. One realm up the lead never comes.
- **The arc:** from a child who learns to count their breath to an elder who still loses to anyone above them, and teaches anyway.

## The Legend

The bearers of the Nine Switchbacks carried rice over the pass to a walled town through one long siege winter. They had poor roots and good shoulders. The ones who arrived were never the strongest. They were the ones who still had breath at the last turn, and they sang to keep the pace. When the siege lifted they kept walking, and the song became a method. The Hill-Road Hall (Sơn Lộ Đường) still takes anyone with a root and a back, and a disciple's first senior is whoever carries beside them.

The manuals are body manuals, so they ask nothing of a root, and a dull student loses less by them than by any scripture. The great sects call it the mule's method, and they are right: it has never beaten anyone a realm above it. But the Hall counts its disciples at the end of every war, and the count is what it boasts of. Every bearer has one rule by heart: bring the load home, and bring each other.

## How It Fights

The bearer strikes in the first second with a small qi blow and does not raise a strong ward. Blows get through. They land on a trained body, and the breath stays in. By the second second the enemy has spent more than the bearer has, and the bearer's hits grow by half. At three seconds they set the load down, and the fight ends by four. **The signature moment:** a disciple on 38 % health looks beaten, but the Breakdown says `Longer Breath +50`. The enemy has more health and almost no linh lực, and the next hit lands on bare skin.

**What an ordinary player finds.** Take the same disciple and move 48 points from ward efficiency to ward strength, which is what everyone does first. A win at 4 s with 21 % health left becomes a loss at 4 s with the enemy on 53 % (`variants/long-carry-naive.fight.json`). Longer Breath is on for 0 of 9 hits. A stronger ward blocks more, and every blocked point drains the pool. That is one number on one screen, and a player can find it alone.

## The Stack

Sizes on new modifiers are first guesses. Forms: Increased, More, Per, Conditional, Redirect.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | The three drill arts | c_art 1.48, 2.2, 2.9, each at the art lint | none | art | none | ○ | Volumes I and II | any cheap art build |
| Multiplier | Damage (`attack_pct`) | +40, below a typical cultivator's 62 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Sustained Note (Dư Âm) | +6 points per second to +30, on arts: the carrying song | Per | art | L2 | ○ reused | Volume I | Ninth Bell |
| Multiplier | Artifact attack | +30 from one plain flying sword | Gear | any | L3 | ● | Artifact | every build |
| Multiplier | Iron-Sand Hand Bath (Thiết Sa Dục Thủ) | +25 points to body hits, prepared | More | basic, art | L4 | ○ reused | Preparation | Receiving Hand |
| Multiplier | **Longer Breath (Trường Tức)** | +50 points to hits while your linh lực share is more than 10 points above the enemy's. A lead of 10 is this sheet's grade: The Deepest Well holds the same modifier at a lead of 0, and one lead would change fights | Conditional | art, basic | L5 | ○ | Volume I, layer 3 | any ward-breaker or drainer: **used by The Deepest Well** |
| Crit | Crit chance | 5 %, a few tree nodes | Increased | any | none | ● | Tree | every build |
| Fuel | **Thrift (Tiết Dụng)** | A quarter of your ward efficiency also counts as `art_cost_pct`, inside its 50 % limit | Redirect | art | none | ○ | Volume II, layer 5 | any per-hit ward build, any cheap art build: **used by The Deepest Well** |
| Fuel | Ward efficiency (`ward_efficiency_pct`) | `we` 75, from two shields and 48 tree points | Increased | any | none | ◐ | Tree, artifacts | any sustain build |
| Survival | Body guard from two manuals | `t_b` 0.9, because blows are meant to reach the body | none | any | none | ◐ | Volumes I and II | any thể tu |

**Identity piece:** Longer Breath. Without it the disciple loses at 6 s with the enemy on 3 %. One realm up it is on for 0 of 5 hits, so the same piece makes the build and marks its ceiling.
**Empty rungs:** Rate, Reach and Past the cap are sacrifices. There is no art speed or pierce to buy a fight above your realm, and nothing reaches a cap.

| Layer | Points at Foundation Establishment | Multiplier | Sources |
|---|---|---|---|
| L1 | 40 | ×1.40 | `attack_pct` |
| L2 | 0 to 30 | ×1.00 to ×1.30 | Sustained Note, arts only, growing |
| L3 | 30 | ×1.30 | One Phi Kiếm |
| L4 | 25 on body hits | ×1.25 | Hand Bath; gone in a blind fight |
| L5 | 50 while ahead | ×1.50 | Longer Breath |

`m_static` 1.82 against a typical 4.19. With every layer on, Setting Down reaches ×4.44.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any | The manuals are body techniques, so they name no element. This is how one doctrine serves a thousand different roots |
| Main method | Any par-tier main method for the root | The doctrine sits in both auxiliary slots and leaves the main slot alone |
| Key talents | Physique | Body manuals scale with it: F = 1.1 at Physique 60. Comprehension 20 costs a body manual 6 % of a bonus, not 12.5 % (Formulas F) |
| The Way (Đạo) | None required | A disciple's Way is their own business |

## The Ladder: How the Hall Teaches It

Four volumes, one per tier, all **body techniques** (`tech_kind: body`, `names: []`), so any root can slot them. No rule changes. It uses three things already in Cultivation Techniques: there are two auxiliary slots, slotted techniques gain mastery in parallel, and the tier cap of rule 10 touches only a main method's speed.

**Two baskets.** A bearer carries the volume they are climbing and the one before it, one in each auxiliary slot. Each volume re-lists its predecessor's arts at its **handover layer**, the first layer of the next realm. Once there, the older volume may be set down.

| Volume | Tier, layers | Who gets it | Taught at each layer | Handover | Seasons at Comprehension 45 |
|---|---|---|---|---|---|
| **I. First Load Method (Sơ Đảm Công)** | Hoàng, 6 | Every outer disciple, on the first day | 2 Even Step · 3 Longer Breath, Sustained Note · 5 Shifted Pole · 6 great completion | none | 31 for layers 2–3, 58 for 4–6 |
| **II. Two Baskets Method (Song Lam Công)** | Huyền, 9 | Inner disciples, on reaching Foundation Establishment | 3 Home Road · 5 Thrift · 6 Setting Down · 7 handover · 8 Over the Ridge | 7, at Core Formation | 79 to layer 6, climbed beside Volume I; 98 for 7–9 |
| **III. Long Slope Scripture (Trường Pha Kinh)** | Địa, 12 | Those who form a core | 9 Second Wind · 10 handover · 12 Longer Breath's lead falls to 5 points | 10, at Nascent Soul | 60 to layer 7, begun at Core Formation |
| **IV. Ten Thousand Steps Scripture (Vạn Bộ Kinh)** | Thiên, 15 | Elders of the Hall | 13 handover · 14 Hill Road · 15 great completion | 13, at Deity Transformation | 114 to layer 10, begun at Nascent Soul |

Season counts come from Cultivation Techniques Formulas B: `gain` 1.45, with catch-up on lower-realm layers. A Comprehension 20 disciple's `gain` is 1.2, so they take about a fifth longer, and the path still fits inside each realm (200 seasons at Foundation Establishment).

**What the ladder costs.** Both auxiliary slots, for four realms. A bearer has no secret art until they can set down Volume III in Deity Transformation, and the free hand is the reward for the whole climb. **What it buys.** A disciple never stands with half their arts missing, because the old basket stays up until the new one holds the same load. No volume is a strict upgrade: Volume III at layer 4 gives less than Volume II finished, which is why you carry both.

```json
[{"id": "so_dam_cong", "name": "Sơ Đảm Công", "tier": 0, "tech_kind": "body", "names": [], "layers": 6,
  "bonuses": [{"stat": "khi_huyet_pct", "value": 8}, {"stat": "linh_luc_pct", "value": 9}],
  "abilities": [{"ability_id": "even_step", "unlock_layer": 2}, {"ability_id": "shifted_pole", "unlock_layer": 5}],
  "seal_clusters": [], "origin": "authored"},
 {"id": "song_lam_cong", "name": "Song Lam Công", "tier": 1, "tech_kind": "body", "names": [], "layers": 9,
  "bonuses": [{"stat": "khi_huyet_pct", "value": 12}, {"stat": "linh_luc_pct", "value": 12}, {"stat": "tam_ma_resist_pct", "value": 8}],
  "abilities": [{"ability_id": "home_road", "unlock_layer": 3}, {"ability_id": "setting_down", "unlock_layer": 6},
                {"ability_id": "even_step", "unlock_layer": 7}, {"ability_id": "shifted_pole", "unlock_layer": 7},
                {"ability_id": "over_the_ridge", "unlock_layer": 8}],
  "seal_clusters": [], "origin": "authored"},
 {"id": "truong_pha_kinh", "name": "Trường Pha Kinh", "tier": 2, "tech_kind": "body", "names": [], "layers": 12,
  "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 15}, {"stat": "tam_ma_resist_pct", "value": 10}, {"stat": "lifespan_years", "value": 8}],
  "abilities": [{"ability_id": "second_wind", "unlock_layer": 9}],
  "seal_clusters": [], "origin": "authored"},
 {"id": "van_bo_kinh", "name": "Vạn Bộ Kinh", "tier": 3, "tech_kind": "body", "names": [], "layers": 15,
  "bonuses": [{"stat": "khi_huyet_pct", "value": 20}, {"stat": "linh_luc_pct", "value": 20}, {"stat": "tam_ma_resist_pct", "value": 15}, {"stat": "lifespan_years", "value": 8}],
  "abilities": [{"ability_id": "hill_road", "unlock_layer": 14}],
  "seal_clusters": [], "origin": "authored"}]
```

Volumes III and IV also re-list every earlier art at their handover layers; those rows are left out here for length.

**Fit:** Needs key (abilities, and `t_b` on the record) · **`t_b` at great completion, a guess:** 0.4 / 0.7 / 1.0 / 1.4, scaled by B(k) · **Budget:** I 8/15 + 9/20 = 0.98 of 1.0. II 0.80 + 0.60 + 0.53 = 1.93 of 2.0. III 1.00 + 0.75 + 0.67 + 0.53 = 2.95 of 3.0. IV 1.33 + 1.00 + 1.00 + 0.53 = 3.87 of 4.0. Each is under the single cap.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Even Step (Bình Bộ) | Volume I, 2 | qi, palm | 1.48 | 0.04 | 1 s | none | Needs key |
| Shifted Pole (Hoán Kiên) | Volume I, 5 | qi, palm | 2.2 | 0.08 | 2 s | none | Needs key |
| Setting Down (Phóng Đảm) | Volume II, 6 | body, palm | 2.9 | 0.12 | 3 s | none | Needs key |
| Home Road (Quy Lộ) | Volume II, 3 | escape | none | 0.06 | 1 s | own health below 50 % | Needs key |
| Over the Ridge (Việt Lĩnh) | Volume II, 8 | qi, palm | 3.4 | 0.14 | 4 s | none | Needs key |

- **Even Step.** **Effect:** a hit. **Description:** The first thing taught, and the last thing dropped.
- **Shifted Pole.** **Effect:** a hit. **Description:** Change shoulders before the first one asks.
- **Setting Down.** **Effect:** a hit. **Description:** The load comes off, and it comes off on someone.
- **Home Road.** **Effect:** the escape art of Combat rule 13. **Description:** The only art the Hall examines twice.
- **Over the Ridge.** **Effect:** a hit. **Description:** Only tried once you can see the other side.

Second Wind and Hill Road are placeholders for the upper volumes and were not run.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Qi Refining | 3 | Even Step | Common | Learning to count. Longer Breath at layer 3 |
| Foundation Establishment | 4 | Even Step, Shifted Pole, Setting Down, Home Road | Common | The defining loadout |
| Core Formation | 5 | As above, with Over the Ridge | Common | Run early in the realm: Volume II at 9, Volume III at 4 |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Sect-issue sword | Artifact, weapon | Phi Kiếm, Phàm phẩm, Pháp bảo | L3 30. 60 thần thức | Fits today |
| Two sect-issue shields | Artifact, ward | Thuẫn, Hạ phẩm, Pháp bảo | `a_w` 0.91, so ws and we +27. 45 thần thức each | Fits today |
| Common ward | Warding spell | Pass 0.54 body, 0.36 qi | Drain model, left on | Fits today |
| Iron-Sand Hand Bath | Coating | Reused | L4 on body hits, the night before a trial | Needs key |

Thần thức: 150 of 150 at soul strength 50. The sword is the only weapon a disciple is given, and they are told why.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Ward efficiency | +48 | Feeds the lead twice, through drain and through Thrift | Fits today |
| 2 | Damage | +40 | The ordinary stack | Fits today |
| 3 | Linh lực regeneration | +1 | Small, and it counts toward the lead | Fits today |

Ward strength gets no tree points. No cluster is needed, on purpose.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | One art and a count | Longer Breath | Sings on the road with the others |
| Foundation Establishment | The full drill | Thrift, Setting Down | Told to stop raising their ward |
| Core Formation | The same drill, one heavier blow | Over the Ridge, Volume III | Sets down the first manual, and keeps it |
| Nascent Soul and above | Not run | Second Wind | Loses to younger people from richer sects, and teaches anyway |

## Matchups

All at Foundation Establishment, on the mixed enemy's stats, one file each. "On" counts hits with Longer Breath active.

| Enemy | Result | Why | File |
|---|---|---|---|
| Mixed, same realm | Wins at 4 s, 21 % health, on 6 of 11 | The drill works | `variants/long-carry-mixed.fight.json` |
| Mixed, one realm up | **Loses at 2 s, enemy on 95 %, on 0 of 5** | The honest loss | same file, `--gap 1` |
| Top-end, same realm | Loses at 1 s | As it should | same file, `--enemy top_end` |
| Poisoner | Wins at 5 s, 32 % health | Ticks skip the ward, so the pool stays up | `variants/long-carry-poisoner.fight.json` |
| Miser, one cheap art | Wins at 5 s, 45 % health | A slow enemy is still drained by hits | `variants/long-carry-miser.fight.json` |
| Thể tu, ward off | Loses at 5 s, enemy on 37 %, on 0 of 13 | A pool that blocks nothing never falls | `variants/long-carry-thetu.fight.json` |
| High ward efficiency | Loses at 5 s, enemy on 34 %, on 0 of 13 | Beaten at its own game | `variants/long-carry-warded.fight.json` |
| Per-hit ward | Loses at 5 s, enemy on 59 %, on 0 of 13 | Drain does nothing to it | `variants/long-carry-perhit.fight.json` |
| Drainer | Loses at 7 s, enemy on 21 %, on 3 of 14 | It takes the lead away | `variants/long-carry-drainer.fight.json` |

**Counter:** anyone whose pool does not fall. A thể tu, a per-hit ward or a hard drainer turns Longer Breath off, and the rest of the build is below a typical cultivator.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Four volumes inside budget (above). Three arts at the lint. 4 of 4 slots. 150 of 150 thần thức |
| Validity | PASS | Body techniques with `names: []`. Tier `max_realm` reaches each volume's span. Common ward values from Combat Formulas D |
| Stack | PASS | Five forms. Every rung filled or named. `--without "Longer Breath"` turns a win into a loss |
| Scaling | PASS | `m_static` 1.82 against typical 4.19: below the anchor, and the stated power is ordinary |
| The fight | PASS | Against the mixed enemy the condition starts off and is on for 6 of 11 hits. No Combat cap is hit. Home Road is unmodelled but is not the engine |
| Reuse | PASS | Sustained Note and Iron-Sand Hand Bath reused. Both new modifiers have second homes |
| NPC use | PASS | Fixed slot order, and one Breakdown line per modifier. It suits a sect template |
| Counterplay | PASS | Thể tu, per-hit ward, drainer |
| Originality | PASS | No names from existing works |

## Fight Results

Input: `sheets/long-carry.fight.json`. Observations from `fight_x.py`, a paper model, not the game. Plug-ins: `breath_lead`, `ward_thrift`, `per_cap`.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 37 % health | 3 s | never | none |
| typical | 1 | Loss, enemy on 94 % | 2 s | | none |
| typical | 2 | Loss, enemy on 99 % | 1 s | | none |
| top_end | 0, 1, 2 | Loss | 1 s | | none |

The fixture bankrupts itself, so the mixed runs are the real evidence.

| Run, on `variants/long-carry-mixed.fight.json` unless named | Result |
|---|---|
| As built | Win at 4 s, own 21 % health, 3 % linh lực |
| `--without "Longer Breath"` | Loss at 6 s, enemy on 3 % |
| `--without ward_thrift` | Loss at 6 s, a double knockout lost on overkill |
| Blind, no Hand Bath, `variants/long-carry-blind.fight.json` | Win at 6 s on overkill, both sides at 0: a coin toss |
| Ill-supplied disciple, `variants/long-carry-dull.fight.json` | Loss at 5 s, enemy on 19 % |
| Core Formation, `variants/long-carry-core.fight.json` | Win at 4 s, own 34 % health |
| Core Formation, `--gap 1` | Loss at 2 s, enemy on 95 % |
| Core Formation, `--without "Longer Breath"` | Win at 4 s, own 21 %: at this realm it is margin, not the result |
| Core Formation, `--without ward_thrift` | Win at 5 s, own 8 % |

**Unmodelled:** Home Road, so every loss is shown as a death, and whether a bearer actually gets home is untested. The mass-battle rating was not run.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Longer Breath | Needs key | A "while" condition comparing the two sides' linh lực shares. It is a modifier condition, not an art guard, so rule 13's guard vocabulary is untouched |
| Thrift | Needs key | One compile-time line: `art_cost_pct` += share × `ward_efficiency_pct` |
| Sustained Note, Iron-Sand Hand Bath | Needs key | As in their first builds |
| Four volumes, five arts | Needs key | Ability records, and `t_b` on a body technique |

## Questions for the User

- Should raising a drain ward's strength be able to lose a fight on its own? Moving 48 points from `we` to `ws` is the difference between a win and a loss with the enemy on 53 %.
- Do two body techniques add their `t_b`? Combat does not say, and the two-basket ladder assumes they do.
- Volume IV's last layer could teach instead of fight: a mastered elder hands a disciple a free layer. That would be this build's one rule ask, so it is left out.

## Also Considered

- **The Drill:** arts switched by guards on the enemy's pool, qi until it breaks and body after. It added a setting, not a decision, so it was cut.
- **Row Planting:** a rice-field rhythm on On the Beat. Warm, but it needs a rule and repeats the Ninth Bell.
