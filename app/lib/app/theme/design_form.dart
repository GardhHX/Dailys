import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class DesignField extends StatelessWidget {
  const DesignField({super.key, required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 7),
          child,
        ],
      );
}

class DesignModal extends StatelessWidget {
  const DesignModal(
      {super.key,
      required this.title,
      required this.children,
      required this.onSave,
      required this.saveLabel,
      this.titleSize = 19,
      this.busy = false,
      this.showSave = true});
  final String title;
  final List<Widget> children;
  final VoidCallback? onSave;
  final String saveLabel;
  final double titleSize;
  final bool busy;
  final bool showSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final horizontal = MediaQuery.sizeOf(context).width <= 440 ? 16.0 : 22.0;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 12),
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontSize: titleSize))),
          IconButton(
              tooltip: l10n.closeDialog,
              onPressed: busy ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close)),
        ]),
      ),
      const Divider(height: 1),
      Flexible(
          child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children),
      )),
      const Divider(height: 1),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 16),
          child: Align(
              alignment: Alignment.centerRight,
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton(
                    onPressed: busy ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.actionCancel)),
                if (showSave)
                  FilledButton(
                      onPressed: busy ? null : onSave, child: Text(saveLabel)),
              ]))),
    ]);
  }
}
