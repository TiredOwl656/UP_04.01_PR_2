import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/supabase_config.dart';
import 'repositories/brand_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/product_repository.dart';
import 'repositories/supabase_brand_repository.dart';
import 'repositories/supabase_category_repository.dart';
import 'repositories/supabase_customer_repository.dart';
import 'repositories/supabase_order_repository.dart';
import 'repositories/supabase_product_repository.dart';
import 'repositories/supabase_review_repository.dart';
import 'repositories/supabase_supplier_repository.dart';
import 'repositories/supabase_user_repository.dart';
import 'repositories/supplier_repository.dart';
import 'state/auth_notifier.dart';
import 'state/brand_list_notifier.dart';
import 'state/cart_notifier.dart';
import 'state/category_list_notifier.dart';
import 'state/customer_list_notifier.dart';
import 'state/product_list_notifier.dart';
import 'state/supplier_list_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);

  runApp(const _AppRoot());
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return MultiProvider(
      providers: [
        Provider<SupabaseClient>.value(value: supabase),
        ChangeNotifierProvider(create: (_) => AuthNotifier(supabase)),
        ChangeNotifierProvider(create: (_) => CartNotifier()),

        Provider<ProductRepository>(
          create: (_) => SupabaseProductRepository(supabase),
        ),
        Provider<BrandRepository>(
          create: (_) => SupabaseBrandRepository(supabase),
        ),
        Provider<CategoryRepository>(
          create: (_) => SupabaseCategoryRepository(supabase),
        ),
        Provider<SupplierRepository>(
          create: (_) => SupabaseSupplierRepository(supabase),
        ),
        Provider<CustomerRepository>(
          create: (_) => SupabaseCustomerRepository(supabase),
        ),
        Provider(create: (_) => SupabaseUserRepository(supabase)),
        Provider(create: (_) => SupabaseOrderRepository(supabase)),
        Provider(create: (_) => SupabaseReviewRepository(supabase)),

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
      child: const LibraryApp(), // ← из app.dart
    );
  }
}
