# Alur kerja Git (branch + PR)

Aturan inti: **jangan commit atau push langsung ke `main`**. Setiap kali mau push,
buat **branch baru** yang namanya sesuai pekerjaan, push branch itu, lalu buka
Pull Request ke `main`.

## Penamaan branch

Format: `<tipe>/<ringkas-kebab-case>`, opsional beri awalan milestone.

| Tipe | Untuk | Contoh |
|---|---|---|
| `feat` | Fitur atau implementasi baru | `feat/m1-core-determinism`, `feat/m1-drift-db`, `feat/m1-tugas-crud` |
| `fix` | Perbaikan bug | `fix/streak-recompute-timezone` |
| `docs` | Dokumen kontrak/produk | `docs/theme-contract`, `docs/dr-rightsizing` |
| `design` | Paket desain (`design/`) | `design/splash-v1.4`, `design/weekly-review` |
| `test` | Menambah/merapikan test | `test/dst-golden-vectors` |
| `chore` | Tooling, config, gitignore, CI | `chore/gitignore`, `chore/ci-flutter-test` |
| `refactor` | Rapikan kode tanpa ubah perilaku | `refactor/core-time` |

Aturan nama: huruf kecil, kata dipisah `-`, ringkas tapi jelas menyebut apa yang
dikerjakan. Satu branch = satu unit kerja yang bisa di-review sekaligus.

## Langkah tiap kali mau push

```bash
# 1. Pastikan main terbaru
git checkout main
git pull origin main

# 2. Buat branch sesuai pekerjaan
git checkout -b feat/m1-drift-db

# 3. Kerjakan, lalu commit (pesan imperatif, ringkas)
git add -A
git commit -m "Add Drift M1 tables, migration v1, and seed categories"

# 4. Push branch (bukan main)
git push -u origin feat/m1-drift-db

# 5. Buka Pull Request ke main
#    - via web: buka link yang dicetak setelah push, atau
#    - via CLI GitHub:
gh pr create --base main --head feat/m1-drift-db --fill

# 6. Setelah review/CI hijau, merge PR (disarankan "Squash and merge") di GitHub.

# 7. Bersih-bersih setelah merge
git checkout main
git pull origin main
git branch -d feat/m1-drift-db
git push origin --delete feat/m1-drift-db
```

## Pesan commit

- Baris pertama imperatif dan ringkas (mis. "Add ...", "Fix ...", "Update ...").
- Detail opsional pada baris berikutnya.
- Semua commit di repo ini — termasuk yang dibuat lewat Claude Code — memakai
  identitas git pemilik repo (`GardhHX <gardhastudy@gmail.com>`), **bukan**
  trailer atribusi Claude/AI. Lihat `CLAUDE.md` untuk instruksi setup identitas
  git di awal sesi Claude Code.

## Aturan yang dijaga

- **`main` tidak menerima push langsung.** Semua perubahan lewat branch + PR.
- **Jangan `--force` ke `main`.** Kalau perlu memperbaiki, buat branch/PR baru.
- **`main` selalu sehat**: bisa di-build, test hijau. Jangan merge PR yang merah.
- Satu PR fokus pada satu hal; PR besar dipecah bila memungkinkan.
- Hapus branch setelah di-merge agar daftar branch tetap bersih.
- Otoritas kontrak tetap berlaku: PRD -> schema -> API-SPEC -> OpenAPI -> desain.
  Perubahan yang menyentuh beberapa dokumen diselesaikan dalam satu PR.

## Catatan repo

- Arsip `Dailys-design-*.zip` tidak di-commit (di-`.gitignore`); distribusikan lewat
  GitHub Releases atau buat ulang via `design/pack_design.py`.
- Artefak build Flutter (`app/build/`, `app/.dart_tool/`) di-ignore; `app/pubspec.lock`
  tetap di-commit.
