# The Winnowing Gale (Dương Khang Phong)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: "Push every art to cooldown_min with art speed, use only cheap arts, and solve the linh lực bill. Highest hit count per second in the game, to feed per-hit effects. The build that per-hit wards hate."
> **Direction**: The Winnowing Gale: six cheap, quick Wind arts held at the 0.5 s floor; surplus art speed becomes cheaper strokes (Slipstream); hit count multiplies every per-hit sustain modifier.
> **Realm span**: Kết Đan (Core Formation) – Nguyên Anh (Nascent Soul) · **Power level**: top-end · **Use**: player
> **Fit**: 4 Fits today · 12 Needs key · 4 Needs rule (the New Content Needed rows; pieces already designed in a GDD are not counted)
> **Checks**: 8 PASS · 0 FAIL · 2 NOT ASSESSED (The fight and the identity test: no simulator this run, user decision 2026-11-11)

## Directions considered

Specific concept, so three readings. Chosen by this session (unattended run, override 1).

- **Chosen: The Winnowing Gale (Dương Khang Phong).** Wind root. Cheap, quick arts at `cooldown_min`; Wind buff stacks
  supply the art speed; a new Overflow (Slipstream) turns art speed past the floor into lower costs; `linh_luc_on_hit_pct`
  (a plain, uncapped per-hit modifier) is paid 13 times a second. It answers all four parts of the seed with the engine's
  own rules. Its one new rule is a dampened art cost.
- **Not chosen: The Toll Collector (Quan Thuế Giả).** An enabler that gives you a share of every fee and bill the enemy's
  wards pay against your hits (Water Table widened to per-hit wards), so the enemy's defence pays your art costs.
  Great against Golden Bell users and dead against an unwarded thể tu or a reserved ward: a matchup piece, not a chase build.
- **Not chosen: The Storm Drum (Lôi Cổ Liên Hoàn).** A Thunder root with the crit as the per-hit payload: Called Blow's
  meter fills several times a second, and Storm Battery pays for the next strokes. It repeats variant-thunder's Crit
  Storm and Thunder Drum, and its sustain is an Effect, so the trigger cap (6 per pulse) caps it where a plain
  per-hit modifier is not capped.

## The Spine

- **The channel:** art hits, many and small. Six damaging arts, each authored `quick` (under 2 s) and `cheap` (cost share
  ≤ 0.025), all driven to `cooldown_min` (0.5 s), plus the basic attack: **13 hits a second** at Nguyên Anh before
  triggers, against about 1.6 art-and-basic coefficient per second for the typical rotation (Combat Formulas K). Layers
  L1 to L5 apply (L5 through Overheat, Steady Breath and Eruption), crit applies, and every hit meets evade, ward and block.
- **The enabler:** none. The build is a stack of designed pieces (art speed, Wind stacks, art cost, on-hit sustain,
  Overheat, Steady Breath, Still Water) plus one new identity Effect and one rare slot on a named fan.
