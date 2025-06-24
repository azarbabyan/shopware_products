import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProducts extends ProductEvent {
  final String categoryId;
  final int page;
  final int limit;
  final String sort;
  FetchProducts({
    required this.categoryId,
    this.page = 1,
    this.limit = 20,
    this.sort = 'name:asc',
  });

  @override
  List<Object?> get props => [categoryId, page, limit, sort];
}
