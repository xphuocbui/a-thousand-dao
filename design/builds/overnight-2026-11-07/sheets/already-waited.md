# The Already-Waited (Dĩ Đãi Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Heart demon as a second resource pool: a bargain with what lives in you." Fury or longing as the mood, with something visible in the first 5 seconds.
> **Direction**: Paying arts in heart demon would be one more resource swap, which the critic closed. So the second pool pays what no other pool can: time. Heart demon pays cooldowns, and linh lực still pays costs. Seed 29, borrowing cooldown, became the mechanism.
> **Realm span**: Core Formation – Deity Transformation, defined at Nascent Soul · **Power level**: strong at its realm, and loses one up · **Use**: player build, or a named NPC who has come back for someone
> **Fit**: 3 Fits today · 10 Needs key · 7 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: thần thức not totalled. Scaling: M moves with the pool and with who is ahead, so the anchors compare poorly)

## The Spine

- **The channel:** art hits, on L1, L2, L3 and L5, through ward and guard. Arts cost linh lực the ordinary way, on the common drain ward.
- **The enabler:** Already Waited. Opens heart demon as a pool that pays art timers. Closes your seasons: each point spent is a season you owe at the landing.
- **The loop:** each pulse the demon pays a long art's wait in slot order, the art fires now, and it costs its normal linh lực.
- **The engine:** the art lint prices a coefficient in three things. Linh lực and cooldown trade against each other, and long-cooldown arts are the cheapest damage in the game per linh lực, so a pool that pays the cooldown keeps the cheap price and removes the wait. The ward lasts because the arts are cheap, until there have been too many of them.
- **The sacrifice:** preparation (L4 is empty), a heart demon that bars the Nascent Soul gate and can kill at 90, and whole years of a life.
- **The arc:** kept under 20 until the Nascent Soul gate, because that gate demands it. Then let in.

## The Legend

There is a ferry stage on a brown river where, in hunger years, parents crossing to find work told their children to wait by the post. Most were collected. One child waited nineteen years. The waiting did not go anywhere. It set, the way silt sets, and when that child finally found a root, what lived in them was every hour they had stood there.

They wrote the Ferry-Rope Sutra as knots in a mooring line, one for each season. Those who walk it are the calmest cultivators alive until the first blow, and then they will not wait for anything, ever again, for about five seconds. Afterwards they go back to the river, because they said they would. Everyone knows where to find them, and how empty they are. If the one who left ever comes back, the pool drains and never refills, and nobody who walks this path can say whether they want that.

## How It Fights

Every second, an art that cannot be ready fires anyway. A six-second art and a ten-second art land together at t = 1, then an eight and a twelve at t = 2. **Wait Here** goes first, because it does to the enemy what was done to you: their next art is pushed back three seconds. The Last Ferry, a twenty-second art, waits at the end of the rope until they are under 40 % health, and then nobody waits.

**The signature moment:** a ×4 boss on 29 % at 4 s, with your own linh lực nearly gone. The demon pays fifteen seasons. The Last Ferry arrives fifteen seconds early, and the fight is over at 5 s (`variants/already-waited-boss-x4-mixed.fight.json`).

## Enabler

**Already Waited (Dĩ Đãi)**, a capability on the sealed cluster Cold Landing. Rule removal.

- **Opens:** at each pulse the pool pays one art, the next in slot order, going round, if its guard holds and its linh lực can be met. Price: 1 heart demon per second left on its timer. Paid, it fires this instant by the ordinary rule. Nothing fires before the first pulse, so rule 13 stands.
- **Closes:** the Owed Wait below. A heart demon carried into a fight is also a heart demon carried to a gate.
- **Found:** Cold Landing is sealed by the Ferry-Rope Sutra. A life finds the sutra on a mooring line, or never.

## The Stack

