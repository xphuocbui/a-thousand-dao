"""Stage art for places (production/plans/overnight-2026-11-22.md step 7; design/world/great_projects_proposal.md):
a place's development levels and the stages of its great projects, each painted FROM the place's finished painting
(place_art.py) with only the change described, so the place visibly grows instead of being redrawn.

usage:
  python -I place_stages.py plan  <repo>              writes the jobs: levels for cities and sect seats, and each of the
                                                     ten great projects' stages (2 to 5 each) at one place that lists it
  python -I place_stages.py paint <repo> <quality>    paints the jobs not yet done (stage n is painted from stage n-1)
  python -I place_stages.py cut   <repo>              cuts each stage into a sprite like place_art.py's

Files: design/map/continent-11/art/stages/jobs.json, <job>_<n>.png; sprites assets/map/places/stages/<job>_<n>.png and
assets/map/places/stages/manifest.json (place id, kind "level" or a project key, stage, file, size in tiles).
"""
import json
import os
import subprocess
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import place_art  # noqa: E402  (shares the crop geometry and radius table)

PROJECTS = [  # key, name, how each stage looks (design/world/great_projects_proposal.md), words that pick a place
    ("tu_linh_dai_tran", "Great gathering array (Tụ Linh Đại Trận)",
     ["survey stakes and nine foundation stones set in a ring around the place", "stone pillars carved with array script standing in the ring",
      "the pillars lit, faint golden qi lines joining them over the roofs",
      "a second, outer ring of lit pillars, the qi lines now drawing one visible array figure over the whole place",
      "the array figure glowing on the ground across the place, a soft pillar of light at its centre and the clouds above drawn into a slow spiral"], ["gathering array", "array", "tụ linh"]),
    ("linh_mach_cu", "Vein canal (Linh Mạch Cừ)",
     ["a fresh trench cut toward the place from the nearest high ground", "a stone-lined channel with sluice gates reaching the place",
      "the channel glowing faintly, a soft mist where it meets the place"], ["canal", "channel", "vein canal"]),
    ("linh_dien", "Spirit field terraces (Linh Điền)",
     ["marked slopes and the first low terrace walls on the hill beside the place", "terraced fields stepping up the hill",
      "the terraces green with spirit herbs, a small gathering stone at the top"], ["terrace", "field", "herb"]),
    ("thien_the", "Cloud ladder (Thiên Thê)",
     ["anchors and the first planks driven into the nearest cliff", "a stair and plank road climbing the cliff face",
      "a roofed sky bridge with lanterns spanning the gap",
      "a second sky bridge and a lantern-lit waystation pavilion built halfway up the cliff"], ["ladder", "bridge", "stair", "sky"]),
    ("thuong_hoi_quan", "Trade quarter (Thương Hội Quán)",
     ["a cleared square and timber frames at the edge of the place", "covered halls and warehouses around the square",
      "a walled trade quarter with a tall guild hall and plain coloured banners",
      "the quarter grown past its old walls: a second guild hall, caravan yards and long rows of warehouses"], ["trade", "market", "guild", "warehouse"]),
    ("hai_de", "Harbour works (Hải Đê)",
     ["piles and a rubble mole reaching into the water", "a stone breakwater and quays", "a lighthouse pagoda at the breakwater's end",
      "a second breakwater closing a full harbour basin, with dry docks and a customs hall on the quay"],
     ["harbour", "breakwater", "lighthouse", "quay", "mole"]),
    ("ho_thanh_dai_tran", "Warding wall (Hộ Thành Đại Trận)",
     ["an earth rampart and stakes around the place", "stone walls with gate towers around the place",
      "the walls hung with ward talismans and a faint dome of ward light over the place",
      "a second, outer wall with watchtowers, and the ward dome bright and banded with script"], ["ward", "wall", "rampart"]),
    ("tang_kinh_cac", "Scripture pavilion (Tàng Kinh Các)",
     ["a cleared stone terrace inside the place", "a three-storey pavilion rising in bamboo scaffolding",
      "a five-storey library pagoda with a brass roof finial"], ["library", "scripture", "pavilion", "archive"]),
    ("dan_lo", "Great furnace (Đan Lô)",
     ["a stone platform and a flue at the edge of the place", "a furnace hall with a tall chimney",
      "the furnace hall with a glowing furnace mouth and a column of pale coloured smoke"], ["furnace", "forge", "kiln", "alchemy"]),
    ("tinh_that", "Sanctuary (Tĩnh Thất)",
     ["a cleared path and marker stones beside the natural feature",
      "a small open pavilion with a ring of stone lanterns beside the feature, the feature itself untouched"], ["sanctuary", "shrine", "pavilion"]),
]
LEVEL_KINDS = {"city", "great_seat", "minor_seat", "town", "market"}   # villages: a later pass (budget, 2026-11-22)


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def sdir(repo):
    return os.path.join(repo, "design/map/continent-11/art/stages")


