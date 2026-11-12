# Job transcript: gear-starter-blade (try 1)

I geared `starter-blade` with seven items and re-ran it. At the same realm it won 20-0 in 7.7 s (17.3 s before), with 94 % health left. The six-row matrix is otherwise unchanged except typical ket_dan+1: it still loses 0-20 but now lasts 10.2 s against 8.0 s. The fight is further outside the 30-60 s band, and I tuned no numbers to change that.

**Loadout:**

| Slot | Item |
|---|---|
| Weapon | `metal-hundred-edge-flying-sword` (grade 3) |
| Armour | `metal-tortoise-scale-armour` (grade 3) |
| Rings | `metal-ring-of-returning-edge` (grade 3), `blade-whetted-ring` (grade 1) |
| Necklace | `metal-whetstone-jade-pendant` (grade 2) |
| Extras | `blade-twin-edge-sword` (grade 2), `metal-iron-temper-ring` (grade 1) |

Thần thức is 28 against a limit of 45, and the third extra slot is empty.

**Art swap:** `flying-sword` came out and `metal-hundred-edge-flight` went in. That art counts as a Hundred-Blades Canon art, one of the build's techniques.

**Effect written:** `eff:Edge Returns the Breath` restores 0.8 % linh lực on each Physical crit. It changed nothing, because the build never runs out of linh lực at the same realm.

**`--without` results (typical truc_co+0):**
- **`--without item:metal-hundred-edge-flying-sword`:** 9.3 s, still 20-0. This removes only the item's modifiers, not its art, so 1.6 s is what those modifiers are worth.
- **`--without eff:Edge Returns the Breath`:** 7.7 s, identical to the geared run.

- **Not modelled:** the Tortoise-Scale ward is left out because it is a cast ward and the engine takes only drain wards; the build keeps its typical ward. The Twin-Edge sword's art isn't slotted because the four art slots are full.
- **Stack cap:** `hundred-edge-notch` clips about 28 times a fight, so most of the Metal stacks it lays are lost to the stack cap.
- **Not fired:** `needle-rain` fires 0.3 times a fight at typical truc_co+0 and never at nguyen_anh+2 or top end.
- **Helper script:** I created a short-lived helper script in `tools/design/combat_sim/` and deleted it. The fight file was then written directly, so nothing outside the two output files remains.

Files are in `design/builds/engine-v3/`:
- `builds/starter-blade.fight.json`
- `starter-blade.md`

GEAR-DONE starter-blade

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/starter-blade.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/starter-blade.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/starter-blade.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/starter-blade.md) instead (Edit rules cover all file-editing tools).
```
