import 'package:flutter/material.dart';
import 'package:shoescomm/supabase_config.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;
    final email = user?.email ?? 'Guest User';
    final name = email.contains('@') ? email.split('@').first : email;
    final avatarLetter = name[0].toUpperCase();

    return Drawer(
      backgroundColor: const Color(0xFF0F0F0F),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 28,
              bottom: 28,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A0800),
                  Color(0xFF2A1000),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF4500).withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF4500).withOpacity(0.12),
                      ),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4500).withOpacity(0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          avatarLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Email
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Member badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4500).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF4500).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.verified,
                              color: Color(0xFFFF6B35), size: 12),
                          SizedBox(width: 5),
                          Text(
                            'MA REIGNS Member',
                            style: TextStyle(
                              color: Color(0xFFFF6B35),
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
              ],
            ),
          ),

          // ── Menu Items ───────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _sectionLabel('MENU'),

                _DrawerItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  route: '/home',
                  context: context,
                ),
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  route: '/profile',
                  context: context,
                ),
                _DrawerItem(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  label: 'My Orders',
                  route: '/orders',
                  context: context,
                ),
                _DrawerItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  route: '/profile',
                  context: context,
                ),

                const SizedBox(height: 8),
                _sectionLabel('MORE'),

                _DrawerItem(
                  icon: Icons.info_outline_rounded,
                  activeIcon: Icons.info_rounded,
                  label: 'About Us',
                  route: '/Aboutus',
                  context: context,
                ),
                _DrawerItem(
                  icon: Icons.contact_mail_outlined,
                  activeIcon: Icons.contact_mail_rounded,
                  label: 'Contact Us',
                  route: '/Contactus',
                  context: context,
                ),
                _DrawerItem(
                  icon: Icons.article_outlined,
                  activeIcon: Icons.article_rounded,
                  label: 'Blog',
                  route: '/Blog',
                  context: context,
                ),
              ],
            ),
          ),

          // ── Footer ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
            ),
            child: Column(
              children: [
                // App version
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 24),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                        ).createShader(bounds),
                        child: const Icon(Icons.directions_run,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MA REIGNS  v1.0.0',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Logout
                InkWell(
                  onTap: () async {
                    await SupabaseConfig.client.auth.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE53935).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout_rounded,
                            color: Color(0xFFE53935), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 6),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.2),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ─── Drawer Item ──────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final BuildContext context;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
            )
                : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: const Color(0xFFFF4500).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.45),
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight:
                  isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}