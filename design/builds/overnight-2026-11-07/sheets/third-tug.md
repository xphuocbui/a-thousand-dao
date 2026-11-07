# The Third Tug (Đệ Tam Khiên)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 3: a hunter that kills Cut Line at its own realm, plain rows and existing wards, at most one new piece, someone proud.
> **Direction**: The seed read "be faster than the volley". The runs say be faster, but not too fast: the build must let two tugs land, because those tugs switch on its best row. No new piece.
> **Realm span**: Core Formation – Nascent Soul, defined at Nascent Soul · **Power level**: strong against soul assassins, ordinary otherwise · **Use**: player build, or the sword sect's answer to a bounty
> **Fit**: 6 Fits today · 10 Needs key · 0 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** art hits on all five layers, three body swords in one volley. Nothing spent on soul.
- **The enabler:** none.
- **The loop:** stand through two tugs, then all three cuts land together.
- **The engine:** a soul hit takes 30 % of linh lực as well as health. Two tugs put the pool at 40 %, and Spent Breath asks for 50 % or below. The assassin pays for the row that kills them.
- **The sacrifice:** the third hit. Art speed outside +43 to +66 loses, and the volley has no second plan against a wall.
- **The arc:** a pupil's manual, carried two realms past its tier, for pride.

## The Legend

Elder Phùng of Stone Gate Pass has done the morning lesson every day for four hundred years, from the pupil's manual, and mentions it often. The manual ran out at Core Formation. Every senior said to change it. Phùng refused, because that book taught them to stand straight, and has cultivated at a quarter of the speed ever since. They consider this the finest thing about themselves, and they may be right.

When the kite school killed a Stone Gate graduate over a bowl of noodles, Phùng walked to the salt coast in the yard robe. They had read how the line works and were delighted: it takes your breath first, and the Held Line has a form for exactly that, the one pupils hate, done at the end of the long run. They mend each dead killer's kite, tie it to the school gate with a note on footwork, and are home for breakfast.

## How It Fights

A tug at 0.5 s, a tug at 0.6 s. The elder has lost 60 % of everything and has not moved. At 0.667 s all three cuts land.

**The signature moment:** Cut Line has every stat it wants, and its own second tug is what kills it. **The line of play, Two Tugs:** art speed +50, the pool falls to 40 %, Spent Breath wakes, and the volley lands 33 ms before the third tug.

## The Stack

All catalogue or ledger rows at their listed sizes. Sizes are first guesses where the ledger says so.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Rate | **Sword art speed** | +50: 20 acupoints, 5 notables | Increased | art | none | ○ | Tree | From Daily Lesson |
| Multiplier | Damage (`attack_pct`) | +290 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Sword damage | +32 | Increased | art | L1 | ○ | Tree | From Daily Lesson |
| Multiplier | Full Title | +40 | More | art | L2 | ○ | Technique | From The Loud Sword |
| Multiplier | Short Edge | +20 | More | art | L2 | ○ | Tree | From Daily Lesson |
| Multiplier | Many Forms | +6 at three arts | Per | art | L2 | ○ | Tree | From Daily Lesson |
| Multiplier | Artifact attack | +117: three swords' worth, in two | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Attack pill | +20 | More | any | L4 | ● | Pill | every build |
| Multiplier | **Spent Breath** | +16 while your linh lực is 50 % or below | Conditional | art | L5 | ○ | Tree | From Daily Lesson, used unplanned |

**Identity piece:** Sword art speed. `--without art_speed_pct` on `variants/third-tug-vs-cut-line.fight.json` loses at 0.8 s with Cut Line on 100 %.
**Empty rungs:** crit, reach, fuel and survival past a common ward, all sacrifices. Thần thức is empty on purpose.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 322 | ×3.61 | Past the soft start at 200 |
| L2 | 66 | ×1.66 | Title, Short Edge, Many Forms |
| L3 | 117 | ×2.17 | Gear |
| L4 | 20 | ×1.20 | Pill |
| L5 | 16 | ×1.16 | Spent Breath, when on |

