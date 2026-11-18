"""Đạo Đồ look sketches from an OpenAI image model, with reference images in our renderer's style (2026-11-17).

Replaces sketch_gen.py's way of working: the prompt is a whole file (no parsing), the references are given in order,
input fidelity is high so the model keeps the roads it is given, and a review sheet puts the references beside the
results. Sketches are guides under the editor, never map data.

usage: python -I sketch2.py --prompt <prompt.md> --ref <img1.png> [--ref <img2.png> ...] --out <prefix>
                            [--model gpt-image-2.6-sunburst] [--n 3] [--size 1536x1024] [--quality high]
Reads OPENAI_API_KEY. Writes <prefix>-<i>.png, <prefix>.json (model, prompt, refs, timing, usage) and
<prefix>-sheet.png (references on the first row, results below).
"""
import argparse
import base64
import json
import os
import time
import urllib.error
import urllib.request
import uuid

from PIL import Image, ImageDraw


def multipart(fields, files):
    b = uuid.uuid4().hex
    out = []
    for k, v in fields.items():
        out += [f"--{b}\r\n".encode(), f'Content-Disposition: form-data; name="{k}"\r\n\r\n'.encode(),
                str(v).encode(), b"\r\n"]
    for k, path in files:
        out += [f"--{b}\r\n".encode(),
                f'Content-Disposition: form-data; name="{k}"; filename="{os.path.basename(path)}"\r\n'
                f'Content-Type: image/png\r\n\r\n'.encode(), open(path, "rb").read(), b"\r\n"]
    out.append(f"--{b}--\r\n".encode())
    return b"".join(out), f"multipart/form-data; boundary={b}"


def call(fields, refs):
    body, ctype = multipart(fields, [("image[]", r) for r in refs])
    req = urllib.request.Request("https://api.openai.com/v1/images/edits", data=body, method="POST",
                                 headers={"Authorization": "Bearer " + os.environ["OPENAI_API_KEY"],
                                          "Content-Type": ctype})
    return json.load(urllib.request.urlopen(req, timeout=900))


def sheet(refs, outs, path, cell=720):
    rows = [refs, outs]
    cols = max(len(r) for r in rows)
    ims = [[Image.open(p).convert("RGB") for p in r] for r in rows]
    h = [max(int(cell * im.height / im.width) for im in r) if r else 0 for r in ims]
    S = Image.new("RGB", (cols * cell, sum(h) + 2 * 28), (14, 16, 20))
    d = ImageDraw.Draw(S)
    y = 0
    for label, r, rh in zip(("references (in order)", "results"), ims, h):
        d.text((8, y + 8), label, fill=(200, 190, 160))
        y += 28
        for i, im in enumerate(r):
            S.paste(im.resize((cell, int(cell * im.height / im.width))), (i * cell, y))
        y += rh
    S.save(path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--ref", action="append", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--model", default="gpt-image-2.6-sunburst")
    ap.add_argument("--n", type=int, default=3)
    ap.add_argument("--size", default="1536x1024")
    ap.add_argument("--quality", default="high")
    a = ap.parse_args()
    prompt = open(a.prompt, encoding="utf-8").read().strip()
    fields = {"model": a.model, "prompt": prompt, "n": a.n, "size": a.size, "quality": a.quality,
              "input_fidelity": "high"}
    t = time.time()
    try:
        res = call(fields, a.ref)
    except urllib.error.HTTPError as e:
        msg = e.read().decode("utf-8", "replace")
        if "input_fidelity" not in msg:
            raise SystemExit(f"{a.model}: HTTP {e.code}: {msg[:600]}")
        print("model does not take input_fidelity; retrying without it")
        fields.pop("input_fidelity")
        res = call(fields, a.ref)
    dt = time.time() - t
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    paths = []
    for i, d in enumerate(res.get("data", [])):
        p = f"{a.out}-{i + 1}.png"
        open(p, "wb").write(base64.b64decode(d["b64_json"]))
        paths.append(p)
    meta = {"model": a.model, "prompt_file": a.prompt, "prompt": prompt, "refs": a.ref, "size": a.size,
            "quality": a.quality, "input_fidelity": fields.get("input_fidelity"), "seconds": round(dt, 1),
            "usage": res.get("usage"), "files": paths}
    json.dump(meta, open(a.out + ".json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    if paths:
        sheet(a.ref, paths, a.out + "-sheet.png")
    print(f"{a.model}: {len(paths)} image(s) in {dt:.0f}s, usage {res.get('usage')}")


if __name__ == "__main__":
    main()
