import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import '../models/shop_model.dart';
import 'scan_result_page.dart';

class PurityCheckerScan extends StatefulWidget {
  const PurityCheckerScan({super.key});

  @override
  State<PurityCheckerScan> createState() => _PurityCheckerScanState();
}

class _PurityCheckerScanState extends State<PurityCheckerScan> {
  static const Color bgColor = Color(0xFFF7F1EA);
  static const Color cardColor = Color(0xFFFBF8F4);
  static const Color borderGreen = Color(0xFF6F8553);
  static const Color buttonGreen = Color(0xFF5E6F2D);
  static const Color textPrimary = Color(0xFF2F2F2F);
  static const Color textSecondary = Color(0xFF8A8A8A);

  // 🔹 Fetch shops from Firebase
  void _fetchShopsAndShowUI() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: buttonGreen)),
    );

    try {
      final DatabaseReference db = FirebaseDatabase.instance.ref();
      DataSnapshot snapshot = await db.child('shops').get();

      if (mounted) Navigator.pop(context);

      if (snapshot.exists) {
        Map<dynamic, dynamic> shopsMap = snapshot.value as Map;
        List<ShopModel> shopsList = [];

        shopsMap.forEach((key, value) {
          shopsList.add(ShopModel.fromMap(value, key));
        });

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => ShopSelectionDialog(shops: shopsList),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Purity Checker",
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderGreen, width: 1.5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 42,
                    color: Color(0xFF9A9A9A),
                  ),
                  SizedBox(height: 14),
                  Text(
                    "Capture or upload food image",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            _buildButton("Take Photo", Icons.camera_alt, true),
            const SizedBox(height: 14),
            _buildButton("Upload from Gallery", Icons.upload_file, false),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, bool isPrimary) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _fetchShopsAndShowUI,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? buttonGreen : Colors.white,
          foregroundColor: isPrimary ? Colors.white : textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFD6D1CB)),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// ---------------- SHOP SELECTION DIALOG ----------------

class ShopSelectionDialog extends StatefulWidget {
  final List<ShopModel> shops;
  const ShopSelectionDialog({super.key, required this.shops});

  @override
  State<ShopSelectionDialog> createState() => _ShopSelectionDialogState();
}

class _ShopSelectionDialogState extends State<ShopSelectionDialog> {
  Position? _currentPosition;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredShops = widget.shops.where((shop) {
      return shop.shopName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFF7F1EA),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storefront_outlined, color: Color(0xFF5E6F2D)),
                    SizedBox(width: 8),
                    Text(
                      "Select Shop Where You Purchased",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search shop name...",
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6F8553)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6F8553)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredShops.length,
                itemBuilder: (context, index) =>
                    _buildShopCard(context, filteredShops[index], index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, ShopModel shop, int index) {
    String badge = index == 0
        ? "Gold"
        : index == 1
        ? "Silver"
        : "Bronze";

    Color badgeColor = index == 0
        ? const Color(0xFFE6C46A)
        : index == 1
        ? Colors.grey
        : const Color(0xFFCD7F32);

    // ✅ FIXED DISTANCE CALCULATION (Geolocator only)
    String distanceText = "Calculating...";
    if (_currentPosition != null && shop.lat != 0.0) {
      double meter = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        shop.lat,
        shop.lng,
      );
      distanceText = "${(meter / 1000).toStringAsFixed(1)} km";
    }

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultPage(selectedShop: shop),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  shop.shopName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bookmark, size: 10, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        badge,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              shop.shopAddress,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  distanceText,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.circle, size: 4, color: Colors.grey),
                const SizedBox(width: 8),
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                const Text(
                  "4.8 (24 reviews)",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
