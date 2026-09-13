import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/time/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../tugas/domain/next_deadline.dart';
import '../tugas/domain/tugas_history.dart';
import '../tugas/tugas_detail_screen.dart';

/// Home's Next Deadline companion panel (design/screens/home.md: "pendamping
/// Next deadline"; PRD FR-6.6, FR-6.8–FR-6.10, FR-6.17). Presents Tugas data
/// that already exists elsewhere — the nearest upcoming deadline and every
/// overdue active task — without adding scope to the Tugas tab. Tapping a
/// task opens its detail route ("Panel deadline membuka detail contoh").
class NextDeadlinePanel extends StatelessWidget {
  const NextDeadlinePanel({
    super.key,
    required this.db,
    required this.userId,
    required this.location,
  });

  final AppDatabase db;
  final String userId;
  final tz.Location location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<TugasRow>>(
      stream: db.tugasDao.watchActiveTugas(userId),
      builder: (context, snapshot) {
        final rows = snapshot.data;
        if (rows == null) return const SizedBox.shrink();

        final now = DateTime.now().toUtc();
        final today = LocalDate.fromInstant(now, location);
        final data = computeNextDeadline(
          allTugas: rows,
          classifier: TugasClassifier(location),
          today: today,
          now: now,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeNextDeadlineTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                if (data.isEmpty)
                  Text(l10n.homeNextDeadlineEmpty)
                else ...[
                  if (data.overdue.isNotEmpty) ...[
                    Text(
                      l10n.homeNextDeadlineOverdueSection,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                    _DeadlineTile(
                      tugas: data.overdue.first,
                      today: today,
                      location: location,
                      overdue: true,
                      l10n: l10n,
                      onTap: () => _open(context, data.overdue.first.id),
                    ),
                    if (data.overdue.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          l10n.homeNextDeadlineMoreOverdue(data.overdue.length - 1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    if (data.upcoming != null) const SizedBox(height: AppSpacing.sm),
                  ],
                  if (data.upcoming != null) ...[
                    Text(l10n.homeNextDeadlineUpcomingSection,
                        style: Theme.of(context).textTheme.labelLarge),
                    _DeadlineTile(
                      tugas: data.upcoming!,
                      today: today,
                      location: location,
                      overdue: false,
                      l10n: l10n,
                      onTap: () => _open(context, data.upcoming!.id),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _open(BuildContext context, String tugasId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TugasDetailScreen(
        db: db,
        userId: userId,
        location: location,
        tugasId: tugasId,
      ),
    ));
  }
}

class _DeadlineTile extends StatelessWidget {
  const _DeadlineTile({
    required this.tugas,
    required this.today,
    required this.location,
    required this.overdue,
    required this.l10n,
    required this.onTap,
  });

  final TugasRow tugas;
  final LocalDate today;
  final tz.Location location;
  final bool overdue;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deadlineLocal = LocalDate.fromInstant(tugas.deadline, location);
    final days = daysBetweenLocalDates(today, deadlineLocal);
    final countdown = overdue
        ? l10n.homeNextDeadlineDaysOverdue(-days)
        : days == 0
            ? l10n.homeNextDeadlineDueToday
            : l10n.homeNextDeadlineDaysLeft(days);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(tugas.judul, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(countdown),
      trailing: overdue
          ? Icon(Icons.warning_amber_outlined, color: Theme.of(context).colorScheme.error)
          : null,
      onTap: onTap,
    );
  }
}
