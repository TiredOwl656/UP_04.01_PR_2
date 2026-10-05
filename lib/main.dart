import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/api_client.dart';
import 'repositories/api_brand_repository.dart';
import 'repositories/api_category_repository.dart';
import 'repositories/api_customer_repository.dart';
import 'repositories/api_product_repository.dart';
import 'repositories/api_supplier_repository.dart';
import 'repositories/brand_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/supplier_repository.dart';
import 'state/brand_list_notifier.dart';
import 'state/category_list_notifier.dart';
import 'state/customer_list_notifier.dart';
import 'state/product_list_notifier.dart';
import 'state/supplier_list_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>(create: (_) => buildDio()),

        Provider<ProductRepository>(
          create: (c) => ApiProductRepository(c.read<Dio>()),
        ),
        Provider<BrandRepository>(
          create: (c) => ApiBrandRepository(c.read<Dio>()),
        ),
        Provider<CategoryRepository>(
          create: (c) => ApiCategoryRepository(c.read<Dio>()),
        ),
        Provider<SupplierRepository>(
          create: (c) => ApiSupplierRepository(c.read<Dio>()),
        ),
        Provider<CustomerRepository>(
          create: (c) => ApiCustomerRepository(c.read<Dio>()),
        ),

        ChangeNotifierProvider(
          create: (c) =>
              ProductListNotifier(c.read<ProductRepository>())..load(),
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