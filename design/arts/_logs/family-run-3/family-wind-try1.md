# Job transcript: family-wind (try 1)

I wrote the seven Wind signature arts, and the lint prints `checked 7 arts in 1 files, 0 findings`. The lint only checks the schema and the numbers. No art has been run in `fight.py`, so none of the mechanics are proven in a fight.

The seven arts, each with a different shape:

- **Hundred-Feather Flurry (Bách Vũ Loạn Phong):** counter build-up and cash-in. Basic attacks gather Feathers, and firing it releases one hit per Feather.
- **Swallow Stance (Yến Hành Thế):** a stance you toggle. Basics are faster and you evade more, but your arts are slower. Evades in the stance give Wind stacks.
- **Three-Step Chase (Tam Bộ Truy Phong):** three charges. Each firing gives evade, and recent strides make dash arts hit harder.
- **Reckless Gale (Mệnh Phong Bộ):** pays 6 % of health to fire. It then grants art speed in proportion to the health you are missing.
- **Trailing Gale (Lưu Phong Chướng):** a Slowed Time curse. While the foe is Slowed, each of your evades delays their longest timer.
- **Echo of the Dodge (Hồi Phong Ảnh):** every third evade re-fires your last art at 60 %.
- **Gale Sprite (Phong Linh Đồng):** a 12 s summon that strikes faster the more Wind stacks you hold.

I used no conversion, split or held-payload shape, because seven shapes already differ. The commons are kept as they were.

The engine's validator accepted all of this, but three points rest on assumptions I did not confirm:
- Feather and Echo reset their counter inside the same `do` as the payoff. That assumes the Effect's `scale` is read before its actions run, and that two Effects on one event run in array order.
- Three-Step Chase scopes its "more damage" mod to the `dash` tag. I did not confirm the engine applies it only to arts with that tag.
- Free hits are capped by the trigger budget, so Feather scaling is not truly limitless.

The `.md` lists the replaced library arts and the other missing pieces. Of the existing authored Wind arts, only Threshing Rain, Riding the Gust, Hollow Step and Gale Crown are replaced. Gale Veil, Scatter Gale and Sweeping the Floor are left alone for the review.

Files are in `design/arts`:
- `family-wind.json`
- `family-wind.md`

FAMILY-DONE design/arts/family-wind.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-wind.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-wind.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-wind.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-wind.md) instead (Edit rules cover all file-editing tools).
```
