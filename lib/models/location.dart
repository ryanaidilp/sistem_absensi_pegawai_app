import 'package:spo_balaesang/utils/app_const.dart';

class Location {
  const Location({this.latitude, this.longitude, this.address});

  final double latitude;
  final double longitude;
  final String address;

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
        latitude: double.parse(json[LOCATION_LATITUDE_FIELD].toString()),
        longitude: double.parse(json[LOCATION_LONGITUDE_FIELD].toString()),
        address: json[LOCATION_ADDRESS_FIELD] as String);
  }
}
