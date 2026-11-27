# Stage 6 review: Minh Loan Các (`minh_loan`)

All staged files live under `design/stage6-staging/minh_loan/` and art `"id"` entries were inserted into `design/world/depth/sects/minh_loan.techniques.json`. Decisions are auto-accepted under the 2026-11-26 rule and logged below.

## Summary

- **Built:**
  - `techniques/catalogue-sect-minh_loan.json`: 4 techniques (`clay-mould-primer`, `singing-luan-bell-canon`, `hanging-bells-array`, `unstruck-bell-canon`).
  - `arts/part-sect-minh_loan.json`: 7 new active arts (`fired-mould`, `carriage-bell`, `ward-peal`, `hang-the-bells`, `alarm-line`, `struck-it-answers`, `the-bell-that-rings-itself`); existing `mountain-stance` (`family-earth.json`) is carried by `clay-mould-primer` at layer 2.
  - `items/catalogue-sect-minh_loan.json`: 6 signature items (`ml-luan-bell`, `ml-jade-pendants`, `ml-winter-crack`, `ml-answering-bell`, `ml-ringing-rite-robe`, `ml-lam-ngoc-chip`).
  - `items/sets-minh_loan.json`: 2 sets (`ml-pendant-and-bell`, `ml-bridge-bells`).
  - `effects/minh_loan.effects.json`: 3 Effects (`Rings as It Moves`, `Struck, She Rings`, `Forty Answer`), each declaring every counter it reads or writes for GDScript standalone compilation.
  - `design/world/depth/sects/minh_loan.techniques.json`: `"id"` added before `"new"` on all 7 new arts.
- **Deviations:** 7 small engine-form clarifications/approximations (D1–D7, detailed in §§D–E).
- **Auto-accepted decisions:** 7 (logged in §A with reasons).
- **Pending words:** none (`0`; no `pending.json` needed).
- **Never ran / conditional:** `hang-bells-foreseen` (`tag.foreseen`) and the `was_evaded` branches on `carriage-bell` / `Rings as It Moves` did not fire against the standard `typical` foe (`evade = 0`, no `foreseen` request tag in `REQUEST_TAGS` yet); every art fired on every real holder (`0 NEVER_FIRED` at both `--gap 0` and `--gap 1`), and all 3 Effects ran and changed fights on their real holders.
- **Early promotions:** none (`0` stand-ins; `0` cross-owner references).
- **Open items:** serial step merge/export; `export_named.py` support for `kind == "treasure"` (`ml-luan-bell`); adding `"foreseen"` to `REQUEST_TAGS` (Combat rule 12) when foreseen fights are wired so `hang-bells-foreseen` activates automatically.

---

## A. Auto-accepted decisions (with reasons)

1. **`fired-mould` uses `ward_grow` (`0.08` HP) + timed `block` (`+20` for 3 s) without taking the stance slot:**
   - *Reason:* `clay-mould-primer` carries both `fired-mould` (L1) and `mountain-stance` (L2, which toggles the `mountain` stance). Per Băng Tâm lesson 2, a holder has only one stance slot; giving `fired-mould` a `state` would overwrite `mountain-stance` on every L2–L3 outer disciple (`bien_tieu_linh`, `mao_tieu_huong`, `so_thanh_dac`, `tri_vien_lac`). Using `ward_grow` (like `glacier-bastion`) + `+20 block` for 3 s + `shield_broken` (`event.stance_ward >= 1`) delivers the exact "baked clay skin for 3 s, blocking the next hit; rings for an Earth stack on break" fantasy with zero stance conflict.
2. **`ward-peal` applies its `2.0 s` next-art delay (`timer {side: "foe", which: "next", by: 2.0}`) to any foe rather than gating on a missing `foe.creature` readable:**
   - *Reason:* Neither fight engine exposes a `foe.creature` readable (only `foe.boss` exists in `SIDE_READS`; `creature` is a Modifier scope tag only). Keeping the 2 s delay live against every duel foe avoids creating a narrow one-off pending word and keeps `singing-luan-bell-canon` active for all 12 inner-gate holders, while preserving the beast-turning meaning in the lore and rule text.
