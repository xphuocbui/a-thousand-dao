# Đạo Đồ underlays: the pictures the traced figures come from

Pictures made with OpenAI's image model over the tree's real roads, picked by the user, then traced into nodes by
Claude (the cell files in `design/dao-do/cells/`). They are the design record of what each figure was traced from, and
the traced files read them when the tree is built (`tools/design/dao_do_rework/cells/integrate.sh`). Moved here from
`design/dao-do/cells/openai/` on 2026-11-19 (user: "For openai picture works we probably want to move it outside the
folder"). The scripts that made and measured them are in `tools/design/dao_do_rework/underlay/`.

| Folder | Picked picture | Traced by | Measured data |
|---|---|---|---|
| `sun/` | `inout-3.png` (Fusang 2 inside, Corona 1 flames outside; both sources kept) | `cells/sun_trace.py`, `cells/sun_hand.py` | `flames-inout3.json`; reading aids `grid-top.png`, `grid-bot.png` |
| `moon/` | `moon-2.png` | `cells/moon_trace.py` | (dots measured by hand) |
| `thunder/` | `thunder-3.png` | `cells/thunder_trace.py` | `dots-thunder.json`, `keep-thunder.json`, `links-thunder.json` |
| `shrine/` | `eclipse-2.png`, `lotus-1.png` (the lotus now stands in the Moon's cup) | `cells/shrine_trace.py` | layout `layout.png` |
| `chaos/` | `replace-1.png` (the swirl, regularised), `beside-1.png` (the five elements) | `cells/chaos_swirl.py`, `cells/chaos_elements.py` | `elem-graph.json` (skel2.py), `keepout.json` (today's figures round the first cells; regenerate if those cells change) |
| `pagoda/` | OpenAI's second design (`r2-*`) | `cells/pagoda.py` (the model's code) | `pack.json` (the geometry sent) |

`ideas-2026-11-19/` holds every idea of the 2026-11-19 round for the Shrine, Thunder and Chaos (4 ideas x 2 versions
each, their prompts, layouts and contact sheets), kept for future reference; Thunder's four are unused so far. Older
rounds are in git history (see `design/dao-do/method.md`, "Where the prompts and pictures are kept").

Each folder also holds the prompt (`prompt-*.md`) and the empty road layout the picture was drawn over, and the
model's `*-meta.json`. `first-ideas-*` are the first round of island ideas (sketch 3 style, 2026-11-19).

Model: `gpt-image-2.6-sunburst` via `/v1/images/edits` (`tools/design/dao_do_rework/underlay/img.py`); the pagoda by
`gpt-6.2-sol` via the Responses API (`call.py`). The API key is read from the `OPENAI_API_KEY` environment variable and
is never written to a file.
