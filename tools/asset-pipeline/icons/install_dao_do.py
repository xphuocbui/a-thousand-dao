"""Install the Đạo Đồ node art into assets/icons/dao_do/ (art bible §7.9). Renders and copies only.

  stat_<stat>[__<scope>].webp, note_<notable>.webp, idea_<idea>.webp, <kind>_<id>.webp; INDEX.json maps node id -> file
  node_<node id>.png                        a node's own icon: capabilities, Effect notables, keystones, starts
  road_<kind>_<n>.png                       the qi pearl colour-mapped per road kind, candidates n = 0, 1 (mixed per node)
  frame_<kind>.png                          the B1 painted frames, cut to the node geometry; FRAMES.json gives each hole
All paintings are 256 px (unframed; the engine lays the frame over them). The pick per icon is picks_dao_do.pick():
PICKS.json in that folder, then the low palette-v2 painting `_lo0`, then the medium first set `_dd0`. Then refreshes CATALOGUE.json (catalogue_dao_do.py).

Run (from the repo root): python -I tools/asset-pipeline/icons/install_dao_do.py
"""
import json
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
sys.path.insert(0, HERE)
import catalogue_dao_do as C  # noqa: E402
import frames_painted as P  # noqa: E402
import frames_sculpt as FS  # noqa: E402

AI = os.path.join(HERE, "ai", "openai")
DEST = os.path.join(ROOT, "assets", "icons", "dao_do")
PX = 256
FRAME_OF = {"dd_statc": "small", "dd_idea": "notable", "dd_note": "notable", "dd_cap": "capability", "dd_effect": "notable",
            "dd_keystone": "keystone", "dd_start": "start"}


def main():
    os.makedirs(DEST, exist_ok=True)
    C.main()
    cat = json.load(open(C.OUT, encoding="utf-8"))["icons"]
    picks_p = os.path.join(DEST, "PICKS.json")
    picks = json.load(open(picks_p, encoding="utf-8")) if os.path.exists(picks_p) else {}
    done, missing = 0, []
    index = {}
    for f in os.listdir(DEST):                            # the old PNG install (one file per node) is replaced
        if f.endswith(".png") and f.split("_")[0] in ("stat", "idea", "node", "road", "frame"):
            os.remove(os.path.join(DEST, f))
    for e in cat:
        k, iid = e["kind"], e["id"]
        if k in ("dd_roadmotif", "dd_frame"):
            continue
        src = e.get("pick") and os.path.join(ROOT, e["pick"])          # picks_dao_do: PICKS.json, then _lo0, then _dd0
        if not src or not os.path.exists(src):
            missing.append("%s/%s" % (k, iid))
            continue
        im = Image.open(src).convert("RGB").resize((PX, PX), Image.LANCZOS)
        if k == "dd_stat":
            continue                                      # the bronze first set is superseded by dd_statc
        nm = {"dd_statc": "stat_%s", "dd_idea": "idea_%s", "dd_note": "note_%s"}.get(k, "")
        nm = (nm % iid if nm else "%s_%s" % (k[3:], iid)) + ".webp"
        im.save(os.path.join(DEST, nm), "WEBP", quality=86, method=6)
        for n in e["nodes"]:
            index[str(n)] = {"icon": nm, "frame": FRAME_OF.get(k, "small"), "kind": k[3:]}
        done += 1
    pearl = [os.path.join(AI, "dd_roadmotif", "qi_pearl_dd%d.png" % j) for j in range(2)]
    for kind in P.ROAD_KINDS:
        for j, f in enumerate(pearl):
            P.colourize(f, kind).resize((PX, PX), Image.LANCZOS).save(
                os.path.join(DEST, "road_%s_%d.webp" % (kind.replace("+", "_"), j)), "WEBP", quality=86, method=6)
    holes = {}
    for fk in FS.HOLE:
        import picks_dao_do as PK
        img, hole = P.frame(PK.frame_path(fk), fk, PX)
        img.save(os.path.join(DEST, "frame_%s.webp" % fk), "WEBP", quality=90, method=6)
        holes[fk] = round(hole / PX, 4)
    json.dump({"_doc": "Hole radius of each frame as a share of its image width; the painting is cropped to this "
                       "circle (zoomed 1/0.86, roads 1.7x more) and laid under the frame. Written by install_dao_do.py.",
               "hole": holes, "road_zoom": 1.7, "road_candidate": "(node_id * 2654435761 >> 7) % 2"},
              open(os.path.join(DEST, "FRAMES.json"), "w", encoding="utf-8"), indent=1)
    m = json.load(open(os.path.join(ROOT, "assets", "data", "dao_do_map.json"), encoding="utf-8"))
    for n in m["nodes"]:
        if n["kind"] == "road":
            g = sorted((n.get("grants") or {}).keys())
            rk = "hub" if len(g) == 5 else "+".join(g)
            if rk in P.ROAD_KINDS:
                index[str(n["id"])] = {"icon": "road_%s_%d.webp" % (rk.replace("+", "_"), P.road_candidate(n["id"])),
                                       "frame": "road", "kind": "road"}
    json.dump({"_doc": "Đạo Đồ node art (art bible 7.9): node id -> icon file in this folder, frame kind, icon kind. "
                       "Frames are frame_<kind>.webp; FRAMES.json gives each frame's hole and the road zoom. Notable "
                       "paintings are drawn with a darkening tone in the viewer (NOT SETTLED, art bible 7.9): gamma 1.4, "
                       "rim 0.35, saturation 0.9. Written by install_dao_do.py.", "nodes": index},
              open(os.path.join(DEST, "INDEX.json"), "w", encoding="utf-8"), separators=(",", ":"))
    print("installed\t%d icons, %d road images, %d frames -> %s" % (done, 2 * len(P.ROAD_KINDS), len(holes), os.path.relpath(DEST, ROOT)))
    print("missing\t%d %s" % (len(missing), " ".join(missing[:40])))
    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())
