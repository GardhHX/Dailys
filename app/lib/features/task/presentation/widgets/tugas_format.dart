import '../../../../core/theme/app_colors.dart';

const prioritasLabels = {'low': 'Low', 'medium': 'Medium', 'high': 'High'};
const prioritasColors = {
  'low': AppColors.priorityLow,
  'medium': AppColors.priorityMedium,
  'high': AppColors.priorityHigh,
};

const statusLabels = {'belum': 'Not started', 'progress': 'Progress', 'selesai': 'Done'};

/// FR-6.8 — countdown visual. Format dikonfirmasi dari screenshot Tugas List
/// yang dikirim user ("2 days left", "10 days left", "Overdue by 1d").
String countdownLabel(DateTime deadline) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
  final diff = deadlineDay.difference(today).inDays;

  if (diff == 0) return 'Due today';
  if (diff == 1) return '1 day left';
  if (diff > 1) return '$diff days left';
  return 'Overdue by ${-diff}d';
}

/// FR-6.9 — overdue = deadline lewat & belum selesai.
bool isOverdue(DateTime deadline, String status) {
  return status != 'selesai' && deadline.isBefore(DateTime.now());
}

String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

List<int> decodeReminderOffsets(String encoded) => encoded
    .replaceAll(RegExp(r'[\[\]\s]'), '')
    .split(',')
    .where((s) => s.isNotEmpty)
    .map(int.parse)
    .toList();
