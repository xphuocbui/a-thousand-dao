# The Three Smeltings (Tam Luyện): a Physical blow converted to Fire, then to Chaos, so Physical, Fire and Chaos bonuses all feed every hit

Rebuilt from the art library and technique catalogue at Nascent Soul (Nguyên Anh, `nguyen_anh`); fight file `design/builds/engine-v2/builds/triple-convert.fight.json`. The old build had **no fight file** (the glob found none, and no other realm file), so there is only this one realm file, and layers, crit, ward and body are not carried over from anything: see UNMODELLED.

## Old piece to library piece

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Third Smelting (heavy Physical blow, lays Sundered) | `shatter-edge-cleave` (heavy Physical cleave) | nine-temper-scripture (6) |
| Ore-Splitting Cut (quick cheap cut, Sundered) | `whetstone-pass` (Metal arts, Temper crit stack) | nine-temper-scripture (1) |
| Three Smeltings Canon, first link (art strikes Physical, turns itself 100 % Fire) | `scorch-fist` (Physical fist, half converted to Fire, 3 Burn) | scorch-fist-primer (1) |
| Bellows Flame (4 Burn) | `scorch-fist` (Burn), also `blight-canker` | scorch-fist-primer (1) |
| Charcoal Smoke (4 Poison, Wood buff) and Green-Smoke Rot Sutra (Chaos, Poison) | `blight-canker` (Poison, Stagnation), `thornling-grove` (Chaos-striking Thornling, Poison) | rotting-canopy-canon (2), (6) |
| Ore-Vein Scripture (Physical L2 passive) | `sheathed-edge` (crit banks free Physical hits) plus nine-temper passives | nine-temper-scripture (4) |
| Charcoal Poultice, Quench | not taken (no slot) | none |
| Former Shapes (identity) | Effect `former-shapes`, kept, approximated flat L5 +20 | none (Đạo) |
| Kindled Wound, Marked Prey | Effects kept as written (Kindled Wound flat) | none |
| Kiln-Hook Sword, Nine Rods Array, Soot Coating | items; kept only as a flat L4 80 in `layers` | none |

## Techniques chosen and why

- **Main: Nine-Temper Scripture** (`nine-temper-scripture`, Yellow main, kim). Its four arts are all Physical Metal damage with a crit/Temper engine, the closest library match to "strike as iron". Layers 1/4/6 arts used.
- **Aux: Rotting Canopy Canon** (`rotting-canopy-canon`, Earth secret, moc). Poison, Stagnation and a Chaos-striking Thornling carry the "kill as smoke" end; its passive Chaos +6 attack matches the guide's Chaos bonus (not modelled by the engine as scoped).
- **Aux: Scorch Fist Primer** (`scorch-fist-primer`, Yellow secret, hoa). `scorch-fist` is the only library art that converts Physical toward Fire, the first link of the chain.
- Six arts fit at Nascent Soul (slots 6): `shatter-edge-cleave`, `scorch-fist`, `whetstone-pass`, `sheathed-edge`, `blight-canker`, `thornling-grove`. `blood-quench-blade`, `thorn-rain` and `bloodroot-pact` were left out for slots.

## Lost in the move

- **The double conversion itself.** The library has no art that converts twice and the engine does not model conversion inside a hit; `scorch-fist` converts half to Fire once, and nothing converts to Chaos. The build's defining claim (every hit ends as Chaos, passing iron skin) is **not tested**.
- **The damage history** (Physical, Fire and Chaos bonuses all applying to one hit; Former Shapes counting earlier types): approximated by a flat +20 L5.
- **The L2 300-point stack** from Canon, Green-Smoke Sutra, Ore-Vein Scripture: the invented passives are gone; only library passives load.
- **Sundered** (the curse that strips Chaos resistance), **Fire to Chaos convert_pct**, **Chaos penetration**, **Festering Wound**, **Blood Drinker**, the **Quench cleanse** and **Charcoal Poultice** heal.

## Matchups (nguyen_anh file, `--matrix`, 20 fights each)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, nguyen_anh+0 | 8.2 | 20-0-0 | never | 7.8 s | trig_budget 0.1 |
| typical, hoa_than+1 | 5.5 | 0-20-0 | 4.3 s | never | none |
| top_end, nguyen_anh+0 | 1.6 | 0-20-0 | 1.0 s | never | none |
| top_end, hoa_than+1 | 1.0 | 0-20-0 | 1.0 s | never | none |

Arts per fight (typical, same realm): shatter-edge-cleave 1.0, scorch-fist 2.4, whetstone-pass 5.5, sheathed-edge 2.4, blight-canker 1.0, thornling-grove 1.0.

## --without tests (typical, nguyen_anh+0)

| Test | Before | After |
|---|---|---|
| `--without tech:nine-temper-scripture` (main technique passives) | 8.2 s, 20-0, 82 % health left | 8.5 s, 20-0, 82 % health left |
| `--without former-shapes` (identity Effect) | 8.2 s, 20-0, 82 % health left | 9.0 s, 20-0, 74 % health left |

## UNMODELLED

- Two conversions per hit and the damage history: the engine has no conversion inside a hit beyond an art's own `convert`; Former Shapes is a flat L5 +20.
- Kindled Wound's Fire-part scope and Festering Wound: mod keys have no part scope; Kindled Wound is a flat L5 +15 against Burn, Festering Wound omitted.
- Fire to Chaos convert_pct and Chaos penetration: no field for them; not written.
- Sundered curse: `curses` takes only withering and stagnation; the arts bring their own statuses.
- Kiln-Hook Sword Blood Drinker, Nine Rods Array, Soot Coating: L4 stands as a flat 80, the leech is omitted.
- Layers, crit (30 %, x2.0), ward, body, cost reduction (20 %) and purity (75 each in metal, fire, wood): none existed in an old file; taken from the guide's caps and the typical anchor, so they are a guess, not a carried-over value.
- Technique passives with no engine stat or scope: nine-temper `stack_duration_pct`, rotting-canopy `stack_effect_pct`, `stack_duration_pct`, `status_duration_pct`, `art_cost_health_pct`, scorch-fist-primer `stack_effect_pct` and Fire `resist_pen_pct`; `art_speed_pct` scoped to kim or moc applies to every art.

## Observations

At the build's own realm the fight lasts 8.2 s against a typical enemy, about a fifth of the 30-60 s band; every fight is won with 82 % health left and the enemy runs dry of linh lực first, so the build kills far faster than the target, though a flat L5 and guessed layers may inflate that. Against hoa_than+1 and top-end enemies it loses all 20 fights in 1-5.5 s, and most arts never fire (`shatter-edge-cleave` NEVER_FIRED at hoa_than+1 and top_end; `blight-canker` and `thornling-grove` NEVER_FIRED at hoa_than+1; every art but `whetstone-pass` NEVER_FIRED at top_end), because the build dies before they come off cooldown. The guide's claims do not hold or cannot be tested: the ×255 top-end figure, the double conversion, the Chaos-resistance break and "passes the iron skin" all depend on conversion the engine and library do not provide, so nothing here supports them. The two `--without` tests move the result little (8.2 to 8.5 s without the main technique's passives, 8.2 to 9.0 s without Former Shapes); the build's results mostly come from the arts' own damage, not the technique passives. The identity claim was approximated, not run.
