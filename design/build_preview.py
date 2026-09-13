"""Build the offline design reference from the preserved canvas fragments."""
from pathlib import Path
import hashlib
import html
import json

BASE = Path(__file__).resolve().parent
SCREENS = [
    {"id": "home", "label": "Home", "source": "dailys-home.html", "root": "dailys-home", "state": None, "description": "Activity dan Timebox, Next deadline, Habits, dan akses Weekly Review."},
    {"id": "tugas", "label": "Tugas", "source": "dailys-tugas-pomodoro.html", "root": "dailys-work", "state": "tasks", "description": "Deadline aktif, detail/checklist, riwayat mingguan, mata kuliah dan CourseNote."},
    {"id": "pomodoro", "label": "Pomodoro", "source": "dailys-tugas-pomodoro.html", "root": "dailys-work", "state": "pomo", "description": "Timer fokus dan break, link pekerjaan, durasi aktual, statistik dan riwayat."},
    {"id": "keuangan", "label": "Keuangan", "source": "dailys-keuangan-habit.html", "root": "dailys-life", "state": "finance", "description": "Saldo, ledger, transfer, akun, kategori dan insight arus kas."},
    {"id": "habit", "label": "Habit", "source": "dailys-keuangan-habit.html", "root": "dailys-life", "state": "habit", "description": "Target hari, checklist, streak, heatmap, izin dan jadwal efektif."},
    {"id": "pusat-sync", "label": "Pusat Sync", "source": "dailys-sync-onboarding.html", "root": "dailys-sync", "state": "sync", "kind": "global", "description": "Status lokal, antrean, registrasi, error sync dan alur salinan/snapshot/recovery."},
    {"id": "review-konflik", "label": "Review konflik", "source": "dailys-sync-onboarding.html", "root": "dailys-sync", "state": "conflicts", "kind": "global", "description": "Versi awal/lokal/server, pilihan kelompok atomik, dampak saldo dan hasil resolusi."},
    {"id": "onboarding", "label": "Onboarding", "source": "dailys-sync-onboarding.html", "root": "dailys-sync", "state": "onboarding", "kind": "global", "description": "Bahasa, timezone, perangkat, registrasi/offline dan akun keuangan pertama opsional."},
    {"id": "weekly-review", "label": "Weekly Review", "source": "dailys-weekly-review.html", "root": "dailys-review", "state": "review", "kind": "global", "description": "Dua jurnal, ringkasan live/snapshot, kandidat, draft/promotion dan beban tujuh hari."},
    {"id": "settings", "label": "Global Settings", "source": "dailys-settings.html", "root": "dailys-settings", "state": "settings", "kind": "global", "description": "Bahasa, timezone, Pomodoro, notifikasi, preferensi perangkat dan akses alur global."},
]

HOST_STYLE = """
html{background:#f5f4f0;color:#20212b;font:14px/1.5 'Segoe UI',Arial,sans-serif}
body{margin:0;padding:16px;min-width:288px}*{box-sizing:border-box}
a{color:#3538a0;text-underline-offset:3px}a:focus-visible,select:focus-visible{outline:3px solid #3538a0;outline-offset:3px}
.reference-bar{max-width:1408px;margin:0 auto 16px;display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap}
.reference-links{display:flex;gap:16px;align-items:center;flex-wrap:wrap}.reference-bar label{display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.reference-bar select{font:inherit;min-height:44px;padding:8px;border:1px solid #777887;border-radius:6px;color:#20212b;background:#fff}
.reference-note{max-width:1408px;margin:12px auto 0;color:#595a68;font-size:12px}
.preview-content{max-width:1408px;margin:auto}
@media(max-width:440px){body{padding:16px}.reference-links{gap:12px}}
"""

