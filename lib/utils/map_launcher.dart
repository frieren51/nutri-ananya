import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps({
  required double userLat,
  required double userLng,
  required double destLat,
  required double destLng,
}) async {
  // Use the official Google Maps Directions API URL format
  final String url =
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$userLat,$userLng'
      '&destination=$destLat,$destLng'
      '&travelmode=driving';

  final Uri uri = Uri.parse(url);

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode
            .externalApplication, // Opens the actual Maps app if installed
      );
    } else {
      throw 'Could not launch Google Maps';
    }
  } catch (e) {
    print('Error launching maps: $e');
  }
}
