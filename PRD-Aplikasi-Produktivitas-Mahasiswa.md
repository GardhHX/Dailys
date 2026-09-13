# PRD: Dailys — Aplikasi Produktivitas & Keuangan Mahasiswa

**Status:** Target v1.0 — belum diimplementasikan
**Versi:** 1.0
**Terakhir diperbarui:** 6 September 2026
**Owner:** Gardh
**Indeks:** `README.md`
**Operasional:** `OPERATIONS.md`

Dokumen ini menjadi sumber kebutuhan produk. `schema.md` mendefinisikan model data,
`API-SPEC.md` dan `openapi.yaml` mendefinisikan kontrak jaringan. Catatan
keputusan yang sudah tidak aktif tidak menjadi requirement.

---

## 1. Overview & Problem Statement

**Problem Statement:**

Saat ini pengelolaan aktivitas harian, tugas kuliah, keuangan, dan habit dilakukan lewat Notion. Namun Notion dirancang sebagai tool serba-guna yang fleksibel — dan fleksibilitas itu berbalik jadi beban begitu kebutuhan makin spesifik. Setiap fitur baru (pomodoro tracking, pencatatan keuangan, habit tracker, dst.) berarti page/database baru yang harus dikonfigurasi dan di-link manual. Hasilnya, workspace Notion semakin dipenuhi banyak page terpisah, terasa **sesak dan tidak nyaman** digunakan, alih-alih terasa sebagai satu sistem yang terintegrasi.

**Overview:**

**Dailys** adalah aplikasi produktivitas dan keuangan personal, dibangun native untuk Windows dan Android, yang menyatukan 6 kebutuhan inti mahasiswa dalam **satu aplikasi terintegrasi** — tanpa perlu membangun atau menghubungkan modul baru secara manual seperti di Notion:

- **Daily Activity Log** — catatan rencana & realisasi aktivitas harian
- **Pomodoro Timer** — sesi fokus yang bisa dikaitkan ke tugas/habit
- **Timebox** — jadwal mingguan berulang untuk blok waktu kerja
- **Pencatatan Keuangan** — multi-akun dengan kategori khas kebutuhan mahasiswa
- **Habit Tracker** — target custom per hari dengan visualisasi streak
- **Deadline Tugas Kuliah** — reminder bertingkat, status overdue, dan riwayat

Keenam fitur ini saling terhubung secara native di level data (misal: sesi pomodoro otomatis masuk ke activity log, tugas bisa dikaitkan ke pomodoro/timebox) — sesuatu yang di Notion harus disusun manual dan rawan berantakan.

| | |
|---|---|
| **Nama aplikasi** | Dailys |
| **Platform** | Windows lebih dahulu; Android mulai milestone M2 |
| **Target pengguna** | Personal use — mahasiswa (pembuat aplikasi sendiri) |
| **Model data** | Offline-first di device, sync otomatis via VPS antar device |
| **Tech stack** | Flutter (Dart) |

---

## 2. Goals & Success Metrics

**Goals:**

1. Menggantikan Notion sebagai tool utama untuk mengelola daily activity, pomodoro, timebox, keuangan, habit, dan deadline tugas kuliah — dalam **satu aplikasi terintegrasi**.
2. Menyediakan 6 fitur inti yang berfungsi penuh dan saling terhubung di level data, tanpa perlu konfigurasi manual seperti membangun page/database baru di Notion.
3. Membangun kebiasaan penggunaan rutin sehari-hari sebagai bukti bahwa aplikasi ini benar-benar menyelesaikan masalah, bukan sekadar selesai dibangun.
4. Menjadi media belajar pengembangan Flutter cross-platform secara terarah, lewat vibe coding yang disertai pemahaman — bukan blind.

**Success Metrics:**

- **SM-1** Semua 6 fitur inti (Daily Activity, Pomodoro, Timebox, Keuangan, Habit Tracker, Deadline Tugas) selesai diimplementasi dan dapat digunakan penuh di **Windows dan Android**.
- **SM-2** **Tidak ada bug yang menyebabkan data hilang atau corrupt.** Bug minor terkait UI/UX dapat diterima untuk v1.0.
- **SM-3** Model **offline-first berfungsi dengan benar** — semua fitur dapat dipakai tanpa koneksi internet, dan sync ke VPS berjalan otomatis tanpa konflik data yang signifikan saat online kembali.
- **SM-4** Setelah MVP rilis, Notion **sepenuhnya digantikan** oleh Dailys untuk 6 kebutuhan ini (mulai fresh, tanpa migrasi data lama).
- **SM-5** Aplikasi **dipakai secara rutin** dalam keseharian (tanpa target streak/hari spesifik) sebagai indikator adopsi nyata.
- **SM-6** *(personal/secondary)* Bertambahnya pemahaman praktis tentang pengembangan Flutter cross-platform dan arsitektur sync offline-first melalui proses membangun aplikasi ini.

---

## 3. Scope

**In Scope (v1.0 — MVP):**
- 6 fitur inti: Daily Activity Log, Pomodoro Timer, Timebox, Pencatatan Keuangan, Habit Tracker, Deadline Tugas Kuliah (detail di Section 4)
- Platform rilis v1.0: Windows + Android; Windows dimulai pada M1, Android pada M2
- Model offline-first dengan sync otomatis via VPS antar device
- Bilingual: Bahasa Indonesia + Inggris
- Weekly Review wajib untuk evaluasi minggu berjalan dan planning minggu berikutnya
- Tanpa PIN/biometric lock

**Out of Scope (v1.0 — pasca-v1.0):**
- Quick Capture / Inbox
- Export/backup mandiri oleh user (CSV, PDF, .ics). Backup operasional database
  tetap wajib pada v1.0 sesuai `OPERATIONS.md`.
- Semester & nilai (IPK) tracking
- Item spesifik per fitur yang di-defer, dirangkum di Section 8 — Future Scope

---

## 3.1 Tahapan implementasi dan bukti selesai

Enam fitur tetap menjadi target v1.0. Milestone berikut menentukan urutan pengerjaan;
selesai M1 belum berarti seluruh requirement v1.0 terpenuhi. Tidak ada tanggal
rilis atau estimasi durasi yang ditetapkan sebelum pekerjaan diukur.

| Milestone | Hasil | Bukti selesai |
|---|---|---|
| M0 — Kontrak siap | PRD, schema, API, OpenAPI, ERD, dan operasi konsisten | Link, YAML, referensi, discriminator, dan contoh kontrak lulus pemeriksaan |
| M1 — Lokal Windows | Activity + Tugas; Mata Kuliah, checklist, CourseNote, kategori, recurrence, reminder, settings pendukung | Create/edit/delete dan riwayat bekerja offline, restart mempertahankan data, backup sebelum migration tersedia untuk data nyata |
| M2 — Dua perangkat | Fitur M1 di Android dan Windows, sync, Pusat Sync, review konflik dan recovery | Retry, edit bersamaan, snapshot, restore, dan penerapan ulang tanpa duplikasi lulus pada kedua platform |
| M3 — Fokus dan jadwal | Pomodoro + Timebox pada kedua platform | Timer pulih, Activity hasil unik, planned/actual serta reschedule konsisten |
| M4 — Habit dan Keuangan | Habit lalu Keuangan pada kedua platform | Schedule historis, koreksi log, ledger, transfer dan adjustment lulus fixture |
| M5 — Weekly Review dan rilis v1.0 | Weekly Review di atas seluruh modul M1–M4 | Evaluasi, snapshot, gate planning, draft promotion, acceptance, lokalisasi ID/EN, benchmark dan restore drill sesuai OPERATIONS |

M1 memakai repository lokal dan struktur antrean yang dipersiapkan untuk M2;
network tidak menjadi syarat membuka aplikasi. Identitas user hasil provisioning
lokal tersedia sebelum seed UUIDv5 dibuat, sehingga M2 tidak mengganti ID domain.
Pembuatan akun keuangan pertama ditunda sampai M4; onboarding M1 tidak membuka
fitur yang belum tersedia. Windows dan Android memakai kontrak fitur yang sama
mulai M2. Bahasa memakai resource localization sejak M1; audit seluruh layar
ID/EN menjadi gate M5.

Status setiap area memakai `direncanakan`, `diimplementasikan`, atau `diverifikasi`.
Baseline seluruh area adalah `direncanakan`. Status implementasi membutuhkan
repository dan commit; status verifikasi membutuhkan hasil test serta platform.
Dokumentasi dan fixture target tidak menjadi bukti bahwa aplikasi sudah berjalan.

### Keputusan yang dikunci

- Activity + Tugas lebih dahulu di Windows; Android masuk saat M2.
- Merge aman per kelompok field; pengguna memilih kelompok yang bertabrakan.
- Record berkonflik hanya dapat dibaca, record lain tetap dapat digunakan.
- Recovery membutuhkan review dan persetujuan, termasuk untuk perubahan yang belum
  pernah diterima server; ekspor diagnostik tidak menjadi satu-satunya jalur recovery.
- Belum ada implementasi atau database legacy yang harus dipertahankan.
- Weekly Review masuk M5, wajib diselesaikan, dan tidak memiliki aksi skip.
- Tidak ada keputusan produk terbuka yang menghalangi M0. Bukti implementasi,
  hasil benchmark, dan tanggal rilis diisi setelah pekerjaan terkait dilakukan.

## 4. Feature Requirements

### 4.1 Daily Activity Log

**User Story:**
Sebagai mahasiswa yang mengelola banyak aktivitas (kuliah, tugas, personal), saya ingin mencatat rencana dan realisasi aktivitas harian saya dalam satu tempat, supaya saya bisa melihat pola produktivitas saya dari waktu ke waktu.

**Functional Requirements:**

