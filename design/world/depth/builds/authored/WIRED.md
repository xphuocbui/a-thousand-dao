# Wired: the authored wishes in the depth files (phase B, 2026-11-25)

The wiring pass applied `auth-mod.json`, `auth-eff-1.json`, `auth-eff-2.json`, `auth-tech.json` and the 87
rewordings of `duel-readings.md` §3 to the depth files under `sects/` and `people/`. All of it is still an unpriced
proposal. Every changed record carries `"authored": "<wish keys>"`. This covers items, sets, techniques, art and Effect
dicts, and the people whose builds changed. The key `a1` marks a duel-readings rewording. When several wishes touched
one record, the keys are joined with commas.

Checker at the end (`python -I tools/design/world/depth_check.py`): techniques known 233 (231 + 2 new), items known 661
(653 + 8 new), findings: none.

## How the wires were applied

- **Modifier lines** are written in the catalogue's `{key, value, scope}` form. If a technique had no `passives`
  field, the pass created one. "The N lines above" means the record's `modifiers`.
- **New passive arts** (auth-eff, `arts` add) are art dicts: `{new, concept, effect: <Effect record id>,
  unlock_layer?, authored}`. The concept is the wire text without its "Name (Hán-Việt):" prefix. An `unlock_layer`
  appears only where the wire note names a layer.
- **auth-tech arts** are art dicts: `{new, concept: the record's rule, id, tags, unlock_layer, record: pointer,
  authored}`. The full DSL record stays in `auth-tech.json`; the `record` field points to it.
- **Replaced arts, item Effects and set bonuses** take the wire text. A set bonus keeps its "Name (Hán-Việt):"
  prefix. Some replaces carry no name in their text (The Held Rest, The Second Cup, Open the Cask, Last Cup,
  `the-second-cup-is-poured`, `sealed-cask`, `unlit`); for those the pass found the target from the wire note and kept
  the name.
- **Rows marked "…"** in duel-readings §3 change only the named clause. The rest of the text is unchanged.
- **Concept edits** change one sentence each: `dipper-handle-canon` (d9), `army-breaker-spear` (d21, which keeps its
  "weakest file" line and adds the new rule after it) and `contract-sword-canon` (a1).
- **New items** go at the end of the owning file's `items` array. The holder wears the item in place of the generic
  piece that the wire note names, so the gear count does not change, and the item is added to the holder's `items`
  list.
- **New techniques** (`censer-smoke-manual` and `black-ice-method`) are kept in the catalogue form their record uses
  (`abilities`, `passives`, `effects`). The pass also added an `arts` list so the depth schema can read them.
- **Tags** (`song`, `talisman`, `bow`, `bleed`) go into the art dict's `tags`.

## Conflicts and how they were resolved

When a wire's note said it starts from the §3 wording, the pass applied the wire text and counted the §3 row as
applied through it. Those records carry both keys:

