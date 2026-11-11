# Job transcript: tune-fire (try 1)

The Fire family now meets targets 1, 4 and 5, and engagement (target 2) is met except that Twin Flame Echo's top step fires about 3 times a fight, above the 1–2 target. Red Sun Scripture went from x0.37 / x0.45 (FAST) to x0.62 / x0.63 of the typical mirror at Trúc Cơ and Kết Đan. Ashen Phoenix Canon is x0.78 / x0.81, and Scorch Fist stays at x1.12 / x1.04. The lint is at 0 findings.

- **Furnace Heart:** it never engaged before, because its vent gate was one OR-group that rarely opened. The vent now needs 4 Heat AND (15 Burn on the foe OR 2 Red Sun arts in 3 s), and it fires about once a fight.
- **Furnace Heart payoff:** it consumes up to 60 Burn, and each stack burnt is one more free hit with no cap. Its `c_mult` dropped from 5.5 to 2.5.
- **Flint Volley:** Flashfire now needs (6 Fire buff OR 15 Burn) AND another Red Sun art in 3 s. Its `c_mult` dropped from 2.5 to 0.9 per hit, and the quicken from 8 % to 4 %.
- **Twin Flame Echo:** the bloom now needs 3 flames AND (Brazier OR 30 Burn OR 3 Red Sun arts in 3 s). Its `c_mult` dropped from 5.0 to 2.2.
- **Ash Rebirth:** Phoenix Pyre now needs (6 Ash OR below 35 % health) AND (20 Burn OR 2 Ashen Phoenix arts in 3 s). It fires about once a fight.
- **Left alone:** Heat Haze, Scorch Fist, Blood-Fed Pyre and Brazier Form were in range and engaged. I found no routes that can never open in this family.

- **Twin Flame Echo not tightened:** the flames fill quickly. Tightening further risked pushing Red Sun below x0.6.
- **Noise:** Red Sun sits close to the x0.6 edge, and each cell is only 20 fights, so those numbers are noisy.

I also updated the four changed rows in `family-fire.md`.

TUNE-DONE design/arts/tune-fire.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-fire.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-fire.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/tune-fire.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/tune-fire.md) instead (Edit rules cover all file-editing tools).
```
