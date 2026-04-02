import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';

class EcommerceService {
  EcommerceService._();
  static final EcommerceService instance = EcommerceService._();

  final client = SupabaseConfig.client;

  // =========================
  // PRODUCTS
  // =========================

  Future<List<ProductModel>> getProducts() async {
    final response = await client
        .from('products')
        .select()
        .eq('is_active', true);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<String?> uploadImage(XFile image) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("You must be logged in to upload images.");

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    Uint8List fileBytes = await image.readAsBytes();

    try {
      if (kIsWeb) {
        await client.storage.from('product-images').uploadBinary(
          fileName,
          fileBytes,
          fileOptions: const FileOptions(upsert: true),
        );
      } else {
        final bytes = await File(image.path).readAsBytes();
        await client.storage.from('product-images').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
      }
      final url = client.storage.from('product-images').getPublicUrl(fileName);
      return url;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> addProduct(ProductModel product) async {
    await client.from('products').insert(product.toJson());
  }

  // =========================
  // CART
  // =========================

  Future<void> addToCart(String productId, int quantity) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("Please sign in to add items to cart.");

    await client.from('cart').upsert({
      'user_id': user.id,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<List<CartModel>> getCart() async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("Please sign in to view your cart.");

    final response = await client
        .from('cart')
        .select()
        .eq('user_id', user.id);

    return (response as List)
        .map((json) => CartModel.fromJson(json))
        .toList();
  }

  Future<void> removeFromCart(String cartId) async {
    await client.from('cart').delete().eq('id', cartId);
  }

  // =========================
  // WISHLIST
  // =========================

  Future<void> addToWishlist(String productId) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("Please sign in to add to wishlist.");

    await client.from('wishlist').upsert({
      'user_id': user.id,
      'product_id': productId,
    });
  }

  Future<void> removeFromWishlist(String productId) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("Please sign in to update your wishlist.");

    await client
        .from('wishlist')
        .delete()
        .eq('user_id', user.id)
        .eq('product_id', productId);
  }

  /// Returns the current user's wishlist rows. Throws if not signed in.
  Future<List<Map<String, dynamic>>> getWishlist() async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("Please sign in to view your wishlist.");

    final response = await client
        .from('wishlist')
        .select()
        .eq('user_id', user.id);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Set<String>> getWishlistProductIds() async {
    final rows = await getWishlist();
    return rows
        .map((r) => r['product_id']?.toString())
        .where((id) => id != null && id!.isNotEmpty)
        .cast<String>()
        .toSet();
  }

  // =========================
  // ORDERS
  // =========================

  Future<void> createOrder(
    String addressId,
    double totalAmount,
    List<CartModel> cartItems,
  ) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception("Please sign in to place an order.");

    final orderResponse = await client.from('orders').insert({
      'user_id': user.id,
      'address_id': addressId,
      'total_amount': totalAmount,
    }).select().single();

    final orderId = orderResponse['id'];

    for (var item in cartItems) {
      await client.from('order_items').insert({
        'order_id': orderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'price': totalAmount,
      });
    }

    await client.from('cart').delete().eq('user_id', user.id);
  }
}
