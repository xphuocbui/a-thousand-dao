// Mock OpenAI-compatible chat-completions server for offline testing of the LLM path.
// It imitates a model: returns event JSON that references people from the request
// context, deliberately asks for over-budget numbers (so the engine's clamping is
// exercised), narrates with the facts' numbers (and sometimes invents one, so the
// narration number check is exercised), and voices NPCs in talk.
//
// Run:   node tools/llm-mock/mock_server.js [port]          (default 18080)
// Point: in the debug terminal:  llm url http://localhost:18080 mock-model
// It is NOT a language model; it tests plumbing, prompts and validation only.

const http = require("http");
const port = Number(process.argv[2] || 18080);
let n = 0;

function eventReply(userText) {
  let ctx = {};
  try { ctx = JSON.parse(userText); } catch (e) {}
  const here = (ctx.people_here || []).filter((p) => p && p.id);
  const npc = here.length > 0 && n % 2 === 0
    ? { existing_id: here[0].id }
    : { new: { name: "Mạc Vấn Thiên", archetype: "kiem_tu", realm_offset: 3 } }; // offset clamped to 1
  const place = (ctx.place && ctx.place.name) || "nơi này";
  return {
    title: "Kiếm khách bí ẩn",
    text: `Tại ${place}, một kiếm khách áo xám chặn đường, ánh mắt dò xét túi trữ vật của ngươi.`,
    npc,
    choices: [
      { label: "Rút kiếm nghênh chiến", check: { type: "combat" },
        success: { text: "Kiếm khách lùi lại, ném cho ngươi một túi linh thạch.", effects: [{ type: "linh_thach", amount: 999999 }, { type: "artifact", element: "kim", name: "Vấn Thiên Kiếm", grade: 9 }] },
        failure: { text: "Một kiếm lướt qua vai ngươi.", effects: [{ type: "khi_huyet_loss_pct", amount: 250 }] } },
      { label: "Hỏi chuyện (Mị lực)", check: { type: "stat", stat: "mi_luc", difficulty: 140 },
        success: { text: "Hắn kể về một động phủ cổ.", effects: [{ type: "relationship", npc: "event_npc", amount: 80 }, { type: "summon_dragon" }] },
        failure: { text: "Hắn cười khẩy bỏ đi.", effects: [] } },
      { label: "Nhường đường", check: { type: "none" }, always: [{ type: "linh_thach", amount: -5 }],
        success: { text: "Ngươi bình an rời đi.", effects: [{ type: "tam_ma", amount: 3 }] } },
    ],
  };
}

function narrationReply(userText) {
  const nums = userText.match(/\d+/g) || ["1"];
  const invent = n % 3 === 0 ? " Ba nghìn năm sau người ta vẫn kể lại." : "";
  return `Ngươi đứng vững giữa gió bụi; con số ${nums[nums.length - 1]} khắc sâu trong tâm trí.${invent}`;
}

http.createServer((req, res) => {
  let body = "";
  req.on("data", (c) => (body += c));
  req.on("end", () => {
    n++;
    let reqJson = {};
    try { reqJson = JSON.parse(body); } catch (e) {}
    const msgs = reqJson.messages || [];
    const system = (msgs[0] && msgs[0].content) || "";
    const user = (msgs[1] && msgs[1].content) || "";
    let content;
    if (system.includes("Invent ONE short event")) content = JSON.stringify(eventReply(user));
    else if (system.includes("You voice a character")) {
      let rec = {}; try { rec = JSON.parse(user); } catch (e) {}
      const hist = (rec.you && rec.you.history) || [];
      content = "```json\n" + JSON.stringify({ reply: `Ta là ${(rec.you && rec.you.name) || "kẻ vô danh"}. Đạo hữu tìm ta có việc gì?`, rumor_entity_id: hist.length ? "e1" : "p999999", attitude_change: 50 }) + "\n```";
    } else if (system.includes("Narrate the resolved outcome")) content = narrationReply(user);
    else if (system.includes("closing chronicle")) content = "Một đời tu tiên khép lại.";
    else content = JSON.stringify({ ok: true, greeting: "Chào đạo hữu" });
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ choices: [{ message: { role: "assistant", content } }] }));
  });
}).listen(port, () => console.log("mock llm on http://localhost:" + port));
