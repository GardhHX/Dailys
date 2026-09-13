import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/db/tables/enums.dart';
import '../../core/time/tz_data.dart';
import '../../l10n/app_localizations.dart';
import 'settings_cubit.dart';
import 'settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(
      {super.key,
      required this.db,
      required this.userId,
      required this.deviceId});

  final AppDatabase db;
  final String userId;
  final String deviceId;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsCubit _cubit;
  final _sectionKeys = List.generate(6, (_) => GlobalKey());
  int _activeSection = 0;

  @override
  void initState() {
    super.initState();
    ensureTimeZoneDatabaseLoaded();
    _cubit = SettingsCubit(
        db: widget.db, userId: widget.userId, deviceId: widget.deviceId)
      ..load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.loading ||
            state.userSettings == null ||
            state.deviceSettings == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.settingsTitle)),
            body: Center(
                child: state.loading
                    ? const CircularProgressIndicator()
                    : Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(l10n.settingsSaveFailed),
                        TextButton(
                            onPressed: _cubit.load,
                            child: Text(l10n.actionRetry))
                      ])),
          );
        }
        final us = state.userSettings!;
        final ds = state.deviceSettings!;
        final sections = <Widget>[
          if (state.error != null)
            _ErrorBanner(messageKey: state.error!, l10n: l10n),
          _Section(
            key: _sectionKeys[0],
            title: l10n.settingsSectionAppearanceLanguage,
            children: [
              _PreferenceRow(
                  label: l10n.onboardingLanguageLabel,
                  child: _LanguagePicker(
                      value: us.language,
                      onChanged: _cubit.setLanguage,
                      l10n: l10n)),
            ],
          ),
          _Section(
            key: _sectionKeys[1],
            title: l10n.settingsSectionTimezone,
            children: [
              _PreferenceRow(
                  label: l10n.onboardingTimezoneLabel,
                  child: _TimezonePicker(
                      value: us.timezone, onChanged: _cubit.setTimezone)),
            ],
          ),
          _Section(
            key: _sectionKeys[2],
            title: l10n.settingsSectionPomodoro,
            children: [
              _FieldGrid(children: [
                _BoundedIntField(
                  label: l10n.settingsPomodoroFocusLabel,
                  value: us.pomodoroFocusMinutes,
                  onChanged: _cubit.setPomodoroFocusMinutes,
                ),
                _BoundedIntField(
                  label: l10n.settingsPomodoroShortBreakLabel,
                  value: us.pomodoroShortBreakMinutes,
                  onChanged: _cubit.setPomodoroShortBreakMinutes,
                ),
                _BoundedIntField(
                  label: l10n.settingsPomodoroLongBreakLabel,
                  value: us.pomodoroLongBreakMinutes,
                  onChanged: _cubit.setPomodoroLongBreakMinutes,
                ),
                _BoundedIntField(
                  label: l10n.settingsPomodoroLongBreakIntervalLabel,
                  value: us.pomodoroLongBreakInterval,
                  onChanged: _cubit.setPomodoroLongBreakInterval,
                ),
              ]),
            ],
          ),
          _Section(
            key: _sectionKeys[3],
            title: l10n.settingsSectionNotifications,
            children: [
              SwitchListTile(
                title: Text(l10n.settingsNotificationsEnabledLabel),
                value: us.notificationsEnabled,
                onChanged: _cubit.setNotificationsEnabled,
              ),
              _AlarmModePicker(
                  value: us.alarmMode,
                  onChanged: _cubit.setAlarmMode,
                  l10n: l10n),
            ],
          ),
          _Section(
            key: _sectionKeys[4],
            title: l10n.settingsSectionWeeklyReview,
            children: [
              _WeeklyReviewTimePicker(
                value: us.weeklyReviewTime,
                onChanged: _cubit.setWeeklyReviewTime,
                l10n: l10n,
              ),
            ],
          ),
          _Section(
            key: _sectionKeys[5],
            title: l10n.settingsSectionThisDevice,
            children: [
              _ThemePicker(
                  value: ds.theme, onChanged: _cubit.setTheme, l10n: l10n),
              _AlarmVolumeSlider(
                value: ds.alarmVolumePercent,
                onChanged: _cubit.setAlarmVolumePercent,
                l10n: l10n,
              ),
            ],
          ),
        ];
        final labels = [
          l10n.settingsSectionAppearanceLanguage,
          l10n.settingsSectionTimezone,
          l10n.settingsSectionPomodoro,
          l10n.settingsSectionNotifications,
          l10n.settingsSectionWeeklyReview,
          l10n.settingsSectionThisDevice
        ];
        return Scaffold(
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
          body: LayoutBuilder(builder: (context, constraints) {
            final mobile = constraints.maxWidth <= 680;
            final content = Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(9)),
                padding: EdgeInsets.all(mobile ? 16 : 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: sections));
            return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: mobile ? 16 : 32, vertical: 28),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.chevron_left),
                              label: Text(l10n.homeTitle))),
                      const SizedBox(height: 16),
                      Text(l10n.settingsTitle,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 6),
                      Text(l10n.settingsIntro,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 28),
                      if (mobile)
                        content
                      else
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 208,
                                  child: Padding(
                                      padding: const EdgeInsets.only(right: 22),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(l10n.settingsSections,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                            const SizedBox(height: 12),
                                            for (var i = 0;
                                                i < labels.length;
                                                i++)
                                              Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 6),
                                                  child: TextButton(
                                                      style: TextButton.styleFrom(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          backgroundColor:
                                                              _activeSection == i
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                  : Colors
                                                                      .transparent,
                                                          foregroundColor: _activeSection ==
                                                                  i
                                                              ? Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary
                                                              : Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant),
                                                      onPressed: () {
                                                        setState(() =>
                                                            _activeSection = i);
                                                        final target =
                                                            _sectionKeys[i]
                                                                .currentContext;
                                                        if (target != null) {
                                                          Scrollable.ensureVisible(
                                                              target,
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          150));
                                                        }
                                                      },
                                                      child: Text(labels[i],
                                                          style: const TextStyle(
                                                              fontSize: 12)))),
                                          ]))),
                              const SizedBox(width: 32),
                              Expanded(child: content),
                            ]),
                    ]));
          }),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant))),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.messageKey, required this.l10n});
  final String messageKey;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final text = messageKey == 'settingsValueOutOfRange'
        ? l10n.settingsValueOutOfRange
        : l10n.settingsSaveFailed;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Text(text),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker(
      {required this.value, required this.onChanged, required this.l10n});
  final Language value;
  final ValueChanged<Language> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Language>(
      segments: [
        ButtonSegment(
            value: Language.id, label: Text(l10n.onboardingLanguageId)),
        ButtonSegment(
            value: Language.en, label: Text(l10n.onboardingLanguageEn)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _TimezonePicker extends StatelessWidget {
  const _TimezonePicker({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final names = tz.timeZoneDatabase.locations.keys.toList()..sort();
    return LayoutBuilder(
        builder: (context, constraints) => DropdownMenu<String>(
              initialSelection: value,
              width: constraints.maxWidth,
              enableFilter: true,
              requestFocusOnTap: true,
              dropdownMenuEntries: names
                  .map((n) => DropdownMenuEntry(value: n, label: n))
                  .toList(),
              onSelected: (v) {
                if (v != null) onChanged(v);
              },
            ));
  }
}

class _BoundedIntField extends StatefulWidget {
  const _BoundedIntField(
      {required this.label, required this.value, required this.onChanged});
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_BoundedIntField> createState() => _BoundedIntFieldState();
}

class _BoundedIntFieldState extends State<_BoundedIntField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.toString());

  @override
  void didUpdateWidget(covariant _BoundedIntField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value.toString()) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: (text) {
          final v = int.tryParse(text);
          if (v != null) widget.onChanged(v);
        },
      ),
    );
  }
}

