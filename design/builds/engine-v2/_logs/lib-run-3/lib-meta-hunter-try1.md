# Job transcript: lib-meta-hunter (try 1)

I rebuilt `meta-hunter` from the library and fought it on engine v2. The write-up is in `meta-hunter.md`. It is a "hunter" built on Hunter's Reach Canon (main) plus Nine Seal Ledger (secret), both `kim`. All six arts unlock by layer 6.

Against a typical foe the fight lasts 1.8 s at Nguyên Anh, far under the 30–60 s band. No art fires in it, so all six are NEVER_FIRED. Against top_end it lasts 4.5 s and wins 20-0.

I ran the matrix, `--without tech:hunters-reach-canon` and `--without branding-seal`. I also ran the Kết Đan file once without `--matrix`.

- **Technique test:** removing Hunter's Reach Canon changes nothing in any matchup.
- **Art test:** removing Branding Seal changes nothing against a typical foe. Against top_end the fight goes from 4.5 s to 14.8 s, and one realm up it goes from 17-3 to 0-20.
- **Kết Đan:** 2.4 s against a typical foe, 20-0, with Branding Seal NEVER_FIRED.
- **Lost:** Dear Blood and Called Debt, Clean Ledger and the Stagnation cleanse have no library equivalent. The old file held no Effects, so none were removed.
- **Dropped at Kết Đan:** Frozen Hour Seal, because six arts unlock but there are only five slots.

I read only the Branding Seal, Ambush Talisman and Frozen Hour Seal rules from the INDEX one-liners, not the full family file. Pinning Arrow, Coiling Thrust, Nocked Arrow and Frozen Hour Seal lay Slowed Time, and I left it to you whether that breaks the "never stall a foe" oath. The oath is only modelled as no Stagnation and no health payment.

I picked Branding Seal as the identity piece for the second `--without` test, and the build file was not edited after that choice.

LIB-DONE design/builds/engine-v2/meta-hunter.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/meta-hunter.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/meta-hunter.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/meta-hunter.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/meta-hunter.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/meta-hunter.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/meta-hunter.md) instead (Edit rules cover all file-editing tools).
```
