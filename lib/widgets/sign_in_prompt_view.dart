import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_routes.dart';

/// Shown when a feature requires auth. Reduces duplicate "sign in" UI.
class SignInPromptView extends StatelessWidget {
  const SignInPromptView({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.login_rounded,
              size: 48,
              color: AppColors.whiteOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.whiteOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Sign in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
