# Job transcript: unique-vajra-hide-armour (try 1)

I wrote the build file and the guide and ran the matrix and the `--without` tests. The unique does not make the build. One of the requested `--without` tests could not run.

- **Build:** a Core Formation (ket_dan) Earth build, purity 60, built on Unbroken Flesh Canon with Mountain Heart Canon and Mountain Bone Body Art. It has five arts, three extra pieces at 43 thần thức against a limit of 46.35, and grade 4 at most.
- **Matrix:** it wins typical ket_dan+0 in 12.0 s (20-0) and typical nguyen_anh+1 in 61.2 s (20-0). It loses typical hoa_than+2 and every top_end matchup, where none of the five arts ever fired.
- **Unique's modifiers:** removing the armour's modifiers changes nothing at the same realm. At nguyen_anh+1 it is 1.5 s slower, with health left 90 % against 89 %. The engine reads only the armour's block +15; its shield, regeneration, khi huyết and defence modifiers have no engine stat.
- **Unique's Effect:** written as an 8 % heal plus an 8 % shield deduction on the Tithe firing, with the 20 % healing closes. Removing it raises health left from 89 % to 93 % at nguyen_anh+1, so as modelled it is slightly negative.
- **Main technique:** `--without tech:unbroken-flesh-canon` stopped with `WITHOUT_NOT_FOUND`, because none of that technique's passives has an engine stat and so no `tech:` Effect exists. I ran `--without marrow-tithe-strike` instead: at nguyen_anh+1 it is 65.3 s, 19-0-1, health left 67 %.
- **Last Marrow:** the fight output does not show whether the x11 step ever opened, so the guide does not claim it did.

The guide also covers the loadout, upgrades, missing pieces and UNMODELLED lines. Planted Banner matches its catalogue record, but I copied Iron Skin Renewed from `starter-wall.fight.json` without checking it against the item catalogue.

Files are in `design/builds/engine-v3/`:
- `builds/unique-vajra-hide-armour.fight.json`
- `unique-vajra-hide-armour.md`

UNIQUE-DONE unique-vajra-hide-armour

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/unique-vajra-hide-armour.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/unique-vajra-hide-armour.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/unique-vajra-hide-armour.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/unique-vajra-hide-armour.md) instead (Edit rules cover all file-editing tools).
```
