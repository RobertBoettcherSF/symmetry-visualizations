// Headless check of dist/index.html: every visualization renders, moves and
// keeps its frame rate; Balance moves in every half second; F9 and crash log work.
// Run: node tests/browser-check.js   (needs playwright-core and Chrome)
const {chromium} = require('playwright-core');
const R = require('path').resolve(__dirname, '../..'), URL = 'file://' + R + '/dist/index.html';
const shots = ['rule30','game-of-life','star-mandala','field-1','field-2','field-3','field-4','field-5',
  'tree','balance','lorenz','sierpinski-triangle','koch','sierpinski-hexagon','evolute','crystal'];
// pixels that changed since the last call (sampled in the page, every 4th pixel)
const changed = p => p.evaluate(() => { const c = document.getElementById('view');
  const d = c.getContext('2d').getImageData(0, 0, c.width, c.height).data, o = window.prev || d; let n = 0;
  for (let i = 0; i < d.length; i += 16) if (Math.abs(d[i] + d[i+1] + d[i+2] - o[i] - o[i+1] - o[i+2]) > 30) n++;
  window.prev = d; return n; });
(async () => {
  const b = await chromium.launch({executablePath: '/usr/bin/google-chrome'});
  const c = await b.newContext({acceptDownloads: true, viewport: {width: 1000, height: 1000}});
  let p = await c.newPage(); const errs = [];
  p.on('pageerror', e => errs.push(e.message));
  await p.goto(URL); await p.waitForTimeout(1000);
  for (let v = 0; v < shots.length; v++) {
    await p.selectOption('#menu', String(v)); await p.waitForTimeout(3000);
    await changed(p); await p.waitForTimeout(500);
    console.log(shots[v].padEnd(20), 'fps', await p.evaluate(() => fps), 'changed', await changed(p));
    await p.screenshot({path: `${R}/screenshots/${shots[v]}.png`});
  }
  for (const speed of [1, 3, 6]) {            // Balance: 20 s, look at every half second
    await p.selectOption('#menu', '9'); await p.click('#setBtn');
    await p.fill('input[data-v="9"][data-p="1"]', String(speed)); await p.click('#apply'); await p.click('#setBtn');
    await changed(p); let still = 0, least = 1e9;
    for (let t = 0; t < 40; t++) { await p.waitForTimeout(500); const d = await changed(p); least = Math.min(least, d); if (d === 0) still++; }
    console.log(`balance speed ${speed}: still half-seconds ${still}, fewest changed ${least}`);
  }
  const [d] = await Promise.all([p.waitForEvent('download'), p.keyboard.press('F9')]);
  console.log('F9 ->', d.suggestedFilename());
  const s = await c.newCDPSession(p); s.send('Page.crash').catch(() => {});
  await new Promise(r => setTimeout(r, 1000));
  p = await c.newPage(); await p.goto(URL); await p.waitForTimeout(1500);
  console.log('crash notice visible:', await p.isVisible('#crash'));
  console.log('errors:', errs); await b.close();
})();
