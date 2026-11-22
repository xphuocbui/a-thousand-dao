# PROTOTYPE - NOT FOR PRODUCTION
"""One image-edit request to OpenAI's image model over a game screenshot (UI mood round, 2026-11-22).
usage: python -I img_edit.py <model> <quality> <size> <prompt.md> [<base.md>] -- <out.png> <screenshot.png>
The prompt is base.md (if given) + a blank line + prompt.md. Writes <out.png> and <out>-meta.json (usage only, never
the key). The key comes from OPENAI_API_KEY. Based on tools/design/dao_do_rework/underlay/img.py."""
import base64, json, os, re, sys, time, uuid, urllib.request, urllib.error

args = sys.argv[1:]
cut = args.index("--")
model, quality, size, *prompts = args[:cut]
out, *imgs = args[cut + 1:]
# HTML comments (the prototype header) are stripped before sending
text = "\n\n".join(re.sub(r"<!--.*?-->", "", open(p, encoding="utf-8").read(), flags=re.S).strip()
                   for p in reversed(prompts))
if "--dry" in os.environ.get("IMG_EDIT", ""):
    print(text)
    sys.exit(0)
fields = {"model": model, "prompt": text, "n": "1", "size": size, "quality": quality}
b = uuid.uuid4().hex
body = b""
for k, v in fields.items():
    body += f'--{b}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'.encode()
for p in imgs:
    body += (f'--{b}\r\nContent-Disposition: form-data; name="image[]"; filename="{os.path.basename(p)}"\r\n'
             f"Content-Type: image/png\r\n\r\n").encode() + open(p, "rb").read() + b"\r\n"
body += f"--{b}--\r\n".encode()
req = urllib.request.Request("https://api.openai.com/v1/images/edits", data=body, headers={
    "Authorization": "Bearer " + os.environ["OPENAI_API_KEY"], "Content-Type": f"multipart/form-data; boundary={b}"})
t = time.time()
try:
    r = json.load(urllib.request.urlopen(req, timeout=1200))
except urllib.error.HTTPError as e:
    print("HTTP", e.code, e.read().decode()[:1500])
    sys.exit(1)
open(out, "wb").write(base64.b64decode(r["data"][0]["b64_json"]))
meta = {k: v for k, v in r.items() if k != "data"}
meta.update({"model": model, "quality": quality, "size": size, "prompt": text})
json.dump(meta, open(out[:-4] + "-meta.json", "w", encoding="utf-8"), indent=1, ensure_ascii=False)
print(out, r.get("usage"), f"{time.time() - t:.0f}s")
