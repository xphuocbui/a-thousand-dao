# The Open Ledger (Khai Bạ), geared

A Metal (kim) hunter who stacks Slowed Time and seals on the foe with bow, spear and Nine Seal Ledger arts, now carrying a seal weapon, a crit ring that refunds linh lực, and a curse-and-mark kit. Realm: Nguyên Anh (nguyen_anh).

Fight file: `builds/meta-hunter.fight.json` (a copy of the engine-v2 file with `items`, one art swapped, two Effects added; no number tuned).

## Loadout

Thần thức (TT) limit: 45 × divine_sense 1.0 × (1 + total than_thuc_pct / 100). The items give than_thuc_pct 2 (Ledger Seal) + 6 (Mirror) + 4 (Branding Iron) = 12 %, so the limit is 50.4.

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon (base) | Ledger Seal (Lục Ấn) `soul-song-seal-ledger-seal` | 3 | Its art Ledger Stamp counts as a Nine Seal Ledger art and replaces Ambush Talisman in the art slots; adds seal attack, art speed and status duration. |
| Armour (base) | Tortoise-Scale Armour (Quy Lân Giáp) `metal-tortoise-scale-armour` | 3 | Health, defence, physical resistance, block and health regeneration. Its cast ward is weaker than the build's drain ward, so the ward stays. |
| Ring (base) | Ring of the Returning Edge (Phong Hồi Giới) `metal-ring-of-returning-edge` | 3 | Physical crit chance and damage, and the Effect Edge Returns the Breath (linh lực back on each Physical crit). |
| Ring (base) | Iron Temper Ring (Thiết Thối Giới) `metal-iron-temper-ring` | 1 | Physical crit chance and stronger Metal buffs. |
| Necklace (base) | Whetstone Jade Pendant (Thạch Mài Ngọc Bội) `metal-whetstone-jade-pendant` | 2 | Linh lực, regeneration, health and healing; its Keen Edge Aura reserve is not run. |
| Extra | Mirror of the Second Seat (Nhị Tòa Kính) `general-mirror-of-second-seat` | 4 unique | TT 18. +6 % thần thức, which pays for the other extras, and one more artifact slot. |
| Extra | Ledger Branding Iron (Phế Trướng Lạc Thiết) `force-chaos-ledger-branding-iron` | 2 | TT 15. Curse attack and speed for the Withering curse, and the Effect Marked Prey. |
| Extra | Heaven-Minted Coin (Thiên Đúc Tiền Tiêu) `metal-heaven-minted-coin` | 4 unique | TT 8. Physical attack, Metal debuff stack strength and duration, +10 % linh lực. Its art is not slotted. |
| Total extras | 3 of 5 | | **TT 41 of 50.4** |

Two extra slots are left empty: the cheapest remaining useful piece (Hundred-Edge Flying Sword, TT 20) would not fit with a useful art slot to swap it into.

## Before and after

