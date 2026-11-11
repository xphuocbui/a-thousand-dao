# The Empty Hall (Không Đường)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: "Slot exactly one art and leave the other slots empty on purpose, gaining power per empty slot. The minimalist min-maxer: what one art has to be when everything feeds it."
> **Direction**: The Empty Hall: the largest legal art, made fast and paid for by the slots left empty; each empty slot rings once when it lands.
> **Realm span**: Trúc Cơ (Foundation Establishment) – Hóa Thần (Deity Transformation) · **Power level**: top-end · **Use**: player
> **Root**: single Metal (Kim), purity 90 or more
> **Fit**: 16 Fits today · 5 Needs key · 4 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 2 NOT ASSESSED (the fight, and the identity test: no simulator this run, user decision 2026-11-11)

## Directions considered

Run unattended: the direction was chosen by the session, not asked (run override 1).

- **Chosen: The Empty Hall (Không Đường).** The one art is the art lint's largest (cost 0.125, authored cooldown
  12 s, c 6.75). The empty slots pay for its slowness (art speed per slot), its cost (regeneration per slot) and
  its size (coefficient past the lint per slot), and each empty slot rings once when it lands. Picked because it
  answers the seed's question literally and mechanically: the one art has to be the slowest, dearest legal art,
  because the lint prices cooldown and art speed then erases it.
- **Not picked: The Walled Hermit (Ẩn Sĩ Trọng Bích).** Empty slots feed the wards; the one art is a guarded
  finisher that waits for the enemy's pool to dry. Sound, but it is dry-well and unkillable again, and the one art
  barely matters.
- **Not picked: The Last Word (Tuyệt Ngôn).** Each empty slot banks charge every second and the art fires once,
  late, for everything. A burst-all-in build, which "sustain is king" says should be rare, and it loses to
  anything that wins before the word is spoken.

## The Spine

- **The channel:** art hit, one art only. It uses L1 to L5 and crit; it meets evade, resistance, block and shields.
  Its limits are the art lint (Formulas C), `cooldown_min`, linh lực, and the slots. Triggers ride on it for status
  stacks, not damage (`trig_budget` 0.5, `trig_cap` 6).
- **The enabler:** Vow of the One Stroke (Nhất Chiêu Thệ). Opens: the one art's coefficient may pass the lint by
  +0.4 per empty art slot. Closes: one art in the art slots, ever: no second art, no talisman, no escape art, no
  ward in an art slot.
- **The loop:** one stroke every 2.5–5 s; each empty slot echoes it once and lays a Metal debuff stack; the pool
  stays above half, so the free ward slots hold all fight.
- **The engine:** the lint pays for cooldown, and art speed takes cooldown away. Every empty slot buys art speed
  (Clear Path), regeneration (Quiet Channels), L5 (Undivided), coefficient (the Vow) and one ring (Empty Hall). So
  a slot left empty is worth more than an art put in it, and the build's real stat is `slot_count`.
- **The sacrifice:** one damage type, one answer. No escape art, no heal art, no cleanse art, no talisman. A
  Silence that names its tag, or an evader, turns the build off. It refuses to fix this.
- **The arc:** at Trúc Cơ an executioner's stroke every ~5 s with three rings; at Hóa Thần a stroke every 2.5 s
  with six rings (the seventh is lost to the trigger cap), six wards up and a pool that never empties.

## The Legend

A grinder in a border garrison was never taught a sword form. His task was the edge of one blade, a commander's
flying sword, and he worked it for thirty years. When a raiding general came for the garrison's treasury, the
grinder took the sword off its rack and cut once. The helm split; the sword kept a notch where it struck. He
would not grind the notch out and would not learn a second stroke: "a man who carries two edges finishes
neither." His notes on breathing at the stone became the Whetstone Scripture.

Its heirs are few and plain: wandering blades, temple guards, one cultivator in a village who does nothing
for decades and then does one thing. The many-art schools despise them and buy their manuals to burn them,
because a disciple who reads the Scripture stops buying arts. They answer every challenge, since the Vow gives
them no way to leave a fight. The founder died standing, cut down by a rival who silenced his one stroke; his
heirs keep a ward for that day.

