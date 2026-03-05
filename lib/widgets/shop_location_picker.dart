import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart'
    as places;
import 'package:geocoding/geocoding.dart';

class ShopLocationPicker extends StatefulWidget {
  const ShopLocationPicker({super.key});

  @override
  State<ShopLocationPicker> createState() => _ShopLocationPickerState();
}

class _ShopLocationPickerState extends State<ShopLocationPicker> {
  // ⚠️ Replace with your actual API Key
  static const String apiKey = "AIzaSyBDO4GfLs27UsEUz8ON9MLTVgbTrX7LwoQ";

  GoogleMapController? _mapController;
  LatLng _centerLatLng = const LatLng(28.6139, 77.2090); // Default: Delhi
  String _address = "Locating...";
  bool _isFetching = false;

  late final places.FlutterGooglePlacesSdk _places;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _places = places.FlutterGooglePlacesSdk(apiKey);
    // Fetch initial address after frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAddressFromLatLng(_centerLatLng);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Fetch Address from Coordinates ---
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    setState(() => _isFetching = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _address =
              "${p.name}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea} ${p.postalCode}";
          _centerLatLng = latLng;
        });
      }
    } catch (e) {
      debugPrint("Geocoding Error: $e");
      setState(() => _address = "Address not found");
    } finally {
      setState(() => _isFetching = false);
    }
  }

  // --- Search Place via Autocomplete ---
  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;

    final response = await _places.findAutocompletePredictions(
      query,
      countries: ["in"],
    );

    if (!mounted || response.predictions.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView.builder(
        itemCount: response.predictions.length,
        itemBuilder: (context, index) {
          final p = response.predictions[index];
          return ListTile(
            leading: const Icon(Icons.location_on, color: Colors.red),
            title: Text(p.fullText),
            onTap: () async {
              Navigator.pop(context);
              final details = await _places.fetchPlace(
                p.placeId,
                fields: [places.PlaceField.Location],
              );
              if (details.place?.latLng != null) {
                final newPos = LatLng(
                  details.place!.latLng!.lat,
                  details.place!.latLng!.lng,
                );
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(newPos, 16),
                );
              }
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Shop Location",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for area or street...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _searchPlace,
            ),
          ),

          // 🗺 MAP SECTION
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _centerLatLng,
                    zoom: 15,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onCameraMove: (position) {
                    _centerLatLng = position.target;
                  },
                  onCameraIdle: () {
                    _getAddressFromLatLng(_centerLatLng);
                  },
                ),

                // 📍 CENTER PIN (Stays fixed while map moves)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: const Icon(
                      Icons.location_on,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ),

                // 🏠 BOTTOM ADDRESS CARD
                Positioned(
                  bottom: 20,
                  left: 15,
                  right: 15,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.map, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _isFetching ? "Locating..." : _address,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isFetching
                                  ? null
                                  : () {
                                      Navigator.pop(context, {
                                        "latlng": _centerLatLng,
                                        "address": _address,
                                      });
                                    },
                              child: const Text(
                                "Confirm Shop Location",
                                style: TextStyle(fontSize: 16),
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
          ),
        ],
      ),
    );
  }
}
