import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/product_repository_impl.dart';
import '../../domain/product.dart';
import '../../domain/product_repository.dart';

// Singleton-ish: one DioClient for the whole app.
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

// The UI and other providers depend on the *interface*, never the impl directly.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(dioClientProvider));
});


class ProductListNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return _fetch();
  }

  Future<List<Product>> _fetch() async {
    final repo = ref.read(productRepositoryProvider);
    final result = await repo.getAllProducts();
    return result.fold(
      (failure) => throw failure, // AsyncNotifier converts thrown errors into AsyncError for you
      (products) => products,
    );
  }

  // Called by pull-to-refresh
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(
  ProductListNotifier.new,
);

class CategoriesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final repo = ref.read(productRepositoryProvider);
    final result = await repo.getCategories();
    return result.fold((f) => throw f, (categories) => categories);
  }
}

final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<String>>(
  CategoriesNotifier.new,
);

// Plain synchronous state — replaces what used to be StateProvider in 2.x.
class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null; // null = "All"

  void select(String? category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
  SelectedCategoryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productListProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return productsAsync.whenData((products) {
    return products.where((p) {
      final matchesCategory =
          selectedCategory == null || p.category == selectedCategory;
      final matchesQuery = query.isEmpty || p.title.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  });
});