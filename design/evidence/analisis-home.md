# Analisis dokumentasi untuk Home Dailys

Tanggal: 12 September 2026. Hasil: preview interaktif Home, bukan implementasi Flutter atau backend.

## Dasar keputusan

| Dokumen tersedia | Implikasi produk dan desain |
|---|---|
| README.md | Urutan otoritas: PRD → schema → API-SPEC → OpenAPI → desain. Proyek masih dokumentasi/target v1.0. |
| PRD-Aplikasi-Produktivitas-Mahasiswa.md | Home menyatukan Activity + Timebox; default landing adalah Today. Lima tab utama: Home, Tugas, Pomodoro, Keuangan, Habit. Form sebagai modal; deadline muncul pada timeline/grid. Windows lebih dahulu; Android memakai kontrak fitur yang sama. |
| schema.md | Activity, TimeboxExecution, dan HabitLog memiliki lifecycle terpisah. Hasil Timebox digabung melalui source_id; hasil Habit berasal dari log per tanggal. Completion rate dihitung dari Activity aktif, bukan semua Timebox pending. Local date dan Instant dibedakan. |
| API-SPEC.md | Action start mengisi actual_start_at tanpa mengubah execution pending. Completion menghasilkan satu Activity. Skip occurrence tidak mematikan template. Reschedule mempertahankan source dan membuat destination. Habit done/non-done menjaga hasil Activity konsisten. Weekly Review membuka gate lokal tanpa menunggu server. |
| openapi.yaml | Bentuk wire memiliki status dan field terpisah untuk Activity, Tugas, TimeboxExecution, HabitSchedule/HabitLog, dan WeeklyReview. Parsing aktual: versi 1.0.0; 64 path, 97 operation, 199 schema; operation ID unik dan referensi internal valid. Pemeriksaan ini bukan validasi semantik menyeluruh. |
| ERD.md | Relasi menguatkan sumber hasil Activity: PomodoroSession, TimeboxExecution, HabitLog. CourseNote milik MataKuliah; tidak ditempelkan ke Tugas atau Home. Infrastruktur sync terpisah dari domain. |
| OPERATIONS.md | Startup Today membaca lokal; VPS bukan prasyarat UI. Backup, recovery, benchmark, dan restore drill merupakan target implementasi/rilis. Preview tidak mengklaim hasil benchmark atau sync nyata. |

`design-home.md`, `design-task.md`, dan `design/mockups/` dirujuk README tetapi tidak ada di checkout ini. Arah visual mengikuti brief pengguna dan requirement PRD yang tersedia.

## Komposisi Home

1. App bar: identitas teks Dailys, label data contoh, dan tema terang/gelap.
2. Today: tanggal aktif, navigasi tanggal, date picker, dan strip Senin–Minggu.
3. Jadwal sebagai fokus utama: Daftar, Timeline, dan grid mingguan Timebox.
4. Next deadline: tenggat mendatang terdekat, status, prioritas, mata kuliah, dan tugas overdue yang tetap aktif.
5. Habits: daftar flat target pada tanggal aktif, checklist hari ini, streak dalam target hari, catatan dan izin.
6. Weekly Review: akses jurnal evaluasi/fokus; pratinjau shortcut Home, bukan seluruh modul review.

Panel Next deadline dan Habits di dalam Home mengikuti permintaan eksplisit terbaru pengguna. PRD tidak merinci dua panel ini dalam Screen List Home. Ini perlu ditambahkan ke dokumen desain fitur ketika dipilih sebagai desain aktif. Widget homescreen OS tetap future scope; preview ini berada di dalam aplikasi.

## Traceability

