# Water (Thủy) signature arts

8 authored arts in `family-water.json`; `python -I tools/design/arts/lint_arts.py design/arts/family-water.json` gives 0 findings.
Theme: sustain, flow, tides that build and release, linh lực return. The common Water arts (Still Water Palm, Tide Pulse,
Underground Spring, Drawing Breath, Still Pool Mending) stay as they are.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Swelling Tide Palm (Doanh Triều Chưởng) | Build-up, cash-in (uncapped counter, spend) | water arts fired, art speed, trigger damage, crit | Every Water art adds a Tide; the palm at 5+ Tide breaks them all as one free hit per Tide, then resets. |
| Marrow to Dew (Tủy Hóa Lộ) | Paying with health | health cost, healing received, health regen, low health | Pay 5 % health for 20 % linh lực; each heal after returns 1.5 % more. |
| Deep Lake Stance (Thâm Hồ Thế) | Stance / form | regeneration, healing, Water stacks, trigger damage | In the stance: faster regeneration, +30 % healing, a Water stack a pulse, −30 % damage. |
| Gathering Wave (Tụ Ba) | Held payload ("your next hit") | art speed, hit count, crit, banked cap | Banks up to 4 waves; the next landed hit releases them as free hits and heals. |
| Seep-Through Palm (Thấm Cốt Chưởng) | Conversion | physical and water damage, art speed | Half Physical, half Water, so it meets both defences; each hit speeds your other arts 0.4 s. |
| Backwash Seal (Hồi Lưu Ấn) | Echo / repeat | water arts fired, heavy arts to echo, echo power | Every 3rd Water art is repeated at half power and returns 2 % linh lực. |
| Drag of the Deep (Thâm Uyên Kéo) | Delay, Slowed Time curse pattern | slowed time stacks, timer delay, art speed | Stacks Slowed Time, delays the foe's slowest art 1 s; more stacks, more linh lực to you. |
| Brimming Cup (Doanh Bôi) | Shield and overflow as a weapon | overflow, body shield size, shield breaks | Restores linh lực and raises a shield; overflow and shield breaks become free hits. |

## Library arts replaced

- Water Curtain (Thủy Liêm Chướng) → Brimming Cup.
- Ebb and Flow (Triều Tịch) → Marrow to Dew and Deep Lake Stance (heal-feeds-Water is now carried by the stance and by Marrow's heal return).
- Kept as they are: Spring at the Well's Mouth, Drowning Palm, Ninth-Weight Lance.

## Not expressed or not verified

- **Lint only checks the schema.** I did not run these on the fight engine. Points to check there: that `own.state.deep-lake`, `foe.status.slowed_time` and `own.counter.tide` read as stack or count values inside `scale`; that `set` on `counter` is not multiplied by the `scale` factor (Swelling Tide Palm relies on it); that the `hold` of Gathering Wave releases on a basic hit too.
- **State mod units.** `states[].mods` units are inferred from the engine (`regen` and `hregen` as fractions, `healing` in percent, `dmg_more` as a fraction); content-formats.md does not state them.
- **Stance suppression** needs art ids; Deep Lake Stance suppresses nothing, because a stance cannot name "all Water damage arts" (missing piece: a tag-scoped `suppress`).
- **Trigger budget.** Free hits are clipped by the trigger budget and cap, so Swelling Tide Palm and Gathering Wave at high counts may clip; a "waves" split that grows with a counter (a variable `split`) cannot be written.
- **Conversion** works only to a damage type (`convert`), so "Water converts into healing" or into linh lực is not expressible.
- No summon in this family: a Water summon (a living tide that heals) needs a companion heal target, which the engine lacks.
