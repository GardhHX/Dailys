import 'package:local_notifier/local_notifier.dart';

/// Delivers a reminder as a native OS notification (FR-1.10, FR-6.4).
///
/// `local_notifier` only shows notifications immediately — it has no
/// OS-level scheduling API, so "when" is entirely [ReminderScheduler]'s job;
/// this gateway's only responsibility is "now, put this on screen". Kept
/// behind an interface so tests can swap in a recording fake instead of
/// touching a real platform channel, and so M2 can register an
/// Android-backed implementation (`flutter_local_notifications`, which does
/// support Android/iOS/macOS — just not the Windows target M1 ships) without
/// changing any call site.
abstract class NotificationGateway {
  Future<void> initialize();

  /// Shows a notification right now. [id] only needs to be unique enough to
  /// avoid confusing simultaneous notifications; there is no cancel/update by
  /// id since nothing here is scheduled ahead of time.
  Future<void> notifyNow({required String id, required String title, required String body});
}

class LocalNotifierGateway implements NotificationGateway {
  LocalNotifierGateway({this.appName = 'Dailys'});

  final String appName;
  bool _ready = false;

  @override
  Future<void> initialize() async {
    if (_ready) return;
    // ShortcutPolicy.requireCreate (the default) registers the Start Menu
    // shortcut/AUMID Windows toast delivery needs, so there is no separate
    // native runner setup step for M1.
    await LocalNotifier.instance.setup(appName: appName);
    _ready = true;
  }

  @override
  Future<void> notifyNow({
    required String id,
    required String title,
    required String body,
  }) async {
    await initialize();
    await LocalNotification(identifier: id, title: title, body: body).show();
  }
}
