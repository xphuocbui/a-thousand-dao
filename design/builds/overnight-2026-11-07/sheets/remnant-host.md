# The Remnant Host (Tàn Binh Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Every equipped artifact fights on its own timer: an artifact swarm limited only by thần thức."
> **Direction**: The seed, sharpened. Thần thức left unused is the swarm's speed, so a swarm is sized, never maxed
> **Realm span**: Foundation Establishment – Nascent Soul · **Power level**: top-end, which here means it trades with a same-realm top-end: it loses that double knockout on overkill at 1 s, and a blind fight leaves that enemy on 45 % · **Use**: player build to aim for
> **Fit**: 6 Fits today · 9 Needs key · 4 Needs rule
> **Checks**: 9 PASS · 0 FAIL · 0 NOT ASSESSED. Flight, Spare Mind, Overheat, Idle Hands and the thread cut run as plug-ins
> **Repair**: every number now comes from a saved file. What changed: the thread cut is the rule as written, one `soul_lockout`, so it no longer beats a ×2 soul-piercer; that takes ×4 pools or a soul art every second. Without Spare Mind, one realm up is now a loss, not a win. Foundation now wins one realm up. Three `phi_kiem` barely win, rather than lose. Shaped enemies were rebuilt, because wave 1 kept no input.

## The Spine

- **The channel:** flight, a new one. Each equipped piece strikes on its own timer for no linh lực. It uses L1 to L5 and meets evade, ward and body guard, but never crits.
- **The enabler:** the Recall Banner lifts `equip.max_slots` and puts every piece in the air. It closes all artifact defence, and the thần thức in flight stops defending the cultivator.
- **The loop:** nothing. The cultivator stands still with empty art slots and a full pool while needles land twice in the first second.
- **The engine:** the timer. A piece's timer is its weight against thần thức, and Spare Mind divides it by how much thần thức is left free. Every piece added slows every other piece.
- **The sacrifice:** defence and any second plan. If two volleys do not settle it, a thin ward and no arts have to finish a fight they were never built for.
- **The arc:** at first a scavenger drags three bent needles on a thread. Later the same needles, better made, land twelve hits before an elder finishes drawing breath.

## The Legend

Armies lose their weapons where they fall, and weapons are dear. The quartermasters of a dead sect war sewed a banner to call the steel home: plant it on the field, and everything that once answered to a soldier rises and comes in. It was a tool for counting losses. Then one of them pointed it the other way.

Their heirs walk old battlefields. The sects take the swords, so the gleaners take what fell out of them: splinters, pins, the needles from a dead woman's sleeve. Every piece is somebody's. They answer late when spoken to, because half of them is elsewhere, and the families of the dead know exactly what they are carrying.

## How It Fights

The gleaner plants the banner, opens their hands and waits. Six needles leave at once, and half a second later they do it again. The first needles wear the ward down and the last ones land on nothing, because hits in one instant meet the live pool one at a time. **The signature moment:** an ordinary Nascent Soul elder falls at the end of the first second to someone who never moved or spent a point of linh lực.

## Enabler

**Recall Banner (Thu Binh Kỳ).** A named artifact on the `ky` base, Trung phẩm. Found planted in the middle of an old battlefield, where the ground is full of steel that has not quite stopped listening.

- **Opens:** `equip.max_slots` no longer applies; only thần thức limits the set. Each piece flies on its own timer, `20 s × cost / divine_sense`, taking no art slot and no linh lực. Flight hit: `c = min(1.0, attack / (B_p · stage_mult))`, tag `source: artifact`, no crit, can be evaded, counts as direct damage.
- **What a piece does when its timer ends:** weapon role strikes. A `ky` strikes and plants a curse (Standard Planted). Ward role rings, giving Combat's ward trigger: `trig_ward_strength` for `trig_ward_seconds`.
- **Closes:** artifacts give no defence, to ward or body. The thần thức in flight leaves the fight, so the wearer fights on free thần thức alone against soul attacks, which reverses the last line of Combat rule 3 for them. A soul hit cuts the threads: nothing flies for `soul_lockout`.

