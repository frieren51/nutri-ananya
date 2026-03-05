import 'package:flutter/material.dart';
import 'dart:async';
import 'profile_screen.dart';
import 'purity_checker_scan.dart';
import 'organicity_checker_scan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/realtime_db_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  bool _showSmiley = false;
  String _username = "User";
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();

  final Color mainBg = const Color(0xFFF5F1E9);
  final Color darkGreen = const Color(0xFF4A5D45);

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSmiley = true;
        });
      }
    });
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = await _dbService.getUsername(user.uid);

    if (name != null && mounted) {
      setState(() {
        _username = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome back,",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                _username,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Food Analysis",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    // Navigation logic makes this dynamic, so 'const' was removed here
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PurityCheckerScan(),
                          ),
                        );
                      },
                      child: _buildAnalysisCard(
                        icon: Icons.search,
                        title: "Purity Checker",
                        subtitle: "Analyze food purity",
                        iconBg: const Color(0xFFE8F5E9),
                        iconColor: const Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrganicityCheckerScan(),
                          ),
                        );
                      },
                      child: _buildAnalysisCard(
                        icon: Icons.eco,
                        title: "Organicity",
                        subtitle: "Check organic status",
                        iconBg: const Color(0xFFE8F5E9),
                        iconColor: const Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildQuickActionTile(
                icon: Icons.storefront,
                title: "Find Organic Shops",
                subtitle: "Discover verified shops near you",
                iconBg: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF4CAF50),
                onTap: () {},
              ),
              _buildQuickActionTile(
                icon: Icons.history,
                title: "Scan History",
                subtitle: "View your previous scans",
                iconBg: const Color(0xFFFFF9C4),
                iconColor: const Color(0xFFFBC02D),
              ),
              _buildQuickActionTile(
                icon: Icons.person_outline,
                title: "My Profile",
                subtitle: "Manage your account",
                iconBg: const Color(0xFFF0EBE0),
                iconColor: const Color(0xFF757575),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: darkGreen,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _showSmiley
              ? const Text(
                  "😊",
                  key: ValueKey('smiley'),
                  style: TextStyle(fontSize: 24),
                )
              : const Icon(
                  Icons.chat_bubble_outline,
                  key: ValueKey('chat'),
                  color: Colors.white,
                ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PurityCheckerScan(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Scan"),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            label: "Shops",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildAnalysisCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: iconBg,
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
    );
  }
}
