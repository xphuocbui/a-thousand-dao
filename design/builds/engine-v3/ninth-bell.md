# The Ninth Bell (Cửu Hưởng Đạo): a Metal (kim) art build whose Temper count feeds a coin that breaks Metal stacks, geared with named Metal items

Realm: Core Formation (Kết Đan, `ket_dan`). Fight file: `design/builds/engine-v3/builds/ninth-bell.fight.json` (copy of the engine-v2 file plus `items`, one swapped art and one Effect).

## Loadout

Extra-slot limit: 45 × divine_sense 1.0 × (1 + 0 / 100) = **45 thần thức** (the build file has no than_thuc_pct and no divine_sense). Grade cap 4 at this realm.

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Heaven-Minted Coin (Thiên Đúc Tiền Tiêu), `metal-heaven-minted-coin` | 4 (unique) | Its art Golden Coin Rain reads the same `temper` counter the Nine-Temper Scripture builds, and breaks Metal stacks into free hits. It takes the slot of `frozen-hour-seal` (the technique's seal passives stay). |
| Armour | Tortoise-Scale Armour (Quy Lân Giáp), `metal-tortoise-scale-armour` | 3 | Body: health, block, resistance, regeneration; the best Metal armour. |
| Ring 1 | Iron Temper Ring (Thiết Thối Giới), `metal-iron-temper-ring` | 1 | Crit chance and a stronger Metal buff. |
| Ring 2 | Ring of the Returning Edge (Phong Hồi Giới), `metal-ring-of-returning-edge` | 3 | Crit chance, crit damage, Metal art speed; Effect Edge Returns the Breath refunds linh lực on a Physical crit (Temper gives this build its crit). |
| Necklace | Whetstone Jade Pendant (Thạch Mài Ngọc Bội), `metal-whetstone-jade-pendant` | 2 | linh lực, regen and healing; reserve art Keen Edge Aura (Metal debuffs stronger, Metal arts 10 % faster). |
| Extra 1 | Bronze Peal Bell (Đồng Chung Hộ), `metal-bronze-peal-bell` | 2 | Standing all-damage ward and body stats. TT 25. |
| Extra 2 | Hundred-Edge Flying Sword (Bách Nhận Phi Kiếm), `metal-hundred-edge-flying-sword` | 3 | Metal debuff duration and strength, crit. Its art is not slotted (art slots are full). TT 20. |
| **Total TT** | | | **45 of 45** (base slots cost none) |

## Before and after

Run on the current engine; the engine-v2 guide's own table (6.2 s typical) is older than the engine, so the "old" column below is the engine-v2 file run today.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical ket_dan+0 | 8.7 | 4.5 | 20-0-0 | 20-0-0 |
| typical nguyen_anh+1 | 13.7 | 10.5 | 0-20-0 | 20-0-0 |
| typical hoa_than+2 | 8.0 | 8.9 | 0-20-0 | 0-20-0 |
| top_end ket_dan+0 | 3.0 | 3.9 | 0-20-0 | 0-20-0 |
| top_end nguyen_anh+1 | 2.0 | 2.0 | 0-20-0 | 0-20-0 |
| top_end hoa_than+2 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

Health left, typical ket_dan+0: 59 % old, 89 % geared. Typical nguyen_anh+1 geared: won with 47 % left.

| Test (typical ket_dan+0) | Mean s | W-L | Health left |
|---|---|---|---|
| geared baseline | 4.5 | 20-0 | 89 % |
| `--without item:metal-heaven-minted-coin` (also removes its art) | 5.0 | 20-0 | 88 % |
| `--without eff:Edge Returns the Breath` | 4.5 (NO_CHANGE) | 20-0 | 89 % |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Seal of Full Payment (Effect) | Pays arts in carried stones, keeping linh lực for the ward | Heaven-Minted Coin, held by a Gold-root merchant elder or a sunken vault | In the catalogue (not modelled) | Medium |
| Ring | Edge Returns the Breath (Effect) | Linh lực back on a Physical crit | npc, event | In the catalogue | Low (changed nothing here) |
| Necklace | stack_effect_pct / art_speed_pct [kim] via Keen Edge Aura | Stronger Metal debuffs, faster Metal arts | craft, npc, event | In the catalogue (reserve not run) | Medium |
| Any | Metal art-speed or Temper-count source | A Temper (crit chance) engine that is item-fed | none | Missing | High |
| Armour | Iron Skin Renewed (Effect) | Body shield on every Physical art | craft, quest | In the catalogue (not modelled) | Medium |
| Any | Ward that beats ws 120 / we 120 | Survival against nguyen_anh+ foes | none better found | Missing | High |

## Missing pieces

- A beat-aligned timer item (art cooldowns or Temper gain keyed to a rhythm): metal.
- A Metal art-speed ring or necklace with `art_speed_pct` the engine can read per art: metal.
- A Temper-count Effect (more Temper per Metal art fired): metal.
- A ward item that beats the build's own ward: a family-neutral one from general or body.

## UNMODELLED

- Seal of Full Payment: the engine has no spirit-stone payment.
- Iron Skin Renewed: its rule was not read for this run.
- Ward Tortoise-Scale Shell (cast) and ward Bronze Peal (standing, all 120 points): not shown to beat the build's ward, so the build's ward stands in.
- Item modifiers with no engine stat: khi_huyet_pct, defense_pct, health_regen_inc_pct, linh_luc_pct, stack_effect_pct, stack_duration_pct (the loader printed each as "no engine stat").
- Item art-speed modifiers scoped to kim or sword: applied to every art by the engine.
- Keen Edge Aura reserve art: reserves 15 % linh lực, not deducted; its grants are not run.
- The v1 and technique items carried from the engine-v2 file (Sustained Note, On the Beat, Bare Vessel, pierce, guard, ward shape).

## Observations

Gear mattered: the typical same-realm fight went from 8.7 s to 4.5 s, health left from 59 % to 89 %, and the one-realm-up fight flipped from a 0-20 loss to a 20-0 win (10.5 s, 47 % health left); the two-realm-up and top-end fights are still lost, and top_end hoa_than+2 still lasts 1.0 s. Every fight is shorter than 30-60 s, and the geared one is shorter than the old one, so the gap to the band grew. No item made the build degenerate in what was run, but the one-realm-up win is a large swing from a mostly stat-based loadout, worth a look. The coin is the item that matters most (5.0 s without it against 4.5 s with it), though only a 0.5 s difference; most of the gain comes from the item modifiers the engine can read. Fired nothing: Edge Returns the Breath (NO_CHANGE), the Hundred-Edge Flying Sword (its art is not slotted and its modifiers are mostly unread), the Bronze Peal Bell ward (not modelled), and most Seal of Full Payment and reserve-art value. Several modifiers printed "no engine stat", so the geared result may understate the items. `shatter-edge-cleave` never fires against top_end nguyen_anh+1 or hoa_than+2.
