# The Fortieth Breath (Tứ Thập Tức)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "One art that waits the entire fight: a single cut, 40 seconds in the drawing."
> **Direction**: A headsman who never raises a hand. Every basic attack not thrown is added to one cut at t = 40.000, the last instant the rules allow.
> **Realm span**: Foundation Establishment – Deity Transformation · **Power level**: strong, top-end gear wanted · **Use**: player build to aim for, or a feared NPC archetype
> **Fit**: 4 Fits today · 10 Needs key · 6 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled at this realm)

## The Spine

- **The channel:** one art hit, at all five layers. It meets the ward, but it is far too large for a drain ward and it lands on an enemy who has already spent their pool.
- **The enabler:** Withheld Hand. Your basic attack never fires; each one not thrown adds its coefficient to the cut. It closes the only free, guaranteed channel in the game.
- **The loop:** there is none. You stand there for 39 breaths. The enemy does everything.
- **The engine:** a per-hit ward leaves linh lực almost untouched, so regeneration overflows into health, while the enemy burns out on their own arts. By t = 7 they are at 7 % linh lực with no ward left to speak of.
- **The sacrifice:** no second action, no answer to ticks, and no way to stop someone walking away.
- **The arc:** at first the build takes art speed to shorten the reading and survive. At the end it refuses art speed and stands for the full forty, which costs nothing and is the point.

## The Legend

A provincial court once kept a headsman for condemned cultivators. Law required the sentence to be read in full, forty breaths of it, and the condemned were not bound. So the office needed someone who could stand in front of a desperate person, be struck with everything they had left, and not raise a hand until the last word. A headsman who cut early was a murderer. One who raised a hand had lost the right to the cut.

The court is gone. The method survived because its holders kept reading. They are patient and hard to insult, and most have stopped speaking in full sentences. Those who hunt them are the kin of the people they read to, who learned the only safe answer: poison them from far away, or leave before the reading ends.

## How It Fights

The cultivator does nothing. The enemy opens with everything, and the ward takes a fixed sip of linh lực per blow while body guard eats what leaks. Around seven seconds the enemy is spent. For the next half minute only their basic attack lands, and the headsman's unused regeneration quietly closes the wounds. The log reads like a stalemate until the final line.

**The signature moment:** t = 40.000. The fight is one event from a draw, and the first and only attack the headsman makes all fight lands for 9,605 on an enemy one realm above them.

## Enabler

**Withheld Hand (Thu Thủ)**, the keystone of the Standing Post cluster. **Opens:** a coefficient past the art lint, up to about 52. **Closes:** the basic attack, the one thing rule 13 says always runs. If the cut never lands, this build has dealt nothing at all.

