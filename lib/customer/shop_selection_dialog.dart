import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/shop_model.dart';
import 'scan_result_page.dart';

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
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED SEARCH LOGIC
    final String query = _searchQuery.trim().toLowerCase();

    final List<ShopModel> filteredShops = widget.shops.where((shop) {
      if (query.isEmpty) return true;

      return shop.shopName.toLowerCase().contains(query) ||
          shop.shopAddress.toLowerCase().contains(query);
    }).toList();

    // ✅ SORT BY DISTANCE (NEAREST FIRST)
    if (_currentPosition != null) {
      filteredShops.sort((a, b) {
        final distA = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          a.lat,
          a.lng,
        );
        final distB = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          b.lat,
          b.lng,
        );
        return distA.compareTo(distB);
      });
    }

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

            // 🔍 SEARCH FIELD (UNCHANGED UI)
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

            // 📋 SHOP LIST
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

    // 📏 DISTANCE TEXT
    String distanceText = "Calculating...";
    if (_currentPosition != null && shop.lat != 0.0) {
      final meter = Geolocator.distanceBetween(
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
          MaterialPageRoute(builder: (_) => ScanResultPage(selectedShop: shop)),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