- **FR-1.1** Entry activity dapat dibuat secara **manual** (freeform title + kategori) atau **otomatis** dari source event immutable: Pomodoro selesai, TimeboxExecution selesai, atau HabitLog selesai. Pekerjaan Tugas masuk melalui sesi Pomodoro atau Timebox yang terhubung ke tugas tersebut; perubahan status Tugas tidak membuat Activity secara langsung.
- **FR-1.2** Setiap entry merujuk satu ActivityCategory tersinkron. Aplikasi membuat kategori awal Kuliah, Tugas, Personal, Istirahat, Sosial, dan Olahraga. User dapat membuat, mengubah warna/icon, mengganti nama, serta mengarsipkan kategori custom. ActivityCategory yang sudah dipakai histori tidak dapat dihapus.
- **FR-1.3** Activity dapat memiliki waktu spesifik (start-end time) atau tanpa waktu spesifik (all-day/flexible).
- **FR-1.4** User dapat mengatur activity sebagai **recurring** (harian, atau mingguan pada hari tertentu) dengan opsi tanggal berakhir. Sistem menyimpan template recurrence dan occurrence harian secara terpisah; rolling materializer membuat occurrence sekurang-kurangnya 30 hari ke depan atau lebih panjang sesuai reminder terbesar. Perubahan status satu occurrence tidak boleh mengubah occurrence lain.
- **FR-1.5** Setiap activity v1.0 memiliki status: **belum mulai / selesai / dilewati (skipped)**. PomodoroSession dan TimeboxExecution menyimpan state pekerjaan yang sedang berjalan; Activity tidak memiliki tombol atau status mulai.
- **FR-1.6** Tampilan utama mendukung 2 mode: **list harian** dan **timeline** (kalender harian), dengan toggle antar mode. TimeboxExecution dan Activity hasil execution yang sama tampil sebagai satu unit melalui `Activity.source_id`; unit tersebut berubah dari rencana menjadi hasil dan detailnya memperlihatkan planned/actual tanpa kartu ganda.
- **FR-1.7** Timeline view menggunakan **color coding** per kategori.
- **FR-1.8** Sistem memberi warning non-blocking jika activity timed bertumpang tindih dengan activity timed lain atau Timebox pending. Interval memakai `[start,end)` sehingga boundary yang hanya bersentuhan tidak overlap; all-day/flexible dan Activity hasil Timebox yang sama dikecualikan.
- **FR-1.9** User dapat **filter** activity berdasarkan rentang tanggal, lewat navigasi tanggal (prev/next + date picker) di Today View. *(Filter berdasarkan kategori sempat direncanakan, tapi dihapus dari scope v1.0 setelah dicoba — Today View menampilkan semua kategori sekaligus dirasa cukup dan lebih cepat dipakai sehari-hari.)*
- **FR-1.10** User dapat mengatur satu atau lebih **reminder/notifikasi** sebelum activity berjadwal dimulai. Reminder disimpan sebagai offset menit unik dan non-negative dari `start_time`; activity tanpa waktu mulai wajib tidak memiliki reminder. Occurrence recurring menyimpan snapshot reminder agar perubahan template tidak mengubah occurrence lama.
- **FR-1.11** Tersedia **bulk actions**: tandai selesai atau pindahkan ke hari berikutnya untuk Activity manual/non-derived yang eligible pada tanggal aktif. Aplikasi menampilkan jumlah item, meminta konfirmasi untuk perubahan massal, dan menyediakan Undo lokal sebelum sync. Bulk action tidak mengubah recurrence template, deadline Tugas, TimeboxExecution, atau Activity hasil Pomodoro/Timebox/Habit.
- **FR-1.12** User dapat menambahkan **catatan tambahan** (freeform text) pada tiap activity.
- **FR-1.13** Sistem menghitung **daily completion rate** sebagai jumlah Activity aktif berstatus selesai dibagi seluruh Activity aktif pada tanggal tersebut. Semua jenis dan status masuk denominator; tanggal tanpa Activity menghasilkan 0,0%. Hasil dibulatkan satu desimal dengan round-half-up.
- **FR-1.14** Data activity tersimpan sebagai **riwayat/arsip** permanen, dapat diakses kembali untuk melihat histori aktivitas di tanggal-tanggal sebelumnya.

**Integrasi otomatis dari fitur lain:**
- Sesi Pomodoro selesai → otomatis jadi 1 entry activity (judul & durasi mengikuti sesi/tugas terkait)
- Jadwal Timebox → muncul sebagai unit rencana dari TimeboxExecution; saat selesai, Activity hasilnya dilekatkan pada unit yang sama
- Tugas kuliah yang dikerjakan lewat Pomodoro/Timebox → otomatis tercatat sebagai activity terkait tugas tersebut

**Di luar scope v1.0 (masuk Future Scope):**
- Highlight visual khusus Planned vs Actual — di v1.0, field status dianggap cukup
- Perbandingan estimasi vs durasi aktual per activity
- Drag-and-drop reschedule di timeline — di v1.0, reschedule via edit manual
- Link langsung ke pencatatan Transaksi keuangan dari activity — kedua fitur tetap lepas di v1.0

---

### 4.2 Pomodoro Timer

**User Story:**
Sebagai mahasiswa yang sering kehilangan fokus, saya ingin timer pomodoro yang bisa disesuaikan dengan gaya kerja saya dan opsional terkait ke tugas/habit tertentu, supaya saya bisa mengukur seberapa banyak waktu fokus yang saya habiskan.

**Functional Requirements:**

- **FR-2.1** Durasi sesi kerja, istirahat pendek, dan istirahat panjang dapat diatur user (custom), dengan nilai default awal yang bisa diubah.
- **FR-2.2** Long break otomatis ditawarkan setelah N sesi kerja berturut-turut selesai; N dapat diatur user (default misal 4 sesi).
- **FR-2.3** Sesi pomodoro dapat dikaitkan opsional ke Tugas kuliah atau Habit, atau dijalankan sebagai **sesi bebas** tanpa keterkaitan apapun.
- **FR-2.4** Setiap sesi (kerja maupun istirahat) dimulai secara **manual** — tidak ada auto-start otomatis.
- **FR-2.5** Timer tetap berjalan di **background** saat app di-minimize/dipindah, dengan notifikasi persistent menampilkan sisa waktu.
- **FR-2.6** Sistem memutar suara/alarm **berbeda** untuk penanda "mulai istirahat" dan "istirahat selesai/waktunya kerja lagi".
- **FR-2.7** User dapat **pause dan resume** sesi. Pause mengubah status menjadi `paused`, menyimpan `paused_at`, dan menghentikan penambahan waktu aktual. Resume menambahkan durasi pause ke `accumulated_pause_seconds`, mengosongkan `paused_at`, dan mengembalikan status `running`. Relaunch mempertahankan state paused.
- **FR-2.8** User dapat membatalkan sesi fokus atau melewati sesi istirahat. Keduanya menghasilkan status `cancelled` dan tidak dihitung sebagai selesai; konfirmasi wajib untuk pembatalan fokus, sedangkan melewati istirahat tidak memerlukan konfirmasi berat.
- **FR-2.9** Ada **konfirmasi** sebelum cancel sesi, untuk mencegah pembatalan tidak sengaja.
- **FR-2.10** Sistem menampilkan statistik **harian** dari PomodoroSession `jenis=fokus` dan `status=completed`: total `actual_seconds` dan jumlah sesi, dikelompokkan menurut Local date `start_time`. Sesi break, running, paused, dan cancelled tidak masuk total fokus.
- **FR-2.11** Sistem memakai aturan yang sama untuk statistik **mingguan/bulanan** dan mengembalikan batas periode efektif dalam timezone user.
- **FR-2.12** Sesi pomodoro yang selesai otomatis membuat entry baru di Daily Activity Log (integrasi dengan 4.1).
- **FR-2.13** Timer ditampilkan dengan visual **circular progress bar**.
- **FR-2.14** Riwayat sesi tersimpan sejak timer dimulai: waktu mulai/selesai, keterkaitan tepat satu dari tugas/habit/bebas, planned duration, waktu aktual tanpa pause, akumulasi pause, dan status (`running`, `paused`, `completed`, atau `cancelled`). App yang ditutup tidak boleh mengubah sesi menjadi `cancelled` tanpa aksi user.
- **FR-2.15** Tersedia beberapa **preset durasi cepat** (misal 25/50/90 menit) selain opsi custom manual.
- **FR-2.16** Pengaturan suara, durasi, dan interval long break memiliki satu sumber pada Settings global. Tab Pomodoro menyediakan shortcut menuju bagian tersebut dan boleh memberi override durasi untuk satu sesi melalui preset.

**Di luar scope v1.0 (masuk Future Scope):**
- Breakdown statistik per Tugas/Mata Kuliah/Habit — nice-to-have, lebih berguna setelah data histori cukup banyak
- Widget desktop/homescreen menampilkan timer tanpa buka app
- Vibration sebagai alternatif suara alarm di Android

---

### 4.3 Timebox

**User Story:**
Sebagai mahasiswa dengan jadwal kuliah yang berulang tiap minggu, saya ingin membuat template jadwal waktu kerja yang konsisten, sekaligus bisa menambah block khusus untuk kebutuhan mendadak, supaya rencana dan eksekusi harian saya lebih terstruktur.

**Functional Requirements:**

