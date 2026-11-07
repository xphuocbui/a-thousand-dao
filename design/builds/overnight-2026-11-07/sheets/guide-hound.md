# The Guide Hound (Dẫn Lộ Khuyển)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: The Plain Stack for Companion: spirit beasts, the companion channel, Formulas J and beast keeping, in ordinary rows any keeper can take.
> **Direction**: The road forks on what the owner does: nothing at all (the Held Leash), or curses (the Slipped Leash). This sheet walks the Held Leash, with no arts in any slot.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Nascent Soul · **Power level**: ordinary · **Use**: player path, or any elder with an old dog at their heel
> **Fit**: 8 Fits today · 33 Needs key · 0 Needs rule
> **Checks**: 11 PASS · 0 FAIL · 0 NOT ASSESSED

## The Spine

- **The channel:** the companion, on all five layers, no crit. 91 % of the damage in the defining fight. The basic attack does the rest.
- **The enabler:** none. A beast, the owner's own realm, and nodes on a map. Capability #17 already exists and is one row.
- **The loop:** the hound howls every 0.725 s. The owner stands still and keeps the ward up.
- **The engine:** a companion hits for at most c_comp 1.0 on one timer, so it starts far below an art build's rate. Sixteen small rows close that gap by multiplying: speed by share by five layers. And a side that casts nothing spends its whole pool on its ward, which keeps the condition on the fifth layer true.
- **The sacrifice:** every art. No answer to a deep pool, no reach, nothing to spend if the fight turns.
- **The arc:** at Foundation it wins on 2 %. By Nascent Soul the rows are long enough to win with half its health.

## The Legend

Đào Khiêm lost their sight to a fever at twelve. The village gave them a black puppy nobody else wanted, and they named it Mực, ink, for the last colour they could remember. They gathered herbs on the high slopes for a living, with one hand on the dog's back, and the dog ate what they ate, and there are things growing up there that a dog should not eat. Neither of them noticed the years going by.

They reached Nascent Soul the way they reached everything, by touch and by trust. They have never seen a fight. They hear the howl, they hold their ward, and when it goes quiet they say the dog's name and wait for its weight against their knee. Then they ask whether anyone is hurt. They spend more on its food than on anything they own, and when people ask why, they do not understand the question.

## How It Fights

You stand still. For a moment you are losing: at t = 3 you are on 58 %, and they are on 65 %. But each howl burns their ward, and at t = 3 their pool is on 3 %. After that the same howl lands whole. They go from 65 % to nothing in under a second and a half.

**The signature moment:** the fight ends at 4.35 s, and in the whole of it the owner has not used a single art. Six slots are empty, and that is 19 points of damage (`variants/guide-hound-mixed.fight.json`, `--timeline`).

## The Stack

A walk of 94 nodes, 70 acupoints and 24 notables, 276 W. Cluster rows scale with purity (Meridian Map rule 4), so these sizes assume purity 50 on ground the root holds. Only road rows are exact. That is the 185 W attack quarter of a Nascent Soul's tree and 91 W of the half a typical life spends outside fights.

`Without` is the whole row removed from `variants/guide-hound-mixed.fight.json`: `--without "[id]"`, or the named file. It reads win time, own health, own linh lực, enemy health at t = 3. **The full fight is 4.35 s, 53 %, 37 %, 65 %.**

### The Keeper's road: both lines walk it

