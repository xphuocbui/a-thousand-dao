# Job transcript: family-fire (try 1)

I wrote 8 Fire signature arts to `design/arts/family-fire.json`, and the lint prints 0 findings. I did not run any of them in a fight, so none is tested in play.

The arts, each with its own shape:
- **Flint Volley:** 3 charges, each laying Burn.
- **Furnace Heart:** Heat builds with Fire hits, then vents Burn into free hits at 10 Heat.
- **Brazier Form:** a toggled stance with a damage and speed trade, where hits you take lay Burn on the attacker.
- **Scorch Fist:** Physical hit, half converted to Fire.
- **Blood-Fed Pyre:** pays health and deals more the lower you are.
- **Ash Rebirth:** Burn ticks gather Ash; once per fight you refuse Down and heal per Ash.
- **Twin Flame Echo:** every third Fire art triggers a half-strength repeat of your last art.
- **Heat Haze:** Burn at 25 stacks or more adds Slowed Time on each tick.

`design/arts/family-fire.md` has the table, the arts they replace (Burning Reply, Cinder Cloak, Flare Up), and the engine gaps:
- **Ash Rebirth:** scaling the heal by Ash and then resetting Ash needs a second `down` Effect and relies on Effect order.
- **Brazier Form:** `suppress` takes art ids only, so it suppresses Ember Rain by id, not by tag.
- **Furnace Heart:** it assumes the Heat grant resolves before the vent; the engine has no ordering between the two events.
- **Twin Flame Echo:** "last" may refire the echo art itself.
- **Scorch Fist and Blood-Fed Pyre:** these use a tag-filtered `dmg_more` under an `always` scale, which is only linted.
- **Flint Volley:** there is no c_art budget per volley.

I left out a summon and a shield-as-weapon art, so those two shapes are not covered in this family. Eight arts rather than seven.

FAMILY-DONE design/arts/family-fire.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-fire.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-fire.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-fire.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-fire.md) instead (Edit rules cover all file-editing tools).
```