- The Ninth Verse (d14)
- Geese Startled by the Cold (d4)
- Geese Stance (d4): the Cảnh Trường Thiên lore line was kept
- One Breath Down the File (d4)
- Add a Voice (d7)
- Hang the Bells (d15)
- Laid Ward (d15)
- Heart in the Jade Vessel (d18, X = 25 %)
- Wine in the Night-Glow Cup (d19)
- The Called Blow on `tx-pha-quan-spear` (d21: "breaks a ward" in place of §3's "Broken")
- The Last Step on `py-grey-seal` (d29)

Other records got several wishes that stack:

| Record | Wishes |
|---|---|
| `evening-song-of-the-boats` | b1, b2, d14 |
| `long-sky-one-colour` | d4, a1, d17 |
| `true-gold-canon` | b3 and b5 passives merged into one list, then d31 |
| `pine-warden-staff-and-bow-canon` | b1 and b10 passives, a1, d17 |
| `shao-remnant-score` | b2 tag and e4 concept on Dawn Clouds, the e4 art and Effect |
| `the-monks-rest` | d28 replace and add, b2 tag |
| `ten-thousand-ravines-zither-canon` | b1, b2, a1 |
| `tp-autumn-grave-bell` | b2, d7 |
| `pm-dawn-call-pipe` | b2, e10 |
| `tv-green-moss-mirror` | a1 rewords Light on the Moss, d5 adds a second Effect; they do not compete |
| `nt-first-file-banner` | a1, d17 |
| `mist-lock-array-canon` | a1, d2, d49 |

**The Long Ride (`muc_van` cloud-herd-body-canon) was an either/or.** The pass applied d20's wording whole: "Each
second in which you or your horse land a hit adds a momentum stack, up to 10 … A single heavy blow (5 % of your
health or more), or being Displaced, loses half." (The "up to 10" came off under the Group 8 ruling below; the halving is now its close.) The §3 wording was **not** applied. It reads: "A footwork stance:
each second you are Moving adds a momentum stack (up to 10); each stack raises Physical damage and body shield a
little; being Displaced or Rooted loses half." d20 was chosen because the riders' builds are about landing hits with
the horse, and under R7 a footwork stance counts as Moving on every pulse, so §3's version would just be a timer. The
user may swap it.

**Two-option rows:**
- Open the Sky: the never-firing clause was dropped. The other option, "the second cast also strikes you while you
  are below half health", was not applied.
- `falling-plum-tune`: the place clause was dropped, not kept as flavour.

## Wires not applied

**Outside `design/world/depth/`.** The brief allows edits only inside this folder. These wires are left for the
GDD and catalogue pass:

- **b2** (vocabulary, library and catalogue):
  - the `song` form tag in `design/gdd/modifiers.md` rule 9;
  - `string-cut` `music` → `song` (`design/items/common-arts.json`);
  - `cam` base tag (`bases.json`);
  - `song` on `delaying-gong`, `lustral-bell` and `bell-of-waking` (`design/arts/part-b/c.json`): **applied** later by ruling (group 8);
  - `x_soul 3 [song]` on `hollow-bell-canon` (catalogue).
  - The depth `[song]` scopes do not validate until the vocabulary amendment lands.
- **b9**: `palm` on `rolling-barrage-fist` and `twin-shadow-fist` (`design/arts/family-body.json`), and
  `art_speed_pct 8 [palm]` on `hundred-echo-palm-scripture` (catalogue).
- **b10**: the `bow` form tag in `modifiers.md`. The depth `[bow]` scopes wait on it.
- **d11**: Debt Stone on `mountain-heart-canon` (catalogue).
- **d12**: Written in the Ledger on `ruin-ledger-scripture` (catalogue).

**Held by ruling or condition:**

- **b1 shared methods** (auth-mod entry 7): ruled (group 8). The lines are not put on the shared catalogue methods; they
  go on the lineages' own methods instead (see Group 8 below).
- **e9 `cung_mac_suong` aux** (black-ice-method, layer 3): the wire says it applies only once she accepts Triệu Huyết
  Y's offer. Her build is unchanged. The method itself is filed in `people/demonic.techniques.json`.

**Held because the in-folder wire works only with a skipped one:**

- `trac_anh` `ta-goose-bone-beads` `attack_pct 10 [physical]` → `12 [palm]` (b9). Without the `palm` tag on the two
  fist arts, the rescope would take damage off phi_nhan_tam's fists. It is held with the b9 tag wires.
- `lac_ha` `lh-nails-of-dao-sa` 2-piece "Fished from the Shallows" (d11). The new text reads the Debt Stone, which
  lives on the catalogue's `mountain-heart-canon` (not wired). It is held with that wire, and the hand-written
  reprisal stays.

**Lines the checker refuses.** Item modifier keys must already occur in `design/items/catalogue-*`:

- **b13** `tx-dao-quang-war-flag`: `companion_power_pct 10` and `companion_speed_pct 10`. Both keys are missing, so
  this wire was not applied.
- **b5** `tx-miasma-root-charm`: the `herb_growth_pct 8` line was dropped. The item is in, with poison resistance and
  health.
- **b12** `ls-snare-wire-coins`: the `curse_effect_pct 10` line was dropped. The item is in, with accuracy and Metal
  damage.
- All four keys are valid in `modifiers.md`. A catalogue item that uses them, or a checker change, would let the
  lines return.

**Partly applied:**

- **d2 Way-Out Knot** (`mf-way-out-knot`): hoang_phu_duyen wears it in place of his `ngoc_boi 2`.
- phong_bach_ke, hua_thanh_diem and nham_do_han have full gear and no `ngoc_boi` to swap. They hold the knot in
  `items` but do not wear it, so the user picks which piece it replaces.

**No wire, by design:**

- The Charmed, Drunk and Asleep status rows (d34, d39, d40) go into the Effects GDD's Status Catalogue with its
  amendment.
- b14 was already covered.
- d26 was dropped by ruling.
- e6's Fifteenth Layer is on the technique only (`unlock_layer` 15); no one has the layer yet.

## Group 8 rulings (2026-11-25, after the wiring)

**1. Caps lifted.** The in-piece caps came off. Where a piece could run away, a decay or a cost now bounds it.

| Wish | Cap removed | What bounds it now | Depth files changed | Authored record changed |
|---|---|---|---|---|
| d3 | 40 % on The Glow Deepens | the length of the fight | `lac_ha.techniques` | yes |
| d5 | 30 % Green store; 10 % a fall | the Green decays by a tenth each second | `thuy_vi.techniques` (two arts), `tv-green-moss-mirror`, `tc-purple-lingzhi-gourd` | yes |
| d12 | 5 Debts | each Debt lasts its own 10 s; the Verdict spends them | none (the Effect sits on a catalogue technique) | yes |
| d15 | 3 standing wards on Laid Ward | each standing ward costs a little linh lực each second | `suong_tung.techniques` | yes |
| d18 | consumes up to 10 Ice | consumes all | `bang_tam.techniques` | yes |
| d20 | 10 momentum on The Long Ride | a heavy blow or being Displaced halves it | `muc_van.techniques` | yes |
| d28 | 6 s on The Earned Rest | each later finale's rest is half as long | `van_hac.techniques` (Earned Rest and Held Rest) | yes |
| d29 | 5 s on One Cut Drawn Out (`tvl-dalan-suite`) | waiting costs damage | `thinh_vu.items` | wire text only |
| d39 | Drunk stacks to 3, refreshed together | each stack runs its own 3 pulses | none (status row) | yes |
| d41 | 30 % store on Haze Held All Night (`yq-dusk-field`) | the store decays by a twentieth each second | `yen_quang.items` | yes |

What stays:
- **Thresholds**, which a payoff empties: d1's five colours, d2's five Lost, d19's cup of five, d43's five steps (since
  the review sweep of 2026-11-25, steps past five still count, and the quench spends them all).
- **Rate limits** such as "at most N a pulse" or "once a second".
- **d42's 20 % tiring**, which is a bound on a drawback.
- **Original lineage counts** the wishes did not author: Plant the Stele's three and Walk Slowly's 8. The review sweep
  of 2026-11-25 (`review/RANKED.md` A1) took the cap off Army-Breaker's Momentum in the d21 wire (Momentum now loses a
  twentieth of itself each second), made d23's Walk Slowly discount compound so it holds if Walk Slowly's 8 goes, and
  took the six-stack cap off e8 Move the Sickness (each stack moved costs 0.5 % linh lực). The wired copies in the sect
  and group files are the sect writers'.

No page sentence restated a removed cap. The `auth-eff` `.md` notes are updated.

**2. Engine wishes.** `builds/engine-wishes.md` lists every engine feature the authored Effects need. For each it
gives what the feature does, the Effects that need it and the simplest hook. The duel readings' own hooks stay in
`duel-readings.md` section 2.

**3. Library tags and the shared-method lines.**
- `song` is now on the library arts `delaying-gong` (`design/arts/part-c.json`), `lustral-bell` and `bell-of-waking`
  (`part-b.json`). The edit was a substring insertion into each art's top-level `tags`. Both files parse, and nothing
  else in them changed.
- No library `bow` wire remained: `pinning-arrow` and `nocked-arrow` already carry `bow`.
- Still not applied: the `string-cut` and `cam` tags (`design/items/`) and the `song` and `bow` vocabulary in
  `modifiers.md`.
- The two shared-method lines did not go to `design/techniques/`. Lạc Hà's own three methods already carry the Maple
  Hall lines.
