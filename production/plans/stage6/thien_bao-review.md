# Thiên Bảo Trai: Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/thien_bao/`; nothing exported, nothing outside `_brief-record.md`'s paths):**
- **4 techniques** (`techniques/catalogue-sect-thien_bao.json`): the 3 lineage methods (`heaven-treasure-refining-canon`, `appraisers-eye`, `warm-nurtured-treasure-sutra`), plus 1 new stand-in method (`brook-wash-breath` for the two hired Quan brook-washers). Every bonus and passive is new and sized within its tier's budget (§C, zero `OVER_BUDGET` notes).
- **8 new arts** (`arts/part-sect-thien_bao.json`): the 7 depth arts (`assay-the-ore`, `crucible-guard`, `hammer-price`, `name-the-flaw`, `third-price`, `the-treasure-answers`, `pawn-the-pearl`) plus 1 new stand-in art (`brook-rinse`). All 8 fire in `sect_fight.py thien_bao` at both same realm and `--gap 1`.
- **4 Effects** (`effects/thien_bao.effects.json`): 2 item Effects (`Sold`, `Grown, Not Made`) and 2 full-set Effects (`Going Once, Going Twice`, `Fights With What He Made`). All 4 validate in `engine.validate` and run in the combat engine.
- **6 items and 2 sets** (`items/catalogue-sect-thien_bao.json`, `items/sets-thien_bao.json`), with the depth modifiers preserved verbatim, `sources: ["npc"]`, `unique: true`, `rarity: 5` on the 2 treasures (`tb-land-riches-seal`, `tb-grown-red-pearl`), and the R6 `exception` on the 4 weapon/body_gear/ward_gear pieces (`tb-land-riches-seal`, `tb-furnace-apron`, `tb-red-gold-furnace-sword`, `tb-crucible-lid`).
- **2 stand-ins** replaced in `thien_bao.cast.json` and `thien_bao.5.cast.json`: `quan_tay_ngoc` (layer 3) and `quan_tay_lan` (layer 2) from `hoang_moc` to `brook-wash-breath`. Gap report `stand_ins` is now 0.
- **0 beasts** (`thien_bao` has no `thien_bao.beasts.json`). Art ids and `brook-wash-breath` were written into `thien_bao.techniques.json`.

**Checks:**
- `lint_arts`, `lint_techniques`, and `lint_items`: **0 findings** each (and 0 `OVER_BUDGET` notes).
- `engine.validate`: passes all 4 Effects (13 records).
- `depth_check.py`: `findings: none`.
- `spatial_words_check.py --sect thien_bao`: 0 hits in rule fields (1 non-rule hit in `khang_thien_chuy.ties.note`).
- `sect_fight.py thien_bao` (20 seeds, same realm and `--gap 1`, 0 `REFUSED`) plus real-kit probes (§H). **Every staged art fires** at both same realm and `--gap 1`.

**Counts:**
- **Deviations: 14** (§C–§F, numbered D1–D14).
- **Decisions taken for the user: 8** (§A).
- **Pending words: 0** (`pending.json` is empty; every mechanic runs with existing engine words).
- **Early promotions: none**, and no `foreign/` files (`thien_bao` references only `nine-temper-scripture` and `general-heaven-purchasing-coin`, both already in `design/`).

**Effects that showed 0 runs or no delta in a default `sect_fight` pass, each with its reason (and verified in probes, §H):**
- `Sold` at `--gap 1`: `phan_vat_hoa` wins 20/20 at gap 0 (`Sold` runs 20 times, 14.6 s vs 17.9 s), and against a typical Hóa Thần foe at `--gap 1` her 1st `hammer-price` fires before reaching 10 Metal stacks and she goes Down at 16.1 s before her 2nd. Verified against a sturdy same-realm foe (31 runs over 20 seeds).
- `Grown, Not Made` delta at gap 0: `phan_vat_hoa` wins 20/20 at 100 % HP without dropping to Down; at `--gap 1` it saves her on `down` (40 runs: 20 `mark`, 20 `save`).
- `Fights With What He Made` sword strike in default `sect_fight`: `sect_fight.py` slots 6 technique arts first, never `tb-red-gold-furnace-sword`'s common art `flying-sword-strike`, so `blocked` arms `furnace_hot` (458 runs at gap 0) without a `sword`-tagged art slotted. Real-kit probe replacing `whetstone-pass` with `flying-sword-strike`: **12.57 s with vs 14.97 s without** (139 sword runs at gap 0; 95 at gap 1).

