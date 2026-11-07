# The Cut Line (Đoạn Tuyến Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The pure soul assassin: soul channel, no layers, bends `soul_lockout`, thần thức as the stat that matters, defined at Nascent Soul or Deity Transformation."
> **Direction**: The seed asked what the ratio-squared rule makes possible. The answer is that past `soul_cap` the square is wasted, so the build spends the waste on the lockout. Thần thức stops being damage and becomes speed. The mood moved from cold to glad, on purpose.
> **Realm span**: Core Formation – Deity Transformation, defined at Nascent Soul · **Power level**: top-end at its own realm, against an enemy who spent nothing on soul · **Use**: player build, or a hated school of killers
> **Fit**: 3 Fits today · 12 Needs key · 2 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: soul arts have no lint to check against)

## The Spine

- **The channel:** soul arts (Combat rule 24, Formulas E2). They skip ward, guard and evade. L1 to L5 are all 0, and M is 1.00.
- **The enabler:** none. The stack is built on E2 as written. The keystone below reaches further, but the build stands without it against typical enemies at its own realm.
- **The loop:** four of the cheapest soul arts in the game, in one volley, half a second in. Each takes 30 % of health and of linh lực. Four take everything.
- **The engine:** E2 clips the share at `soul_cap`, and rho is squared, so a specialist's raw share is 9 to 58 times the cap. Running Line turns that clipped share into a shorter `soul_lockout`, and the volley lands inside 0.32 s, before anyone else has acted.
- **The sacrifice:** no artifacts ever, so no L3, no gear ward and no second plan. It has one volley. If the volley fails, it has a thin ward, a spent pool and a fist at M 1.
- **The arc:** at Core Formation it kills its equals and nothing else. At Nascent Soul the thread reaches one realm up. It cannot pass Heavenly Tribulation on its own, and it knows that.

## The Legend

On the salt coast the spring festival is a war fought by children: paper kites on glass-dusted line, and the last kite in the sky eats sugar for a week. A kite-maker's child with a strong soul and no money for a sword watched an elder fly over the festival one year, and saw that a sword on a thought is a kite on a line, and that anyone with quick hands can cut a line from the ground. They did it for a joke, hoping to keep the sword. The elder was dead before it landed.

The school that followed kept the festival. A sour heart pulls a line taut and it snaps, so the killers of the coast are the happiest people most cultivators ever meet: they sing badly, they are terrible at funerals, and after each death they take a season off to fly kites until it stops hurting. Every sword sect pays for their heads. Nobody finds it easy to dislike one.

## How It Fights

Nothing happens for half a second. Then four small tugs arrive within a third of a second, and the enemy's health and linh lực both fall by 30 % four times. Against a same-realm enemy who holds artifacts and spent nothing on soul, that is the fight.

**The signature moment:** a top-end Nascent Soul with every layer on its hard cap, M 256, who spent nothing on soul, is dead at 0.813 s without having moved, killed by arts rated 3 % and 5 % (`sheets/cut-line.fight.json`). The kill needs that blindness: see Where the Kill Flips under Matchups.

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Thần thức (`than_thuc_pct`) | +277 %: 45 % of the realm's W at 1.3 W per 1 %, plus the technique's 22 | Increased | soul | none | ● | Tree, technique | any artifact build |
| 1 Base | Soul attack damage (`x_soul`) | +30 | Increased | soul | none | ○ | Paper Sky, Soul Đạo | any soul art |
| 2 Rate | **Running Line (Phóng Tuyến)** | The share `soul_cap` clips shortens the lockout to `soul_lockout × soul_cap ÷ raw share`, at least 0.1 s | Overflow | soul | none | ○ | Technique ability | any soul art, such as an elder culling below their realm |
| 3 Multiplier | Light Hand (Khinh Thủ) | +2 `than_thuc_pct` for each point of heart demon under 30 | Per | soul | none | ○ | Paper Sky notable | any calm or joyful build wanting thần thức |
| 3 Multiplier | Unseen Hand (Ám Thủ) | +60 `x_soul` while at full health | Conditional | soul | none | ○ | Paper Sky notable | any alpha strike, keyed to its own tag |
| 5 Reach | **Along the Thread (Duyên Tuyến)** | On your soul arts, thần thức the defender has bound to artifacts counts at half. You may equip nothing that costs thần thức. Each kill by a soul art adds +3 heart demon | Rule swap | soul | none | ○ | Paper Sky keystone | any hunter of artifact users |
| 5 Reach | Slackened Soul (Tùng Hồn) | A curse: the defender's thần thức reads 25 % lower against your soul arts for 2 pulses, stacking to 50 % | Trigger | soul | none | ○ | Art rider | any curse build carrying one soul art |
| 8 Survival | Open Sky (Không Thiên) | Each 1 % of thần thức left free adds 0.6 ward strength | Borrow | any | none | ○ | Soul Đạo passive | any build with few artifacts |

