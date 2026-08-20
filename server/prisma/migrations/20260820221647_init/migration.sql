-- CreateEnum
CREATE TYPE "Prioritas" AS ENUM ('low', 'medium', 'high');

-- CreateEnum
CREATE TYPE "TugasStatus" AS ENUM ('belum', 'progress', 'selesai');

-- CreateEnum
CREATE TYPE "ActivityStatus" AS ENUM ('belum_mulai', 'berjalan', 'selesai', 'dilewati');

-- CreateEnum
CREATE TYPE "ActivitySource" AS ENUM ('manual', 'pomodoro', 'timebox', 'tugas', 'habit');

-- CreateEnum
CREATE TYPE "PomodoroJenis" AS ENUM ('fokus', 'istirahat_pendek', 'istirahat_panjang');

-- CreateEnum
CREATE TYPE "PomodoroStatus" AS ENUM ('completed', 'cancelled');

-- CreateEnum
CREATE TYPE "Hari" AS ENUM ('senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu');

-- CreateEnum
CREATE TYPE "HabitLogStatus" AS ENUM ('done', 'skip', 'missed');

-- CreateEnum
CREATE TYPE "AkunTipe" AS ENUM ('cash', 'bank', 'ewallet', 'custom');

-- CreateEnum
CREATE TYPE "KeuanganTipe" AS ENUM ('income', 'expense');

-- CreateEnum
CREATE TYPE "TransaksiTipe" AS ENUM ('income', 'expense', 'transfer');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "nama" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mata_kuliah" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "nama" TEXT NOT NULL,
    "dosen" TEXT,
    "sks" INTEGER,
    "semester" TEXT,
    "warna" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "mata_kuliah_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tugas" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "mata_kuliah_id" TEXT,
    "judul" TEXT NOT NULL,
    "deskripsi" TEXT,
    "deadline" TIMESTAMP(3) NOT NULL,
    "prioritas" "Prioritas" NOT NULL,
    "estimasi_menit" INTEGER,
    "status" "TugasStatus" NOT NULL DEFAULT 'belum',
    "reminder_offsets" JSONB NOT NULL DEFAULT '[7,3,1,0]',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "tugas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tugas_checklist" (
    "id" TEXT NOT NULL,
    "tugas_id" TEXT NOT NULL,
    "judul" TEXT NOT NULL,
    "is_done" BOOLEAN NOT NULL DEFAULT false,
    "urutan" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "tugas_checklist_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "activity" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "judul" TEXT NOT NULL,
    "kategori" TEXT NOT NULL,
    "start_time" TIMESTAMP(3),
    "end_time" TIMESTAMP(3),
    "is_all_day" BOOLEAN NOT NULL DEFAULT false,
    "status" "ActivityStatus" NOT NULL,
    "is_recurring" BOOLEAN NOT NULL DEFAULT false,
    "recurring_days" JSONB,
    "recurring_end_date" TIMESTAMP(3),
    "source" "ActivitySource" NOT NULL DEFAULT 'manual',
    "source_id" TEXT,
    "catatan" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "activity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pomodoro_session" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "tugas_id" TEXT,
    "habit_id" TEXT,
    "start_time" TIMESTAMP(3) NOT NULL,
    "end_time" TIMESTAMP(3),
    "durasi_menit" INTEGER NOT NULL,
    "jenis" "PomodoroJenis" NOT NULL,
    "status" "PomodoroStatus" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "pomodoro_session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "timebox_schedule" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "tugas_id" TEXT,
    "habit_id" TEXT,
    "judul" TEXT NOT NULL,
    "kategori" TEXT NOT NULL,
    "start_time" TEXT NOT NULL,
    "end_time" TEXT NOT NULL,
    "hari" "Hari",
    "tanggal_spesifik" TIMESTAMP(3),
    "is_recurring" BOOLEAN NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "timebox_schedule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "habit" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "nama" TEXT NOT NULL,
    "target_hari" JSONB NOT NULL,
    "warna" TEXT NOT NULL,
    "icon" TEXT,
    "longest_streak" INTEGER NOT NULL DEFAULT 0,
    "max_izin_per_periode" INTEGER NOT NULL DEFAULT 1,
    "is_archived" BOOLEAN NOT NULL DEFAULT false,
    "urutan" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "habit_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "habit_log" (
    "id" TEXT NOT NULL,
    "habit_id" TEXT NOT NULL,
    "tanggal" DATE NOT NULL,
    "status" "HabitLogStatus" NOT NULL,
    "catatan" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "habit_log_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "akun" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "nama" TEXT NOT NULL,
    "tipe" "AkunTipe" NOT NULL,
    "saldo" DECIMAL(65,30) NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "akun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "category_keuangan" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "nama" TEXT NOT NULL,
    "tipe" "KeuanganTipe" NOT NULL,
    "icon" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "category_keuangan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "transaksi" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "akun_id" TEXT NOT NULL,
    "akun_tujuan_id" TEXT,
    "category_id" TEXT,
    "jumlah" DECIMAL(65,30) NOT NULL,
    "tipe" "TransaksiTipe" NOT NULL,
    "tanggal" DATE NOT NULL,
    "catatan" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "transaksi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "quick_capture" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "konten" TEXT NOT NULL,
    "tipe_tujuan" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "processed_to_id" TEXT,
    "processed_to_type" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "quick_capture_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "backup_export_log" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "tipe" TEXT NOT NULL,
    "file_path" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "backup_export_log_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- AddForeignKey
ALTER TABLE "tugas" ADD CONSTRAINT "tugas_mata_kuliah_id_fkey" FOREIGN KEY ("mata_kuliah_id") REFERENCES "mata_kuliah"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tugas_checklist" ADD CONSTRAINT "tugas_checklist_tugas_id_fkey" FOREIGN KEY ("tugas_id") REFERENCES "tugas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pomodoro_session" ADD CONSTRAINT "pomodoro_session_tugas_id_fkey" FOREIGN KEY ("tugas_id") REFERENCES "tugas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pomodoro_session" ADD CONSTRAINT "pomodoro_session_habit_id_fkey" FOREIGN KEY ("habit_id") REFERENCES "habit"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timebox_schedule" ADD CONSTRAINT "timebox_schedule_tugas_id_fkey" FOREIGN KEY ("tugas_id") REFERENCES "tugas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "timebox_schedule" ADD CONSTRAINT "timebox_schedule_habit_id_fkey" FOREIGN KEY ("habit_id") REFERENCES "habit"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "habit_log" ADD CONSTRAINT "habit_log_habit_id_fkey" FOREIGN KEY ("habit_id") REFERENCES "habit"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transaksi" ADD CONSTRAINT "transaksi_akun_id_fkey" FOREIGN KEY ("akun_id") REFERENCES "akun"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transaksi" ADD CONSTRAINT "transaksi_akun_tujuan_id_fkey" FOREIGN KEY ("akun_tujuan_id") REFERENCES "akun"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transaksi" ADD CONSTRAINT "transaksi_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "category_keuangan"("id") ON DELETE SET NULL ON UPDATE CASCADE;
