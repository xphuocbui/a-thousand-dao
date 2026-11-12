# The Moon in the Well (Tĩnh Nguyệt Tỉnh), on the Nine-Fathom Abyss Seal

A Water litany build: stack Slowed Time on the foe, let a slow seal drop four and a half times as hard once the litany is running, and refill linh lực from the foe's own wards. Realm: Core Formation (Kết Đan, ket_dan), root Water (thuỷ), purity water 100.

## How it works

- Three Undertow Litany arts and the Seal all count as litany arts. Two of them fired within one second, with 4 Slowed Time on the foe, unlock the Seal's second step: a 4.5 coefficient hit and every foe art delayed 1.5 s.
- Slowed Time comes from the Seal itself (1 stack, 4 s), Drag of the Deep and the other litany arts; each Seal hit also delays the foe's slowest-ready art by 1 s.
- Still Moon Tide Scripture is the main method: Gathering Wave banks waves that release as free Water hits and heal, and its passives speed Water arts and raise healing.
- The Nine-Fathom Abyss Seal (`water-nine-fathom-seal`) is the weapon slot. It brings the Seal art (the engine's fifth art), Water attack +22 %, art speed, linh lực and its Effect Water Table.
- Water Table (written as an engine Effect, see UNMODELLED): each Water hit returns 1 % linh lực, once a pulse. The item's text says the foe's drain wards feed the pool; the engine cannot read that.

## Loadout

| Slot | Item | Grade | Why |
|---|---|---|---|
| Weapon | `water-nine-fathom-seal` Nine-Fathom Abyss Seal (Cửu Tầm Uyên Ấn) | 4 | The unique: the Seal art, Water attack +22 %, Water Table |
| Armour | `general-hundred-patch-armour` Hundred-Patch Armour | 3 | The only base-slot armour in the catalogue that fits any root (Water has none); health regeneration and a ward not run |
| Ring 1 | `water-returning-tide-ring` Returning Tide Ring (Hồi Lưu Triều Giới) | 3 | Water stack effect, linh lực; Backflow not run |
| Ring 2 | `general-wayfarer-ring` Wayfarer Ring | 1 | Cheap filler |
| Necklace | `water-moon-well-pendant` Moon-Well Pendant (Nguyệt Tỉnh Ngọc Bội) | 2 | Named for this build; Water stack effect, thần thức +5 % |
| Extra 1 (TT 25) | `water-tide-bell` Tide Bell (Triều Chung) | 2 | Water ward gear, linh lực (ward not run) |
| Extra 2 (TT 15) | `water-brimming-shield` Brimming Shield (Doanh Thuẫn) | 3 | Shield and linh lực (shield not run) |

Thần thức: 25 + 15 = 40 against a limit of 45 × (1 + 8/100) = 48.6 (armour +3 %, pendant +5 %). Two extra slots left empty (the Mirror of the Drowned Moon is a second unique, left out).

Techniques: `still-moon-tide-scripture` (main), `undertow-litany`, `returning-wake-verse` (auxiliary).
Arts (5 slots): `water-abyss-seal-descends` (the Seal), `seep-through-palm`, `marrow-to-dew`, `drag-of-the-deep`, `gathering-wave`. The Backwash Seal of the third technique is not slotted.

## Fights

20 fights each; matrix rows are +0, +1, +2 realms above Core Formation.

| Matchup | Mean s | W-L-other | You dry | Foe dry |
|---|---|---|---|---|
| typical ket_dan+0 | 17.1 | 20-0-0 | never | 13.4 s |
| typical nguyen_anh+1 | 61.8 | 7-7-6 | 8.8 s | never |
| typical hoa_than+2 | 4.8 | 0-20-0 | 4.0 s | never |
| top_end ket_dan+0 | 2.0 | 0-20-0 | 1.6 s | never |
| top_end nguyen_anh+1 | 1.0 | 0-20-0 | 1.0 s | never |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 s | never |

What the unique is worth (`--without`):

| Test | typical ket_dan+0 | typical nguyen_anh+1 |
|---|---|---|
| nothing removed | 17.1 s, 20-0-0 | 61.8 s, 7-7-6 |
| `--without item:water-nine-fathom-seal` (modifiers only; the Seal art stays) | 18.8 s, 20-0-0 | 60.7 s, 0-18-2 |
| `--without eff:Water Table` | 17.1 s, 20-0-0 | 62.4 s, 2-13-5 (health left 3 % vs 11 %) |
| `--without tech:still-moon-tide-scripture` | 18.6 s, 20-0-0 | 58.9 s, 0-19-1 |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Armour | Water body piece with a drain ward | Replaces the generic armour | craft, sect | missing (water family has no armour) | high |
| Extra | Backflow on the Returning Tide Ring | More linh lực recovery | `water-returning-tide-ring` | in catalogue, not written | medium |
| Necklace | `than_thuc_pct` | More extra-slot room (limit 48.6, 40 used) | Moon-Well Pendant | in catalogue | low |
| Any | Slowed Time stack duration | Keeps the 4-stack unlock open longer | tree or Ice items | `status_duration_pct` has no engine stat; not run | medium |
| Extra | Steady Breath (Brimming Shield) | Regeneration | Brimming Shield | in catalogue, not written | low |
| Weapon-art | Litany group arts beyond four | Faster unlock | `undertow-litany` arts, the Seal | in catalogue | low |

## Missing pieces

- A Water body armour: the water family should own it.
- A Water or Slow effect that reads the foe's ward drain (what Water Table says): the engine / effects system should own it.
- A cheap, grade-1 slow item (Slowed Time duration): the water family.

## UNMODELLED

- Water Table: written as 1 % linh lực on each Water hit, once a pulse; the engine cannot read the foe's ward drain, so the number is a stand-in.
- Backflow, Final Clause, Steady Breath: not written; the build does not rely on them.
- Hundred-Patch Ward, Rolling Tide Ward, Layered Cloud: not run; the build keeps the typical Common Ward.
- Still Surface reserve (pendant): reserve not deducted, grants not run.
- Item and technique modifiers with no engine stat: linh_luc_pct, stack_effect_pct, status_duration_pct, khi_huyet_pct, defense_pct, health_regen_inc_pct, healing_taken_pct.
- Art speed with a Water or curse scope applies to every art in the engine.

## Observations

Against a same-realm typical foe the build is a flat win, 17.1 s with full health and never dry; every `--without` leaves that row at 17.1–18.8 s, so the unique does not make it. At nguyen_anh+1, a coin flip (7-7-6 in 61.8 s), the gaps are large: without the item's modifiers 0-18-2, without Water Table 2-13-5, without the main technique 0-19-1, so the item and its Effect carry the one contested matchup. The Water Table number is a stand-in I chose (1 % a pulse), so its worth is only as good as that guess. Fight length at same realm is 17 s, under 30–60 s; the contested one reaches 62 s. Nothing degenerate. Marrow to Dew fired only 3.9 times a fight and Gathering Wave 4.7; every art never fired at top end and at hoa_than+2 except two (fights end in 1–5 s), and the Seal's second step was not counted separately.

UNIQUE-DONE unique-nine-fathom-seal
