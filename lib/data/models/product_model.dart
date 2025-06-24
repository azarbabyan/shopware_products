import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
  }) : super(
         id: id,
         name: name,
         description: description,
         price: price,
         imageUrl: imageUrl,
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final translated = json['translated'] as Map<String, dynamic>?;
    final name = translated != null && translated['name'] != null
        ? translated['name'] as String
        : '';
    final description = translated != null && translated['description'] != null
        ? translated['description'] as String
        : '';

    // Use calculatedCheapestPrice if available, otherwise fallback to calculatedPrice
    double price = 0.0;
    if (json['calculatedCheapestPrice'] != null) {
      price = (json['calculatedCheapestPrice']['unitPrice'] as num).toDouble();
    } else if (json['calculatedPrice'] != null) {
      price = (json['calculatedPrice']['unitPrice'] as num).toDouble();
    }

    // Get the main image URL from cover.media.url
    String imageUrl = '';
    final cover = json['cover'] as Map<String, dynamic>?;
    if (cover != null && cover['media'] != null) {
      final media = cover['media'] as Map<String, dynamic>;
      imageUrl = media['url'] as String? ?? '';
    }

    return ProductModel(
      id: json['id'] as String,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