## The Stack

Sizes on new modifiers are first guesses. Needles only; the banner has no Overheat.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Weapon attack (`artifact_attack_pct`) | Liệt affix, +20 on each needle. It raises the hit and L3 together | Flat | flight | none | ● | Artifact affix | every weapon build |
| Rate | Artifact thần thức cost (`than_thuc_cost_pct`) | Linh affix, −20 on each needle: shorter timer, more thần thức free | Flat | flight | none | ● | Artifact affix | any many-piece set |
| Rate | Thần thức (`than_thuc_pct`) | +65: technique 15, capability #2 20, tree 30 | Flat | flight | none | ● | Technique, tree | soul builds |
| Rate | **Spare Mind (Dư Thần)** | +3 % flight speed per 1 % of thần thức left free | Per | flight | none | ○ | Many Threads | any artifact-active build |
| Multiplier | Damage (`attack_pct`) | +134 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Flown artifact damage | +60 to `source: artifact` hits | Increased | flight | L1 | ○ | Tree | any flying sword build |
| Multiplier | Drilled Ranks (Thao Binh) | +50 to `source: artifact` hits | More | flight | L2 | ○ | Technique | any flying sword build |
| Multiplier | Idle Hands (Nhàn Thủ) | +10 to `source: artifact` hits per empty art slot; +50 with all 5 empty | Per | flight | L2 | ○ | Array Đạo | any no-art build |
| Multiplier | Artifact attack (gear) | 295 raw, clipped to 250 | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Whetstone Ash (Ma Thạch Hôi) | +60 to `source: artifact` hits, prepared | More | flight | L4 | ○ | Coating | any flying sword build |
| Multiplier | Full Sea (Mãn Hải) | +40 while linh lực is above 80 % | Conditional | flight, basic | L5 | ○ catalogue | Tree | any cheap-art build |
| Reach | Standard Planted (Thụ Kỳ) | A `ky` strike applies a curse: ward pass +30 % for 3 pulses | Trigger | flight | none | ○ | Banner rule | any banner set |
| Reach | Bare Vessel (Lộ Đỉnh) | +80 while the enemy has under 5 % linh lực. Greater grade, +80. The same modifier has a lesser grade, +30, in Brush Fee, Fortieth Breath, Receiving Hand and Turned-Away; one size would change fights | Conditional | flight, basic | L5 | ○ ledger | Many Threads | Burial Shroud, Ninth Bell |
| Past the cap | Overheat (Quá Nhiệt) | Each 1 % of speed that `cooldown_min` clips adds 1 point to L5, up to +30 | Overflow | flight | L5 | ○ | Array Đạo | **Reused from The Taster's Fever** |

**Identity piece:** Spare Mind. It turns thần thức nobody saves into the only rate stat. Removing it loses the first-second double volley, and with it the win one realm up.
**Empty rungs:** Crit is a sacrifice: flight never crits. Fuel is empty on purpose: flight is free, which is why Full Sea is nearly always on. Survival is a sacrifice. Past L3's cap needs no modifier: the 45 clipped points still count in each hit's base, so this is the first build that wants attack past that cap.

| Layer | Points at Core Formation (needles) | Multiplier | Sources |
|---|---|---|---|
| L1 | 194 | ×2.94 | `attack_pct`, flown artifact damage |
| L2 | 100 | ×2.00 | Drilled Ranks, Idle Hands |
| L3 | 250 | ×3.50 | Gear, at the cap |
| L4 | 60 | ×1.60 | Whetstone Ash; a blind fight loses it |
| L5 | 65, or 100 at the cap | ×1.65 to ×2.00 | Full Sea, Overheat, Bare Vessel, which clip at 100 together |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal, with Earth to feed it | Element match on needles; Earth generates Metal |
| Key talents | Soul strength (thần hồn) 85 | 850 × 1.65 = 1,400 thần thức at Core Formation, stage 1.00 |
| The Way (Đạo) | Array, Host branch (below) | Holds Idle Hands and Overheat |

