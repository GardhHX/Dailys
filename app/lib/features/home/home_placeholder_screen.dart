import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../settings/settings_screen.dart';
import '../../core/db/database.dart';

/// Temporary stand-in for Home/Today until `features/activity` (M1-PLAN
/// Section 5, the next step after settings/onboarding/splash) is built. Not a
/// generic redesign of a spec'd screen — Home has its own spec
/// (design/screens/home.md) that this does not attempt to fulfill.
class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({
    super.key,
    required this.db,
    required this.userId,
    required this.deviceId,
  });

  final AppDatabase db;
  final String userId;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homePlaceholderTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(db: db, userId: userId, deviceId: deviceId),
              ),
            ),
          ),
        ],
      ),
      body: Center(child: Text(l10n.homePlaceholderBody)),
    );
  }
}