- **FR-3.1** Timebox dapat dibuat sebagai **template mingguan berulang**, berlaku otomatis tiap minggu sampai diubah/dihapus.
- **FR-3.2** Timebox juga dapat dibuat sebagai **block ad-hoc** khusus untuk 1 hari tertentu, tanpa menjadi bagian template permanen.
- **FR-3.3** Tampilan utama berupa **grid mingguan** (Senin-Minggu x jam) untuk keperluan planning.
- **FR-3.4** Block Timebox juga muncul di **timeline harian** yang sama dengan Daily Activity Log, untuk melihat rencana vs eksekusi dalam satu tempat.
- **FR-3.5** Block dapat dikaitkan opsional ke **Tugas kuliah, Habit, atau kategori bebas**.
- **FR-3.6** Block dapat dimulai sebagai aktivitas biasa atau satu sesi Pomodoro. Aksi **Mulai block** mengisi `actual_start_at`; block polos tanpa Pomodoro tetap valid.
- **FR-3.7** Saat waktu block sudah lewat tanpa ada aktivitas tercatat, sistem menampilkan **prompt konfirmasi**: tandai sebagai missed, reschedule, atau "masih berlaku (belum sempat update)". Missed/reschedule disimpan bersama catatan opsional sebagai histori execution, termasuk planned/actual timestamps dan hubungan ke activity yang dihasilkan. "Masih berlaku" menutup prompt tanpa mutation dan execution tetap `pending`; prompt boleh muncul lagi paling cepat pada hari lokal berikutnya. Reschedule membuat destination execution `pending` dan menyimpan relasi dari source execution tanpa mengubah histori source.
- **FR-3.8** User dapat mengedit template mingguan (ubah hari/durasi) tanpa memengaruhi histori atau execution block minggu-minggu sebelumnya.
- **FR-3.9** Sistem memberi warning non-blocking jika dua TimeboxExecution pending atau satu Timebox dan Activity timed overlap menurut aturan interval FR-1.8.
- **FR-3.10** **Color coding** kategori konsisten dengan Daily Activity Log.
- **FR-3.11** User dapat **menduplikasi block** ke hari lain dengan cepat (copy jadwal).
- **FR-3.12** User dapat menonaktifkan seluruh template sampai diaktifkan kembali, atau memilih **Lewati kejadian ini** untuk satu occurrence, misalnya saat minggu libur. Menonaktifkan template menghentikan materialisasi baru; melewati occurrence menghasilkan TimeboxExecution `skipped`, tidak memutus template, tidak membuat Activity, dan tidak dihitung sebagai missed.
- **FR-3.13** User dapat mengatur satu atau lebih **reminder/notifikasi** sebelum block dimulai. Reminder disimpan sebagai offset menit unik dan non-negative dari waktu mulai occurrence; perubahan schedule hanya memengaruhi execution yang belum dimaterialisasi.
- **FR-3.14** Block yang diselesaikan otomatis **generate tepat satu entry** di Daily Activity Log dan menyimpan `activity_id` pada execution (integrasi dengan 4.1).
- **FR-3.15** User dapat menambah block baru langsung dari grid view (**quick-add**, klik atau drag).
- ~~FR-3.16~~ *(Dipindah ke pasca-v1.0 — lihat Section 8. Ini konsisten dengan Section 3, yang mengecualikan Export/Backup data, termasuk .ics, dari scope v1.0.)* Export jadwal mingguan ke format kalender (.ics) agar bisa diimpor ke Google Calendar.

**Di luar scope v1.0 (masuk Future Scope):**
- Reschedule block secara umum di luar alur prompt missed — untuk v1.0 cukup ditangani lewat FR-3.7
- Adherence rate mingguan khusus Timebox — berpotensi tumpang tindih dengan daily completion rate di Activity Log
- Filter grid berdasarkan kategori/tugas
- Auto-suggest block mendekati deadline tugas (smart scheduling)

---

### 4.4 Pencatatan Keuangan

**User Story:**
Sebagai mahasiswa yang mengelola uang dari beberapa sumber (cash, rekening bank, e-wallet), saya ingin mencatat semua transaksi dengan kategori yang relevan dengan kehidupan mahasiswa, supaya saya tahu ke mana uang saya habis tiap bulan.

**Functional Requirements:**

- **FR-4.1** User dapat membuat **multiple akun/dompet** (Cash, Bank, E-wallet, atau custom) dengan saldo awal dan saldo berjalan masing-masing. `saldo_awal` dapat diperbaiki hanya sebelum akun memiliki transaksi retained; setelah itu seluruh koreksi memakai adjustment ledger. `saldo` adalah cache yang tidak dapat diedit langsung.
- **FR-4.2** User dapat membuat, mengedit, dan menghapus **transfer antar akun** (misal tarik tunai dari Bank ke Cash). Create mengurangi saldo asal dan menambah saldo tujuan; update membalik efek lama lalu menerapkan efek baru; delete membalik kedua sisi. Seluruh perubahan berjalan atomik dan transfer tidak dihitung sebagai income/expense.
- **FR-4.3** Kategori expense awal: **Belanja, Hiburan, Makanan, Kendaraan, Pulsa, Rokok, Tagihan**. Kategori income awal: **Uang Saku, Beasiswa, Gaji, Penjualan, Refund**. User dapat membuat kategori custom dan mengarsipkan kategori yang tidak lagi dipakai; histori tetap mempertahankan referensinya.
- **FR-4.4** Setiap transaksi memiliki field **keterangan/catatan bebas**.
- **FR-4.5** Transaksi kas biasa bertipe **income** atau **expense**. Ledger juga memiliki tipe **transfer** yang hanya dibuat lewat alur transfer dan **adjustment** yang hanya dibuat lewat koreksi saldo.
- **FR-4.6** Semua nominal ditampilkan dalam format **Rupiah (Rp)** dengan pemisah ribuan yang mudah dibaca.
- **FR-4.7** Input jumlah transaksi menggunakan **numpad khusus angka** untuk mempercepat entry.
- **FR-4.8** Tanggal transaksi dapat **diedit** (tidak terkunci ke hari ini), untuk mencatat transaksi yang telat diinput.
- **FR-4.9** User dapat **memfilter** transaksi berdasarkan akun, kategori, rentang tanggal, dan tipe, termasuk transfer serta adjustment pada riwayat ledger.
- **FR-4.10** Halaman utama menampilkan **summary saldo total** dari akun aktif. Saldo akun adalah saldo awal ditambah income dan adjustment increase, dikurangi expense, transfer keluar, serta adjustment decrease, lalu ditambah transfer masuk dari seluruh transaksi aktif.
- **FR-4.11** Tersedia **chart pie** pengeluaran aktif per kategori untuk rentang tanggal inklusif; transfer tidak dihitung. Default adalah bulan kalender berjalan.
- **FR-4.12** Tersedia **chart trend** pemasukan vs pengeluaran aktif per bulan (line/bar chart); transfer tidak dihitung dan bulan kosong tetap ditampilkan. Default adalah 12 bulan kalender termasuk bulan berjalan.
- **FR-4.13** User dapat **mengedit dan menghapus** transaksi income/expense serta transfer yang sudah diinput. Adjustment tidak diedit sebagai transaksi biasa; koreksi berikutnya membuat adjustment baru agar audit ledger tetap dapat dijelaskan.
- **FR-4.14** Riwayat transaksi ditampilkan lengkap, dengan **scroll per bulan**.
- **FR-4.15** Ada **konfirmasi** sebelum menghapus transaksi.
- **FR-4.16** User dapat mengarsipkan akun tanpa menghapus histori. Akun arsip tidak muncul pada pilihan transaksi baru dan tidak masuk summary saldo aktif, tetapi tetap tampil pada transaksi lama. Aplikasi memperingatkan user jika saldo akun belum nol.
- **FR-4.17** User dapat mengoreksi saldo. Selama akun belum memiliki transaksi, user dapat memperbaiki `saldo_awal`. Setelah ledger terbentuk, command koreksi menerima saldo target dan membuat transaksi `adjustment` sebesar selisihnya. Adjustment tidak masuk agregasi income/expense atau chart.

**Di luar scope v1.0 (masuk Future Scope):**
- Attach foto struk/bukti transaksi
- Search transaksi berdasarkan keterangan (filter dianggap cukup untuk v1.0)
- Link opsional transaksi ke Tugas kuliah — konsisten dengan keputusan di Daily Activity Log agar kedua fitur tetap lepas di v1.0
- Quick-add transaksi dengan minim step
- Warning saldo akun minus setelah expense

---

### 4.5 Habit Tracker

**User Story:**
Sebagai mahasiswa yang ingin membangun kebiasaan baik secara konsisten, saya ingin mencatat habit dengan target hari yang fleksibel dan melihat progres saya lewat visualisasi streak, supaya saya termotivasi untuk tetap konsisten.

**Functional Requirements:**

- **FR-5.1** User dapat mengatur **target hari spesifik** per habit (misal Senin, Rabu, Jumat) saat membuat habit. Target disimpan dalam HabitSchedule bertanggal efektif agar aturan historis dapat direkonstruksi.
- **FR-5.2** Habit List membagi data menjadi **Hari ini** untuk target aktif pada tanggal tersebut dan **Habit lainnya** untuk habit aktif yang bukan target hari itu. Checklist hanya tersedia pada bagian Hari ini.
- **FR-5.3** Sistem menghitung **streak counter** sebagai jumlah target day berstatus `done` sejak target day terakhir yang missed. Non-target day dan periode paused diabaikan; skip valid tidak menambah dan tidak memutus; target day lampau tanpa log memutus. Target day hari ini belum memutus sampai akhir hari dalam timezone user.
- **FR-5.4** Tersedia **heatmap kalender** (ala GitHub contribution graph) untuk visualisasi konsistensi dari waktu ke waktu.
- **FR-5.5** Semua habit ditampilkan dalam **satu list flat** tanpa kategori/grouping.
- **FR-5.6** Sistem menyimpan **longest streak record** yang pernah dicapai per habit.
- **FR-5.7** User dapat menandai target day sebagai **skip/izin** tanpa memutus streak. Batas izin dapat dikonfigurasi per minggu kalender Senin–Minggu dalam timezone user dan disimpan pada HabitSchedule yang aktif untuk tanggal tersebut.
- **FR-5.8** User dapat **menjeda** habit mulai hari ini atau tanggal masa depan tanpa menghapus histori. Jeda/lanjutkan membuat versi HabitSchedule `paused`/`active`; periode jeda tidak dinilai dan resume tidak mengisi log secara retroaktif. UI memakai istilah Jeda, bukan Archive.
- **FR-5.9** User dapat **mengedit target hari atau batas izin** habit yang sudah berjalan dengan tanggal efektif hari ini atau masa depan. Sistem membuat HabitSchedule baru dan menyesuaikan rentang versi yang bersebelahan secara atomik; histori dan perhitungan streak sebelum tanggal efektif tidak berubah.
- **FR-5.10** User dapat **menghapus** habit dengan konfirmasi terlebih dahulu.
- **FR-5.11** User dapat **mengurutkan ulang (reorder)** habit dalam list sesuai preferensi.
- **FR-5.12** User dapat menambahkan **catatan opsional** saat menandai habit selesai pada hari tertentu.
- **FR-5.13** Saat habit ditandai selesai, sistem otomatis membuat **entry di Daily Activity Log** (integrasi dengan 4.1).
- **FR-5.14** Setiap habit dapat diberi **warna/icon custom** untuk identifikasi visual.
- **FR-5.15** Koreksi HabitLog menjaga Activity turunannya konsisten. Perubahan `done` menjadi `skip`/`missed` men-tombstone Activity terkait; perubahan kembali menjadi `done` membuat atau me-restore Activity deterministik yang sama. Perubahan catatan pada log `done` memperbarui catatan Activity tanpa membuat record baru.

