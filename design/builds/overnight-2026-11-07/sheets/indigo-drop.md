# The Indigo Drop (Nhất Tích Lam)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "One drop of perfect purity: everything sacrificed for a single element's purity. A new notable or keystone at the end of a sealed cluster."
> **Direction**: Only one thing reads purity, a row's ×1.5, and a bigger row is dull. So purity goes into an exponent. One drop colours a share of the target's sea, the share multiplies each pulse by how much purer you are, and whatever is your colour stops obeying them. The first plan kept damage arts. The numbers had no use for them, so four slots are empty.
> **Realm span**: Foundation Establishment – Core Formation tested, defined at Core Formation · **Power level**: strong · **Use**: player build, or a guild master nobody will sit beside
> **Fit**: 5 Fits today · 7 Needs key · 5 Needs rule
> **Checks**: 9 PASS · 0 FAIL · 0 NOT ASSESSED

## The Spine

- **The channel:** the enemy's own arts. At 100 % colour their hits land on them. Your `m_static` is 1.00, and their M is your multiplier.
- **The enabler:** One Drop (Nhất Tích), the keystone at the end of the sealed cluster The Clear Vat. It opens a share that spreads by itself. It closes everything The Clear Line stains.
- **The loop:** one art, fired once at 0.5 s. Then stand there.
- **The engine:** the spread reads a difference of purity inside a power. Against purity 50 it is ×2.18 a pulse: 3 % at 0.5 s, 100 % by 5 s. Against purity 95 it is ×1.12, so one fight takes five times as long.
- **The sacrifice:** no damage, no gear, no pills, four empty slots, and nothing at all to do against a root as pure as yours.
- **The arc:** purity 84 at Foundation is a slow stain. Purity 100 at Core is a verdict.

## The Legend

The vats of Indigo Ward have not been emptied in four hundred years, and Lam Chí, who owns them, will tell you so before you have sat down. Lam Chí was born at Wood 76, took three Marrow-Washing Pills at the proper ages, and has since refused a sect seat, a spirit sword, two marriages and every pill offered, on the grounds that each was dirty. They wear undyed hemp and have never once been wrong about a colour. They quote the old philosophers as a plain fact of the trade: blue comes from the indigo plant, and is bluer than the plant.

At a banquet in the capital a Nascent Soul elder slapped them for saying so at table. One drop from Lam Chí's cuff reached the elder's sleeve. Six breaths later the elder's guards carried them out, beaten by their own hand, and Lam Chí asked for the tablecloth to be changed. Every school of purity sends them a student and gets the student back. The only people who want them gone are the ones born pure, who alone can share a room with Lam Chí and stay their own colour.

## How It Fights

At 0.5 s the drop lands for almost nothing. For three seconds you stand behind a good ward while a stronger person hits you, and your bar falls to 89 %. At 4 s two-thirds of what they throw comes back on them. At 5 s all of it does, and the bar they are watching drops from 61 % to 11 % with you doing nothing (`variants/indigo-drop-mixed.fight.json`, `--timeline`).

**The signature moment:** `m_static` 1.00, one art, one firing, and a Nascent Soul enemy beats itself to death in six seconds (`mixed --gap 1`, on 57 %).

## The Stack