**Open items** (for the user or the serial step; §I):
- `export_named.py` skips `kind: treasure` (affects `tb-land-riches-seal` and `tb-grown-red-pearl`, same carry-over as Băng Tâm / Lạc Hà / Thiên Xu).
- `artifact_attack_pct` (2 open modifier lines in `depth_gap.py`: `tb-red-gold-furnace-sword` 12 and `tb-xich-kim-furnace` 2-piece set 6): item-level is already read by `CombatPower.artifact_numbers`, while set-level `artifact_attack_pct` and `fight.py` / `depth_gap.py` recognition are open.
- `sect_fight.py` slots technique arts first (up to 6), so `flying-sword-strike` on `khang_thien_chuy` needs the real-kit probe (§H).
- Out-of-fight halves: `Grown, Not Made`'s unstealable/unsellable rule (world/inventory rule) and `Going Once, Going Twice`'s spirit-stone exemption (spirit stones are not in the fight sim).
- `phan_vat_hoa` has 18 ties (> 16 cap; trimmed at Stage 7 export, already marked `game 1` in `depth_gap.py`).

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **Stand-in technique for `quan_tay_ngoc` and `quan_tay_lan`: new `brook-wash-breath` (`moc, thuy`, Yellow main, `tap_dich`).**
   - Following the ruled stand-in order: Thiên Bảo's outer method is `nine-temper-scripture` (`kim`), and both Quan sisters explicitly have no Metal (`moc 44, thuy 34` and `moc 42, thuy 30`) and are hired `tap_dich` who wash refinings in the brooks of Khê Thanh Thôn (`thien_bao.md` §2, §6). Neither note names another method.
   - Created `brook-wash-breath` with `brook-rinse` (`water` heal, `c_heal 0.5, cost_share 0.03, cooldown 5`), matching Băng Tâm's `warm-hearth-breath`, Thiên Xu's `water-clock-breath`, and Lạc Hà's `evening-ferry-breath`. Registered in `thien_bao.techniques.json` and assigned in `thien_bao.cast.json` (layer 3) and `thien_bao.5.cast.json` (layer 2).

2. **`hammer-price` 10-stack artifact suppression modelled with `sundered` (4 s) + `silence` (`tag: "artifact"`, 3 s).**
   - No engine word disables an enemy's highest-grade item directly. `silence` with `tag: "artifact"` suppresses any `artifact`-tagged art the foe carries for 3 s, while `sundered` (-150 resistance for 4 s) strips the defensive protection of their artifact ward/armour so the suppression matters against enemies without `artifact`-tagged arts too. Uses existing engine words without adding a single-art engine word.

3. **`third-price` ("lowers its modifiers for the holder's next three hits") modelled as a 3-charge art-hit buff (`pen: 120`, `dmg_more: 0.25`).**
   - No engine action edits an opponent's item modifiers. Lowering an enemy's defensive/offensive artifact modifiers for 3 hits is expressed as a 3-charge counter (`third_price_hits = 3`) granting `pen: 120` + `dmg_more: 0.25` via `always` and spent on `hit_landed` (`kind: "art"` so basic attacks do not waste charges). `c_art` is `0.0` so all 3 charges apply to damaging arts.