ADAPTER = r"""
(() => {
  const config = __CONFIG__;
  const root = document.getElementById(config.root);
  const api = root.dailysPreview;
  const state = api.design || api.settings;
  if (config.state) state.screen = config.state;
  api.render();

  if (config.id !== 'settings' && config.id !== 'onboarding') {
    const header = root.querySelector('header');
    const button = document.createElement('button');
    button.type='button'; button.textContent='Settings'; button.dataset.globalSettings='';
    button.style.cssText='min-height:44px;font:inherit;font-size:12px;padding:8px 12px;flex-shrink:0';
    header.style.flexWrap='wrap';
    header.append(button);
  }
  root.addEventListener('click', event => {
    const button = event.target.closest('[data-global-settings],[data-settings],[data-route]');
    if (!button) return;
    let destination;
    if(button.hasAttribute('data-global-settings')) destination='settings.html';
    else if(button.hasAttribute('data-settings')) destination='settings.html#dg-'+(config.root==='dailys-work'?'pomodoro':'sync');
    else if(config.id==='settings') destination=button.dataset.route+'.html';
    if(!destination) return;
    event.preventDefault();event.stopImmediatePropagation();location.href=destination;
  },true);
  if(config.id==='settings' && location.hash.startsWith('#dg-')) api.setSection(location.hash.slice(4));

  const icons = {
    house: '<path d="m3 10 9-7 9 7v11h-6v-7H9v7H3z"/>',
    'clipboard-list': '<rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4V2h6v2M9 10h6M9 15h6"/>',
    timer: '<circle cx="12" cy="14" r="8"/><path d="M9 2h6m-3 0v4m6 1 2-2m-8 5v4l3 2"/>',
    wallet: '<rect x="3" y="5" width="18" height="15" rx="2"/><path d="M15 10h6v5h-6zM3 8h18"/>',
    'list-checks': '<path d="m3 6 2 2 3-4m3 2h10M3 13l2 2 3-4m3 2h10M3 20l2 2 3-4m3 2h10"/>'
  };
  root.querySelectorAll('[data-lucide]').forEach(node => {
    const path = icons[node.dataset.lucide];
    if (!path) return;
    node.outerHTML = '<svg aria-hidden="true" width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">' + path + '</svg>';
  });

  const destinations = {Home:'home', Tugas:'tugas', Pomodoro:'pomodoro', Keuangan:'keuangan', Habit:'habit'};
  root.querySelectorAll('nav button').forEach(button => {
    const label = Object.keys(destinations).find(key => button.textContent.trim().endsWith(key));
    if (!label) return;
    button.disabled = false;
    button.dataset.referenceDestination = destinations[label];
    if (destinations[label] === config.id) button.setAttribute('aria-current','page');
    else button.removeAttribute('aria-current');
  });
  root.querySelectorAll('.dh-navcaption,.dw-navnote,.dl-navnote').forEach(node => {
    node.textContent = 'Acuan lima layar · data contoh';
  });
  root.addEventListener('click', event => {
    const button = event.target.closest('[data-reference-destination]');
    if (!button) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    const destination = button.dataset.referenceDestination;
    if (destination !== config.id) location.href = destination + '.html';
  }, true);

  document.getElementById('reference-condition').addEventListener('change', event => {
    state.condition = event.target.value;
    api.render();
  });
  if (config.root === 'dailys-sync') root.addEventListener('click', event => {
    const button = event.target.closest('[data-onboardhome]');
    if (!button) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    location.href = 'home.html';
  }, true);
  if (config.root === 'dailys-review') root.addEventListener('click', event => {
    const button = event.target.closest('[data-home],[data-candidate]');
    if (!button) return;
    const candidate = api.getCandidates().find(candidate => candidate.id === button.dataset.candidate);
    const destination = button.hasAttribute('data-home') ? 'home' : destinations[candidate?.module];
    if (!destination) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    location.href = destination + '.html';
  }, true);
  if (config.root === 'dailys-home') root.addEventListener('click', event => {
    if (!event.target.closest('#dh-reviewopen')) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    location.href = 'weekly-review.html';
  }, true);
  root.addEventListener('click', event => {
    if (event.target.closest('[data-retry]')) document.getElementById('reference-condition').value='terisi';
  });
})();
"""


def page(title, body):
    return '<!doctype html>\n<html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>' + html.escape(title) + '</title><style>' + HOST_STYLE + '</style></head><body>' + body + '</body></html>\n'


