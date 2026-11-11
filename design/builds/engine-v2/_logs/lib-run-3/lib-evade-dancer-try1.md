# Job transcript: lib-evade-dancer (try 1)

I rebuilt `evade-dancer` from the library and ran it on engine v2; the write-up is in `design/builds/engine-v2/evade-dancer.md`. Fights are far shorter than the 30–60 s band: 1.7 s against a typical same-realm foe, 9.2 s against a top-end one.

- **Build:** Gale Courier Scripture as the main technique and Slow Hour Scripture as the secret. The Nguyên Anh file carries six arts and the Kết Đan file five. Each art's technique and layer are in the md.
- **Left out:** I did not slot Swallow Stance (it slows arts 25 %) or Reckless Gale (it pays health). The Kết Đan file also drops Three-Step Chase because it has only 5 slots.
- **Lost:** Scatter Gale's evade-cleanse of your own stacks has no library equivalent, so Carried Off stays unmodelled and the build has no modelled answer to ticks. The old per-art Wind stacks and Hollow Step's linh lực restore are also gone.
- **Arts that never fire:** against the typical same-realm foe all six arts are `NEVER_FIRED` at Nguyên Anh, because the foe dies before the first art is ready.
- **Top-end foes:** the same-realm top-end foe is a 20-0 win, not the guide's even fight (13-6-1). One realm higher you lose 0-20, as the guide says.
- **Removing Echo of the Dodge:** the top-end same-realm result drops from 20-0 to 13-7, so it carries the build. Removing the main technique costs two wins.
- **Extra `--without` runs:** I also ran `--without echo-of-the-dodge` and `--without tech:slow-hour-scripture`; both are in the md.

I wrote a temporary helper script into `tools/design/combat_sim/` and deleted it after the sandbox refused to run it, so the final tree holds only the two fight files and the md.

LIB-DONE design/builds/engine-v2/evade-dancer.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/evade-dancer.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/evade-dancer.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/evade-dancer.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/evade-dancer.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/evade-dancer.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/evade-dancer.md) instead (Edit rules cover all file-editing tools).
```
