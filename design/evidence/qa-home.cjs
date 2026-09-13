const {chromium}=require('C:/Users/gardh/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const fs=require('fs');
const out=__dirname;
(async()=>{
 require('child_process').execFileSync('C:/Users/gardh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe',['C:/Users/gardh/.codex/plugins/cache/openai-bundled/visualize/1.0.37/skills/visualize/scripts/render.py',out+'/dailys-home.html',out+'/qa-render.html','--force']);
 const browser=await chromium.launch({headless:true,channel:'msedge'});
 const page=await browser.newPage({viewport:{width:1056,height:1100}}),errors=[];
 page.on('pageerror',e=>errors.push(e.message));
 await page.goto('file:///'+out.replaceAll('\\','/')+'/qa-render.html');
 let frame=page.frames().find(f=>f.parentFrame());
 await frame.locator('#dailys-home').waitFor();
 const results=[];
 const click=async s=>{await frame.locator(s).filter({visible:true}).first().click()};
 const assert=(v,msg)=>{if(!v)throw Error(msg)};
 for(const theme of ['terang','gelap'])for(const w of [1440,1056,860,736,680,440,392,360,352]){
  await page.setViewportSize({width:w,height:1100});
  await frame.evaluate(theme=>{const p=document.getElementById('dailys-home').dailysPreview;p.settings.appearance=theme;p.render()},theme);
  for(const mode of ['list','timeline','week']){
   await click(`[data-mode="${mode}"]`);
   const overflow=await frame.evaluate(()=>{const r=document.getElementById('dailys-home'),b=r.getBoundingClientRect();return [...r.querySelectorAll('*')].filter(e=>{const x=e.getBoundingClientRect();return x.width&&x.height&&getComputedStyle(e).display!=='none'&&!e.closest('dialog:not([open])')&&(x.left<b.left-1||x.right>b.right+1||e.scrollWidth>e.clientWidth+2)}).map(e=>({tag:e.tagName,class:e.className,text:e.textContent.slice(0,70),scroll:e.scrollWidth,client:e.clientWidth}))});
   results.push({theme,w,mode,overflow});assert(!overflow.length,'Overflow '+JSON.stringify(results.at(-1)));
  }
 }
 await page.setViewportSize({width:1056,height:1100});
 await frame.evaluate(()=>{const p=document.getElementById('dailys-home').dailysPreview;p.settings.appearance='terang';p.render()});
 await click('[data-home]');
 await page.locator('iframe').evaluate((e,h)=>e.style.height=h+'px',await frame.locator('#dailys-home').evaluate(e=>e.scrollHeight+4));
 await page.setViewportSize({width:1056,height:1600});
 await frame.locator('#dailys-home').screenshot({path:out+'/home-desktop.png'});
 await click('[data-habitcheck="h2"]');
 assert(await frame.locator('[data-item="habit-h2-2026-09-12"]').count()===1,'Habit derived once');
 await click('[data-habitcheck="h2"]');
 assert(await frame.locator('[data-item="habit-h2-2026-09-12"]').count()===0,'Habit undo removes derived');
 await click('[data-habit="h2"]');await frame.locator('#dh-habitnote').fill('Jalan sore');await click('[data-habitdone="h2"]');
 await click('[data-habit="h2"]');await click('[data-habitskip="h2"]');
 assert(await frame.locator('[data-item="habit-h2-2026-09-12"]').count()===0,'Skip removes derived');
 await click('[data-item="tb2"]');await click('[data-command="start|tb2"]');
 await click('[data-item="tb2"]');await click('[data-command="complete|tb2"]');
 assert(await frame.locator('[data-item="tb2"]').count()===1,'Timebox result not duplicated');
 await click('[data-task="t1"]');await frame.locator('#dh-taskstatus').selectOption('selesai');await click('[data-tasksave="t1"]');
 assert(await frame.locator('.dh-deadlineoverlay[data-task="t1"]').count()===0,'Completed task hidden');
 await click('#dh-add');await frame.locator('[name="title"]').fill('Baca referensi');await click('button[type=submit]');
 const debug=await frame.evaluate(()=>({items:document.getElementById('dailys-home').dailysPreview.items,error:document.getElementById('dh-formerror')?.textContent,date:document.getElementById('dh-date').value,html:document.getElementById('dh-agenda').innerHTML}));
 assert(await frame.locator('[data-item="new1"]').count()===1,'Add manual '+JSON.stringify({debug,errors,form:await frame.locator('#dh-form').evaluate(e=>({valid:e.checkValidity(),controls:[...e.elements].map(e=>({name:e.name,value:e.value,valid:e.validity?.valid}))}))}));
 await click('[data-item="new1"]');await click('[data-edit="new1"]');await frame.locator('[name="title"]').fill('Baca referensi lanjutan');await click('button[type=submit]');
 await click('[data-item="new1"]');await click('[data-manualaction="dilewati|new1"]');
 await click('[data-item="a3"]');await click('[data-manualaction="selesai|a3"]');
 await click('[data-mode="list"]');await click('[data-manual="a3"]');
 await click('#dh-prev');await click('[data-item="tb5"]');await click('[data-cancel]');
 await click('[data-item="tb5"]');await click('[data-reschedule="tb5"]');await click('button[type=submit]');
 assert(await frame.evaluate(()=>document.getElementById('dailys-home').dailysPreview.items.find(i=>i.id==='tb5').status)==='rescheduled','Reschedule preserves source');
 await click('[data-home]');await click('[data-mode="week"]');await click('[data-slot="2026-09-07|08:00"]');await frame.locator('[name="title"]').fill('Block baru');await click('button[type=submit]');
 await click('[data-home]');await click('#dh-reviewopen');await frame.locator('[name="evaluation"]').fill('Catatan kuliah rapi.');await frame.locator('[name="focus"]').fill('Selesaikan laporan.');await click('button[type=submit]');
 assert((await frame.locator('#dh-reviewstatus').textContent()).includes('Review selesai'),'Review completes');
 await click('#dh-add');await page.keyboard.press('Escape');assert(!await frame.locator('#dh-dialog').evaluate(e=>e.open),'Escape closes');
 await page.keyboard.press('Tab');assert(await frame.evaluate(()=>document.activeElement.tagName==='BUTTON'),'Keyboard reaches control');
 for(const condition of ['kosong','memuat','gagal']){await frame.evaluate(condition=>{const p=document.getElementById('dailys-home').dailysPreview;p.settings.condition=condition;p.render()},condition);assert(await frame.locator('.dh-state').count()===3,'Three data sections state '+condition);if(condition==='gagal')await click('[data-retry]')}
 await click('#dh-theme');await click('#dh-theme');await click('#dh-next');await click('#dh-prev');await frame.locator('#dh-date').fill('2026-09-10');await frame.locator('#dh-date').dispatchEvent('change');await click('[data-date="2026-09-12"]');
 await click('[data-item="res2"]');await click('[data-command="skip|res2"]');
 await click('[data-home]');await click('[data-mode="week"]');await click('[data-item="tb3"]');await click('[data-command="skip|tb3"]');
 await click('[data-item="tb4"]');await click('#dh-close');
 await click('[data-item="tb1"]');await click('[data-cancel]');
 await click('#dh-add');await frame.locator('[name="title"]').fill('Validasi Timebox');await frame.locator('#dh-formtype').selectOption('timebox');await click('button[type=submit]');assert((await frame.locator('#dh-formerror').textContent()).includes('jam'),'Missing times validation');await frame.locator('[name="start"]').fill('08:00');await frame.locator('[name="end"]').fill('09:00');await frame.locator('[name="date"]').fill('2026-09-11');await frame.locator('[name="link"]').selectOption('habit:h2');await frame.locator('[name="repeat"]').selectOption('weekly');await click('button[type=submit]');
 await click('[data-mode="timeline"]');await click('[data-item="new4"]');await click('[data-command="missed|new4"]');
 await click('[data-home]');await click('#dh-reviewopen');await frame.locator('[name="evaluation"]').fill('Jurnal diperbarui.');await click('button[type=submit]');
 await click('#dh-add');await frame.locator('[name="title"]').fill('Keyboard save');await page.keyboard.press('Enter');assert(await frame.locator('[data-item="new5"]').count()===1,'Enter saves');
 await click('#dh-add');await page.setViewportSize({width:352,height:900});const modalOverflow=await frame.locator('#dh-dialog').evaluate(r=>{const b=r.getBoundingClientRect();return [...r.querySelectorAll('*')].filter(e=>{const x=e.getBoundingClientRect();return x.width&&x.height&&(x.right>b.right+1||x.left<b.left-1)}).map(e=>e.className)});assert(!modalOverflow.length,'Phone form overflow');await click('[data-cancel]');
 await page.reload();frame=page.frames().find(f=>f.parentFrame());await frame.locator('#dailys-home').waitFor();await page.locator('iframe').evaluate((e,h)=>e.style.height=h+'px',await frame.locator('#dailys-home').evaluate(e=>e.scrollHeight+4));await page.setViewportSize({width:352,height:2700});await frame.locator('#dailys-home').screenshot({path:out+'/home-mobile.png'});await page.setViewportSize({width:1056,height:1100});
 assert(!errors.length,'Runtime errors '+errors.join(', '));
 const contrast=[];
 for(const theme of ['terang','gelap']){await frame.evaluate(theme=>{const p=document.getElementById('dailys-home').dailysPreview;p.settings.appearance=theme;p.render()},theme);const checks=await frame.evaluate(()=>{
  const L=c=>{const m=c.match(/[\d.]+/g);if(!m)return 0;const v=m.slice(0,3).map(x=>{const n=Number(x)/255;return n<=.04045?n/12.92:((n+.055)/1.055)**2.4});return v[0]*.2126+v[1]*.7152+v[2]*.0722};
  const ratio=(a,b)=>(Math.max(L(a),L(b))+.05)/(Math.min(L(a),L(b))+.05);
  return [...document.getElementById('dailys-home').querySelectorAll('*')].filter(e=>e.getBoundingClientRect().width&&!e.closest('dialog')&&!e.disabled&&[...e.childNodes].some(n=>n.nodeType===3&&n.textContent.trim())).map(e=>{const s=getComputedStyle(e);let bg=s.backgroundColor,parent=e;while((bg==='rgba(0, 0, 0, 0)'||bg==='transparent')&&parent.parentElement){parent=parent.parentElement;bg=getComputedStyle(parent).backgroundColor}return {text:e.textContent.slice(0,60),color:s.color,bg,ratio:ratio(s.color,bg),size:parseFloat(s.fontSize)}}).filter(v=>v.ratio<(v.size>=24?3:4.5));
 });contrast.push({theme,failures:checks});assert(!checks.length,'Contrast '+JSON.stringify(contrast.at(-1)))}
 fs.writeFileSync(out+'/qa-results.json',JSON.stringify({results,contrast,errors,interactions:'PASS'},null,2));
 await browser.close();console.log('PASS: '+results.length+' responsive checks; light/dark text contrast; primary interactions; no JavaScript errors.');
})().catch(e=>{console.error(e);process.exit(1)});
