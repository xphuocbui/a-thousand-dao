# The Struck Name (Tước Danh Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Tagless: arts with no tags, so no enemy modifier or ward rule can touch them."
> **Direction**: A stronger idea than the seed. Tagless arts protect you a little; a curse that strips the enemy's tags, and lets you wear what it took, is the build
> **Realm span**: Foundation Establishment – Nascent Soul · **Power level**: strong · **Use**: player build to aim for, and a hunter of famous cultivators
> **Fit**: 4 Fits today · 9 Needs key · 6 Needs rule
> **Checks**: 9 PASS · 0 FAIL · 0 NOT ASSESSED. Bare hits, Unnamed and Borrowed Name run as plug-ins, and Borrowed Name reads each enemy's L2 live
> **Repair**: every number now comes from a saved file. The matrix did not move. What changed: the ward specialist no longer beats the build one realm up, either way; bare hits are worth 0.3 s over qi at the same realm rather than nothing; Ten Thousand Names shows no gain one realm up; without the curse the specialist ends on 80 %, not 95 %; Foundation and Nascent Soul moved. The tougher top-end copy is gone: nothing saved could reproduce it.

## The Spine

- **The channel:** art hits with no tags. They use L1, L3 and L5 and whatever L2 the build can find. No crit.
- **The enabler:** Struck Name, a sealed cluster's keystone. It opens bare arts and closes crit, every tag-keyed modifier, talismans and escape.
- **The loop:** strike the enemy's name each second, so their L2 stops; wear what you took; break the ward; finish with a health-paid blow.
- **The engine:** Combat rule 6 turned on the enemy. A modifier applies only when its tags are on the hit, so a hit with its tags struck loses all of L2, and that L2 becomes yours.
- **The sacrifice:** an empty L4, no crit, no way out of a fight, and a name. It has nothing to take from a plain fighter.
- **The arc:** first a weak cultivator with arts nobody can resist or use. Then a hunter of specialists. At the end, every name at once.

## The Legend

The Bureau of Registers kept the names of every disciple in the old sects, and it had one punishment worse than death: a clerk scraped the name from your tablet, your lineage and your manuals, and you went on living with nothing to answer to. The Bureau found what followed by accident. A ward is a thing of rules, and rules need something to read. Those it had erased walked through wards like weather.

Most of them went quietly mad. The ones who kept working learned that the scraper works on other people too. They hunt the famous now, because the famous have the most to lose. Sects put bounties on them and cannot write the bounties, since nobody remembers who to name. A struck cultivator buys bread from the same seller for forty years and is greeted as a stranger each morning.

## How It Fights

Each second, the cultivator makes one small stroke in the air. It does nothing you can see, and the enemy's great technique goes flat in their hands, then comes back at them in a stranger's voice. Their ward has no rule for what is hitting it and burns everything trying. **The signature moment:** a sword saint with a lifetime of Sword modifiers, one realm higher, dies sooner than a nobody would, because all that L2 changed sides.

## Enabler

**Struck Name (Tước Danh).** The keystone at the far end of Struck Register. The player earns it with seasons on a scraped manual, then pays for it in who they are.

