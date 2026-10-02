import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/brand.dart';
import '../models/brand_query.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/supplier.dart';
import '../repositories/brand_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/persistent_product_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/supplier_repository.dart';
import '../validators/validators.dart';
import '../widgets/entity_form.dart';

class ProductFormScreen extends StatefulWidget {
  final int? id;
  const ProductFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  Product? _existing;
  bool _loading = true;

  int? _brandId;
  int? _supplierId;
  List<int> _categoryIds = [];

  List<Brand> _brands = [];
  List<ProductCategory> _categories = [];
  List<Supplier> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Сначала фиксируем все репозитории — пока не было await.
    final productRepo = context.read<ProductRepository>();
    final brandRepo = context.read<BrandRepository>();
    final categoryRepo = context.read<CategoryRepository>();
    final supplierRepo = context.read<SupplierRepository>();

    if (widget.id != null) {
      _existing = await productRepo.findById(widget.id!);
      _brandId = _existing?.brandId;
      _supplierId = _existing?.supplierId;
      _categoryIds = List<int>.from(_existing?.categoryIds ?? []);
    }

    _brands = (await brandRepo.find(const BrandQuery())).items;
    _categories = await categoryRepo.findAll();
    _suppliers = await supplierRepo.findAll();

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return EntityForm(
      title: widget.isEditing ? 'Редактирование товара' : 'Новый товар',
      submitLabel: widget.isEditing ? 'Сохранить' : 'Создать',
      fields: [
        FormFieldSpec(
          key: 'name',
          label: 'Название',
          initialValue: _existing?.name ?? '',
          validator: V.compose([
            V.required('Название'),
            V.minLength(2, 'Название'),
            V.maxLength(120, 'Название'),
          ]),
        ),
        FormFieldSpec(
          key: 'sku',
          label: 'Артикул',
          initialValue: _existing?.sku ?? '',
          validator: V.compose([
            V.required('Артикул'),
            V.maxLength(32, 'Артикул'),
          ]),
        ),
        FormFieldSpec(
          key: 'price',
          label: 'Цена, руб.',
          initialValue: _existing?.price.toStringAsFixed(0) ?? '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: V.compose([
            V.required('Цена'),
            V.positiveNumber('Цена'),
          ]),
        ),
        FormFieldSpec(
          key: 'stock',
          label: 'Остаток на складе',
          initialValue: _existing?.stock.toString() ?? '',
          keyboardType: TextInputType.number,
          validator: V.compose([
            V.required('Остаток'),
            V.intRange(0, 100000, 'Остаток'),
          ]),
        ),
        FormFieldSpec(
          key: 'size',
          label: 'Размер',
          initialValue: _existing?.size ?? '',
          validator: V.compose([
            V.required('Размер'),
            V.maxLength(8, 'Размер'),
          ]),
        ),
        FormFieldSpec(
          key: 'color',
          label: 'Цвет',
          initialValue: _existing?.color ?? '',
          validator: V.maxLength(32, 'Цвет'),
        ),
        FormFieldSpec(
          key: 'year',
          label: 'Год коллекции',
          initialValue: _existing?.year.toString() ?? '',
          keyboardType: TextInputType.number,
          validator: V.year(),
        ),
      ],
      beforeFields: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _brandId,
            decoration: const InputDecoration(
              labelText: 'Бренд',
              border: OutlineInputBorder(),
            ),
            items: _brands
                .map((b) => DropdownMenuItem<int>(
                      value: b.id,
                      child: Text(b.name),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _brandId = v),
            validator: (v) => v == null ? 'Выберите бренд' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _supplierId,
            decoration: const InputDecoration(
              labelText: 'Поставщик',
              border: OutlineInputBorder(),
            ),
            items: _suppliers
                .map((s) => DropdownMenuItem<int>(
                      value: s.id,
                      child: Text(s.name),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _supplierId = v),
            validator: (v) => v == null ? 'Выберите поставщика' : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
      afterFields: FormField<List<int>>(
        initialValue: _categoryIds,
        validator: (value) => (value == null || value.isEmpty)
            ? 'Выберите хотя бы одну категорию'
            : null,
        builder: (field) => InputDecorator(
          decoration: InputDecoration(
            labelText: 'Категории',
            border: const OutlineInputBorder(),
            errorText: field.errorText,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((c) {
              final selected = field.value!.contains(c.id);
              return FilterChip(
                label: Text(c.name),
                selected: selected,
                onSelected: (_) {
                  final next = [...field.value!];
                  selected ? next.remove(c.id) : next.add(c.id);
                  field.didChange(next);
                  setState(() => _categoryIds = next);
                },
              );
            }).toList(),
          ),
        ),
      ),
      onSubmit: (values) async {
        final repo = context.read<ProductRepository>();
        final router = GoRouter.of(context);
        final sku = values['sku']!;

        if (repo is PersistentProductRepository) {
          final taken = await repo.isSkuTaken(sku, exceptId: widget.id);
          if (taken) {
            throw Exception(
                'Артикул "$sku" уже используется другим товаром');
          }
        }

        final product = Product(
          id: _existing?.id ?? 0,
          name: values['name']!,
          sku: sku,
          brandId: _brandId ?? 0,
          supplierId: _supplierId ?? 0,
          categoryIds: _categoryIds,
          size: values['size']!,
          color: values['color'] ?? '',
          price: double.tryParse(values['price']!.replaceAll(',', '.')) ?? 0,
          stock: int.tryParse(values['stock']!) ?? 0,
          year: int.tryParse(values['year'] ?? '') ?? 0,
        );

        if (widget.isEditing) {
          await repo.update(product);
        } else {
          await repo.create(product);
        }

        if (!mounted) return;
        router.go('/products');
      },
    );
  }
}