# The Bought Edge (Mãi Phong Kiếm), built on the Heaven-Purchasing Coin

A Metal crit-and-temper blade whose purse flips the first crit that lands on it, then flicks its last coin for four times the damage when it is half dead. Realm: Core Formation (Kết Đan, ket_dan), root Metal (Kim), purity 80, grade 4 at most.

## How it works

- Whetstone Pass adds a Temper for every Metal art fired, and each Temper gives Metal arts +1 crit chance with no cap. Sheathed Edge banks a keen strike on every crit and releases the bank with the next art.
- Blood-Quench Blade pays 6 % of health for Metal buff stacks, which moves the build toward the low-health band where the unique's art pays.
- The Heaven-Purchasing Coin (Mãi Thiên Tiền) gives attack +24 (arts), crit +5, crit damage +30, art speed +10 and its art, Last Coin Flick, a quick Physical hit that flies 4 times as hard with 40 % of health gone.
- Its Effect, Bought Fate (Mãi Mệnh): once a fight a crit taken, a failed evade or a failed escape goes your way, paid with 5 % of the spirit stones you carry. In the engine only the crit branch runs: the first crit taken heals back 40 % of that hit.
- Edge Returns the Breath (Returning-Edge ring) restores 0.8 % linh lực on each Physical crit, so the Temper pile does not run the build dry.

## Loadout

| Slot | Item | Grade | Why |
|---|---|---|---|
| Weapon (unique) | `general-heaven-purchasing-coin` Heaven-Purchasing Coin (Mãi Thiên Tiền) | 4 | The engine piece: Bought Fate, Last Coin Flick, crit and attack |
| Armour | `metal-tortoise-scale-armour` Tortoise-Scale Armour (Quy Lân Giáp) | 3 | Health, regeneration and Physical resistance (its ward and Iron Skin Renewed are not run) |
| Ring 1 | `metal-ring-of-returning-edge` Ring of the Returning Edge (Phong Hồi Giới) | 3 | Physical crit +8, crit damage +40, attack +14, Edge Returns the Breath |
| Ring 2 | `metal-iron-temper-ring` Iron Temper Ring (Thiết Thối Giới) | 1 | Physical crit +4 |
| Necklace | `metal-whetstone-jade-pendant` Whetstone Jade Pendant (Thạch Mài Ngọc Bội) | 2 | Linh lực and health; reserve art not run |
| Extra 1 (TT 8) | `general-wayfarer-ring` Wayfarer's Ring (Hành Lữ Giới) | 1 | Fortune (khí vận) +1 and health |
| Extra 2 (TT 25) | `metal-bronze-peal-bell` Bronze Peal Bell (Đồng Chung Hộ) | 2 | Physical resistance +100 and block +12 |
| Extra 3 (TT 5) | `general-hundred-patch-armour` Hundred-Patch Armour (Bách Nạp Giáp) | 3 | Health regeneration, healing taken, thần thức +3 % |
| Extra 4 | empty | - | no piece left that the engine would count |

Thần thức: 8 + 25 + 5 = 38 against a limit of 45 × (1 + 3 / 100) = 46.35.

