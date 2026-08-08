import '../../../core/network/dio_client.dart';
import '../../../core/network/result.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DioClient dioClient;

  ProductRepositoryImpl(this.dioClient);

  @override
  Future<Result<List<Product>>> getAllProducts() {
    return dioClient.safeCall<List<Product>>(
      () => dioClient.dio.get('/products'),
      (data) => (data as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Result<List<String>>> getCategories() {
    return dioClient.safeCall<List<String>>(
      () => dioClient.dio.get('/products/categories'),
      (data) => (data as List).map((e) => e as String).toList(),
    );
  }

  @override
  Future<Result<List<Product>>> getProductsByCategory(String category) {
    return dioClient.safeCall<List<Product>>(
      () => dioClient.dio.get('/products/category/$category'),
      (data) => (data as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }
}