## Công Pháp

### Roll-Call Method (Điểm Binh Quyết) — main, Địa giai

A quartermaster's habit of counting what came back, written down as a discipline. It has no art at all.

```json
{"id": "diem_binh_quyet", "name": "Điểm Binh Quyết", "tier": 2, "tech_kind": "main",
 "names": ["kim"], "layers": 12,
 "bonuses": [{"stat": "than_thuc_pct", "value": 15}, {"stat": "khi_huyet_pct", "value": 10},
             {"stat": "linh_luc_pct", "value": 15}],
 "abilities": [], "seal_clusters": ["many_threads"], "origin": "authored"}
```

**Fit:** Needs key (Drilled Ranks has no field; `seal_clusters` is unread today) · **Budget:** 15/15 + 10/15 + 15/20 = 2.42 of 3.0

## Loadout by Realm

The build slots no arts. Numbers are thần thức used of thần thức held.

| Realm | Slots | Pieces in the air | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4, all empty | Banner, 3 needles, 132 of 420 | Common | Needles are tier 1 |
| Core Formation | 5, all empty | Banner, 6 needles, 680 of 1,400 | Common | The defining set: timer 1.143 s, +154 % speed, on the 0.5 s floor |
| Nascent Soul | 6, all empty | Banner, 6 needles, 2,040 of 4,200 | Common | The same shares at tier 3 |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Recall Banner | Artifact, utility | `ky`, Trung phẩm, tier 2 | The enabler, cost 200, c 0.255 | Needs rule |
| Six needles | Artifact, weapon | `cham`, Trung phẩm, tier 2, Liệt +20 and Linh −20 | Cost 80, c 0.449 each. Generated, no uniques | Fits today |
| Whetstone Ash | Coating, preparation | new | L4 for flight | Needs key |

