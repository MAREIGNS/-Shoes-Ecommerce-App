import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoescomm/pages/product_list_page.dart';
// import 'package:shoescomm/pages/dashboard_page.dart';
import 'package:shoescomm/pages/cart_page.dart';
// import 'package:shoescomm/pages/profile_page.dart';
import 'package:shoescomm/pages/userdashboard.dart'; // create if not exists

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnim;

  final List<Widget> _pages = const [
    ProductListPage(),
    DashboardPage(),
    CartPage(),
    ProfilePlaceholderPage(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Orders'),
    _NavItem(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Cart'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _indicatorAnim = CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOutCubic,
    );
    _indicatorController.forward();
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _indicatorController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: _onTap,
        indicatorAnim: _indicatorAnim,
      ),
    );
  }
}

// ─── Nav Item Model ───────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─── Bottom Nav Bar Widget ────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  final Animation<double> indicatorAnim;

  const _BottomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
    required this.indicatorAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with animated background pill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 16 : 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                              colors: [
                                Color(0xFFFF6B35),
                                Color(0xFFFF4500),
                              ],
                            )
                                : null,
                            color: isSelected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: const Color(0xFFFF4500)
                                    .withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ]
                                : [],
                          ),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.35),
                            size: 22,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Label
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFFF6B35)
                                : Colors.white.withOpacity(0.3),
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Profile Placeholder (replace with your real ProfilePage) ─────────────────
class ProfilePlaceholderPage extends StatelessWidget {
  const ProfilePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4500).withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 38),
            ),
            const SizedBox(height: 20),
            const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}