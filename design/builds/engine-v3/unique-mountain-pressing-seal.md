# The Mountain That Presses (Áp Sơn Tông), built on the Mountain-Pressing Seal

Concept: pile Earth stacks on the foe with the Deep Vein arts, then let the Seal spend ten of them in one Sundering press. Realm: Core Formation (Kết Đan, ket_dan), grade 4 at most. Root: Earth (thổ, tho), purity 65.

## How it works

- Four cheap Deep Vein and Mountain Heart arts lay Earth stacks and Slowed Time on the foe (Millstone Palm 2, Sinking Weight 3, the Seal itself 4 a firing); Quarry Offering pays 7 % of your health for 8 Earth stacks on you.
- The Mountain-Pressing Seal's art, Mountain Presses the Sky (Sơn Áp Thiên), counts as a Deep Vein Scripture art. With 10 Earth stacks on the foe, and either three Deep Vein arts fired in 8 s or the foe Slowed 3 deep, it spends those 10 stacks for a hit 4.2 times as hard that Sunders and adds 2 Slowed Time.
- The Seal has no Effect of its own: the engine is its art's step, plus modifiers (Earth attack +22, Earth debuff stack effect +36 and duration +40) that make the stacks it needs stronger and longer.
- The necklace Debt of Stone turns Quarry Offering's health payment into 3 more Earth stacks on you (written as an Effect; accepted for now, not yet in effects.md).
- The body side (Mountain Bone Body Art, Boulder-Ring Mail, the shield and rings) is plain bulk; the build lives off the typical ward.

## Loadout

| Slot | Item | Grade | Why |
|---|---|---|---|
| Weapon | `earth-mountain-pressing-seal` Mountain-Pressing Seal (Áp Sơn Ấn) | 4 unique | The engine piece: its art presses 10 Earth stacks into a 4.2x Sundering hit; Earth attack +22 |
| Armour | `earth-boulder-ring-mail` Boulder-Ring Mail (Cự Thạch Hoàn Giáp) | 3 | Health, regeneration, Physical resistance; its cast ward is not run |
| Ring 1 | `earth-clay-seal-ring` Clay Seal Ring (Nê Ấn Giới) | 1 | Stronger Earth buff stacks, Physical resistance, health |
| Ring 2 | `body-iron-skin-ring` Ring of Renewed Iron Skin (Thiết Bì Phục Giới) | 3 | Body shield +24, block +20, health |
| Necklace | `earth-stone-debt-necklace` Necklace of Stone Debt (Thạch Trái Liên) | 3 | Debt of Stone Effect, leech, regeneration, healing |
| Extra 1 (TT 30) | `earth-mountain-mooring-anchor` Mountain-Mooring Anchor (Hệ Sơn Mao) | 3 | Earth attack +16, debuff stack effect +30 and duration +30, Earth art speed +12; its art is not slotted |
| Extra 2 (TT 15) | `body-mountain-gate-shield` Mountain-Gate Shield (Sơn Môn Thuẫn) | 2 | Block +20, body shield, defence; cast ward not run |
| Extra 3, 4 | empty | - | Nothing else fits under the limit (see below) |

The Seal sits in the weapon slot (its base, Ấn, is a weapon), so the base slots cost no thần thức. Thần thức: 30 + 15 = 45 against a limit of 45 × (1 + 7/100) = 48.15 (than_thuc_pct: Seal 3, Boulder-Ring Mail 2, Anchor 2). The Boundary Flag (20) would not fit beside the Anchor (50 against 48.15).

Techniques: main Mountain Heart Canon (Sơn Tâm Kinh, tho); auxiliaries Deep Vein Scripture (Thâm Mạch Kinh, tho) and Mountain Bone Body Art (Sơn Cốt Thể Thuật, body).

Arts (5 slots at Core Formation): Quarry Offering (Thạch Tế, Deep Vein L1), Millstone Palm (Ma Thạch Chưởng, Deep Vein L4), Stone Warden Call (Thạch Vệ Triệu, Deep Vein L2), Sinking Weight (Trầm Trọng Ấn, Mountain Heart L2), Mountain Presses the Sky (Sơn Áp Thiên, the Seal). Left out: Aftershock Slam, Strata Hammer and Bastion Reprisal (slots full).

## Fights

Layers [112, 40, 40, 20, 10], crit 0.15 x 1.7, typical ward and body. 20 fights each.