class _AlarmModePicker extends StatelessWidget {
  const _AlarmModePicker(
      {required this.value, required this.onChanged, required this.l10n});
  final AlarmMode value;
  final ValueChanged<AlarmMode> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: SegmentedButton<AlarmMode>(
        segments: [
          ButtonSegment(
              value: AlarmMode.sound, label: Text(l10n.settingsAlarmModeSound)),
          ButtonSegment(
              value: AlarmMode.muted, label: Text(l10n.settingsAlarmModeMuted)),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

class _WeeklyReviewTimePicker extends StatelessWidget {
  const _WeeklyReviewTimePicker({
    required this.value,
    required this.onChanged,
    required this.l10n,
  });
  final String value; // HH:mm:ss
  final ValueChanged<String> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final parts = value.split(':');
    final tod =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.settingsWeeklyReviewTimeLabel),
      trailing: Text(tod.format(context)),
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: tod);
        if (picked != null) {
          final hh = picked.hour.toString().padLeft(2, '0');
          final mm = picked.minute.toString().padLeft(2, '0');
          onChanged('$hh:$mm:00');
        }
      },
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker(
      {required this.value, required this.onChanged, required this.l10n});
  final ThemePreference value;
  final ValueChanged<ThemePreference> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemePreference>(
      segments: [
        ButtonSegment(
            value: ThemePreference.system,
            label: Text(l10n.settingsThemeSystem)),
        ButtonSegment(
            value: ThemePreference.light, label: Text(l10n.settingsThemeLight)),
        ButtonSegment(
            value: ThemePreference.dark, label: Text(l10n.settingsThemeDark)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _AlarmVolumeSlider extends StatelessWidget {
  const _AlarmVolumeSlider(
      {required this.value, required this.onChanged, required this.l10n});
  final int value;
  final ValueChanged<int> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(l10n.settingsAlarmVolumeLabel)),
          Expanded(
            flex: 2,
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '$value%',
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 440 ? 2 : 1;
        return Wrap(spacing: 16, runSpacing: 12, children: [
          for (final child in children)
            SizedBox(
                width: (constraints.maxWidth - (columns - 1) * 16) / columns,
                child: child)
        ]);
      });
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final title =
            Text(label, style: Theme.of(context).textTheme.labelLarge);
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: constraints.maxWidth >= 600
                ? Row(children: [
                    Expanded(child: title),
                    const SizedBox(width: 24),
                    SizedBox(width: 290, child: child)
                  ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [title, const SizedBox(height: 12), child]));
      });
}