## How It Fights

The Empty Hall carries one art, the Grindstone Stroke, and leaves every other art slot empty. Each empty slot makes
the Stroke faster, cheaper to keep up and heavier, and when it lands the hall rings: one free echo per empty slot,
each laying a Metal debuff stack that makes the next Stroke cut deeper. It spends about half its regeneration on
the Stroke, so its linh lực stays high and its free ward slots (four, plus two from a strong thần thức at Hóa Thần)
hold all fight. Blood Drinker turns each huge hit into health.

**Signature moment:** at 1.6 s the Stroke falls; the Breakdown then logs six rings, and a seventh dropped with the
note "trigger cap". The seventh slot is still worth having: it is speed, coefficient and L5, just not sound.

## Enabler

**Vow of the One Stroke (Nhất Chiêu Thệ)**, tier `enabler`. Hosts: the Whetstone Scripture (layer 1, both copies);
the Đại Đạo capstone (second host, for a player on another technique).

- **Opens (Room to Grow, Dư Địa):** your one art's coefficient is raised by +0.4 for each empty art slot, past the
  art lint (Combat Formulas C), cap +2.8 (7 empty slots). Read at compile. Payload key `art_coef_add` (new).
- **Closes:** enforce a closing rule at compile: at most one art in your art slots; no talisman, escape art or ward
  may be slotted in an art slot. The slots still count.
- **Why it is fair:** each empty slot is an art not carried, 20 W by `bonus_slots`' price. The Vow sells that slot to
  the one art for +0.4 coefficient (6 % of the lint maximum) plus whatever the other per-slot pieces pay. The
  price is real: no escape in a game where fleeing keeps a life, and no answer in the art slots to a silencer.
- **Fit:** Needs key (`art_coef_add`), Needs rule (Combat Formulas C: a coefficient added after the lint, from this
  enabler only).

## The Stack

