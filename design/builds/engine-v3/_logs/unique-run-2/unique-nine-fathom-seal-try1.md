# Job transcript: unique-nine-fathom-seal (try 1)

I wrote the build file and the player guide, and ran the matrix plus the three `--without` tests. Only the contested Nascent Soul+1 matchup shows the unique mattering. Water Table is my own stand-in, so that part of its worth is a guess.

The build is a Core Formation Water build with root `water` 100. It has the Nine-Fathom Abyss Seal as its weapon, five items around it, and the three Water techniques `still-moon-tide-scripture`, `undertow-litany` and `returning-wake-verse`. The five arts are the Seal's own art plus Seep-Through Palm, Marrow to Dew, Drag of the Deep and Gathering Wave. Thần thức used is 40 of a 48.6 limit.

| Test | Typical Core Formation+0 | Typical Nascent Soul+1 |
|---|---|---|
| Nothing removed | 17.1 s, 20-0-0 | 61.8 s, 7-7-6 |
| `--without item:water-nine-fathom-seal` | 18.8 s, 20-0-0 | 60.7 s, 0-18-2 |
| `--without eff:Water Table` | 17.1 s, 20-0-0 | 62.4 s, 2-13-5 |
| `--without tech:still-moon-tide-scripture` | 18.6 s, 20-0-0 | 58.9 s, 0-19-1 |

- **Same realm:** a flat win in 17.1 s, which is under the 30-60 s target. Removing any piece leaves it a win, so the unique doesn't make the build there.
- **Water Table:** the catalogue never wrote its rule, and the engine can't read a foe's ward drain. I wrote it as 1 % linh lực back on each Water hit, once a pulse, and listed that as unmodelled.
- **Higher realms:** the build loses everything at Deity Transformation+2 and against top-end foes.
- **Never fired:** none of the five arts fire against top-end foes, and only the Seal and Seep-Through Palm fire at Deity Transformation+2, because those fights end in 1-5 s.
- **Not checked:** I did not count the Seal's second step (the 4.5× hit) separately.

Files are in `design/builds/engine-v3/`:
- `builds/unique-nine-fathom-seal.fight.json`
- `unique-nine-fathom-seal.md`

UNIQUE-DONE unique-nine-fathom-seal

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/builds/unique-nine-fathom-seal.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/builds/unique-nine-fathom-seal.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/unique-nine-fathom-seal.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/unique-nine-fathom-seal.md) instead (Edit rules cover all file-editing tools).
```
