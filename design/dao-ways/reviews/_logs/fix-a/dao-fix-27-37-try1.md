# Job transcript: dao-fix-27-37 (try 1)

I revised the 11 drafts, 27-sinh-tu through 37-lien, and wrote the triage file. I did not run any check on the edits.

- **Pointed:** about 26 of the 61 `Needs rule` / `Needs key` labels now cite an accepted decision (R1–R7, R10, R13, R14, R15a, R18, R20, R22) or a key.
- **Left:** the rest stay as they were because no decision covers them. Examples are the Ghost Fire soul tick, the Rebirth second loadout, the `delayed` tag and Corpse Lord's stacking.
- **Deferred:** nothing in these 11 Ways relies on a deferred decision, so none got a `(deferred, …)` tag.
- **Row fixes:** the earlier in-session triage had already fixed the `batch-27-37.md` rows. I found nothing left open except the unflagged `status_duration_pct`. I noted in Sinh Tử, Bỉ Ngạn, Hoàng Tuyền and Quỷ that the key now exists and curse durations clamp to 1–5 pulses.
- **Bounds applied:** Karma and the Every Blow Comes Home payout now use `bypass_share` 50 %. Skull Ward's Soul stop dropped to 30 %. Bone Wall now sits inside the avoid budget of 2 a pulse. Seed of Rebirth now refuses to health 1 and then heals.
- **My choice to review:** Skull Ward needed a closing cost to meet R3's "each source closes something real". I made it "Plates regrow 1 s slower". Swap it if you want a different one.
- **Untouched:** nothing about Băng's Absolute Zero or Cold Toll, and no life-bonus caps added.

FIX-DONE design/dao-ways/reviews/fix-27-37.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/dao-ways/reviews/fix-27-37.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/dao-ways/reviews/fix-27-37.md) instead (Edit rules cover all file-editing tools).
```
