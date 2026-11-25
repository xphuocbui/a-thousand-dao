# Brief: minor sect writer (world-depth pass)

Same pass, same rules and quality bar as `_brief-sect-writer.md`. **Read that brief first** and follow everything
in it, except where this file differs. You write **several minor sects** (vassals of one great sect). Read your lord's
page `design/world/depth/sects/<lord>.md` and its cast first if it exists, because your sects live inside its world.

## What differs for a minor sect

- **Page**: the same 12 sections, about half the length of a great sect's. Keep sections 2 (land), 4 (doctrine),
  5 (lineage), 8 (relations) and 12 (hooks) full. A minor sect is a place and a people, not a small copy of its lord.
  Give each one a reason to exist and a distinct way of life: fishers, nuns, caravan guards, a clan, smiths, a
  hermitage, raiders, a temple, a school.
- **Seat (R4)**: a minor sect may **re-lean to its land** instead of moving (cheaper, and often truer). Choose
  per sect, and say why. If you re-lean, write the new `leans` in section 1 and the lineage to match.
- **No-lean sects (R3)**: if a sect's land is mixed and its story suits it (a body-tempering school, a merchant
  house, a sword school that takes anyone with talent, a clan sect), make it no-lean: `leans: []`, an
  element-neutral lineage (body, blade, soul/song/seal or force techniques in `design/techniques/`), recruiting by
  talent or kin. Aim for **one or two no-lean sects in your batch**, not more.
- **Lineage**: main method Profound or Earth tier (tier 1-2); outer method Yellow; 1-2 secret arts. Reuse catalogue
  techniques where they fit, and propose the rest.
- **Cast per minor sect**: about **10-14 living** and **1-3 dead**. Realm caps: Kết Đan at most 2, Trúc Cơ 4, Luyện
  Khí 5, Nguyên Anh 0. The three minor sects with a Nguyên Anh head (cung_tinh, van_khoi, thien_bao) may have 1.
  The existing head counts. Tiers: A 1-2 (the head, maybe one more), B 3-5, the rest C.
- **Items**: 2-4 signature items per sect (the head's and an elder's); a set only if it has a story. Id prefix: the
  sect key's initials and a hyphen, e.g. `ht-` for hoa_tinh; add a third letter if two of your sects share initials.
- **Ties to the lord's people** are encouraged: masters who trained at the lord's seat, a daughter married into it,
  a debt, a grudge. Point only to keys that already exist (your lord's cast file, `bang_tam.cast.json`, or
  `assets/data/world_history.json`).

## Files

For each sect `<key>` in your batch: `design/world/depth/sects/<key>.md`, `<key>.techniques.json`,
`<key>.cast.json` (and `<key>.2.cast.json` if needed), `<key>.items.json`. Nothing else.
