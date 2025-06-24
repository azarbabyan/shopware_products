import 'package:dartz/dartz.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../datasources/remote_data_source.dart';
import '../datasources/local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  ProductRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String sort = 'name:asc',
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.fetchProducts(
          page: page,
          limit: limit,
        );
        localDataSource.cacheProducts(categoryId, remote);
        return Right(remote);
      } catch (_) {
        return Left(ServerFailure());
      }
    } else {
      try {
        final local = await localDataSource.getCachedProducts(categoryId);
        return Right(local);
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }
}
