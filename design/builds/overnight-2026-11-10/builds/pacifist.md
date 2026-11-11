# The Unquarrelling Ledger (Bất Tranh Trướng)

You never strike. You write down everything the enemy spends, and let the bill wound them.

## Why it works

Every cultivator fights with one pool of linh lực that is both their arts and their ward. This build attacks the pool and the price of using it, not the health bar.

- **Cold Ledger** puts ice stacks on the foe. Each stack makes their arts cost about 4 % more linh lực (0.039 a stack). Three stacks, refreshed every 4 s, keep their pool draining faster than it fills.
- **Silent Tally** stagnates their regeneration (Stagnation) and ticks their linh lực away (Qi Disruption). Neither is damage.
- **Debt Seal** (the identity piece) makes every art they cast cost part of their own health: 5 % of the art's cost per Seal, up to 10 Seals, so at most half of every cost comes out of health.
- **Interest** gives you back 20 % of the linh lực they spend. The harder they cast, the more your ward refills.
- **Open Palm Vow** is the price: your basic attack does no damage and instead lays a Seal. No art you slot can deal damage either.

In the simulator a typical same-realm caster runs dry at about 21 s and you are never dry, finishing with about 60 % health. The fight lasts around 65 s, because it ends when fatigue (from 60 s) takes over. All numbers on new pieces are first guesses.

## What to look for

In the order you find them.

| Piece | What | Status |
|---|---|---|
| Spiritual root (linh căn) | Thủy (Water) at 80 % purity or more, with the Băng (Ice) variant | in the game (Băng requires Thủy) |
| Talents | Thần thức and Comprehension. Heart-demon resistance (Tĩnh Tâm affix) | in the game |
| Đạo | Nhân Quả Đạo, facet Nợ (Debts); Thủy Đạo, Uyên (linh lực); Bồ Đề Đạo, Nghiệp Thuẫn (wards) | Ways in the game; the nodes are not set (staged: `no-ledger-facet`) |
| Công pháp | Still Pond Ledger Sutra (Tĩnh Trì Trướng Kinh), tier 3 main, reaches Nguyên Anh | not in the game yet (staged: `tinh-tri-truong-kinh`) |
| Arts | Cold Ledger, Silent Tally, Still Tide, Closing the Book | not in the game yet (staged: `cold-ledger`, `silent-tally`, `still-tide`, `closing-the-book`) |
| Items | Patched Robe of the Quiet Pond (`giap`, `ho_than`, `tinh_tam`) | base and affixes in the game; its named effect staged (`unspent-edge`) |
| Items | Silent Pond Array; Ledger Slip Talisman | not in the game yet (staged: `still-pond-array`, `ledger-slip-talisman`) |
| Enabler | Open Palm Vow (Bất Tranh Thệ), a layer-9 ability of the sutra | not in the game yet (staged: `open-palm-vow`) |

## The enabling Effects

- **Open Palm Vow.** Your basic attack deals no damage and lays one Debt Seal; no slotted art may deal damage. The build needs it: it is the only free, never-blocked channel, and it makes the pacifism real.
- **Debt Seal (Trái Ấn).** A foe with Seals pays part of each art's cost in health. Without it nothing in the build touches their health bar.
- **Interest (Lợi Tức).** You regain 20 % of the linh lực the foe spends, up to 2 % of your maximum a pulse. It turns their casting into your fuel.
- **Backlash Count (Phản Chấn).** Every 4th art a foe casts while holding 3 or more Seals costs them 4 % of their health. It rewards pressure.
- **Unspent Edge (Nhận Chưa Rút).** Your attack bonuses count 50 % as ward and body strength. Every item with attack on it now defends.
- **Dread of the Ledger (Kinh Trướng).** At Nguyên Anh, a foe with 8 or more Seals and half health may start to flee, and fleeing counts as your win.

## Modifiers to stack

Most important first.

