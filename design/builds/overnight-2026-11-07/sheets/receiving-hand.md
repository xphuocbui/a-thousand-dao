# The Receiving Hand (Tiếp Sinh Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The basic attack as the whole build: empty art slots are the resource, a fist saint with no arts."
> **Direction**: The seed made empty slots a bonus to the punch. The stronger idea makes them a resource you actually spend: each one catches an enemy art whole.
> **Realm span**: Foundation Establishment – Deity Transformation · **Power level**: top-end against art users, ordinary otherwise · **Use**: player build, or a sect of unarmed gatekeepers
> **Fit**: 6 Fits today · 12 Needs key · 4 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: thần thức not totalled; Reuse depends on a reading of Combat rule 13)
> **Repair**: Catching Hand, Returned Force, Hollow Palm and Sustained Note's cap now run as plug-ins, with no stand-ins. What changed: without catches one realm up the enemy ends on 69 %, not 40 %; Sustained Note is worth less than claimed; the ×4 boss surprise was wrong and is gone; heavy wards no longer slow the build; Foundation and Nascent Soul moved. Shaped enemies were rebuilt, because wave 1 kept no input.

## The Spine

- **The channel:** the basic attack, on all five layers, through the ward. No crit.
- **The enabler:** Vow of the Open Hand. Opens empty slots as a spendable resource. Closes every slot that ever holds an art again.
- **The loop:** stand with empty hands. The enemy's arts fire, cost them, and land on nothing. The fist lands once a second.
- **The engine:** a caught art is still paid for. The enemy spends its ward on hits that never arrive, the build spends nothing, and when the catches run out the enemy has no linh lực and no ward.
- **The sacrifice:** no arts, no escape, no talisman, no slotted ward art, ever. It has no answer to anything that is not an art.
- **The arc:** every breakthrough offers a new slot and a new art to put in it. The player keeps refusing, and each refusal is one more thing they can catch.

## The Legend

In the flood valleys the midwives kept one rule above the others: when a birth is coming, hold nothing. Their breathing method was made to keep a tired pair of hands steady through a three-day labour. It was never a fighting art. It became one on the day a sect's tax collector struck at a midwife in a doorway and the blow simply did not arrive.

The sects call the method a heresy, because it makes an art-user's whole life of study worth nothing for five seconds, and five seconds is enough. Those who walk it stop carrying things: tools, keepsakes, in the end most of their friends. Nobody who has seen one of them standing in a road with open palms has ever been sure whether to be afraid.

## How It Fights

Nothing happens, and it costs the enemy everything. Their arts fire on time and fall into open hands, and each caught art comes back in the next punch. The fist lands every second, exactly on the pulse, without paying a thing.

**The signature moment:** a Nascent Soul cultivator opens with everything they have, at full cost, and none of it lands. Three seconds later they have no ward and no arts, and at four a Core Formation midwife ends it.

## Enabler

**Vow of the Open Hand (Khai Thủ Thệ)**, keystone of the Way of the Bare Hand. Slot bender.

- **Opens:** Catching Hand holds one catch per empty slot, not one in all. Empty Hand counts every empty slot.
- **Closes:** after the Vow, any slot that holds an art, talisman, escape or ward art is **stained** for the rest of this life and never counts as empty again, even when cleared. Slots gained at later breakthroughs arrive clean.
- **Found:** a Dao keystone, at least 9 nodes and 27 points in. The Vow reads forward from the day it is sworn, so a past of ordinary art use is forgiven and a single moment of panic later is not.

## The Stack

