p = 'body2.js'
lines = open(p, encoding='utf-8').read().split('\n')
out = []
i = 0
while i < len(lines):
    l = lines[i]
    while l.count('"') % 2 == 1 and i + 1 < len(lines):
        i += 1
        l = l + '\\n' + lines[i]
    out.append(l)
    i += 1
open(p, 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
print('lines', len(lines), '->', len(out))
