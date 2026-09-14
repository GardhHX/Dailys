import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_cubit.dart';
import 'onboarding_state.dart';

/// First-run onboarding (design/screens/onboarding.md, M1 subset: stage 1
/// "Bahasa & waktu" and stage 4 "Ringkasan & mulai"; stages 2/3 are M2/M4).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.db,
    required this.userId,
    required this.deviceId,
    required this.onCompleted,
  });

  final AppDatabase db;
  final String userId;
  final String deviceId;
  final VoidCallback onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingCubit _cubit;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _cubit = OnboardingCubit(
        db: widget.db, userId: widget.userId, deviceId: widget.deviceId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state.completed) widget.onCompleted();
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            toolbarHeight: 68,
            shape: Border(
                bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant)),
            title: Text(l10n.appWordmark,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1))),
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          final mobile = constraints.maxWidth <= 680;
          final form = _step == 0
              ? _LanguageTimeStep(
                  l10n: l10n,
                  state: state,
                  onLanguageChanged: _cubit.selectLanguage,
                  onTimezoneChanged: _cubit.selectTimezone,
                  onContinue: () => setState(() => _step = 1))
              : _SummaryStep(
                  l10n: l10n,
                  state: state,
                  onBack: () => setState(() => _step = 0),
                  onFinish: _cubit.finish);
          final colors = Theme.of(context).colorScheme;
          final localInfo = Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(9)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.onboardingLocalTitle,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colors.onPrimary)),
                    const SizedBox(height: 16),
                    Text(l10n.onboardingLocalBody,
                        style: TextStyle(color: colors.onPrimary, height: 1.5)),
                  ]));
          return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: mobile ? 16 : 28, vertical: 32),
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l10n.onboardingIntro,
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 6),
                            Text(
                                _step == 0
                                    ? l10n.onboardingHeading
                                    : l10n.onboardingSummaryTitle,
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 24),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                    2,
                                    (i) => Expanded(
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                right: i == 0 ? 8 : 0),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      height: 3,
                                                      color: i == _step
                                                          ? colors.primary
                                                          : colors
                                                              .outlineVariant),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                      '${i + 1} · ${i == 0 ? l10n.onboardingTitleLanguageTime : l10n.onboardingSummaryTitle}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall),
                                                ]))))),
                            const SizedBox(height: 32),
                            if (mobile) ...[
                              form,
                              const SizedBox(height: 28),
                              localInfo
                            ] else
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: form),
                                    const SizedBox(width: 38),
                                    SizedBox(width: 280, child: localInfo)
                                  ]),
                          ]))));
        })),
      ),
    );
  }
}

class _LanguageTimeStep extends StatelessWidget {
  const _LanguageTimeStep({
    required this.l10n,
    required this.state,
    required this.onLanguageChanged,
    required this.onTimezoneChanged,
    required this.onContinue,
  });

  final AppLocalizations l10n;
  final OnboardingState state;
  final ValueChanged<Language> onLanguageChanged;
  final ValueChanged<String> onTimezoneChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.onboardingLanguageLabel,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<Language>(
          segments: [
            ButtonSegment(
                value: Language.id, label: Text(l10n.onboardingLanguageId)),
            ButtonSegment(
                value: Language.en, label: Text(l10n.onboardingLanguageEn)),
          ],
          selected: {state.language},
          onSelectionChanged: (s) => onLanguageChanged(s.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.onboardingTimezoneLabel,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
            builder: (context, constraints) => DropdownMenu<String>(
                  initialSelection: state.timezone,
                  width: constraints.maxWidth,
                  enableFilter: true,
                  requestFocusOnTap: true,
                  dropdownMenuEntries: state.availableTimezones
                      .map((tz) => DropdownMenuEntry(value: tz, label: tz))
                      .toList(),
                  onSelected: (v) {
                    if (v != null) onTimezoneChanged(v);
                  },
                )),
        const SizedBox(height: 16),
        Text(l10n.onboardingZoneHint,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xxl),
        const Divider(),
        const SizedBox(height: 16),
        Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
                onPressed: onContinue, child: Text(l10n.actionContinue))),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({
    required this.l10n,
    required this.state,
    required this.onBack,
    required this.onFinish,
  });

  final AppLocalizations l10n;
  final OnboardingState state;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final languageLabel = state.language == Language.id
        ? l10n.onboardingLanguageId
        : l10n.onboardingLanguageEn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.onboardingSummaryLanguage(languageLabel)),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.onboardingSummaryTimezone(state.timezone)),
        if (state.error != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.saving ? null : onBack,
                child: Text(l10n.actionBack),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: state.saving ? null : onFinish,
                child: state.saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.actionFinish),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
