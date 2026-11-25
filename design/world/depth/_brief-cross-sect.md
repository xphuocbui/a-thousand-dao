# Brief: the cross-sect pass (world-depth pass, stage 7)

Fifty sects and six outside groups were written by separate writers. Each wrote its own side of the ties it wanted
with other files and listed the far sides in `design/world/depth/_cross-sect-wishes.md`. Your job is to close the web
so the world reads as one place: both sides of every tie, no contradictions, and the big threads that span sects
written down.

## Read first

`design/world/depth/README.md`, `rules-proposals.md`, `schema.md` (tie kinds and their direction), then
`_cross-sect-wishes.md` whole. Read sect pages and cast files as each wish needs (use Grep for keys).

## Do

1. **Far sides of ties.** For every wish whose both people exist (check keys in `design/world/depth/**/*.cast.json`
   and `assets/data/world_history.json`), add the missing side to the person's `ties` in their cast file, with a short
   note consistent with the near side. Use the right direction (`schema.md`: a kind names what the *other* person is to
   you; `debt` = you owe them, `creditor` = they owe you; `parent`/`child`, `master`/`disciple`, `sibling`, `cousin`...
   mirror). Do this with a small Python script that loads each cast file, appends the tie if absent and writes the
   file back (`json.dump(..., ensure_ascii=False, indent=1)`), so you never hand-edit large JSON. If a wish names a
   person who does not exist, either create them as a tier C record in the file the wish belongs to (only when the
   wish needs them: a named father, a sister) or drop the wish and list it.
2. **Fix the listed errors** in the wishes file (pronouns, a place called "isles" that is tundra, a person called "her"
   who is male, legendary item wordings to propose, the Tùng Đào voice-only canon vs a claim that someone knows its
   written form, Phất Y's founder as Tư Không Hạc Niên's master, uc_da_diep's technique). Change only what the error
   needs, and add a `changed` note where you change a fact on a record.
3. **Contradictions.** Grep for the claims listed under "claims to confirm" and "canon additions" and check they don't
   contradict each other or the chronicle (`assets/data/world_history.json` events). Where two files disagree, pick
   the version that fits the chronicle and more files, and fix the other with a note.
4. **Write `design/world/depth/cross-sect.md`**: the world as one web. Sections: the great threads that span sects
   (each 1-2 paragraphs, naming people by key and the files they live in: the Red Plum and Cô Thành, the 803 vein and
   Chiết Kích, the succession quarrels, Triệu Huyết Y's net, the debts that run to the market houses, the marriages of
   the clans, the Ferry War and the bridge battles...); a table of cross-sect marriages, feuds, debts and master lines;
   the claims you confirmed or changed; the wishes you dropped and why.
5. **Run the checker** (`python -I tools/design/world/depth_check.py`) until it shows no findings.

## Rules

Edit only files in `design/world/depth/` (cast files, pages where a fix needs it, and your `cross-sect.md`). Do not
touch `README.md` (the orchestrator keeps it), game data, GDDs or code. Do not commit. Prefix scratchpad files with
`xsect-`. Report briefly (under 300 words): ties added, people created, errors fixed, contradictions resolved, wishes
dropped, checker's final lines.
