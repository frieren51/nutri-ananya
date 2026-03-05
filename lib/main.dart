import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'onboarding/welcome_screen.dart';

const Color appBackgroundColor = Color(0xFFFBF4EE);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🔥 Before Firebase init");

  await Firebase.initializeApp();
  print("✅ Firebase initialized");

  runApp(const NutriShieldApp());
}

class NutriShieldApp extends StatelessWidget {
  const NutriShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriShield',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: appBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
          surface: appBackgroundColor,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
