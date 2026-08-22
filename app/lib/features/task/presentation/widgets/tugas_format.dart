import '../../../../core/theme/app_colors.dart';

const prioritasLabels = {'low': 'Low', 'medium': 'Medium', 'high': 'High'};
const prioritasColors = {
  'low': AppColors.priorityLow,
  'medium': AppColors.priorityMedium,
  'high': AppColors.priorityHigh,
};

const statusLabels = {'belum': 'Belum Dikerjakan', 'progress': 'Progress', 'selesai': 'Selesai'};

/// FR-6.8 — countdown visual, mis. "3 hari lagi", "Hari ini", "Terlambat 2 hari".
String countdownLabel(DateTime deadline) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
  final diff = deadlineDay.difference(today).inDays;

  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Besok';
  if (diff > 1) return '$diff hari lagi';
  return 'Terlambat ${-diff} hari';
}

/// FR-6.9 — overdue = deadline lewat & belum selesai.
bool isOverdue(DateTime deadline, String status) {
  return status != 'selesai' && deadline.isBefore(DateTime.now());
}

String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

List<int> decodeReminderOffsets(String encoded) => encoded
    .replaceAll(RegExp(r'[\[\]\s]'), '')
    .split(',')
    .where((s) => s.isNotEmpty)
    .map(int.parse)
    .toList();
