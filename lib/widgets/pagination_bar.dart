import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int size;
  final void Function(int page)? onPage;
  final void Function(int size)? onSize;

  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.size,
    this.onPage,
    this.onSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: page > 1 && onPage != null ? () => onPage!(1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: page > 1 && onPage != null ? () => onPage!(page - 1) : null,
          ),
          Text('Страница $page из $totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: page < totalPages && onPage != null ? () => onPage!(page + 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: page < totalPages && onPage != null ? () => onPage!(totalPages) : null,
          ),
          const SizedBox(width: 16),
          Text('Всего: $total'),
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: size,
            onChanged: onSize == null ? null : (v) => v != null ? onSize!(v) : null,
            items: const [
              DropdownMenuItem(value: 10, child: Text('10 / стр.')),
              DropdownMenuItem(value: 25, child: Text('25 / стр.')),
              DropdownMenuItem(value: 50, child: Text('50 / стр.')),
            ],
          ),
        ],
      ),
    );
  }
}