4. **`the-treasure-answers` ("strikes with the grown treasure's grade") modelled as `L3 +35` and `dmg_more 0.15` scoped `tags: ["artifact"]`, plus `stack_dur +50` Metal debuff (6 s).**
   - `L3` is the gear/artifact layer in Combat Formulas B and is in `CTX_MODS`, so scoping `L3 +35` and `dmg_more +15 %` to `tags: ["artifact"]` raises artifact-tagged strikes directly, and `stack_dur +50` extends Metal debuffs for 6 s. Added the `"artifact"` tag to `assay-the-ore`, `crucible-guard`, `hammer-price`, `the-treasure-answers`, and `pawn-the-pearl` so canon strikes through artifacts benefit.

5. **`crucible-guard` lays 1 Earth + 1 Metal stack on counter-hits (`was_hit`) and uses a timed 6 s stance (`tags: ["composed"]`).**
   - Without an Earth debuff source in `thien_bao`'s kit, `assay-the-ore`'s "against a foe already carrying Earth stacks" clause could never trigger on a `thien_bao` holder. Having `crucible-guard`'s artifact retaliation (`c 0.45`, limit 2/pulse) lay 1 Earth + 1 Metal stack (8 s) activates both `assay-the-ore` and `heaven-treasure-refining-canon`'s `stack_effect_pct [tho, debuff]` passive, while feeding `hammer-price`'s 10-stack threshold.
   - Timed via counter `crucible_t` (6 s -> `state: {"set": null}`), no stance collisions in `thien_bao` (it is the only stance in the sect).

6. **`pawn-the-pearl` is an active ward art (`cooldown: 3`, guarded once until cracked), and `Grown, Not Made` sets `has_grown_pearl` so they coordinate cleanly.**
   - `pawn-the-pearl` is in `warm-nurtured-treasure-sutra`'s active `arts` list (not a passive art), so keeping it as an active ward art (`6 %` body shield + `+10 %` ward strength for 8 s + arms `refuse_down` at 15 % HP) allows all 7 depth arts to run today with zero `technique-effects` dependency.
   - Because `phan_vat_hoa` holds both `pawn-the-pearl` (art) and `tb-grown-red-pearl` (`Grown, Not Made`, item), `Grown, Not Made` sets `has_grown_pearl = 1` on `fight_start` so `pawn-the-pearl`'s `down` listener yields to `Grown, Not Made` on `phan_vat_hoa` while still saving `khang_thien_chuy` (who lacks the Pearl item).
   - Cracking is modelled as `ward_pct -10, L1 -10` on `pawn-the-pearl`, plus `ward_pct -10, L1 -10, stack_dur -24 [metal, buff]` on `Grown, Not Made`.

7. **`Sold` (`burn_qi 0.25 qi_max` + `ward_grow 0.25 hp`) and `Going Once, Going Twice` (`refusals = 1` cap respected, `seal_ward_protects`).**
   - `hammer-price` sets `hammer_big = 1` and `hammer_keep = floor(foe.debuff.metal / 3)` on `art_fired` before consuming Metal stacks (because art Effects execute before item/set Effects in `expand_library`). `Sold` reads `hammer_big >= 1` to drain 25 % of `foe.qi_max` (weakening their main drain ward) and grow a 25 % HP stance ward; `Going Once, Going Twice` reads `hammer_keep` to restore 1/3 Metal stacks on the foe.
   - For the Pearl clause ("while you still hold such a ward, the Pearl's saving of a killing blow is ready once more, spending that ward instead of cracking"): Effects rule 11 caps Down refusals at 1 per fight (`refusals: 1`). Rather than requesting a GDD rule change for one NPC set, `Going Once, Going Twice` intercepts `down` when `own.ward_share > 0` (`seal_ward_protects == 1`), saves at 15 % HP, and spends the stance ward (`ward_grow: {"share": -1.0, "of": "peak"}`) without setting `pearl_cracked = 1`.
   - For the Coin clause: tracks the 1st crit via `fate_flip_seen` (handled by `Bought Fate`) and flips a 2nd crit (`heal 0.4 of amount` + `ward_grow -0.04 hp`) while `own.ward_share > 0`.

