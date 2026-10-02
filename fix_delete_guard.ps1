# fix_delete_guard.ps1
# Пункт 13 ПР3: запрет удаления связанных сущностей + фильтр удалённых.
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

function Write-File($path, $content) {
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path $PWD $path), $content, $utf8)
    Write-Host "  [write] $path" -ForegroundColor Green
}

# ===============================================================
# 1) persistent_product_repository.dart — добавить countByBrand
# ===============================================================

$path = 'lib\repositories\persistent_product_repository.dart'
$content = Get-Content $path -Raw

if ($content -notmatch 'countByBrand') {
    $anchor = @'
  Future<int> countBySupplier(int supplierId) async {
    return _products.where((p) => p.supplierId == supplierId).length;
  }
'@

    $replacement = @'
  Future<int> countBySupplier(int supplierId) async {
    return _products.where((p) => p.supplierId == supplierId).length;
  }

  Future<int> countByBrand(int brandId) async {
    return _products.where((p) => p.brandId == brandId).length;
  }
'@

    if ($content.Contains($anchor)) {
        $content = $content.Replace($anchor, $replacement)
        [System.IO.File]::WriteAllText((Join-Path $PWD $path), $content, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "  [patch] $path (добавлен countByBrand)" -ForegroundColor Green
    } else {
        Write-Host "  [warn]  ${path}: не найден якорь countBySupplier — добавь вручную" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [skip]  $path (countByBrand уже есть)" -ForegroundColor DarkGray
}

# ===============================================================
# 2) persistent_supplier_repository.dart — findAll возвращает всё
# ===============================================================

$path = 'lib\repositories\persistent_supplier_repository.dart'
$content = Get-Content $path -Raw

$old = @'
  Future<List<Supplier>> findAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_suppliers.where((s) => !s.isDeleted));
  }
'@

$new = @'
  Future<List<Supplier>> findAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Возвращаем всё; фильтр "показывать удалённые" — на экране.
    return List.unmodifiable(_suppliers);
  }
'@

if ($content.Contains($old)) {
    $content = $content.Replace($old, $new)
    [System.IO.File]::WriteAllText((Join-Path $PWD $path), $content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  [patch] $path (findAll → все записи)" -ForegroundColor Green
} else {
    Write-Host "  [warn]  ${path}: не нашёл старый findAll — проверь вручную" -ForegroundColor Yellow
}

# ===============================================================
# 3) persistent_category_repository.dart — findAll возвращает всё
# ===============================================================

$path = 'lib\repositories\persistent_category_repository.dart'
$content = Get-Content $path -Raw

$old = @'
  Future<List<ProductCategory>> findAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_categories.where((c) => !c.isDeleted));
  }
'@

$new = @'
  Future<List<ProductCategory>> findAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Возвращаем всё; фильтр "показывать удалённые" — на экране.
    return List.unmodifiable(_categories);
  }
'@

