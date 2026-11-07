# The Welcome Bath (Tẩy Trần Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "A cleanse that is an attack (seed 49), or forcing the enemy to act by flipping their guards (seed 56), whichever gives the stronger build. Mischief or ambition."
> **Direction**: The cleanse. Flipping guards does little, since most enemies have none. A cleanse aimed at someone else can take what everyone has: layers. Each firing washes off the target's largest layer, and the washer keeps what fits. The forced push added Down to the Skin, because the first version had no answer once the guest was bare.
> **Realm span**: Qi Refining – Foundation Establishment tested, defined at Qi Refining · **Power level**: a legend against the rich, ordinary against the poor · **Use**: player build, and the most frightening NPC a top-end player can meet
> **Fit**: 6 Fits today · 5 Needs key · 4 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: thần thức not totalled. Scaling: the anchors do not describe a stolen M)

## The Spine

- **The channel:** art hits and the fist, on a multiplier that starts at 1.16 and is carried in by the guest.
- **The enabler:** Wash the Dust (Tẩy Trần), on the Attendant's Manual. It opens washing. It closes your own L2 to L5: Towel Only.
- **The loop:** scrub every half second, largest garment first. Hit them with their own clothes on.
- **The engine:** M is a product, so the top-end anchors are almost all in L2 to L5. Four washes take a Qi Refining top-end from M 103 to 1.48 and hand over 60 % of it. **The better dressed they are, the faster it ends.**
- **The sacrifice:** nothing of your own past L1, and no way through someone who brought nothing to steal and hits slowly.
- **The arc:** an attendant stays low on purpose. They beat the top-end one realm up, and lose to the ordinary person there.

## The Legend

Everyone who crosses at Nine Landings stops at the steam house, because Auntie Sáu stands in the road and will not hear otherwise. *You have had a long road. Let me wash the dust off you.* It is the oldest courtesy on the river, and they say it to carters, widows and sect elders alike, rolling up their sleeves, delighted. They have stayed at Qi Refining for sixty years by choice, and consider it a good height for reaching people's backs.

The first elder came out of the steam in twenty heartbeats with no pill-glow, no sword-sense and no idea what had happened, and Auntie Sáu was wearing the elder's confidence and singing. The elder did not complain, because a complaint would have to say how. Three sect masters have now been welcomed. Nobody well dressed takes the ferry road any more, and nobody will say why. The porters, who own one shirt each, think Auntie Sáu is the finest person alive.

## How It Fights

Wash the Dust fires at 0.5 s and takes two layers with Both Hands, then one every half second until the guest is bare. After that each firing takes 40 ward strength and efficiency, and she keeps 60 % of everything. Hot Towel and Bathwater do the hitting, with the guest's own layers on them.

**The signature moment:** the same sheet beats a Qi Refining top-end in 2 s on 83 %, and takes 4 s to beat an ordinary cultivator (`variants/welcome-bath-top-end.fight.json`, `-mixed`). Removing Washing, the ordinary one wins at 6 s.

## Enabler

**Wash the Dust.** A cleanse aimed at the target (Combat rule 8 aims it at the caster). A worn-out manual from any bath house. **Closes:** Towel Only. Your own L2 to L5 count for nothing while the Manual is your main method. You come to work in a towel.

## The Stack

Sizes are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Identity | **Washing (Tẩy)** | An art with the wash tag zeroes the target's largest of L2 to L5, for the fight. L1 never washes. You add 50 % of it to the same layer | Rule swap | art | L2–L5 | ○ | Enabler | any thief |
| Sacrifice | **Towel Only (Đơn Cân)** | Your own L2 to L5 count for nothing | Trade | any | L2–L5 | ○ | Enabler | any build that lives on borrowed layers |
| Rate | **Both Hands (Song Thủ)** | The first firing of a fight takes two layers | Timing | art | none | ○ | Notable | any wash, any first firing |
| Base | **Good Fit (Vừa Người)** | +10 % kept, to 60 % | Increased | art | none | ○ | Notable | any thief |
| Past the cap | **Down to the Skin (Thoát Y)** | With no layer left, a wash takes 40 ward strength and efficiency, and you keep your share | Overflow | art | none | ○ | Notable | any ward breaker |
| Survival | Vinegar Cloth | Per-hit ward, pass 0.34 and 0.24. Reused, and not the plan: see Matchups | Rule swap | any | none | ○ | Ward | From The Held Door |
| Reach | Accuracy | +3 %: 1 notable | Increased | any | none | ● | Tree | any build that meets evaders |
| Multiplier | Damage (`attack_pct`) | L1 16 | Increased | any | L1 | ● | Tree | every build |
| Survival | Maximum health, Maximum linh lực, Ward strength, Ward efficiency | 40, 8, 5 and 5 W | Increased | any | none | ● | Tree | every build |

**Identity piece:** Washing. `--without washing` loses to Mixed at 6 s with the enemy on 27 %, and to the Wall at 9 s, enemy on 87 %.
**Empty rungs:** crit, and L2 to L5 until someone arrives. Sacrifices.

**W:** 106, all of it: L1 16, health 40, linh lực 8, ward 10, accuracy 8, three notables 24. `ws` and `we` 30 each is 5 of tree and 25 of one ward robe.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water, any purity | Nothing reads it |
| Main method | Attendant's Manual (Dục Sự Pháp), main, tier 1, names Water, no bonuses, gives all three arts | The method is the job |
| Ward | Vinegar Cloth, `ws` 30, `we` 30 | She spends 15 % a second on arts, so a drain ward has nothing left |

## Arts