def plan(repo):
    cat = {e["id"]: e for e in load(os.path.join(repo, "design/world/place_catalogue.json"))["places"]}
    places = {p["id"]: p for p in load(os.path.join(repo, "assets/data/world_continent.json"))["places"]}
    jobs = []
    for pid, p in sorted(places.items()):
        if p["kind"] in LEVEL_KINDS and len(cat.get(pid, {}).get("levels", [])) >= 2:
            jobs.append({"job": "level_%d" % pid, "place": pid, "kind": "level", "name": p["name"],
                         "stages": cat[pid]["levels"][:2]})
    used = set()
    for key, name, stages, words in PROJECTS:
        best = None
        for pid, e in sorted(cat.items()):
            text = " ".join(e.get("projects", []) or []).lower()
            if pid not in used and any(w in text for w in words) and os.path.exists(
                    os.path.join(repo, "design/map/continent-11/art/places/paint_%d.png" % pid)):
                best = pid
                break
        if best is None:   # no catalogue entry names it: pick the site from the land (the proposal's "where")
            painted = lambda q: os.path.exists(os.path.join(repo, "design/map/continent-11/art/places/paint_%d.png" % q))
            if key == "linh_mach_cu":
                veins = [p for p in places.values() if p["kind"] == "spirit_vein"]
                towns = [p for p in places.values() if p["kind"] in ("town", "village") and p["id"] not in used and painted(p["id"])]
                if veins and towns:
                    best = min(towns, key=lambda t: min((t["tile"][0] - v["tile"][0]) ** 2 + (t["tile"][1] - v["tile"][1]) ** 2 for v in veins))["id"]
            elif key == "tinh_that":
                peaks = [p for p in places.values() if p["kind"] == "peak" and p["id"] not in used and painted(p["id"])]
                if peaks:
                    best = peaks[0]["id"]
        if best is None:
            continue
        used.add(best)
        jobs.append({"job": "%s_%d" % (key, best), "place": best, "kind": key, "name": places[best]["name"],
                     "project": name, "stages": stages})
    os.makedirs(sdir(repo), exist_ok=True)
    with open(os.path.join(sdir(repo), "jobs.json"), "w", encoding="utf-8") as f:
        json.dump(jobs, f, ensure_ascii=False, indent=1)
    n = sum(len(j["stages"]) for j in jobs)
    print("jobs %d (levels %d, projects %d), images %d" % (len(jobs), sum(j["kind"] == "level" for j in jobs),
                                                        sum(j["kind"] != "level" for j in jobs), n))


PROMPT = """This image is a painted grand-strategy map seen straight down, with {name} painted at its centre. Change ONLY the place at the centre, and only as described; keep its layout, every existing building, the terrain, the water, the colours and the golden-hour light from the top left exactly as they are, so the two images can be swapped on the map.

{what}

Keep the change inside a circle about {share} % of the image width across the centre. Never: text, labels, writing, symbols on flags, people larger than specks, a frame, a vignette."""