| # | Node | Take | Each | Total | Form | Layer | Status | Without |
|---|---|---|---|---|---|---|---|---|
| 1 | Companion damage (Thú Thương) | 8 + 2 | +2 / +12 | +40 | Increased | L1 | ○ catalogue | 5.8 s, 48 %, 33 %, 71 % |
| 2 | Beast damage (Thú Hình) | 6 + 2 | +2 / +12 | +36 | Increased | L1 | ○ catalogue | 5.8 s, 48 %, 33 %, 70 % |
| 3 | Qi damage (Khí Thương) | 2 + 1 | +1.5 / +10 | +13 | Increased | L1 | ○ catalogue | 5.1 s, 48 %, 33 %, 67 % |
| 4 | Companion attack speed (Thú Tốc) | 12 + 2 | +1.5 / +10 | +38 | Increased | none | ○ catalogue | `companion_speed`: 6 s, 36 %, 21 %, 73 % |
| 5 | Beast Soul Union (Thú Hồn Hợp Thể), capability #17 | 0 + 1 | c_comp 0.5 to 1.0 | ×2 | Capability | none | ● | `no-union`: 9.4 s, 15 %, 2 %, 80 % |
| 6 | Full Trough (Mãn Tào): feed four times what is due | 0 + 1 | to +40 | +40 | Per | L4 | ○ reused | 6.5 s, 36 %, 21 %, 73 % |
| 7 | **Long Loyalty (Trường Trung)**: companion hits, per 10 loyalty above 50 | 0 + 1 | +0.4 / +2.5 | +12.5 at 100 | Per | L2 | ○ new | 5.1 s, 48 %, 33 %, 67 % |
| 8 | **Grown Together (Đồng Trưởng)**: hits from a beast of your own realm or higher | 0 + 1 | +1.5 / +10 | +10 | More | L2 | ○ new | 5.1 s, 48 %, 33 %, 67 % |
| 9 | Wasting (Hao Tổn): hits, per 1 % of the enemy's linh lực missing | 0 + 1 | notable +0.2 | up to +20 | Per | L2 | ○ reused | 5.1 s, 48 %, 33 %, 67 % |
| 10 | Ward strength (Hộ Lực) | 10 + 2 | +1.2 / +8 | +28 | Increased | none | ● | `no-ws`: 5 s, 39 %, 38 %, 65 % |
| 11 | Ward efficiency (Hộ Hiệu) | 6 + 2 | +1.2 / +8 | +23.2 | Increased | none | ● | `no-eff`: 4.35 s, 53 %, 27 %, 65 % |
| 12 | Maximum linh lực (Linh Hải) | 4 + 2 | +1.2 / +8 | +20.8 % | Increased | none | ● | `no-pool`: 5.1 s, 48 %, 18 %, 65 % |
| 13 | Maximum health (Khí Huyết) | 12 + 2 | +1 / +6.5 | +25 % | Increased | none | ● | `no-hp`: 5.1 s, 33 %, 33 %, 65 % |

### The Held Leash (Trì Cương): walked here

The owner does nothing, so everything that reads "nothing" pays.

| # | Node | Take | Each | Total | Form | Layer | Status | Without |
|---|---|---|---|---|---|---|---|---|
| 14 | **Still Hand (Tĩnh Thủ)**: companion hits, per empty art slot | 4 + 1 | +0.3 / +2 | +19.2 at 6 | Per | L2 | ○ new | 5.1 s, 48 %, 33 %, 68 % |
| 15 | **Behind the Ward (Hộ Hậu)**: companion hits while your linh lực is above 25 % | 4 + 2 | +2 / +12 | +32 | Conditional | L5 | ○ new | 5.8 s, 41 %, 25 %, 72 % |
| 16 | Damage while above 50 % health (Toàn Thân) | 2 + 1 | +2 / +12 | +16 | Conditional | L1 | ○ catalogue | `Above Half`: 5.1 s, 48 %, 33 %, 69 % |

**All 16 rows removed one at a time still win.** Fifteen move the fight by at most about two seconds, most of them by a single howl. The one that moves it far is capability #17, which is less a modifier than a doubling: 9.4 s on 15 %.

### The Slipped Leash (Phóng Cương): the rival

The owner sings curses, and the dog goes in on what they open. Rows 14 to 16 are given up, ward rows 10 to 12 are cut to 8 + 2, 4 + 2 and 2 + 2, and that W buys these. Same W, 277. Saved as `slipped-*`.

| # | Node | Take | Each | Total | Form | Layer | Status |
|---|---|---|---|---|---|---|---|
| 17 | **Urging Word (Thôi Ngôn)**: companion hits, per curse on the enemy | 4 + 2 | +1 / +5 | +14 a curse | Per | L2 | ○ new |
| 18 | **Opened Guard (Khai Hộ)**: companion hits, per curse on the enemy | 4 + 2 | +1 / +5 | +14 a curse | Per | L5 | ○ new |
| 19 | Thrifty Word (Tiết Ngôn): curse art cost | 2 + 1 | −1 / −6 | −8 % | Increased | none | ○ reused |

Its arts are Rain Song, Furrow Song and Low Song, reused from The Herd-Child as they stand.

### Beside the road

| # | Node | Each | Form | Status | Who wants it |
|---|---|---|---|---|---|
| 20 | Power share (Phân Lực) | +0.5 / +3 points | Increased | ○ new | A keeper who cannot reach #17. Dead once it is held. Not run |
| 21 | Damage to an enemy with no linh lực (Tận Khí) | +2.5 / +15 | Conditional | ○ catalogue | A keeper who meets walls. Not run |
| 22 | Feed cost (Tiết Liệu) | −2 / −12 % | Increased | ○ new | Any keeper. Outside the fight, and it makes Full Trough cheaper |
| 23 | Taming chance (Thuần Thú) | +1 / +6 % | Increased | ○ new | Any keeper. Outside the fight |

