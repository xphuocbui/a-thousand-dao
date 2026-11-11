import json
import os

here = os.path.dirname(os.path.abspath(__file__))
maps = json.load(open(os.path.join(here, '..', 'maps', 'maps.json'), encoding='utf-8'))
body = open(os.path.join(here, 'body2.js'), encoding='utf-8').read()
out = 'const MAPS = ' + json.dumps(maps, ensure_ascii=False) + ';\n\n' + body
open(os.path.join(here, 'pixel_sets2.px.js'), 'w', encoding='utf-8', newline='\n').write(out)
print('ok', len(out))