- **The loop:** each art hit grants Wind buff stacks (art speed) or Wind debuff stacks (the foe's evade falls); each landed
  hit restores linh lực; each firing at the floor clips more art speed, and Slipstream makes the next firing cheaper.
- **The engine:** **the floor is where the bill dies.** Past 0.5 s art speed adds no hits, so the surplus would be
  wasted; Slipstream spends it on cost. Wind stacks keep piling the surplus up, so the longer the fight, the
  cheaper the gale. And `linh_luc_on_hit_pct` is a plain, uncapped modifier (Modifier System rule 1, the sustain
  exception), so 13 hits a second pay it 13 times, where a 3-art caster is paid 2 or 3 times.
- **The sacrifice:** no big hit, no escape art, a thin L2 (cheap arts carry no "more" of their own), Glass Meridians'
  −25 % health, and **no answer to Ice stacks inside the kit**: its cleanse clears curses, not element stacks. It never
  carries a slow art (Breath Between Blows forbids arts over 6 s; nothing here wants one).
- **The arc:** at Kết Đan the gale reaches the floor only after its Wind stacks rise (about 3 s), and the bill is paid by
  Breath Between Blows. At Nguyên Anh compile art speed alone puts every art on the floor at the first stroke (0.500 s,
  all six together), Slipstream carries the bill, and the trigger budget moves from sustain to Echo's extra strokes.

## The Legend

The Winnowing Wind Scripture was written in a drought valley by a woman the village called the Granary Mother. Her sect
owned one spirit vein and no spirit stones to spare, so she cultivated the way she threshed grain: many light strokes,
each costing almost nothing, the chaff carried off by the wind of the last one. "Chaff is light," the first page says,
"but a thousand chaffs bury a man."

She died in the Year of the Late Frost. A cultivator of the Ice root came for the valley's vein, and with every exchange
her strokes grew dearer, until the gale she had kept going for thirty years stopped mid-breath. Her students added one
art to the scripture, a sweep that clears the threshing floor of curses, and they wrote under it that it does not clear
frost. They never found a sweep that does.

The bell monasteries hate the scripture. Their Golden Bell asks a fee for every blow it meets, and the Winnowing Gale is
thirteen blows a second. A bell-ward abbot who meets it is out of linh lực before the second pulse.

## How It Fights

Half a second in, all six arts leave the hands at once, and every half second after that they go again. Each blow is
small. Each one carries a Wind stack, a sliver of linh lực back into the pool, and a little of the enemy's evade away.
By the third second the Wind buff stacks have pushed art speed far past the floor, the strokes cost a third of what they
cost at the start, and the pool stands near full while the gale runs. That keeps Steady Breath lit, and the full pool
keeps the cultivator's own drain ward fed. The enemy does not meet one hit; it meets a weather.

**The signature moment:** a Golden Bell boss-fighter's log. Thirteen ward-fee lines a second, its linh lực bar falling
in steps, Golden Bell going Down unpaid at about 2 s, and then every hit landing with no ward line at all.

## The Stack

Sizes on new modifiers are first guesses. Status: ● exists in data, ◐ designed in a GDD, ○ new (staged).

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Quick, cheap art kit (Winnowing Wind Scripture arts) | c 1.42–1.82 at cost 0.02–0.025, authored 1.0–1.9 s (lint `1 + 24·cost + 0.25·(cd − 1)`) | Flat base | art hit | none | ○ | Công pháp | any quick-art kit (curse-engine, two-clocks) |
| 2 Rate | Art speed (`art_speed_pct`) | +310 % at compile: 1.9 s ÷ 4.1 = 0.463 → floor 0.5 s; sources tree, technique, Phong Đạo, fan, Glass Meridians | Increased | art hit | none | ◐ | Tree, Tech, Way, Item | every art build |
| 2 Rate | Wind buff stacks (Effects rule 9a) | +7.5 % art speed per stack × (1 + 0.002 × purity); arts grant 1 stack for 4 s per hit | Per | art hit | none | ◐ | Arts, root | variant-wind Gale Dancer |
| 2 Rate | Bonus art slot (`bonus_slots` +1) | A seventh slot at Nguyên Anh (sixth at Kết Đan): +2 hits a second | Cap shift (rare) | art hit | none | ◐ (key), ○ (host) | Named item: Granary-Mother's Fan | any art build |
| 3 L1 | Damage increased (`attack_pct`, [phong], [physical]/[force]) | Tree W and technique +15: about +200 (×3.0) | Increased | art hit | L1 | ● | Tree, Tech | every build |
| 3 L2 | Light Chaff (Khinh Khang) | `damage_more` +60 (technique) and +40 (Way notable ×2), scope [quick, cheap] | More | art hit | L2 | ○ | Tech passive, Phong Đạo | curse-engine, two-clocks, dry-well quick arts |
| 3 L3 | Gear attack | Fan (`phien` 32) and a needle (`cham` 22), Cực phẩm, Liệt | Flat base | art hit | L3 | ● | Item | every build |
| 3 L4 | Ringing Ground (Nine Rods Array) and Iron-Sand Hand Bath | +80 all arts, +50 Physical arts, foreseen fights | More | art hit | L4 | ○ (reused, staged) | Formation, coating | first-volley, bare-fist |
| 3 L5 | Overheat (Quá Nhiệt) | Compile art speed the floor clips becomes L5 on that art, point for point, cap +30 | Overflow | art hit | L5 | ◐ | Phong Đạo, MM | variant-wind Gale Dancer |
| 3 L5 | Steady Breath (Bình Tức), scope [phong] | +12 L5 while own linh lực ≥ 50 % (the pool stays high) | Conditional | art hit | L5 | ◐ | Item (fan) | ward casters, cheap arts |
| 3 L5 | Eruption (Phún Trào) | +5 L5 per other art fired in the same instant, cap +25: six arts on one floor timer | Per | art hit | L5 | ○ (reused, staged) | Phong Đạo notable | first-volley |
| 4 Crit | Crit chance and damage | To 50 % and ×2.0–3.0; at 13 rolls a second the average holds, so chance stays a flavour (rule 15) | Flat | art hit | none | ◐ | Tree | every hit build |
| 5 Reach | Wind debuff stacks | −1.2 pp evade per stack on the foe; three arts grant 1 stack for 4 s per hit: about 24 stacks, −33 pp at purity 80 | Per | art hit | none | ◐ | Arts | variant-wind Storm Front |
| 5 Reach | Resistance penetration (`resist_pen_pct` [physical], [force]) | Points through a Physical/Force wall (rule 18 resist profile) | Flat | art hit | none | ◐ | Tree, affix | every Physical build |
| 6 Past the cap | **Slipstream (Thuận Phong)** | Art speed that `cooldown_min` clips on an art (live, at the firing) dampens that art's cost: +1 dampened per 2 pp clipped, cap +200 (cost ÷ 3) | Overflow | art hit (fuel) | none | ○ | Phong Đạo major, Tech passive | variant-wind Gale Dancer, beast-carry (Bonded Spirit speed), curse-engine quick curses |
| 6 Past the cap | Trigger limit (Dư Hưởng) | `trig_cap` +1 (6 → 7 firings between pulses); rare | Cap shift | trigger | none | ○ (tree catalogue idea, staged) | Phong Đạo capstone | curse-engine, armoury-mind, one-art (all hit `trig_cap`) |
| 7 Fuel | Art cost (`art_cost_pct`) | −50 % (the cap): technique −20 [phong], tree −20 [phong] and −13.3 | Increased | art hit | none | ◐ | Tree, Tech | every caster |
| 7 Fuel | Linh lực on hit (`linh_luc_on_hit_pct`) | +0.5 pp of maximum per hit landed (family notable +0.29, fan +0.15, technique passive +0.10 [phong]); 13 hits → 6.5 % a second | Flat (sustain exception) | art hit | none | ◐ | Tree, Item, Tech | every many-hit build |
| 7 Fuel | Breath Between Blows (Gian Tức) | Each art fired restores 1.2 % of maximum linh lực; a trigger, so at most 6 a pulse (7.2 % a second). Closes: no art over 6 s | Trigger (keystone) | fuel | none | ○ (by-root, staged) | MM keystone, Wind land | variant-wind (every Wind build) |
| 7 Fuel | Still Water (Tĩnh Thủy) | Linh lực lost to a full pool heals at half | Overflow | sustain | none | ◐ | MM, Way | ward casters |
| 8 Survival | Health leech (`leech_health_pct`) | +6 % fan, +4 % affix: a share of a very high damage rate returns as health | Flat (sustain exception) | sustain | none | ◐ | Item | every hit build |
| 8 Survival | Common Ward (drain) in ward slots | The pool stays high, so the drain ward has its whole capacity | — | defence | none | ● | Ward | everyone |
| 9 Identity | **Slipstream** (above) | The reason to keep stacking art speed past the floor | Overflow | — | — | ○ | — | — |

**Forms used:** Flat base, Increased, More, Per, Conditional, Overflow, Cap shift, Trigger, Flat (sustain). Nine forms.

**Identity piece:** Slipstream. Without it the build is "every art at the floor", which any art-speed build can reach and
none can pay for: twelve firings a second at 0.0125 each is 15 % of the pool a second against about 12 % of income, so the
pool and with it the ward drain away. With it the surplus speed that Wind stacks pile up past the floor makes each stroke
cheaper, so the bill falls as the fight goes on.

**Empty rungs:** none empty. Thin: **L2** (×2.4–2.85, short of the 300 cap; a sacrifice of cheap arts, which carry no
authored "more") and **L4 blind** (×1.0 outside foreseen fights; accepted).

| Layer | Points at Nguyên Anh (foreseen) | Multiplier | Sources |
|---|---|---|---|
| L1 | +200 | ×3.0 | Tree W (`attack_pct` and [phong]), technique +15 |
| L2 | +140 (Force arts) / +185 (Physical arts) | ×2.4 / ×2.85 | Light Chaff +60 technique, +80 Phong Đạo; Ore Weight +45 [physical] from the Ore-Vein Scripture (auxiliary, staged by triple-convert) |
| L3 | about +170 | ×2.7 | Fan and needle, Cực phẩm Nguyên Anh tier with Liệt (smaller bases than first-volley's seals) |
| L4 | +80 (Force) / +130 (Physical) | ×1.8 / ×2.3 | Nine Rods Array (Ringing Ground), Iron-Sand Hand Bath; blind 0 |
| L5 | +67 | ×1.67 | Overheat +30, Steady Breath +12, Eruption +25 |

`M` for a Physical art, foreseen: 3.0 × 2.85 × 2.7 × 2.3 × 1.67 ≈ **89**. Blind: ≈ **38**. Top-end anchor at Nguyên Anh:
256 (Combat Formulas B). The build is under the anchor per hit and far over it per second (see Checks, Scaling).

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Wind (Phong), innate, purity 70+, on any base root; Metal or Earth base suits the Physical arts' tags | Wind buff stacks are art speed, Wind debuff stacks are the evade answer; purity multiplies both (`1 + 0.002 × P`, linh-can.md Formulas H) |
| Key talents | Comprehension (ngộ tính) for layer 12; enough Root bone (căn cốt) to offset Glass Meridians | The scripture's L12 cleanse and L9 Slipstream |
| The Way (Đạo) | Phong Đạo · Thanh Phong: facets Cuồng Phong (Gale: art speed) and Phiêu (Drift: Wind stacks) | Slipstream, Overheat, Light Chaff notables, art speed and stack lines |

## Công Pháp

### Winnowing Wind Scripture (Dương Khang Phong Quyết) — main, Địa giai (tier 2), 12 layers, names `phong`

A drought valley's threshing method, written as breathing: many light strokes, the last one's wind carrying the chaff.

```json
{"id": "duong_khang_phong_quyet", "name": "Dương Khang Phong Quyết", "tier": 2, "tech_kind": "main",
 "names": ["phong"], "layers": 12,
 "bonuses": [{"stat": "attack_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 20},
             {"stat": "defense_pct", "value": 15}],
 "abilities": [{"ability_id": "khang_cham", "unlock_layer": 1},
               {"ability_id": "pha_xac_tram", "unlock_layer": 2},
               {"ability_id": "duong_phong_thuc", "unlock_layer": 4},
               {"ability_id": "sang_chuong", "unlock_layer": 6},
               {"ability_id": "da_coc_vu", "unlock_layer": 8},
               {"ability_id": "khong_xac_phong", "unlock_layer": 10},
               {"ability_id": "tao_truong", "unlock_layer": 12}],
 "seal_clusters": [], "origin": "authored"}
```

Passives (no field in `items_cong_phap.json` yet): L3 Light Chaff `damage_more` +60 [quick, cheap] L2; L5 `art_speed_pct`
+40 [phong]; L7 `linh_luc_on_hit_pct` +0.10 [phong]; L9 Slipstream (second host); L11 `art_cost_pct` −20 [phong].

**Fit:** Needs key (passives and ability records have no field yet). **Budget:** 15/15 + 20/20 + 15/15 = **3.0 of 3.0**,
each 1.0 ≤ 1.5 (cong-phap.md Formulas D; pool maxima as other tier-2 templates in the staging catalogue). Abilities do not
count. `max_realm` Nguyên Anh covers the span.

## Arts

All arts are first guesses at the lint's limit, with the stack charge (Effects Formulas D: buff 0.010, debuff 0.015 per
stack-second). Derived tags from the authored record: under 2 s is `quick`, cost ≤ 0.025 is `cheap` (Modifier System rule 10).

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Chaff Needle (Khang Châm) | Scripture L1 | Physical hit; phong, physical, art, quick, cheap | 1.42 (lint 1.48 × 0.96) | 0.02 | 1.0 s | — | Needs key |
| Husk-Splitting Cut (Phá Xác Trảm) | Scripture L2 | Physical hit; phong, physical, sword, art, quick, cheap | 1.71 (1.825 × 0.94) | 0.025 | 1.9 s | — | Needs key |
| Winnowing Toss (Dương Phong Thức) | Scripture L4 | Force hit; phong, force, art, quick, cheap | 1.75 (1.825 × 0.96) | 0.025 | 1.9 s | — | Needs key |
| Sieve Palm (Sàng Chưởng) | Scripture L6 | Force hit; phong, force, palm, art, quick, cheap | 1.71 (1.825 × 0.94) | 0.025 | 1.9 s | — | Needs key |
| Threshing Rain (Đả Cốc Vũ) | Scripture L8 | Physical hit; phong, physical, art, quick, cheap | 1.64 (1.825 × 0.90) | 0.025 | 1.9 s | — | Needs key |
| Empty-Husk Gust (Không Xác Phong) | Scripture L10 | Force hit; phong, force, art, quick, cheap | 1.82 (1.825) | 0.025 | 1.9 s | — | Needs key |
| Sweeping the Floor (Tảo Trường) | Scripture L12 | Cleanse; cleanse, art (no `phong` tag) | — | 0.03 | 2.0 s | own status Silence or Heavy Breath | Needs key |

- **Chaff Needle.** Effect: hit; grants its owner 1 Wind buff stack for 4 s. Description: the first straw off the fork.
- **Husk-Splitting Cut.** Effect: hit; lays 1 Wind debuff stack for 4 s (−1.2 pp evade). Description: the edge that opens the husk.
- **Winnowing Toss.** Effect: hit; grants its owner 1 Wind buff stack for 4 s. Description: grain thrown up into the wind.
- **Sieve Palm.** Effect: hit; lays 1 Wind debuff stack for 4 s. Description: the shake that lets nothing through but grain.
- **Threshing Rain.** Effect: hit; grants 1 Wind buff stack and lays 1 Wind debuff stack, each for 4 s. Description: flails falling in turn.
- **Empty-Husk Gust.** Effect: hit, no stacks: the kit's plain damage. Description: what the wind does to what is left.
- **Sweeping the Floor.** Effect: cleanse every curse with the `curse` cleanse tag from its owner. It carries no `phong` tag, so a
  Silence that names [phong] cannot stop it; it clears no element stacks, so Ice stacks stay. Description: added by the
  founder's students, with the note "it does not clear frost".

Why 1.9 s and not 1.0 s: the lint gives 0.25 coefficient per authored second, and art speed takes the authored second
back. A 1.9 s art is still `quick` and is 23 % larger than a 1.0 s art at the same cost; it needs +280 % art speed to
reach the floor instead of +100 %. The build buys that art speed, so it authors every art at the edge of `quick`.
Chaff Needle stays at 1.0 s so the first stroke reaches the floor at Kết Đan before the rest.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Kết Đan | 5 + 1 (fan) = 6 | Chaff Needle, Husk-Splitting Cut, Winnowing Toss, Sieve Palm, Threshing Rain, Empty-Husk Gust | Common Ward in ward slots | No cleanse; the compile art speed (about +150 %) floors only Chaff Needle; the rest reach 0.5 s as Wind stacks rise |
| Nguyên Anh | 6 + 1 (fan) = 7 | The six above, then Sweeping the Floor | Common Ward; Clear Heart Ward against an Ice foe | Compile art speed +310 %: all six fire together at 0.500 s; Eruption full |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Granary-Mother's Fan (Thương Mẫu Phiến) | Named artifact, weapon role | `phien`, Cực phẩm, Kết Đan and Nguyên Anh tiers | `bonus_slots` +1 (rare, named items only: Modifier System rule 13), `art_speed_pct` +30, `linh_luc_on_hit_pct` +0.15, `leech_health_pct` +6; carries Steady Breath scope [phong] | Fits today (named item on designed keys; Steady Breath lists Item hosts) |
| A needle (Châm), Cực phẩm, Liệt | Weapon | `cham` (attack 22, thần thức 10) | Cheap in thần thức; L3 with the fan | Fits today |
| Gale affixes (Tật, Hồi Khí, Hấp Huyết) | Affix rows | any base | `art_speed_pct` +5–15, `linh_luc_on_hit_pct` +0.05–0.15, `leech_health_pct` +2–6: what a generated piece rolls for this build | Needs key (rows in `items_artifacts.json` affixes on designed keys) |
| Nine Rods Array (Cửu Can Trận) | Formation, foreseen | — | Ringing Ground +80 L4 | Needs key (staged, reused) |
| Iron-Sand Hand Bath (Thiết Sa Dục Thủ) | Coating, foreseen and ambush | — | +50 L4 on the Physical arts | Needs key (staged, reused) |

The fan: the Granary Mother's own winnowing fan, its frame reed and its face a hundred layered feathers; her students
say it held the wind still in the year it stopped. One fan in a cultivator's hands strikes like seven.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Linh lực on hit, [phong] family notable | +0.29 pp per hit | Paid 13 times a second | Fits today (◐ designed) |
| 2 | Art speed [phong] family notables (×3), universal (×2) | +20 / +13.3 each | Compile +310 % | Fits today (◐) |
| 3 | Art cost [phong] and universal notables | −20 / −13.3 | To the −50 % cap | Fits today (◐) |
| 4 | Glass Meridians (keystone) | +40 art speed; −25 % health, half body shields | The glass in the gale | Fits today (◐ designed Effect) |
| 5 | Breath Between Blows (Wind land keystone) | 1.2 % per art fired, 6 a pulse | The Kết Đan bill | Fits today (staged) |
| 6 | Still Water (keystone) | Overflow heals at half | Turns the surplus into health | Fits today (◐) |
| 7 | Crit chance and damage, accuracy | to caps | Rung 4 | Fits today |

### Tree region idea: Threshing Floor (Cốc Trường)

Hidden clusters and `seal_clusters` are retired (cong-phap.md rule 15), so this is an open region idea in the Wind land
for the tree rework, not data. Theme: many light strokes (art speed, art cost and per-hit sustain), wider than this
build: any quick-art kit, curse casters, companion keepers. Wind affinity. Eight acupoints: `art_speed_pct` +2 (×2),
`art_cost_pct` −0.5 (×2), `linh_luc_on_hit_pct` +0.03 (×2); notables `linh_luc_on_hit_pct` +0.19 and, farthest,
`art_speed_pct` +20 scope [quick]. No capability.

## Đạo

**Phong Đạo · Thanh Phong** (dao.md § Catalogue #21, requirement Wind). Facets used, as staged pieces (the graph is not
drawn; this session did not read design/dao-ways):

- **Cuồng Phong (Gale: art speed):** stat lines `art_speed_pct` [phong], `art_cost_pct` [phong], `linh_luc_on_hit_pct`;
  notables Light Chaff (+40 [quick, cheap] L2) ×2; Overheat (existing, Way host) as a `minor`; Eruption as a notable;
  the facet's `major` is **Slipstream**.
- **Phiêu (Drift: evade, Wind stacks):** stat lines `stack_effect_pct` [phong, buff] and [phong, debuff],
  `stack_duration_pct` [phong].
- **Capstone line:** Trigger limit (Dư Hưởng) `trig_cap` +1 (a rare cap shift; Way capstones are an allowed rare host).

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Trúc Cơ | A quick-art Wind caster, two or three arts | The scripture's first layers; Chaff Needle | Finds the scripture in a dead granary's rafters |
| Kết Đan | The gale reaches the floor after ~3 s of Wind stacks; Breath Between Blows pays the bill | Fan (Kết Đan tier), Glass Meridians, sixth slot | Takes the Granary Mother's fan from her last student |
| Nguyên Anh | Six arts on one 0.5 s timer from the first stroke; Slipstream carries the bill; Echo uses the trigger budget | Slipstream, Phong Đạo nodes, cleanse art, Trigger limit | Meets the frost that killed the founder, and has to bring a ward she never had |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Golden Bell or Surging Tide user (per-hit ward) | Wins | Fee 0.035 (0.027) of their maximum per hit × 13 hits: 45 % (35 %) of their pool a second; dry by about 2 s, then no ward at all (combat.md rule 23) |
| Typical drain-ward cultivator | Wins | The drain bill does not care about hit count; the rate of damage does the work |
| Evasive profile (40 % cap) | Wins | Wind debuff stacks (about −33 pp) and accuracy take it to near 0 within 2–3 s |
| Boss with a big pool | Wins slowly | Sustain holds; damage rate is the build's strength |
| Thể tu with block | Even to wins | Flat block takes a fixed amount per hit, after resistance: at Nguyên Anh a hit of about 15,000 that a ward stopping ~80 % leaves at ~3,000 loses 237 to a thể tu's block (8 %), 372 with Iron Shirt (12 %). It costs a tenth, not the fight |
| Physical/Force resistance wall (rule 18, 150+ points) | Loses some | Every art is Physical or Force; answer with `resist_pen_pct` |
| Ice applier with Heavy Breath (the frost) | Loses | Ice adds +3.9 % cost per stack, no cap; 40 stacks multiply every cost by 2.56 and the bill passes income. The cleanse art clears Heavy Breath, not the stacks |
| Silence naming [phong] | Loses for 3 pulses | Every damaging art is `phong`; Sweeping the Floor (no `phong` tag) clears it |

**Counter:** an Ice-stack applier (rule 18's enemy kinds include Cold dealers; any Ice root lays Ice debuff stacks)
with Heavy Breath. It turns the cheap strokes dear. Answer: Clear Heart Ward (reserved 0.25, cleanses 25 % of every
debuff batch a pulse) in a ward slot, and fewer arts in the loadout.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Technique bonuses 3.0 of 3.0, each 1.0 ≤ 1.5. Art lint: every c at or under `1 + 24·cost + 0.25·(cd − 1)` × (1 − charge), charges 0–0.10 ≤ 0.6. Slots: Kết Đan 5 + 1, Nguyên Anh 6 + 1 (`bonus_slots` from a named item, allowed by Modifier System rule 13). Artifacts: fan (thần thức 25), needle (10) and ward gear, well under a top-end budget; exact thần thức not computed. Technique passives have no budget field (no field exists) |
| Validity | PASS | `phong` is a real element tag (Wind, linh-can.md); bases `phien`, `cham` exist; tier 2 (Địa giai) reaches Nguyên Anh (cong-phap.md, `max_realm` NS); derived tags `quick` (< 2 s) and `cheap` (≤ 0.025) by Modifier System rule 10; Physical and Force are Wind's types (combat-damage-types.md rule 1 table). No auxiliary technique required; the optional Ore-Vein Scripture (kim) is staged by triple-convert, harmony not checked |
| Stack | PASS | All nine rungs filled; nine forms; identity piece Slipstream; L5 modifiers only on hits (this channel); layer totals stated above, L2 and blind L4 thin and named |
| Identity test | NOT ASSESSED | No simulator this run (user decision 2026-11-11). By the rules alone: without Slipstream the steady bill at Nguyên Anh is about 14.5 % of maximum a second against about 11.8 % income, so the pool and the ward drain away over the fight; with it the bill is about 6.6 %. That is a reading, not a run |
| Scaling | PASS (INFO) | Per hit M ≈ 89 foreseen / 38 blind against the top-end anchor 256. Per second: about 21 coefficient a second (12 × 1.68 + 1) against the typical rotation's 1.6, so sustained offence ≈ 21 × 89 ≈ 1,870 against a top-end volley build's 256 × a few coefficient a second. Above the anchors in rate; noted, not pulled back (only macro targets matter) |
| The fight | NOT ASSESSED | No simulator this run (user decision 2026-11-11). Unmodelled by any run: Slipstream, Wind stack growth, Echo, Eruption, Breath Between Blows, per-hit fees on the enemy |
| Reuse | PASS | Second homes named for every new modifier; signature pieces: the fan only. Reused: Eruption, arts-fired-this-instant, Nine Rods Array, Iron-Sand Hand Bath, basic attack speed, preparation fight payload (staging); Overheat, Steady Breath, Still Water, Glass Meridians, Echo (Effects GDD); Breath Between Blows (by-root); Trigger limit (tree catalogue) |
| NPC use | PASS | Slipstream reads compile stats, live element stacks and the art's record, and has one Breakdown line ("Slipstream: 220 pp clipped, cost ÷ 2.1"); Light Chaff is a plain scoped `more`; the arts are plain records. A Wind NPC generator can roll the kit |
| Counterplay | PASS | Ice applier with Heavy Breath (cost tax), a Physical/Force resistance wall, a Silence on [phong] (rule 18 profiles) |
| Originality | PASS | Names are new (Granary Mother, Winnowing Wind Scripture, Slipstream/Thuận Phong as a rule name); the structure (attack speed and on-hit sustain) is a common genre structure, not a lifted name or character |

## Fight Results

Not run: no simulator this run (user decision 2026-11-11). No fight input was written.

**Unmodelled:** everything; see Checks.

## New Concepts

- **Dampened art cost.** Art cost accepts the `dampened` op (Modifier System rule 6a): `cost = cost_share · (1 −
  cost_red) · (1 + cost_raise) · qi_max ÷ (1 + D/100)`. Bounded by shape (never 0); Slipstream caps itself at +200. Rule:
  combat.md Formulas E; Stat List row "Art cost" gains `D`. Breakdown: "Slipstream: cost ÷ 2.1". Serves: this build,
  variant-wind Gale Dancer, any art-speed build past the floor (beast-carry's Bonded Spirit keeper, curse-engine's quick curses).
- **"A hit landed" for on-hit sustain.** Clarify that `linh_luc_on_hit_pct` and `leech_*` read every own hit that is not
  evaded (art, basic, companion and trigger free hits), and that a hit fully stopped by block still lands.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Slipstream (Thuận Phong) | Needs rule | Dampened art cost (combat.md Formulas E; modifiers.md Stat List `art_cost_pct` op D) |
| Trigger limit (Dư Hưởng) | Needs rule | `trig_cap` +1 as a rare cap shift (combat.md Formulas G; modifiers.md rare table) |
| Hit-landed definition | Needs rule | Clarification, modifiers.md rule 1 sustain exception and AC-MD-33 |
| Eruption (reused) | Needs rule | effects.md rule 5 readable "arts you fired this instant" |
| Light Chaff (Khinh Khang) | Fits today | `damage_more` L2 by tag is designed; content rows |
| Winnowing Wind Scripture and its seven arts | Needs key | Ability and passive fields in `items_cong_phap.json`; art records |
| Granary-Mother's Fan | Fits today | Named item on designed keys |
| Gale affixes | Needs key | Affix rows in `items_artifacts.json` |
| Breath Between Blows (by-root) | Fits today | Event "an art fired" and action "restore linh lực" exist; an Effect record |
| Phong Đạo Cuồng Phong and Phiêu pieces | Needs key | Way graph nodes (not drawn) |
| Threshing Floor | Fits today | Tree region idea on designed keys, for the rework |
| Nine Rods Array, Iron-Sand Hand Bath (reused) | Needs key | Combat formation; coating fight payload |
