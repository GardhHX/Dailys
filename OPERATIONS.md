# Dailys Operations and Quality Contract

**Versi:** 1.0 target contract  
**Terakhir diperbarui:** 6 September 2026  
**Terkait:** `README.md`, `PRD-Aplikasi-Produktivitas-Mahasiswa.md`, `schema.md`, `API-SPEC.md`

Dokumen ini menetapkan prosedur backup, disaster recovery, migration safety, dan
pengukuran NFR v1.0. Release/operations owner menyimpan log eksekusi, checksum,
hasil benchmark, serta bukti restore di penyimpanan artefak rilis.

## 1. Sasaran pemulihan

Dailys offline-first: setiap device menyimpan salinan penuh domain di SQLite dan
tetap berfungsi tanpa server (NFR-2, NFR-9). Server PostgreSQL adalah sync relay
dan backup sekunder, bukan satu-satunya salinan data. Kehilangan data user-facing
membutuhkan kegagalan server bersamaan dengan hilangnya seluruh device; untuk
aplikasi personal satu pengguna dengan sedikit device, DR disesuaikan ke risiko
tail tersebut, bukan ke layanan zero-RPO. Ketersediaan pengguna tidak bergantung
pada pemulihan server. Perlindungan utama salinan primer adalah backup SQLite
sebelum migration (bagian 3); backup server menutup skenario ekstrem.

| Sasaran | Batas v1.0 | Titik ukur |
|---|---:|---|
| PostgreSQL RPO | Maksimal 24 jam data server; device tetap menyimpan salinan penuh | Timestamp manifest backup harian terakhir |
| Pemulihan layanan | Best-effort dan tidak memblokir pengguna karena device jalan offline; target pragmatis API sehat dalam 24 jam | Incident dinyatakan sampai API sehat dan satu client menyelesaikan snapshot serta pull |
| Backup freshness | Logical backup sukses dalam 24 jam terakhir | Timestamp manifest backup terakhir |
| Verifikasi restore | Otomatis pada setiap backup harian | Restore ke database scratch terisolasi lolos validasi bagian 4 |
| Full restore drill | Satu drill setiap kuartal atau sebelum rilis | Restore terisolasi lolos seluruh validasi bagian 4 |

PITR bergranularitas menit bersifat opsional (bagian 2): ia memperkecil tail loss
tetapi tidak wajib untuk skala personal karena device mereconcile lewat recovery
review setelah generation baru (API-SPEC 8.9). Replica sync menyimpan keadaan
terbaru dan tidak menyediakan point-in-time recovery; snapshot sync juga tidak
menggantikan backup database.

## 2. Backup PostgreSQL

Lapisan minimum wajib untuk v1.0 personal:

| Lapisan | Jadwal | Retensi | Lokasi |
|---|---|---|---|
| Logical `pg_dump` format custom | Setiap hari | 30 hari | Object storage off-host |

Lapisan opsional yang direkomendasikan bila ingin memperkecil tail loss, menyimpan
histori lebih panjang, atau saat volume data dan jumlah device bertambah:

| Lapisan | Jadwal | Retensi | Tujuan |
|---|---|---|---|
| WAL archive plus physical base backup (PITR) | WAL kontinu `archive_timeout` maksimal 15 menit; base mingguan | WAL 14 hari; base 8 minggu | Menurunkan RPO ke satuan menit |
| Logical backup bulanan | Bulanan | 12 bulan | Pemulihan kesalahan lama, misalnya hapus tak sengaja berbulan lalu |

Backup job wajib:

- mengenkripsi objek saat transit dan saat tersimpan;
- memakai credential backup dengan izin minimum;
- mengaktifkan versioning dan write protection sekurang-kurangnya tujuh hari;
- membuat manifest berisi waktu UTC, versi PostgreSQL, database, ukuran,
  checksum SHA-256, status verifikasi, dan WAL range bila PITR aktif;
- mengirim alert jika backup harian gagal, verifikasi restore gagal, checksum
  berbeda, atau storage tidak dapat dibaca; bila PITR aktif, juga jika WAL archive
  tertinggal lebih dari 30 menit.

Operations owner menyimpan credential dekripsi terpisah dari VPS dan bucket backup.
Backup domain hanya memuat hash API key dari PostgreSQL; secret API key mentah
tetap berada di secure storage device.

