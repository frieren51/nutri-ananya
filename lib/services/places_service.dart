import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  final String apiKey;

  PlacesService(this.apiKey);

  Future<List<dynamic>> searchPlaces(String input) async {
    if (input.isEmpty) return [];

    // 1. Encode the input to handle spaces and special characters
    final encodedInput = Uri.encodeComponent(input);

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$encodedInput'
        '&types=geocode' // Optional: restricts results to actual addresses
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        return data['predictions'];
      } else {
        print("Places API Error: ${data['status']}");
        return [];
      }
    } catch (e) {
      print("Network Error: $e");
      return [];
    }
  }

  Future<Map<String, double>?> getPlaceLatLng(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry' // 2. Critical: Only fetch fields you need to save money
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['result'] != null) {
        final loc = data['result']['geometry']['location'];
        return {
          'lat': (loc['lat'] as num).toDouble(),
          'lng': (loc['lng'] as num).toDouble(),
        };
      }
      return null;
    } catch (e) {
      print("Error fetching place details: $e");
      return null;
    }
  }
}