1. **Ice stack strength and duration.** Deeper Frost (+% `cost_up`) and Long Frost (+12 % duration). Fills the stack layer of the foe's cost. Stop when your Cold Ledger keeps 3 stacks on all the time; more duration beyond that is wasted.
2. **Curse effect (Deeper Nails).** Makes Stagnation and Seals stronger. Falling returns: Stagnation never fully stops regeneration (100 stacks halve it).
3. **Seal cap.** 10 to 15 (Extra Curse Slot style). Past 15 the foe is paying most of every cost, and the Backlash Count fires every 4th art regardless.
4. **Linh lực regeneration and art cost.** Fuel. Regeneration has a log curve with no cap, so returns fall.
5. **Ward and body layers W2–W5, B2–B5.** Empty offence layers are the price; put your points into the four defence layers up to their caps (300 / 250 / 150 / 100).
6. **Patient Ward.** +1 % ward strength per 10 s fought, cap +20 %. Stops at 200 s, which fatigue prevents anyway.
7. **Basic attack speed.** Seals land faster. Needs a rule for the basic, so it is a luxury.
8. **Healing.** Still Tide and Spring Returns. Withering on you reduces it; guard against it.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Debt Seal | Effect | The only thing that wounds the foe | Nhân Quả Đạo, Nợ notable | staged (`debt-seal`) | core |
| Open Palm Vow | Effect (enabler) | The build's channel | Sutra, layer 9 | staged | core |
| Interest | Effect | Turns their spend into your sustain | Nhân Quả Đạo, Nợ notable | staged | core |
| Cold Ledger | Art (ice stack) | Makes their arts dearer | Sutra, layer 1 | staged | core |
| Silent Tally | Art (Stagnation, Qi Disruption) | Their pool and regeneration | Sutra, layer 4 | staged | core |
| Still Tide | Art (heal) | Keeps you standing | Sutra, layer 2 | staged | core |
| Deeper Nails | Modifier | Stronger curses and Seals | Tree cluster (curse effect) | staged (`deeper-nails`) | strong |
| Deeper Frost | Modifier | More cost per ice stack | Tree small and notable nodes | staged | strong |
| Long Frost / Status duration | Modifier | Stacks hold longer | Tree (status duration) | staged | strong |
| Backlash Count | Effect | Wounds that scale with their pace | Nhân Quả Đạo, Báo Ứng | staged | strong |
| Unspent Edge | Effect | Spare attack turns into ward | Patched Robe (named) | staged | strong |
| Patched Robe | Named armour (`giap`, `ho_than`, `tinh_tam`) | Health, heart-demon guard | Dead monk's habit, loot | in the game (base and affixes) | strong |
| Dread of the Ledger | Effect | Foes flee at Nguyên Anh | Nhân Quả keystone | staged | strong |
| Seal cap shift | Modifier (cap) | 10 to 15 Seals | Dried Pond Ledger cluster | staged | nice |
| Patient Ward | Modifier | +20 % ward in long fights | Sutra bonus | staged | nice |
| Silent Pond Array | Formation | Ward more before the fight | Formation craft | staged | nice |
| Ledger Slip Talisman | Talisman | 5 Seals at t = 0 | Crafting | staged | nice |
| Late Bloom | Keystone | Art speed over a long fight | Tree keystone | catalogue only | top-end |
| Closing the Book | Art | Turns Seals into a flight | Nợ node, Nguyên Anh | staged | top-end |

## Realm by realm

- **Trúc Cơ (4 slots).** Mender. Seals grow slowly; you survive on Still Tide. Beats small casters, slowly.
- **Kết Đan (5 slots).** Seals at the cap of 10; foe pools collapse around 21 s. This is where the build comes alive.
- **Nguyên Anh (6 slots).** Cap 15, Patient Ward, Closing the Book. Foes with half health may run, and that is your win.

## How it plays

Fight start: Ledger Slip Talisman if you carry it, then Cold Ledger, Silent Tally, Still Tide, in that slot order. The Open Palm lays Seals between arts. Keep the ward reserved or drain-type and let the foe's pool run down. The signature moment: the foe's last art costs them a tenth of their health, and its Interest refills your ward.

## What beats it

- **A body cultivator (thể tu) who rarely casts.** No casts means no debts. Hold Stagnation and Patient Ward and let fatigue decide, which is a coin-toss in the simulator.
- **A cleanser.** Strips ice stacks and Seals. Reapply sooner (first firing, short cooldowns).
- **A top-end burst build.** One volley in about 2 s. You cannot win; avoid it.
- **A foe a realm above.** In the simulator you are dead in 9 s.
- **Soul attackers.** Tĩnh Tâm only guards heart demon, not soul damage.

## Not in the game yet

Open Palm Vow, Debt Seal, Interest, Backlash Count, Unspent Edge, Dread of the Ledger; arts Cold Ledger, Silent Tally, Still Tide, Closing the Book; sutra Tĩnh Trì Trướng Kinh; modifiers Long Frost, Deeper Frost, Patient Ward, Deeper Nails, Extra Curse Slot, basic attack speed; Silent Pond Array; Ledger Slip Talisman; the Nợ facet nodes; and the Dried Pond Ledger cluster.

## Changes the game would need

- **Opposed cost payment.** Combat rule 11 and Effects System: an Effect can make the foe pay part of an art's cost in health (the Blood Casting rule applied to the other side), plus Interest.
- **Flight is a win.** Combat rule on Escape (fight ends in flight with no winner): a foe's flight counts as a win for a side with the Vow.
- **Borrow attack into ward.** Combat Defence & Healing A0: `attack_pct` counts partly toward ward and body strength.