| Matchup | Mean s | W-L-other | You dry | Foe dry |
|---|---|---|---|---|
| typical ket_dan+0 | 9.1 | 20-0-0 | never | 8.0 |
| typical nguyen_anh+1 | 19.3 | 0-20-0 | 10.4 | never |
| typical hoa_than+2 | 6.0 | 0-20-0 | 4.5 | never |
| top_end ket_dan+0 | 2.0 | 0-20-0 | 2.0 | never |
| top_end nguyen_anh+1 | 1.6 | 0-20-0 | 1.0 | never |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never |

Health left at typical ket_dan+0: 100 %.

`--without` (typical ket_dan+0 / typical nguyen_anh+1, mean s, record unchanged in both):

| Test | ket_dan+0 | nguyen_anh+1 |
|---|---|---|
| nothing removed | 9.1 | 19.3 |
| `--without item:earth-mountain-pressing-seal` | 9.2 | 19.0 |
| `--without tech:mountain-heart-canon` | 9.1 | 19.0 |
| `--without eff:Debt of Stone` (the necklace's Effect; the Seal has none) | 9.8 | 19.2 |

`--without item:` removes only the item's plain modifiers (one Effect `item:<id>`); its art stays slotted. The Seal's one modelled modifier is Earth attack +22 and it was worth nothing visible (9.1 against 9.2 s). The Seal has no Effect, so the `--without eff:` step does not apply; Debt of Stone was run in its place. The art itself was not removed and tested.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon art slot | Aftershock Slam / Strata Hammer | Another heavy art; Slam counts the Seal as heavy | Deep Vein L6, Mountain Heart L6 | in catalogue, no slot | medium |
| Extra | `earth-boundary-flag` Planted Banner | Earth parts 2 % more per 4 Earth buff stacks | craft, quest | in catalogue, Effect not run, 20 TT does not fit | low |
| Armour | Iron Skin Renewed | Physical arts refill the body shield | `earth-boulder-ring-mail` | in catalogue, Effect not written | medium |
| Necklace/any | `than_thuc_pct` | Room for both the Anchor and the Flag | Dust Veil Robe (+4) | in catalogue | low |
| Any | `stack_effect_pct`, `stack_duration_pct` on foe Earth debuff | Faster, longer pile for the press | the Seal, Anchor | in catalogue, engine has no stat | high |
| Ring/Necklace | Slowed Time on hit | The second unlock condition without three Deep Vein arts | none | missing | medium |

## Missing pieces

- The engine has no stat for `stack_effect_pct` or `stack_duration_pct`, so most of this build's modifiers are not run: the engine (combat) should own it.
- The engine does not report whether a step unlocked, so the press cannot be counted: the engine (fight.py output) should own it.
- A cheap Earth debuff source stronger than Tremor Palm that is not a Deep Vein art: the earth family should own it.
- Items with Slowed Time on hit for the "foe Slowed 3 deep" branch: the earth or control family.

## UNMODELLED

- Iron Skin Renewed (Boulder-Ring Mail, Ring of Renewed Iron Skin): not written, the build does not rely on it.
- Mooring Drop (Mountain-Mooring Anchor art): art slots full, the anchor is there for its modifiers only.
- Mountain-Gate Ward and Boulder Shell: cast wards; the engine takes only drain wards, so the build keeps the typical ward.
- Stack effect and stack duration on Earth stacks (Seal, Anchor, Clay Seal Ring, Debt necklace, both Deep Vein and Mountain Heart passives): no engine stat.
- Deep Vein's art_cost_health_pct +30: no engine stat; Quarry Offering's 7 % health payment runs as its own hp_cost.
- Body shield, health regeneration, khi huyết, defence and status duration modifiers across the loadout: no engine stat.
- Than thuc and linh lực modifiers: no engine stat (than thuc counted by hand above).
- Mountain Anchor's Earth-scoped art speed applies to every art in the engine.

## Observations

The Seal does not make the build in this run: removing its modifiers moved typical ket_dan+0 from 9.1 to 9.2 s and the Earth stack modifiers that give it its value are not modelled at all, while removing the main technique's passives changed nothing at this precision (the run is 9.1 s either way). The art fired exactly once per fight in every case that reached it, but the engine does not say whether the 10-stack press step unlocked, so the Sundering press is unconfirmed. Fights are 9.1 s at same realm, well under the 30-60 s band, and the build wins them with 100 % health left while it never runs dry; against a higher realm it loses 0-20 every time (19.3 s at nguyen_anh+1, 6.0 s at hoa_than+2) and nothing at top end fires an art at all. Millstone Palm, Stone Warden Call and the Seal never fired against hoa_than+2 or top end (NEVER_FIRED); the build never fired anything against top end. Nothing looks degenerate; the Debt of Stone necklace was the only piece with a visible gap (0.7 s).

UNIQUE-DONE unique-mountain-pressing-seal
