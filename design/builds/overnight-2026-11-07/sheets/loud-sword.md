# The Loud Sword (Hưởng Kiếm Môn)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 5: "The fantasy everyone picks first: crit and evade as the engine, kept readable under rule 15, with presence above 45 as the stat, Forgotten Face turned inside out. Vanity as the mood, an arena or a palace as the home, and a protagonist who is awful and enjoying it. No enabler, at most 2 rule asks, no elegy."
> **Direction**: Rule 15 wants chance to stay a flavour, so the build takes the dice away. Crit and evade are counted, not rolled, and a fighter who has read you sets where the counts start. The hit is called before it lands, which is exactly what a vain person would do anyway. Hưởng is a pun: 響 to ring out, 享 to enjoy.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Core Formation · **Power level**: strong · **Use**: player build, or an arena champion a whole city is tired of
> **Fit**: 6 Fits today · 15 Needs key · 1 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** art hits on all five layers, with crit at 2.75 at full presence. No draw anywhere: every crit and every slip is on a schedule.
- **The enabler:** none.
- **The loop:** the count fills, the blow is called, the crit lands where it was rehearsed to land. Each blow slipped pulls the next crit half a step closer.
- **The engine:** presence is one pool feeding crit, evade and L2, and being hit spends it. Evade protects the stat, crit ends the fight before it is spent, and the count lets both land on the hits that matter.
- **The sacrifice:** the unrehearsed fight, and any fight that does not go by the script. One realm up, the same person with no Rehearsal dies at 2 s with the enemy on 72 %. It has no soul answer, no cleanse, no escape, and no interest in any of them.
- **The arc:** at Foundation it is a good sword with a good tailor. At Core it starts beating Nascent cultivators it has studied. It stays a performer: nothing here teaches it to fight a stranger.

## The Legend

Gold Terrace (Kim Đài) is a nine-tier arena in the capital, built by a prince who wished to watch cultivators hurt each other from a comfortable chair. Its champion wrote the Mirror Hall Sword Canon: three hundred plates, every one a portrait of the author, and forty pages on which side of the face to give the top tier. The forms have names like bad poetry and must be announced in full. Scholars call it the worst sword manual in print. It has never lost a bout it rehearsed.

So its students rehearse. They hire the opponent's old sparring partners, buy their training logs and walk the bout through in the empty arena with a stand-in, then go out and call the blow to the cheap seats one beat before it lands. They have had a painter flogged for an honest nose and sent a beaten rival's master flowers with the invoice attached. Poisoners are the usual reply. Those who got close report that when the face goes the show stops, the crowd is sent out, and what happens next is not sold. Refunds are available at the door. They are not generous.

## How It Fights

Every art is shouted first. Two counts run on the sheet, one for crit and one for evade, and both are in the Breakdown, so a spectator can read when the next crit is due. A Rehearsal sets where they start. The first blow at them is slipped, because it was always going to be. The answer comes a second later.

**The signature moment:** a Nascent Soul elder swings at Core Formation's champion in front of nine tiers. The first blow passes through nothing. The champion calls "Ten Thousand Geese Bow to the Peak", which is a thrust, and it crits. Two seconds in the elder is on 27 %. At 3 s the third title is finished and so is the elder, with the champion on 31 % and very upset about the sleeve (`variants/loud-sword-mixed.fight.json`, `--gap 1`).

The second script is the matinee: the same person, the same stats, counts set to crit the first thrust. A same-realm opponent is down at t = 1 with the champion on 94 % (`variants/loud-sword-matinee-mixed.fight.json`).

## The Stack