**Di luar scope v1.0 (masuk Future Scope):**
- Link otomatis dari sesi Pomodoro yang selesai untuk menandai habit terkait sebagai done
- Completion rate keseluruhan sebagai metrik agregat terpisah — v1.0 mengandalkan streak & heatmap saja
- Quick-check dari home screen/widget tanpa buka app
- Notifikasi motivasi saat streak record baru tercapai

---

### 4.6 Deadline Tugas Kuliah

**User Story:**
Sebagai mahasiswa dengan banyak tugas dari berbagai mata kuliah, saya ingin mencatat semua deadline dengan reminder yang bisa disesuaikan, supaya saya tidak kelewat tenggat dan bisa melihat beban kerja saya tiap minggu.

**Functional Requirements:**

- **FR-6.1** User dapat membuat tugas baru dengan field: **judul, mata kuliah** (pilih dari list atau ketik baru), **deskripsi, deadline**, dan **estimasi waktu pengerjaan**.
- **FR-6.2** User memilih **prioritas** tugas secara manual (Low/Medium/High) saat membuat tugas.
- **FR-6.3** Setiap tugas memiliki status: **belum dikerjakan / progress / selesai**.
- **FR-6.4** Sistem menyediakan reminder bertingkat yang dapat dikustomisasi per tugas. Reminder memakai bentuk bertipe: `calendar_day` berisi `days_before` dan Local time, atau `relative_minutes` berisi menit sebelum deadline. Default v1.0 adalah H-7, H-3, dan H-1 pukul 09.00 timezone user serta 120 menit sebelum deadline. Trigger yang sudah lewat saat tugas dibuat tidak ditembakkan ulang.
- **FR-6.5** User dapat mengelola **list Mata Kuliah** (nama, dosen, sks) yang dapat dipilih ulang saat membuat tugas baru.
- **FR-6.6** Deadline tugas ditampilkan sebagai **overlay/badge** pada timeline harian & grid mingguan di tab Home (yang sudah menyatukan Activity + Timebox — lihat FR-1.6, FR-3.4), bukan sebagai layar kalender gabungan terpisah. *(Disederhanakan dari rencana awal "kalender view gabungan" berdiri sendiri — menghindari layar ke-3 yang tumpang tindih fungsi dengan Home.)*
- **FR-6.7** Tab Tugas menampilkan semua tugas aktif sebagai **kartu yang dapat diklik**. Daftar memakai urutan deadline terdekat sebagai default; user dapat mengurutkan berdasarkan deadline, prioritas, atau mata kuliah.
- **FR-6.8** Bagian bawah setiap kartu tugas menampilkan **deadline** tugas, countdown visual (misal "3 hari lagi"), dan **nama mata kuliah**. Tugas tanpa mata kuliah menampilkan label "Tanpa mata kuliah".
- **FR-6.9** Tugas yang **overdue** (deadline lewat, belum selesai) ditandai dengan **highlight warna berbeda** pada kartu dan tetap menampilkan jumlah hari keterlambatan.
- **FR-6.10** Kartu tugas menampilkan badge status (**belum dikerjakan**, **progress**, atau **selesai**) dan prioritas. Tampilan utama tidak memakai kanban; user membuka detail dari kartu yang dipilih.
- **FR-6.11** User dapat **mengedit dan menghapus** tugas, dengan konfirmasi sebelum menghapus.
- ~~FR-6.12~~ *(Dipindah ke pasca-v1.0, lihat Section 8.)* Weekly workload view menghitung jumlah tugas dan estimasi waktu per minggu. Public API v1.0 tidak mengekspos endpoint workload; `schema.md` menyimpan formula future agar implementasi berikutnya memakai semantik yang tetap.
- **FR-6.13** User memperbarui **status tugas secara manual**. Saat status menjadi `selesai`, sistem mengisi `completed_at`; membuka kembali tugas mengosongkan `completed_at`. Checklist pertama yang selesai boleh menawarkan status `progress`, dan seluruh checklist selesai boleh menawarkan status `selesai`, tetapi aplikasi tidak mengubah status tanpa konfirmasi user.
- **FR-6.14** Setiap tugas dapat memiliki **sub-tugas/checklist internal** (misal tugas besar dipecah jadi beberapa item checklist).
- **FR-6.15** Setiap **mata kuliah** dapat memiliki **CourseNote**. User memilih tanggal catatan lalu menulis teks bebas untuk merekam materi, arahan dosen, atau hal penting saat perkuliahan berlangsung. CourseNote dibuka dari Mata Kuliah Detail dan dikelompokkan berdasarkan tanggal; CourseNote tidak menjadi bagian dari Tugas dan tidak memiliki `tugas_id`.
- **FR-6.16** Sistem mengirim **notifikasi khusus** untuk tugas overdue yang belum ditandai selesai.
- **FR-6.17** Tugas overdue yang belum selesai tetap berada di daftar aktif tanpa batas. Tugas selesai masuk **Riwayat Tugas** pada pukul 00.00, tujuh hari setelah Local date `completed_at`. User juga dapat mengarsipkan atau membuka kembali tugas secara manual; `archived_at` menentukan tanggal masuk riwayat manual. Pemindahan hanya mengubah tampilan dan tidak menghapus checklist. CourseNote tetap mengikuti Mata Kuliah.
- **FR-6.18** Setiap mata kuliah memiliki **warna/tag tersendiri** untuk identifikasi visual di kalender.
- **FR-6.19** Saat user mengklik kartu tugas, aplikasi membuka **Detail Tugas** yang menampilkan informasi tugas, checklist, status, countdown, dan tautan menuju mata kuliah terkait. Detail Tugas tidak menampilkan atau menyimpan CourseNote.
- **FR-6.20** Riwayat Tugas memakai rentang **satu minggu**, dapat dinavigasi ke minggu sebelumnya/berikutnya, dan mengelompokkan tugas berdasarkan `history_date`. Untuk arsip otomatis, tanggal tersebut adalah Local date `completed_at + 7 hari`; untuk arsip manual, tanggal tersebut adalah Local date `archived_at`.

> **Catatan:** Keterkaitan tugas dengan sesi Pomodoro/Timebox sudah tercakup di **FR-2.3** dan **FR-3.5** (dihubungkan manual dari sisi Pomodoro/Timebox), sehingga tidak diulang di sini.

**Di luar scope v1.0 (masuk Future Scope):**
- Duplikasi tugas (misal tugas mingguan berpola sama)
- Semester/nilai (IPK) tracking — di luar scope sejak awal

### 4.7 Pengaturan

- **FR-7.1** Settings dapat mengubah bahasa aplikasi antara Bahasa Indonesia (`id`) dan Inggris (`en`).
- **FR-7.2** User dapat memilih IANA timezone. Perubahan timezone tidak menulis ulang Local date atau Instant yang tersimpan dan tidak menggeser occurrence/execution yang sudah dimaterialisasi. Sistem menghitung ulang batas "hari ini", streak, dan statistik; menjadwalkan ulang notifikasi existing pada Instant trigger yang sama; serta memakai timezone baru hanya untuk occurrence setelah watermark.
- **FR-7.3** User dapat mengatur durasi fokus 1–180 menit, short break 1–60 menit, long break 1–120 menit, dan interval long break 2–12 sesi fokus.
- **FR-7.4** User dapat memilih mode alarm `sound` atau `muted` serta mengaktifkan/menonaktifkan preferensi notifikasi.
- **FR-7.5** Bahasa, timezone, konfigurasi Pomodoro, alarm mode, dan preferensi notifikasi disimpan pada satu UserSettings ber-ID deterministik dan disinkronkan lintas device. Entity ini tidak dapat dihapus; sync memakai full upsert, sedangkan REST Settings menerima partial update dan mengembalikan record penuh.
- **FR-7.6** Izin notifikasi OS, volume per-device, tema tampilan, notification handle, serta cursor/status sync disimpan lokal sebagai DeviceSettings dan tidak ditimpa snapshot. State sesi Pomodoro tetap berada pada PomodoroSession, bukan diduplikasi sebagai setting.
- **FR-7.7** API key hanya berada di platform secure storage dan tidak pernah tampil pada Settings, database domain, payload sync, log, atau export.
- **FR-7.8** `notifications_enabled=true` hanya menyatakan preferensi. Jika izin OS ditolak, aplikasi menampilkan status dan shortcut ke system settings tanpa mengubah preferensi user.
- **FR-7.9** Perubahan durasi Pomodoro berlaku mulai fase/session berikutnya dan tidak mengubah `durasi_menit` session yang sedang `running`.
- **FR-7.10** Saat user menonaktifkan notifikasi, setiap device membatalkan trigger lokal yang belum terkirim tanpa menghapus reminder domain. Saat user mengaktifkannya kembali, device menjadwalkan trigger masa depan jika izin OS `granted`.
- **FR-7.11** Mode alarm `muted` menonaktifkan suara, sementara visual notification tetap dapat tampil. Device menerapkan volume lokal jika platform mendukungnya.
- **FR-7.12** Settings memiliki **Pusat Sync** yang menampilkan status, waktu sukses terakhir, jumlah mutation menunggu, konflik yang belum dilihat, recovery/snapshot state, dan trigger manual. UI menerjemahkan error protokol menjadi instruksi yang dapat dipahami user dan menyediakan daftar konflik/recovery tanpa memperlihatkan secret.
- **FR-7.13** First-run onboarding meminta bahasa dan timezone, mendaftarkan device, menjelaskan penyimpanan lokal/sync, serta menawarkan pembuatan akun keuangan pertama. Aplikasi meminta izin notifikasi saat user pertama kali mengaktifkan reminder atau Pomodoro, bukan saat splash. Splash hanya membuka database, menjalankan migration/recovery timer, dan tidak menunggu VPS.
- **FR-7.14** Settings menyimpan waktu Weekly Review dalam Local time. Hari review tetap Minggu pada v1.0 dan default waktunya `09:00:00`. Perubahan waktu menjadwalkan ulang trigger masa depan tanpa mengubah review atau snapshot yang sudah ada.
- **FR-7.15** User dapat memilih tema tampilan `system`, `light`, atau `dark`, dengan default `system` yang mengikuti tema OS. Tema adalah preferensi tampilan **per-device** yang disimpan pada DeviceSettings lokal (lihat FR-7.6); ia tidak disinkronkan, tidak masuk UserSettings, payload sync, atau export, sehingga tiap device dapat berbeda (misal ponsel gelap, laptop terang). Perubahan tema hanya memengaruhi presentasi dan tidak mengubah data domain, status, atau perhitungan apa pun.