- **Opens:** art records may carry no tags. A bare hit has no kind, so a ward reads it on `default_ward_pass` 0.70 and `default_ward_drain` 2.0, whatever spell the enemy wears; `ws` and `we` still apply. Body guard reads it at the qi share. Tag-based curses, `pass_tag` terms and ground tags cannot touch it.
- **Closes:** a bare hit cannot crit and gains no tag-keyed modifier. Every slotted art must be bare, so no talisman and no escape art. Bare arts carry no status, conversion or trigger, except Unnamed.
- **After the fight:** presence (mị lực) −20 for life, and no sect can keep a record of this character. The caller applies it (rule 14).

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Rate | Art speed (`art_speed_pct`) | +30, which puts the first stroke at 1 s | Flat | art | none | ◐ | Tree | every art build |
| Multiplier | Damage (`attack_pct`) | +200. With no tagged nodes worth buying, the W all goes here | Increased | any | L1 | ● | Tree | every build |
| Multiplier | **Borrowed Name (Mạo Danh)** | While the enemy is Unnamed, your art hits gain 75 % of the L2 it lost | Borrow | art | L2 | ○ | Struck Register | any curse build |
| Multiplier | Unwritten Margin (Bạch Biên) | +12 for each tag family a hit lacks; +72 on a bare hit | Per | art | L2 | ○ | Way of the Unnamed | any half-stripped art |
| Multiplier | Forgotten Face (Vô Diện) | +2 per point of presence under 45, up to +60; +40 at presence 25 | Per | art | L2 | ○ | Way of the Unnamed | any low-presence rogue |
| Multiplier | Artifact attack (gear) | +150 | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Bare Vessel (Lộ Đỉnh) | +80 while the enemy has under 5 % linh lực. Greater grade, +80. The same modifier has a lesser grade, +30, in Brush Fee, Fortieth Breath, Receiving Hand and Turned-Away; one size would change fights | Conditional | art, basic | L5 | ○ ledger | Struck Register | Burial Shroud, Ninth Bell |
| Reach | Struck Name | Bare hits meet any ward on default terms | Rule swap | art | none | ○ | Keystone | signature |
| Fuel | Art cost, regeneration | −10 %; +3 % per second | Flat | any | none | ● | Tree | sustain builds |
| Survival | **Unnamed (Vô Danh Ấn)** | A curse: the enemy's hits count as having no element or form tags, so their L2 stops for 2 pulses. It carries no tag, so no cleanse matches it | Rule swap | any | none | ○ | Strike the Name | any curse build |
| Survival | Body guard, ward strength | +30 body guard; `ws` and `we` 80 | Flat | any | none | ● | Tree, gear | every build |

**Identity piece:** Borrowed Name. It is the reason a build with no L2 of its own wants to meet the strongest L2 in the world.
**Empty rungs:** L4 is a sacrifice: prepared hits are tag-keyed, so the build is the same in a blind fight. Crit is a sacrifice. Past the cap is a gap: against top-end, stolen L2 would pass the L2 cap, and nothing spends the rest.

| Layer | Points at Core Formation (arts) | Multiplier | Sources |
|---|---|---|---|
| L1 | 200 | ×3.00 | `attack_pct` |
| L2 | 112, or 142 against a typical enemy once it is Unnamed | ×2.12 to ×2.42 | Unwritten Margin, Forgotten Face, Borrowed Name |
| L3 | 150 | ×2.50 | Gear |
| L4 | 0 | ×1.00 | Sacrifice |
| L5 | 0, or 80 with the ward down | ×1.00 to ×1.80 | Bare Vessel |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any. Bare arts read no element | The one build that does not care. The root only sets cultivation speed |
| Key talents | Low presence (mị lực) | The stat every other cultivator wants high is the one that pays here |
| The Way (Đạo) | Way of the Unnamed (below) | Holds Unwritten Margin and Forgotten Face |

## Công Pháp

### Scraped Register Sutra (Tước Bạ Kinh) — main, Địa giai

A cultivation manual with every name cut out of it by a careful clerk. What is left still works, which frightened them.

```json
{"id": "tuoc_ba_kinh", "name": "Tước Bạ Kinh", "tier": 2, "tech_kind": "main",
 "names": ["thuy"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 15}, {"stat": "khi_huyet_pct", "value": 12},
             {"stat": "attack_pct", "value": 12}],
 "abilities": [{"ability_id": "strike_the_name", "unlock_layer": 4},
               {"ability_id": "unwritten_line", "unlock_layer": 6},
               {"ability_id": "worn_name", "unlock_layer": 8},
               {"ability_id": "empty_tablet", "unlock_layer": 10}],
 "seal_clusters": ["struck_register"], "origin": "authored"}
```