- The Green Ring lines now sit on Thúy Vi's own inner-gate secrets, `haze-walk` and `rock-splitting-root`.
- So that the two requesters get the lines, each takes one of those methods as an aux at layer 5, a choice for the
  user to review:
  - sai_thanh_phong + `evening-song-of-the-boats`;
  - pham_thu_dien + `haze-walk`.

**4. The crane king.** Thanh Điền is now a named spirit beast record (proposal) in `sects/cuu_cao.beasts.json`, in
the game's beast form:
- `is_beast`, `owner_id` `ung_hac_minh`, `loyalty`, realm and root;
- `tags` `crane` and `bird`;
- a `combat` note on the power share;
- a `bond` to its rider (A097).

Ung Hạc Minh lists it in `beasts`, the game's Character field, and the Cửu Cao page names it in section 10.

## Still open

- **Pages updated (follow-up, 2026-11-25):** 30 rule sentences on 22 `sects/*.md` and `people/*.md` pages now match
  the JSON. Ten are verbatim set Effects that were replaced whole; twenty are short set or lineage summaries, reworded
  only in their rule clause. Lore was left alone. A few pages still give lore or doctrine readings, such as "a file
  fights as one body". They do not state a rule, so they were not changed.
- The engine and vocabulary needs are listed in each authored `.md`: `song`, `bow`, `fan`, `mist`, `crane` and `bird`
  tags; held damage; delay immunity; turning a tick into healing; the rolling "lost in the last N s"; and stopping a
  side's clock.
- The e1 counter-cut reads an art id `where-the-drop-falls` that does not exist yet.
- Two texts describe the same clause in different ways:
  - the Eighth Movement art in `nine-shao-advent` (e4 text) still says the foe "cannot target the player with an
    art";
  - `pm-tieu-thieu-quan / eight-of-nine` now uses §3's "holds its arts" reading.
  - Neither source covers the other, so the catalogue pass should pick one.
- Two `build_use` lines still describe a modifier that was dropped: `tx-miasma-root-charm` ("and her root fields")
  and `ls-snare-wire-coins` ("bite harder").

## Applied, by wish

### a1

86 of the 87 rows are applied: 75 directly, and 11 through the wish wires listed under Conflicts. The Long Ride row was not applied (d20 was chosen; see Conflicts).

