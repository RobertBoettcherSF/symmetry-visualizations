// Pages front door and the committed demo file.
// No Ada toolchain: checks that dist/index.html still embeds the real module,
// runs two Ada visualizations in that module, then opens the site root in
// Chrome and uses the existing menu.
// Run from the repo root: node tests/browser/pages-root-smoke.js
// Needs playwright-core and Chrome. Does not rewrite screenshots/.
"use strict";
const fs = require("fs");
const http = require("http");
const path = require("path");
const {chromium} = require("playwright-core");

const ROOT = path.resolve(__dirname, "../..");
const EXPORTS = ["sv_frame", "sv_width", "sv_height", "sv_set_param", "sv_start", "sv_tick", "memory"];
const CHROME = process.env.CHROME || "/usr/bin/google-chrome";

function fail(msg) {
  console.error("FAIL", msg);
  process.exit(1);
}

function read(rel) {
  return fs.readFileSync(path.join(ROOT, rel), "utf8");
}

function embeddedWasm(html) {
  const m = html.match(/const VERSION = "[^"]*", WASM = "([A-Za-z0-9+/=]+)"/);
  if (!m) fail("dist/index.html has no embedded WASM string");
  return Buffer.from(m[1], "base64");
}

function frameBytes(exp) {
  const w = exp.sv_width(), h = exp.sv_height();
  if (w < 50 || h < 50 || w > 1024 || h > 1024) fail("frame size " + w + "x" + h);
  return {w, h, bytes: Buffer.from(new Uint8Array(exp.memory.buffer, exp.sv_frame(), w * h * 4))};
}

function runViz(exp, index, params) {
  params.forEach((v, j) => exp.sv_set_param(j + 1, v));
  exp.sv_start(index, 42);
  for (let i = 0; i < 8; i++) exp.sv_tick();
  for (let i = 0; i < 12; i++) exp.sv_tick();
  const before = frameBytes(exp);
  let bright = 0;
  for (let i = 0; i < before.bytes.length; i += 4) {
    if (before.bytes[i] !== 16 || before.bytes[i + 1] !== 16 || before.bytes[i + 2] !== 16) bright++;
  }
  for (let i = 0; i < 24; i++) exp.sv_tick();
  const after = frameBytes(exp);
  let moved = 0;
  const n = Math.min(before.bytes.length, after.bytes.length);
  for (let i = 0; i < n; i += 4) if (before.bytes[i] !== after.bytes[i] || before.bytes[i + 1] !== after.bytes[i + 1]) moved++;
  if (bright < 20) fail("visualization " + index + " drew " + bright + " inked pixels");
  if (moved < 20) fail("visualization " + index + " changed " + moved + " pixels");
  return {bright, moved, w: after.w, h: after.h};
}

