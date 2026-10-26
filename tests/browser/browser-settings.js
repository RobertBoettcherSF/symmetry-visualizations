const {chromium} = require('playwright-core');
(async () => {
  const b = await chromium.launch({executablePath: '/usr/bin/google-chrome', headless: true});
  const p = await (await b.newContext({viewport: {width: 900, height: 650}})).newPage(); const errs = [];
  p.on('pageerror', e => errs.push(e.message));
  await p.goto('file:///workspace/symmetry-visualizations/dist/index.html'); await p.waitForTimeout(500);
  for (let i = 0; i < 2; i++) await p.keyboard.press('Space');
  await p.click('#setBtn');
  console.log('playing:', (await p.textContent('#info')).split(':')[0], '| visible legends:', await p.$$eval('#setPanel fieldset:not([hidden]) legend', l => l.map(x => x.textContent)));
  await p.fill('#setPanel fieldset:not([hidden]) input >> nth=0', '300'); await p.click('#apply'); await p.waitForTimeout(300);
  console.log('after apply: menu =', await p.$eval('#menu', m => m.options[m.selectedIndex].text), '|', await p.textContent('#info'));
  await p.selectOption('#menu', '9'); await p.waitForTimeout(2000);
  console.log('fps', await p.evaluate(() => fps), 'trap', await p.evaluate(() => fatal), 'errors', errs);
  await b.close();
})();