- `sects/lac_ha.techniques.json` evening-song-of-the-boats › The Ninth Verse: art reworded (d14; covers duel-readings 3a)
- `sects/lac_ha.techniques.json` long-sky-one-colour › Geese Startled by the Cold: art reworded (d4; covers duel-readings 3a)
- `sects/lac_ha.techniques.json` long-sky-one-colour › One Colour: art reworded (duel-readings 3b)
- `sects/lac_ha.items.json` lh-cold-geese-sword / geese-in-file: item Effect reworded (duel-readings 3a)
- `sects/lac_ha.items.json` lh-cloud-bridge-flags / span-the-gap: item Effect reworded (duel-readings 3a)
- `sects/lac_ha.items.json` lh-off-the-field (3 pieces): set bonus Effect reworded (duel-readings 3a)
- `sects/lac_ha.items.json` lh-cloud-bridge-works (3 pieces): set bonus Effect reworded (duel-readings 3c)
- `sects/nhan_tran.techniques.json` wild-geese-formation-canon › Geese Stance: art reworded (d4; covers duel-readings 3a; lore line kept)
- `sects/nhan_tran.techniques.json` wild-geese-formation-canon › Trading the Point: art reworded (duel-readings 3a)
- `sects/nhan_tran.techniques.json` spring-levy-drum › Close the File: art reworded (duel-readings 3a)
- `sects/nhan_tran.techniques.json` walking-out-of-the-grey › One Breath Down the File: art reworded (d4; covers duel-readings 3a)
- `sects/nhan_tran.techniques.json` walking-out-of-the-grey › The Rear Guard Faces Back: art reworded (duel-readings 3a)
- `sects/nhan_tran.items.json` nt-first-file-banner / one-goose: item Effect reworded (duel-readings 3a)
- `sects/nhan_tran.items.json` nt-out-of-the-grey (3 pieces): set bonus Effect reworded (duel-readings 3a)
- `sects/nhan_tran.items.json` nt-point-of-file (2 pieces): set bonus Effect reworded (duel-readings 3a; now always on)
- `sects/thuy_vi.techniques.json` green-furnace-canon › Green Fire Eats Dead Wood: art reworded (duel-readings 3b)
- `sects/thuy_vi.items.json` tv-green-moss-mirror / light-on-the-moss: item Effect reworded (duel-readings 3a)
- `sects/thuy_vi.items.json` tv-poria-under-pine (3 pieces): set bonus Effect reworded (duel-readings 3a)
- `sects/thu_phan.techniques.json` autumn-grave-canon › Add a Voice: art reworded (d7; extends duel-readings 3a)
- `sects/van_hac.techniques.json` ten-thousand-ravines-zither-canon › Ten Thousand Ravines: art reworded (duel-readings 3b)
- `sects/tuan_tung.techniques.json` pine-warden-staff-and-bow-canon › Wolf Ring: art reworded (duel-readings 3a)
- `sects/tuan_tung.techniques.json` wolf-winter-arrow › The Leader First: art reworded (duel-readings 3e)
- `sects/tuan_tung.items.json` ttg-caravan-bell / ring-for-the-wardens: item Effect reworded (duel-readings 3a)
- `sects/tuan_tung.items.json` ttg-wolf-winter-bow / the-pack-turns: item Effect reworded (duel-readings 3e)
- `sects/thien_xu.techniques.json` heavenly-pivot-true-canon › North Star Writ: art reworded (duel-readings 3a)
- `sects/thien_xu.techniques.json` heavenly-pivot-true-canon › The Pivot Does Not Turn: art reworded (duel-readings 3d)
- `sects/thien_xu.techniques.json` boundary-stele-array-canon › Plant the Stele: art reworded (duel-readings 3a)
- `sects/thien_xu.techniques.json` boundary-stele-array-canon › No Crossing the Line: art reworded (duel-readings 3c)
- `sects/thien_xu.techniques.json` dipper-handle-canon › The Handle Points East: art reworded (duel-readings 3e)
- `sects/thien_xu.items.json` tx-iron-horse (2 pieces): set bonus Effect reworded (duel-readings 3a)
- `sects/thien_xu.items.json` tx-square-and-compass / true-to-the-line: item Effect reworded (duel-readings 3c)
- `sects/thien_xu.items.json` tx-archive-desk (3 pieces): set bonus Effect reworded (duel-readings 3d)
- `sects/thien_xu.items.json` tx-pha-quan-spear / the-called-blow: item Effect reworded (d21; covers duel-readings 3e)
- `sects/thien_xu.items.json` tx-dawn-pair (2 pieces): set bonus Effect reworded (duel-readings 3e)
- `sects/cung_tinh.techniques.json` bowing-stars-canon › Fixed Pole: art reworded (duel-readings 3d)
- `sects/cung_tinh.techniques.json` star-pacing-primer › Seven Steps: art reworded (duel-readings 3c)
- `sects/cung_tinh.items.json` ct-pole-star-court (2 pieces): set bonus Effect reworded (duel-readings 3c)
- `sects/minh_loan.techniques.json` singing-luan-bell-canon › Ward Peal: art reworded (duel-readings 3a)
- `sects/minh_loan.techniques.json` hanging-bells-array › Hang the Bells: art reworded (d15; covers duel-readings 3c)
- `sects/minh_loan.techniques.json` hanging-bells-array › Alarm Line: art reworded (duel-readings 3b)
- `sects/minh_loan.items.json` ml-bridge-bells (2 pieces): set bonus Effect reworded (duel-readings 3c)
- `sects/vu_an.techniques.json` mist-lock-array-canon › Lock the Road: art reworded (duel-readings 3a)
- `sects/vu_an.techniques.json` mist-lock-array-canon › Lantern-Stone: art reworded (duel-readings 3a)
- `sects/suong_tung.techniques.json` frost-pine-ward-canon › Laid Ward: art reworded (d15; covers duel-readings 3c)
- `sects/bang_tam.techniques.json` jade-vessel-ice-heart-canon › Heart in the Jade Vessel: art reworded (d18; covers duel-readings 3d, X = 25 %)
- `sects/bang_tam.items.json` bt-glacier-vigil (3 pieces): set bonus Effect reworded (duel-readings 3d)
- `sects/bang_tam.items.json` bt-jade-vessel / ice-in-the-vessel: item Effect reworded (duel-readings 3d)
- `sects/bang_tam.items.json` bt-fishers-heirs (2 pieces): set bonus Effect reworded (duel-readings 3d)
- `sects/muc_van.techniques.json` cloud-herd-body-canon › Run With the Herd: art reworded (duel-readings 3a)
- `sects/muc_van.items.json` mv-cloud-herding-lance / turn-the-herd: item Effect reworded (duel-readings 3a)
- `sects/muc_van.items.json` mv-phu-dao-last (3 pieces): set bonus Effect reworded (duel-readings 3a)
- `sects/phat_y.techniques.json` dry-road-sword-primer › Noon Guard: art reworded (duel-readings 3a)
- `sects/phat_y.techniques.json` contract-sword-canon: method concept reworded (fixB-apply 2026-11-25: Steps at ten -> Terms, Khoản; Final Count's pierce at five)
- `sects/phat_y.techniques.json` contract-sword-canon › Step Back: art reworded (duel-readings 3e)
- `sects/phat_y.items.json` py-grey-seal (2 pieces): set bonus Effect reworded (d29; covers duel-readings 3e)
- `sects/da_quang.techniques.json` night-glow-blood-sabre-canon › Wine in the Night-Glow Cup: art reworded (d19; covers duel-readings 3e)
- `sects/da_quang.items.json` dq-night-glow-cup / drink-after-the-raid: item Effect reworded (duel-readings 3e)
- `sects/phuong_minh.items.json` pm-tieu-thieu-quan / eight-of-nine: item Effect reworded (duel-readings 3b)
- `sects/thinh_vu.techniques.json` thunder-in-the-rain-canon › The Chain Carries It Down: art reworded (duel-readings 3b)
- `sects/thinh_vu.techniques.json` opening-thunder-canon › Open the Sky: art reworded (duel-readings 3b: the never-firing clause dropped)
- `sects/thinh_vu.techniques.json` lightning-rod-sword › Sword Raised to the Cloud: art reworded (duel-readings 3c)
- `sects/ngao_tuyet.techniques.json` lone-branch-sword › Bare Winter: art reworded (duel-readings 3a; on for companion-less builds)
- `sects/ngao_tuyet.items.json` ngt-plum-and-snow (2 pieces): set bonus Effect reworded (duel-readings 3a)
- `sects/binh_thuy.items.json` bth-slack-water (3 pieces): set bonus Effect reworded (duel-readings 3a)
- `sects/ho_lam.techniques.json` night-beside-the-tree › Bark Closes: art reworded (duel-readings 3a)
- `sects/ho_lam.techniques.json` raft-and-root-primer › Log on the Current: art reworded (duel-readings 3b)
- `sects/le_hoa.items.json` lh-bolt-ice-bell / toll-of-the-frozen-bolt: item Effect reworded (duel-readings 3b)
- `sects/le_tuyen.items.json` ltp-sweet-dew-needles / needle-of-mending: item Effect reworded (duel-readings 3a)
- `sects/nam_pho.items.json` np-dusk-half (3 pieces): set bonus Effect reworded (duel-readings 3a)
- `sects/tung_dao.techniques.json` startled-goose-step › The Goose Rises from the Reeds: art reworded (duel-readings 3e)
- `sects/tung_dao.items.json` td-broken-ice-flags / crack-the-ice: item Effect reworded (duel-readings 3c)
- `sects/tung_dao.items.json` td-coiled-root-banner / roots-under-the-field: item Effect reworded (duel-readings 3d)
- `sects/xuyen_lam.techniques.json` straw-sandal-step-primer › Lighter Than a Horse: art reworded (duel-readings 3d)
- `sects/van_khoi.items.json` vk-empty-mountain (3 pieces): set bonus Effect reworded (duel-readings 3d)
- `sects/nhan_van.techniques.json` living-scroll-art › Door Guardian: art reworded (duel-readings 3a)
- `sects/bach_vu.techniques.json` roosting-branch-canon › Under the Wing: art reworded (duel-readings 3a)
- `sects/bach_vu.techniques.json` hundred-call-breath › Still on the Branch: art reworded (duel-readings 3d)
- `people/loose-south.items.json` ls-thuy-khau-stern-lamp / no-fare: item Effect reworded (duel-readings 3a; the lamp clause dropped with it)
- `people/loose-south.items.json` ls-free-crossing (2 pieces): set bonus Effect reworded (duel-readings 3a)
- `people/loose-south.items.json` ls-miasma-walker (3 pieces): set bonus Effect reworded (duel-readings 3d)
- `people/market-folk.items.json` mf-second-spring-needles / second-spring: item Effect reworded (duel-readings 3a)
- `people/market-folk.items.json` mf-loom-of-letters-seal / carried-array: item Effect reworded (duel-readings 3c)
- `people/market-folk.techniques.json` second-spring-needle-art › Draw the Poison: art reworded (duel-readings 3a)
- `people/market-folk.techniques.json` loom-of-letters-array › Walking Ward: art reworded (duel-readings 3c)
- `people/clans.items.json` cl-locust-shade (3 pieces): set bonus Effect reworded (duel-readings 3d)
- `people/hermits-sages.items.json` hs-fifth-month-plum / falling-plum-tune: item Effect reworded (duel-readings 3f: the place clause dropped)

### b1
- `sects/lac_ha.techniques.json` sunset-cloud-canon: passives +dao_tam 1.33; khi_huyet_pct 6.6; breakthrough_chance 0.8; health_regen_inc_pct 13.3
- `sects/lac_ha.techniques.json` evening-song-of-the-boats: passives +dao_tam 1.33; khi_huyet_pct 6.6; breakthrough_chance 0.8; health_regen_inc_pct 13.3
- `sects/lac_ha.techniques.json` evening-dust-primer: passives +dao_tam 0.66; khi_huyet_pct 3.3; breakthrough_chance 0.4; health_regen_inc_pct 6.6
- `sects/nhan_tran.techniques.json` wild-geese-formation-canon: passives +attack_pct 6 [tho]; block_rating 10; khi_huyet_pct 6.6
- `sects/thuy_vi.techniques.json` emerald-haze-canon: passives +health_regen_pct 0.4; breakthrough_chance 0.8; cultivation_speed_pct 1.8; herb_growth_pct 4.4
- `sects/thuy_vi.techniques.json` seed-and-soil-primer: passives +health_regen_pct 0.2; breakthrough_chance 0.4; cultivation_speed_pct 0.9; herb_growth_pct 2.2
- `sects/van_hac.techniques.json` ten-thousand-ravines-zither-canon: passives +soul_res_pct 8.3; status_resist_pct 7.5
- `sects/tuan_tung.techniques.json` pine-warden-staff-and-bow-canon: passives +khi_huyet_pct 6.6; can_cot 1.33; health_regen_inc_pct 13.3

### b2
- `sects/lac_ha.techniques.json` evening-song-of-the-boats › Coming Home at Dusk: tag song
- `sects/lac_ha.techniques.json` evening-song-of-the-boats › Oars Together: tag song
- `sects/lac_ha.techniques.json` evening-song-of-the-boats › The Ninth Verse: tag song
- `sects/thu_phan.techniques.json` autumn-grave-canon: passives +x_soul 5 [song]; soul_res_pct 6.6
- `sects/thu_phan.techniques.json` autumn-grave-canon › Ghosts Sing Old Poems: tag song
- `sects/thu_phan.techniques.json` autumn-grave-canon › Autumn Comes: tag song
- `sects/thu_phan.techniques.json` grave-sweeping-chant › Sweep the Stones: tag song
- `sects/thu_phan.items.json` tp-grave-drum: modifier art_speed_pct 8 [soul] -> art_speed_pct 8 [song]
- `sects/thu_phan.items.json` tp-nine-graves-zither: modifier art_speed_pct 10 [soul] -> art_speed_pct 10 [song]
- `sects/thu_phan.items.json` tp-autumn-grave-bell: modifier + art_speed_pct 10 [song]
- `sects/van_hac.techniques.json` ten-thousand-ravines-zither-canon › Ten Thousand Ravines: tag song
- `sects/van_hac.techniques.json` ten-thousand-ravines-zither-canon › Echo Wall: tag song
- `sects/van_hac.techniques.json` the-monks-rest › The Held Rest: tag song
- `sects/thien_xu.items.json` tx-hidden-string-zither: new item
- `sects/thien_xu.2.cast.json` bach_vong_ngon: wears tx-hidden-string-zither in place of cam 3 kim
- `sects/phuong_minh.techniques.json` shao-remnant-score: passives +x_soul 5 [song]; art_speed_pct 8 [song]
- `sects/phuong_minh.techniques.json` shao-remnant-score › Dawn Clouds Take the Colour: tag song
- `sects/phuong_minh.items.json` pm-remnant-score-zither: modifier art_speed_pct 12 [soul] -> art_speed_pct 12 [song]
- `sects/phuong_minh.items.json` pm-rites-drum: modifier + art_speed_pct 8 [song]
- `sects/phuong_minh.items.json` pm-dawn-call-pipe: modifier art_speed_pct 10 [soul] -> art_speed_pct 10 [song]
- `people/hermits-sages.items.json` hs-between-the-notes-flute: new item
- `people/hermits-sages.2.cast.json` gian_thu_dich: wears hs-between-the-notes-flute in place of ngoc_boi 3
- `people/demonic.items.json` dm-cracked-bell: modifier art_speed_pct 10 [soul] -> art_speed_pct 10 [song]

### b3
- `sects/minh_loan.techniques.json` singing-luan-bell-canon: passives +stack_effect_pct 12 [kim, debuff]; stack_duration_pct 16 [kim, debuff]
- `sects/hoa_cai.techniques.json` nine-cycle-mercury-art: passives +stack_effect_pct 12 [kim, debuff]; stack_duration_pct 16 [kim, debuff]
- `sects/hoa_cai.items.json` hc-fume-censer: modifier than_thuc_pct 4 -> stack_duration_pct 20 [kim, debuff]
- `sects/chan_kim.techniques.json` true-gold-canon: passives +stack_effect_pct 12 [kim, debuff]; stack_duration_pct 16 [kim, debuff]; status_resist_pct 20 [poison]; khi_huyet_pct 6.6
- `sects/thoi_tinh.techniques.json` star-quench-canon: passives +stack_effect_pct 12 [kim, debuff]; stack_duration_pct 16 [kim, debuff]

### b4
- `sects/lac_ha.items.json` lh-scribes-reed-brush: new item
- `sects/lac_ha.3.cast.json` ta_quy_yen: wears lh-scribes-reed-brush in place of an 1
- `sects/suong_tung.items.json` st-lantern-maker-brush: modifier + attack_pct 8 [talisman]
- `sects/nam_pho.techniques.json` southern-shore-cloud-canon: passives +attack_pct 6 [talisman]; art_speed_pct 10 [talisman]; status_duration_pct 8
- `sects/nam_pho.techniques.json` mulberry-ink-primer: passives +attack_pct 3 [talisman]; art_speed_pct 5 [talisman]; status_duration_pct 4
- `sects/nam_pho.techniques.json` southern-shore-cloud-canon › Catch the Morning Cloud: tag talisman
- `sects/nam_pho.techniques.json` southern-shore-cloud-canon › Painted Rain: tag talisman
- `sects/nam_pho.techniques.json` southern-shore-cloud-canon › Paper Beam: tag talisman
- `sects/nam_pho.techniques.json` mulberry-ink-primer › Three Wet Sheets: tag talisman
- `sects/nam_pho.techniques.json` mulberry-ink-primer › Blotting Paper: tag talisman
- `sects/nam_pho.techniques.json` painted-beams-dawn-flight › Dawn Flight: tag talisman
- `sects/nam_pho.techniques.json` painted-beams-dawn-flight › Dusk Curtain: tag talisman

### b5
- `sects/thien_xu.items.json` tx-miasma-root-charm: new item
- `sects/thien_xu.2.cast.json` quy_thu_luy: wears tx-miasma-root-charm in place of ngoc_boi 3
- `sects/hoa_cai.items.json` hc-cinnabar-robe: modifier status_resist_pct 15 -> status_resist_pct 30 [poison]
- `sects/chan_kim.techniques.json` true-gold-canon: passives +stack_effect_pct 12 [kim, debuff]; stack_duration_pct 16 [kim, debuff]; status_resist_pct 20 [poison]; khi_huyet_pct 6.6
- `people/loose-south.items.json` ls-miasma-veil-robe: modifier status_resist_pct 15 -> status_resist_pct 30 [poison]

### b6
- `sects/phuong_minh.items.json` pm-tower-rain-chain-sword: new item
- `sects/phuong_minh.cast.json` chu_tri_am: wears pm-tower-rain-chain-sword in place of phi_kiem 3 kim
- `sects/thinh_vu.techniques.json` thunder-in-the-rain-canon: passives +attack_pct 6 [kim]; attack_pct 6 [loi]; resist_pct 150 [lightning]; can_cot 1.33
- `sects/thinh_vu.techniques.json` rain-chain-sword-scripture: passives +attack_pct 6 [loi]; resist_pct 150 [lightning]

### b7
- `sects/thien_xu.techniques.json` heavenly-pivot-true-canon: passives +stack_effect_pct 16 [tho, debuff]
- `sects/cung_tinh.techniques.json` bowing-stars-canon: passives +stack_effect_pct 14 [tho, debuff]
- `sects/cung_tinh.items.json` ct-armillary-ring: modifier + stack_effect_pct 20 [tho, debuff]

### b8
- `sects/thien_xu.items.json` tx-heavenly-weight: modifier + art_speed_pct 10 [seal]
- `sects/thien_xu.items.json` tx-copyist-pair (2 pieces): set bonus modifier + attack_pct 6 [seal]
- `people/loose-north.items.json` ln-digger-kit (2 pieces): set bonus modifier + attack_pct 6 [seal]

### b10
- `sects/tuan_tung.techniques.json` pine-warden-staff-and-bow-canon: passives +attack_pct 6 [bow]; crit_damage_pct 20 [bow]
- `sects/tuan_tung.techniques.json` wolf-winter-arrow › The Leader First: tag bow
- `sects/tuan_tung.items.json` ttg-wolf-winter-bow: modifier attack_pct 18 [physical] -> attack_pct 21 [bow]

### b11
- `sects/da_quang.techniques.json` night-glow-blood-sabre-canon: passives +status_duration_pct 15 [bleed]; attack_pct 10 [bleed]
- `sects/da_quang.techniques.json` night-glow-blood-sabre-canon › Crescent of Red Sand: tag bleed

### b12
- `people/loose-south.items.json` ls-snare-wire-coins: new item
- `people/loose-south.cast.json` sam_van_nuong: wears ls-snare-wire-coins in place of tien_tieu 2 kim

### d1
- `sects/phuong_minh.techniques.json` five-virtue-phoenix-canon › Five-Colour Plumage: art reworded

### d2
- `sects/thien_xu.items.json` tx-envoy-jade-tally: item Effect added: Know the Way Out (Thức Lộ)
- `sects/thien_xu.2.cast.json` phong_bach_ke: holds mf-way-out-knot (not worn)
- `sects/vu_an.techniques.json` mist-lock-array-canon: new passive art: Lost on the Road (Mê Lộ)
- `sects/thinh_vu.cast.json` hua_thanh_diem: holds mf-way-out-knot (not worn)
- `people/loose-south.items.json` ls-thu-am-goat-bell: item Effect added: Know the Way Out (Thức Lộ)
- `people/loose-south.items.json` ls-unlit-sail: item Effect added: Know the Way Out (Thức Lộ)
- `people/market-folk.items.json` mf-way-out-knot: new item
- `people/market-folk.2.cast.json` hoang_phu_duyen: wears mf-way-out-knot in place of ngoc_boi 2
- `people/loose-north.cast.json` nham_do_han: holds mf-way-out-knot (not worn)

### d3
- `sects/lac_ha.techniques.json` sunset-cloud-canon › The Glow Deepens: art reworded
- `sects/lac_ha.techniques.json` sunset-cloud-canon › Last Light on the Field: art reworded
- `sects/tuan_tung.techniques.json` three-nights-on-the-road › Second Night: art reworded

### d4
- `sects/lac_ha.techniques.json` long-sky-one-colour › Geese Startled by the Cold: art reworded (d4; covers duel-readings 3a)
- `sects/nhan_tran.techniques.json` wild-geese-formation-canon › Geese Stance: art reworded (d4; covers duel-readings 3a; lore line kept)
- `sects/nhan_tran.techniques.json` walking-out-of-the-grey › One Breath Down the File: art reworded (d4; covers duel-readings 3a)

### d5
- `sects/thuy_vi.techniques.json` empty-mountain-sutra: new passive art: The Empty Mountain's Answer (Không Sơn Đáp)
- `sects/thuy_vi.techniques.json` green-furnace-canon: new passive art: The Furnace Spills Over (Lô Dật)
- `sects/thuy_vi.items.json` tv-green-moss-mirror: item Effect added: The Empty Mountain's Answer (Không Sơn Đáp)
- `sects/thai_chi.items.json` tc-purple-lingzhi-gourd: item Effect added: The Empty Mountain's Answer (Không Sơn Đáp)

### d6
- `sects/tung_dao.techniques.json` pine-wave-true-canon: new passive art: Answering Wave (Ứng Đào)

### d7
- `sects/thu_phan.techniques.json` autumn-grave-canon › Add a Voice: art reworded (d7; extends duel-readings 3a)
- `sects/thu_phan.items.json` tp-autumn-grave-bell / toll-for-the-dead: item Effect reworded

### d8
- `sects/thien_xu.techniques.json` heavenly-pivot-true-canon: new passive art: The Pole Draws from the Vein (Xu Cực Dẫn Mạch)

### d9
- `sects/thien_xu.techniques.json` dipper-handle-canon: method concept reworded

### d10
- `sects/thinh_vu.techniques.json` rain-chain-sword-scripture: new passive art: Not a Drop Spilled (Bất Lậu Nhất Trích)

### d13
- `sects/thuy_vi.techniques.json` rock-splitting-root › Root in the Crack: art reworded

### d14
- `sects/lac_ha.techniques.json` evening-song-of-the-boats › The Ninth Verse: art reworded (d14; covers duel-readings 3a)

### d15
- `sects/minh_loan.techniques.json` hanging-bells-array › Hang the Bells: art reworded (d15; covers duel-readings 3c)
- `sects/suong_tung.techniques.json` frost-pine-ward-canon › Laid Ward: art reworded (d15; covers duel-readings 3c)

### d16
- `sects/cung_tinh.techniques.json` armillary-array-canon: new passive art: The Twelve Hours (Thập Nhị Thời)

### d17
- `sects/lac_ha.techniques.json` long-sky-one-colour: new passive art: Geese Line (Nhạn Hàng)
- `sects/nhan_tran.items.json` nt-first-file-banner: item Effect added: Geese Line (Nhạn Hàng)
- `sects/tuan_tung.techniques.json` pine-warden-staff-and-bow-canon: new passive art: Geese Line (Nhạn Hàng)

### d18
- `sects/bang_tam.techniques.json` jade-vessel-ice-heart-canon › Heart in the Jade Vessel: art reworded (d18; covers duel-readings 3d, X = 25 %)

### d19
- `sects/da_quang.techniques.json` night-glow-blood-sabre-canon › Wine in the Night-Glow Cup: art reworded (d19; covers duel-readings 3e)

### d20
- `sects/muc_van.techniques.json` cloud-herd-body-canon › The Long Ride: art reworded (d20 chosen over duel-readings 3d; conflict)

### d21
- `sects/thien_xu.techniques.json` army-breaker-spear: method concept reworded
- `sects/thien_xu.items.json` tx-pha-quan-spear / the-called-blow: item Effect reworded (d21; covers duel-readings 3e)

### d22
- `sects/hoa_tinh.techniques.json` painted-dipper-canon › Seven-Star Talisman: art reworded

### d23
- `sects/xuyen_lam.techniques.json` calm-wind-staff-canon: new passive art: The Long Road (Trường Lộ)

### d24
- `sects/coc_vu.techniques.json` good-rain-canon: new passive art: Water Wears the Stone (Thủy Tích Thạch Xuyên)

### d25
- `sects/vong_trieu.techniques.json` lamp-ward-seal-canon: new passive art: The Lamp Flares (Đăng Bùng)
- `sects/vong_trieu.techniques.json` last-lamp-vigil › Bind the Flame: art reworded

### d27
- `sects/vong_trieu.techniques.json` lamp-ward-seal-canon: new passive art: Lamp-Ward (Thủ Đăng)

### d28
- `sects/van_hac.techniques.json` the-monks-rest: new passive art: The Earned Rest (Đắc Hưu)
- `sects/van_hac.techniques.json` the-monks-rest › The Held Rest: art reworded

### d29
- `sects/phat_y.items.json` py-grey-seal (2 pieces): set bonus Effect reworded (d29; covers duel-readings 3e)
- `sects/thinh_vu.techniques.json` rain-chain-sword-scripture: new passive art: Return to the Scabbard (Quy Sao)
- `sects/thinh_vu.items.json` tvl-dalan-suite (2 pieces): set bonus Effect reworded

### d30
- `sects/thoi_tinh.techniques.json` star-quench-canon: new passive art: Brittle from Its Own Blow (Tự Kích Tự Thúy)

### d31
- `sects/chan_kim.techniques.json` true-gold-canon: new passive art: True Gold Does Not Fear the Furnace (Chân Kim Bất Phạ Hỏa)

### d32
- `sects/cuu_cao.techniques.json` crane-bond-rite: new passive art: A Crane for the Rider (Hạc Linh)

### d33
- `sects/thai_chi.techniques.json` hundred-herbs-tasting: new passive art: Bitter Medicine (Khổ Dược)

### d34
- `sects/hong_dau.techniques.json` canon-of-longing › The Second Cup: art reworded
- `sects/hong_dau.items.json` hd-tea-at-the-manor (2 pieces): set bonus Effect reworded
- `sects/hong_dau.items.json` hd-gracious-door-fan / the-second-cup-is-poured: item Effect reworded

### d35
- `sects/hoa_tinh.techniques.json` rainfast-ink-art: new passive art: Rainfast Ink (Vũ Bất Thoát)

### d36
- `sects/phuong_minh.techniques.json` five-virtue-phoenix-canon: new passive art: Birds Pay Court to the Phoenix (Bách Điểu Triều Phượng)
- `sects/phuong_minh.items.json` pm-wutong-twig-ring: new item
- `sects/phuong_minh.2.cast.json` an_thuy_vu: wears pm-wutong-twig-ring in place of nhan 2

### d37
- `sects/chuc_ha.techniques.json` unbroken-thread-canon: new passive art: When the Thread Breaks (Đoạn Ti)

### d38
- `sects/chan_kim.items.json` ck-hallmark-seal: item Effect added: Touchstone (Thí Kim Thạch)

### d39
- `sects/le_tuyen.items.json` ltp-hundred-jars (3 pieces): set bonus Effect reworded
- `sects/le_tuyen.items.json` ltp-hundred-jar-seal / sealed-cask: item Effect reworded
- `sects/le_tuyen.techniques.json` sweet-spring-wine-rite › Open the Cask: art reworded
- `sects/le_tuyen.techniques.json` sweet-spring-wine-rite › Last Cup: art reworded

### d40
- `people/demonic.items.json` dm-karst-lamp: item Effect added: Lullaby of the Karst (Thạch Động Ca)

### d41
- `sects/yen_quang.items.json` yq-dusk-field (3 pieces): set bonus Effect reworded
- `sects/yen_quang.items.json` yq-cold-furnace / unlit: item Effect reworded

### d42
- `sects/muc_van.items.json` mv-dap-van-bridle-ring: item Effect added: Horse and Rider Bear It Together (Nhân Mã Đồng Đảm)

### d43
- `sects/thoi_tinh.items.json` tht-fallen-star-forge (3 pieces): set bonus Effect reworded

### d44
- `sects/nhan_van.items.json` nv-idle-cloud (3 pieces): set bonus Effect reworded

### d45
- `people/market-folk.items.json` mf-carried-array (3 pieces): set bonus Effect reworded

### d46
- `sects/cung_tinh.items.json` ct-armillary-rings (3 pieces): set bonus Effect reworded

### d47
- `people/hermits-sages.items.json` hs-what-the-old-man-kept (2 pieces): set bonus Effect reworded

### d48
- `people/loose-north.items.json` ln-thawing-brazier: item Effect added: Thaw (Giải Băng)

### d49
- `sects/vu_an.techniques.json` mist-lock-array-canon: new passive art: The Wind Lifts the Mist (Phong Khởi Vụ Tán)
- `sects/vu_an.techniques.json` road-mist-primer: new passive art: The Wind Lifts the Mist (Phong Khởi Vụ Tán)

### e1
- `sects/thinh_vu.techniques.json` thunder-in-the-rain-canon: new art: Bronze Answers (Đồng Ứng)

### e2
- `sects/phuong_minh.cast.json` ke_chu_sa: aux + censer-smoke-manual 6
- `sects/thinh_vu.cast.json` o_thiem_tu: aux + censer-smoke-manual 6
- `sects/hoa_cai.techniques.json` canopy-furnace-canon: new art: Pill Smoke (Đan Yên)
- `sects/chan_kim.cast.json` phung_xich_kim: aux + censer-smoke-manual 6
- `people/market-folk.items.json` mf-vermilion-azure-censer: item art added: Pill Smoke (Đan Yên)
- `people/market-folk.techniques.json` censer-smoke-manual: new technique
- `people/hermits-sages.techniques.json` purple-smoke-furnace-canon: new art: Pill Smoke (Đan Yên)
- `people/hermits-sages.2.cast.json` khuyet_van_ha: main dia_hoa 10 -> purple-smoke-furnace-canon 10

### e3
- `sects/phan_vu.techniques.json` burning-feather-body-canon: new art: Into the Vent (Nhập Huyệt)

### e4
- `sects/phuong_minh.techniques.json` shao-remnant-score › Dawn Clouds Take the Colour: art reworded (e4 The Note Holds)
- `sects/phuong_minh.techniques.json` shao-remnant-score: new art: The Next Movement, Remnant Score (Tàn Phổ Tấu Tiếp)
- `sects/phuong_minh.techniques.json` shao-remnant-score: technique Effect Playing Past the Break (Tục Phổ)
- `sects/phuong_minh.techniques.json` nine-shao-advent: new art: The Next Movement (Tấu Tiếp)
- `sects/phuong_minh.techniques.json` nine-shao-advent › Eighth Movement: The Phoenix Is Near: art reworded (e4: played in turn, no stacks needed)

### e5
- `sects/lanh_giang.techniques.json` lone-line-sitting-canon: new art: Landing the Fish (Thu Tuyến)
- `sects/lanh_giang.techniques.json` lone-line-sitting-canon › Line Through the Ice: art reworded (e5: names the Catch bank)
- `sects/lanh_giang.items.json` lg-ice-hook / a-bite-on-the-line: item Effect reworded (e5: names the Catch bank)

### e6
- `sects/tung_dao.techniques.json` pine-wave-true-canon: technique Effect The Fifteenth Layer (Đệ Thập Ngũ Tầng)

### e7
- `people/loose-south.cast.json` do_liet_co: aux + black-wind-blood-sabre 6
- `people/demonic.techniques.json` black-wind-blood-sabre: new art: Drink Within a Breath (Nhất Tức Ẩm)
- `people/demonic.cast.json` khoai_thiet_ung: aux tearing-force-rites -> black-wind-blood-sabre 9

### e8
- `people/demonic.techniques.json` withered-branch-method: new art: Move the Sickness (Di Bệnh)
- `people/demonic.2.cast.json` duong_kho_chi: aux + withered-branch-method 9

### e9
- `people/demonic.techniques.json` black-ice-method: new technique

### e10
- `sects/phuong_minh.items.json` pm-dawn-call-pipe: item art added: Dawn Call (Thần Khiếu)
