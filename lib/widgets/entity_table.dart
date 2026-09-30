import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;
  final bool Function(T item)? isDeleted;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
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
    final hasSelection = onToggleSelect != null;

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            sortColumnIndex: _sortColumnIndex(hasSelection),
            sortAscending: sortAscending,
            columns: [
              if (hasSelection) const DataColumn(label: Text('')),
              for (var i = 0; i < columns.length; i++)
                DataColumn(
                  label: Text(columns[i].label),
                  numeric: columns[i].numeric,
                  onSort: columns[i].sortField == null || onSort == null
                      ? null
                      : (_, _) => onSort!(columns[i].sortField!),
                ),
              if (actions != null) const DataColumn(label: Text('Действия')),
            ],
            rows: [
              for (final item in items)
                DataRow(
                  selected: hasSelection && selected.contains(idOf(item)),
                  color: (isDeleted?.call(item) ?? false)
                      ? WidgetStateProperty.all(
                          Colors.red.withValues(alpha: 0.08),
                        )
                      : null,
                  cells: [
                    if (hasSelection)
                      DataCell(Checkbox(
                        value: selected.contains(idOf(item)),
                        onChanged: (_) => onToggleSelect!(idOf(item)),
                      )),
                    for (final c in columns) DataCell(c.build(item)),
                    if (actions != null)
                      DataCell(Row(children: actions!(item))),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  int? _sortColumnIndex(bool hasSelection) {
    if (sortField == null) return null;
    for (var i = 0; i < columns.length; i++) {
      if (columns[i].sortField == sortField) {
        return i + (hasSelection ? 1 : 0);
      }
    }
    return null;
  }
}