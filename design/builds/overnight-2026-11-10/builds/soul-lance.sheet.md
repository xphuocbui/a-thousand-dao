# Soul Lance (Hồn Thương)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses.
> **Seed**: "Soul arts skip ward, guard and evade and ignore the multiplier layers; they scale with thần thức squared and are bounded by soul_lockout. Build the strongest legal soul sniper: thần thức as the only stat that matters, and what it spends its artifact budget on instead."
> **Direction**: The Mountain-Bearing Lance (Phụ Sơn Hồn Thương), chosen by the session under the overnight override (Directions considered, below)
> **Realm span**: Kết Đan (Core Formation) to Hóa Thần (Deity Transformation) · **Power level**: top-end · **Use**: player · **Kind**: min-max
> **Fit**: 9 Fits today · 9 Needs key · 3 Needs rule (counting the three Hồn Đạo facets and the seven arts one by one)
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: no soul-art lint exists in Combat, so the three soul arts cannot be checked against one, and the technique's passive is outside `bonus_pool`; The fight: `fight_calc.py` reports CONSTANT_DRIFT on 31 of 60 constants and cannot model Slackened Soul, soul shields or the three new Effects, and the paper model `soul-lance.sim.py` could not be run in the unattended session)

## Directions considered

Seed shape: **game concept** (the rule is given; the lore and the stack are not). Three directions, one lens each.

**Chosen: The Mountain-Bearing Lance (Phụ Sơn Hồn Thương).** Lenses: *invert the resource* and *stack the useless
stat*. A soul build has no use for a weapon (Layer L3 does nothing for a soul hit), and it has far more thần thức than
its artifacts need. So it spends the artifact budget on *weight*: six or seven heavy treasures, none of them weapons,
whose bound thần thức becomes soul attack damage (Thousand-Weight Thought), while the same thần thức buys two extra
free ward slots and the walls that keep the sniper alive. Thần thức feeds four systems at once. Fit: Needs keys (art
records) and one Needs rule. It was chosen because it answers both halves of the seed, gives the player a real decision
(heavy treasures against light, strong ones; Open Sky against Thousand-Weight Thought), and stays legal under every
cap: it never touches `soul_cap` or `soul_lockout`.

**Not picked: The Empty Hall (Không Điện).** Carry nothing: every empty artifact slot adds soul attack damage and all free
thần thức goes to Open Sky's ward strength. A cleaner "pure mind" fantasy, but its answer to "what does it spend the
artifact budget on" is "nothing", and it loses the walls it needs against bosses and soul rivals.

**Not picked: The Lamp-Thief (Đạo Đăng).** The surprise reading: a soul hit takes the same share of linh lực as of
health, so the build is really a linh lực starver. It works, but it is a side effect every soul build already has, not
a stack; its one good piece (Lamp-Oil Siphon) is kept here as fuel.

## The Spine

- **The channel:** soul art (Combat rule 24, Formulas E2). A soul hit takes `min(soul_pct · (1 + x_soul/100) · ρ² · supp, soul_cap)`
  of the foe's maximum health **and** maximum linh lực, where ρ is thần thức over the foe's thần thức (raised by its soul
  resistance). It skips evade, resistance, block, every ward and body shield, crit and all five layers; only soul
  resistance, soul wards and soul shields meet it. Its two hard limits are `soul_cap` 0.30 per hit and `soul_lockout`
  1 s between a side's soul arts, so the channel's ceiling is **0.30 of both pools per second**, four lances to kill
  from full. Layers L1 to L5: all empty, on purpose.
- **The enabler:** none. The soul channel is already in the rules; what the game lacks is content (no technique holds a
  soul art today). The build is a stack plus one identity Effect.
- **The loop:** the Needle loosens the soul (Slackened Soul, −30 pp, no floor), the next art lands on the loosened soul,
  and a soul art fires at every lockout end, one a second; between lances the walls hold and the heal art mends.
- **The engine:** thần thức is one number that feeds four systems. Squared, it is the lance (ρ²). Past 3.5× the realm's
  reference it buys **+2 free ward slots** (Combat Defence & Healing Formulas D). It is the **artifact capacity** that lets
  the build wear six or seven heavy treasures a typical cultivator could not lift. And through **Thousand-Weight Thought**
  the weight of those treasures comes back as soul attack damage. Every bell it wears for its walls also sharpens
  its lance.
- **The sacrifice:** no damage layers, no weapon, no crit; its basic attack is a mortal's. Against a boss every share is
  divided by `boss_pool_mult`. Against stacked soul resistance and against another soul cultivator it slows to a crawl, and
  two realms up it does nothing at all. It refuses to fix these with hit damage.
- **The arc:** at Kết Đan a lamp-reader who kills ordinary cultivators in four breaths and struggles with strong ones, short
  of linh lực. At Nguyên Anh the seventh treasure, the passive and the loosening Needle carry the lance across the cap
  against strong foes and one realm up. At Hóa Thần the Ninth-Weight Lance ends almost any fight of its realm in four
  or five seconds, and what is left to fear is what killed the founder: something larger than a mountain.

