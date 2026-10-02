import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';

// Репозитории
import 'repositories/brand_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/persistent_brand_repository.dart';
import 'repositories/persistent_category_repository.dart';
import 'repositories/persistent_customer_repository.dart';
import 'repositories/persistent_product_repository.dart';
import 'repositories/persistent_supplier_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/supplier_repository.dart';

// Состояние
import 'state/brand_list_notifier.dart';
import 'state/category_list_notifier.dart';
import 'state/customer_list_notifier.dart';
import 'state/product_list_notifier.dart';
import 'state/supplier_list_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // --- репозитории ---
        Provider<ProductRepository>(
          create: (_) => PersistentProductRepository(prefs),
        ),
        Provider<BrandRepository>(
          create: (_) => PersistentBrandRepository(prefs),
        ),
        Provider<CategoryRepository>(
          create: (_) => PersistentCategoryRepository(prefs),
        ),
        Provider<SupplierRepository>(
          create: (_) => PersistentSupplierRepository(prefs),
        ),
        Provider<CustomerRepository>(
          create: (_) => PersistentCustomerRepository(prefs),
        ),

        // --- состояние ---
        ChangeNotifierProvider(
          create: (c) => ProductListNotifier(c.read<ProductRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (c) => BrandListNotifier(c.read<BrandRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (c) =>
              CategoryListNotifier(c.read<CategoryRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (c) =>
              SupplierListNotifier(c.read<SupplierRepository>())..load(),
        ),
        ChangeNotifierProvider(
          create: (c) =>
              CustomerListNotifier(c.read<CustomerRepository>())..load(),
        ),
      ],
      child: const LibraryApp(),
    ),
  );
}