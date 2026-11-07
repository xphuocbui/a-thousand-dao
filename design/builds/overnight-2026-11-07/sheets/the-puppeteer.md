# The Puppeteer (Khiên Ti)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "A puppet master: the body in the fight is not the cultivator's own." Order 4: an artifact that is also a beast record, 3 or more puppets, set in a monastery, faith as the mood.
> **Direction**: The monk's own body stays out of the fight. Three puppets stand in the slot order, and each is one record with two families of tags, so the beast stack and the artifact stack both land on it.
> **Realm span**: Qi Refining – Nascent Soul, defined at Nascent Soul · **Power level**: strong at home and abroad, no answer to a realm above · **Use**: player build, or a mountain monastery nobody should raid
> **Fit**: 4 Fits today · 16 Needs key · 1 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled, because the Puppet Frame's cost is a guess and `than_hon_per_extra_beast` adds 80)

## The Spine

- **The channel:** the companion, on all five layers of the operator's M, with no crit. 85 % of the damage in the mixed fight.
- **The enabler:** Borne Body. The side's health, n_body and guard are the puppet's. The operator's linh lực, ward and arts stay, so rule 11 still binds. It closes the operator's own body, and three art slots.
- **The loop:** the bell rings, the body strikes on the note, and when a body falls the next walks on at full health.
- **The engine:** a puppet is an artifact and a beast at once, so it carries both tag families. Beast rows, companion rows and every artifact-source row a flying-banner build ever wanted all stack on one fist.
- **The sacrifice:** three slots of six, and the body of the one you love most, if you send them. Nothing at all against a realm above.
- **The arc:** at Qi Refining a carved novice that bows. At Core, two bodies. At Nascent Soul the Abbot, who is not spent lightly.

## The Legend

A landslide took Tịnh Căn's legs when they were a child. The old abbot of Vân Đỉnh carried them up the four hundred steps every day for six years, to the hall in the morning and down again at night, and never once spoke of it. They taught Tịnh Căn the Lamp-and-Thread Sutra, a devotion for keeping a lamp lit from across a room, and Tịnh Căn carved a small wooden novice and, one winter, made it bow. When the abbot was dying they asked to be seated in the hall and lacquered in the old way, so that they could stay.

Tịnh Căn does not believe the abbot left. That is not a figure of speech. They kneel at the altar, light the lamp and ask, and they believe they are answered. When men came up the mountain for the monastery's grain, the wooden novice met them on the steps, then the clay guardian from the door. They always send the novice first, though the sums say otherwise, because a chipped novice can be carved again. The Abbot has stood four times in seven years. After each, Tịnh Căn has spent the winter on the cracks, with their own hands, reciting. They light the lamp every morning.

## How It Fights

The Wooden Novice takes the opening. It strikes every 0.625 s for a share of what a true hand would, and the Morning Bell lands in step with every second blow. It falls at 3 s, at the defeat check, on a blow that would have been the same size whatever it hit. In that instant the Clay Guardian walks on at full health with whatever curses and poison the Novice carried left behind, and a store of 15 % of the pool. The enemy has spent three seconds on wood. At 4.875 s it is over, the Guardian on 90 %.

**Signature moment:** abroad, the Clay Guardian cannot leave its door, so the Novice goes down at 3 s on a road far from any altar, and the lacquered figure in the litter stands up. In a little over a second it is finished (`the-puppeteer-abroad`: 4.25 s on 93 %).

## Enabler

**Borne Body (Tá Thể).** Lives on the Lamp-and-Thread Sutra, a main technique, and needs a puppet in the slot order.

- **Opens:** the side's health, n_body and guard come from the first puppet in slot order. Its blow is the companion channel, and the side has no separate basic attack: one body, one fist. When a body falls, the next walks on in the same instant at full health. Statuses and curses on the fallen body fall with it. A puppet's store refills that share of linh lực as it walks on.
- **Closes:** each puppet takes an art slot. Each beyond the first costs `than_hon_per_extra_beast`. The operator's own Physique, body techniques and body guard reach nothing.
- **At home** the operator kneels out of reach, and the last body falling is a loss with no wound. **Abroad** they must be carried within reach, and when the last body falls their own bar stands, n_body 0.6, with no blow.
- **Up the thread:** a soul art does not stop at a puppet. Its health share lands on the operator's own bar, which nothing else can touch while a body stands, and if that empties the thread is cut and the side is Down.

## The Stack