## 3. Backup SQLite sebelum migration

Client owner menjalankan langkah berikut pada setiap migration schema lokal:

1. App menghentikan domain write dan sync, lalu menunggu transaction aktif selesai.
2. App menjalankan `PRAGMA integrity_check` pada source database.
3. App membuat consistent copy melalui SQLite backup API setelah WAL checkpoint.
4. Manifest lokal mencatat app version, schema version asal/tujuan, device ID,
   waktu UTC, ukuran file, dan checksum SHA-256.
5. App membuka copy pada lokasi sementara, menjalankan `integrity_check`, dan
   membandingkan row count tabel domain, `SyncOutbox`, `SyncConflictNotice`,
   `SyncSnapshotStaging`, `SyncRecoveryQueue`, `SyncEntityBase`, `SyncMutationJournal`, dan `DeviceSettings` dengan source.
6. App menjalankan migration hanya setelah verifikasi backup lulus.
7. App mempertahankan backup sekurang-kurangnya 30 hari dan sampai tersedia tiga
   backup migration yang lebih baru.

App mengenkripsi copy dengan key device-local yang tersimpan di secure storage dan
tidak menaruh key di sebelah file backup. Copy tidak berisi API key karena client
menyimpan key di secure storage.

Jika migration gagal sebelum sync kembali aktif, app mengembalikan copy dan schema
version asal. Setelah client mengirim mutation dengan schema baru, app tidak boleh
melakukan downgrade otomatis. Client owner menyiapkan forward-fix atau prosedur
ekspor/recovery untuk kondisi tersebut.

## 4. Restore dan disaster recovery

### 4.1 Verifikasi restore otomatis dan full drill

Perlindungan utama adalah verifikasi restore **otomatis pada setiap backup harian**:
operations owner merestore logical dump terbaru ke database scratch terisolasi lalu
membuktikan:

- logical dump dapat direstore tanpa error;
- seluruh checksum cocok dan `SELECT` dasar dapat membaca semua tabel;
- invariant ownership/FK, saldo ledger, unique key aktif, revision monotonic, dan
  jumlah snapshot item lulus query validasi;
- API `/health` melaporkan database `reachable` pada hasil restore.

Kegagalan verifikasi mengirim alert dan diperlakukan seperti backup gagal. Rezim
ini menggantikan drill manual bulanan dengan pemeriksaan yang benar-benar berjalan
tiap hari.

**Full restore drill** dijalankan setiap kuartal atau sebelum rilis: operations
owner memilih satu restore point acak dari tujuh hari terakhir, memulihkan pada host
terisolasi, dan menjalankan seluruh validasi di atas. Bila PITR diaktifkan, drill
juga membuktikan replay base backup dan WAL sampai target dengan selisih tidak lebih
dari 15 menit. Owner mencatat waktu mulai, waktu selesai, restore point, backup ID,
hasil query, penyimpangan sasaran, dan tindakan koreksi. Kegagalan full drill
memblokir release sampai owner menutup tindakan koreksi dan mengulang drill.

### 4.2 Pemulihan insiden

Operations owner menjalankan urutan berikut:

1. Bekukan write API dan simpan log/artefak insiden.
2. Tentukan recovery target sebelum corruption atau kehilangan data.
3. Restore base backup dan WAL pada PostgreSQL baru; gunakan logical dump jika
   physical recovery gagal.
4. Jalankan validasi drill, set sequence revision di atas maksimum hasil restore,
   reset last_ack_revision device ke 0, dan invalidasi snapshot serta cache lama.
5. Buat UUIDv4 sync_generation baru pada konfigurasi deployment di luar database
   yang direstore. Catat generation lama/baru dalam log insiden. Tandai SyncChange
   hasil restore dengan generation baru sebagai baseline; jangan menghidupkan
   receipt/idempotency outcome generation lama. Naikkan epoch dan tandai device
   snapshot_required, lalu aktifkan API. Restart biasa mempertahankan generation.
