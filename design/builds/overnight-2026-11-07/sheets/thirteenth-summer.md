# The Thirteenth Summer (Thập Tam Hạ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "One innate root with no parents, defined at Qi Refining, your own idea. Make it something the user would never have thought of."
> **Direction**: The Cicada Root. You are awake one year in thirteen. The other twelve you lie in the ground, and the ground pays one art's cooldown for you. A cicada never meets its parents, so "no parents" came for free.
> **Realm span**: Qi Refining – Foundation Establishment, defined at Qi Refining · **Power level**: legend for 0.5 s every thirteen years, a poor Qi Refining the rest of the time · **Use**: player build, or a world event
> **Fit**: 3 Fits today · 8 Needs key · 3 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: thần thức not totalled, and the Long Note is outside the lint's range by design; The fight's real cost, the years, is outside the fight)

## The Spine

- **The channel:** one art hit, the Long Note, carrying the whole stack at once. L1 to L4 filled on that art.
- **The enabler:** the Cicada Root. It opens an art whose timer runs while you are buried. It closes twelve years of every thirteen.
- **The loop:** wake, ask what happened, choose one person, sing once, go back to the ground.
- **The engine:** the art lint is linear in cooldown, and it sells a long wait for a large coefficient. Every other way past that wait skips it. This one pays it, in years of a life.
- **The sacrifice:** nearly everything, including the people you knew.
- **The arc:** thirty wakings in a Qi Refining lifespan. Each one finds the world further on and the same person.

## The Legend

In the hill country they say a child who does not cry at birth has gone quiet to listen. At twelve such a child fell asleep in a dry bean-field, and the family dug the small grave themselves, and went home, and thirteen years later something scratched at the door at the start of summer. They were twelve still, or near it. They wanted to know whether the bean-field had been planted. They wanted to know everything: who had married, why the bridge was gone, what the new tax was for, whether anyone had fed the dog. Their mother was old, and held them, and answered for as long as the summer lasted, and in the autumn walked with them to the field.

There are a few of them in the world, all on the same calendar, and that year they can hear each other from a long way off. They have never met a parent who remembered the same things they did. They are not sad in the way people expect. They come up each time very glad and very curious, and they ask, and someone has usually died, and they ask about that too. When a stranger is cruel to the place they come from they will spend the one thing they have, and then they have to go back down, and they will not find out how it ended for thirteen years.

## How It Fights

For half a second nothing happens. Then one note, and the fight is over or the summer is wasted. A second fight in the same year is a child with two poor arts.

**The signature moment:** a Qi Refining kills a Core Formation elder at 0.5 s and takes no damage, with an art the lint reads as `within`, and the output line says `paid 576 s`, `owed 0 s`. Forum Build's rule was "a wait is paid, never deleted". This is the first build that pays it.

## The Root

**Cicada Root (Thiền Căn).** Innate, with no parents in the rule's sense or the insect's.

| Field | Value |
|---|---|
| **Origin** | Innate (Thiên Sinh), rule 9 |
| **Requirement** | None. Reads no element |
| **Roll** | Birth only, flat `innate_chance` 0.001, about five in a world of 5,000. Purity from the birth distribution, fixed for life (rule 10). A Self-made life may pick it at `purity_mean` |
| **Per purity point** | One buried season pays 0.2 s of one named art's authored cooldown |
| **The calendar** | From the first Qi Refining level, you are buried 12 years of every 13, as forced closed-door cultivation. You wake in the Brood Year, four seasons, the same year for every holder |
| **Buried** | You age at a quarter speed, so a cycle costs 4 years of lifespan, and a Qi Refining lifespan of 120 holds 30 cycles, 390 years. No events, no arts, no ward: you are a sleeping body. You may sleep through a waking, and the wait keeps paying, up to 3 cycles. Breakthrough only while awake |
| **The Long Note** | The named art is authored at burial with the cooldown you intend to pay. Its timer is run down by what was paid, but never below `cooldown_min`, so it fires at 0.5 s. Once fired it stays on that whole cooldown |