Plain rows do most of the work, on tags that any beast or banner build could want. Sizes on new rows are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Fixed blows | c_comp 0.6, 0.7, 1.0, inside `c_comp_cap` | Flat base | companion | none | ○ | Puppet record | any beast |
| Rate | Companion attack speed | Catalogue row, +60 in all, so a blow every 0.625 s | Increased | companion | none | ○ row | Tree | any beast |
| Multiplier | Companion damage | Catalogue row, +30 | Increased | companion | L1 | ○ row | Tree | any beast |
| Multiplier | Beast damage | Catalogue row, +20 | Increased | companion | L1 | ○ row | Tree | any beast |
| Multiplier | Flown artifact damage | +10, on the artifact source tag | Increased | companion | L1 | ◐ reused | Tree | Remnant Host |
| Multiplier | Damage (`attack_pct`) | Plain, +100 | Increased | any | L1 | ● | Tree | everyone |
| Multiplier | Drilled Ranks (Thao Binh) | +50, on the artifact source tag | More | companion | L2 | ◐ reused | Technique | Remnant Host |
| Multiplier | Whetstone Ash (Ma Thạch Hôi) | +60, on the artifact source tag, prepared | More | companion | L4 | ◐ reused | Coating | Remnant Host |
| Multiplier | Full Trough (Mãn Tào) | +40 at four times the feed due. Here the feed is lacquer and incense | Per | companion | L4 | ◐ reused | Upkeep | Herd-Child |
| Multiplier | In Step (Đồng Bộ) | +50 to a hit landing after one of your arts in the instant | Conditional | companion | L5 | ◐ reused | Tree | Herd-Child |
| Multiplier | Vow Renewed (Trùng Thệ) | +4 small, +25 notable, on companion hits once a body has fallen | Conditional | companion | L5 | ○ | Acupoint, notable | any beast that outlives a keeper, any queue |
| Fuel | Ward efficiency, Maximum linh lực | Plain rows, +80 of 120 and +80 | Increased | any | none | ● | Tree | everyone |
| Survival | Ward strength | Plain row, +80 of 120 | Increased | any | none | ● | Tree | everyone |
| Identity | Borne Body (Tá Thể) | Above | Rule swap | any | none | ○ | Technique | any golem, any possessed relic |

**Identity piece:** Borne Body. Without it (`--without borne_body`) the monk fights on their own legs and is dead at 3 s with the enemy on 85 %. With one body and no queue (`one-body`) it is lost at 3 s with the enemy on 60 %.
**Unplanned reuse:** Drilled Ranks was written for flying banners. A puppet is an artifact, so it reads it. `--without "Drilled Ranks"` turns 4.875 s on 90 % into 6.125 s on 57 %.
**Pairs, removed together:** Whetstone Ash and Full Trough, the whole of L4: 8 s on 31 %. Whetstone Ash alone, which is what a blind fight loses: 6.125 s on 57 %. Morning Bell takes In Step with it: 5.5 s on 80 %. In Step alone: 5.5 s on 86 %. Vow Renewed alone: 5 s on 86 %.
**Empty rungs:** Crit is a sacrifice, since a companion cannot crit. Reach is a gap: no pierce, and that is why a realm above is hopeless.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 160 on the blow | ×2.60 | Damage 100, Companion 30, Beast 20, Flown 10 |
| L2 | 50 | ×1.50 | Drilled Ranks |
| L3 | 60 | ×1.60 | Gear, and the frames themselves |
| L4 | 100 | ×2.00 | Whetstone Ash, Full Trough |
| L5 | up to 75 | up to ×1.75 | In Step, Vow Renewed |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Wood, a plain one | Lacquer and timber. The technique's element |
| Key talents | Soul (thần hồn), for the third body. Physique is dumped | `than_hon_per_extra_beast` is 40 a body. n_body 0.6 is the price of a life in a chair |
| The Way (Đạo) | None | The tree and the bodies carry it |

**Sense:** the operator's `divine_sense` is 1.0, the same as the fixture's, as an assumption. The soul fights type the enemy's in by hand: 2.0 and 3.0. Neither is derived. Fortune is not used.

## Công Pháp

### Lamp-and-Thread Sutra (Đăng Ti Kinh) — main, Địa giai

A devotion for keeping a lamp alight across a room. Nobody who wrote it meant it for this.

