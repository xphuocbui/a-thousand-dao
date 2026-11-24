"""Painted công pháp icons for the slot cards and technique rows (user 2026-11-24: "do 3": the cards showed element
status icons). Techniques are mostly generated (item_factory.gd: a tech_kind, element names, a tier), so the icons go
by type: tech_<kind>_<element>_<band>.png, kind main (a cultivation method), secret (a secret art used in fights) or
body (a body method, no element); element kim / moc / thuy / hoa / tho / multi; band low (Hoàng, Huyền) or high
(Địa, Thiên giai, grander). Painted by OpenAI's image model at low quality in the art-icon grammar (a colour field of the
element, the subject mid-moment, glowing energy brightest).

Masters: tools/asset-pipeline/icons/ai/openai/tech/<key>.png (git-ignored). Game copies: assets/icons/techniques/<key>.png
at 128 px. Usage (repo root): python -I tools/asset-pipeline/icons/gen_tech_icons.py [test]
"""
import base64, concurrent.futures, json, os, sys, time, urllib.error, urllib.request
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
OUT = os.path.join(HERE, "ai", "openai", "tech")
GAME = os.path.join(ROOT, "assets", "icons", "techniques")
STYLE = ("%s. Square game ability icon, semi-realistic painted concept art, Chinese xianxia cultivation theme. The whole square "
         "is filled with a rich %s colour field, darker toward the corners; nearly monochrome, one hue family from deep shadow to "
         "blazing white. Solid forms are dark or mid-tone silhouettes cut against intense glowing energy, which is the brightest "
         "thing in the image. Strong bloom, a bold composition cropped tight, high contrast, readable at 48 pixels. No text, no "
         "letters, no numbers, no border, no frame, no UI, no watermark.")
HUE = {"kim": "silver white and pale gold (#DCE3EC)", "moc": "jade green (#2FBF8A)", "thuy": "deep blue (#3F6FE0)",
       "hoa": "vermilion (#E8442A)", "tho": "earthen ochre (#B98A3E)", "multi": "iridescent five-colour", "body": "bronze and blood red"}
ELEMENT_WORD = {"kim": "metal: blades of light", "moc": "wood: vines and leaves", "thuy": "water: waves and mist",
                "hoa": "fire: flames", "tho": "earth: stone and mountains", "multi": "the five elements circling together"}


def subject(kind, el, band):
    grand = band == "high"
    if kind == "main":
        s = "A cultivator seated in meditation, a cultivation method's energy of %s spiralling around them" % ELEMENT_WORD[el]
        return s + (", a vast heavenly mandala behind them" if grand else ", a modest glow")
    if kind == "secret":
        s = "A secret combat art unleashed: a striking hand or blade bursting with %s" % ELEMENT_WORD[el]
        return s + (", a world-shaking blast" if grand else ", a sharp focused strike")
    s = "A body-tempering method: a muscular torso of a cultivator with glowing bones and veins of bronze qi"
    return s + (", skin like a golden vajra statue" if grand else ", iron-hard skin")


def keys():
    out = []
    for kind in ("main", "secret"):
        for el in ("kim", "moc", "thuy", "hoa", "tho", "multi"):
            for band in ("low", "high"):
                out.append((kind, el, band))
    out += [("body", "body", "low"), ("body", "body", "high")]
    return out


def paint(k):
    kind, el, band = k
    key = "tech_%s_%s_%s" % k
    full = os.path.join(OUT, key + ".png")
    if os.path.exists(full):
        return key, "skip"
    text = STYLE % (subject(kind, el, band), HUE[el])
    body = json.dumps({"model": "gpt-image-2", "prompt": text, "n": 1, "size": "1024x1024", "quality": "low"}).encode()
    req = urllib.request.Request("https://api.openai.com/v1/images/generations", data=body, headers={
        "Authorization": "Bearer " + os.environ["OPENAI_API_KEY"], "Content-Type": "application/json"})
    for attempt in range(3):
        try:
            r = json.load(urllib.request.urlopen(req, timeout=600))
            break
        except urllib.error.HTTPError as e:
            if e.code in (429, 500, 502, 503) and attempt < 2:
                time.sleep(20 * (attempt + 1))
                continue
            return key, "HTTP %d %s" % (e.code, e.read().decode()[:300])
        except Exception as e:
            if attempt < 2:
                continue
            return key, "error %s" % e
    os.makedirs(OUT, exist_ok=True)
    open(full, "wb").write(base64.b64decode(r["data"][0]["b64_json"]))
    json.dump({"prompt": text, "usage": r.get("usage")}, open(full[:-4] + "-meta.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    return key, "ok"


def main():
    ks = keys()
    if "test" in sys.argv:
        ks = [("main", "hoa", "low"), ("secret", "kim", "high"), ("body", "body", "low")]
    with concurrent.futures.ThreadPoolExecutor(6) as ex:
        for key, res in ex.map(paint, ks):
            if res not in ("ok", "skip"):
                print(key, res, flush=True)
    n = 0
    for k in keys():
        src = os.path.join(OUT, "tech_%s_%s_%s.png" % k)
        if os.path.exists(src):
            Image.open(src).convert("RGB").resize((128, 128), Image.LANCZOS).save(os.path.join(GAME, "tech_%s_%s_%s.png" % k))
            n += 1
    print("installed", n)


if __name__ == "__main__":
    main()