| Perilaku | Requirement |
|---|---|
| Daftar dan timeline pada tanggal aktif | FR-1.6, FR-1.9 |
| Activity tanpa waktu ditampilkan terpisah | FR-1.3 |
| Status Activity: belum mulai, selesai, dilewati | FR-1.5 |
| Timebox dan hasilnya satu unit | FR-1.6, FR-3.14; schema §8 |
| Indikator completion memakai denominator Activity | FR-1.13; schema §14.1 |
| Grid Senin–Minggu × jam dan quick-add | FR-3.3, FR-3.15 |
| Mulai, selesai, skip, missed, reschedule, putuskan nanti | FR-3.6, FR-3.7, FR-3.12 |
| Deadline overlay pada timeline/grid | FR-6.6 |
| Countdown, course, status, priority, overdue | FR-6.8, FR-6.9, FR-6.10, FR-6.17 |
| Habit hanya target aktif; done membuat hasil unik | FR-5.2, FR-5.3, FR-5.13, FR-5.15 |
| Catatan dan izin Habit | FR-5.7, FR-5.12 |
| Shortcut Weekly Review dan dua jurnal wajib | FR-8.2, FR-8.3 |
| Status dengan teks dan warna; keyboard; reflow | NFR dan antislop R-03, R-25, R-32 |

## Alasan visual

Design Read: Home personal untuk mahasiswa, modern dengan bidang warna tegas dan tipografi Windows. ENERGY 2 / RHYTHM 2 / MOTION 1.

- Indigo pekat memusatkan perhatian pada Timebox terpilih dan aksi utama; teks putih menjaga keterbacaan.
- Permukaan netral hangat memberi struktur untuk jadwal panjang tanpa efek glass/glow.
- Segoe UI mengikuti konteks Windows dan mendukung teks Indonesia yang padat.
- Kolom jadwal lebih lebar karena pengguna memilih pekerjaan berikutnya; deadline dan habit menjadi pendamping.
- Kotak jadwal menampung waktu, kategori, dan status; habit memakai baris checklist karena pekerjaannya berbeda.
- Titik kategori mengikuti nama kategori; merah dan label menandai deadline/overdue, hijau dan teks menandai streak/hasil.
- Radius 3/6/9/12 px membedakan blok grid, kontrol, entry, dan dialog; bayangan hanya untuk dialog.
- Hover dan active memberi feedback tanpa animasi berulang.
- Pada ponsel grid mingguan menjadi agenda per hari; seluruh hari, block, deadline, dan quick-add tetap tersedia.
- Navigasi lima tab mengikuti PRD; tab lain dinonaktifkan dengan label belum dipreview karena tugas ini hanya Home.

## Batas preview

Data tugas, habit, jadwal, dan streak merupakan contoh berlabel. Interaksi mengubah state sementara; reload mengembalikan contoh. Tidak ada persistensi SQLite, REST, sinkronisasi, provisioning, alarm OS, atau benchmark native. Form menampilkan field utama untuk mengeksplorasi Home; pengelolaan template/recurrence lengkap, kategori, reminder, bulk action, route detail penuh, heatmap, recovery, dan keseluruhan Weekly Review tetap memerlukan desain lanjutan.

## Bukti verifikasi

`qa-results.json` mencatat 54 pemeriksaan: 9 lebar × 3 mode × 2 tema. Viewport luar 352–1440 px memberi lebar preview sekitar 320–1408 px. Pemeriksaan mengukur root dan descendant, termasuk scrollWidth, bukan hanya root.

Click-through mencakup mode jadwal, navigasi tanggal, date picker, strip hari, tema, detail Timebox, start/completion, reschedule, detail deadline/status tugas, tambah/edit/skip/checklist Activity, Habit done/correction/izin/catatan, quick-add grid, jurnal review, Escape, fokus keyboard, serta state kosong/memuat/gagal/retry. Pemeriksaan tambahan dan hasil akhir tercatat dalam laporan gate.

Teks non-disabled yang terlihat pada keadaan utama diukur terhadap background aktual di kedua tema dan memenuhi AA. Pemeriksaan ini tidak menggantikan audit aksesibilitas native atau pengujian Android dengan keyboard layar.