8. **`Fights With What He Made`: "ignores 20 % of the target's defence" modelled as `pen: 95` (resistance points).**
   - Engine `pierce` only pierces realm suppression (`supp`), which is `0` against same-realm foes. On a typical Kết Đan foe (`~479` ward points), 20 % of defence is `~95` resistance points (`pen: 95`), which works at both gap 0 and gap 1.

---

## B. The mechanic table (step 1)

| Record | Mechanic | Engine |
|---|---|---|
| `heaven-treasure-refining-canon`, `assay-the-ore` | strike through artifact, Metal dmg + Metal stack; +1 if foe has Earth | has (`metal`, `phys`, `tags: ["metal", "artifact"]`, `debuff: [2, 8]`, `hit_landed` `foe.debuff.earth >= 1`) |
| `heaven-treasure-refining-canon`, `crucible-guard` | stance: artifacts strike back on hit taken, body shield from Earth | has (`states` `crucible-guard` tagged `composed`, `shield: {"body": 0.08}`, `buff: [2, 8]`, `was_hit` -> `free_hit` + Earth/Metal) |
| `heaven-treasure-refining-canon`, `hammer-price` | consumes all Metal stacks for heavy hit; at 10+ suppresses foe's highest-grade artifact | has + approx (`consume` Metal -> `mod dmg_more`; at 10+ sets `hammer_big`/`hammer_keep`, lays `sundered` 4 s + `silence [artifact]` 3 s) |
| `appraisers-eye`, `name-the-flaw` | marks foe: hits pierce ward and deal more damage | has (`mod`: `bypass 0.20`, `pen 50`, `dmg_more 0.12` for 5 s, + 1 Metal stack) |
| `appraisers-eye`, `third-price` | reveals strongest artifact, lowers modifiers for next 3 hits | has + approx (`third_price_hits = 3`, `always` `pen 120`, `dmg_more 0.25`, spent on art `hit_landed`) |
| `warm-nurtured-treasure-sutra`, `the-treasure-answers` | artifacts strike with grown treasure's grade, Metal stacks last longer | has (`mod`: `L3 +35`, `dmg_more 0.15` `[artifact]`, `stack_dur +50` Metal debuff, 6 s) |
| `warm-nurtured-treasure-sutra`, `pawn-the-pearl` | once a fight death blow taken by grown treasure, cracks & loses mods | has (`art_fired` arms `pearl_armed` + shield/ward; `down` `refuse_down 0.15`, `pearl_cracked = 1` -> `always` penalty) |
| `brook-wash-breath` (`brook-rinse`, new) | stand-in heal for `quan_tay_ngoc` and `quan_tay_lan` | has (`c_heal 0.5`, `water`, `cost_share 0.03`, `cooldown 5`) |
| `Sold` (`tb-land-riches-seal`) | Hammer Price 10+ Metal: foe loses 1/4 ward, you gain ward of that size | has + approx (`burn_qi 0.25 qi_max` + `ward_grow 0.25 hp` on `hammer_big >= 1`) |
| `Grown, Not Made` (`tb-grown-red-pearl`) | unstealable/unsellable; saves 1 killing blow then cracks | has (`down` `refuse_down 0.15`, `pearl_cracked = 1` -> `always` penalty; steal/sell out-of-fight) |
| `Going Once, Going Twice` (`tb-hammer-pearl-eye`, 3) | keep 1/3 Metal on Hammer Price 10+; Bought Fate 2nd flip from ward; ward saves Pearl | has + approx (`hammer_keep` stacks; 2nd crit `heal 0.4` + `ward_grow -0.04 hp`; `down` spends stance ward; `refusals = 1` cap) |
| `Fights With What He Made` (`tb-xich-kim-furnace`, 3) | block -> Sword's next strike +30 % dmg, ignores 20 % defence, +2 Metal | has + approx (`blocked` arms `furnace_hot`; `always` `dmg_more 0.30, pen 95` `[sword]`; `hit_landed` `[sword]` -> +2 Metal + reset) |

---

## C. Techniques (`techniques/catalogue-sect-thien_bao.json`; new bonuses and passives marked NEW, unpriced)

