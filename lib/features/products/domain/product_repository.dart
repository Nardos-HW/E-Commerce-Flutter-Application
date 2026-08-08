import '../../../core/network/result.dart';
import 'product.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getAllProducts();
  Future<Result<List<String>>> getCategories();
  Future<Result<List<Product>>> getProductsByCategory(String category);
  Future<Result<Product>> getProductById(int id);
}