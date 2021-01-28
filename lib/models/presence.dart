import 'package:spo_balaesang/models/location.dart';
import 'package:spo_balaesang/utils/app_const.dart';

class Presence {
  const Presence(
      {this.id,
      this.date,
      this.codeType,
      this.status,
      this.attendTime,
      this.location,
      this.photo,
      this.startTime,
      this.endTime});

  final int id;
  final DateTime date;
  final String codeType;
  final String status;
  final String attendTime;
  final DateTime startTime;
  final DateTime endTime;
  final Location location;
  final String photo;

  factory Presence.fromJson(Map<String, dynamic> json) {
    return Presence(
      id: json[userIdField] as int,
      date: DateTime.parse(json[presenceDateField].toString()),
      codeType: json[presenceCodeTypeField] as String,
      status: json[presenceStatusField] as String,
      attendTime: json[presenceAttendTimeField] as String,
      location: Location.fromJson(
          json[presenceLocationField] as Map<String, dynamic>),
      photo: json[presencePhotoField] as String,
      startTime: DateTime.parse(json[presenceStartTimeField].toString()),
      endTime: DateTime.parse(json[presenceEndTimeField].toString()),
    );
  }
}
