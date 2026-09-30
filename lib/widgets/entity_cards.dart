import 'package:flutter/material.dart';

class EntityCards<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;

  const EntityCards({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final item = items[i];
        final isSelected = selected.contains(idOf(item));
        return Card(
          margin: EdgeInsets.zero,
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.08)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onToggleSelect != null)
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggleSelect!(idOf(item)),
                  ),
                Expanded(child: itemBuilder(item)),
              ],
            ),
          ),
        );
      },
    );
  }
}