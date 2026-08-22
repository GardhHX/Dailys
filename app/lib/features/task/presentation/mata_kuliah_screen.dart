import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/tugas_providers.dart';

/// Mata Kuliah Manage — CRUD (nama, dosen, sks, warna) — FR-6.5, FR-6.18.
class MataKuliahScreen extends ConsumerWidget {
  const MataKuliahScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(mataKuliahListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mata Kuliah')),
      body: listAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada mata kuliah.'));
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
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {MataKuliahData? editing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MataKuliahForm(editing: editing),
    );
  }
}

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
    final repo = ref.read(tugasRepositoryProvider);
    final dosen = _dosenController.text.trim();
    final sks = int.tryParse(_sksController.text.trim());

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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.editing == null ? 'Tambah Mata Kuliah' : 'Edit Mata Kuliah',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _dosenController,
                decoration: const InputDecoration(labelText: 'Dosen (opsional)'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _sksController,
                decoration: const InputDecoration(labelText: 'SKS (opsional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Warna', style: Theme.of(context).textTheme.labelLarge),
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
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _save, child: const Text('Simpan')),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
