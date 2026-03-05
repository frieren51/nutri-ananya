import 'dart:convert';
import 'package:http/http.dart' as http;

class DirectionsService {
  final String apiKey;

  DirectionsService(this.apiKey);

  Future<Map<String, dynamic>> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$originLat,$originLng'
        '&destination=$destLat,$destLng'
        '&mode=driving'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    final route = data['routes'][0];
    final leg = route['legs'][0];

    return {
      'distance': leg['distance']['text'],
      'duration': leg['duration']['text'],
      'polyline': route['overview_polyline']['points'],
    };
  }
}