```json
{"id": "thien", "name": "Thiền", "name_en": "Cicada", "origin": "innate", "requires": [],
 "desc": "Twelve years under the roots. One summer."}
"thien": [{"stat": "buried_seconds_per_season", "per_purity": 0.20}]
```

One waking at purity 60: 0.2 × 60 × 48 seasons = 576 s, and `c_art` 145.23 at cost 0.04, which is what the lint sells for 576 s.

**Meridian Map.** Element sectors are untouched: the root reads no element. Its own sector follows rule 12, with a spur off an inner radial like the other innate variants, scaled by `0.5 + purity / 100`, so 1.10 at purity 60. Theme: `art_cost_pct`, `body_guard_pct`, `than_thuc_pct`, all weighted stats. Points accrue only while awake, so the tree fills slowly, and at Qi Refining this sheet takes it as thin.

**Existing variants.** As an innate variant it counts once toward `n_eff` (rule 3), so a single root cultivates on the dual curve. Wind, Blood and Void roll independently. Wind's travel is worth little in a four-season life. Void's fortunate encounters are worth a lot, since a whole life's events fit in thirty summers. Mutation Awakening is untouched. Capability #7, Embryonic Breath, does not stack with the buried rate.

**The cost.** Twelve years in thirteen. A dug-up cicada is the weakest thing in the game. Everyone you know ages on the far side of the soil. And it is a one-shot: the second fight of the year is lost.

## The Stack

Sizes on new modifiers are first guesses. An ordinary stack on one strange timer.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | The Long Note (Trường Minh) | c_art 145.23, authored cooldown 576 s, cost 0.04 | none | art | none | ○ | Technique | signature |
| Rate | **Paid in the Ground (Địa Thường)** | One art's timer runs while you are buried | Timing | art | none | ○ | Root | any long seclusion rule, if the user wants one |
| Multiplier | Damage (`attack_pct`) | +20 | Increased | any | L1 | ● | Tree | everyone |
| Multiplier | Slow Art Damage (Hoãn Pháp Thương) | Small +3, notable +15, on arts with an authored cooldown of 10 s or more. Two notables: +30 | Increased | art | L1 | ○ | Tree | The Fortieth Breath, any long-cooldown art |
| Multiplier | Heavy Note (Trọng Âm) | +20 to arts with an authored cooldown of 20 s or more. Two taken: +40 | More | art | L2 | ○ | Tree | The Fortieth Breath, Forum Build |
| Multiplier | Weapon | +40 | Increased | any | L3 | ● | Artifact | everyone |
| Multiplier | Slough Powder (Thiền Thoái Tán) | +40 to your next art, a pill ground from your own last husk | More | art | L4 | ○ | Pill | any first-strike build, with any husk |
| Certainty | Measured Stroke (Định Trảm) | **Reused from The Fortieth Breath.** Arts with an authored cooldown of 20 s or more cannot be evaded and cannot crit | Trade | art | none | ○ | Technique | **Reused** |
| Survival | Ward strength | `ws` 30 | Increased | any | none | ● | Gear | everyone |

**Identity piece:** Paid in the Ground. `--without buried_years --gap 2`: dead at 1 s, enemy on 99 %.

**The standing rule, used unplanned.** Measured Stroke was written so a forty-second cut could not be dodged. Here it guards thirteen years. Main fight, `--gap 2`, a hunter with evade 25: win at 0.5 s. `--without accuracy_pct`: the same note, expected value 75 %, and you are dead at 2 s with the enemy on 42 %. In a real roll that is one miss and a thirteen-year wait.

**Empty rungs:** crit, given away by Measured Stroke. Pierce was tried and cut: removing it changed nothing at two realms up. L5 is a gap. Survival is a sacrifice: the plan is that nothing lands.

| Layer | Points on the Long Note | Multiplier | Sources |
|---|---|---|---|
| L1 | 50 | ×1.50 | Damage, Slow Art Damage |
| L2 | 40 | ×1.40 | Heavy Note |
| L3 | 40 | ×1.40 | Weapon |
| L4 | 40 | ×1.40 | Slough Powder. A foreseen fight: a waking year is nothing but foresight |
| L5 | 0 | ×1.00 | Gap |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any, plus Cicada at 60 | The root reads no element |
| Key talents | None | |
| The Way (Đạo) | None. Sense and fortune stay at their defaults (1.0 and 50) in every file | Thirty summers is too little |

