# The Worst Root (Độn Căn Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The Worst Root: five weak elements, scaling per element held, the wasted-talent fantasy turned round. Faith or stubbornness as the mood."
> **Direction**: A ward is a filter tuned to refined force. This root produces nothing refined. Its hits split into a thin stream per element held, and any stream too small to notice goes straight through. So the build must stay weak on purpose, and being offered a cure is a real threat.
> **Realm span**: Qi Refining – Deity Transformation, defined at Deity Transformation · **Power level**: strong against wards, ordinary without one to ignore · **Use**: player build, or the old monk nobody thought to count
> **Fit**: 7 Fits today · 5 Needs key · 3 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: thần thức not totalled, and L2 has no W price; NPC use: an NPC would have to know its enemy's body to size its hits)

## The Spine

- **The channel:** art hits and the basic attack, split into parts that never meet the ward. L1, L2 and L3 filled up to a line. L4 refused. L5 empty.
- **The enabler:** the Dull Root. It opens ward-free hits, and it closes every ordinary way of getting stronger.
- **The loop:** seven small arts every second, every one the same size as yesterday.
- **The engine:** a part under the line ignores the ward, and the line is a share of the target's body. So the build has a size it must not pass. Every element held adds a part, which is more force under the same line.
- **The sacrifice:** more. More damage, a pill before the fight, a purer root: each can lose the fight outright.
- **The arc:** one art, then one more at each realm, like beads added to a string. It is at its worst at the start and it gets better only by outlasting everyone.

## The Legend

The testing stone at the mountain gate lit five dull colours for the child from the charcoal village, and the examiner, who was kind, took him aside and explained. Five roots that weak will not carry a person out of Qi Refining before they die of age. He should go home. They stayed anyway and swept the steps. The sect gave them the old sutra nobody wanted, written by someone who had nothing else to offer, and they recited it each morning and tried the same small art each morning, and it did what it always did, which was very little.

They are not proud of this. They do not think they were right. When a Marrow-Cleansing Pill was offered to them, late on, out of pity, they held it for a long while and gave it back, and could not say why, except that they had already become something and did not want to start again. People forget them. The wards do too. Those who have fought them say it felt like nothing at all, and that this went on, and that they looked down and saw what had happened.

## How It Fights

Seven beads, once a second, each hit falling apart into five thin streams. Nothing flashes. The enemy's ward does not move, and neither does their linh lực. Their health just falls.

**The signature moment:** a Deity with a top-end ward is dead at 2 s, and the fight line reads `enemy_linh_luc_burned_by_ward 0.0`. Add 20 points of damage to the same character and they lose, with that enemy on 46 % (`variants/worst-root-warded.fight.json`, `variants/worst-root-warded-stronger.fight.json`).

## The Root

**Dull Root (Độn Căn).** Độn căn is the old word for a person of slow capacity, the one the teachings are said to be for.

| Field | Value |
|---|---|
| **Origin** | A new derived origin, Residual (Tàn Dư): it reads its parents upside down |
| **Requirement** | `n_base` ≥ 3, and every owned element below purity 50 |
| **Roll** | None. Chance 1 whenever the requirement is first met: at birth, or when a root change meets it. It is a diagnosis, not a blessing. A Self-made life may decline it (rule 2) |
| **Purity** | `round(100 − 2 × mean purity of owned elements)`, recomputed as rule 10 does for derived variants. 1 to 80, the derived ceiling. Five at 20 is 60 |
| **Per element held** | Every art hit and basic attack splits into one equal part per base element, each with that element's tag. Rule 6's limit of 2 conversions is lifted for this root |
| **Per purity point** | The line rises by 0.05 % of the target's maximum health. `attack_pct` −0.5 |
| **The line** | A part smaller than the line, before the ward, skips the ward: nothing is blocked and no linh lực is touched. A part at or over the line meets the ward as usual. Evade and body guard still apply |

```json
{"id": "don_can", "name": "Độn Căn", "name_en": "Dull", "origin": "residual", "requires": [],
 "desc": "Five poor streams. No ward was ever built to notice them."}
"don_can": [{"stat": "ward_skip_line_pct", "per_purity": 0.05}, {"stat": "attack_pct", "per_purity": -0.50}]
```