### 4.8 Weekly Review

**User Story:**
Sebagai mahasiswa yang ingin belajar dari pelaksanaan minggu berjalan, saya ingin
menulis evaluasi dan menyusun rencana minggu depan dalam satu sesi, supaya rencana
baru berangkat dari pekerjaan yang selesai, tertunda, atau terlewat.

**Functional Requirements:**

- **FR-8.1** Satu WeeklyReview mewakili minggu kalender Senin–Minggu dalam `UserSettings.timezone`. ID memakai UUIDv5 dari user dan tanggal Senin `week_start`; satu user hanya memiliki satu review aktif per minggu.
- **FR-8.2** Aplikasi membuat atau membuka review minggu berjalan pada Minggu pukul waktu review, default `09:00:00`, dan menjadwalkan reminder lokal jika notifikasi diizinkan. Review dapat dibuka manual sebelum trigger, tetapi gate planning baru aktif saat trigger tercapai.
- **FR-8.3** Review menyediakan dua field teks wajib: **Evaluasi minggu ini** dan **Fokus minggu depan**. Keduanya berupa jurnal bebas tanpa pertanyaan refleksi wajib.
- **FR-8.4** Selama review masih `draft`, ringkasan produktivitas dihitung sampai waktu baca. Command complete membekukan ringkasan dan `summary_cutoff_at` dalam transaction yang sama. Edit teks setelah completion tidak menghitung ulang snapshot.
- **FR-8.5** Ringkasan memuat Activity planned/selesai/dilewati/belum selesai dan completion rate; Tugas selesai/aktif/overdue; jumlah serta durasi Pomodoro fokus completed; Timebox completed/missed/skipped/pending; dan Habit target done/missed/excused. Keuangan tidak masuk ringkasan v1.0.
- **FR-8.6** Aplikasi menampilkan Tugas aktif/overdue, Activity belum selesai/dilewati, serta Timebox pending/missed sebagai kandidat. Kandidat hanya membaca source record. User dapat membiarkannya, menanganinya di modul asal, atau membuat WeeklyPlanDraft; sistem tidak memindahkan pekerjaan otomatis.
- **FR-8.7** WeeklyPlanDraft menargetkan tepat satu dari `tugas`, `activity`, atau `timebox`, memiliki judul, catatan opsional, dan tanggal target dalam Senin–Minggu berikutnya. Draft dapat berasal dari kandidat atau dibuat bebas.
- **FR-8.8** User mengaktifkan draft satu per satu. Aplikasi membuka form modul tujuan untuk melengkapi field wajib. Penyimpanan membuat target dan menandai draft `promoted` dalam satu transaction lokal; UUIDv5 hasil promosi mencegah duplikasi saat retry.
- **FR-8.9** Sejak Minggu pada waktu review sampai WeeklyReview completed, aplikasi menahan create atau perubahan planning yang memengaruhi minggu berikutnya: jadwal Activity, deadline Tugas, Timebox, dan recurrence yang mematerialisasi occurrence pada periode itu. Item yang sudah direncanakan sebelum gate tetap ada.
- **FR-8.10** Gate tetap mengizinkan pencatatan hasil, completion/cancel/skip, perubahan aktual, edit non-planning, serta seluruh operasi di luar minggu berikutnya. Penyelesaian review lokal membuka gate tanpa menunggu VPS.
- **FR-8.11** Review tidak dapat dilewati atau dihapus. Complete ditolak jika salah satu teks wajib kosong atau draft aktif memiliki target/tanggal yang tidak valid. Draft tidak wajib dipromosikan sebelum review selesai.
- **FR-8.12** Fresh install di tengah minggu tidak membuat review parsial. Review wajib pertama dimulai pada trigger Minggu berikutnya.
- **FR-8.13** Review completed tetap dapat diedit pada dua field teks. Periode, cutoff, ringkasan snapshot, dan status completed tidak dapat dibuka kembali atau diganti.
- **FR-8.14** WeeklyPlanDraft `promoted` menyimpan jenis dan ID target. Draft tersebut tidak dapat dipromosikan lagi; draft yang tidak dibutuhkan dapat berstatus `discarded`.

---

## 5. Non-Functional Requirements

- **NFR-1 Platform:** Aplikasi berjalan native di **Windows 10+** dan **Android 8+ (API 26+)**, menggunakan Flutter dengan satu codebase; Windows dimulai M1 dan Android M2.
- **NFR-2 Offline-first:** Semua fitur inti (Daily Activity, Pomodoro, Timebox, Keuangan, Habit Tracker, Deadline Tugas) dan Weekly Review dapat digunakan **penuh tanpa koneksi internet**. Data lokal (SQLite di device) adalah **source of truth**; completion review lokal membuka gate tanpa menunggu server.
- **NFR-3 Sync:** Saat device online, perubahan data disinkronkan **otomatis** ke backend VPS melalui polling saat foreground, interval lima menit selama app aktif, dan trigger manual. Rejection deterministik disimpan untuk replay; timeout/deadlock/5xx di-rollback dan di-retry dengan change ID sama memakai exponential backoff plus jitter. Snapshot start memakai Idempotency-Key yang sama saat retry agar response yang hilang tidak membuat epoch/session baru berulang kali.
- **NFR-4 Conflict resolution:** Server membandingkan base kanonik, payload lokal, dan record server terbaru. Perubahan pada kelompok field berbeda digabung jika hasilnya valid; perubahan berbeda pada kelompok yang sama meminta review pengguna. Pengguna memilih nilai per kelompok field, dan record terkait hanya dapat dibaca sampai review selesai. Server tidak menerapkan sebagian mutation yang berkonflik. Jam device tidak menentukan pemenang. Aturan tombstone, immutable history, dan command domain tetap berlaku.
- **NFR-5 Keamanan data in-transit:** Semua komunikasi antara app dan VPS dienkripsi menggunakan **HTTPS/TLS**.
- **NFR-6 Autentikasi minimal:** Meski single-user, tetap ada bearer API key antara app dan VPS. Revocation device bukan pencabutan credential bersama; dugaan kebocoran mewajibkan rotasi key, reprovision device tepercaya, revoke device lama, dan epoch/snapshot baru.
- **NFR-7 Localization:** Aplikasi mendukung **Bahasa Indonesia dan Inggris**, dengan opsi switch bahasa dari settings.
- **NFR-8 Performa:** Pada dataset `PERF-10K-v1` dan perangkat referensi di `OPERATIONS.md`, cold-start p95 maksimal 2.000 ms dan warm-start p95 maksimal 750 ms. Tim mengukur 30 cold start serta 50 warm start per platform pada release build tanpa debugger.
- **NFR-9 Availability:** Fitur-fitur utama **tidak boleh bergantung pada VPS** untuk berfungsi — VPS down tidak boleh membuat app tidak bisa dipakai sama sekali (konsisten dengan NFR-2).
- **NFR-10 Data retention:** VPS menyimpan replica off-device, change log, dan tombstone minimal 180 hari. Tombstone hanya dibersihkan setelah seluruh device aktif mengakui revision. Device tidak aktif 180 hari wajib full snapshot dengan epoch baru. Snapshot disimpan sebagai item maksimal 256 KiB, dipaginasi maksimal 500 item/2 MiB, dan dibersihkan satu jam setelah selesai/kedaluwarsa. Replica sync bukan pengganti point-in-time backup.
- **NFR-11 Backup dan disaster recovery:** Karena offline-first menjadikan setiap device salinan penuh, server disesuaikan sebagai relay plus backup sekunder. Operations owner menjaga PostgreSQL RPO maksimal 24 jam lewat logical backup harian off-host dan verifikasi restore otomatis, dengan full restore drill kuartalan; pemulihan layanan best-effort dan tidak memblokir pengguna karena device tetap jalan offline. PITR menit-granular (WAL archive plus physical base backup) opsional untuk memperkecil tail loss. Client membuat dan memverifikasi backup SQLite sebelum setiap migration lokal sebagai perlindungan utama salinan primer. `OPERATIONS.md` menetapkan retensi dan prosedur restore.
- **NFR-12 Latency sync:** Pada network profile referensi, incremental sync 100 local dan 100 remote change memiliki p95 maksimal 5 detik; batch 500 item mendekati 2 MiB maksimal 15 detik; snapshot dataset `PERF-10K-v1` maksimal 120 detik.
- **NFR-13 Recovery timer:** Setelah process restart atau sleep/resume, sisa waktu Pomodoro berbeda maksimal satu detik dari Instant tersimpan dan UI memperbaiki state maksimal 500 ms setelah frame pertama. Runtime memakai monotonic clock selama process hidup.

---

## 6. Technical Overview

**Tech Stack:**

| Layer | Tools |
|---|---|
| UI Framework | Flutter (stable channel) |
| State Management | **Riverpod** |
| Local Database | Drift (SQLite) — source of truth offline |
| Backend API | **Node.js + Express** (REST API di VPS) |
| Backend Database | PostgreSQL di VPS |
| Charts | fl_chart |
| Kalender | table_calendar |
| Notifikasi lokal | flutter_local_notifications |
| Background service | workmanager (Android) + custom service (Windows), untuk timer & notifikasi tetap jalan |
| Localization | flutter_localizations + intl (ID/EN) |
| Export PDF/CSV *(pasca-v1.0)* | pdf + csv package |

