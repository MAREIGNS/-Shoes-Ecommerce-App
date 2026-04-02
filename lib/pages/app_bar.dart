import 'package:flutter/material.dart';
import 'package:shoescomm/core/app_routes.dart';
import 'package:shoescomm/service/ecommerce_service.dart';
import 'package:shoescomm/supabase_config.dart';

AppBar buildBarApp(BuildContext context) {
  final user = SupabaseConfig.client.auth.currentUser;
  final avatarLetter =
  (user?.email ?? 'U').split('@').first[0].toUpperCase();

  return AppBar(
    backgroundColor: const Color(0xFF0A0A0A),
    elevation: 0,
    scrolledUnderElevation: 0,
    leadingWidth: 56,

    // ── Hamburger menu button ──────────────────────────────────
    leading: Builder(
      builder: (ctx) => GestureDetector(
        onTap: () => Scaffold.of(ctx).openDrawer(),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Icon(Icons.menu_rounded,
                  color: Colors.white.withOpacity(0.8), size: 18),
            ),
          ),
        ),
      ),
    ),

    // ── Brand title ────────────────────────────────────────────
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
          ).createShader(bounds),
          child: const Icon(Icons.directions_run,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 8),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFF6B35)],
          ).createShader(bounds),
          child: const Text(
            'MA REIGNS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 17,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    ),
    centerTitle: true,

    // ── Action buttons: Cart, Wishlist, Profile ─────────────────
    actions: [
      // Cart
      _AppBarButton(
        icon: Icons.shopping_bag_outlined,
        onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
        showBadge: true,
        badgeCount: 3,
      ),

      // Wishlist (replaces admin) – shows count of wishlist items
      const _WishlistAppBarButton(),

      // Profile avatar
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
        child: Container(
          margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4500).withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              avatarLetter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    ],

    // ── Bottom orange glow line ────────────────────────────────
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFFF4500).withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    ),
  );
}

// ─── Wishlist button with live count badge ──────────────────────────────────────
class _WishlistAppBarButton extends StatelessWidget {
  const _WishlistAppBarButton();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getWishlistCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return _AppBarButton(
          icon: Icons.favorite_border,
          onTap: () => Navigator.pushNamed(context, AppRoutes.wishlist),
          showBadge: count > 0,
          badgeCount: count,
        );
      },
    );
  }

  Future<int> _getWishlistCount() async {
    try {
      final list = await EcommerceService.instance.getWishlist();
      return list.length;
    } catch (_) {
      return 0;
    }
  }
}

// ─── AppBar Icon Button ───────────────────────────────────────────────────────
class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;

  const _AppBarButton({
    required this.icon,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(icon,
                  color: Colors.white.withOpacity(0.8), size: 18),
            ),
            if (showBadge && badgeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
