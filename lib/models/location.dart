import 'package:spo_balaesang/utils/app_const.dart';

class Location {
  const Location({this.latitude, this.longitude, this.address});

  final double latitude;
  final double longitude;
  final String address;

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
        latitude: double.parse(json[locationLatitudeField].toString()),
        longitude: double.parse(json[locationLongitudeField].toString()),
        address: json[locationAddressField] as String);
  }

  Map<String, dynamic> toJson() => {
        locationLatitudeField: latitude,
        locationLongitudeField: longitude,
        locationAddressField: address
      };
}