That is 19 modifiers plus capability #17, Full Trough, Wasting and Thrifty Word, 38 rows in `pieces/guide-hound.json`, with 0 rule asks. Companion attack speed is the catalogue's plain row; `rules/companion_speed.py` exists only because the calculator has no field for it.

**Identity piece:** none, on purpose. The nearest thing is Still Hand, because a Slipped owner can never have it. `--without "Still Hand"` on the fixture moves the win from 4.35 s to 5.1 s.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 89 to 105 | ×1.89 to ×2.05 | Rows 1, 2, 3, 16 |
| L2 | 82, up to 102 | ×1.82 to ×2.02 | The method 40, rows 7, 8, 14, 9 |
| L3 | 40 | ×1.40 | The typical weapon, as a collar or not |
| L4 | 60 | ×1.60 | A pill 20, Full Trough 40. A blind fight keeps the 40, because it was eaten |
| L5 | 0 to 32 | ×1 to ×1.32 | Row 15 |
| M | | ×7.7 to ×12.2 | Typical at Nascent Soul is ×7.37 |

At 1.38 hits a second and c_comp 1.0, that is about 1.4 of coefficient a second before M. The mixed enemy runs 3.7.

## Remove Five

Same fight, whole rows, each file `variants/guide-hound-[name].fight.json`.

| File | Removed | Result |
|---|---|---|
| `five-damage` | Companion, Beast, Qi, Behind the Ward, Full Trough | **Lost** at 6 s, enemy on 71 % |
| `five-keeper` | Speed, Full Trough, Loyalty, Grown Together, Still Hand | **Lost** at 6 s, enemy on 50 % |
| `five-mixed` | Speed, Beast, Behind the Ward, health, pool | **Lost** at 6 s, enemy on 54 % |
| `five-ward` | Ward strength, efficiency, pool, health, Behind the Ward | **Still wins** at 5.8 s on 11 %, pool 0 % |
| `five-gentle` | Above Half, Loyalty, Wasting, Qi, Grown Together | **Still wins** at 6.5 s on 36 % |

The test holds for the three fives above that reach deep into the damage, and not for every five. A fight this short does not outlast the owner's ward rows, so taking all of them leaves a win on 11 %.

## The Same 276 W As Plain Attack

A half-share beast and 276 W of `attack_pct`, no rows: `plain-mixed` **loses** at 5 s with the enemy on 60 %. Spread over five layers and a timer, the same W wins with half its health.

## The Choice

| Enemy | Held Leash, no arts | Slipped Leash, three curses |
|---|---|---|
| Mixed | Wins at 4.35 s on 53 %, pool 37 % | `slipped-mixed`: wins at 4.35 s on 52 %, pool 7 % |
| Wall, `n_body` 7 | `wall`: wins at 12.3 s on 14 % | `slipped-wall`: **loses** at 9 s, enemy on 17 % |
| Deep pool, `n_qi` 4 | `deep`: **loses** at 6 s, enemy on 36 % | `slipped-deep`: **wins** at 5.8 s on 6 % |
| Evader, 30 % | `evader`: wins at 7.3 s on 32 % | `slipped-evader`: wins at 5.8 s on 30 % |
| Cost curse on its jab | `nagger`: wins at 4.35 s on 53 %, pool 37 % | `slipped-nagger`: wins at 4.35 s on 52 %, pool 0 % |

Slipped opens the ward sooner and cracks a deep pool. Held is the only one that lasts: it finishes a 12 s wall that Slipped cannot, and an enemy who taxes arts has nothing to tax. You cannot have both, because Still Hand counts the slots the songs fill, and the songs spend the pool that Behind the Ward reads.

**Counter:** a deep pool (above), one realm up (`mixed --gap 1`: loses at 3 s, enemy on 93 %), or a top-end.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth, purity 50 | Sets the cluster scale. Purity is not a fight input, but the row sizes assume it |
| Key talents | Soul strength for taming, then any | Sense and fortune are not read in the fight |
| Beast keeping | Fed four times what is due, loyalty 100, 8,000 stones a year at a Nascent Soul beast's 2,000 | Rows 6 and 7 are paid here, not in W |
| The rest of the tree | The typical life's pools and base ward | Copied from the fixture |
| The Way (Đạo) | None | Everything is on the Map |

## Công Pháp

### Walking Stick Method (Trượng Hành Quyết) — main, Địa giai

