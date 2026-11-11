# Job transcript: lib-one-art (try 1)

I rebuilt `one-art` on the library cleave and fought it, but this is a partial result. The old `one-art*.fight.json` files don't exist: the glob found only the guide, a sheet and a driver note. The realm, layers, crit, art speed and effects therefore come from the guide, not from an old file.

- **Fights:** I wrote only `builds/one-art.fight.json`, for Deity Transformation (Hóa Thần), because no old fight file named another realm. The matrix has no +1 realm above Hóa Thần.
- **Typical foe, same realm:** the build wins 20 of 20 in 8.1 s, far below the 30-60 s band.
- **Top-end foe, same realm:** the build loses 20 of 20 in 1.6 s, and the cleave never fires (NEVER_FIRED).
- **Build:** the main technique is `nine-temper-scripture`, with `hundred-blades-canon` and `afterimage-sword-canon` as secrets. The one art is `shatter-edge-cleave`, in place of the invented Grindstone Stroke.
- **`--without` tests (typical, same realm):**
  - Without `tech:nine-temper-scripture` the result barely moves: 8.1 s and 79 % health left, against 80 % with it.
  - Without `empty-hall` the fight lengthens to 10.4 s with the same 20 wins, so the build's identity piece costs time but not the result.
- **Lost in the move:** the Vow's 6.75-9.55 coefficient is gone, since arts take no overrides. Each Empty Hall ring's free echo hit is also gone, so only its Metal stacks are modelled.

LIB-DONE design/builds/engine-v2/one-art.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/one-art.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/one-art.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/one-art.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/one-art.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/one-art.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/one-art.md) instead (Edit rules cover all file-editing tools).
```
