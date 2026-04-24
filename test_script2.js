import puppeteer from 'puppeteer';
(async () => {
  const browser = await puppeteer.launch({args: ['--no-sandbox']});
  const page = await browser.newPage();
  await page.goto('https://rexuvia.com', {waitUntil: 'networkidle0'});
  const text = await page.evaluate(() => {
    const el = document.querySelector('.modelshow-section');
    return el ? el.innerText : 'Not found';
  });
  console.log('Text content:', text);
  await browser.close();
})();
