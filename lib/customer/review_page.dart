import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/realtime_db_service.dart';

class StoreReviewPage extends StatefulWidget {
  final String shopName;
  final String shopId; // Required to save the review to the correct shop

  const StoreReviewPage({
    super.key,
    required this.shopName,
    required this.shopId,
  });

  @override
  State<StoreReviewPage> createState() => _StoreReviewPageState();
}

class _StoreReviewPageState extends State<StoreReviewPage> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final RealtimeDatabaseService _dbService = RealtimeDatabaseService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleReviewSubmit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Fetch the customer's username using your existing service method
      String? username = await _dbService.getUsername(user.uid);

      Map<String, dynamic> reviewData = {
        "customerName": username ?? "Verified User",
        "rating": _selectedRating,
        "comment": _commentController.text.trim(),
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };

      // Calls the addReview function you added to realtime_db_service.dart
      await _dbService.addReview(widget.shopId, reviewData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Review submitted. Thank you!"),
            backgroundColor: Color(0xFF4A5D3A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed to submit: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Write a Review",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How was your experience with ${widget.shopName}?",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your feedback helps others choose healthy products.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              "Your Rating",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      index < _selectedRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 48,
                      color: index < _selectedRating
                          ? Colors.amber
                          : Colors.grey[300],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            const Text(
              "Your Comments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Share your experience with the product and shop...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedRating == 0 || _isSubmitting)
                    ? null
                    : _handleReviewSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5D3A),
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Review",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
