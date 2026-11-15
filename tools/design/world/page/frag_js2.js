(function () {
  "use strict";
  var D = JSON.parse(document.getElementById("c11data").textContent);
  var EV = D.events, AN = D.annals, S = D.sects, P = D.people, SL = D.slots, U = D.units;
  var GREATS = ["thien_xu", "tung_dao", "lac_ha", "thinh_vu", "bang_tam", "thuy_vi", "phuong_minh"];
  var SLOT_EL = { "L-1": "Water", "L-2": "Fire", "S-1": "Metal", "S-2": "Metal", "S-3": "Earth", "S-4": "Water", "S-5": "Fire",
    "S-6": "Wind", "S-7": "Wind", "S-8": "Light", "S-9": "Light", "S-10": "Darkness", "S-11": "Darkness", "S-12": "Ice", "S-13": "Thunder" };
  var KIND = {
    realm_opened: ["A realm opens", "land"], departure: ["A master leaves the world", "life"], natural: ["A mark on the land", "land"],
    sect_founded: ["A sect is founded", "sect"], tribulation: ["A tribulation survived", "life"], hermit: ["A hermit's mark", "land"],
    sect_fall: ["A sect falls", "war"], burial: ["A burial", "land"], realm_sealed: ["A realm is sealed", "land"], death: ["A death", "life"],
    tribulation_death: ["Death in tribulation", "life"], ascension: ["An ascension", "life"], sect_war: ["War breaks out", "war"],
    battle: ["Battle", "war"], truce: ["Truce", "war"], headship: ["A new head", "sect"], tale: ["A tale", "land"],
    claim: ["Land claimed", "sect"], city_founded: ["A city is founded", "city"], city_abandoned: ["A city is abandoned", "city"],
    city_ruined: ["A city falls", "city"], item_made: ["An item is made", "land"], item_found: ["An item is found", "land"],
    item_lost: ["An item is lost", "land"], item_passed: ["An item passes on", "land"], war_start: ["War begins", "war"],
    war_end: ["War ends", "war"], gift: ["A gift of land", "sect"], oath: ["An oath", "sect"], compact: ["The Compact", "sect"],
    omen: ["An omen", "land"], meeting: ["A meeting", "life"], fort_built: ["A fort is raised", "war"], appointment: ["An appointment", "sect"],
    pact: ["A secret pact", "sect"], disaster: ["A disaster", "land"], birth: ["A birth", "life"], duel: ["A duel", "life"],
    intervention: ["The Pivot steps in", "war"], petition: ["A petition", "sect"], edict: ["An edict", "sect"],
    settlement: ["A settlement", "city"], trade: ["Trade", "land"], beast: ["A beast", "land"], discovery: ["A discovery", "land"],
    festival: ["A festival", "city"], mine: ["A mine", "land"], raid: ["A raid", "war"], siege: ["A siege", "war"]
  };
  var GVAR = { sect: "var(--g-sect)", war: "var(--g-war)", city: "var(--g-city)", life: "var(--g-life)", land: "var(--g-land)" };
  var MCOL = { sect: "#7cc4a8", war: "#ff8a6a", city: "#c6b3ef", life: "#b9bcff", land: "#f0cd6a" };
  var SLOTK = { secret_realm: "Hidden secret realm", ruin: "Ruin of a vanished sect", abode: "Dead cultivator's cave abode",
    blessed_large: "Hidden large blessed land", blessed_small: "Hidden small blessed land" };
  var REALM = { hoa_than: "Hóa Thần", nguyen_anh: "Nguyên Anh", ket_dan: "Kết Đan", truc_co: "Trúc Cơ", luyen_khi: "Luyện Khí" };
  var ALIGN = { chinh: ["chính đạo", ""], trung: ["trung lập", "al-trung"], ma: ["ma đạo", "al-ma"] };
  var NOW = { id: "NOW", year: 1200, kind: "now", people: [], sects: [] };
  var ALL = EV.concat([NOW]);
  var byId = {}; ALL.forEach(function (e, i) { e.i = i; byId[e.id] = e; });
  var st = { g: "all", follow: null, lang: "en", active: null, region: 14, itemf: "all" };
  try { if (localStorage.getItem("c11-lang") === "vi") st.lang = "vi"; } catch (e) { /* storage unavailable */ }

  function esc(s) { return String(s == null ? "" : s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function rgb(c) { return c ? "rgb(" + c.join(",") + ")" : "var(--muted)"; }
  function num(n) { return n.toLocaleString("en-US"); }
  function grp(e) { return e.kind === "now" ? "now" : (KIND[e.kind] || ["", "land"])[1]; }
  function klabel(e) { return (KIND[e.kind] || [e.kind])[0]; }
  function sectChip(k) { var s = S[k]; if (!s) return ""; return '<span class="schip"><i style="background:' + rgb(s.col) + '"></i>' + esc(s.name) + (s.vanished ? " (fallen)" : "") + "</span>"; }
  function personBtn(k) { var p = P[k]; if (!p) return ""; return '<button type="button" class="pchip" data-follow="' + k + '" title="Follow ' + esc(p.name) + ' through the chronicle">' + esc(p.name) + "</button>"; }
  var ITEMS = {}; D.items.forEach(function (it) { ITEMS[it.key] = it; });
  function itemBtn(k) { var it = ITEMS[k]; if (!it) return ""; return '<button type="button" class="pchip" data-fitem="' + k + '" title="Follow this item through the chronicle">◆ ' + esc(it.name_hv) + "</button>"; }
  function regionsOf(slot) { var seen = []; SL[slot].c.forEach(function (c) { if (c.r && seen.indexOf(c.r) < 0) seen.push(c.r); }); return seen; }
  function orList(a) { return a.length < 2 ? a.join("") : a.slice(0, -1).join(", ") + " or " + a[a.length - 1]; }
  function atLabel(e) {
    if (e.kind === "now") return "The whole continent";
    if (e.slot) { var s = SL[e.slot]; return SLOTK[s.kind] + " " + e.slot + (SLOT_EL[e.slot] ? " · " + SLOT_EL[e.slot] : ""); }
    if (e.place && e.site && e.place !== e.site) return e.place + " · " + e.site;
    return e.place || e.site || e.region || "";
  }
  function txt(e) { return st.lang === "vi" ? e.text_vi : e.text; }
  function eraOf(y) { for (var i = 0; i < D.eras.length; i++) if (y >= D.eras[i].from && y <= D.eras[i].to) return i; return D.eras.length - 1; }

  // ---------- land holders
  var UKEYS = Object.keys(U);
  function unitsOf(land) {
    if (typeof land === "number") return UKEYS.filter(function (k) { return U[k].region === land; });
    var k = land.slice(5);
    if (U[k]) return [k];
    return UKEYS.filter(function (u) { return u.indexOf(k + "_") === 0; });
  }
  var CH = D.changes.slice().sort(function (a, b) { return a.y - b.y; });
  function holdersAt(y) {
    var h = {};
    CH.forEach(function (c) {
      if (c.y > y) return;
      unitsOf(c.land).forEach(function (u) { if ((h[u] || null) === c.from) h[u] = c.to; });
    });
    return h;
  }
  var MASK = {}, nLoaded = 0, OFF = document.createElement("canvas"); OFF.width = 1620; OFF.height = 1080;
  var OCTX = OFF.getContext("2d"), painted = [];
  UKEYS.forEach(function (k) {
    var im = new Image();
    im.onload = function () { nLoaded++; if (nLoaded === UKEYS.length) painted.forEach(function (p) { p.sig = null; paintUnits(p.el, p.y); }); };
    im.src = "u-" + k + ".png";
    MASK[k] = im;
  });
  function makeUnits(el) { painted.push({ el: el, y: 0, sig: null }); }
  function paintUnits(el, y) {
    var h = holdersAt(y), rec = painted.filter(function (p) { return p.el === el; })[0];
    var sig = UKEYS.map(function (k) { return h[k] || "-"; }).join("|");
    rec.y = y;
    if (rec.sig === sig || nLoaded < UKEYS.length) return h;
    rec.sig = sig;
    var ctx = el.getContext("2d");
    ctx.clearRect(0, 0, 1620, 1080);
    UKEYS.forEach(function (k) {
      var s = h[k] && S[h[k]];
      if (!s || !s.col) return;
      OCTX.globalCompositeOperation = "source-over";
      OCTX.clearRect(0, 0, 1620, 1080);
      OCTX.drawImage(MASK[k], 0, 0);
      OCTX.globalCompositeOperation = "source-in";
      OCTX.fillStyle = rgb(s.col);
      OCTX.fillRect(0, 0, 1620, 1080);
      ctx.globalAlpha = s.vanished ? 0.72 : 1;
      ctx.drawImage(OFF, 0, 0);
    });
    ctx.globalAlpha = 1;
    return h;
  }

  // ---------- chronicle list
  var list = document.getElementById("clist");
  function buildList() {
    var h = [], ei = -1;
    ALL.forEach(function (e) {
      if (e.kind !== "now") {
        var era = eraOf(e.year);
        if (era !== ei) {
          ei = era; var E = D.eras[ei];
          h.push('<li class="era-chap" data-chap="' + ei + '"><span>Years ' + num(E.from) + "–" + num(E.to) + " · " + esc(E.name_hv) + " " + esc(E.name_han) + "</span><b>" + esc(E.name) + "</b><p>" + esc(E.gist) + "</p></li>");
        }
        var g = grp(e), who = e.people.map(personBtn).join("") + e.sects.map(sectChip).join("") + (e.item ? itemBtn(e.item) : "");
        h.push('<li class="ev" tabindex="0" data-id="' + e.id + '" data-chap="' + ei + '">' +
          '<div class="ev-y"><b>' + num(e.year) + "</b><span>" + e.id + (e.secret ? " · secret" : "") + "</span></div>" +
          '<div class="ev-b"><div class="ev-k"><span class="kchip" style="color:' + GVAR[g] + '">' + klabel(e) + "</span><span>" + esc(atLabel(e)) + "</span></div>" +
          '<p class="ev-t"></p><div class="ev-who">' + who + "</div></div></li>");
      } else {
        h.push('<li class="era-chap"><span>Year 1,200</span><b>The game begins</b></li>');
        h.push('<li class="ev now" tabindex="0" data-id="NOW"><div class="ev-y"><b>1,200</b><span>now</span></div>' +
          '<div class="ev-b"><div class="ev-k"><span class="kchip" style="color:var(--gold)">The starting year</span><span>The whole continent</span></div>' +
          '<p class="ev-t"></p><div class="ev-who">' + GREATS.map(headOf).filter(Boolean).map(personBtn).join("") + personBtn("mac_quy_khu") + personBtn("thoi_khinh_hong") + "</div></div></li>");
      }
    });
    list.innerHTML = h.join("") + '<li class="empty" id="cempty" hidden>No events match this filter.</li>';
    setTexts();
  }
  var nowText = "The chronicle ends and every game begins. 51 people are alive, the Pivot keeps the North Star Compact over seven great sects and 22 vassals, and each hidden place lies at the spot this game's seed picked. The map shows where the living cast can be found.";
  function setTexts() {
    list.querySelectorAll(".ev").forEach(function (li) {
      var e = byId[li.dataset.id], p = li.querySelector(".ev-t");
      p.textContent = e.kind === "now" ? nowText : txt(e);
      p.setAttribute("lang", st.lang === "vi" && e.kind !== "now" ? "vi" : "en");
    });
    document.getElementById("f-lang").setAttribute("aria-pressed", st.lang === "vi" ? "true" : "false");
    renderAnnals();
  }
  function headOf(k) { for (var key in P) { var p = P[key]; if (p.alive && p.sect === k && p.rank === "tong_chu") return key; } return null; }

  // ---------- filters and following
  function passes(e) {
    if (e.kind === "now") return true;
    if (st.g !== "all" && grp(e) !== st.g) return false;
    if (st.follow) {
      if (st.follow.t === "p" && e.people.indexOf(st.follow.k) < 0) return false;
      if (st.follow.t === "i" && e.item !== st.follow.k) return false;
    }
    return true;
  }
  function applyFilter() {
    var shown = {};
    list.querySelectorAll(".ev").forEach(function (li) {
      var e = byId[li.dataset.id], ok = passes(e);
      li.hidden = !ok;
      if (ok && e.kind !== "now") shown[li.dataset.chap] = 1;
    });
    list.querySelectorAll(".era-chap[data-chap]").forEach(function (c) { c.hidden = !shown[c.dataset.chap]; });
    document.getElementById("cempty").hidden = Object.keys(shown).length > 0;
    document.querySelectorAll(".fchip[data-g]").forEach(function (b) { b.setAttribute("aria-pressed", b.dataset.g === st.g ? "true" : "false"); });
    var f = document.getElementById("follow");
    if (st.follow) {
      var n = EV.filter(passes).length, name = st.follow.t === "p" ? P[st.follow.k].name : ITEMS[st.follow.k].name_hv;
      f.innerHTML = '<span class="follow">Following ' + esc(name) + " · " + n + (n === 1 ? " event" : " events") +
        '<button type="button" id="unfollow" aria-label="Stop following">×</button></span>';
      f.hidden = false;
    } else { f.hidden = true; f.innerHTML = ""; }
    st.active = null;
    pick();
  }
  document.querySelectorAll(".fchip[data-g]").forEach(function (b) { b.addEventListener("click", function () { st.g = b.dataset.g; applyFilter(); }); });
  document.getElementById("f-lang").addEventListener("click", function () {
    st.lang = st.lang === "vi" ? "en" : "vi";
    try { localStorage.setItem("c11-lang", st.lang); } catch (e) { /* storage unavailable */ }
    setTexts();
  });

  // ---------- chronicle map
  var svg = document.getElementById("cmap"), strip = document.getElementById("cstrip"), unitsEl = document.getElementById("units");
  var miasma = document.getElementById("miasma");
  makeUnits(unitsEl);
  function star(x, y, r, fill) {
    var pts = [];
    for (var i = 0; i < 10; i++) { var a = -Math.PI / 2 + i * Math.PI / 5, rr = i % 2 ? r * 0.45 : r; pts.push((x + rr * Math.cos(a)).toFixed(1) + "," + (y + rr * Math.sin(a)).toFixed(1)); }
    return '<polygon points="' + pts.join(" ") + '" fill="' + fill + '" stroke="#0b0f12" stroke-width="2.5"/>';
  }
  function label(x, y, text, fill, size) {
    var left = x > 1330, ty = y < 40 ? y + 30 : y + 8;
    return '<text class="lbl" x="' + (left ? x - 20 : x + 20) + '" y="' + ty + '" text-anchor="' + (left ? "end" : "start") + '" fill="' + fill + '"' +
      (size ? ' style="font-size:' + size + 'px"' : "") + ">" + esc(text) + "</text>";
  }
  function diamond(x, y, r, fill, title) { return '<rect x="' + (x - r) + '" y="' + (y - r) + '" width="' + 2 * r + '" height="' + 2 * r + '" transform="rotate(45 ' + x + " " + y + ')" fill="' + fill + '" stroke="#0b0f12" stroke-width="2">' + (title ? "<title>" + esc(title) + "</title>" : "") + "</rect>"; }
  function renderMap(e) {
    var y = e.year, h = [];
    var flash = (e.kind === "sect_founded" || e.kind === "claim" || e.kind === "gift" || e.kind === "oath" || e.kind === "war_end" || e.kind === "sect_fall") ? e.sects : null;
    var holders = paintUnits(unitsEl, y);
    miasma.classList.toggle("on", y >= D.miasma_year);
    // cities and ruins
    D.cities.forEach(function (c) { if (c.from <= y) h.push('<rect x="' + (c.p[0] - 5) + '" y="' + (c.p[1] - 5) + '" width="10" height="10" fill="#e9e3ff" stroke="#0b0f12" stroke-width="2"><title>' + esc(c.name) + " (" + c.from + ")</title></rect>"); });
    D.ruins.forEach(function (r) {
      if (y < r.lived[0]) return;
      if (y < r.lived[1]) {
        var s = S[r.key];
        if (r.former === "sect" && s) h.push(diamond(r.p[0], r.p[1], 7, rgb(s.col), r.name));
        else h.push('<rect x="' + (r.p[0] - 5) + '" y="' + (r.p[1] - 5) + '" width="10" height="10" fill="#e9e3ff" stroke="#0b0f12" stroke-width="2"><title>' + esc(r.name) + "</title></rect>");
      } else {
        h.push('<g><path d="M' + (r.p[0] - 6) + " " + (r.p[1] - 6) + "L" + (r.p[0] + 6) + " " + (r.p[1] + 6) + "M" + (r.p[0] + 6) + " " + (r.p[1] - 6) + "L" + (r.p[0] - 6) + " " + (r.p[1] + 6) + '" stroke="#0b0f12" stroke-width="6"/><path d="M' + (r.p[0] - 6) + " " + (r.p[1] - 6) + "L" + (r.p[0] + 6) + " " + (r.p[1] + 6) + "M" + (r.p[0] + 6) + " " + (r.p[1] - 6) + "L" + (r.p[0] - 6) + " " + (r.p[1] + 6) + '" stroke="#d8d2c6" stroke-width="3"/><title>' + esc(r.name) + " (ruin since " + r.lived[1] + ")</title></g>");
      }
    });
    Object.keys(S).forEach(function (k) {
      var s = S[k];
      if (s.minor && s.seat && s.founded <= y) h.push(diamond(s.seat[0], s.seat[1], 5, rgb(s.col), s.name + " (" + s.founded + ")"));
    });
    GREATS.forEach(function (k) {
      var s = S[k];
      if (s.founded <= y && s.seat) { h.push(star(s.seat[0], s.seat[1], 15, rgb(s.col))); if (e.kind !== "now") h.push(label(s.seat[0], s.seat[1], s.name, "#eef3ef", 21)); }
    });
    ALL.forEach(function (o) {
      if (o.i >= e.i || o.kind === "now" || !passes(o)) return;
      var c = MCOL[grp(o)], t = "<title>" + o.year + " · " + esc(klabel(o)) + " · " + esc(atLabel(o)) + "</title>";
      if (o.slot) SL[o.slot].c.forEach(function (cc) { h.push('<circle class="mk" data-goto="' + o.id + '" cx="' + cc.p[0] + '" cy="' + cc.p[1] + '" r="5" fill="#0b0f12" fill-opacity=".35" stroke="' + c + '" stroke-width="2.5">' + t + "</circle>"); });
      else if (o.p) h.push('<circle class="mk" data-goto="' + o.id + '" cx="' + o.p[0] + '" cy="' + o.p[1] + '" r="6" fill="' + c + '" stroke="#0b0f12" stroke-width="2.5">' + t + "</circle>");
    });
    var where = "";
    if (e.kind === "now") {
      var homes = {};
      Object.keys(P).forEach(function (k) { var p = P[k]; if (p.alive && p.home_p) { var key = p.home_p.join(","); (homes[key] = homes[key] || []).push(k); } });
      Object.keys(homes).forEach(function (key) {
        var xy = key.split(",").map(Number), ks = homes[key];
        h.push('<circle cx="' + xy[0] + '" cy="' + xy[1] + '" r="' + (6 + Math.min(ks.length, 5)) + '" fill="#fff3d0" stroke="#0b0f12" stroke-width="2.5"><title>' + esc(ks.map(function (k) { return P[k].name; }).join(", ")) + "</title></circle>");
      });
      ["mac_quy_khu", "thoi_khinh_hong", "tu_khong_hac_nien", "trieu_huyet_y"].forEach(function (k) { var p = P[k]; h.push(label(p.home_p[0], p.home_p[1] + 26, p.name, "#fff3d0", 22)); });
      where = "<b>Year 1,200.</b> Light dots are the homes of the 51 living people. Hover a dot for names.";
    } else if (e.slot) {
      var cs = SL[e.slot].c, pts = cs.map(function (c) { return c.p.join(","); });
      if (cs.length > 1) h.push('<polyline points="' + pts.concat(cs.length > 2 ? [pts[0]] : []).join(" ") + '" fill="none" stroke="#ffd36b" stroke-width="2" stroke-dasharray="7 6" opacity=".8"/>');
      cs.forEach(function (c) {
        h.push('<circle class="pulse" cx="' + c.p[0] + '" cy="' + c.p[1] + '" r="15" fill="none" stroke="#ffd36b" stroke-width="3"/>');
        h.push('<circle cx="' + c.p[0] + '" cy="' + c.p[1] + '" r="11" fill="#0b0f12" fill-opacity=".45" stroke="#ffd36b" stroke-width="3" stroke-dasharray="5 4"/>');
      });
      var top = cs.slice().sort(function (a, b) { return a.p[1] - b.p[1]; })[0];
      h.push(label(top.p[0], top.p[1] - 26, e.slot + ": one of " + cs.length + " spots", "#ffe9a8"));
      where = "<b>" + esc(atLabel(e)) + ".</b> Each game puts it at one of these " + cs.length + " spots, in " + esc(orList(regionsOf(e.slot))) + ".";
    } else if (e.p) {
      h.push('<circle class="pulse" cx="' + e.p[0] + '" cy="' + e.p[1] + '" r="18" fill="none" stroke="#ffd36b" stroke-width="4"/>');
      h.push('<circle cx="' + e.p[0] + '" cy="' + e.p[1] + '" r="9" fill="#ffd36b" stroke="#0b0f12" stroke-width="3"/>');
      h.push(label(e.p[0], e.p[1] - 26, e.place || e.site || e.region, "#ffe9a8"));
      where = "<b>" + esc(atLabel(e)) + "</b>" + (e.place || e.site ? ". A fixed place, the same in every game." : ". The region as a whole.");
    }
    svg.innerHTML = h.join("");
    document.getElementById("cyear").textContent = num(y);
    document.getElementById("cera").textContent = e.kind === "now" ? "Thiên Nguyên · the start" : D.eras[eraOf(y)].name_hv + " · year";
    document.getElementById("cwhere").innerHTML = where;
    var cnt = {}; Object.keys(holders).forEach(function (u) { var k = holders[u]; if (k) cnt[k] = (cnt[k] || 0) + U[u].tiles; });
    document.getElementById("cheld").innerHTML = Object.keys(cnt).sort(function (a, b) { return cnt[b] - cnt[a]; }).map(function (k) {
      return '<span><i style="background:' + rgb(S[k].col) + (S[k].vanished ? ";opacity:.7" : "") + '"></i>' + esc(S[k].name) + "</span>";
    }).join("");
    renderStrip(e);
  }
  function sx(y) { return 20 + y / 1200 * 960; }
  function renderStrip(e) {
    var h = [];
    D.eras.forEach(function (E, i) {
      var x0 = sx(E.from), x1 = sx(Math.min(E.to + 1, 1200));
      h.push('<rect x="' + x0 + '" y="0" width="' + (x1 - x0) + '" height="15" fill="' + (i % 2 ? "#2a3530" : "#1f2924") + '"/>');
      if (x1 - x0 > 60) h.push('<text x="' + ((x0 + x1) / 2) + '" y="11.5" text-anchor="middle" fill="#cdd8d1" style="font:600 11px var(--f-body)">' + esc(E.name_hv) + "</text>");
    });
    h.push('<line x1="20" y1="44" x2="980" y2="44" stroke="#a3b2aa" stroke-width="1"/>');
    [0, 300, 600, 900, 1200].forEach(function (y) {
      h.push('<line x1="' + sx(y) + '" y1="44" x2="' + sx(y) + '" y2="48" stroke="#a3b2aa"/><text x="' + sx(y) + '" y="62" text-anchor="middle" fill="#a3b2aa" style="font:14px var(--f-data)">' + num(y) + "</text>");
    });
    ALL.forEach(function (o) {
      if (o.kind === "now") return;
      var on = o.id === e.id, ok = passes(o);
      h.push('<line class="mk" data-goto="' + o.id + '" x1="' + sx(o.year) + '" y1="' + (on ? 18 : 26) + '" x2="' + sx(o.year) + '" y2="43" stroke="' + MCOL[grp(o)] + '" stroke-width="' + (on ? 4 : 2.5) + '" opacity="' + (ok ? 0.95 : 0.2) + '"><title>' + o.year + " · " + esc(klabel(o)) + "</title></line>");
    });
    var x = sx(e.year);
    h.push('<polygon points="' + (x - 6) + ",16 " + (x + 6) + ",16 " + x + ',23" fill="#ffd36b"/>');
    strip.innerHTML = h.join("");
  }

  // ---------- scroll sync
  var mapEl = document.querySelector(".chron-map");
  function narrow() { return window.matchMedia("(max-width: 900px)").matches; }
  function refY() { return narrow() ? mapEl.getBoundingClientRect().bottom + 70 : window.innerHeight * 0.42; }
  function setActive(id) {
    if (st.active === id) return;
    st.active = id;
    list.querySelectorAll(".ev.on").forEach(function (li) { li.classList.remove("on"); });
    var li = list.querySelector('.ev[data-id="' + id + '"]'); if (li) li.classList.add("on");
    renderMap(byId[id]);
  }
  function pick() {
    var r = refY(), best = null, first = null;
    list.querySelectorAll(".ev").forEach(function (li) { if (li.hidden) return; if (!first) first = li; if (li.getBoundingClientRect().top <= r) best = li; });
    var li = best || first; if (li) setActive(li.dataset.id);
  }
  var ticking = false;
  window.addEventListener("scroll", function () { if (!ticking) { ticking = true; requestAnimationFrame(function () { ticking = false; pick(); }); } }, { passive: true });
  window.addEventListener("resize", pick);
  function scrollToCard(id) {
    var li = list.querySelector('.ev[data-id="' + id + '"]'); if (!li) return;
    var off = narrow() ? mapEl.getBoundingClientRect().height + 70 : window.innerHeight * 0.3;
    var reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    window.scrollTo({ top: li.getBoundingClientRect().top + window.scrollY - off, behavior: reduce ? "auto" : "smooth" });
    setActive(id);
  }
  function goTo(id) { var e = byId[id]; if (e && !passes(e)) { st.g = "all"; st.follow = null; applyFilter(); } scrollToCard(id); }
  function follow(t, k) {
    st.follow = { t: t, k: k }; st.g = "all"; applyFilter();
    var first = EV.filter(passes)[0];
    if (first) scrollToCard(first.id); else document.getElementById("chronicle").scrollIntoView();
  }
  list.addEventListener("click", function (ev) {
    if (ev.target.closest("[data-follow],[data-fitem]")) return;
    var li = ev.target.closest(".ev"); if (li) scrollToCard(li.dataset.id);
  });
  list.addEventListener("keydown", function (ev) { var li = ev.target.closest(".ev"); if (li && ev.target === li && (ev.key === "Enter" || ev.key === " ")) { ev.preventDefault(); scrollToCard(li.dataset.id); } });
  document.addEventListener("click", function (ev) {
    var f = ev.target.closest("[data-follow]"); if (f) { follow("p", f.dataset.follow); return; }
    var fi = ev.target.closest("[data-fitem]"); if (fi) { follow("i", fi.dataset.fitem); return; }
    var g = ev.target.closest("[data-goto]"); if (g) { goTo(g.getAttribute("data-goto")); return; }
    var r = ev.target.closest("[data-region]"); if (r) { st.region = +r.getAttribute("data-region"); renderAnnals(); return; }
    var it = ev.target.closest("[data-i]"); if (it) { st.itemf = it.dataset.i; buildItems(); return; }
    if (ev.target.closest("#unfollow")) { st.follow = null; applyFilter(); }
  });
  document.addEventListener("keydown", function (ev) {
    var r = ev.target.closest && ev.target.closest(".lrow");
    if (r && (ev.key === "Enter" || ev.key === " ")) { ev.preventDefault(); follow("p", r.getAttribute("data-follow")); }
  });

  // ---------- lifelines
  function buildLifelines() {
    var keys = [];
    EV.forEach(function (e) { e.people.forEach(function (k) { if (P[k] && keys.indexOf(k) < 0) keys.push(k); }); });
    keys.sort(function (a, b) { return P[a].born - P[b].born; });
    var x = function (y) { return 200 + (y + 300) / 1500 * 780; }, top = 30, rh = 22, H = top + keys.length * rh + 8, h = [];
    [-300, 0, 300, 600, 900, 1200].forEach(function (y) {
      h.push('<line x1="' + x(y) + '" y1="' + (top - 6) + '" x2="' + x(y) + '" y2="' + (H - 4) + '" style="stroke:var(--line)" stroke-width="1"/><text x="' + x(y) + '" y="16" text-anchor="middle" style="fill:var(--muted);font:11px var(--f-data)">' + (y < 0 ? "−" + num(-y) : num(y)) + "</text>");
    });
    keys.forEach(function (k, i) {
      var p = P[k], y = top + i * rh, s = S[p.sect], col = s && s.col ? rgb(s.col) : "var(--muted)";
      var end = p.alive ? 1200 : p.died, mine = EV.filter(function (e) { return e.people.indexOf(k) >= 0; });
      var g = ['<g class="lrow" tabindex="0" role="button" data-follow="' + k + '" aria-label="Follow ' + esc(p.name) + '">',
        '<rect class="lbg" x="0" y="' + (y - 2) + '" width="1000" height="' + rh + '" fill="transparent"/>',
        '<text x="190" y="' + (y + 13) + '" text-anchor="end" style="fill:' + (p.record ? "var(--muted)" : "var(--fg)") + ';font:500 12.5px var(--f-body)">' + esc(p.name) + "</text>",
        '<rect x="' + x(p.born) + '" y="' + (y + 5) + '" width="' + Math.max(2, x(end) - x(p.born)) + '" height="8" rx="4" style="fill:' + col + '"' + (p.alive ? "" : ' opacity=".55"') + "/>"];
      if (p.alive) g.push('<circle cx="' + x(1200) + '" cy="' + (y + 9) + '" r="5" style="fill:' + col + ';stroke:var(--panel)" stroke-width="2"/>');
      mine.forEach(function (e) { g.push('<circle cx="' + x(e.year) + '" cy="' + (y + 9) + '" r="4" style="fill:var(--panel);stroke:var(--fg)" stroke-width="1.5"><title>' + e.year + " · " + esc(klabel(e)) + "</title></circle>"); });
      g.push("<title>" + esc(p.name) + ", " + (p.alive ? "born " + p.born + ", alive" : p.born + "–" + p.died) + "</title></g>");
      h.push(g.join(""));
    });
    var el = document.getElementById("lifelines"); el.setAttribute("viewBox", "0 0 1000 " + H); el.innerHTML = h.join("");
  }

  // ---------- living cast
  function buildCast() {
    var alive = Object.keys(P).filter(function (k) { return P[k].alive; });
    var groups = [
      ["Hóa Thần, the two at the top", function (p) { return p.realm === "hoa_than"; }],
      ["Heads of the great sects", function (p) { return p.rank === "tong_chu" && GREATS.indexOf(p.sect) >= 0; }],
      ["First elders", function (p) { return p.rank === "truong_lao"; }],
      ["Heirs and disciples", function (p) { return p.rank === "noi_mon"; }],
      ["Heads of the vassal sects", function (p) { return p.rank === "tong_chu" && GREATS.indexOf(p.sect) < 0 && p.realm !== "hoa_than"; }],
      ["Bound to no sect", function (p) { return !p.sect && p.realm !== "hoa_than"; }]
    ];
    var used = {}, h = [], fate = [];
    groups.forEach(function (gr) {
      var ks = alive.filter(function (k) { return !used[k] && gr[1](P[k]); });
      ks.sort(function (a, b) { return GREATS.indexOf(P[a].sect) - GREATS.indexOf(P[b].sect) || P[a].born - P[b].born; });
      ks.forEach(function (k) { used[k] = 1; });
      if (!ks.length) return;
      h.push('<div class="cast-group"><h3>' + gr[0] + " · " + ks.length + '</h3><div class="cast-grid">');
      ks.forEach(function (k) {
        var p = P[k], s = S[p.sect], t = p.traits || {}, n = EV.filter(function (e) { return e.people.indexOf(k) >= 0; }).length;
        var na = AN.filter(function (e) { return e.people.indexOf(k) >= 0; }).length;
        (t.fate_given || []).forEach(function (f) { fate.push(p.name + ": " + f); });
        h.push('<article class="pc"><h4>' + (s ? '<span class="sw" style="background:' + rgb(s.col) + ';margin-right:0"></span>' : "") + esc(p.name) + "<small>" + esc(p.han) + "</small></h4>" +
          '<div class="meta">' + (REALM[p.realm] || p.realm) + " · age " + num(1200 - p.born) + " · " + (s ? esc(s.name) : "no sect") + "</div>" +
          '<p class="gl">' + esc(p.gloss) + "</p><p>" + esc(p.role) + "</p>" +
          '<div class="traits">' + (t.calling ? '<span class="call">' + esc(t.calling) + "</span>" : "") +
          (t.personality || []).map(function (x) { return "<span>" + esc(x) + "</span>"; }).join("") +
          (t.fate_given || []).map(function (x) { return '<span class="call">' + esc(x) + "</span>"; }).join("") + "</div>" +
          (n ? '<button type="button" class="pchip" data-follow="' + k + '">' + n + (n === 1 ? " landmark" : " landmarks") + (na ? ", " + na + (na === 1 ? " annal" : " annals") : "") + "</button>" : (na ? '<span class="meta">' + na + (na === 1 ? " annal" : " annals") + "</span>" : "")) + "</article>");
      });
      h.push("</div></div>");
    });
    document.getElementById("cast").innerHTML = '<div style="display:grid;gap:22px">' + h.join("") + "</div>";
    document.getElementById("fatecount").textContent = fate.join("; ") || "none";
  }

  // ---------- year 1,200 tables
  function lv(n, max) { return '<span class="lv"><i style="--w:' + (n / max * 100).toFixed(0) + '%"></i><span>' + n + "</span></span>"; }
  function al(a) { var x = ALIGN[a]; return '<span class="' + x[1] + '">' + x[0] + "</span>"; }
  function founder(k) { return EV.filter(function (e) { return e.kind === "sect_founded" && e.sects.indexOf(k) >= 0; })[0] || null; }
  function buildStart() {
    var h = ["<thead><tr><th>Great sect</th><th>Tier</th><th>Alignment</th><th>Head in 1,200</th><th>Founded</th><th>Holdings</th><th>Trade</th><th>Military</th><th>Institutions</th><th>Treasury</th></tr></thead><tbody>"];
    GREATS.forEach(function (k) {
      var s = S[k], hk = headOf(k), hd = P[hk], f = founder(k), L = s.levels, t = hd.traits || {};
      h.push('<tr><td class="name"><span class="sw" style="background:' + rgb(s.col) + '"></span>' + esc(s.name) + (k === "thien_xu" ? '<span class="sub">the Pivot</span>' : "") + "</td>" +
        '<td class="num">' + s.tier + "</td><td>" + al(s.align) + "</td>" +
        '<td><button type="button" class="pchip" data-follow="' + hk + '">' + esc(hd.name) + '</button><span class="sub">' + (REALM[hd.realm] || "") + " · " + esc(t.calling || "") + "</span></td>" +
        '<td class="num"><button type="button" class="gotobtn" data-goto="' + (f ? f.id : "") + '">year ' + s.founded + '</button><span class="sub">by ' + esc(f && f.people[0] ? P[f.people[0]].name : "") + "</span></td>" +
        "<td>" + lv(L.holdings, 12) + "</td><td>" + lv(L.trade, 12) + "</td><td>" + lv(L.military, 12) + "</td><td>" + lv(L.institutions, 12) + "</td>" +
        '<td class="num">' + num(s.treasury) + "</td></tr>");
    });
    document.getElementById("greatstart").innerHTML = h.join("") + "</tbody>";
    var WN = {}; D.wars.forEach(function (w) { WN[w.key] = w; });
    var g = ["<thead><tr><th>Pair</th><th>Grudge</th><th>From</th></tr></thead><tbody>"];
    D.grudges.forEach(function (gr) {
      g.push("<tr><td>" + sectChip(gr.pair[0]) + " " + sectChip(gr.pair[1]) + '</td><td class="num">' + gr.g + "</td><td>" +
        gr.from.map(function (w) { var W = WN[w]; var e = EV.filter(function (o) { return o.war === w; })[0]; return W ? (e ? '<button type="button" class="gotobtn" data-goto="' + e.id + '">' + esc(W.name) + " · " + W.years.join("–") + "</button>" : esc(W.name)) : w; }).join(" ") + "</td></tr>");
    });
    document.getElementById("grudgetable").innerHTML = g.join("") + "</tbody>";
    var m = ["<thead><tr><th>Vassal</th><th>Lord</th><th>Founded</th><th>Alignment</th><th>Head in 1,200</th><th>Loyalty</th></tr></thead><tbody>"];
    var minors = Object.keys(S).filter(function (k) { return S[k].minor; });
    minors.sort(function (a, b) { return GREATS.indexOf(S[a].lord) - GREATS.indexOf(S[b].lord) || S[a].founded - S[b].founded; });
    minors.forEach(function (k) {
      var s = S[k], hk = headOf(k), hd = P[hk];
      m.push('<tr><td class="name"><span class="sw dia" style="background:' + rgb(s.col) + '"></span>' + esc(s.name) + "</td><td>" + esc(S[s.lord].name) + "</td>" +
        '<td class="num">' + s.founded + "</td><td>" + al(s.align) + "</td>" +
        "<td>" + (hd ? '<button type="button" class="pchip" data-follow="' + hk + '">' + esc(hd.name) + '</button><span class="sub">' + (REALM[hd.realm] || "") + " · " + esc((hd.traits || {}).calling || "") + "</span>" : "") + "</td>" +
        '<td><span class="loy"><i class="' + (s.loyalty < 50 ? "low" : "") + '" style="--w:' + s.loyalty + '%"></i><span>' + s.loyalty + "</span></span></td></tr>");
    });
    document.getElementById("minorstart").innerHTML = m.join("") + "</tbody>";
  }

  // ---------- hidden slots
  function buildSlots() {
    var order = { R: 0, V: 1, A: 2, L: 3, S: 4 };
    var ids = Object.keys(SL).sort(function (a, b) { var x = a.split("-"), y = b.split("-"); return order[x[0]] - order[y[0]] || x[1] - y[1]; });
    var h = ["<thead><tr><th>Slot</th><th>What</th><th>Element</th><th>Year</th><th>How it came to be</th><th>Candidate spots</th><th></th></tr></thead><tbody>"];
    ids.forEach(function (id) {
      var s = SL[id], e = EV.filter(function (o) { return o.slot === id; })[0];
      h.push('<tr><td class="num">' + id + "</td><td>" + SLOTK[s.kind] + "</td><td>" + (SLOT_EL[id] || "—") + '</td><td class="num">' + (e ? e.year : "") + "</td>" +
        "<td>" + (e ? esc(e.text) : "") + "</td><td>" + s.c.length + ": " + esc(regionsOf(id).join(", ")) + "</td>" +
        "<td>" + (e ? '<button type="button" class="gotobtn" data-goto="' + e.id + '">See it</button>' : "") + "</td></tr>");
    });
    document.getElementById("slots").innerHTML = h.join("") + "</tbody>";
  }

  // ---------- annals
  var RN = {}; Object.keys(D.regions).forEach(function (n) { RN[D.regions[n].id] = n; });
  var aunits = document.getElementById("aunits"); makeUnits(aunits); paintUnits(aunits, 1200);
  var amap = document.getElementById("amap");
  function regionHistory(rid) {
    var u = String(rid), out = [], cur, from = 0;
    var ys = [0].concat(CH.filter(function (c) { return unitsOf(c.land).indexOf(u) >= 0; }).map(function (c) { return c.y; }));
    ys.forEach(function (y) {
      var h = holdersAt(y)[u] || null;
      if (out.length === 0 || h !== cur) { if (out.length) out[out.length - 1].to = y; out.push({ k: h, from: y }); cur = h; }
    });
    out[out.length - 1].to = 1200;
    return out;
  }
  function renderAnnals() {
    var rid = st.region, name = RN[rid], R = D.regions[name], h = [];
    Object.keys(D.regions).forEach(function (n) {
      var r = D.regions[n], on = r.id === rid;
      h.push('<text class="rlab' + (on ? " on" : "") + '" data-region="' + r.id + '" x="' + r.c[0] + '" y="' + r.c[1] + '" text-anchor="middle" fill="#eef3ef">' + esc(n) + "</text>");
    });
    amap.innerHTML = h.join("");
    var chips = Object.keys(D.regions).sort(function (a, b) { return D.regions[a].id - D.regions[b].id; }).map(function (n) {
      var r = D.regions[n];
      return '<button class="fchip" type="button" data-region="' + r.id + '" aria-pressed="' + (r.id === rid) + '">' + r.id + " " + esc(n) + "</button>";
    });
    document.getElementById("aregs").innerHTML = chips.join("");
    var hist = regionHistory(rid).map(function (seg) {
      var s = seg.k && S[seg.k];
      return "<span><i style=\"background:" + (s ? rgb(s.col) : "transparent;border:1px solid var(--muted)") + "\"></i>" + (s ? esc(s.name) : "wild") + " · " + num(seg.from) + "–" + (seg.to >= 1200 ? "" : num(seg.to)) + "</span>";
    }).join("");
    var rows = AN.filter(function (e) { return e.rid === rid; }).concat(EV.filter(function (e) { return e.rid === rid && !e.secret; }).map(function (e) { return Object.assign({ lm: true }, e); }));
    rows.sort(function (a, b) { return a.year - b.year || (a.lm ? -1 : 1); });
    var lis = rows.map(function (e) {
      return '<li class="' + (e.lm ? "lm" : "") + '"><span class="y">' + num(e.year) + '</span><div style="display:grid;gap:2px;min-width:0">' +
        (e.lm ? '<span class="lmtag">Landmark · ' + esc(klabel(e)) + ' · <button type="button" class="gotobtn" data-goto="' + e.id + '">' + e.id + "</button></span>" : '<span class="where">' + e.id + " · " + esc(klabel(e)) + (e.place ? " · " + esc(e.place) : "") + "</span>") +
        '<p class="t" lang="' + st.lang + '">' + esc(st.lang === "vi" ? e.text_vi : e.text) + "</p></div></li>";
    }).join("");
    var na = AN.filter(function (e) { return e.rid === rid; }).length, nl = rows.length - na;
    document.getElementById("apanel").innerHTML = '<div class="reg-head"><span class="meta">Region ' + rid + " · " + na + " annals · " + nl + " landmarks</span><h3>" + esc(name) + ' <small style="font:400 1rem var(--f-body);color:var(--muted)">' + esc(R.han) + "</small></h3>" +
      '<p class="lede" style="margin:0">' + esc(R.gloss) + '</p><div class="reg-hist">' + hist + "</div></div>" +
      '<ol class="alist">' + lis + "</ol>";
  }

  // ---------- items
  function placeLabel(it) {
    if (it.status === "held") { var p = P[it.holder]; return "Held by " + (p ? '<button type="button" class="pchip" data-follow="' + it.holder + '">' + esc(p.name) + "</button>" : esc(it.holder)); }
    if (it.place) return "Lost at <b>" + esc(it.place) + "</b>";
    if (it.famous_site) return "Lost inside <b>" + esc(it.famous_site) + "</b>";
    if (it.slot) return "Lost in hidden place <b>" + esc(it.slot) + "</b>, somewhere in " + esc(orList(regionsOf(it.slot)));
    return "";
  }
  function buildItems() {
    document.querySelectorAll(".fchip[data-i]").forEach(function (b) { b.setAttribute("aria-pressed", b.dataset.i === st.itemf ? "true" : "false"); });
    var h = D.items.filter(function (it) { return st.itemf === "all" || it.status === st.itemf; }).map(function (it) {
      var n = EV.filter(function (e) { return e.item === it.key; }).length, maker = it.made_by && S[it.made_by] ? S[it.made_by].name : null;
      return '<article class="it' + (it.status === "lost" ? " lost" : "") + '"><h4>' + esc(it.name_hv) + "<small>" + esc(it.name_han) + " · " + esc(it.gloss) + "</small></h4>" +
        '<div class="meta">' + esc(it.kind) + (it.element_guess ? " · " + esc(it.element_guess) : "") + (it.made_year != null ? " · made " + it.made_year : "") + (maker ? " by " + esc(maker) : "") + "</div>" +
        "<p>" + esc(it.story) + '</p><div class="st">' + placeLabel(it) + "</div>" +
        (it.pair && ITEMS[it.pair] ? '<div class="pair">Pair: ' + esc(ITEMS[it.pair].name_hv) + "</div>" : "") +
        (it.secret ? '<div class="pair">Secret: ' + esc(it.secret) + "</div>" : "") +
        (n ? '<button type="button" class="pchip" data-fitem="' + it.key + '" style="justify-self:start">' + n + (n === 1 ? " event" : " events") + " in the chronicle</button>" : "") + "</article>";
    });
    document.getElementById("igrid").innerHTML = h.join("");
  }

  buildList();
  buildLifelines();
  buildCast();
  buildStart();
  buildSlots();
  buildItems();
  applyFilter();
})();
