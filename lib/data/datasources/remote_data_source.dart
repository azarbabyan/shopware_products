import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../../core/error/exceptions.dart';

/// Data source for fetching products from Shopware 6 API.
abstract class RemoteDataSource {
  /// Fetches a list of products using the provided query parameters.
  ///
  /// [page] and [limit] for pagination.
  /// [filters] and [postFilters] are arrays of filter definitions.
  /// [sorts] is an array of sort definitions.
  /// [associations] for including related entities.
  /// [aggregations] for facet data.
  /// [grouping] and [fields] to limit response.
  /// [totalCountMode] controls including total count in response.
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
    } on DioError catch (e) {
      throw ServerException();
    }
  }
}
