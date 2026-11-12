# The Dry Well (Khô Tỉnh): an Ice-stacking Water-root cultivator whose Winter Toll suite taxes the foe's art costs until it runs dry, now geared with seven Ice items.

Realm Nguyên Anh (nguyên anh, `nguyen_anh`), root Water 90 + Ice 72. Files: `builds/dry-well.fight.json` (old: `design/builds/engine-v2/builds/dry-well.fight.json`).

## Loadout

Extra-slot limit: 45 × divine_sense 1.0 × (1 + total than_thuc_pct / 100). The build file carries no `divine_sense`, so it is 1.0. The limit is taken at its base of 45, not raised by the 7 % thần thức the equipped items give, so there is a little room that goes unused.

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Winter Toll Seal (Đông Toán Ấn, `ice-winter-toll-seal`) | 3 | Its art Toll Stamp counts as a Winter Toll Canon art, and it carries Ice stack duration and cold art speed. |
| Armour | Glacier Plate (Băng Xuyên Giáp, `ice-glacier-plate`) | 3 | The one Ice armour; health and status resistance. Its cast shield does not beat the build's drain ward, so the ward stays as it was. |
| Ring 1 | Deep Freeze Ring (Thâm Đống Giới, `ice-deep-freeze-ring`) | 4 unique | Extra Ice stack per application, cold art speed, Ice stack duration; the Frost Lock's keystone piece. |
| Ring 2 | Rimed Band (Sương Giới, `ice-rimed-band`) | 1 | Ice stack effect +20 %, a little health and linh lực regeneration. |
| Necklace | Sleeping Marrow Pendant (Miên Tủy Bội, `ice-sleeping-marrow-pendant`) | 2 | The only Ice necklace; the build has no heal, so this is the least relevant piece. |
| Extra 1 | Moonrime Flying Sword (Nguyệt Sương Phi Kiếm, `ice-moonrime-sword`) | 4 unique | Its art Moon Stills the Tide counts as a Stilled Hour Sutra art and spends Ice stacks. TT 20. |
| Extra 2 | Black Ledger Mirror (Huyền Trướng Kính, `ice-black-ledger-mirror`) | 3 | Ice stack duration +35 %, effect +30 %, and Toll Taker (not run). TT 18. |

Thần thức: 20 + 18 = **38 of 45**. Five extra slots are allowed, two are used; the next best piece (Hoarfrost Tide Shield, TT 15) would make 53, over the limit. The other items were left out for the TT or because they do nothing here.

Arts swapped in (six art slots as before): Toll Stamp replaces Shatter Palm; Moon Stills the Tide replaces Black Ice Glaze. Deep Winter Form, Rime Lock Seal, Sleet Volley and Stilled Instant stay. The build's ward is unchanged (nothing from the items beats it).

## Before and after