**Fit:** Needs key (abilities; `seal_clusters` is unread today) · **Budget:** 15/20 + 12/15 + 12/15 = 2.35 of 3.0

## Arts

Before the keystone these are ordinary qi arts with Water tags. Strike the Name needs the keystone to do anything.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Strike the Name (Tước Danh Thức) | Sutra, 4 | none | 0 | 0.05 | 1.3 s | none | Needs rule |
| Unwritten Line (Vô Tự Hoạch) | Sutra, 6 | none | 2.2 | 0.08 | 2 s | none | Needs key |
| Worn Name (Phi Danh) | Sutra, 8 | none | 2.9 | 0.12 | 3 s | enemy has Unnamed | Needs key |
| Empty Tablet (Không Bài) | Sutra, 10 | none | 2.9 | health 0.06 | 3 s | enemy linh lực below 5 % | Needs key |

- **Strike the Name.** **Effect:** no hit. Applies Unnamed for 2 pulses. With art speed it fires every second, and the first firing lands before the enemy's first hit only if this side opened the fight. **Description:** One stroke, as a clerk would make it.
- **Unwritten Line.** **Effect:** a plain bare hit. **Description:** It leaves no mark that can be described afterwards.
- **Worn Name.** **Effect:** a bare hit that waits for Unnamed, the turn in the loop where Borrowed Name pays. **Description:** Their own technique, in the wrong hands.
- **Empty Tablet.** **Effect:** a finishing hit paid in health, since by now the pool is gone. **Description:** What the Bureau left on the shelf.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Strike the Name, Unwritten Line, Worn Name | Common | A fourth slot stays empty |
| Core Formation | 5 | Strike the Name, Unwritten Line, Worn Name, Empty Tablet | Common | The fifth stays empty: nothing else is bare |
| Nascent Soul | 6 | As above | Common | Two empty. A second bare art would be new content |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Any plain weapons | Artifact, weapon | Generated | L3, one of the few layers a bare hit keeps | Fits today |
| Any armour | Artifact, ward or body | Generated | The defence that crit and escape used to be | Fits today |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Struck Register | Sealed cluster | The keystone, Borrowed Name, Bare Vessel | Needs key |
| 2 | Damage notables | +8 each | L1 is the only layer the W can reach | Fits today |
| 3 | Ward strength and body guard | +8 each | Nothing else keeps them alive | Fits today |

### Hidden cluster idea: Struck Register (Tước Bạ Mạch)

Theme: Heart State (`tam_canh`), what a person is without a name. Water affinity, outer, sealed. Seal: a technique that lists it, for its `seal_seasons`. Size 12, so two notables and one capability, above `cap_min_n`. Small acupoints give `status_resist_pct` and `art_cost_pct`. Notables: Borrowed Name holding Bare Vessel's line, then **Struck Name** at the far end as the capability. The theme is wider than this build: any curse user wants the first half.

## Đạo

**Way of the Unnamed (Vô Danh Đạo).** A new Đạo with no requirement, so it counts toward `dao_open_min`. `theme_stats`: `art_cost_pct`, `status_resist_pct`, `tam_ma_resist_pct`, `stealth`. 20 nodes.

| Branch | Nodes | Signature |
|---|---|---|
| Unsaid (Bất Ngôn), 6 | Art cost lines, passives on tag-free hits | **Unwritten Margin** at the end |
| Unseen (Bất Kiến), 7 | `stealth` lines, passives on presence | **Forgotten Face** at the end; a passive that lets low presence shorten a pursuit |
| Unbound (Bất Trụ), 6 | `tam_ma_resist_pct` and `status_resist_pct` lines | A passive that lengthens curses that carry no tag by 1 pulse |
| **Keystone: Ten Thousand Names (Vạn Danh)** | | A bare hit counts as carrying every tag **for your own modifiers**, and none for the enemy's. L2 from any technique you hold now applies |

