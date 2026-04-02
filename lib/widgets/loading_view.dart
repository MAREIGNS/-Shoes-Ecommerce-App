import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Single loading indicator used across the app. Lighter than per-page custom painters.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        strokeWidth: 2.5,
      ),
    );
  }
}
