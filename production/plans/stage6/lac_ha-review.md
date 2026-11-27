# Lạc Hà Tông: Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/lac_ha/`; nothing exported, nothing outside the brief's paths):**
- **6 techniques** (`techniques/catalogue-sect-lac_ha.json`): the 3 active lineage methods (`evening-dust-primer`,
  `sunset-cloud-canon`, `evening-song-of-the-boats`), plus 3 new methods for the stand-ins (`evening-ferry-breath` and
  `bellows-and-hearth-breath` for the non-lineage servants, and `anvil-thunder-canon` for guest armourer Vưu Chước Kim).
  `long-sky-one-colour` is **parked whole** per user ruling (`design/world/depth/builds/postponed-2026-11-26.json`) and
  not staged. Every new bonus and combat passive is marked new (§C); b1's non-fight lines (`dao_tam`,
  `breakthrough_chance`) are kept in `lac_ha.techniques.json` and held out of staged `passives` because
  `lint_techniques.py` refuses them as `NOT_PRICED` (§A 1, §I 2).
- **10 new arts** (`arts/part-sect-lac_ha.json`): the 6 active depth arts (`dust-in-the-last-light`,
  `the-sunset-clouds-fly-with-the-lone-duck`, `last-light-on-the-field`, `coming-home-at-dusk`, `oars-together`,
  `the-ninth-verse`), plus 4 new arts for the stand-in methods (`ferry-breath`, `hearth-ember-breath`, `anvil-blow`,
  `thunder-quench`). The seventh depth art, `The Glow Deepens` (d3), is a passive art: an Effect on
  `sunset-cloud-canon` at layer 3, not an art record. The three arts of `long-sky-one-colour` (`One Colour`, `Geese
  Startled by the Cold`, `Geese Line`) are parked and not staged.
- **21 Effects** (`effects/lac_ha.effects.json`): 1 passive art (`The Glow Deepens`), 10 active item Effects, and 10
  set Effects. All 21 validate in `engine.validate` and run in the engine (`Geese in File` on `lh-cold-geese-sword` is
  parked per `postponed-2026-11-26.json` and omitted).
  - 1 carries a `pending` field: `The Glow Deepens` (attaching technique Effects waits on `technique-effects`, same
    pending word as Thiên Xu; tested via `tree_effects`).
- **30 items and 10 sets** (`items/catalogue-sect-lac_ha.json`, `items/sets-lac_ha.json`), with the depth modifiers as
  given, `sources: ["npc"]`, `unique: true`, `rarity: 5` on the 2 treasures (`lh-tu-dien`, `lh-thanh-suong`), and the R6
  `exception` on the 23 weapons, robes, armour and shields.
- **9 stand-ins** replaced in `lac_ha.cast.json`, `lac_ha.3.cast.json` and `lac_ha.4.cast.json`: Ngụy Thụ Căn to
  `evening-dust-primer`, 3 Water/Wood servants to `evening-ferry-breath`, 4 Fire/Metal/Earth servants to
  `bellows-and-hearth-breath`, and guest elder Vưu Chước Kim to `anvil-thunder-canon`. Gap report `stand_ins` is now 0.
- **0 beasts** (`lac_ha` has no `lac_ha.beasts.json`). Art ids and the 3 new stand-in techniques were added to
  `lac_ha.techniques.json`.

**Checks:**
- `lint_arts`, `lint_techniques` and `lint_items`: **0 findings** each (`OVER_BUDGET` lines are notes only, since
  `catalogue-sect-*` files are unpriced).
- `engine.validate` passes all 21 staged Effects.
- `depth_check.py`: `findings: none`.
- `sect_fight.py lac_ha` (same realm and `--gap 1`, 10 seeds, 0 REFUSED) plus real-kit and synthetic probes (§H).
  **Every staged art fires** (the 9 offensive/utility/heal arts at same realm; `the-ninth-verse` at `--gap 1` when
  Wounded).

