# Underlay tools: making, measuring and tracing the Đạo Đồ pictures

Moved here 2026-11-19 from `design/dao-do/cells/openai/` (the pictures themselves are in `design/dao-do/underlays/`).
Measurement and tracing aids only: the cell files in `design/dao-do/cells/` choose what becomes nodes. Run from the
repo root unless a script's usage line says otherwise. The OpenAI API key is read from `OPENAI_API_KEY` and is never
written anywhere.

| Script | What it does |
|---|---|
| `img.py` | an image request to OpenAI's image model (`/v1/images/edits`) over a road layout: `img.py <model> <prompt.md> <out prefix> <n> <layout.png>` |
| `call.py`, `extract.py`, `pack.py`, `oai_check.py`, `common.md`, `regions.json` | the Responses API round that had OpenAI design pieces as code (the rim pagoda, `cells/pagoda.py`): the call, pulling the code block, the region geometry pack, the checks, the shared and per-region briefs |
| `rotmap.py`, `ks_find.py` | map rotation for renders; keystone spot finder |
| `trace_lib.py` | `Underlay` (a picture placed on the map), `even_chain` (nodes evenly along a drawn line between waypoints), `thin` |
| `trace_fine.py` | `Fine` (an underlay with set spacing minima and a mirror axis), `ring`, `mirror`, `thin_at`, `settle` (the spacing settler) |
| `swirl_lib.py` | turtle swirls (each step turns a little more) |
| `dots.py`, `label.py`, `links.py`, `showlinks.py` | a picture's beads measured, labelled and linked (Moon, Thunder) |
| `comps.py`, `flames.py` | the Sun's flame components and centre lines (`design/dao-do/underlays/sun/flames-inout3.json`) |
| `skel2.py` | a picture's centre-line network (Zhang-Suen thinning, strokes between ends and junctions); Chaos's `elem-graph.json` |
| `overlay.py` | a compiled map's pieces of one cell drawn over its picture, to compare |
