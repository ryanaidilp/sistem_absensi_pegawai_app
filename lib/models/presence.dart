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
      id: json[USER_ID_FIELD] as int,
      date: DateTime.parse(json[PRESENCE_DATE_FIELD].toString()),
      codeType: json[PRESENCE_CODE_TYPE_FIELD] as String,
      status: json[PRESENCE_STATUS_FIELD] as String,
      attendTime: json[PRESENCE_ATTEND_TIME_FIELD] as String,
      location: Location.fromJson(
          json[PRESENCE_LOCATION_FIELD] as Map<String, dynamic>),
      photo: json[PRESENCE_PHOTO_FIELD] as String,
      startTime: DateTime.parse(json[PRESENCE_START_TIME_FIELD].toString()),
      endTime: DateTime.parse(json[PRESENCE_END_TIME_FIELD].toString()),
    );
  }
}
