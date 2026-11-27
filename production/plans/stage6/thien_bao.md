# Stage 6: Thiên Bảo Trai (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method" (user-approved 2026-11-26), and `production/plans/stage6/_brief-record.md` (`OWNER = thien_bao`).
Standing rule (2026-11-26): decisions are auto-accepted; take the recommended option thought through against the design rules, and log each one with its reason in `production/plans/stage6/thien_bao-review.md`.

## Scope (`python -I tools/design/world/depth_gap.py --sect thien_bao`)
- 3 proposal techniques (`heaven-treasure-refining-canon`, `appraisers-eye`, `warm-nurtured-treasure-sutra`), plus 1 new stand-in method (`brook-wash-breath` for the two hired Quan brook-washers).
- 7 depth new arts + 1 new stand-in art (`brook-rinse`).
- 6 items (`tb-land-riches-seal`, `tb-grown-red-pearl`, `tb-furnace-apron`, `tb-third-price-mirror`, `tb-red-gold-furnace-sword`, `tb-crucible-lid`), 2 sets (`tb-hammer-pearl-eye`, `tb-xich-kim-furnace`).
- 4 Effects (`Sold`, `Grown, Not Made`, `Going Once, Going Twice`, `Fights With What He Made`).
- 0 beasts, 4 events (already structured in `thien_bao.events.json`).
- 2 stand-ins (`quan_tay_ngoc`, `quan_tay_lan`, both `hoang_moc` tạp dịch).
- 1 person over the 16-tie cap (`phan_vat_hoa`, 18 ties; trimmed at Stage 7 export).
- 2 open modifier lines (`artifact_attack_pct` on `tb-red-gold-furnace-sword` and `tb-xich-kim-furnace` 2-piece set; item-local reading already lives in `CombatPower.artifact_numbers`, not yet in `fight.py` / `depth_gap.py`).
- `spatial_words_check.py --sect thien_bao`: 1 non-rule hit only (`khang_thien_chuy.ties.note` "flag-poles").

## Steps
- [x] 1. Verify first: mechanic table built; `spatial_words_check.py` checked (0 rule hits).
- [x] 2. Techniques and arts (staged in `design/stage6-staging/thien_bao/`).
- [x] 3. Effects (staged in `design/stage6-staging/thien_bao/effects/thien_bao.effects.json`).
- [x] 4. Items and sets (staged in `design/stage6-staging/thien_bao/items/`).
- [x] 5. Stand-ins (`quan_tay_ngoc`, `quan_tay_lan` -> `brook-wash-breath`) and depth file art ids.
- [x] 6. Beasts: none (`thien_bao` has no beasts).
- [x] 7. Holder check (`lint_techniques.py`, `lint_arts.py`, `lint_items.py`, `sect_fight.py thien_bao` and `--gap 1`, real-kit probes): 0 findings across all linters, 0 REFUSED, all 8 arts fire, all 4 Effects verified.
- [x] 8. Review file (`production/plans/stage6/thien_bao-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` and `production/plans/stage6/thien_bao.done`).

RECORD PASS DONE

## Step 1 result: the mechanic table

| Record | Mechanic | Engine |
|---|---|---|
| `heaven-treasure-refining-canon`, `assay-the-ore` | strike through artifact, Metal damage + Metal stack; +1 Metal if foe carries Earth | has (`element: "metal"`, `kind: "phys"`, `tags: ["metal", "artifact"]`, `debuff: [1, 8]`, `hit_landed` `foe.debuff.earth >= 1` -> +1 Metal) |
| `heaven-treasure-refining-canon`, `crucible-guard` | stance: artifacts strike back on hit taken, body shield from Earth | has (`states` `crucible-guard` tagged `composed`, `shield: {"body": 0.08}`, `buff: [2, 8]`, `was_hit` -> `free_hit` + 1 Earth debuff) |
| `heaven-treasure-refining-canon`, `hammer-price` | consumes all Metal stacks for heavy hit; at 10+ suppresses foe's highest-grade artifact | has + approx (`consume` Metal -> `mod dmg_more`; at 10+ sets `hammer_big` / `hammer_keep`, lays `sundered` 4 s + `silence` `[artifact]` 3 s) |
| `appraisers-eye`, `name-the-flaw` | marks foe: hits pierce ward and deal more damage | has (`mod`: `bypass 0.20`, `pen 50`, `dmg_more 0.12` for 5 s) |
| `appraisers-eye`, `third-price` | reveals strongest artifact, lowers its modifiers for next 3 hits | has + approx (`counter` `third_price_hits = 3`; `always` `pen 120`, `dmg_more 0.25`; decremented on art `hit_landed`) |
| `warm-nurtured-treasure-sutra`, `the-treasure-answers` | artifacts strike with grown treasure's grade, Metal stacks last longer | has (`mod`: `L3 +35`, `dmg_more 0.15` scoped `artifact`, `stack_dur +50` Metal debuff, for 6 s) |
| `warm-nurtured-treasure-sutra`, `pawn-the-pearl` | once a fight, death blow taken by grown treasure instead, then cracks and loses modifiers | has (`art_fired` arms `pearl_armed` + small ward/shield; `down` `refuse_down` 15 % HP, sets `pearl_cracked = 1` -> `always` penalty) |
| `brook-wash-breath` (`brook-rinse`, new) | stand-in heal for `quan_tay_ngoc` and `quan_tay_lan` | has (`c_heal 0.5`, `water`, `cost_share 0.03`, `cooldown 5`) |
| `Sold` (`tb-land-riches-seal`) | when Hammer Price spends 10+ Metal, foe loses quarter of ward, you gain ward of that size | has (`hammer_big >= 1` -> `burn_qi` 0.25 `qi_max` + `ward_grow` 0.25 `hp`) |
| `Grown, Not Made` (`tb-grown-red-pearl`) | cannot be stolen/sold; once a fight saves killing blow, cracks and loses modifiers | has (`down` `refuse_down` 15 % HP when not `seal_ward_protects`, sets `pearl_cracked = 1` -> `always` penalty; steal/sell out-of-fight) |
| `Going Once, Going Twice` (`tb-hammer-pearl-eye`, 3) | keep 1/3 Metal on Hammer Price 10+; Bought Fate flips twice paid from Seal ward; while ward holds, Pearl saves spending ward not cracking | has + approx (restores `hammer_keep` Metal stacks; 2nd crit `heal 0.4` + `ward_grow -0.04 hp`; `down` spends stance ward via `ward_grow -1.0 peak` instead of cracking; `refusals = 1` cap noted) |
| `Fights With What He Made` (`tb-xich-kim-furnace`, 3) | block -> Sword's next strike +30 % dmg, ignores 20 % defence, +2 Metal stacks | has + approx (`blocked` arms `furnace_hot`; `always` `dmg_more 0.30, pen 95` scoped `sword`; `hit_landed` `sword` -> +2 Metal + reset) |
