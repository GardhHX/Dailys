import 'package:flutter_test/flutter_test.dart';

/// Golden round-trip from schema.md 23.3 (API-SPEC 8.4, 18.1). Sync/SyncChange
/// land in M2; kept here so this fixture isn't lost before then.
///
/// Tugas `id=11111111-1111-4111-8111-111111111111`, atomic groups `schedule`
/// (deadline, reminders) and `lifecycle` (status, completed_at, archived_at).
/// `D0=2026-09-20T10:00:00Z`, `D1=2026-09-22T10:00:00Z`. Base at
/// `server_revision=10`: `schedule{deadline=D0, reminders=[H-1]}`,
/// `lifecycle{status=belum_dikerjakan, completed_at=null, archived_at=null}`.
///
/// | Step | Action                        | base_rev | Change                                          | Result                                             |
/// |------|-------------------------------|---------:|--------------------------------------------------|-----------------------------------------------------|
/// | 1    | Device A pushes `C_A`          | 10       | lifecycle: status=selesai, completed_at set       | accepted, server_revision=11, merge_applied=false   |
/// | 2    | Device B pushes `C_B`          | 10       | schedule: D0->D1; lifecycle: status->progress     | review_required                                     |
/// | 3    | Resolution pushes `C2`         | 11       | schedule=D1 (agreed merge); lifecycle=selesai     | accepted, server_revision=12                        |
///
/// Step 2 detail: `schedule` changed only locally (one-sided, merges safely
/// to D1); `lifecycle` diverges (base=belum_dikerjakan, local=progress,
/// server=selesai) so the whole item becomes `review_required`:
/// `conflict=true`, `merge_applied=false`, `conflicting_groups=[lifecycle]`,
/// `reviewed_server_revision=11`, `reason=field_conflict` — no partial write
/// of the safe `schedule` group.
///
/// Step 3 detail: `change_id=C2`, `resolution_of=C_B`, `base_server_revision=11`
/// (== `reviewed_server_revision`). `schedule` must equal the agreed merge
/// (D1); `lifecycle` must equal one of the review's own candidates (here:
/// server's selesai), not a third value. If the current revision is still 11:
/// accepted, server_revision=12. Variant `server_changed`: if the server had
/// already advanced to 12 before step 3, the same push instead produces a
/// fresh review with `reason=server_changed`.
///
/// Adjacent fixed cases: two devices changing different groups from the same
/// base -> accepted with merge_applied=true, no review; upsert over a
/// tombstone -> CONFLICT; a stale delete -> review on the `lifecycle` group.
void main() {
  test('conflict resolution round-trip matches schema 23.3', () {},
      skip: 'M2: sync/SyncChange do not exist yet');
}
