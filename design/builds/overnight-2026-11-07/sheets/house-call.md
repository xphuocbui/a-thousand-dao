# The House Call (Xuất Chẩn Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The Healer (seed 70): wins by keeping a fight going. Who are they healing and why? Joy as the mood. Treat Tribulation rule 7's question about healing inside a wave as a real opportunity."
> **Direction**: They heal the enemy. Every wound closed on the other side counts three times toward the one row that makes their hits matter, so the enemy's bar climbs back to 100 % while the physician gets stronger, and then the bars cross.
> **Realm span**: Core Formation – Nascent Soul, defined at Nascent Soul, for the sky · **Power level**: ordinary in a duel, strong at the gate · **Use**: player build, or the district physician no one can get rid of
> **Fit**: 6 Fits today · 11 Needs key · 2 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled, and no lint exists for a heal)

## The Spine

- **The channel:** needles and a fist, on a multiplier that starts at 1.92 and grows only by healing.
- **The enabler:** Both Sides (Song Phương Thệ). Opens healing inside a fight. Closes the choice of patient: every heal goes to both sides, by the same share of maximum.
- **The loop:** wound them a little, Mend you both, wound them a little harder.
- **The engine:** a heal is a share of maximum, and only real wounds count. Joy of the Work makes each point the enemy regains count three times for Gorged, so a small hit, closed, buys a bigger hit. The enemy's own recovery is the fuel.
- **The sacrifice:** speed, a weapon, and anyone who cannot be wounded. No wound, no patient, no power.
- **The arc:** a Core physician who can barely end a bout, and a Nascent Soul who walks into the sky's three waves and walks out on 90 %.

## The Legend

Thầy Lạc has never lost a patient, which is the first thing they tell you, usually while pressing a warm needle into the arm you have just tried to kill them with. They came up as the physician at the harvest bouts of a river district, paid in eggs, and found out at nineteen that nothing in the world made them as happy as a good bout that had not finished yet. So they stopped letting it finish. They laugh the whole way through. It is a real laugh. Two hundred duellists have been mended to their faces by the person hitting them, and several have asked, in tears, to be killed by someone else.

Asked who they treat, Thầy Lạc says that a fight is a fever two people have caught, and that nobody walks out on half a patient. When the gate of Deity Transformation came they climbed up with the bag and asked the sky where it hurt, because in their professional opinion a thing that throws lightning is not well. Their sect has tried twice to retire them. They sent the elders a basket of eggs.

## How It Fights

For six seconds nothing seems to happen, and the enemy feels wonderful. Against the Evader the enemy's bar reads 98, 95, 93, 99, 95, **100**, 96, 95, while Lạc's sinks to 74. Then the needles start to mean something: 79, 75, 60, 39, 23, 19, 3, 0, while Lạc's climbs back to 98.

**The signature moment:** t = 6 against the Evader: the enemy on 100 %, and already dead (`variants/house-call-evader.fight.json --timeline`). On the pools that drain, the enemy's linh lực also runs out at about the same time, as it does on most sheets tonight. What differs is the bar, which rises first.

**Who, and why, in one line:** they heal you because it is the only thing that makes them dangerous, and they would do it anyway.

## Enabler

**Both Sides (Song Phương Thệ).** A physician's oath taken at a keystone on the Income border. Opens: an art may carry `heal_share`, restoring that share of maximum health when it resolves. Closes: the same share goes to the other side, and a heal cannot be aimed. A heal meets no ward, guard or evade, and fires no triggers. A side under a regeneration block is restored nothing, and the other side still is.

## The Stack

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Silver Needle, Long Needle | Two cheap Water arts | Art | art | none | ○ | Technique | any Water build |
| Rate | Healing art speed (Trị Liệu Tốc) | +1 / +6 % art speed, healing tag | Increased | heal | none | ○ | Tree | catalogue's any-tag row |
| Multiplier | Damage (`attack_pct`) | +60, kept low on purpose | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Gorged (Bão Lôi) | +1 per 1 % of maximum health restored this fight, to +100 | Per | art, basic | L2 | ○ | Cluster | **Reused from Drink the Lightning** |
| Multiplier | Spring Head (Tuyền Đầu) | +3 to Water arts per 1 % regeneration you own: +21 | Per | art | L2 | ○ | Tree | **Reused from The One Ladle, unplanned** |
| Multiplier | Grateful Patients (Cảm Ân) | +1 per 5 living people you have fought and left alive, to +20 | Per | any | L4 | ○ | Technique | any spared-enemy build |
| Reach | Healing (Trị Liệu) | +2 / +12 % to heal shares: +30 % here | Increased | heal | none | ○ | Tree | catalogue's any-tag row |
| Fuel | Healing art cost (Trị Liệu Phí) | −1 / −6 % | Increased | heal | none | ○ | Tree | catalogue's any-tag row |
| Past the cap | **Joy of the Work (Lạc Nghiệp)** | Health you restore to the other side counts 3 times as health you restored, for anything that reads it | Redirect | heal | none | ○ | Keystone | any build reading health restored |
| Survival | Stone Ward (Thạch Hộ) | Per-pulse ward at the legal 0.10 | Rule swap | any | none | ○ | Ward | **Reused from The Long Firing** |
| Survival | Health, pool, ward, regeneration rows | `n_body` 2.8, `n_qi` 1.6, `ws` 100, `we` 80, guard +25 %, +5 % | Increased | any | none | ● | Tree | every build |

