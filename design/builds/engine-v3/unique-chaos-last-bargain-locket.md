# The Shadow Bargain (Ám Ảnh Tuyệt Khế)

Pay in blood first, collect at the end: a Wood and Metal health-payer that leeches back what it spends and keeps one free Chaos art for the moment it goes Down. Realm: Core Formation (Kết Đan, ket_dan). Root: Wood (Mộc) 60, Metal (Kim) 40.

## How it works

- Every art here either pays health (Bloodletting Rite 4 %, Bloodroot Pact 6 %) or lays Poison and Stagnation that Chaos ticks feed on; Harvest Bloom turns 12 Poison into Chaos blooms and heals.
- Leech and healing carry the cost: the locket's 30 % health leech and 10 % healing, Ring of the Open Vein's 25 % leech, and Blood Drinker (6 % of each hit back) all pile on one pool.
- The locket's Final Clause (Tuyệt Khế): once a fight, as you go Down, your longest-cooldown art fires at no cost. Here that is Bloodletting Rite (9 s), which hits harder the more health you are missing, so the clause is meant to land at its strongest.
- The locket also gives crit damage +40 and maximum health +18 %, the "pay for the fight before it" part.
- In the engine the build never reaches the Down step at the same realm, so the clause is written and run but sits unused (see Observations).

## Loadout

Techniques: Verdant Cycle Scripture (Thanh Hoàn Kinh, main, Wood), Tearing Force Rites (Xé Chấn Nghi, auxiliary, Metal), Rotting Canopy Canon (Hủ Quan Điển, auxiliary, Wood).
Arts (5 slots at ket_dan): Bloodletting Rite, Thorn Rain, Bloodroot Pact, Blight Canker, Harvest Bloom. The locket has no art of its own.

| Slot | Item | Grade | Why |
|---|---|---|---|
| Unique / necklace | `force-chaos-last-bargain-locket` Locket of the Last Bargain (Tuyệt Khế Bội) | 4 (unique) | Final Clause, crit damage +40, health +18 %, leech +30 %, healing +10 %; it is the build's necklace |
| Weapon | `force-chaos-ledger-seal` Balance-Sheet Seal (Kết Toán Ấn) | 3 | Chaos damage +16 %, curse art speed, health; its art Settle the Account is not slotted |
| Armour | `force-chaos-hollow-robe` Hollow Robe (Không Y) | 3 | Chaos resistance, health +10 %, thần thức +6 % (raises the extra limit) |
| Ring 1 | `force-chaos-open-vein-ring` Ring of the Open Vein (Khai Mạch Giới) | 3 | Blood Drinker, leech +25 %, health, healing |
| Ring 2 | `force-chaos-hollow-ring` Hollow Ring (Không Giới) | 2 | Chaos damage +8 % |
| Extra 1 (TT 25) | `force-chaos-hollow-bell` Hollow Bell (Không Chung) | 3 | Health +14 %, thần thức +8 %, status resistance; its ward is not run |
| Extra 2 (TT 10) | `force-chaos-ledger-murmur-pendant` Ledger-Murmur Pendant (Phế Thanh Bội) | 3 | Chaos damage +12 %, healing +8 % |
| Extra 3 (TT 15) | `force-chaos-ledger-branding-iron` Ledger Branding Iron (Phế Trướng Lạc Thiết) | 3 | Curse damage +14 %, thần thức +4 %; Marked Prey is not run |
| Extra 4 | empty | - | the next piece would pass the limit |

Thần thức: 25 + 10 + 15 = 50 against a limit of 45 × (1 + 18 / 100) = 53.1 (robe 6 + bell 8 + iron 4 = 18 %). All grades are 4 or less.

## Fights

20 fights each, `--matrix`, no tuning.

| Matchup | Mean s | W-L-other | You dry | Foe dry |
|---|---|---|---|---|
| typical ket_dan+0 | 19.9 | 20-0-0 | never | 15.5 |
| typical nguyen_anh+1 | 10.4 | 0-20-0 | 7.8 | never |
| typical hoa_than+2 | 4.0 | 0-20-0 | 3.8 | never |
| top_end ket_dan+0 | 2.0 | 0-20-0 | 1.6 | never |
| top_end nguyen_anh+1 | 1.0 | 0-20-0 | 1.0 | never |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never |

`--without` (typical ket_dan+0, then typical nguyen_anh+1):

| Test | Mean s same realm | W-L-other | Mean s nguyen_anh+1 | W-L-other |
|---|---|---|---|---|
| nothing removed | 19.9 | 20-0-0 | 10.4 | 0-20-0 |
| `--without item:force-chaos-last-bargain-locket` (plain modifiers only) | 20.3 | 20-0-0 | 10.2 | 0-20-0 |
| `--without eff:Final Clause` | 19.9 | 20-0-0 | 10.4 | 0-20-0 |
| `--without tech:verdant-cycle-scripture` | 20.4 | 20-0-0 | 10.5 | 0-20-0 |