| Technique | Tier, kind | Bonuses | Passives | Arts (unlock) | Peer sized against |
|---|---|---|---|---|---|
| `heaven-treasure-refining-canon` | Earth main (tier 2), `kim, tho` | **NEW**: `khi_huyet_pct` 10, `defense_pct` 10 | **NEW**: `attack_pct` 6 `[kim]`, `stack_effect_pct` 12 `[kim, debuff]`, `stack_duration_pct` 14 `[kim, debuff]`, `stack_effect_pct` 10 `[tho, debuff]`, `attack_pct` 6 `[artifact]`, `body_shield_pct` 5, `linh_luc_regen_inc_pct` 6 | `assay-the-ore` (1), `crucible-guard` (2), `hammer-price` (4) | `jade-vessel-ice-heart-canon` (23.7 W of 24) |
| `appraisers-eye` | Profound secret (tier 1), `kim` | **NEW**: `than_thuc_pct` 10 | **NEW**: `crit_chance_pct` 5 `[kim]`, `crit_damage_pct` 18 `[kim]`, `pierce_pct` 6, `accuracy_pct` 6 | `name-the-flaw` (1), `third-price` (2) | `snow-plum-sword` / `hundred-blades-canon` (15.9 W of 16) |
| `warm-nurtured-treasure-sutra` | Earth secret (tier 2), `kim` | **NEW**: `khi_huyet_pct` 12, `linh_luc_pct` 12 | **NEW**: `attack_pct` 10 `[artifact]`, `art_speed_pct` 8 `[artifact]`, `stack_duration_pct` 15 `[kim, debuff]`, `ward_efficiency_pct` 6, `health_regen_inc_pct` 15 | `the-treasure-answers` (1), `pawn-the-pearl` (4) | `frost-lotus-array-canon` / `afterimage-sword-canon` (23.4 W of 24) |
| **`brook-wash-breath` (new)** | Yellow main (tier 0), `moc, thuy` | none | **NEW**: `health_regen_inc_pct` 8, `linh_luc_regen_inc_pct` 5, `status_resist_pct` 4 | `brook-rinse` (1) | `warm-hearth-breath` / `water-clock-breath` (8.0 W of 8) |

Deviations: none in technique structure (all 4 pass `lint_techniques.py` with 0 findings and 0 `OVER_BUDGET` notes).

---

