import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // ── Background decorations ─────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4500).withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4500).withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF4500).withOpacity(0.1),
                ),
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ── Custom AppBar ──────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.08)),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white, size: 15),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'About Us',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Hero logo ──────────────────────────────
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF4500).withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.directions_run,
                              color: Colors.white, size: 52),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Brand name
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFFFFF), Color(0xFFFF6B35)],
                        ).createShader(bounds),
                        child: const Text(
                          'MA REIGNS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'STEP INTO GREATNESS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Mission statement ──────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF4500)
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.star_outline,
                                        color: Color(0xFFFF6B35), size: 17),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Our Mission',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'We are your one-stop shop for stylish, comfortable, and trendy shoes. '
                                    'At MA REIGNS, we believe in quality, affordability, and fashion-forward '
                                    'designs that let you express your unique identity with every step.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 14,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Stats row ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                                child: _StatCard(
                                    value: '500+',
                                    label: 'Products',
                                    icon: Icons.inventory_2_outlined)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _StatCard(
                                    value: '10K+',
                                    label: 'Customers',
                                    icon: Icons.people_outline_rounded)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _StatCard(
                                    value: '4.8★',
                                    label: 'Rating',
                                    icon: Icons.star_border_rounded)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Values ────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _ValueCard(
                              icon: Icons.verified_outlined,
                              color: const Color(0xFF4CAF50),
                              title: 'Premium Quality',
                              subtitle:
                              'Every shoe is crafted with the finest materials and passes rigorous quality checks.',
                            ),
                            const SizedBox(height: 12),
                            _ValueCard(
                              icon: Icons.local_shipping_outlined,
                              color: const Color(0xFF2196F3),
                              title: 'Fast Delivery',
                              subtitle:
                              'Get your order delivered to your doorstep in 3–5 business days, absolutely free.',
                            ),
                            const SizedBox(height: 12),
                            _ValueCard(
                              icon: Icons.loop_rounded,
                              color: const Color(0xFFFF9800),
                              title: 'Easy Returns',
                              subtitle:
                              '30-day hassle-free return policy. Not satisfied? We\'ll make it right.',
                            ),
                            const SizedBox(height: 12),
                            _ValueCard(
                              icon: Icons.support_agent_outlined,
                              color: const Color(0xFFFF4500),
                              title: '24/7 Support',
                              subtitle:
                              'Our team is always here to help you with anything you need.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Team ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  child: const Icon(Icons.people_outline,
                                      color: Color(0xFFFF6B35), size: 16),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Meet the Team',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                    child: _TeamCard(
                                        initial: 'M',
                                        name: 'Muhammad',
                                        role: 'Founder & CEO')),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _TeamCard(
                                        initial: 'A',
                                        name: 'Ali',
                                        role: 'Head of Design')),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _TeamCard(
                                        initial: 'R',
                                        name: 'Raza',
                                        role: 'Lead Dev')),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Footer ────────────────────────────────
                      Text(
                        '© 2025 MA REIGNS. All rights reserved.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFF6B35), size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Value Card ───────────────────────────────────────────────────────────────
class _ValueCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _ValueCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Team Card ────────────────────────────────────────────────────────────────
class _TeamCard extends StatelessWidget {
  final String initial;
  final String name;
  final String role;

  const _TeamCard(
      {required this.initial, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4500).withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            role,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}