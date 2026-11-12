# Job transcript: unique-mountain-pressing-seal (try 1)

I wrote the fight file and the guide and ran all the fights. The unique doesn't make the build, and I can't confirm its press ever fired.

**Fights**
- At typical Core Formation the build wins 20-0, in 9.1 s with 100 % health left. That is well under the 30-60 s band.
- Against a higher realm or a top-end foe it loses 0-20 every time. Against the top-end foes nothing it carries fires at all.

**The `--without` runs**
- With the seal's modifiers removed, the same fight is 9.2 s instead of 9.1 s.
- With the main technique (Mountain Heart Canon) removed, it is 9.1 s, no change.
- The seal has no Effect of its own; its engine is the art. So the `--without eff:` step doesn't apply. I ran Debt of Stone, the necklace's Effect, instead: 9.8 s.

**The unmodelled stat**
- The engine has no stat for Earth stack effect or stack duration, which is most of what the seal and the Anchor give.
- The one modelled seal modifier, Earth attack +22, shows nothing in these fights.

**The press**
- Mountain Presses the Sky fired once per fight where it fired at all, but the engine doesn't report whether the 10-stack step unlocked. I can't say whether the 4.2× Sundering press ever happened.

**Loadout choices**
- The seal sits in the weapon slot, so the base slots cost no thần thức.
- The Mooring Anchor (30) plus the Mountain-Gate Shield (15) fill the extras at 45, against a limit of 48.15.
- Both rings are placed to fit, and the Boundary Flag doesn't fit beside the Anchor.

Files are in `design/builds/engine-v3/`:
- `builds/unique-mountain-pressing-seal.fight.json`
- `unique-mountain-pressing-seal.md`

UNIQUE-DONE unique-mountain-pressing-seal

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/unique-mountain-pressing-seal.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/unique-mountain-pressing-seal.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/unique-mountain-pressing-seal.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/unique-mountain-pressing-seal.md) instead (Edit rules cover all file-editing tools).
```
