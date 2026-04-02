import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shoescomm/core/app_colors.dart';
import 'package:shoescomm/core/app_routes.dart';
import 'package:shoescomm/pages/login_page.dart';
import 'package:shoescomm/pages/product_list_page.dart';
import 'package:shoescomm/supabase_config.dart';

/// Lightweight splash for low-spec devices: single fade, short duration, no repeating animations.
class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 800);
  static const _navDelay = Duration(seconds: 2);

  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    Timer(_navDelay, _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final isLoggedIn = SupabaseConfig.client.auth.currentSession != null;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            isLoggedIn ? const ProductListPage() : const LoginPage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primary,
                        Color(0xFFCC3300),
                      ],
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'images/2.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.directions_run,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'MA REIGNS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'STEP INTO GREATNESS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3,
                    color: AppColors.whiteOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
