import 'package:flutter/material.dart';
import 'package:nutrishield1/shopkeeper/manage_inventory.dart';
import 'package:nutrishield1/shopkeeper/customer_reviews.dart';
import 'package:nutrishield1/shopkeeper/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopkeeperHome extends StatefulWidget {
  const ShopkeeperHome({super.key});

  @override
  State<ShopkeeperHome> createState() => _ShopkeeperHomeState();
}

class _ShopkeeperHomeState extends State<ShopkeeperHome> {
  int _currentIndex = 0;

  // Centralized decoration for all cards
  final BoxDecoration _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE8), // NutriShield Cream Background
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF4E6B3A), // Brand Olive Green
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Get the current logged-in shopkeeper's ID
          final String? shopId = FirebaseAuth.instance.currentUser?.uid;

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageInventory()),
            );
          } else if (index == 2 && shopId != null) {
            // Check if shopId is not null
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CustomerReviews(shopId: shopId), // PASS SHOP ID HERE
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review_rounded),
            label: 'Reviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Shop Title Header
                const Text(
                  "Shopkeeper Dashboard",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Kumar's Organic Farm Store",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4E6B3A),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 25),

                /// Certification Badge
                _buildInfoCard(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: Colors.amber.shade700,
                  title: "Certification Status",
                  value: "Not Certified",
                  trailing: Icons.info_outline_rounded,
                ),

                const SizedBox(height: 16),

                /// Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.shopping_basket_rounded,
                        count: "6",
                        label: "Products Listed",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.stars_rounded,
                        count: "3",
                        label: "Customer Reviews",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// Quick Actions Section
                const Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                _buildActionTile(
                  context,
                  icon: Icons.add_business_rounded,
                  title: "Manage Inventory",
                  subtitle: "Update products and availability",
                  iconBg: const Color(0xFFE5EEDD),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageInventory(),
                    ),
                  ),
                ),

                _buildActionTile(
                  context,
                  icon: Icons.comment_bank_rounded,
                  title: "View Customer Reviews",
                  subtitle: "Read feedback from customers",
                  iconBg: const Color(0xFFFFF3D6),
                  onTap: () {
                    final String? shopId =
                        FirebaseAuth.instance.currentUser?.uid;
                    if (shopId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerReviews(
                            shopId: shopId,
                          ), // PASS SHOP ID HERE
                        ),
                      );
                    }
                  },
                ),

                _buildActionTile(
                  context,
                  icon: Icons.manage_accounts_rounded,
                  title: "My Profile",
                  subtitle: "Edit profile and shop details",
                  iconBg: const Color(0xFFEDE7E3),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
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

  // -------------------- REUSABLE COMPONENT METHODS --------------------

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required IconData trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(trailing, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: _cardDecoration,
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4E6B3A), size: 32),
          const SizedBox(height: 10),
          Text(
            count,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.black87),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
