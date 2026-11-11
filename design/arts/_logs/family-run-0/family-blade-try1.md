# Job transcript: family-blade (try 1)

I wrote seven new arts for the blade family. They pass the lint (`checked 7 arts, 0 findings`), but I did not run any of them in a fight, so the mechanics are only schema-valid, not tested.

| Art | Mechanic shape |
|---|---|
| Debt Blade (Huyết Trái Kiếm) | Pays 5 % health; strikes again per 10 % of health missing. |
| Flurry Stance (Loạn Đao Thế) | Stance that speeds up and strengthens the basic attack, and suppresses Plain Sword Cut and Broad Saber Sweep. |
| Coiling Thrust (Triền Thương Đột) | Coils build with each firing and cash in as extra thrusts at 4 or more. |
| Pinning Arrow (Đinh Tiễn) | Slowed Time stack plus a 1 s delay on the foe's longest timer; a crit adds 2 more stacks. |
| Phantom Sword (Huyễn Ảnh Kiếm) | Afterimages build, then a crit echoes your last art at 60 %. |
| Flying Sword (Phi Kiếm) | Stacking summoned swords. |
| Triple Draw (Tam Bạt Đao) | 3 charges; draws in the last 4 s snowball into extra cuts. |

None of them replaces an existing library art, so the common arts and the authored curse and cull arts stay as they were. `sources` is `(gap)` throughout.

Gaps I hit, all listed in the `.md`:
- A held payload (a riposte banked from an evade) can't carry damage, so I left that shape out.
- I used no art for conversion, so that shape is still open for another family.
- Coiling Thrust's "becomes N thrusts" is modelled as extra free hits, which the engine's trigger budget and cap can clip at high scaling.
- The bow has no range or volley readable, so Pinning Arrow is a curse-and-delay art with a bow tag.
- Flurry Stance suppresses by art id, not by tag.
- I guessed the state mod values (`basic_speed 50`, `basic_coef 0.5`, `gain_on_hit 2`) and did not check them against a tuned build.

Files are in design/arts:
- family-blade.json
- family-blade.md

FAMILY-DONE design/arts/family-blade.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-blade.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-blade.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-blade.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-blade.md) instead (Edit rules cover all file-editing tools).
```
