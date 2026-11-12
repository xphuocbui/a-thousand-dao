# Job transcript: gear-status-collector (try 1)

I geared `status-collector` with seven named items. Gear changed the fight only a little: top-end foes died faster, typical foes did not. I wrote the fight file and the guide.

The guide covers the Loadout, Before and after, Upgrades, Missing pieces, UNMODELLED and Observations sections you listed.

**Loadout.**
- **Base slots:** Balance-Sheet Seal as the weapon, Hollow Robe as the armour, Deep Freeze Ring (a unique) and Hollow Ring as the rings, and Ledger-Murmur Pendant as the necklace.
- **Extra slots:** Ledger Branding Iron and Black Ledger Mirror use 33 thần thức of a 51.3 limit, with four extra slots left empty.
- **Art swap:** Settle the Account (from the Seal) replaces `blight-canker`, so the build loses Poison as a status kind.
- **Marked Prey:** I wrote it as `eff:Marked Prey`, +4 L5 per different status on the foe, capped at +16.

**Results.** The old file was re-run on the current engine, so its numbers differ from the v2 guide's 1.6 s and 4.0 s. All runs were 20-0-0.

| Matchup | Mean s, old | Mean s, geared |
|---|---|---|
| typical | 2.9 | 2.9 |
| top_end | 6.5 | 5.4 |

Both are far under the 30-60 s band.

**`--without` tests.**
- Removing `eff:Marked Prey` moves top_end from 5.4 to 5.9 s. It changes nothing on typical.
- Removing the Balance-Sheet Seal or the Branding Iron changes nothing on either foe.
- On typical, Settle the Account and four other arts never fired. On top_end all arts fired.

**UNMODELLED.** The engine cannot express Toll Taker, Deep Freeze, the pendant's reserve art, or the stack and status-duration passives. The Hollow Veil ward is not run because the build's own ward is stronger. Each is listed with its reason in the guide.

Files are in `design/builds/engine-v3/`:
- `builds/status-collector.fight.json`
- `status-collector.md`

GEAR-DONE status-collector

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/status-collector.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/status-collector.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/status-collector.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/status-collector.md) instead (Edit rules cover all file-editing tools).
```