**Why needles.** `cham` has the most attack per thần thức of any base (2.2 against `phi_kiem`'s 1.5), and a light piece also has a short timer. At the same 680 thần thức, three `phi_kiem` of the same grade beat a typical enemy one realm up only at 2.7 s, on under 1 % health (`variants/remnant-host-phi-kiem.fight.json`); six `cham` beat it in 1 s on 50 %.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Many Threads | Sealed cluster | Spare Mind, the whole Rate rung | Needs key |
| 2 | Thần thức notables | +6 each | Reaching the 0.5 s floor | Fits today |
| 3 | Capability #2, Divided Divine Sense | +20 % thần thức | Its slot does nothing here; its thần thức does | Fits today |

### Hidden cluster idea: Many Threads (Thiên Ti Mạch)

Theme: Divine Sense (`than_thuc`). Metal affinity, outer, sealed. Seal: a technique that lists it, for its `seal_seasons`. Size 10, so two notables. Small acupoints give `than_thuc_pct` and `than_thuc_cost_pct`. Notables: Bare Vessel, then Spare Mind at the far end as the cluster's capability. Anyone who runs many pieces wants it, with or without the banner.

## Đạo

**Array, Host branch (proposal).** A branch of the Array Đạo, requirement unchanged. A host is an array that moves. Its passives are Idle Hands and Overheat; its stat lines come from Array's `theme_stats`.

## Progression

Foundation and Nascent Soul rows are `variants/remnant-host-foundation.fight.json` and `variants/remnant-host-nascent.fight.json`. Their stats are a first guess, because wave 1 kept no input: L1 and L3 scale from the Core Formation file by tree W, L3 at most 250.

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | Three needles on a thread: beats a typical enemy in 1 s on 89 %, and one realm up in 2.5 s on 26 % | Recall Banner | Pulling the banner out of the ground, and hearing the field answer |
| Core Formation | Two volleys in the first second | Spare Mind | The first heir who comes asking for a needle by name |
| Nascent Soul | The same, one tier up: typical in 0.5 s, one realm up in 1 s on 39 % | Tier 3 needles | They no longer finish sentences |

## Matchups

All are the build at Core Formation. Enemy shapes are first guesses, stated in each file. Numbers are from `--gap 1` where the row says one realm up.

| Enemy | Result | Why | Input |
|---|---|---|---|
| Typical, same realm | Wins, 0.5 s, untouched | First volley | `sheets/remnant-host.fight.json` |
| Typical, one realm up | Wins, 1 s, 50 % health | Second volley lands in the instant of their first hit | `sheets/remnant-host.fight.json` |
| Armoured beast, one realm up, guard at about the cap | Wins, 2.5 s, 33 % health | `--without "Bare Vessel"` slows it to 3.4 s on 17 % | `variants/remnant-host-armoured.fight.json` |
| Per-hit ward, one realm up | Wins, 1.5 s, 50 % health | Many small hits empty a per-hit ward | `variants/remnant-host-per-hit-ward.fight.json` |
| 40 % evade, one realm up | Wins, 2 s, 33 % health | Expected value: every hit lands at 60 % | `variants/remnant-host-evade-40.fight.json` |
| ×4 pools, same realm | Wins, 1.1 s | | `variants/remnant-host-boss-x4.fight.json` |
| ×4 pools, one realm up | Loses, 3 s, enemy on 20 % | It outlasts the opening and the thin ward fails | `variants/remnant-host-boss-x4.fight.json` |
| Soul-piercer, ×2 pools, one realm up | Wins, 2.5 s, 7 % health, threads cut once at 1.5 s | The cut costs one volley, not the fight | `variants/remnant-host-soul-piercer.fight.json` |
| Soul-piercer, ×2 pools, a soul art every second, one realm up | **Loses a double knockout at 2 s**, on overkill | Cut at 1 s and 2 s | `variants/remnant-host-soul-piercer-fast.fight.json` |
| Soul-piercer, ×4 pools, one realm up | **Loses, 2 s, enemy on 62 %** | Pools to spare | `variants/remnant-host-soul-piercer-x4.fight.json` |
| Top-end, same realm | Double knockout at 1 s, lost on overkill | The elder ends on about 0 health under Combat rule 10 | `sheets/remnant-host.fight.json` |

**Counter:** anything that outlasts the first second and hits back: ×4 pools one realm up, or a soul-piercer with pools to spare. A single thread cut only delays the swarm by a volley.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Technique 2.42 of 3.0. Thần thức 680 of 1,400. Seven pieces is over `equip.max_slots` by design, which the banner lifts. Calculator art lint: all within |
| Validity | PASS | `ky`, `cham`, `trung`, tier 2 at Core Formation, Metal and Earth, `dia` reaches Nascent Soul |
| Stack | PASS | Seven forms: Flat, Per, Increased, More, Conditional, Trigger, Overflow. Rungs filled or named. Identity test changes the fight |
| Scaling | PASS | `m_static` 8.19 holds no tag points; a needle hit runs at about 54 to 66 by the layer table, against anchors of 5.48 and 210. INFO: it trades with a top-end enemy, which is its stated level |
| The fight | PASS | Constants 60 of 60; selftest clean. Flight runs as cost-0 art records through `rules/flight.py`, `rules/spare_mind.py` and `rules/speed_overflow.py`, timed exactly. `layer_5_over_cap` hit in three fights. The stand-ins the wave 1 critic named are gone, which is why this stays PASS; the power claim is corrected in the status line |
| Reuse | PASS | Bare Vessel from the ledger, Full Sea from the catalogue, Overheat from The Taster's Fever. Signature piece: the banner only |
| NPC use | PASS | All passive and compile-time. The generator must pick a piece count, which is one formula; Spare Mind is one Breakdown line |
| Counterplay | PASS | Top-end burst, ×4 pools one realm up and a ×4 soul-piercer win, as above |
| Originality | PASS | The structure is any minion build. Names and the battlefield story are new |

## Fight Results

Input: `sheets/remnant-host.fight.json`. Observations from `_tools/fight_x.py`, the calculator plus the plug-ins the file lists: a paper model, not the game. Top-end at gap 0 reads as a loss with both sides on 0 %.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 100 % health left | 0.5 s | never | L5 |
| typical | 1 | Win, 50 % health left | 1 s | never | L5 |
| typical | 2 | Loss, enemy on 78 % | 1 s | 1 s | none |
| top_end | 0 | Loss on overkill, enemy on 0 % | 1 s | 1 s | L5 |
| top_end | 1 | Loss, enemy on 82 % | 1 s | 1 s | none |
| top_end | 2 | Loss, enemy on 97 % | 1 s | 1 s | none |

**Identity test** (`--without spare_mind`, which also ends Overheat, since nothing is left to clip): typical wins at 1.143 s on 85 % health; one realm up becomes a **loss at 3 s with the enemy on 29 %**; top-end loses with the enemy on 97 % instead of 0 %.

**The surprise.** The swarm has a cliff, not a curve, and it sits at the 0.5 s floor, the only timer that fits two volleys into the first second. Against top-end at the same realm:

| Thần thức, 6 needles | Needle timer | Top-end left on | Input |
|---|---|---|---|
| 1,200 | 0.580 s | 62 % | `variants/remnant-host-thought-1200.fight.json` |
| 1,300 | 0.506 s | 62 % | `variants/remnant-host-thought-1300.fight.json` |
| 1,400 | 0.450 s, floored to 0.5 s | 0 % | `sheets/remnant-host.fight.json` |

| Needles, 1,400 thần thức | On the floor | Top-end left on | Input |
|---|---|---|---|
| 3 | yes | 45 % | `variants/remnant-host-needles-3.fight.json` |
| 4 | yes | 1 % | `variants/remnant-host-needles-4.fight.json` |
| 5 | yes | 0 % | `variants/remnant-host-needles-5.fight.json` |
| 6 | yes | 0 % | `sheets/remnant-host.fight.json` |
| 7 | yes | 0 % | `variants/remnant-host-needles-7.fight.json` |
| 8 | no | 50 % | `variants/remnant-host-needles-8.fight.json` |

So 0.006 s of timer decides the fight, and a seventh needle is the last one worth adding. A blind fight, with no L4, leaves top-end on 45 % (`variants/remnant-host-blind.fight.json`).

**Unmodelled:** flight is written as art records, cost 0, so the slot line in the lint reads them and `bonus_slots` only silences it; the ward ring of a `chuong` or `thuan` is not in this loadout, so it is untested.

## New Concepts

**Flight (ngự bảo).** A new way for damage to arrive, on a timer per piece rather than per art.

- **Rule needed:** Combat rule 13 (a new source outside the art slots), rule 3 (thần thức in flight leaves the fight) and Item Database rule 11 (`equip.max_slots`).
- **Bounds:** thần thức, Spare Mind's trade-off, `cooldown_min`, and the 1.0 cap on `c`, as with companions.
- **Breakdown line:** `Needle 3: flight, 0.5 s, 51 % of thần thức free.`
- **Other builds:** a puppet master, and a shield swarm whose ward role rings on a timer.
- **Question for the user:** should flight stay on one banner, or become a general rule for artifacts with a technique or Đạo gate?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Recall Banner, flight | Needs rule | See New Concepts |
| Spare Mind | Needs rule | A timer rule that reads free thần thức |
| Standard Planted | Needs rule | Curses set by a flight action |
| Overheat | Needs rule | Combat Formulas A2: where speed clipped by `cooldown_min` goes |
| Flown artifact damage, Drilled Ranks, Idle Hands, Whetstone Ash, Full Sea, Bare Vessel | Needs key | Tagged and conditional modifier keys (catalogue, To settle) |
| Roll-Call Method, Many Threads, Array Host branch | Needs key | A modifier field on techniques; `seal_clusters`; Đạo data |

## Also Considered

- **The Bell Line:** every piece a ward-role bell, so defence becomes hits blocked per second against hits taken per second.
- **Slipped Leash:** one relic far too heavy to hold, swung on a thread, with every second swing landing on its owner. Fights end too soon for a slow swing to matter.
