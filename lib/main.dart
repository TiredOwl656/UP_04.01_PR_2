import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'repositories/brand_repository.dart';
import 'repositories/in_memory_brand_repository.dart';
import 'repositories/in_memory_product_repository.dart';
import 'repositories/product_repository.dart';
import 'state/brand_list_notifier.dart';
import 'state/product_list_notifier.dart';

void main() {
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        Provider<ProductRepository>(create: (_) => InMemoryProductRepository()),
        Provider<BrandRepository>(create: (_) => InMemoryBrandRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              ProductListNotifier(context.read<ProductRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              BrandListNotifier(context.read<BrandRepository>())..load(),
        ),
      ],
      child: const LibraryApp(),
    ),
  );
}