6. Saat mismatch generation, client menghentikan sync biasa dan membuat salinan
   SQLite terenkripsi beserta manifest/hash sebelum mengganti state. Salinan
   memuat domain, SyncEntityBase, outbox, konflik, dan SyncMutationJournal, termasuk
   request/receipt yang sudah acknowledged dan dihapus dari outbox. Registrasi
   ulang mengambil generation/epoch aktif; device yang tidak ada setelah restore
   tetap menjalankan snapshot sebelum recovery perubahan lokal.
7. Client mengambil snapshot baru, lalu membandingkan state/jurnal dengan snapshot.
   Client tidak mengurutkan revision lintas generation atau memakai jam device
   sebagai bukti bahwa data lebih baru. Request tanpa receipt pasti masuk review
   ambigu. Perubahan yang sudah terwakili tidak direplay.
8. Pengguna meninjau semua kandidat pemulihan di Pusat Sync, termasuk never_accepted
   dan accepted_missing. Persetujuan massal menampilkan jumlah, jenis perubahan,
   dan dampak saldo. Client membentuk mutation baru dengan change ID baru dan
   menyimpan original_change_id pada jurnal. Tombstone/parent dan ledger tetap
   divalidasi; efek transfer yang sudah ada tidak diterapkan dua kali.
9. Simpan salinan recovery sampai seluruh review selesai dan minimal 30 hari;
   jurnal tidak dibersihkan otomatis pada v1.0. Kegagalan snapshot/replay tidak
   menghapus salinan, jurnal, atau keputusan yang belum selesai.
10. Satu device referensi wajib menyelesaikan snapshot dan pull setelah watermark,
    serta pemeriksaan saldo, habit, task, activity dan antrian review. Pemulihan
    layanan tercapai saat API sehat dan client selesai snapshot/pull; insiden baru ditutup setelah
    review pengguna selesai atau pekerjaan review tersisa diserahkan dengan jelas.

Retention expiry lebih dari 180 hari dan BASE_REVISION_UNAVAILABLE memakai jalur
salin-snapshot-review yang sama tanpa mengganti generation server. Client menahan
write lokal selama salin/snapshot; setelah replacement, hanya entity dalam review
yang tetap terkunci untuk edit. Client tetap menyajikan pembacaan state lama jika
snapshot gagal. Pengguna dapat memulihkan lewat aplikasi; ekspor diagnostik
bukan satu-satunya jalan.

Tim merotasi API key jika insiden menyentuh credential atau host compromise. Tim
tidak merotasi key untuk kerusakan data yang tidak memengaruhi credential.

## 5. Dataset benchmark

Suite `PERF-10K-v1` memakai data deterministik selama 24 bulan:

| Data | Jumlah |
|---|---:|
| Activity / ActivityRecurrence | 10.000 / 300 |
| ActivityCategory | 12, termasuk enam seed dan enam custom |
| Tugas / checklist / CourseNote | 2.000 / 8.000 / 2.000 |
| Habit / HabitSchedule / HabitLog | 100 / 500 / 20.000 |
| PomodoroSession | 2.000 |
| TimeboxSchedule / TimeboxExecution | 500 / 5.000 |
| Akun / kategori / transaksi | 20 / 50 / 10.000 |
| WeeklyReview / WeeklyPlanDraft | 104 / 520; dua tahun, rata-rata lima draft per review |
| Tombstone | 5% dari setiap entity sync yang dapat dihapus |

Fixture memakai timezone `Asia/Jakarta`, dua device, dan 1.000 SyncChange yang
belum ditarik oleh device kedua.
Tim menyimpan generator seed serta ukuran SQLite/PostgreSQL aktual pada artefak
benchmark.

## 6. Perangkat dan kondisi referensi

| ID | Platform referensi | Kondisi |
|---|---|---|
| WIN-REF-1 | Windows 10 22H2 x64, Intel Core i5-8250U, RAM 8 GB, SSD | Release x64, AC power, battery saver off, tidak ada debugger |
| AND-REF-1 | Android 11/API 30 arm64, Snapdragon 662, RAM 4 GB | Release arm64, battery saver off, suhu device di bawah 40°C, tidak ada debugger |

Jika hardware tersebut tidak tersedia, release owner boleh memakai pengganti
dengan CPU, RAM, storage, dan OS yang sama atau lebih lambat. Artefak benchmark
wajib mencatat model, OS build, app commit, build mode, dataset hash, suhu awal,
serta alasan substitusi.

## 7. Metode dan ambang NFR