**Arsitektur Singkat:**

```
[Flutter App] ──local read/write──> [SQLite/Drift] (source of truth)
      │
      └──sync module (saat online)──> [REST API di VPS] ──> [PostgreSQL]
                                              ▲
                                              │
                              [Flutter App di device lain] (sync 2 arah)
```

**Referensi Skema Database:**

Target skema v1.0 tersedia di **`schema.md`** (32 entity/table v1.0 serta 2 entity future scope, termasuk WeeklyReview, WeeklyPlanDraft, ActivityCategory, UserSettings, local DeviceSettings dan state sync lokal, versioned HabitSchedule, durable idempotency, normalized snapshot item, tombstone, dan revision server). Belum ada implementasi Prisma, Drift, atau migration. Pembuatan database baru mengikuti schema awal; migrasi legacy hanya berlaku jika kelak ada sumber data legacy yang terverifikasi.

> ⚠️ **Perubahan penting dari diskusi ERD awal** (detail lengkap ada di `schema.md`):
> - 🆕 Entity **Activity** ditambahkan — sebelumnya *tidak ada* entity untuk menyimpan data Daily Activity Log, padahal ini fitur pertama yang kita detailkan (4.1).
> - 🆕 Entity **Akun** (Wallet) ditambahkan untuk mendukung multi-akun di fitur Keuangan (FR-4.1).
> - ✏️ **Transaksi** mendapat `akun_id` dan `akun_tujuan_id` untuk transfer antar akun (FR-4.2).
> - ✏️ **TimeboxSchedule** mendapat `habit_id` (sebelumnya cuma `tugas_id`, padahal FR-3.5 juga menyebut Habit).
> - ✏️ **Habit** dan **HabitLog** disesuaikan untuk target hari custom (FR-5.1) dan status skip/missed (FR-5.7).
> - 🆕 **HabitSchedule** menyimpan target hari dan batas izin sebagai versi bertanggal efektif sehingga streak historis tidak berubah setelah edit.
> - Semua entity yang ikut sync mendapat metadata audit, soft-delete (`is_deleted`), dan `server_revision`; pull memakai change log dan opaque cursor (NFR-4).
> - 🆕 `SyncDevice`, `ProcessedChange`, dan `SyncSnapshot` membuat device epoch, durable replay protection, acknowledgement, serta full snapshot dapat dijalankan secara deterministik.

**Keputusan teknis v1.0:**
- Sync memakai REST polling melalui registrasi device, `POST /sync/push`, `GET /sync/pull`, dan `POST /sync/ack`, dipicu saat foreground, setiap lima menit selama app aktif, dan lewat trigger manual. Cursor expired dipulihkan melalui snapshot session yang memiliki epoch dan high watermark.
- Server memakai PostgreSQL pada VPS entry-level.
- Auth memakai bearer API key statis yang disimpan di secure storage. Implementasi v1.0 tidak mengklaim validasi JWT; revoke device tidak menggantikan rotasi key saat credential bocor.
- Semua instant dikirim sebagai RFC 3339 UTC. Tanggal kalender memakai `YYYY-MM-DD` dan dihitung dalam timezone user yang dikonfigurasi, default `Asia/Jakarta`.

---

## 7. Screen List & Navigation Map

**Pola Navigasi Utama:**

Bottom Navigation Bar (Android) / Navigation Rail (Windows, layar lebih lebar) dengan **5 tab utama**. Daily Activity Log dan Timebox digabung dalam satu tab **"Home"** karena keduanya memang dirancang saling terhubung di layar yang sama (lihat FR-1.6 dan FR-3.4 — timeline harian dan grid mingguan menampilkan data yang saling terkait).

```
Bottom Nav / Nav Rail:
[ Home ]   [ Tugas ]   [ Pomodoro ]   [ Keuangan ]   [ Habit ]
```

- **Settings** diakses lewat ikon di app bar (bukan bagian bottom nav), bisa dibuka dari layar manapun.
- Form tambah/edit data (activity, transaksi, tugas, habit, dan resource lain) dibuka sebagai **modal dialog**, bukan halaman penuh.
- Detail screen (Tugas Detail, Habit Detail) di-push sebagai route baru.

---

**1. Home** *(Daily Activity Log + Timebox)*
- Today View — list + timeline harian, toggle antar mode (**default landing screen** aplikasi)
- Weekly Grid View — grid mingguan Timebox (Senin-Minggu x jam)
- Deadline tugas ditampilkan sebagai overlay/badge di Today View & Weekly Grid (FR-6.6) — bukan layar kalender terpisah
- Timebox dan Activity hasil execution yang sama tampil sebagai satu unit plan/actual
- Activity/Block Detail & Edit — modal, buat/edit entry manual, pilih cakupan satu occurrence atau jadwal berikutnya
- Missed Block Review — daftar terkelompok untuk missed / reschedule / putuskan nanti; satu occurrence juga dapat dilewati tanpa menonaktifkan template
- Activity Category Manage — kelola nama, warna, icon, dan arsip kategori Activity/Timebox
- Next Deadline (panel pendamping) — tenggat mendatang terdekat beserta tugas overdue yang tetap aktif; menyajikan data FR-6.6, FR-6.8–FR-6.10, dan FR-6.17 tanpa menambah scope Tugas
- Habits (panel pendamping) — target habit pada tanggal aktif dengan checklist cepat hari ini dan indikator streak; memakai sumber Habit normatif yang sama dengan tab Habit (FR-5.2, FR-5.3, FR-5.13)
- Weekly Review Shortcut — membuka Weekly Review dari Home (FR-8.2)

> Panel Next Deadline dan Habits ditambahkan atas permintaan eksplisit pengguna sebagai pendamping Today View. Keduanya menyajikan data fitur lain yang sudah ada di FR, bukan scope baru; widget homescreen OS tetap Future Scope.

**2. Tugas** *(Deadline Tugas Kuliah)*
- Tugas List — seluruh tugas aktif sebagai kartu yang dapat diklik; footer kartu berisi deadline terdekat, countdown, dan mata kuliah
- Tugas Detail — informasi tugas, sub-checklist, status, countdown, dan tautan ke mata kuliah terkait; tidak memuat catatan
- Riwayat Tugas — rentang tujuh hari yang dapat dinavigasi per minggu; tugas selesai masuk otomatis setelah tujuh hari dan tugas dapat diarsipkan manual
- Tugas Add/Edit Form — modal
- Mata Kuliah Manage — CRUD mata kuliah (nama, dosen, sks, warna)
- Mata Kuliah Detail — informasi mata kuliah, tugas aktif terkait, dan CourseNote yang dikelompokkan berdasarkan tanggal
- CourseNote Add/Edit — catatan perkuliahan bertanggal yang selalu berada di bawah mata kuliah, bukan tugas

**3. Pomodoro**
- Timer Screen — circular progress, start/pause/skip (layar utama tab ini)
- Session Link Picker — modal, pilih Tugas/Habit/sesi bebas sebelum mulai
- Pomodoro Stats — statistik harian/mingguan/bulanan, riwayat sesi
- Timer Settings Shortcut — membuka bagian Timer & Alarm pada Settings global; preset tetap tersedia sebagai override satu sesi

**4. Keuangan**
- Keuangan Home — summary saldo total, transaksi terbaru
- Transaksi List — filter akun/kategori/tanggal/tipe
- Transaksi Add/Edit Form — modal, numpad
- Akun/Wallet Manage — create/edit/archive akun dan koreksi saldo
- Transfer Antar Akun — modal
- Chart & Insight — pie kategori, trend income vs expense
- Category Keuangan Manage — create/edit/archive kategori income/expense

**5. Habit**
- Habit List — bagian Hari ini dan Habit lainnya, checklist harian, sisa izin, serta indikator streak
- Habit Detail — heatmap kalender, longest streak, catatan per hari
- Habit Add/Edit Form — modal, target hari custom, warna/icon

**Global:**
- Splash Screen — membuka database, menjalankan migration (dengan backup terverifikasi bila ada data nyata) dan recovery timer; tidak menunggu VPS lalu mengarah ke Onboarding (first run) atau Today
- First-run Onboarding — bahasa, timezone, registrasi device, penjelasan local/sync, dan akun keuangan pertama
- Settings — bahasa ID/EN, IANA timezone, durasi Pomodoro, alarm/notifikasi,
  izin notifikasi device, tema tampilan per-device (FR-7.15), waktu Weekly Review
  (FR-7.14), pintu ke Pusat Sync, dan tentang app. API key tidak ditampilkan; jika
  izin OS ditolak, layar hanya menawarkan pintasan ke system settings.
- Pusat Sync — status, pending mutation, konflik, recovery/snapshot, dan manual trigger
  - Review Konflik — daftar dan detail record berkonflik; pilihan base/lokal/server per kelompok field, dengan record ditahan sampai resolusi (FR-7.12, NFR-4)
  - Recovery/Snapshot — alur salinan, snapshot, dan persetujuan replay kandidat berdampak saldo setelah generation mismatch/PITR/retention (FR-7.12, NFR-3)
- Weekly Review — ringkasan minggu berjalan, dua jurnal bebas, kandidat pekerjaan tersisa, draft plan, dan aktivasi draft satu per satu; dapat dibuka dari Home atau reminder

**Catatan implementasi:**
- Total ±25 screen/modal — bukan angka final, bisa berkembang saat development, tapi cukup jadi kerangka awal routing di Flutter (**go_router** direkomendasikan untuk nested navigation bottom nav + modal).
- Pola detail-screen vs modal-form dibuat konsisten di semua fitur biar UX predictable dan gampang di-generate ulang lewat vibe coding.

---

## 8. Future Scope (pasca-v1.0)

Berikut fitur dan requirement yang sengaja di-defer dari MVP v1.0, dikelompokkan berdasarkan asalnya.

