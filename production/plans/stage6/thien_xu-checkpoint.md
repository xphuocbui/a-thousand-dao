# Thiên Xu Tông: Stage 6 checkpoint review (2026-11-27, headless, decisions auto-accepted)

## What this review read
I did not take the record pass's review file on trust. This review read:
- **All the staged files.** I read every record in the arts, Effects, techniques and `pending.json` files. Items and
  sets I checked against the depth text with a script (ids, modifiers, base, grade, kind, set and Effect names, and
  set pieces and bonuses). Only D38 (the tally's base, `phu`) and D39 (the zither's `song` scope, now `artifact`)
  differ, as logged.
  - D39 stands: String Cut, the zither's common art, is tagged `artifact` and `music`, not `song`.
  - D40 (rarity) and D41 (dropped fields) are field additions and drops.
- **The depth text:**
  - `thien_xu.techniques.json` and `thien_xu.items.json`;
  - from the cast, the eight stand-ins and d8's six holders: root, rank, realm and build;
  - d8 in `builds/authored/auth-eff-1.json` and `wishlist.md`.
- **The rulings:** `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, the record brief's design rules,
  `_brief-serial.md`, and `FIGHT-INPUT.md` (Stage 6, the traps, and the vocabulary).
- **The engine source,** which gave these facts:
  - Effects run in list order within an event.
  - `hit_landed` fires before `crit`, and the Broken crossing is checked before `hit_landed`.
  - A `mod` with no `for` on an event lasts 1 ms (the firing's own hits).
  - `tags` and `not_tags` filters match any of the tags listed.
  - `art_fired` comes before an art's hits, and is raised for arts only.
  - **An evade writes `t_act`**, so `since_act` and Composed count an evade as an act. That is the user's Composed
    ruling of 2026-11-26.
  - GDScript `CombatConstants.ELEMENTS` has Water and Light.
- **The runs:**
  - `sect_fight.py thien_xu`, every holder, 5 seeds, at the same realm and at `--gap 1`;
  - 40 seeds on the Primer holders;
  - in-memory kits through `sect_fight.run`, with per-record run counts.

## Findings, most severe first

| # | File | Record | What was wrong | Fix applied | Rank |
|---|---|---|---|---|---|
| 1 | `effects/thien_xu.effects.json` | The Called Blow (`eff:The Called Blow wait halved`) | `called_half` was set when a called blow broke a ward and never cleared. One broken ward halved every later wait for the rest of the fight, but the rule says "the wait for the next". | The halved-wait record clears `called_half` when it arms the blow. The rule says "(that one only)". Correct by reading only: no fight in the probes broke a ward, so the halved path never ran (Đỗ Tinh Hà's spear kit: wait 0.7 a fight, break 0). | MUST-FIX |
| 2 | `arts/part-sect-thien_xu.json` | counterweight-palm | The `pan` memory was never cleared, and the palm's own firing was excluded. So "your last art was Earth or Metal" really meant "you have fired some other Earth art or any Metal art this fight". Palm-only holders never laid Metal and never reached the level clause: thac_bat_lu, lien_thanh_de, bo_tra_nhi, and the stand-ins huong_nghien_thach and vu_tinh_giai, 0 wins in 5. A kit with an art of another element kept the Metal forever. | At the palm's `art_fired`, the previous art is read into a new counter `pan_hit`. Then every art clears `pan`, and an Earth or Metal art sets it again (in list order). The hit records read `pan_hit`, and the rule pins "the art you fired just before it; this palm counts". Results: palm only, 5 wins in 40 (was 0 in 5), with Metal laid on 13.0 of 14.2 firings. Palm with Sinking Weight, 14 in 40, the same as before within noise. | MUST-FIX |
| 3 | `arts/part-sect-thien_xu.json` | the-pivot-does-not-turn | `pivot_half` was never cleared, and `pivot-turned-back` checked only `pivot_half`. After the stance had ended, each later movement art laid the old half of the Weights again for free. | A last record, `pivot-turned-done`, clears `pivot_half` on every movement art. **Correct by reading.** The probe (the head's Pivot kit plus Băng Tâm's movement art hidden-fragrance) shows the clause runs (turned-back 5.9 a fight, turned-clear 10.1). But the stance was always up when a movement art fired (done = clear = 10.1), so the stance-down path was never exercised. | MUST-FIX |
| 4 | `effects/thien_xu.effects.json` | Words Before Needles (`drop`) | The drop read `own.since_act < 1`, and an evade writes that clock. So the evade that loaded a needle dropped it on the next pulse, and an envoy who only evades never kept a needle. | A flag counter `needle_strike` is set on `art_fired` when the art is a damaging or movement art (`since_act ≤ 0`). The drop reads the flag, and the flag is cleared each pulse. The rule says "an evade alone is not a strike". Probe (Mâu Tri Viễn): load 9.8, drop 5.0 and throw 2.4 a fight. | MUST-FIX |
| 5 | `arts/part-sect-thien_xu.json` | weigh-the-heart | It read 7 element piles. The engine (both engines) also has Water and Light debuff piles, and the depth text says "every stack the foe carries of any element". | Added `weigh-water` and `weigh-light` (+3 % each, judgement scope inside the mod). The rule lists all nine piles. | SHOULD |
| 6 | `effects/thien_xu.effects.json` | The Called Thrust | An unlogged deviation. It counts and spends every Earth stack on the foe, including the Pivot's Weights, not only the stacks the waiting laid. Because the spend comes as the thrust fires, before it strikes (the depth text: "spends them all, and if it spends 5 or more it breaks the foe's ward entirely before it strikes"), the Pivot's Metal bonus per Earth stack reads 0 on the thrust's own hit. | Pinned both in `rule` and `approx`. The engine cannot tell where a stack came from. The timing is the depth text's, so it is kept. (I moved the spend to `hit_landed` for a while during this review, then reverted it as unfaithful.) | SHOULD |
| 7 | Effects `_doc`, The Called Blow, The Called Thrust; arts: the-seventh-star-falls, the-handle-points-east | "strike nothing (no damaging or movement art)" | These texts read the Composed clock, which an evade also resets (Combat rule 25; the rulings of 2026-11-25 group 9 and 2026-11-26), but they did not say so. | Pinned "and no evade (the Composed clock)" in each. The records are unchanged: they follow the ruling. | SHOULD |
| 8 | `pending.json` | The Banner Is Raised | Its record (`el: dark`) sat under `effects`, which the serial step moves into the staged files before it deletes `pending.json`. A word decided `not_run` was protected only by prose, and the record would have been lost with the file. | Removed from `pending.json`. The record is kept at the end of this file, and the staged `not_run` note points here. `effects` now holds Sentence Stands only. | SHOULD |
| 9 | the record review (§H, §I 2) and `thien_xu.done` | holder table and never-ran list | Both are stale. The `fight.py` Light purity fix a39bf4e1 closed that open item, so Hình Thủ Tinh and Thịnh Hàm Quang now run. | **Not applied:** those files are outside this job's write set. The table below is current. Open item. | SHOULD |
| 10 | arts the-handle-points-east; Effects Words Before Needles | "a damaging art" read as `since_act ≤ 0` at `art_fired` | A ward or heal fired in the same instant as an evade or another strike reads as damaging. Measured on long_thu_chuan: 21.1 "damaging" firings against 20.9 real ones, so 0.2 lost counts a fight from his Stele arts. (sai_thiet_dien's 3.1 losses are Mountain Root Stance, `c_art` 1.0, a real damaging art.) No existing filter tells a damaging art from the rest. | Pinned in both rules. Not rebuilt. | NIT |
| 11 | `design/world/depth/sects/thien_xu.techniques.json` | The Pole Draws (d8) | The depth file said `unlock_layer` 7, but the staged technique has 4. That was the record pass's decision §A2, confirmed from the cast: d8's holders hold the Pivot at layers 10, 9, 6, 6, 5 and 4, so layer 4 reaches all six and layer 7 only two. | Depth set to 4, a one-number edit. | NIT |
| 12 | `pending.json`, Effects | A Fair Copy | Its pending record would have been swapped in, but its word is now decided `not_run`. | Pending record removed. The note that the curse half is not run is in `approx`. | NIT |

**Choice logged (the brief's "mark the Effect not_run"):** A Fair Copy is **not** marked `not_run` as a whole. Its
soul half runs on an existing word (`soul_reflect`), and only the curse half is unbuilt. Marking the whole Effect
`not_run` would throw away a working half. The `approx` says which half does not run.

### Checked and kept
- **The other Effects.** I read every record. Where noted, I also counted per-record runs per fight on real or
  in-memory kits, 10 seeds each:
  - Sealed Writ;
  - Seven Lamps Turn: in the head's real kit the 7th lamp never comes (4.0 lamps a fight). In a Stele kit (Pivot,
    Writ, Weigh, Plant the Stele, No Crossing, Stone Warden) it turns **2.8 times a fight**;
  - Weighed: **74 % against 55 % health left** on Phương Trực Ngôn;
  - Beat to Quarters and The Weakest File;
  - Envoys Are Not Struck: its halving runs 0.6 a fight, since he often strikes first;
  - The Ink Remembers: 12 writings a fight;
  - True to the Line;
  - Seal and Weight in One Hand: the head with all three Regalia pieces judges **0.4 times a fight**, and ends at 58 %
    health. The "own ward half" penalty holds;
  - The Army That Waits: Ngũ Trấn Bắc with banner and tally added: the riders join **1.0 a fight** and their first hit
    lands **1.0 a fight**;
  - Sentence Stands: read only, as an `always` record;
  - The Door Stays Shut: latched 3.0 a fight, hold 10.0;
  - True Line: in Công Tôn Đoan's kit with his sword's Flying Sword Strike, the row runs 17.4 a fight and the free
    blade 2.0. In sect_fight's kit it never runs, because the kit has no sword art;
  - Before the Sun: read, plus sect_fight's with and without.
- **The Called Thrust on Đỗ Tinh Hà's spear kit** (after the revert): thrust 5.0 a fight, break 1.0, Called Blow 0.7.
- **Momentum against the 2026-11-25 ruling** (group 8: "10 momentum" is among the caps removed; a runaway piece gets
  a decay or cost instead). Momentum has no cap: it decays 5 % a second and costs upkeep past the fifth second. "Full
  Momentum" (10 or more) is only the threshold for the break (D16). That fits the ruling.
- **No stances.** No staged art sets a stance. The Pivot is a counter.
- **Every `always` record scopes inside its mod.** No counter is armed and spent on the same sub-hit: Before the Sun's
  sure crit is read inside the hit, and `dawn` is spent on its `hit_landed`.
- **The Handle Points East.** The handle points 1.0 a fight on pure-Metal Trúc Cơ kits (8-11 stars).
- **The Dipper's recovery.** It counts again after 3 s without acting. The depth text's "Composed for three seconds"
  is 5 s; this is the record pass's logged retune (§A3, D7, measured), so I kept it.
- **Spatial and environment words.** None in any staged record.
- **Scale without caps.** Momentum, Weights, needles and the Stele's cost are uncapped, each bounded by decay, upkeep,
  timers or cost. Full Momentum (10) is a threshold, not a cap (ruling 2026-11-25, group 8).
- **Stand-ins.** Every pick fits its person's root and follows the order:
  - dong_to_huong (Earth 38, Water 24), huong_nghien_thach (Earth 36, Wood 30), hang_that_ket (Earth 40, Fire 26),
    phan_boi_son (Earth 34, Fire 30) and vu_tinh_giai (Fire 40, Earth 36) are all servants (`tap_dich`). They take the
    lineage's lowest method, the Weighing-Stone Primer (Metal and Earth). Its own text admits a one-element root.
  - ha_khac_thuy (Water 44, Wood 26), o_tieu_dan (Wood 52, Water 30) and dieu_duong_hac (Wood 46, Water 24) have no
    Metal or Earth, and no lineage method fits them. They take the new owner technique Water-Clock Breathing (Water
    and Wood).
  - None of the eight has a note naming a method.
- **Techniques.** The new bonuses and passives are marked as new and sized in the record review (§C). The OVER_BUDGET
  lines are notes, since the files are unpriced.

## Decisions on the pending words (recorded in `pending.json`)

| Word | Decision | Reason |
|---|---|---|
| technique-effects | **build** | Passive arts are written in about 20 owners' technique files (chan_kim, coc_vu, lac_ha, thuy_vi, vu_an and others). No existing word attaches a technique's Effect by layer: `passives` carry plain stat lines only. The Pole Draws keeps its record in the Effects file. |
| darkness-element | **not_run** | A whole new element (piles, readables, scope, and a stack effect the user must rule on) for one Effect on a lost item with no holder. The Banner Is Raised stays `not_run`, and its record is kept at the end of this file. thu_phan, hong_dau and nam_pho also name Darkness, so build it in a pass that has a holder, after the ruling. |
| curse-fast | **build** | It has a real holder: Phương Trực Ngôn, the Nguyên Anh Chief Judge, whose build is seal-and-curse and who wears the Bridge Court Pair. It is half of that set's bonus as written. It is small: the curse-status twin of `talisman_fast`, one flag in each engine's cleanse path. No existing word holds a curse status through a cleanse. Other owners' "cannot be cleansed" texts are talisman stacks (already `talisman_fast`) or a self-poison, so this rests on Sentence Stands alone. |
| curse-reflect | **not_run** | It would be new redirect code in both engines' status handling for half of one Effect, on a Trúc Cơ copyist who does not fight. No other owner asks for it. No existing word fits either: no event is raised on the side a curse lands on (`status_applied` goes to the caster), and `move_own_debuffs` moves every batch, not the one curse. A Fair Copy's soul half keeps running. |

## Holder table after the fixes

Same realm, typical foe, 5 seeds unless noted. With and without each Effect, from `sect_fight.py`.

| Holder (realm) | Result | Effects: with / without (runs) | Note |
|---|---|---|---|
| doan_ngoc_hanh (NA) | 20.5 s, 5 of 5, 70 % | Sealed Writ 70 / 72 % (25); Seven Lamps 70 / 70 % (20) | the 7th lamp comes late in short fights; it shows in his real kit (record review §H) |
| do_tinh_ha (NA) | 30.0 s, 5 of 5, 91 % | Called Thrust 30.0 / 32.4 s (89); Called Blow 4 runs | sect_fight slots no spear. Spear kit (Seventh Star, Coiling Thrust): 31.8 s, 10 of 10, 89 %; thrust 5.1 a fight, Called Thrust break 1.0, Called Blow 0.7 |
| phuong_truc_ngon (NA) | 28.3 s, 5 of 5, 74 % | **Weighed 74 % / 55 %** (63); Sentence Stands 0 counted | an `always` record; its cleanse half waits for curse-fast |
| ngu_tran_bac (NA) | 43.1 s, 5 of 5, 67 % | Beat to Quarters 43.1 / 41.8 s (19); Weakest File 43.1 / 44.3 s (19) | full Momentum 0.1 a fight: the Pivot arts in his kit break the wait |
| mau_tri_vien (KĐ) | 30.3 s, 5 of 5, 62 % | Envoys (296); Words Before Needles 62 / 63 % (330); **Know the Way Out 0** | he slots no escape art (open item 1) |
| su_ngung_mac (KĐ) | 26.5 s, 5 of 5, 72 % | Ink Remembers 26.5 / 27.1 s (60); **Door Stays Shut 72 % / 64 %** (228) | |
| cong_ton_duan (KĐ) | 36.6 s, 5 of 5, 66 % | True Line (155, the break record only) | with Flying Sword Strike: 23.0 s, 10 of 10, 78 %, free blade 2.0 a fight |
| thien_thua_cu (KĐ) | 53.8 s, 2 of 5, 8 % | True to the Line 8 % / 2 % (5) | weak kit (Stage 11) |
| dang_quan_binh (KĐ) | 42.7 s, 4 of 5, 25 % | True Gold Shows `not_run` | out of fight |
| hinh_thu_tinh (KĐ) | 37.4 s, 5 of 5, 99 % | | **now runs** (was REFUSED); Mountain Root Stance in her kit (open item 2) |
| thinh_ham_quang (TC) | 32.6 s, 3 of 5, 8 % | | **now runs** (was REFUSED) |
| other Pivot elders (KĐ) | trong 4, boc 5, bach 5, quy 5 (99 %), nhiep 2 of 5 | | |
| doan_hi_hoa (TC) | 26.9 s, 5 of 5, 65 % | Before the Sun 65 % / 58 % (20) | |
| thich_minh_thu (TC) | 21.2 s, 5 of 5, 62 % | A Fair Copy (5), no change | the typical foe casts no soul art |
| Dipper inner gate (TC) | plain 3 of 5 (8 %); with Needle Rain 5 of 5 (58 %); with Mountain Root 5 of 5 (95-100 %) | | handle points 1.0 a fight |
| Dipper (LK) | 2-3 of 5, 11-14 % | | |
| Primer outer gate (LK) | 3 arts: 4 of 5, 20 %. Palm and Sinking Weight: 14 of 40. Palm only: 5 of 40 | | palm only was 0 before fix 2; weak start intended |
| servants on Water-Clock Breathing (LK) | 0 of 5 | | as Băng Tâm's servants |

- **`--gap 1`, every holder.** All die in 8-20 s. Every staged art fires, Clock Breath included. The only 0 fires are
  library arts on 9-10 s cooldowns: Stone Warden Call, Flying Blade Retinue and Bastion Reprisal, which is the realm
  step.
- **Linters, after every fix.** `lint_arts` 9 arts, `lint_techniques` 6 techniques and `lint_items` 30 items all give
  0 findings. Every edited JSON file parses.

## Open items (for the user or the serial step)
1. **Mâu Tri Viễn has no escape art.** His kit is Pivot plus Hundred Blades, so Know the Way Out and the escape half of
   Envoys Are Not Struck never run, for an envoy whose depth text says "an envoy fights only to leave". Giving him an
   escape art is a kit choice for the user, not a record fix.
2. **Mountain Root Stance.** A library art (mountain-bone-body-art). Every sect_fight kit that holds it finishes at
   95-100 % health: hinh_thu_tinh, quy_thu_luy, and the Dipper holders chu_binh_quan, sai_thiet_dien, tan_thu_quan and
   others. The Dipper holders do not slot Mountain Stance, so the outlier is Mountain Root Stance itself, not the
   overwrite. The overwrite with Mountain Stance (record review §I 5) also stands for the two Pivot holders. For
   Stage 11 or the library's owner.
3. **sect_fight slotting.** It slots main-technique arts first, so aux spears and swords and item common arts rarely
   slot. The Called Blow, True Line and full Momentum show little in the table for that reason; the in-memory kits
   above stand in.
4. **The record review's holder table and `thien_xu.done` are stale** (finding 10). The Light purity open item is
   closed.
5. **For the serial step:**
   - build technique-effects and curse-fast;
   - move `pending.json`'s `effects` (Sentence Stands only) into the staged Effects file.
6. **Carried over from the record review:**
   - `export_named.py` skips `kind: treasure` (4 items);
   - there is no spear base;
   - the out-of-fight halves: Weighed's lie, the Thiết Mã realm, True Gold Shows;
   - WIRED b13 and the miasma-root `build_use`;
   - the Way-Out Knot.

## Kept record: The Banner Is Raised (darkness-element, decided not_run)
This is the record for the day Darkness is ruled and built. It is kept here, not in `pending.json`, because the
serial step deletes that file.

```json
{"The Banner Is Raised": {
  "rule": "Armoured Horse Banner: while you hold the banner, each hit of your companions and summons lays a Darkness stack on the foe (8 s). (\"Your summons take a quarter less damage\" is dropped: companions and summons are never struck, Combat rule 19.)",
  "records": [
   {"id": "eff:The Banner Is Raised", "on": "hit_landed", "filter": {"kind": "companion"}, "limit": {"per_pulse": 2},
    "do": [{"stacks": {"el": "dark", "n": 1, "for": 8, "side": "foe"}}]}]}}
```

CHECKPOINT DONE
