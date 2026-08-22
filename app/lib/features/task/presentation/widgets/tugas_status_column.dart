import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../../core/theme/app_radius.dart';
import 'tugas_tile.dart';

class TugasStatusColumn extends StatelessWidget {
  const TugasStatusColumn({
    super.key,
    required this.title,
    required this.items,
    required this.mataKuliahById,
    required this.onTapTugas,
  });

  final String title;
  final List<TugasData> items;
  final Map<String, MataKuliahData> mataKuliahById;
  final ValueChanged<TugasData> onTapTugas;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
            child: Text('$title (${items.length})', style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text('Kosong', style: TextStyle(color: Theme.of(context).colorScheme.outline)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final t = items[i];
                      return TugasTile(
                        tugas: t,
                        mataKuliah: mataKuliahById[t.mataKuliahId],
                        onTap: () => onTapTugas(t),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
