"""Generate painted icon candidates with an image model (art bible §7.1, §7.4, §7.4b, §8.6 item 9).

Builds one prompt per icon (arts, techniques, wards, statuses, counters, stances, element glyphs) from the art bible's
grammar and the game data, calls Recraft and/or OpenAI, saves every candidate with its prompt, model and seed, and
writes a pick sheet (one row per icon, one column per candidate) for the user to choose from.

Keys come only from the environment: RECRAFT_API_TOKEN, OPENAI_API_KEY. A missing key skips that provider and says so.
Costs are estimates from the providers' published per-image prices (OpenAI's is unverified).

Run (from the repo root):
  python -I tools/asset-pipeline/icons/gen_ai.py --set test --provider both --n 2 --dry-run   (prompts and cost only)
  python -I tools/asset-pipeline/icons/gen_ai.py --set test --provider both --n 2
Default provider: openai (gpt-image-2, user choice 2026-11-12). Sets: test (17 icons), dao_do_test (the look test), dao_do (the full node set), dao_do_frames (6 painted frames), dao_do_roads (3 colourless road motifs), arts, techniques, wards, statuses, counters, stances, glyphs, chips (the last four), all.
Subjects are hand-written per icon in subjects.py.
"""
import argparse
import concurrent.futures
import base64
import glob
import io
import json
import os
import sys
import threading
import time
import urllib.error
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
OUTDIR = os.path.join(HERE, "ai")
PRICE = {"recraft": 0.035, "openai": 0.211}           # USD per image: recraftv4_1 raster; gpt-image-2 high 1024 (unverified)
MODEL = {"recraft": "recraftv4_1", "openai": "gpt-image-2"}
QUALITY = ["high"]
OPENAI_PRICE = {"low": 0.006, "medium": 0.053, "high": 0.211}   # gpt-image-2 1024x1024, unverified

HUE = {"fire": ("vermilion", "#E8442A"), "water": ("deep blue", "#3F6FE0"), "wood": ("jade green", "#2FBF8A"),
       "metal": ("silver white", "#DCE3EC"), "earth": ("earthen brown", "#8F5A2E"), "ice": ("pale cyan", "#7AD7F0"),
       "thunder": ("violet", "#A15CFF"), "wind": ("pale mint", "#A6EBD8"), "phys": ("bone white", "#C9C2B2"),
       "force": ("rose", "#E58FB5"), "chaos": ("magenta", "#E0409A"), "soul": ("lavender white", "#CFC4FF"),
       # Đạo Đồ (art bible 7.9, provisional): neutral for shared stat icons; Light and Darkness lands
       "stat": ("antique bronze", "#B08D57"),
       # Đạo Đồ stat families (design/research/poe-node-icons.md §4, approved for the test 2026-11-20)
       "body": ("crimson", "#B3243A"), "linh": ("azure", "#4FA3FF"), "mind": ("lavender", "#B79CFF"),
       "offence": ("amber", "#F0A030"), "defence": ("slate steel blue", "#7F9CB8"), "fortune": ("rich gold", "#E6B84A"),
       "craft": ("copper", "#D08850"), "poison": ("venom green-yellow", "#A3C93A"), "sword": ("steel blue-grey", "#9FB3C8"), "light": ("bright sunlight yellow", "#FFE45C"), "dark": ("dark purple", "#6B2D8F")}

# Palette v2 (2026-11-20, design/research/poe-node-icons.md 4b): chosen by measurement for the Đạo Đồ and the
# fight screen alike (art bible 7.5). Sword joins Metal. The old values above stay only as history.
HUE.update({
    "body": ("crimson", "#C62839"), "fire": ("flame orange", "#FF7A1A"), "fortune": ("rich gold", "#FFD24A"),
    "mind": ("lavender", "#B49CFF"), "offence": ("keen sky-cyan", "#7FE0FF"), "defence": ("slate blue", "#3F6F9F"),
    "linh": ("azure", "#3D8BFF"), "craft": ("brass", "#A0A040"), "wood": ("qing blue-green", "#22B07A"),
    "metal": ("white", "#FFFFFF"), "sword": ("white", "#FFFFFF"), "water": ("sapphire blue", "#2A50E0"),
    "ice": ("frost white-cyan", "#C8F8FF"), "thunder": ("electric violet", "#B060FF"), "dark": ("dark violet", "#8A3AB8"),
    "chaos": ("magenta", "#C02CA8"), "earth": ("ochre brown", "#B47A40"), "light": ("pale radiant white-gold", "#FFFBE0"),
    "phys": ("bone", "#BFB39A"), "force": ("bone", "#BFB39A"), "wind": ("pale mint", "#B5F5E0"), "poison": ("venom lime", "#D0F040"),
})


