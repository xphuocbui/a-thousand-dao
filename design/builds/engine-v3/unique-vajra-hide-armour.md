# The Tithe-Paying Wall (Nạp Cống Thuẫn Thân), unique build

Concept: a body-tempering Earth fist build where the Vajra-Hide Armour (Kim Cương Bì Giáp) pays Marrow Tithe Strike's health cost from the body shield, so health stays full while Debt piles up for the x11 Last Marrow. Realm: Core Formation (Kết Đan, ket_dan). Root: Earth (Thổ), purity 60.

File: `design/builds/engine-v3/builds/unique-vajra-hide-armour.fight.json`.

## How it works

- Unbroken Flesh Canon (Bất Hoại Nhục Kinh) is the engine: Marrow Tithe Strike writes 2 Debt a firing (and 1 per hit taken, once a pulse), pays 8 % health, and its next two firings call the Debt in as a x4 Marrow Burst and the x11 Last Marrow.
- Last Breath Fist and Bulwark Knuckle read the same Debt, health missing and body shield, so every art in the file is a canon art.
- The body shield (base 0.3 of health, plus Bulwark Knuckle, Bastion Reprisal and Iron Skin Renewed top-ups) is the second health bar; Mountain Root Stance and the drain ward sit in front of it.
- The unique, Vajra-Hide Armour, adds Shield Pays the Blood (Thuẫn Thế Huyết): the 8 % health the Tithe would cost is taken from the shield while the shield holds that much, and the armour's healing closes 20 % weaker.
- As written, the Effect trades shield for health at a loss: the engine still takes the health, then gives back a heal cut by the 20 % closes, so the shield pays 8 % and flesh recovers about 6.4 % (see Observations).

## Loadout

| Slot | Item | Grade | Why |
|---|---|---|---|
| Armour (unique) | `body-vajra-hide-armour` Vajra-Hide Armour (Kim Cương Bì Giáp) | 4 | The build's item: Shield Pays the Blood, shield +30 %, health regeneration +30 %, block +15, a cast Physical ward (not run) |
| Weapon | `body-flesh-seal` Flesh Seal (Nhục Ấn) | 3 | "Unbroken Flesh Canon builds" piece; shield +20 %, khi huyết +14; its art stays out (art slots full) |
| Ring 1 | `body-iron-skin-ring` Iron Skin Ring (Thiết Bì Giới) | 3 | Iron Skin Renewed: each Physical art adds 2 % body shield (once a pulse); shield +24 % |
| Ring 2 | `body-tempered-marrow-ring` Tempered Marrow Ring (Luyện Tủy Giới) | 1 | khi huyết +8, health regeneration +20 |
| Necklace | `body-stone-marrow-pendant` Stone-Marrow Pendant (Thạch Tủy Ngọc Bội) | 2 | Health regeneration +30; reserve art (not deducted) |
| Extra 1 (TT 15) | `body-mountain-gate-shield` Mountain-Gate Shield (Sơn Môn Thuẫn) | 2 | Shield +10, defence +8; its cast body-shield ward is not run |
| Extra 2 (TT 20) | `earth-boundary-flag` Boundary Flag (Giới Kỳ) | 2 | Planted Banner: Earth parts 2 % more per 4 Earth buff stacks; Earth stack effect +24 %, duration +30 %, thần thức +3 % |
| Extra 3 (TT 8) | `earth-clay-seal-ring` Clay Seal Ring (Nê Ấn Giới) | 1 | Earth stack effect +12 %, khi huyết +8 |
| Extra 4 | empty | - | nothing else fits the TT left |

Thần thức: 15 + 20 + 8 = 43 against a limit of 45 × (1 + 3/100) = 46.35 (only the flag gives than_thuc_pct; the engine does not read it).

Techniques: Unbroken Flesh Canon (body, main method here, always usable), Mountain Heart Canon (Sơn Tâm Kinh, Earth), Mountain Bone Body Art (Sơn Cốt Thể Thuật, body).

Arts (5 slots at Core Formation, layers all within 9): Marrow Tithe Strike (Tủy Cống Quyền), Last Breath Fist (Tàn Tức Quyền), Bulwark Knuckle (Thuẫn Quyền), Bastion Reprisal (Thuẫn Phản Kích, Mountain Heart L4), Mountain Root Stance (Sơn Căn Thế, Mountain Bone L2). The armour has no art of its own.

## Fights

20 fights each, layers, crit, ward and body at the typical anchor (L1 112, 40/40/20/10; crit 0.10 x1.5).

| Matchup | Mean s | W-L-other | You dry | Foe dry |
|---|---|---|---|---|
| typical ket_dan+0 | 12.0 | 20-0-0 | never | 10.4 |
| typical nguyen_anh+1 | 61.2 | 20-0-0 | 15.1 | 40.2 |
| typical hoa_than+2 | 8.5 | 0-20-0 | 4.0 | never |
| top_end ket_dan+0 | 2.0 | 0-20-0 | 2.0 | never |
| top_end nguyen_anh+1 | 1.0 | 0-20-0 | 1.0 | never |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never |

`--without` (health left in brackets, typical matchups):

