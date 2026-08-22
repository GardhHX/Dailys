import 'package:flutter/material.dart';

/// Modal terpusat untuk semua form tambah/edit (Activity, Tugas, Timebox,
/// Mata Kuliah) — DIREVISI 23 Agu 2026: sebelumnya tiap form pakai
/// `showModalBottomSheet` sendiri-sendiri (naik dari bawah), ternyata file
/// desain menunjukkan modal terpusat di tengah layar (`Dialog`), dikonfirmasi
/// langsung dari screenshot "Add activity" yang dikirim user. Widget ini
/// dibuat supaya ke-4 form tidak duplikasi boilerplate shape/tombol
/// Cancel-Save, dan supaya perubahan gaya modal ke depannya cuma di 1 tempat.
class AppFormDialog extends StatelessWidget {
  const AppFormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.onCancel,
    required this.onSave,
    required this.saveLabel,
    this.saving = false,
  });

  final String title;
  final Widget child;
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final String saveLabel;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                child,
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Override minimumSize — theme default OutlinedButton
                    // punya width infinite (dirancang utk full-width di
                    // form lain), crash kalau dipakai langsung di Row.
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                      onPressed: saving ? null : onSave,
                      child: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(saveLabel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle bergaya radio (lingkaran) — dipakai utk boolean single-option
/// seperti "All day / no specific time" & "Recurring" di file desain,
/// BUKAN `Switch` seperti draft sebelumnya. `Checkbox` dgn `shape:
/// CircleBorder()` dipilih drpd `Radio` karena semantiknya memang boolean
/// tunggal (bukan pilihan eksklusif antar 2+ opsi terlihat).
class RadioToggleRow extends StatelessWidget {
  const RadioToggleRow({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              shape: const CircleBorder(),
            ),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

/// Field waktu bergaya file desain — kotak dgn border, teks jam kiri, ikon
/// jam kanan (bukan `OutlinedButton` polos teks-di-tengah seperti draft
/// sebelumnya).
class TimeFieldBox extends StatelessWidget {
  const TimeFieldBox({super.key, required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
                Icon(Icons.access_time, size: 18, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
