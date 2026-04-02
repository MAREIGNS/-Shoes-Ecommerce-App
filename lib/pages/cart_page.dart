import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoescomm/core/app_colors.dart';
import 'package:shoescomm/core/app_routes.dart';
import 'package:shoescomm/service/ecommerce_service.dart';
import 'package:shoescomm/widgets/loading_view.dart';
import 'package:shoescomm/widgets/sign_in_prompt_view.dart';
import 'package:shoescomm/widgets/app_snackbar.dart';
import '../models/cart_model.dart';
import 'address_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  final EcommerceService _service = EcommerceService.instance;
  late Future<List<CartModel>> _cart;

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _cart = _service.getCart();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void refresh() {
    setState(() {
      _cart = _service.getCart();
    });
  }

  void _showSnack(String msg, {required bool isError}) {
    showAppSnackBar(context, message: msg, isError: isError);
  }

  double _calcTotal(List<CartModel> items) {
    return items.fold(0, (sum, item) => sum + (3 * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 15),
          ),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4500).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFFF4500).withOpacity(0.25)),
            ),
            child: const Center(
              child: Text(
                'CART',
                style: TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<CartModel>>(
        future: _cart,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }

          if (snapshot.hasError) {
            return SignInPromptView(
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _EmptyCart();
          }

          final items = snapshot.data!;
          final total = _calcTotal(items);

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  // Item count bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Row(
                      children: [
                        Text(
                          '${items.length} item${items.length > 1 ? 's' : ''} in your cart',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            for (final item in items) {
                              await _service.removeFromCart(item.id);
                            }
                            refresh();
                            _showSnack('Cart cleared', isError: false);
                          },
                          child: Text(
                            'Clear all',
                            style: TextStyle(
                              color: const Color(0xFFFF4500).withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cart items list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _CartItemCard(
                          item: items[index],
                          onDelete: () async {
                            HapticFeedback.mediumImpact();
                            await _service.removeFromCart(items[index].id);
                            refresh();
                            _showSnack('Item removed', isError: false);
                          },
                        );
                      },
                    ),
                  ),

                  // Order summary + checkout
                  _CheckoutPanel(items: items, total: total),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Cart Item Card ───────────────────────────────────────────────────────────
class _CartItemCard extends StatefulWidget {
  final CartModel item;
  final VoidCallback onDelete;

  const _CartItemCard({required this.item, required this.onDelete});

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.item.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border:
          Border.all(color: const Color(0xFFE53935).withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: Color(0xFFE53935), size: 22),
            const SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(
                color: const Color(0xFFE53935).withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // Product image placeholder
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
                border:
                Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: widget.item.quantity!= null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                // child: Image.network(
                //   widget.item.quantity!,
                //   fit: BoxFit.cover,
                //   errorBuilder: (_, __, ___) => const Center(
                //     child: Icon(Icons.image_not_supported_outlined,
                //         color: Colors.white24, size: 28),
                //   ),
                // ),
              )
                  : const Center(
                child: Icon(Icons.directions_run,
                    color: Color(0xFFFF4500), size: 32),
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   widget.item. ?? 'Shoe Product',
                  //   style: const TextStyle(
                  //     color: Colors.white,
                  //     fontWeight: FontWeight.w700,
                  //     fontSize: 14,
                  //     letterSpacing: 0.1,
                  //   ),
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  const SizedBox(height: 4),
                  Text(
                    'Size EU ${widget.item.quantity ?? 42}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        '\$${(widget.item.quantity * widget.item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFFF6B35),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),

                      // Qty pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            _miniBtn(Icons.remove, () {}),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '${widget.item.quantity}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _miniBtn(Icons.add, () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Delete button
            GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFFE53935).withOpacity(0.2)),
                ),
                child: const Icon(Icons.delete_outline,
                    color: Color(0xFFE53935), size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.6), size: 14),
      ),
    );
  }
}

// ─── Checkout Panel ───────────────────────────────────────────────────────────
class _CheckoutPanel extends StatelessWidget {
  final List<CartModel> items;
  final double total;

  const _CheckoutPanel({required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    final shipping = total > 100 ? 0.0 : 9.99;
    final grandTotal = total + shipping;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Order summary
          _summaryRow('Subtotal', '\$${total.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _summaryRow(
            'Shipping',
            shipping == 0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}',
            valueColor: shipping == 0 ? Colors.greenAccent : null,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.07),
            ),
          ),

          _summaryRow(
            'Total',
            '\$${grandTotal.toStringAsFixed(2)}',
            isBold: true,
            valueColor: const Color(0xFFFF6B35),
          ),

          if (total <= 100)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Add \$${(100 - total).toStringAsFixed(2)} more for free shipping!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 16),

          // Checkout button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AddressPage(),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B35),
                    Color(0xFFFF4500),
                    Color(0xFFCC3300),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4500).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.white : Colors.white.withOpacity(0.45),
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isBold ? Colors.white : Colors.white.withOpacity(0.7)),
            fontSize: isBold ? 18 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Empty Cart ───────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4500).withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFFFF4500).withOpacity(0.15),
                  width: 1.5),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: Color(0xFFFF4500), size: 42),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some awesome shoes to get started!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4500).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Browse Collection',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}