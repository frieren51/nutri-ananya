import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../onboarding/welcome_screen.dart'; // Adjust path as needed

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 🔹 Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // 🔹 Profile data variables
  String _username = 'Loading...';
  String _email = 'Loading...';
  String _phone = 'Loading...';
  String _shopName = 'Loading...';
  String _shopAddress = 'Loading...';
  String _shopNo = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShopkeeperData();
  }

  Future<void> _loadShopkeeperData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Fetching from 'shops' node as per your Signup logic
      final snapshot = await _db.child('shops').child(user.uid).get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          _username = data['username'] ?? 'N/A';
          _email = data['email'] ?? 'N/A';
          _phone = data['phoneNo'] ?? 'N/A';
          _shopName = data['shopName'] ?? 'N/A';
          _shopAddress = data['shopAddress'] ?? 'N/A';
          _shopNo = data['shopNo'] ?? 'N/A';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Shopkeeper Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4E6B3A)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  /// Personal Information Section
                  _buildSection(
                    title: "Personal Information",
                    children: [
                      _buildProfileTile(
                        Icons.person_outline,
                        "Full Name",
                        _username,
                      ),
                      _buildProfileTile(Icons.email_outlined, "Email", _email),
                      _buildProfileTile(Icons.phone_outlined, "Phone", _phone),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// Shop Information Section
                  _buildSection(
                    title: "Shop Information",
                    children: [
                      _buildProfileTile(
                        Icons.store_outlined,
                        "Shop Name",
                        _shopName,
                      ),
                      _buildProfileTile(Icons.tag, "Shop Number", _shopNo),
                      _buildProfileTile(
                        Icons.location_on_outlined,
                        "Address",
                        _shopAddress,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// Dark Mode Toggle (UI only)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFEDE7E3),
                          child: Icon(
                            Icons.dark_mode_outlined,
                            color: Color(0xFF4E6B3A),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dark Mode",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Toggle dark theme",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(value: false, onChanged: (val) {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// Edit Profile Button
                  ElevatedButton(
                    onPressed: () {
                      // Logic for editing profile can go here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E6B3A),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// Sign Out Button
                  OutlinedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Sign Out",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: _cardDecoration(),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileTile(IconData icon, String label, String value) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFF6EFE8),
        child: Icon(icon, color: Colors.grey, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black12.withOpacity(0.1)),
    );
  }
}
