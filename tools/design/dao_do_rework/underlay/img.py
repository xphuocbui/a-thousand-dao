"""One image-edit request to OpenAI. usage: python -I img.py <model> <prompt.md> <out_prefix> <n> <img> [img ...]
Writes <out_prefix>-<i>.png and <out_prefix>-meta.json (usage, no key)."""
import base64, json, os, sys, time, uuid, urllib.request, urllib.error
model, pp, pre, n, *imgs = sys.argv[1:]
fields = {'model': model, 'prompt': open(pp, encoding='utf-8').read(), 'n': n, 'size': '1024x1024', 'quality': 'high'}
b = uuid.uuid4().hex
body = b''
for k, v in fields.items():
    body += f'--{b}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'.encode()
for p in imgs:
    body += (f'--{b}\r\nContent-Disposition: form-data; name="image[]"; filename="{os.path.basename(p)}"\r\n'
             f'Content-Type: image/png\r\n\r\n').encode() + open(p, 'rb').read() + b'\r\n'
body += f'--{b}--\r\n'.encode()
req = urllib.request.Request('https://api.openai.com/v1/images/edits', data=body, headers={
    'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY'], 'Content-Type': f'multipart/form-data; boundary={b}'})
t = time.time()
try:
    r = json.load(urllib.request.urlopen(req, timeout=1200))
except urllib.error.HTTPError as e:
    print('HTTP', e.code, e.read().decode()[:1500]); sys.exit(1)
for i, d in enumerate(r['data']):
    open(f'{pre}-{i + 1}.png', 'wb').write(base64.b64decode(d['b64_json']))
json.dump({k: v for k, v in r.items() if k != 'data'}, open(pre + '-meta.json', 'w'), indent=1)
print(pre, len(r['data']), 'images', r.get('usage'), f'{time.time() - t:.0f}s')
