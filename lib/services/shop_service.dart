import 'package:firebase_database/firebase_database.dart';

class ShopService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<List<Map<String, dynamic>>> getAllShops() async {
    try {
      // 1. Fetch the data
      final snapshot = await _db.child('shops').get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      // 2. Safely handle the data structure
      // We iterate over snapshot.children instead of casting the whole value
      // This is much safer and handles both Map and List structures from Firebase
      List<Map<String, dynamic>> shops = [];

      for (var child in snapshot.children) {
        final value = child.value;
        if (value is Map) {
          shops.add({'id': child.key, ...Map<String, dynamic>.from(value)});
        }
      }

      return shops;
    } catch (e) {
      print("Error fetching shops: $e");
      return [];
    }
  }
}