The keystone comes late, at 27 points or more, and it is the end of the arc. With +90 of L2 from auxiliary techniques, at Nascent Soul, one realm up does not change: a win at 2.308 s on 50 % health with or without it (`variants/struck-name-nascent.fight.json`, `variants/struck-name-nascent-ten-thousand-names.fight.json`). The hits already break that enemy in the same firings, so its worth is untested and the number is a first guess.

## Progression

Foundation and Nascent Soul rows are `variants/struck-name-foundation.fight.json` and `variants/struck-name-nascent.fight.json`. Their stats are a first guess, because wave 1 kept no input: L1 and L3 scale from the Core Formation file by tree W.

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | A weak hitter: beats a typical enemy in 2.3 s, loses one realm up at 9 s with it on 43 % | Three arts | Finding the manual, and reading what is not there |
| Core Formation | The hunter of specialists | Struck Name | The tablet scraped by their own hand, and the first morning nobody knows them |
| Nascent Soul | One realm up, 50 % health left | Ten Thousand Names | Being offered a sect's bounty on themselves, by a stranger, for a stranger |

## Matchups

All at Core Formation. Shaped enemies set their layers in `enemy_overrides`, and Borrowed Name reads 75 % of whatever L2 they hold.

| Enemy | Result | Why | Input |
|---|---|---|---|
| Typical, same realm | Wins, 2 s, 93 % health | | `sheets/struck-name.fight.json` |
| Typical, one realm up | Wins, 3 s, 34 % health | A close thing: Empty Tablet fires only because the ward crosses 5 % at 3 s | `sheets/struck-name.fight.json` |
| **Specialist, one realm up, L2 250** | **Wins, 2.3 s, 58 % health** | Quicker and safer than the typical enemy, because 187 points change sides. `--without strike_the_name`: loses at 2 s, enemy on 80 % | `variants/struck-name-specialist.fight.json` |
| Ward specialist, pass 0.20, `ws` 150 | Same realm: wins, 2 s, and `--without bare_hit` takes 2.3 s. One realm up: wins 2.3 s on 58 %, and with a kind 3 s on 52 % | A bare hit is read at 0.70 pass whatever spell the enemy wears | `variants/struck-name-ward-specialist.fight.json` |
| **Plain brute, one realm up, L2 0, gear 200** | **Loses, 2 s, enemy on 80 %** | Nothing to strike and nothing to borrow. It has lower raw `M` than the specialist | `variants/struck-name-brute.fight.json` |
| Top-end, same realm | Loses, 1 s, enemy on 98 % | Stolen L2 changes nothing: it never lands | `sheets/struck-name.fight.json` |

**Counter:** a dull old soldier with a good sword. Attack from W and gear from L3 name no tag, so the Bureau's scraper finds nothing. Fast burst also works, since the curse needs one second.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Technique 2.35 of 3.0. All arts inside the lint: 2.20 of 2.21, 2.90 of 2.94 twice. Slots 4 of 5. No thần thức-heavy set |
| Validity | PASS | Water, `dia` reaches Nascent Soul, `tam_canh` is a hidden theme, cluster size within 3 to 12 |
| Stack | PASS | Seven forms: Flat, Increased, Borrow, Per, Conditional, Rule swap, Trade (the keystone). Rungs filled or named. Identity test changes the fight |
| Scaling | PASS | `m_static` 7.50 holds no tag points; arts run at about 16 to 33 by the layer table, against anchors of 5.48 and 210. Strong, as stated |
| The fight | PASS | Constants 60 of 60; selftest clean. Bare hits run through `rules/bare_hit.py`, Unnamed and Borrowed Name through `rules/unnamed.py`, timed exactly. No `cap_hit`. Own linh lực dry at 3 s one realm up, which is the price of a close win |
| Reuse | PASS | Bare Vessel from the ledger. New modifiers scoped by tag or by missing tags. Signature: Struck Name only |
| NPC use | PASS | All passive or guarded. Unnamed is one Breakdown line: `Sword modifiers do not apply: name struck.` |
| Counterplay | PASS | The plain brute, as above; top-end burst |
| Originality | PASS | The Bureau, its names and the scraping are new. Nothing is lifted from a work; the nameless-as-origin idea is old philosophy, not anyone's character |

