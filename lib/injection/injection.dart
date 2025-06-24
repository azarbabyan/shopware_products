import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/network/network_info.dart';
import '../data/datasources/local_data_source.dart';
import '../data/datasources/remote_data_source.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/usecases/get_products.dart';
import '../presentation/bloc/product_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  await Hive.initFlutter();
  final box = await Hive.openBox('cacheBox');

  // Core
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(Connectivity()),
  );

  // External
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://shopware66.armdev.am/store-api',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'sw-access-key': 'SWSCYWNMWHVYOGKZQMNTYTC1QW',
        },
      ),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl(box));

  // Repository
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      getIt<RemoteDataSource>(),
      getIt<LocalDataSource>(),
      getIt<NetworkInfo>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<GetProducts>(
    () => GetProducts(getIt<ProductRepository>()),
  );

  // BLoC
  getIt.registerFactory(() => ProductBloc(getProducts: getIt<GetProducts>()));
}