### 7.1 Startup

- Cold start berarti process tidak hidup, app tidak sedang migration, dataset
  `PERF-10K-v1` sudah terpasang, dan OS mempertahankan user data.
- Warm start berarti app berada di background selama dua menit lalu user membuka
  kembali app.
- Harness mengukur dari perintah launch/resume sampai frame Today pertama selesai
  dan UI menerima input.
- Tim menjalankan 30 cold start dan 50 warm start per perangkat. Perhitungan p95
  memakai nearest-rank tanpa menghapus sampel.
- Batas lulus: cold-start p95 maksimal 2.000 ms dan warm-start p95 maksimal 750 ms.
- Suite mengukur first install dan migration secara terpisah; hasil tersebut tidak
  masuk metrik startup rutin.

### 7.2 Latency sync

Harness memakai staging VPS dengan RTT `80 ± 10 ms`, bandwidth downstream 10
Mbps, upstream 5 Mbps, dan packet loss 0%. Client sudah terautentikasi, lalu
harness mengukur dari trigger sync sampai push accepted, pull diterapkan dalam
transaction lokal, dan status berubah menjadi `success`.

| Skenario | Sampel | Batas p95 |
|---|---:|---:|
| Incremental, 100 local dan 100 remote change, rata-rata 2 KiB/item | 30 | 5 detik |
| Batch maksimum, 500 item dan body mendekati 2 MiB | 30 | 15 detik |
| Snapshot `PERF-10K-v1` sampai complete dan pull lanjutan | 10 | 120 detik |

Rate limit, packet loss, dan VPS failure masuk reliability test, bukan sampel
latency normal. Test tersebut tetap wajib membuktikan backoff, idempotency, serta
outbox yang tidak hilang.

### 7.3 Recovery timer

Harness membuat Pomodoro fokus 25 menit dan menjalankan tiga skenario: process
ditutup setelah lima menit lalu dibuka sepuluh menit kemudian; device sleep selama
30 menit; serta session dipause setelah lima menit, process ditutup, lalu dibuka
dan di-resume. Tim menjalankan masing-masing 30 sampel pada dua perangkat.

Batas lulus:

- sisa waktu setelah relaunch berbeda maksimal satu detik dari perhitungan
  `start_time + durasi_menit`;
- UI memperbaiki state timer maksimal 500 ms setelah frame pertama;
- session paused tetap paused setelah relaunch, tidak mengurangi sisa waktu, dan
  menambahkan selisih `resume_at - paused_at` tepat satu kali ke
  `accumulated_pause_seconds`;
- `actual_seconds` dan statistik fokus tidak memasukkan interval pause;
- session yang melewati planned end tetap memiliki satu outcome dan maksimal satu
  derived Activity setelah user menyelesaikan atau membatalkan session;
- perubahan wall clock saat process hidup tidak menghasilkan drift lebih dari
  satu detik karena runtime memakai monotonic clock; relaunch memakai Instant UTC
  yang tersimpan.

Pengujian delivery notifikasi mencatat batasan OS dan status permission. Tim hanya
menilai ketepatan delivery saat permission granted dan platform mengizinkan exact
alarm.

## 8. Matriks bukti NFR