**Identity piece:** Running Line. Without it the build kills a typical at 3.5 s rather than 0.8 s, and loses to a same-realm top-end at t = 1 with the enemy on 70 % (`--without running_line`).
**The new Per:** Light Hand reads heart demon, which no build has read. Joy is the stat. It also sets the kill rate of a life: +3 per kill against a decay of 0.25 a season means one kill in 3 years holds level.
**Empty rungs:** crit (soul cannot crit, and is certain by rule). Past the cap is Running Line itself. Fuel is deliberately ordinary: arts are paid in linh lực, and each one weakens the ward. The boss fight shows that bill is real.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 to L5 | 0 | ×1.00 | Empty by design. Soul ignores layers, and this build takes that literally |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any. Metal for the story | The root does nothing here, so a poor root can still walk this |
| Key talents | Soul strength (thần hồn) 60 | Top of the Trung band. Everything multiplies it |
| The Way (Đạo) | Soul (Hồn), the catalogue Đạo: `x_soul` lines and Open Sky as a passive | Its nodes are not authored yet, so these are wants |

## Công Pháp

### Paper Kite Manual (Chỉ Diên Phổ) — main, Địa giai

A children's kite-fighting manual with a second reading in the margins.

```json
{"id": "chi_dien_pho", "name": "Chỉ Diên Phổ", "tier": 2, "tech_kind": "main",
 "names": ["kim"], "layers": 12,
 "bonuses": [{"stat": "than_thuc_pct", "value": 22}, {"stat": "stealth", "value": 10}],
 "abilities": [{"ability_id": "running_line", "unlock_layer": 9}],
 "seal_clusters": ["chi_thien_mach"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 22 ÷ 15 + 10 ÷ 10 = 2.47 of 3; the larger single value is 1.47 of 1.5. Tier 2 reaches Nascent Soul.

## Arts

Source: Paper Kite Manual. Kind soul. Cost is paid in linh lực.

| Art | Layer | soul_pct | Cost | Cooldown | Rider | Fit |
|---|---|---|---|---|---|---|
| Test Tug (Thí Tuyến) | 1 | 0.03 | 0.05 | 0.5 s | Slackened Soul | Needs key |
| Paper Cut (Chỉ Thương) | 3 | 0.03 | 0.05 | 0.5 s | none | Needs key |
| Glass Line (Lưu Ly Tuyến) | 6 | 0.05 | 0.09 | 0.5 s | none | Needs key |
| Running Cut (Tẩu Cát) | 9 | 0.05 | 0.09 | 0.5 s | none | Needs key |

At the cap a 0.03 art takes exactly what a 0.08 art takes, so the weakest art you own is the best one until you fight upward. **Description:** a tug on the line, to see who is holding it.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Core Formation | 5 | Test Tug, Paper Cut, Glass Line, Running Cut | Common drain | Keystone just reached. Equals only |
| Nascent Soul | 6 | The same | Common drain, Open Sky +60 | Two slots stay free for whatever the enemy demands |

## Items

None that cost thần thức, by the keystone. That is the most visible thing about these people: no sword, no armour, a roll of line in a sleeve.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Thần thức roads | +255 % in all | The stat | Fits today |
| 2 | Paper Sky | Below | The reach | Needs key |
| 3 | Ward strength, linh lực | The rest of W | The pool still is the ward | Fits today |

### Hidden cluster idea: Paper Sky (Chỉ Thiên Mạch)

Theme Divine Sense, Metal, outer, sealed by technique (Paper Kite Manual lists it), size 8, so it gates at Core Formation. Small acupoints: `x_soul` and thần thức. **Notables:** Light Hand and Unseen Hand. **Keystone, as the capability on the farthest notable:** Along the Thread. An idea for the tree rework, not data.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining, Foundation | A weak fighter with a strange hobby | Test Tug, Paper Cut | Learns on the beach, and is laughed at for carrying no sword |
| Core Formation | Kills equals in under a second, helpless above | Along the Thread, the last artifact sold | First kill, first heart demon, first season of kites |
| Nascent Soul | The same volley reaches one realm up | Running Cut, Light Hand at its peak | The sects start paying for the head |
| Deity Transformation | Only if something else carries them through Tribulation | | Most stop here, happily or not |

## Matchups

Variants are in `variants/`, named `cut-line-[name].fight.json`. "One up" uses the true thần thức ratio, through `rules/realm_sense.py`.

| Enemy | Result | Why | File |
|---|---|---|---|
| Typical or mixed, same realm | Wins at 0.800 s, unhurt | Hits at 0.5 to 0.8 | main, `mixed` |
| Top-end, same realm, soul-blind | Wins at 0.813 s, unhurt | The enemy's first act is at 1.0, and it spent nothing on soul | main |
| Mixed, one up | Wins at 1.871 s on 35 % health | Starts raw 0.48, then the curse lifts the share further past the cap | `mixed --gap 1` |
| Top-end, one up | Loses at t = 1, enemy on 78 % | One hit lands. Raw share 0.215 is under the cap, so the lockout holds | main |
| Bare-fisted body cultivator, no artifacts | Wins at 0.830 s | The keystone reads nothing, and at its own realm that hardly matters | `bare-fist` |
| Typical who invested in soul (thần thức 170, resistance 40) | Wins at 4.500 s on 14 % health | No overflow, so a real fight | `soul-elder` |
| Top-end with the same soul answer | Loses at t = 1, enemy on 81 % | | `soul-top-end` |
| Top-end with art speed +100 | Loses at 0.5 s, enemy on 70 % | Both act in the first instant, and M 256 wins it | `fast-opener` |
| ×8 boss | Loses at 2.0 s, boss on 51 %, 13 hits landed | E2 divides by `boss_pool_mult`. The pool empties and the ward goes with it | `boss` |
| Mirror | Wins at 12.0 s on 14 % health | Rho 1.33: a grind, not an assassination | `mirror` |

**Where the Kill Flips.** The 0.813 s kill is real arithmetic on a soul-blind enemy: E2 gives rho 6.8 to 9.1, and the hits land at 0.500, 0.613, 0.713 and 0.813. The reference top-end spends nothing on soul, and its sense of 85 is a value set in this file (`realm_sense`), derived from nothing, though it sits beside the build's own 60 × 1.45 = 87. So the headline is "kills a top-end who spent nothing on soul". Each row changes one key against the same-realm top-end. Files are `variants/cut-line-[name].fight.json`, run with no flag.

| Key changed | File value | Last value that kills | First value that loses | Result at the flip | Files |
|---|---|---|---|---|---|
| Enemy sense (`sense_base`) | 85 | 127, at 0.994 s | 128, which is +51 % | Double knockout at 1 s, lost on overkill | `hold-sense`, `flip-sense` |
| Enemy soul resistance | 0 | 50, at 0.997 s | 51 | Loses at 1 s, enemy on 10 % | `hold-soul-res`, `flip-soul-res` |
| Enemy art speed | 0 | +40, at 0.813 s | +41, which acts at 0.709 s, 4 ms before the third hit | Loses at 0.709 s, enemy on 40 % | `hold-art-speed`, `flip-art-speed` |
| Enemy thần thức bound to artifacts | 75 %, assumed | 12 %, at 0.999 s | 11 %, and 0 % with no artifacts at all | Loses at 1 s, enemy on 10 % | `hold-bound`, `flip-bound`, `flip-no-artifacts` |
| Running Line's floor | 0.1 s, invented | 0.16 s, at 0.980 s | 0.17 s | Loses at 1 s, enemy on 10 % | `hold-floor`, `flip-floor` |
| Own `than_thuc_pct` | 277 | 138, at 0.997 s | 137 | Double knockout at 1 s, lost on overkill | `hold-own-sense`, `flip-own-sense` |

At 1.3 W per 1 %, the enemy's +51 % is about 66 W, about 9 % of the realm's W. That is all that separates dying without moving from killing this build at t = 1.

**Counter:** speed or soul. Anything that acts before the third hit, or a top-end who has put a little into thần thức or resistance. A boss's pool beats it by arithmetic, and Tribulation's waves are bosses, which is why the build is defined one step before them.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | 4 of 6 slots; technique 2.47 of 3. Soul arts have no lint: `lint_arts` skips them, and Formulas C has no soul term. Costs are a guess, reading 40 × `soul_pct` as a `c_art` |
| Validity | PASS | Tier 2 reaches `nguyen_anh`; size 8 is above `cap_min_n` 7 |
| Stack | PASS | Forms: Increased, Overflow, Per, Conditional, Rule swap, Trigger, Borrow. `--without running_line` changes every same-realm fight |
| Scaling | PASS | `m_static` 1.00 against 7.37 and 256, by design. INFO: same-realm rho is 6.8 to 13.6 |
| The fight | PASS | Rules are plug-ins, not stand-ins. Cap hit: `soul_cap_clipped`, which is the engine. Along the Thread reads an assumed 75 % bound on reference enemies, because they state no artifacts; `bare-fist` shows it at 0 |
| Reuse | PASS | No ledger piece fits a soul channel, and none is forced. Every new modifier has a home outside this build. 0 signature |
| NPC use | PASS | All compile-time or fight-time, with no player input |
| Counterplay | PASS | Fast opener, soul-invested top-end and boss all run above |
| Originality | PASS | Kite fighting is a folk game, used as a structure. No names borrowed |

## Fight Results

Input: `sheets/cut-line.fight.json`, through `_tools/fight_x.py`. The calculator clamps at Deity Transformation, so gap 2 from Nascent Soul is the same enemy with extra suppression, and is left out here.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | win | 0.800 | never | `soul_cap` ×4 |
| typical | 1 | win, own 19 % | 1.871 | never | `soul_cap` ×4 |
| top_end | 0 | win | 0.813 | never | `soul_cap` ×4 |
| top_end | 1 | loss, enemy 78 % | 1.000 | 1.000 | none |

**Removal runs** (`--matrix --without [key]` on the same file):

| Removed | Typical | Top-end | Typical one up |
|---|---|---|---|
| `running_line` | 3.500 s, own 38 % | loss, enemy 70 % | loss, enemy 39 % |
| `along_the_thread` | 0.830 s | loss, enemy 10 % | loss, enemy 58 % |
| `light_hand` | 0.800 s | 0.838 s | loss, enemy 9 % |
| `unseen_hand` | 0.800 s | 0.865 s | loss, enemy 9 % |
| `open_sky` | 0.800 s | 0.813 s | loss at t = 1, enemy 70 % |

**Second realm:** Core Formation (`core`, `core-mixed`) kills typical at 0.800 s and top-end at 0.905 s, and loses one up, with the enemy on 39 % against typical and 85 % against top-end. So the reach really does arrive at Nascent Soul.

**The surprises:**
1. The square buys nothing past the cap, so the stat stack looks wasted. It is not: it is all the speed in the build.
2. Along the Thread looks like a one-realm-up piece, but it also decides the same-realm top-end. Without it the fourth hit misses the 1.0 s deadline and the enemy lives on 10 %.
3. With every bender removed (`plain-rules`) the same arts still kill a typical in 3.5 s through any ward. Combat's rule as written already puts a four-hit clock on anything at rho above about 2.45.
4. Heart demon 30 instead of 10 (`heavy-heart`) turns a win one realm up into a loss with the enemy on 9 %. The assassin's mood decides the fight.
5. Slot order hardly matters: opening with the big art (`big-first`) moves the kill by 0.06 s.

**For the user, none of them a reason to shave this:**
- `fight_calc.py` gives one `divine_sense` to every gap, but Character Stats multiplies it by `M_ts`. A soul result in any matrix is off by the square of about 3 per realm unless `rules/realm_sense.py` is used.
- By E2 and `M_ts`, one realm down is rho 3 before any stacking, so a 0.05 art is at the cap: any Nascent Soul with soul arts kills any Core cultivator of equal talent in four hits.
- Thần thức costs 1.3 W per 1 %, and the W a top-end puts in attack gives rho 7 to 14 here. Open Question 16 may want soul priced higher, or its defence cheaper.
- `soul_cap` 0.30 means four hits. At 0.34 it would be three, which is a cliff.

**Unmodelled:** heart demon gained per kill and the season of kites, both outside the fight.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Running Line | Needs rule | Combat rule 24: a side's lockout can vary. Breakdown line: "lockout 0.17 s (clipped share)" |
| Along the Thread | Needs rule | Formulas E2 reads bound thần thức, which Item Database rule 11 supplies. A heart demon gain per kill, as an exception like capability #9, since Character Stats says kills add none |
| `sense_shred` curse field | Needs key | Combat rule 8, capped at 0.5 |
| Light Hand, Unseen Hand, Open Sky | Needs key | A Per on `tam_ma`, a full-health condition on `x_soul`, free thần thức into ward strength |
| Kite Season (Diên Tiết) | Needs key | A season action: −2 heart demon, no cultivation |
| Soul art lint | Question | Should Formulas C price `soul_pct`? |

## Also Considered

- **The Smallest Soul:** invert rho, so a tiny soul kills great ones. Bold, but it is worthless at the top realm and ends realm crossing outright.
- **The Bruise:** soul hits wound thần thức for good and compound through the square. Kept in small form as Slackened Soul.