**Fitur baru (belum ada sama sekali di v1.0):**
- Quick Capture / Inbox — tempat catat cepat ide/todo/transaksi tanpa harus langsung dikategorikan
- Export/backup mandiri oleh user — export ke CSV/PDF untuk laporan dan .ics
  untuk jadwal. Item ini tidak menunda backup database operasional.
- Budget/limit per kategori keuangan dengan alert
- Monthly Review otomatis dan dashboard lintas-periode; Weekly Review v1.0 hanya menyimpan snapshot produktivitas inti dan tidak memasukkan keuangan

**Daily Activity Log (4.1):**
- Highlight visual khusus Planned vs Actual
- Perbandingan estimasi vs durasi aktual per activity
- Drag-and-drop reschedule di timeline
- Link langsung ke pencatatan Transaksi keuangan

**Pomodoro Timer (4.2):**
- Breakdown statistik per Tugas/Mata Kuliah/Habit
- Widget desktop/homescreen
- Vibration sebagai alternatif suara alarm (Android)

**Timebox (4.3):**
- Reschedule block secara umum di luar alur prompt missed
- Adherence rate mingguan khusus Timebox
- Filter grid berdasarkan kategori/tugas
- Auto-suggest block mendekati deadline tugas
- Export jadwal mingguan ke .ics (FR-3.16) — dipindah dari v1.0, konsisten dengan Section 3 yang sudah mengecualikan export/backup dari scope v1.0

**Pencatatan Keuangan (4.4):**
- Attach foto struk/bukti transaksi
- Search transaksi berdasarkan keterangan
- Link opsional transaksi ke Tugas kuliah
- Quick-add transaksi dengan minim step
- Warning saldo akun minus setelah expense

**Habit Tracker (4.5):**
- Reminder notifikasi per habit
- Link otomatis dari sesi Pomodoro yang selesai untuk menandai habit
- Completion rate keseluruhan sebagai metrik terpisah
- Quick-check dari home screen/widget
- Notifikasi motivasi saat streak record baru

**Deadline Tugas Kuliah (4.6):**
- Duplikasi tugas
- Weekly workload view sebagai layar/endpoint mandiri; v1.0 hanya memakai proyeksi beban minggu depan di dalam Weekly Review

---

## 9. Acceptance Criteria & Release Gates

Requirement v1.0 dianggap selesai jika implementasi, test, dan dokumentasi kontraknya
memenuhi kriteria berikut.

### 9.1 Functional acceptance

| Area | Acceptance criteria minimum |
|---|---|
| Activity | Status satu occurrence recurring tidak mengubah template atau occurrence lain. Bulk action hanya menyentuh Activity manual yang eligible. Timebox dan Activity hasilnya tampil sebagai satu unit. Reminder kosong untuk activity tanpa waktu mulai. ActivityCategory menjaga nama/warna lintas Activity dan Timebox. |
| Pomodoro | App menyimpan sesi saat start dan mempertahankan `running`/`paused` saat relaunch. Pause tidak menambah waktu aktual. Completion sesi fokus menghasilkan maksimal satu Activity; cancel dan break tidak masuk statistik fokus. |
| Timebox | Sistem menyimpan planned/actual timestamps serta outcome `completed`, `missed`, `skipped`, atau `rescheduled` per execution. Reschedule membuat destination pending secara atomik. Lewati occurrence tidak menonaktifkan template; putuskan nanti tidak membuat mutation. |
| Habit | Satu habit memiliki maksimal satu log aktif per tanggal. Perhitungan streak memakai schedule historis; periode paused diabaikan. Koreksi done/non-done membuat atau men-tombstone Activity deterministik yang sama. |
| Tugas dan Mata Kuliah | Tugas overdue belum selesai tetap aktif. Tugas selesai masuk riwayat tujuh hari setelah `completed_at`, sedangkan arsip manual memakai `archived_at`; minggu riwayat dapat dinavigasi. Reminder bertipe memiliki kalender/hari atau offset menit yang jelas. |
| Keuangan | Transfer dan adjustment ledger diterapkan tepat sekali. Saldo awal hanya dapat diperbaiki sebelum ada transaksi; sesudah itu koreksi membuat adjustment yang tidak masuk chart. Akun/kategori yang pernah dipakai diarsipkan dan histori tetap terbaca. |
| Lifecycle | Delete parent mengikuti matrix cascade/detach/restrict, menghasilkan revision berurutan, dan tidak meninggalkan child aktif yang tidak valid. Restore eksplisit tidak melakukan cascade otomatis. |
| API lifecycle | OpenAPI v1.0 tidak memuat endpoint weekly workload mandiri; proyeksinya hanya ada pada response Weekly Review. Compatibility route `mark-status` mencantumkan replacement dan removal version `2.0.0`. |
| Perhitungan | Completion rate, overlap, saldo, summary, chart, snapshot Weekly Review, dan workload minggu depan menghasilkan nilai identik dari fixture yang sama pada server dan repository lokal, termasuk zero denominator serta half-open boundary. Endpoint workload mandiri tetap future scope. |
| Settings | UserSettings tersinkron lintas device; DeviceSettings dan API key tetap lokal. Server menolak timezone invalid. Perubahan timezone memicu recompute/reschedule tanpa mengubah Local date atau Instant historis. Perubahan durasi tidak mengubah Pomodoro running; toggle notifikasi tidak menghapus reminder domain. |
| Weekly Review | Satu review per minggu. Dua jurnal wajib sebelum completion; ringkasan membeku pada cutoff. Gate planning berlaku Minggu pada waktu review, bekerja offline, dan hanya menahan perubahan yang memengaruhi minggu berikutnya. Draft dipromosikan satu per satu tanpa target ganda. |

### 9.2 Sync acceptance

- Replay `(sync_generation, user_id, device_id, change_id)` dengan payload sama tidak membuat mutation atau revision baru, termasuk setelah cache HTTP 24 jam kedaluwarsa. Accepted outcome kembali sebagai `duplicate` dengan revision/record awal; rejection deterministik tetap `rejected` dengan error awal. Payload berbeda menghasilkan `IDEMPOTENCY_KEY_REUSED`.
- Push hanya diterima dari device `active` dengan `sync_generation` dan `sync_epoch` yang sama. Device stale, revoked, atau berada dalam snapshot tidak dapat mengirim mutation biasa.
- Setiap item push beserta derived entity diproses dalam satu database transaction. Partial success hanya berlaku antar-item.
- Pull memakai opaque cursor berisi versi format, user, sync_generation, epoch, dan revision. Setiap change membawa snapshot record tepat pada revision tersebut.
- HabitLog, TimeboxExecution, recurring Activity, dan derived Activity memakai UUIDv5 deterministik serta natural unique constraint.
- Snapshot memiliki session ID, frozen records, high-watermark revision, pagination stabil, dan expiry maksimal 30 menit. Client menerapkan snapshot melalui staging dan mengganti seluruh synced state secara atomik, bukan merge dengan state lama. Snapshot start memakai Idempotency-Key yang direplay sebelum validasi epoch. Setelah completion, pull dilanjutkan dari high watermark.
- Ack revision per device hanya bergerak naik dalam satu sync_generation dan baru dikirim setelah transaction lokal berhasil. Setelah restore, generation baru memisahkan revision dari database lama.
- Server mempertahankan tombstone minimal 180 hari dan sampai seluruh device aktif mengakui revision tersebut. Device stale wajib snapshot sehingga tidak dapat membangkitkan data yang telah dihapus.
- Mismatch revision dilaporkan deterministik. Stale update terhadap tombstone serta create/restore child dengan parent terhapus ditolak. Pengecualian hanya untuk terminalisasi TimeboxExecution pending yang dipertahankan sebagai histori.
- Push upsert membawa kandidat lengkap field mutable bertipe ketat untuk perbandingan tiga versi; delete/restore membawa payload null. Restore membutuhkan revision tombstone terbaru. Seluruh record pull/snapshot tervalidasi terhadap schema entity sesuai discriminator.
- Auto-generated Activity memakai source event immutable dan menghasilkan maksimal satu Activity.
- Accepted, review_required, recovery_required, dan rejection deterministik masuk ProcessedChange. Transient failure tidak meninggalkan ledger idempotency dan retry change ID yang sama tetap tepat sekali.
- Merge tiga versi mengikuti kelompok field pada schema. Konflik membawa base/lokal/server untuk review; penyelesaian membutuhkan revision server yang masih sama. Record berkonflik terkunci untuk edit sampai selesai, termasuk mutation parent yang dapat mengubahnya secara cascade.
- Recovery setelah PITR atau retention expiry menyimpan salinan lokal sebelum replacement, termasuk mutation acknowledged. Semua replay membutuhkan persetujuan pengguna; review massal tersedia dan tidak membangkitkan tombstone otomatis.
- Antrean per entity mengizinkan satu request aktif; accepted response dan pull tidak menghapus edit lokal yang lebih baru. Revision server dialokasikan dalam urutan commit yang aman untuk pull dan snapshot.
- Snapshot memakai item ternormalisasi, page maksimal 500 item/2 MiB, record maksimal 256 KiB, satu session aktif per device, dan cleanup maksimal satu jam.

### 9.3 Quality gates

- `flutter analyze` lulus tanpa finding.
- Semua test Flutter dan test integration backend lulus.
- Contract test memvalidasi route Express terhadap `openapi.yaml`.
- Tidak ada hardcoded user-facing string di widget yang masuk release build.
- Setiap NFR memiliki artefak lulus sesuai matriks bukti pada `OPERATIONS.md`.
- Benchmark startup, sync, dan timer recovery lulus ambang serta metode pada `OPERATIONS.md`.
- PostgreSQL verifikasi restore otomatis hijau dan full restore drill berumur
  maksimal 90 hari; backup SQLite migration terverifikasi pada Windows serta Android.
- OpenAPI tidak memuat route future; setiap route deprecated memiliki versi
  penghapusan dan replacement.

### 9.4 Traceability baseline