| NFR | Test wajib | Bukti lulus |
|---|---|---|
| NFR-1 Platform | Install dan smoke test release build pada Windows 10 22H2, Android 8/API 26, WIN-REF-1, dan AND-REF-1 | App membuka Today dan seluruh enam modul tanpa crash |
| NFR-2 Offline-first | Matikan seluruh network selama 30 menit; create/update/delete satu record pada setiap modul, complete Weekly Review, uji gate, pause timer, restart app, lalu baca ulang | Semua operasi lokal berhasil, gate terbuka setelah completion lokal, timer konsisten, dan outbox tetap tersimpan |
| NFR-3 Sync | Jalankan test retry, partial success, crash-after-commit, snapshot start replay, dan recovery mutation acknowledged pasca-PITR, generation mismatch, dan retention review | Tidak ada mutation hilang/revision ganda; Pusat Sync menampilkan outbox, conflict, snapshot, dan recovery state yang benar |
| NFR-4 Conflict | Dua device mengubah entity yang sama dan menjalankan skenario stale tombstone | Kelompok berbeda digabung; kelompok bertabrakan meminta review base/lokal/server tanpa write domain, dan client menahan edit record |
| NFR-5 TLS | Uji endpoint public dengan TLS scanner dan coba koneksi HTTP/plaintext | TLS 1.2 atau lebih baru berhasil; plaintext dan sertifikat invalid ditolak |
| NFR-6 Auth | Kirim request tanpa key, key salah, serta key lama setelah rotasi; scan log dan export | Request mendapat 401 dan secret mentah tidak muncul pada artefak |
| NFR-7 Localization | Jalankan seluruh screen dengan locale `id` dan `en`; bandingkan key resource | Tidak ada key hilang, fallback debug, atau user-facing string di luar resource localization |
| NFR-8 Performa | Jalankan bagian 7.1 | Cold/warm p95 memenuhi ambang |
| NFR-9 Availability | Putuskan VPS selama test offline NFR-2, lalu pulihkan koneksi | UI inti tetap dapat dipakai dan outbox terkirim setelah VPS pulih |
| NFR-10 Retention | Simulasikan ack beberapa device, device stale 180 hari, expiry snapshot, dan cleanup | Server hanya membersihkan tombstone/session sesuai kontrak |
| NFR-11 Backup/DR | Jalankan bagian 2 sampai 4 | RPO 24 jam, backup harian off-host, verifikasi restore otomatis hijau, dan full drill kuartalan memenuhi sasaran; PITR opsional sehat bila diaktifkan |
| NFR-12 Sync latency | Jalankan bagian 7.2 | Seluruh p95 memenuhi ambang |
| NFR-13 Timer recovery | Jalankan bagian 7.3 | Drift, recovery time, dan uniqueness outcome memenuhi ambang |

## 9. Gate pengembangan, milestone, dan rilis

Belum ada benchmark atau restore drill yang dijalankan. Matriks bagian 8 adalah
kriteria target; owner melampirkan bukti setelah implementasi tersedia.

| Tahap | Pemeriksaan yang wajib saat tahap itu |
|---|---|
| M0 dokumentasi | Link lokal, YAML, referensi OpenAPI, operation ID, kelompok merge dan contoh sesuai schema; tidak mengklaim runtime pass |
| M1 lokal Windows | Persistensi/restart, recurrence/reminder, integrity check; backup terverifikasi sebelum setiap migration ketika ada data nyata |
| M2 server dan Android | Backup harian off-host dan verifikasi restore otomatis aktif sejak server menyimpan data nyata (PITR opsional); satu full drill sebelum menerima data utama; sync dua perangkat, review dan recovery lulus |
| M3–M4 | Uji domain yang baru ditambahkan, regresi integrasi dan keselamatan data pada kedua platform |
| M5 Weekly Review dan rilis v1.0 | Trigger/gate offline dan server, snapshot cutoff, kandidat, promotion idempotent, seluruh NFR bagian 8, dan gate rilis di bawah lulus |

Owner mengaktifkan verifikasi restore otomatis per backup sejak M2 menyimpan data
nyata dan menjalankan full drill kuartalan. Sasaran RPO dan perlindungan backup
tidak ditunda sampai rilis. Benchmark lengkap PERF-10K-v1 menjadi gate M5;
pengembangan mengukur bagian yang sudah tersedia.
Skema database baru membutuhkan validasi inisialisasi, bukan backfill legacy.

### 9.1 Gate rilis v1.0

Release v1.0 membutuhkan:

- backup harian sehat dan verifikasi restore otomatis hijau (WAL archive sehat bila PITR diaktifkan);
- full restore drill dalam 90 hari terakhir;
- backup SQLite migration terverifikasi pada kedua platform;
- seluruh benchmark bagian 7 lulus pada build release candidate;
- first-run onboarding pada fresh install dan Pusat Sync pada state idle, offline,
  failed, conflict, snapshot-required, serta recovery-required lulus acceptance test;
- Weekly Review pada Minggu 09.00, fresh install tengah minggu, completion offline,
  gate planning, frozen snapshot, dan promotion retry lulus pada Windows/Android;
- laporan mencantumkan percentile mentah, kegagalan, dan environment;
- deprecation metadata serta indeks dokumentasi lulus pemeriksaan kontrak.
