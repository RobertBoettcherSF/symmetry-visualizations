const {chromium} = require('playwright-core');
(async () => {
  const b = await chromium.launch({executablePath: '/usr/bin/google-chrome', headless: true});
  const p = await (await b.newContext({viewport: {width: 900, height: 650}})).newPage(); const errs = [];
  p.on('pageerror', e => errs.push(e.message));
  await p.goto('file:///workspace/symmetry-visualizations/dist/index.html'); await p.waitForTimeout(500);
  const names = [await p.textContent('#info')];
  for (let i = 0; i < 3; i++) { await p.keyboard.press('Space'); await p.waitForTimeout(200); names.push((await p.textContent('#info')).split(':')[0]); }
  console.log('cycle mode:', names.map(n => n.split(':')[0]).join(' -> '));
  await p.selectOption('#menu', '8'); await p.keyboard.press('Space'); await p.waitForTimeout(300);
  console.log('selected mode after Space: menu =', await p.$eval('#menu', m => m.options[m.selectedIndex].text), '|', await p.textContent('#info'));
  await p.click('#setBtn'); await p.focus('input[data-v="0"][data-p="0"]'); await p.keyboard.press('Space');
  console.log('space in input keeps:', await p.$eval('#menu', m => m.options[m.selectedIndex].text)); await p.click('#setBtn');
  // sample the balance canvas for 22 s; a jump shows as a big change between samples
  const diffs = await p.evaluate(async () => {
    const c = document.getElementById('view').getContext('2d'); let prev = null, out = [];
    for (let k = 0; k < 110; k++) {
      await new Promise(r => setTimeout(r, 200));
      const d = c.getImageData(0, 0, innerWidth, innerHeight).data; let n = 0;
      if (prev) for (let i = 0; i < d.length; i += 4) if (d[i] !== prev[i]) n++;
      prev = d; out.push(n);
    } return out; });
  console.log('changed px per 0.2s: max', Math.max(...diffs), 'median', diffs.slice().sort((a,b)=>a-b)[55]);
  await p.screenshot({path: '/workspace/symmetry-visualizations/screenshots/balance.png'});
  console.log('fps', await p.evaluate(() => fps), 'trap', await p.evaluate(() => fatal), 'errors', errs);
  await b.close();
})();
