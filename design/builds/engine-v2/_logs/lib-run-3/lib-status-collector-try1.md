# Job transcript: lib-status-collector (try 1)

I rebuilt `status-collector` on library arts and fought it on engine v2. The fights are far too short to show the build's engine: a typical foe dies in 1.6 s at Hóa Thần (hoa_than) and 4.0 s at Kết Đan (ket_dan), against the 30-60 s band.

**Techniques and arts**
- **Winter Toll Canon (main, Băng):** `rime-lock-seal`, `black-ice-glaze`, `shatter-palm`.
- **Ruin Ledger Scripture (auxiliary, Thổ):** `fraying-thread`, `ripening-curse`, `gathered-ruin-verdict`. `ripening-curse` is the count reader, 3 % more per different status on the foe.
- **Rotting Canopy Canon (auxiliary, Mộc):** `blight-canker`.
- **Kết Đan file:** 5 arts, dropping `shatter-palm` and `gathered-ruin-verdict` because there are only 5 slots.

**Purity:** the old files had no `purity`, so I wrote none. I assumed the five-element root with Lôi and Băng has Băng, Thổ and Mộc; the loader accepted it.

**Fights** (20-0-0 everywhere, you never run dry):

| Matchup | Mean s | Foe dry | Notes |
|---|---|---|---|
| Hóa Thần vs typical | 1.6 | 1.6 | all seven arts NEVER_FIRED |
| Hóa Thần vs top_end | 4.0 | 3.9 | `black-ice-glaze` NEVER_FIRED |
| Kết Đan vs typical | 4.0 | 3.2 | `black-ice-glaze` and `blight-canker` NEVER_FIRED |

**Without tests (Hóa Thần)**
- **`--without tech:winter-toll-canon`:** no change on typical (1.6 s); top_end 4.0 → 4.1 s.
- **`--without ripening-curse`:** no change on typical (1.6 s). It is the only removal that moves a fight: top_end 4.0 → 6.6 s.

**Lost:** the six one-element Brands (fire, earth, metal, thunder debuffs) have no library equivalent. Marked Prey, Tally Ten, Crowded Ledger and the Tally Gourd belonged to the invented arts, so they are gone. The twelve-kind +48 L5 payoff cannot be tested here.

The write-up also covers the old-to-library table, the UNMODELLED lines and the observations.

Files are in `design/builds/engine-v2/`:
- `builds/status-collector.fight.json`
- `builds/status-collector.ket-dan.fight.json`
- `status-collector.md`

LIB-DONE design/builds/engine-v2/status-collector.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/status-collector.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/status-collector.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/status-collector.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/status-collector.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/status-collector.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/status-collector.md) instead (Edit rules cover all file-editing tools).
```
