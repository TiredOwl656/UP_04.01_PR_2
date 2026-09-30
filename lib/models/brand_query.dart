const _unsetB = Object();

class BrandQuery {
  final String search;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const BrandQuery({
    this.search = '',
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  BrandQuery copyWith({
    String? search,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return BrandQuery(
      search: search ?? this.search,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  BrandQuery withPage(int p) => copyWith(page: p);

  Map<String, String> toQueryParams() => {
        if (search.isNotEmpty) 'search': search,
        'sort': '$sortField,${sortAscending ? "asc" : "desc"}',
        'page': '$page',
        'size': '$size',
        if (includeDeleted) 'includeDeleted': 'true',
      };

  factory BrandQuery.fromQueryParams(Map<String, String> q) {
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

    return BrandQuery(
      search: s('search') ?? '',
      sortField: sortField,
      sortAscending: sortAsc,
      page: i('page') ?? 1,
      size: i('size') ?? 10,
      includeDeleted: s('includeDeleted') == 'true',
    );
  }
}

// Чтобы анализатор не ругался на неиспользуемую константу
// ignore: unused_element
const _ = _unsetB;