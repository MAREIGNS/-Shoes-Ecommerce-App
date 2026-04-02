import 'package:flutter/material.dart';
import 'package:shoescomm/core/app_routes.dart';
import 'package:shoescomm/service/ecommerce_service.dart';
import 'package:shoescomm/widgets/empty_view.dart';
import 'package:shoescomm/widgets/loading_view.dart';
import 'package:shoescomm/widgets/sign_in_prompt_view.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final EcommerceService _service = EcommerceService.instance;
  late Future<List<Map<String, dynamic>>> _wishlistFuture;

  @override
  void initState() {
    super.initState();
    _wishlistFuture = _service.getWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _wishlistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }

          if (snapshot.hasError) {
            return SignInPromptView(
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
            );
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const EmptyView(
              message: 'Your wishlist is empty',
              icon: Icons.favorite_border,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final row = items[index];
              return ListTile(
                title: Text("Product ID: ${row['product_id'] ?? '—'}"),
                trailing: Icon(Icons.favorite, color: Colors.red.withOpacity(0.8), size: 20),
              );
            },
          );
        },
      ),
    );
  }
}
