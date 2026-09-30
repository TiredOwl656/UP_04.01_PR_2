import 'package:flutter/material.dart';
import '../state/product_list_notifier.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class EmptyView extends StatelessWidget {
  final String message;
  const EmptyView({super.key, this.message = 'Ничего не найдено'});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Попробуйте изменить условия отбора',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorView({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Повторить')),
            ],
          ],
        ),
      );
}

/// Универсальный переключатель состояний.
Widget buildStateView({
  required LoadStatus status,
  required bool isEmpty,
  required String? error,
  required Widget Function() onData,
  VoidCallback? onRetry,
}) {
  switch (status) {
    case LoadStatus.idle:
    case LoadStatus.loading:
      return const LoadingView();
    case LoadStatus.error:
      return ErrorView(message: error ?? 'Ошибка', onRetry: onRetry);
    case LoadStatus.success:
      return isEmpty ? const EmptyView() : onData();
  }
}