Sizes on new modifiers are first guesses. `[C]` was taken on the stack: a flat crit stack became the two counts and the V of Shown and Forgotten Face.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Multiplier | Damage (`attack_pct`) | +150 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Full Title (Toàn Hiệu) | +40 points to arts with the sword form | More | art | L2 | ○ | Technique | any Sword build |
| Multiplier | Shown Face (Lộ Diện) | +2 per point of presence above 45, up to +60. Forgotten Face inside out | Per | art | L2 | ○ | Cluster | any courtier, duellist or sect envoy |
| Multiplier | Forgotten Face (Vô Diện) | +2 per point of presence under 45, up to +60. **Reused from The Struck Name**, read live here | Per | art | L2 | ○ | Cluster | **Reused** |
| Multiplier | Artifact attack | +100 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Whetstone Water (Ma Thạch Thủy) | +40 points to Sword arts, foreseen fights only | More | art | L4 | ○ | Coating | **Reused from The Fortieth Breath** |
| Multiplier | In Step (Đồng Bộ) | +50 points to a hit landing after one of your arts in the same instant | Conditional | art, basic | L5 | ○ | Cluster | **Reused from The Herd-Child** |
| Crit | Crit chance and damage | +10 chance, +50 damage | Increased | art, basic | none | ● | Tree | every crit build |
| Crit | All Eyes (Chúng Mục) | Per point of presence above 45: +0.4 `crit_chance_pct`, +1 `crit_damage_pct`, +0.5 `evade_pct`, inside Combat's caps | Borrow | any | none | ○ | Cluster | any high-presence build |
| Crit | Rehearsal (Diễn Tập) | Foreseen fights only, a prepared item: you choose where both counts of Called Blow start | Timing | any | none | ○ | Preparation | any Called Blow user; sect examiners |
| Crit | The Answer (Hoàn Chiêu) | +0.5 to the crit count for each hit slipped | Trigger | any | none | ○ | Technique | any riposte build |
| Survival | Evade (`evade_pct`) | +5, with All Eyes reaching the 40 % cap at presence 115 | Increased | incoming | none | ● | Tree | every build |
| Survival | Losing Face (Thất Diện) | Presence reads 1.5 lower per 1 % of maximum health missing, for the fight | Trade | any | none | ○ | Technique | any build reading a talent live |
| Identity | **Called Blow (Báo Chiêu)** | Your crit and evade take no draw. Crit chance adds to a count on each hit you throw; the hit that fills it to 1 crits, and the count falls by 1. Evade does the same on each hit thrown at you, and that hit is slipped. Fortune still shifts what is added | Rule swap | any | none | ○ | Capability, Gilt Line | any crit or evade build; NPC champions the user wants deterministic |

**Identity piece:** Called Blow. One realm up against the mixed enemy, the build wins at 3 s on 31 %. With `--without called_blow`, the same chance as expected values, it loses at 3 s with the enemy on 44 %. Against the fixture one up it wins on 19 %, and without it loses at 2 s with the enemy on 70 %.

**The standing rule: Forgotten Face.** The Struck Name's author wrote a static bonus for a rogue nobody remembers. Here it is read live, so a champion whose face is ruined falls through 45 and comes out the other side. Presence draws a V: +60 at the top, 0 at the line, +60 at the bottom. In the second script, `variants/loud-sword-second-act-mixed.fight.json --gap 1` wins a double knockout on overkill, and `--without "Forgotten Face"` loses it. With both faces out the enemy keeps 18 %.

**Removed together** (`variants/loud-sword-mixed.fight.json --gap 1`): both faces, loss with the enemy on 6 %. The Answer and In Step, the two pieces that sharpen the third second, loss with the enemy on 35 %. Alone, The Answer gives a double-knockout loss and In Step a loss with the enemy on 2 %.

**Empty rungs:** Reach is a sacrifice, and it has no pierce. Past the cap is empty on purpose: presence past 115 still feeds crit, and past that nothing. Fuel is a sacrifice: the pool is spent by 3 s and the fight had better be over.

| Layer | Points at Core | Multiplier | Sources |
|---|---|---|---|
| L1 | 150 | ×2.50 | `attack_pct` |
| L2 | 40, up to 100 | ×1.40 to ×2.00 | Full Title, then either face |
| L3 | 100 | ×2.00 | Gear |
| L4 | 40 | ×1.40 | Whetstone Water. Zero in a blind fight |
| L5 | 50 in step | ×1.50 | In Step |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal, any purity | Sword tags, and mission income to pay the tailor |
| Key talents | Presence (`mi_luc`) 120: a Heavenly roll plus the robe and every pill going. Physique for `n_body` 1.8 | Presence is the build. Effective talents clamp at 150 |
| The Way (Đạo) | Sword, any display nodes the tree rework gives it | None of the engine lives here |

## Công Pháp

### Mirror Hall Sword Canon (Kính Điện Kiếm Điển) — main, Địa giai

Three hundred plates of the author, and a chapter on being looked at.

