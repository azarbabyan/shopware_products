// lib/presentation/widgets/filter_sheet.dart

import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final List<String> categories;

  final String? initialCategory;

  final double minPriceLimit;

  final double maxPriceLimit;

  final List<String> productTypes;

  final String? initialProductType;

  const FilterSheet({
    Key? key,
    required this.categories,
    this.initialCategory,
    this.minPriceLimit = 0,
    this.maxPriceLimit = 1000,
    this.productTypes = const [],
    this.initialProductType,
  }) : super(key: key);

  @override
  _FilterSheetState createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _selectedCategory;
  double _minPrice = 0;
  double _maxPrice = 0;
  String? _selectedProductType;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _minPrice = widget.minPriceLimit;
    _maxPrice = widget.maxPriceLimit;
    _selectedProductType = widget.initialProductType;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: controller,
            children: [
              // Drag-handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Price Range Filter
              const Text(
                'Price Range',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: widget.minPriceLimit,
                max: widget.maxPriceLimit,
                divisions: 100,
                labels: RangeLabels(
                  '\$${_minPrice.toStringAsFixed(0)}',
                  '\$${_maxPrice.toStringAsFixed(0)}',
                ),
                onChanged: (range) {
                  setState(() {
                    _minPrice = range.start;
                    _maxPrice = range.end;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Product Type Filter
              const Text(
                'Filter by Product Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedProductType,
                hint: const Text('Select type'),
                items: widget.productTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (type) {
                  setState(() {
                    _selectedProductType = type;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = null;
                          _minPrice = widget.minPriceLimit;
                          _maxPrice = widget.maxPriceLimit;
                          _selectedProductType = null;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop<Map<String, dynamic>>(context, {
                          'category': _selectedCategory,
                          'minPrice': _minPrice,
                          'maxPrice': _maxPrice,
                          'productType': _selectedProductType,
                        });
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
