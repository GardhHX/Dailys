import '../../core/db/tables/enums.dart';
import '../../l10n/app_localizations.dart';

/// Localized labels for Tugas enums (schema 5), shared across the list, detail,
/// and form.
String tugasStatusLabel(TugasStatus status, AppLocalizations l10n) =>
    switch (status) {
      TugasStatus.belum => l10n.tugasStatusBelum,
      TugasStatus.progress => l10n.tugasStatusProgress,
      TugasStatus.selesai => l10n.tugasStatusSelesai,
    };

String tugasPriorityLabel(TugasPrioritas p, AppLocalizations l10n) =>
    switch (p) {
      TugasPrioritas.low => l10n.tugasPriorityLow,
      TugasPrioritas.medium => l10n.tugasPriorityMedium,
      TugasPrioritas.high => l10n.tugasPriorityHigh,
    };
