import json
T = set(['fist', 'palm', 'body', 'stance', 'heavy', 'physical'])
for f in 'abc':
    for a in json.load(open('design/arts/part-%s.json' % f)):
        if a['element'] == '' and (set(a['tags']) & T or a['role'] in ('ward', 'heal')):
            print(f, json.dumps(a, ensure_ascii=False))
