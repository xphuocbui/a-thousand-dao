// PROTOTYPE - NOT FOR PRODUCTION
// Question: Does drafting/fusing fragments into a chain engine make players rework builds, and can a local LLM narrate it within engine budgets?
// Date: 2026-11-02
// Mock OpenAI-compatible endpoint that misbehaves on purpose. Tests plumbing + validation only.
// Run: node mock-llm.js [port]   (default 11434)
const http = require("http");
const port = Number(process.argv[2] || 11434);
let n = 0;
http.createServer((req, res) => {
  let body = "";
  req.on("data", (c) => (body += c));
  req.on("end", () => {
    n++;
    const reqJson = JSON.parse(body || "{}");
    const wantJson = !!reqJson.response_format;
    let content;
    if (wantJson) {
      const reward = n % 5 === 0 ? 999999 : 20 + n; // every 5th is out of budget
      const ev = JSON.stringify({ title: "Wounded Hermit " + n, text: "A hermit offers a trade.", npc_name: "Old Lu", reward_stones: reward });
      if (n % 4 === 0) content = "```json\n" + ev + "\n```"; // fenced
      else if (n % 7 === 0) content = "Sure! Here is your event: {title: oops"; // broken
      else content = ev;
    } else {
      content = "The Sect Elder staggers as your Dao roars for 77 damage" + (n % 2 === 0 ? ", and 9000 spirits wail" : "") + ".";
    }
    const delay = 300 + Math.floor(Math.random() * 500);
    setTimeout(() => {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ choices: [{ message: { role: "assistant", content } }] }));
    }, delay);
  });
}).listen(port, () => console.log("mock llm on " + port));