Twenty fights each. "Old" is the engine-v2 file run on the current engine (the engine-v2 guide's own table, written earlier, read 1.8 s, 4.5 s, 2.4 s and 4.7 s; the engine has moved since).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, nguyên_anh | 2.4 | 2.3 | 20-0-0 | 20-0-0 |
| top_end, nguyên_anh | 4.5 | 4.5 | 20-0-0 | 20-0-0 |
| typical, hóa_thần+1 | 3.5 | 2.8 | 20-0-0 | 20-0-0 |
| top_end, hóa_thần+1 | 6.3 | 5.6 | 20-0-0 | 20-0-0 |

`--without` runs on the geared file (same four matchups, all 20-0-0 unless noted):

| Run | typical nguyên_anh | top_end nguyên_anh | typical hóa_thần+1 | top_end hóa_thần+1 |
|---|---|---|---|---|
| Geared | 2.3 | 4.5 | 2.8 | 5.6 |
| `--without item:soul-song-seal-ledger-seal` | 2.3 | 4.5 | 2.8 | 5.8 |
| `--without eff:Marked Prey` | 2.3 | 4.5 | 2.9 | 5.6 |
| `--without eff:Edge Returns the Breath` | 2.3 | 4.5 | 2.8 | 5.6 |

## Budget revision (2026-11-13)

**What changed.** The file's `layers` went from [200, 280, 250, 150, 80] to [70, 110, 100, 70, 0]. The old values claimed 80 % of the typical-to-top-end gap, against a 23 % budget at nguyên_anh; the new values claim 22 %. No technique, item, art or Effect was touched.

**Why.** The techniques' passives and the items' modifiers already run as Effects, so they were being counted twice. The Meridian Map should supply only a small remainder. Cut first: L5 (80 → 0), which the file's own note said was left at 0 anyway and which Marked Prey already feeds as an Effect. Then L4 (150 → 70), since the hunt needs preparation less than marks and seals. L2 and L3 (the status and seal layers the concept leans on) were kept highest.

**How the fights moved** (20 fights each, old → new; the numbers in "Before and after" above are from the earlier gear test and are replaced by these).

| Matchup | Mean s, old → new | Wins, old → new |
|---|---|---|
| typical, nguyên_anh | 2.1 → 5.3 | 20 → 20 |
| top_end, nguyên_anh | 3.6 → 9.4 | 20 → 20 |
| typical, hóa_thần+1 | 2.6 → 12.9 | 20 → 20 |
| top_end, hóa_thần+1 | 5.3 → 27.7 | 20 → 19 (1 loss) |

The build still beats a typical same-realm foe faster than the 10–20 s the budget rule expects (5.3 s), so it remains strong: its strength now comes from its techniques and items, not from the Meridian Map.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Ledger Stamp (Nine Seal Ledger art) | An engine art that counts seals and empowers itself with Exposed | Ledger Seal | In the catalogue | High |
| Ring | Edge Returns the Breath | Linh lực on each Physical crit | Ring of the Returning Edge | In the catalogue (new Effect, not yet in effects.md) | High |
| Extra | Marked Prey | More damage for each different status on the foe | Ledger Branding Iron | In the catalogue | Medium |
| Armour | Physical resistance, block, health regeneration | A sturdier body against Physical foes | Tortoise-Scale Armour | In the catalogue | Low (the fight is won in seconds) |
| Ring / extra | `stack_effect_pct` and `stack_duration_pct` [kim, debuff] | Stronger, longer Metal stacks | Heaven-Minted Coin, Iron Temper Ring | In the catalogue (not run: no engine stat) | Medium |
| Any | `status_duration_pct` [slowed time, seals] | Longer Slowed Time and seals | none | Missing (only curse-scoped and unscoped versions exist) | Medium |
| Any | A health-pay counter (Dear Blood / Called Debt) | Answers the foe's health-paid costs | none | Missing | Low |

## Missing pieces

- A bow or spear weapon (Hunter's Reach scope): the weapon base list has none; the metal family should own it.
- An item that adds Slowed Time stacks or lengthens Slowed Time: the metal or wind family.
- A cleanse or Stagnation-cap piece for the Stagnation-immune concept of the old build: the soul-song-seal family.
- A seal-scoped ring or necklace (seal attack, seal count): the soul-song-seal family.
- A Dear Blood / Called Debt answer to health-paid costs: the metal family.

## UNMODELLED

- Debt Called Per modifier (+0.4 % more per Stagnation stack on me): no engine rule; L5 stays 0.
- Ledger Seal's entries and its closing rule (no health-paid costs, no Stagnation applied by me): no engine rule for the oath.
- L4 preparation against a known quarry: run at 100 points.
- Edge Returns the Breath "closes": the engine cannot make non-Physical hits unable to crit, so the Seal art may still crit in the run.
- Marked Prey is run as L5 +4 per distinct status on the foe, cap +16, reading `foe.distinct_statuses`; whether that counts only statuses of mine is not checkable here.
- Tortoise-Scale Shell (cast ward, 105.3 Physical points): weaker than the build's drain ward, kept out; Iron Skin Renewed (body shield per Physical art): not written, the build's body shield is left as it was.
- Whetstone Jade Pendant's Keen Edge Aura (15 % linh lực reserved; Metal stacks 20 % stronger, Metal arts 10 % faster): reserve not deducted, grants not run.
- Cold Feet (Mirror of the Second Seat): an escape, which the engine does not model.
- Seal of Full Payment (Heaven-Minted Coin): spirit-stone payment, no engine action.
- `stack_effect_pct`, `stack_duration_pct`, `status_duration_pct`, `than_thuc_pct`, `khi_huyet_pct`, `defense_pct`, `health_regen_inc_pct`, `artifact_slots`, `khi_van`, `cultivation_speed_pct`, `linh_luc_pct`: no engine stat (printed by fight.py, not run).
- Scoped art-speed items (seal, kim, curse) apply to every art in the run, overstating them.

## Observations

Gear changed little. Wins stayed 20-0 in all four matchups, the nguyên_anh fights did not move (2.3 s and 4.5 s), and only the hóa_thần+1 fights shortened (3.5 → 2.8 s typical, 6.3 → 5.6 s top_end). No fight is inside the 30–60 s band: all last 2–6 s, and the old file was already that short, so gear did not cause it. Removing the Ledger Seal costs 0.2 s at top_end hóa_thần+1 and nothing elsewhere; removing Marked Prey costs 0.1 s at typical hóa_thần+1; Edge Returns the Breath changed nothing (the build never runs dry). No item made the build degenerate, because it was already winning every fight before gear. Fired nothing: at typical nguyên_anh Ledger Stamp, Frozen Hour Seal and Branding Seal never fire (the fight ends first), and Branding Seal also never fires at typical hóa_thần+1; Edge Returns the Breath has no measurable effect; the Mirror, Coin, Pendant, armour and the Iron Temper Ring contribute mostly modifiers on stats the engine does not read. Ambush Talisman was dropped from the art slots for the Ledger Stamp, so the build lost its control and Chaos hit.