## Công Pháp

### Under the Roots Method (Căn Hạ Quyết) — main, Hoàng giai

Three pages. It says how to breathe when there is no air, and when to start digging.

```json
{"id": "can_ha_quyet", "name": "Căn Hạ Quyết", "tier": 0, "tech_kind": "main",
 "names": ["thien"], "layers": 6, "bonuses": [],
 "abilities": [{"ability_id": "truong_minh", "unlock_layer": 1}, {"ability_id": "bao_tho", "unlock_layer": 2}, {"ability_id": "kho_minh", "unlock_layer": 3}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** no bonuses, 0 of 1.0.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| The Long Note (Trường Minh) | Method, 1 | qi, song | 145.23 | 0.04 | 576 s | none | Needs rule |
| Scrabble (Bào Thổ) | Method, 2 | body | 1.48 | 0.04 | 1 s | none | Needs key |
| Dry Click (Khô Minh) | Method, 3 | qi | 1.48 | 0.04 | 1 s | none | Needs key |

**Effect:** a hit each. **Description:** the one thing you came up to say, and the two things you can do afterwards.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Slough Powder (Thiền Thoái Tán) | Pill | From your last husk | L4 +40. Each waking leaves one husk, so one powder a year. Without it (`-blind`), the note still kills one realm up, but at two up you die at 2 s with the enemy on 51 % | Needs key |
| Hidden Pit (Ẩn Huyệt) | Formation, ground | New | Hides the burial. Twelve years of upkeep nobody is awake to pay, so someone has to love you enough to do it. Unmodelled | Needs key |

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | One note a brood | The husk, the powder | Their mother answers questions |
| Qi Refining, a century on | One note, chosen better | Sleeping through a waking | Nobody left who knew the bean-field |
| Foundation Establishment | The same note on a bigger unit: kills a Nascent Soul at 0.5 s (`-foundation --gap 2`) | One more slot | They are older now than their mother was |

## Matchups

Main fight: `sheets/thirteenth-summer.fight.json`, the mixed arts with evade 25, purity 60, one waking.

| Enemy | Result | File |
|---|---|---|
| Typical, own realm to two up | Win at 0.5 s, untouched | main file, `--matrix` |
| Top-end, own realm and one up | Win at 0.5 s, untouched | main file, `--matrix` |
| Top-end, two up | Dead at 1 s, enemy on 86 % | main file, `--gap 2 --enemy top_end` |
| Typical Nascent Soul, three up | Dead at 1 s, enemy on 88 % | main file, `--gap 3` |
| The same, two wakings slept | Dead at 1 s, enemy on 76 % | `-two-broods --gap 3` |
| The same, three wakings slept | Dead at 1 s, enemy on 63 %. The ceiling holds | `-three-broods --gap 3` |
| Mixed, no evade, two up | Win at 0.5 s | `-mixed --gap 2` |
| One jab and nothing else, two up | Win at 0.5 s | `-one-jab --gap 2` |
| Purity 30, one and two up | Win at 0.5 s; dead at 1 s, enemy on 68 % | `-purity-30 --gap 1`, `--gap 2` |
| Purity 90, two up | Win at 0.5 s | `-purity-90 --gap 2` |
| Second fight of the year, own realm | **Dead at 5 s, enemy on 44 %** | `-second-fight` |
| Dug up three years in, own realm | **Dead at 5 s, enemy on 44 %, 432 s still owed** | `-dug-up` |
| Quick enemy, an art on 0.5 s, two up | Both go down at 0.5 s, won on overkill, own health 0 | `-quick-enemy --gap 2` |
| Per-hit ward, pass 0.2, `ws` 100, two up | **Dead at 1 s, enemy on 75 %** | `-per-hit-ward --gap 2` |

**Counter:** send someone else first. Its one note is spent on the first fight of the year, and a sect that knows the calendar can walk a servant up the road. A per-hit ward blocks a share of any blow for a flat price, so it is the one ward that does not care how big a note is. And the grave: a hunter with a map and a spade (an ambush, Combat rule 12, in the off season).

## Swap Test

| Fight | Cicada Root | Plain root, same art at the 30 s limit | Plain root, three ordinary arts |
|---|---|---|---|
| Hunter, two realms up | Win at 0.5 s, untouched | **Dead at 1 s, enemy on 99 %** (`-plain --gap 2`) | **Dead at 1 s, enemy on 97 %** (`-plain-best --gap 2`) |
| Hunter, own realm | Win at 0.5 s, untouched | **Dead at 5 s, enemy on 44 %** (`-plain`) | **Dead at 7 s, enemy on 10 %** (`-plain-best`) |

The plain file uses c_art 8.73 at 30 s, the best the lint allows a plain root at cost 0.04, and it never fires.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | 3 of 3 slots. The lint prints `within`, but Formulas A2 and AC-CB-57 stop cooldowns at 30 s and c_art at 12, and this art is past both by design, so it needs the rule below. Thần thức not totalled |
| Validity | PASS | Tier 0 reaches Foundation Establishment. Fields real |
| Stack | PASS | Forms: Timing, Increased, More, Trade. L5 empty and named |
| Scaling | PASS | `m_static` 1.68 as printed, 4.12 on the note, against typical 3.27 at Qi Refining. INFO: a Qi Refining kills two realms up |
| The fight | NOT ASSESSED | The note fires at 0.5 s in every file. But the engine's real price is twelve years in thirteen, which no fight sees. The fight proves the hit, not the life |
| Reuse | PASS | Measured Stroke proved in the main fight. Second homes named, one signature piece |
| NPC use | PASS | An NPC holder needs one rule: wake, spend it on whoever is highest in reach, go back. The Brood Year is world data |
| Counterplay | PASS | A decoy, a per-hit ward, a spade |
| Originality | PASS | Cicada lore is natural history. Thiền thoái is an ordinary medicine name |

## Fight Results

Input: `sheets/thirteenth-summer.fight.json`. Rule `buried_years`. Observations from `_tools/fight_x.py`, a paper model.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0, 1, 2 | Win, 100 %, pool 96 % | 0.5 s | never | none |
| top_end | 0, 1 | Win, 100 %, pool 96 % | 0.5 s | never | none |
| top_end | 2 | Dead, enemy on 86 % | 1 s | 1 s | none |

**Unmodelled:** accuracy 40 stands in for Measured Stroke, as in The Fortieth Breath, and it also helps the two small arts. The years, the pit, the brood, and who is left.

## New Concepts

**The Brood Year (Thiền Niên).** One year in thirteen, world-wide. Rule: a new line in Realms & Bottlenecks' closed-door cultivation, forced on the root's holders. Bounds: four seasons awake, three cycles at most. Breakdown line: "Thiền: paid 576 s of 576 s." Other uses: a known date for sects to fear, and a calendar a player can plan a life around. NPCs: yes, by schedule. Thirteen is prime, so it rarely lines up with a sect's own cycles of six or four, which is why cicadas do it.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Cicada Root | Needs rule | Spiritual Roots rule 9, one new innate row |
| Paid in the Ground | Needs rule | Combat rule 13 and Formulas A2: a timer that survives between fights, and a cooldown above 30 s for this art only. It takes Forum Build's sentence as written, and reports the seconds paid |
| Brood Year | Needs rule | Realms & Bottlenecks: forced seclusion at a quarter of the aging rate |
| Slow Art Damage, Heavy Note, Slough Powder, Hidden Pit, arts, technique | Needs key | Records as above |

## Also Considered

- **Half a Root:** a root shared with one living stranger, whose purity plus yours is 100. Strong, and it depends on an NPC's life more than yours.
- **The Sense Root:** a root in the ear, not the dantian, from the old six sense-roots, that hears cooldowns. Elegant, and closer to a keystone than a root.
