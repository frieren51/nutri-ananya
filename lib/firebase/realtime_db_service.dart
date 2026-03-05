import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // SAVE CUSTOMER
  Future<void> saveCustomer({
    required String uid,
    required String username,
    required String email,
    required String phoneNo,
    required String address,
    required double lat,
    required double lng,
  }) async {
    await _db.child('users').child(uid).set({
      'username': username,
      'email': email,
      'phoneNo': phoneNo,
      'address': address,
      'lat': lat,
      'lng': lng,
      'role': 'customer',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // SAVE SHOPKEEPER
  Future<void> saveShopkeeper({
    required String uid,
    required String username,
    required String email,
    required String phoneNo,
    required String shopName,
    required String shopNo,
    required String shopAddress,
    required double lat,
    required double lng,
  }) async {
    await _db.child('shops').child(uid).set({
      'username': username,
      'email': email,
      'phoneNo': phoneNo,
      'shopName': shopName,
      'shopNo': shopNo,
      'shopAddress': shopAddress,
      'lat': lat,
      'lng': lng,
      'role': 'shopkeeper',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // GET USERNAME (Checks both nodes)
  Future<String?> getUsername(String uid) async {
    // Try looking in users first
    DataSnapshot snapshot = await _db
        .child('users')
        .child(uid)
        .child('username')
        .get();

    // If not found, try looking in shops
    if (!snapshot.exists) {
      snapshot = await _db.child('shops').child(uid).child('username').get();
    }

    if (snapshot.exists) {
      return snapshot.value.toString();
    }
    return null;
  }

  // ADD REVIEW
  Future<void> addReview(String shopId, Map<String, dynamic> reviewData) async {
    // Used '_db' consistently as defined above
    await _db.child('reviews').child(shopId).push().set(reviewData);
  }
}
