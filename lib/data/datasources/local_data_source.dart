import 'package:hive/hive.dart';
import '../models/product_model.dart';
import '../../core/error/exceptions.dart';

abstract class LocalDataSource {
  Future<List<ProductModel>> getCachedProducts(String categoryId);
  Future<void> cacheProducts(String categoryId, List<ProductModel> products);
}

class LocalDataSourceImpl implements LocalDataSource {
  final Box box;
  LocalDataSourceImpl(this.box);

  @override
  Future<void> cacheProducts(
    String categoryId,
    List<ProductModel> products,
  ) async {
    final list = products.map((p) => p.toJson()).toList();
    await box.put('products_$categoryId', list);
  }

  @override
  Future<List<ProductModel>> getCachedProducts(String categoryId) {
    final list = box.get('products_$categoryId') as List?;
    if (list != null) {
      return Future.value(
        list
            .cast<Map<String, dynamic>>()
            .map((m) => ProductModel.fromJson(m))
            .toList(),
      );
    } else {
      throw CacheException();
    }
  }
}
