# Job transcript: gear-evade-dancer (try 1)

I geared `evade-dancer` with eight Wind-family items and wrote the fight file and the guide. Gear changed fight length a little and no results; the keystone item's Effect could not be modelled.

**Loadout:**
- **Base slots:**
  - weapon: Nine-Gale Heron Fan (`wind-heron-fan`, grade 4);
  - armour: Cloud-Walker's Mantle (`wind-cloud-walker-mantle`, grade 4);
  - rings: Ring of Hollow Echoes (`wind-hollow-echo-ring`) and Gale-Step Ring (`wind-gale-step-ring`);
  - necklace: Swallow-Tail Pendant (`wind-swallow-tail-pendant`).
- **Extra slots:** Four-Winds Banner (`wind-four-winds-banner`), Windbreak Shield (`wind-windbreak-shield`) and Stitchwind Needles (`general-stitchwind-needles`).
- **Thần thức:** 20 + 15 + 10 = 45, exactly the limit of 45.
- **Art swap:** Heron Takes Wing replaces Gale Sprite in the sixth art slot.

**Results** (20 runs each):

| Matchup | Old | Geared |
|---|---|---|
| typical, same realm | 2.0 s, 20-0 | 1.9 s, 20-0 |
| typical, one realm higher | 3.8 s, 20-0 | 3.1 s, 20-0 |
| top end, same realm | 15.9 s, 20-0 | 10.5 s, 20-0 |
| top end, one realm higher | 8.6 s, 0-20 | 8.7 s, 0-20 |

- **Fan test:** `--without item:wind-heron-fan` shifts means by 0.1–0.4 s and changes no result.
- **Effect test:** `--without eff:Wind at Your Back` showed no change in the typical same-realm fight (1.9 s, 20-0). I did not run it at top end.
- **Fight length:** all fights are well under the 30–60 s band. Nothing degenerated.
- **Never fired:** against the typical same-realm foe, `hundred-feather-flurry`, `three-step-chase`, `trailing-gale` and `wind-heron-takes-wing` never fire.
- **Old numbers:** the old file's fresh run differs slightly from the old guide's table (2.0 s against 1.7 s for the typical same-realm fight).

**Unmodelled:**
- **Phantom Dodge (the fan's keystone):** the engine cannot turn a basic attack into an evade event, which is why the fan barely matters.
- **Echo, Cold Feet and Beneath Notice:** I was not allowed to read `effects.md`, so I wrote no engine form for them rather than guess.
- **Item wards:** neither the Mantle's ward nor the Windbreak Shield's cast shield is a drain ward, so the build's own ward stays.
- **Other gaps:** the two reserve arts and several modifiers (stack effect on Wind buffs, `than_thuc_pct`, `khi_huyet_pct`, `defense_pct`, `linh_luc_pct`) have no engine stat.

I modelled one Effect, `eff:Wind at Your Back`, as an `evaded` trigger that adds one Wind stack for 4 s, at most 2 per pulse.

Files are in `design/builds/engine-v3/`:
- `builds/evade-dancer.fight.json`
- `evade-dancer.md`

GEAR-DONE evade-dancer

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/evade-dancer.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/evade-dancer.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/evade-dancer.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/evade-dancer.md) instead (Edit rules cover all file-editing tools).
```