## The Legend

High on a cold ridge stood a shrine of hanging bells, kept by people who were going blind. The keepers trained by
lifting the shrine's bronze bells with thought alone and holding them aloft through the night; a keeper who could hold
all nine could thread a needle through a lamp flame without bending it. They never struck anyone with a bell. The
weight was the training: a mind that carries a mountain can push a needle through anything smaller.

The last true keeper wrote it down as the **Lamp-Threading Scripture** (Xuyên Đăng Bí Điển) before she went to read the
soul of the great toad that slept under the next ridge, and her lance broke on it. The scripture's last line is hers:
*a lance cannot cross a mountain larger than the one it carries.* Her disciples scattered with the bells. The heaviest,
the Bronze Shrine Bell, is useless to almost anyone else: it binds half an ordinary cultivator's thần thức and does nothing
in their hands.

Lance keepers are rare and unloved. When one passes through a city the price of Soul-Guarding Lamps doubles, and sects that
fear them keep a lamp-bearer at every gate.

## How It Fights

It does not draw a weapon. Six or seven treasures hang in the air around it, bells and seals and a banner, and none of
them is ever swung. Each second a thread of thought leaves it: the first loosens the foe's soul, the next goes through
the loosened place, and every hit takes the same share of the foe's health and linh lực at once, so the foe's wards go
dark with its body. An ordinary foe is dead at the fourth lance; most strong ones by the fifth or sixth. Its walls
(four to six free wards and its heavy treasures) are there for the fights that last longer: bosses, rivals and
cultivators above its realm.

