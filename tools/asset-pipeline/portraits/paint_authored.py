"""Authored art prompts (design/world/depth/art/README.md; user 2026-11-25: every portrait and place prompt is
authored for that person or place).

Portraits are the existing cast style block (gen_portraits.STYLE), then the sect's dress sheet
(design/world/depth/art/dress.json), then the person's hand-written subject paragraph
(design/world/depth/art/portraits/<batch>.json).

Places use the existing place-art base prompt (tools/asset-pipeline/map/prompts/place-base.md) with the authored
look and art_brief and a kind override (design/world/depth/art/places/<batch>.json), painted into the real map crop.
The crop is the same view as place_art.py plan; it is made here when missing.

Everything is written to separate folders, so no existing portrait, painting, sprite or game asset is touched:
  portraits: tools/asset-pipeline/portraits/out/authored/<batch>/<key>.png (+ -meta.json)
  places:    design/world/depth/art/places/out/<batch>/paint_<id>.png (+ prompt_<id>.md, in_<id>.png)
Nothing is installed into assets/ (installing is a later step, after the user's review).

usage (repo root):
  python -I tools/asset-pipeline/portraits/paint_authored.py prompts <batch>   write the assembled prompts for review
  python -I tools/asset-pipeline/portraits/paint_authored.py paint <batch> [--jobs 4]   paint what is not yet painted
The key comes only from OPENAI_API_KEY.
"""
import concurrent.futures
import glob
import importlib.util
import json
import os
import subprocess
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
ART = os.path.join(ROOT, "design", "world", "depth", "art")
spec = importlib.util.spec_from_file_location("gen_portraits", os.path.join(HERE, "gen_portraits.py"))
gp = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gp)

# How the portrait is used (art bible sections 1 and 3; the UI specs): added after the unchanged style block so the
# authored portraits keep the existing cast's look.
USAGE = ("How it is used: this is one person's own portrait in the game's character window, shown large in a carved "
         "rosewood and brass frame, and also cropped to a small round medallion about 36 pixels across in rankings, "
         "tooltips and on the map. So the face must read at that small size: the head and shoulders form a clear "
         "silhouette, the face is lit, and the one or two things that make this person recognisable are big and simple, "
         "not fine detail. The clothing's cut and collar shows at a glance what they are (a sect disciple, a loose "
         "cultivator in a travel cloak, a mortal in work clothes). Power is never drawn: a strong cultivator does not "
         "look grander, larger or more glowing than a weak one; any qi is a small, subtle hint of their element only. "
         "Cultivators are not poor: their clothes are well-made robes of fine, clean cloth, often spirit-woven, neatly "
         "kept and well fitted, even in a humble or frugal sect, where humble means plain colour and little ornament, "
         "never worn, frayed, patched or ragged. Wear and patches belong to mortals only. "
         "No numbers, writing or symbols that could read as text.")
SEX = {"m": "a man", "f": "a woman"}
MEMORIAL = " Painted as a memorial portrait of someone long dead: slightly faded, as on old silk."
PLACE_QUALITY, PLACE_SIZE = "low", "1536x864"   # user 2026-11-25: low on all
PX, VIEW = 12, (40, 22.5)   # as place_art.py


def load(p):
    return json.load(open(p, encoding="utf-8"))


def portrait_prompt(person, dress):
    sheet = dress.get(person["dress"]) if person.get("dress") else None
    text = gp.STYLE + "\n\n" + USAGE
    if sheet:
        text += "\n\nThe sect's dress: " + sheet
    text += "\n\nThe subject, %s who looks about %d: %s" % (SEX[person["sex"]], person["age"], person["subject"])
    if person.get("memorial"):
        text += MEMORIAL
    return text


PLACE_STYLE = ("A painted illustration of one place in an original Chinese cultivation (xianxia) world, for a historical "
               "grand-strategy game. Seen from high above at a steep aerial angle, as a bird circling overhead would see "
               "it, so that the whole place and its setting fill the frame. The place is painted at its true, grand, "
               "scale, and cultivators build with magic: a great sect is a domain kilometres across that houses thousands of "
               "people (disciples, servants, artisans, mortal families), with hundreds of buildings, palace-sized halls, "
               "whole mountainsides carved into terraces, towers taller than any mortal could raise, and works no mortal "
               "could build; a minor sect is a walled settlement of dozens to a hundred buildings; a city has walls, "
               "districts and tens of thousands of roofs; a village has all its houses, yards and fields. It is never a "
               "miniature, a model or a small compound. Refined semi-realistic painting with soft visible brushwork, rich natural colour, "
               "golden-hour light from the upper left with long soft shadows to the lower right, matching the game's "
               "painted relief map. No text, labels, banners with writing, flags with symbols, frame, border or "
               "watermark; people appear only as tiny figures that show the scale.")
PLACE_USAGE = ("How it is used: this is the place's own picture, shown as the wide banner at the top of its window in a "
               "carved wood frame. It must read at a glance as this one place and no other, with its signature feature "
               "large and clear.")


def place_prompt(place, base=None):
    return "\n\n".join([PLACE_STYLE, PLACE_USAGE, place["subject"]])


