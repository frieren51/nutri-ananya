import 'package:flutter/material.dart';
import 'customer_home_screen.dart';
import 'review_page.dart';
import '../models/shop_model.dart';

class ScanResultPage extends StatelessWidget {
  final ShopModel selectedShop; // Dynamic data passed from the scanner

  const ScanResultPage({super.key, required this.selectedShop});

  static const Color bgColor = Color(0xFFF7F1EA);
  static const Color cardColor = Color(0xFFFBF8F4);
  static const Color primaryGreen = Color(0xFF4A5D3A);
  static const Color textPrimary = Color(0xFF2F2F2F);
  static const Color textSecondary = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildProductHero(),
            const SizedBox(height: 16),
            _buildShopInfo(),
            const SizedBox(height: 16),
            _buildPurityCard(),
            const SizedBox(height: 16),
            _buildAnalysisCard(),
            const SizedBox(height: 16),
            _buildRecommendationCard(),
            const SizedBox(height: 24),

            // DYNAMIC REVIEW BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoreReviewPage(
                        shopName: selectedShop.shopName,
                        shopId: selectedShop.uid,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.star_outline, size: 20),
                label: Text("Review ${selectedShop.shopName}"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildBottomNav(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildShopInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storefront_outlined, size: 18, color: primaryGreen),
              SizedBox(width: 8),
              Text(
                "Purchased From",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedShop.shopName, // Dynamic
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      selectedShop.shopAddress, // Dynamic
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildRankBadge("Gold"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductHero() {
    return Hero(
      tag: 'product_image',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text("🍎", style: TextStyle(fontSize: 40)),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detected:",
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                      Text(
                        "Grapes",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildGradeBadge("A"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeBadge(String grade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            grade,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            "GRADE",
            style: TextStyle(
              fontSize: 9,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(String rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        rank,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPurityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Purity Score",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "98%",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.98,
              minHeight: 8,
              backgroundColor: Color(0xFFE0D8CF),
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Analysis Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _rowAnalysis("Pesticide Residue", "Very Low"),
          _rowAnalysis("Freshness", "Excellent"),
          _rowAnalysis("Surface Coating", "Natural Wax"),
          _rowAnalysis("Color Consistency", "Uniform"),
        ],
      ),
    );
  }

  Widget _rowAnalysis(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: textSecondary)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Text(
                "Recommendations",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text("• Safe for consumption", style: TextStyle(fontSize: 13)),
          Text(
            "• Wash before eating for best hygiene",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text("Scan Again"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              side: const BorderSide(color: Colors.black12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerHomeScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.home_outlined, size: 18),
            label: const Text("Home"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              side: const BorderSide(color: Colors.black12),
            ),
          ),
        ),
      ],
    );
  }
}
