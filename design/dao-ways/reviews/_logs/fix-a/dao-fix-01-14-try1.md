# Job transcript: dao-fix-01-14 (try 1)

I revised all 14 drafts and wrote the triage file. Nothing was run or tested; this was prose editing only.

The batch 01–14 review rows were already fixed in the earlier in-session triage, so no old rows were open. This pass pointed labels at the accepted rules, fit pieces to the rule bounds, and fixed a few bound breaks I found while pointing.

Bound breaks fixed:
- **Vô Cực:**
  - Return to One's major wrote a layer, but layer writes are capstone only (R15d). The major is now a read, and the capstone holds the write.
  - Before Taiji skipped ward shields at 100 %. It is now `bypass_share` 50 % (R2).
- **Tinh:** Array in the Sky carried at 60 % in ambush and blind fights. It is now 100/70/50 % (R9).
- **Thời:**
  - Slowed Time was 4 % per stack and Stopped Heaven raised the cap to 10. It is now 6 % per stack, cap 5 and 3 pulses (R1).
  - Stopped Heaven now applies 2 stacks per hit and lasts 5 pulses instead.
- **Hỗn Độn:**
  - Before the Forms now says it still meets resistance, block and body shield (R2).
  - Primal Mixing now uses `consume` (R19).

Two edits create things the Status Catalogue doesn't have yet:
- Mệnh's Ill Star now works through a named curse (R17, R21). That curse is new and needs a Status Catalogue row.
- Càn Khôn's Torn Ward now applies Leaking Ward, which does exist in the catalogue, instead of changing the foe's ward bill directly (R21).

Deferred and untouched:
- Only Âm Dương's pool swap is marked `(deferred, R12)`. None of these Ways had thần thức theft, overdraw or Dream window labels.
- Hỗn Độn's `dao_offer_size` needs a rule no decision covers. It stays labelled.
- I did not touch Băng's Absolute Zero or Cold Toll, and I added no caps for life-earned bonuses or resistance.

The file lists Fixed, Pointed, Deferred and Left per Way, plus notes for the main session.

FIX-DONE design/dao-ways/reviews/fix-01-14.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/dao-ways/reviews/fix-01-14.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/dao-ways/reviews/fix-01-14.md) instead (Edit rules cover all file-editing tools).
```