function checkFiles() {
  const door = read("index.html");
  if (!fs.existsSync(path.join(ROOT, ".nojekyll"))) fail("missing .nojekyll");
  if ((door.match(/<a href="dist\/index.html">/g) || []).length !== 1) fail("root page should have one link");
  if (!door.includes('location.replace("dist/index.html")')) fail("root page does not open dist/index.html");
  if (!door.includes('content="0; url=dist/index.html"')) fail("root page has no refresh to the demo");
  const html = read("dist/index.html");
  const template = read("web/template.html");
  if (!template.includes("__WASM_BASE64__")) fail("web/template.html lost the build placeholder");
  if (html.includes("__WASM_BASE64__")) fail("dist/index.html was not built");
  if (/<script\b[^>]*\bsrc=/.test(html)) fail("dist/index.html loads an external script");
  if (/\bfetch\s*\(/.test(html)) fail("dist/index.html fetches from the network");
  if (!html.includes("WebAssembly.instantiate")) fail("demo does not instantiate WebAssembly");
  const names = [...html.matchAll(/name: "([^"]+)"/g)].map(m => m[1]);
  if (names.length !== 16) fail("expected 16 visualizations, found " + names.length);
  const bytes = embeddedWasm(html);
  if (bytes.length < 1000 || bytes[0] !== 0x00 || bytes[1] !== 0x61 || bytes[2] !== 0x73 || bytes[3] !== 0x6d) {
    fail("embedded bytes are not a Wasm module (" + bytes.length + ")");
  }
  const exp = new WebAssembly.Instance(new WebAssembly.Module(bytes)).exports;
  for (const name of EXPORTS) if (exp[name] === undefined) fail("module missing " + name);
  const rule = runViz(exp, 0, [30, 401, 300, 0, 2, 45]);
  const life = runViz(exp, 1, [160, 100, 30, 1, 4, 120]);
  console.log("wasm", bytes.length, "bytes; Rule 30", rule.w + "x" + rule.h, "bright", rule.bright, "moved", rule.moved);
  console.log("Game of Life", life.w + "x" + life.h, "bright", life.bright, "moved", life.moved);
}

function serve() {
  return new Promise(resolve => {
    const server = http.createServer((req, res) => {
      const url = new URL(req.url, "http://127.0.0.1");
      let rel = decodeURIComponent(url.pathname);
      if (rel.endsWith("/")) rel += "index.html";
      const file = path.resolve(ROOT, "." + rel);
      if (file !== ROOT && !file.startsWith(ROOT + path.sep)) {
        res.writeHead(403); res.end(); return;
      }
      fs.readFile(file, (err, data) => {
        if (err) { res.writeHead(404); res.end("missing"); return; }
        const type = path.extname(file) === ".html" ? "text/html; charset=utf-8" : "application/octet-stream";
        res.writeHead(200, {"Content-Type": type, "Cache-Control": "no-store"});
        res.end(data);
      });
    });
    server.listen(0, "127.0.0.1", () => resolve(server));
  });
}

function changed(page) {
  return page.evaluate(() => {
    const c = document.getElementById("view");
    const d = c.getContext("2d").getImageData(0, 0, c.width, c.height).data;
    const o = window.__prev || d;
    let n = 0;
    for (let i = 0; i < d.length; i += 64) {
      if (Math.abs(d[i] + d[i + 1] + d[i + 2] - o[i] - o[i + 1] - o[i + 2]) > 30) n++;
    }
    window.__prev = d;
    return n;
  });
}

async function checkBrowser() {
  const server = await serve();
  const port = server.address().port;
  const base = "http://127.0.0.1:" + port + "/";
  const browser = await chromium.launch({
    executablePath: CHROME,
    args: ["--no-sandbox", "--disable-dev-shm-usage"]
  });
  const page = await browser.newPage({viewport: {width: 1100, height: 800}});
  const errors = [];
  page.on("pageerror", e => errors.push(String(e)));
  await page.goto(base);
  await page.waitForURL(/\/dist\/index\.html$/);
  await page.waitForFunction(() => /wasm loaded|Rule 30|Game of Life|Field|Lorenz|Crystal|Balance|Tree|Mandala|Sierpinski|Koch|Evolute/.test(document.getElementById("info").textContent));
  const auto = await page.$eval("#info", el => el.textContent);
  const exportsOk = await page.evaluate(() => typeof ada !== "undefined" && typeof ada.sv_tick === "function" && ada.memory && ada.memory.buffer.byteLength > 0);
  if (!exportsOk) fail("page did not keep the Ada module");
  await changed(page);
  await page.waitForTimeout(400);
  const moving = await changed(page);
  await page.selectOption("#menu", "1");
  await page.waitForFunction(() => document.getElementById("info").textContent.startsWith("Game of Life"));
  const life = await page.$eval("#info", el => el.textContent);
  await page.keyboard.press("Space");
  await page.waitForFunction(() => document.getElementById("info").textContent.startsWith("Star Mandala"));
  const mandala = await page.$eval("#info", el => el.textContent);
  const options = await page.$$eval("#menu option", os => os.map(o => o.textContent));
  if (options.length !== 17) fail("menu has " + options.length + " entries");
  const shot = process.env.SMOKE_SHOT || path.join(require("os").tmpdir(), "symmetry-pages-root.png");
  await page.screenshot({path: shot});
  console.log("browser", page.url());
  console.log("auto", auto);
  console.log("moving samples", moving);
  console.log("menu", life);
  console.log("space", mandala);
  console.log("shot", shot);
  if (errors.length) fail(errors.join(" | "));
  if (moving < 1) fail("canvas did not change after the module started");
  await browser.close();
  server.close();
}

(async () => {
  checkFiles();
  await checkBrowser();
  console.log("PASS");
})().catch(e => fail(e && e.stack || e));
