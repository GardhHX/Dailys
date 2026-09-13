import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import 'splash_cubit.dart';
import 'splash_state.dart';

/// Splash screen (design/screens/splash.md). Transient, no app bar/nav, no
/// network, no permission prompts. Identity + a single status line, with a
/// progress affordance only when real work is happening, and a plain-text
/// failure state with retry.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onReady, this.databaseOpener});

  final void Function(
    SplashDestination destination,
    AppDatabase db,
    String userId,
    String deviceId,
  ) onReady;

  /// Overrides how the database is opened; used by tests to avoid touching
  /// `path_provider`/real disk. Production always uses the default.
  final Future<AppDatabase> Function()? databaseOpener;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SplashCubit(databaseOpener: widget.databaseOpener)..start();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<SplashCubit, SplashState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state.stage == SplashStage.ready) {
          widget.onReady(state.destination!, state.db!, state.userId!, state.deviceId!);
        }
      },
      builder: (context, state) => Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: _buildContent(context, l10n, state),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, SplashState state) {
    final theme = Theme.of(context);
    final wordmark = Text(
      l10n.appWordmark,
      textAlign: TextAlign.center,
      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
    );

    if (state.stage == SplashStage.failed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: wordmark),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            _failureMessage(l10n, state.failureReasonKey),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.retriable)
            ElevatedButton(
              onPressed: () => _cubit.start(),
              child: Text(l10n.actionRetry),
            ),
        ],
      );
    }

    final statusKey = state.stage == SplashStage.newInstall
        ? l10n.splashStatusNewInstall
        : l10n.splashStatusOpening;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        wordmark,
        const SizedBox(height: AppSpacing.xxl),
        Text(
          statusKey,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  String _failureMessage(AppLocalizations l10n, String? key) {
    switch (key) {
      case 'splashIntegrityRestoreFailed':
        return l10n.splashIntegrityRestoreFailed;
      case 'splashDowngradeForbidden':
        return l10n.splashDowngradeForbidden;
      default:
        return l10n.splashOpenFailed;
    }
  }
}
