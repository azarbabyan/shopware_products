import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';
import '../../core/error/failures.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;

  ProductBloc({required this.getProducts}) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final Either<Failure, List<Product>> failureOrProducts = await getProducts(
      GetProductsParams(
        categoryId: event.categoryId,
        page: event.page,
        limit: event.limit,
        sort: event.sort,
      ),
    );
    failureOrProducts.fold(
      (failure) => emit(
        ProductError(
          message: failure is ServerFailure ? 'Server error' : 'No cached data',
        ),
      ),
      (products) => emit(ProductLoaded(products: products)),
    );
  }
}
