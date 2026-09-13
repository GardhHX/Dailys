# Weekly Review

Acuan visual paket v1.2: [preview interaktif](../preview/weekly-review.html),
[desktop](../mockups/weekly-review-desktop.png), dan
[ponsel](../mockups/weekly-review-mobile.png). Sumber yang dapat diedit:
`../source/dailys-weekly-review.html`. Gunakan token `../tokens.json` dan lihat
`../GAPS.md` untuk batas simulasi.

## Tempat dan hierarki

Route global dengan tombol kembali, bukan tab utama keenam. Masuk dari shortcut
Weekly Review di Home dan dari Settings. Satu WeeklyReview mewakili satu minggu
kalender Senin sampai Minggu dalam timezone user; layar selalu menampilkan satu
minggu.

Header: rentang `week_start`-`week_end`, badge status (`draft` atau `completed`),
waktu review, dan CTA utama **Selesaikan review**. Review yang dibuka manual
sebelum trigger tetap dapat diselesaikan jika dua jurnal dan draft aktif valid;
trigger mengaktifkan gate planning, bukan syarat tambahan command complete.
Penyesuaian ini mengikuti PRD/schema/API; lihat
[pemeriksaan kontrak](../evidence/weekly-review-contract-check.md).
Isi: dua jurnal wajib -> ringkasan produktivitas -> kandidat -> rencana minggu
depan -> beban minggu depan. Desktop memberi kolom kiri lebih lebar untuk dua
jurnal dan ringkasan; kandidat/rencana pada kolom pendamping. Ponsel menumpuk
dengan urutan sama; jurnal tetap dahulu.

Data contoh berlabel dan tanggal seed tetap; angka ringkasan berasal dari fixture,
bukan statistik pengguna.
Fixture ringkasan dan tiga contoh kandidat bukan database source lengkap. Activity
contoh mencakup 31 hasil derived (9 Pomodoro, 6 Timebox, 16 Habit) serta 6 Activity
manual: 2 selesai, 1 dilewati, 3 belum mulai. Implementasi membaca seluruh kandidat
dari domain sebenarnya dan menghitung agregasi dari record, bukan daftar contoh ini.

## Dua jurnal wajib

**Evaluasi minggu ini** dan **Fokus minggu depan**. Keduanya textarea jurnal bebas
tanpa pertanyaan refleksi wajib. Boleh kosong saat `draft`; wajib terisi saat
complete. Review `completed` tetap dapat mengedit kedua teks ini; edit mengubah
`updated_at` tanpa menghitung ulang ringkasan. Tidak ada aksi skip, hapus, reopen,
atau ganti periode.

## Ringkasan produktivitas

Angka terpindai dengan label, bukan chart pengisi. Saat `draft` dihitung live
sampai waktu baca dan menandai belum dibekukan. Command complete membekukan
ringkasan dan `summary_cutoff_at` dalam transaction yang sama; edit jurnal atau
perubahan source sesudahnya tidak menghitung ulang angka `completed`. Schema 15.1
tetap mengizinkan response/pull mengganti snapshot client dengan hasil kanonik
server pada cutoff sama, tanpa membuka kembali gate.

Lima kelompok mengikuti schema 14.1:

| Kelompok | Angka |
|---|---|
| Activity | planned, selesai, dilewati, belum mulai, completion rate |
| Tugas | selesai, aktif, overdue |
| Pomodoro | sesi fokus completed, durasi fokus |
| Timebox | completed, missed, skipped, pending |
| Habit | done, missed, excused |

Completion rate memakai rumus normatif Activity 14.1 (`selesai / seluruh Activity
aktif`, `0.0` bila kosong). Keuangan tidak masuk ringkasan v1.0. Angka overdue dan
missed memakai warna danger plus teks; selesai/done memakai success plus teks.
Ringkasan draft dan completed dibedakan dengan label status yang jelas, bukan
warna saja.

## Kandidat dan rencana minggu depan

Kandidat hanya membaca source record: Tugas aktif/overdue, Activity belum
selesai/dilewati, Timebox pending/missed. Tiap baris menampilkan jenis, judul, dan
tanggal terkait. Tindakan per kandidat: biarkan, tangani di modul asal, atau buat
WeeklyPlanDraft. Layar tidak memindahkan pekerjaan otomatis dan tidak mengubah
source.

Rencana minggu depan berisi daftar WeeklyPlanDraft. Tiap draft menarget tepat satu
`tugas`, `activity`, atau `timebox`, memiliki judul, catatan opsional, dan
`target_date` pada `week_start + 7..13 hari`. Draft dapat dibuat dari kandidat atau
bebas melalui modal tambah/edit.

- Draft dapat diubah atau dihapus selama `draft`; `promoted` dan `discarded` menjadi
  histori dan tidak kembali ke draft.
- Aktivasi satu per satu: **Aktifkan** membuka form modul tujuan (Tugas, Activity,
  atau Timebox ad-hoc) untuk melengkapi field wajib. Simpan membuat target dan
  menandai draft `promoted` dalam satu transaction lokal.
