class Location {
  const Location({this.latitude, this.longitude, this.address});

  final double latitude;
  final double longitude;
  final String address;

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
        latitude: double.parse(json['latitude'].toString()),
        longitude: double.parse(json['longitude'].toString()),
        address: json['address'] as String);
  }
}
