class CartModel {
  final String id;
  final String productId;
  final int quantity;

  CartModel({
    required this.id,
    required this.productId,
    required this.quantity,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'].toString(),
      productId: json['product_id'],
      quantity: json['quantity'],
    );
  }
}