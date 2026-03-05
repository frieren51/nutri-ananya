import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'signin_screen.dart';
import '../firebase/firebase_auth_service.dart';
import '../firebase/realtime_db_service.dart';
import '../customer/customer_home_screen.dart';
import '../shopkeeper/shopkeeper_home.dart';
import '../widgets/shop_location_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();

  final Color appBackgroundColor = const Color(0xFFFBF4EE);
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color fieldFillColor = const Color(0xFFF9FAFB);

  String? selectedRole;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  double? _shopLat;
  double? _shopLng;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _customerAddressController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopNumberController = TextEditingController();
  final _shopAddressController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _customerAddressController.dispose();
    _shopNameController.dispose();
    _shopNumberController.dispose();
    _shopAddressController.dispose();
    super.dispose();
  }

  Future<Position> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    if (selectedRole == "Shopkeeper" &&
        (_shopLat == null || _shopLng == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select shop location")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    try {
      final user = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: selectedRole!,
      );

      if (user == null) throw Exception("Signup failed");

      if (selectedRole == "Customer") {
        Position pos = await _getLocation();
        await _dbService.saveCustomer(
          uid: user.uid,
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNo: _phoneController.text.trim(),
          address: _customerAddressController.text.trim(),
          lat: pos.latitude,
          lng: pos.longitude,
        );
      } else {
        await _dbService.saveShopkeeper(
          uid: user.uid,
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNo: _phoneController.text.trim(),
          shopName: _shopNameController.text.trim(),
          shopNo: _shopNumberController.text.trim(),
          shopAddress: _shopAddressController.text.trim(),
          lat: _shopLat!,
          lng: _shopLng!,
        );
      }

      if (mounted) Navigator.pop(context); // Close loading dialog

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => selectedRole == "Shopkeeper"
              ? const ShopkeeperHome()
              : const CustomerHomeScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (mounted) Navigator.pop(context); // Fixed: Close loading on error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 32),
                const Text(
                  "Create your account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose your role to get started",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _roleCard("Customer", Icons.person_outline),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _roleCard("Shopkeeper", Icons.store_outlined),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                _field(
                  "Username",
                  _usernameController,
                  icon: Icons.person_outline,
                ),
                _field(
                  "Email",
                  _emailController,
                  type: TextInputType.emailAddress,
                  icon: Icons.email_outlined,
                ),
                _field(
                  "Phone",
                  _phoneController,
                  type: TextInputType.phone,
                  icon: Icons.phone_outlined,
                ),

                _passwordField(
                  "Password",
                  _passwordController,
                  _isPasswordVisible,
                  () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                _passwordField(
                  "Confirm Password",
                  _confirmPasswordController,
                  _isConfirmPasswordVisible,
                  () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                ),

                if (selectedRole == "Customer")
                  _field(
                    "Address",
                    _customerAddressController,
                    icon: Icons.home_outlined,
                  ),

                if (selectedRole == "Shopkeeper") ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    "Shop Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _field(
                    "Shop Name",
                    _shopNameController,
                    icon: Icons.storefront,
                  ),
                  _field(
                    "Shop Number",
                    _shopNumberController,
                    icon: Icons.numbers,
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShopLocationPicker(),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _shopLat = result['latlng'].latitude;
                            _shopLng = result['latlng'].longitude;
                            // Pre-fill the address controller with the selected address
                            _shopAddressController.text =
                                result['address'] ?? "";
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: _shopLat != null
                              ? primaryGreen
                              : Colors.grey.shade400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        Icons.map_rounded,
                        color: _shopLat != null ? primaryGreen : Colors.grey,
                      ),
                      label: Text(
                        _shopLat != null
                            ? "Location Selected"
                            : "Pin Shop Location on Map",
                        style: TextStyle(
                          color: _shopLat != null
                              ? primaryGreen
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  _field(
                    "Shop Address",
                    _shopAddressController,
                    icon: Icons.location_on_outlined,
                  ),
                ],

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: selectedRole == null ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(color: Colors.black54),
                        children: [
                          TextSpan(
                            text: "Sign in",
                            style: TextStyle(
                              color: darkGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  Widget _header() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: Colors.green,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "NutriShield",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _roleCard(String role, IconData icon) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryGreen : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              role,
              style: TextStyle(
                color: isSelected ? primaryGreen : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          filled: true,
          fillColor: fieldFillColor,
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryGreen, width: 2),
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool visible,
    VoidCallback toggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextFormField(
        controller: controller,
        obscureText: !visible,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          filled: true,
          fillColor: fieldFillColor,
          labelStyle: TextStyle(color: Colors.grey[600]),
          suffixIcon: IconButton(
            icon: Icon(
              visible ? Icons.visibility : Icons.visibility_off,
              size: 20,
            ),
            onPressed: toggle,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryGreen, width: 2),
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }
}
