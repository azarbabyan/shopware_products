import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shopware_products/presentation/pages/filter_bottom_sheet.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  static const _pageSize = 20;
  final PagingController<int, Product> _pagingController = PagingController(
    firstPageKey: 1,
  );

  String _selectedSortValue = 'name:asc';
  final Map<String, String> _sortOptions = {
    'Name (A-Z)': 'name:asc',
    'Name (Z-A)': 'name:desc',
    'Newest First': 'createdAt:desc',
    'Price: Low to High': 'price:asc',
    'Price: High to Low': 'price:desc',
  };

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      context.read<ProductBloc>().add(
        FetchProducts(
          categoryId: _selectedCategory == 'All'
              ? ''
              : (_selectedCategory ?? ''),
          page: pageKey,
          limit: _pageSize,
          sort: _selectedSortValue,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          productType: _selectedProductType,
        ),
      );
    });
    // initial load
    _loadFirstPage();
  }

  void _loadFirstPage() {
    _pagingController.refresh();
  }

  final List<String> _categories = ['Shirts', 'Mugs', 'Posters'];
  final List<String> _productTypes = ['T-Shirt', 'Mug', 'Poster'];

  String? _selectedCategory;
  String? _selectedProductType;
  double _minPrice = 0;
  double _maxPrice = 1000;
  final int _limit = 20;
  String _selectedSort = 'name:asc';

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterSheet(
        categories: _categories,
        initialCategory: _selectedCategory,
        minPriceLimit: 0,
        maxPriceLimit: 1000,
        productTypes: _productTypes,
        initialProductType: _selectedProductType,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result['category'] as String?;
        _minPrice = (result['minPrice'] as double?) ?? _minPrice;
        _maxPrice = (result['maxPrice'] as double?) ?? _maxPrice;
        _selectedProductType = result['productType'] as String?;
      });

      // Dispatch the BLoC event with the new filters
      _loadFirstPage();
    }
  }

  void _openSortSheet() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _SortSheet(
        options: _sortOptions.keys.toList(),
        selectedKey: _sortOptions.entries
            .firstWhere((e) => e.value == _selectedSortValue)
            .key,
      ),
    );
    if (chosen != null && _sortOptions[chosen] != _selectedSortValue) {
      setState(() => _selectedSortValue = _sortOptions[chosen]!);
      _loadFirstPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
          ),
          IconButton(icon: const Icon(Icons.sort), onPressed: _openSortSheet),
        ],
      ),
      body: SafeArea(
        child: BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductLoaded) {
              final isLastPage = state.products.length < _pageSize;
              if (isLastPage) {
                _pagingController.appendLastPage(state.products);
              } else {
                final nextKey = (_pagingController.nextPageKey ?? 1) + 1;
                _pagingController.appendPage(state.products, nextKey);
              }
            } else if (state is ProductError) {
              _pagingController.error = state.message;
            }
          },
          child: PagedListView<int, Product>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Product>(
              itemBuilder: (context, product, index) =>
                  _buildProductCard(product),
              firstPageProgressIndicatorBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              firstPageErrorIndicatorBuilder: (_) =>
                  Center(child: Text(_pagingController.error.toString())),
              noItemsFoundIndicatorBuilder: (_) =>
                  const Center(child: Text('No products found')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: p.imageUrl.isNotEmpty
                    ? Image.network(
                        p.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.image, size: 48),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final List<String> options;
  final String selectedKey;
  const _SortSheet({required this.options, required this.selectedKey, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sort Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: options.map((opt) {
              final isSelected = opt == selectedKey;
              return ChoiceChip(
                label: Text(opt),
                selected: isSelected,
                onSelected: (_) => Navigator.of(context).pop(opt),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