| Test | ket_dan+0 | nguyen_anh+1 | hoa_than+2 |
|---|---|---|---|
| nothing removed | 12.0 s, 20-0-0 (100 %) | 61.2 s, 20-0-0 (89 %) | 8.5 s, 0-20-0 |
| `--without item:body-vajra-hide-armour` | 12.0 s, 20-0-0 (100 %) | 62.7 s, 20-0-0 (90 %) | 8.4 s, 0-20-0 |
| `--without eff:Shield Pays the Blood` | 12.0 s, 20-0-0 (100 %) | 61.4 s, 20-0-0 (93 %) | 8.5 s, 0-20-0 |
| `--without tech:unbroken-flesh-canon` | not run: WITHOUT_NOT_FOUND | | |
| `--without marrow-tithe-strike` (art, extra) | 12.0 s, 20-0-0 (100 %) | 65.3 s, 19-0-1 (67 %) | 8.1 s, 0-20-0 |

What the unique is worth: `--without item:` removes only its plain modifiers (of which the engine reads only block +15): without it the nguyen_anh+1 fight is 1.5 s slower and 1 point of health left higher (90 % against 89 %), and 0.1 s different elsewhere. The Effect removed: +0.2 s at nguyen_anh+1 and health left rises from 89 % to 93 %. The tech test failed because every passive of Unbroken Flesh Canon (shield, health regeneration, khi huyết) has no engine stat, so no `tech:` Effect exists; the art-level test shows the canon's opener is worth 4 s and 22 points of health at nguyen_anh+1.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Armour | Shield Pays the Blood refund without the 20 % closes on its own refund | Makes the Effect a real saving | the unique armour, new engine rule | in catalogue (new, not in effects.md) | high |
| Ring | a Debt-writing modifier or Effect | Faster Last Marrow | body family | missing | high |
| Weapon | grade 4 body weapon with a tithe art | Another canon art in the slots | body family | `body-mountain-splitting-axe` exists, its art is Mountain Root not tithe | medium |
| Extra | `than_thuc_pct` | Room for a fourth extra piece | Boundary Flag +3 % | in catalogue, small | low |
| Necklace | `earth-stone-debt-necklace` Debt of Stone | A Debt source for a health payer | earth family | in catalogue, Effect new and not written | medium |
| Any | body shield modifiers the engine reads | The shield stat is at anchor, so +30 % shield and the rest add nothing | engine | missing from the engine, not the catalogue | high |

## Missing pieces

- A shield-share stat (`body_shield_pct`) the engine reads: the combat engine, since the armour, flesh seal, rings and three techniques all give it.
- A cast Physical ward the engine can run (Vajra Shell): the engine's ward model.
- A fifth art slot's worth of canon arts: Marrow Tithe Strike, Last Breath Fist and Bulwark Knuckle already fill three; a Debt-reading art from the body family would give the Last Marrow a second user.
- A reading of Debt as a visible counter: the engine's art fire counter does not report how often the x11 step opened.

## UNMODELLED

- Vajra Shell (cast Physical ward 140.4, cooldown 5 s, up 2 s): the engine takes drain wards only; the typical drain ward stays.
- Mountain-Gate Ward (cast body-shield ward, shield 0.18): no cast shield of that kind in the file.
- Item and technique modifiers with no engine stat (khi_huyet_pct, defense_pct, health_regen_inc_pct, body_shield_pct, stack_effect_pct, stack_duration_pct, than_thuc_pct): not added; layers and body shield stay at the anchor.
- Shield Pays the Blood: written as a 0.08 heal plus a 0.08 body-shield deduction on any tithe-tagged firing while the shield holds 0.08, with the 20 % closes as a separate always-on healing -20; a part-empty shield is not split, and the heal shrinks by the closes, which the real rule may not do.
- Reserve art Stone-Marrow Aura: reserve not deducted, grants not run.
- Planted Banner and Iron Skin Renewed: written from their catalogue rules (Planted Banner matches its record; Iron Skin Renewed copied from `starter-wall.fight.json`).

## Observations

The unique does not make this build. At the same realm the fight is a flat win at 12.0 s with full health with or without the armour, and the armour's modifiers (shield, regeneration, block) are almost all stats the engine does not read, so its `--without` gap is 1.5 s at nguyen_anh+1 and nothing elsewhere. The Effect as written is slightly negative: removing it lifts health left from 89 % to 93 % at nguyen_anh+1, because the shield spent on the tithe is worth more than the heal that comes back, and the engine still charges the health. The engine's refund treatment may be the wrong reading of "paid from the shield first", so this is a modelling limit as much as a design one. Fight length is the right band only against nguyen_anh+1 (61.2 s, just over 60); at the same realm 12.0 s is far below 30-60 s, and against a higher realm the build dries (4.0 s) and loses. Top-end foes finish it in 1-2 s and the arts never fired there (NEVER_FIRED on all five). Bastion Reprisal fires once a fight at same realm and 0.1 times at hoa_than+2; Tithe-wound Debt clips 8.5 times a fight at same realm (once a pulse limit), so most hits taken do not turn into Debt. Whether the x11 Last Marrow step ever opened is not visible in the fight output, so this guide does not claim it did.

UNIQUE-DONE unique-vajra-hide-armour
