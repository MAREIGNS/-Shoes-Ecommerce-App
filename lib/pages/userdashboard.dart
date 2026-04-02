import 'package:flutter/material.dart';
import 'package:shoescomm/pages/app_drawer.dart';
import 'package:shoescomm/pages/app_bar.dart';
import 'package:shoescomm/supabase_config.dart';
import '../service/user_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final UserService _service = UserService.instance;

  List<Map<String, dynamic>> orders = [];
  bool loading = true;

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    loadOrders();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> loadOrders() async {
    final data = await _service.getUserOrders();
    setState(() {
      orders = data;
      loading = false;
    });
    _entryController.forward();
  }

  double get _totalSpent {
    double total = 0;
    for (var order in orders) {
      final product = order['products'];
      final price =
          double.tryParse(product?['price']?.toString() ?? '0') ?? 0;
      final quantity =
          int.tryParse(order['quantity']?.toString() ?? '0') ?? 0;
      total += price * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    final email = user?.email ?? 'User';
    final name = email.split('@').first;
    final avatarLetter = name[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: buildBarApp(context),
      drawer: AppDrawer(),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF4500),
          strokeWidth: 2.5,
        ),
      )
          : FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // ── Welcome Header ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF6B35),
                              Color(0xFFFF4500)
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4500)
                                  .withOpacity(0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            avatarLetter,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Refresh button
                      GestureDetector(
                        onTap: () {
                          setState(() => loading = true);
                          loadOrders();
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Icon(Icons.refresh_rounded,
                              color: Colors.white.withOpacity(0.6),
                              size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Stats Cards ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.receipt_long_outlined,
                          label: 'Total Orders',
                          value: '${orders.length}',
                          color: const Color(0xFFFF4500),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.attach_money_rounded,
                          label: 'Total Spent',
                          value: '\$${_totalSpent.toStringAsFixed(2)}',
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Extra stat row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_shipping_outlined,
                          label: 'Delivered',
                          value: orders
                              .where((o) =>
                          o['status'] == 'delivered')
                              .length
                              .toString(),
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.pending_outlined,
                          label: 'Pending',
                          value: orders
                              .where((o) =>
                          o['status'] != 'delivered')
                              .length
                              .toString(),
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── Order History Title ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4500)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                                Icons.history_rounded,
                                color: Color(0xFFFF6B35),
                                size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Order History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${orders.length} orders',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // ── Orders List ──────────────────────────────────
              orders.isEmpty
                  ? SliverToBoxAdapter(child: _EmptyOrders())
                  : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final order = orders[index];
                      final product = order['products'];
                      final name = product?['name']?.toString() ??
                          'Unknown Product';
                      final price = double.tryParse(
                          product?['price']?.toString() ??
                              '0') ??
                          0;
                      final quantity = int.tryParse(
                          order['quantity']?.toString() ??
                              '0') ??
                          0;
                      final total = price * quantity;
                      final imageUrl =
                      product?['image_url']?.toString();
                      final status =
                          order['status']?.toString() ?? 'pending';

                      return _OrderCard(
                        name: name,
                        quantity: quantity,
                        total: total,
                        imageUrl: imageUrl,
                        status: status,
                        index: index,
                      );
                    },
                    childCount: orders.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final String name;
  final int quantity;
  final double total;
  final String? imageUrl;
  final String status;
  final int index;

  const _OrderCard({
    required this.name,
    required this.quantity,
    required this.total,
    required this.imageUrl,
    required this.status,
    required this.index,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF4CAF50);
      case 'shipped':
        return const Color(0xFF2196F3);
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFF9800);
    }
  }

  IconData get _statusIcon {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle_outline;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.pending_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: imageUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.directions_run,
                      color: Color(0xFFFF4500), size: 28),
                ),
              ),
            )
                : const Center(
              child: Icon(Icons.directions_run,
                  color: Color(0xFFFF4500), size: 28),
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  'Qty: $quantity',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                // Status pill
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: _statusColor, size: 11),
                      const SizedBox(width: 4),
                      Text(
                        status[0].toUpperCase() + status.substring(1),
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Price
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Orders ─────────────────────────────────────────────────────────────
class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4500).withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFFFF4500).withOpacity(0.15),
                  width: 1.5),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: Color(0xFFFF4500), size: 34),
          ),
          const SizedBox(height: 16),
          const Text(
            'No orders yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your order history will appear here',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}