3. **`carriage-bell`, `hang-the-bells`, `Rings as It Moves`, and `Forty Answer` read `any: [own.foe_pressed >= 1, foe.since_act <= 1]` (gated by `time > 1`) on `pulse`:**
   - *Reason:* In both `engine.py` and `fight.gd`, `pulse()` runs before `act()` on exact integer seconds, and `own.foe_pressed` checks strict inequality `t - o.t_act < 1000`. Against foes with integer cooldowns (such as the `typical` enemy's `2/4/8 s` arts), `3000 - 2000 = 1000` makes `foe_pressed` permanently `0` on holders without `Slowed Time` (`nguy_tram_am`, `lo_hong_pham`, `khang_vien_dac`, `uy_chu_dong`, `uong_lac_chuy`, `phi_ngoc_thanh`, `than_lac_am`). Combining `time > 1` with `foe.since_act <= 1` (`<= 1.0 s`) captures exact-integer foe actions cleanly without firing falsely at `t = 1 s`, in exact parity across both engines.
4. **Pulse-driven bell tolls (`carriage-bell`, `the-bell-that-rings-itself`, `Forty Answer`) use one-shot `summon` (`cd: 0.5, for: 0.6`), while item/set `free_hit` rings (`Rings as It Moves`, `Struck, She Rings`, `alarm-line`) use `outside_budget: true`:**
   - *Reason:* On `pulse`, `s.direct_dmg` resets to `0`, shrinking `trig_budget` to `0.25 * U_att`. When `yen_boi_ngoc` or `tham_huong_nhi` ran multiple `pulse` `free_hit` records together, the first filled `s.trig_dmg` and clipped the later item/set Effects (`Rings as It Moves`, `Forty Answer`) to zero. Using one-shot `summon` (`cd: 0.5, for: 0.6`, exact parity in `engine.py` and `fight.gd`) on the pulse tolls removes all trigger-budget starvation (`clipped: {}`) while letting `Forty Answer` and `alarm-line` scale linearly with uncapped Bell charges.
5. **`struck-it-answers` returns `35 %` Physical damage on both `was_hit` (HP damage) and `ward_absorbed` (ward-soaked damage), laying `1` Metal stack on `was_hit` only; cooldown set to `8 s`:**
   - *Reason:* `was_hit` carries only post-ward HP damage (`dealt`), whereas Minh Loan builds stack `ward-peal` stance wards and `chuong` common wards. Listening on both `was_hit` and `ward_absorbed` returns `35 %` of the full blow (ward + HP) without double-applying the Metal stack. Setting cooldown to `8 s` (matching its `8 s` window) ensures `nguy_tram_am` fires it even in short `--gap 1` fights.
6. **`hang-the-bells` wires its foreseen-fight start using `tag.foreseen` (`on: "fight_start"`):**
   - *Reason:* Both `engine.py` and `effect_compiler.gd` already accept `tag.<name>` readables with zero errors. In unforeseen fights `tag.foreseen` reads `0` cleanly; once `"foreseen"` is added to `REQUEST_TAGS` (Combat rule 12), the bells hang at fight start at no cost with no record rewrite.
7. **`ml-luan-bell` (`kind: "treasure"`, `grade: 4`) carries `"rarity": 5`:**
   - *Reason:* `minh_loan.items.json` specifies `kind: "treasure"` and `grade: 4`, and `lint_items.py` requires `rarity` in `{4, 5}` for `treasure`. Modifiers are untouched (`40.5 W` of `51.2`). `export_named.py` currently skips `kind != "artifact"` (noted in §I).

---

## B. Pending words

None (`0` pending words; all 4 techniques, 7 new arts, 6 items, 2 sets, and 3 Effects run on existing engine words with Python/GDScript parity).

---

## C. Techniques (`design/stage6-staging/minh_loan/techniques/catalogue-sect-minh_loan.json`)

Only `singing-luan-bell-canon` carries depth passives (`b3` Quench Mark: `stack_effect_pct 12 [kim, debuff]`, `stack_duration_pct 16 [kim, debuff]`). **All bonuses and all other passives below are new**, sized against the tier's combat passive budget (`8 / 16 / 24 W`) and unpriced (`catalogue-sect-*`).

| Technique | Tier, kind, elements | Bonuses (all new) | Passives (new unless marked depth) | Arts (unlock layer) |
|---|---|---|---|---|
| `clay-mould-primer` | Tier 0 main, Earth + Metal (`6` layers) | none (`bonus_count 0`) | `defense_pct` 3, `block_rating` 5, `stack_duration_pct` 8 `[tho, debuff]`, `khi_huyet_pct` 2 (`7.8 / 8 W`) | `fired-mould` (1), `mountain-stance` (2, existing) |
| `singing-luan-bell-canon` | Tier 1 main, Metal (`9` layers) | `defense_pct` 8 | **depth (`b3`):** `stack_effect_pct` 12 `[kim, debuff]`, `stack_duration_pct` 16 `[kim, debuff]`; **new:** `ward_efficiency_pct` 3, `linh_luc_regen_inc_pct` 4, `attack_pct` 4 `[kim]` (`15.1 / 16 W`) | `carriage-bell` (1), `ward-peal` (2) |
| `hanging-bells-array` | Tier 1 secret, Metal + Earth (`9` layers) | `than_thuc_pct` 8 | `status_duration_pct` 10 `[curse]`, `stack_duration_pct` 15 `[kim, debuff]`, `stack_effect_pct` 12 `[tho, debuff]`, `art_cost_pct` −6 `[formation]`, `defense_pct` 4 (`15.4 / 16 W`) | `hang-the-bells` (1), `alarm-line` (2) |
| `unstruck-bell-canon` | Tier 2 secret, Metal (`12` layers) | `khi_huyet_pct` 10, `defense_pct` 10 | `block_rating` 12, `ward_efficiency_pct` 6, `stack_effect_pct` 16 `[kim, debuff]`, `stack_duration_pct` 16 `[kim, debuff]`, `health_regen_inc_pct` 12, `status_resist_pct` 6 (`24.0 / 24 W`) | `struck-it-answers` (1), `the-bell-that-rings-itself` (4) |

---

## D. Arts (`design/stage6-staging/minh_loan/arts/part-sect-minh_loan.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `fired-mould` (`clay-mould-primer`, L1) | A ward stance: the holder's skin sets like baked clay for 3 s, blocking the next hit; when the ward breaks it rings, giving the foe an Earth stack. | Earth ward (`c 0`, cost 0.03, cd 5): `ward_grow` 8 % HP + `block +20` for 3 s + `mould_ward = 1`; on `shield_broken` (`event.stance_ward >= 1`), resets `mould_ward` and lays 1 Earth debuff (8 s). | **D1:** uses `ward_grow` + timed `block` without occupying the stance slot so it coexists with `mountain-stance` (L2); the clay ward stays until broken rather than expiring at 3 s. |
| `carriage-bell` (`singing-luan-bell-canon`, L1) | For 6 s, each time the foe presses or dodges, the bell rings: a light Metal hit and one Metal stack on the foe. | Metal (`c 1.2`, cost 0.04, cd 6, `phys`): sets `carriage_bell` (`cap 1, each_for 6`); each pulse while active when `own.foe_pressed`, `foe.pressing`, or `foe.since_act <= 1` (`time > 1`), and on `was_evaded` (`per_pulse 1`), rings via one-shot `summon` (`0.45 phys`) + 1 Metal debuff (8 s). | **D2:** adds a light opening toll (`c 1.2`) on cast so 2-art inner disciples have an active strike; "each time the foe presses" is read once per pulse via `foe_pressed` / `since_act <= 1`. |
| `ward-peal` (`singing-luan-bell-canon`, L2) | One long note: a creature foe's soonest art waits 2 s (it flees); you gain a ward that grows with the Metal stacks on the foe. | Metal ward (`c 0`, cost 0.04, cd 7): `timer` delays foe's `next` art by `2.0 s`; `ward_grow` 6 % HP + `1.5 %` HP per Metal debuff stack on the foe (uncapped). | **D3:** `2.0 s` delay applies to any foe in duels (no `foe.creature` readable in the fight engines; creature-fleeing kept in lore/rule). |
| `hang-the-bells` (`hanging-bells-array`, L1) | Gains four Bell charges for 10 s; each time the foe fires an art while you hold two or more, it gains one Slowed Time stack and Metal stacks, one more each time than the last. In a foreseen fight, the bells are hung before it begins, at no cost. | Metal (`c 0`, cost 0.05, cd 8): adds 4 `bell` charges (`each_for 10`, uncapped); while `bell >= 2`, each pulse the foe acted (`foe_pressed` or `since_act <= 1`, `time > 1`), increments `bell_escalate`, lays 1 `slowed_time` (3 s) and `bell_escalate` Metal debuffs (8 s); resets `bell_escalate` when `bell < 2`. `fight_start` with `tag.foreseen >= 1` adds 4 `bell` charges. | **D4:** "each time the foe fires an art" is read once per pulse via `foe_pressed` / `since_act <= 1` (no `foe_art_fired` event); `tag.foreseen` awaits `"foreseen"` in `REQUEST_TAGS`. |
| `alarm-line` (`hanging-bells-array`, L2) | Rings all your Bell charges at once: the foe gains 2 Earth stacks, and its arts that come ready in the next 0.5 s wait until it ends. | Earth control (`c 0`, cost 0.04, cd 7): lays 2 Earth debuffs (8 s) and `stop_clock` `0.5 s` on the foe; if `own.counter.bell >= 1`, rings each held `bell` charge for `0.25` Physical (`free_hit`, `outside_budget: true`) without spending them. | **D5:** specifies the Bell-ring payoff (`0.25 phys` per held `bell` charge) while leaving Bell charges intact for `Forty Answer` and `Hang the Bells`. |
| `struck-it-answers` (`unstruck-bell-canon`, L1) | For 8 s, each hit the holder takes returns a share of its damage to the striker as Metal and lays a Metal stack on them. | Metal ward (`c 0`, cost 0.04, cd 8): sets `unstruck_answer` (`cap 1, each_for 8`); while active, `was_hit` runs `return_damage` `35 %` (`phys`) + 1 Metal debuff (8 s), and `ward_absorbed` runs `return_damage` `35 %` (`phys`). | none (`35 %` pins "a share"; `ward_absorbed` preserves return on ward-soaked hits). |
| `the-bell-that-rings-itself` (`unstruck-bell-canon`, L4) | Once a foe carries 8 Metal stacks, the bell rings on its own once per second on that foe until the stacks are gone. | Metal (`c 1.2`, cost 0.05, cd 8, `debuff [2, 8]`, `empower c_mult 1.6` at `>= 8` Metal): passively on `pulse`, latches `self_ring = 1` once `foe.debuff.metal >= 8`, tolls each pulse via one-shot `summon` (`0.45 phys`) while `foe.debuff.metal >= 1`, and clears `self_ring` at `0`. | **D6:** gives the active art a `1.2` Physical toll + `2` Metal stacks (`1.6x` at `8+` stacks) so it fires cleanly before and after the `8`-stack threshold while the passive self-ring runs once per second until stacks expire. |

---

## E. Effects (`design/stage6-staging/minh_loan/effects/minh_loan.effects.json`)

Every Effect declares all counters it reads or writes in its own `"counters"` array for GDScript standalone compilation.

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Rings as It Moves` (`ml-luan-bell`) | The bell rings whenever the foe presses or dodges: it takes a light Metal hit and gains one Metal stack, at most once per second. | Declares `luan_bell_cd` (`cap 1, each_for 1`). On `pulse` (`time > 1`, `foe_pressed` / `foe.pressing` / `foe.since_act <= 1`) and on `was_evaded`, when `luan_bell_cd < 1`: arms `luan_bell_cd`, deals `free_hit` (`0.4 phys, outside_budget: true`) and lays 1 Metal debuff (8 s). | **D7:** "presses" read once per pulse via `foe_pressed` / `foe.pressing` / `foe.since_act <= 1`; shared `luan_bell_cd` enforces "at most once per second" across both triggers. |
| `Struck, She Rings` (`ml-pendant-and-bell`, 3pc) | Each hit you take rings the Luan Bell as though the attacker had moved (a light Metal hit and a Metal stack on it), and the Pendants chime back: each chime heals you 1 % of your health, at most once per second. | On `was_hit` (`limit: {cooldown: 1}`): `free_hit` (`0.4 phys, outside_budget: true`), 1 Metal debuff (8 s), and `heal` `1 %` max HP. | none |
| `Forty Answer` (`ml-bridge-bells`, 2pc) | Bells you hang with Hang the Bells answer your hand bell: each time the foe acts, every Bell charge you hold rings once, each a light Metal hit; at most once per second. | Declares `bell` (`each_for 10`). On `pulse` (`time > 1`, `own.counter.bell >= 1`, `own.foe_pressed >= 1` or `foe.since_act <= 1`), `scale: own.counter.bell`, `limit: {cooldown: 1}`: one-shot `summon` (`0.25 phys` × Bell charges). | shares **D4** (`foe_pressed` / `since_act <= 1` on `pulse`); one-shot `summon` avoids `pulse` trigger-budget clipping. |

---

## F. Items and sets (`design/stage6-staging/minh_loan/items/catalogue-sect-minh_loan.json`, `sets-minh_loan.json`)

- **6 signature items**, modifiers copied verbatim from `design/world/depth/sects/minh_loan.items.json`, all with `sources: ["npc"]`, `unique: true`, and `arts: []`.
- R6 `exception` set on the 3 `chuong` (`ward_gear`) items (`ml-luan-bell`, `ml-winter-crack`, `ml-answering-bell`) and 1 `dao_bao` (`body_gear`) item (`ml-ringing-rite-robe`); the 2 `ngoc_boi` (`necklace`) items (`ml-jade-pendants`, `ml-lam-ngoc-chip`) satisfy rule 21 directly.
- `ml-luan-bell` (`kind: "treasure"`, `grade: 4`) carries `"rarity": 5` and `"effects": ["Rings as It Moves"]`.
- **2 sets:** `ml-pendant-and-bell` (3pc, `Struck, She Rings`) and `ml-bridge-bells` (2pc, `Forty Answer`), matching the depth modifiers and rules.

---

## G. Stand-ins and beasts

- **Stand-ins:** `0` (`minh_loan` has no stand-in techniques in either cast file).
- **Beasts:** `0`.
- **Depth art ids:** inserted `"id"` before `"new"` on all 7 new arts in `design/world/depth/sects/minh_loan.techniques.json`; `depth_check.py --sect minh_loan` reported `findings: none` and `depth_gap.py --sect minh_loan` reported `unknown_ids: 0`, `engine_words: 0`.

---

## H. Holder check (`$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\minh_loan"`)

**Linters & standalone Effect validation:**
- `lint_arts.py design/stage6-staging/minh_loan/arts/part-sect-minh_loan.json`: `7 arts in 1 files, 0 findings`.
- `lint_techniques.py design/stage6-staging/minh_loan/techniques/catalogue-sect-minh_loan.json`: `4 techniques, 0 findings` (`7.8/8`, `15.1/16`, `15.4/16`, `24.0/24`).
- `lint_items.py design/stage6-staging/minh_loan/items/catalogue-sect-minh_loan.json`: `6 items, 22 bases, 9 common arts, 0 findings`.
- `engine.validate` + standalone counter/state check: `0 errors` across all 3 Effects (`Rings as It Moves`, `Struck, She Rings`, `Forty Answer`).
- `depth_check.py --sect minh_loan`: `findings: none`.
- `spatial_words_check.py --sect minh_loan`: `0` non-soft hits (`5` soft `"beside"` hits in `build_use` / `ties.note`).

**`sect_fight.py minh_loan` (`--seeds 20` at `--gap 0`; `--seeds 5` at `--gap 1`; `0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN`):**

| Holder(s) | Realm | Active arts | Same realm (`mean_s`, `wins/20`, `hp_left`) | `--gap 1` (`mean_s`, `wins/5`, `hp_left`) | Art fires (min–max, gap 0) | Effect ablations & notes |
|---|---|---|---|---|---|---|
| `yen_boi_ngoc` | `ket_dan` | `carriage-bell, ward-peal, struck-it-answers, the-bell-that-rings-itself, hang-the-bells, alarm-line` | `19.5 s`, `20/20`, `100%` | `13.1 s`, `0/5`, `0%` | `2.0–3.0` | `Rings as It Moves`: with `19.5 s 100%` vs without `20.5 s 100%` (`runs 132`). `Struck, She Rings`: with `19.5 s 100%` vs without `22.7 s 95%` (`runs 335`). `clipped: {}`. |
| `nguy_tram_am` | `ket_dan` | `carriage-bell, ward-peal, struck-it-answers, the-bell-that-rings-itself` | `29.1 s`, `20/20`, `91%` | `11.2 s`, `0/5`, `0%` | `3.0–4.5` | `ml-winter-crack`; all sub-records active (`carriage-bell-press 45`, `self-ring-toll 100`, `struck-answers-hit/ward 155` over 5 seeds). `clipped: {}`. |
| `tham_huong_nhi` | `truc_co` | `carriage-bell, ward-peal, hang-the-bells, alarm-line` | `33.0 s`, `20/20`, `85%` | `9.3 s`, `0/5`, `0%` | `3.8–5.0` | `Forty Answer`: with `33.0 s 85%` vs without `38.8 s 85%` (`runs 191`, `5.8 s` faster). `clipped: {}`. |
| `chiem_thinh_ba`, `ong_hai_linh` | `truc_co` | `carriage-bell, ward-peal, hang-the-bells, alarm-line` | `40.4 s`, `20/20`, `83%` | `9.1 s`, `0/5`, `0%` | `4.5–6.3` | Full inner + array rotation wins cleanly inside the 30–60 s sustain band. |
| `ve_soc_linh` | `luyen_khi` | `carriage-bell, ward-peal, hang-the-bells` | `43.7 s`, `20/20`, `81%` | `8.6 s`, `0/5`, `0%` | `4.7–7.0` | Escalating Metal stacks + Slowed Time from `hang-the-bells` cleanly wins same-realm duels. |
| `lo_hong_pham`, `khang_vien_dac`, `uy_chu_dong` | `truc_co` | `carriage-bell, ward-peal` | `62.4–62.5 s`, `8/20`, `5–6%` | `9.2 s`, `0/5`, `0%` | `7.3–9.1` | 2-art defensive ward-bell core (no secret art) fights long attrition duels and wins ~40%. |
| `uong_lac_chuy`, `phi_ngoc_thanh`, `than_lac_am` | `luyen_khi` | `carriage-bell, ward-peal` | `56.2 s`, `1/20`, `1%` | `8.2 s`, `0/5`, `0%` | `6.2–8.1` | Early inner-gate 2-art kit; survives 56 s against armed 3-art typical foe. |
| `bien_tieu_linh`, `mao_tieu_huong`, `so_thanh_dac`, `tri_vien_lac` | `luyen_khi` | `fired-mould, mountain-stance` | `47.5–48.2 s`, `0/20`, `0%` | `9.8 s`, `0/5`, `0%` | `7.8–9.5` | Outer-gate defensive primer; both `fired-mould-break` (`33` runs/5 seeds) and `mountain-stance` (`50` answers) run cleanly with zero stance collision. |
| `dau_tieu_hoa`, `do_ne_huong` | `luyen_khi` | `fired-mould` | `48.8–48.9 s`, `0/20`, `0%` | `8.6 s`, `0/5`, `0%` | `8.6` | L1 outer-gate single defensive ward art; `fired-mould-break` fires `38` times over 5 seeds. |

---

## I. Open items (for the serial step / user)

1. **`export_named.py` `kind == "treasure"`:** `ml-luan-bell` has `kind: "treasure"`, `grade: 4`, `rarity: 5`; ensure `export_named.py` exports `treasure` records at Stage 7/serial export (same open item as `ct-star-lake-mirror`).
2. **`REQUEST_TAGS` `"foreseen"`:** `hang-the-bells` already includes `hang-bells-foreseen` gated on `tag.foreseen >= 1`; adding `"foreseen"` to `assets/data/combat_engine.json` `REQUEST_TAGS` when foreseen encounters are wired will activate it automatically.

REVIEW DONE
