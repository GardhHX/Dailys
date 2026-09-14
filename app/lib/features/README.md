# features

Setiap fitur memakai lapisan `data/` (repository + DAO Drift), `domain/` (entity,
value object, enum status), `bloc/` (Cubit untuk state list sederhana, Bloc
event/state untuk alur berstatus), dan `presentation/` (layar + widget).

Fitur M1:

- `activity/` - Home Today (list + timeline harian), Activity manual dan occurrence
  recurring, status belum_mulai/selesai/dilewati, reminder, completion rate,
  overlap, serta ActivityCategory manage. FR-1.x dan FR-1.2.
- `tugas/` - tab Tugas penuh: list kartu, detail + checklist, riwayat tujuh hari,
  add/edit/archive, reminder bertipe, Mata Kuliah manage/detail, dan CourseNote.
  Panel Next Deadline pada Home juga disajikan dari sini. FR-6.x.
- `settings/` - bahasa id/en, IANA timezone (dengan recompute), tema per-device
  (FR-7.15), konfigurasi Pomodoro, dan
  preferensi notifikasi. FR-7.x.
- `onboarding/` - first-run: bahasa, timezone, registrasi device lokal; pembuatan
  akun keuangan di-skip pada M1 (fitur Keuangan M4).
- `splash/` - buka database, jalankan migration/recovery timer, route ke Onboarding
  atau Today; tidak menunggu network (FR-7.13).

Fitur Pomodoro tersedia di navigasi Home dan Tugas: fokus/break, preset dan durasi
custom, tautan Tugas, pause/resume, pemulihan sesi tersimpan, serta statistik dan
riwayat. Fokus selesai menghasilkan satu Activity. Upgrade database v1 ke v2
memerlukan backup terenkripsi yang sudah diverifikasi. Alarm OS dan tautan Habit
belum tersedia.

Ditunda ke milestone lain (jangan isi desain generik): Timebox dan Weekly Grid Home
(M3), panel Habits Home (M4), shortcut Weekly Review aktif (M5).
