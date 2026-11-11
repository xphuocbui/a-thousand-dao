# Job transcript: family-thunder (try 1)

I wrote eight Thunder (Lôi) arts to `design/arts/family-thunder.json`, and the lint prints 0 findings (`checked 8 arts`). The lint checks the schema and the art numbers; I have not run a single one in a simulated fight.

| Art | Mechanic shape |
|---|---|
| Capacitor Palm (Tụ Lôi Chưởng) | Build-up, then cash-in: each landed Lightning art stores a Charge, and the Palm releases them all as strikes. |
| Stormcloud Familiar (Lôi Vân Linh) | Summon: a cloud that strikes for 9 s, and its crits lay Thunder stacks. |
| Overload Form (Quá Tải Thể) | Stance: more art speed and crit, less evade, with a lightning backlash on your own crits. |
| Chain Arc (Liên Hoàn Lôi) | Split hits: five sub-hits, each crit raises crit chance for the rest of the chain. |
| Answering Peal (Hồi Lôi) | Echo: every 3rd crit fires your last art again at 60 %. |
| Thunderclap Bind (Lôi Phược) | Delay: applies Slowed Time, and crits on a slowed foe push its longest cooldown back. |
| Tribulation Seal (Kiếp Lôi Ấn) | Conditional payoff: at 8+ Thunder stacks on the foe, lightning strikes every pulse, scaling with the stack count and uncapped. |
| Storm Bank (Tích Lôi Ngân) | Charges and bursts: three back-to-back bolts paid partly in health, each adding a stacking damage bonus. |

`design/arts/family-thunder.md` has the table with hooks and one-line rules, which library arts each one replaces, and the engine gaps.

The gaps that matter most:
- **Chain Arc:** the crit ramp assumes each sub-hit rolls its own crit and fires a crit event in sequence. A fight run needs to confirm that.
- **Answering Peal:** `fire_art` repeats the last art fired, with no Thunder-only filter, so it can echo a non-Thunder art.
- **Overload Form:** a state can only suppress arts by id, not by tag, so a "heavy arts suppressed" trade-off can't be written.
- **Capacitor Palm and Tribulation Seal:** their `free_hit` strikes are clipped by the trigger budget, so large Charge or stack counts don't scale without limit.
- **Not written:** an Iron Spark-style Physical conversion art and a shield or heal as a weapon; both need engine pieces.

I did not edit the `part-*.json` files, so the original Thunder arts still exist until triage merges this one.

FAMILY-DONE design/arts/family-thunder.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-thunder.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-thunder.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-thunder.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-thunder.md) instead (Edit rules cover all file-editing tools).
```