Sizes on new modifiers are first guesses. `[C]` was taken on the stack: a plain "pool above 75 means more damage" gave way to Both Hands, which spends the pool faster on purpose, and Wait Here.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Heavy Hand (Trọng Thủ) | Arts with a cooldown of 5 s or more deal +20 points; arts under 2 s deal less | More | art | L2 | ○ | Keystone, tree | **Catalogue keystone** |
| Rate | **Already Waited** | As above | Rule swap | art | none | ○ | Capability, Cold Landing | any build that must have one slow art early |
| Rate | Both Hands (Song Thủ) | While heart demon stands above 50 as a pulse begins, the pool pays two arts that pulse | Cap shift | art | none | ○ | Cold Landing | signature |
| Multiplier | Damage (`attack_pct`) | +188 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Heart Demon Turned to Strength | Capability #25: heart demon ÷ 2 as `attack_pct` above 50, read at compile. +42 here | Increased | any | L1 | ● | Capability | **Exists** |
| Multiplier | Heart Demon's Blade (Tâm Ma Nhập Đao) | +0.6 points to arts per point of heart demon held now | Per | art | L2 | ○ | Technique | **Catalogue dark path** |
| Multiplier | Artifact attack | +60 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Landing Ground (Độ Khẩu Địa) | +40 points on a place where you owe seasons. A ground tag, so a blind fight keeps it | More | any | L4 | ○ | Formation | a hermit of a single place |
| Multiplier | Cornered (Khốn Đấu) | +50 points while your health share is below the enemy's | Conditional | art, basic | L5 | ○ | Cold Landing | **Used by The Herd-Child** |
| Multiplier | In Step (Đồng Bộ) | +50 points to a hit landing after one of your arts in the same instant, here the second art of a volley | Conditional | art | L5 | ○ | Technique | **Reused from The Herd-Child** |
| Crit | Crit | 10 % at ×1.6 | | any | none | ● | Tree | Not chased |
| Reach | Wait Here (art) | Pushes the enemy's next art back 3 s | Timing | art | none | ○ | Technique | any build fighting one big art |
| Fuel | Hearth Ash Talisman (Lô Hôi Phù) | Refunds 15 % of maximum linh lực while under 45 %, stock 2 | | any | none | ○ | Talisman | **Reused from The Turned-Away** |
| Survival | Every Blow (Mỗi Kích) | +0.3 heart demon per 1 % of maximum health lost to a hit, kept after the fight | Trigger | incoming | none | ○ | Cold Landing | any #25 or Blade build |
| Survival | The Owed Wait (Trái Đãi) | One season at the landing owed per heart demon spent. Each season paid returns 1 heart demon, with natural decay off. Each season left unpaid costs 1 Dao heart | Trade | none | none | ○ | Capability | any power paid in seasons |

**Identity piece:** Already Waited. With `--without already_waited` the same arts and the same demon lose at the same realm at 5 s with the enemy on 66 %, because the long arts have not fired. With it the build wins at 2 s.

**Empty rungs:** L4 is a sacrifice. Fury does not prepare; Landing Ground is the one exception, and it arrives when the pool is empty.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 230 | ×3.15 | `attack_pct` 188, #25 at 42, past the soft start |
| L2 | 20 + 0.6 per heart demon: 71 at 85 | ×1.71 | Heavy Hand, Heart Demon's Blade |
| L3 | 60 | ×1.60 | Gear |
| L4 | 0 | ×1.00 | Sacrifice |
| L5 | 0 to 100 | ×1 to ×2 | In Step 50, Cornered 50 |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water, any purity | The sutra names Water. Nothing here depends on purity |
| Key talents | Dao heart | It is what stands between 85 heart demon and a deviation |
| The Way (Đạo) | Any. Time suits it | No Đạo is needed, which keeps a slot of a life free |

## Công Pháp

### Ferry-Rope Sutra (Độ Lãm Kinh) — main, Địa giai

Knots in a mooring line, one for each season someone stood there.

