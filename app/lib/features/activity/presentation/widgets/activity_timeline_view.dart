import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
    final color = AppColors.kategoriColor(a.kategori);

    return Positioned(
      top: top,
      left: 56,
      right: 8,
      height: height.clamp(20, double.infinity),
      child: GestureDetector(
        onTap: () => onTapOccurrence(o),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (o.isVirtual) const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.repeat, size: 12, color: Colors.white),
              ),
              Flexible(
                child: Text(
                  a.judul,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
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