The trade is honest. It moves damage rather than creating it: 39 coefficient arrives once instead of 1.0 forty times. Timing is what pays. One realm up the cut lands 9,605 with those 39 points and 1,886 without them (`variants/fortieth-breath-no-hand.fight.json`), so they add 7,719. The same basic attacks thrown deal 728 (`--without withheld_hand`), because the cut lands on an empty ward with every layer switched on.

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | **Withheld Hand (Thu Thủ)** | Your basic attack does not fire. Each time it would, +1.0 `c_art` to your longest-cooldown art until that art fires | Rule swap | art, basic | none | ○ | Sealed cluster keystone | any fist-refusing or one-art build |
| Rate | Art speed (`art_speed_pct`) | The dial: shortens the reading. +21 is a 33 s cut, +60 a 25 s cut | Timing | art | none | ◐ | Tree | every art build, as a plain stat |
| Multiplier | Sword damage | +12 to Sword arts | Increased | art | L1 | ○ | Tree | any Sword build |
| Multiplier | Sustained Note (Dư Âm) | +15 per second of the fight, to +90. **Reused from the Ninth Bell** | Per | art | L2 | ○ | Time Đạo, Rhythm branch | Late Bloom builds |
| Multiplier | Bare Rack (Không Giá) | +15 per empty art slot, on arts | Per | art | L2 | ○ | Sealed cluster notable | any few-art build, Empty Hand builds |
| Multiplier | Artifact attack | +60 from one blade | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Whetstone Water (Ma Thạch Thủy) | +40 to Sword arts, a coating applied in preparation | More | art | L4 | ○ | Coating | any Sword build |
| Multiplier | Bare Vessel (Lộ Đỉnh) | +30 while the enemy is under 5 % linh lực. **Reused from the Burial Shroud**. Lesser grade, +30. The same modifier has a greater grade, +80, in Great Tonic, Remnant Host, Struck Name and Taster's Fever; one size would change fights | Conditional | art | L5 | ○ | Sealed cluster | any ward-breaker |
| Multiplier | Full Sea (Mãn Hải) | +30 while your linh lực is above 80 %. **Catalogue keystone** | Conditional | art | L5 | ○ | Technique | any build that does not spend |
| Certainty | Measured Stroke (Định Trảm) | Arts with an authored cooldown of 20 s or more cannot be evaded and cannot crit | Trade | art | none | ○ | Technique | any very slow art |
| Past the cap | **Final Clause (Mạt Khoản)** | Once a fight, if you would go Down, your longest-cooldown art fires in that instant with what it holds | Trigger | art | none | ○ | Technique | any build that plans a double knockout |
| Fuel | Still Water (Tĩnh Thủy) | Regeneration clipped by a full pool restores health, at half its amount | Overflow | any | none | ○ | Body technique | any Full Sea build |
| Fuel | Regeneration (`linh_luc_regen_pct`) | +6, to the 8 % cap | Flat | any | none | ● | Tree | sustain builds |
| Survival | Standing Verdict (Án Định Hộ) | Per-hit ward, pass 0.30 and 0.20, `hit_cost_share` 0.05 | Rule 22 model | any | none | ○ | Ward | any build that fears big hits |
| Price | Cut Short (Đoản Án) | +1 heart demon after the fight per whole second art speed removed from the reading | Trade | art | none | ○ | Technique | signature |

**Identity piece:** Withheld Hand. Without it, and with the basic attack back (`--without withheld_hand`), one realm up, a knockout at 40 s becomes a stalemate with the enemy on 10 %. With no basic attack either (`variants/fortieth-breath-no-hand.fight.json`), the enemy ends on 42 %.
**Empty rungs:** Reach is a sacrifice: pierce is unneeded at one realm up, and two realms up the build is dead before reach matters. Crit is replaced by Measured Stroke, because a missed cut loses the whole fight and rule 15 wants chance to stay a flavour.

| Layer | Points at Core Formation (the cut, t = 40) | Multiplier | Sources |
|---|---|---|---|
| L1 | 12 | ×1.12 | Sword damage only. All W goes to defence |
| L2 | 150 | ×2.50 | Sustained Note 90, Bare Rack 60 (four empty slots) |
| L3 | 60 | ×1.60 | One blade |
| L4 | 40 | ×1.40 | Whetstone Water; a blind fight loses it |
| L5 | 60 | ×1.60 | Bare Vessel, Full Sea |

M for the cut is about 10. `m_static` prints 1.60 because only gear is channel-wide.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal | Sword tags and the method's element |
| Key talents | Physique, then Dao heart | Health and body guard, and heart demon pays for any shortened reading |
| W at Core Formation | Health 40 %, ward strength 25 %, efficiency 10 %, regeneration 11 %, body guard 4.5 %, attack 0 | Every point of offence is on the art, so `attack_pct` is worth nothing here |
| The Way (Đạo) | Time, Rhythm branch (ledger proposal) | Holds Sustained Note |

## Công Pháp

### Forty-Breath Sentence (Tứ Thập Tức Án Kinh) — main, Thiên giai

The court's own text. Half of it is a form of words.

