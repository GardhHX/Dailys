const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {pathToFileURL} = require('node:url');
const {chromium} = require('playwright');

(async () => {
  const base = __dirname;
  const manifest = JSON.parse(fs.readFileSync(path.join(base,'manifest.json'),'utf8'));
  const browser = await chromium.launch({headless:true,channel:process.env.DESIGN_BROWSER_CHANNEL || 'msedge'});
  const page = await browser.newPage();
  const errors = [], remote = [], checks = [];
  page.on('pageerror', error => errors.push(String(error)));
  page.on('request', request => {if(/^https?:/i.test(request.url())) remote.push(request.url());});
  const open = file => page.goto(pathToFileURL(path.join(base,'preview',file)).href);
  const rootFor = id => id==='home'?'dailys-home':['tugas','pomodoro'].includes(id)?'dailys-work':'dailys-life';
  async function overflow() {
    return page.evaluate(() => [...document.querySelectorAll('body *')].filter(el => {
      const rect=el.getBoundingClientRect(),style=getComputedStyle(el);
      if(!rect.width||!rect.height||style.display==='none'||style.visibility==='hidden'||el.closest('dialog:not([open])')) return false;
      return rect.left < -1 || rect.right > innerWidth+1 || (el.clientWidth>0&&el.scrollWidth>el.clientWidth+2);
    }).map(el=>el.tagName+'#'+el.id+'.'+el.className).slice(0,12));
  }
  for (const screen of manifest.screens.filter(screen=>screen.kind!=='global')) {
    for (const width of [1440,860,680,352]) {
      for (const theme of ['terang','gelap']) {
        await page.setViewportSize({width,height:1100});
        await open(screen.id+'.html');
        const root=rootFor(screen.id);
        assert(await page.locator('#'+root).isVisible());
        await page.evaluate(({root,theme})=>{
          const api=document.getElementById(root).dailysPreview;
          if(api.design) api.design.theme=theme; else api.settings.appearance=theme;
          api.render();
        },{root,theme});
        assert.equal(await page.locator('[data-lucide]').count(),0,'Unresolved host icons');
        assert.equal(await page.locator('[data-reference-destination]:disabled').count(),0);
        const issues=await overflow();
        assert.deepEqual(issues,[],screen.id+' '+width+' '+theme+' overflow');
        checks.push({screen:screen.id,width,theme,overflow:issues});
        if(theme==='terang'&&[1440,352].includes(width)) await page.locator('#'+root).screenshot({path:path.join(base,'mockups',screen.id+'-'+(width===1440?'desktop':'mobile')+'.png')});
      }
    }
    await open(screen.id+'.html');
    for (const condition of ['kosong','memuat','gagal','terisi']) {
      await page.locator('#reference-condition').selectOption(condition);
      assert.equal(await page.evaluate(root=>{
        const api=document.getElementById(root).dailysPreview;return (api.design||api.settings).condition;
      },rootFor(screen.id)),condition);
      assert.deepEqual(await overflow(),[],screen.id+' state '+condition);
    }
    const trigger={home:'#dh-add',tugas:'[data-newtask]',pomodoro:'[data-settings]',keuangan:'[data-newtrans]',habit:'[data-newhabit]'}[screen.id];
    await page.locator(trigger).first().click();
    if(screen.id==='pomodoro'){
      await page.waitForURL('**/settings.html#dg-pomodoro');
      assert.equal(await page.locator('#dg-pomodoro input').count(),4);
      continue;
    }
    assert(await page.locator('dialog[open]').isVisible());
    assert.deepEqual(await overflow(),[],screen.id+' dialog mobile');
    await page.keyboard.press('Escape');
    assert.equal(await page.locator('dialog[open]').count(),0);
  }
  const routeChecks=[];
  for (const width of [1440,352]) {
    await page.setViewportSize({width,height:1100});
    await open('home.html');
    for (const destination of ['tugas','pomodoro','keuangan','habit','home']) {
      const locator=page.locator('[data-reference-destination="'+destination+'"]').filter({visible:true});
      await locator.click();
      await page.waitForURL('**/'+destination+'.html');
      assert(await page.locator('#'+rootFor(destination)).isVisible());
      if(destination!=='home') assert.equal(await page.locator('#'+rootFor(destination)+' h1').first().textContent(),manifest.screens.find(s=>s.id===destination).label);
      routeChecks.push({width,destination});
    }
  }
  for (const width of [1440,352]) {
    await page.setViewportSize({width,height:1100});
    await open('index.html');
    assert.equal(await page.locator('.gallery-grid article').count(),manifest.screens.length);
    assert.deepEqual(await overflow(),[],'gallery '+width);
    await page.locator('.gallery-grid img').evaluateAll(images=>{images.forEach(image=>image.loading='eager');return Promise.all(images.map(image=>image.decode()));});
    await page.screenshot({path:path.join(base,'evidence','package-gallery-'+(width===1440?'desktop':'mobile')+'.png'),fullPage:true});
  }
  assert.deepEqual(errors,[]);
  assert.deepEqual(remote,[]);
  fs.writeFileSync(path.join(base,'evidence','package-qa.json'),JSON.stringify({status:'PASS',responsiveChecks:checks.length,checks,conditionChecks:20,mobileDialogs:4,settingsShortcut:1,navigationChecks:routeChecks,galleryWidths:[1440,352],pageErrors:errors,remoteRequests:remote},null,2)+'\n');
  await browser.close();
  console.log('PASS: 40 layout/theme checks, 20 states, 4 mobile dialogs, Settings shortcut, 10 cross-screen routes, 2 gallery widths; no JS errors or remote requests.');
})().catch(error=>{console.error(error);process.exit(1);});
