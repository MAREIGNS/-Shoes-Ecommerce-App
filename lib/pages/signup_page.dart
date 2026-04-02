import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shoescomm/core/validators.dart';
import '../supabase_config.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final client = SupabaseConfig.client;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  XFile? selectedImage;
  bool isLoading = false;
  bool _obscurePassword = true;

  final Map<String, bool> _focused = {
    'name': false,
    'email': false,
    'password': false,
  };

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _headerAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)));
    _headerAnim = CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic));
    _entryController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImage = image);
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();

      final response = await client.auth.signUp(email: email, password: password);
      final user = response.user;
      if (user == null) throw Exception("Signup failed");

      String? imageUrl;

      if (selectedImage != null) {
        final fileExt = selectedImage!.name.split('.').last;
        final fileName = '${user.id}.$fileExt';

        if (kIsWeb) {
          final bytes = await selectedImage!.readAsBytes();
          await client.storage.from('user-images').uploadBinary(
              fileName, bytes,
              fileOptions: const FileOptions(upsert: true));
        } else {
          final file = File(selectedImage!.path);
          await client.storage.from('user-images').upload(
              fileName, file,
              fileOptions: const FileOptions(upsert: true));
        }
        imageUrl = client.storage.from('user-images').getPublicUrl(fileName);
      }

      await client.from('users').insert({
        'id': user.id,
        'name': name,
        'email': email,
        'image_url': imageUrl,
      });

      if (!mounted) return;
      _showSnack('Account created! Welcome to MA REIGNS 👟', isError: false);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } on AuthException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (e) {
      _showSnack('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
            Expanded(
                child: Text(msg, style: const TextStyle(color: Colors.white))),
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
          // Background decorations
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4500).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4500).withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.04),

                  // ── Header ───────────────────────────────────────
                  FadeTransition(
                    opacity: _headerAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            const SizedBox(width: 14),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                    colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                                  ).createShader(bounds),
                              child: const Icon(Icons.directions_run,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 8),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                    colors: [
                                      Color(0xFFFFFFFF),
                                      Color(0xFFFF6B35)
                                    ],
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

                        SizedBox(height: size.height * 0.04),

                        const Text(
                          'Create\nAccount 🚀',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Join the MA REIGNS family today',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.45),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // ── Form ─────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Avatar picker
                            Center(
                              child: GestureDetector(
                                onTap: pickImage,
                                child: Stack(
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                      const Duration(milliseconds: 300),
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: selectedImage == null
                                            ? null
                                            : const LinearGradient(
                                          colors: [
                                            Color(0xFFFF6B35),
                                            Color(0xFFFF4500)
                                          ],
                                        ),
                                        color: selectedImage == null
                                            ? Colors.white.withOpacity(0.06)
                                            : null,
                                        border: Border.all(
                                          color: selectedImage != null
                                              ? const Color(0xFFFF4500)
                                              : Colors.white.withOpacity(0.1),
                                          width: 2,
                                        ),
                                        boxShadow: selectedImage != null
                                            ? [
                                          BoxShadow(
                                            color:
                                            const Color(0xFFFF4500)
                                                .withOpacity(0.4),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          )
                                        ]
                                            : [],
                                      ),
                                      child: ClipOval(
                                        child: selectedImage != null
                                            ? (kIsWeb
                                            ? Image.network(
                                            selectedImage!.path,
                                            fit: BoxFit.cover)
                                            : Image.file(
                                            File(selectedImage!.path),
                                            fit: BoxFit.cover))
                                            : Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt_outlined,
                                              color: Colors.white
                                                  .withOpacity(0.4),
                                              size: 26,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Upload',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Edit badge
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFFF6B35),
                                              Color(0xFFFF4500)
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.edit,
                                            color: Colors.white, size: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                            Text(
                              'Tap to add profile photo',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Name field
                            _buildField(
                              key: 'name',
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                              hint: 'e.g. John Doe',
                              validator: (v) => Validators.name(v, 'Full name'),
                            ),

                            const SizedBox(height: 14),

                            _buildField(
                              key: 'email',
                              controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.email_outlined,
                              hint: 'e.g. john@email.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),

                            const SizedBox(height: 14),

                            // Password field
                            _buildPasswordField(),

                            const SizedBox(height: 32),

                            // Sign up button
                            GestureDetector(
                              onTap: isLoading ? null : signUp,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: isLoading
                                      ? LinearGradient(colors: [
                                    Colors.grey.shade800,
                                    Colors.grey.shade700,
                                  ])
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
                                  boxShadow: isLoading
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
                                  child: isLoading
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
                                      Icon(Icons.rocket_launch_outlined,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Create Account',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
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
                                    'already have an account?',
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

                            // Sign in link
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushReplacementNamed(context, '/login'),
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
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Already a member? ',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.45),
                                        fontSize: 14,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'Sign In',
                                          style: TextStyle(
                                            color: Color(0xFFFF6B35),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String key,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isFocused = _focused[key] ?? false;
    return Focus(
      onFocusChange: (f) => setState(() => _focused[key] = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFocused
                ? const Color(0xFFFF4500)
                : Colors.white.withOpacity(0.1),
            width: isFocused ? 1.5 : 1,
          ),
          color: Colors.white.withOpacity(0.05),
          boxShadow: isFocused
              ? [
            BoxShadow(
              color: const Color(0xFFFF4500).withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ]
              : [],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.2), fontSize: 13),
            labelStyle: TextStyle(
              color: isFocused
                  ? const Color(0xFFFF6B35)
                  : Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused
                  ? const Color(0xFFFF4500)
                  : Colors.white.withOpacity(0.3),
              size: 19,
            ),
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    final isFocused = _focused['password'] ?? false;
    return Focus(
      onFocusChange: (f) => setState(() => _focused['password'] = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFocused
                ? const Color(0xFFFF4500)
                : Colors.white.withOpacity(0.1),
            width: isFocused ? 1.5 : 1,
          ),
          color: Colors.white.withOpacity(0.05),
          boxShadow: isFocused
              ? [
            BoxShadow(
              color: const Color(0xFFFF4500).withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ]
              : [],
        ),
        child: TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Min. 6 characters',
            hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.2), fontSize: 13),
            labelStyle: TextStyle(
              color: isFocused
                  ? const Color(0xFFFF6B35)
                  : Colors.white.withOpacity(0.4),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: isFocused
                  ? const Color(0xFFFF4500)
                  : Colors.white.withOpacity(0.3),
              size: 19,
            ),
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white.withOpacity(0.35),
                size: 20,
              ),
            ),
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (v) => Validators.password(v),
        ),
      ),
    );
  }
}