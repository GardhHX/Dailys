import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/form_dialog.dart';
import '../application/tugas_providers.dart';

/// Mata Kuliah Manage — CRUD (nama, dosen, sks, warna) — FR-6.5, FR-6.18.
class MataKuliahScreen extends ConsumerWidget {
  const MataKuliahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(mataKuliahListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mata Kuliah'),
        actions: [
          // Diseragamkan dgn tombol aksi utama Home/Tugas ("Add Activity"/
          // "Add Tugas") — FilledButton berlabel "Add", bukan IconButton "+"
          // polos, atas permintaan user 23 Agu 2026.
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
              onPressed: () => _showForm(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Mata Kuliah'),
            ),
          ),
        ],
      ),
      body: listAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No mata kuliah yet.'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final mk = list[i];
              return ListTile(
                leading: Container(width: 4, height: 40, color: AppColors.hexToColor(mk.warna)),
                title: Text(mk.nama),
                subtitle: Text([
                  if (mk.dosen != null && mk.dosen!.isNotEmpty) mk.dosen!,
                  if (mk.sks != null) '${mk.sks} SKS',
                ].join(' • ')),
                onTap: () => _showForm(context, ref, editing: mk),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref.read(tugasRepositoryProvider).deleteMataKuliah(mk.id),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {MataKuliahData? editing}) {
    showDialog(
      context: context,
      builder: (_) => _MataKuliahForm(editing: editing),
    );
  }
}

/// Form tambah/edit Mata Kuliah — tampil sebagai [AppFormDialog] (modal
/// terpusat), DIREVISI 23 Agu 2026 dari bottom sheet, konsisten dgn form
/// lain (`ActivityFormSheet`/`TugasFormSheet`/`TimeboxFormSheet`).
class _MataKuliahForm extends ConsumerStatefulWidget {
  const _MataKuliahForm({this.editing});

  final MataKuliahData? editing;

  @override
  ConsumerState<_MataKuliahForm> createState() => _MataKuliahFormState();
}

class _MataKuliahFormState extends ConsumerState<_MataKuliahForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _dosenController;
  late final TextEditingController _sksController;
  late String _warna;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _namaController = TextEditingController(text: e?.nama ?? '');
    _dosenController = TextEditingController(text: e?.dosen ?? '');
    _sksController = TextEditingController(text: e?.sks?.toString() ?? '');
    _warna = e?.warna ?? AppColors.colorToHex(AppColors.palette.first);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _dosenController.dispose();
    _sksController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(tugasRepositoryProvider);
    final dosen = _dosenController.text.trim();
    final sks = int.tryParse(_sksController.text.trim());

    try {
      if (widget.editing != null) {
        await repo.updateMataKuliah(
          widget.editing!.id,
          nama: _namaController.text.trim(),
          dosen: dosen,
          sks: sks,
          warna: _warna,
        );
      } else {
        await repo.createMataKuliah(
          nama: _namaController.text.trim(),
          dosen: dosen.isEmpty ? null : dosen,
          sks: sks,
          warna: _warna,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: widget.editing == null ? 'Add mata kuliah' : 'Edit mata kuliah',
      saveLabel: 'Save',
      saving: _saving,
      onCancel: () => Navigator.of(context).pop(),
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(hintText: 'e.g. Statistics'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Lecturer', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            TextFormField(
              controller: _dosenController,
              decoration: const InputDecoration(hintText: 'Optional'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('SKS', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            TextFormField(
              controller: _sksController,
              decoration: const InputDecoration(hintText: 'Optional'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Color', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final color in AppColors.palette)
                  ChoiceChip(
                    label: CircleAvatar(radius: 10, backgroundColor: color),
                    selected: _warna == AppColors.colorToHex(color),
                    onSelected: (_) => setState(() => _warna = AppColors.colorToHex(color)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
