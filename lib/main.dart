import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kshetraiq/screens/splash_screen.dart';
import 'package:kshetraiq/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const KshetraIQApp());
}

class KshetraIQApp extends StatelessWidget {
  const KshetraIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KshetraIQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.primaryBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.forestGreen,
          primary: AppColors.forestGreen,
          secondary: AppColors.softTerracotta,
          surface: AppColors.secondaryBackground,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}