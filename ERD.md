# Dailys ERD

**Versi:** 1.0 target contract  
**Terakhir diperbarui:** 6 September 2026  
**Sumber detail:** `schema.md`  
**Indeks:** `README.md`

ERD ini menunjukkan hubungan antar-entity. Field, tipe data, constraint, index,
aturan sync, dan migrasi tetap didefinisikan oleh `schema.md`.

## 1. Gambaran umum

```mermaid
flowchart LR
    UI[Flutter: Windows M1, Android M2] --> LOCAL[Domain lokal Drift]
    LOCAL --> OUTBOX[Outbox dan jurnal]
    OUTBOX --> API[REST sync]
    API --> PG[Domain server PostgreSQL]
    PG --> PULL[Change log dan snapshot]
    PULL --> BASE[Base server lokal]
    BASE --> LOCAL
    OUTBOX --> REVIEW[Review konflik dan recovery]
    REVIEW --> LOCAL
```

Panah pada gambaran umum menunjukkan aliran data. Relasi ERD berikut menunjukkan
ownership/FK; field rinci tetap berada di schema. Baseline belum diimplementasikan.

## 2. Relasi domain

```mermaid
erDiagram
    USER ||--|| USER_SETTINGS : configures
    USER ||--o{ MATA_KULIAH : owns
    USER ||--o{ TUGAS : owns
    MATA_KULIAH o|--o{ TUGAS : categorizes
    MATA_KULIAH ||--o{ COURSE_NOTE : records
    TUGAS ||--o{ TUGAS_CHECKLIST : contains
    USER ||--o{ ACTIVITY_RECURRENCE : owns
    USER ||--o{ ACTIVITY : owns
    USER ||--o{ ACTIVITY_CATEGORY : owns
    ACTIVITY_CATEGORY ||--o{ ACTIVITY_RECURRENCE : categorizes
    ACTIVITY_CATEGORY ||--o{ ACTIVITY : categorizes
    ACTIVITY_CATEGORY ||--o{ TIMEBOX_SCHEDULE : categorizes
    ACTIVITY_RECURRENCE o|--o{ ACTIVITY : produces
    USER ||--o{ POMODORO_SESSION : owns
    TUGAS o|--o{ POMODORO_SESSION : links
    USER ||--o{ TIMEBOX_SCHEDULE : owns
    TUGAS o|--o{ TIMEBOX_SCHEDULE : links
    TIMEBOX_SCHEDULE ||--o{ TIMEBOX_EXECUTION : executes
    TIMEBOX_EXECUTION o|--o| TIMEBOX_EXECUTION : reschedules_to
    TIMEBOX_EXECUTION o|--o| ACTIVITY : creates
    USER ||--o{ HABIT : owns
    HABIT ||--o{ HABIT_SCHEDULE : versions
    HABIT ||--o{ HABIT_LOG : records
    HABIT_LOG o|--o| ACTIVITY : creates
    HABIT o|--o{ POMODORO_SESSION : links
    HABIT o|--o{ TIMEBOX_SCHEDULE : links
    USER ||--o{ AKUN : owns
    USER ||--o{ CATEGORY_KEUANGAN : owns
    USER ||--o{ TRANSAKSI : owns
    AKUN ||--o{ TRANSAKSI : source_account
    AKUN o|--o{ TRANSAKSI : destination_account
    CATEGORY_KEUANGAN o|--o{ TRANSAKSI : categorizes
    POMODORO_SESSION o|--o| ACTIVITY : creates
    USER ||--o{ WEEKLY_REVIEW : owns
    WEEKLY_REVIEW ||--o{ WEEKLY_PLAN_DRAFT : plans
    USER {
        uuid id PK
        string api_key_hash
    }
    USER_SETTINGS {
        uuid id PK
        uuid user_id FK
        string language
        string timezone
        int pomodoro_focus_minutes
        int pomodoro_short_break_minutes
        int pomodoro_long_break_minutes
        int pomodoro_long_break_interval
        string alarm_mode
        boolean notifications_enabled
        string weekly_review_time
    }
    MATA_KULIAH {
        uuid id PK
        uuid user_id FK
    }
    TUGAS {
        uuid id PK
        uuid user_id FK
        uuid mata_kuliah_id FK
        datetime deadline
        string status
        datetime completed_at
        datetime archived_at
        json reminders
    }
    TUGAS_CHECKLIST {
        uuid id PK
        uuid tugas_id FK
    }
    COURSE_NOTE {
        uuid id PK
        uuid mata_kuliah_id FK
        date tanggal
    }
    ACTIVITY_RECURRENCE {
        uuid id PK
        uuid user_id FK
        uuid activity_category_id FK
        json reminder_offsets_minutes
        date materialized_through_date
    }
    ACTIVITY {
        uuid id PK
        uuid user_id FK
        uuid recurrence_id FK
        uuid activity_category_id FK
        string status
        json reminder_offsets_minutes
    }
    ACTIVITY_CATEGORY {
        uuid id PK
        uuid user_id FK
        string nama
        string warna
        boolean is_system
        boolean is_archived
    }
    POMODORO_SESSION {
        uuid id PK
        uuid user_id FK
        uuid tugas_id FK
        uuid habit_id FK
        datetime start_time
        datetime end_time
        datetime paused_at
        int accumulated_pause_seconds
        int actual_seconds
        string status
    }
    TIMEBOX_SCHEDULE {
        uuid id PK
        uuid user_id FK
        uuid tugas_id FK
        uuid habit_id FK
        uuid activity_category_id FK
        boolean is_recurring
        json reminder_offsets_minutes
        date materialized_through_date
    }
    TIMEBOX_EXECUTION {
        uuid id PK
        uuid schedule_id FK
        uuid activity_id FK
        uuid rescheduled_to_id FK
        datetime planned_start_at
        datetime planned_end_at
        datetime actual_start_at
        datetime actual_end_at
        string status
    }
    HABIT_SCHEDULE {
        uuid id PK
        uuid habit_id FK
        date effective_from
        date effective_to
        json target_hari
        int max_izin_per_minggu
        string state
    }
    HABIT {
        uuid id PK
        uuid user_id FK
        int current_streak
        boolean is_archived
    }
    HABIT_LOG {
        uuid id PK
        uuid habit_id FK
    }
    AKUN {
        uuid id PK
        uuid user_id FK
        bigint saldo_awal
        bigint saldo
        boolean is_archived
        datetime archived_at
    }
    CATEGORY_KEUANGAN {
        uuid id PK
        uuid user_id FK
        boolean is_archived
        datetime archived_at
    }
    TRANSAKSI {
        uuid id PK
        uuid user_id FK
        uuid akun_id FK
        uuid akun_tujuan_id FK
        uuid category_id FK
        string tipe
        string adjustment_direction
    }
    WEEKLY_REVIEW {
        uuid id PK
        uuid user_id FK
        date week_start
        date week_end
        string status
        text evaluation_text
        text next_week_focus_text
        json summary_snapshot
        datetime summary_cutoff_at
        datetime completed_at
    }
    WEEKLY_PLAN_DRAFT {
        uuid id PK
        uuid weekly_review_id FK
        string target_type
        date target_date
        string source_entity_type
        uuid source_entity_id
        string status
        string promoted_entity_type
        uuid promoted_entity_id
    }
```