```json
{"id": "kinh_dien_kiem_dien", "name": "Kính Điện Kiếm Điển", "tier": 2, "tech_kind": "main",
 "names": ["kim"], "layers": 12,
 "bonuses": [{"stat": "attack_pct", "value": 15}, {"stat": "khi_huyet_pct", "value": 15}],
 "abilities": [{"ability_id": "van_nhan_trieu_phong", "unlock_layer": 2},
               {"ability_id": "nguyet_do_ta_tu", "unlock_layer": 5},
               {"ability_id": "nhat_co_khuynh_quoc", "unlock_layer": 8}],
 "seal_clusters": ["kim_tuyen_mach"], "origin": "authored"}
```

Full Title, The Answer and Losing Face are this technique's passives, which is a new key. **Fit:** Needs key · **Budget:** 15/15 + 15/15 = 2.0 of 3.0, the largest 1.0 under the 1.5 single cap.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Ten Thousand Geese Bow to the Peak (Vạn Nhạn Triều Phong) | Canon, 2 | qi, sword | 1.48 | 0.04 | 1 s | none | Needs key |
| The Moon Envies My Left Sleeve (Nguyệt Đố Tả Tụ) | Canon, 5 | qi, sword | 2.2 | 0.08 | 2 s | none | Needs key |
| One Glance Topples the Realm (Nhất Cố Khuynh Quốc) | Canon, 8 | body, sword | 2.94 | 0.12 | 3 s | none | Needs key |

**Effect:** a hit each. **Description:** it is a thrust. It is a slash. It is a slightly larger thrust.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Geese, Moon, Glance | Common ward | The count works, the numbers do not yet |
| Core Formation | 5 | Geese, Moon, Glance | Common ward | Two slots stay empty: nothing else has a good enough name |
| Nascent Soul | 6 | As above | Common ward | Same script, bigger stage |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| A sword with a name longer than the blade | Artifact, weapon | `phi_kiem`, generated | L3 | Fits today |
| Robe of a Hundred Mirrors (Bách Kính Bào) | Artifact, body | `giap`, named | +20 `mi_luc` in place of defence. Vanity paid for in armour | Needs key |
| Whetstone Water | Coating | Reused | L4 in a foreseen fight | Needs key |
| Rehearsal | Prepared item | Costs a season and the opponent's records | The script | Needs key |

## Tree and Clusters

### Hidden cluster idea: Gilt Line (Kim Tuyến Mạch)

Theme NPC Interaction and presence, Metal, outer, sealed by event: win twenty ticketed bouts. Size 10. Small acupoints: crit chance, evade, `mi_luc`. Notables: Shown Face, In Step, then All Eyes. Capability: Called Blow. An idea for the tree rework, not data.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | Wins its own realm at 2 s on 86 %. One up it loses with the enemy on 51 % (`variants/loud-sword-foundation-mixed.fight.json`) | Called Blow | The first ticketed bout |
| Core Formation | Beats a studied Nascent Soul | Rehearsal, All Eyes | The portrait gets a bigger frame |
| Nascent Soul | Same shape: wins one up on 32 % (`variants/loud-sword-nascent-mixed.fight.json`) | Nothing | A Deity sends a note asking them to be quieter |

## Matchups

All at Core Formation. The script is crit 0.15, evade 0.85 unless named.

| Enemy | Result | Why |
|---|---|---|
| Mixed, same realm | Win, 2 s on 88 % | `variants/loud-sword-mixed.fight.json` |
| Mixed, one up | Win, 3 s on 31 % | Same file, `--gap 1` |
| Mixed, one up, unrehearsed | Loss, 2 s, enemy on 72 % | Both counts start at 0: `variants/loud-sword-unrehearsed-mixed.fight.json`. Blind, with no coating, enemy on 79 %: `-blind-mixed` |
| Hawk-eye (`accuracy_pct` 40), one up | Loss, 2 s, enemy on 77 %, no slips | `variants/loud-sword-hawk-eye.fight.json` |
| Poisoner, one up | Loss, 3 s, enemy on 65 % | Ticks cannot be slipped, and each one spends presence: `variants/loud-sword-poisoner.fight.json` |
| Fortress, same realm | Win, 5 s on 76 % | `variants/loud-sword-fortress.fight.json` |
| Top-end, same realm | Loss at t = 1, enemy on 94 % | The sheet's file, `--enemy top_end`. Normal |