## Fight Results

Input: `sheets/struck-name.fight.json`. Observations from `_tools/fight_x.py`, the calculator plus the plug-ins the file lists: a paper model, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 93 % health left | 2 s | never | none |
| typical | 1 | Win, 34 % health left | 3 s | 3 s | none |
| typical | 2 | Loss, enemy on 95 % | 2 s | 1.54 s | none |
| top_end | 0 | Loss, enemy on 98 % | 1 s | 1 s | none |
| top_end | 1 | Loss, enemy on 100 % | 1 s | 1 s | none |
| top_end | 2 | Loss, enemy on 100 % | 1 s | 1 s | none |

**Identity test.** `--without borrowed_name`: same realm, the win slips to 2.308 s on 87 % health; one realm up becomes a loss at 6 s, enemy on 51 %. Only 30 points do that, because they carry the ward under 5 % in time for Empty Tablet. That is a knife edge on first-guess numbers. `--without strike_the_name`: one realm up loses at 4 s, enemy on 75 %.

**The surprise.** Two, and the first changed the design.

- Against a plain ward, the bare clause does little: with `--without bare_hit` the same arts as qi give the identical fight one realm up, and 0.3 s more at the same realm (2.308 s on 87 %). Written as body they lose one realm up at 4 s, enemy on 61 % (`variants/struck-name-as-body.fight.json`). The seed's idea, escaping ward rules, is worth little until the enemy has invested in one. That is why the curse and the borrow became the build.
- The stronger the specialist, the sooner they die. A one-realm-up enemy with L2 250 falls at 2.3 s; the typical enemy with L2 40 takes 3 s; a plain brute with L2 0 wins. The order of difficulty runs backwards from their power.

**Unmodelled:** the reference enemies have no cleanse, so "cannot be cleansed" is untested; Forgotten Face and Unwritten Margin are folded into each art's `x`; the presence cost and the lost record are caller rules.

## New Concepts

**Bare hit (vô danh kích).** A hit with no kind and no tags.

- **Rule needed:** Combat rule 4 says every attack has a kind. Formulas D needs a fallback when a ward has no term for a hit, and the Formulas C guard share needs a value for it.
- **Bounds:** only arts under Struck Name, default terms, `ws` and `we` still apply, no crit.
- **Breakdown line:** `Bare hit: ward reads default 0.70 / 2.0.`
- **Other builds:** a mute assassin who strikes only once, and any curse build that wants a curse no cleanse can match.
- **Question for the user:** should a curse be able to reach every tag at once? Rule 8 allows blocking a tag. Unnamed blocks a family, and it is what makes the build work.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Struck Name, bare hit | Needs rule | See New Concepts |
| Unnamed, Strike the Name | Needs rule | Combat rule 8: a curse that blocks tag families, and how the cleanse match treats a tagless curse |
| Borrowed Name | Needs rule | A modifier that reads what a curse removed |
| Ten Thousand Names | Needs rule | A different tag set for own and enemy modifiers on one hit |
| Unwritten Margin, Forgotten Face, Bare Vessel | Needs key | Modifier keys that read missing tags and `mi_luc` |
| Scraped Register Sutra, three arts, Struck Register, Way of the Unnamed | Needs key | Abilities, `seal_clusters`, Đạo data |

## Also Considered

- **Every Name from the start:** bare hits count as every tag for your own modifiers from the first realm. Too clean: it removes the price. It survives as the Đạo keystone.
- **The Blank Ground:** a formation that strips ground tags from both sides, so the fight happens nowhere.
