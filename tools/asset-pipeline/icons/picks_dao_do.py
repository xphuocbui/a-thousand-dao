"""Which painted file is a Đạo Đồ icon's pick, and how it was made (art bible §7.9). Renders nothing.

One rule for install_dao_do.py, catalogue_dao_do.py and the viewer build, so a new run is never paid for and then
silently ignored: assets/icons/dao_do/PICKS.json (an explicit "kind/id": path) first, then the low-quality palette-v2
painting `<id>_lo0.png`, then the medium first-set painting `<id>_dd0.png`.

Each file's prompt, model and quality come from ai/log.jsonl (the generator's record), never recomputed from the
current style, so the catalogue says truthfully which icons are low and can be redone at medium later.
"""
import glob
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
AI = os.path.join(HERE, "ai", "openai")
ORDER = ("l2", "lo", "dd")   # stat style 2 (dark, layered) at low, then palette v2 at low, then the first set; was                    # palette v2 at low quality, then the first set at medium
_picks = None
_log = None


def explicit():
    global _picks
    if _picks is None:
        p = os.path.join(ROOT, "assets", "icons", "dao_do", "PICKS.json")
        _picks = json.load(open(p, encoding="utf-8")) if os.path.exists(p) else {}
    return _picks


def log():
    """(kind, id, tag) -> the last log record for that painting."""
    global _log
    if _log is None:
        _log = {}
        p = os.path.join(HERE, "ai", "log.jsonl")
        for line in open(p, encoding="utf-8"):
            if line.strip():
                r = json.loads(line)
                _log[(r.get("kind"), r.get("id"), r.get("tag", ""))] = r
    return _log


def pick(kind, iid):
    """(path, tag) of the file to use, or (None, None)."""
    e = explicit().get("%s/%s" % (kind, iid))
    if e:
        return os.path.join(ROOT, e), "picked"
    for tag in ORDER:
        f = os.path.join(AI, kind, "%s_%s0.png" % (iid, tag))
        if os.path.exists(f):
            return f, tag
    return None, None


def record(kind, iid, tag):
    """The log record (prompt, model, quality, seed) of one painting, or {}."""
    return log().get((kind, iid, tag), {})


def candidates(kind, iid):
    """Every painting on disk for an icon: [(relative path, tag, quality, prompt)]."""
    out = []
    for f in sorted(glob.glob(os.path.join(AI, kind, glob.escape(iid) + "_*.png"))):
        tag = os.path.basename(f)[len(iid) + 1:-5]
        r = record(kind, iid, tag)
        out.append((os.path.relpath(f, ROOT).replace("\\", "/"), tag, r.get("quality"), r.get("prompt")))
    return out


# Frames in use (user 2026-11-20: "1 looks good"): notables and keystones take the v2 frames, the rest the B1 set.
FRAME_PICK = {"notable": "notable2_f20.png", "keystone": "keystone2_f20.png"}


def frame_path(kind):
    """The painted frame file for a node frame kind (road, small, notable, capability, keystone, start)."""
    return os.path.join(AI, "dd_frame", FRAME_PICK.get(kind, "%s_dd0.png" % kind))
