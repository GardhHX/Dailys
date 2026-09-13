const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {pathToFileURL}=require('node:url'),{chromium}=require('playwright');
(async()=>{
  const canvas=process.argv[2],base=__dirname,browser=await chromium.launch({headless:true,channel:'msedge'}),page=await browser.newPage();
  let view=page;const errors=[],requests=[],checks=[],contrast=[],textChecks=[];
  page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});page.on('request',r=>{if(/^https?:/.test(r.url()))requests.push(r.url())});
  const open=async()=>{await page.goto(pathToFileURL(canvas||path.join(base,'preview/splash.html')).href);view=canvas?page.frames().find(f=>f.parentFrame()):page;await view.locator('#dspl-scenario').waitFor()};
  const state=changes=>view.evaluate(changes=>{const a=document.getElementById('dailys-splash').dailysPreview;Object.assign(a.design,changes);a.render()},changes);
  const overflow=()=>view.evaluate(()=>[...document.querySelectorAll('#dailys-splash *')].filter(el=>{const r=el.getBoundingClientRect();return r.width&&r.height&&(r.left< -1||r.right>innerWidth+1||el.clientWidth&&el.scrollWidth>el.clientWidth+2)}).map(el=>el.tagName+'#'+el.id+'.'+el.className));
  const scenarios=['opening','fresh','backup','verify','migration','timer','restore','locked','backupFailed','migrationFailed','integrityFailed','incompatible'];
  for(const width of canvas?[1024,736,392,352]:[1440,1024,860,680,392,352])for(const language of ['id','en'])for(const theme of ['terang','gelap']){
    await page.setViewportSize({width,height:900});await open();
    for(const scenario of scenarios){
      await state({scenario,language,theme});assert.deepEqual(await overflow(),[],`${width}/${language}/${theme}/${scenario}`);
      assert.equal(await view.locator('#dspl-product :is(header,nav)').count(),0);
      assert.equal(await view.locator('#dspl-product button').count(),['locked','backupFailed','migrationFailed'].includes(scenario)?2:['integrityFailed','incompatible'].includes(scenario)?1:0);
      checks.push({width,contentWidth:await view.evaluate(()=>innerWidth),language,theme,scenario});
    }
  }
  const ratio=async selector=>view.evaluate(selector=>{
    const el=document.querySelector(selector),s=getComputedStyle(el);let n=el,bg;while(n){bg=getComputedStyle(n).backgroundColor;if(bg!=='rgba(0, 0, 0, 0)')break;n=n.parentElement}
    const lum=c=>c.match(/[\d.]+/g).slice(0,3).map(Number).map(v=>{v/=255;return v<=.04045?v/12.92:((v+.055)/1.055)**2.4}).reduce((s,v,i)=>s+v*[.2126,.7152,.0722][i],0),a=lum(s.color),b=lum(bg);return{selector,foreground:s.color,background:bg,ratio:(Math.max(a,b)+.05)/(Math.min(a,b)+.05)};
  },selector);
  for(const theme of ['terang','gelap']){
    await state({theme,scenario:'opening'});contrast.push(await ratio('.dspl-status'));
    await state({scenario:'locked'});for(const s of ['.dspl-error h2','.dspl-error p','.dspl-primary'])contrast.push(await ratio(s));
    await view.locator('#dspl-guide').click();assert.equal(await view.locator('#dspl-guide').getAttribute('aria-expanded'),'true');
    assert.deepEqual(await overflow(),[],'guide');await view.locator('#dspl-close-guide').focus();await page.keyboard.press('Escape');
    assert.equal(await view.evaluate(()=>document.activeElement.id),'dspl-guide');assert.equal(await view.evaluate(()=>getComputedStyle(document.activeElement).outlineStyle),'solid');
    await view.locator('#dspl-guide').click();await view.locator('#dspl-close-guide').click();assert.equal(await view.locator('#dspl-guide-content').count(),0);
  }
  contrast.forEach(c=>assert(c.ratio>=4.5,JSON.stringify(c)));
  await view.locator('#dspl-theme').selectOption('gelap');assert.equal(await view.evaluate(()=>document.getElementById('dailys-splash').style.colorScheme),'dark');
  await view.locator('#dspl-language').selectOption('en');assert.equal(await view.locator('#dailys-splash').getAttribute('lang'),'en');
  for(const s of ['locked','backupFailed','migrationFailed']){
    await view.locator('#dspl-scenario').selectOption(s);await view.locator('#dspl-retry').press('Enter');
    assert.equal(await view.locator('#dspl-complete').isDisabled(),true);await view.waitForFunction(()=>document.getElementById('dailys-splash').dailysPreview.design.scenario==='opening');
  }
  for(const condition of ['kosong','memuat','gagal','terisi']){await state({condition});assert.deepEqual(await overflow(),[],'condition '+condition)}
  await state({scenario:'migration',measuredProgress:false});assert.equal(await view.locator('[role=progressbar]').count(),0);
  await state({measuredProgress:true});assert.equal(await view.locator('[role=progressbar]').getAttribute('aria-valuenow'),'60');
  for(const width of [1024,352])for(const theme of ['terang','gelap']){
    await page.setViewportSize({width,height:500});await open();await state({theme,scenario:'integrityFailed',language:'en'});await view.locator('#dspl-guide').click();
    await view.evaluate(()=>{const list=[...document.querySelectorAll('#dailys-splash,#dailys-splash *')],sizes=list.map(e=>parseFloat(getComputedStyle(e).fontSize));list.forEach((e,i)=>e.style.fontSize=sizes[i]*2+'px')});
    assert.deepEqual(await overflow(),[],`text 200% ${width} ${theme}`);textChecks.push({width,theme});
  }
  const destinations=[];
  for(const onboarded of [true,false]){
    await open();await state({onboarded});await view.locator('#dspl-complete').click();
    const target=onboarded?'home':'onboarding';if(canvas)assert((await view.locator('#dspl-demo-result').textContent()).includes(onboarded?'Home':'onboarding'));else await page.waitForURL('**/'+target+'.html');destinations.push(target);
  }
  for(const [width,theme,suffix] of [[1440,'terang','desktop'],[392,'terang','mobile'],[1024,'gelap','dark'],[1024,'terang','error']]){
    await page.setViewportSize({width,height:900});await open();await state({theme,scenario:suffix==='error'?'locked':'opening'});
    await view.locator('#dspl-product').screenshot({path:path.join(base,canvas||['dark','error'].includes(suffix)?'evidence':'mockups','splash-'+(canvas?'canvas-':'')+suffix+'.png')});
  }
  if(canvas){const allowed=['https://unpkg.com/@floating-ui/core@1.7.3/dist/floating-ui.core.umd.min.js','https://unpkg.com/@floating-ui/dom@1.7.4/dist/floating-ui.dom.umd.min.js','https://unpkg.com/lucide@1.17.0/dist/umd/lucide.js'];assert(requests.every(url=>allowed.includes(url)))}else assert.deepEqual(requests,[]);
  assert.deepEqual(errors,[]);fs.writeFileSync(path.join(base,'evidence',canvas?'qa-canvas-splash-results.json':'qa-splash-results.json'),JSON.stringify({status:'PASS',responsiveChecks:checks.length,checks,contrast,textChecks,destinations,actions:['12 scenarios','ID/EN/theme controls','guide click/close/Escape focus','3 retry Enter flows','4 conditions','optional labeled fixture progress','2 readiness routes'],pageErrors:errors,remoteRequests:[...new Set(requests)]},null,2)+'\n');
  await browser.close();console.log(`PASS ${canvas?'canvas':'offline'}: ${checks.length} responsive cases, 8 contrast pairs, 4 text cases, guide/retry/routing.`);
})().catch(e=>{console.error(e);process.exit(1)});
