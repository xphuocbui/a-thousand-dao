# The Herd-Child (Mục Đồng Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The companion is the fighter and the cultivator is its support; the beast is the build, not an add-on." Also "A beast sacrificed mid-fight as a resource."
> **Direction**: The seed's sacrifice was cold, so it became the reverse: nobody spends the beast, it spends itself. Not a dragon: the family's old plough buffalo, a realm above its stalled owner, who plays the flute.
> **Realm span**: Qi Refining – Core Formation, defined at Foundation Establishment · **Power level**: strong, and falling as the owner rises · **Use**: player build, or a village elder nobody should have robbed
> **Fit**: 3 Fits today · 14 Needs key · 7 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** the companion, on all five layers of the owner's M, through ward and guard, no crit. 92 % of the damage in the defining fight is the buffalo's.
- **The enabler:** none. The beast is raised, not found: an owned beast already cultivates in the world tick, and an owner stalled at a gate falls behind it.
- **The loop:** the flute keeps time, the buffalo strikes on the note, and the ward buys one more second of song.
- **The engine:** every song is paid in the same linh lực that keeps the singer standing. When the singer falls, the buffalo stands over them and finishes it, wounded by every blow it took for them.
- **The sacrifice:** the owner's own life. A low method, a stalled realm, years given away, a feed bill one realm too high. It has no answer to a top-end blow, and that blow costs the buffalo its life.
- **The arc:** this build is at its best on its first great day. As the owner climbs, the buffalo stops outranking them and the build fades, so the player is choosing between their own Core and its strength.

## The Legend

In the delta villages they say the buffalo is where a family begins. The Plough-Song Method was never cultivation: it is a breathing rhythm that herd-children sang to keep an animal walking straight through a ten-hour furrow. A buffalo that hears it for sixty years learns to breathe with it, and nobody noticed what that did, because it still pulled the plough.

A child of such a house may find a root, go up to a sect, and come home at ninety, stalled at Foundation Establishment. The animal they rode to the river is now stronger than any elder they ever bowed to, and it is dying of age. So they give it years. The sects have tried to tax these villages and tried to buy the animals, and each has a story about what happened when someone struck the herder.

## How It Fights

The flute plays, and the buffalo walks on the note. One Calling Note every 0.8 s, one blow on the same instant, a Rain Song that makes the enemy's ward burn faster. In a fair fight it is over before the second verse. One realm up the singer lasts three seconds. Then the song stops, and that is when the fight begins.

**The signature moment:** a Core Formation collector strikes the old herder down in the road at 3 s, with the flute still in their hand. The neck bell stops. The buffalo steps over the body and lowers its head, and at 4.8 s it is the only thing on that road still standing, on 85 % of its health (`variants/herd-child-mixed.fight.json`, `--gap 1`).

## The Stack

