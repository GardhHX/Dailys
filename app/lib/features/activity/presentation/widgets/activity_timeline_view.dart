import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_kategori_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../data/activity_repository.dart';

const _hourHeight = 60.0;

/// Timeline harian sederhana — FR-1.6 (mode timeline) & FR-1.7 (color coding
/// per kategori). Cuma menampilkan activity yang punya start/end time;
/// all-day activity tetap tampil di list mode.
class ActivityTimelineView extends StatelessWidget {
  const ActivityTimelineView({super.key, required this.occurrences, required this.onTapOccurrence});

  final List<ActivityOccurrence> occurrences;
  final ValueChanged<ActivityOccurrence> onTapOccurrence;

  @override
  Widget build(BuildContext context) {
    final timed = occurrences.where((o) => !o.data.isAllDay && o.data.startTime != null).toList();

    return SingleChildScrollView(
      child: SizedBox(
        height: _hourHeight * 24,
        child: Stack(
          children: [
            for (var hour = 0; hour < 24; hour++)
              Positioned(
                top: hour * _hourHeight,
                left: 0,
                right: 0,
                child: Container(
                  height: _hourHeight,
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Text('${hour.toString().padLeft(2, '0')}:00',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
            for (final o in timed) _buildBlock(context, o),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(BuildContext context, ActivityOccurrence o) {
    final a = o.data;
    final start = a.startTime!;
    final end = a.endTime ?? start.add(const Duration(minutes: 30));
    final top = (start.hour + start.minute / 60) * _hourHeight;
    final height = ((end.difference(start).inMinutes) / 60) * _hourHeight;
    // DESIGN.md v2 Section 2.4 — kategori dibedakan lewat ikon + aksen tipis
    // (bar kiri), bukan lagi fill besar warna kategori seperti v1.
    final accent = AppColors.kategoriColor(a.kategori);
    final scheme = Theme.of(context).colorScheme;

    return Positioned(
      top: top,
      left: 56,
      right: 8,
      height: height.clamp(20, double.infinity),
      child: GestureDetector(
        onTap: () => onTapOccurrence(o),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border(left: BorderSide(color: accent, width: 3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(kategoriIcon(a.kategori), size: 12, color: accent),
              const SizedBox(width: 4),
              if (o.isVirtual) ...[
                Icon(Icons.repeat, size: 12, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  a.judul,
                  style: TextStyle(color: scheme.onSurface, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
