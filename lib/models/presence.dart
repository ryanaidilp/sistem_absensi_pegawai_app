import 'package:spo_balaesang/models/location.dart';

class Presence {
  const Presence(
      {this.date,
      this.codeType,
      this.status,
      this.attendTime,
      this.location,
      this.photo,
      this.startTime,
      this.endTime});

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
      date: DateTime.parse(json['date'].toString()),
      codeType: json['code_type'] as String,
      status: json['status'] as String,
      attendTime: json['attend_time'] as String,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      photo: json['photo'] as String,
      startTime: DateTime.parse(json['start_time'].toString()),
      endTime: DateTime.parse(json['end_time'].toString()),
    );
  }
}