Techniques: Nine-Temper Scripture (Cửu Luyện Kinh, main), Hundred-Blades Canon (Bách Nhận Kinh, auxiliary), Unbroken Flesh Canon (Bất Hoại Nhục Kinh, body, passives only).
Arts (5 slots): Last Coin Flick (the unique's), Whetstone Pass, Sheathed Edge, Needle Rain, Blood-Quench Blade.

## Fights

20 seeds each, typical foes. Layers [70, 20, 15, 10, 0], crit 0.15 × 1.7 plus the gear.

| Matchup | Mean s | W-L-other | You dry | Foe dry |
|---|---|---|---|---|
| typical ket_dan+0 | 17.6 | 20-0-0 | never | 14.4 s |
| typical nguyen_anh+1 | 13.3 | 0-20-0 | 8.4 s | never |
| typical hoa_than+2 | 5.2 | 0-20-0 | 4.0 s | never |
| top_end ket_dan+0 | 2.0 | 0-20-0 | 2.0 s | never |
| top_end nguyen_anh+1 | 1.6 | 0-20-0 | 1.0 s | never |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 s | never |

Health left at typical ket_dan+0: 68 %.

`--without` (typical ket_dan+0):

| Test | Mean s | W-L-other | Health left |
|---|---|---|---|
| nothing removed | 17.6 | 20-0-0 | 68 % |
| `--without item:general-heaven-purchasing-coin` | 20.2 | 20-0-0 | 64 % |
| `--without eff:Bought Fate` | 17.6 | 20-0-0 | no change at the 0.05 s test |
| `--without tech:nine-temper-scripture` | 18.4 | 20-0-0 | not printed |

`--without item:` removes only the coin's plain modifiers (Last Coin Flick stays slotted), so the 2.6 s is what the modifiers are worth, not the art.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Armour | an Effect the engine runs on a Metal armour | Iron Skin Renewed written as an Effect | craft, quest | in catalogue, not written | medium |
| Extra | `than_thuc_pct` | More slot room (46 allowed, 38 used) | Sword-Nest Flag +6 % | in catalogue, but its Chorus penalises non-sword arts | low |
| Ring | crit-triggered Effects (Opening Cut) | Another crit payoff | `blade-twin-edge-sword` | in catalogue, not written | medium |
| Any | evade or escape reliability | The two other Bought Fate branches would matter | a Wind technique, an escape art | evade stat in catalogue; escape missing | medium |
| Any | stones carried | Pays Bought Fate in play | economy | missing from the engine | low |

## Missing pieces

- A way to read "a roll was a crit/evade" before damage is applied, so that a flip can be run exactly: the combat engine (Effects System).
- An escape action and an escape roll: the combat system.
- A carried-currency readable (spirit stones) for the price in Bought Fate's `closes`: the economy system and the engine.
- A Metal armour whose ward is a drain ward, not a cast ward: the metal family.

## UNMODELLED

- Bought Fate flips a crit taken: the engine cannot change a roll already made, so the first crit taken heals back 40 % of that hit, once a fight.
- Bought Fate failed evade and failed escape: no evade stat on the build and no escape in the engine.
- Bought Fate spirit-stone price (5 % of carried stones per flip): the engine has no carried currency, so nothing is charged.
- Iron Skin Renewed and Final Clause: not written, the build does not rely on them.
- Tortoise-Scale Shell, Bronze Peal and Hundred-Patch wards: the engine takes only drain wards; the build keeps the typical ward.
- Passives with no engine stat (khí huyết, khí vận, defence, stack effect and duration, body shield, health regeneration, linh lực %): not run.
- Keen Edge Aura reserve art: reserve not deducted, grants not run.
- Kim-scoped art speed applies to every art in the engine.

## Observations

The unique does not make the build: removing the coin's modifiers lengthens the same-realm fight from 17.6 s to 20.2 s and costs 4 points of health left, all wins either way, and removing Bought Fate changes nothing at the test's resolution. The flip is the weak part in the engine, because the proxy heals 40 % of one hit and a typical foe's single crit is a small share of a Core Formation health pool; the real item may be worth more against a one-shot top-end hit, but the top-end matchups end in 1-2 s and the first volley kills before any flip matters. Fight length is 17.6 s at same realm, under the 30-60 s band, and the build is a flat win there (foe dries at 14.4 s, you never do) and loses 0-20 against every higher-realm and top-end foe. Nothing looks degenerate. Last Coin Flick fires 8.5 times a fight at same realm, so the 40 %-missing condition is met at times, but the build ends at 68 % health, so the four-times branch is used mostly late in the fight. Needle Rain fires only 2.0 times a fight and never against Hóa Thần+2 or top-end foes, and Sheathed Edge, Blood-Quench Blade and Needle Rain never fire against top-end foes because those fights end first. The failed-evade and failed-escape branches did not run at all (no model).

UNIQUE-DONE unique-heaven-purchasing-coin