Sizes are first guesses. Sector rows here pay ×1.5 at purity 100 (Meridian Map rule 21), and roads pay ×1.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Identity | **One Drop (Nhất Tích)** | Your first hit leaves 1 % colour. Each pulse colour × (1 + (clean purity − their highest purity) ÷ 50 × spread). That share of their art hits resolves on them, and that share of their ward does not stop you or them | Rule swap | art | none | ○ | Cluster keystone | signature |
| Sacrifice | **The Clear Line (Thanh Tuyến)** | Clean purity is purity −4 per stain: each artifact, pill in effect, art naming another element, or second Way | Trade | any | none | ○ | Same keystone | any ascetic path |
| Base | **Clean Hands (Tịnh Thủ)** | +0.5 % starting colour per empty art slot | Per | any | none | ○ | Cluster notable | any build with empty slots |
| Rate | **Steeped (Tẩm Lâu)** | +6 % spread on spreading statuses, and six acupoints of +1 %. +18 % at ×1.5 | Increased | status | none | ○ | Cluster | any spreading status |
| Past the cap | **Bluer Than the Plant (Thanh Ư Lam)** | At 100 %, their basic attack turns too | Overflow | basic | none | ○ | Cluster notable | The Lucky Fool, any self-hit door |
| Survival | **Mordant (Môi Nhiễm)** | A cleanse leaves half of the colour | Trade | status | none | ○ | Cluster notable | any status that fears a cleanse |
| Survival | Standing Verdict | Per-hit ward, pass 0.30 and 0.20. Reused, and not the plan: see Matchups | Rule swap | any | none | ○ | Ward | From The Fortieth Breath |
| Survival | Maximum health, Ward strength, Ward efficiency, Maximum linh lực, Regeneration | Plain rows | Increased | any | none | ● | Tree | every build |

**Identity piece:** One Drop. `--without one_drop` on `indigo-drop-mixed` loses at 37 s with the enemy on 49 %. On the Wall, a stalemate with the enemy on 95 %.
**Empty rungs:** multiplier, crit, reach and fuel are sacrifices. L1 to L5 are all 0. Purity is what you bought with them.

**W:** 447, all of it. Cluster 39.2. The rest at ×1.3, a guess of 60 % sector rows at ×1.5 and 40 % roads: health 190 W, ward strength 90, ward efficiency 90, linh lực 30, regeneration 8. So purity pays about 123 W of free rows, a second reader of the same number.

### Cluster: The Clear Vat (Thanh Hang)

Wood sector, sealed by a cultivation technique: Clear Vat Canon as the main method for `cong_phap_seasons`. Eleven nodes: six acupoints of spread, Steeped, Clean Hands, Mordant, Bluer Than the Plant, and One Drop farthest from the entry. Anyone can open it. It does nothing unless you are purer than the person you meet.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Wood alone, purity 100: born at 76 or better, and all three Marrow-Washing Pills (Tẩy Tủy Đan) at low toxicity | +8 each (Formulas F). One element, so they cannot land elsewhere |
| Main method | Clear Vat Canon (Thanh Hang Kinh), main, names only Wood, no bonuses, seals The Clear Vat | Its one job is the seal |
| Ward | Standing Verdict, `ws` 117, `we` 117 | The pool pays for nothing else, so a per-hit fee is free |
| The Way | None | A second Way is a stain |

## Arts

| Art | Source | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Falling Drop (Nhất Tích) | Clear Vat Canon | qi, Wood | 1.3 | 0.04 | 0.5 s | Target holds no colour | Needs key |

**Effect:** the hit that leaves the colour. It waits while colour stands, so it fires once a fight, or again after a full cleanse. It is the one cheap art in the sheet, because a later drop costs a pulse.

## Matchups

Files are `variants/indigo-drop-[name].fight.json`.

| Enemy | Result | File |
|---|---|---|
| **Panel: 5 of 5** | Mixed and Pulse 6 s on 87 %, Evader 6 s on 85 %, Fast 6 s on 74 %, Wall 18 s on 93 % | `mixed`, `pulse`, `evader`, `fast`, `wall` |
| One cheap art | 6 s on 89 % | `cheap` |
| No arts at all | 8 s on 94 %: Bluer turns the fist | `no-arts` |
| A cleanse every 3 s | 6 s on 83 %. Without Mordant, 11 s on 67 % | `cleanser`, `cleanser-no-mordant` |
| Top-end | Loses at 1 s, enemy on 88 % | `top-end` |
| One realm up, two up | 6 s on 57 %. Loses at 3 s, enemy on 87 % | `mixed --gap 1`, `--gap 2` |
| Foundation, purity 84 | 7 s on 68 %, Wall 20 s on 84 % | `foundation`, `foundation-wall` |

**What purity does.** Here the seed's sacrifice is measured.