The build's modifiers and Effects, up the ladder. Sizes on new pieces are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Grindstone Stroke (Ma Thạch Trảm) | c 6.75 at cost 0.125, cooldown 12 s: the lint's maximum (Formulas C) | Flat base | art hit | none | ○ | Whetstone Scripture L1 | any slow nuke |
| 1 Base | Room to Grow (Dư Địa), the Vow's payload | +0.4 coefficient per empty art slot, past the lint, cap +2.8 | Flat base (Trade) | art hit | none | ○ | Vow of the One Stroke | any one-art build (a soul lance, a Fire caster) |
| 2 Rate | Clear Path (Thông Lộ) | +40 `art_speed_pct` per empty art slot, cap +280 | Per | art hit | none | ○ | Đại Đạo Giản `major` | any build of 1–2 arts; NPC hermits |
| 2 Rate | Art speed (`art_speed_pct`) | +40 technique (Thiên L8), +30 sword, tree notables | Increased | art hit | none | ◐ | technique, sword, tree | every caster |
| 2 Rate | Opening Haste (Tiên Phát) | first timer ÷ (1 + 60/100) | Timing | art hit | none | ○ (staged) | Whetstone Scripture L3 | first-volley (its source) |
| 3 L1 | `attack_pct`, Physical damage, Metal damage | tree and technique, about +300 points | Increased | art hit | L1 | ● / ○ | tree, technique | everyone |
| 3 L2 | Whetted Edge (Mài Phong) | `damage_more` +60 [kim] (Địa +40) | More | art hit | L2 | ○ | Whetstone Scripture L5 | any Metal art build |
| 3 L2 | Ore Weight (Khoáng Trọng) | `damage_more` +45 [physical] | More | art hit | L2 | ○ (staged) | Ore-Vein Scripture (aux) | triple-convert (its source), curse-engine |
| 3 L2 | Whole Weight (Toàn Trọng) | `damage_more` +40 [costly, slow] | More | art hit | L2 | ○ | Đại Đạo Bỏ notables ×2; Swept Floor notable | curse-engine's Iron Nail, home-fortress's Mountain-Press Seal, triple-convert's Third Smelting |
| 3 L3 | Single-Notch Sword (Nhất Khuyết Kiếm) | one Cực phẩm flying sword; Treasure Nurtured Within (+50 % at full) | gear | art hit | L3 | ○ / ● | named artifact; capability #3 | any one-treasure build |
| 3 L4 | Nine Rods Array, Iron-Sand Hand Bath | +80, +50 (foreseen) | More | art hit | L4 | ○ (staged) | formation; coating | six builds of this run |
| 3 L5 | Undivided (Chuyên Nhất) | your arts: L5 +10 per empty art slot, cap +70 | Per | art hit | L5 | ○ | Swept Floor far notable; Đại Đạo Giản `minor` | any few-art build; Bare Rack's art twin |
| 3 L5 | Steady Breath (Bình Tức) [sword]; Marked Prey | +12 at ≥ 50 % linh lực; +4 (Sundered) | Conditional, Per | art hit | L5 | ● | sword; tree or Way | sword builds; curse kits |
| 4 Certainty | Called Blow (Báo Chiêu) | crit counted on a meter; crit cap 0.35 | Rule swap | art hit | none | ● | tree keystone | crit builds |
| 4 Certainty (alt.) | Measured Stroke (Định Trảm) | no evade, no crit, for authored cooldown ≥ 20 s (needs ≥ 10 s) | Rule swap | art hit | none | ● (threshold dead) | Đại Đạo Nhất notable | slow nukes vs evaders |
| 5 Reach | Sundered on the Stroke; `resist_pen_pct` [physical] +60 | −150 Physical points; +60 pen | Curse; Increased | art hit | none | ● | the art; the sword | every Physical build |
| 5 Reach | Empty Hall's Metal stacks | +1.8 % Physical taken each, ×1.2 at purity 100 | Trigger | art hit | none | ○ | see rung 9 | — |
| 7 Fuel | Quiet Channels (Tĩnh Mạch) | +0.5 pp regeneration per art slot holding no art, cap +3 pp | Per | linh lực | none | ○ (staged) | Đại Đạo Giản `minor` | bare-fist (its source), unkillable |
| 7 Fuel | Art cost (`art_cost_pct`) | −15 % (technique), tree | Increased | linh lực | none | ● | technique, tree | everyone |
| 8 Survival | Free ward slots, thần thức, Blood Drinker, Open Sky | 1/1/2/3/4 + up to 2 by thần thức; 6 % of each hit as health; wards +0.5 per 1 % free thần thức, cap +30 | — | defence | none | ● | wards; sword; Đại Đạo Bỏ | ward casters |
| 9 Identity | **Empty Hall (Không Đường)** | when your art lands, it rings once per empty art slot: a free hit (c_trig 0.3, the art's tags and types) that lays 1 debuff stack of the art's element for 6 s; once per pulse | Trigger (Per) | art hit → stacks | none | ○ | Đại Đạo Nhất `major`; Whetstone Scripture (Thiên L15) | any element caster with 2–3 arts and empty slots |

**Identity piece:** Empty Hall. Without it the empty slots are only numbers on the one art; with it they are heard,
and every ring opens the target for the next Stroke (Metal debuff), so the slot count also sets the target's
Physical weakness. Its bound is the game's own: `trig_cap` 6 between pulses, so the seventh ring is dropped.

**Forms used:** Flat base, Trade, Per (×4), Increased, Timing, More, Conditional, Rule swap, Trigger, gear. Eleven.

**Empty rungs:** **rung 6 (past the cap)** is a gap by choice: no layer reaches its cap except perhaps L2; the
seventh ring overflows into nothing, and that is the build's one honest waste. Crit has no overflow either.

| Layer | Points at Hóa Thần (foreseen) | Multiplier | Sources |
|---|---|---|---|
| L1 | ≈ +300 (soft past 200, so 250 counted) | ×3.5 | tree W, technique `attack_pct` 22.5, Metal and Physical nodes |
| L2 | 255 (cap 300) | ×3.55 | Whetted Edge 60, Stroke's own 30, Ore Weight 45, Whole Weight 40 × 3 |
| L3 | ≈ +150 (first guess) | ×2.5 | one sword only; the top-end anchor is 3.5. One treasure is the price of free thần thức |
| L4 | 130 (cap 150); blind: 0 | ×2.3 / ×1.0 | Nine Rods Array 80, Iron-Sand Hand Bath 50 |
| L5 | 86 (cap 100) | ×1.86 | Undivided 70 (7 empty), Steady Breath 12, Marked Prey 4 |
| **M** | | **≈ 133** (blind ≈ 58) | top-end anchor at Hóa Thần is 325 (Formulas B) |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Single Metal (Kim), purity 90+ | Fastest early cultivation; purity powers the Metal stacks the hall lays (× (1 + 0.002 × P), Effects rule 9a) and scales the Metal land's acupoints (0.5 + P/100) |
| Key talents | Divine sense (thần hồn) high; comprehension | Thần thức past 1.75 × and 3.5 × `ds_ref` gives +1 and +2 ward slots (Combat Defence Formulas D) |
| The Way (Đạo) | Đại Đạo, The Great Way Is Simple (Đại Đạo Chí Giản), no requirement: Giản, Nhất and Bỏ facets, capstone | The catalogue's own "power per empty slot" and "one art, one ward" Way |

## Công Pháp

### Whetstone Scripture (Ma Thạch Kinh) — main, Địa giai (tier 2), to Nguyên Anh

"Breathe as the stone turns; an edge is finished, or it is not."

```json
{"id": "ma_thach_kinh", "name": "Ma Thạch Kinh", "tier": 2, "tech_kind": "main",
 "names": ["kim"], "layers": 12,
 "bonuses": [{"stat": "attack_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 20},
             {"stat": "than_thuc_pct", "value": 15}],
 "abilities": [{"ability_id": "grindstone_stroke", "unlock_layer": 1},
               {"ability_id": "vow_of_the_one_stroke", "unlock_layer": 1}],
 "origin": "authored"}
```

No `seal_clusters`: the field is retired with the Meridian Map's hidden clusters (cong-phap.md rule 15).
Passives (no field yet): L3 Opening Haste +30; L5 Whetted Edge +40 [kim] L2; L8 `art_speed_pct` +20; L10 `art_cost_pct` −15.

**Fit:** Needs key (combat passives and ability records have no field) · **Budget:** 15/15 + 20/20 + 15/15 = 3.0 of 3.0; each 1.0 ≤ 1.5.

### Whetstone True Scripture (Ma Thạch Chân Kinh) — main, Thiên giai (tier 3), to Hóa Thần

```json
{"id": "ma_thach_chan_kinh", "name": "Ma Thạch Chân Kinh", "tier": 3, "tech_kind": "main",
 "names": ["kim"], "layers": 15,
 "bonuses": [{"stat": "attack_pct", "value": 22.5}, {"stat": "linh_luc_pct", "value": 20},
             {"stat": "than_thuc_pct", "value": 15}, {"stat": "defense_pct", "value": 7.5}],
 "abilities": [{"ability_id": "grindstone_stroke", "unlock_layer": 1},
               {"ability_id": "vow_of_the_one_stroke", "unlock_layer": 1},
               {"ability_id": "empty_hall", "unlock_layer": 15}],
 "origin": "authored"}
```

Passives: L3 Opening Haste +60; L5 Whetted Edge +60 [kim] L2; L8 `art_speed_pct` +40; L11 `art_cost_pct` −15; L15 Empty Hall (second host).

**Fit:** Needs key · **Budget:** 1.5 + 1.0 + 1.0 + 0.5 = 4.0 of 4.0; largest 1.5 ≤ 1.5. **It teaches one art and no other.**

### Ore-Vein Scripture (Khoáng Mạch Kinh) — secret, Địa giai, reused (staging: triple-convert)

Only its passive Ore Weight (+45 [physical] L2) and its bonuses (`defense_pct` 15, `linh_luc_pct` 20) matter here; its
Quench art cannot be slotted under the Vow. Harmony: names kim under a kim main.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Grindstone Stroke (Ma Thạch Trảm) | Whetstone Scripture, L1 | Physical hit; kim, physical, sword, art; derived costly, slow | 6.75 (+0.4 per empty slot by the Vow) | 0.125 | 12 s | none | Needs key (art record) |

**Effect:** one Physical hit; applies Sundered (1 stack, Physical); carries `damage_more` +30 L2 for itself. Lint:
1.0 × (1 + 24 × 0.125) + 0.25 × (12 − 1) = 4.0 + 2.75 = **6.75**, the maximum Combat Formulas C allows. Curses carry
no lint charge today. **Description:** the stroke the grinder made once, made again.

Effective timing by realm (art speed sums; first firing ÷ (1 + opening haste)):

| Realm | Empty slots | Art speed | cd_eff | First firing | Coefficient | Cost per second (of qi_max) | Regeneration per second |
|---|---|---|---|---|---|---|---|
| Trúc Cơ | 3 | +150 (Clear Path 120, technique 20, tree 10) | 4.8 s | 3.7 s (haste +30) | 7.95 | 0.1125 / 4.8 = 0.023 | 0.035 + 0.08 · ln(1 + 0.015/0.08) = 0.049 |
| Kết Đan | 4 | +200 | 4.0 s | 3.1 s | 8.35 | 0.028 | 0.051 |
| Nguyên Anh | 5 | +270 | 3.2 s | 2.0 s (haste +60) | 8.75 | 0.033 | 0.058 |
| Hóa Thần (capstone +1 slot) | 7 | +380 (Clear Path 280, technique 40, sword 30, tree 30) | 2.5 s | 1.56 s | 9.55 | 0.10625 / 2.5 = 0.0425 | 0.035 + 0.08 · ln(1 + 0.04/0.08) = 0.067 |

Regeneration from Combat Formulas E (`regen_base` 0.035, `regen_k` 0.08); bonus is Quiet Channels plus a tree
point. In every realm the Stroke spends about half of regeneration, so the other half is left for drain and
per-hit ward bills.

## Loadout by Realm

| Realm | Art slots | Slot order | Wards (free ward slots) | Note |
|---|---|---|---|---|
| Trúc Cơ | 4 | Grindstone Stroke, —, —, — | 1 + 1 (thần thức): Common Ward, Mountain Screen | Địa copy; three rings |
| Kết Đan | 5 | Stroke + 4 empty | 2 + 1: + Clear Heart Ward | Single-Notch Sword (Kết Đan tier) |
| Nguyên Anh | 6 | Stroke + 5 empty | 3 + 2: + Thousand-Layer Cloud, Soul-Guarding Lamp | Called Blow; Undivided +50 |
| Hóa Thần | 7 + 1 (capstone) | Stroke + 7 empty | 4 + 2: Common Ward, Mountain Screen, Thousand-Layer Cloud, Golden Bell, Clear Heart Ward, Soul-Guarding Lamp | Thiên copy; six rings, one dropped |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Single-Notch Sword (Nhất Khuyết Kiếm) | Named artifact, weapon | `phi_kiem`, Cực phẩm, Kết Đan to Hóa Thần | `artifact_attack_pct` +30, `art_speed_pct` +30, `resist_pen_pct` [physical] +60; carries Blood Drinker (6 % of each hit's dealt damage as health) and Steady Breath [sword]. The one treasure, so capability #3 makes it cost no thần thức | Fits today (named item on designed keys; both Effects list Item hosts) |
| Plain armour | `giap`, any grade | defence 30, thần thức 5 | Ward gear, cheap in thần thức | Fits today |
| Nine Rods Array (Cửu Can Trận) | Formation, foreseen | reused | L4 +80 on art hits | Needs key (staged) |
| Iron-Sand Hand Bath (Thiết Sa Dục Thủ) | Coating, foreseen and ambush | reused | L4 +50 on body hits, [basic, art] | Needs key (staged) |

No talismans and no escape: the Vow forbids them. **History of the sword:** the commander's blade the grinder sharpened
for thirty years, notched where it split a general's helm; every heir is told never to grind the notch out.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Swept Floor region (tree rework idea) | Undivided at its far end | L5 per empty slot | Fits today |
| 2 | Art speed notables, Sword art speed | +3 / +6 | Rate | ◐ / ○ |
| 3 | Treasure Nurtured Within (capability #3) | first treasure 0 thần thức, +1 %/yr to +50 % | One sword, more free thần thức (ward slots, Open Sky) | Fits today (in data) |
| 4 | Called Blow keystone | crit on a meter, cap 0.35 | A one-art build cannot afford variance | Fits today (Effects GDD) |
| 5 | Crit damage, Physical and Metal damage, `attack_pct` | catalogue sizes | L1 and crit multiplier (cap 3.0) | ● / ○ |
| 6 | Art cost, linh lực regeneration, thần thức | catalogue sizes | Fuel and ward slots | ● |

### Tree region idea: Swept Floor (Tảo Địa)

Hidden clusters and `seal_clusters` were retired on 2026-11-10 (cong-phap.md rule 15), so this is a region idea for
the tree rework, or the Whetstone Scripture's side tree if techniques get those (`design/research/side-trees-thoughts.md`).
Theme: the uncluttered life (loadout and slots), wider than one build: any cultivator who carries little.
Element affinity Metal. 8 acupoints.
Smalls: `art_speed_pct` +2 (×2), `art_cost_pct` −0.5 (×2), `linh_luc_regen_pct` +0.15, `than_thuc_pct` +0.9;
notables Whole Weight (+40 [costly, slow] L2) and, farthest, Undivided. No capability. An idea for the tree rework, not data.

## Đạo

**Đại Đạo, The Great Way Is Simple (Đại Đạo Chí Giản)** — catalogue #88, no requirement. Pieces wanted (the graph is
not drawn; this session did not read `design/dao-ways/`):

- **Giản (Simplicity: power per empty slot):** `major` Clear Path; `minor` Undivided (second host); `minor` Quiet
  Channels (reused); stat lines `art_speed_pct`, `linh_luc_regen_pct`.
- **Nhất (The One: one art, one ward):** `major` Empty Hall; Measured Stroke (existing, Way host) as a notable for
  the evader matchup; stat lines `crit_damage_pct`, `defense_pct`.
- **Bỏ (Letting Go: fewer pieces, stronger ones):** Whole Weight L2 art nodes ×2; Open Sky (existing, Way host) as a
  `minor`; stat line `than_thuc_pct`.
- **Capstone, Less Is Everything:** `bonus_slots` +1 (Modifier System rule 13 accepts it on a Way capstone) and the
  Vow of the One Stroke as a second host.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Trúc Cơ | One slow, crushing stroke every ~5 s behind one or two wards; three rings | Whetstone Scripture (Địa), the Vow, Clear Path | Takes the Vow: gives up the escape art for life |
| Kết Đan | The stroke at 4 s; a cleansing ward joins | Single-Notch Sword, Swept Floor | Inherits or wins the notched sword |
| Nguyên Anh | 3.2 s, five rings, Called Blow's every-third crit | Called Blow, Undivided +50 | First duel against a silencer; survives on the Clear Heart Ward |
| Hóa Thần | 2.5 s, six rings, six wards, pool never below half | Thiên copy, Empty Hall on the technique, capstone slot | Leaves seven slots empty: the Great Way's last lesson |

## Matchups

| Enemy (Combat rule 18) | Result | Why |
|---|---|---|
| Typical ward caster, same realm | wins | The full pool keeps every ward up; the Stroke and the stacks outlast its spending |
| Burst opener (first-volley type) | even | It strikes before 1.56 s; six wards on a full pool usually hold that volley |
| High Physical resistance (≥ 150 points) | even | Sundered −150, `resist_pen_pct` +60 and the Metal stacks bring it back near 0; no second type |
| Evader | loses without Measured Stroke | One evaded Stroke wastes 2.5 s and lays no rings; accuracy and the Measured Stroke fix help |
| Silencer (Silence naming [sword] or [physical]) | loses | A blocked tag stops the only art for up to `curse_duration_max` 5 pulses; only status resistance helps |
| Drainer (Qi Disruption, soul art) | even | 0.125 a Stroke is dear when burned; Soul-Guarding Lamp and Clear Heart Ward answer |
| Healer | wins | Each Stroke is large against a heal per pulse; Blood Drinker matches its sustain |

**Counter:** the Silencer. A curse that blocks the `sword` tag, laid every 5 pulses, leaves the Empty Hall with its
basic attack. The Vow forbids the cleanse art that would answer it, so the answers are `status_resist_pct` and ward
status payloads, which only lower the chance.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Địa 3.0 of 3.0 and Thiên 4.0 of 4.0, each ≤ 1.5 (cong-phap.md Formulas D, `bonus_pool` maxima 15/20/15/15). The Stroke at the lint maximum 6.75; Room to Grow passes the lint by rule, flagged Needs rule. One art in `slots_by_realm` 4–7 (+1). Two artifacts of `equip.max_slots` 6; the sword binds 0 thần thức under capability #3 |
| Validity | PASS | Element `kim`; tiers 2 (to Nguyên Anh) and 3 (to Hóa Thần) cover Trúc Cơ–Hóa Thần; bases `phi_kiem`, `giap`; aux Ore-Vein Scripture names `kim` under a `kim` main; wards are Formulas H starters |
| Stack | PASS | Every rung filled except rung 6 (a stated gap); eleven forms; identity piece named; layer totals stated (L3 short of top-end by choice, L4 empty when blind) |
| Identity test | NOT ASSESSED | No simulator this run (user decision 2026-11-11). Read from the rules: without Empty Hall the target carries no Metal stacks (about +31 % Physical damage taken at Hóa Thần) and nothing reads the slot count as damage outside L5 |
| Scaling | PASS (INFO: above) | M ≈ 133 against the top-end anchor 325, but the coefficient is 9.55: per firing c × M ≈ 1,270 against 325 × 1.6 = 520 for the anchor's mean art (Formulas B gives 1.6 as the typical mean coefficient and none for top-end). Per-second comparison not made: the anchors give no rate |
| The fight | NOT ASSESSED | No simulator this run (user decision 2026-11-11). Read from the rules: the art fires (no guard; cost below regeneration in every realm); cap hits expected: `trig_cap` (the seventh ring, Hóa Thần only) |
| Reuse | PASS | Reused Quiet Channels, Opening Haste, Ore Weight and Ore-Vein Scripture, Nine Rods Array, Iron-Sand Hand Bath (staging); Called Blow, Measured Stroke, Steady Breath, Marked Prey, Blood Drinker, Open Sky, capability #3 (game). Every new piece has a second home; signature pieces: the sword only |
| NPC use | PASS | Every new Effect reads compile slots or a hit event and uses listed actions (rules 5, 6); an NPC "one-stroke hermit" archetype is a generator choice: one art, the Vow. Breakdown lines: "Room to Grow: +2.8 (7 empty slots)", "Empty Hall: 6 rings, 1 dropped (trigger cap)" |
| Counterplay | PASS | The Silencer and the evader (rule 18 profiles) beat it, as Matchups shows |
| Originality | PASS | Names checked against the run's catalogues; the grinder, the Scripture, the sword and the Way pieces are original. Borrowed structure only (PoE-style "empty slot" scaling) |

## Fight Results

No fight input and no simulation this run (user decision 2026-11-11). **The fight: NOT ASSESSED.**

**Unmodelled** (would be, with a simulator): Room to Grow (coefficient past the lint), Empty Hall (rings and Metal
stacks), Clear Path and Undivided (per-slot reads), Quiet Channels, Opening Haste, Called Blow's meter, Blood Drinker.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Vow of the One Stroke | Needs rule + Needs key | Combat Formulas C: a coefficient added after the lint by this enabler only; key `art_coef_add` (F, target art) |
| Opening Haste | Needs rule | combat.md rule 13 and Formulas A2 (staged by first-volley) |
| Measured Stroke | Needs rule | effects.md Starter Effects: the 20 s threshold is unreachable since cooldowns stop at 12 s (#44); lower it to 10 s |
| Empty art slot | Needs rule (clarification) | effects.md rule 5: one meaning of "empty art slot" for every Effect (no art, talisman or ward) |
| Grindstone Stroke, Whetstone Scripture, Ore-Vein Scripture | Needs key | Art records and combat passives have no field in `items_cong_phap.json` |
| Nine Rods Array, Iron-Sand Hand Bath | Needs key | A combat formation; a coating's fight payload (staged) |
