(function(){const want=['life','crit','mana','attributes','aura/reservation','energy shield','armour','evasion','minion','trap/mine','warcry','lightning'];
  let h='<thead><tr><th>Theme</th><th>PoE 1 clusters</th><th>Spread</th><th>Directions</th><th>Access</th><th>PoE 2 clusters</th><th>Spread</th><th>Directions</th><th>Access</th></tr></thead><tbody>';
  const cell=v=>v?`<td class="n">${v.clusters}</td><td class="n">${v.dispersion.toFixed(2)}</td><td class="n">${v.sectors_of_12} / 12</td><td class="n">${v.points_from_start_min_max[0]}–${v.points_from_start_min_max[1]}</td>`:'<td class="n">—</td><td></td><td></td><td></td>';
  for(const w of want)h+=`<tr><td>${w}</td>${cell(TM.poe1.themes[w])}${cell(TM.poe2.themes[w])}</tr>`;
  document.getElementById('themetab').innerHTML=h+'</tbody>';})();
