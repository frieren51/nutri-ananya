import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Add this for RTDB

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Database ka reference create karein
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // SIGN UP (Existing logic updated to support both nodes)
  Future<User?> signUp({
    required String email,
    required String password,
    required String role,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = credential.user;

    if (user != null) {
      // 1. Requirement: Database node decide karein based on role
      String node = (role == 'Shopkeeper') ? 'shops' : 'users';

      // 2. Register hone ke baad user ka data sahi node mein save karein
      await _dbRef.child(node).child(user.uid).set({
        'email': email,
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    return user;
  }

  // LOGIN (Aapka existing login logic)
  Future<User?> login({required String email, required String password}) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // Sign In with Role Verification
  Future<User?> signInWithEmailAndRole(
    String email,
    String password,
    String selectedRole,
  ) async {
    try {
      // 1. Authenticate karein
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        // 2. Requirement: Dynamic path check based on your DB structure
        String node = (selectedRole == 'Shopkeeper') ? 'shops' : 'users';

        // 3. Sahi node se role fetch karein
        DataSnapshot snapshot = await _dbRef.child(node).child(user.uid).get();

        if (snapshot.exists) {
          final userData = Map<dynamic, dynamic>.from(snapshot.value as Map);
          String storedRole = userData['role'];

          // 4. Role Match check
          if (storedRole.toLowerCase() == selectedRole.toLowerCase()) {
            return user;
          } else {
            await _auth.signOut();
            throw 'Access Denied: You are registered as $storedRole';
          }
        } else {
          await _auth.signOut();
          throw 'User record not found in $node.';
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