| Your clean purity | Their purity | Result | File |
|---|---|---|---|
| 100 | 50 | 6 s on 87 % | `mixed` |
| 88 | 50 | 6 s on 84 % | `p88` |
| 76, no pills | 50 | 7 s on 75 % | `p76` |
| 60 | 50 | 17 s on 48 % | `p60` |
| 50 | 50 | **Loses** at 38 s, enemy on 32 % | `p50` |
| 100 | 85 | 12 s on 60 % | `pure85` |
| 88 | 85 | **35 s on 6 %** | `p88-pure85` |
| 100 | 95 | 28 s on 22 % | `pure95` |
| 100 | 100 | **Loses** at 38 s, enemy on 32 % | `pure100` |

**The surprise, and it cuts against the seed.** Against ordinary roots the last 24 points buy almost nothing: 87 % against 75 %. They exist for the 4.2 % of elements born at 85 or more. Three stains with ward gear on them (`stained`, `ws` and `we` +25.5) cost nothing against Mixed, 6 s on 86 %, and take the pure fight from 12 s to 35 s on 16 % (`stained-pure85`). So purity 100 is not a damage stat. It is the right to be in the same room as the few people who matter.

**Planned ward, replaced.** Stone Ward was the plan. Standing Verdict is better on every run: Stone is 6 s on 77 %, Fast 6 s on 53 %, Wall 18 s on 88 % (`stone`, `stone-fast`, `stone-wall`). A build that spends nothing has a pool only a per-hit fee can use.

**Small rows, said plainly.** Clean Hands is 83 % against 87 % and Steeped 85 % against 87 %, at the same 6 s (`no-hands`, `no-spread`). Mordant and Bluer do the real work: Bluer's Wall is 39 s on 43 % without it (`no-bluer-wall`).

**Counter:** a root at purity 100, or anyone who ends it before 4 s. An enemy who cleanses every pulse was not run.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | 447 W, the ×1.3 a stated guess. Lint within, 1 of 5 slots, no artifact, so no thần thức |
| Validity | PASS | Fee 0.05 inside Combat's 0 to 0.10. Regeneration 3.3 %, under 8 %. Purity 100 reachable by Formulas F |
| Stack | PASS | Five forms. Layers all empty on purpose. `--without` changes every fight |
| Scaling | PASS | `m_static` 1.00 against 5.48. The anchors measure damage this build does not deal |
| The fight | PASS | Runs on `rules/one_drop.py`. `turned_hit_capped` 2 on the fixture, 4 on Mixed: Phản Thủ Luật's 25 % cap bites and changes no time |
| Reuse | PASS | Standing Verdict, Phản Thủ Luật. One signature piece |
| NPC use | PASS | Any NPC can carry it. Its purity is on its profile |
| Counterplay | PASS | Purity 100 wins (`pure100`), top-end kills first |
| Originality | PASS | The blue and indigo line is a classical saying, used as a proverb |

## Fight Results

Input: `sheets/indigo-drop.fight.json`, through `_tools/fight_x.py`, `--matrix`. A paper model, on the bankrupting fixture.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win on 86 % | 6 s | never | `turned_hit_capped` |
| typical | 1 | Win on 54 % | 6 s | never | `turned_hit_capped` |
| typical | 2 | Loss, enemy 90 % | 3 s | never | |
| top_end | 0, 1, 2 | Loss, enemy 83, 88, 91 % | 1 s | never | |

**Unmodelled:** stains are set by hand in the file, a target's purity is 50 unless the file says, and landing is an expected value.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| One Drop, The Clear Line | Needs rule | A share that spreads by a purity difference, and a stain count. Combat rule 8 and a new rule beside Phản Thủ Luật |
| Bluer Than the Plant | Needs rule | The Merged self-hit rule says basic attacks never turn. This is the one exception |
| Mordant | Needs rule | A cleanse that leaves a share |
| Spread rows, Clean Hands, cluster, Clear Vat Canon, Falling Drop | Needs key | `spread_pct`, a `start` key, and one cluster record |

## Also Considered

- **The Spotless Robe:** full power until the first hit lands, then you are dirty and stop to wash. A joke with one good second.
- **Seed Crystal:** a drop that freezes a share of the enemy's pool. One more way to read 0 on their sea, which the critic has had enough of.
