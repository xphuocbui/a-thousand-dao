# Job transcript: family-metal (try 1)

I wrote 8 Metal (Kim) signature arts, one more than the "about 7" you asked for. The lint prints `checked 8 arts in 1 files, 0 findings`. I did not run any of them in the combat engine.

Each art has a different mechanic shape:
- **Whetstone Pass (Mài Phong Chưởng):** each Metal art fired adds a 10 s Temper that gives Metal arts +1 crit chance, with no cap.
- **Shatter-Edge Cleave (Toái Nhận Trảm):** a heavy hit that breaks all the foe's Metal debuff stacks, and every 2 stacks broken become a free hit.
- **Iron Hide Stance (Thiết Bì Thế):** a stance with +60 resistance and +20 block but -20 % art speed. It suppresses Cleave, and hits you take give you Metal buff stacks.
- **Blood-Quench Blade (Huyết Thối Nhận):** it costs 6 % of your health and gives you Metal buff stacks. Each crit of the art heals you back 2 %.
- **Needle Rain (Châm Vũ):** a hit split into 6 needles that each roll their own crit and lay Bleed. Each crit needle also lays a Metal debuff stack.
- **Sundering Wedge (Liệt Thạch Tiết):** lays Sundered, and into a foe already at 3 Sundered it adds Exposed, once per 6 s.
- **Flying Blade Retinue (Phi Nhận Trận):** each firing adds another flying sword that strikes every 2 s for 12 s, and its hits lay Metal debuff stacks.
- **Sheathed Edge (Nhập Sao Nhận):** crits bank up to 4 strikes, and your next art fired releases them as free hits.

Iron Hide Stance replaces Thorn Chorus, and Sundering Wedge replaces Writ of Reckoning. Sundering Wedge drops Writ's Withering anti-healer job, which should move to another family's curse art. The other authored Metal arts stay as they are, and so do the commons.

The `.md` lists these engine gaps:
- **Held payloads:** the engine ignores `filter` on them, so Sheathed Edge banks on any crit, not only Metal crits.
- **Art Effects:** they are live whenever the art is equipped, not only when it fires.
- **Stance suppression:** it works by art id only, not by tag.
- **Unconfirmed by the lint:** it does not show whether a negative `art_speed` works in a stance, or whether Needle Rain's split rolls crit and Bleed per needle.
- **Cleave scaling:** its consume has no cap, so it scales without limit on stacks, bounded only by the trigger budget.

Files are in `design/arts/`:
- `family-metal.json`
- `family-metal.md`

FAMILY-DONE design/arts/family-metal.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-metal.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-metal.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-metal.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-metal.md) instead (Edit rules cover all file-editing tools).
```
