import 'package:flutter/material.dart';
import 'package:shoescomm/core/app_routes.dart';
import 'package:shoescomm/core/app_theme.dart';
import 'package:shoescomm/supabase_config.dart';

export 'package:shoescomm/core/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoescomm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