**Patronage (Bảo Trợ), which the character does and the build should not.** Paying for a broke enemy's art so it can be slipped is exactly the vanity this person would pay for, and it is The Brush Fee's piece used for a reason its author never had. The numbers say no: the fortress win falls from 5 s on 76 % to 9 s on 6 %, for 465 linh lực (`variants/loud-sword-fortress-patron.fight.json`, and `--without patronage_open`). It is left out of the build, so the rule asks stay at 1.

Enemies are the reference fixtures with the mixed arts, so they carry no element and divine sense 1.0. The hawk-eye's accuracy and the poisoner's `c_tick` 0.6 are first guesses, set in their files.

**Counter:** a poisoner or an accurate enemy who is one realm up, or anyone who arrives unannounced. It is at its worst against a stranger on a road.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts within the lint, slots 3 of 5, technique 2.0 of 3.0. Thần thức is not totalled |
| Validity | PASS | `kim`, tier `dia` reaches Nascent Soul, bases `phi_kiem` and `giap`. `mi_luc` is a real flat key on the sheet (Character Stats), not yet an item bonus |
| Stack | PASS | 9 forms. Rungs filled or named. Forgotten Face tested live, both faces removed together |
| Scaling | PASS | `m_static` 5.00 against typical 5.48 and top-end 210. INFO: tagged M reaches ×21 on an art in step |
| The fight | PASS | All three arts fire, no cap hit in the matrix, counts land as written. Two of the one-up wins in other scripts are double knockouts on overkill, and the sheet says which |
| Reuse | PASS | Forgotten Face, Whetstone Water, In Step. Signature pieces: none |
| NPC use | PASS | An NPC runs Called Blow with both counts at 0. One Breakdown line: count 0.85 + 0.40, slipped |
| Counterplay | PASS | Accuracy and ticks, both Combat rule 18 types |
| Originality | PASS | Names checked. The Hán-Việt art titles are built from classical beauty idiom, not from any novel |

## Fight Results

Input: `sheets/loud-sword.fight.json`. Observations from `fight_x.py`, a paper model. Called Blow is counted, not an expected value, so this build's results are exact under the rule as stated, and the enemy's chance stays an expected value.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | win, 88 % left | 2 s | never | none |
| typical | 1 | win, 19 % left | 3 s | 2 s | none |
| typical | 2 | loss, enemy on 94 % | 2 s | 2 s | none |
| top_end | 0 | loss, enemy on 94 % | 1 s | 1 s | none |
| top_end | 1 | loss, enemy on 99 % | 1 s | 1 s | none |
| top_end | 2 | loss, enemy on 100 % | 1 s | 1 s | none |

**Presence, one realm up against the mixed enemy** (`variants/loud-sword-presence-[45|75|95]-mixed.fight.json`, `--gap 1`): 45 loses with the enemy on 12 %, 75 on 39 %, 95 on 4 %, 120 wins. 75 is worse than 45: the middle of the V is the worst place to stand, so the only thing this build fears is being average.

**The grid** (`variants/loud-sword-grid.fight.json`): of 400 scripts at steps of 0.05, 40 win both one-up fights, 72 only the mixed one, 12 only the fixture, and 276 lose both. A script is a real choice, and the file's own is one of the 40.

**Unmodelled:** the arena, the crowd, the prices and who comes looking.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Called Blow | Needs rule | Combat rule 15 and Formulas C, I: a side may count chance instead of drawing it. It makes that side deterministic, which is what rule 15 says the design aims at. This is the build's only rule ask |
| Rehearsal | Needs key | A prepared item under rule 12 that sets two starting values |
| The Answer | Needs key | One event on the count Called Blow creates |
| Shown Face, All Eyes, Losing Face | Needs key | Per keys on `mi_luc`, and presence read during a fight. Forgotten Face needs the same |
| Full Title, canon, three arts, the robe, Gilt Line | Needs key | Ability records, a `mi_luc` affix |

## Questions for the User

- A counted crit is worth more than a rolled one at the same rate, because it can be aimed: same stats, a loss with the enemy on 44 % becomes a win on 31 %. Should Called Blow cost something for that, or is the fragility of the script the price?
- May a talent be read live in a fight? Combat compiles once. Losing Face needs one more exception to that.
- Should the arena be real, with tickets and a purse? Quests and Sects & Missions could carry it.

## Also Considered

- **The Peacock's Debt:** crit stored as a loan against the next fight's presence. Good joke, but it needed a second rule.
- **The Duelling Prince:** evade from a retinue that takes the blow. The fantasy moved off the sword.
