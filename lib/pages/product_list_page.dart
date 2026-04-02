import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shoescomm/core/app_colors.dart';
import 'package:shoescomm/pages/app_drawer.dart';
import 'package:shoescomm/pages/app_bar.dart';
import 'package:shoescomm/service/ecommerce_service.dart';
import 'package:shoescomm/widgets/cached_app_image.dart';
import 'package:shoescomm/widgets/empty_view.dart';
import 'package:shoescomm/widgets/loading_view.dart';
import '../models/product_model.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final EcommerceService _service = EcommerceService.instance;
  late Future<List<ProductModel>> _productsFuture;

  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Running', 'Sport', 'Casual', 'Lifestyle'];
  Set<String> _wishlistIds = <String>{};

  @override
  void initState() {
    super.initState();
    _productsFuture = _service.getProducts();
    _loadWishlistIds();
  }

  Future<void> _loadWishlistIds() async {
    try {
      final ids = await _service.getWishlistProductIds();
      if (!mounted) return;
      setState(() => _wishlistIds = ids);
    } catch (_) {
      // Not signed in or network issue: treat as empty wishlist.
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    var list = products;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((p) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final descMatch = p.description.toLowerCase().contains(query);
        return nameMatch || descMatch;
      }).toList();
    }
    if (_selectedCategory != 'All') {
      final cat = _selectedCategory.toLowerCase();
      list = list.where((p) {
        final idMatch = (p.categoryId ?? '').toLowerCase() == cat;
        final nameMatch = p.name.toLowerCase().contains(cat);
        final descMatch = p.description.toLowerCase().contains(cat);
        return idMatch || nameMatch || descMatch;
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildBarApp(context),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyView(
              message: 'No Products Found',
              icon: Icons.shopping_bag_outlined,
            );
          }

          final allProducts = snapshot.data!;
          final products = _filterProducts(allProducts);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _HeroBanner()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _SearchBar(
                      controller: _searchController,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Collections',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${products.length} items',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _CategoryRow(
                      categories: _categories,
                      selected: _selectedCategory,
                      onSelect: (cat) =>
                          setState(() => _selectedCategory = cat),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: products.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                'No products match your search or category',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final product = products[index];
                        return _ProductCard(
                          product: product,
                          index: index,
                          isWishlisted: _wishlistIds.contains(product.id),
                          onWishlistedChanged: (isWishlisted) {
                            setState(() {
                              if (isWishlisted) {
                                _wishlistIds.add(product.id);
                              } else {
                                _wishlistIds.remove(product.id);
                              }
                            });
                          },
                        );
                      },
                      childCount: products.length,
                    ),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            );
          },
        ),
      );

  }
}

// ─── Hero Banner ─────────────────────────────────────────────────────────────
class _HeroBanner extends StatefulWidget {
  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  final List<String> _images =
      List.generate(11, (i) => 'images/${i + 2}.jpg'); // 2.jpg → 12.jpg
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _index = (_index + 1) % _images.length;
      _controller.animateToPage(
        _index,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4500).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _images.length,
              onPageChanged: (i) => _index = i,
              itemBuilder: (_, i) => Image.asset(
                _images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.surfaceVariant),
              ),
            ),
            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
            // Text content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4500),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NEW SEASON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Step Into\nGreatness',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Shop Now',
                        style: TextStyle(
                          color: Color(0xFFFF6B35),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward,
                          color: Color(0xFFFF6B35), size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: Colors.white.withOpacity(0.35), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search shoes, brands...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Row ─────────────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryRow({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.1),
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: const Color(0xFFFF4500).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
                    : [],
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final int index;

  final bool isWishlisted;
  final ValueChanged<bool> onWishlistedChanged;

  const _ProductCard({
    required this.product,
    required this.index,
    required this.isWishlisted,
    required this.onWishlistedChanged,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  bool _isWishlisted = false;
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.isWishlisted;
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.0,
      value: 1.0,
    );
    _heartScale = CurvedAnimation(
        parent: _heartController, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(covariant _ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWishlisted != widget.isWishlisted) {
      _isWishlisted = widget.isWishlisted;
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggleWishlist() async {
    final next = !_isWishlisted;
    setState(() => _isWishlisted = next);
    await _heartController.reverse();
    _heartController.forward();

    try {
      if (next) {
        await EcommerceService.instance.addToWishlist(widget.product.id);
      } else {
        await EcommerceService.instance.removeFromWishlist(widget.product.id);
      }
      widget.onWishlistedChanged(next);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isWishlisted = !next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              ProductDetailPage(product: widget.product),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF1E1E1E),
                      child: CachedAppImage(
                        imageUrl: widget.product.imageUrl,
                        fit: BoxFit.cover,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                    ),
                  ),

                  // Wishlist button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleWishlist,
                      child: ScaleTransition(
                        scale: _heartScale,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _isWishlisted
                                ? const Color(0xFFFF4500).withOpacity(0.15)
                                : Colors.black.withOpacity(0.4),
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
                                : Colors.white.withOpacity(0.5),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // "New" badge on select items
                  if (widget.index % 3 == 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4500),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info section
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Stars
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < 4 ? Icons.star : Icons.star_half,
                          color: const Color(0xFFFFB300),
                          size: 11,
                        );
                      }),
                    ),

                    // Price + Cart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.product.price}',
                          style: const TextStyle(
                            color: Color(0xFFFF6B35),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF4500).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
