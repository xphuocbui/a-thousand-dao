# The Thousand-Year Banyan (Thiên Niên Dung Thụ)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses.
> **Seed**: "Sustain is king. A build that cannot lose a 60 s fight: regeneration at regen_cap, many health and linh lực sustain sources, damage low but certain. The tank that wins by being alive at the end, and the enemy type that is built to break it."
> **Direction**: Surplus Life: healing the build does not need becomes Poison on the enemy, and fatigue finishes what the Poison does not (chosen by the session under the run's override; the other directions are under Directions considered).
> **Realm span**: Kết Đan to Hóa Thần · **Power level**: top-end (sustain); damage low by design · **Use**: player
> **Fit**: 9 Fits today · 6 Needs key · 2 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 2 NOT ASSESSED (The fight; the identity test: no simulator this run, user decision 2026-11-11)

**A note on the seed's `regen_cap`.** That cap no longer exists. The Combat economy revision (#44) removed `regen_cap`,
`dot_pool_cap`, `dot_pulse_cap` and `qi_burn_cap` (combat.md Parameter keys). Today linh lực regeneration has a log curve
with no ceiling (`regen_k` 0.08, Formulas E), and health regeneration has no cap at all (combat-defence.md Formulas E).
This sheet reads "at regen_cap" as "regeneration pushed to the point where more stops paying". For linh lực that point
is the log curve: +6 pp of bonus counts as +4.48, +30 as +12.47. Health has no curve, so the build makes its own stop
point: past full health, healing is wasted, and the identity piece spends that waste.

## Directions considered

Chosen: **Surplus Life (Dư Sinh)**, below. It wins on two clocks. Overheal turns into Poison, which kills an ordinary foe
in about 20–40 s. Fatigue from 60 s is flat, so the side with the bigger bar and the faster regeneration falls last. It
uses the seed's own words: "damage low but certain" (ticks never miss or crit) and "alive at the end" (fatigue).

Not picked:

- **The Last Lamp (Tàn Đăng)**, the pure pacifist: no damage at all, it wins only through fatigue, with a bigger bar,
  regeneration and Unyielding Breath. It fits today with no new piece.
  Not picked because every fight runs past 60 s with nothing happening, and any healer with more health beats it. It
  survives as this build's Kết Đan stage.
- **The Still Lake (Tĩnh Hồ)**, a linh lực loop: a full pool, Still Water turning overflow into health, and wards as
  the only defence. Not picked because bare-fist's Stored Breath already owns "linh lực overflow becomes damage", and
  this would be a near copy that spends the overflow on health.
- **The Thorn Bark (Kinh Bì)**, a retaliation tank: hits that reach it come back as damage (by-root Thorns).
  Not picked because its damage depends on being hit, so the main counter, a ticking curse kit, never feeds it. It also
  breaks "certain": a reflected hit can be evaded.

## The Spine

- **The channel:** Poison ticks (Wood's debuff: Chaos, `c_tick` 0.019 a stack) laid by an Effect, plus fatigue. Ticks
  skip evade and block and never crit, so the damage is certain. They scale on L1 to L4, and L5 is empty by the
  channel's nature. Chaos passes body shields; only Chaos and all resistance cut it. The backstop channel is fatigue
  (combat.md rule 10): it is flat, it is the same for both sides of one realm, and no Effect changes it.
- **The enabler:** Surplus Life (Dư Sinh), a keystone-tier Effect. Healing lost to a full health bar lays Poison on the
  enemy. It closes **Rooted (Bám Rễ)**: your evade cap is 0, and you may slot no escape art.
- **The loop:** regenerate, top up with a refunding heal art, overflow, lay Poison, regenerate. Each pulse the bar is
  full again, and the part that would not fit becomes stacks on the enemy.
- **The engine:** the more the enemy hurts it, the less it hurts them, and the reverse. Poison per pulse is your
  healing minus the damage you took. So against a foe it can out-heal, the build kills on a fixed clock. Against a foe
  it cannot, it stops attacking and spends everything on staying alive until fatigue. Still Water closes the circle:
  linh lực lost to a full pool becomes health, so spare linh lực also becomes Poison.
- **The sacrifice:** burst, evade and flight. It refuses a big hit (no art hit above 0.7), refuses evade (Rooted), and
  refuses to run. It wins late or not at all.
- **The arc:** a sapling at Kết Đan that only outlasts (fatigue, no Surplus Life yet). At Nguyên Anh Surplus Life opens
  and the bark starts to poison. At Hóa Thần an old tree that grows stronger with every century it has lived (Growth
  Rings).

## The Legend

There is a banyan on the road to the Ninefold Ford that grew over a shrine, split it, and kept the bell inside its
trunk. Pilgrims say the shrine's last keeper sat under it through three sieges and was never touched, because every
soldier who camped in its shade sickened and left. The sect that took the tree as its teacher calls its method the
Thousand-Root Spring: water drunk from below, wood grown above, and nothing wasted.

Those who walk it now are patient and hard to like. They do not win quickly, they do not run, and an elder of the path
at twelve hundred years old is harder to kill than he was at three hundred. The sects that fight them carry salt:
curses that wither healing and still the breath, and wards that wash the rot away. A banyan in salt ground is just a
big tree.

## How It Fights

The fight starts with the cultivator at full health, and nothing it does is fast. Spring Sap and Underground Spring
fire every 2 s for almost nothing, holding about thirty Wood stacks (health regeneration) and thirty Water stacks
(linh lực). Banyan Shade heals whenever the bar dips below 95 %, so it always refunds its cost. From the first pulse,
whatever the bar cannot hold goes onto the enemy as Poison. Against a foe that cannot dent the bar, the Poison counter
climbs to a steady pile in 10 s and stays there. Against a foe that can, the counter stalls and the build simply holds.
At 60 s fatigue begins, flat and equal for both sides. The bigger bar, refilling faster, is the one that stays up.

**The signature moment:** an enemy's big volley lands, the bar drops to 70 %, and the Poison counter stops cold. Two
pulses later the bar is full again and the counter starts to climb. The enemy's damage paid for nothing.

## Enabler

**Surplus Life (Dư Sinh)**, a keystone-tier Effect (Overflow; a scaling bridge from healing to damage).

- **Rule:** healing lost to your full health bar (overheal, from any source: regeneration, heal arts, leech, Still
  Water, Effects) is counted over the pulse window. At the pulse, lay 1 Poison stack for 10 s on the enemy for each
  1 % of your maximum health overhealed, at most 30 stacks a pulse. Fractions carry to the next pulse.
- **Reads:** a new event, health overflow (the healing lost to a full bar, Needs rule: effects.md rule 5; the linh lực
  overflow event already exists).
- **Action:** grant element stacks (effects.md rule 6, exists). The Poison is yours, at your values and your Wood
  purity when laid (rule 9a).
- **Closes: Rooted (Bám Rễ).** Your evade cap is 0, and you may slot no escape art. This uses two existing closing-rule
  actions: lower an owner's cap, and forbid a slot kind.
- **Where it lives:** Mộc Đạo, as the Sinh Trưởng facet's keystone (Nguyên Anh), and the Thousand-Root Spring
  Scripture (Địa layer 11, Thiên layer 12). A player needs one host.
- **Why the close bites:** evade is free defence for everyone else (cap 0.40). Refusing it means the bar eats every
  hit, which is exactly what this build is designed to do. Refusing escape means a fight it is losing cannot end in
  flight.

## The Stack

The build's modifiers, in order up the ladder. Sizes on new pieces are first guesses. ● exists, ◐ designed, ○ new.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Health regeneration (`health_regen_pct`) | pp of maximum health per pulse, no cap | Flat | sustain → Surplus Life | none | ◐ | Scripture passive, Banyan-Bark Mantle, Hồi Xuân affix, Heartwood cluster | every healer and tank |
| 1 Base | Wood buff stacks via Spring Sap | +0.1 pp health regeneration a stack (× purity) | Flat (stacks) | sustain | none | ◐ (art staged) | Scripture layer 1 (reused art) | two-clocks (its source) |
| 2 Rate | Stack duration [moc] (`stack_duration_pct`) | Longer Wood buff and Poison batches, so more held at once | Increased | sustain, tick | none | ◐ | Mộc Đạo Sinh Trưởng lines, Heartwood cluster | every Wood stack build |
| 2 Rate | Growth Rings (Niên Luân) | +0.1 pp health regeneration per 100 years of age, cap +1.5 pp (compile) | Per | sustain | none | ○ | Banyan-Bark Mantle; Sinh Tử Đạo Trường Sinh minor | old NPC elders and sect guardians; any long-lived body build |
| 3 Multiplier | Healing (`healing_pct`) and health regeneration, increased (`health_regen_inc_pct`) | Multiply every heal, regeneration included (combat-defence.md Formulas E) | Increased | sustain | none | ◐ | Scripture Thiên passives, Heartwood notables, pill | every healer |
| 3 Multiplier | `attack_pct` [poison] | L1 on the Poison | Increased | tick | L1 | ◐ | tree, weapon | every Poison build |
| 3 Multiplier | Rot Deepens (Thi Độc Thâm) | `damage_more` +40 / +60 [poison] | More | tick | L2 | ○ (content ledger) | Scripture layer 9 | Burial Shroud, two-clocks |
| 3 Multiplier | Corpse-Wax Coating (Thi Lạp) | prepared `damage_more` on ticks | More | tick | L4 | ○ (content ledger) | coating | Burial Shroud, two-clocks |
| 3 Multiplier | Stack effect [moc, debuff] (`stack_effect_pct`) | More damage per Poison stack | Increased | tick | none | ◐ | Mộc Đạo lines | every Poison build |
| 4 Certainty | (the channel) | Ticks never miss or crit, and stacks from an Effect take no apply roll (suggestion 2) | — | tick | — | ● | — | — |
| 5 Reach | Chaos penetration (`resist_pen_pct` [chaos]) via the Thực affix | Lowers the target's Chaos resistance points | Flat | tick | none | ◐ (affix staged) | generated weapon | triple-convert, every Poison build |
| 6 Past the cap | **Surplus Life (Dư Sinh)** | Overheal becomes Poison | Overflow | sustain → tick | none | ○ | Mộc Đạo keystone; Scripture | identity piece (see second homes below) |
| 6 Past the cap | Still Water (Tĩnh Thủy) | Linh lực lost to a full pool restores health at half | Overflow | linh lực → sustain | none | ◐ | Mộc Đạo or Thủy Đạo (Way host), tree | bare-fist, Lotus on Still Water |
| 6 Past the cap | The Spring Never Fails (Tuyền Bất Kiệt) | +0.025 pp linh lực regeneration a Water stack, outside the log curve | Rule swap | linh lực | none | ○ (by-root) | Water land keystone | single-water, Spring Rain, Lotus on Still Water |
| 7 Fuel | Quiet Channels (Tĩnh Mạch) | +0.5 pp linh lực regeneration per art slot holding no art or a ward, cap +3 | Per | linh lực | none | ○ (staged) | Heartwood cluster far notable (and Porter's Shoulder) | bare-fist (its source) |
| 7 Fuel | Spillover (Dật Độc) | Ticks burn 25 % of what they deal as the enemy's linh lực | Overflow | tick → linh lực | none | ◐ | Scripture layer 7 | every Poison build |
| 8 Survival | Sap Rises (Nhựa Thăng) | +1 % healing per Wood buff stack | Per | sustain | none | ○ (by-root) | Heartwood cluster notable | single-wood Evergreen Wall |
| 8 Survival | `khi_huyet_pct`, `healing_taken_pct`, `reserve_eff_pct`, `status_resist_pct`, `body_shield_pct` | Bar size (fatigue margin), the answer to Withering, room for reserved wards, the answer to curses | Increased, Flat | survival | none | ● / ◐ | tree, Mantle, Scripture | every tank |

**Second homes of the identity piece.** Surplus Life serves any build whose healing outruns its damage taken: by-root
Spring Rain and the Evergreen Wall (Wood healers), the Lotus on Still Water (Still Water's overflow becomes health,
then Poison), and NPC sect guardians. It is not a signature piece. It is the healer's general answer to "heals do
nothing at full health".

**Identity piece:** Surplus Life. Without it, the build is The Last Lamp. It can win only through fatigue, and its
healing past full is wasted. With it, every point of sustain the enemy does not force it to spend becomes damage.

**Empty rungs:**

- **L5 (sacrifice):** ticks never take L5 (combat.md Formulas F). Gorged would add L5 to the two buff arts' tiny hits
  only, so it is left out.
- **Crit (sacrifice):** ticks cannot crit. Certainty replaces it.
- **Burst (sacrifice):** there is no finisher. The build waits.

| Layer | Points at Hóa Thần (first guess) | Multiplier | Sources |
|---|---|---|---|
| L1 | +80 | ×1.80 | `attack_pct` [poison] and Way W on the tree, weapon |
| L2 | +80 | ×1.80 | Rot Deepens +60 (Thiên passive), Mộc Đạo notable +20 |
| L3 | +50 | ×1.50 | a generated weapon (Châm or Phiến) at Hóa Thần tier |
| L4 | +40 | ×1.40 | Corpse-Wax Coating (foreseen and ambush fights only; blind fights lose it) |
| L5 | 0 | ×1.00 | empty: ticks never take L5 |
| **M** | | **×6.80** | Below the typical anchor 8.96 at Deity Transformation, on purpose: the damage is certain, not large |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water and Wood, Wood purity high (80+), Water 60+ | A generating pair (Water feeds Wood). Wood purity powers both the Wood buff (regeneration) and the Poison it lays (×(1 + 0.002 × P), effects.md rule 9a). Water powers the Water buff at half share |
| Key talents | Căn cốt (Physique) high, then Ngộ tính (Comprehension) | Căn cốt: +2.22 % health a point (combat-defence.md H), so a bigger bar and a longer fatigue margin. Ngộ tính: reaching the technique's late layers, where Surplus Life sits |
| The Way (Đạo) | Mộc Đạo · Khô Vinh (Wither and Bloom): Sinh Trưởng facet (keystone Surplus Life, Sap Rises lines), Rễ for Still Water; optionally Sinh Tử Đạo's Trường Sinh facet for Growth Rings | "The forest outlives everything" is this build's capstone idea in dao.md § Catalogue. This session did not read design/dao-ways (out of scope) |

## Công Pháp

### Thousand-Root Spring Scripture (Thiên Căn Tuyền Kinh) — main, Địa giai and Thiên giai

"Drink from below, grow above, and let nothing fall that the roots can catch."

```json
{
  "id": "thien_can_tuyen_kinh",
  "name": "Thiên Căn Tuyền Kinh",
  "tier": 3,
  "tech_kind": "main",
  "names": ["moc", "thuy"],
  "layers": 15,
  "bonuses": [
    {"stat": "khi_huyet_pct", "value": 15},
    {"stat": "linh_luc_pct", "value": 20},
    {"stat": "defense_pct", "value": 15},
    {"stat": "lifespan_years", "value": 15}
  ],
  "abilities": [
    "L1 art spring_sap", "L2 passive health_regen_pct +1.0", "L3 art underground_spring",
    "L5 art banyan_shade", "L7 passive Spillover (existing Effect)", "L8 art shedding_bark",
    "L9 passive damage_more +60 [poison] L2 (Rot Deepens)", "L11 passive healing_pct +30",
    "L12 Surplus Life (enabler, closes Rooted)", "L14 passive health_regen_inc_pct +40"
  ],
  "seal_clusters": ["heartwood"],
  "origin": "authored"
}
```

The Địa giai copy (Thiên Căn Tuyền Quyết, tier 2, 12 layers, to Nguyên Anh) has `khi_huyet_pct` 15, `linh_luc_pct` 20
and `lifespan_years` 15. Its passives are L2 regeneration +0.5, L7 Spillover, L9 Rot Deepens +40 and L11 Surplus Life.
Its arts are the same.

**Fit:** Needs key (combat passives, Effects and art records have no field in `items_cong_phap.json` yet) ·
**Budget:** Thiên Σ value / pool_max = 15/15 + 20/20 + 15/15 + 15/15 = **4.0 of 4**, each 1.0 ≤ `bonus_single_cap`
1.5. Địa = **3.0 of 3**. Passives and abilities do not count against the budget (system-roles).

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Spring Sap (Xuân Dịch) | Scripture L1 (reused, staged by two-clocks) | Wood hit; moc, art, cheap | 0.69 | 0.02 | 2 s | — | Fits today |
| Underground Spring (Ám Tuyền) | Scripture L3 | Water hit; thuy, art, cheap | 0.69 | 0.02 | 2 s | — | Needs key (art record) |
| Banyan Shade (Dung Âm) | Scripture L5 | Heal; moc, heal, art | c_heal 4.13 | 0.05 | 4 s | own health ≤ 95 % | Needs key (art record) |
| Shedding Bark (Thoát Bì) | Scripture L8 | Cleanse; moc, cleanse, art | — | 0.03 | 3 s | own status Withering or Stagnation | Needs key (art record) |

- **Spring Sap. Effect:** a hit that grants its owner 6 Wood buff stacks for 10 s (charge 0.010 × 60 = 0.6, so c ≤ 1.73 ×
  0.4 = 0.69). **Description:** the first sap of spring, drawn up before the leaves.
- **Underground Spring. Effect:** a hit that grants its owner 6 Water buff stacks for 10 s (+0.5 % maximum linh lực and
  +0.025 pp regeneration a stack). The lint is the same as Spring Sap's. **Description:** water that never sees the
  sky, feeding the root from beneath.
- **Banyan Shade. Effect:** heals U × stage × 4.13 × 4 (heal lint 1.4 × 2.95; combat-defence.md Formulas E), refunding
  its cost when it restores any health (rule 16). The 95 % guard means it fires on any scratch and always refunds;
  what it heals past full feeds Surplus Life. **Description:** step into the shade and the heat leaves you.
- **Shedding Bark. Effect:** cleanse every curse with the `curse` cleanse tag from its owner (the shape of
  curse-engine's Ash of the Effigy, with its own guard). It answers Withering (healing taken −50 %) and Stagnation
  (regeneration ÷ (1 + D/100)). **Description:** the old bark splits and falls, and what was written on it falls too.

## Loadout by Realm

| Realm | Slots | Slot order | Ward slots | Note |
|---|---|---|---|---|
| Kết Đan | 5 | Banyan Shade, Spring Sap, Underground Spring, Clear Heart Ward, Mountain Screen | 2: Common Ward, Still Lake Aura | No Surplus Life yet (Địa layer 11). Wins on fatigue; Quiet Channels +1.0 pp |
| Nguyên Anh | 6 | + Shedding Bark | 3: + Soul-Guarding Lamp | Surplus Life opens (Scripture Địa L11 or the Mộc Đạo keystone) |
| Hóa Thần | 7 | + Thousand-Layer Cloud (art slot) | 4: Common Ward, Still Lake Aura, Soul-Guarding Lamp, Golden Bell | Thiên copy; Quiet Channels +1.5 pp; Growth Rings near its cap |

**Reservation check at Hóa Thần:** Still Lake 0.71 + Clear Heart 0.25 + Mountain Screen 0.06 + Thousand-Layer 0.044 +
Soul Lamp 0.20 = 1.264 of maximum before efficiency. With `reserve_eff_pct` 50 (its cap) and ward efficiency 60
(half weight on reservation), the reservation is 1.264 × 0.5 / 1.3 = **0.486**, inside `reserve_cap` 0.9
(combat-defence.md Formulas C). Without reservation efficiency it is over the cap: drop Still Lake Aura first.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Banyan-Bark Mantle (Dung Bì Bào) | Named artifact, body armour | `giap`, Cực phẩm, Nguyên Anh or Hóa Thần tier | `khi_huyet_pct` +20, `health_regen_pct` +1.0, `body_shield_pct` +10; carries Growth Rings | Fits today |
| Generated weapon with Thực and Hồi Xuân | Artifact, weapon | `cham` or `phien`, Thượng or Cực phẩm | L3 for the Poison; Thực: `resist_pen_pct` [chaos] +40–80; Hồi Xuân: `health_regen_pct` +0.2–0.6 | Fits today (staged affix rows on designed keys) |
| Thousand-Year Sap Pill (Thiên Niên Dịch Đan) | Pill, preparation | — | For one fight: `health_regen_pct` +1.5, `healing_pct` +20; pill toxicity as its recipe sets | Needs key (a pill's fight payload) |
| Corpse-Wax Coating (Thi Lạp) | Coating, preparation | — | L4 on ticks (content ledger) | Needs key |
| Hot Spring Array (Ôn Tuyền Trận) | Formation, preparation | — | +linh lực and health regeneration for its owner on its ground (by-root) | Needs key (a combat formation) |

**Banyan-Bark Mantle.** Stripped from the shrine banyan by a keeper who wanted to take the tree's patience with her
when the sect moved; the tree grew the bark back in a season, and the mantle still grows a ring every hundred years.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Health regeneration nodes | +0.12 pp small (1.2 W at 9.9 W a pp) | The base of the engine | Fits today (designed key) |
| 2 | Heartwood (Tâm Mộc), sealed cluster | see below | Regeneration, healing, Sap Rises at its end | Needs key (cluster idea) |
| 3 | Maximum health, reservation efficiency | +1 % / +0.8 % a small | The fatigue margin; room for the reserved wards | Fits today |
| 4 | Linh lực regeneration | to about +6 pp total bonus | Past it the log curve flattens (+6 pp counts 4.48) | Fits today |
| 5 | Poison damage, Chaos penetration | catalogue sizes | The damage half | Fits today (designed keys) |

### Hidden cluster idea: Heartwood (Tâm Mộc)

Theme: the slow growth at a tree's centre, meaning health regeneration and healing. This is wider than one build:
every healer, Wood body and NPC guardian reads it. Wood affinity. Kind: sealed, and the Thousand-Root Spring
Scripture lists it in `seal_clusters`. Size 8 acupoints:

- Smalls: `health_regen_pct` +0.12 (×3), `healing_pct` +2 (×2), `stack_duration_pct` [moc, buff] +4.
- Notables: `health_regen_inc_pct` +20, and, farthest, **Sap Rises** (+1 % healing per Wood buff stack). Quiet Channels
  sits at Porter's Shoulder's far end, so a player takes one or the other.
- No capability.

## Đạo

Mộc Đạo · Khô Vinh (Wither and Bloom). The build proposes pieces, not a whole Way:

- **Sinh Trưởng (Growth) facet:** keystone **Surplus Life** at the far end (Nguyên Anh). Notables
  `stack_duration_pct` [moc] +12 and `damage_more` +20 [poison] L2. Sap Rises as a `minor`. Stat lines
  `health_regen_pct` and `stack_effect_pct` [moc].
- **Rễ (Roots) facet:** Still Water (an existing Effect with Way as a host) as a `minor` on the way in.
- **Sinh Tử Đạo, Trường Sinh (Longevity) facet** (optional second Way): Growth Rings as a `minor`; stat lines
  `khi_huyet_pct`, `lifespan_years`.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Kết Đan | The Last Lamp: heals, wards and waits for fatigue; small hits from the two buff arts | Địa Scripture to layer 9 (Spring Sap, Underground Spring, Banyan Shade, Spillover, Rot Deepens); Clear Heart Ward | A sapling in the shrine's shade: it learns to be left alone |
| Nguyên Anh | Surplus Life opens: overheal becomes Poison; most ordinary fights end at 25–40 s | Scripture Địa L11 or the Mộc Đạo keystone; Shedding Bark; Banyan-Bark Mantle | It takes the Rooted vow: it will never step aside or run again |
| Hóa Thần | The full engine: about 10 % of health a pulse, a Poison pile in 10 s, a fatigue margin of about 6 pulses over a typical side | Thiên Scripture (healing +30, regeneration increased +40); Growth Rings near +1.2–1.5 pp | An old tree that its own sect is afraid to prune |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical same-realm duelist | wins (about 20–40 s) | Cannot dent a bar that refills about 10 % a pulse, so overheal runs near its full size |
| Top-end burst (alpha strike, e.g. first-volley) | even | If the opening volley does not kill (a bar of n_body 3 and a body shield), the burst build has nothing left and loses by Poison or fatigue. If it does, nothing else matters |
| High Chaos resistance (rule 18: 150+ points) | wins late | The Poison is cut hard; Spillover still drains a little; fatigue decides at about 66–72 s |
| Linh lực drainer (Qi Disruption) | wins | Reserved wards (Still Lake Aura) and Clear Heart Ward cannot be starved; regeneration is health, which drain does not touch |
| Healer (rule 18) | even | Two sustain sides; the bigger bar and regeneration wins fatigue |
| The Salt-Sower (below) | loses | Built to break it |

**Counter: the Salt-Sower (Tát Diêm Giả).** This is an enemy profile built from existing pieces only (Combat rule 18).

- **Withering:** healing taken −50 %, the floor. It halves both the regeneration and the overheal.
- **Stagnation stacks:** regeneration ÷ (1 + D/100), with no cap.
- **Clear Heart Ward:** cleanses 25 % of every Poison batch each pulse, so the pile holds about a quarter of its size.
- **High Chaos resistance.**
- **A steady mid-sized hitter:** it keeps the bar just under full, so overheal is 0.

Against it, Surplus Life lays almost nothing, and the fight goes to fatigue. There the Salt-Sower wins if its bar is
bigger. The banyan's answers are Shedding Bark (it cleanses the curses, on a 3 s cooldown), `healing_taken_pct` and
`status_resist_pct`. They make it even, not a win.

## Checks

Each result is PASS, FAIL or NOT ASSESSED, with the reason.

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Scripture Thiên 4.0 of 4, Địa 3.0 of 3, each line 1.0 ≤ 1.5. Arts: Spring Sap and Underground Spring lint 1.73 × (1 − 0.6) = 0.69; Banyan Shade c_heal 4.13 = 1.4 × 2.95. Slots 5/6/7 = `slots_by_realm` at Kết Đan / Nguyên Anh / Hóa Thần, ward slots 2/3/4. Artifacts 2 to 3 of `equip.max_slots` 6 (armour 5, needles 10 thần thức). Reservation 0.486 ≤ 0.9 with `reserve_eff_pct` at its cap |
| Validity | PASS | Elements `moc`, `thuy`; tiers `dia` (max_realm nguyen_anh) and `thien` (hoa_than) cover Kết Đan to Hóa Thần; bases `giap`, `cham`, `phien` exist; wards are Formulas H records; the main method names both root elements. No aux technique, so no harmony check |
| Stack | PASS | Ladder rungs 1–9 filled, or named sacrifices (L5, crit, burst). Forms: Flat, Increased, More, Per, Overflow, Rule swap, plus the close's cap change (7). No L5 modifier on the tick channel. Layer totals are stated above |
| Identity test | NOT ASSESSED | No simulator this run (user decision 2026-11-11). By the rules alone: removing Surplus Life leaves no damage channel except two 0.69 hits every 2 s, so the fight can end only by fatigue |
| Scaling | PASS | The stated power is top-end sustain with low damage. Defence: health n_body about 3 (top-end health share 20 %); regeneration about 10 % a pulse at Hóa Thần. Damage M 6.8 is below the typical anchor (8.96 at Deity Transformation) by design (seed). INFO: sustain likely sits above the top-end anchor; it is not pulled back |
| The fight | NOT ASSESSED | No simulator this run (user decision 2026-11-11). The engine and its key numbers are worked from the GDD formulas in the guide, not on a timeline |
| Reuse | PASS | Reused: Spring Sap, Quiet Channels, Thực affix (staging); Rot Deepens, Corpse-Wax Coating (content ledger); Sap Rises, The Spring Never Fails, Hot Spring Array (by-root); Still Water, Spillover, Withering, Stagnation, wards (GDDs). Each new piece names a second home; no signature-only piece |
| NPC use | PASS | Surplus Life, Growth Rings and the arts read only compile or engine values, so the generator can use them. Growth Rings gives old NPC elders the toughness the world expects. One Breakdown line each: "Surplus Life: 9.4 % overhealed → 9 Poison stacks"; "Growth Rings: 1,240 years → +1.24 pp regeneration" |
| Counterplay | PASS | The Salt-Sower (Withering, Stagnation, Clear Heart Ward, Chaos resistance, a steady hitter); top-end alpha strikes; a bigger-barred healer at fatigue |
| Originality | PASS | Names are generic objects or invented (banyan, growth rings, heartwood, salt). An earlier draft name, "Overgrowth", was dropped because it is a game title |

## Fight Results

No fight input was written and no fight was run (user decision 2026-11-11: no combat simulator this run).

**Unmodelled:** all of it. Most importantly Surplus Life (the engine), the health overflow event, Still Water feeding
it, Spillover, and fatigue against a regenerating bar.

## New Concepts

**Health overflow (a readable).** The healing lost to a full health bar, carried as an event each pulse window, just as
linh lực overflow is (effects.md rule 5, #44). The rule needed is one line in effects.md rule 5. Bounds: it can be no
larger than the side's healing. Breakdown line: "Overheal 4,210 (8.7 %)". Serves: this build (Surplus Life); Spring
Rain and the Evergreen Wall (by-root Wood healers); and any later "overheal becomes a shield" Effect. NPCs use it the
same way. Question for the user: should overheal from a refusal-free Down step ever count? This sheet says no:
refusals are not healing (combat-defence.md rule 19).

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Surplus Life (Dư Sinh) | Needs rule | effects.md rule 5: health overflow as a readable event |
| Element stacks from an Effect take no apply roll | Needs rule (clarification) | effects.md rule 6 / combat.md Formulas F: say whether "grant element stacks" rolls status chance |
| Thousand-Root Spring Scripture | Needs key | combat passives, Effects and art records on technique records |
| Underground Spring, Banyan Shade, Shedding Bark | Needs key | art records |
| Thousand-Year Sap Pill, Corpse-Wax Coating, Hot Spring Array | Needs key | a pill's, coating's and combat formation's fight payload |
| Heartwood cluster | Needs key | the tree rework |
| Growth Rings, Banyan-Bark Mantle, Hồi Xuân affix, Thực affix, Salt-Sower profile | Fits today | content rows on existing or designed keys |