## D. Arts (`arts/part-sect-thien_bao.json`), depth text beside engine form

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `assay-the-ore` | strike through holder's artifact, Metal damage + Metal stacks; +1 if foe carries Earth | Metal phys `c_art` 1.5, cost 0.03, cd 2.5, tags `metal, artifact, quick`, debuff `[2, 8]`; on `hit_landed` if `foe.debuff.earth >= 1`: +1 Metal (8 s) | **D1** lays 2 base Metal stacks (instead of 1) so holders reach `hammer-price`'s 10-stack threshold inside a ~14 s fight |
| `crucible-guard` | stance: for a few seconds artifacts strike back on hits taken; body shield from Earth | Earth phys `c_art` 0, cost 0.04, cd 8, tags `earth, metal, stance, ward, artifact`, buff `[2, 8]`, guard `state < 1`. Enters `crucible-guard` (`composed`, +12 block, +40 resist) 6 s + 8 % body shield; `was_hit` (2/pulse): `free_hit` 0.45 phys + 1 Earth + 1 Metal (8 s) | **D2** retaliation lays 1 Earth + 1 Metal stack so `assay-the-ore`'s Earth synergy fires in pure-lineage builds (§A 5) |
| `hammer-price` | spends all Metal stacks for heavy Metal hit; at 10+ suppresses foe's highest-grade artifact for a few seconds | Metal phys `c_art` 1.8, cost 0.06, cd 8, tags `metal, artifact, heavy`, guard `foe.debuff.metal >= 1`. Consumes Metal debuffs (`+14 % dmg_more` per stack); at 10+: sets `hammer_big = 1`, `hammer_keep = floor(stacks / 3)`, applies `sundered` (4 s) + `silence` (`tag: "artifact"`, 3 s) | **D3** artifact suppression modelled as `sundered` (4 s) + `silence [artifact]` (3 s) (§A 2); **D4** cd 8 s with `foe.debuff.metal >= 1` guard so stacks build to 10+ before spending |
| `name-the-flaw` | marks foe for a few seconds: hits pierce part of ward and deal more damage | Metal phys `c_art` 1.4, cost 0.03, cd 5, tags `metal, curse`, debuff `[1, 8]`; `art_fired`: `bypass 0.20, pen 50, dmg_more 0.12` for 5 s | **D5** adds 1 Metal stack (8 s) and `pen 50` alongside `bypass 0.20` and `dmg_more 0.12` |
| `third-price` | reveals foe's strongest equipped artifact and lowers its modifiers for next 3 hits | Metal phys `c_art` 0, cost 0.03, cd 6, tags `metal`; sets `third_price_hits = 3`; `always` while `>= 1`: `pen 120, dmg_more 0.25`; art `hit_landed` spends 1 | **D6** lowering the foe's artifact modifiers is modelled as `pen 120, dmg_more 0.25` for the next 3 art hits (§A 3) |
| `the-treasure-answers` | for a few seconds every artifact strikes with grown treasure's grade, Metal stacks last longer | Metal phys `c_art` 0, cost 0.03, cd 8, tags `metal, artifact`; `art_fired`: `L3 +35, dmg_more 0.15` `[artifact]` + `stack_dur +50` Metal debuff for 6 s | **D7** grown treasure's grade is `L3 +35` + `dmg_more 0.15` on `artifact`-tagged arts (§A 4) |
| `pawn-the-pearl` | once a fight death blow taken by grown treasure instead; cracks and loses modifiers for rest of fight | Metal phys `c_art` 0, cost 0.03, cd 3, tags `metal, ward, artifact`, guard `pearl_armed == 0` & `pearl_cracked == 0`; `art_fired` arms `pearl_armed = 1`, +6 % body shield, +10 % ward (8 s); `down` (if `has_grown_pearl == 0` and `seal_ward_protects == 0`): `refuse_down 0.15`, `pearl_cracked = 1` (`ward_pct -10, L1 -10`) | **D8** active ward art giving an active shield/ward buffer on cast and yielding to `Grown, Not Made` when the Pearl item is worn (§A 6) |
| `brook-rinse` (new) | n/a (stand-in) | Water elem heal `c_heal` 0.5, cost 0.03, cd 5, tags `heal` | new stand-in art |

---

## E. Effects (`effects/thien_bao.effects.json`), depth text beside engine form

