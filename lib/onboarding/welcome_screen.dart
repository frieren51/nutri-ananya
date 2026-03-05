import 'package:flutter/material.dart';
import 'intro_screen.dart';

// Your central Boho Chic color
const Color appBackgroundColor = Color(0xFFFBF4EE);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CHANGED: Updated from 0xFFF7F9F4 to your custom appBackgroundColor
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // LOGO
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF3BAA4A), // NutriShield Green
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 52,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 26),

              // APP NAME
              RichText(
                text: const TextSpan(
                  text: 'Nutri',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: 'Shield',
                      style: TextStyle(color: Color(0xFF3BAA4A)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // TAGLINE
              const Text(
                'Your Food Safety Guardian',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 36),

              // DESCRIPTION
              const Text(
                'Analyze food purity and organicity\nwith intelligent assessments',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 44),

              // GET STARTED BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IntroScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3BAA4A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
