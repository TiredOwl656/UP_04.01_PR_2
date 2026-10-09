import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/review.dart';
import '../repositories/api_review_repository.dart';

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
      final list = await context.read<ApiReviewRepository>().pending();
      if (!mounted) return;
      setState(() {
        _reviews = list;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _setStatus(int id, String status) async {
    try {
      await context.read<ApiReviewRepository>().setStatus(id, status);
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Модерация отзывов')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_reviews == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Модерация отзывов')),
      body: _reviews!.isEmpty
          ? const Center(child: Text('Нет отзывов на модерации'))
          : ListView.separated(
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
                        onPressed: () => _setStatus(r.id, 'approved'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _setStatus(r.id, 'rejected'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}