## 3. Infrastruktur sync

```mermaid
erDiagram
    USER ||--o{ SYNC_DEVICE : registers
    SYNC_DEVICE ||--o| DEVICE_SETTINGS : has_local_state
    DEVICE_SETTINGS ||--o{ SYNC_OUTBOX : queues_local_changes
    DEVICE_SETTINGS ||--o{ SYNC_CONFLICT_NOTICE : surfaces_conflicts
    DEVICE_SETTINGS ||--o{ SYNC_SNAPSHOT_STAGING : stages_snapshot
    DEVICE_SETTINGS ||--o{ SYNC_RECOVERY_QUEUE : stages_pitr_recovery
    SYNC_DEVICE ||--o{ PROCESSED_CHANGE : deduplicates
    SYNC_DEVICE ||--o{ SYNC_SNAPSHOT : snapshots
    SYNC_SNAPSHOT ||--o{ SYNC_SNAPSHOT_ITEM : contains
    USER ||--o{ SYNC_CHANGE : tracks
    SYNC_DEVICE o|--o{ SYNC_CHANGE : originates
    DEVICE_SETTINGS ||--o{ SYNC_ENTITY_BASE : remembers_server
    DEVICE_SETTINGS ||--o{ SYNC_MUTATION_JOURNAL : retains_receipts
    USER {
        uuid id PK
        string api_key_hash
    }
    DEVICE_SETTINGS {
        uuid device_id PK
        string notification_permission
        int alarm_volume_percent
        string theme
        int active_timer_notification_id
        string last_pull_cursor
        string last_sync_status
        datetime last_sync_at
        datetime onboarding_completed_at
        uuid sync_generation
        bigint sync_epoch
    }
    SYNC_CHANGE {
        uuid sync_generation
        bigint revision PK
        uuid user_id FK
        uuid device_id FK
        uuid change_id
        string operation
        json record_json
    }
    SYNC_DEVICE {
        uuid id PK
        uuid user_id FK
        bigint sync_epoch
        string sync_state
        bigint last_ack_revision
    }
    PROCESSED_CHANGE {
        uuid sync_generation PK
        uuid user_id PK
        uuid device_id PK
        uuid change_id PK
        string request_hash
        bigint server_revision
    }
    SYNC_SNAPSHOT {
        uuid sync_generation
        uuid id PK
        uuid user_id FK
        uuid device_id FK
        bigint sync_epoch
        bigint high_watermark_revision
        int record_count
        bigint total_bytes
    }
    SYNC_SNAPSHOT_ITEM {
        uuid snapshot_id PK,FK
        int sequence PK
        string entity_type
        uuid entity_id
        json record_json
        int size_bytes
    }
    SYNC_OUTBOX {
        uuid change_id PK
        uuid device_id FK
        string entity_type
        uuid entity_id
        string operation
        string status
        json payload_json
    }
    SYNC_CONFLICT_NOTICE {
        uuid id PK
        uuid change_id
        string entity_type
        uuid entity_id
        string status
        bigint reviewed_server_revision
    }
    SYNC_SNAPSHOT_STAGING {
        uuid snapshot_id PK
        int sequence PK
        string entity_type
        uuid entity_id
        json record_json
    }
    SYNC_RECOVERY_QUEUE {
        uuid id PK
        uuid original_change_id
        string entity_type
        uuid entity_id
        string status
    }
    SYNC_ENTITY_BASE {
        uuid device_id PK
        string entity_type PK
        uuid entity_id PK
        uuid sync_generation
        bigint server_revision
        json record_json
    }
    SYNC_MUTATION_JOURNAL {
        uuid change_id PK
        uuid device_id FK
        uuid sync_generation
        uuid original_change_id
        json request_json
        json receipt_json
    }
```

DEVICE_SETTINGS, SYNC_OUTBOX, SYNC_CONFLICT_NOTICE, SYNC_SNAPSHOT_STAGING,
SYNC_RECOVERY_QUEUE, SYNC_ENTITY_BASE, dan SYNC_MUTATION_JOURNAL bersifat local-only.
Relasi ke device menjelaskan ownership lokal; tabel tersebut tidak berada di server.
USER_SETTINGS termasuk domain yang disinkronkan. Snapshot item adalah materialisasi
server sementara, sedangkan jurnal lokal mempertahankan receipt setelah outbox selesai.

sync_generation berasal dari konfigurasi deployment di luar database restore;
ia bukan entity tambahan. Schema memuat 32 entity/table v1.0. Conflict review
menahan edit lokal pada record terkait; ia tidak menahan lock database server
selama pengguna memilih.
