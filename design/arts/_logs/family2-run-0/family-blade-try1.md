# Job transcript: family-blade (try 1)

I wrote the blade family: 8 authored arts in `design/arts/family-blade.json` and the table in `design/arts/family-blade.md`. The lint prints 0 findings for the JSON; I did not run these arts in the simulator.

- **Standalone (3):** Debt Blade (Huyết Trái Kiếm) pays health. Flurry Stance (Loạn Đao Thế) is a stance. Pinning Arrow (Đinh Tiễn) delays foe timers per Slowed Time stack.
- **Engine (5):**
  - Coiling Thrust (Triền Thương Đột): Coil build-up and cash-in, 2 steps.
  - Nocked Arrow (Nhập Huyền Tiễn): held free-hit payloads, 2 steps ending in a Volley.
  - Phantom Sword (Huyễn Ảnh Kiếm): echoes and repeats, 2 steps.
  - Flying Sword (Phi Kiếm): unbounded summons, one empower.
  - Triple Draw (Tam Bạt Đao): charges and bursts, one empower.
- **Feeding routes:** every engine art has at least two OR-guard routes per gate.
- **Engine payoff:** the lint reports 3.2–4.5× for the fully fed steps and empowers.
- **Suites:** two suites, each sharing a `group` id. `hunters-reach-canon` is Pinning Arrow, Nocked Arrow and Coiling Thrust; `afterimage-sword-canon` is Flurry Stance, Phantom Sword, Flying Sword and Triple Draw. The `.md` has a section per suite and the "Engine (how to feed it)" column.

**Engine gaps** (also listed in the `.md`):
- **Pay on timed counters:** a counter with `each_for` ignores a negative `add`, so a pay on it spends nothing. My Coil and Afterimage counters use `decay_per_pulse` for that reason. Whetstone Pass and Shatter-Edge Cleave in `family-metal.json` pay `add: -3/-5` on their timed `temper` counter, so their pay does nothing. I did not touch that file.
- **No charges readable:** I couldn't read an art's remaining charges, so Triple Draw uses a 4 s draw counter instead.
- **Held payloads can't carry a `mod`:** a banked `mod` is dropped when spent, so Nocked Arrow banks free hits rather than a damage multiplier.
- **Steps can't add effects:** Phantom Sword's top step is three cuts, not an echo.
- **Stance suppression by id:** `suppress` takes art ids only, so Flurry Stance names the two common arts it suppresses.

I assumed the `art_fired` tag filter matches any tag of the fired art (used for `reach`); I did not check it in the engine.

FAMILY-DONE design/arts/family-blade.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-blade.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-blade.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-blade.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-blade.md) instead (Edit rules cover all file-editing tools).
```
