"""Versioned Kinh Mạch Đồ graphs: one JSON file per version in design/meridian-map/versions/.

Rules (user decision 2026-11-12):
- A generator run (build_tree.py) always writes a NEW version and never overwrites an existing file.
- The editor overwrites only the version it has open (Save), or writes a new one (Save as new version).
- Before an overwrite, the previous copy of that one file goes to versions/.prev/<name>.json (one step back).

A version file has the shape of the kit's tree.json plus a "meta" block:
  {"meta": {"name", "created", "saved", "source", "parent", "note"}, "nodes", "edges", "clusters", "themes",
   "regions", "metrics"}
"""
import datetime
import json
import os
import re
import shutil

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
VERSIONS_DIR = os.path.join(ROOT, "design", "meridian-map", "versions")
PREV_DIR = os.path.join(VERSIONS_DIR, ".prev")
NAME_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]{0,80}$")


def now():
    return datetime.datetime.now().isoformat(timespec="seconds")


def valid_name(name):
    """A version name is a plain file stem: letters, digits, dot, dash, underscore (no paths)."""
    return bool(NAME_RE.match(name or "")) and not name.endswith(".json")


def path_of(name):
    if not valid_name(name):
        raise ValueError(f"bad version name: {name!r}")
    return os.path.join(VERSIONS_DIR, name + ".json")


def free_name(base):
    """`base` if no version has it yet, else base-2, base-3, ... (never an existing name)."""
    os.makedirs(VERSIONS_DIR, exist_ok=True)
    if not os.path.exists(path_of(base)):
        return base
    k = 2
    while os.path.exists(path_of(f"{base}-{k}")):
        k += 1
    return f"{base}-{k}"


def _dump(data, path):
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
    os.replace(tmp, path)


def write_new(data, base, source, parent=None, note=""):
    """Write `data` as a new version named after `base` (suffixed if taken). Returns the name used."""
    name = free_name(base)
    meta = dict(data.get("meta") or {})
    meta.update(name=name, created=now(), saved=now(), source=source, parent=parent, note=note or meta.get("note", ""))
    out = {"meta": meta, **{k: v for k, v in data.items() if k != "meta"}}
    path = path_of(name)
    # exclusive create: never overwrite, even if another process wrote the same name a moment ago
    with open(path, "x", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))
    return name


def overwrite(name, data):
    """Overwrite an EXISTING version (the one being edited), keeping its previous copy in .prev/."""
    path = path_of(name)
    if not os.path.exists(path):
        raise FileNotFoundError(name)
    os.makedirs(PREV_DIR, exist_ok=True)
    shutil.copy2(path, os.path.join(PREV_DIR, name + ".json"))
    meta = dict(data.get("meta") or {})
    meta.update(name=name, saved=now())
    _dump({"meta": meta, **{k: v for k, v in data.items() if k != "meta"}}, path)


def read(name):
    with open(path_of(name), encoding="utf-8") as f:
        return json.load(f)


def listing():
    """Every version, newest save first: name, bytes, mtime, and its meta block."""
    out = []
    if not os.path.isdir(VERSIONS_DIR):
        return out
    for fn in os.listdir(VERSIONS_DIR):
        if not fn.endswith(".json"):
            continue
        p = os.path.join(VERSIONS_DIR, fn)
        meta = {}
        try:
            with open(p, encoding="utf-8") as f:
                head = f.read(65536)
            i = head.find('"meta":')
            if i >= 0:
                meta, _ = json.JSONDecoder().raw_decode(head, i + len('"meta":'))
        except (OSError, ValueError):
            pass
        st = os.stat(p)
        out.append({"name": fn[:-5], "bytes": st.st_size, "mtime": st.st_mtime, "meta": meta})
    out.sort(key=lambda v: -v["mtime"])
    return out
