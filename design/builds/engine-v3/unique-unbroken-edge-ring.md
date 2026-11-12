# The Unbroken Edge (Bất Đoạn Nhận), unique ring

A Metal sword build that keeps every Afterimage and Coil it earns, so the slow suite arts can bank toward their big steps. Realm: Core Formation (Kết Đan, ket_dan), grade 4 at most. Root: pure Metal (Kim), purity 70.

## How it works

- Phantom Sword, Flying Sword, Triple Draw and Rain-Calling's Sword Rain all feed or spend an Afterimage count; Coiling Thrust does the same with Coils. Phantom Sword's big step wants 7 Afterimages, Sword Rain wants 5, Coiling Thrust's last step wants 6 Coils.
- Normally both counters decay 0.1 a pulse. The ring's Lingering Afterimage (Dư Ảnh Bất Tán) removes that decay; the price is a basic attack that deals 30 % less.
- The ring also carries sword crit +8, sword attack +18, crit damage +50 and art speed +14, so most of what it does in the run is plain modifiers.
- Crits feed the Afterimage count (Phantom Sword) and Edge Returns the Breath refunds linh lực on Physical crits.
- The weapon (Rain-Calling Sword) gives a fifth suite art that Phantom Sword, Flying Sword and Triple Draw count as a canon art.

## Loadout

| Slot | Item | Grade | Why |
|---|---|---|---|
| Ring 1 (unique) | `blade-unbroken-edge-ring` Ring of Unbroken Edges (Bất Đoạn Nhận Giới) | 4 | Lingering Afterimage; sword crit, attack, crit damage and speed |
| Weapon | `blade-rain-calling-sword` Rain-Calling Flying Sword (Hoán Vũ Phi Kiếm) | 3 | Its art Sword Rain Descends is a canon art with its own Afterimage payoff; sword attack, speed, crit |
| Armour | `blade-tortoise-edge-armour` Tortoise-Edge Armour (Quy Nhận Giáp) | 3 | Physical resistance 150 and block 18 (the cast ward is not run) |
| Ring 2 | `metal-ring-of-returning-edge` Ring of the Returning Edge (Phong Hồi Giới) | 3 | Physical crit +8, crit damage +40, attack +14; Edge Returns the Breath |
| Necklace | `metal-whetstone-jade-pendant` Whetstone Jade Pendant (Thạch Mài Ngọc Bội) | 2 | Linh lực, regeneration, healing |
| Extra 1 (TT 20) | `blade-twin-edge-sword` Twin-Edge Flying Sword (Song Nhận Phi Kiếm) | 2 | Sword crit +6, attack +14, speed +10, crit damage +15 |
| Extra 2 (TT 8) | `blade-whetted-ring` Whetted Edge Ring (Ma Phong Giới) | 1 | Sword crit +4, attack +6 |
| Extra 3 (TT 8) | `metal-iron-temper-ring` Iron Temper Ring (Thiết Thối Giới) | 1 | Physical crit +4 |
| Extra 4 | empty | - | nothing fit that helped (see observations) |

Thần thức: 20 + 8 + 8 = 36 against a limit of 45 × (1 + 0/100) = 45 (no item here gives than_thuc_pct; the Sword-Nest Flag would, but see the UNMODELLED line on its penalty). The unique is counted as one of the two rings.

Techniques: main Hunter's Reach Canon (Liệp Trình Kinh); auxiliaries Afterimage Sword Canon (Tàn Ảnh Kiếm Kinh) and Hundred-Blades Canon (Bách Nhận Kinh, passives only).
Arts (5 slots): Phantom Sword (Huyễn Ảnh Kiếm), Flying Sword (Phi Kiếm), Triple Draw (Tam Bạt Đao), Sword Rain Descends (Kiếm Vũ Giáng, from the weapon), Coiling Thrust (Triền Thương Đột).

## Fights

20 fights each, `--matrix`.

| Matchup | Mean s | W-L-other | You dry | Foe dry |
|---|---|---|---|---|
| typical ket_dan+0 | 8.2 | 20-0-0 | never | 7.3 |
| typical nguyen_anh+1 | 10.8 | 0-20-0 | 8.0 | never |
| typical hoa_than+2 | 4.5 | 0-20-0 | 4.0 | never |
| top_end ket_dan+0 | 2.0 | 0-20-0 | 2.0 | never |
| top_end nguyen_anh+1 | 1.0 | 0-20-0 | 1.0 | never |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never |