Sizes on new modifiers are first guesses. `[C]` was taken on the stack: a flat beast stack became the Carried Note and In Step pair, and Broad Back moved from a guard bonus, which changed no fight, to blows taken.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Fights as Itself (Tự Chiến) | A companion hits with its own realm's fight unit, stage and suppression gap, not its owner's. c_comp_cap and the owner's M stay | Rule swap | companion | none | ○ | Capability, Old Yoke | any elder's inherited beast; NPC sect guardians |
| Rate | Bonded Spirit (Linh Khế) | The companion's timer carries your art speed, stopping at `cooldown_min` | Redirect | companion | none | ○ | Way of the Herd | **Catalogue keystone** |
| Multiplier | Damage (`attack_pct`) | +70 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Companion damage | +20 | Increased | companion | L1 | ○ | Old Yoke | **Catalogue row** |
| Multiplier | Reed Song (Lô Ca) | +60 points to arts with the song form | More | art | L2 | ○ | Technique | any bell or song art |
| Multiplier | Carried Note (Đới Âm) | Tag modifiers on an art you fired this instant also apply to your companion's hit in that instant | Redirect | companion | L2 | ○ | Way of the Herd | any art build that keeps a beast |
| Multiplier | Given Years (Tặng Niên) | +1.5 points to companion hits per 1 % of your realm's base lifespan given to the beast, to +45. +30 here, 40 years. This is the companion grade: The Given Years holds the art and basic grade of the same modifier, +2 per 1 % on L4, and one size would change fights | Per | companion | L2 | ○ | Way of the Herd | **Reused from The Given Years**: any bond that can take years, such as capability #3's treasure |
| Multiplier | Artifact attack | +50 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Full Trough (Mãn Tào) | +20 points to companion hits per doubling of the year's feed above what is due, to +40. It was eaten, so a blind fight keeps it | Per | companion | L4 | ○ | Way of the Herd | any beast keeper |
| Multiplier | In Step (Đồng Bộ) | +50 points to a hit landing after one of your arts in the same instant | Conditional | companion, art | L5 | ○ | Old Yoke | any volley: **used by The Already-Waited** |
| Multiplier | Cornered (Khốn Đấu) | +50 points while your health share is below the enemy's; an owner on the ground always counts | Conditional | companion | L5 | ○ | Way of the Herd | **Reused from The Already-Waited** |
| Past the cap | Broad Back (Khoan Bối) | Each 1.0 of c_comp the cap clips moves 10 % of each hit on your health to the beast, to 40 %, against its guard. Overkill is not moved. If its wounds reach its health it dies | Overflow | incoming | none | ○ | Old Yoke | capability #17 holders, whose beast clips too |
| Fuel | Hearth Ash Talisman (Lô Hôi Phù) | Refunds 15 % of maximum linh lực while under 45 %, stock 2 | | any | none | ○ | Talisman | **Reused from The Turned-Away** |
| Identity | **Stands Over You (Hộ Chủ)** | When you go Down, your companion stays, on its own health, guard and no ward, and the fight goes on until it falls. Needs loyalty 60 or more | Rule swap | companion | none | ○ | Keystone, Way of the Herd | any companion; beasts guarding a sect's fallen |

**Identity piece:** Stands Over You. One realm up against the mixed enemy, the build wins at 4.8 s. With `--without stands_over` it loses at 3 s with the enemy on 47 %.

**Empty rungs:** crit is a sacrifice, since a companion cannot crit; In Step is what replaces it. Reach is two songs and nothing more, on purpose (see What the numbers changed).

| Layer | Points at Foundation | Multiplier | Sources |
|---|---|---|---|
| L1 | 90 | ×1.90 | `attack_pct` 70, Companion damage 20 |
| L2 | 30, or 90 in step | ×1.30 or ×1.90 | Given Years, plus Reed Song through Carried Note |
| L3 | 50 | ×1.50 | Gear |
| L4 | 20 | ×1.20 | Full Trough |
| L5 | 0 to 100 | ×1 to ×2 | In Step 50, Cornered 50. On the ground, Cornered only |

The buffalo's M peaks at 13.0 while singing and behind, and is 6.7 in the Stand. The owner's own `m_static` is 2.55. Anchors: typical 4.19, top-end 148.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth, purity 30 or more | Meets the Way of the Herd. Nothing else matters |
| Key talents | Soul strength for taming, then any | The beast does not need the owner to be gifted |
| The Way (Đạo) | Way of the Herd, all of it | Holds the keystone and both Redirects |

## Công Pháp

### Plough-Song Method (Canh Ca Quyết) — main, Hoàng giai

A breathing rhythm for walking behind an animal. Nobody who stays on it passes Foundation Establishment at full strength, and that is the point.

