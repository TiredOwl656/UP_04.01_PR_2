import 'package:flutter/material.dart';
import 'entity_table.dart';
import 'entity_cards.dart';

class AdaptiveEntityView<T> extends StatelessWidget {
  final List<T> items;
  final List<TableColumnSpec<T>> columns;
  final Widget Function(T item) cardBuilder;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;
  final bool Function(T item)? isDeleted;

  const AdaptiveEntityView({
    super.key,
    required this.items,
    required this.columns,
    required this.cardBuilder,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
    this.isDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    if (isNarrow) {
      return EntityCards<T>(
        items: items,
        idOf: idOf,
        selected: selected,
        onToggleSelect: onToggleSelect,
        itemBuilder: (item) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cardBuilder(item),
            if (actions != null)
              Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!(item)),
          ],
        ),
      );
    }
    return EntityTable<T>(
      items: items,
      columns: columns,
      idOf: idOf,
      selected: selected,
      onToggleSelect: onToggleSelect,
      sortField: sortField,
      sortAscending: sortAscending,
      onSort: onSort,
      actions: actions,
      isDeleted: isDeleted,
    );
  }
}