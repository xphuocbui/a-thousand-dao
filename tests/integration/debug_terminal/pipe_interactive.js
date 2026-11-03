// Integration check: the debug terminal answers each command as it is typed, line by
// line, over a pipe (the way a person types, or a harness/agent drives it) — not only
// when all input arrives at once. Also checks that an empty line (Enter) shows the menu
// instead of ending the session.
//
// Usage: node tests/integration/debug_terminal/pipe_interactive.js [godot_console_exe]
// Exit 0 on success, 1 on failure (with the reason).
const { spawn } = require("child_process");
const path = require("path");

const godot = process.argv[2] || process.env.GODOT_CONSOLE || "C:/Godot/Godot_v4.7.1-stable_win64_console.exe";
const root = path.resolve(__dirname, "../../..");
const g = spawn(godot, ["--headless", "--path", root, "-s", "res://src/debug_terminal/terminal_main.gd", "--", "--no-llm", "--achievements-file", ""],
  { stdio: ["pipe", "pipe", "pipe"] });
let out = "";
const strip = (s) => s.replace(/\x1b\[[0-9;]*m/g, "");
g.stdout.on("data", (d) => { out += d.toString(); });

const steps = [
  // [what to type, text that must appear in the new output before the next step]
  ["new quick Pipe 4242", "Generating the world (seed 4242)"],
  ["sheet", "THIÊN PHÚ"],
  ["", "Type a number, or any command"],
  ["goals", "What matters now"],
];
let i = 0;
let mark = 0;
const timer = setTimeout(() => fail("timed out at step " + i + " (" + JSON.stringify(steps[i] && steps[i][0]) + ")"), 60000);

function fail(msg) {
  console.error("PIPE INTERACTIVE: FAIL — " + msg);
  console.error(strip(out).slice(-1500));
  g.kill();
  process.exit(1);
}

function waitFor(text, then) {
  const poll = setInterval(() => {
    if (strip(out.slice(mark)).includes(text)) {
      clearInterval(poll);
      mark = out.length;
      then();
    }
  }, 50);
}

function next() {
  if (i >= steps.length) {
    g.stdin.write("quit\n");
    g.stdin.end();
    return;
  }
  const [line, expect] = steps[i];
  i++;
  g.stdin.write(line + "\n");
  waitFor(expect, next);
}

// Wait for the welcome menu before typing anything.
waitFor("Type a number, or any command", next);
g.on("exit", (code) => {
  clearTimeout(timer);
  if (i < steps.length) fail("exited early with code " + code);
  if (strip(out).includes("SCRIPT ERROR")) fail("script error in output");
  console.log("PIPE INTERACTIVE: OK (" + steps.length + " commands answered one at a time)");
  process.exit(0);
});