def _shade(hx, f):
    """f < 1 darkens toward black, f > 1 lightens toward white."""
    c = [int(hx[i:i + 2], 16) for i in (1, 3, 5)]
    c = [v * f for v in c] if f < 1 else [v + (255 - v) * (f - 1) for v in c]
    return "#%02X%02X%02X" % tuple(int(max(0, min(255, round(v)))) for v in c)


def _hue_turn(hx, deg):
    """The same colour turned a few degrees round the hue wheel: a neighbouring shade inside the group."""
    import colorsys
    r, g, b = [int(hx[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    h, l, s_ = colorsys.rgb_to_hls(r, g, b)
    r, g, b = colorsys.hls_to_rgb((h + deg / 360) % 1, l, s_)
    return "#%02X%02X%02X" % (int(r * 255), int(g * 255), int(b * 255))


# Style validated by the user on GPT Image 2 (2026-11-12): the whole tile is one hue field, painted concept art, an
# action caught mid-moment, a dark subject against blazing light (art bible 7.2, revised).
STYLE = ("Square game ability icon, semi-realistic painted concept art, cinematic spell-effect still, Chinese xianxia "
         "cultivation theme. The whole square is filled with a rich {hue_name} colour field ({hex}), darker toward the "
         "corners; nearly monochrome, one hue family from deep shadow to blazing white. The subject is caught mid-moment; "
         "solid forms are dark or mid-tone silhouettes cut against intense glowing energy, which is the brightest thing "
         "in the image. Strong bloom, sparks and motion streaks, a dynamic often diagonal composition cropped tight so "
         "the effect fills the frame and runs off its edges. Vivid and luminous, high contrast, readable at 48 pixels. "
         "No text, no letters, no numbers, no border, no frame, no UI, no watermark.")
# Chip style (2026-11-12): the flat glyph read as clip art. Element stacks only (user: "the basic buffs and debuffs are
# fine, everything else should be the same") are painted as ONE bold emblem on a dark tinted ground, so they read at
# 24 px inside the in-engine green or red halo (art bible 7.4). Statuses, counters and stances use the art STYLE.
CHIP_STYLE = ("Small square status-effect icon for a game HUD, painted in a semi-realistic glowing concept-art manner, "
              "Chinese xianxia cultivation theme. One single bold emblem, centred, filling about two thirds of the square, "
              "with a thick simple silhouette that still reads at 24 pixels. The emblem is made of luminous {hue_name} "
              "light ({hex}) with a white-hot core and crisp edges, softly blooming, with a little painterly texture; the "
              "background is a deep, almost black {hue_name}-tinted vignette with a faint glow behind the emblem and dark "
              "space all round the edge. Minimal detail, no scene, no extra objects, no motion clutter. No text, no "
              "letters, no numbers, no border, no frame, no ring, no UI, no watermark.")
# Đạo Đồ stat icons v2 (PoE study 2026-11-20): the colour names the family, so the whole circle is one rich colour field,
# as PoE's passive icons and our fight icons (art bible 7.2) are; the picture names the stat.
STAT_STYLE = ("Circular medallion icon for a passive skill tree node, semi-realistic painted concept art, Chinese xianxia "
              "cultivation theme. The whole circle is filled with a rich, saturated {hue_name} colour field ({hex}), shading "
              "from deep {deep} in the shadows to bright {bright} in the glow, with touches of a neighbouring shade ({accent}); "
              "the {hue_name} must clearly dominate. One simple bold subject, centred, a dark or mid-tone silhouette cut "
              "against glowing energy, readable at 40 pixels. Vivid and luminous, high contrast. No text, no letters, no "
              "numbers, no border, no frame, no ring drawn around it, no UI, no watermark.")
# Đạo Đồ stat icons, style 2 (2026-11-20, research §6-7: PoE icons are dark paintings with deep shadows and two or three
# hues; ours were bright single-hue discs, so clusters read as flat colour). The group colour still dominates.
STAT_STYLE2 = ("Circular medallion icon for a passive skill tree node, semi-realistic painted concept art in a dark, moody "
               "fantasy style, Chinese xianxia cultivation theme. Deep shadows: about a quarter of the image is near-black, "
               "with strong chiaroscuro and a rim light. The subject is lit mainly by {hue_name} light ({hex}), the dominant "
               "colour, with a contrasting accent of {counter} and a touch of {accent}, so the palette is rich and layered, "
               "never one flat colour. The background is dark and atmospheric, not a glowing colour field. One clear subject, "
               "centred, detailed but readable at 40 pixels, painterly texture. No text, no letters, no numbers, no border, "
               "no frame, no ring drawn around it, no UI, no watermark.")
NOTE_STYLE = STAT_STYLE.replace("One simple bold subject, centred,", "A richer, more detailed subject than a small node, still centred and bold; "
                                "it may keep a little natural colour of its own,")
# Keystones, capabilities, Effect notables and starts: the notable style, as a dramatic iconic moment.
SPECIAL_STYLE = NOTE_STYLE.replace("A richer, more detailed subject", "A dramatic, iconic, richly detailed subject")
# Đạo Đồ road motif: painted colourless so one painting can be colour-mapped to every element (frames_painted.colourize).
ROAD_STYLE = ("Circular medallion icon for a passive skill tree travel node, semi-realistic painted glowing energy, "
              "Chinese xianxia cultivation theme. Strictly greyscale: pure white and silver light on a plain near-black "
              "ground, no colour at all. The subject is centred and small, about half the circle, simple and bold so it "
              "reads at 30 pixels, with a white-hot core and soft bloom. Calm and iconic. No text, no letters, no numbers, "
              "no border, no frame, no ring drawn around it, no UI, no watermark.")
# Đạo Đồ painted frame (option B): one ring seen straight on, centred, an empty black centre to be cut out.
FRAME_STYLE = ("Game UI asset: a single circular ornamental frame ring for a skill tree node, seen perfectly straight on, "
               "exactly centred, the ring's outer edge just inside the image edges. Semi-realistic painted metalwork with "
               "real depth: bevels, raised mouldings, worn highlights on the edges, dark patina in the recesses, lit from "
               "the top-left with a soft shadow on the lower right. The centre of the ring is completely empty flat black, "
               "and the area outside the ring is flat black. Chinese xianxia style ornament, accents of {hue_name} "
               "({hex}) only where named. Perfectly round, symmetric. No text, no letters, no icon or picture in the centre, "
               "no background scene, no watermark.")
# Đạo Đồ node style (art bible 7.9, user 2026-11-20: round nodes like a PoE passive tree). The painting is a circle
# medallion; the round frame is added afterwards (frames_dao_do.py), so the painting carries none.
ROUND_STYLE = ("Circular medallion icon for a passive skill tree node, semi-realistic painted concept art, Chinese "
               "xianxia cultivation theme. The subject is centred and composed to fit inside a circle, filling about "
               "four fifths of it, with a simple bold silhouette that still reads at 40 pixels. Lit by luminous "
               "{hue_name} light ({hex}) with a white-hot core, nearly monochrome, one hue family from deep shadow to "
               "bright highlight; the area outside the circle is plain near-black. Calm, iconic, emblem-like rather "
               "than a busy scene; soft bloom, a little painterly texture. No text, no letters, no numbers, no border, "
               "no frame, no ring drawn around it, no UI, no watermark.")

def items(which):
    """(kind, id, hue, subject, style) for every icon in the set; subjects are hand-written in subjects.py."""
    sys.path.insert(0, HERE)
    if which == "dao_do_special":
        import subjects_dao_do as D
        return [(k, i, D.TABLE[k][i][0], D.TABLE[k][i][1], SPECIAL_STYLE) for k in ("dd_keystone", "dd_cap", "dd_effect", "dd_start")
                for i in D.TABLE[k]]
    if which in ("dao_do_note_test", "dao_do_note"):
        import subjects_dao_do as D
        return [("dd_note", i, D.NOTE[i][0], D.NOTE[i][1], NOTE_STYLE) for i in D.NOTE]
    if which == "dao_do_statc2":
        import subjects_dao_do as D
        return [("dd_statc", i, D.STATC[i][0], D.STATC[i][1], STAT_STYLE2) for i in D.STATC]
    if which in ("dao_do_statc_test", "dao_do_statc"):
        import subjects_dao_do as D
        return [("dd_statc", i, D.STATC[i][0], D.STATC[i][1], STAT_STYLE) for i in D.STATC]
    if which == "dao_do_roads":
        import subjects_dao_do as D
        return [("dd_roadmotif", i, h, subj, ROAD_STYLE) for i, (h, subj) in D.ROAD_MOTIF.items()]
    if which == "dao_do_frames":
        import subjects_dao_do as D
        return [("dd_frame", i, h, subj, FRAME_STYLE) for i, (h, subj) in D.FRAME.items() if not i.endswith("2")]
    if which == "dao_do_frames2":
        import subjects_dao_do as D
        return [("dd_frame", i, D.FRAME[i][0], D.FRAME[i][1], FRAME_STYLE) for i in ("notable2", "keystone2")]
    if which in ("dao_do_test", "dao_do"):
        import subjects_dao_do as D
        keys = D.TEST if which == "dao_do_test" else [(k, i) for k in D.FULL for i in D.TABLE[k]]
        return [(k, i, D.TABLE[k][i][0], D.TABLE[k][i][1], ROUND_STYLE) for k, i in keys]
    import subjects as S
    out = []
    names = {}
    for f in glob.glob(os.path.join(ROOT, "design", "arts", "family-*.json")) + glob.glob(os.path.join(ROOT, "design", "arts", "part-*.json")):
        for a in json.load(open(f, encoding="utf-8")):
            names[a["id"]] = a.get("name", a["id"]).split(" (")[0]
    missing = [i for i in names if i not in S.ART]
    if missing:
        print("MISSING_SUBJECT	arts with no subject in subjects.py: %s" % ",".join(sorted(missing)))
    if which in ("arts", "all", "test"):
        for aid in sorted(names):
            if aid in S.ART:
                el, subj = S.ART[aid]
                out.append(("art", aid, el, "%s: %s" % (names[aid], subj), STYLE))
    if which in ("techniques", "all", "test"):
        for f in sorted(glob.glob(os.path.join(ROOT, "design", "techniques", "catalogue-*.json"))):
            for t in json.load(open(f, encoding="utf-8")):
                el, form, subj = S.TECH[t["id"]]
                nm = t["name"].split(" (")[0]
                if form == "body":
                    what = "%s, a body-refining art: %s" % (nm, subj)
                else:
                    what = ("%s: a closed cultivation scripture book with %s, seen at a slight angle, %s"
                            % (nm, S.TIER_BIND[t["tier"]], subj))
                out.append(("tech", t["id"], el, what, STYLE))
    if which in ("wards", "all", "test"):
        for wid, (el, subj) in S.WARD.items():
            out.append(("ward", wid, el, "A protective ward, symmetric and calm, no motion: " + subj, STYLE))
    if which in ("statuses", "chips", "all", "test"):
        for sid, (el, subj) in S.STATUS.items():
            out.append(("status", sid, el, subj, STYLE))
    if which in ("counters", "chips", "all"):
        for cid, (el, subj) in S.COUNTER.items():
            out.append(("counter", cid, el, subj, STYLE))
    if which in ("stances", "chips", "all"):
        for sid, (el, subj) in S.STANCE.items():
            out.append(("stance", sid, el, subj, STYLE))
    if which in ("glyphs", "chips", "all", "test"):
        for gid, (el, subj) in S.GLYPH.items():
            out.append(("glyph", gid, el, subj, CHIP_STYLE))
    if which == "test":
        keep = {("art", x) for x in ("twin-flame-echo", "swelling-tide-palm", "sheathed-edge", "strata-hammer", "harvest-bloom",
                                      "stilled-instant", "chain-arc", "three-step-chase", "tolling-bell-requiem", "hollowing-strike")}
        keep |= {("tech", "red-sun-scripture"), ("tech", "unbroken-flesh-canon"), ("ward", "golden-bell"),
                 ("ward", "black-tortoise-shell"), ("status", "bleed"), ("status", "withering"), ("glyph", "fire")}
        out = [o for o in out if (o[0], o[1]) in keep]
    return out


def prompt_of(kind, iid, el, what, style):
    hn, hx = HUE[el]
    import zlib
    turn = 14 if zlib.crc32(("%s/%s" % (kind, iid)).encode("utf-8")) % 2 else -14
    return what + ". " + style.format(hue_name=hn, hex=hx, what=what, deep=_shade(hx, 0.45), bright=_shade(hx, 1.45),
                                      accent=_hue_turn(hx, turn), counter=_shade(_hue_turn(hx, 165), 0.8))


def post(url, body, key, timeout=180):
    req = urllib.request.Request(url, data=json.dumps(body).encode("utf-8"), method="POST",
                                 headers={"Authorization": "Bearer " + key, "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read().decode("utf-8"))


def gen(provider, prompt, n, seed):
    if provider == "recraft":
        body = {"prompt": prompt, "model": MODEL["recraft"], "size": "1:1", "n": n, "style": "any",
                "response_format": "b64_json", "image_format": "png", "random_seed": seed}
        res = post("https://external.api.recraft.ai/v1/images/generations", body, os.environ["RECRAFT_API_TOKEN"])
        out = []
        for d in res.get("data", []):
            if d.get("b64_json"):
                out.append(base64.b64decode(d["b64_json"]))
            elif d.get("url"):
                out.append(urllib.request.urlopen(d["url"], timeout=120).read())
        return out
    body = {"model": MODEL["openai"], "prompt": prompt, "size": "1024x1024", "quality": QUALITY[0], "n": n,
            "output_format": "png", "background": "opaque"}
    res = post("https://api.openai.com/v1/images/generations", body, os.environ["OPENAI_API_KEY"])
    return [base64.b64decode(d["b64_json"]) for d in res.get("data", [])]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--set", default="test")
    ap.add_argument("--provider", default="openai", choices=["recraft", "openai", "both"])
    ap.add_argument("--quality", default="medium", choices=["low", "medium", "high"])
    ap.add_argument("--ids", help="only these icon ids (comma-separated), e.g. the rejects to redo at high")
    ap.add_argument("--tag", default="", help="file suffix for a rerun, e.g. h (saves <id>_h0.png)")
    ap.add_argument("--n", type=int, default=2)
    ap.add_argument("--workers", type=int, default=3, help="parallel requests (429s back off and retry)")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    QUALITY[0] = a.quality
    PRICE["openai"] = OPENAI_PRICE[a.quality]
    its = items(a.set)
    if a.ids:
        want = set(a.ids.split(","))
        its = [i for i in its if i[1] in want]
    provs = ["recraft", "openai"] if a.provider == "both" else [a.provider]
    est = sum(PRICE[p] for p in provs) * a.n * len(its)
    print("plan\t%d icons x %d candidates x %s = %d images, about $%.2f" % (len(its), a.n, "+".join(provs), len(its) * a.n * len(provs), est))
    if a.dry_run:
        for k, iid, el, what, style in its:
            print("prompt\t%s/%s\t%s" % (k, iid, prompt_of(k, iid, el, what, style)))
        return 0
    keys = {"recraft": "RECRAFT_API_TOKEN", "openai": "OPENAI_API_KEY"}
    ready = [p for p in provs if os.environ.get(keys[p])]
    for p in provs:
        if p not in ready:
            print("NOT_ASSESSED	%s skipped: environment variable %s is not set" % (p, keys[p]))
    if not ready:
        return 2
    os.makedirs(OUTDIR, exist_ok=True)
    log = open(os.path.join(OUTDIR, "log.jsonl"), "a", encoding="utf-8")
    lock = threading.Lock()
    state = {"spent": 0.0, "fails": 0, "stop": False}

    def have(d, iid):
        # candidates already on disk for this tag; a short icon (e.g. 1 of 2) is topped up, never overwritten
        return sorted(glob.glob(os.path.join(d, "%s_%s[0-9]*.png" % (glob.escape(iid), a.tag))))

    def one(job):
        k, iid, el, what, style, p = job
        if state["stop"]:
            return
        prompt = prompt_of(k, iid, el, what, style)
        d = os.path.join(OUTDIR, p, k)
        os.makedirs(d, exist_ok=True)
        need = a.n - len(have(d, iid))
        if need <= 0:
            return
        seed = abs(hash((iid, p))) % 100000
        for attempt in range(6):
            try:
                imgs = gen(p, prompt, need, seed)
                break
            except urllib.error.HTTPError as e:
                body = e.read()[:300].decode("utf-8", "replace")
                if e.code == 429 and "quota" not in body and "billing" not in body and attempt < 5:
                    time.sleep(20 * (attempt + 1))          # rate limit: back off and retry
                    continue
                with lock:
                    print("FAIL	%s	%s/%s	HTTP %d %s" % (p, k, iid, e.code, body), flush=True)
                    state["fails"] += 1
                    if e.code in (401, 403) or "insufficient_quota" in body or "credit_balance" in body or "billing" in body:
                        print("STOPPED	%s: account or billing problem; nothing more will succeed until it is fixed" % p, flush=True)
                        state["stop"] = True
                return
            except Exception as e:  # network, timeout
                if attempt < 2:
                    time.sleep(10)
                    continue
                with lock:
                    print("FAIL	%s	%s/%s	%s" % (p, k, iid, e), flush=True)
                    state["fails"] += 1
                return
        with lock:
            used = {os.path.basename(f) for f in have(d, iid)}
            j = 0
            for b in imgs:
                while "%s_%s%d.png" % (iid, a.tag, j) in used:
                    j += 1
                open(os.path.join(d, "%s_%s%d.png" % (iid, a.tag, j)), "wb").write(b)
                used.add("%s_%s%d.png" % (iid, a.tag, j))
            state["spent"] += PRICE[p] * len(imgs)
            log.write(json.dumps({"t": time.time(), "provider": p, "model": MODEL[p], "kind": k, "id": iid, "seed": seed,
                                  "n": len(imgs), "quality": QUALITY[0], "tag": a.tag, "prompt": prompt}) + chr(10))
            log.flush()
            print("ok	%s	%s/%s	%d images	(about $%.2f so far)" % (p, k, iid, len(imgs), state["spent"]), flush=True)

    jobs = [(k, iid, el, what, style, p) for k, iid, el, what, style in its for p in ready]
    with concurrent.futures.ThreadPoolExecutor(max_workers=a.workers) as ex:
        list(ex.map(one, jobs))
    print("spent	about $%.2f; %d failures" % (state["spent"], state["fails"]))
    print("next	python -I tools/asset-pipeline/icons/review.py   (builds the review page)")
    return 2 if state["stop"] else (1 if state["fails"] else 0)


def sheet(its, provs, n):
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        print("NOT_ASSESSED\tPillow missing: no pick sheet")
        return
    cell, lab = 160, 230
    W = lab + cell * n * len(provs)
    img = Image.new("RGB", (W, 30 + cell * len(its)), (236, 235, 227))
    dr = ImageDraw.Draw(img)
    for pi, p in enumerate(provs):
        dr.text((lab + pi * cell * n + 6, 8), "%s (%s)" % (p, MODEL[p]), fill=(30, 30, 30))
    for i, (k, iid, el, what, style) in enumerate(its):
        y = 30 + i * cell
        dr.text((6, y + 6), "%s\n%s" % (k, iid), fill=(30, 30, 30))
        for pi, p in enumerate(provs):
            for j in range(n):
                f = os.path.join(OUTDIR, p, k, "%s_%d.png" % (iid, j))
                if os.path.exists(f):
                    im = Image.open(f).convert("RGB").resize((cell - 8, cell - 8), Image.LANCZOS)
                    img.paste(im, (lab + (pi * n + j) * cell + 4, y + 4))
    p = os.path.join(OUTDIR, "pick_sheet.png")
    img.save(p)
    print("sheet\t%s" % p)


if __name__ == "__main__":
    sys.exit(main())
