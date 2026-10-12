import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/review.dart';
import '../repositories/supabase_review_repository.dart';

class ReviewsModerationScreen extends StatefulWidget {
  const ReviewsModerationScreen({super.key});

  @override
  State<ReviewsModerationScreen> createState() =>
      _ReviewsModerationScreenState();
}

class _ReviewsModerationScreenState extends State<ReviewsModerationScreen> {
  List<Review>? _reviews;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await context.read<SupabaseReviewRepository>().pending();
      if (!mounted) return;
      setState(() {
        _reviews = list;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _reviews = [];
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reviews = [];
        _error = 'Ошибка: $e';
      });
    }
  }

  Future<void> _setStatus(int id, String status) async {
    try {
      await context.read<SupabaseReviewRepository>().setStatus(id, status);
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _hardDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить отзыв?'),
        content: const Text('Действие необратимо.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await context.read<SupabaseReviewRepository>().hardDelete(id);
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Модерация отзывов'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: _load,
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_error!),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _load,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
          : _reviews == null
          ? const Center(child: CircularProgressIndicator())
          : _reviews!.isEmpty
          ? const Center(child: Text('Отзывов на модерации нет'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _reviews!.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, i) {
                    final r = _reviews![i];
                    return ListTile(
                      title: Text('Товар #${r.productId} — ${'★' * r.rating}'),
                      subtitle: Text(r.text),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            tooltip: 'Одобрить',
                            onPressed: () => _setStatus(r.id, 'approved'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            tooltip: 'Отклонить',
                            onPressed: () => _setStatus(r.id, 'rejected'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever),
                            tooltip: 'Удалить',
                            onPressed: () => _hardDelete(r.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