**W:** `attack_pct` 290, Sword damage 20, Sword art speed 64, ward strength 35 (over gear 25), efficiency 60, health 120, linh lực 60, regeneration 8, the L2 and L5 rows 25.6: 682.6 of 739.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal | The Canon names it |
| Key talents | None | Nothing here reads one |
| Main method | Daily Lesson Canon, Huyền giai | Past its tier the method keeps power and abilities, and only cultivation falls to ×0.25 (Cultivation Techniques rule 10). That is the price of the pride |
| Ward | Common drain, 60 / 60 | |

## Arts

Morning Thrust, Rising Cut and Falling Cut, unchanged from the Canon: body, sword, `c_art` 1.72, cost 0.06, 1 s. Three of six slots. At art speed +50 they fire every 0.667 s.

## Matchups

Files are `variants/third-tug-[name].fight.json`, run with no flag. Each enemy is the target's own fight file, translated into `enemy_overrides`, every plug-in running on the enemy's side.

| Enemy | Result | File |
|---|---|---|
| **Cut Line, Nascent Soul** | **Wins at 0.667 s on 40 %, pool 22 %** | `vs-cut-line` |
| Cut Line opens (its file, this build as the enemy) | Wins at 0.667 s on 40 % | `swap` |
| Cut Line, Core Formation, this build at Core (442.6 W) | Wins at 0.667 s on 40 % | `core-vs-cut-line` |
| Mixed, same realm | Wins at 1.334 s on 82 % | `mixed` |
| Panel Wall | Loses at 8 s, enemy on 3 % | `wall` |
| Full Price, Core profile | Loses at 0.5 s, enemy on 100 % | `vs-full-price` |
| Forum Build | Loses at 1 s, enemy on 95 % | `vs-forum-build` |

**Faster is worse.** Only art speed changes in these rows.

| Art speed | First volley | Pool then | Result | File |
|---|---|---|---|---|
| +42 | 0.704 s, after the third tug | 10 %, pays for one cut | Loses at 0.8 s, Cut Line on 66 % | `speed-42` |
| +43 | 0.699 s | 40 % | Wins | `speed-43` |
| +66 | 0.602 s | 40 % | Wins | `speed-66` |
| +67 | 0.599 s, before the second tug | 70 %, row off | Loses at 0.8 s, Cut Line on 13 % | `speed-67` |
| +100 | 0.5 s | 100 %, row off | Loses at 0.8 s, Cut Line on 13 % | `speed-100` |
| +50, no Spent Breath | 0.667 s | 40 % | Loses at 0.8 s, Cut Line on 13 % | `no-spent-breath` |

**Counter:** a wall, or anything with no need of a pool race. It has one good volley and spends 27 % of its pool a second.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts within the lint, 3 of 6 slots, 682.6 of 739 W. Thần thức not totalled |
| Validity | PASS | Canon past its tier is legal by rule 10. `ket_dan` and `nguyen_anh` real |
| Stack | PASS | Five forms. `--without art_speed_pct` changes every fight |
| Scaling | PASS | `m_static` 8.98 against 7.37 and 256; ×18.1 in the volley |
| The fight | PASS | No plug-in of its own. Cut Line's `soul_line` runs on the enemy side. The swap matches |
| Reuse | PASS | No new piece. Spent Breath used in a fight it was not written for |
| NPC use | PASS | Any Stone Gate elder |
| Counterplay | PASS | Wall, Full Price and Forum Build all beat it |
| Originality | PASS | No name borrowed |

## Fight Results

Input: `sheets/third-tug.fight.json`, through `_tools/fight_x.py`. A paper model.

| Enemy | Gap | Result | Time | Enemy left |
|---|---|---|---|---|
| typical | 0 | Win on 77 % | 1.334 s | 0 |
| typical | 1 | Loss | 2 s | 66 % |
| top_end | 0 | Loss | 1 s | 85 % |
| top_end | 1 | Loss | 1 s | 97 % |

**Unmodelled:** see the fight file. Thần thức 57 is the reference typical in Cut Line's own file.

**For the user:** Cut Line's soul hit taking linh lực is the whole reason this works. If a soul hit stopped doing that, Spent Breath would need another trigger.

## Also Considered

- **The Wide Sky:** a soul wall that holds rho under the cap and shuts off Running Line. It works, but costs a third of W to answer one enemy.
- **The Kite Rival:** a festival champion cutting lines with soul arts. A mirror, and Cut Line's sheet already has that fight.
