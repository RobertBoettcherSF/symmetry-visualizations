const {chromium} = require('playwright-core');
const R = require('path').resolve(__dirname, '../..'), URL = 'file://' + R + '/dist/index.html';
(async () => {
  const b = await chromium.launch({executablePath: '/usr/bin/google-chrome', headless: true});
  const p = await (await b.newContext({viewport: {width: 900, height: 650}})).newPage(); const errs = [];
  p.on('pageerror', e => errs.push(e.message)); p.on('console', m => m.type()==='error' && errs.push(m.text()));
  await p.goto(URL); await p.waitForTimeout(1000);
  console.log('menu:', await p.$$eval('#menu option', o => o.map(x => x.textContent).join(' | ')));
  for (let i = 3; i <= 7; i++) {
    await p.selectOption('#menu', String(i)); await p.waitForTimeout(2500);
    const a = await p.screenshot(); await p.waitForTimeout(1000);
    await p.screenshot({path: `${R}/screenshots/field-${i-2}.png`});
    const bb = await p.screenshot();
    console.log(await p.textContent('#info'), '| fps', await p.evaluate(() => fps), '| animates', !a.equals(bb), '| trap', await p.evaluate(() => fatal));
  }
  console.log('errors:', errs); await b.close();
})();