```json
{"id": "do_lam_kinh", "name": "Độ Lãm Kinh", "tier": 2, "tech_kind": "main", "names": ["thuy"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20}, {"stat": "khi_huyet_pct", "value": 15}, {"stat": "attack_pct", "value": 15}],
 "abilities": [{"ability_id": "rope_burn", "unlock_layer": 3}, {"ability_id": "third_winter", "unlock_layer": 5},
               {"ability_id": "wait_here", "unlock_layer": 7}, {"ability_id": "lantern_left", "unlock_layer": 9},
               {"ability_id": "last_ferry", "unlock_layer": 12}],
 "seal_clusters": ["cold_landing"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 20/20 + 15/15 + 15/15 = 3.0 against Địa's 3. Tier `max_realm` is `nguyen_anh`, so a Deity Transformation life pays `beyond_realm_mult`.

## Arts

Each sits within the art lint because the cooldown pays for the coefficient.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Wait Here (Tại Thử Đãi) | Sutra, 7 | qi, Water | 2.7 | 0.04 | 6 s | none | Needs rule |
| Rope Burn (Lãm Ngân) | Sutra, 3 | body, Water | 3.7 | 0.04 | 10 s | none | Needs key |
| Third Winter (Đệ Tam Đông) | Sutra, 5 | qi, Water | 3.3 | 0.05 | 8 s | none | Needs key |
| Lantern Left (Lưu Đăng) | Sutra, 9 | body, Water | 4.4 | 0.06 | 12 s | none | Needs key |
| The Last Ferry (Mạt Độ) | Sutra, 12 | body, Water | 6.3 | 0.05 | 20 s | enemy health below 40 % | Needs key |

**Wait Here. Effect:** a hit; the enemy's art nearest to firing is pushed back 3 s. **Description:** what was said to you, said to them.
**The Last Ferry. Effect:** a hit. **Description:** you stayed for it anyway.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Core Formation | 5 | Wait Here, Rope Burn, Third Winter, Lantern Left, Last Ferry | Common drain | 20 heart demon, the most the next gate allows |
| Nascent Soul | 6 | As above, then Hearth Ash | Common drain | The defining loadout, at 85 heart demon |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Hearth Ash Talisman | Talisman | as ledger | The ward's last 15 %, twice. Without it a ×4 boss wins | Needs key |
| Tĩnh Tâm Đan | Pill | existing | −25 heart demon before the Nascent Soul gate. The build's only way in | Fits today |
| Any weapon pieces | Artifact, weapon | Generated | L3 only | Fits today |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Cold Landing | Sealed cluster | The enabler | Needs rule |
| 2 | Capability #25 | Exists | L1, and it doubles the deviation chance | Fits today |
| 3 | Heavy Hand | Keystone | Long arts are the whole loadout | Needs rule |

### Hidden cluster idea: Cold Landing (Lãnh Độ)

Theme Heart State (Tâm Cảnh), Water, outer, sealed by a technique through `seal_clusters`, size 10. Small acupoints: Dao heart and body guard. Notables: Every Blow, then Both Hands with Already Waited as its capability. An idea for the tree rework, not data.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Core Formation | 20 heart demon pays about one fight, wins at 4 s on 47 % (`variants/already-waited-core-mixed.fight.json`) | Rope Burn, Third Winter | Every beating is a year further from the gate, because Every Blow raises what it must hold under 20 |
| Nascent Soul | The defining fight: wins at 2 s, and owes 30 seasons | Both Hands, Last Ferry | Three hundred years of calm to pass the gate. Then they go back to the post and let it in |
| Deity Transformation | Not run. By rule, a failed attempt at 85 heart demon can kill | | They pick a fight before their gate, to bring the demon down |

## Matchups

From `--gap 0` and `--gap 1` on the file named, in `variants/`. Spent is seasons owed.

| Enemy | Result | Why |
|---|---|---|
| Mixed, same realm (`already-waited-mixed`) | Wins at 2 s on 74 %, 30 spent | Four long arts in two pulses |
| Mixed, one up | Loses at 3 s, enemy on 53 % | The pulse is the limit, and it does not outlive the third |
| Chaff, 4 cheap arts (`already-waited-chaff`) | Same realm: wins at 2 s on 20 % | Wait Here moves one art of four |
| Per-hit ward (`already-waited-per-hit-ward`) | Same realm: wins at 3 s on 54 %, own linh lực 4 %, 51 spent | Blocks a share of every big hit at a fixed price, and holds 59 % of its own pool |
| Pool-burner (`already-waited-silencer`) | Same realm: wins at 2 s on 77 %. One up: loses at 2 s, enemy on 83 % | Your arts cost half as much again, and the ward falls at 1 s |
| ×4 boss (`already-waited-boss-x4-mixed`) | Same realm: wins at 5 s on 39 %, 73 spent. One up: loses at 3 s, enemy on 88 % | |
| Top-end, same realm (`sheets/already-waited.fight.json`) | Loses at 1 s, enemy on 89 % | One pulse is all it gets |
| During the Owed Wait (`already-waited-landing-mixed`) | 15 heart demon, Landing Ground on: wins at 3 s on 54 % | Empty is not helpless at home |

**Counter:** anything that ends the fight by the third pulse, which means a top-end enemy or one realm up (Combat rule 18). Outside the fight: find them at the river, while the pool is empty.

## What the numbers changed

1. **The Last Ferry goes last.** The first draft opened with a twenty-second art at t = 1, the obvious screenshot. Against the ×4 boss that wins at 7 s on 7 %, spending 95 (`variants/already-waited-ferry-first-boss-x4-mixed.fight.json`). At the end of the rope, guarded as a finisher, the same art wins at 5 s on 39 %, spending 73. Against a fair opponent the two take the same time, and the opening costs 8 more seasons (`variants/already-waited-ferry-first-mixed.fight.json`). The longest wait was the worst thing to pay for and the best thing to arrive at.
2. **It must still be affordable.** At a cost of 0.08 the Last Ferry never fires in that boss fight. The demon can pay the wait, but by then linh lực cannot pay the art, and the win slips to 6 s on 28 % (`variants/already-waited-dear-ferry-boss-x4-mixed.fight.json`). Two pools, and either one stops you.
3. **Holding back was the wrong instinct.** A guard at 50 % linh lực on three arts was meant to be this build's skill. It turns the boss into 7 s on 13 % (`variants/already-waited-held-boss-x4-mixed.fight.json`), and one realm up the enemy keeps 71 % instead of 53 % (`variants/already-waited-held-mixed.fight.json`). The fury is the better play, which is not what the story wanted to hear. The margin rests on first-guess sizes, so read it as a tendency.
4. **Paying twice a pulse is the build.** With one payment a pulse, the same loadout loses that boss at 6 s with it on 32 % (`variants/already-waited-one-hand-boss-x4-mixed.fight.json`).
5. **The pool is not the limit in a fair fight, the pulse is.** At 85 it spends 30. At 45, under Both Hands' line, it wins a second later, at 3 s on 54 %, spending 18 (`variants/already-waited-low-pool-mixed.fight.json`). Holding more buys tempo and the Blade, and its price is the danger of holding it.
6. **What the boss fight needs.** On `variants/already-waited-boss-x4-mixed.fight.json`: `--without wait_here` loses at 4 s, boss on 43 %. `--without hearth_ash` loses at 6 s on 41 %. `--without "In Step"` loses at 8 s on 11 %. `--without "Heart Demon's Blade"` loses at 8 s on 26 %. `--without Cornered` only slows it, to 6 s on 26 %.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 3.0 of 3. All five arts within the art lint. Slots 6 of 6. Thần thức not totalled |
| Validity | PASS | `thuy`, tier `dia`, `nguyen_anh` real. The Nascent Soul gate is read as written, at most 20 |
| Stack | PASS | Nine forms. Identity piece removed loses the fight. L4 empty, as a stated sacrifice |
| Scaling | NOT ASSESSED | `m_static` 5.04 against typical 7.37 and top-end 256. L2 and L5 move in the fight, so that figure says little |
| The fight | PASS | The engine is a plug-in, `rules/already_waited.py`. No stand-ins. Arts paid in linh lực on the common ward. Visible from t = 1 |
| Reuse | PASS | Heavy Hand, Heart Demon's Blade, #25, Hearth Ash, In Step reused. One signature, Both Hands |
| NPC use | PASS | Slot order and guards are loadout data. An NPC needs a heart demon value and a landing. One Breakdown line each |
| Counterplay | PASS | Top-end and one realm up, as above. Chaff arts cost it most of its health |
| Originality | PASS | No name from any work. Abandonment at a crossing is a folk image, not a borrowed story |

## Fight Results

Input: `sheets/already-waited.fight.json`. Observations from `_tools/fight_x.py`, a paper model with expected values for chance, not the game. Spent is heart demon, so seasons owed.

| Enemy | Gap | Result | Time | Own dry at | Spent |
|---|---|---|---|---|---|
| typical | 0 | win on 69 % | 2 s | never | 30 |
| typical | 1 | loss, enemy 60 % | 2 s | 2 s | 30 |
| typical | 2 | loss, enemy 67 % | 2 s | 2 s | 30 |
| top_end | 0 | loss, enemy 89 % | 1 s | 1 s | 14 |
| top_end | 1 | loss, enemy 98 % | 1 s | 1 s | 14 |
| top_end | 2 | loss, enemy 98 % | 1 s | 1 s | 14 |

Mixed enemy, `variants/already-waited-mixed.fight.json`: win, loss, loss. Cap hits: none. `enemy_art_delayed` in the output is Wait Here firing, not a cap.

**Identity:** `--without already_waited` on the mixed file, same realm: loss at 5 s, enemy on 66 %. **Second realm:** Core Formation, in Progression. **Shaped enemies:** in Matchups.

**Unmodelled:** the Owed Wait itself, seasons, Dao heart and the refill; heart demon carried out of the fight and what it does at the next gate; #25 does not move with the pool in a fight, by its own rule.

## New Concepts

**A heart demon that moves in a fight.** Combat reads heart demon at compile and today returns only +2 from #9. This asks that a fight can spend it and raise it, with the change reported to Character Stats like vitality loss. Rules: Combat rule 2 and rule 14, Character Stats rule 8. Bound: 0 to 100, as it is. Breakdown: "Already Waited: paid 9". Also serves any Heart Demon's Blade build and a build that feeds on being hurt. NPCs use it as they use any stat.

**The Owed Wait.** A forced stay of seasons at one place, in the Time & Turn loop. Also serves oaths, sentences and a hermit of a single place.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Already Waited, Both Hands | Needs rule | Combat rule 13: a timer can be paid at a pulse. One new pool |
| Every Blow | Needs rule | Combat rule 14 output, Character Stats rule 8 |
| The Owed Wait | Needs rule | Time & Turn, Character Stats rule 8 |
| Wait Here | Needs rule | Combat rule 13: an enemy timer can be moved |
| Heavy Hand, Heart Demon's Blade | Needs rule | Catalogue rows, not yet rules |
| In Step, Cornered, Landing Ground | Needs key | Two guards, one ground tag |
| Sutra, arts, Hearth Ash, Cold Landing | Needs key | Content |

## Questions

1. A heart demon of 85 is a character the game expects to be in danger. Is a build that holds one on purpose wanted?
2. Should a quest offer the return of the one who left? It would end the build, and it may be the best story in it.
3. One season per point means a fair fight costs about 7.5 years. On a 1,000-year life is that the right price?

## Also Considered

- **The Named Grudge:** the bargain names one living NPC, the pool works in full only against them and their sect, and it ends when they die. Strongest as a nemesis system; the pool itself was weaker.
- **The Tenant Moves House:** your demon is handed to an enemy in a fight, cleans you for the gate, and returns if they die. A good story, but the kill was "the enemy ruins itself", which is tired.
