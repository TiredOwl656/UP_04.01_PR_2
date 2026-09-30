import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repositories/brand_repository.dart';

class BrandDetailScreen extends StatelessWidget {
  final int id;
  const BrandDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<BrandRepository>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка бренда'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/brands'),
        ),
      ),
      body: FutureBuilder(
        future: repo.findById(id),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final b = snap.data;
          if (b == null) return const Center(child: Text('Бренд не найден'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(b.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text('Страна: ${b.country}'),
              Text('Год основания: ${b.foundedYear}'),
            ],
          );
        },
      ),
    );
  }
}