if ($content.Contains($old)) {
    $content = $content.Replace($old, $new)
    [System.IO.File]::WriteAllText((Join-Path $PWD $path), $content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  [patch] $path (findAll → все записи)" -ForegroundColor Green
} else {
    Write-Host "  [warn]  ${path}: не нашёл старый findAll — проверь вручную" -ForegroundColor Yellow
}

# ===============================================================
# 4) supplier_list_screen.dart — проверка связей + фильтр удалённых
# ===============================================================

Write-File 'lib\screens\supplier_list_screen.dart' @'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repositories/persistent_product_repository.dart';
import '../repositories/product_repository.dart';
import '../state/supplier_list_notifier.dart';
import '../widgets/state_views.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  bool _showDeleted = false;

  Future<void> _tryDelete(int id, String name) async {
    final productRepo = context.read<ProductRepository>();
    final notifier = context.read<SupplierListNotifier>();

    var linked = 0;
    if (productRepo is PersistentProductRepository) {
      linked = await productRepo.countBySupplier(id);
    }

    if (linked > 0) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Удаление невозможно'),
          content: Text(
            'На поставщика «$name» ссылаются товары: $linked шт.\n'
            'Сначала удалите или переназначьте эти товары.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
      return;
    }

    await notifier.softDelete(id);
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<SupplierListNotifier>();
    final items = _showDeleted
        ? n.items
        : n.items.where((s) => !s.isDeleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Поставщики'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/suppliers/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          CheckboxListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: const Text('Показывать удалённые'),
            value: _showDeleted,
            onChanged: (v) => setState(() => _showDeleted = v ?? false),
          ),
          const Divider(height: 1),
          Expanded(
            child: buildStateView(
              status: n.status,
              isEmpty: items.isEmpty,
              error: n.error,
              onRetry: n.load,
              onData: () => ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, i) {
                  final s = items[i];
                  final deleted = s.isDeleted;
                  return ListTile(
                    title: Text(
                      s.name,
                      style: deleted
                          ? const TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            )
                          : null,
                    ),
                    subtitle: Text('${s.country} • ${s.email} • ${s.phone}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (deleted)
                          IconButton(
                            icon: const Icon(Icons.restore),
                            tooltip: 'Восстановить',
                            onPressed: () => n.restore(s.id),
                          )
                        else ...[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                context.go('/suppliers/${s.id}/edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _tryDelete(s.id, s.name),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
'@

# ===============================================================
# 5) category_list_screen.dart — проверка связей + фильтр удалённых
# ===============================================================

Write-File 'lib\screens\category_list_screen.dart' @'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../repositories/persistent_product_repository.dart';
import '../repositories/product_repository.dart';
import '../state/category_list_notifier.dart';
import '../widgets/state_views.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  bool _showDeleted = false;

  Future<void> _tryDelete(int id, String name) async {
    final productRepo = context.read<ProductRepository>();
    final notifier = context.read<CategoryListNotifier>();

    var linked = 0;
    if (productRepo is PersistentProductRepository) {
      linked = await productRepo.countByCategory(id);
    }

    if (linked > 0) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Удаление невозможно'),
          content: Text(
            'На категорию «$name» ссылаются товары: $linked шт.\n'
            'Сначала удалите или переназначьте эти товары.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
      return;
    }

    await notifier.softDelete(id);
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<CategoryListNotifier>();
    final items = _showDeleted
        ? n.items
        : n.items.where((c) => !c.isDeleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/categories/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          CheckboxListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: const Text('Показывать удалённые'),
            value: _showDeleted,
            onChanged: (v) => setState(() => _showDeleted = v ?? false),
          ),
          const Divider(height: 1),
          Expanded(
            child: buildStateView(
              status: n.status,
              isEmpty: items.isEmpty,
              error: n.error,
              onRetry: n.load,
              onData: () => ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, i) {
                  final c = items[i];
                  final deleted = c.isDeleted;
                  return ListTile(
                    title: Text(
                      c.name,
                      style: deleted
                          ? const TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough,
                            )
                          : null,
                    ),
                    subtitle: Text(c.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (deleted)
                          IconButton(
                            icon: const Icon(Icons.restore),
                            tooltip: 'Восстановить',
                            onPressed: () => n.restore(c.id),
                          )
                        else ...[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                context.go('/categories/${c.id}/edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _tryDelete(c.id, c.name),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
'@

# ===============================================================
# 6) brand_list_screen.dart — добавить проверку _tryDelete
# ===============================================================

$path = 'lib\screens\brand_list_screen.dart'
$content = Get-Content $path -Raw

# 6.1 Импорты
if ($content -notmatch "persistent_product_repository") {
    $content = $content -replace "(import '../state/brand_list_notifier.dart';)", @"
import '../repositories/persistent_product_repository.dart';
import '../repositories/product_repository.dart';
`$1
"@
    Write-Host "  [patch] $path (импорты)" -ForegroundColor Green
}

# 6.2 Метод _tryDelete — вставляем перед build()
if ($content -notmatch "_tryDelete") {
    $anchor = @'
  @override
  Widget build(BuildContext context) {
    final n = context.watch<BrandListNotifier>();
'@

    $replacement = @'
  Future<void> _tryDelete(int id, String name) async {
    final productRepo = context.read<ProductRepository>();
    final notifier = context.read<BrandListNotifier>();

    var linked = 0;
    if (productRepo is PersistentProductRepository) {
      linked = await productRepo.countByBrand(id);
    }

    if (linked > 0) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Удаление невозможно'),
          content: Text(
            'На бренд «$name» ссылаются товары: $linked шт.\n'
            'Сначала удалите или переназначьте эти товары.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
      return;
    }

    await notifier.softDelete(id);
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<BrandListNotifier>();
'@

    if ($content.Contains($anchor)) {
        $content = $content.Replace($anchor, $replacement)
        Write-Host "  [patch] $path (добавлен _tryDelete)" -ForegroundColor Green
    } else {
        Write-Host "  [warn]  ${path}: не найден якорь build — добавь _tryDelete вручную" -ForegroundColor Yellow
    }
}

# 6.3 Заменить вызовы n.softDelete(b.id) на _tryDelete
$content = $content -replace 'onPressed:\s*\(\)\s*=>\s*n\.softDelete\(b\.id\)', 'onPressed: () => _tryDelete(b.id, b.name)'
[System.IO.File]::WriteAllText((Join-Path $PWD $path), $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "  [patch] $path (softDelete → _tryDelete)" -ForegroundColor Green

Write-Host "`nГотово. Теперь выполни:" -ForegroundColor Cyan
Write-Host "  flutter analyze" -ForegroundColor White
Write-Host "  flutter run -d chrome" -ForegroundColor White