import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/ids/deterministic_id.dart';
import '../../l10n/app_localizations.dart';

/// Preset course colors (hex `#RRGGBB`, schema 4). A course must carry a color;
/// this keeps the form simple without a full picker.
const _coursePalette = <String>[
  '#4F46E5', '#0891B2', '#059669', '#D97706', '#DC2626', '#7C3AED',
];

Color _hex(String hex) => Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));

/// Courses & notes tab (design/screens/tugas.md: "tab ... Mata kuliah &
/// catatan"). MataKuliah has its own detail with dated CourseNotes.
class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key, required this.db, required this.userId});

  final AppDatabase db;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<MataKuliahRow>>(
      stream: db.mataKuliahDao.watchActiveMataKuliah(userId),
      builder: (context, snapshot) {
        final courses = snapshot.data ?? const [];
        if (courses.isEmpty) {
          return Center(child: Text(l10n.coursesEmpty));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: courses.length,
          itemBuilder: (context, i) {
            final c = courses[i];
            final meta = [
              if (c.dosen != null && c.dosen!.isNotEmpty) c.dosen!,
              if (c.sks != null) '${c.sks} ${l10n.courseFieldSks}',
              if (c.semester != null && c.semester!.isNotEmpty) c.semester!,
            ].join(' · ');
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: _hex(c.warna), radius: 8),
                title: Text(c.nama),
                subtitle: meta.isEmpty ? null : Text(meta),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(db: db, userId: userId, courseId: c.id),
                )),
              ),
            );
          },
        );
      },
    );
  }
}

Future<void> showAddEditCourseSheet(
  BuildContext context, {
  required AppDatabase db,
  required String userId,
  MataKuliahRow? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CourseSheet(db: db, userId: userId, existing: existing),
  );
}

class _CourseSheet extends StatefulWidget {
  const _CourseSheet({required this.db, required this.userId, this.existing});
  final AppDatabase db;
  final String userId;
  final MataKuliahRow? existing;

  @override
  State<_CourseSheet> createState() => _CourseSheetState();
}

class _CourseSheetState extends State<_CourseSheet> {
  late final TextEditingController _nama;
  late final TextEditingController _dosen;
  late final TextEditingController _sks;
  late final TextEditingController _semester;
  late String _warna;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nama = TextEditingController(text: e?.nama ?? '');
    _dosen = TextEditingController(text: e?.dosen ?? '');
    _sks = TextEditingController(text: e?.sks?.toString() ?? '');
    _semester = TextEditingController(text: e?.semester ?? '');
    _warna = e?.warna ?? _coursePalette.first;
  }

  @override
  void dispose() {
    _nama.dispose();
    _dosen.dispose();
    _sks.dispose();
    _semester.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existing == null ? l10n.courseAddTitle : l10n.courseEditTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _nama,
              decoration: InputDecoration(labelText: l10n.courseFieldNama),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _dosen,
              decoration: InputDecoration(labelText: l10n.courseFieldDosen),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sks,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.courseFieldSks),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _semester,
                    decoration: InputDecoration(labelText: l10n.courseFieldSemester),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final hex in _coursePalette)
                  GestureDetector(
                    onTap: () => setState(() => _warna = hex),
                    child: CircleAvatar(
                      backgroundColor: _hex(hex),
                      radius: 16,
                      child: _warna == hex
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: _submit, child: Text(l10n.tugasSave)),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final nama = _nama.text.trim();
    if (nama.isEmpty) {
      setState(() => _error = l10n.courseNameRequired);
      return;
    }
    int? sks;
    final sksText = _sks.text.trim();
    if (sksText.isNotEmpty) {
      sks = int.tryParse(sksText);
      if (sks == null || sks <= 0) {
        setState(() => _error = l10n.courseSksPositive);
        return;
      }
    }
    final dosen = _dosen.text.trim().isEmpty ? null : _dosen.text.trim();
    final semester = _semester.text.trim().isEmpty ? null : _semester.text.trim();
    final ts = DateTime.now().toUtc();

    if (widget.existing == null) {
      await widget.db.mataKuliahDao.insertMataKuliah(MataKuliahCompanion.insert(
        id: DeterministicId.v4(),
        createdAt: ts,
        updatedAt: ts,
        userId: widget.userId,
        nama: nama,
        dosen: Value(dosen),
        sks: Value(sks),
        semester: Value(semester),
        warna: _warna,
      ));
    } else {
      await widget.db.mataKuliahDao.updateMataKuliah(
        widget.existing!.id,
        MataKuliahCompanion(
          nama: Value(nama),
          dosen: Value(dosen),
          sks: Value(sks),
          semester: Value(semester),
          warna: Value(_warna),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }
}

/// MataKuliah detail with dated CourseNotes (schema 4.1).
class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({
    super.key,
    required this.db,
    required this.userId,
    required this.courseId,
  });

  final AppDatabase db;
  final String userId;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return StreamBuilder<List<MataKuliahRow>>(
      stream: db.mataKuliahDao.watchActiveMataKuliah(userId),
      builder: (context, courseSnap) {
        final course =
            courseSnap.data?.where((c) => c.id == courseId).firstOrNull;
        if (course == null) {
          // Deleted; pop out.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).maybePop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(course.nama),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    showAddEditCourseSheet(context, db: db, userId: userId, existing: course),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.courseDelete,
                onPressed: () => _confirmDelete(context, l10n),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addNote(context, l10n),
            child: const Icon(Icons.note_add_outlined),
          ),
          body: StreamBuilder<List<CourseNoteRow>>(
            stream: db.mataKuliahDao.watchCourseNotes(courseId),
            builder: (context, snapshot) {
              final notes = snapshot.data ?? const [];
              if (notes.isEmpty) {
                return Center(child: Text(l10n.courseNotesEmpty));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: notes.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(l10n.courseNotesTitle,
                          style: Theme.of(context).textTheme.titleMedium),
                    );
                  }
                  final n = notes[i - 1];
                  final dateLabel = DateFormat.yMMMEd(locale)
                      .format(DateTime.parse(n.tanggal));
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      title: Text(n.isi),
                      subtitle: Text(dateLabel),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => db.mataKuliahDao.softDeleteCourseNote(n.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.courseDeleteConfirmTitle),
        content: Text(l10n.courseDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.courseDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await db.mataKuliahDao.softDeleteMataKuliah(courseId);
      if (context.mounted) Navigator.of(context).maybePop();
    }
  }

  Future<void> _addNote(BuildContext context, AppLocalizations l10n) async {
    final controller = TextEditingController();
    var date = DateTime.now();
    String? error;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final locale = Localizations.localeOf(ctx).toString();
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.courseNoteAdd, style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.courseNoteDate),
                  trailing: Text(DateFormat.yMMMEd(locale).format(date)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setModal(() => date = picked);
                  },
                ),
                TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(hintText: l10n.courseNoteHint),
                ),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(error!, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
                ],
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      setModal(() => error = l10n.courseNoteRequired);
                      return;
                    }
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text(l10n.tugasSave),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (saved == true) {
      final ts = DateTime.now().toUtc();
      final ymd = DateFormat('yyyy-MM-dd').format(date);
      await db.mataKuliahDao.insertCourseNote(CourseNoteCompanion.insert(
        id: DeterministicId.v4(),
        createdAt: ts,
        updatedAt: ts,
        mataKuliahId: courseId,
        tanggal: ymd,
        isi: controller.text.trim(),
      ));
    }
    controller.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
