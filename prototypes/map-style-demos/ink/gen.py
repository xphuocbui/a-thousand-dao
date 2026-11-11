import json, os
here = os.path.dirname(os.path.abspath(__file__))
maps = json.load(open(os.path.join(here, '..', 'maps', 'maps.json'), encoding='utf-8'))
helpers = open(os.path.join(here, '_helpers.js'), encoding='utf-8').read()
body = open(os.path.join(here, 'body.js'), encoding='utf-8').read()
head = 'const MAPS = ' + json.dumps(maps, ensure_ascii=False) + ';\nconst T = 24;\nconst MG = 26;\nconst isLand = (c) => c !== "~" && c !== "w";\n'
open(os.path.join(here, 'ink_sets.vx.js'), 'w', encoding='utf-8', newline='\n').write(head + helpers + '\n' + body)
print('ok')