Sizes on new modifiers are first guesses. A forced push replaced the plain rungs: the first draft was a flat fist stack, and Catching Hand, Returned Force and Ten Thousand Strikes came from that push.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Ten Thousand Strikes (Vạn Kích) | +0.1 to the basic attack's coefficient per power of ten of basic attacks landed this life, up to +0.7 (+0.3 here) | Flat base | basic | none | ○ | Sealed cluster | any Elemental Fist build |
| Base | Returned Force (Hoàn Lực) | A caught art adds half its `c_art` to your next basic attack's coefficient | Borrow | basic | none | ○ | Đạo | any build holding one catch |
| Rate | None | A faster basic attack would leave the pulse and lose On the Beat | | | | | | |
| Multiplier | Damage (`attack_pct`) | +134 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Basic attack damage | +40 | Increased | basic | L1 | ○ | Tree, Đạo | **Catalogue row** |
| Multiplier | Empty Hand (Không Thủ) | +35 points to basic attacks per empty art slot | Per | basic | L2 | ○ | Đạo | **Catalogue keystone** |
| Multiplier | Sustained Note (Dư Âm) | +15 points per second of the fight, up to +90 | Per | art, basic | L2 | ○ | Way, as in the pilot | **Reused from the Ninth Bell** |
| Multiplier | Artifact attack | +60 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Iron-Sand Hand Bath (Thiết Sa Dục Thủ) | +25 points to body hits, prepared | More | basic, art | L4 | ○ | Preparation | any thể tu |
| Multiplier | On the Beat (Hợp Tiết) | +70 points to an art that fires in the same millisecond as a pulse | Conditional | art, basic | L5 | ○ | Sealed cluster | **Reused from the Ninth Bell** |
| Multiplier | Bare Vessel (Lộ Đỉnh) | +30 points to hits while the enemy has under 5 % linh lực. Lesser grade, +30. The same modifier has a greater grade, +80, in Great Tonic, Remnant Host, Struck Name and Taster's Fever; one size would change fights | Conditional | art, basic | L5 | ○ | Sealed cluster | **Reused from both pilots** |
| Reach | Hollow Palm (Không Chưởng) | 50 % of a basic attack becomes qi, keeping its body tags | Conversion | basic | rule 6 | ○ | Đạo | any body build short of ward-breaking |
| Reach | Realm pierce (`pierce_pct`) | +15 | Flat | any | none | ● | Tree | any realm-crosser |
| Past the cap | Art slot (`bonus_slots`) | +1 slot, left empty: one more catch | Cap shift | any | none | ◐ | Rare one-off | **Catalogue row** |
| Survival | Body guard, health | `t_b` 2.0, `body_guard_pct` +60, `n_body` 1.75 | Flat | any | none | ● | Technique, Tree | any thể tu |
| Identity | **Catching Hand (Tiếp Thủ)** | Each empty art slot catches one enemy art hit per fight: the art fires and pays, and its hit deals nothing and drains nothing | Trigger | any | none | ○ | Đạo | any art build that leaves one slot open against an opening strike |

**Identity piece:** Catching Hand. It takes nothing from the enemy directly. It lets them finish ruining themselves. One realm up, without it the build loses at 3 s with the enemy on 69 %. With it the build wins at 4 s on 60 % health.

**The surprise, on Rule 13:** Combat gives the basic attack the `art` tag and a timer of exactly one pulse. So On the Beat, which the Ninth Bell spends a lifetime tuning art speed to reach, is always true for a fist. Nothing here was designed to do that; it is how the two rules read together.

**A claim that did not survive:** this sheet used to say that against a ×4 boss, removing Sustained Note shortened the fight from 5 s to 4 s. With the catch as a real rule it does the opposite: the same-realm boss falls at 4 s with it and 5 s without. More damage simply helps.

**Empty rungs:** Rate is a sacrifice. Crit is a sacrifice: On the Beat is the certainty that replaces it. Fuel is the build's point: it has no costs to fund, so the rung is empty and regeneration serves only the ward.

| Layer | Points at Core Formation | Multiplier | Sources |
|---|---|---|---|
| L1 | 174 | ×2.74 | `attack_pct`, Basic attack damage |
| L2 | 190 at t = 1, 250 at t = 5 | ×2.9 to ×3.5 | Empty Hand 175, Sustained Note |
| L3 | 60 | ×1.60 | Gear |
| L4 | 25 | ×1.25 | Hand bath; a blind fight loses it (`variants/receiving-hand-blind.fight.json`) |
| L5 | 70 to 100 | ×1.7 to ×2.0 | On the Beat, Bare Vessel once the enemy is dry |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any. Earth suits the life | The Way asks for a technique, not an element, so the worst root in the world can walk this |
| Key talents | Physique (căn cốt) | Feeds `n_body` and the guard |
| The Way (Đạo) | Way of the Bare Hand, then Time (Rhythm branch) | The first holds the enabler and the identity piece, the second holds Sustained Note |