| Effect (piece) | Engine form | Deviation |
|---|---|---|
| `Sold` (`tb-land-riches-seal`) | `art_fired` on `hammer-price` with `hammer_big >= 1`: `burn_qi 0.25 of qi_max` + `ward_grow 0.25 of hp` | **D9** "foe's ward loses a quarter of what it holds" is `burn_qi 0.25 of qi_max` (drains main drain ward's linh lực pool) and gained ward is a 25 % HP stance ward |
| `Grown, Not Made` (`tb-grown-red-pearl`) | `fight_start` sets `has_grown_pearl = 1`; `down` (when `pearl_cracked == 0` & `seal_ward_protects == 0`): `refuse_down 0.15`, `pearl_cracked = 1`; `always` while cracked: `ward_pct -10, L1 -10, stack_dur -24 [metal, buff]` | **D10** "cannot be stolen or sold" is out-of-fight; mid-fight modifier loss approximates static `khi_huyet_pct`/`stack_effect_pct` via `ward_pct -10, L1 -10, stack_dur -24 [metal, buff]` |
| `Going Once, Going Twice` (`tb-hammer-pearl-eye`, 3) | `art_fired` (`hammer-price`, `hammer_big >= 1`): lays `hammer_keep` Metal stacks; `pulse` syncs `seal_ward_protects` to `own.ward_share > 0`; `was_hit` 2nd crit while `ward_share > 0`: `heal 0.4 of amount` + `ward_grow -0.04 hp`; `down` while `ward_share > 0`: `refuse_down 0.15` + `ward_grow -1.0 peak` | **D11** respects Effects rule 11's `refusals = 1` cap (spends Seal ward instead of cracking Pearl rather than adding a 2nd Down refusal); spirit stones not modelled (§A 7) |
| `Fights With What He Made` (`tb-xich-kim-furnace`, 3) | `blocked` sets `furnace_hot = 1`; `always` while `>= 1`: `dmg_more 0.30, pen 95` `[sword]`; `hit_landed` `[sword]` while `>= 1`: +2 Metal (8 s) and resets `furnace_hot = 0` | **D12** "ignores 20 % of the target's defence" is `pen 95` (~20 % of Kết Đan typical ~479 ward points) rather than realm-suppression `pierce` (§A 8) |

---

## F. Items and sets (`items/catalogue-sect-thien_bao.json`, `items/sets-thien_bao.json`)

- **6 items, 2 sets**, with the depth modifiers preserved verbatim (`artifact_attack_pct` kept on `tb-red-gold-furnace-sword` and `tb-xich-kim-furnace`).
- **D13.** The 2 treasures (`tb-land-riches-seal`, `tb-grown-red-pearl`) use `"rarity": 5` (`grade + 1`, replacing `grade: 4`) per `lint_items.py` schema. All 6 items carry `sources: ["npc"]` and `unique: true`; 4 weapon/body_gear/ward_gear pieces (`tb-land-riches-seal`, `tb-furnace-apron`, `tb-red-gold-furnace-sword`, `tb-crucible-lid`) carry the R6 `exception`. Proposal `"status"` fields are dropped.
- **D14.** Set `tb-hammer-pearl-eye` and `tb-xich-kim-furnace` split the depth string into `"effect"` (plain name + Hán-Việt) and `"rule"` (rule text), matching `sets-bang_tam.json`.

---

## G. Stand-ins (applied in `thien_bao.cast.json` and `thien_bao.5.cast.json`)

| Person | Rank, realm | Root | Was | Now (layer kept) |
|---|---|---|---|---|
| `quan_tay_ngoc` | tạp dịch, LK | Wood 44, Water 34 | `hoang_moc` 3 | `brook-wash-breath` 3 (new) |
| `quan_tay_lan` | tạp dịch, LK | Wood 42, Water 30 | `hoang_moc` 2 | `brook-wash-breath` 2 (new) |

---

## H. The holder table (`sect_fight.py thien_bao`, 20 seeds, typical same-realm foe & `--gap 1`; probes)

**Every staged art fires.** All 8 staged arts fire at both same realm and `--gap 1`. Zero holders refused.

| Holder (realm) | Same-realm result | `--gap 1` result | Effects: with / without (runs) | Probe / Note |
|---|---|---|---|---|
| `phan_vat_hoa` (NA) | 14.6 s, 20/20, 100 % | 16.1 s, 0/20 | `Bought Fate` 14.6/14.6 s (20; gap 1: 16.1/15.9 s, 19); **`Sold` 14.6/17.9 s (20; gap 1: 0)**; `Grown, Not Made` 14.6/14.6 s (20; **gap 1: 40 runs, saves on `down`**); **`Going Once, Going Twice` 14.6/15.2 s (324; gap 1: 340)** | vs sturdy+crit foe (`n_body 3.0`, crit 0.35, 20 seeds): 19.18 s, 20/20 wins, **`Sold` 31, `keep` 31, `fate` (2nd flip) 16, `ward_check` 116** |
| `khang_thien_chuy` (KĐ) | 13.5 s, 20/20, 100 % | 13.2 s, 0/20 | `Fights With What He Made` 13.5/13.5 s (458 block runs; gap 1: 445) | Real-kit probe (+`flying-sword-strike` for `whetstone-pass`): **gap 0: 12.57 s with vs 14.97 s without (139 sword runs)**; **gap 1: `pawn-pearl-save` 13.05 s with vs 11.00 s without (20 runs)** |
| `tien_ngu_phan` (TC) | 16.2 s, 20/20, 85 % | 8.2 s, 0/20 | n/a | all 5 arts fire at gap 0 and gap 1 (`hammer-price` 0.6 at gap 1) |
| `ho_tam_ky` (TC) | 12.4 s, 20/20, 74 % | 8.0 s, 0/20 | n/a | all 6 arts fire at gap 0 and gap 1 (`hammer-price` 0.2 at gap 1) |
| `thuong_toi_kim` (TC) | 12.4 s, 20/20, 74 % | 8.0 s, 0/20 | n/a | all 6 arts fire at gap 0 and gap 1 (`hammer-price` 0.2 at gap 1) |
| `phong_tu_gia` (TC) | 19.5 s, 20/20, 84 % | 8.2 s, 0/20 | n/a | all 4 arts fire at gap 0 and gap 1 |
| `an_toan_chau`, `vien_hong_kim` (TC) | 30.2–30.3 s, 20/20, 79–80 % | 8.7 s, 0/20 | n/a | `assay-the-ore` and `crucible-guard` fire at both |
| `nguy_minh_giam`, `ta_thuc_bao` (LK) | 12.9–13.0 s, 20/20, 58 % | 8.0 s, 0/20 | n/a | all 5 arts (`nine-temper` + `appraisers-eye`) fire at both |
| `quan_tay_ngoc`, `quan_tay_lan` (LK) | 44.1 s, 0/20, 0 % | 8.0 s, 0/20 | n/a | `brook-rinse` 7.9 fires; matches Băng Tâm / Thiên Xu / Lạc Hà servants |

**The five lessons (all checked):**
- [x] Every Effect changes the fight on its holders or real-kit probes, with written reasons for gap-1 / slotting zeroes; all 8 arts fire.
- [x] No holder slots two stances; `crucible-guard` defines `"crucible-guard"` and is the sect's only stance.
- [x] Each "your X" works for every holder (`has_grown_pearl` separates `pawn-the-pearl` on `khang_thien_chuy` from `Grown, Not Made` on `phan_vat_hoa`; `own.ward_share > 0` gates `Going Once, Going Twice`).
- [x] Vague words are pinned in every `rule` and `approx` (10-stack artifact suppression, Third Price's 3 art hits, grown treasure's grade, Sold's ward drain, Fights With What He Made's resistance penetration).
- [x] All new technique bonuses and passives are sized within their tier budgets (`23.7 / 24`, `15.9 / 16`, `23.4 / 24`, `8.0 / 8`) and marked new in §C.

---

## I. Open items (for the user or the serial step)

1. **`export_named.py` skips `kind: treasure`:** affects `tb-land-riches-seal` and `tb-grown-red-pearl` (same carry-over as Băng Tâm / Lạc Hà / Thiên Xu).
2. **`artifact_attack_pct` (2 open lines in `depth_gap.py`):** kept verbatim on `tb-red-gold-furnace-sword` (12) and `tb-xich-kim-furnace` 2-piece set (6). Item-level is already read by `CombatPower.artifact_numbers`; set-level handling and `fight.py` / `depth_gap.py` recognition are open.
3. **`sect_fight.py` slotting:** slots up to 6 technique arts first, so `flying-sword-strike` on `khang_thien_chuy` was verified via the real-kit probe (§H).
4. **Out-of-fight / non-sim halves:** `Grown, Not Made`'s cannot-be-stolen/sold property (inventory/world rule), `Going Once, Going Twice`'s carried spirit-stone exemption (stones are not in the fight sim), and `Going Once, Going Twice`'s 2nd Down refusal bounded by Effects rule 11's `refusals = 1` cap.
5. **Tie cap:** `phan_vat_hoa` has 18 ties (> 16 cap; trimmed at Stage 7 export, already `game 1` in `depth_gap.py`).
