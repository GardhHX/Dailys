const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {pathToFileURL}=require('node:url');
const {chromium}=require('playwright');

(async()=>{
  const canvas=process.argv[2],base=__dirname;
  const browser=await chromium.launch({headless:true,channel:'msedge'});
  const page=await browser.newPage(),errors=[],remote=[],checks=[],actions=[];
  page.on('pageerror',e=>errors.push(String(e)));
  page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});
  page.on('request',r=>{if(/^https?:/.test(r.url()))remote.push(r.url())});
  let view=page;
  const open=async()=>{
    await page.goto(pathToFileURL(canvas||path.join(base,'preview/settings.html')).href);
    view=canvas?page.frames().find(f=>f.parentFrame()):page;
    await view.locator('#dailys-settings h1').waitFor();
  };
  const evaluate=(fn,arg)=>view.evaluate(fn,arg);
  const api=method=>evaluate(method=>document.getElementById('dailys-settings').dailysPreview[method](),method);
  const state=async changes=>evaluate(changes=>{const a=document.getElementById('dailys-settings').dailysPreview;Object.assign(a.design,changes);a.render()},changes);
  const issues=()=>evaluate(()=>[...document.querySelectorAll('#dailys-settings *')].filter(el=>{
    const r=el.getBoundingClientRect(),s=getComputedStyle(el);
    if(!r.width||!r.height||s.visibility==='hidden'||el.closest('dialog:not([open])'))return false;
    return r.left< -1||r.right>innerWidth+1||(!['INPUT','TEXTAREA','OPTION','SELECT'].includes(el.tagName)&&el.clientWidth>0&&el.scrollWidth>el.clientWidth+2);
  }).map(el=>el.tagName+'#'+el.id+'.'+el.className).slice(0,12));
  const settled=async key=>view.waitForFunction(key=>document.getElementById('dailys-settings').dailysPreview.getStatuses()[key]?.kind!=='saving',key);
  const setField=async(key,value)=>{
    const field=view.locator('[data-setting="'+key+'"]');
    if(key==='notifications_enabled')await field.setChecked(value);
    else if(['language','alarm_mode'].includes(key))await field.selectOption(value);
    else if(key==='alarm_volume')await field.evaluate((el,value)=>{el.value=value;el.dispatchEvent(new Event('input',{bubbles:true}));el.dispatchEvent(new Event('change',{bubbles:true}))},String(value));
    else {await field.fill(String(value));await field.press('Enter')}
    await settled(key);
  };
  const widths=canvas?[1024,736,392,352]:[1440,1200,1024,860,736,680,392,352];
  for(const width of widths)for(const theme of ['terang','gelap']){
    await page.setViewportSize({width,height:1100});await open();
    for(const scenario of ['normal','save-failed','permission-denied','unregistered','registration-failed','recovery','empty']){
      await state({theme,scenario,condition:'terisi'});
      assert.equal(await view.locator('.dg-section').count(),8);
      assert.deepEqual(await issues(),[],`${width} ${theme} ${scenario}`);
      checks.push({width,contentWidth:await evaluate(()=>innerWidth),theme,scenario});
    }
    for(const condition of ['kosong','memuat','gagal']){
      await state({condition});assert.deepEqual(await issues(),[],`${width} ${theme} ${condition}`);
      checks.push({width,contentWidth:await evaluate(()=>innerWidth),theme,condition});
    }
  }
  await page.setViewportSize({width:1024,height:1100});await open();await state({theme:'terang'});
  const initial=await api('getSaved'),immutable=await api('getImmutableSamples');
  assert.equal(Object.keys(initial).length,9);
  await setField('language','en');assert.equal(await view.locator('#dg-appearance-title').textContent(),'Appearance & language');
  assert.equal(await view.locator('#dg-device-title').textContent(),'This device');
  assert.equal(await view.locator('#dg-about-title').textContent(),'About');
  assert.equal(await view.locator('#dailys-settings').getAttribute('lang'),'en');
  await setField('language','id');actions.push('ID/EN resource switch');
  for(const [key,min,max] of [['pomodoro_focus_minutes',1,180],['pomodoro_short_break_minutes',1,60],['pomodoro_long_break_minutes',1,120],['pomodoro_long_break_interval',2,12]]){
    for(const value of [min,max]){await setField(key,value);assert.equal((await api('getSaved'))[key],value)}
    for(const value of [min-1,max+1,2.5]){
      await setField(key,value);assert.equal((await api('getStatuses'))[key].kind,'invalid');
      assert.equal((await api('getSaved'))[key],max);assert.equal(await view.locator('#dg-'+key).getAttribute('aria-invalid'),'true');
    }
    await setField(key,min);
  }
  actions.push('4 Pomodoro fields: both bounds, outside bounds, fractional invalid');
  const queueBefore=(await api('getMutations')).length;
  await setField('alarm_volume',42);assert.equal((await api('getDevice')).alarm_volume,42);
  assert.equal((await api('getMutations')).length,queueBefore);
  assert(!Object.hasOwn(await api('getSaved'),'alarm_volume'));assert(!Object.hasOwn(await api('getSaved'),'theme'));
  const mutation=(await api('getMutations'))[0];assert.equal(Object.keys(mutation.patch).length,1);assert.equal(Object.keys(mutation.record).length,9);
  actions.push('partial preference patch/full record; volume device-only; no theme contract invented');
  await setField('alarm_mode','muted');let p=await api('getNotificationProjection');assert.equal(p.visual_enabled,true);assert.equal(p.sound_enabled,false);
  await setField('notifications_enabled',false);assert.equal((await api('getNotificationProjection')).future_trigger_count,0);
  await setField('notifications_enabled',true);assert.equal((await api('getNotificationProjection')).visual_enabled,true);
  await setField('weekly_review_time','10:30:00');assert.equal((await api('getSaved')).weekly_review_time,'10:30:00');
  actions.push('muted visual preserved; disabled cancels sample triggers; review local time saved');
  assert((await api('getZones')).length>300);
  await view.locator('#dg-timezone-open').click();
  assert.deepEqual(await issues(),[],'timezone picker');
  await view.locator('#dg-zone-search').fill('no-matching-zone-123');
  await view.locator('#dg-zoneform button[type=submit]').click();assert(await view.locator('#dg-zone-error').textContent());
  await view.locator('#dg-zone-search').fill('Tokyo');assert.equal(await view.locator('#dg-zone-list option').count(),1);
  await view.locator('#dg-zoneform button[type=submit]').click();await settled('timezone');
  assert.equal((await api('getSaved')).timezone,'Asia/Tokyo');
  assert((await view.locator('#dg-time .dg-effect').textContent()).includes('Menghitung ulang'));
  await view.waitForFunction(()=>document.querySelector('#dg-time .dg-effect').textContent.includes('Tanggal tersimpan'));
  assert.deepEqual(await api('getImmutableSamples'),immutable);
  await view.locator('#dg-timezone-open').click();await page.keyboard.press('Escape');
  assert.equal(await evaluate(()=>document.activeElement.id),'dg-timezone-open');actions.push('IANA search, empty invalid, timezone recompute; stored dates/session/review/offsets invariant; Escape focus');
  await state({scenario:'save-failed'});await setField('pomodoro_focus_minutes',50);
  assert.equal((await api('getSaved')).pomodoro_focus_minutes,25);assert.equal((await api('getValues')).pomodoro_focus_minutes,50);
  await view.locator('[data-retrysave="pomodoro_focus_minutes"]').click();await settled('pomodoro_focus_minutes');assert.equal((await api('getStatuses')).pomodoro_focus_minutes.kind,'failed');
  await state({condition:'gagal'});await view.locator('[data-retry]').click();assert.equal(await view.locator('#dg-pomodoro_focus_minutes').inputValue(),'50');
  actions.push('save failed/retry and read failed/retry retain input');
  await view.locator('#dg-timezone-open').click();await view.locator('#dg-zone-search').fill('London');
  await view.locator('#dg-zoneform button[type=submit]').click();await settled('timezone');
  assert.equal((await api('getSaved')).timezone,'Asia/Jakarta');assert.equal((await api('getValues')).timezone,'Europe/London');
  assert.equal(await view.locator('#dg-time .dg-value strong').textContent(),'Europe/London');
  await view.locator('#dg-timezone-open').click();assert.equal(await view.locator('#dg-zone-list').inputValue(),'Europe/London');await page.keyboard.press('Escape');
  actions.push('failed timezone retains and displays chosen zone; picker reopens that input');
  await state({scenario:'permission-denied'});assert.equal((await api('getSaved')).notifications_enabled,true);
  await view.locator('#dg-permission-guide').click();assert(await view.locator('dialog[open]').isVisible());await page.keyboard.press('Escape');
  assert.equal(await evaluate(()=>document.activeElement.id),'dg-permission-guide');
  await view.locator('[data-checkpermission]').click();assert.equal((await api('getDevice')).permission,'denied');assert.equal((await api('getSaved')).notifications_enabled,true);
  await state({permissionRead:'granted'});await view.locator('[data-checkpermission]').click();assert.equal((await api('getDevice')).permission,'granted');
  await state({platform:'android',scenario:'normal'});await state({scenario:'permission-denied'});await view.locator('#dg-permission-guide').click();assert((await view.locator('#dg-modal-title').textContent()).includes('Android'));await page.keyboard.press('Escape');
  actions.push('Windows/Android permission guide; recheck does not alter user preference');
  for(const scenario of ['unregistered','registration-failed']){
    await state({scenario});assert(await view.locator('[data-syncnow]').isDisabled());await view.locator('[data-register]').click();
    await view.waitForFunction(()=>!document.querySelector('[data-register]')||!document.querySelector('[data-register]').disabled);
    assert.equal((await api('getDevice')).registration,scenario==='unregistered'?'active':'failed');
  }
  await state({scenario:'recovery'});assert(await view.locator('[data-syncnow]').isDisabled());
  await state({scenario:'normal'});await view.locator('[data-syncnow]').click();await view.waitForFunction(()=>!document.querySelector('[data-syncnow]').disabled);
  assert.equal((await api('getSync')).pending,0);assert.equal((await api('getSync')).conflicts,2);
  await state({scenario:'empty'});await setField('pomodoro_focus_minutes',40);assert.equal((await api('getSync')).pending,1);assert.equal(await view.locator('.dg-syncstatus strong').textContent(),'Menunggu sync');
  actions.push('registration pending/failed; recovery blocks sync; sync keeps conflicts; new change exits empty queue');
  const contrast=[];
  const pickerCases=[];
  for(const width of [1024,352])for(const theme of ['terang','gelap']){
    await page.setViewportSize({width,height:1100});await open();
    await view.locator('[data-theme="'+theme+'"]').click();
    assert.equal(await view.locator('[data-theme="'+theme+'"]').getAttribute('aria-pressed'),'true');
    await view.locator('#dg-timezone-open').click();assert.deepEqual(await issues(),[],`picker ${width} ${theme}`);
    await page.keyboard.press('Tab');assert.equal(await evaluate(()=>getComputedStyle(document.activeElement).outlineStyle),'solid');
    await page.keyboard.press('Escape');assert.equal(await evaluate(()=>document.activeElement.id),'dg-timezone-open');
    pickerCases.push({width,theme});
  }
  for(const theme of ['terang','gelap']){
    await state({theme,scenario:'permission-denied'});
    for(const selector of ['.dg-muted','.dg-primary','.dg-danger','.dg-success','.dg-source','.dg-localnotice']){
      contrast.push(await evaluate(selector=>{
        const el=[...document.querySelectorAll('#dailys-settings '+selector)].find(e=>e.getBoundingClientRect().width),style=getComputedStyle(el);
        let node=el,bg;while(node){bg=getComputedStyle(node).backgroundColor;if(bg!=='rgba(0, 0, 0, 0)')break;node=node.parentElement}
        const rgb=s=>s.match(/[\d.]+/g).slice(0,3).map(Number),l=s=>rgb(s).map(v=>{v/=255;return v<=.04045?v/12.92:((v+.055)/1.055)**2.4}).reduce((sum,v,i)=>sum+v*[.2126,.7152,.0722][i],0);
        const a=l(style.color),b=l(bg);return{selector,foreground:style.color,background:bg,ratio:(Math.max(a,b)+.05)/(Math.min(a,b)+.05)};
      },selector));
    }
  }
  contrast.forEach(c=>assert(c.ratio>=4.5,JSON.stringify(c)));
  const textChecks=[];
  for(const width of [1024,352])for(const theme of ['terang','gelap']){
    await page.setViewportSize({width,height:1100});await open();await state({theme});
    await evaluate(()=>{const elements=[...document.querySelectorAll('#dailys-settings,#dailys-settings *')];const sizes=elements.map(el=>parseFloat(getComputedStyle(el).fontSize));elements.forEach((el,i)=>el.style.fontSize=sizes[i]*2+'px')});
    assert.deepEqual(await issues(),[],`text 200% ${width} ${theme}`);textChecks.push({width,theme});
  }
  if(!canvas){
    const manifest=JSON.parse(fs.readFileSync(path.join(base,'manifest.json'))),routes=[];
    for(const width of [1440,352]){
      await page.setViewportSize({width,height:1100});
      for(const s of manifest.screens.filter(s=>!['settings','onboarding'].includes(s.id))){
        await page.goto(pathToFileURL(path.join(base,'preview',s.id+'.html')).href);
        await page.locator('[data-global-settings]').click();await page.waitForURL('**/settings.html');routes.push({width,from:s.id,to:'settings'});
      }
      for(const target of ['home','weekly-review','pusat-sync']){
        await open();await page.locator('[data-route="'+target+'"]').click();await page.waitForURL('**/'+target+'.html');routes.push({width,from:'settings',to:target});
      }
      await page.goto(pathToFileURL(path.join(base,'preview/pomodoro.html')).href);await page.locator('[data-settings]').first().click();await page.waitForURL('**/settings.html#dg-pomodoro');assert.equal(await page.locator('#dg-pomodoro input').count(),4);
    }
    actions.push(`${routes.length} global routes and 2 Pomodoro shortcuts`);
  }
  for(const [width,theme,suffix] of [[1440,'terang','desktop'],[392,'terang','mobile'],[1024,'gelap','dark']]){
    await page.setViewportSize({width,height:1100});await open();await state({theme});
    await view.locator('#dailys-settings').screenshot({path:path.join(base,canvas||suffix==='dark'?'evidence':'mockups','settings-'+(canvas?'canvas-':'')+suffix+'.png')});
  }
  if(canvas){const allowed=['https://unpkg.com/@floating-ui/core@1.7.3/dist/floating-ui.core.umd.min.js','https://unpkg.com/@floating-ui/dom@1.7.4/dist/floating-ui.dom.umd.min.js','https://unpkg.com/lucide@1.17.0/dist/umd/lucide.js'];assert(remote.every(url=>allowed.includes(url)))}else assert.deepEqual(remote,[]);
  assert.deepEqual(errors,[]);
  fs.writeFileSync(path.join(base,'evidence',canvas?'qa-canvas-settings-results.json':'qa-settings-results.json'),JSON.stringify({status:'PASS',responsiveChecks:checks.length,checks,textMagnificationChecks:textChecks,pickerCases,contrast,actions,pageErrors:errors,remoteRequests:[...new Set(remote)]},null,2)+'\n');
  await browser.close();console.log('PASS '+(canvas?'canvas':'offline')+': '+checks.length+' responsive cases, 4 text magnification cases, '+contrast.length+' contrast pairs; settings and routes verified.');
})().catch(e=>{console.error(e);process.exit(1)});