| Art | Source | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Wash the Dust (Tẩy Trần) | Manual | body, cleanse, wash | 1.3 | 0.04 | 0.5 s | | Needs rule |
| Hot Towel (Nhiệt Cân) | Manual | qi | 2.2 | 0.08 | 2 s | | Needs key |
| Bathwater (Dục Thủy) | Manual | body | 3.1 | 0.12 | 4 s | | Needs key |

**Wash the Dust** also takes the worst status off her, as any cleanse does. It is a 0.5 s art for a reason the kit does not have: its value is its firing, not its hit. Three of 3 slots, and the other two are slow.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | A top-end's nightmare | The whole sheet | The elder who could not complain |
| Foundation | The same, one more art | A fourth art (`foundation`) | Beats Mixed at 4 s on 87 %, a top-end at 2 s on 82 %. Loses to the Wall at 34 s, enemy on 20 % |

## Matchups

Files are `variants/welcome-bath-[name].fight.json`.

| Enemy | Result | File |
|---|---|---|
| **Panel: 4 of 5, and one stalemate** | Mixed and Pulse 4 s on 84 %, Fast 4 s on 73 %, Evader 9 s on 41 %. **Wall: stalemate at 40 s, her on 34 %, it on 22 %** | `mixed`, `pulse`, `fast`, `evader`, `wall` |
| **Top-end, Mixed kit** | **Wins 2 s on 83 %** | `top-end` |
| Top-end, fixture | Wins 2 s on 79 % | `top-end-fixture` |
| **Top-end opens the fight** | **Wins 2 s on 55 %** | `top-end-opens` |
| Top-end one realm up | Wins 4 s on 4 % | `top-end --gap 1` |
| Top-end two up | Loses at 1 s, enemy on 99 % | `top-end --gap 2` |
| **Ordinary, one realm up** | **Loses at 7 s, enemy on 50 %** | `mixed --gap 1` |
| One cheap art | 4 s on 87 % | `cheap` |
| A soul art every second | 4 s on 50 % | `soul` |
| All its M in L1 | 7 s on 6 %. L1 300, more than a Qi Refining tree holds | `beggar` |

**The ladder is upside down.** One realm up she beats the top-end and loses to the ordinary person, on the same sheet.

**The surprise: who opens.** Combat rule 10 lands the requesting side's hits first. My first version won only because the file's side A goes first: when the top-end opened, she died at 1 s with it on 91 % (`one-hand-top-end-opens`). One wash at 0.5 s leaves it with M 26, and its first volley kills. That is why Both Hands exists. It changes almost nothing else: Mixed is 4 s on 83 % without it (`one-hand`).

**Three rows, proved.** Down to the Skin: without it she loses to the Wall at 16 s, enemy on 79 % (`no-skin-wall`). Good Fit: at 50 % the Wall stalemate becomes a loss at 32 s, enemy on 35 % (`keep50-wall`), though Mixed is unchanged (`keep50`). Vinegar Cloth was not the plan: on Stone Ward, Mixed is 4 s on 75 % and Evader 8 s on 9 % (`stone`, `stone-evader`).

**Counter:** an ordinary cultivator one realm up. At her own realm nothing run kills her: the Wall only holds her to a stalemate.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | 106 W, arts inside the lint, 3 of 3 slots. Thần thức for the ward robe not totalled |
| Validity | PASS | Fee 0.04 inside 0 to 0.10. Tier 1 reaches Qi Refining |
| Stack | PASS | Five forms: Rule swap, Trade, Timing, Increased, Overflow. `--without` changes every fight |
| Scaling | NOT ASSESSED | `m_static` 1.16 against 3.27 and 103, but the real M is the guest's. **INFO:** it beats top-end, far above any claim |
| The fight | PASS | Runs on `rules/washing.py` and `rules/cleanse_art.py`. Every wash shows in `cap_hit` |
| Reuse | PASS | Vinegar Cloth, Accuracy, plain rows. No signature pieces |
| NPC use | PASS | Trivial for the generator, which is the worry below |
| Counterplay | PASS | `mixed --gap 1` |
| Originality | PASS | Washing a guest's dust is an ordinary courtesy, and the phrase is common speech |

## Fight Results

Input: `sheets/welcome-bath.fight.json`, through `_tools/fight_x.py`, `--matrix`. A paper model.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win on 85 % | 4 s | never | |
| typical | 1 | Loss, enemy 37 % | 8 s | 6 s | |
| typical | 2 | Loss, enemy 95 % | 3 s | never | |
| top_end | 0 | Win on 79 % | 2 s | never | |
| top_end | 1 | Win on 1 % | 4 s | never | |
| top_end | 2 | Loss, enemy 99 % | 1 s | never | |

**Unmodelled:** a wash on evade is an expected share, conditional points do not wash, and the panel has none. What the washed do next is outside the fight.

**For the user.** Rule 2 says every modifier also serves NPCs. A generated attendant strips a player's build the same way, and a player's whole stack is L2 to L5. If that is too cruel, the bound is one line: `status_resist_pct` cuts the share, or a realm gap does. No bound is in the file.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Washing, Towel Only | Needs rule | Combat rule 8: a cleanse aimed at the target, and layers that can move during a fight |
| Both Hands, Down to the Skin | Needs rule | Ward strength changing during a fight |
| Good Fit, Manual, Hot Towel, Bathwater | Needs key | A `wash_keep_pct` key, a `wash` tag, one technique, two arts |

## Also Considered

- **The Contrary:** flips the enemy's guards. Two of the five panel enemies have a guard at all, and one has one guard.
- **Spring Cleaning:** a cleanse that fires your own statuses at the target. The Stand-In already owns that door.