**Counts:**
- **Deviations: 31** (§C–§F, numbered D1–D31).
- **Decisions taken for the user: 13** (§A).
- **Pending words: 1** (`technique-effects`, matching Thiên Xu's spec).
- **Early promotions: none**, and no `foreign/` files.

**Never ran on a real holder in default `sect_fight`, each with its reason (and verified in probes, §H):**
- `The Glow Deepens`: loader does not attach technique Effects yet (`technique-effects`); probed via `tree_effects`
  (Hình Trọng Sơn 43.5 s → 36.4 s, Cảnh Trường Thiên 41.5 s → 33.4 s, Tô Vãn Chiếu 32.8 s → 29.7 s).
- `The Lightning Sleeps`: Tô Vãn Chiếu lacks Thunder and does not hold Thanh Sương, so the sword sleeps as its lore
  says; probed on Vưu Chước Kim (Thunder, 60 runs) and Tô Vãn Chiếu with both Twin Swords (78 forks over 30 seeds).
- `Frost on the Field`: `lh-thanh-suong` is lost (`holder: null`); probed on Tô Vãn Chiếu (Twins) and Cảnh Trường Thiên
  (Scabbard + Thanh Sương, 27.6 s vs 33.1 s).
- `The Treasury Key` and `The Sky Goes One Colour`: `lh-lone-duck-ring` is pledged to Phan Vật Hoa (`thien_bao`), so
  Sunset Regalia is split by design; probed on Tô Vãn Chiếu wearing all three (Regalia 48.7 s vs 49.8 s past 30 s;
  Treasury Key 23.1 s vs 20.2 s at `--gap 1`).
- `Lightning and Frost`: Twin Swords are split (`lh-thanh-suong` lost); probed on Tô Vãn Chiếu (22.4 s vs 25.1 s).
- `Waits for Its Blade`: Cảnh Trường Thiên wears the scabbard empty without Thanh Sương; probed with Thanh Sương
  (27.6 s vs 33.1 s).
- `Geese in the Cold`: `always` shelter record counts no runs in `sect_fight` and Cảnh never drops to Wounded at same
  realm; at `--gap 1` it runs (17.5 s vs 16.3 s, 10 runs), and with `flying-sword-strike` slotted its extra blades fire
  (15.4 s vs 13.8 s).
- `Price on the Ribs` and `Eight Marks`: `sect_fight` slots 6 technique arts, never the fan's `fan-gust`; probed on
  Hách Ánh Hà with `fan-gust` (Eight Marks 24.0 s vs 25.9 s, 74 runs; Price on the Ribs 20.7 s vs 30.8 s against a
  300-resistance body foe).
- `Breath Held`: typical foe lays no poison and `sect_fight` never slots `flying-sword-strike`; probed on Hình Lạc Nhạn
  with `flying-sword-strike` vs a Wood/poison foe (28.2 s vs 29.7 s, 153 poison stacks shed).
- `The Flame Turns Green`: typical foe lays no poison; probed on Hình Trọng Sơn vs a Wood/poison foe (44.6 s vs 48.7 s,
  344 poison stacks shed, feeding `Outlast the Grey` 407 heals and 72 anchor Earth-stack boosts).
- `Glow After Dark`: Tô Mộ Vân is Luyện Khí and wears only 1 item (set is a Trúc Cơ growth goal, ruling 2026-11-25
  Group 4); probed on a Trúc Cơ kit wearing both pieces (38.2 s, 46 % HP vs 39.2 s, 40 % HP, 23 unspent-expiry strikes).
- `the-ninth-verse` at same realm: `hong_van_tinh` and `ha_hau_thanh_bich` win at 94 % HP without ever being Wounded;
  fires at `--gap 1` when Wounded (`cooldown: 2`).

**Open items** (for the user or the serial step; §I):
- `technique-effects` pending word (shared with Thiên Xu);
- `lint_techniques.py` refuses non-fight passive keys (`dao_tam`, `breakthrough_chance` from wish b1) as `NOT_PRICED`
  even on unpriced `catalogue-sect-*` files (affects later batch owners too);
- parked records (`long-sky-one-colour` whole, `Geese in File` on `lh-cold-geese-sword`) await multi-fighter combat;
- `export_named.py` skips `kind: treasure` (2 Lạc Hà items: `lh-tu-dien`, `lh-thanh-suong`);
- `sect_fight.py` slots technique arts first, so item common arts (`fan-gust`, `needle-rain`, `flying-sword-strike`,
  `anchor-drop`, `seal-slam`) need real-kit probes;
- WIRED.md held items: d11 Debt Stone (`mountain-heart-canon` + `lh-nails-of-dao-sa`), d12 Written in the Ledger
  (`ruin-ledger-scripture`), and `sai_thanh_phong` aux `evening-song-of-the-boats`;
- out-of-fight halves: `The Treasury Key` (treasury arrays at Vân Kiều Trấn).

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **Hold b1's non-fight technique passives (`dao_tam`, `breakthrough_chance`) out of staged `passives`.**
   - `evening-dust-primer`, `sunset-cloud-canon` and `evening-song-of-the-boats` carry wish b1's `dao_tam` and
     `breakthrough_chance` in `lac_ha.techniques.json`, alongside `khi_huyet_pct` and `health_regen_inc_pct`.
   - `lint_techniques.py` treats `NOT_PRICED` as a blocking finding even on unpriced `catalogue-sect-*` files (only
     `OVER_BUDGET` is downgraded to a note), and neither key exists in `combat_engine.json` `CHARACTER_MODS`.
   - Kept `khi_huyet_pct` and `health_regen_inc_pct` in staged `passives`, left `lac_ha.techniques.json` untouched so
     the exact b1 values remain the source of truth, and logged the `lint_techniques.py` gap for the serial step (§I 2).
2. **`long-sky-one-colour` and `Geese in File` are parked, not staged** (user ruling 2026-11-26,
   `design/world/depth/builds/postponed-2026-11-26.json`).
   - `long-sky-one-colour` and its 3 new arts (`One Colour`, `Geese Startled by the Cold`, `Geese Line`) are omitted
     from staged techniques/arts/pending and get no art ids. Its 4 holders keep the aux in their cast files.
   - `lh-cold-geese-sword` IS staged (with its modifiers, R6 exception and set link `lh-off-the-field`), with
     `effects: []` because `Geese in File` is parked.
3. **`The Glow Deepens` (d3) is a passive art: a technique Effect on `sunset-cloud-canon` at layer 3, not an art.**
   - Same pattern as Thiên Xu's `The Pole Draws from the Vein` (pending word `technique-effects`).
   - Layer 3 reaches every living `sunset-cloud-canon` holder (`tang_van_tieu` is layer 3, `hinh_lac_nhan` layer 4,
     `thinh_kinh_han` layer 5, elders layers 6–14).
   - `glow_clock` is ticked by `the-sunset-clouds-fly-with-the-lone-duck` (unlock layer 1) so `last-light-on-the-field`
     works before `technique-effects` lands and never double-counts afterwards. Because `was_hit` carries raw HP
     (`event.amount`) rather than HP share, each damaging blow adds 1.5 s (≈ 3 % max HP per blow; never wound back by
     healing). Uses `dmg_more: 0.04` per 6 s (uncapped, per 2026-11-25 Group 8 ruling removing d3's 40 % cap; `L5` would
     cap at 100).
4. **Sunset Cloud's Field stance never overwrites another stance (Lesson 2).**
   - `quach_tiep_van` slots both `sunset-cloud-canon` and `mountain-heart-canon` (`mountain-stance`).
   - `the-sunset-clouds-fly-with-the-lone-duck` tracks its 10 s cloud via counter `sunset_cloud` (`decay_per_pulse: 1`)
     and only sets `state: "sunset-cloud"` (`tags: ["field"]`) when `own.state.any == 0`; expiry clears `state: null`
     only while in `sunset-cloud`. Thus `quach_tiep_van` keeps `mountain-stance` intact while his cloud still ticks,
     and every other holder (including `canh_truong_thien` for `Geese in the Cold`) holds `field_up == 1`.
   - Cooldown set to 4 s with guard `sunset_cloud <= 1` (like Băng Tâm's `lotus-seal-ground` and Thiên Xu's
     `the-pivot-does-not-turn`) so the cloud opens early at `--gap 1` without recasting while already up.
5. **`Coming Home at Dusk` (`coming-home-at-dusk`) is a sustain song, not a net linh lực drain.**
   - The depth text's literal wording ("pay 3 % of your maximum linh lực each second: you regain 2 % of your linh lực
     each second") yields −1 % linh lực/s, contradicting the technique's concept ("In a fight it is a sustain song: you
     recover linh lực and shake off fear") and `lh-stern-lamp`'s "extends it by 2 s".
   - Resolved: 3 % is the cast cost (`cost_share: 0.03`, cd 8 s), and the song runs 6 s (8 s with `lh-stern-lamp`),
     restoring 2 % linh lực/s and granting +33 % `timer_resist` (slows and delays a third shorter) and +15 %
     `status_resist`.
6. **`The Ninth Verse` uses `cooldown: 2` (guarded by `own.wounded >= 1` and `ninth_used == 0`).**
   - At `cooldown: 10`, `--gap 1` fights ended at 9.6–10.0 s before the opening cooldown elapsed. A 2 s cooldown lets the
     once-per-fight emergency verse fire as soon as the singer is Wounded.
7. **Stand-in techniques (9 people; ruled order: lineage → note → new owner technique).**
   - `nguy_thu_can` (`tho 34, moc 30`, oils the founder's maple stumps at the old seat) → `evening-dust-primer` layer 3
     (Earth ≥ 30 and Wood ≥ 30 at the old seat).
   - `hoang_lan_chi` (`moc 46, thuy 30`, "never joined the lineage"), `khuc_lao_dieu` (`thuy 50, moc 30`),
     `tan_tieu_uyen` (`moc 34, thuy 30`) → new Yellow main servants' method **`evening-ferry-breath`** (`thuy`, `moc`).
   - `ho_tu_nuong` (`hoa 40, tho 30`), `hua_tra_nuong` (`hoa 36, tho 28`, Earth < 30), `co_tieu_thiet`
     (`kim 46, hoa 38, loi 12`), `ngu_hoa_lien` (`hoa 44, kim 34`) → new Yellow main servants' method
     **`bellows-and-hearth-breath`** (`hoa`, `kim`, `tho`).
   - `vuu_chuoc_kim` (`khach_khanh`, Kết Đan, `kim 66, hoa 60, loi 34`, was `dia_loi 6`, note: "hammer, lightning, and a
     hide like his anvil") → new Earth main method **`anvil-thunder-canon`** (`loi`, `kim`, layer 6). No catalogue
     Earth-tier Thunder main method exists (`thousand-bolt-scripture` is Yellow, `heavenly-tribulation-scripture` is
     Heaven), and his former sect Thối Tinh has no Thunder method.
8. **Tử Điện's fork (`The Lightning Sleeps`) strikes the one foe and ignores trigger hits.**
   - Multi-foe forks are cut by the 2026-11-26 one-on-one ruling; replaced by a bonus Lightning hit (`c 0.7` on every
     4th Lightning art hit; `c 0.35` on every 4th sword art hit when `Lightning and Frost` wakes it). Filtered to
     `kind: "art"` so the fork's own trigger hit never feeds its own counter.
9. **`Every Debt Written` and `Every Debt Called` tally hits/blocks (`c 0.35` and `0.02` body shield per mark).**
   - `return_damage` reads only the current event's `amount`, not an accumulated damage counter. Tallying each damaging
     blow taken (and each blocked blow with the 3-piece set) and firing a `free_hit` (`c 0.35` per mark,
     `outside_budget: true`) plus a body shield (`0.02` max HP per mark) keeps the ledger-wall identity without a new
     engine word.
10. **`Price on the Ribs` uses resistance penetration (`pen: 25` per Earth stack for 4 s) and `Eight Marks` uses
    `exposed` + `bypass: 0.30`.**
    - The engine cannot write a negative defence mod onto the foe. On a ~500-point typical ward, 5 % defence per Earth
      stack is ~25 resistance points (no cap). `Eight Marks`'s guard break follows Thiên Xu's standing ruling (§A7:
      `exposed` + `bypass`).
11. **Non-spatial/non-environment rewrites for `The Flame Turns Green` and `Outlast the Grey`.**
    - "within 30 m" becomes carrying a poison (`own.debuff.wood >= 1`) or miasma (`own.status.corpse_rot >= 1`) stack;
      "fade twice as fast" cleanses 1 Wood stack each pulse (feeding `poison_faded` for `Outlast the Grey`, since
      `batch_ended` fires on the caster rather than the victim).
    - "locked in place for 1.5 s" becomes `stop_clock` 1.5 s + `bound` 2 s (no positions).
12. **`Geese in the Cold` reads `own.field_up` while `long-sky-one-colour` is parked.**
    - Standing ruling R1 maps "while your field stands" to `own.field_up`. Cảnh Trường Thiên's Sunset Cloud Field
      activates the 10 % damage dampening and the Wounded blade-gain cleanly.
13. **Signature items as R6 and treasures as rarity 5.**
    - All 30 items carry `sources: ["npc"]` and `unique: true`; 23 weapons/robes/armour/shields carry the R6 exception;
      the 2 treasures (`lh-tu-dien`, `lh-thanh-suong`) keep `kind: "treasure"` with `rarity: 5` (`grade + 1`).

---

## B. The mechanic table (step 1: the engine has it / needs a word / parked)

| Record | Mechanic | Engine |
|---|---|---|
| Evening Dust Primer, Dust in the Last Light | Earth hit, Earth stack + 3 s accuracy drop | has (`debuff`, short 3 s `stacks` Earth) |
| Sunset Cloud, Sunset Clouds Fly with the Lone Duck | 10 s Field, 1 Earth/s + 1 % heal/s, slow at 5+ Earth, glow clock | has (`state` tag `field`, `counter` decay, `stacks`, `heal`, `slowed_time`, `was_hit`) |
| Sunset Cloud, The Glow Deepens (d3) | glow clock (+time, +blows taken); +4 % Earth dmg per 6 s, no cap | record runs (`dmg_more` scaled); **needs a word** to attach a technique Effect (`technique-effects`) |
| Sunset Cloud, Last Light on the Field (d3) | gated by 10 s glow clock or 10+ Earth; consumes Earth stacks for scaled Earth hit | has (`guards` with `any`, `consume` → `then` `mod` `dmg_more`) |
| Evening Song, Coming Home at Dusk | sustain song: linh lực/s, slows & fear shorter | has (`gain_qi`, `timer_resist`, `status_resist`) |
| Evening Song, Oars Together | 4 s own haste + foe slow | has (`art_speed`, `slowed_time`) |
| Evening Song, The Ninth Verse (d14) | once when Wounded: 10 s −10 % dmg taken, 1 % heal/s, delay immunity | has (`wounded`, `dampen_taken`, `heal`, `delay_immune`) |
| Long Sky One Colour (+ 3 arts) & Geese in File | ally-counting field & blades | **parked** (`postponed-2026-11-26.json`) |
| The Lightning Sleeps (`lh-tu-dien`) | sleeps without Thunder; 4th hit forks | has, approx (triggers on `lightning` art hits or `twins_awake` sword hits; forks onto the one foe) |
| Frost on the Field (`lh-thanh-suong`) | sleeps without Ice; slowed foe takes Ice stacks twice | has (`foe.status.slowed_time`, `stack_grant` +1 Ice debuff, awake sword hit) |
| Colour of the Hour (`lh-sunset-cloud-robe`) | +15 % HoT at 20 s, +30 % at 40 s | has (`time`, `hregen_inc`, `healing`) |
| The Treasury Key (`lh-lone-duck-ring`) | once at ≤ 50 % HP: ward of 20 % max HP; treasury key | has (`hp_share <= 0.5`, `ward_grow` `of: "hp"`); treasury key is out-of-fight |
| Every Debt Written (`lh-vo-dinh-tally`) & Every Debt Called (`lh-debt-and-wall`, 3) | tally taken (+ blocked) dmg; call 1× (2×) for Earth return + shield | has, approx (`was_hit` / `blocked` counter, scaled `free_hit` `outside_budget`, `shield`) |
| Waits for Its Blade (`lh-empty-frost-scabbard`) | paired with Thanh Sương: grade 4 + wakes cold mods | has (reads `has_thanh_suong` flag from Thanh Sương, lifts stats & sets `frost_awake`) |
| Price on the Ribs (`lh-evening-market-fan`) | Fan Gust lowers foe defence 5 %/Earth stack for 4 s | has, approx (`pen` 25 per Earth stack for 4 s on `fan-gust`) |
| Span the Gap (`lh-cloud-bridge-flags`) & Anchored Span (`lh-cloud-bridge-works`, 3) | 2 Flag charges (12 s): −10 % dmg, ward/3 s; foe acts → 2 Earth + Slowed Time; Composed free upkeep | has (`each_for`, `dampen_taken`, `ward_grow`, `foe_pressed`, `composed`, `cost_red`, `gain_qi`) |
| The Flame Turns Green (`lh-miasma-watch-lantern`) & Outlast the Grey (`lh-miasma-watch`, 3) | poison fades 2×; faded poison heals 1 %/3 s + anchor Earth; 6 Earth locks 1.5 s | has, approx (`cleanse` Wood/rot + counter, `each_for` heal, `anchor-drop`, `stop_clock` + `bound`) |
| Lit but Not Launched (`lh-stern-lamp`) | extends Evening Song arts by 2 s | has (flag `stern_lamp` read by all 3 Evening Song arts) |
| The Sky Goes One Colour (`lh-sunset-regalia`, 3) | after 30 s, 8 s red sky: Earth stacks count double, 3 % heal/s | has, approx (doubles Earth stacks for 8 s + `stack_grant` +1 Earth + 3 % `heal`/s) |
| Lightning and Frost (`lh-armoury-twins`, 2) | wakes both swords at half strength without Thunder/Ice | has (sets `twins_awake`/`frost_awake`, half mods on `sword`, Thunder+Ice stacks) |
| Fished from the Shallows (`lh-nails-of-dao-sa`, 2) | needle on 3+ Earth pins 1 Earth; hit taken → sure-crit needle volley (6 s cd) | has (`needle-rain` + `needle` tag, `was_hit`, `sure_crit`, spent on `crit`) |
| Breath Held (`lh-three-hundred-paces`, 2) | while poisoned: +15 % sword speed, sword hits shed poison | has (`own.debuff.wood`/`corpse_rot`, `art_speed` scoped `sword`, `cleanse` Wood/rot) |
| Glow After Dark (`lh-prize-and-brush`, 2) | sealed talisman expiring unspent fires at half strength | has, approx (`talisman`/`seal` charge + `batch_ended` → `free_hit` 1.2) |
| Geese in the Cold (`lh-off-the-field`, 3) | field up: −10 % dmg; first Wounded in field adds 2 blades | has (`field_up`, `dampen_taken`, `wounded`, `free_hit` 0.16 on `sword`) |
| Eight Marks (`lh-envoys-errand`, 3) | Fan Gust at 4+ Earth breaks guard 4 s; breaks heal 2 % on song | has (`fan-gust`, `exposed`, `bypass` 0.30, counter spent on `song` `art_fired`) |

`spatial_words_check.py` had hits in `lac_ha` ONLY on the parked `long-sky-one-colour` / `geese-in-file` records and
soft prose notes; nothing staged names a position or environment condition.

---

## C. Techniques (new bonuses and passives marked NEW, sized against tier; unpriced)

| Technique | Tier, kind | Bonuses | Passives | Arts (unlock) | Peer it is sized against |
|---|---|---|---|---|---|
| `evening-dust-primer` | Yellow main, Earth + Wood | none | khi_huyet 3.3 % (b1), health_regen_inc 6.6 % (b1); **NEW**: Earth stack effect 6 % (debuff), attack 4 % [tho] | dust-in-the-last-light 1, millstone-palm 2 | clear-frost-breath (8.1 W of 8) |
| `sunset-cloud-canon` | Heaven main, Earth + Wood | **NEW**: khi_huyet 12 %, defence 12 %, tâm ma resist 10 | khi_huyet 6.6 % (b1), health_regen_inc 13.3 % (b1); **NEW**: Earth stack effect 14 % (debuff), Earth stack duration 16 % (debuff), attack 8 % [tho], linh lực regen +14 % | the-sunset-clouds-fly-with-the-lone-duck 1, sinking-weight 2, second-spring 3, last-light-on-the-field 4; passive art The Glow Deepens (layer 3) | heavenly-pivot-true-canon, deep-vein-scripture (31.2 W of 32) |
| `evening-song-of-the-boats` | Profound secret, Wood | **NEW**: linh lực 12 % | khi_huyet 6.6 % (b1), health_regen_inc 13.3 % (b1); **NEW**: linh lực regen +6 %, healing 5 %, status resist 6 % | coming-home-at-dusk 1, oars-together 2, the-ninth-verse 4 | verdant-cycle-scripture, hundred-blades-canon (17.6 W of 16, note) |
| **`evening-ferry-breath` (new)** | Yellow main, Water + Wood | none | **NEW**: health_regen_inc 8 %, linh lực regen +5 %, status resist 5 % | ferry-breath 1 | water-clock-breath, warm-hearth-breath (8.4 W of 8) |
| **`bellows-and-hearth-breath` (new)** | Yellow main, Fire + Metal + Earth | none | **NEW**: khi_huyet 4 %, health_regen_inc 10 %, linh lực regen +4 % | hearth-ember-breath 1 | warm-hearth-breath (8.6 W of 8) |
| **`anvil-thunder-canon` (new)** | Earth main, Thunder + Metal | **NEW**: attack 10 %, khi_huyet 10 % | **NEW**: attack 8 % [kim], crit 6 % [lightning], crit damage 20 % [lightning], Thunder stack duration 12 % (debuff), block 8, linh lực regen +8 % | anvil-blow 1, thunder-quench 2 | army-breaker-spear, jade-vessel-ice-heart-canon (24.9 W of 24) |

Deviations:
- **D1.** Wish b1's non-fight passives (`dao_tam`, `breakthrough_chance`) on the 3 lineage methods are omitted from
  staged `passives` because `lint_techniques.py` rejects them as `NOT_PRICED`; they stay intact in
  `lac_ha.techniques.json` (§A 1, §I 2).
- **D2.** `sunset-cloud-canon` carries 4 active abilities (cong-phap rule 17 note: 1–3), matching the depth text's 4
  active arts, plus passive art `The Glow Deepens` at layer 3 (§A 3).
- **D3.** `long-sky-one-colour` is parked whole per `postponed-2026-11-26.json` (§A 2).

---

## D. Arts (`arts/part-sect-lac_ha.json`), depth text beside engine form

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `dust-in-the-last-light` | light Earth hit, 1 Earth stack, lowers target accuracy a little for 3 s | Earth phys c 1.5, cost 0.03, cd 3; debuff 1 Earth (8 s) + on hit 2 Earth (3 s) | **D4** "lowers accuracy a little for 3 s" modelled as 2 short Earth stacks (3 s, −2.4 % acc) |
| `the-sunset-clouds-fly-with-the-lone-duck` | 10 s Field; each second +1 Earth on foe, heal 1 % HP; foe at 5+ Earth is slowed | Earth c 0, cost 0.05, cd 4, guard `sunset_cloud <= 1`, tags `earth, formation`. Counter `sunset_cloud` (10, decay 1); enters stance `sunset-cloud` (`field`) only if `state.any == 0`; pulse: 1 Earth (10 s), heal 1 %, at 5+ Earth 1 Slowed Time (2 s). Also ticks `glow_clock` (+1/pulse, +1.5/damaging `was_hit`) | **D5** stance skipped while another stance (`mountain`) is up; **D6** cd 4 with guard so it opens at `--gap 1`; **D7** carries `glow_clock` (+1.5 s per blow) |
| `last-light-on-the-field` | Earth damage × foe Earth stacks (consumed); cannot fire before 10 s glow clock unless foe has 10+ Earth | Earth phys c 1.8, cost 0.06, cd 7, guard `glow_clock >= 10` or `time >= 10` or `foe.debuff.earth >= 10`. On `art_fired`: consumes all foe Earth stacks for +12 % `dmg_more` per stack, no cap | **D8** scaling coefficient set to +12 % `dmg_more` per consumed Earth stack (`time >= 10` safety fallback) |
| `coming-home-at-dusk` | song held paying 3 % linh lực/s: regain 2 % linh lực/s, fear and slow 1/3 shorter | Wood c 0, cost 0.03, cd 8, tag `song`. Held 6 s (8 s with Stern Lamp): +2 % linh lực/s, +33 % `timer_resist`, +15 % `status_resist` | **D9** 3 % is the cast cost, not per-second drain (fixes net −1 %/s contradiction with sustain song concept, §A 5); **D10** "fear" read as `status_resist` +15 % |
| `oars-together` | next art within 4 s cast faster; foe casts slower for 4 s | Wood c 0, cost 0.03, cd 6, tag `song`. For 4 s (6 s with Stern Lamp): `art_speed` +20 %, foe 2 `slowed_time` (4 s; 5 s clamp with Stern Lamp) | **D11** haste spans the 4 s window rather than ending after a single cast; sizes (+20 %, 2 stacks) are mine |
| `the-ninth-verse` | once when first Wounded: 10 s −10 % dmg taken, 1 % heal/s, foe delays do not apply | Wood c 0, cost 0.03, cd 2, tag `song`, guard `own.wounded >= 1` and `ninth_used == 0`. For 10 s (12 s with Stern Lamp): `dampen_taken` 10, `delay_immune` 1, heal 1 %/s | **D12** cd 2 so it fires when Wounded even in short `--gap 1` fights; `dampen_taken` 10 uses the dampened op |
| `ferry-breath` (new) | n/a (stand-in) | Water heal, c_heal 0.5, cost 0.03, cd 5 | new stand-in art |
| `hearth-ember-breath` (new) | n/a (stand-in) | Elementless heal, c_heal 0.5, cost 0.03, cd 5 | new stand-in art |
| `anvil-blow` (new) | n/a (stand-in) | Metal phys c 1.9, cost 0.04, cd 3.5; 1 Metal (8 s) + 1 Thunder (8 s) on hit | new stand-in art for Vưu Chước Kim |
| `thunder-quench` (new) | n/a (stand-in) | Thunder elem c 2.0, cost 0.05, cd 6; empowered (`foe.debuff.thunder >= 3` or `own.buff.metal >= 3`): consumes up to 3 Thunder for c 3.6 + Sundered (4 s) | new stand-in art for Vưu Chước Kim |

---

## E. Effects (`effects/lac_ha.effects.json`), depth text beside engine form

| Effect (piece) | Engine form | Deviation |
|---|---|---|
| `The Glow Deepens` (Sunset Cloud, layer 3) | `always`, scaled by `glow_clock` / 6: +4 % `dmg_more` on Earth arts, no cap | **D13** blows advance `glow_clock` by 1.5 s per damaging hit (no HP-share on `was_hit`); attaching waits on `technique-effects` |
| `The Lightning Sleeps` (Tử Điện) | every 4th Lightning art hit fires a `c 0.7` Lightning free hit; with `twins_awake`, every 4th sword art hit fires `c 0.35` Lightning | **D14** 1v1 fork hits the single foe (2026-11-26 ruling); checks `dtype: lightning` / `twins_awake` rather than root purity |
| `Frost on the Field` (Thanh Sương) | marks `has_thanh_suong`; while foe has `slowed_time`, `stack_grant` +1 Ice debuff; when `frost_awake`, sword hits on slowed foe lay 1 Ice (8 s) | **D15** "takes Ice stacks twice" is `stack_grant` +1 (same ruling as Băng Tâm's `Hidden Half`) |
| `Colour of the Hour` (Robe of the Drifting Glow) | on `pulse` at `time >= 20`: `hregen_inc` +15, `healing` +15 (1.5 s); at `time >= 40`: another +15/+15 | **D16** applies to both regeneration (`hregen_inc`) and pulsed healing (`healing`) |
| `The Treasury Key` (Lone Duck Ring) | once at `hp_share <= 0.5`: `ward_grow` 20 % of max HP | **D17** treasury-array unlock is out-of-fight |
| `Every Debt Written` (Vô Định Tally) | each damaging `was_hit` adds 1 mark; once at 8+ marks or `hp_share <= 0.5`, fires `free_hit` (`c 0.35` × marks, `outside_budget`) and resets | **D18** approximated per tallied blow (`c 0.35`) rather than exact 1/3 raw damage; auto-called at threshold |
| `Waits for Its Blade` (Empty Frost Scabbard) | when `has_thanh_suong >= 1`: sets `frost_awake`, adds grade-4 lift (`ward_pct` 5, `status_resist` 4, Cold `resist` 30) and sword `L1` +20 / `art_speed` +10 | **D19** grade 3→4 rise modelled as flat defensive mods; Cold modifiers woken onto `sword`-tagged arts |
| `Price on the Ribs` (Evening Market Fan) | `fan-gust` hit grants `pen` 25 per foe Earth stack for 4 s, no cap | **D20** −5 % foe defence modelled as holder `pen` +25/stack (§A 10) |
| `Span the Gap` (Cloud Bridge Flags) | 2 Flag charges (12 s) at start + 1 per Earth art (4 s cd); at 2+ charges: `dampen_taken` 10 and `ward_grow` 3 % HP every 3 s | **D21** flags planted on fight start and refreshed by Earth arts (base `ky` has no common art) |
| `The Flame Turns Green` (Miasma Watch Lantern) | while carrying Wood debuff or Corpse Rot: cleanses 1 Wood/pulse (or Corpse Rot / 3 s) and increments `poison_faded` | **D22** non-spatial trigger; "fade twice as fast" modelled as 1 stack cleansed per second (§A 11) |
| `Lit but Not Launched` (Stern Lamp) | sets `stern_lamp = 1` (read by all 3 Evening Song arts for +2 s) | **D23** `oars-together`'s Slowed Time clamps at 5 s (Effects R22) |
| `The Sky Goes One Colour` (Sunset Regalia, 3) | once at `time >= 30`: doubles foe Earth stacks (8 s), runs 8 s `red_sky`: 3 % HP heal/s and `stack_grant` +1 Earth debuff | **D24** "Earth stacks count double" modelled as doubling current Earth stacks + `+1` Earth `stack_grant` during the 8 s window |
| `Lightning and Frost` (Twin Swords, 2) | sets `twins_awake` + `frost_awake`, adds `L1` +20 / `crit` +5 / `art_speed` +11 on `sword`, sword hits lay 1 Thunder + 1 Ice (6 s) | **D25** half-strength element mods placed on `sword` scope plus element stacks on hit |
| `Fished from the Shallows` (Nails of Đào Sa, 2) | `needle-rain` or `needle`-tagged hit on 3+ Earth lays 1 Earth (8 s); `was_hit` (6 s cd) arms `sure_crit` for next needle volley (spent on `crit`) | none (depth text followed; WIRED d11 held, §I 6) |
| `Breath Held` (Three Hundred Paces, 2) | while carrying Wood debuff or Corpse Rot: `art_speed` +15 on `sword`; sword hits cleanse 1 Wood (or Corpse Rot) | none |
| `Glow After Dark` (Prize and Brush, 2) | `talisman`/`seal` art loads a 10 s charge; unspent debuff expiry (`batch_ended`) spends 1 charge for `free_hit` `c 1.2` | **D26** half-strength expiry fire modelled as fixed `c 1.2` Physical hit on `batch_ended` |
| `Every Debt Called` (Debt and Wall, 3) | `blocked` adds 1 tally mark; grants `0.02` max HP body shield per mark on first call; allows 2nd call at 8+ marks or ≤ 40 % HP with shield | **D27** shield sized per mark (`0.02` max HP/mark) matching D18 |
| `Geese in the Cold` (What Came Off the Field, 3) | while `field_up`: `dampen_taken` 10; first `wounded` while `field_up` arms `geese_blades` (+`c 0.16` free hit on `sword` hits) | **D28** reads `own.field_up` while `long-sky-one-colour` is parked (§A 12) |
| `Eight Marks` (Envoy's Errand, 3) | `fan-gust` at 4+ Earth lays `exposed` (4 s), `bypass` 0.30 (4 s) and loads a mark; next `song` art heals 2 % HP per mark | **D29** guard break modelled as `exposed` + `bypass` 0.30 (§A 10) |
| `Anchored Span` (Cloud Bridge Works, 3) | at 2+ Flags and `foe_pressed` (2 s cd): 2 Earth (8 s) + 1 Slowed Time (3 s); while Composed at 2+ Flags: `cost_red` 0.95 on `formation` + 1 % linh lực/s | none (cap `cost_red_cap` 0.95) |
| `Outlast the Grey` (Miasma Watch, 3) | each `poison_faded` adds a 3 s heal charge (0.333 %/s) + 1 Earth stack on next `anchor-drop`; reaching 6+ Earth triggers `stop_clock` 1.5 s + `bound` 2 s (12 s cd) | **D30** non-spatial lock (`stop_clock` 1.5 s + `bound` 2 s); poison fade fed by Lantern |

---

## F. Items and sets (`items/catalogue-sect-lac_ha.json`, `items/sets-lac_ha.json`)

- **30 items, 10 sets**, with the depth modifiers preserved verbatim. Effects are referenced by plain English name.
- **D31.** `lh-cold-geese-sword` omits parked Effect `Geese in File` (§A 2). The 2 treasures (`lh-tu-dien`,
  `lh-thanh-suong`) gain `rarity: 5` (`grade + 1`). 23 weapon/body_gear/ward_gear items carry the R6 `exception`. The
  proposal-only fields `status` and `authored` are dropped.
- Set `rule` texts preserve the depth text; the engine records live in `effects/lac_ha.effects.json`.

---

## G. Stand-ins (applied in `lac_ha.cast.json`, `lac_ha.3.cast.json`, `lac_ha.4.cast.json`)

| Person | Rank, realm | Root | Was | Now (layer kept) |
|---|---|---|---|---|
| `nguy_thu_can` | tạp dịch, LK | Earth 34, Wood 30 | `hoang_tho` 3 | `evening-dust-primer` 3 |
| `hoang_lan_chi` | tạp dịch, LK | Wood 46, Water 30 | `hoang_moc` 5 | `evening-ferry-breath` 5 (new) |
| `khuc_lao_dieu` | tạp dịch, LK | Water 50, Wood 30 | `hoang_thuy` 5 | `evening-ferry-breath` 5 (new) |
| `tan_tieu_uyen` | tạp dịch, LK | Wood 34, Water 30 | `hoang_moc` 2 | `evening-ferry-breath` 2 (new) |
| `ho_tu_nuong` | tạp dịch, LK | Fire 40, Earth 30 | `hoang_hoa` 4 | `bellows-and-hearth-breath` 4 (new) |
| `hua_tra_nuong` | tạp dịch, LK | Fire 36, Earth 28 | `hoang_hoa` 3 | `bellows-and-hearth-breath` 3 (new) |
| `co_tieu_thiet` | tạp dịch, LK | Metal 46, Fire 38, Thunder 12 | `hoang_kim` 3 | `bellows-and-hearth-breath` 3 (new) |
| `ngu_hoa_lien` | tạp dịch, LK | Fire 44, Metal 34 | `hoang_hoa` 1 | `bellows-and-hearth-breath` 1 (new) |
| `vuu_chuoc_kim` | khách khanh, KĐ | Metal 66, Fire 60, Thunder 34 | `dia_loi` 6 | `anvil-thunder-canon` 6 (new) |

---

## H. The holder table (`sect_fight.py lac_ha`, 10 seeds, typical same-realm foe & `--gap 1`; probes)

**Every staged art fires.** All 9 offensive/utility/heal arts fire at same realm; `the-ninth-verse` fires at `--gap 1`
when its holders drop to Wounded. Zero holders refused.

| Holder (realm) | Same-realm result | `--gap 1` result | Effects: with / without (runs) | Probe / Note |
|---|---|---|---|---|
| `to_van_chieu` (NA) | 32.8 s, 10/10, 100 % | 19.5 s, 0/10 | Colour of the Hour 32.8/32.8 (136; gap 1: 7); Lightning Sleeps 0 | Lightning Sleeps sleeps by lore (no Thunder). Probed via `tree_effects`: **Glow Deepens 29.7 s / 32.8 s** |
| `tram_tich_duong` (NA) | 10.7 s, 10/10, 100 % | 25.5 s, 0/10 | **Every Debt Written 10.7/11.2 s (20; gap 1: 25.5/22.1 s, 163)**; **Every Debt Called 10.7/11.2 s (196; gap 1: 25.5/21.5 s, 410)** | Huge gap-1 survival gain from blocks + 2nd call + shields |
| `canh_truong_thien` (NA) | 41.5 s, 10/10, 99 % | 17.5 s, 0/10 | Waits for Its Blade 0 (scabbard empty); **Geese in the Cold gap 1: 17.5/16.3 s (10)** | Real-kit + `flying-sword-strike` gap 1: **Geese blades 15.4/13.8 s (14 runs)**. Probed `tree_effects`: **Glow Deepens 33.4/41.5 s** |
| `hach_anh_ha` (KĐ) | 39.8 s, 10/10, 99 % | 12.2 s, 0/10 | Price on the Ribs 0; Eight Marks 0 (no `fan-gust` slotted) | Real-kit + `fan-gust`: **Eight Marks 24.0/25.9 s (74 runs)**; **Price on the Ribs** (vs 300-res body foe) **20.7/30.8 s** |
| `quach_tiep_van` (KĐ) | 24.4 s, 10/10, 100 % | 24.3 s, 0/10 | **Span the Gap 24.4/32.7 s (146; gap 1: 24.3/14.1 s, 142)**; **Anchored Span 24.4/27.2 s (161; gap 1: 24.3/22.4 s, 146)** | Mountain Stance preserved beside Sunset Cloud |
| `hinh_trong_son` (KĐ) | 43.5 s, 10/10, 99 % | 13.7 s, 0/10 | Flame Turns Green 0 (no poison foe); **Outlast the Grey 43.5/42.0 s (31; gap 1: 13.7/11.2 s, 10)** | Real-kit + `anchor-drop` vs poison foe: **Lantern 44.6/48.7 s (344 runs)**, **Outlast the Grey 44.6/45.2 s (1279 runs: 407 heals, 72 anchor Earth, 40 locks)**. Probed `tree_effects`: **Glow Deepens 36.4/43.5 s** |
| `lo_xuong_van` (KĐ) | 40.6 s, 10/10, 99 % | 9.6 s, 0/10 | **Lit but Not Launched 40.6/45.3 s (129 runs)** | +2 s on Coming Home at Dusk and Oars Together cuts 4.7 s off fight |
| `chu_hong_diep`, `bo_tan_chieu`, `lan_vien_pham`, `su_thu_thuy`, `thinh_kinh_han` (KĐ) | 41.9–45.2 s, 10/10, 98–99 % | 9.6–13.7 s | n/a | Patient 40 s Sunset Cloud elders |
| `vuu_chuoc_kim` (KĐ) | 24.9 s, 10/10, 82 % | 13.4 s, 0/10 | n/a | New `anvil-thunder-canon` + `iron-hide-manual`; both arts fire cleanly |
| `lu_tan_chu` (TC) | 15.8 s, 10/10, 95 % | 9.4 s, 0/10 | Fished from the Shallows (28 runs, `was_hit` arming only) | Real-kit + `needle-rain` (30 seeds): 16.08/16.12 s (89 arms, 48 sure crits, 54 Earth pins) |
| `hinh_lac_nhan` (TC) | 38.0 s, 10/10, 98 % | 8.9 s, 0/10 | Breath Held 0 (no poison foe / no sword slotted) | Real-kit + `flying-sword-strike` vs poison foe: **Breath Held 28.2/29.7 s (153 runs)** |
| `hong_van_tinh`, `ha_hau_thanh_bich` (TC) | 38.4 s, 10/10, 94 % | 9.6 s, 0/10 | `the-ninth-verse` 0 at gap 0 (never Wounded), **0.2 fires/fight at gap 1** | |
| `to_mo_van` (LK) | 47.5 s, 3/10, 9 % | — | wears seal only at LK | Synthetic TC kit with both pieces: **Glow After Dark 38.2 s (46 % HP) / 39.2 s (40 % HP), 141 runs (23 expiry hits)** |
| `evening-dust-primer` outer gate (LK) | 39.7–42.8 s, 1–2/10, 3–4 % | — | `dust-in-the-last-light` 12.1 fires, `millstone-palm` 3.8 fires | Matches Luyện Khí baseline (weak start intended) |
| servants on new breaths (LK) | 44.1–44.4 s, 0/10, 0 % | — | `ferry-breath` 7.9 fires, `hearth-ember-breath` 8.0 fires | Matches Băng Tâm / Thiên Xu servants |

**Synthetic kits for split / lost sets and unheld items (10 seeds each):**
- **Sunset Regalia (`The Sky Goes One Colour`):** Tô Vãn Chiếu wearing all 3 pieces vs sturdy foe (`n_body: 3.0`):
  **48.7 s with vs 49.8 s without (100 runs: 10 opens, 10 starts, 80 heals)**.
- **Lone Duck Ring (`The Treasury Key`):** Tô Vãn Chiếu wearing all 3 pieces at `--gap 1`: **23.1 s survival with vs
  20.2 s without (10 runs)**.
- **Twin Swords (`Lightning and Frost` + `The Lightning Sleeps` + `Frost on the Field`):** Tô Vãn Chiếu wearing both
  swords + `flying-sword-strike`: **Lightning and Frost 22.4 s vs 25.1 s (132 runs)**; **The Lightning Sleeps**
  356 sword counts / 78 half-strength forks (30 seeds); **Frost on the Field** 72 awake Ice grants.
- **Tử Điện on a Thunder root (`The Lightning Sleeps`):** Vưu Chước Kim wearing `lh-tu-dien`: **23.9 s vs 24.5 s
  (50 Lightning art counts, 10 full forks)**.
- **Empty Frost Scabbard + Thanh Sương (`Waits for Its Blade` + `Frost on the Field`):** Cảnh Trường Thiên wearing
  both + `flying-sword-strike`: **27.6 s with vs 33.1 s without (10 wakes, 68 awake Frost grants)**.

**The five lessons (all checked):**
- [x] Every Effect changes the fight on its holders (or real-kit/synthetic probe) or has a written reason; every staged
  art fires.
- [x] No holder overwrites a stance: `sunset-cloud` skips setting the stance when `state.any > 0` (`quach_tiep_van`'s
  `mountain-stance` is untouched), and the art defines `"sunset-cloud"`.
- [x] Each "your X" works for a holder who lacks X (`ward_grow` creates a stance ward; `field_up` works on Sunset
  Cloud).
- [x] Vague words are pinned in every `rule`: glow clock, fan art, needle volley, anchor hit, guard broken, burns green,
  fade twice as fast, locked in place, extends by 2 s.
- [x] New technique bonuses and passives are sized against their tier and marked new (§C).

---

## I. Open items (for the user or the serial step)

1. **Pending word (`pending.json`):** `technique-effects` (shared with Thiên Xu) to attach `The Glow Deepens` to
   `sunset-cloud-canon` at layer 3.
2. **Tool/brief gap for batch b01+ (`lint_techniques.py` `NOT_PRICED` on non-fight passives):** `lint_techniques.py`
   only downgrades `OVER_BUDGET` (not `NOT_PRICED`) to a note on unpriced `catalogue-sect-*` files, so b1's `dao_tam`
   and `breakthrough_chance` (and other owners' `can_cot`, `cultivation_speed_pct`, `herb_growth_pct`) fail the gate
   unless held out of `passives`. Later jobs (`thuy_vi`, `thinh_vu`, `van_hac`, `tuan_tung`) will hit the same check.
   Restoring b1's 6 held lines waits on `lint_techniques.py` accepting non-fight keys and the stat-sheet readers.
3. **Parked records (`postponed-2026-11-26.json`):** `long-sky-one-colour` (technique + 3 arts) and `Geese in File`
   (`lh-cold-geese-sword`) await multi-fighter combat.
4. **`export_named.py` skips `kind: treasure`:** carried over from Băng Tâm / Thiên Xu; covers 2 Lạc Hà treasures
   (`lh-tu-dien`, `lh-thanh-suong`).
5. **`sect_fight.py` slotting:** slots technique arts first (up to 6), so item common arts (`fan-gust`, `needle-rain`,
   `flying-sword-strike`, `anchor-drop`, `seal-slam`) never slot in `sect_fight`; real-kit probes above cover them.
6. **WIRED.md items for the user:** d11 Debt Stone (`mountain-heart-canon` + `lh-nails-of-dao-sa` 2-piece), d12 Written
   in the Ledger (`ruin-ledger-scripture`), and `sai_thanh_phong`'s aux `evening-song-of-the-boats`.
7. **Out-of-fight half:** `The Treasury Key`'s opening of Lạc Hà's treasury arrays at Vân Kiều Trấn (story / sect
   vault system).
8. **Gap report reads committed files only:** staged records remain `rule text` until the serial step merges them;
   `stand_ins` already reads 0.
