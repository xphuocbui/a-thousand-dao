"""Hybrid pass 2 (user, 2026-11-23: "Go"): the 2x detail pass over hybrid/near_24px.png (near_upres.py), checked
against pass 1 and repainted once where it drifts, then the natural landmarks (landmarks.py), then the game tiles
(near_tiles.py: coast lock and clean open sea per tile).

A detail piece fails when, in any cell of a 4 x 4 grid over it, its mean colour moves more than CELL_LIMIT from the
pass-1 input there (pass 1 already holds the right land types; this pass should only add detail).
usage: python -I tools/asset-pipeline/map/terrain/pass2_run.py <repo>
"""
import json
import os
import subprocess
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
MAP = os.path.dirname(HERE)
CELL_LIMIT = 30.0
PASS = "../hybrid/p2"


def drift(src, paint):
    h, w = src.shape[:2]
    worst = 0.0
    for j in range(4):
        for i in range(4):
            a = src[j * h // 4:(j + 1) * h // 4, i * w // 4:(i + 1) * w // 4].reshape(-1, 3).mean(0)
            b = paint[j * h // 4:(j + 1) * h // 4, i * w // 4:(i + 1) * w // 4].reshape(-1, 3).mean(0)
            worst = max(worst, float(np.sqrt(((a - b) ** 2).sum())))
    return worst


def run(cmd, env=None):
    e = dict(os.environ)
    e.update(env or {})
    subprocess.run(cmd, check=False, env=e)


QUALITY = os.environ.get("QUALITY", "medium")   # user 2026-11-23: "switch to low from this point on"


def main(repo):
    py = sys.executable
    nu = os.path.join(MAP, "near_upres.py")
    d = os.path.join(repo, "design/map/continent-11/art/near/upres4", PASS)
    plan = json.load(open(os.path.join(d, "plan.json")))
    if os.environ.get("RESUME"):
        # resume after a stop: pieces set aside for a repaint (first_*.png) and not yet repainted are the repaint list
        bad = [c["id"] for c in plan["crops"] if c["paint"] and os.path.exists(os.path.join(d, "first_%s.png" % c["id"]))]
        todo = [cid for cid in bad if not os.path.exists(os.path.join(d, "paint_%s.png" % cid))]
        print("resume: %d set aside for a repaint, %d still to paint (%s)" % (len(bad), len(todo), QUALITY), flush=True)
        if todo:
            run([py, "-I", nu, "paint", repo, PASS, QUALITY, ",".join(todo)], {"PAINT_WORKERS": "6"})
        keep_best(d, bad)
        finish(repo, py)
        return
    run([py, "-I", nu, "paint", repo, PASS, QUALITY], {"PAINT_WORKERS": "6"})
    bad = []
    for c in plan["crops"]:
        if not c["paint"]:
            continue
        f = os.path.join(d, "paint_%s.png" % c["id"])
        if not os.path.exists(f):
            bad.append(c["id"])
            continue
        src = np.asarray(Image.open(os.path.join(d, "src_%s.png" % c["id"])).convert("RGB"), np.float32)
        pa = np.asarray(Image.open(f).convert("RGB").resize((src.shape[1], src.shape[0])), np.float32)
        if drift(src, pa) > CELL_LIMIT:
            os.replace(f, os.path.join(d, "first_%s.png" % c["id"]))
            bad.append(c["id"])
    print("pass 2: %d of %d pieces drifted or missing; repainting once" % (len(bad), sum(1 for c in plan["crops"] if c["paint"])), flush=True)
    if bad:
        run([py, "-I", nu, "paint", repo, PASS, QUALITY, ",".join(bad)], {"PAINT_WORKERS": "6"})
        keep_best(d, bad)
    finish(repo, py)


def keep_best(d, bad):
    """Keeps whichever attempt of each repainted piece drifts less from its pass-1 input."""
    if True:
        for cid in bad:
            f, first = os.path.join(d, "paint_%s.png" % cid), os.path.join(d, "first_%s.png" % cid)
            if os.path.exists(first) and os.path.exists(f):
                src = np.asarray(Image.open(os.path.join(d, "src_%s.png" % cid)).convert("RGB"), np.float32)
                a = np.asarray(Image.open(f).convert("RGB").resize((src.shape[1], src.shape[0])), np.float32)
                b = np.asarray(Image.open(first).convert("RGB").resize((src.shape[1], src.shape[0])), np.float32)
                if drift(src, b) < drift(src, a):
                    os.replace(first, f)
            elif os.path.exists(first):
                os.replace(first, f)


def finish(repo, py):
    lm = os.path.join(MAP, "landmarks.py")
    run([py, "-I", lm, repo, "plan"])
    run([py, "-I", lm, repo, "paint"], {"LANDMARK_QUALITY": QUALITY})
    run([py, "-I", os.path.join(MAP, "near_tiles.py"), repo])
    print("PASS2_DONE", flush=True)


if __name__ == "__main__":
    main(sys.argv[1])
