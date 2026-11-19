"""Sends one design request to the OpenAI Responses API. usage: python -I call.py <model> <prompt.md> <out_prefix> [img ...]
Writes <out_prefix>-raw.json (the whole response) and <out_prefix>-text.md (the output text). The key comes from the
environment and is never written."""
import base64, json, os, sys, time, urllib.request, urllib.error
model, prompt_path, pre, *imgs = sys.argv[1:]
content = [{'type': 'input_text', 'text': open(prompt_path, encoding='utf-8').read()}]
for p in imgs:
    content.append({'type': 'input_image', 'image_url': 'data:image/png;base64,' + base64.b64encode(open(p, 'rb').read()).decode()})
body = {'model': model, 'input': [{'role': 'user', 'content': content}]}
if os.environ.get('OAI_PREV'):
    body['previous_response_id'] = os.environ['OAI_PREV']
if os.environ.get('OAI_EFFORT'):
    body['reasoning'] = {'effort': os.environ['OAI_EFFORT']}
req = urllib.request.Request('https://api.openai.com/v1/responses', data=json.dumps(body).encode(),
                             headers={'Authorization': 'Bearer ' + os.environ['OPENAI_API_KEY'], 'Content-Type': 'application/json'})
t = time.time()
try:
    r = json.load(urllib.request.urlopen(req, timeout=3000))
except urllib.error.HTTPError as e:
    print('HTTP', e.code, e.read().decode()[:2000]); sys.exit(1)
json.dump(r, open(pre + '-raw.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
text = ''.join(c.get('text', '') for o in r.get('output', []) if o.get('type') == 'message' for c in o.get('content', []))
open(pre + '-text.md', 'w', encoding='utf-8').write(text)
print(r.get('model'), r.get('status'), 'usage', r.get('usage'), f'{time.time() - t:.0f}s')
