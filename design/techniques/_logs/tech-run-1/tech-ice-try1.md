# Job transcript: tech-ice (try 1)

I wrote two ice techniques, one per suite, and the lint reports `checked 2 techniques, 0 findings`.

- **Winter Toll Canon (Đông Toán Kinh):** Profound, main method, names `bang`, 9 layers, 15.8 of 16 W.
- **Stilled Hour Sutra (Đình Thời Kinh):** Heaven, secret art, names `bang`, 15 layers, 31.9 of 32 W.

**Carriers:** none. All 8 ice arts have a `group`, so no carrier techniques were needed.

**Unlock layers:** every suite art unlocks by layer 6, with the opener first and the payoff art last.
- Winter Toll Canon: Rime-Lock Seal at layer 1, Deep Winter Form at 2, Black Ice Glaze at 4, Shatter Palm at 6.
- Stilled Hour Sutra: Sleet Volley at layer 1, Stilled Instant at 2, Shattering Mantle at 4, Frozen Marrow Pact at 6.

**Passives:**
- **Both techniques:** they carry plain numbers on Ice-stack duration and effect, plus cold damage.
- **Winter Toll Canon:** it adds cheaper and faster seal arts.
- **Stilled Hour Sutra:** it adds cold art speed, status duration, body shield and healing.
- **Dropped:** I left out `art_cost_health_pct`. The lint counts a negative value on it as negative W, so it could not express a cheaper health payment for the Pact.

**Bonuses:** Winter Toll Canon gets linh lực +12 %. Stilled Hour Sutra gets linh lực +18 %, tam ma resist +12 % and khi huyết +12 %.

**Open GDD point:** each suite has 4 arts, which exceeds the "1-3 signature abilities" in cong-phap rule 17. The lint only notes this and does not flag it.

Files are in `design/techniques/`:
- `catalogue-ice.json`
- `catalogue-ice.md`

TECH-DONE ice

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-ice.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-ice.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-ice.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-ice.md) instead (Edit rules cover all file-editing tools).
```
