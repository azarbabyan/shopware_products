import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts
    implements UseCase<Either<Failure, List<Product>>, GetProductsParams> {
  final ProductRepository repository;
  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) {
    return repository.getProducts(
      categoryId: params.categoryId,
      page: params.page,
      limit: params.limit,
      sort: params.sort,
    );
  }
}

class GetProductsParams {
  final String categoryId;
  final int page;
  final int limit;
  final String sort;
  GetProductsParams({
    required this.categoryId,
    this.page = 1,
    this.limit = 20,
    this.sort = 'name:asc',
  });
}
