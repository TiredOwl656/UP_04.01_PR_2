const _unset = Object();

class ProductQuery {
  final String search;
  final int? categoryId;
  final int? brandId;
  final int? yearFrom;
  final int? yearTo;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const ProductQuery({
    this.search = '',
    this.categoryId,
    this.brandId,
    this.yearFrom,
    this.yearTo,
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  ProductQuery copyWith({
    String? search,
    Object? categoryId = _unset,
    Object? brandId = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return ProductQuery(
      search: search ?? this.search,
      categoryId: categoryId == _unset ? this.categoryId : categoryId as int?,
      brandId: brandId == _unset ? this.brandId : brandId as int?,
      yearFrom: yearFrom == _unset ? this.yearFrom : yearFrom as int?,
      yearTo: yearTo == _unset ? this.yearTo : yearTo as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      // Любое изменение условий отбора возвращает на первую страницу
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  /// Явный сброс страницы (например, при клике по пагинации).
  ProductQuery withPage(int p) => copyWith(page: p);

  Map<String, String> toQueryParams() => {
        if (search.isNotEmpty) 'search': search,
        if (categoryId != null) 'categoryId': '$categoryId',
        if (brandId != null) 'brandId': '$brandId',
        if (yearFrom != null) 'yearFrom': '$yearFrom',
        if (yearTo != null) 'yearTo': '$yearTo',
        'sort': '$sortField,${sortAscending ? "asc" : "desc"}',
        'page': '$page',
        'size': '$size',
        if (includeDeleted) 'includeDeleted': 'true',
      };

  factory ProductQuery.fromQueryParams(Map<String, String> q) {
    String? s(String k) => q[k];
    int? i(String k) => q[k] == null ? null : int.tryParse(q[k]!);

    var sortField = 'name';
    var sortAsc = true;
    final sort = s('sort');
    if (sort != null && sort.contains(',')) {
      final parts = sort.split(',');
      sortField = parts[0];
      sortAsc = parts.length < 2 || parts[1] != 'desc';
    }

    return ProductQuery(
      search: s('search') ?? '',
      categoryId: i('categoryId'),
      brandId: i('brandId'),
      yearFrom: i('yearFrom'),
      yearTo: i('yearTo'),
      sortField: sortField,
      sortAscending: sortAsc,
      page: i('page') ?? 1,
      size: i('size') ?? 10,
      includeDeleted: s('includeDeleted') == 'true',
    );
  }
}