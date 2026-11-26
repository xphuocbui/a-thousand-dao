# Authored art prompts (portraits and places)

Asked by the user on 2026-11-25 (`DECISIONS-2026-11-25.md` group 14). Every authored person gets a portrait, and about
100 story sites get an illustration. Each prompt is authored for that person or place from their record, not
assembled from fields.

## Portraits: three layers
1. **Style block** (fixed, in `tools/asset-pipeline/portraits/paint_authored.py`). It is the existing cast style: a
   chest-up oil portrait, warm key light from the upper left, a dark painterly background, no text.
   A **usage block** follows it (added 2026-11-25 after the user asked for the art's context). It covers how the
   portrait is shown: large in the character window, and as a 36 px round medallion in rankings, tooltips and on the
   map, so the face and silhouette must read small. It also carries the art bible's rules: the clothing cut shows
   the archetype; power is never drawn as size or glow; no text.
2. **Dress sheet** (`dress.json`, one per sect or group, written once). The sect's cloth, colours, ranks' marks and
   tools, so a sect's people read as one house.
3. **Subject paragraph** (`portraits/<batch>.json`, one per person, hand-written after reading the whole record).

### Rules for the subject paragraph
- **Imagine the person in full, and describe them in detail** (user, 2026-11-25). The most important thing comes
  first, then a full description in this order:
  - the face: shape, skin, eyes, brows, nose, mouth, age marks, and the mark that makes them them;
  - the hair: colour, length, style, ornaments;
  - the build and bearing;
  - the clothes, layer by layer: cloth, colour, cut, collar, sleeves, belt, embroidery;
  - what they carry;
  - then the qi hint, the expression and the palette.
  About 130-180 words.
- **Cultivators are never ragged** (user, 2026-11-25). Rags, patches or filth appear only where the story calls for
  it (a madman, a beggar-sage, a penitent, a prisoner), and then the paragraph says so and why. The "well-made,
  practical clothing" wording was removed the same night at the user's word: it read as wuxia. The xianxia style pass
  (next) sets how cultivators dress.
- **Lead with something different each time**: the eyes, a posture, an object, a beast, the hands, a laugh. 1,800
  prompts must not share one shape.
- **Two or three anchors, front-loaded.** Low quality holds about three clear things. The frame is chest-up, so a
  thing worn at the belt is out of shot: bring it into the hands or leave it out.
- **Apparent age is a number, and the record's `appearance` wins.** This is a prompt convention, not a GDD rule:
  - a cultivator looks roughly the age they were when their ageing slowed, at Trúc Cơ or later;
  - they look old in the last fifth of their realm's lifespan (Luyện Khí 120, Trúc Cơ 200, Kết Đan 500, Nguyên Anh
    1,000, Hóa Thần 2,000), or if the record says so.
- **What to read:**
  - the element and main technique, for the colour and kind of qi;
  - the build's gear, for the weapon or tool in hand;
  - traits, talents and flaws, for the expression and body;
  - the backstory, for one concrete detail.
  A secret may be hinted at (a mended seam, damp stone behind), but never shown.
- **Describe the look, not the deed.** A cruel man has a grin held too long, not blood. Avoid anything that invites
  writing (seals, ledgers, banners): say "small painted emblems".
- **The dead** are painted at the age of their defining deed, as a memorial portrait (faded, as on old silk).
- No names, characters or images from existing novels, dramas or games.