```json
{"id": "truong_hanh_quyet", "name": "Trượng Hành Quyết", "tier": 2, "tech_kind": "main", "names": ["tho"], "layers": 12,
 "bonuses": [{"stat": "tam_ma_resist_pct", "value": 15}, {"stat": "lifespan_years", "value": 15}],
 "abilities": [], "seal_clusters": [], "origin": "authored"}
```

Also +40 L2 on hits with the beast form, the typical anchor. **Budget:** 15/15 + 15/15 = 2.0 of 3.0. It teaches no art. **Description:** step, tap, listen.

## Companion

**Mực (Dẫn Lộ Khuyển).** A black hound of the owner's realm, beast form. Fixed art **Low Howl (Đê Hống):** a qi hit, on the companion's timer of 0.725 s. Qi, because a qi hit burns their ward half as fast again, and an owner this slow needs that ward gone.

**Items:** the typical weapon (L3 40) and an attack pill (L4 20), on the common drain ward. No art is slotted.

## Progression

| Realm | Plays like | Result | Story beat |
|---|---|---|---|
| Foundation, 33 nodes, 108 W | A dog and a very frightened owner | `foundation-mixed`: wins at 6.9 s on 2 % | The first time someone came for the herbs |
| Nascent Soul, 94 nodes | The rows are long enough | Wins at 4.35 s on 53 % | They still say its name first |

## Matchups

| Enemy | Result |
|---|---|
| Mixed, same realm (`mixed`) | Wins at 4.35 s on 53 %. A foreseen fight with no home ground |
| One cheap art (`one-art`) | Wins at 5.1 s on 55 %, pool 55 % |
| Top-end (`sheets/guide-hound.fight.json`) | Loses at 1 s, enemy on 98 % |

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Method 2.0 of 3.0. Slots 0 of 6, on purpose. No arts to lint |
| Validity | PASS | `nguyen_anh`, Địa giai reaches it. c_comp at the cap, timer above `cooldown_min` |
| Stack | PASS | Increased, More, Conditional and Per in the walk, every layer stated |
| Plain Stack test | PASS | 16 of 16 single rows still win. 3 of 5 saved fives lose, and the two that win are shown. Capability #17 moves it far, and the sheet says so |
| Against plain attack | PASS | Wins a fight plain attack loses at the same W |
| Scaling | PASS | M 7.7 to 12.2 against 7.37, on a channel at about a third of the mixed enemy's rate |
| The fight | PASS | One plug-in, for a catalogue row with no field. No cap hit |
| Reuse | PASS | Full Trough, proved in the main fight: 6.5 s on 36 % without it. Wasting costs one howl. The Herd-Child's songs, as they stand |
| NPC use | PASS | Plain numbers, each one Breakdown line. An NPC needs a beast and no arts |
| Counterplay | PASS | Deep pool, one up, top-end |
| Originality | PASS | Plain words. A blind person and a guide dog is common human experience |

## Fight Results

Input: `sheets/guide-hound.fight.json`. Observations from `fight_x.py`, a paper model with expected values. Plug-in: `companion_speed`.

| Enemy | Gap | Result | Time | Own left | Cap hits |
|---|---|---|---|---|---|
| Typical | 0 | Win | 4.35 s | 61 % | none |
| Typical | 1, 2 | Loss, enemy on 93 % and 94 % | 3 s | 0 | none |
| Top-end | 0 to 2 | Loss, enemy on 98 %, 100 %, 100 % | 1 s | 0 | none |

**Unmodelled:** element on a hit. Feed, loyalty and stones are costs outside the fight, so rows 6 and 7 are flat points at the value stated. Rows 20 to 23 are not run.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Companion tag key | Needs key | The catalogue's key shape. Rows 1, 2, 3, 16 |
| Companion attack speed | Needs key | A key on the companion's timer |
| Empty slots, loyalty, beast realm, curses on the enemy, own pool | Needs key | Rows 7, 8, 14, 15, 17, 18 |
| The method and the hound | Needs key | Content |

## Questions

1. Capability #17 doubles c_comp for one node, and it is the one row whose loss moves this fight far (9.4 s on 15 %). Should Power share exist beside it, or should the capability be priced as a keystone?
2. Does a technique "more" keyed to the beast form reach a companion hit? The Walking Stick Method assumes it does.
3. Full Trough gives +40 on L4 for one node and a stone bill, far above any catalogue L4 size. Is stones enough of a price?

## Also Considered

- **The Pack:** capability #16's extra beasts, several small hits. Dropped, because Combat rule 19 has one companion, and that is a rule ask.
- **The Fang:** a body-kind beast and the same rows. Dropped, because a slow channel needs their ward gone first.
