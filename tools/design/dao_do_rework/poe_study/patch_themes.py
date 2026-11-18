import sys
p = sys.argv[1]
t = open(p, encoding="utf-8").read()


def rep(a, b):
    global t
    assert t.count(a) == 1, (t.count(a), a[:60])
    t = t.replace(a, b)


rep('<option value="hubs">Crossroads and dead ends</option>',
    '<option value="hubs">Crossroads and dead ends</option>\n        <option value="theme">Where a theme sits</option>')
rep('<label for="start">Start</label>',
    '<label for="theme" id="theme-l" hidden>Theme</label>\n      <select id="theme" hidden></select>\n      <label for="start">Start</label>')
rep('<script id="metrics" type="application/json">__METRICS__</script>',
    '<script id="metrics" type="application/json">__METRICS__</script>\n<script id="themes" type="application/json">__THEMES__</script>\n<script id="tmetrics" type="application/json">__TMETRICS__</script>')
rep("const MET=JSON.parse(document.getElementById('metrics').textContent);",
    "const MET=JSON.parse(document.getElementById('metrics').textContent);\n"
    "const TH=JSON.parse(document.getElementById('themes').textContent),TM=JSON.parse(document.getElementById('tmetrics').textContent);\n"
    "const themeSel=document.getElementById('theme'),themeL=document.getElementById('theme-l');")
rep("  P[key]={...t,N,adj,bbox:[x0,y0,x1,y1],starts,deg:adj.map(a=>a.length)};",
    "  const cl=new Int32Array(N).fill(-1);(TH[key]?.clusters||[]).forEach((c,ci)=>c.forEach(i=>{cl[i]=ci;}));\n"
    "  P[key]={...t,N,adj,bbox:[x0,y0,x1,y1],starts,deg:adj.map(a=>a.length),cl,th:TH[key]};")
rep("  if(m==='hubs'){",
    "  if(m==='theme'){const c=t.cl[i];if(c<0)return ty===T_START?css.start:css.dim;return t.th.theme[c]===themeSel.value?css.path:css.travel;}\n"
    "  if(m==='hubs'){")
rep("  else h=`<span><i class=\"sw\" style=\"background:${css.accent}\"></i>crossroads",
    "  else if(m==='theme'){const k=TM[cur].themes[themeSel.value];h=`<span><i class=\"sw\" style=\"background:${css.path}\"></i>${themeSel.value} clusters</span><span><i class=\"sw\" style=\"background:${css.travel}\"></i>other notable clusters</span>`"
    "+(k?`<span>${k.clusters} clusters · ${k.sectors_of_12} of 12 directions · ${k.points_from_start_min_max[0]}–${k.points_from_start_min_max[1]} points from the nearest start</span>`:'');}\n"
    "  else h=`<span><i class=\"sw\" style=\"background:${css.accent}\"></i>crossroads")
rep("function fillStarts(){",
    "function fillThemes(){const tm=TM[cur].themes;const list=Object.keys(tm).sort((a,b)=>tm[b].clusters-tm[a].clusters);const prev=themeSel.value;"
    "themeSel.innerHTML=list.map(x=>`<option value=\"${x}\">${x} (${tm[x].clusters})</option>`).join('');"
    "const want=list.includes(prev)?prev:(list.includes('crit')?'crit':list[0]);themeSel.value=want;}\n"
    "function syncMode(){const on=modeSel.value==='theme';themeSel.hidden=!on;themeL.hidden=!on;}\n"
    "function fillStarts(){")
rep("hover=-1;tip.hidden=true;fillStarts();", "hover=-1;tip.hidden=true;fillStarts();fillThemes();syncMode();")
rep("modeSel.addEventListener('change',()=>{setLegend();draw();});",
    "modeSel.addEventListener('change',()=>{syncMode();setLegend();draw();});\nthemeSel.addEventListener('change',()=>{setLegend();draw();});")
rep("  const d=dist?dist[i]:-1;h+=",
    "  const c=t.cl[i];if(c>=0){const th=t.th;h+=`<div style=\"color:var(--muted)\">Cluster: ${th.theme[c]} · ${th.form[c]} · ${th.exits[c]} way${th.exits[c]===1?'':'s'} in${th.mastery[c]?' · '+th.mastery[c]+' mastery':''}</div>`;}\n"
    "  const d=dist?dist[i]:-1;h+=")

SECTION = open(p.replace("template.html", "clusters_section.html"), encoding="utf-8").read()
rep('<section>\n  <h2 style="margin-bottom:12px">Measured side by side</h2>',
    SECTION + '\n<section>\n  <h2 style="margin-bottom:12px">Measured side by side</h2>')
rep("let first='poe1';", open(p.replace("template.html", "themetab.js"), encoding="utf-8").read() + "\nlet first='poe1';")
open(p, "w", encoding="utf-8").write(t)
print("patched")