The locket's modifiers are worth 0.4 s at the same realm and nothing measurable above it; the clause is worth 0.0 s everywhere; the main technique's modelled passives are worth 0.5 s.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Armour or ring | a way to go Down with more health pools | Lets Final Clause matter at all | crafting, quest | missing | high |
| Weapon | grade 4 Chaos weapon with health payment | A harder payer so the build reaches low health | sect, crafting | missing (Balance-Sheet Seal is grade 3) | medium |
| Extra | Marked Prey written as an Effect | More damage per status on the foe | `force-chaos-ledger-branding-iron` | in catalogue, Effect not written | medium |
| Extra | ward the engine can run | Muffled Bell as a drain ward | `force-chaos-hollow-bell` | in catalogue, ward not run | low |
| Any | `than_thuc_pct` | A fourth extra slot (limit 53.1, 50 used) | robe, bell, iron | in catalogue | low |
| Technique | a Wood main with Chaos arts at layer 9 | Real Chaos blooms and leech arts | tree | missing | medium |

## Missing pieces

- A way to be low on health without dying, so a Down-triggered clause has something to cash: Wood (health-pay arts) or the Chaos family.
- A Darkness (Ám) element or tag: the locket's damage [am] has nothing to match, and the library has no Darkness arts; a Darkness family should own it.
- A Chaos main method: Tearing Force Rites and Rotting Canopy Canon are secrets, so the build's main is Wood Verdant Cycle, not a Chaos one; the technique catalogue.
- A grade 4 weapon of the family with health pay: Chaos family.
- A way for the clause to name which art fires (it reads "longest-cooldown"): effects.md.

## UNMODELLED

- Final Clause: run as `on: down`, once a fight, `fire_art` of Bloodletting Rite (the longest-cooldown art, 9 s) at full share; whether the engine fires a `down` event without `refuse_down` was not proved because no fight reached it.
- Blood Drinker (Ring of the Open Vein): run as a heal of 6 % of each hit's amount; the engine's "removes enemy health" condition is not checked.
- Locket attack +26 % [am]: loaded with tag "am", which no art carries, so it most likely adds nothing.
- khi_huyet_pct (locket, seal, robe, ring, bell): no engine stat, so the health the build is meant to carry is not there.
- stack_effect_pct, stack_duration_pct, status_duration_pct, health_regen_inc_pct, resist_pen_pct, art_cost_health_pct and than_thuc_pct passives: no engine stat.
- Art speed with a `moc` or `curse` scope applies to every art in the engine.
- Hollow Veil and Muffled Bell wards: not run; the build keeps the typical Common Ward (payload 411, drain 0.394).
- Murmuring Debts reserve art: reserve not deducted, grants not run.
- Marked Prey (Branding Iron): not written; the build does not rely on it.
- Settle the Account (Balance-Sheet Seal's art): not slotted, art slots full.
- Darkness damage the item's build_use names: no Darkness element in the engine.

## Observations

The unique does not make this build: without the locket's modifiers the same-realm fight is 0.4 s slower (20.3 against 19.9) and above it the result is the same 0-20, and removing Final Clause changes nothing because the build never goes Down in the one fight it wins, with 100 % health left and "you dry" never; in the fights it loses it dies in 1 to 10 s and the clause is a free art at the very end of a fight that is already decided, so the loss is unchanged. Same-realm length is 19.9 s, below the 30-60 s band, and it was never close to the band above: 10.4 s at nguyen_anh+1, 4.0 at hoa_than+2, 1 to 2 s against top end. Nothing looks degenerate, but the leech and healing never get used at same realm (no health lost to heal) and, in the realm-up fights, the arts fire so rarely that the sustain does not matter: against hoa_than+2 and top end every art shows NEVER_FIRED because the build is dead before its first cast. Bloodletting Rite fires 1.9 times a fight at same realm, so the clause's chosen art does fire from the hand; the other four fire about 4 times each. Clipped: canker-spread (92.8 a fight), canker-wither (79) and root-drink (108.8) mean most Poison and Stagnation stacks are lost to caps, and the trigger budget clipped 2.5 times, so some free hits were lost. Many of the item modifiers that make this a sustain build (health +18 % and more, health regeneration, status resistance) have no engine stat, so the build is measured without its main pool, and that should be read before trusting the 0.0 s.

UNIQUE-DONE unique-chaos-last-bargain-locket