```json
{"id": "dang_ti_kinh", "name": "Đăng Ti Kinh", "tier": 2, "tech_kind": "main",
 "names": ["moc"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20}, {"stat": "than_thuc_pct", "value": 15}],
 "abilities": [{"ability_id": "borne_body", "unlock_layer": 1},
               {"ability_id": "morning_bell", "unlock_layer": 3},
               {"ability_id": "binding_sutra", "unlock_layer": 6},
               {"ability_id": "evening_drum", "unlock_layer": 9}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs rule · **Budget:** 20/20 + 15/15 = 2.0 of 3.0, two bonuses, reaches Nascent Soul.

## Arts

| Art | Source, layer | Kind | c_art | Cost | Cooldown | Fit |
|---|---|---|---|---|---|---|
| Morning Bell (Thần Chung) | Layer 3 | Qi | 1.0 | 0.04 | 1.25 s | Needs key |
| Binding Sutra (Phược Kinh) | Layer 6 | Qi | 1.0 | 0.05 | 2.5 s | Needs key |
| Evening Drum (Mộ Cổ) | Layer 9 | Body | 2.6 | 0.08 | 3.75 s | Needs key |

Morning Bell's cooldown is twice the blow's, so every second blow is In Step. **Binding Sutra:** curse, `shred` 0.25 for 3 pulses. All are within the art lint.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation | 4 | Novice, then 3 arts | Common | One body, and no queue. Not a fight file |
| Core Formation | 5 | Novice, Guardian, 3 arts (`core`) | Common | Wins at 5.142 s on 92 % |
| Nascent Soul | 6 | Novice, Guardian, Abbot, 3 arts | Common, ws and we 120 | The home fight |

The common ward stays. The operator's pool holds it up on a body far away, and it runs dry as fast as anyone's.

## Items: The Puppets

Each is one record: an artifact on the new Puppet Frame base, with a grade and an equip slot, and a beast entry with feed, loyalty and a fixed art. A puppet below 60 loyalty does not walk on. Loyalty is `creatures_linh_thu.json`'s own: −25 for a year unfed.

| Puppet | n_body | Guard | Blow | Store | What it is for |
|---|---|---|---|---|---|
| Wooden Novice (Mộc Sa Di) | 0.7 | t_b 0.8 | Body, c 0.6 | none | Cheap, carved in a winter, sent first. Costs nothing to lose |
| Clay Guardian (Nê Hộ Pháp) | 1.2 | t_b 3.0, +20 % | Body, c 0.7 | 15 % | Heavy. It cannot leave its door, so it stays home |
| Lacquered Abbot (Tất Thân Trụ Trì) | 1.0 | t_b 1.5, +20 % | Qi, c 1.0 | 15 % | The strongest blow. Real wounds, mended by hand over a winter |

Puppet Frame (Khôi Giá): new artifact base, attack 20, defence 0, thần thức 30. Guess.

## Slot Order Is a Choice of Faith

Against the mixed enemy, the same three bodies. All files are in `variants/`.

| Order | File | Result | Who took the blows |
|---|---|---|---|
| Novice, Guardian, Abbot | `the-puppeteer-mixed` | 4.875 s on 90 % | Wood fell, clay barely marked |
| Guardian first | `the-puppeteer-clay-first` | 4.375 s on 57 % | The Guardian, nearly half gone |
| Abbot first | `the-puppeteer-abbot-first` | 3.125 s on 60 % | The Abbot, 40 % of the lacquer |

The Abbot first is the best fight by more than a second and a half, and it costs a winter. A player will sit and look at this table. Wounds and repair are outside the fight and unmodelled.

## What the Double Record Breaks

| Rule | The problem | Asked |
|---|---|---|
| Combat rule 19 | "A companion cannot be targeted." Here it is the only target | One exception, in rule 19 |
| Formulas J | `c_comp` is a share of a beast's power. A frame has an attack too. Both are entered | Which feeds what: this sheet says L3 from the frame, c from the beast |
| Item Database rule 6, `equip.max_slots` | A puppet takes an equip slot, a beast slot and here an art slot | Is three the right price? |
| Rule 14 | `wound` belongs to a side. A puppet's wound is not the operator's | Does a body keep its damage between fights? |
| Tag scope | Both families apply, so one fist reads two whole stacks. This is the engine, and it may be too good | Should a record carry one family only? |
| Rule 7 | Is a puppet poisoned? Here it is, and it drops the poison when it falls | Should a body with no blood take a tick at all? |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Mixed, same realm | Wins, 4.875 s on 90 % | The heavy art lands on the wrong body |
| One jab and nothing else (`jab`) | Wins, 5.25 s on 96 % | A cheap art wears wood slowly |
| Abroad, foreseen (`abroad`) | Wins, 4.25 s on 93 % | Two bodies, the operator in reach. Faster, since the Abbot's fist replaces clay's |
| Poisoner, ticks and hits (`poisoner`) | Wins, 5.25 s on 96 % | The rot falls with the Novice. On their own legs: dead at 3 s (`poisoner --without borne_body`) |
| Fast double hitter (`fast`) | Wins, 3.875 s on 82 % | Speed is the honest threat, and the pool ends on 6 % |
| Soul-piercer, sense 2 (`soul`) | Wins, 4.875 s, own bar on 20 % | One more needle and the thread is cut |
| Soul-piercer, sense 3 (`soul-deep`) | Loses at 4 s, enemy on 40 % | Thread cut with a body still on its feet |
| Mixed, one up | Loses at 4 s, enemy on 86 % | All three bodies fall in 2, 3 and 4 s |
| top_end, same realm | Loses at 3 s, enemy on 94 % | One blow, one body, three seconds bought |

**Counter:** a soul-piercer. It walks straight past three bodies and kills a monk in a chair. Rule 18 requires one at every realm.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Art lint within on all three, slots 3 of 3 after the bodies take 3 (`bonus_slots` −3). Technique 2.0 of 3.0. Thần thức not totalled |
| Validity | PASS | Tier 2 reaches Nascent Soul. `moc`, base stats and `than_hon_per_extra_beast` read from data |
| Stack | PASS | Six forms: Flat base, Increased, More, Per, Conditional, Rule swap. Empty rungs named |
| Scaling | PASS | m_static 3.20 against typical 7.37. The blow's own M is about 12.5, 22 in step. INFO: above typical, far below top-end's 256 |
| The fight | PASS | The queue fires, and the Abbot walks in `abroad`. No caps hit |
| Reuse | PASS | 5 ledger pieces and 7 catalogue rows. Only Borne Body and Vow Renewed are new in the stack |
| NPC use | PASS | A slot order is data. A sect can field one |
| Counterplay | PASS | Rule 18's soul-piercer beats it (`soul-deep`) |
| Originality | PASS | Monastery terms are common words. No sect, character or item from any work |

## Fight Results

Input: `sheets/the-puppeteer.fight.json`, plug-ins `borne_body` and `in_step`. A paper model.

| Enemy | Gap | Result | Time | Own health, pool | Enemy health |
|---|---|---|---|---|---|
| typical | 0 | Win | 4.25 s | 96 %, 36 % | 0 |
| typical | 1 | Loss | 4 s | 0, 0 | 86 % |
| typical | 2 | Loss | 4 s | 0, 0 | 88 % |
| top_end | 0 | Loss | 3 s | 0, 0 | 94 % |
| top_end | 1, 2 | Loss | 3 s | 0, 0 | 99 % |

Deity Transformation is the top realm, so gap 2 is the same enemy with more suppression. Second realm: `the-puppeteer-core` wins at 5.142 s on 92 %, `the-puppeteer-core-mixed` at 5.856 s on 72 %, and `core-mixed --gap 1` loses at 3 s, enemy on 92 %. `the-puppeteer-abroad-one-up --gap 1`: loses at 4 s, enemy on 91 %, the operator's own body the last thing standing.

**Unmodelled:** a body's wounds between fights, loyalty and feed (Full Trough is entered at its ceiling), and any falling-off of the thread with distance.

## New Concepts

**Puppet (Khôi Lỗi).** One record that is an artifact and a beast. Combat rule 19 and Item Database rule 6. Bounds: `equip.max_slots`, an art slot each, `than_hon_per_extra_beast`. Breakdown line: "Lacquered Abbot, artifact and beast: both tag families apply". Other users: a sect's guardian golem, a possessed banner. NPCs can use it.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Borne Body, Puppet | Needs rule | Combat rule 19: a puppet in the slot order is the side's body, and may be targeted |
| `bodies_fallen` guard | Needs key | One word in rule 13's guard vocabulary |
| Three puppets, Frame, Vow Renewed, three arts | Needs key | A record that holds both shapes |

## Questions

- Should one record really read both tag families? It is the build's whole engine and the likeliest thing to rule out.
- Does a body keep its wounds between fights? The slot order table means nothing without it.
- Can a puppet be above its operator's realm? This sheet keeps them level, so as not to repeat Herd-Child's buffalo.

## Also Considered

- **Sit still and mend:** ward off, a full pool, Still Water closing the cracks. Tired twice over: standing still and rejecting the ward.
- **The operator inside the statue:** a mech. Loses what the chair gives, the soul weakness.
