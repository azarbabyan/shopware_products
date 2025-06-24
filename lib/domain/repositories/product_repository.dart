import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String sort = 'name:asc',
    double? minPrice,
    double? maxPrice,
    String? productType,
  });
}
