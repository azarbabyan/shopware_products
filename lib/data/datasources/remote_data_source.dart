import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../../core/error/exceptions.dart';

abstract class RemoteDataSource {
  Future<List<ProductModel>> fetchProducts({
    required int page,
    required int limit,
    List<Map<String, dynamic>>? filters,
    List<Map<String, dynamic>>? sorts,
    List<Map<String, dynamic>>? postFilters,
    Map<String, dynamic>? associations,
    List<Map<String, dynamic>>? aggregations,
    List<String>? grouping,
    List<String>? fields,
    int totalCountMode = 0,
  });
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final Dio dio;
  RemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductModel>> fetchProducts({
    required int page,
    required int limit,
    List<Map<String, dynamic>>? filters,
    List<Map<String, dynamic>>? sorts,
    List<Map<String, dynamic>>? postFilters,
    Map<String, dynamic>? associations,
    List<Map<String, dynamic>>? aggregations,
    List<String>? grouping,
    List<String>? fields,
    int totalCountMode = 0,
  }) async {
    final body = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (filters != null && filters.isNotEmpty) 'filter': filters,
      if (sorts != null && sorts.isNotEmpty) 'sort': sorts,
      if (postFilters != null && postFilters.isNotEmpty)
        'post-filter': postFilters,
      if (associations != null) 'associations': associations,
      if (aggregations != null && aggregations.isNotEmpty)
        'aggregations': aggregations,
      if (grouping != null && grouping.isNotEmpty) 'grouping': grouping,
      if (fields != null && fields.isNotEmpty) 'fields': fields,
      'total-count-mode': totalCountMode,
    };

    try {
      final response = await dio.post('/product', data: body);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final elements = data['elements'] as List<dynamic>?;
        if (elements == null) {
          throw ServerException();
        }
        return elements
            .cast<Map<String, dynamic>>()
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } else {
        throw ServerException();
      }
    } on DioException catch (e) {
      throw ServerException();
    }
  }
}
