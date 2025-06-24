import 'package:dartz/dartz.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../datasources/remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  ProductRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String sort = 'name:asc',
    double? minPrice,
    double? maxPrice,
    String? productType,
  }) async {
    final filters = <Map<String, dynamic>>[];

    if (categoryId.isNotEmpty) {
      filters.add({
        'type': 'equals',
        'field': 'categoryIds',
        'value': categoryId,
      });
    }

    if ((minPrice != null && maxPrice != null) &&
        (minPrice != 0.0 || maxPrice != 1000.0)) {
      filters.add({
        'type': 'range',
        'field': 'price',
        'parameters': {'gte': minPrice, 'lte': maxPrice},
      });
    }

    if (productType != null && productType.isNotEmpty) {
      filters.add({
        'type': 'equalsAny',
        'field': 'propertyIds',
        'value': productType,
      });
    }

    final sorts = sort.split(',').map((part) {
      final kv = part.split(':');
      return {
        'field': kv[0],
        'order': kv.length > 1 ? kv[1] : 'asc',
        'naturalSorting': false,
      };
    }).toList();
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.fetchProducts(
          page: page,
          limit: limit,
          sorts: sorts,
          filters: filters,
        );
        return Right(remote);
      } catch (_) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
