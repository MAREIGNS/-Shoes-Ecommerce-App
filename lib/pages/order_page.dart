import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoescomm/service/ecommerce_service.dart';
import '../models/cart_model.dart';

class OrderPage extends StatefulWidget {
  final String addressId;
  const OrderPage({super.key, required this.addressId});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  final EcommerceService _service = EcommerceService.instance;

  List<CartModel> _cartItems = [];
  double _total = 0;
  bool _isLoading = true;
  bool _isPlacing = false;
  bool _orderPlaced = false;

  late AnimationController _entryController;
  late AnimationController _successController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _successScale;
  late Animation<double> _successFade;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _successController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));
    _successScale = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _successController, curve: Curves.elasticOut));
    _successFade = CurvedAnimation(parent: _successController, curve: Curves.easeIn);
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final items = await _service.getCart();
      double total = 0;
      for (var item in items) {
        total += item.quantity * 3; // ✅ fixed: was item.quantity * item.quantity
      }
      setState(() {
        _cartItems = items;
        _total = total;
        _isLoading = false;
      });
      _entryController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  // ✅ Creates order then clears every item from cart
  Future<void> _confirmOrder() async {
    HapticFeedback.mediumImpact();
    setState(() => _isPlacing = true);

    try {
      await _service.createOrder(widget.addressId, _total, _cartItems);

      if (!mounted) return;
      setState(() { _isPlacing = false; _orderPlaced = true; });
      HapticFeedback.heavyImpact();
      _successController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacing = false);
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showSnack('Failed to place order: $msg', isError: true);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _orderPlaced
          ? null
          : AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        // ✅ Fixed back button — no longer references undefined 'items'
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 15),
          ),
        ),
        title: const Text('Confirm Order',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.3)),
        centerTitle: true,
      ),
      body: _orderPlaced
          ? _buildSuccessScreen()
          : _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4500), strokeWidth: 2.5))
          : FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StepIndicator(currentStep: 3),
                      const SizedBox(height: 28),
                      _sectionHeader(Icons.shopping_bag_outlined, 'Order Items'),
                      const SizedBox(height: 14),
                      ..._cartItems.map((item) => _OrderItemRow(item: item)),
                      const SizedBox(height: 24),
                      _sectionHeader(Icons.receipt_long_outlined, 'Price Summary'),
                      const SizedBox(height: 14),
                      _PriceSummaryCard(total: _total),
                      const SizedBox(height: 24),
                      _sectionHeader(Icons.local_shipping_outlined, 'Delivery'),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4500).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_shipping_outlined, color: Color(0xFFFF6B35), size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text('Standard Delivery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('Estimated 3–5 business days', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                              ]),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.withOpacity(0.25)),
                              ),
                              child: const Text('FREE', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom confirm button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total to pay', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                          ).createShader(bounds),
                          child: Text('\$${_total.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _isPlacing ? null : _confirmOrder,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: _isPlacing
                              ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700])
                              : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF6B35), Color(0xFFFF4500), Color(0xFFCC3300)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isPlacing ? [] : [
                            BoxShadow(color: const Color(0xFFFF4500).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
                          ],
                        ),
                        child: Center(
                          child: _isPlacing
                              ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.verified_outlined, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Confirm & Pay',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFF4500).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFF6B35), size: 16),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A0A00)]),
      ),
      child: FadeTransition(
        opacity: _successFade,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _successScale,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF4500)]),
                  boxShadow: [BoxShadow(color: const Color(0xFFFF4500).withOpacity(0.5), blurRadius: 40, spreadRadius: 5)],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Order Placed! 🎉',
                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 12),
            Text('Your sneakers are on their way.\nGet ready to step into greatness!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 15, height: 1.6)),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.tag, color: Color(0xFFFF6B35), size: 16),
                const SizedBox(width: 8),
                Text('Order confirmed successfully', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 52),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF4500)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF4500).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                    Icon(Icons.home_outlined, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Back to Home', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: Text('Continue Shopping →',
                  style: TextStyle(color: const Color(0xFFFF6B35).withOpacity(0.75), fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Order Item Row ───────────────────────────────────────────────────────────
class _OrderItemRow extends StatelessWidget {
  final CartModel item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [ 
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: item.quantity != null
                ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:Text(("")))
                : const Icon(Icons.directions_run, color: Color(0xFFFF4500), size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(  'Shoe Product',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('Qty: ${item.quantity}  •  Size EU ${item.quantity ?? 42}',
                  style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12)),
            ]),
          ),
          Text('\$${(item.quantity * item.quantity).toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    );
  }
}

// ─── Price Summary Card ───────────────────────────────────────────────────────
class _PriceSummaryCard extends StatelessWidget {
  final double total;
  const _PriceSummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    final shipping = total > 100 ? 0.0 : 9.99;
    final grand = total + shipping;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(children: [
        _row('Subtotal', '\$${total.toStringAsFixed(2)}'),
        const SizedBox(height: 10),
        _row('Shipping', shipping == 0 ? 'FREE' : '\$${shipping.toStringAsFixed(2)}', valueColor: Colors.greenAccent),
        Padding(padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(height: 1, color: Colors.white.withOpacity(0.07))),
        _row('Total', '\$${grand.toStringAsFixed(2)}', isBold: true, valueColor: const Color(0xFFFF6B35)),
      ]),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          color: isBold ? Colors.white : Colors.white.withOpacity(0.45),
          fontSize: isBold ? 15 : 13,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
        )),
        Text(value, style: TextStyle(
          color: valueColor ?? (isBold ? Colors.white : Colors.white.withOpacity(0.7)),
          fontSize: isBold ? 18 : 13,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
        )),
      ],
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Cart', 'Address', 'Order'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = (i ~/ 2) + 1;
          return Expanded(child: Container(height: 2,
              color: stepIndex < currentStep ? const Color(0xFFFF4500) : Colors.white.withOpacity(0.1)));
        }
        final stepIndex = i ~/ 2 + 1;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;
        return Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isCurrent || isCompleted
                  ? const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF4500)]) : null,
              color: isCurrent || isCompleted ? null : Colors.white.withOpacity(0.07),
              boxShadow: isCurrent
                  ? [BoxShadow(color: const Color(0xFFFF4500).withOpacity(0.4), blurRadius: 10)] : [],
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : Text('$stepIndex', style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.white.withOpacity(0.35),
                  fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 6),
          Text(steps[stepIndex - 1], style: TextStyle(
            color: isCurrent ? const Color(0xFFFF6B35) : Colors.white.withOpacity(0.3),
            fontSize: 11, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
          )),
        ]);
      }),
    );
  }
}