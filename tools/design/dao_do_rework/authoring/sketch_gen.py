"""Make Đạo Đồ look sketches with an OpenAI image model (reference images + a prompt from underlay/prompt.md).

usage: python -I sketch_gen.py <model> <prompt-letter A|B|C> <out-prefix> [n] [size] [quality] [ref1.png ref2.png ...]
  refs default to design/dao-do/underlay/current-layout.png and poe-grammar.png (B: poe-grammar.png only).
Reads OPENAI_API_KEY from the environment. Writes <out-prefix>-<i>.png and <out-prefix>.json (model, prompt, refs,
timing, usage). The sketches are guides under the editor, never map data.
"""
import base64
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
import uuid

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), *[".."] * 4))
UL = os.path.join(ROOT, "design", "dao-do", "underlay")


def prompt_text(letter):
    md = open(os.path.join(UL, "prompt.md"), encoding="utf-8").read()
    blocks = re.findall(r"## Prompt ([ABC])[^\n]*\n(.*?)(?=\n## |\Z)", md, re.S)
    sec = dict(blocks)[letter]
    codes = re.findall(r"```\n(.*?)```", sec, re.S)
    if letter == "B":  # B = A without its KEEP paragraph, plus B's composition paragraph
        a = re.findall(r"```\n(.*?)```", dict(blocks)["A"], re.S)[0]
        a = re.sub(r"KEEP from image 1:.*?\n\n", "", a, flags=re.S)
        a = a.replace("in image 1", "described below").replace("of image 2", "of the attached image")
        a = a.replace("COPY from image 2", "COPY from the attached image")
        return a.strip() + "\n\n" + codes[0].strip().replace("Attach only image 2.", "").strip()
    return codes[0].strip()


def multipart(fields, files):
    b = uuid.uuid4().hex
    out = []
    for k, v in fields.items():
        out += [f"--{b}\r\n".encode(), f'Content-Disposition: form-data; name="{k}"\r\n\r\n'.encode(), str(v).encode(), b"\r\n"]
    for k, path in files:
        out += [f"--{b}\r\n".encode(),
                f'Content-Disposition: form-data; name="{k}"; filename="{os.path.basename(path)}"\r\nContent-Type: image/png\r\n\r\n'.encode(),
                open(path, "rb").read(), b"\r\n"]
    out.append(f"--{b}--\r\n".encode())
    return b"".join(out), f"multipart/form-data; boundary={b}"


def main():
    a = sys.argv[1:]
    if len(a) < 3:
        raise SystemExit(__doc__)
    model, letter, prefix = a[0], a[1], a[2]
    n = int(a[3]) if len(a) > 3 else 1
    size = a[4] if len(a) > 4 else "1024x1024"
    quality = a[5] if len(a) > 5 else "high"
    refs = a[6:] or ([os.path.join(UL, "poe-grammar.png")] if letter == "B" else
                     [os.path.join(UL, "current-layout.png"), os.path.join(UL, "poe-grammar.png")])
    prompt = prompt_text(letter)
    body, ctype = multipart({"model": model, "prompt": prompt, "n": n, "size": size, "quality": quality},
                            [("image[]", r) for r in refs])
    req = urllib.request.Request("https://api.openai.com/v1/images/edits", data=body, method="POST",
                                 headers={"Authorization": "Bearer " + os.environ["OPENAI_API_KEY"], "Content-Type": ctype})
    t = time.time()
    try:
        res = json.load(urllib.request.urlopen(req, timeout=600))
    except urllib.error.HTTPError as e:
        raise SystemExit(f"{model}: HTTP {e.code}: {e.read().decode('utf-8', 'replace')[:600]}")
    dt = time.time() - t
    os.makedirs(os.path.dirname(os.path.abspath(prefix)), exist_ok=True)
    paths = []
    for i, d in enumerate(res.get("data", [])):
        p = f"{prefix}-{i + 1}.png"
        open(p, "wb").write(base64.b64decode(d["b64_json"]))
        paths.append(p)
    meta = {"model": model, "prompt_letter": letter, "prompt": prompt, "refs": [os.path.relpath(r, ROOT) for r in refs],
            "size": size, "quality": quality, "seconds": round(dt, 1), "usage": res.get("usage"), "files": paths}
    json.dump(meta, open(prefix + ".json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
    print(f"{model}: {len(paths)} image(s) in {dt:.0f}s, usage {res.get('usage')}")


if __name__ == "__main__":
    main()