def main():
    output = BASE / 'preview'
    output.mkdir(exist_ok=True)
    for screen in SCREENS:
        fragment = (BASE / 'source' / screen['source']).read_text(encoding='utf-8-sig')
        toolbar = '<div class="reference-bar"><div class="reference-links"><a href="index.html">← Semua desain</a><a href="../screens/' + screen['id'] + '.md">Spesifikasi ' + screen['label'] + '</a><a href="../../DESIGN.md">Panduan desain</a></div><label for="reference-condition">Keadaan contoh<select id="reference-condition"><option value="terisi">Terisi</option><option value="kosong">Kosong</option><option value="memuat">Memuat</option><option value="gagal">Gagal</option></select></label></div>'
        adapter = ADAPTER.replace('__CONFIG__', json.dumps(screen, ensure_ascii=False))
        body = toolbar + '<div class="preview-content">' + fragment + '</div><p class="reference-note">Toolbar acuan bukan UI produk. Data contoh bersifat sementara; pindah halaman atau reload mengembalikannya. Lihat GAPS.md untuk flow yang belum dirancang.</p><script>' + adapter + '</script>'
        (output / (screen['id'] + '.html')).write_text(page('Dailys — ' + screen['label'], body), encoding='utf-8')

    cards = []
    for screen in SCREENS:
        ident, label = screen['id'], screen['label']
        cards.append('<article><a class="gallery-image" href="' + ident + '.html" aria-label="Buka preview ' + label + '"><img src="../mockups/' + ident + '-desktop.png" alt="Desain ' + label + ' desktop" loading="lazy"></a><div class="gallery-copy"><h2>' + label + '</h2><p>' + screen['description'] + '</p><div class="gallery-actions"><a class="gallery-primary" href="' + ident + '.html">Buka preview</a><a href="../screens/' + ident + '.md">Spesifikasi</a><a href="../mockups/' + ident + '-mobile.png">Gambar ponsel</a></div></div></article>')
    gallery_style = '<style>.gallery{max-width:1408px;margin:auto}.gallery header{padding:16px 0 24px}.gallery h1{font-size:32px;line-height:1.2;letter-spacing:-1px;margin:12px 0}.gallery header p{max-width:760px;color:#595a68}.gallery-nav{display:flex;gap:16px;flex-wrap:wrap}.gallery-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:24px}.gallery article{min-width:0;background:#fff;border:1px solid #dcdce2;border-radius:9px;overflow:hidden}.gallery-image{display:block;background:#eeeefa;border-bottom:1px solid #dcdce2}.gallery-image img{display:block;width:100%;aspect-ratio:16/10;object-fit:cover;object-position:top}.gallery-copy{padding:20px}.gallery h2{font-size:22px;margin:0 0 8px}.gallery-copy p{color:#595a68;margin:0 0 16px}.gallery-actions{display:flex;align-items:center;gap:16px;flex-wrap:wrap}.gallery-actions a{min-height:44px;display:inline-flex;align-items:center}.gallery-primary{background:#3538a0;color:#fff;text-decoration:none;border-radius:6px;padding:10px 14px;font-weight:600}.gallery-primary:hover{background:#2d308a}.gallery footer{margin:24px 0;color:#595a68}@media(max-width:736px){.gallery-grid{grid-template-columns:1fr;gap:20px}.gallery h1{font-size:28px}}</style>'
    body = gallery_style + '<main class="gallery"><header><strong>dailys. / acuan desain v1.3</strong><h1>Lima menu dan alur global.</h1><p>Home, Tugas, Pomodoro, Keuangan, Habit; ditambah Global Settings, Pusat Sync, review konflik, onboarding, dan Weekly Review. Alur global bukan tab utama tambahan. Buka preview untuk mencoba tema, form, dan keadaan data.</p><nav class="gallery-nav" aria-label="Dokumentasi desain"><a href="../../DESIGN.md">DESIGN.md</a><a href="../VIBECODE-PROMPT.md">Prompt vibecoding</a><a href="../GAPS.md">Coverage dan gap</a><a href="../tokens.json">Token desain</a></nav></header><section class="gallery-grid" aria-label="Preview sepuluh desain">' + ''.join(cards) + '</section><footer>Offline, tanpa instalasi. Seluruh isi preview berlabel data contoh; bukan aplikasi produksi. Gambar kartu memotong screenshot untuk galeri. Buka PNG atau preview untuk melihat seluruh layar.</footer></main>'
    (output / 'index.html').write_text(page('Dailys — acuan desain', body), encoding='utf-8')
    sources = {name: hashlib.sha256((BASE / 'source' / name).read_bytes()).hexdigest() for name in sorted({s['source'] for s in SCREENS})}
    manifest = {"version": "1.3", "created": "2026-09-13", "entry": "preview/index.html", "authority": "../DESIGN.md", "screens": [{"id":s['id'], "label":s['label'], "kind":s.get('kind','primary'), "preview":"preview/"+s['id']+".html", "spec":"screens/"+s['id']+".md", "desktop":"mockups/"+s['id']+"-desktop.png", "mobile":"mockups/"+s['id']+"-mobile.png", "source":"source/"+s['source']} for s in SCREENS], "sourceSha256": sources, "qaCanvasResponsiveChecks": {"home":54, "tugasPomodoro":96, "keuanganHabit":144}, "statePersistence": "none", "externalDependencies": []}
    (BASE / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    print('Built 10 offline previews, gallery, and manifest.')


if __name__ == '__main__':
    main()