```json
{"id": "tu_thap_tuc_an_kinh", "name": "Tứ Thập Tức Án Kinh", "tier": 3, "tech_kind": "main",
 "names": ["kim"], "layers": 15,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "defense_pct", "value": 15},
             {"stat": "tam_ma_resist_pct", "value": 10}],
 "abilities": [{"ability_id": "last_word", "unlock_layer": 5},
               {"ability_id": "measured_stroke", "unlock_layer": 9},
               {"ability_id": "final_clause", "unlock_layer": 13}],
 "seal_clusters": ["tram_trang"], "origin": "authored"}
```

**Fit:** Needs key (abilities; `seal_clusters` is unread today) · **Budget:** 15/15 + 15/15 + 10/15 = 2.67 of 4.0, each under the single cap

### Block-Stone Method (Châm Thạch Công) — body, Thiên giai

The chopping block is struck ten thousand times and does not complain. Gives `t_b` 3 and Still Water.

```json
{"id": "cham_thach_cong", "name": "Châm Thạch Công", "tier": 3, "tech_kind": "body",
 "names": [], "layers": 15,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "defense_pct", "value": 10}],
 "abilities": [{"ability_id": "still_water", "unlock_layer": 6}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 15/15 + 10/15 = 1.67 of 4.0

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Last Word (Mạt Tự) | Sentence, 5 | body, Sword, Metal | 13.75 + withheld | 0.25 | 40 s | none | Needs rule |

**Effect:** one hit. 13.75 is exactly the lint at cost 0.25 and 40 s, though 40 s is above the 30 s in Formulas A2. In hit order an art precedes the basic attack, so 39 are withheld at 40.000, and the fortieth breath is the cut itself. **Description:** the last character of the sentence.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Core Formation | 5 | Last Word, four empty | Standing Verdict | An empty slot is worth +15. A cleanse costs that, and the player may want to pay it |
| Nascent Soul | 6 | Last Word, five empty | Standing Verdict | Bare Rack reaches +75 |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Any blade | Artifact, weapon | `phi_kiem`, generated | Fills L3 and carries the Sword tag | Fits today |
| Body armour | Artifact, body | `giap` and `thuan`, top grade, body tag | `a_b` 5. With `a_b` 1 the build falls at 35 s one realm up (`variants/fortieth-breath-ab-1.fight.json`) | Fits today |
| Whetstone Water | Coating, preparation | new | Fills L4 | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Standing Post cluster | Sealed | Withheld Hand, Bare Rack | Needs key; its keystone needs a rule |
| 2 | Maximum health, ward strength | Notables | The wall | Fits today |
| 3 | Regeneration | To the cap | Fuels Still Water | Fits today |

### Hidden cluster idea: Standing Post (Trạm Trang)

Theme: body refinement, the stillness a body technique trains. Metal affinity, outer, sealed. Seal condition: a technique that lists it, here the Forty-Breath Sentence. Size 10, so 2 notables at `huyet_per_notable` 5, and it may carry a capability. The small acupoints give health, body guard and a little regeneration. The notables are Bare Rack and, farthest from the entry, Withheld Hand as the capability. A fist saint would come here for Bare Rack and stop short of the keystone.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | A slow, frightened wall with art speed on the dial | Last Word, 25 s draw | Reading to someone for the first time, and hurrying it |
| Core Formation | The full forty, one realm up | Withheld Hand | The first fight that ends with no blow thrown before the last |
| Nascent Soul | Unbothered: 72 % health left one realm up | Final Clause | People start leaving before the end. Now they have to be found first |
| Deity Transformation | The office, with no court | More empty slots | Nobody is left who remembers what the sentence was for |

## Matchups

Core Formation. Each row is read from `--matrix` on the file named, in `variants/` unless it says `main`, which is `sheets/fortieth-breath.fight.json`.

| Enemy | Result | Why | File |
|---|---|---|---|
| Typical, same realm | Wins at 40 s, 99 % health | Health back to nearly full before the cut | main |
| Typical, one realm up | Wins at 40 s, 40 % health | The defining fight, and it rests on Still Water: `--without still_water` dies at 34 s (surprise 2) | main |
| Typical, two realms up | Loses at 7 s | Still Water healed only 2 % in time. Final Clause leaves them on 83 % | main; `fortieth-breath-final-clause.fight.json` |
| Top-end, same realm | Loses at 2 s, enemy on 79 % even with Final Clause | Not chased | `fortieth-breath-final-clause.fight.json` |
| Flurry of four 1 s arts, same realm | Wins, 53 % health | The per-hit ward's weakness, but the enemy runs dry first. One realm up it loses at 11 s | `fortieth-breath-flurry.fight.json` |
| Soul art, 3 s, share 0.05, same realm | Wins, 54 % health | Soul skips everything and hurts. One realm up it wins on 5 % | `fortieth-breath-soul-arts.fight.json` |
| Boss, ×8 pools, same realm | Wins at 40 s | The cut still lands for 9,787. One realm up it lands 3,758: a stalemate, boss on 86 % | `fortieth-breath-boss-x8.fight.json` |
| **Poisoner, same realm** | **Loses at 23 s** | Ticks skip the ward. Regeneration cannot keep up, and the build has no cleanse | `fortieth-breath-poisoner.fight.json` |
| **Per-hit fortress, ws 400, same realm** | **Stalemate, enemy on 32 %** | Its own ward model takes the cut's share away. Two headsmen read at each other all day | `fortieth-breath-fortress.fight.json` |

**Counter:** a poisoner (rule 18's over-time attacker), or anyone with an escape art, since flight ends the fight before the last word and the cut is never thrown.

## Checks

Each result is PASS, FAIL or NOT ASSESSED, with the reason.

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Techniques 2.67 and 1.67 of 4.0, Last Word inside the lint at 13.75, slots 1 of 5. Withheld Hand takes the cut to 52.75 at run time, deliberately over the lint: a Needs rule item below. Thần thức not totalled |
| Validity | PASS | `kim`, `thien`, `phi_kiem`, `giap`, `thuan` are real; Thiên giai reaches Deity Transformation; a body technique names no element, so harmony is neutral |
| Stack | PASS | Nine forms. Every rung filled or named. Identity test: `--without withheld_hand` turns the win one realm up into a stalemate, enemy on 10 % |
| Scaling | PASS | Cut M about 10, above typical 5.48, far below top-end 210. Stated level is strong, and it beats one realm up, with Still Water |
| The fight | PASS | Constants 60 of 60, selftest clean. The cut fires at 40.000 and resolves; no cap hit. `rules/withheld_hand.py`, `rules/still_water.py` and `rules/final_clause.py` run the rule-benders, so nothing stands in for them |
| Reuse | PASS | Bare Vessel, Sustained Note, the Rhythm branch and the catalogue's Full Sea. One signature modifier, Cut Short |
| NPC use | PASS | All static choices; an NPC simply takes no art speed. Breakdown line: "Withheld 39: +39.0 coefficient" |
| Counterplay | PASS | Poisoner, escape, per-hit fortress, any high burst |
| Originality | PASS | Structure from the idea of a reading of a sentence; no borrowed names |

## Fight Results

Input: `sheets/fortieth-breath.fight.json`, rules `withheld_hand`, `still_water` and `per_cap`. Observations from `_tools/fight_x.py`, a paper model with expected values for chance, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 99 % health | 40 s | never | none |
| typical | 1 | Win, 40 % health | 40 s | never | none |
| typical | 2 | Loss, enemy on 100 % | 7 s | never | none |
| top_end | 0 | Loss, enemy on 100 % | 2 s | never | none |
| top_end | 1, 2 | Loss, enemy on 100 % | 1 s | never | none |

**What the repair changed.** The first pass ran the cut as two hits in one instant. The second one met an enemy the first had just emptied, so it dodged the ward. As one hit, which is what the rule says, the cut is smaller than first written: the numbers above and in the signature moment. No fight changed result. A real Still Water replaces `start_health` 1.55, and Sustained Note now ramps to its cap, so it counts in a Final Clause fired early.

**The surprises.**

1. **The ward model is the build.** Same stats on a common drain ward: dead at 31 s to an equal enemy and 4 s one realm up (`variants/fortieth-breath-common-ward.fight.json`). On the per-hit ward, own linh lực sits at 93 to 97 % all fight (`--gap 1 --timeline`). The plan treated linh lực as the thing that ran out, and it barely moves, so Still Water took over the fuel rung.
2. **Overkill is not waste.** The cut lands 11,616 on an equal enemy with 1,041 maximum health. Rule 10 settles a double knockout by overkill share, so Final Clause turns that surplus into wins. With no Still Water at all, the build dies at 34 s one realm up (`--without still_water`), and with Final Clause the same fight is a double knockout it wins, left at 1 health (`variants/fortieth-breath-final-clause-no-still-water.fight.json`). Killing the headsman is what fires the cut.
3. **Art speed is a real dial.** With no Still Water one realm up, the full forty dies at 34 s, a 33 s cut wins on 4 % health (`variants/fortieth-breath-speed-21.fight.json`), and a 25 s cut wins on 22 % (`variants/fortieth-breath-speed-60.fight.json`).

**Other realms.** Foundation Establishment, on a 25 s draw, wins at 95 % and, one up, 15 %; top-end kills it at 1 s (`variants/fortieth-breath-foundation.fight.json`). Nascent Soul with Final Clause wins at 100 % and, one up, 72 %; top-end kills it at 2 s (`variants/fortieth-breath-nascent.fight.json`). Their stats are a first guess. A blind fight, losing L4, still wins one realm up (`variants/fortieth-breath-blind.fight.json`).

**Unmodelled:** Cut Short sits outside the fight. Escape is not simulated. Measured Stroke is `accuracy_pct` 40, which equals `evade_cap`, so no evade touches the cut.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Withheld Hand | Needs rule | Combat rule 13: the basic attack "always runs" gains one exception; Formulas C: `c_art` may pass the lint through this source. Deliberately over the lint: Last Word is 13.75 at the lint, and the 39 withheld take it to 52.75, because passing the lint is what the keystone sells and the basic attack it gives up is the price |
| Last Word | Needs rule | Formulas A2: cooldown range to 40 s, or a stated exception |
| Final Clause | Needs rule | Combat rule 10: a step between the last hit and the defeat check |
| Still Water | Needs rule | Combat rule 11 and Pulse: clipped regeneration is measured and can restore health |
| Measured Stroke | Needs rule | Formulas C: the evade roll skips on an authored-cooldown condition |
| Cut Short | Needs rule | Combat rule 14: a result line reporting the shortened seconds, for the caller to apply |
| Bare Rack, Whetstone Water, Full Sea, Sword damage, Sustained Note, Bare Vessel | Needs key | Tagged and per-slot modifier keys |
| Standing Verdict | Needs key | A ward record; the model exists in rule 22, the data file does not |
| Two techniques, Standing Post | Needs key | Ability catalogue, `seal_clusters` |

**Questions for the user.** Should any keystone be able to switch off the always-on basic attack? Is a per-hit ward meant to be this much better than a drain ward against ordinary enemies? Pass 0.30 at `hit_cost_share` 0.05 is inside Combat's ranges and decides this whole build. Is winning a double knockout through Final Clause acceptable, given that it asks an NPC to avoid landing the killing blow, which NPCs cannot choose?

## Also Considered

- **The Long Draw:** the cut's timer carries between fights, so a sword is drawn over a whole life; broke rule 1's atomic fight for less payoff.
- **The Loaded Scabbard:** blocked damage is stored in the blade (Mirror Ward), which reads as a mirror build and overlaps seed 34.