## Công Pháp

### Waiting Hands Method (Đãi Thủ Pháp) — body, Thiên giai

A breathing method for a three-day labour. It teaches nothing to do, only how to stay ready.

```json
{"id": "dai_thu_phap", "name": "Đãi Thủ Pháp", "tier": 3, "tech_kind": "body",
 "names": [], "layers": 15,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "attack_pct", "value": 12},
             {"stat": "tam_ma_resist_pct", "value": 10}],
 "abilities": [], "seal_clusters": ["callus_road"], "origin": "authored"}
```

**Fit:** Needs key (`seal_clusters` is unread today) · **Budget:** 15/15 + 12/15 + 10/15 = 2.47 of 4, each under the 1.5 single cap. `abilities` is empty on purpose: a top-tier manual with no arts in it, which is also the only kind the game ships today.

The main technique can be anything. Its arts stay unslotted.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Empty | Common | 4 catches |
| Core Formation | 5 | Empty | Common | 5 catches, L2 +175 |
| Nascent Soul | 6 | Empty | Common | 6 catches |
| Deity Transformation | 7 | Empty | Common | 7 catches; L2 reaches its cap of 300 near t = 4 by arithmetic |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Knuckle Wraps (Triền Thủ) | Artifact, weapon | New base: attack 20, defence 10, thần thức 10 | L3 without carrying anything, which is why the Vow allows it. Linen boiled in a birthing house | Needs key |
| Any bell or shield | Artifact, ward | `chuong` or `thuan`, generated | The pool is never spent, so ward gear pays in full | Fits today |
| Iron-Sand Hand Bath | Preparation | New coating | Fills L4 | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Callus Road | Sealed cluster | Ten Thousand Strikes, On the Beat | Needs key |
| 2 | `attack_pct`, Basic attack damage | Notables | The stack | Fits today, Needs key |
| 3 | `body_guard_pct`, `khi_huyet_pct` | Notables | Enemy basic attacks are never caught | Fits today |

### Hidden cluster idea: Callus Road (Kiển Lộ)

Theme: body cultivation (luyện thể), the slow hardening of flesh, wider than any one build. Earth affinity, outer, sealed. Seal condition: a technique that lists it. Size 7. Small acupoints give Basic attack damage and body guard. Notables: Ten Thousand Strikes, and On the Beat or Bare Vessel for a character who has not found Measured Breath or Sick Meridians.

## Đạo

**Way of the Bare Hand (Xích Thủ Đạo), proposal.** Requirement: holds a `body` technique, no element. `theme_stats`: `body_guard_pct`, `khi_huyet_pct`, `status_resist_pct`, `linh_luc_regen_pct`, and new `basic_attack_pct`. 20 nodes, on the same mix as dao.md Formulas D1's worked example, so 236 W, 11.8 W a node. **It holds no art nodes**, which is the point of it.

| Branch | Nodes, in order | Signature nodes |
|---|---|---|
| **Receiving (Tiếp)**, 6 | guard, Catching Hand, health, Swaddling, resistance, Cut Cord | **Catching Hand** (T2). **Swaddling (Bao Tã)** (T1): a caught art's status or curse is caught too. **Cut Cord (Đoạn Đái)** (T1): each catch restores 1 % of maximum linh lực |
| **Striking (Kích)**, 6 | basic, Ten Thousand Strikes, basic, Hollow Palm, guard, Returned Force | **Hollow Palm** (T2), **Returned Force** (T2), **Ten Thousand Strikes** (T1) |
| **Waiting (Đãi)**, 7 | regeneration, Empty Hand, regeneration, health, Long Labour, resistance, Ready Hands | **Empty Hand** (T2). **Long Labour (Trường Sản)** (T1): vitality lost in a fight falls by a share per empty slot. **Ready Hands (Bị Thủ)** (T1): counts as prepared for the hand bath in an ambush |
| **Keystone** | Vow of the Open Hand | T3 and a 4 W `body_guard_pct` line. With the name hidden, every node is about hands, holding or waiting |

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | A weak brawler who outlasts careless art-users | 4 catches, the Vow | Clearing the slots for the last time, and meaning it |
| Core Formation | Beats most art users one realm up | Returned Force | A sect offers an art as a gift. It stays unopened |
| Nascent Soul | Still wins one realm up, on 63 % health, with first-guess stats | The 6th hand | Hunted by those it left empty |
| Deity Transformation | Same fist, 7 hands | Nothing new | Nothing left to refuse |

