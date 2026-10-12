import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../repositories/product_repository.dart';
import '../repositories/supabase_review_repository.dart';
import '../state/auth_notifier.dart';

class ProductDetailScreen extends StatefulWidget {
  final int id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  List<Review> _reviews = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final product = await context.read<ProductRepository>().findById(
        widget.id,
      );
      final reviews = await context.read<SupabaseReviewRepository>().forProduct(
        widget.id,
      );
      if (!mounted) return;
      setState(() {
        _product = product;
        _reviews = reviews;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Ошибка: $e';
      });
    }
  }

  Future<void> _openReviewDialog() async {
    final rating = ValueNotifier<int>(5);
    final textCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Оставить отзыв'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: rating,
                builder: (_, v, __) => Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      IconButton(
                        icon: Icon(
                          i <= v ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () => rating.value = i,
                      ),
                  ],
                ),
              ),
              TextFormField(
                controller: textCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Текст отзыва',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().length < 5)
                    ? 'Не короче 5 символов'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      await context.read<SupabaseReviewRepository>().create(
        productId: widget.id,
        rating: rating.value,
        text: textCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Отзыв отправлен на модерацию')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка товара'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
        actions: [
          if (auth.canPlaceOrder && _product != null)
            IconButton(
              icon: const Icon(Icons.rate_review),
              tooltip: 'Оставить отзыв',
              onPressed: _openReviewDialog,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _product == null
          ? const Center(child: Text('Товар не найден'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _product!.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Артикул: ${_product!.sku}'),
                Text('Цена: ${_product!.price.toStringAsFixed(0)} ₽'),
                Text('Остаток: ${_product!.stock}'),
                Text('Размер: ${_product!.size}'),
                Text('Цвет: ${_product!.color}'),
                Text('Год: ${_product!.year}'),

                const SizedBox(height: 24),
                const Divider(),
                Text(
                  'Отзывы (${_reviews.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (_reviews.isEmpty)
                  const Text('Пока отзывов нет')
                else
                  for (final r in _reviews)
                    Card(
                      child: ListTile(
                        title: Text('★' * r.rating),
                        subtitle: Text(r.text),
                      ),
                    ),
              ],
            ),
    );
  }
}