**Signature moment:** a strong Nguyên Anh foe with a full ward and an evasion art loses 20, 28, 30 and 28 % of its health
and linh lực at 1, 2, 3 and 4 s (30 % at 2 s once the Needle's Slackened Soul is counted) and falls at exactly 4.000 s (fight_calc), its linh lực empty. By hand, Soul Wound and
Splinters of Thought push its first two arts back about 1 s each, so it fires at most one (not modelled by fight_calc).

## The Stack

The build's modifiers, in order up the ladder. Sizes on new pieces are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Soul strength (Thần Hồn), `than_hon` | Flat onto effective soul strength: small +0.40, notable +2.66 | Flat base | soul (via ρ²) | none | ● | Tree, Lamp Wick cluster, Hồn Đạo | any artifact master, formation master |
| 1 Base | Thần thức (Thần Thức), `than_thuc_pct` | +0.9 small, +6 notable; technique bonus +22.5; capability #2 +20 | Increased | soul (via ρ²), ward slots, capacity | none | ● | Tree, Xuyên Đăng Bí Điển, capability #2, Hồn Đạo | any artifact master (dual-earth-metal) |
| 1 Base | Soul art share, `soul_pct` | 0.031 / 0.043 / 0.055 / 0.064 on the four soul arts | Flat base | soul | none | ◐ (field designed, Combat E2) | Arts of Xuyên Đăng Bí Điển | any soul art |
| 2 Rate | Art speed, `art_speed_pct` | +60 (Kết Đan), +100 (Nguyên Anh on). Stop when the Needle's effective cooldown reaches 1.000 s (the lockout) | Timing | soul | none | ◐ | Tree, Hồn Đạo Hồn Kích | any art build |
| 2 Rate | First Move (Tiên Thủ) | The first soul art of the fight is free | Rule swap | soul | none | ◐ (effects.md) | Way, Item | alpha strikes, soul openers |
| 3 Multiplier | Soul attack damage, `x_soul` | +1.5 small, +10 notable, +12 notable scoped [thuy]; Still Flame passive +30; Soul-Piercing affix +5 to +15 | Increased | soul | own sum (not a layer) | ◐ / ○ affix | Tree, technique passive, artifacts, Hồn Đạo | every soul build (Mind Blade, Mirage) |
| 4 Certainty | — (by rule) | A soul hit cannot be evaded and cannot crit, so the build is deterministic | — | soul | none | ● | Combat rule 24 | — |
| 5 Reach | Slackened Soul (Tùng Hồn) | −15 pp soul resistance a stack, 2 stacks, 2 pulses, **no floor**: on a foe with 0 it reaches −30 and multiplies ρ by 1.3 | Trigger (curse rider) | soul | none | ● (effects.md) | Lamp-Threading Needle | any soul build |
| 5 Reach | Realm pierce, `pierce_pct` | +0.5 / +3; suppression applies to soul and pierce works on it | Increased | soul | none | ● | Tree | vượt cấp builds |
| 6 Past the cap | Splinters of Thought (Niệm Tiết) | What `soul_cap` clips from a soul hit delays the foe's next ready art: 0.5 s per 0.10 clipped, cap 1.5 s, once per lockout | Overflow | soul | none | ○ | Hồn Đạo Hồn Kích (major) | Mind Blade, Mirage, any soul build |
| 6 Past the cap | Soul Wound (Thương Hồn) | Each soul hit delays the foe's next ready art 0.5 s | Trigger | soul | none | ◐ (effects.md) | Hồn Đạo, technique | every soul build |
| 7 Fuel | Lamp-Oil Siphon (Hấp Đăng Du) | When your soul hit takes the foe's linh lực, restore 25 % of the points taken | Trigger | soul → linh lực | none | ○ | Hồn Đạo (shared minor), Phệ Đạo Hắc Khẩu | dry-well, Phệ Đạo soul drain |
| 7 Fuel | Regeneration, `linh_luc_regen_pct` | +0.15 / +1 | Increased | any | none | ● | Tree | any sustain build |
| 8 Survival | Ward slots by thần thức | +2 free ward slots at 3.5 × ds_ref (Combat Defence & Healing Formulas D) | Borrow (rule) | defence | none | ● | Combat Defence & Healing | any high-thần-thức build |
| 8 Survival | Open Sky (Không Thiên) | Ward strength +0.5 per 1 % of thần thức not bound to artifacts, cap +30 | Per | defence | none | ◐ (effects.md) | Meridian Map, Way | ward builds, artifact-free builds |
| 9 Identity | **Thousand-Weight Thought (Thiên Quân Niệm)** | Soul attack damage (`x_soul`) +1 per 1 % of your thần thức bound to artifacts, cap +60 | Borrow / Per | soul | own sum | ○ | Hồn Đạo Thần Thức (major), named item | any soul build that carries treasures: Mind Blade (dual-metal-water), Incense Burner (triple-wood-fire-earth) |
| 9 Identity | Heavier treasures: Bronze Shrine Bell's own `than_thuc_cost_pct` +100; Mother Lode (Mẫu Khoáng), +20 % thần thức cost per refined piece | A cost that every other build avoids, taken on purpose | Trade | soul (via the identity) | none | ○ / by-root | Named item; Meridian Map content | dual-earth-metal (where it is a cost) |

**Forms used (8):** Flat base, Increased, Timing, Rule swap, Trigger, Overflow, Per/Borrow, Trade.

**Identity piece:** Thousand-Weight Thought. It is the mirror of Open Sky: Open Sky pays for thần thức left *free*,
Thousand-Weight Thought pays for thần thức *bound*. Because a soul build has two or three times the thần thức its gear
needs, the choice is real: light, strong armour (Giáp costs 5 and defends 30) and a big Open Sky, or heavy treasures
(the Bell binds 50, the Seal 30) and a lance that crosses the cap. It is also why the build wants a stat everyone else
reduces (`than_thuc_cost_pct`). Without it the build loses its best x_soul source at Kết Đan (60 of 85) and the
fight changes (Fight Results).

**Empty rungs:** none empty. L1 to L5 are a **sacrifice**: the build takes no layer modifier, because a soul hit reads none
(Modifier System rule 8 rejects damage scoped [soul]). Crit is replaced by certainty, by rule.

| Layer | Points at Nguyên Anh | Multiplier | Sources |
|---|---|---|---|
| L1 to L5 | 0 | ×1.00 each | Empty by design: soul hits skip the layers. The basic attack is the only thing they would touch |
| Soul's own sum (`x_soul`) | 157 | ×2.57 | Thousand-Weight Thought 60, tree 35, Still Flame 30, affixes 20, Hồn Kích notable 12 |
| ρ² (thần thức) | vs strong foe 2.54, loosened 4.43 | | 260 talent-units (talent 100 × stage 1.30 × 2.00) against 142 at soul resistance 15 |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Single Water (Thủy), purity 70+ | Soul arts carry no damage element, so the root only names the art tag. Water gives the fastest cultivation of a single root, the existing Huyền Thủy main techniques (`dia_thuy`, `thien_thuy`), [thuy]-scoped x_soul (+12 per notable rather than +10) and the still-water lore of the shrine |
| Key talents | Soul strength (thần hồn) 85+ base, then talent pills and flat nodes to an effective 100–105; Comprehension (ngộ tính) for technique layers | Thần thức is talent × realm × stage × (1 + %): every point of soul strength is squared in the lance. A Fated life with thần hồn 70+ is the build's invitation; a self-made birth sets it to 100 |
| Capability | #2 Divided Divine Sense (Thần Thức Phân Hóa), Nguyên Anh | +20 % thần thức and a seventh artifact slot, the seventh weight |
| The Way (Đạo) | Hồn Đạo · *Nguyên Thần* (34): Thần Thức, Hồn Kích and Hồn Hộ facets (Đạo, below) | The Way that holds the build's three new Effects |

## Công Pháp

Main method: **Huyền Thủy Địa Quyết** (`dia_thuy`, Earth tier, to Nguyên Anh), then **Huyền Thủy Thiên Kinh** (`thien_thuy`,
Heaven tier, to Hóa Thần). Both exist; their `linh_luc_pct` and `defense_pct` bonuses feed fuel and walls. The soul arts
live in a secret art.

### Lamp-Threading Scripture (Xuyên Đăng Bí Điển) — secret art, Thiên giai (tier 3)

*The shrine keepers' book: how to hold a bell up with thought, and how to put a needle through a flame.*

```json
{"id": "xuyen_dang_bi_dien", "name": "Xuyên Đăng Bí Điển", "tier": 3, "tech_kind": "secret",
 "names": ["thuy"], "layers": 15,
 "bonuses": [{"stat": "than_thuc_pct", "value": 22.5}, {"stat": "linh_luc_pct", "value": 20},
             {"stat": "defense_pct", "value": 15}, {"stat": "tam_ma_resist_pct", "value": 7.5}],
 "abilities": [{"ability_id": "lamp-threading-needle", "unlock_layer": 1},
               {"ability_id": "lamp-light", "unlock_layer": 4},
               {"ability_id": "mountain-splitting-thought", "unlock_layer": 6},
               {"ability_id": "heart-lamp-lance", "unlock_layer": 8},
               {"ability_id": "lantern-out", "unlock_layer": 9},
               {"ability_id": "bell-of-waking", "unlock_layer": 12},
               {"ability_id": "ninth-weight-lance", "unlock_layer": 15}],
 "effects": ["still-flame"], "seal_clusters": ["lamp-wick"], "origin": "authored"}
```

Passive **Still Flame (Tĩnh Diễm)**, layer 11: `x_soul` +30 (a combat passive; no field holds it yet).

**Fit:** Needs key (abilities and the passive have no catalogue or field) · **Budget:** 22.5/15 + 20/20 + 15/15 + 7.5/15 =
1.5 + 1.0 + 1.0 + 0.5 = **4.0 of 4.0** (Thiên), each line ≤ 1.5 (`bonus_single_cap`). The passive is outside `bonus_pool`,
so its budget is NOT ASSESSED. Harmony: the secret art names `thuy`, the main names `thuy`.

## Arts

Soul art sizes follow a **proposed soul lint** (suggestions.md): `soul_pct ≤ 0.0125 × art lint`, the art lint being
Combat Formulas C's `1 + 24 · cost_share + 0.25 · (cooldown − 1)`, inside E2's band 0.03–0.08. Today no lint binds
`soul_pct` at all.

| Art | Source, layer | Kind, tags | Size | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Lamp-Threading Needle (Xuyên Đăng Châm) | Xuyên Đăng Bí Điển, 1 | soul; thuy, soul, hit, art | soul_pct 0.0306 (lint 2.45) | 0.05 | 2 s | — | Needs key |
| Mountain-Splitting Thought (Phá Sơn Niệm) | 6 | soul; thuy, soul, hit, art | soul_pct 0.0429 (lint 3.43) | 0.07 | 4 s | — | Needs key |
| Heart-Lamp Lance (Tâm Đăng Thương) | 8 | soul; thuy, soul, hit, art | soul_pct 0.0551 (lint 4.41) | 0.09 | 6 s | — | Needs key |
| Ninth-Weight Lance (Cửu Quân Thương) | 15, replaces the Heart-Lamp Lance | soul; thuy, soul, hit, art | soul_pct 0.0644 (lint 5.15) | 0.10 | 8 s | — | Needs key |
| Lamp-Light (Đăng Quang Dưỡng) | 4 | heal; thuy, art | c_heal 4.47 (heal lint 1.4 × 3.19) | 0.06 | 4 s | own health at or below 85 % | Needs key |
| Lantern Out (Đăng Tắt) | 9 | escape; thuy, escape, art | — | 0.05 | 4 s | own health at or below 30 % | Needs key |
| Bell of Waking (Tỉnh Hồn Chung) | 12 | cleanse; soul, cleanse, art | — | 0.03 | 3 s | own status: Slackened Soul or Silence | Needs key |

- **Lamp-Threading Needle. Effect:** soul hit; on landing applies Slackened Soul, 2 stacks (−30 pp, 2 pulses). It fires
  just before the Lance in each lockout cycle, so the Lance lands on the loosened soul. The curse rides free today; if
  dry-well's suggestion (charge curses in the art lint) is adopted, the Needle's `soul_pct` falls by that charge.
  **Description:** the needle that does not bend the flame.
- **Mountain-Splitting Thought. Effect:** soul hit. The middle weight that fills the lockout between Needle and Lance.
  **Description:** a thought pushed as one pushes a bell off a ledge.
- **Heart-Lamp Lance. Effect:** soul hit, the largest share. With art speed +100 it fires every 3 s, always one lockout after
  the Needle. **Description:** the keeper's own heart, thrown.
- **Ninth-Weight Lance. Effect:** soul hit; replaces the Heart-Lamp Lance at great completion. **Description:** what a keeper
  who holds all nine bells can push.
- **Lamp-Light. Effect:** heal art under the heal lint; refunds its cost when it restores health (Combat Defence & Healing
  rule 16). Sustain for the long fights (bosses, rivals). **Description:** the lamp is trimmed and the room is warm again.
- **Lantern Out. Effect:** escape art (Combat Formulas I). **Description:** the keeper puts out its own light and is not
  there.
- **Bell of Waking. Effect:** cleanse: removes curses with the `soul` or `seal` cleanse tag from its owner (Slackened Soul,
  Silence). The answer to the rival lance keeper and to a Silence that names [soul]. **Description:** one bell rung
  inside the head.

## Loadout by Realm

| Realm | Slots | Slot order | Wards (free ward slots) | Note |
|---|---|---|---|---|
| Kết Đan | 5 | Heart-Lamp Lance, Mountain-Splitting Thought, Lamp-Threading Needle, Lamp-Light, Lantern Out | 4 (2 + 2 by thần thức): Common Ward, Golden Bell, Mountain Screen, and Soul-Guarding Lamp against a soul foe (else Thousand-Layer Cloud) | Art speed +60: lances at 1.25, 2.5, 3.5, 4.5 s … Fuel is the weak point |
| Nguyên Anh | 6 | as above, + Bell of Waking | 5: Common Ward, Golden Bell, Mountain Screen, Thousand-Layer Cloud, Soul-Guarding Lamp | Art speed +100: a soul art every second from 1.000 s; cycle Lance, Thought, Needle from 6 s |
| Hóa Thần | 7 | Ninth-Weight Lance, Thought, Needle, Lamp-Light, Lantern Out, Bell of Waking, Golden Light Shield | 6: as above + Clear Heart Ward against cursers and poisoners (else Surging Tide) | The burst answer: Golden Light Shield (existing cast ward) in an art slot |

The slot order matters: when two soul arts are ready at a lockout end, the earlier slot fires. Putting the Lance first
and the Needle third makes the cycle Lance, Thought, Needle, so the Needle's 2-pulse curse always covers the Lance.
Reserved linh lực with the full Nguyên Anh ward set is 0.304 (Mountain Screen 0.060, Soul-Guarding Lamp 0.20,
Thousand-Layer Cloud 0.044); drop the Lamp when no soul foe is foreseen.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| **Bronze Shrine Bell (Đồng Từ Chung)** | Named artifact, ward role | `chuong`, Cực phẩm, Linh bảo (refined up a tier per realm) | Authored lines: `than_thuc_cost_pct` +100 (it binds 50 base units, twice a bell), `artifact_defense_pct` +30, `x_soul` +15, `khi_huyet_pct` +10. The heaviest piece: a third of the weight Thousand-Weight Thought needs | Fits today (named item, existing keys) |
| Seal (Ấn) | Generated, weapon role | `an`, Thượng phẩm | Carried for its weight (30), not its attack. Roll: Soul-Piercing (`x_soul`) | Fits today |
| Bell (Chuông) | Generated, ward role | `chuong`, Thượng phẩm | Weight 25, defence 25: the best weight-and-wall piece | Fits today |
| Banner (Kỳ) | Generated, ward role | `ky` | Weight 20, defence 15 | Fits today |
| Shield (Thuẫn) | Generated, ward role | `thuan` | Weight 15, defence 35 | Fits today |
| Armour (Giáp) | Generated, body role | `giap` | Weight 5, defence 30: the light piece, for block and body shield | Fits today |
| Gourd (Hồ Lô), Nguyên Anh | Generated, ward role | `ho_lo` | The seventh weight (capability #2's slot), 25 | Fits today |
| **Soul-Piercing affix (Thấu Hồn)** | Affix row, `x_soul` +5 to +15, weight 6 | any base | A generated piece a soul build can roll for. **Never take a Linh affix** (thần thức cost −10 to −30): it lightens the piece | Fits today (a data row on an existing key) |
| **Lamp-Clear Pill (Minh Đăng Đan)** | Pill, preparation (foreseen and ambush) | — | For one fight, `x_soul` +25; adds pill toxicity (đan độc) as its recipe sets. For bosses and soul-warded foes | Needs key (a pill's fight payload) |

Total weight bound: Kết Đan 145 talent-units (Bell 50, Seal 30, Bell 25, Banner 20, Shield 15, Armour 5) of 198
thần thức, 73 %; Nguyên Anh 170 of 260 (+ Gourd), 65 %; Hóa Thần 204 of 314 (Mother Lode's +20 % on refined pieces), 65 %.
Thousand-Weight Thought is at its cap of +60 at each. Artifact costs and thần thức both scale by the realm's M (1/3/10/30/100),
so these shares hold at every realm. A typical cultivator (≈ 59 units) could carry the Bell and one bell more.

No talisman and no formation: the soul channel ignores L4, so **a blind fight costs this build nothing** (Combat rule 12).

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Thần thức (`than_thuc_pct`) notables | +6 | Squared in the lance; also ward slots and capacity. No falling return below the cap | Fits today |
| 2 | Soul attack damage (`x_soul`) notables, scoped [thuy] | +12 | Linear, but the build's only multiplier | Fits today (designed key) |
| 3 | Soul strength (`than_hon`) notables | +2.66 | +2.66 % thần thức at talent 100 | Fits today |
| 4 | Art speed (`art_speed_pct`) | +3 notable | To +100, then **stop**: the Needle sits at 1.000 s, the lockout. Each further +100 only raises the Lance's share of the cycle (≈ +14 % average share) | Fits today (designed) |
| 5 | Capability #2 Divided Divine Sense | +20 % thần thức, +1 artifact slot | The seventh weight | Fits today |
| 6 | Realm pierce (`pierce_pct`) | +3 notable | One realm up only | Fits today |
| 7 | Regeneration (`linh_luc_regen_pct`) | +1 notable | Kết Đan fuel | Fits today |
| 8 | Open Sky (Meridian Map host) | ward strength per free 1 % | The other end of the dial: +13.5 to +17.5 ws on the build's 27–35 % free thần thức | Fits today (designed) |
| — | Unyielding Breath (keystone) | — | Optional, against burst foes that would kill before the fourth lance; costs 15 % health | Fits today (designed) |

### Hidden cluster idea: Lamp Wick (Đăng Tâm)

Theme: divine sense, the mind's weight (wider than this build: artifact masters, formation masters and every soul
build read it). Water affinity. **Sealed**, 8 acupoints; seal: the Lamp-Threading Scripture lists it in
`seal_clusters`. Smalls: thần thức +0.9 (×3), soul strength +0.40 (×2), soul attack damage +1.5 (×1). Notables: thần thức
+6 (middle) and, farthest from the entry, soul attack damage +12 scoped [thuy]. No capability. An idea for the tree
rework, not data.

## Đạo

Not a new Way: **Hồn Đạo · Nguyên Thần (34)** in dao.md's catalogue already has the facets this build wants (Thần Thức,
Hồn Kích, Hồn Hộ, Linh Bộc, Khôi Lỗi), and its requirement is "—". Nodes wanted (the graph is drafted separately; this
sheet did not read it):

- **Thần Thức (Divine Sense):** stat lines `than_thuc_pct` and `than_hon`; its `major` Effect **Thousand-Weight Thought**;
  Open Sky as a shared `minor`.
- **Hồn Kích (Soul Strike):** stat lines `x_soul` and `pierce_pct`; its `major` Effect **Splinters of Thought**; Soul Wound
  as a `minor` (already lists Way as a host).
- **Hồn Hộ (Soul Ward):** stat lines `soul_res_pct` and `defense_pct`; the build's defence against the rival lance keeper.
- **Lamp-Oil Siphon** as a shared `minor` of Hồn Đạo and Phệ Đạo (Hắc Khẩu, the Maw: soul drain).

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Kết Đan | A slow hunter: 4.5 s against an ordinary foe, 8.75 s against a strong one, ≈ 15 s against a lamp-warded strong one. Runs dry around 9 s without the Siphon | Heart-Lamp Lance (layer 8), Lantern Out (9); Bronze Shrine Bell; six weights | Inherits the Bell from a dying keeper; nobody else can lift it |
| Nguyên Anh | The lance crosses the cap: 4.0 s against strong foes, 6.0 s one realm up, 6.0 s against a lamp-warded strong foe | Still Flame (11), Bell of Waking (12), capability #2 and the seventh weight | Sects post lamp-bearers at their gates; the price of lamps doubles |
| Hóa Thần | Ends nearly every fight of its realm in 4–5 s; bosses take 14 s; a rival lance keeper ≈ 26 s | Ninth-Weight Lance (15), Mother Lode refining, Golden Light Shield | The great toad under the next ridge is still there |

## Matchups

Closed-form soul shares (Combat E2, exact for this channel) with the cadence fight_calc confirmed; survival is the
fortress's and is not fully modelled (The fight check). Foe thần thức is a first guess (Combat Defence & Healing Open
Question 12): typical 59.4 talent-units, strong 142 with soul resistance 15. "Lamp" adds Soul-Guarding Lamp (22.5 pp × (1 + ws/100), soul shield 0.50 on a 0.10 bar).

| Enemy | Kết Đan | Nguyên Anh | Hóa Thần | Why |
|---|---|---|---|---|
| Typical, same realm | wins, 4.5 s | wins, 4.0 s | wins, 4.0 s | ρ 3.3–5.3: every hit capped; the channel's ceiling |
| Typical with a Soul-Guarding Lamp | wins, 5.5 s | wins, 5.0 s | wins, 5.0 s | The shield bar soaks ≈ 0.06 of health once; still capped |
| Strong (top-end soul defence) | wins, 8.75 s | wins, 4.0 s | wins, 4.0 s | ρ² 1.47 / 2.54 / 3.70; loosened by the Needle |
| Strong with a Lamp | even, ≈ 15 s | wins, 6.0 s | wins, 5.0 s | Soul resistance 51 pp; the Needle takes it to 21 |
| Typical, one realm up | wins, ≈ 9.75 s | wins, 6.0 s | — | ρ 1.11 / 1.31, suppression 0.93 with pierce 0.30 |
| Strong, one realm up | loses | loses | — | ≈ 0.04 a second; it kills first |
| Anyone, two realms up | loses | loses | — | ρ ≈ 0.33, share ≈ 0.01 a hit |
| Boss (`boss_pool_mult` 4) | ≈ 15 s | 14.0 s | 14.0 s | Capped 0.30 ÷ 4 = 0.075 a hit; the walls must hold 14 s |
| Rival lance keeper (mirror, both Lamps) | — | even, ≈ 26 s | even | ρ 0.56 (0.68 loosened); sustain and Bell of Waking decide it |
| Top-end burst (kills in its first volley) | loses | loses or even | even | Needs four lances by 4 s; Soul Wound pushes its first art from 2.0 to ≈ 3.0 s; Golden Light Shield and Unyielding Breath at Hóa Thần |

**Counter:** the soul-resistant enemy that Combat rule 18 requires at every realm (high resistance to the Soul group),
best with a Soul-Guarding Lamp and its own high thần thức: it turns four lances into fifteen or more. A **boss** divides
every share by its pool multiplier. A curser who carries **Silence naming [soul]** stops every soul art for 3 pulses
(Bell of Waking is the answer, from Nguyên Anh). Above all, **a realm gap**: thần thức triples per realm, so the lance
is useless two realms up.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 4.0 of 4.0 (Thiên), each line ≤ 1.5: pass. Heal art c_heal 4.47 at the heal lint (1.4 × 3.19): pass. Slots 5/5, 6/6, 7/7: pass. Artifacts 6/6 (`equip.max_slots` 6), 7/7 with capability #2's slot; thần thức bound 145/198, 170/260, 204/314: pass. **Not assessed:** Combat has no lint for `soul_pct`, so the soul arts can only be checked against the proposed one (all four at its maximum); the Still Flame passive is outside `bonus_pool` |
| Validity | PASS | Element `thuy`; tier 3 (Thiên) `max_realm` `hoa_than` covers Kết Đan to Hóa Thần; layer unlocks follow ⌈k/3⌉ (Lance at 8 = Kết Đan, Ninth-Weight at 15 = Hóa Thần); main `dia_thuy` then `thien_thuy` exist; aux harmony thuy/thuy; bases `chuong`, `an`, `ky`, `thuan`, `giap`, `ho_lo` exist; wards from Combat Defence & Healing Formulas H; Slackened Soul, Soul Wound, Open Sky, First Move and capability #2 exist; soul hits applying Slackened Soul is allowed (effects.md, Sundered's row) |
| Stack | PASS | Every rung filled; L1–L5 named a sacrifice; 8 forms; nothing targets a layer the channel lacks (no `damage_more`, no L5 Effect). Identity test: at Kết Đan, `x_soul` 85 → 25 (Thousand-Weight Thought removed) turns a win at 11.000 s into a loss at 12.000 s with the foe at 24 %; at Nguyên Anh 157 → 97 moves the kill from 4.000 s to 5.000 s (fight_calc). By hand against a lamp-warded strong foe: 6.0 s → 8.0 s |
| Scaling | PASS (INFO) | m_static 1.00 against anchors 7.37 / 256 means nothing for this channel: soul hits skip M. The soul measure is the share per second against the channel's ceiling of 0.30: reached against typical foes at every realm and against strong foes from Nguyên Anh, which is top-end. INFO: at the ceiling, not above it; no cap is moved |
| The fight | NOT ASSESSED | `fight_calc.py --selftest` passes its fixtures but prints CONSTANT_DRIFT on 31 of 60 constants (health_units 16 against 64, the retired ward/guard model, regen_base 0.02 against 0.035, the anchors). It cannot express Slackened Soul, soul shields, Soul Wound, Splinters, the Siphon, the heal art or the fortress (UNMODELLED). The soul constants match combat.md, and the cadence it shows (1, 2, 3, 4 s) and its kill times match the closed form exactly. The paper model `soul-lance.sim.py` (on the canonical #44 sim) could not be run: the unattended session had no approval to run a new script. Its fuel line: own linh lực dry at 8.75 s at Kết Đan with no Siphon modelled |
| Reuse | PASS | Every new piece has a second home except the Bronze Shrine Bell (one signature). Reused: Soul Wound, Open Sky, First Move, Slackened Soul, Unyielding Breath, six wards, capability #2, `dia_thuy`/`thien_thuy`, Mother Lode (by-root missing pieces). The ledgers' modifiers are hit or tick pieces (L2, L4, L5), none of which a soul hit reads, so none fit |
| NPC use | PASS | Every new piece reads compile values or fight events (bound thần thức, a clipped cap, a soul hit) and has no player input; each has a one-line Breakdown ("Thousand-Weight Thought: 65 % bound, soul attack damage +60"). The generator can take Hồn Đạo nodes like any other |
| Counterplay | PASS | Combat rule 18's soul-resistant enemy, bosses (`boss_pool_mult`), the soul-piercer rival, a Silence naming [soul], and any foe a realm up with strong soul defence |
| Originality | PASS | Names checked as plain Hán-Việt images (lamp, needle, bell, weight); no novel or game names, sects or signature techniques |

## Fight Results

Input: `soul-lance.fight.json` (Nguyên Anh, the defining realm) and `soul-lance.fight-ket-dan.json` (the second realm).
Observations from `fight_calc.py`, a paper model with expected values for chance, not the game. The foe is the script's
"typical" damage fixture carrying the strong foe's soul (thần thức 142 talent-units, soul resistance 15).

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical fixture, strong soul (NA) | 0 | win; own health 54 %, foe linh lực 0 % | 4.000 s | never | none named (soul_cap is not reported by the script) |
| same, `x_soul` 97 (no Thousand-Weight Thought) | 0 | win | 5.000 s | never | — |
| same, `--without x_soul` | 0 | loss, foe at 8 % | 8.000 s | 6.000 s | — |
| same, `--without heart-lamp-lance` | 0 | win | 4.000 s | never | The lockout, not the Lance, is the limit against this foe |
| typical fixture (NA) | 1, 2 | loss | 3.000 s | 2.000 s | Not valid for soul: the script does not scale the foe's thần thức by realm (UNMODELLED) |
| top_end fixture (NA) | 0, 1, 2 | loss | 1.000 s | 1.000 s | The pre-#44 top-end anchor ends every fight in 1 s ("re-derive" in Formulas B) |
| typical fixture, strong soul (KĐ) | 0 | win; own health 1 % | 11.000 s | 8.750 s | Lance blocked 4 instants by cost |
| same, `x_soul` 25 (KĐ, no Thousand-Weight Thought) | 0 | loss, foe at 24 % | 12.000 s | 8.750 s | — |

Closed-form soul shares, Nguyên Anh, x_soul 157, against the lamp-warded strong foe (soul resistance 51, 21 loosened):
Needle 0.116 (0.058 after the shield), Thought 0.253 (loosened), Lance 0.208, Thought 0.162, Needle 0.116, Lance 0.30
(loosened, capped): **kill at 6.0 s**. Without Thousand-Weight Thought, 8.0 s; without Slackened Soul, 7.0 s.

**Unmodelled:** Slackened Soul; soul shields; Soul Wound; Splinters of Thought; Lamp-Oil Siphon; First Move; the heal,
escape and cleanse arts; the fortress (free ward slots, layered wards, Open Sky, seven defensive artifacts); the foe's
thần thức across realms; health at 64 units rather than 16.

## New Concepts

**A soul-art lint.** Combat rule 24 and Formulas E2 give `soul_pct` a band (0.03–0.08) and nothing else, so a soul art
at 0.08 can be authored at the cheapest cost and a 1 s cooldown. Since the lockout already caps the rate, the open
hole is cost: the cheapest legal soul art is the best one. Proposal: `soul_pct ≤ soul_lint_k × (art lint)`, with
`soul_lint_k` 0.0125, so the most expensive and slowest art (lint 6.75) reaches 0.084 and is clipped to 0.08. It serves
every soul build (Mind Blade, Mirage, Incense Burner, Hồn Đạo arts). Question for the user: adopt the lint, or another
price for soul arts (suggestions.md).

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Thousand-Weight Thought | Fits today | Effect record (reads free thần thức at compile, effects.md rule 5; payload `x_soul`) |
| Splinters of Thought | Fits today | Effect record (reads `soul_cap`'s clipped amount, a named cap; action: move a timer) |
| Lamp-Oil Siphon | Needs rule | effects.md rule 5: the linh lực a soul hit takes, as a readable (event payload) |
| Soul-Piercing affix | Fits today | A row in `items_artifacts.json` affixes on `x_soul` |
| Bronze Shrine Bell | Fits today | A named artifact with authored lines on existing keys |
| Lamp-Clear Pill | Needs key | A pill's fight payload (`x_soul` for one fight) |
| Lamp-Threading Scripture and Still Flame | Needs key | Abilities and combat passives have no field in `items_cong_phap.json` |
| Seven arts | Needs key | Art records (Combat rule 13); soul-art size, cleanse art and escape art formats |
| Hồn Đạo nodes (Thần Thức, Hồn Kích, Hồn Hộ) | Fits today | Graph nodes when Hồn Đạo is drawn |
| Lamp Wick cluster | Fits today | A cluster idea for the tree rework |
| Mother Lode (from by-root) | Fits today | Meridian Map content |
| Soul-art lint | Needs rule | combat.md Formulas C or E2 |
| Reference thần thức and soul resistance by realm | Needs rule | combat-defence.md Open Question 12; this sheet's foe values are guesses until it exists |
