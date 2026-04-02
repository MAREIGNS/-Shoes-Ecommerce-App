class OrderItemModel {
  final String id;
  final String productId;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'].toString(),
      productId: json['product_id'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}