**Identity piece:** Joy of the Work. `--without joy_weight`: the pool falls from 1.000 to 0.325, and Mixed slows from 10 s to 12 s. `--without both_sides` (no healing at all): pool 0.375, final health 21 %, Mixed ends on 39 % health.
**Empty rungs:** L3, a sacrifice: a physician carries no weapon. L5, a gap, and a place for someone else's condition. Crit, a sacrifice.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 60 | ×1.60 | `attack_pct` |
| L2 | 0 to 121 | ×1.00 to ×2.21 | Gorged, Spring Head on needles |
| L3 | 0 | ×1.00 | None |
| L4 | 20 | ×1.20 | Grateful Patients, 100 of them. 0 blind |
| L5 | 0 | ×1.00 | None |

**W:** 556 of 739: attack 60, health 216, linh lực 60, ward strength 75 over gear 25, efficiency 80, guard 25, regeneration 40. The rest pays for the healing rows, which have no W price yet.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root | Water, purity 50 or more | Spring Head, the Income border |
| Key talents | Physique, then Comprehension | A big body makes a share of maximum large |
| The Way | None needed | Keeping would suit it. Nothing here asks for one |

## Công Pháp

### Warm Hands Method (Ôn Thủ Pháp) — main, Địa giai

Written by someone who had to work with cold fingers, and was cross about it.

