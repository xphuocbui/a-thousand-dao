import json, sys
p = 'design/arts/family-force-chaos.json'
d = json.load(open(p, encoding='utf-8'))
A = {a['id']: a for a in d}
P = json.load(open(sys.argv[1]))
for k, v in P.items():
    a = A[k]
    for path, val in v.items():
        o = a
        ks = path.split('.')
        for x in ks[:-1]:
            o = o[int(x)] if x.isdigit() else o[x]
        x = ks[-1]
        if x.isdigit():
            o[int(x)] = val
        else:
            o[x] = val
json.dump(d, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