**Odds.** Of 2,000,000 Fated births, 2.174 % qualify, and 0.0405 % reach purity 60 or more (`variants/worst-root-birth.fight.json`, seed 1). That makes it the commonest variant in the game, and nearly every holder has a useless one. It raises the 12.14 % of Formulas D accordingly, which needs a ruling.

**Meridian Map.** The root's own sector follows rule 12: 30 acupoints, hidden until owned, scaled by `0.5 + purity / 100`, so 1.10 at purity 60. The element sectors do not invert. Five at 20 scale 0.7 each. This sheet takes the tree at 0.7 of each realm's W, plus the sector's gain of 35 W over the same points at 0.7. Bought points are never refunded. The sector theme is `art_speed_pct`, `linh_luc_regen_pct` and `ward_efficiency_pct`, all weighted stats.

**Existing variants.** It lives beside any of them. Thunder or Chaos on elements this weak will be poor, and they add nothing to the parts. Innate variants still raise `n_eff` and not the part count, because parts read `n_base`. A technique naming only this root runs at its purity (rule 8), which is the root's way out of Qi Refining: by Cultivation Techniques' `tech` formula, a method naming a purity-20 element runs at about 0.3 of the table's rate, so Formulas B's 50 years becomes about 160 against a lifespan of 120. Naming the root at purity 60 runs near the table's rate.

**Root changes.** A Tẩy Tủy Đan lowers this root's purity: +8 on one of five is −3 purity, and three pills take 60 to 50. A Linh Căn Quả adds a part, at a small cost in purity. So it wants fruit and refuses medicine, and it does not need a rule for that.

**The cost.** Damage −30 at purity 60. Element sectors at 0.7. The Way mostly closed: most requirements ask 25 to 40 in one element. A size you must never pass, sized against an enemy you have not met.

## The Stack

Sizes on new modifiers are first guesses. Sized for an ordinary Deity's body: a part of about 298 against a line of 315.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | The Seven Beads | Seven arts at c_art 1.48, cost 0.04, 1 s. The lint's floor of cost | none | art | none | ○ | Technique | any many-hit build |
| Rate | More slots by realm | 3 to 7 arts | none | art | none | ● | Combat | everyone |
| Multiplier | Damage, Split Hit Damage (Phân Kích Thương) | +150 before the root's −30. Split Hit Damage: small +2, notable +12, on hits with three or more parts | Increased | any | L1 | ● ○ | Tree | any Conversion build |
| Multiplier | Many Streams (Đa Lưu) | +20 per notable to arts that split, two taken: +40 | More | art | L2 | ○ | Tree | The Kept Hearth, any Conversion build |
| Multiplier | Worn weapon | +30 | Increased | any | L3 | ● | Artifact | everyone |
| Reach | **Even Streams (Phân Lưu)** | A hit splits into one part per base element | Conversion | any | none | ○ | Root | any many-element build |
| Reach | **Unfelt (Bất Giác)** | A part under the line skips the ward | Rule swap | any | none | ○ | Root | any build of very small hits |
| Fuel | Regeneration | +6 | Increased | any | none | ● | Tree | everyone |
| Fuel | Thrift (Tiết Dụng) | **Reused from The Deepest Well.** A quarter of ward efficiency counts as `art_cost_pct` | Redirect | art | none | ○ | Tree | **Reused** |
| Survival | Ward strength, efficiency, maximum health, maximum linh lực, body guard | `ws` 225, `we` 126, `n_body` 1.95, `n_qi` 1.86, guard 86 | Increased | any | none | ● | Tree, gear | everyone |
| Trade | Dull Hand (Độn Thủ) | `attack_pct` −0.5 per purity point | Trade | any | L1 | ○ | Root | signature |

**Identity piece:** Unfelt, with Even Streams. They are one root and `--without turbid_root` removes both.

**The standing rule, used unplanned.** Thrift was written for someone guarding a deep pool. Here it pays for seven beads. Main fight: win at 3 s on 11 %. `--without ward_thrift`: dead at 3 s, enemy on 4 %. Thrift and regeneration share a job, so removed together (`variants/worst-root-no-fuel.fight.json`): dead at 3 s, enemy on 19 %.

**Empty rungs:** crit is a sacrifice, since a crit can carry a part over the line. L4 is refused, and that is the build's strangest rule. Past the cap is empty. Rate has no modifier beyond slots: the arts are already at 1 s and the fuel will not bear more.

