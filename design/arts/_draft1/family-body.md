# Family: element-less body forms (fist, palm, thể tu)

7 signature arts in `family-body.json`, linted: 0 findings. Numbers are first guesses; none tested in a fight yet.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Rolling Barrage Fist (Cổn Liên Quyền) | Charges and bursts | charges, crit, cooldown cut, art speed | 4 charges of quick fist hits; each firing stacks +6 % crit, crits shorten other timers |
| Mountain Root Stance (Sơn Căn Thế) | Stance / form | damage taken, block, body shield, thorns | Toggle: 20 % less damage taken and a strike back on every hit, but 20 % slower and the Barrage Fist is suppressed |
| Marrow Tithe (Tủy Cống) | Paying with health | health cost, linh lực regen, cost reduction, low health | Pay 8 % health for 18 % linh lực and 40 % cheaper arts for 5 s |
| Last Breath Fist (Tàn Tức Quyền) | Conditional payoff (low health) + refused fall | low health, refused fall, dmg more, healing | More damage per 10 % health missing; once a fight, refuse a fall and surge |
| Answering Palm (Ứng Hưởng Chưởng) | Echo / repeat | echo, art speed, crit, heavy arts | Every 3rd palm art refires your last art at 60 % |
| Twin Shadow Fist (Song Ảnh Quyền) | Summon | companion speed, crit, summon | Calls a 12 s double that strikes every 2.5 s; art crits quicken it |
| Bulwark Knuckle (Thuẫn Quyền) | Shield as a weapon | body shield, shield size, force, dmg more | Raises a body shield; the hit grows with shield held; a broken shield bursts for a Force hit |

## Replaces

No library art is replaced: the `common` fist and palm arts (Iron Fist, Qi-Shaking Palm, Shockwave) stay. Rolling Barrage
Fist and Twin Shadow Fist stand beside Iron Fist as its authored upgrades (`sources` lists `iron-fist` for the former
only as lineage). Shattering Fist (strip) was left alone; it is a control art, not a body form.

## Engine gaps

- **Held payload ('your next art')**: `held` exists on Effects, but no art here could use it without a readable for
  art tags; Marrow Tithe uses a timed `cost_red` mod instead. Missing piece: "next art" mod scoped by art tag.
- **`own.charges` readable**: Rolling Barrage Fist cannot pay off on its last charge or when empty.
- **Echo recursion**: Answering Palm resets its counter before `fire_art` and limits itself to once a pulse, because
  an echo's own firing may count as a palm art; I did not verify how `fire_art` interacts with `art_fired`.
- **Refused fall rider**: Last Breath Fist's heal and mod sit beside `refuse_down` on the `down` event; the engine
  reads only `refuse_down` there (and needs the build's `refusals` field, which the art cannot grant), so heal and mod
  may not run. Also the stance's thorns use `self_hit` as written in the engine (hit on the foe).
- **Split hits, Slowed Time/delay, curses and build-up/cash-in** are covered by other families, not this one.