- Retry aktivasi mengembalikan target yang sama; UUIDv5 hasil promotion mencegah
  duplikat. Draft yang sudah promoted tidak dapat dipromosikan lagi.
- Saat gate aktif, **Aktifkan** ditahan dengan penjelasan di atas daftar. Pembuatan
  draft ringan tetap tersedia. Selesaikan review dahulu tanpa mewajibkan promotion.

Beban minggu depan menampilkan tujuh baris Senin sampai Minggu untuk minggu setelah
`week_start`: jumlah tugas, estimasi menit, dan jumlah tugas tanpa estimasi. Hari
tanpa tugas tetap baris nol. Ini bagian Weekly Review, bukan layar workload
tersendiri.
WeeklyPlanDraft belum ikut workload; aktivasi Tugas menambah beban pada tanggal
deadline target baru. Aktivasi Activity/Timebox tidak menambah jumlah tugas.

Form contoh Tugas memuat judul, mata kuliah opsional, prioritas, tanggal/jam
deadline, estimasi opsional dan deskripsi. Activity memuat judul, tanggal,
kategori, pasangan waktu opsional dan catatan. Timebox memakai tanggal tunggal,
waktu mulai/selesai, kategori dan catatan. Semua membuka modal form; tidak ada
aktivasi massal. Reminder editor, pemilihan link Timebox, dan pilihan waktu Activity
secara lengkap tetap memakai kontrak/pola modul, bukan allowlist fixture ini.

## Gate planning

Gate aktif sejak Minggu pada waktu review sampai review minggu berjalan
`completed`. Selama aktif, layar menahan create atau perubahan planning yang
memengaruhi minggu berikutnya: jadwal Activity, deadline Tugas, Timebox, dan
recurrence yang mematerialisasi occurrence pada periode itu. Item yang sudah
direncanakan sebelum gate tetap ada dan tetap terbaca.

Gate tetap mengizinkan pencatatan hasil, completion/cancel/skip, perubahan aktual,
edit non-planning, serta seluruh planning di luar minggu berikutnya. Complete
menolak bila salah satu teks wajib kosong atau ada draft aktif dengan target/tanggal
tidak valid; draft tidak wajib dipromosikan lebih dahulu. Penyelesaian lokal
membuka gate tanpa menunggu VPS; client mengirim WeeklyReview `completed` sebelum
mutation planning minggu depan. Banner menjelaskan gate dalam bahasa pengguna dan
menautkan aksi menyelesaikan review, bukan menampilkan kode error mentah.

## Keadaan dan aksesibilitas

Keadaan wajib: draft dengan gate belum aktif (dibuka manual sebelum trigger),
draft dengan gate aktif, completed read-only dengan dua teks tetap dapat diedit,
minggu tanpa aktivitas (ringkasan nol, kandidat kosong dengan langkah berikutnya),
serta memuat dan gagal-dengan-retry pada ringkasan/kandidat. Fresh install tengah
minggu tidak membuat review parsial; layar menjelaskan review wajib pertama dimulai
pada trigger Minggu berikutnya.

Modal tambah/edit draft dan form promotion mengelola fokus, submit dengan Enter,
tutup dengan Escape, dan mengembalikan fokus ke pemicu. Error tidak menghapus teks
jurnal atau isi draft yang masih dapat dipulihkan. Target implementasi kontras AA,
fokus terlihat, urutan Tab logis, status memiliki teks/simbol selain warna, dan
angka ringkasan memakai angka tabular.

## Kontrak dan gap

PRD FR-8.1 sampai 8.14; FR-7.14; schema 15.1, 15.2, 15.3, dan 14.1 (weekly summary
snapshot serta next-week workload); API-SPEC 9.9. Ringkasan/gate/promotion mengikuti
kontrak walau preview kelak memakai langkah pendek dan data contoh.

Preview/mockup, CRUD/discard draft, form promotion ketiga modul, ringkasan live
dan frozen, serta routing shortcut Home pada paket offline tersedia. Kontrol
keadaan contoh dan tema memperlihatkan before-trigger, gate aktif, completed,
minggu kosong dan fresh install. Memuat/gagal dapat dipilih dari toolbar acuan;
canvas menyediakan pilihan keadaan data pada kontrol desain.

Belum lengkap: missed review terkelompok saat beberapa minggu terlewat, seluruh
field/picker/reminder form modul, Settings route penuh, dan data/persistensi lintas
modul. Identitas target berprefix `example-` dan receipt retry adalah simulasi;
implementasi wajib memakai UUIDv5 dan transaction/outbox sebenarnya. Jangan memakai
contoh sebagai allowlist domain. Bukti browser:
[QA Weekly Review](../evidence/qa-review-results.json).

## Periksa saat implementasi

Minggu kosong dengan rate 0.0, ringkasan live vs frozen, edit teks setelah complete
tanpa recompute, complete ditolak karena teks kosong atau draft invalid, draft
target ketiga modul, aktivasi satu per satu dan retry idempotent, gate memblokir
planning minggu depan tetapi mengizinkan hasil/aktual, completion offline membuka
gate, fresh install tengah minggu, beban tujuh hari termasuk hari nol, dua tema,
modal ponsel, dan fokus keyboard.