## Matchups

Core Formation. Same realm first, then one realm up, each from the named file. Duels are at the same realm only, and their enemies are the pilots' fight files. Poisoner, chaff, bruiser and soul shapes are first guesses, stated in each file.

| Enemy | Result | Why | Input |
|---|---|---|---|
| Typical art user | Wins 2 s; wins 4 s on 60 % | The engine | `sheets/receiving-hand.fight.json` |
| The Ninth Bell (duel) | Wins 2 s on 95 %; with `--without catching_hand`, loses at 2 s, enemy on 48 % | Its opening tolls fall into open hands | `variants/receiving-hand-duel-ninth-bell.fight.json` |
| The Burial Shroud (duel) | Wins 5 s on 55 % | Its aura cannot be caught, and it spends little | `variants/receiving-hand-duel-burial-shroud.fight.json` |
| Poisoner, tick | Wins 3 s; wins 6 s on 4 % | Ticks pass the hands, and this one nearly ends it | `variants/receiving-hand-poisoner.fight.json` |
| Heavy ward (`ws` 200) | Wins 2 s; wins 4 s on 60 % | The same as a plain ward: the enemy's own arts still empty it | `variants/receiving-hand-heavy-ward.fight.json` |
| Chaff art: 0.5 s, cost 0.02 | Wins 2 s; **loses a double knockout at 4 s**, on overkill | Cheap arts burn five catches by 2 s for almost nothing, then the real art lands | `variants/receiving-hand-chaff.fight.json` |
| Bruiser: no arts, a beast | Wins 3 s; **loses 4 s**, enemy on 58 % | Nothing to catch, so nothing spends | `variants/receiving-hand-bruiser.fight.json` |
| Soul art | Wins 2 s; **loses 4.5 s**, enemy on 58 % | Soul skips the catch | `variants/receiving-hand-soul.fight.json` |
| Any top-end | Loses at 1 s, enemy on 92 % or more | Its basic attack alone is enough | `sheets/receiving-hand.fight.json` |
| The Full Price (duel) | Wins 1 s on 95 % | Catches the 45,000-stone Ruinous Offer and throws it back | `variants/receiving-hand-duel-full-price.fight.json` |

**Counter:** an enemy who does not need arts, or who burns the catches on cheap ones first. A beast-master one realm up, or a chaff art in slot one, beats it.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 2.47 of 4 and each value under 1.5; slots 0 of 5; no arts to lint. Thần thức not totalled |
| Validity | PASS | `body` kind, tier 3 `max_realm` is `hoa_than`, real `chuong` and `thuan` bases, real keys except the new ones named |
| Stack | PASS | Nine forms, identity piece, each layer stated; all rungs filled or named. `--without catching_hand` flips one realm up from a win to a loss |
| Scaling | PASS | `m_static` 3.74 reads only the file's fixed layers, against anchors 5.48 and 210. By the layer table above, a fist hit runs at M 27.0 at t = 1 and 38.4 at t = 5, between them |
| The fight | PASS | Constants 60 of 60, selftest clean. Catches fire, the enemy runs dry, the loop happens. Run through `rules/catching_hand.py`, `rules/basic_split.py` and `rules/per_cap.py`, against any enemy shape |
| Reuse | NOT ASSESSED | On the Beat, Sustained Note and Bare Vessel reused unchanged, but the first two reach the basic attack only on a reading of rule 13. Every new piece has a second home |
| NPC use | PASS | A generator can leave slots empty and needs no tuning. One Breakdown line: "caught, 3 of 5 hands used" |
| Counterplay | PASS | Beast-master and chaff enemies win one realm up |
| Originality | PASS | Midwifery as a fighting origin, original names. The catalogue's Empty Hand is the only inherited idea |

## Fight Results

