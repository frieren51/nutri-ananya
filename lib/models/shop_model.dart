class ShopModel {
  final String uid;
  final String shopNo;
  final String shopName;
  final String shopAddress;
  final double lat; // New
  final double lng; // New

  ShopModel({
    required this.uid,
    required this.shopNo,
    required this.shopName,
    required this.shopAddress,
    required this.lat,
    required this.lng,
  });

  factory ShopModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return ShopModel(
      uid: id,
      shopNo: map['shopNo'] ?? 'N/A',
      shopName: map['shopName'] ?? 'Unknown',
      shopAddress: map['shopAddress'] ?? 'No Address',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