## Places
Painted into the real map crop (`tools/asset-pipeline/map/place_art.py`'s base prompt and crop) at medium quality. The
writer first fixes **where** the place is: region, biome, terrain, height, coast and rivers, neighbours, and what
else is inside the crop. Then the **theme**: the owner's craft and doctrine, the events there, and the story uses.
A **usage line** is appended to each place prompt: the painting is both the map miniature and the banner of the
place's window, so its signature element must read at a glance.
The output is two catalogue fields:
- `look`: what a traveller sees;
- `art_brief`: what the painter draws, with the signature element, the base and what to leave untouched.
A kind override is used where the place's role changed, for example a ruin that is now a seat.

## Pilot (2026-11-25)
- `portraits/pilot.json`: 10 people across tiers A, B and C, living and dead.
- `places/pilot.json`: 3 places, namely Băng Tâm's new seat (214), the Frost Test islet (239), and the unpainted
  Tuần Tùng seat (376).
- `pilot-prompts.md`: the assembled prompts, for the user to read before anything is painted.

## Lessons from the pilot paint (2026-11-25, `pilot-review/`)
- **Look at the input crop before writing a place.** The near map paints 214 and 239 as islands in open blue sea,
  but the record says tundra, so the prompts' "frozen lake" and "cleared circle of ice" fought the picture. The model
  followed the map, and the circle came out as a pool. Writers open `in_<id>.png` and describe the land that is
  painted there.
- **Facial marks and flaws need the lead and plain words.** At low quality a crooked split lip, rust-brown teeth and
  homeliness were smoothed away (cu_tieu_lang, cao_sa_lang). Put such a mark first and make it big.
- **Shape, not species.** A "blue luan" came out as a peacock. Describe the bird by its shape and colour.
- **Clothing details that make a person need to be large.** Thang Vô Tạ's one long sleeve did not read.
- The memorial fade is weak; use "faded and yellowed like an old silk painting, edges darkened".

## The method as of v4 (2026-11-25, the user: "really imagine it first, then describe it really specifically")
1. **Imagine one concrete moment** and write it in `imagined` (a few sentences; it is kept for review and not sent):
   where they are, what they have just done or are about to do, what they want right now, what the light is doing.
2. **Describe that picture precisely** in `subject`, in labelled parts, in this order:
   - The moment
   - Face (marked "most important" when a mark must show)
   - Hair
   - Body
   - Clothing, garment by garment
   - Hands and objects
   - Background
   - Light
   - Expression

   Use exact shapes, materials, colours, counts and positions, such as "nine holes in three rows of three", "the left
   sleeve twice as long as the right". Nothing vague. About 220-300 words.
3. Results: v4 made the long sleeve, the nine-hole lamp, the gauntlet bird, the wrist band, the wet stone and the
   brown teeth all read at low quality. A facial deformity (the cleft-lip scar) is still faint at low and only a
   little better at medium. Medium used 1,372 output image tokens against 158 at low, about 8.7 times as many. It
   adds texture but no new content.

## Places v2 (2026-11-25, the user: keep the top-down view, but each place is its own picture at true, grand scale, not a miniature on the map; detail the prompt)
- **What is painted:** a standalone painting (text-to-image, no map input), from a steep aerial angle, at medium
  quality, 1536x864. This is the banner shape the place and sect windows use. The place style block and usage line
  are in `paint_authored.py`.
- **Scale:** true scale. A great sect is a mountain or island of halls, terraces, walls and towers (dozens to
  hundreds of buildings); a minor sect a walled compound of dozens; a city tens of thousands of roofs; a village all
  its houses, yards and fields.
- **Method:** as for portraits.
  - `where`: the real geography, from the record and from looking at the map crop.
  - `imagined`: one moment, which is not sent.
  - `subject`: a precise description, covering the place and its setting, the layout and buildings with counts and
    materials, the signature elements, life at scale, and the light.
- **The map is separate.** The map miniatures (`place_art.py`, painted into the near layer) are not changed by this.
- **Pilot result** (`pilot-review/places-v2.jpg`): all three read as their place.
  - Băng Tâm: the island, the walled terraces, the jade ring under the ice, the buried pagoda tip, the volcano on the
    horizon.
  - Hàn Giao Chử: the serpent ridge with a lifted head, the Frost Test circle with candidates in rows, the alchemist's
    chimney.
  - Tuần Tùng: the palisade, the great pine with its platform, the caravan, the river.

  The look is more realistic and aerial than the old map miniatures.
- **Scale rule (user, 2026-11-25):** "a sect is supposed to house thousands of people... imagine the scale if people have
  magic". A great sect is a domain kilometres across: thousands of residents (disciples, servants, artisans, mortal
  families), hundreds of buildings, palace-sized halls, mountainsides carved into terraces, works no mortal could build.
  A minor sect is a walled settlement of dozens to a hundred buildings. Use the map's real size too: a tile is 25 km,
  so 214's island is about 250 km across and runs off the frame. This is now in the place style block, and
  `pilot-review/214-v2-vs-v3.jpg` shows the result.