`--without` (typical ket_dan+0, health left 94 % with everything):

| Test | Mean s | W-L-other | Foe dry |
|---|---|---|---|
| everything | 8.2 | 20-0-0 | 7.3 |
| `--without item:blade-unbroken-edge-ring` | 9.2 | 20-0-0 | 8.1 |
| `--without eff:Lingering Afterimage` | 8.4 | 20-0-0 | 7.6 |
| `--without tech:hunters-reach-canon` | 8.5 | 20-0-0 | 7.6 |

`--without item:` removes only the ring's plain modifiers, so the 1.0 s is what its sword crit, attack, crit damage and speed are worth. The Effect is run as three records (see UNMODELLED); only the Afterimage hold was removed in the Effect test, so the Coil hold and the basic-attack cut stayed in.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | grade 4 sword with a canon art | A stronger fifth suite art | craft, sect | missing at grade 4 (`blade-thousand-cut-sword` is a Thousand Cuts piece) | medium |
| Extra | `than_thuc_pct` | Room for a fourth extra | Sword-Nest Flag +6 % | in catalogue, costs non-sword arts 15 % | low |
| Any | Slowed Time on the foe (Pinning Arrow, Nocked Arrow) | Opens Coiling Thrust's and Nocked Arrow's steps | Hunter's Reach Canon arts | in the library, no slot left | medium |
| Any | Flurry Stance | Opens Phantom Sword's steps without 3 canon arts in a pulse | Afterimage Sword Canon | in the library, no slot left | medium |
| Armour | a ward the engine runs | Defence that shows in the fight | craft | in catalogue, ward not run | low |
| Extra | counter-spending Effect (a crit that spends a big Afterimage bank) | A reason for banks above 7 | blade family | missing | medium |

## Missing pieces

- A way to bank a counter faster, not just keep it: the blade family should own an item or art that adds Afterimages on crit beyond Phantom Sword.
- A second slow-engine technique at grade 4 for the Sword Hall: blade, or a main-tier technique for Afterimage.
- A body piece for this build with a ward the engine can run as drain: blade or body.

## UNMODELLED

- Lingering Afterimage: no verb for "a counter does not decay", so two pulse Effects add back 0.1 a pulse to Afterimage and Coil while above 0.05; a third Effect carries the basic attack cut of 30 % (basic_coef -0.3). Their order against the decay is not shown, so the hold may be off by one tenth.
- Unbroken Edge Aura reserve art: linh lực not deducted, grants not run (the engine has no reserve).
- Tortoise-Edge Shell ward: cast ward, the engine takes only drain wards.
- Iron Skin Renewed and Opening Cut: not written, the build does not rely on them.
- Twin-Edge Return art: art slots full, not slotted.
- Sword scope on item crit chance, crit damage, art speed: art speed applies to every art, so Coiling Thrust gets the sword bonuses too.
- Passives with no engine stat: linh_luc_on_crit_pct, linh_luc_pct, khi_huyet_pct, defense_pct, health_regen_inc_pct, stack_effect_pct, stack_duration_pct, status_duration_pct.

## Observations

The unique did not make this build: without the ring the typical same-realm fight is 9.2 s against 8.2 s, a 1.0 s gap that is all modifiers, and the Lingering Afterimage Effect alone is worth 0.2 s (8.4 against 8.2) with the Coil hold and the basic cut left in. The reason is fight length, not the Effect: the foe dries at 7.3 s, before any engine can bank, since Phantom Sword fires 3.5 times and Flying Sword 0.9 times a fight, so a counter that decays 0.1 a pulse hardly decays in 8 s. The build is far under the 30-60 s band (8.2 s) and wins 20-0 at the same realm with 94 % health, while it loses 0-20 against every higher realm and top end (10.8 s against nguyen_anh+1, 1-2 s at top end); I did not tune it. Nothing looks degenerate except that the same-realm win is a flat one: you never run dry. Never fired: flying-sword (0.0) and triple-draw against typical hoa_than+2, and everything against top end, where the foe kills in 1-2 s. Blade-rain-afterimage clipped 3.9 times a fight, so Sword Rain's twice-a-pulse Afterimage limit throws away more than the ring keeps. Hunter's Reach as main is worth little: removing its passives costs 0.3 s (8.5 s against 8.2 s), and Coiling Thrust has no Slowed Time source in the loadout.

UNIQUE-DONE unique-unbroken-edge-ring
