# Job transcript: tech-soul-song-seal (try 1)

I wrote three techniques for the soul-song-seal family, and the lint reports 0 findings on `catalogue-soul-song-seal.json`. It also notes that the whole-catalogue checks (`UNCARRIED`, missing suite) are skipped on a single file, as you said to expect. The `.md` is written and ends with the lint's final line.

| Technique | Tier and kind | Carries | Passive W | Names |
|---|---|---|---|---|
| Hollow Bell Canon (Hư Chung Kinh) | Hoàng, main method | Tolling Bell Requiem at layer 1, Lamp-Oil Lance at layer 3 | 7.8 of 8 | thuy |
| Nine Seal Ledger (Cửu Ấn Lục) | Thiên, secret art | Ambush Talisman at layer 1, Frozen Hour Seal at layer 3, Branding Seal at layer 6 | 31.8 of 32 | kim |
| Thorn and Ink Verses (Cức Mặc Thi) | Huyền, secret art | Marching Dirge at layer 1, Thorn Lullaby at layer 3, Blood-Ink Writ at layer 5 | 15.6 of 16 | moc |

All three carry the three group-less arts in one carrier. The three are element-less, so they share nothing to split on. I picked Huyền (tier 1) because the 16 W budget leaves room for heal, leech and seal-damage lines. The main method is Hollow Bell Canon, since the Yellow suite is the one that can be a tâm pháp (main method).

Nine Seal Ledger has three bonuses: divine sense (thần thức) +12 %, linh lực +15 % and tam ma resist +10 %. The carrier has one: max health (khí huyết) +10 %. Hollow Bell Canon has none.

Passives feed each suite's engine:
- **Hollow Bell Canon:** soul damage, soul art speed and curse duration keep Slackened Soul up for the Bell's Peal and Knell. A cost cut on costly arts keeps the Lance cheap.
- **Nine Seal Ledger:** every passive is scoped to seal (the last two are curse-scoped duration and soul damage).
- **Thorn and Ink Verses:** healing and leech feed the Lullaby's thorns, and a seal-damage line lifts Blood-Ink Writ's seals.

No art was changed.

TECH-DONE soul-song-seal

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-soul-song-seal.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-soul-song-seal.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/techniques/catalogue-soul-song-seal.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/techniques/catalogue-soul-song-seal.md) instead (Edit rules cover all file-editing tools).
```
