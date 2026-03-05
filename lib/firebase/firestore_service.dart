import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // SAVE CUSTOMER
  Future<void> saveCustomer({
    required String uid,
    required String username,
    required String email,
    required String phoneNo,
    required String address,
  }) async {
    await _db.collection('users').doc(uid).set({
      'username': username,
      'email': email,
      'phoneNo': phoneNo,
      'address': address,
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
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
  }) async {
    await _db.collection('shops').doc(uid).set({
      'username': username,
      'email': email,
      'phoneNo': phoneNo,
      'shopName': shopName,
      'shopNo': shopNo,
      'shopAddress': shopAddress,
      'role': 'shopkeeper',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
