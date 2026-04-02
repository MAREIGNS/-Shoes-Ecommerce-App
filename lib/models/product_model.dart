class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? categoryId;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.categoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final price = json['price'];
    final stock = json['stock'];
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: price is num ? price.toDouble() : double.tryParse(price?.toString() ?? '') ?? 0,
      stock: stock is int ? stock : int.tryParse(stock?.toString() ?? '') ?? 0,
      imageUrl: json['image_url']?.toString(),
      categoryId: json['category_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'category_id': categoryId,
    };
  }
}