Twenty fights each, seeded, from `--matrix`. Old = the engine-v2 file run today (its guide's numbers were from an earlier engine state and are not used).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 7.5 | 6.8 | 20-0-0 | 20-0-0 |
| typical hoa_than+1 | 63.5 | 64.8 | 20-0-0 | 20-0-0 |
| top_end nguyen_anh+0 | 18.1 | 17.1 | 0-20-0 | 0-20-0 |
| top_end hoa_than+1 | 11.9 | 10.2 | 0-20-0 | 0-20-0 |

Other readings: at typical hoa_than+1 health left fell 66 % → 49 % and the build ran dry at 14.5 s (old 17.4 s); at top_end nguyen_anh+0 the foe ran dry at 10.8 s (old 11.4 s) and the build at 12.5 s (old 14.7 s); at top_end hoa_than+1 the foe never ran dry geared (old 8.5 s).

`--without` (top_end nguyen_anh+0, geared 17.1 s, 0 wins):

| Removed | Mean s | Wins | Foe dry |
|---|---|---|---|
| `item:ice-winter-toll-seal` (its modifiers; the art stays) | 17.1 → 18.5 | 0 → 0 | 10.8 → 13.3 |
| `item:ice-moonrime-sword` (its modifiers; the art stays) | 17.1 → 17.7 | 0 → 0 | 10.8 → 12.5 |
| `item:ice-deep-freeze-ring` (its modifiers; the Effect is not run) | 17.1 → 17.7 | 0 → 0 | 10.8 → 13.9 |

No `--without eff:` run: no item Effect could be written for the engine (see UNMODELLED).

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Ring | Deep Freeze (Effect) | Rime Lock repeating at every 10 Ice stacks | Northern Nascent Soul Ice cultivator, or a frozen lake | In (`ice-deep-freeze-ring`, worn, not run) | High |
| Extra | Toll Taker (Effect) | Linh lực back from the foe's inflated art cost | Event, craft, npc | In (`ice-black-ledger-mirror`, worn, not run) | High |
| Weapon | drain-ward bill raise (`ward_bill_pct`) | The Weighted Bucket / Absolute Zero payoff the guide leans on | Any | Missing as an item piece | High |
| Ring or necklace | stack_effect_pct, stack_duration_pct on Ice | More from every Ice stack | Craft | Partly in (Rimed Band, grade 1 only) | Medium |
| Necklace | linh lực sustain (regeneration or on-hit) | Stops the build running dry at 12–14 s | Any | Missing for Ice | Medium |
| Armour | cast shield that beats the drain ward | A ward worth modelling | Quest | Not in the catalogue for a drain ward | Low |
| Extra | Hoarfrost Tide Shield (`ice-hoarfrost-tide-shield`, TT 15) | Ward gear | Craft | In, over the TT limit with the two extras | Low |

## Missing pieces

- An item that raises the bills the foe's drain wards pay (the Weighted Bucket line): Ice, with Water as the second owner.
- An item for the Owed Water idea, linh lực debt repaid to the wearer: Water.
- A necklace with Ice or Water sustain that is not a reserve art (the build runs dry before the foe in three of four rows): Water.
- A cheap utility piece (TT 7 or less) so the last 7 points of the 45 can be filled: Ice.

## UNMODELLED

- Deep Freeze (Thâm Đống, Deep Freeze Ring): the engine has no event for Ice stacks crossing a multiple of 10; its close (arts cost 10 % more) goes with it.
- Toll Taker (Black Ledger Mirror): no readable for the extra art cost the foe pays because of your Ice stacks.
- Shattering Ward (Glacier Plate): fires on a shield breaking; the build's ward is a drain ward, so there is no shield.
- Glacier Shell ward: does not beat the build's ward; the drain ward stays.
- Reserve arts (Winter Sleep Aura, Cold Ledger Aura, 25 % of linh lực in all): reserved shares are not deducted and their grants are not run.
- Item modifiers with no engine stat (stack effect, stack duration, linh lực %, khí huyết %, defence %, status resistance, pierce, thần thức %): not run. Cold-scoped art speed applies to every art in the engine.
- All the old file's lines (Absolute Zero, Owed Water, Water Table, Frost Tithe, Still Water, Weighted Bucket, Cracked Clay, shields, #44 defence, v1 fields) are carried unchanged.

## Observations

Gear mattered a little and did not change a result: every win and loss is the same as before, and means moved by about a second (typical +0 7.5 → 6.8 s, top-end +0 18.1 → 17.1 s, top-end +1 11.9 → 10.2 s), while typical hoa_than+1 got slightly longer (63.5 → 64.8 s) and ended with less health (66 % → 49 %). The pieces that carry the build's concept, Deep Freeze, Toll Taker and Shattering Ward, are not run, so the gear here is mostly modifiers the engine reads as cold art speed; the `--without` runs show the Toll Seal, Moonrime Sword and Deep Freeze Ring each cost 0.6–1.4 s when removed, and the foe runs dry 2.5–3.1 s later without the Seal or the Ring. Only the hoa_than+1 typical fight sits in the 30-60 s band (64.8 s, just over it); typical +0 is 6.8 s and top-end 10–17 s, all under. No item made the build degenerate. Every swapped-in art fired in every row (Toll Stamp 2.0 to 6.0 times a fight, Moon Stills the Tide 3.0 to 11.9); no art or item fired nothing, but Glacier Plate, the Sleeping Marrow Pendant and the Black Ledger Mirror contribute nothing the engine runs. The `--without` tests removed an item's modifiers only, and ran at top_end nguyen_anh+0.
