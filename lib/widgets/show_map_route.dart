import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopRouteMap extends StatefulWidget {
  final LatLng shopLatLng;

  const ShopRouteMap({super.key, required this.shopLatLng});

  @override
  State<ShopRouteMap> createState() => _ShopRouteMapState();
}

class _ShopRouteMapState extends State<ShopRouteMap> {
  // ⚠️ Ensure 'Directions API' is enabled in Google Cloud Console
  static const String apiKey = "AIzaSyBDO4GfLs27UsEUz8ON9MLTVgbTrX7LwoQ";

  GoogleMapController? _mapController;
  LatLng? _userLatLng;
  Set<Polyline> _polylines = {};
  String _distance = "Calculatig...";
  String _duration = "Calculating...";

  @override
  void initState() {
    super.initState();
    _initRoute();
  }

  Future<void> _initRoute() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _userLatLng = LatLng(pos.latitude, pos.longitude);
      });
      await _fetchRoute();
      _fitBounds(); // Auto-zoom to show full route
    }
  }

  Future<void> _fetchRoute() async {
    if (_userLatLng == null) return;

    final url =
        "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${_userLatLng!.latitude},${_userLatLng!.longitude}"
        "&destination=${widget.shopLatLng.latitude},${widget.shopLatLng.longitude}"
        "&mode=driving"
        "&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final route = data['routes'][0];
        final leg = route['legs'][0];

        setState(() {
          _distance = leg['distance']['text'];
          _duration = leg['duration']['text'];
        });

        final points = PolylinePoints().decodePolyline(
          route['overview_polyline']['points'],
        );

        final polyline = Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blueAccent,
          width: 6,
          points: points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        );

        setState(() {
          _polylines = {polyline};
        });
      }
    } catch (e) {
      debugPrint("Route Fetch Error: $e");
    }
  }

  // Helper to make both points visible on screen
  void _fitBounds() {
    if (_mapController == null || _userLatLng == null) return;

    LatLngBounds bounds;
    if (_userLatLng!.latitude > widget.shopLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: widget.shopLatLng,
        northeast: _userLatLng!,
      );
    } else {
      bounds = LatLngBounds(
        southwest: _userLatLng!,
        northeast: widget.shopLatLng,
      );
    }

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _openGoogleMaps() async {
    // Standard Google Maps Navigation URL
    final String url =
        "https://www.google.com/maps/dir/?api=1"
        "&origin=${_userLatLng!.latitude},${_userLatLng!.longitude}"
        "&destination=${widget.shopLatLng.latitude},${widget.shopLatLng.longitude}"
        "&travelmode=driving";

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Route", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _userLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _userLatLng!,
                    zoom: 14,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: {
                    Marker(
                      markerId: const MarkerId("shop"),
                      position: widget.shopLatLng,
                      infoWindow: const InfoWindow(title: "Shop Location"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  },
                ),

                // Overlay ETA Card
                Positioned(
                  bottom: 20,
                  left: 15,
                  right: 15,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _infoItem(Icons.timer, _duration, "Time"),
                              _infoItem(
                                Icons.directions_car,
                                _distance,
                                "Distance",
                              ),
                            ],
                          ),
                          const Divider(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _openGoogleMaps,
                              icon: const Icon(Icons.navigation),
                              label: const Text("Start Live Navigation"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
