# Dailys app (Flutter)

Kode aplikasi Dailys. Tahap saat ini: **scaffold M1** (struktur + rencana), belum
implementasi penuh. Kontrak dan desain berada di root repo:

- Produk: [`../PRD-Aplikasi-Produktivitas-Mahasiswa.md`](../PRD-Aplikasi-Produktivitas-Mahasiswa.md)
- Data: [`../schema.md`](../schema.md), relasi [`../ERD.md`](../ERD.md)
- API/sync: [`../API-SPEC.md`](../API-SPEC.md), [`../openapi.yaml`](../openapi.yaml)
- Operasi: [`../OPERATIONS.md`](../OPERATIONS.md)
- Desain UI: [`../DESIGN.md`](../DESIGN.md), [`../design/screens`](../design/screens),
  token [`../design/tokens.json`](../design/tokens.json)

Otoritas tetap: PRD -> schema -> API-SPEC -> OpenAPI -> desain. Kode tidak boleh
memperluas scope atau melemahkan invariant dokumen tersebut.

## Stack

Flutter (Dart), **Bloc/Cubit** untuk state management, **Drift** (SQLite) sebagai
source of truth lokal, **go_router** untuk navigasi (PRD Section 7), `uuid` untuk
UUIDv4/UUIDv5 deterministik, `timezone` + kebijakan DST clamp manual, dan
`flutter_local_notifications` untuk reminder.

## Rencana kerja

Lihat [`M1-PLAN.md`](M1-PLAN.md) untuk scope M1, tree folder, pemetaan FR->file,
urutan kerja, dan jangkar kontrak.

## Mulai (saat implementasi dimulai)

```powershell
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d windows
```

Windows lebih dahulu (M1); Android masuk M2. Belum ada backend/sync pada M1.