| Requirement | Data contract | API contract | Test minimum |
|---|---|---|---|
| FR-1.2, FR-1.4, FR-1.5 | `ActivityCategory`, `ActivityRecurrence`, `Activity` | `/activity-categories`, `/activity`, recurrence operations | category lifecycle, occurrence isolation, no running status |
| FR-2.7, FR-2.12, FR-2.14 | `PomodoroSession`, `Activity.source_id` | `/pomodoro/sessions` | pause/resume recovery, exclusive link, idempotent completion |
| FR-1.10, FR-3.13 | reminder offset snapshots pada Activity, ActivityRecurrence, dan TimeboxSchedule | `/activity`, `/activity-recurrences`, `/timebox` | no-time invariant, template-edit isolation, local reschedule after pull |
| FR-3.6–FR-3.8, FR-3.12 | `TimeboxSchedule`, `TimeboxExecution` | `/timebox/:id/executions` | start, skip occurrence, atomic reschedule chain, plan/result unit |
| FR-5.1–FR-5.3, FR-5.7–FR-5.9, FR-5.13, FR-5.15 | `Habit`, `HabitSchedule.state`, `HabitLog`, `Activity.source_id` | `/habit`, `/habit/:id/archive`, `/habit/:id/schedules`, `/habit/:id/logs` | schedule isolation, pause/resume, streak, weekly izin, correction-derived activity |
| FR-4.1–FR-4.3, FR-4.13, FR-4.16–FR-4.17 | `Akun`, `CategoryKeuangan`, `Transaksi` | `/akun`, `/akun/:id/koreksi-saldo`, transaksi/transfer | archive, opening correction, adjustment exclusion, atomic ledger replay |
| FR-6.4, FR-6.7, FR-6.8, FR-6.13, FR-6.17, FR-6.19, FR-6.20 | `Tugas`, `TugasChecklist`, typed reminders | `/tugas`, archive, detail dan riwayat | overdue retention, completed/manual archive date, reminder scheduling, checklist suggestion |
| FR-6.5, FR-6.15 | `MataKuliah`, `CourseNote` | `/matakuliah`, `/matakuliah/:id/catatan` | parent ownership, pilihan tanggal catatan, soft delete, dan retensi terpisah dari tugas |
| FR-1.8, FR-1.13, FR-3.9, FR-4.10 | Derived projection rules | completion/finance endpoints dan overlap warning | zero denominator, rounding, half-open interval, ledger equation |
| FR-7.1–FR-7.14, NFR-7 | `UserSettings`, `DeviceSettings`, local sync state | `/settings`, device registration, dan sync | preferences, onboarding, Sync Center, notification permission, local/secret preservation |
| FR-8.1–FR-8.14 | `WeeklyReview`, `WeeklyPlanDraft`, weekly summary/candidate projection | `/weekly-reviews`, complete, draft, dan promotion operations | Sunday trigger, offline gate, frozen snapshot, unfinished candidates, idempotent promotion, two-device completion |
| NFR-2, NFR-3, NFR-4, NFR-10 | `SyncDevice`, `ProcessedChange`, `SyncChange`, `SyncSnapshot` | `/sync/devices`, `/sync/push`, `/sync/pull`, `/sync/ack`, `/sync/snapshot/*` | durable replay, two-device collision, delete/update conflict, stable snapshot, cursor expiry, tombstone acknowledgement |
| NFR-8, NFR-12, NFR-13 | `PERF-10K-v1` dan perangkat referensi | Endpoint sync dan instrumentasi app | startup p95, sync p95, timer drift/recovery |
| NFR-11 | Backup PostgreSQL dan SQLite | Prosedur `OPERATIONS.md` | checksum, verifikasi restore otomatis, full drill kuartalan, PITR bila diaktifkan, migration rollback |

### 9.5 Contoh penerimaan lintas fitur

| Kondisi awal | Tindakan | Hasil yang diharapkan |
|---|---|---|
| Tugas versi sama tersimpan di dua perangkat | Windows mengganti judul; Android mengganti deadline | Kedua perubahan bertahan bila kandidat gabungan valid |
| Dua perangkat mengganti deadline ke waktu berbeda | Keduanya sync | Record menunggu review kelompok jadwal; pengguna memilih satu nilai dan reminder terkait |
| Konflik sedang ditinjau | Perangkat lain mengubah server lagi | Pilihan lama tidak menimpa server; client memuat ulang review |
| Request judul A sedang dikirim | Pengguna mengetik judul B | Response A memperbarui base; tampilan B dan antrean berikutnya tetap ada |
| Recurrence memiliki occurrence hari ini | Jadwal berikutnya diedit | Occurrence yang sudah dimaterialisasi mempertahankan snapshot; aturan baru berlaku setelah watermark |
| Habit Senin/Rabu telah memiliki histori | Target diganti mulai minggu depan | Streak sebelum tanggal efektif tetap sama |
| HabitLog done telah menghasilkan Activity | Log dikoreksi menjadi non-done lalu done | Activity deterministik ditombstone lalu direstore melalui domain service; tidak ada duplikasi |
| Pomodoro berjalan lima menit | Pause, tutup app sepuluh menit, buka dan resume | Tetap paused sampai resume; sepuluh menit pause tidak masuk fokus |
| Timebox pending telah lewat | Pengguna reschedule | Source menyimpan histori rescheduled dan destination pending terbentuk atomik |
| Transfer 50.000 telah accepted | Response hilang dan request diulang | Saldo kedua akun berubah tepat sekali |
| Akun memiliki saldo 100.000 | Koreksi target menjadi 90.000 | Adjustment decrease 10.000; tidak masuk income/expense |
| Server kehilangan perubahan acknowledged setelah PITR | Client mengambil snapshot baru | Salinan lokal dan jurnal menyediakan perubahan untuk review sebelum replay |
| Perangkat offline lebih dari 180 hari | Kembali online dengan perubahan lokal | Salinan aman dibuat sebelum replacement; pengguna dapat memulihkan melalui aplikasi |
| Minggu pukul 09.00 dan review masih draft | User membuat Activity untuk minggu berikutnya | Planning ditahan; pencatatan hasil minggu berjalan tetap tersedia |
| WeeklyPlanDraft dipromosikan lalu response hilang | Command diulang | UUIDv5 dan status draft menghasilkan tepat satu target |

## 10. Changelog

- **1.0, 3 September 2026:** baseline terkonsolidasi untuk scope produk, CourseNote milik Mata Kuliah, versioned HabitSchedule, reminder data contract, Timebox execution/reschedule contract, immutable account opening balance, PostgreSQL, bearer API key, timezone contract, occurrence history, Pomodoro `running`, serta protokol sync operasional.
- **1.0, 4 September 2026:** kontrak P0 diperketat dengan typed response/sync payload, lifecycle delete/restore, rolling materialization, Habit pause dan algoritma streak normatif, serta update/delete transfer atomik.
- **1.0, 4 September 2026:** kontrak P1 menormalkan rumus statistik/overlap/ledger, menambahkan UserSettings dan DeviceSettings, mengklasifikasikan retry sync, memperjelas entity-level conflict, serta memecah snapshot menjadi item berpaginasi dan terbatasi.
- **1.0, 4 September 2026:** kontrak P2 menambahkan indeks otoritas, backup/DR dan benchmark NFR terukur, mengeluarkan workload future dari API v1.0, serta menetapkan removal version untuk compatibility route deprecated.
- **1.0, 5 September 2026:** keputusan produk per menu menghapus status Activity berjalan, menyatukan plan/result Timebox di Home, mempertahankan tugas overdue, menambahkan completion/archive Tugas, pause Pomodoro, reminder Tugas bertipe, skip occurrence Timebox, ActivityCategory, koreksi/arsip keuangan, koreksi Activity hasil HabitLog, Settings tunggal, Pusat Sync, dan onboarding.

- **1.0, 5 September 2026 — revisi hasil wawancara:** baseline belum diimplementasikan; milestone Windows lebih dahulu, Android M2; merge tiga versi per kelompok field, review yang mengunci record, recovery berpersetujuan, jurnal acknowledged, dan generation restore. Kebijakan ini menggantikan keputusan conflict entity-level sebelumnya.
- **1.0, 6 September 2026:** Weekly Review masuk M5 dengan jurnal evaluasi/fokus, snapshot produktivitas, kandidat pekerjaan tersisa, gate planning Minggu 09.00, serta draft Tugas/Activity/Timebox yang dipromosikan satu per satu.
- **1.0, 13 September 2026:** tema tampilan (`system`/`light`/`dark`, default `system`) ditetapkan sebagai preferensi per-device pada DeviceSettings lokal (FR-7.15, FR-7.6); tema tidak disinkronkan dan tidak masuk UserSettings, payload sync, OpenAPI, atau export. Keputusan ini menutup gap kontrol tema yang muncul dari desain Global Settings.
- **1.0, 13 September 2026:** Screen List (Section 7) direkonsiliasi dengan paket desain sebelas layar: panel pendamping Home (Next Deadline, Habits, Weekly Review Shortcut) dicantumkan sebagai penyaji data FR-6/FR-5/FR-8 yang sudah ada, Settings menambahkan tema dan waktu Weekly Review, Splash diberi deskripsi startup, dan Pusat Sync merinci sub-route Review Konflik serta Recovery/Snapshot. Rekonsiliasi ini presentasi, bukan scope baru.
- **1.0, 13 September 2026:** golden fixtures lintas-platform ditambahkan pada `schema.md` bagian 23 untuk resolusi DST occurrence, recompute setelah ganti timezone, dan round-trip resolusi konflik; ketiganya wajib menjadi contract test Dart dan Node.js. Fixture ini menutup tiga area determinisme yang sebelumnya hanya prosa.
- **1.0, 13 September 2026:** disaster recovery server disesuaikan ke skala personal offline-first (NFR-11, OPERATIONS bagian 1-4/8-9): RPO 15 menit ke 24 jam, RTO 4 jam ke pemulihan best-effort yang tidak memblokir pengguna, lima lapisan backup ke floor wajib logical harian dengan PITR/physical/monthly opsional, dan restore drill bulanan ke verifikasi restore otomatis per backup plus full drill kuartalan. Backup SQLite sebelum migration tetap wajib sebagai perlindungan salinan primer. Perubahan ini menurunkan garansi server secara sadar karena device menyimpan salinan penuh; tinjau ulang bila aplikasi menjadi multi-user atau data kritis bertambah.
