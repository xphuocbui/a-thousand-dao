# Decisions 2026-11-26 (world-depth art)

- **Portrait style: xianxia v1** (user: "v1 is better"). It uses the XIANXIA_STYLE block (layered silk, embroidery,
  jade and silver, ethereal light, power where it suits) and per-sect xianxia dress sheets, with no automatic rank or
  realm lines. v2 added those lines and the rank uniforms; it made low realms plainer and was judged worse. Its
  code stays behind a flag (`rank_realm`), and its sheets are kept in `art/portraits/_unused-uniform-dress.json.bak`.
- Sect sameness and power still come through the dress sheet and the style block's "stronger for the stronger". The
  user's earlier ask (a sect's cast looks like one house; higher realms look more powerful) should be written into
  each sect's v1-style sheet and each prompt's clothing, without the separate lines.

# Decisions 2026-11-26 (implementation scope)

- **Everything goes into the game** (user: "please make sure to include everything, including the effects and items
  that are not in the game in the implementation"). It covers every proposal technique and its arts, every item, set
  bonus and Effect, the engine features they need (`builds/engine-wishes.md`, the duel readings), the beasts, and the
  new statuses, tags and modifier keys. Generated stand-in techniques are only a temporary step; they are not the end
  state. This answers the plan's old D2 question. Plan: `production/plans/world-depth-implementation.md` (Stages 4-6
  and the gap report's done condition).
