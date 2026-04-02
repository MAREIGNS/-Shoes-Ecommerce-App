import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoescomm/core/validators.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;
  bool _sent = false;

  final Map<String, bool> _focused = {
    'name': false,
    'email': false,
    'message': false,
  };

  late AnimationController _entryController;
  late AnimationController _successController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _successScale;
  late Animation<double> _successFade;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _successController = AnimationController(
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
    _successScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successFade =
        CurvedAnimation(parent: _successController, curve: Curves.easeIn);
    _entryController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _entryController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSending = true);

    // Simulate sending
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() {
      _isSending = false;
      _sent = true;
    });
    HapticFeedback.heavyImpact();
    _successController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4500).withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
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
            child: _sent
                ? _buildSuccessScreen()
                : FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // Custom AppBar
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                Colors.white.withOpacity(0.06),
                                borderRadius:
                                BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white
                                        .withOpacity(0.08)),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 15),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Contact Us',
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

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
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
                                              .withOpacity(0.45),
                                          blurRadius: 24,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                        Icons.contact_mail_outlined,
                                        color: Colors.white,
                                        size: 32),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Get In Touch',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Have a question or feedback? We\'d\nlove to hear from you.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                      Colors.white.withOpacity(0.4),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Contact info cards
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.email_outlined,
                                    label: 'Email',
                                    value: 'hello@mareigns.com',
                                    color: const Color(0xFF2196F3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _InfoCard(
                                    icon: Icons.phone_outlined,
                                    label: 'Phone',
                                    value: '+1 800 REIGNS',
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            _InfoCard(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              value:
                              '123 Sole Street, Fashion District, NY 10001',
                              color: const Color(0xFFFF4500),
                              fullWidth: true,
                            ),

                            const SizedBox(height: 28),

                            // Section header
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4500)
                                        .withOpacity(0.12),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.edit_outlined,
                                      color: Color(0xFFFF6B35),
                                      size: 16),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Send a Message',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildField(
                                    key: 'name',
                                    controller: _nameController,
                                    label: 'Your Name',
                                    icon: Icons.person_outline,
                                    hint: 'e.g. John Doe',
                                    validator: (v) => Validators.name(v, 'name'),
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    key: 'email',
                                    controller: _emailController,
                                    label: 'Email Address',
                                    icon: Icons.email_outlined,
                                    hint: 'e.g. john@email.com',
                                    keyboardType:
                                    TextInputType.emailAddress,
                                    validator: Validators.email,
                                  ),
                                  const SizedBox(height: 14),
                                  _buildField(
                                    key: 'message',
                                    controller: _messageController,
                                    label: 'Message',
                                    icon: Icons.chat_bubble_outline,
                                    hint:
                                    'Write your message here...',
                                    maxLines: 5,
                                    validator: Validators.message,
                                  ),
                                  const SizedBox(height: 28),

                                  // Send button
                                  GestureDetector(
                                    onTap:
                                    _isSending ? null : _sendMessage,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      width: double.infinity,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        gradient: _isSending
                                            ? LinearGradient(colors: [
                                          Colors.grey.shade800,
                                          Colors.grey.shade700,
                                        ])
                                            : const LinearGradient(
                                          begin:
                                          Alignment.topLeft,
                                          end: Alignment
                                              .bottomRight,
                                          colors: [
                                            Color(0xFFFF6B35),
                                            Color(0xFFFF4500),
                                            Color(0xFFCC3300),
                                          ],
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(16),
                                        boxShadow: _isSending
                                            ? []
                                            : [
                                          BoxShadow(
                                            color: const Color(
                                                0xFFFF4500)
                                                .withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(
                                                0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: _isSending
                                            ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child:
                                          CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                            : Row(
                                          mainAxisSize:
                                          MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.send_rounded,
                                                color: Colors.white,
                                                size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              'Send Message',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight:
                                                FontWeight.w700,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
    int maxLines = 1,
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
          maxLines: maxLines,
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

  Widget _buildSuccessScreen() {
    return FadeTransition(
      opacity: _successFade,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _successScale,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4500).withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 54),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Message Sent! 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thanks for reaching out!\nWe\'ll get back to you within 24 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36, vertical: 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4500).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
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

// ─── Info Card ────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: fullWidth ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