def paint(repo, quality):
    jobs = load(os.path.join(sdir(repo), "jobs.json"))
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    plan_rows = {r["id"]: r for r in load(os.path.join(repo, "design/map/continent-11/art/places/plan.json"))["places"]}

    def run_job(j):
        prev = os.path.join(repo, "design/map/continent-11/art/places/paint_%d.png" % j["place"])
        share = int(round(100 * 2 * plan_rows[j["place"]]["radius_tiles"] / place_art.VIEW[0]))
        for n, stage in enumerate(j["stages"], 1):
            out = os.path.join(sdir(repo), "%s_%d.png" % (j["job"], n))
            if not os.path.exists(out):
                if j["kind"] == "level":
                    what = "The place grows one development level: %s" % stage
                else:
                    what = "%s builds the great project %s, stage %d of %d: %s." % (j["name"], j["project"], n, len(j["stages"]), stage)
                pf = os.path.join(sdir(repo), "%s_%d.md" % (j["job"], n))
                with open(pf, "w", encoding="utf-8") as f:
                    f.write(PROMPT.format(name=j["name"], what=what, share=share))
                subprocess.run([sys.executable, "-I", tool, "gpt-image-2", quality, "1536x864", pf, "--", out, prev], check=False)
            if not os.path.exists(out):
                return
            prev = out

    only = os.environ.get("STAGE_KIND", "")   # "level" or "project": paint only that kind (unset: all)
    if only:
        jobs = [j for j in jobs if (j["kind"] == "level") == (only == "level")]
    base = os.path.join(repo, "design/map/continent-11/art/places")
    jobs = [j for j in jobs if os.path.exists(os.path.join(base, "paint_%d.png" % j["place"]))]   # base painted first
    if os.environ.get("STAGE_REVERSE", ""):   # a second painter works from the other end, so the two rarely meet
        jobs = jobs[::-1]
    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=int(os.environ.get("PAINT_WORKERS", "4"))) as pool:
        list(pool.map(run_job, jobs))
    print("stage jobs run: %d" % len(jobs))


def cut(repo):
    jobs = load(os.path.join(sdir(repo), "jobs.json"))
    plan_rows = {r["id"]: dict(r) for r in load(os.path.join(repo, "design/map/continent-11/art/places/plan.json"))["places"]}
    radii = load(os.path.join(repo, "design/map/continent-11/art/places/radii.json"))   # the base sprite's fitted patch
    for pid, rad in radii.items():
        if int(pid) in plan_rows:
            plan_rows[int(pid)]["radius_tiles"] = rad
    out_dir = os.path.join(repo, "assets/map/places/stages")
    os.makedirs(out_dir, exist_ok=True)
    manifest = {"_doc": "Stage sprites (tools/asset-pipeline/map/place_stages.py): a place's levels and great-project "
                        "stages, each cut like its base sprite; swap it for the base sprite on the place's tile.",
                "stages": []}
    for j in jobs:
        r = plan_rows[j["place"]]
        for n in range(1, len(j["stages"]) + 1):
            src = os.path.join(sdir(repo), "%s_%d.png" % (j["job"], n))
            if not os.path.exists(src):
                continue
            # a stage may reach further than its base (a breakwater): fit its own patch, at least the base's, capped by
            # the distance to the next place like the base
            inp = os.path.join(repo, "design/map/continent-11/art/places/in_%d.png" % j["place"])
            tiles = [q["tile"] for q in plan_rows.values() if q["id"] != j["place"]]
            near = min(np.hypot(r["tile"][0] - t[0], r["tile"][1] - t[1]) for t in tiles)
            fit = place_art.fitted_radius(src, inp, r["radius_tiles"])
            rad = max(r["radius_tiles"], min(fit, 0.55 * near))
            rgba, size_px = place_art.patch(src, rad)
            name = "%s_%d.png" % (j["job"], n)
            Image.fromarray(rgba.astype(np.uint8), "RGBA").resize((size_px, size_px), Image.LANCZOS).save(
                os.path.join(out_dir, name), optimize=True)
            manifest["stages"].append({"place": j["place"], "kind": j["kind"], "stage": n, "file": name,
                                       "tile": r["tile"], "size_tiles": round(2 * rad, 2),
                                       "what": j["stages"][n - 1], "project": j.get("project", "")})
    with open(os.path.join(out_dir, "manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)
    print("cut %d stage sprites" % len(manifest["stages"]))


if __name__ == "__main__":
    cmd, repo = sys.argv[1], sys.argv[2]
    {"plan": lambda: plan(repo), "paint": lambda: paint(repo, sys.argv[3]), "cut": lambda: cut(repo)}[cmd]()