def place_crop(pid, dst):
    if os.path.exists(dst):
        return
    src = os.path.join(ROOT, "design/map/continent-11/art/places/in_%d.png" % pid)
    if os.path.exists(src):
        Image.open(src).save(dst)
        return
    cont = load(os.path.join(ROOT, "assets/data/world_continent.json"))
    tx, ty = next(p["tile"] for p in cont["places"] if p["id"] == pid)
    near = Image.open(os.path.join(ROOT, "assets/map/map_near_relief.jpg")).convert("RGB")
    cx, cy = (tx + 0.5) * PX, (ty + 0.5) * PX
    w, h = VIEW[0] * PX, VIEW[1] * PX
    x0, y0 = int(round(cx - w / 2)), int(round(cy - h / 2))
    near.crop((x0, y0, x0 + int(w), y0 + int(h))).resize((1536, 864), Image.BICUBIC).save(dst)


def main():
    cmd, batch = sys.argv[1], sys.argv[2]
    jobs = int(sys.argv[sys.argv.index("--jobs") + 1]) if "--jobs" in sys.argv else 4
    dress = load(os.path.join(ART, "dress.json"))
    for f in sorted(glob.glob(os.path.join(ART, "portraits", "*-dress.json"))):
        dress.update({k: v for k, v in load(f).items() if not k.startswith("_")})

    def gather(kind, field):
        # a batch is either <kind>/<batch>.json or a folder <kind>/<batch>/ of json files (one per sect or chunk)
        one = os.path.join(ART, kind, batch + ".json")
        files = [one] if os.path.exists(one) else sorted(glob.glob(os.path.join(ART, kind, batch, "*.json")))
        return [x for f in files for x in load(f)[field]]
    people = gather("portraits", "people")
    places = gather("places", "places")
    base = open(os.path.join(ROOT, "tools/asset-pipeline/map/prompts/place-base.md"), encoding="utf-8").read()
    pout = os.path.join(gp.OUT, "authored", batch)
    lout = os.path.join(ART, "places", "out", batch)
    if cmd == "prompts":
        lines = ["# Assembled prompts: %s" % batch, "",
                 "Generated by tools/asset-pipeline/portraits/paint_authored.py from design/world/depth/art/. "
                 "The style block is the same for every portrait and is shown once.", "",
                 "## The portrait style block (unchanged from the existing cast)", "", gp.STYLE, "",
                 "## The usage block (new, after the style block)", "", USAGE, "",
                 "## The place style block (every place)", "", PLACE_STYLE, "", PLACE_USAGE, ""]
        head = gp.STYLE + "\n\n" + USAGE
        for p in people:
            full = portrait_prompt(p, dress)
            lines += ["## Portrait: %s" % p["key"], ""]
            if p.get("imagined"):
                lines += ["*Imagined (not sent):* " + p["imagined"], ""]
            lines += [full[len(head):].strip(), ""]
        for p in places:
            lines += ["## Place %d: %s" % (p["id"], p["name"]), "", "*Where (from the record and the map crop):* " + p["where"], "",
                      "*Imagined (not sent):* " + p.get("imagined", ""), "", p["subject"], ""]
        out = os.path.join(ART, batch + "-prompts.md")
        open(out, "w", encoding="utf-8").write("\n".join(lines))
        print("wrote %s: %d portraits, %d places" % (os.path.relpath(out, ROOT), len(people), len(places)))
        return
    if cmd == "paint":
        os.makedirs(pout, exist_ok=True)
        os.makedirs(lout, exist_ok=True)
        todo = [p for p in people if not os.path.exists(os.path.join(gp.OUT, "authored", batch, p["key"] + ".png"))]
        with concurrent.futures.ThreadPoolExecutor(jobs) as ex:
            for key, res in ex.map(lambda p: gp.paint(p["key"], portrait_prompt(p, dress), os.path.join("authored", batch)), todo):
                print("portrait", key, res, flush=True)
        # medium-quality copies for comparison (also_medium), painted after the low pass
        med = [p for p in people if p.get("also_medium")
               and not os.path.exists(os.path.join(gp.OUT, "authored", batch, p["key"] + "__medium.png"))]
        if med:
            gp.QUALITY = "medium"
            with concurrent.futures.ThreadPoolExecutor(jobs) as ex:
                for key, res in ex.map(lambda p: gp.paint(p["key"] + "__medium", portrait_prompt(p, dress),
                                                          os.path.join("authored", batch)), med):
                    print("portrait", key, res, flush=True)
            gp.QUALITY = "low"
        todo_pl = [p for p in places if not os.path.exists(os.path.join(lout, "paint_%d.png" % p["id"]))]
        gp.QUALITY, gp.SIZE = PLACE_QUALITY, PLACE_SIZE
        for p in todo_pl:
            open(os.path.join(lout, "prompt_%d.md" % p["id"]), "w", encoding="utf-8").write(place_prompt(p))
        with concurrent.futures.ThreadPoolExecutor(jobs) as ex:
            for key, res in ex.map(lambda p: gp.paint("paint_%d" % p["id"], place_prompt(p),
                                                      os.path.relpath(lout, gp.OUT)), todo_pl):
                print("place", key, res, flush=True)
        gp.QUALITY, gp.SIZE = "low", "1024x1536"
        return
    sys.exit("unknown command " + cmd)


if __name__ == "__main__":
    main()
