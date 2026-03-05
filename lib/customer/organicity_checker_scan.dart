import 'package:flutter/material.dart';

class OrganicityCheckerScan extends StatefulWidget {
  const OrganicityCheckerScan({super.key});

  @override
  State<OrganicityCheckerScan> createState() => _OrganicityCheckerScanState();
}

class _OrganicityCheckerScanState extends State<OrganicityCheckerScan> {
  // Colors (exact match)
  static const Color bgColor = Color(0xFFF7F1EA);
  static const Color cardColor = Color(0xFFFBF8F4);
  static const Color borderGreen = Color(0xFF6F8553);
  static const Color buttonGreen = Color(0xFF5E6F2D);
  static const Color textPrimary = Color(0xFF2F2F2F);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color tipsBg = Color(0xFFF4EFE9);

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
          "Organicity Checker",
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // IMAGE CAPTURE BOX
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderGreen, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 42,
                    color: Color(0xFF9A9A9A),
                  ),
                  SizedBox(height: 14),
                  Text(
                    "Capture or upload food image",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "For best results, use good lighting",
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // TAKE PHOTO BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text(
                  "Take Photo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // UPLOAD FROM GALLERY BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.upload_file,
                  size: 18,
                  color: textPrimary,
                ),
                label: const Text(
                  "Upload from Gallery",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  side: const BorderSide(color: Color(0xFFD6D1CB)),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // TIPS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tipsBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFFFFB300),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Tips for accurate results",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "• Place item on a clean, plain surface",
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "• Ensure good, natural lighting",
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "• Capture the entire item in frame",
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "• Avoid shadows on the food item",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
