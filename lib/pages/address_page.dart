import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoescomm/core/validators.dart';
import 'package:shoescomm/service/ecommerce_service.dart';
import 'order_page.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();

  final EcommerceService _service = EcommerceService.instance;
  bool _isLoading = false;

  // Focus tracking
  final Map<String, bool> _focused = {
    'name': false,
    'phone': false,
    'address': false,
    'city': false,
    'country': false,
  };

  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));
    _entryController.forward();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _country.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final userId = _service.client.auth.currentUser!.id;

      final response = await _service.client.from('addresses').insert({
        'user_id': userId,
        'full_name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'address_line': _address.text.trim(),
        'city': _city.text.trim(),
        'country': _country.text.trim(),
      }).select().single();

      if (!mounted) return;

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => OrderPage(addressId: response['id']),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to place order: $e', isError: true);
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
            Expanded(
              child: Text(msg, style: const TextStyle(color: Colors.white)),
            ),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 15),
          ),
        ),
        title: const Text(
          'Delivery Address',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress indicator
                        _StepIndicator(currentStep: 2),

                        const SizedBox(height: 28),

                        // Section header
                        _sectionHeader(
                            Icons.person_outline, 'Personal Information'),
                        const SizedBox(height: 14),

                        _buildField(
                          key: 'name',
                          controller: _name,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          hint: 'e.g. John Doe',
                          validator: (v) => Validators.name(v, 'Full name'),
                        ),
                        const SizedBox(height: 14),

                        _buildField(
                          key: 'phone',
                          controller: _phone,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          hint: 'e.g. +1 234 567 8900',
                          keyboardType: TextInputType.phone,
                          validator: Validators.phone,
                        ),

                        const SizedBox(height: 28),

                        _sectionHeader(
                            Icons.location_on_outlined, 'Delivery Location'),
                        const SizedBox(height: 14),

                        _buildField(
                          key: 'address',
                          controller: _address,
                          label: 'Street Address',
                          icon: Icons.home_outlined,
                          hint: 'e.g. 123 Main Street, Apt 4B',
                          maxLines: 2,
                          validator: (v) => Validators.required(v, 'Street address'),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                key: 'city',
                                controller: _city,
                                label: 'City',
                                icon: Icons.location_city_outlined,
                                hint: 'e.g. New York',
                                validator: (v) => Validators.required(v, 'City'),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildField(
                                key: 'country',
                                controller: _country,
                                label: 'Country',
                                icon: Icons.flag_outlined,
                                hint: 'e.g. USA',
                                validator: (v) => Validators.required(v, 'Country'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Delivery note card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4500).withOpacity(0.07),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFF4500).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_shipping_outlined,
                                  color: Color(0xFFFF6B35), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Standard Delivery',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Estimated 3–5 business days',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.green.withOpacity(0.25)),
                                ),
                                child: const Text(
                                  'FREE',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
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

                // Bottom CTA
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.06)),
                    ),
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: GestureDetector(
                    onTap: _isLoading ? null : _placeOrder,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 54,
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
                            color:
                            const Color(0xFFFF4500).withOpacity(0.4),
                            blurRadius: 20,
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
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle_outline,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Place Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFFF4500).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFF6B35), size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
      onFocusChange: (focused) =>
          setState(() => _focused[key] = focused),
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
              color: Colors.white.withOpacity(0.2),
              fontSize: 13,
            ),
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
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ),
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Cart', 'Address', 'Order'];

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = (i ~/ 2) + 1;
          final isCompleted = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted
                  ? const Color(0xFFFF4500)
                  : Colors.white.withOpacity(0.1),
            ),
          );
        }

        final stepIndex = i ~/ 2 + 1;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isCurrent || isCompleted
                    ? const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                )
                    : null,
                color: isCurrent || isCompleted
                    ? null
                    : Colors.white.withOpacity(0.07),
                border: Border.all(
                  color: isCurrent
                      ? Colors.transparent
                      : isCompleted
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.15),
                ),
                boxShadow: isCurrent
                    ? [
                  BoxShadow(
                    color: const Color(0xFFFF4500).withOpacity(0.4),
                    blurRadius: 10,
                  )
                ]
                    : [],
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text(
                  '$stepIndex',
                  style: TextStyle(
                    color: isCurrent
                        ? Colors.white
                        : Colors.white.withOpacity(0.35),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[stepIndex - 1],
              style: TextStyle(
                color: isCurrent
                    ? const Color(0xFFFF6B35)
                    : Colors.white.withOpacity(0.3),
                fontSize: 11,
                fontWeight:
                isCurrent ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}