| Layer | Points at Deity Transformation | Multiplier | Sources |
|---|---|---|---|
| L1 | 120 | ×2.20 | Damage 150, Dull Hand −30 |
| L2 | 40 on arts | ×1.40 | Many Streams |
| L3 | 30 | ×1.30 | Weapon |
| L4 | 0 | ×1.00 | Refused |
| L5 | 0 | ×1.00 | Gap |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | All five, near purity 20, Dull Root 60 | Five parts. In a Fated life, three at low purity and two fruits is the realistic road, at lower purity |
| Key talents | None | That is the point |
| The Way (Đạo) | None. Sense and fortune stay at their defaults (1.0 and 50) in every file | Requirements are out of reach |

## Công Pháp

### Five Dregs Sutra (Ngũ Trọc Kinh) — main, Thiên giai

Written by someone who failed, for people who will. It names only the root.

```json
{"id": "ngu_troc_kinh", "name": "Ngũ Trọc Kinh", "tier": 3, "tech_kind": "main",
 "names": ["don_can"], "layers": 15,
 "bonuses": [{"stat": "linh_luc_pct", "value": 12}, {"stat": "khi_huyet_pct", "value": 10}, {"stat": "defense_pct", "value": 10}],
 "abilities": [{"ability_id": "that_chau", "unlock_layer": 1}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 12/20 + 10/15 + 10/15 = 1.93 of 4.0. A top tier for a despised sutra is a question: see New Content Needed.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Wood, Fire, Earth, Metal and Water Beads (Mộc, Hỏa, Thổ, Kim, Thủy Châu) | Sutra | qi and body in turn, all five elements | 1.48 | 0.04 | 1 s | none | Needs key |
| Counted Bead (Niệm Châu) | Sutra | body | 1.48 | 0.04 | 1 s | none | Needs key |
| Dedication (Hồi Hướng) | Sutra | qi | 1.48 | 0.04 | 1 s | none | Needs key |

**Effect:** a hit each, in five parts. **Description:** the same small act, because it is the only one you have.

## Progression

Hits are sized to each realm's ordinary body. A plain root of the same stack at Qi Refining is dead at 4 s with the enemy on 25 % (`-qi-refining-plain`).

| Realm | Arts | Against the mixed enemy | File | Story beat |
|---|---|---|---|---|
| Qi Refining | 3 | Win, 3 s on 42 % | `-qi-refining` | The examiner was right about the years |
| Foundation Establishment | 4 | Win, 2 s on 68 % | `-foundation` | Nobody noticed |
| Core Formation | 5 | Win, 2 s on 70 % | `-core` | Still nobody |
| Nascent Soul | 6 | Win, 2 s on 72 % | `-nascent` | Pity offered |
| Deity Transformation | 7 | Win, 2 s on 80 % | `-mixed` | The curve (n_eff 5, ×9.0) arrives at last |

## The Line

A warded Deity: typical body, top-end ward, mixed arts (`variants/worst-root-warded.fight.json`). The line is 315, the part about 298. Every row is one change.

| Change | Result | File |
|---|---|---|
| None | **Win, 2 s on 80 %, enemy's pool 92 %** | `-warded` |
| +20 damage | **Dead at 4 s, enemy on 46 %** | `-warded-stronger` |
| One pill before the fight, L4 +40 | **Dead at 4 s, enemy on 11 %** | `-warded-foreseen` |
| Three Tẩy Tủy Đan, purity 50 | **Dead at 4 s, enemy on 49 %** | `-warded-cured` |
| Four elements, not five | **Dead at 4 s, enemy on 50 %** | `-warded-four` |
| Three elements | **Dead at 4 s, enemy on 50 %** | `-warded-three` |
| A plain root | **Dead at 4 s, enemy on 67 %** | `-warded-plain` |

A foreseen fight is worse for this build than a blind one. A build that prepares loses. Against the main fight's hale body the line is far away and these changes do nothing (`-stronger`, `-foreseen`, `-four-elements`, `-three-elements` all win at 3 s on 11 %), so sizing is a bet on who you will meet.

## Swap Test

| Fight | Dull Root | Plain root, same purities | Plain, rebuilt for damage |
|---|---|---|---|
| Main fight | Win, 3 s on 11 % | **Dead at 4 s, enemy on 88 %** (`-plain`) | **Dead at 3 s, enemy on 93 %** (`-plain-best`) |
| Warded Deity | Win, 2 s on 80 % | **Dead at 4 s, enemy on 67 %** (`-warded-plain`) | not run |
| Qi Refining, mixed | Win, 3 s on 42 % | **Dead at 4 s, enemy on 25 %** (`-qi-refining-plain`) | not run |
| Deity, mixed enemy | Win, 2 s on 80 % | **Survives: win, 3 s on 74 %** (`-plain-mixed`) | Dead at 7 s, enemy on 19 % (`-plain-best-mixed`) |

**The last row is a failure of the test, and it stays in the sheet.** A plain root with this exact stack beats an ordinary mixed Deity. Two things limit it. That plain character cannot exist, because a purity-20 method does not leave Qi Refining before old age, as above. And it dies to every ward. But in that one fight the root is a speed-up, not the difference. `--without turbid_root` on the main file: dead at 4 s, enemy on 88 %.

## Matchups

| Enemy | Result | File |
|---|---|---|
| Main fight: `n_body` 6, top-end ward, mixed arts | Win, 3 s on 11 %, pool dry at 3 s | `sheets/worst-root.fight.json` |
| Mixed | Win, 2 s on 80 % | `-mixed` |
| One jab and nothing else | Win, 2 s on 80 % | `-one-jab` |
| Foreseen, away from any ground | Win, 3 s on 11 % | `-foreseen` |
| A Nascent Soul, one realm down | Win, 2 s on 94 %, every part over the line | `-lesser` |
| Frail master: top-end ward, `n_body` 1.5 | **Dead at 4 s, enemy on 8 %** | `-frail-master` |
| Purest dregs: five at 10, purity 80 | **Dead at 3 s, enemy on 0 %, lost on overkill** | `-purest-dregs` |
| Top-end | Dead at 1 s, enemy on 65 % | main file, `--enemy top_end` |

**Counter:** a frail master. The line is a share of the target's body, so a small body behind a great ward drops the line under the part, and the ward wakes up. Also anything that wins before 2 s, since the build has M 4 against a top-end's 325: a body-crusher (Combat rule 18) at that M.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts at the lint, 7 of 7 slots, technique 1.93 of 4.0. Thần thức not totalled. L2 has no W price |
| Validity | PASS | Tier 3 reaches Deity. Cost 0.04 is Formulas E's floor |
| Stack | PASS | Forms: Increased, More, Conversion, Rule swap, Redirect, Trade. L4 and L5 named |
| Scaling | PASS | `m_static` 3.25 as printed, before the root's −30, 4.0 on arts in the fight, against typical 8.96. Far below by design |
| The fight | PASS | The loop fires, `turbid_under_line` 120 of 120 in the main fight, 60 of 60 constants |
| Reuse | PASS | Thrift proved in the main fight, and removed with regeneration. Second homes named |
| NPC use | NOT ASSESSED | The generator could size hits to a realm's typical body, but it must be told to stop adding damage, which no NPC rule says |
| Counterplay | PASS | A frail master, and a top-end body-crusher |
| Originality | PASS | The terms are ordinary Buddhist vocabulary, no source work |

## Fight Results

Input: `sheets/worst-root.fight.json`. Rules `turbid_root`, `ward_thrift`. Observations from `_tools/fight_x.py`, a paper model. `m_static` omits the root's L1 loss, which the plug-in applies.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical (main shape) | 0 | Win, 11 %, pool 0 | 3 s | 3 s | none |
| top_end | 0 | Dead, enemy on 65 % | 1 s | 1 s | none |

There is no realm above Deity Transformation, so the gap rows add only suppression and are not quoted.

**Unmodelled:** cultivation and the years, as stated in the fight file. A part's element tag is not read against a target's element ward terms.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Dull Root | Needs rule | Spiritual Roots rules 9 and 10: a derived variant that reads its parents inverted, with chance 1 |
| Even Streams | Needs rule | Combat rule 6: conversions per hit read `n_base` − 1 for this root |
| Unfelt | Needs rule | Combat Formulas D: a size test before the ward |
| Dull Hand, Split Hit Damage, Many Streams | Needs key | New keys and a `split` tag |
| Sutra, beads | Needs key | Records as above. Is a despised sutra Thiên giai? It must reach Deity, and only that tier does |

## Also Considered

- **Five Lives:** each element is a life you fall from, losing a sector each time. Moving, but it is Turned Away's rule with new fuel.
- **Waste Heat:** the 80 % your root cannot use is banked as silt for a century. Good, and it needs a whole new pool.
