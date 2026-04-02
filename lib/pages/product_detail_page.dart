import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoescomm/service/ecommerce_service.dart';
import 'package:shoescomm/widgets/cached_app_image.dart';
import '../models/product_model.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  final EcommerceService _service = EcommerceService.instance;

  int _selectedSize = 42;
  int _quantity = 1;
  bool _isWishlisted = false;
  bool _isAddingToCart = false;

  final List<int> _sizes = [39, 40, 41, 42, 43, 44, 45];

  late AnimationController _slideController;
  late AnimationController _buttonController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _buttonScale = _buttonController;
    _slideController.forward();
  }

  Future<void> _toggleWishlist() async {
    final next = !_isWishlisted;
    setState(() => _isWishlisted = next);
    HapticFeedback.lightImpact();

    try {
      if (next) {
        await _service.addToWishlist(widget.product.id);
        if (mounted) _showSnack('Added to wishlist', isError: false);
      } else {
        await _service.removeFromWishlist(widget.product.id);
        if (mounted) _showSnack('Removed from wishlist', isError: false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isWishlisted = !next);
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _addToCart() async {
    HapticFeedback.mediumImpact();
    await _buttonController.reverse();
    _buttonController.forward();

    setState(() => _isAddingToCart = true);

    try {
      await _service.addToCart(widget.product.id, _quantity);
      if (!mounted) return;
      _showSnack('Added to cart! 🛒', isError: false);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showSnack(msg, isError: true);
    }

    if (mounted) setState(() => _isAddingToCart = false);
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(msg, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor:
        isError ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // ── Product Image (top half) ─────────────────────────────
          SizedBox(
            height: size.height * 0.48,
            width: double.infinity,
            child: Stack(
              children: [
                Hero(
                  tag: widget.product.id,
                  child: CachedAppImage(
                    imageUrl: widget.product.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Gradient fade into dark bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF0A0A0A),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Back button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 16),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleWishlist,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _isWishlisted
                                  ? const Color(0xFFFF4500).withOpacity(0.15)
                                  : Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isWishlisted
                                    ? const Color(0xFFFF4500).withOpacity(0.5)
                                    : Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Icon(
                              _isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isWishlisted
                                  ? const Color(0xFFFF4500)
                                  : Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable detail sheet ──────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.58,
            minChildSize: 0.58,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF111111),
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 24),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),

                          // Name + Price row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'MA REIGNS Collection',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.35),
                                        fontSize: 12,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B35),
                                        Color(0xFFFF4500),
                                      ],
                                    ).createShader(bounds),
                                child: Text(
                                  '\$${widget.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Rating row
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                    (i) => Icon(
                                  i < 4 ? Icons.star : Icons.star_half,
                                  color: const Color(0xFFFFB300),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '4.5',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(128 reviews)',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.green.withOpacity(0.25)),
                                ),
                                child: Text(
                                  'In Stock: ${widget.product.stock}',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Size selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Select Size',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'EU Size Guide →',
                                style: TextStyle(
                                  color: const Color(0xFFFF6B35).withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 46,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _sizes.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                              itemBuilder: (context, i) {
                                final s = _sizes[i];
                                final isSelected = s == _selectedSize;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedSize = s);
                                    HapticFeedback.selectionClick();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 46,
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B35),
                                          Color(0xFFFF4500),
                                        ],
                                      )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.white.withOpacity(0.1),
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                        BoxShadow(
                                          color: const Color(0xFFFF4500)
                                              .withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                          : [],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$s',
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.5),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.55),
                              height: 1.7,
                              letterSpacing: 0.2,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Feature pills
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _featurePill(Icons.water_drop_outlined, 'Waterproof'),
                              _featurePill(Icons.air, 'Breathable'),
                              _featurePill(Icons.bolt_outlined, 'Lightweight'),
                              _featurePill(Icons.recycling, 'Eco-Friendly'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Bottom Action Bar ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.06)),
                  ),
                ),
                child: Row(
                  children: [
                    // Quantity selector
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          _qtyButton(
                            icon: Icons.remove,
                            onTap: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                                HapticFeedback.selectionClick();
                              }
                            },
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _qtyButton(
                            icon: Icons.add,
                            onTap: () {
                              setState(() => _quantity++);
                              HapticFeedback.selectionClick();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Add to Cart button
                    Expanded(
                      child: ScaleTransition(
                        scale: _buttonScale,
                        child: GestureDetector(
                          onTap: _isAddingToCart ? null : _addToCart,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: _isAddingToCart
                                  ? LinearGradient(
                                colors: [
                                  Colors.grey.shade800,
                                  Colors.grey.shade700,
                                ],
                              )
                                  : const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFFF6B35),
                                  Color(0xFFFF4500),
                                  Color(0xFFCC3300),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: _isAddingToCart
                                  ? []
                                  : [
                                BoxShadow(
                                  color: const Color(0xFFFF4500)
                                      .withOpacity(0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isAddingToCart
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.shopping_bag_outlined,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add to Cart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
      ),
    );
  }

  Widget _featurePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFF6B35), size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}