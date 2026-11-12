# The Verdict Under the Seal (Cửu Kiếp Ấn Phán)

A Thunder stack-and-delay build: Slowed Time makes the Thunder stacks stay, and the Ninth Verdict consumes six of them for one hit at six times strength. Realm: Core Formation (Kết Đan, ket_dan), root `purity` thunder (lôi) 100, grade 4 at most.

## How it works

- Stormcloud Familiar, Storm Bank and the Seal's own stack batches lay Thunder debuff stacks on the foe; Thunderclap Bind lays Slowed Time x2 and pushes the foe's timers back on crits.
- Tribulation Seal (the Scripture's art) strikes with heaven every pulse once the foe carries 8 stacks; its verdict step needs 6 stacks and a Slowed foe.
- The unique item, Seal of the Ninth Tribulation, gives Verdict Stands (Phán Quyết Bất Diệt): Thunder stacks on a Slowed foe cannot expire, so the pile only grows while Bind keeps the foe slowed.
- Its art, Ninth Verdict (Cửu Kiếp Phán), counts as a fourth Heavenly Tribulation Scripture art. Its step consumes 6 Thunder stacks on the foe for a 6.0 hit when the foe is Slowed twice, at 50 % health, or three scripture arts fire in one pulse; each of its crits lays one more stack.
- Lightning modifiers (crit, crit damage, attack, speed) from the seal and the other thunder pieces ride on every art.

## Loadout

| Slot | Item | Grade | Why |
|---|---|---|---|
| Weapon | `thunder-ninth-tribulation-seal` Seal of the Ninth Tribulation (Cửu Kiếp Lôi Ấn) | 4 | The unique: Verdict Stands, Ninth Verdict, Lightning attack +25, crit +8, crit damage +50 |
| Armour | `thunder-stormcloud-armour` Stormcloud Armour (Vân Lôi Giáp) | 3 | Lightning crit +6, crit damage +30, speed +10; cast ward not run |
| Ring 1 | `thunder-static-band` Static Band (Tĩnh Điện Giới) | 1 | Lightning crit +4, crit damage +20 |
| Ring 2 | `general-wayfarer-ring` Wayfarer Ring | 1 | Filler; the only other cheap ring in the catalogue |
| Necklace | `thunder-peal-heart-pendant` Peal-Heart Pendant (Lôi Tâm Bội) | 3 | Lightning crit +10, crit damage +40, thần thức +4 % |
| Extra 1 (TT 20) | `thunder-stormcaller-drum` Stormcaller's Drum (Hô Lôi Cổ) | 2 | Lightning crit +10, speed +10, crit damage +30 |
| Extra 2 (TT 20) | `thunder-forked-light-sword` Forked-Light Sword (Phân Quang Lôi Kiếm) | 2 | Lightning attack +14, crit +8, speed +8, crit damage +25; its art is not slotted |
| Extra 3 | empty | - | no further piece fits the limit |

Thần thức: 20 + 20 = 40 against a limit of 45 × (1 + 4/100) = 46.8.

Techniques: main `heavenly-tribulation-scripture` (Thiên Kiếp Kinh); auxiliary `thousand-bolt-scripture` (Thiên Lôi Kinh, Lightning crit passives) and `unbroken-flesh-canon` (Bất Hoại Nhục Kinh, a body technique, passives only).
Arts (5 slots): `thunder-ninth-verdict`, `tribulation-seal`, `thunderclap-bind`, `stormcloud-familiar`, `storm-bank`.

## Fights

20 fights each, `--matrix` (the engine's own realm offsets: ket_dan+0, nguyen_anh+1, hoa_than+2).

| Matchup | Mean s | W-L-other | You dry | Foe dry |
|---|---|---|---|---|
| typical ket_dan+0 | 13.4 | 20-0-0 | never | 10.9 s |
| typical nguyen_anh+1 | 10.4 | 0-20-0 | 8.0 s | never |
| typical hoa_than+2 | 4.0 | 0-20-0 | 3.8 s | never |
| top_end ket_dan+0 | 2.0 | 0-20-0 | 1.6 s | never |
| top_end nguyen_anh+1 | 1.0 | 0-20-0 | 1.0 s | never |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 s | never |

Health left at typical ket_dan+0: 90 %.

`--without` (typical ket_dan+0; every other matchup unchanged):

| Test | Mean s | W-L-other | Health left |
|---|---|---|---|
| nothing removed | 13.4 | 20-0-0 | 90 % |
| `--without item:thunder-ninth-tribulation-seal` | 14.5 | 20-0-0 | 89 % |
| `--without eff:Verdict Stands` | 13.9 | 20-0-0 | 89 % |
| `--without tech:heavenly-tribulation-scripture` | 13.4 | 20-0-0 | 90 % |

`--without item:` removes only the item's plain modifiers; the art Ninth Verdict stays in its slot, so 1.1 s is what the seal's modifiers are worth, not its art. The art was not tested separately.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Ring 2 | Lightning crit / crit damage ring at grade 3 | Replaces the Wayfarer filler | craft, event | missing (only `thunder-static-band`, grade 1) | high |
| Extra | stack duration or stack effect piece for Thunder | Feeds the Scripture's +40 % / +50 % passives (no engine stat yet) | craft | missing | medium |
| Armour | a ward the engine can run | Cloudflash Shell is a cast shield, not run | craft, quest | in catalogue, not run | medium |
| Necklace | Marked Prey written as an Effect | The pendant's Effect | event, NPC | in catalogue, Effect not written | low |
| Extra | `thunder-tribulation-rod` Lightning Drinker | Linh lực back from Lightning hits; only useful against Lightning foes | quest | in catalogue, not used (no Lightning foe in the matrix) | low |
| Any | a Slowed Time source that is not an art slot | Keeps the Seal's key lit with fewer slots | tree, item | missing | medium |

## Missing pieces

- A real "stack batch never expires" engine action, so Verdict Stands can be written as the rule says: the engine and effects system.
- A Thunder item or technique passive that the engine can read for stack duration and stack effect (`stack_duration_pct`, `stack_effect_pct` have no engine stat): the engine.
- A grade 3 Lightning ring: the thunder family.
- A second source of Slowed Time outside the four Scripture arts: the wind family or the ice family.

## UNMODELLED

- Verdict Stands: written as one extra permanent Thunder stack per pulse in which a Thunder batch lands on a Slowed foe; the engine cannot stretch a batch already laid, so this undercounts the real rule.
- Verdict Stands closes (non-Slowed foe: stacks last 25 % shorter): no engine hook shortens a batch.
- Marked Prey (pendant), Steady Breath (drum): not written, the build does not rely on them.
- Cloudflash Shell ward, reserve arts (Peal-Heart Aura, Stormcaller's Cadence): not run; typical Common Ward kept.
- Item and technique modifiers with no engine stat (khi_huyet_pct, defense_pct, linh_luc_pct, linh_luc_on_crit_pct, leech_linh_luc_pct, linh_luc_regen_inc_pct, stack_effect_pct, stack_duration_pct, status_duration_pct, body_shield_pct, health_regen_inc_pct): not run.
- Lightning art speed applies to every art in the engine, since art speed is read without hit context.

## Observations

At the same realm the build wins 20-0 in 13.4 s with 90 % health left and never runs dry, so it is well under the 30-60 s band; it loses everything against a higher realm, where it runs dry first (8.0 s at nguyen_anh+1). The seal's modifiers are worth 1.1 s and the Verdict Stands stand-in 0.5 s, so on this matrix the unique does not make the build: the Scripture's four arts and the lightning gear carry it, and the verdict fires only 1.8 times a fight at typical ket_dan+0 and 0.5 times at nguyen_anh+1. Removing the main technique changed nothing at all (13.4 s both ways); its passives that matter here (Thunder stack effect and duration) have no engine stat, so that test says only that its crit and damage passives are not what moves the fight. The Verdict Stands stand-in was clipped by its once-a-pulse limit about 3.1 times a fight, so the real rule would hold many more stacks than are modelled. Nothing looks degenerate. Never fired: every art at hoa_than+2 and top end (the foe ends the fight in a volley or two), and Stormcloud Familiar at nguyen_anh+1; trig_budget clipped 0.1 per fight.

UNIQUE-DONE unique-ninth-tribulation-seal
