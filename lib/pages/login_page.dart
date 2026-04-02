import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shoescomm/core/validators.dart';
import '../service/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserService _userService = UserService.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  late AnimationController _entryController;
  late AnimationController _buttonController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _footerFade;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryController, curve: const Interval(0.0, 0.5)),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));

    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryController, curve: const Interval(0.3, 0.8)),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)));

    _footerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryController, curve: const Interval(0.6, 1.0)),
    );

    _buttonScale = _buttonController;

    _entryController.forward();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Button press animation
    await _buttonController.reverse();
    _buttonController.forward();

    setState(() => _isLoading = true);

    try {
      await _userService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      _showSnack("Welcome back! 👟", isError: false);
      Navigator.pushReplacementNamed(context, '/productlist');
    } on AuthException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack("Something went wrong. Please try again.", isError: true);
    }

    if (mounted) setState(() => _isLoading = false);
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4500).withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF4500).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A2E).withOpacity(0.8),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                  width: 1,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.07),

                  // Header
                  SlideTransition(
                    position: _headerSlide,
                    child: FadeTransition(
                      opacity: _headerFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo row
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B35),
                                      Color(0xFFFF4500),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF4500)
                                          .withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.directions_run,
                                    color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFFFFFFF),
                                        Color(0xFFFF6B35),
                                      ],
                                    ).createShader(bounds),
                                child: const Text(
                                  'MA REIGNS',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.06),

                          const Text(
                            'Welcome\nBack 👋',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Sign in to continue your journey',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.45),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // Form
                  SlideTransition(
                    position: _formSlide,
                    child: FadeTransition(
                      opacity: _formFade,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email field
                            Focus(
                              onFocusChange: (focused) =>
                                  setState(() => _emailFocused = focused),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _emailFocused
                                        ? const Color(0xFFFF4500)
                                        : Colors.white.withOpacity(0.1),
                                    width: _emailFocused ? 1.5 : 1,
                                  ),
                                  color: Colors.white.withOpacity(0.05),
                                  boxShadow: _emailFocused
                                      ? [
                                    BoxShadow(
                                      color: const Color(0xFFFF4500)
                                          .withOpacity(0.15),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    )
                                  ]
                                      : [],
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    labelStyle: TextStyle(
                                      color: _emailFocused
                                          ? const Color(0xFFFF6B35)
                                          : Colors.white.withOpacity(0.4),
                                      fontSize: 13,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: _emailFocused
                                          ? const Color(0xFFFF4500)
                                          : Colors.white.withOpacity(0.3),
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 18),
                                  ),
                                  validator: Validators.email,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Password field
                            Focus(
                              onFocusChange: (focused) =>
                                  setState(() => _passwordFocused = focused),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _passwordFocused
                                        ? const Color(0xFFFF4500)
                                        : Colors.white.withOpacity(0.1),
                                    width: _passwordFocused ? 1.5 : 1,
                                  ),
                                  color: Colors.white.withOpacity(0.05),
                                  boxShadow: _passwordFocused
                                      ? [
                                    BoxShadow(
                                      color: const Color(0xFFFF4500)
                                          .withOpacity(0.15),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    )
                                  ]
                                      : [],
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      color: _passwordFocused
                                          ? const Color(0xFFFF6B35)
                                          : Colors.white.withOpacity(0.4),
                                      fontSize: 13,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: _passwordFocused
                                          ? const Color(0xFFFF4500)
                                          : Colors.white.withOpacity(0.3),
                                      size: 20,
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white.withOpacity(0.35),
                                        size: 20,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 18),
                                  ),
                                  validator: (v) => Validators.password(v),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: const Color(0xFFFF6B35)
                                        .withOpacity(0.85),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Login Button
                            ScaleTransition(
                              scale: _buttonScale,
                              child: GestureDetector(
                                onTap: _isLoading ? null : _login,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: _isLoading
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
                                    boxShadow: _isLoading
                                        ? []
                                        : [
                                      BoxShadow(
                                        color: const Color(0xFFFF4500)
                                            .withOpacity(0.45),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                        : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'or continue with',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Google button
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                  color: Colors.white.withOpacity(0.04),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Simple G icon
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF4285F4),
                                            Color(0xFF34A853),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'G',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Continue with Google',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.65),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Sign up footer
                  FadeTransition(
                    opacity: _footerFade,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFFFF6B35),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}