```json
{"id": "on_thu_phap", "name": "Ôn Thủ Pháp", "tier": 2, "tech_kind": "main", "names": ["thuy"], "layers": 12,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 20}],
 "abilities": [{"ability_id": "ngan_cham", "unlock_layer": 1}, {"ability_id": "bo_thu", "unlock_layer": 3},
               {"ability_id": "truong_cham", "unlock_layer": 6}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 15/15 + 20/20 = 2.0 of 3.0

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Mend (Bổ Thủ) | Method, 3 | no hit, healing | 0 | 0.04 | 2 s | enemy health below 92 % | Needs rule |
| Silver Needle (Ngân Châm) | Method, 1 | qi, Water | 1.45 | 0.04 | 1 s | none | Needs key |
| Long Needle (Trường Châm) | Method, 6 | qi, Water | 2.1 | 0.03 | 4 s | none | Needs key |

**Mend, effect:** restores 8 % of maximum to both sides, ×1.3 with the rows. **Description:** a warm thumb on the wrist, and an unwelcome feeling of being looked after. The guard is the whole trick: Lạc treats only when the enemy has something to treat. 3 of 6 slots used. The rest are free for talismans.

## Rule 7: Healing Inside a Wave

Thien-kiep rule 7 forbids healing between waves. Degenerate Strategies names only that. Drink the Lightning found that nothing stops it inside one, through Still Water. **This sheet proposes making it a rule and giving it a price:**

> Health restored inside a wave is real and carries by rule 7. An art heals only under an oath that treats both sides, so the sky recovers by the same share.

A first lint for any heal: `heal_share ≤ 2 × cost_share`, because a ward at normal efficiency buys about 1.8 health for each linh lực, and a heal that feeds the enemy has to beat that. Mend sits on the line. Pool: Drink the Lightning's first pool, boss numbers unchanged, all 120 ordered draws. Prefix `variants/house-call-`.

| File, flags | p_t | Final health | What failed |
|---|---|---|---|
| `pool` | 1.000 | 90 % | Nothing |
| `pool-fasted`, starts on 40 % | 1.000 | 84 % | Nothing |
| `pool-lean`, `n_body` 2.0, `ws` 60 | 1.000 | 78 % | Nothing |
| `pool-no-oath`, heals self only | **0.917** | 85 % | Dry Wind, wave 3, mostly a stalemate at 40 s |
| `pool --without joy_weight` | **0.325** | 85 % | |
| `pool --without both_sides` | **0.375** | 21 % | |
| `pool-plain`, no heal, L1 240 | 1.000 | 47 % | Nothing |

**Honest reading.** This pool is a first guess and a plain road survives it too, on 47 %. What the House Call changes is what comes out: 90 %, not 47 %. And **refusing to heal the sky costs 8 points of survival**: with the oath off, the third wave runs to the time limit and rule 8 kills you. Healing your tribulation makes it end sooner.

**Chains.** `draw-famine`: 98 %, 99 %, then Sour Cloud for 23 s, 74 %. `draw-feast`: 98 %, 88 %, 98 %.

## Matchups

Panel, at Nascent Soul, each file `variants/house-call-[enemy].fight.json`.

| Enemy | Result | Why |
|---|---|---|
| Mixed | Wins 10 s on 92 % | Self and enemy each mended 42 % |
| Pulse | Wins 14 s on 96 % | A ward that does not fall is only a slower patient |
| Evader | Wins 16 s on 98 % | The best fight on the sheet |
| Fast | Wins 8 s on 69 % | Its flurry starves itself. Its worst finish |
| Wall | **Loses** at 40 s, enemy on 97 % | Nothing wounds it, so nothing heals it. Oath off gives a stalemate on 77 % (`-no-oath-wall`) |
| Cheap single art (`-cheap`) | Wins 12 s on 90 % | The fight is slower because the enemy does so little harm |
| Regeneration curse (`-closed-gate`) | Wins 10 s on 60 %, pool 0 | Self mended only 10 %, enemy 41 %: joy still counts, and the build survives its own counter's first try |
| Blind (`-blind-mixed`) | Wins 12 s on 94 % | No patients in the room |
| The sky, foreseen, away from home | See Rule 7 | |
| Top-end | **Loses** at t = 1 | Normal |
| Typical, one realm up | **Loses** at 5 s, enemy on 95 % | The patient outlasts the doctor |

**Oath on or off, on the panel** (`-no-oath-*`): 10 s and 10 s, 14 s and 13 s, 16 s and 14 s, 8 s and 8 s. The oath buys almost nothing in a duel and costs almost nothing. Its payment is the third wave.

**Counter:** a Wall. Anything it cannot wound, it cannot grow on. Or a hit big enough to arrive before t = 6.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Hit arts inside the lint, 3 of 6 slots, method 2.0 of 3.0. A heal has no lint yet, one is proposed. Thần thức not totalled |
| Validity | PASS | Địa giai reaches Nascent Soul. Keys real. The only tribulation step is Nascent Soul to Deity |
| Stack | PASS | Five forms. Both identity runs change the fight. Pair removed together: Gorged with Joy of the Work, Mixed 16 s |
| Scaling | PASS | `m_static` 1.92 against a typical 7.37, on purpose, for an ordinary duellist |
| The fight | PASS | 60 of 60 constants. No cap hit. Plug-ins `gorged`, `both_sides`, `per_cap`, `tribulation` |
| Reuse | PASS | Gorged, Spring Head, Stone Ward and catalogue rows. Spring Head, unplanned: without it the Evader ends on 90 %, not 98 % |
| NPC use | PASS | A heal is one Breakdown line. NPCs never run a tribulation |
| Counterplay | PASS | The Wall, by 97 % |
| Originality | PASS | Nothing borrowed. A house call is a word, not a work |

## Fight Results

Input: `sheets/house-call.fight.json`. `fight_x.py`, a paper model.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Wins, 95 % | 8 s | never | none |
| typical | 1, 2 | Loses, enemy on 95 %, 96 % | 5 s | | none |
| top_end | 0, 1, 2 | Loses | 1 s | | none |

**Second realm:** Core Formation, `-ket-dan-mixed` wins 8 s on 93 %, `-ket-dan-fast` wins 7 s on 71 %. **Unmodelled:** Grateful Patients' count. `v_after` is unchanged: a fight never raises vitality, so a House Call's patients leave with their own wounds on the next season's sheet.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Both Sides, Mend | Needs rule | Combat rule 13: a heal effect. Thien-kiep rule 7: the sentence above. `rules/both_sides.py` |
| Joy of the Work, healing rows, needles, method, Grateful Patients | Needs key | Records, the `healing` tag, `heal_pct` |

## Questions

1. **Is healing inside a wave wanted at all?** This sheet and Drink the Lightning both say it is the one open door in rule 7. If yes, is "both sides" the right price?
2. Should healing rows have a W price? Catalogue sizes are used here, unpriced.

## Also Considered

- **The Second:** heal only a companion in the ring, the beast as the patient. Beast has no health bar outside two keystones, so most of it would be a new rule.
- **Long-Life Clinic:** self-only heal with Still Water. Fortieth Breath and Drink the Lightning already own that seat.