```json
{"id": "canh_ca_quyet", "name": "Canh Ca Quyết", "tier": 0, "tech_kind": "main", "names": ["tho"], "layers": 6,
 "bonuses": [{"stat": "lifespan_years", "value": 15}],
 "abilities": [{"ability_id": "calling_note", "unlock_layer": 1}, {"ability_id": "rain_song", "unlock_layer": 3},
               {"ability_id": "low_song", "unlock_layer": 4}, {"ability_id": "furrow_song", "unlock_layer": 5},
               {"ability_id": "home_call", "unlock_layer": 6}],
 "seal_clusters": ["old_yoke"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 15 / 15 = 1.0 against Hoàng's 1. Tier `max_realm` is `truc_co`, the same place the owner stalls. Reed Song is a technique "more", unbudgeted.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Calling Note (Hô Thanh) | Method, 1 | qi, Earth, song | 1.2 | 0.03 | 1 s | none | Needs key |
| Rain Song (Vũ Ca) | Method, 3 | qi, Earth, song | 0 | 0.05 | 2 s | none | Needs key |
| Low Song (Đê Ca) | Method, 4 | qi, Earth, song | 0 | 0.05 | 2 s | none | Needs key |
| Furrow Song (Lũng Ca) | Method, 5 | qi, Earth, song | 0 | 0.05 | 2 s | none | Needs key |
| Home Call (Hồi Thôn Khúc) | Method, 6 | escape, song | 0 | 0.10 | 3 s | own health below 30 % | Needs key |

**Calling Note. Effect:** a hit. Carries Reed Song, so the buffalo's blow in this instant has it too. **Description:** two notes, the same two every evening.
**Rain Song. Effect:** curse, +50 % ward drain, 3 pulses. **Description:** what you sing when the sky turns and the animal must keep walking.
**Low Song. Effect:** curse, −30 % body guard, 3 pulses. **Furrow Song. Effect:** curse, ward pass ×1.5, 3 pulses. Both are off the main loadout; a singer cannot afford them.
**Home Call. Effect:** escape. Unmodelled. The only way to keep a top-end blow from reaching the owner, and so to keep the buffalo alive.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Qi Refining | 3 | Calling Note | Default | A calf and a child |
| Foundation Establishment | 4 | Calling Note, Rain Song, Hearth Ash, Home Call | Common drain | The defining loadout. +25 art speed, so every timer sits on a whole 800 ms |
| Core Formation | 5 | As above | Common drain | The buffalo no longer outranks the owner |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Neck Bell (Cảnh Linh) | Artifact, utility | Chuông, generated | L3 on a piece the family already owned. Its great-grandmother hung it there | Fits today |
| Hearth Ash Talisman | Talisman | as ledger | The second it buys is the buffalo's health, not the owner's | Needs key |

## Companion

**The Old Plough Buffalo (Lão Canh Ngưu).** Earth, beast form, one realm above its owner, stage 1.0. Fixed art **Long Furrow (Trường Lũng):** a body hit, every timer. In the Stand it has `n_body` 2.0, `t_b` 2.0, `body_guard_pct` 60, no ward and no regeneration.

Two existing rules give the bond its price. Feed is `feed_lt_by_realm` at the beast's realm, so a Foundation owner pays 300 stones a year instead of 40, and unfed loyalty falls by 25 with Stands Over You needing 60. And a beast at 0 in the Stand is dead, for good, with nothing in the game to bring it back.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Old Yoke | Sealed cluster | Fights as Itself, In Step, Broad Back | Needs rule |
| 2 | Way of the Herd keystone | Stands Over You | The build | Needs rule |
| 3 | `attack_pct`, art speed | Tree | The owner's M is the buffalo's M | Fits today |

### Hidden cluster idea: Old Yoke (Cổ Ách)

Theme Beast Taming (Ngự Thú), Earth, outer, sealed by a technique through `seal_clusters`, size 10. Small acupoints: Companion damage and Companion attack speed. Notables: In Step, then Broad Back with Fights as Itself as its capability. An idea for the tree rework, not data.

## Đạo

**Way of the Herd (Mục Đạo).** Requires Earth at purity 30. `theme_stats`: `khi_huyet_pct`, `linh_luc_regen_pct`, `art_speed_pct`, `body_guard_pct`. 20 nodes, no art nodes.

- **The Rope (Lãm):** art speed and body guard lines, passive Bonded Spirit.
- **The Song (Ca):** regeneration lines, passive Carried Note.
- **The Field (Điền):** health lines, passives Full Trough and Given Years.
- **Keystone:** Stands Over You.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | A fist and a calf, c_comp near 0.5 | Calling Note | The family asks who will take the animal to the river |
| Foundation, stalled | The defining fight: wins at 1.6 s, and one realm up the buffalo finishes it | Stands Over You, Given Years | The method's ceiling, and a gate that keeps refusing. The animal has passed them |
| Core Formation | A cultivator with a good pet: wins at 3.2 s on 32 %, and loses one up (`variants/herd-child-core-mixed.fight.json`) | Capability #17 lifts that to 45 % (`variants/herd-child-core-union-mixed.fight.json`) | They reached the gate at last. It is old now, and the years it needs are theirs |

## Matchups

All from `--gap 0` and `--gap 1` on the file named, in `variants/`.

| Enemy | Result | Why |
|---|---|---|
| Mixed, same realm (`herd-child-mixed`) | Wins at 1.6 s on 88 % | Two blows |
| Mixed, one up (`herd-child-mixed`) | Wins at 4.8 s, owner Down at 3 s, buffalo on 85 % | It is the buffalo's own realm |
| Mixed, two up | Loses at 3 s, enemy on 92 %, buffalo dead | The owner falls at 1 s |
| Evader, 35 % (`herd-child-evader-mixed`) | One up: wins at 9.6 s, buffalo on 13 % | A companion has no accuracy |
| Pool-burner (`herd-child-silencer`) | One up: wins at 6.4 s, buffalo on 8 % | Song stops early, owner falls at 2 s |
| Soul striker (`herd-child-soul-striker`) | One up: wins at 5.6 s, buffalo on 22 % | Soul skips the ward the song paid for |
| ×4 boss (`herd-child-boss-x4-mixed`) | Same realm: wins at 4.8 s on 43 %. One up: loses at 6 s, enemy on 78 % | |
| Top-end, same realm (`sheets/herd-child.fight.json`) | Loses at 2 s, enemy on 80 % | Owner falls at 1 s, the buffalo dies a second later |

**Counter:** a top-end cultivator (Combat rule 18). It costs the player far more than a lost fight: the buffalo will not leave, so it dies, and a life's build goes with it. The only answers are Home Call and not being there.

**A rare case:** a buffalo two realms up, on a life that gave it everything, wins at 2.4 s one up and takes a same-realm top-end to 35 % (`variants/herd-child-elder-mixed.fight.json`). Nothing says such an animal can be raised.

## What the numbers changed

1. **Support costs the animal.** The draft sang four songs. Run that way one realm up, the owner falls at 2 s, not 3 s, and the buffalo ends on 6 %, not 85 % (`variants/herd-child-all-songs-mixed.fight.json`). Linh lực is the ward, the ward is one more second, and that second is worth most of the buffalo's health. A good support here is one who sings less.
2. **A song the singer does not live to sing.** With 3 s cooldowns, the songs never fire one realm up: the result is identical to singing only Calling Note, 7.2 s on 40 % (`variants/herd-child-slow-songs-mixed.fight.json`, `variants/herd-child-note-only-mixed.fight.json`). Everything a support does must fit inside two seconds.
3. **Most of the winning happens with the owner on the ground.** The enemy has 47 % left when the singer falls. Years in the fight are spent there.
4. **The Redirect is worth more than a Conditional.** `--without bonded_spirit` turns the win into a loss at 8 s with the enemy on 4 %. `--without "In Step"` only slows it to 6.4 s on 59 %.
5. **Cut, because no result changed:** What It Brings Home, a refund on each companion hit, moved linh lực and never a winner or a time. A guarded Furrow Song never fired. `rules/brings_home.py` stays, unused.

Every `--without` above is on `variants/herd-child-mixed.fight.json` with `--gap 1`.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 1.0 of 1. Calling Note within the art lint (1.2 of 1.36). Slots 4 of 4 with Home Call. Thần thức not totalled |
| Validity | PASS | `tho`, `hoang`, `truc_co`, `chuong`, `ket_dan` are real. Core span runs past the tier's `max_realm` at `beyond_realm_mult`, which is the arc |
| Stack | PASS | Seven forms. Identity piece removed changes the fight. L1 to L5 stated, none empty |
| Scaling | PASS | INFO: `m_static` 2.55 is below typical 4.19, and the buffalo peaks at 13.0 at a U one realm up. Power is what a realm gap gives, so a one-up win is against the beast's peer |
| The fight | PASS | The engine runs as plug-ins, with no stand-ins. No cap hit. Escape and all costs in years are unmodelled and are not the engine |
| Reuse | PASS | Reuses Bonded Spirit, Hearth Ash, Companion damage, Cornered and Given Years. All second homes named, none signature. Bonded Spirit's status half is not used |
| NPC use | PASS | Every piece is a compile-time value or fixed rule. The generator needs a beast realm above the owner's. One Breakdown line each |
| Counterplay | PASS | Top-end cultivator, as above. An evader and a pool-burner both cost it most of the buffalo |
| Originality | PASS | No name from any work. The proverb and the image of a herd-child with a flute are common folk heritage |

## Fight Results

Input: `sheets/herd-child.fight.json`. Observations from `_tools/fight_x.py`, a paper model with expected values for chance, not the game. Cap hits: none.

| Enemy | Gap | Result | Time | Own dry at | Owner down, buffalo left |
|---|---|---|---|---|---|
| typical | 0 | win | 1.6 s | never | not needed |
| typical | 1 | win | 5.6 s | 2 s | 2 s, 54 % |
| typical | 2 | loss, enemy 92 % | 3 s | 1 s | 1 s, dead |
| top_end | 0 | loss, enemy 80 % | 2 s | 1 s | 1 s, dead |
| top_end | 1 | loss, enemy 95 % | 2 s | 1 s | 1 s, dead |
| top_end | 2 | loss, enemy 99 % | 2 s | 1 s | 1 s, dead |

Mixed enemy, `variants/herd-child-mixed.fight.json`: win, win, loss.

**Identity:** `--without stands_over`, one up on mixed: loss at 3 s, enemy on 47 %. **Second realm:** Core Formation, in Progression. **Shaped enemies:** in Matchups.

**Unmodelled:** Shared Years, feed and loyalty; years owed on wounds; Home Call, because the calculator has no escape; the Stand clears statuses and curses on the owner, which is a choice of the plug-in; Given Years and Full Trough are flat points at a 20 % gift and a doubled feed.

## New Concepts

**Shared Years (Cộng Thọ).** A beast has a lifespan by its realm, and its owner may give it years of their own, up to 30 % of the owner's realm base. Each 1 % of health the beast loses in a fight also costs it 1 year of what it has left. Rule in Spirit Beasts and Realms rule 14. Breakdown: "Given Years: +30". Also serves any bound treasure (capability #3) and a master keeping a dying disciple alive. **Question for the user below.**

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Fights as Itself | Needs rule | Combat Formulas J: U, stage and gap by the companion's realm |
| Stands Over You | Needs rule | Combat rules 14, 19 and the Edge Case on an owner going Down |
| Broad Back | Needs rule | Combat rule 19: blows reach the companion. A health for companions |
| Carried Note, Bonded Spirit | Needs rule | Rule 10 hit order is unchanged; a companion reads this instant's art |
| Given Years, Shared Years | Needs rule | Spirit Beasts; Realms rule 14 |
| In Step, Full Trough, Companion damage | Needs key | A guard on "an art resolved this instant"; feed spend; companion tag |
| Song form tag, method, arts, buffalo, Old Yoke, Way of the Herd | Needs key | Content |

## Questions

1. Combat rule 19 and Open Question 3 closed targeting of companions on 2026-11-06. Stands Over You and Broad Back ask to reopen it for this keystone alone. Is that allowed?
2. Should an owned beast be able to outrun its owner by a realm at all? The world tick seems to allow it. If not, this build needs a named source.
3. Is permanent beast death acceptable as a cost the player can lose to a single top-end blow?

## Also Considered

- **The Last Meal:** a beast sacrificed mid-fight for one enormous strike. Cold, and the seed's literal reading.
- **Between (Cản Đường):** the beast takes every blow from the first second. A plain taunt tank; Broad Back keeps the good part.