Input: `design/builds/overnight-2026-11-07/sheets/receiving-hand.fight.json`. Observations from `_tools/fight_x.py`, the calculator plus the plug-ins the file lists: a paper model with expected values for chance, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 94 % health left | 2 s | never | none |
| typical | 1 | Win, 60 % health left | 4 s | never | none |
| typical | 2 | Loss, enemy on 89 % | 3 s | 2 s | none |
| top_end | 0 | Loss, enemy on 92 % | 1 s | 1 s | none |
| top_end | 1 | Loss, enemy on 98 % | 1 s | 1 s | none |
| top_end | 2 | Loss, enemy on 100 % | 1 s | 1 s | none |

**What each piece is worth, one realm up** (`--gap 1`, against a win at 4 s on 60 %):

| Removed | Result |
|---|---|
| `--without catching_hand` | Loss at 3 s, enemy on 69 % |
| `--without returned_force` | Win at 5 s on 50 % |
| `--without "Empty Hand"` | Double knockout at 7 s, won on overkill |
| `--without "On the Beat"` | Win at 5 s on 50 % |
| `--without "Sustained Note"` | No change |
| Both of the last two | Win at 6 s on 24 % |
| `--without "Bare Vessel"` | No change here. On `variants/receiving-hand-boss-x2.fight.json`, a ×2 boss one realm up, it turns a 6 s win on 24 % into a double knockout at 7 s, still won on overkill |
| `--without basic_parts` (Hollow Palm) | No change here |

**×4 boss** (`variants/receiving-hand-boss-x4.fight.json`): same realm a win at 4 s on 88 %, and `--without "Sustained Note"` slows it to 5 s on 85 %. One realm up a loss at 7 s, enemy on 44 %.

**Second realm.** These stats are a first guess, because wave 1 kept no input: L1 and L3 scale from the Core Formation file by tree W, and nothing else changes. Foundation, 4 catches (`variants/receiving-hand-foundation.fight.json`): wins one up at 5 s on 63 %. Nascent Soul, 6 catches (`variants/receiving-hand-nascent.fight.json`): wins one up at 3 s on 63 %, and `--without catching_hand` loses that fight at 2 s, enemy on 78 %. Deity Transformation (`variants/receiving-hand-deity.fight.json`): wins at the same realm in 2 s on 90 %.

**Unmodelled:** the Vow's stained slots; Ten Thousand Strikes' count, taken as 1,000 hits; `bonus_slots` in Empty Hand. All are listed in the fight file. Removed from this sheet because nothing saved could reproduce them: the all-qi Hollow Palm bracket and the old Burial Shroud run without Returned Force.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Catching Hand | Needs rule | Combat rule 9: a trigger that voids a hit before the ward, and rule 10: where it sits in the hit order. Limited to hits from arts |
| Returned Force | Needs rule | Combat rule 13: the basic attack's coefficient may change for one firing |
| Vow of the Open Hand | Needs rule | Combat rule 13 and Save/Load: a per-slot `stained` flag on the character |
| On the Beat | Needs rule | As in the Ninth Bell, and a ruling on the basic attack |
| Basic attack damage, Empty Hand, Sustained Note, Bare Vessel | Needs key | Tagged and per-slot modifier keys; `basic_attack_pct` |
| Ten Thousand Strikes | Needs key | A lifetime count of basic attacks landed |
| Hollow Palm | Needs key | A conversion on the basic attack (rule 6) |
| Iron-Sand Hand Bath, Knuckle Wraps | Needs key | A coating entry and an artifact base |
| Art slot | Needs key | Combat's `bonus_slots` |
| Waiting Hands Method, Callus Road, Way of the Bare Hand | Needs key | `seal_clusters`, a cluster idea, and a Đạo as data |

## Questions for the User

1. Rule 13 tags the basic attack `art`. Should "art" modifiers reach it? If yes, On the Beat is always true for every basic attack in the game. If no, this build still wins one realm up, at 6 s on 24 %.
2. Is a stained slot too cold, or the right kind of cold?

## Also Considered

- **Broken Thought:** hits push the enemy's art timers back. Rejected: a slowed enemy spends less and keeps its ward, which works against the engine.
- **The Plain Fist:** Empty Hand and a stack, nothing else. It works, and it is the safe, literal reading of the seed.
